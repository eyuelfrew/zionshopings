import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  const CustomSearchBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40, // Make it smaller
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.5)
                  : const Color(0xFFFFC0CB).withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: const Color(0xFFFF69B4), // Pink color
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onTap: onTap,
                decoration: const InputDecoration(
                  hintText: 'Search for products...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 14,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                ),
                readOnly: true, // Make it read-only to trigger navigation on tap
              ),
            ),
          ],
        ),
      ),
    );
  }
}
