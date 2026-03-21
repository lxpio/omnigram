import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/enums/lang_list.dart';
import 'package:omnigram/service/translate/index.dart';
import 'package:omnigram/widgets/common/axis_flex.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'dart:async';

class TranslationMenu extends StatefulWidget {
  const TranslationMenu({
    super.key,
    required this.content,
    required this.decoration,
    required this.axis,
    this.contextText,
  });
  final String content;
  final BoxDecoration decoration;
  final Axis axis;
  final String? contextText;

  @override
  State<TranslationMenu> createState() => _TranslationMenuState();
}

class _TranslationMenuState extends State<TranslationMenu> {
  Widget? _translationWidget;
  Timer? _debounceTimer;
  bool _translationInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeTranslation();
  }

  void _initializeTranslation() {
    // Use addPostFrameCallback to ensure the UI is rendered first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _translationInitialized) return;

      // Debounce: Delay the translation call to ensure context has stopped updating
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (!mounted || _translationInitialized) return;

        setState(() {
          final effectiveContextText =
              (widget.contextText?.trim().isEmpty ?? true)
                  ? null
                  : widget.contextText;
          _translationWidget = translateText(
            widget.content,
            contextText: effectiveContextText,
          );
          _translationInitialized = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Widget _langPicker(bool isFrom) {
    final MenuController menuController = MenuController();

    return PointerInterceptor(
      child: MenuAnchor(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.secondaryContainer,
          ),
          maximumSize: WidgetStateProperty.all(const Size(300, 300)),
        ),
        controller: menuController,
        menuChildren: [
          for (var lang in LangListEnum.values)
            PointerInterceptor(
              child: MenuItemButton(
                onPressed: () {
                  if (isFrom) {
                    Prefs().translateFrom = lang;
                  } else {
                    Prefs().translateTo = lang;
                  }
                },
                child: Text(lang.getNative(context)),
              ),
            ),
        ],
        builder: (context, controller, child) {
          return GestureDetector(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: Text(
              isFrom
                  ? Prefs().translateFrom.getNative(context)
                  : Prefs().translateTo.getNative(context),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // print('Building TranslationMenu');
    return Expanded(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Container(
          height: widget.axis == Axis.vertical ? double.infinity : 150,
          width: widget.axis == Axis.vertical ? 100 : double.infinity,
          decoration: widget.decoration,
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.content,
                  style: const TextStyle(
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show translation widget if initialized, otherwise show loading placeholder
                    _translationWidget ??
                        const SizedBox(
                          height: 20,
                          child: Center(child: Text('...')),
                        ),
                    const Divider(),
                    AxisFlex(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      axis: widget.axis,
                      children: [
                        _langPicker(true),
                        Transform.rotate(
                            angle: widget.axis == Axis.horizontal ? 0 : 1.57,
                            child: Icon(Icons.arrow_forward_ios, size: 16)),
                        _langPicker(false),
                        if (widget.axis == Axis.horizontal) const Spacer(),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
