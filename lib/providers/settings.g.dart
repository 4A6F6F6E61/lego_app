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

String _$userTokenHash() => r'7fa9cdc9830491a61aa8af972f020eb4670edb91';

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

String _$rebrickableApiKeyHash() => r'6e542d123ed3e672be53a09b7e9121b7df2b2c0f';

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
