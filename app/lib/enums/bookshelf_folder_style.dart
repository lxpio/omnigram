enum BookshelfFolderStyle {
  stacked('stacked'),
  grid2x2('grid2x2');

  const BookshelfFolderStyle(this.code);

  final String code;

  static BookshelfFolderStyle fromCode(String code) {
    return BookshelfFolderStyle.values.firstWhere((e) => e.code == code,
        orElse: () => BookshelfFolderStyle.stacked);
  }
}
