class PaymentRequest {
  final double amount;
  final DateTime paymentDate;

  PaymentRequest({required this.amount, required this.paymentDate});

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'payment_date': paymentDate.toIso8601String().split('T').first,
      };
}