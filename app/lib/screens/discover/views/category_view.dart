import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Category {
  const Category(this.icon, this.label);
  final Icon icon;
  final String label;
  // final String route;
}

const List<Category> destinations = <Category>[
  Category(Icon(Icons.book), 'all'),
  Category(Icon(Icons.explore), 'discover'),
  Category(Icon(Icons.messenger_outline_rounded), 'chat'),
  Category(Icon(Icons.person), 'profile'),
];

class CategoryView extends HookConsumerWidget {
  const CategoryView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
