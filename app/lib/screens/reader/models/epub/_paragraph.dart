import 'package:html/dom.dart' as dom;

class Paragraph {
  Paragraph(this.element);

  final dom.Element element;
  // final int chapterIndex;
}

class Range {
  Range(this.start, this.end);

  final int start;
  final int end;
}
