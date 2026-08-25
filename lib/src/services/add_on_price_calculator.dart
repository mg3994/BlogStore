import '../domain/models/product_add_on.dart';

class AddOnPriceCalculator {
  /// Calculates total unit price = basePrice + sum of selected add-on adjustments.
  static double calculateUnitPrice({
    required double basePrice,
    required List<SelectedAddOn> selectedAddOns,
  }) {
    double total = basePrice;
    for (final addOn in selectedAddOns) {
      total += addOn.totalPriceAdjustment;
    }
    return total;
  }

  /// Calculates total price for a given quantity.
  static double calculateTotalPrice({
    required double basePrice,
    required List<SelectedAddOn> selectedAddOns,
    int quantity = 1,
  }) {
    final unitPrice = calculateUnitPrice(
      basePrice: basePrice,
      selectedAddOns: selectedAddOns,
    );
    return unitPrice * quantity;
  }

  /// Validates whether all required groups have met their `minSelect` criteria.
  static Map<String, String> validateGroupSelections({
    required List<AddOnGroup> groups,
    required List<SelectedAddOn> selectedAddOns,
  }) {
    final Map<String, String> errors = {};

    for (final group in groups) {
      final selectedInGroup = selectedAddOns.where((s) => s.groupId == group.id).toList();

      if (group.isRequired && selectedInGroup.length < group.minSelect) {
        errors[group.id] = 'Please select at least ${group.minSelect} option(s)';
      } else if (selectedInGroup.length > group.maxSelect) {
        errors[group.id] = 'Please select at most ${group.maxSelect} option(s)';
      }

      // Check nested choices for chosen options
      for (final selected in selectedInGroup) {
        final optionModel = group.options.firstWhere(
          (o) => o.id == selected.optionId,
          orElse: () => AddOnOption(id: selected.optionId, name: selected.optionName),
        );

        if (optionModel.nestedGroups.isNotEmpty) {
          final nestedErrors = validateGroupSelections(
            groups: optionModel.nestedGroups,
            selectedAddOns: selected.selectedSubAddOns,
          );
          errors.addAll(nestedErrors);
        }
      }
    }

    return errors;
  }
}
