import 'package:flutter/material.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 38});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(
        Icons.eco_outlined,
        color: Colors.white,
        size: size * 0.56,
      ),
    );
  }
}
