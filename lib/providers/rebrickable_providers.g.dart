// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rebrickable_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(colors)
const colorsProvider = ColorsProvider._();

final class ColorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, Color>>,
          Map<int, Color>,
          FutureOr<Map<int, Color>>
        >
    with $FutureModifier<Map<int, Color>>, $FutureProvider<Map<int, Color>> {
  const ColorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'colorsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$colorsHash();

  @$internal
  @override
  $FutureProviderElement<Map<int, Color>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<int, Color>> create(Ref ref) {
    return colors(ref);
  }
}

String _$colorsHash() => r'9cc0ba125ba8e0a9e4b89c13b281593b941c9590';
