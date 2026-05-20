class TunnelEntry {
  final String id;
  final String sessionId;
  final int localPort;
  final String remoteHost;
  final int remotePort;
  final String? label;

  const TunnelEntry({
    required this.id,
    required this.sessionId,
    required this.localPort,
    required this.remoteHost,
    required this.remotePort,
    this.label,
  });

  String get displayLabel =>
      label?.isNotEmpty == true ? label! : '→ $remoteHost:$remotePort';

  String get localAddress => '127.0.0.1:$localPort';

  static String generateId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${Object().hashCode.abs()}';
}
