import 'package:flutter/material.dart';

class PowerSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onClear;
  final List<String> activeLabels;
  final ValueChanged<String>? onRemoveLabel;

  const PowerSearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.onClear,
    this.activeLabels = const [],
    this.onRemoveLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: 'Search or type label:category...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        if (onClear != null) onClear!();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ),
        if (activeLabels.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: activeLabels.map((label) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text('label:$label'),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: onRemoveLabel != null ? () => onRemoveLabel!(label) : null,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
