class AuthState {
  final bool isLoggedIn;
  final String? errorMessage;
  AuthState({this.errorMessage, this.isLoggedIn = false});
}
