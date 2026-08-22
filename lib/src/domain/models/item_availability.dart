enum ItemAvailability {
  inStock('https://schema.org/InStock'),
  outOfStock('https://schema.org/OutOfStock'),
  onlineOnly('https://schema.org/OnlineOnly'),
  inStoreOnly('https://schema.org/InStoreOnly'),
  preOrder('https://schema.org/PreOrder'),
  preSale('https://schema.org/PreSale'),
  limitedAvailability('https://schema.org/LimitedAvailability'),
  soldOut('https://schema.org/SoldOut'),
  discontinued('https://schema.org/Discontinued');

  final String schemaUrl;
  const ItemAvailability(this.schemaUrl);

  bool get isAvailable =>
      this == ItemAvailability.inStock ||
      this == ItemAvailability.onlineOnly ||
      this == ItemAvailability.inStoreOnly ||
      this == ItemAvailability.limitedAvailability;

  static ItemAvailability parse(dynamic rawValue) {
    if (rawValue == null) return ItemAvailability.inStock;

    final str = rawValue.toString().toLowerCase().trim();

    if (str.contains('outofstock') || str.contains('out of stock')) {
      return ItemAvailability.outOfStock;
    }
    if (str.contains('soldout') || str.contains('sold out')) {
      return ItemAvailability.soldOut;
    }
    if (str.contains('discontinued')) {
      return ItemAvailability.discontinued;
    }
    if (str.contains('preorder') || str.contains('pre-order')) {
      return ItemAvailability.preOrder;
    }
    if (str.contains('presale') || str.contains('pre-sale')) {
      return ItemAvailability.preSale;
    }
    if (str.contains('onlineonly')) {
      return ItemAvailability.onlineOnly;
    }
    if (str.contains('instoreonly')) {
      return ItemAvailability.inStoreOnly;
    }
    if (str.contains('limitedavailability')) {
      return ItemAvailability.limitedAvailability;
    }

    return ItemAvailability.inStock;
  }
}
