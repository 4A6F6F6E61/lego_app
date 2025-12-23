// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserToken)
const userTokenProvider = UserTokenProvider._();

final class UserTokenProvider
    extends $AsyncNotifierProvider<UserToken, String?> {
  const UserTokenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userTokenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userTokenHash();

  @$internal
  @override
  UserToken create() => UserToken();
}

String _$userTokenHash() => r'e82f34a8c436843111e4b0dcf04c6f8f9fc82e3b';

abstract class _$UserToken extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(RebrickableApiKey)
const rebrickableApiKeyProvider = RebrickableApiKeyProvider._();

final class RebrickableApiKeyProvider
    extends $AsyncNotifierProvider<RebrickableApiKey, String?> {
  const RebrickableApiKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rebrickableApiKeyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rebrickableApiKeyHash();

  @$internal
  @override
  RebrickableApiKey create() => RebrickableApiKey();
}

String _$rebrickableApiKeyHash() => r'70f65ff0311054cc2213d188bb50fc15d9b9e503';

abstract class _$RebrickableApiKey extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(BricksetApiKey)
const bricksetApiKeyProvider = BricksetApiKeyProvider._();

final class BricksetApiKeyProvider
    extends $AsyncNotifierProvider<BricksetApiKey, String?> {
  const BricksetApiKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bricksetApiKeyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bricksetApiKeyHash();

  @$internal
  @override
  BricksetApiKey create() => BricksetApiKey();
}

String _$bricksetApiKeyHash() => r'd9512e4e57f8b9a78e05f7ca61e2b75fd8538008';

abstract class _$BricksetApiKey extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
