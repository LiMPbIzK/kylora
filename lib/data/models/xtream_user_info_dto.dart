/// DTO del bloque `user_info` devuelto por `player_api.php`.
class XtreamUserInfoDto {
  const XtreamUserInfoDto({
    required this.username,
    required this.status,
    this.expiresAt,
    this.maxConnections,
    this.activeConnections,
  });

  final String username;
  final String status;
  final DateTime? expiresAt;
  final int? maxConnections;
  final int? activeConnections;

  factory XtreamUserInfoDto.fromJson(Map<String, dynamic> json) {
    return XtreamUserInfoDto(
      username: json['username'] as String? ?? '',
      status: json['status'] as String? ?? '',
      expiresAt: _parseUnixTimestamp(json['exp_date']),
      maxConnections: _parseInt(json['max_connections']),
      activeConnections: _parseInt(json['active_conns']),
    );
  }

  static DateTime? _parseUnixTimestamp(dynamic value) {
    if (value == null) return null;
    final String str = value.toString();
    if (str.isEmpty || str == '0') return null;
    final int? seconds = int.tryParse(str);
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }
}
