// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on AuthStoreBase, Store {
  late final _$tokenAtom = Atom(name: 'AuthStoreBase.token', context: context);

  @override
  String? get token {
    _$tokenAtom.reportRead();
    return super.token;
  }

  @override
  set token(String? value) {
    _$tokenAtom.reportWrite(value, super.token, () {
      super.token = value;
    });
  }

  late final _$refreshTokenAtom = Atom(name: 'AuthStoreBase.refreshToken', context: context);

  @override
  String? get refreshToken {
    _$refreshTokenAtom.reportRead();
    return super.refreshToken;
  }

  @override
  set refreshToken(String? value) {
    _$refreshTokenAtom.reportWrite(value, super.refreshToken, () {
      super.refreshToken = value;
    });
  }

  late final _$tokenVerifiedAtom = Atom(name: 'AuthStoreBase.tokenVerified', context: context);

  @override
  bool get tokenVerified {
    _$tokenVerifiedAtom.reportRead();
    return super.tokenVerified;
  }

  @override
  set tokenVerified(bool value) {
    _$tokenVerifiedAtom.reportWrite(value, super.tokenVerified, () {
      super.tokenVerified = value;
    });
  }

  late final _$initAsyncAction = AsyncAction('AuthStoreBase.init', context: context);

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$verifyAuthTokenAsyncAction = AsyncAction('AuthStoreBase.verifyAuthToken', context: context);

  @override
  Future<void> verifyAuthToken() {
    return _$verifyAuthTokenAsyncAction.run(() => super.verifyAuthToken());
  }

  late final _$AuthStoreBaseActionController = ActionController(name: 'AuthStoreBase', context: context);

  @override
  void deleteToken() {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(name: 'AuthStoreBase.deleteToken');
    try {
      return super.deleteToken();
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
token: ${token},
refreshToken: ${refreshToken},
tokenVerified: ${tokenVerified}
    ''';
  }
}
