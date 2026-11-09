class Payee {
  final String name;
  final String bank;
  const Payee(this.name, this.bank);

  String get initials {
    final parts = name.split(' ');
    return parts.length == 1
        ? parts[0].substring(0, 1)
        : '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}';
  }
}

const List<Payee> payees = [
  Payee('Rohan Mehta', 'HDFC \u2022\u2022 2231'),
  Payee('Priya Nair', 'SBI \u2022\u2022 8890'),
  Payee('Karthik Reddy', 'ICICI \u2022\u2022 4417'),
  Payee('Ananya Das', 'Axis \u2022\u2022 1203'),
  Payee('Mom', 'SBI \u2022\u2022 7781'),
];
