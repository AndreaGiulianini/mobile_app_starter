import 'dart:async';

import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

class AuthStore = AuthStoreBase with _$AuthStore;

abstract class AuthStoreBase with Store {
  @observable
  String? token;

  @observable
  String? refreshToken;

  @observable
  bool tokenVerified = false;

  @action
  Future<void> init() async {
    unawaited(verifyAuthToken());
  }

  @action
  void deleteToken() {
    token = null;
    refreshToken = null;
    tokenVerified = false;
  }

  @action
  Future<void> verifyAuthToken() async {}
}
