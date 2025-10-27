import 'package:firstapp/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import '../models/expense.dart';

class Dashboard extends StatelessWidget {
  final double? monthlySalary;
  final Map<String, List<Expense>> monthlyHistory;
  final String currentMonth;

  const Dashboard({
    required this.monthlySalary,
    required this.monthlyHistory,
    required this.currentMonth,
  });

  double _totalExpenses(String month) {
    final expenses = monthlyHistory[month] ?? [];
    return expenses.fold(0, (sum, e) => sum + e.amount);
  }

  Color _getBudgetStatusColor() {
    if (monthlySalary == null) return Colors.grey;
    final remaining = monthlySalary! - _totalExpenses(currentMonth);
    final percentageLeft = (remaining / monthlySalary!) * 100;
    if (percentageLeft > 50) return Colors.green;
    if (percentageLeft > 20) return Colors.orange;
    return Colors.red;
  }

  String _getBudgetStatusMessage() {
    if (monthlySalary == null) return "Pas de budget défini";
    final remaining = monthlySalary! - _totalExpenses(currentMonth);
    final percentageLeft = (remaining / monthlySalary!) * 100;
    if (remaining < 0) return "⚠️ Budget dépassé !";
    if (percentageLeft > 70) return "✅ Excellente gestion !";
    if (percentageLeft > 50) return "👍 Bonne gestion";
    if (percentageLeft > 20) return "⚡ Attention aux dépenses";
    return "🔴 Budget critique !";
  }

  @override
  Widget build(BuildContext context) {
    if (monthlySalary == null) {
      return const Center(
        child: Text("Veuillez définir un salaire mensuel."),
      );
    }
    final remaining = monthlySalary! - _totalExpenses(currentMonth);
    final percentageUsed = (monthlySalary! > 0)
        ? (_totalExpenses(currentMonth) / monthlySalary!) * 100
        : 0.0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Budget Status Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_getBudgetStatusColor(), _getBudgetStatusColor().withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _getBudgetStatusColor().withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getBudgetStatusMessage(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Reste",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${remaining.toStringAsFixed(2)} DH",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.trending_up, color: Colors.white, size: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: "Salaire",
                  value: "${monthlySalary!.toStringAsFixed(2)} DH",
                  icon: Icons.account_balance_wallet,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: "Dépensé",
                  value: "${_totalExpenses(currentMonth).toStringAsFixed(2)} DH",
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Utilisation du budget",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentageUsed / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(_getBudgetStatusColor()),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${percentageUsed.toStringAsFixed(1)}% utilisé",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Recent Expenses
          const Text(
            "Dépenses récentes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if ((monthlyHistory[currentMonth]?.length ?? 0) == 0)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      "Aucune dépense ce mois-ci",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ...monthlyHistory[currentMonth]!.map((expense) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_downward, color: Colors.red),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${expense.date.day}/${expense.date.month}/${expense.date.year}",
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "-${expense.amount.toStringAsFixed(2)} DH",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
