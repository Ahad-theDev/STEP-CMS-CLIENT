class FeeStructureUpdateRequest {
  final double? amount;
  final bool? isActive;

  FeeStructureUpdateRequest({this.amount, this.isActive});

  Map<String, dynamic> toJson() => {
        if (amount != null) 'amount': amount,
        if (isActive != null) 'is_active': isActive,
      };
}