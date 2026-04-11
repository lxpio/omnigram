/// Universal voice identifier: "source:voiceId"
/// Examples: edge:zh-CN-XiaoxiaoNeural, sherpa:kokoro-multi-lang-v1_0:47
class VoiceFullId {
  final String source;
  final String voiceId;

  const VoiceFullId({required this.source, required this.voiceId});

  factory VoiceFullId.parse(String fullId) {
    final colonIndex = fullId.indexOf(':');
    if (colonIndex < 0) return VoiceFullId(source: 'edge', voiceId: fullId);
    return VoiceFullId(
      source: fullId.substring(0, colonIndex),
      voiceId: fullId.substring(colonIndex + 1),
    );
  }

  factory VoiceFullId.from(String serviceId, String shortName) {
    return VoiceFullId(source: serviceId, voiceId: shortName);
  }

  @override
  String toString() => '$source:$voiceId';

  @override
  bool operator ==(Object other) =>
      other is VoiceFullId && source == other.source && voiceId == other.voiceId;

  @override
  int get hashCode => Object.hash(source, voiceId);
}
