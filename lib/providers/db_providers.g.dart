// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sets)
const setsProvider = SetsProvider._();

final class SetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LegoSet>>,
          List<LegoSet>,
          Stream<List<LegoSet>>
        >
    with $FutureModifier<List<LegoSet>>, $StreamProvider<List<LegoSet>> {
  const SetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setsHash();

  @$internal
  @override
  $StreamProviderElement<List<LegoSet>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LegoSet>> create(Ref ref) {
    return sets(ref);
  }
}

String _$setsHash() => r'ac2622b01e5e7b46ba1b4cc352c6f4b0f60d1fa4';

@ProviderFor(setParts)
const setPartsProvider = SetPartsFamily._();

final class SetPartsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SetPart>>,
          List<SetPart>,
          Stream<List<SetPart>>
        >
    with $FutureModifier<List<SetPart>>, $StreamProvider<List<SetPart>> {
  const SetPartsProvider._({
    required SetPartsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'setPartsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$setPartsHash();

  @override
  String toString() {
    return r'setPartsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SetPart>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SetPart>> create(Ref ref) {
    final argument = this.argument as String;
    return setParts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SetPartsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$setPartsHash() => r'7fe9870b18e4f206c60aa9df91595303cf949bb9';

final class SetPartsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SetPart>>, String> {
  const SetPartsFamily._()
    : super(
        retry: null,
        name: r'setPartsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SetPartsProvider call(String setId) =>
      SetPartsProvider._(argument: setId, from: this);

  @override
  String toString() => r'setPartsProvider';
}

@ProviderFor(set)
const setProvider = SetFamily._();

final class SetProvider
    extends
        $FunctionalProvider<AsyncValue<LegoSet?>, LegoSet?, Stream<LegoSet?>>
    with $FutureModifier<LegoSet?>, $StreamProvider<LegoSet?> {
  const SetProvider._({
    required SetFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'setProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$setHash();

  @override
  String toString() {
    return r'setProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<LegoSet?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<LegoSet?> create(Ref ref) {
    final argument = this.argument as String;
    return set(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SetProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$setHash() => r'e106ec2e8530daf8af494e860a3208b27c4b478c';

final class SetFamily extends $Family
    with $FunctionalFamilyOverride<Stream<LegoSet?>, String> {
  const SetFamily._()
    : super(
        retry: null,
        name: r'setProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SetProvider call(String setId) => SetProvider._(argument: setId, from: this);

  @override
  String toString() => r'setProvider';
}
