String formatPrice(double price) {
  final priceStr = price.toStringAsFixed(0);
  if (priceStr.length > 3) {
    return priceStr.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
  return priceStr;
}