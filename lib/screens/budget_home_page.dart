import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../database/db_helper.dart';

class BudgetHomePage extends StatefulWidget {
  @override
  _BudgetHomePageState createState() => _BudgetHomePageState();
}

class _BudgetHomePageState extends State<BudgetHomePage> {
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _expenseTitleController = TextEditingController();
  final TextEditingController _expenseAmountController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double? monthlySalary;
  final Map<String, List<Expense>> monthlyHistory = {};
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final savedSalary = await loadSalary();
    final expenses = await DBHelper.getAllExpenses();

    setState(() {
      monthlySalary = savedSalary;
      monthlyHistory[currentMonth] = expenses;
    });
  }

  String get currentMonth =>
      "${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}";

  void _setSalary() {
    if (_salaryController.text.isEmpty) return;
    final salary = double.tryParse(_salaryController.text);
    if (salary == null) return;

    setState(() {
      monthlySalary = salary;
      monthlyHistory.putIfAbsent(currentMonth, () => []);
    });

    saveSalary(salary);
  }


  Future<void> _loadExpenses() async {
    final expenses = await DBHelper.getAllExpenses();
    setState(() {
      monthlyHistory[currentMonth] = expenses;
    });
  }

  Future<void> _addExpense() async {
    if (_expenseTitleController.text.isEmpty || _expenseAmountController.text.isEmpty) return;

    final expense = Expense(
      title: _expenseTitleController.text,
      amount: double.tryParse(_expenseAmountController.text) ?? 0,
      date: DateTime.now(),
    );

    // 1️⃣ Ajouter dans SQLite
    await DBHelper.insertExpense(expense);

    // 2️⃣ Recharger les dépenses
    final expenses = await DBHelper.getAllExpenses();
    setState(() {
      monthlyHistory[currentMonth] = expenses;
    });

    // 3️⃣ Nettoyer les champs
    _expenseTitleController.clear();
    _expenseAmountController.clear();
    Navigator.pop(context);
  }


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

  void _showAddExpenseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Nouvelle dépense",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _expenseTitleController,
              decoration: InputDecoration(
                labelText: "Titre de dépense",
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _expenseAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Montant (DH)",
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Ajouter", style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> saveSalary(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthlySalary', value);
  }

  Future<double?> loadSalary() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('monthlySalary');
  }


  Widget _buildDashboard() {
    if (monthlySalary == null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_wallet, size: 64, color: Colors.indigo),
                  const SizedBox(height: 20),
                  const Text(
                    "Bienvenue !",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Entrez votre salaire mensuel pour commencer",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _salaryController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Salaire mensuel (DH)",
                      prefixIcon: const Icon(Icons.monetization_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _setSalary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Commencer", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final remaining = monthlySalary! - _totalExpenses(currentMonth);
    final percentageUsed = (monthlySalary! > 0)
        ? (_totalExpenses(currentMonth) / monthlySalary!) * 100
        : 0.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Budget Status Card
          Container(
            padding: EdgeInsets.all(24),
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
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getBudgetStatusMessage(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Reste",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${remaining.toStringAsFixed(2)} DH",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.trending_up, color: Colors.white, size: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Salaire",
                  "${monthlySalary!.toStringAsFixed(2)} DH",
                  Icons.account_balance_wallet,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "Dépensé",
                  "${_totalExpenses(currentMonth).toStringAsFixed(2)} DH",
                  Icons.shopping_cart,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Progress Bar
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Utilisation du budget",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentageUsed / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(_getBudgetStatusColor()),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "${percentageUsed.toStringAsFixed(1)}% utilisé",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Recent Expenses
          Text(
            "Dépenses récentes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          if ((monthlyHistory[currentMonth]?.length ?? 0) == 0)
            Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 48, color: Colors.grey[300]),
                    SizedBox(height: 12),
                    Text(
                      "Aucune dépense ce mois-ci",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ...monthlyHistory[currentMonth]!.map((expense) {
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_downward, color: Colors.red),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${expense.date.day}/${expense.date.month}/${expense.date.year}",
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "-${expense.amount.toStringAsFixed(2)} DH",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildHistoryPage() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          "Historique des mois",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        if (monthlyHistory.isEmpty)
          Center(
            child: Column(
              children: [
                SizedBox(height: 60),
                Icon(Icons.history, size: 64, color: Colors.grey[300]),
                SizedBox(height: 16),
                Text(
                  "Aucun historique",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          )
        else
          ...monthlyHistory.keys.map((month) {
            final total = monthlyHistory[month]!.fold(0.0, (sum, e) => sum + e.amount);
            final remaining = (monthlySalary ?? 0) - total; // Reste pour ce mois
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.indigo[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.calendar_month, color: Colors.indigo),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              month,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "${monthlyHistory[month]!.length} dépenses",
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Reste: ${remaining.toStringAsFixed(2)} DH",
                              style: TextStyle(color: Colors.green[700], fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "Dépensé: ${total.toStringAsFixed(2)} DH",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),

      ],
    );
  }


  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Budget Manager', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.indigo),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.indigo[50],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo, Colors.indigo[700]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 48, color: Colors.white),
                    const SizedBox(height: 12),
                    const Text(
                      'Budget Manager',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentMonth,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.dashboard, color: _selectedIndex == 0 ? Colors.indigo : Colors.grey),
                title: Text(
                  'Tableau de bord',
                  style: TextStyle(
                    fontWeight: _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: _selectedIndex == 0,
                selectedTileColor: Colors.indigo[100],
                onTap: () {
                  setState(() => _selectedIndex = 0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.history, color: _selectedIndex == 1 ? Colors.indigo : Colors.grey),
                title: Text(
                  'Historique',
                  style: TextStyle(
                    fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: _selectedIndex == 1,
                selectedTileColor: Colors.indigo[100],
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              if (monthlySalary != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        monthlySalary = null;
                        _salaryController.clear();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Nouveau mois"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: _selectedIndex == 0 ? _buildDashboard() : _buildHistoryPage(),
      floatingActionButton: monthlySalary != null && _selectedIndex == 0
          ? FloatingActionButton.extended(
        onPressed: _showAddExpenseDialog,
        icon: const Icon(Icons.add),
        label: const Text("Dépense"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      )
          : null,
    );
  }
}

