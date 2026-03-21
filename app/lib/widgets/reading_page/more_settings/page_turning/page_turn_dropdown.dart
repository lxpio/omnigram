import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/widgets/common/anx_dropdown_button.dart';
import 'package:omnigram/widgets/reading_page/more_settings/page_turning/diagram.dart';
import 'package:flutter/material.dart';

class PageTurnDropdown extends StatelessWidget {
  const PageTurnDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final PageTurningType value;
  final ValueChanged<PageTurningType?> onChanged;

  String _getLabel(BuildContext context, PageTurningType type) {
    switch (type) {
      case PageTurningType.none:
        return L10n.of(context).pageTurnActionNone;
      case PageTurningType.prev:
        return L10n.of(context).pageTurnActionPrev;
      case PageTurningType.next:
        return L10n.of(context).pageTurnActionNext;
      case PageTurningType.menu:
        return L10n.of(context).pageTurnActionMenu;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnxDropdownButton<PageTurningType>(
      value: value,
      items: PageTurningType.values
          .map((type) => DropdownItem<PageTurningType>(
                value: type,
                label: _getLabel(context, type),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
