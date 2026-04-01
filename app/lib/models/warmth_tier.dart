enum WarmthTier {
  low,
  mid,
  high;

  static WarmthTier fromWarmth(int warmth) {
    if (warmth <= 33) return WarmthTier.low;
    if (warmth <= 66) return WarmthTier.mid;
    return WarmthTier.high;
  }
}
