class DeviceSyncPayload {
  final String action; // 'SYNC_DEVICE' or 'LOGOUT_DEVICE'
  final String clientId;
  final String? idToken;
  final String? deviceToken;
  final String? clientName;

  const DeviceSyncPayload({
    this.action = 'SYNC_DEVICE',
    required this.clientId,
    this.idToken,
    this.deviceToken,
    this.clientName,
  });

  Map<String, dynamic> toJson() => {
        'action': action,
        'clientId': clientId,
        if (idToken != null) 'idToken': idToken,
        if (deviceToken != null) 'deviceToken': deviceToken,
        if (clientName != null) 'clientName': clientName,
      };

  factory DeviceSyncPayload.fromJson(Map<String, dynamic> json) => DeviceSyncPayload(
        action: json['action'] as String? ?? 'SYNC_DEVICE',
        clientId: json['clientId'] as String? ?? '',
        idToken: json['idToken'] as String?,
        deviceToken: json['deviceToken'] as String?,
        clientName: json['clientName'] as String?,
      );
}
