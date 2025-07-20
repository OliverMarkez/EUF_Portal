import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_sidebar.dart';
import '../services/transaction_service.dart';
import '../providers/auth_provider.dart';

const double kMobileBreakpoint = 800.0;

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  static const String routeName = '/reports';

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedTimeframe = 'Day';
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  // Simulated Data for reports
  final Map<String, Map<String, int>> _touristCounts = {
    'Day': {
      'Regular': 150,
      'Senior Citizen': 30,
      'PWDs': 10,
      'Children': 50,
      'Resident': 20,
    },
    'Week': {
      'Regular': 1050,
      'Senior Citizen': 210,
      'PWDs': 70,
      'Children': 350,
      'Resident': 140,
    },
    'Month': {
      'Regular': 4500,
      'Senior Citizen': 900,
      'PWDs': 300,
      'Children': 1500,
      'Resident': 600,
    },
  };

  final Map<String, double> _collectedFees = {
    'Day': 18500.00,
    'Week': 129500.00,
    'Month': 555000.00,
  };

  final Map<String, Map<String, double>> _revenueBreakdown = {
    'Day': {
      'Regular': 18000.00,
      'Senior Citizen': 2880.00,
      'PWDs': 960.00,
      'Children': 0.00,
      'Resident': 0.00,
    },
    'Week': {
      'Regular': 126000.00,
      'Senior Citizen': 20160.00,
      'PWDs': 6720.00,
      'Children': 0.00,
      'Resident': 0.00,
    },
    'Month': {
      'Regular': 540000.00,
      'Senior Citizen': 108000.00,
      'PWDs': 36000.00,
      'Children': 0.00,
      'Resident': 0.00,
    },
  };

  final Map<String, double> _averageFeePerTourist = {
    'Day': 92.50,
    'Week': 92.50,
    'Month': 92.50,
  };

  // Add these state variables to _ReportsPageState
  String _sortBy = 'Date Descending';
  String? _categoryFilter;
  DateTimeRange? _dateRange;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTransactionData();
  }

  Future<void> _loadTransactionData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Load transactions
      final transactions = await TransactionService.getTransactions(
        authProvider: authProvider,
      );

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading transaction data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < kMobileBreakpoint) {
              return AppBar(
                title: const Text('Reports'),
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
              );
            }
            return Container();
          },
        ),
      ),
      drawer: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < kMobileBreakpoint) {
            return const AppSidebar(isDrawer: true);
          }
          return const SizedBox.shrink();
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < kMobileBreakpoint;
          if (isMobile) {
            // Mobile layout
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _buildMainContent(context, isMobile: true),
            );
          } else {
            // Desktop/Tablet layout
            return Row(
              children: [
                const AppSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 0,
                          bottom: 0,
                        ),
                        child: _PageHeader(title: 'Reports'),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: _buildMainContent(context, isMobile: false),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, {required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTotalsOverview(context, isMobile: isMobile),
        const SizedBox(height: 24),
        _buildTimeframeSelector(),
        const SizedBox(height: 30),
        _buildSectionHeader('Tourist Categories Overview'),
        const SizedBox(height: 16),
        _buildTouristCategoryCards(
          _touristCounts[_selectedTimeframe] ?? {},
          isMobile: isMobile,
        ),
        const SizedBox(height: 30),
        _buildSectionHeader('Revenue Breakdown by Category'),
        const SizedBox(height: 16),
        _buildCard(
          context,
          child: _buildRevenueBreakdown(
            _revenueBreakdown[_selectedTimeframe] ?? {},
          ),
        ),
        const SizedBox(height: 30),
        _buildSectionHeader('Average Fee per Tourist'),
        const SizedBox(height: 16),
        _buildCard(
          context,
          child: _buildAverageFeeDisplay(
            _averageFeePerTourist[_selectedTimeframe] ?? 0.0,
          ),
        ),
        const SizedBox(height: 30),
        _buildSectionHeader('Recent Transactions'),
        const SizedBox(height: 16),
        _buildCard(context, child: Column(
          children: [
            _buildTransactionControls(),
            const SizedBox(height: 16),
            _buildRecentTransactionsList(isMobile: isMobile),
          ],
        )),
      ],
    );
  }

  Widget _buildTotalsOverview(BuildContext context, {required bool isMobile}) {
    final totalTourists =
        (_touristCounts[_selectedTimeframe]?.values.fold(
          0,
          (sum, count) => sum + count,
        )) ??
        0;
    final totalFees = _collectedFees[_selectedTimeframe] ?? 0.0;
    String formattedFees = totalFees
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
    final cardPadding = isMobile
        ? const EdgeInsets.symmetric(vertical: 16, horizontal: 10)
        : const EdgeInsets.symmetric(vertical: 20, horizontal: 24);
    final valueFontSize = isMobile ? 28.0 : 36.0;
    final labelFontSize = isMobile ? 13.0 : 15.0;
    final cardRadius = isMobile ? 14.0 : 18.0;
    final valueSpacing = isMobile ? 2.0 : 6.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            padding: cardPadding,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Total Tourist Arrival',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: labelFontSize,
                  ),
                ),
                SizedBox(height: valueSpacing),
                Text(
                  '$totalTourists',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    fontSize: valueFontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: cardPadding,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Total Amount Collected',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: labelFontSize,
                  ),
                ),
                SizedBox(height: valueSpacing),
                Text(
                  '₱$formattedFees',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                    fontSize: valueFontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTouristCategoryCards(
    Map<String, int> counts, {
    required bool isMobile,
  }) {
    if (counts.isEmpty) {
      return const Center(child: Text('No data available for this timeframe.'));
    }
    final cards = counts.entries
        .map(
          (entry) => _buildSmallCategoryCard(
            entry.key,
            entry.value,
            isMobile: isMobile,
          ),
        )
        .toList();
    if (isMobile) {
      return SizedBox(
        height: 125, // Increased height for mobile
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cards.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) => cards[i],
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: cards
            .map(
              (card) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: card,
              ),
            )
            .toList(),
      );
    }
  }

  Widget _buildSmallCategoryCard(
    String category,
    int count, {
    required bool isMobile,
  }) {
    IconData icon;
    Color iconColor;
    switch (category) {
      case 'Regular':
        icon = Icons.people;
        iconColor = Colors.purple;
        break;
      case 'Senior Citizen':
        icon = Icons.elderly;
        iconColor = Colors.orange;
        break;
      case 'PWDs':
        icon = Icons.accessible;
        iconColor = Colors.blue;
        break;
      case 'Children':
        icon = Icons.child_care;
        iconColor = Colors.amber;
        break;
      case 'Resident':
        icon = Icons.home;
        iconColor = Colors.brown;
        break;
      default:
        icon = Icons.person;
        iconColor = Colors.grey;
    }
    final cardWidth = isMobile ? 110.0 : 110.0;
    final cardHeight = isMobile ? 115.0 : 120.0;
    final iconSize = isMobile ? 24.0 : 28.0;
    final countFontSize = isMobile ? 20.0 : 22.0;
    final labelFontSize = isMobile ? 11.0 : 12.0;
    final spacing1 = isMobile ? 6.0 : 6.0;
    final spacing2 = isMobile ? 1.0 : 1.0;
    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: iconSize),
          SizedBox(height: spacing1),
          Text(
            '$count',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: countFontSize,
            ),
          ),
          SizedBox(height: spacing2),
          Text(
            category,
            style: TextStyle(fontSize: labelFontSize, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: child,
    );
  }

  Widget _buildTimeframeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('View Data:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: _selectedTimeframe,
          dropdownColor: Theme.of(context).cardColor,
          style: Theme.of(context).textTheme.titleMedium,
          underline: Container(height: 0, color: Colors.transparent),
          items: <String>['Day', 'Week', 'Month'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedTimeframe = newValue!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRevenueBreakdown(Map<String, double> revenueData) {
    if (revenueData.isEmpty) {
      return const Center(
        child: Text('No revenue data available for this timeframe.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: revenueData.entries.map((entry) {
        final String category = entry.key;
        final double amount = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$category:', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                '₱ ${amount.toStringAsFixed(2)}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAverageFeeDisplay(double averageFee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average Fee per Tourist:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '₱ ${averageFee.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 36,
            color: Colors.lightBlueAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionControls() {
    final categories = _transactions
        .map((t) => t['tourist_category'] as String?)
        .where((cat) => cat != null)
        .toSet()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sort Dropdown
              DropdownButton<String>(
                value: _sortBy,
                items: [
                  'Date Descending',
                  'Date Ascending',
                  'Amount Descending',
                  'Amount Ascending',
                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _sortBy = val!),
              ),
              const SizedBox(width: 16),
              // Category Filter
              DropdownButton<String>(
                value: _categoryFilter,
                hint: const Text('All Categories'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Categories'),
                  ),
                  ...categories.map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat!),
                  )),
                ],
                onChanged: (val) => setState(() => _categoryFilter = val),
              ),
              const SizedBox(width: 16),
              // Date Range Picker
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: _dateRange,
                  );
                  if (picked != null) setState(() => _dateRange = picked);
                },
                child: Text(_dateRange == null
                    ? 'Select Date Range'
                    : '${_dateRange!.start.month}/${_dateRange!.start.day}/${_dateRange!.start.year} - ${_dateRange!.end.month}/${_dateRange!.end.day}/${_dateRange!.end.year}'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search by Receipt ID, Staff, or Category',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredSortedTransactions() {
    var filtered = _transactions;

    // Filter by category
    if (_categoryFilter != null) {
      filtered = filtered.where((t) => t['tourist_category'] == _categoryFilter).toList();
    }

    // Filter by date range
    if (_dateRange != null) {
      filtered = filtered.where((t) {
        final date = DateTime.parse(t['created_at']);
        return !date.isBefore(_dateRange!.start) && !date.isAfter(_dateRange!.end);
      }).toList();
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((t) =>
        (t['receipt_id'] ?? '').toString().toLowerCase().contains(q) ||
        (t['staff_encoder'] ?? '').toString().toLowerCase().contains(q) ||
        (t['tourist_category'] ?? '').toString().toLowerCase().contains(q)
      ).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'Date Ascending':
        filtered.sort((a, b) => a['created_at'].compareTo(b['created_at']));
        break;
      case 'Amount Descending':
        filtered.sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));
        break;
      case 'Amount Ascending':
        filtered.sort((a, b) => (a['amount'] as num).compareTo(b['amount'] as num));
        break;
      default: // Date Descending
        filtered.sort((a, b) => b['created_at'].compareTo(a['created_at']));
    }

    return filtered;
  }

  Widget _buildRecentTransactionsList({bool isMobile = false}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredTransactions = _getFilteredSortedTransactions();

    if (filteredTransactions.isEmpty) {
      return const Center(
        child: Text(
          'No transactions found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (isMobile) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredTransactions.take(10).length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final transaction = filteredTransactions[index];
          final receiptId = transaction['receipt_id'] ?? 'N/A';
          final category = transaction['tourist_category'] ?? 'Unknown';
          final count = transaction['count'] ?? 0;
          final amount = transaction['amount'] ?? 0.0;
          final staffEncoder = transaction['staff_encoder'] ?? 'Unknown';
          final createdAt = transaction['created_at'] != null
              ? DateTime.parse(transaction['created_at'])
              : DateTime.now();

          return Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          receiptId.toString().substring(receiptId.toString().length - 3),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '$category - $count person(s)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '₱${amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.receipt, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Receipt: $receiptId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 8),
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Staff: $staffEncoder', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Spacer(),
                      Text(
                        '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Desktop/tablet layout (unchanged)
    return Column(
      children: filteredTransactions.take(10).map((transaction) {
        final receiptId = transaction['receipt_id'] ?? 'N/A';
        final category = transaction['tourist_category'] ?? 'Unknown';
        final count = transaction['count'] ?? 0;
        final amount = transaction['amount'] ?? 0.0;
        final staffEncoder = transaction['staff_encoder'] ?? 'Unknown';
        final createdAt = transaction['created_at'] != null
            ? DateTime.parse(transaction['created_at'])
            : DateTime.now();

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(
                receiptId.toString().substring(receiptId.toString().length - 3),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              '$category - $count person(s)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Receipt: $receiptId | Staff: $staffEncoder',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₱${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  const _PageHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.blueAccent,
              size: 28,
            ),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blueGrey.shade100,
            child: const Icon(Icons.person, color: Colors.blueGrey, size: 24),
          ),
        ],
      ),
    );
  }
}
