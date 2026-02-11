class LoginRequestModel {
  final String username;
  final String password;
  final bool remember;

  LoginRequestModel({
    required this.username,
    required this.password,
    this.remember = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'remember': remember,
    };
  }
}
