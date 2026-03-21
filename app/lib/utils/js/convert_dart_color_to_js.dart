String convertDartColorToJs(String dartColor) {
  // convert color from AABBGGRR to RRGGBBAA
  if (dartColor.length < 8) {
    return dartColor;
  }
  return dartColor.substring(2) + dartColor.substring(0, 2);
}
