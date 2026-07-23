/// Price formatting (Design Review Initiative 7). Single source of truth for
/// the currency-symbol table that was copy-pasted across the two product tiles
/// (imagedetailed_main / imagedetailed_top_raited) and itemcard2.

/// Symbol for an ISO-4217 code; falls back to the code itself, then ''.
String currencySymbol(String? code) {
  const symbols = {
    'ARS': 'AR\$',
    'CAD': 'CA\$',
    'CLP': 'CL\$',
    'CNY': '¥',
    'COP': 'CO\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'KRW': '₩',
    'MXN': 'MX\$',
    'PEN': 'S/',
    'RUB': '₽',
    'USD': '\$',
  };
  return symbols[code] ?? code ?? '';
}

/// Formats a price as "<symbol><rounded amount>", e.g. `$12`, `€8`.
String formatPrice(double price, String? code) =>
    '${currencySymbol(code)}${price.round()}';
