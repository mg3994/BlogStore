import 'package:flutter/material.dart';
import '../domain/models/product_add_on.dart';
import '../services/schema_i18n_resolver.dart';

class NestedAddOnSelector extends StatelessWidget {
  final List<AddOnGroup> groups;
  final List<SelectedAddOn> selectedAddOns;
  final ValueChanged<List<SelectedAddOn>> onChanged;
  final Map<String, String> errorMessages;

  const NestedAddOnSelector({
    super.key,
    required this.groups,
    required this.selectedAddOns,
    required this.onChanged,
    this.errorMessages = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.map((group) {
        return _buildGroup(context, group);
      }).toList(),
    );
  }

  Widget _buildGroup(BuildContext context, AddOnGroup group) {
    final groupTitle = SchemaI18nResolver.resolve(group.title);
    final errorMessage = errorMessages[group.id];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: errorMessage != null
            ? BorderSide(color: Theme.of(context).colorScheme.error)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    groupTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (group.isRequired)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Required',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              group.isSingleSelect
                  ? 'Select 1 option'
                  : 'Select up to ${group.maxSelect} options',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                errorMessage,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
            const Divider(height: 16),
            ...group.options.map((option) => _buildOptionRow(context, group, option)),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(BuildContext context, AddOnGroup group, AddOnOption option) {
    final optionName = SchemaI18nResolver.resolve(option.name);
    final isSelected = selectedAddOns.any((s) => s.groupId == group.id && s.optionId == option.id);
    final currentSelection = isSelected
        ? selectedAddOns.firstWhere((s) => s.groupId == group.id && s.optionId == option.id)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (group.isSingleSelect)
          RadioListTile<String>(
            value: option.id,
            groupValue: currentSelection?.optionId,
            title: Text(optionName),
            secondary: option.priceAdjustment > 0
                ? Text(
                    '+${option.currency} ${option.priceAdjustment.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  )
                : null,
            onChanged: (val) {
              if (val != null) {
                final updated = selectedAddOns.where((s) => s.groupId != group.id).toList();
                updated.add(SelectedAddOn(
                  groupId: group.id,
                  optionId: option.id,
                  optionName: optionName,
                  priceAdjustment: option.priceAdjustment,
                ));
                onChanged(updated);
              }
            },
          )
        else
          CheckboxListTile(
            value: isSelected,
            title: Text(optionName),
            secondary: option.priceAdjustment > 0
                ? Text(
                    '+${option.currency} ${option.priceAdjustment.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  )
                : null,
            onChanged: (checked) {
              final updated = List<SelectedAddOn>.from(selectedAddOns);
              if (checked == true) {
                updated.add(SelectedAddOn(
                  groupId: group.id,
                  optionId: option.id,
                  optionName: optionName,
                  priceAdjustment: option.priceAdjustment,
                ));
              } else {
                updated.removeWhere((s) => s.groupId == group.id && s.optionId == option.id);
              }
              onChanged(updated);
            },
          ),
        if (isSelected && currentSelection != null && option.nestedGroups.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 4, bottom: 8),
            child: NestedAddOnSelector(
              groups: option.nestedGroups,
              selectedAddOns: currentSelection.selectedSubAddOns,
              onChanged: (subSelections) {
                final updated = List<SelectedAddOn>.from(selectedAddOns);
                final index = updated.indexWhere((s) => s.groupId == group.id && s.optionId == option.id);
                if (index != -1) {
                  updated[index] = SelectedAddOn(
                    groupId: group.id,
                    optionId: option.id,
                    optionName: optionName,
                    priceAdjustment: option.priceAdjustment,
                    selectedSubAddOns: subSelections,
                  );
                  onChanged(updated);
                }
              },
              errorMessages: errorMessages,
            ),
          ),
      ],
    );
  }
}
