// Create a new file named spending_model.dart

class SpendingData {
  final Map<String, double> categorySpending;
  final double totalSpending;

  SpendingData({
    required this.categorySpending,
    required this.totalSpending,
  });

  // Create a new instance with updated values for a category
  SpendingData addSpending(String category, double amount) {
    final newCategorySpending = Map<String, double>.from(categorySpending);
    newCategorySpending[category] =
        (newCategorySpending[category] ?? 0) + amount;

    return SpendingData(
      categorySpending: newCategorySpending,
      totalSpending: totalSpending + amount,
    );
  }

  // Calculate percentages for each category
  Map<String, int> getCategoryPercentages() {
    final Map<String, int> percentages = {};

    if (totalSpending > 0) {
      categorySpending.forEach((category, amount) {
        percentages[category] = ((amount / totalSpending) * 100).round();
      });
    }

    return percentages;
  }

  // Factory method to create from Firestore data
  factory SpendingData.fromFirestore(Map<String, dynamic> data) {
    return SpendingData(
      categorySpending:
          Map<String, double>.from(data['categorySpending'] ?? {}),
      totalSpending: data['totalSpending'] ?? 0.0,
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'categorySpending': categorySpending,
      'totalSpending': totalSpending,
    };
  }
}
