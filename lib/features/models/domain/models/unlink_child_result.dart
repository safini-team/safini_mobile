class UnlinkChildResult {
  const UnlinkChildResult({
    required this.unlinked,
    required this.childAccountDeleted,
  });

  final bool unlinked;
  final bool childAccountDeleted;

  factory UnlinkChildResult.fromJson(Map<String, dynamic> json) {
    return UnlinkChildResult(
      unlinked: json['unlinked'] == true,
      childAccountDeleted: json['child_account_deleted'] == true,
    );
  }
}
