class Account {
  final String domain;
  final String login;
  final String password;
  bool revealed;

  Account({
    required this.domain,
    required this.login,
    required this.password,
    this.revealed = false,
  });
}
