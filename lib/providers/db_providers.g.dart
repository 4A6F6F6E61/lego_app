// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(setsStream)
const setsStreamProvider = SetsStreamProvider._();

final class SetsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LegoSet>>,
          List<LegoSet>,
          Stream<List<LegoSet>>
        >
    with $FutureModifier<List<LegoSet>>, $StreamProvider<List<LegoSet>> {
  const SetsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<LegoSet>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LegoSet>> create(Ref ref) {
    return setsStream(ref);
  }
}

String _$setsStreamHash() => r'91c2ebe39ca09083c3872db8f7c6854430e16c08';

@ProviderFor(setPartsStream)
const setPartsStreamProvider = SetPartsStreamFamily._();

final class SetPartsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SetPart>>,
          List<SetPart>,
          Stream<List<SetPart>>
        >
    with $FutureModifier<List<SetPart>>, $StreamProvider<List<SetPart>> {
  const SetPartsStreamProvider._({
    required SetPartsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'setPartsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$setPartsStreamHash();

  @override
  String toString() {
    return r'setPartsStreamProvider'
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
    return setPartsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SetPartsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$setPartsStreamHash() => r'a3c984e778513836c49760c9cb6e63cd10ae38c8';

final class SetPartsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SetPart>>, String> {
  const SetPartsStreamFamily._()
    : super(
        retry: null,
        name: r'setPartsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SetPartsStreamProvider call(String setId) =>
      SetPartsStreamProvider._(argument: setId, from: this);

  @override
  String toString() => r'setPartsStreamProvider';
}

@ProviderFor(setParts)
const setPartsProvider = SetPartsFamily._();

final class SetPartsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SetPart>>,
          List<SetPart>,
          FutureOr<List<SetPart>>
        >
    with $FutureModifier<List<SetPart>>, $FutureProvider<List<SetPart>> {
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
  $FutureProviderElement<List<SetPart>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SetPart>> create(Ref ref) {
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

String _$setPartsHash() => r'562fa0c5b302372907c7f9bc9d3ffe328796309a';

final class SetPartsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SetPart>>, String> {
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

@ProviderFor(setStream)
const setStreamProvider = SetStreamFamily._();

final class SetStreamProvider
    extends
        $FunctionalProvider<AsyncValue<LegoSet?>, LegoSet?, Stream<LegoSet?>>
    with $FutureModifier<LegoSet?>, $StreamProvider<LegoSet?> {
  const SetStreamProvider._({
    required SetStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'setStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$setStreamHash();

  @override
  String toString() {
    return r'setStreamProvider'
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
    return setStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SetStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$setStreamHash() => r'eb501dfc634fc87af3a275739f60e95ef0fbf3dd';

final class SetStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<LegoSet?>, String> {
  const SetStreamFamily._()
    : super(
        retry: null,
        name: r'setStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SetStreamProvider call(String setId) =>
      SetStreamProvider._(argument: setId, from: this);

  @override
  String toString() => r'setStreamProvider';
}

@ProviderFor(setAllPartsToFound)
const setAllPartsToFoundProvider = SetAllPartsToFoundFamily._();

final class SetAllPartsToFoundProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  const SetAllPartsToFoundProvider._({
    required SetAllPartsToFoundFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'setAllPartsToFoundProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$setAllPartsToFoundHash();

  @override
  String toString() {
    return r'setAllPartsToFoundProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return setAllPartsToFound(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SetAllPartsToFoundProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$setAllPartsToFoundHash() =>
    r'2075ec1f7a427820c20eeb7c40a08799becba680';

final class SetAllPartsToFoundFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  const SetAllPartsToFoundFamily._()
    : super(
        retry: null,
        name: r'setAllPartsToFoundProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SetAllPartsToFoundProvider call(String setId) =>
      SetAllPartsToFoundProvider._(argument: setId, from: this);

  @override
  String toString() => r'setAllPartsToFoundProvider';
}
