import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:provider/provider.dart';
import '../services/transaction_service.dart';
import '../providers/auth_provider.dart';
import 'dart:math';

const double kMobileBreakpoint = 800.0;

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  int regularCount = 0;
  int seniorCitizenCount = 0;
  int pwdsCount = 0;
  int childrenCount = 0;
  int residentCount = 0;

  final double regularPrice = 120.0;
  final double seniorCitizenPrice = 96.0; // 20% discount
  final double childrenPrice = 0.0; // Exempt
  final double pwdsPrice = 0.0; // Exempt
  final double residentPrice = 0.0; // Exempt

  // Controllers for manual input
  final TextEditingController _regularController = TextEditingController();
  final TextEditingController _seniorController = TextEditingController();
  final TextEditingController _pwdsController = TextEditingController();
  final TextEditingController _childrenController = TextEditingController();
  final TextEditingController _residentController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  double _cash = 0.0;
  bool _isVerified = false;
  bool _isVerifying = false;
  bool _isProcessing = false;
  int _receiptNumber = 0;
  String? _actualReceiptId;
  String? _staffEncoder;

  @override
  void initState() {
    super.initState();
    _regularController.text = regularCount.toString();
    _seniorController.text = seniorCitizenCount.toString();
    _pwdsController.text = pwdsCount.toString();
    _childrenController.text = childrenCount.toString();
    _residentController.text = residentCount.toString();
    _receiptNumber = 1000 + Random().nextInt(9000); // random 4-digit
  }

  @override
  void dispose() {
    _regularController.dispose();
    _seniorController.dispose();
    _pwdsController.dispose();
    _childrenController.dispose();
    _residentController.dispose();
    _cashController.dispose();
    super.dispose();
  }

  void _resetTransactionData() {
    setState(() {
      // Reset all counts
      regularCount = 0;
      seniorCitizenCount = 0;
      pwdsCount = 0;
      childrenCount = 0;
      residentCount = 0;

      // Reset cash and verification
      _cash = 0.0;
      _isVerified = false;
      _isVerifying = false;
      _isProcessing = false;

      // Reset receipt data
      _actualReceiptId = null;
      _staffEncoder = null;

      // Reset controllers
      _regularController.text = '0';
      _seniorController.text = '0';
      _pwdsController.text = '0';
      _childrenController.text = '0';
      _residentController.text = '0';
      _cashController.text = '';

      // Generate new receipt number
      _receiptNumber = 1000 + Random().nextInt(9000);
    });
  }

  double get totalAmount {
    return (regularCount * regularPrice) +
        (seniorCitizenCount * seniorCitizenPrice) +
        (pwdsCount * pwdsPrice) +
        (childrenCount * childrenPrice) +
        (residentCount * residentPrice);
  }

  double get change => (_cash - totalAmount) >= 0 ? (_cash - totalAmount) : 0.0;

  @override
  Widget build(BuildContext context) {
    // Always update _staffEncoder from AuthProvider before building receipt
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    _staffEncoder = currentUser?['username'] ?? 'Unknown';
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < kMobileBreakpoint) {
              return AppBar(
                title: const Text('Transaction'),
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
          final bool isMobile = constraints.maxWidth < kMobileBreakpoint;
          if (isMobile) {
            // Mobile layout
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTouristCategoriesSection(context),
                  const SizedBox(height: 24),
                  _buildReceiptDisplaySection(context, processed: false),
                ],
              ),
            );
          } else {
            // Desktop/Tablet layout
            return Row(
              children: [
                const AppSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      // Top header at the very top
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 0,
                          bottom: 0,
                        ),
                        child: _PageHeader(title: 'Transaction'),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildTouristCategoriesSection(context),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 2,
                                child: _buildReceiptDisplaySection(
                                  context,
                                  processed: false,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildTouristCategoriesSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Tourist Categories',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              _buildCategoryRow('Regular', regularCount, (value) {
                setState(() => regularCount = value);
                _regularController.text = value.toString();
              }, _regularController),
              _buildCategoryRow('Senior Citizen', seniorCitizenCount, (value) {
                setState(() => seniorCitizenCount = value);
                _seniorController.text = value.toString();
              }, _seniorController),
              _buildCategoryRow('PWDs', pwdsCount, (value) {
                setState(() => pwdsCount = value);
                _pwdsController.text = value.toString();
              }, _pwdsController),
              _buildCategoryRow('Children', childrenCount, (value) {
                setState(() => childrenCount = value);
                _childrenController.text = value.toString();
              }, _childrenController),
              _buildCategoryRow('Resident', residentCount, (value) {
                setState(() => residentCount = value);
                _residentController.text = value.toString();
              }, _residentController),
              const SizedBox(height: 30),
              _buildAmountDisplay(
                'Total Amount',
                '₱ ${totalAmount.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 10),
              _buildAmountDisplay(
                'Cash',
                null,
                valueWidget: SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _cashController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter cash',
                      prefixIcon: Icon(Icons.payments),
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _cash = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildAmountDisplay('Change', '₱ ${change.toStringAsFixed(2)}'),
              const SizedBox(height: 10),
              _buildAmountDisplay(
                'Amount Collected',
                '₱ ${_cash.toStringAsFixed(2)}',
                isVerified: _isVerified,
                showVerifyButton: true,
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 400 ||
                      MediaQuery.of(context).size.width < kMobileBreakpoint) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: (!_isVerified || _isProcessing)
                              ? null
                              : () async {
                                  setState(() {
                                    _isProcessing = true;
                                  });

                                  final authProvider =
                                      Provider.of<AuthProvider>(
                                        context,
                                        listen: false,
                                      );
                                  final currentUser = authProvider.currentUser;
                                  final staffUsername =
                                      currentUser?['username'];
                                  if (currentUser == null ||
                                      staffUsername == null ||
                                      staffUsername.isEmpty) {
                                    setState(() {
                                      _isProcessing = false;
                                    });
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                          'Authentication Error',
                                        ),
                                        content: const Text(
                                          'You must be logged in as a staff member to process transactions.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                    return;
                                  }
                                  _staffEncoder = staffUsername;
                                  try {
                                    // Process each category as separate transactions
                                    if (regularCount > 0) {
                                      final result =
                                          await TransactionService.createTransaction(
                                            touristCategory: 'Regular',
                                            count: regularCount,
                                            amount: regularCount * regularPrice,
                                            cash: _cash,
                                            changeAmount: change,
                                            authProvider: authProvider,
                                          );
                                      // Store the receipt_id from the first transaction
                                      if (_actualReceiptId == null) {
                                        _actualReceiptId =
                                            result?['receipt_id'];
                                      }
                                    }

                                    if (seniorCitizenCount > 0) {
                                      await TransactionService.createTransaction(
                                        touristCategory: 'Senior Citizen',
                                        count: seniorCitizenCount,
                                        amount:
                                            seniorCitizenCount *
                                            seniorCitizenPrice,
                                        cash: _cash,
                                        changeAmount: change,
                                        authProvider: authProvider,
                                      );
                                    }

                                    if (pwdsCount > 0) {
                                      await TransactionService.createTransaction(
                                        touristCategory: 'PWDs',
                                        count: pwdsCount,
                                        amount: pwdsCount * pwdsPrice,
                                        cash: _cash,
                                        changeAmount: change,
                                        authProvider: authProvider,
                                      );
                                    }

                                    if (childrenCount > 0) {
                                      await TransactionService.createTransaction(
                                        touristCategory: 'Children',
                                        count: childrenCount,
                                        amount: childrenCount * childrenPrice,
                                        cash: _cash,
                                        changeAmount: change,
                                        authProvider: authProvider,
                                      );
                                    }

                                    if (residentCount > 0) {
                                      await TransactionService.createTransaction(
                                        touristCategory: 'Resident',
                                        count: residentCount,
                                        amount: residentCount * residentPrice,
                                        cash: _cash,
                                        changeAmount: change,
                                        authProvider: authProvider,
                                      );
                                    }

                                    setState(() {
                                      _isProcessing = false;
                                    });
                                  } catch (e) {
                                    print('Error processing transaction: $e');
                                    setState(() {
                                      _isProcessing = false;
                                    });
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Error'),
                                        content: Text(
                                          'Failed to process transaction: $e',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                    return;
                                  }
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      contentPadding: const EdgeInsets.all(0),
                                      content: SizedBox(
                                        width: 600,
                                        height: 700,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildReceiptDisplaySection(
                                                context,
                                                processed: true,
                                              ),
                                              const SizedBox(height: 16),
                                              ElevatedButton.icon(
                                                icon: const Icon(Icons.print),
                                                label: const Text('Print'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      content: const Text(
                                                        'Please wait... Printing Receipt..',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                            _resetTransactionData();
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  'Receipt printed successfully! Transaction data reset.',
                                                                ),
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                duration:
                                                                    Duration(
                                                                      seconds:
                                                                          2,
                                                                    ),
                                                              ),
                                                            );
                                                          },
                                                          child: const Text(
                                                            'OK',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            minimumSize: const Size(120, 42),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: _isProcessing
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Processing...'),
                                  ],
                                )
                              : const Text('Process Transaction'),
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: (!_isVerified || _isProcessing)
                              ? null
                              : () async {
                                  setState(() {
                                    _isProcessing = true;
                                  });

                                  final authProvider =
                                      Provider.of<AuthProvider>(
                                        context,
                                        listen: false,
                                      );
                                  final currentUser = authProvider.currentUser;
                                  final staffUsername =
                                      currentUser?['username'];
                                  if (currentUser == null ||
                                      staffUsername == null ||
                                      staffUsername.isEmpty) {
                                    setState(() {
                                      _isProcessing = false;
                                    });
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                          'Authentication Error',
                                        ),
                                        content: const Text(
                                          'You must be logged in as a staff member to process transactions.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                    return;
                                  }
                                  _staffEncoder = staffUsername;
                                  try {
                                    // Process each category as separate transactions
                                    if (regularCount > 0) {
                                      final result =
                                          await TransactionService.createTransaction(
                                            touristCategory: 'Regular',
                                            count: regularCount,
                                            amount: regularCount * regularPrice,
                                            cash: _cash,
                                            changeAmount: change,
                                            authProvider: authProvider,
                                          );
                                      // Store the receipt_id from the first transaction
                                      if (_actualReceiptId == null) {
                                        _actualReceiptId =
                                            result?['receipt_id'];
                                      }
                                    }

                                    if (seniorCitizenCount > 0) {
                                      await TransactionService.createTransaction(
                                        touristCategory: 'Senior Citizen',
                                        count: seniorCitizenCount,
                                        amount:
                                            seniorCitizenCount *
                                            seniorCitizenPrice,
                                        cash: _cash,
                                        changeAmount: change,
                                        authProvider: authProvider,
                                      );
                                    }

                                    if (pwdsCount > 0) {
                                      await TransactionService.createTransaction(
                                        touristCategory: 'PWDs',
                                        count: pwdsCount,
                                        amount: pwdsCount * pwdsPrice,
                                        cash: _cash,
                                        changeAmount: change,
                                        authProvider: authProvider,
                                      );
                                    }

                                    if (childrenCount > 0) {
                                      await TransactionService.createTransaction(
                                        touristCategory: 'Children',
                                        count: childrenCount,
                                        amount: childrenCount * childrenPrice,
                                        cash: _cash,
                                        changeAmount: change,
                                        authProvider: authProvider,
                                      );
                                    }

                                    if (residentCount > 0) {
                                      await TransactionService.createTransaction(
                                        touristCategory: 'Resident',
                                        count: residentCount,
                                        amount: residentCount * residentPrice,
                                        cash: _cash,
                                        changeAmount: change,
                                        authProvider: authProvider,
                                      );
                                    }

                                    setState(() {
                                      _isProcessing = false;
                                    });
                                  } catch (e) {
                                    print('Error processing transaction: $e');
                                    setState(() {
                                      _isProcessing = false;
                                    });
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Error'),
                                        content: Text(
                                          'Failed to process transaction: $e',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                    return;
                                  }
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      contentPadding: const EdgeInsets.all(0),
                                      content: SizedBox(
                                        width: 600,
                                        height: 700,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildReceiptDisplaySection(
                                                context,
                                                processed: true,
                                              ),
                                              const SizedBox(height: 16),
                                              ElevatedButton.icon(
                                                icon: const Icon(Icons.print),
                                                label: const Text('Print'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      content: const Text(
                                                        'Please wait... Printing Receipt..',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                            _resetTransactionData();
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  'Receipt printed successfully! Transaction data reset.',
                                                                ),
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                duration:
                                                                    Duration(
                                                                      seconds:
                                                                          2,
                                                                    ),
                                                              ),
                                                            );
                                                          },
                                                          child: const Text(
                                                            'OK',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            minimumSize: const Size(120, 42),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: _isProcessing
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Processing...'),
                                  ],
                                )
                              : const Text('Process Transaction'),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryRow(
    String category,
    int count,
    Function(int) onCountChanged,
    TextEditingController controller,
  ) {
    IconData? icon;
    switch (category) {
      case 'Regular':
        icon = Icons.people;
        break;
      case 'Senior Citizen':
        icon = Icons.elderly;
        break;
      case 'PWDs':
        icon = Icons.accessible;
        break;
      case 'Children':
        icon = Icons.child_care;
        break;
      case 'Resident':
        icon = Icons.home;
        break;
      default:
        icon = null;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.blueAccent, size: 22),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              category,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white),
                  onPressed: () {
                    if (count > 0) {
                      onCountChanged(count - 1);
                      controller.text = (count - 1).toString();
                    }
                  },
                ),
                SizedBox(
                  width: 40,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (value) {
                      final intValue = int.tryParse(value) ?? 0;
                      onCountChanged(intValue);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    onCountChanged(count + 1);
                    controller.text = (count + 1).toString();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay(
    String label,
    String? value, {
    bool isVerified = false,
    bool showVerifyButton = false,
    Widget? valueWidget,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.blueAccent, size: 22),
            const SizedBox(width: 8),
          ],
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          if (showVerifyButton)
            _buildVerifyButton(inline: true)
          else if (valueWidget != null)
            valueWidget
          else if (value != null)
            Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildReceiptDisplaySection(
    BuildContext context, {
    bool processed = false,
  }) {
    return Center(
      child: SizedBox(
        width: 500,
        height: 650, // Ensure enough height for watermark visibility
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Floating background with 'Preview' watermark
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'PREVIEW',
                    style: TextStyle(
                      fontSize: 120, // Make it very large
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.withOpacity(0.25), // More visible
                      letterSpacing: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            // Foreground: actual receipt
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.90),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blueGrey.withOpacity(0.15),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: _buildReceiptContent(processed: processed),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptContent({bool processed = false}) {
    // Always update _staffEncoder from AuthProvider before building receipt
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    _staffEncoder = currentUser?['username'] ?? 'Unknown';
    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy - hh:mm:ss a').format(now);
    final receiptNumber = _actualReceiptId != null
        ? '#$_actualReceiptId'
        : '#$_receiptNumber';
    final barcodeData = _actualReceiptId ?? '$_receiptNumber';
    final totalCount =
        regularCount +
        seniorCitizenCount +
        pwdsCount +
        childrenCount +
        residentCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'ENVIRONMENTAL USER FEE',
          style: const TextStyle(
            fontFamily: 'CourierPrime',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          formattedDate,
          style: const TextStyle(
            fontFamily: 'CourierPrime',
            fontSize: 13,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          receiptNumber,
          style: const TextStyle(
            fontFamily: 'CourierPrime',
            fontSize: 12,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const DashedDivider(height: 1, color: Colors.black26),
        const SizedBox(height: 12),
        Text(
          'ENTRY',
          style: const TextStyle(
            fontFamily: 'CourierPrime',
            fontSize: 13,
            color: Colors.black,
          ),
        ),
        Text(
          'ENCODE BY: ${_staffEncoder ?? ''}',
          style: const TextStyle(
            fontFamily: 'CourierPrime',
            fontSize: 13,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        const DashedDivider(height: 1, color: Colors.black26),
        const SizedBox(height: 12),
        _buildReceiptItem(
          'REGULAR',
          '$regularCount X ₱${regularPrice.toStringAsFixed(0)}',
          labelColor: Colors.black54,
        ),
        _buildReceiptItem(
          'SENIOR CITIZEN',
          '$seniorCitizenCount X ₱${regularPrice.toStringAsFixed(0)} (20%)',
          labelColor: Colors.black54,
        ),
        _buildReceiptItem(
          'CHILDREN',
          '$childrenCount X (exempt)',
          labelColor: Colors.black54,
        ),
        _buildReceiptItem(
          'PWDs',
          '$pwdsCount X (exempt)',
          labelColor: Colors.black54,
        ),
        _buildReceiptItem(
          'RESIDENT',
          '$residentCount X (exempt)',
          labelColor: Colors.black54,
        ),
        const SizedBox(height: 12),
        const DashedDivider(height: 1, color: Colors.black26),
        const SizedBox(height: 12),
        _buildReceiptItem('COUNT', '$totalCount'),
        _buildReceiptItem(
          'TOTAL',
          '₱${totalAmount.toStringAsFixed(0)}',
          isBold: true,
        ),
        _buildReceiptItem(
          'CASH',
          _cash > 0 ? '₱${_cash.toStringAsFixed(2)}' : '₱0',
        ),
        _buildReceiptItem(
          'CHANGE',
          change > 0 ? '₱${change.toStringAsFixed(2)}' : '₱0',
        ),
        const SizedBox(height: 12),
        const DashedDivider(height: 1, color: Colors.black26),
        const SizedBox(height: 18),
        Text(
          'OFFICIAL RECEIPT',
          style: const TextStyle(
            fontFamily: 'CourierPrime',
            fontSize: 14,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          processed ? 'PROCESSED' : 'FOR PROCESS',
          style: const TextStyle(
            fontFamily: 'CourierPrime',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        Text(
          'THANK YOU AND ENJOY.',
          style: const TextStyle(
            fontFamily: 'CourierPrime',
            fontSize: 13,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        BarcodeWidget(
          barcode: Barcode.code128(),
          data: barcodeData,
          width: 200,
          height: 60,
          drawText: false,
        ),
      ],
    );
  }

  Widget _buildReceiptItem(
    String label,
    String value, {
    bool isBold = false,
    Color? labelColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'CourierPrime',
              fontSize: 13,
              color: labelColor ?? Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'CourierPrime',
              fontSize: 13,
              color: Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton({bool inline = false}) {
    if (_isVerified) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check, color: Colors.white, size: 20),
        label: const Text('Verified'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.green,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          minimumSize: inline ? const Size(120, 42) : null,
          padding: inline
              ? const EdgeInsets.symmetric(horizontal: 18, vertical: 0)
              : null,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: _isVerifying
            ? null
            : () async {
                setState(() {
                  _isVerifying = true;
                });
                await Future.delayed(const Duration(seconds: 1));
                setState(() {
                  _isVerifying = false;
                  _isVerified = true;
                });
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          minimumSize: inline ? const Size(120, 42) : null,
          padding: inline
              ? const EdgeInsets.symmetric(horizontal: 18, vertical: 0)
              : null,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
        child: _isVerifying
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Verify'),
      );
    }
  }
}

class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const DashedDivider({
    this.height = 1,
    this.color = Colors.white30,
    this.dashWidth = 5,
    this.dashSpace = 3,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(dashCount, (_) {
            return Container(
              width: dashWidth,
              height: height,
              color: color,
              margin: EdgeInsets.only(right: dashSpace),
            );
          }),
        );
      },
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
