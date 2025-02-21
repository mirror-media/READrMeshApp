import 'package:flutter/material.dart';

class CategoryEditItem extends StatelessWidget {
  const CategoryEditItem(
      {super.key, required this.title, required this.isSelect});

  final String title;
  final bool isSelect;

  @override
  Widget build(BuildContext context) {
    return Flexible(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
      child: Text(title),
    ));
  }
}
