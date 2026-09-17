import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:lego_app/api/services/brickset_api.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class InstructionPdfService {
  const InstructionPdfService();

  String getInstructionFileName(String setNum, LegoInstruction instruction) {
    final safeSet = setNum.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final safeDesc = instruction.description
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final urlHash = instruction.url.hashCode.toUnsigned(32).toRadixString(16).padLeft(8, '0');
    return '${safeSet}_${safeDesc}_$urlHash.pdf';
  }

  Future<File> getLocalInstructionFile(
    String setNum,
    LegoInstruction instruction, {
    Directory? baseDir,
  }) async {
    final rootDir = baseDir ?? await getApplicationDocumentsDirectory();
    final instructionsDir = Directory('${rootDir.path}/instructions');
    if (!instructionsDir.existsSync()) {
      await instructionsDir.create(recursive: true);
    }
    final filename = getInstructionFileName(setNum, instruction);
    return File('${instructionsDir.path}/$filename');
  }

  Future<bool> isInstructionDownloaded(
    String setNum,
    LegoInstruction instruction, {
    Directory? baseDir,
  }) async {
    try {
      final file = await getLocalInstructionFile(setNum, instruction, baseDir: baseDir);
      return file.existsSync() && await file.length() > 0;
    } catch (_) {
      return false;
    }
  }

  Future<int> getDownloadedFileSize(
    String setNum,
    LegoInstruction instruction, {
    Directory? baseDir,
  }) async {
    try {
      final file = await getLocalInstructionFile(setNum, instruction, baseDir: baseDir);
      if (file.existsSync()) {
        return await file.length();
      }
    } catch (_) {}
    return 0;
  }

  Future<File> downloadInstruction({
    required String setNum,
    required LegoInstruction instruction,
    void Function(double progress, int receivedBytes, int totalBytes)? onProgress,
    http.Client? client,
    bool Function()? isCancelled,
    Directory? baseDir,
  }) async {
    final targetFile = await getLocalInstructionFile(setNum, instruction, baseDir: baseDir);
    if (targetFile.existsSync() && await targetFile.length() > 0) {
      final size = await targetFile.length();
      onProgress?.call(1.0, size, size);
      return targetFile;
    }

    final tempFile = File('${targetFile.path}.tmp');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }

    final httpClient = client ?? http.Client();
    final shouldCloseClient = client == null;

    try {
      final request = http.Request('GET', Uri.parse(instruction.url));
      final response = await httpClient.send(request);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: Failed to download instruction PDF');
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;
      final sink = tempFile.openWrite();

      try {
        await for (final chunk in response.stream) {
          if (isCancelled?.call() == true) {
            throw Exception('Download cancelled');
          }
          sink.add(chunk);
          receivedBytes += chunk.length;
          final progress = totalBytes > 0 ? (receivedBytes / totalBytes).clamp(0.0, 1.0) : -1.0;
          onProgress?.call(progress, receivedBytes, totalBytes);
        }
      } finally {
        await sink.flush();
        await sink.close();
      }

      if (isCancelled?.call() == true) {
        if (tempFile.existsSync()) await tempFile.delete();
        throw Exception('Download cancelled');
      }

      if (tempFile.existsSync() && await tempFile.length() > 0) {
        if (targetFile.existsSync()) {
          await targetFile.delete();
        }
        await tempFile.rename(targetFile.path);
        return targetFile;
      } else {
        throw Exception('Downloaded file was empty');
      }
    } catch (e) {
      if (tempFile.existsSync()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      rethrow;
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
    }
  }

  Future<OpenResult> openPdfFile(File file) async {
    return await OpenFilex.open(file.path);
  }

  Future<bool> fallbackOpenInBrowser(LegoInstruction instruction) async {
    return await launchUrl(
      Uri.parse(instruction.url),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> deleteCachedInstruction(String setNum, LegoInstruction instruction) async {
    try {
      final file = await getLocalInstructionFile(setNum, instruction);
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (_) {}
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    final i = (log(bytes) / log(1024)).floor().clamp(0, suffixes.length - 1);
    final value = bytes / pow(1024, i);
    return '${value.toStringAsFixed(1)} ${suffixes[i]}';
  }
}

const instructionPdfService = InstructionPdfService();
