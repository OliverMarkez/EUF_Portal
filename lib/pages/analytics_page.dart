import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'dart:async';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  static const String routeName = '/analytics';

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedFilter = 'Day';
  final List<String> _filters = ['Hour', 'Day', 'Week', 'Month', 'Custom'];

  // Enhanced filtering options
  String _selectedCategory = 'All Categories';
  String _selectedTimeOfDay = 'All Day';
  DateTimeRange? _customDateRange;
  bool _showAdvancedFilters = false;

  final List<String> _categories = [
    'All Categories',
    'Regular',
    'Senior Citizen',
    'PWDs',
    'Children',
    'Resident',
  ];

  final List<String> _timeOfDayOptions = [
    'All Day',
    'Morning (6AM-12PM)',
    'Afternoon (12PM-6PM)',
    'Evening (6PM-12AM)',
    'Night (12AM-6AM)',
  ];

  // Real-time data simulation
  int _liveTouristCount = 47;
  double _liveRevenue = 5640.00;
  String _peakHour = '2:00 PM';
  int _currentQueue = 3;

  // Interactive chart data
  final List<FlSpot> _lineChartData = [
    const FlSpot(0, 8),
    const FlSpot(1, 12),
    const FlSpot(2, 10),
    const FlSpot(3, 16),
    const FlSpot(4, 14),
    const FlSpot(5, 20),
  ];

  // Pie chart data with interactive sections
  final List<PieChartSectionData> _pieChartData = [
    PieChartSectionData(
      value: 40,
      color: Colors.greenAccent,
      title: '40%',
      radius: 60,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    PieChartSectionData(
      value: 25,
      color: Colors.blueAccent,
      title: '25%',
      radius: 60,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    PieChartSectionData(
      value: 20,
      color: Colors.purpleAccent,
      title: '20%',
      radius: 60,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    PieChartSectionData(
      value: 10,
      color: Colors.orangeAccent,
      title: '10%',
      radius: 60,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    PieChartSectionData(
      value: 5,
      color: Colors.redAccent,
      title: '5%',
      radius: 60,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Simulate real-time updates
    _startLiveUpdates();
  }

  void _startLiveUpdates() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _liveTouristCount += (Random().nextInt(3) - 1); // Random change
          _liveRevenue +=
              (Random().nextInt(200) - 100); // Random revenue change
          if (_liveTouristCount < 0) _liveTouristCount = 0;
          if (_liveRevenue < 0) _liveRevenue = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isMobile ? Colors.black : Colors.transparent,
        elevation: isMobile ? 0 : 0,
        toolbarHeight: kToolbarHeight,
        automaticallyImplyLeading: isMobile,
        title: isMobile ? const Text('Analytics') : null,
        // No title, no color for desktop
      ),
      drawer: isMobile ? const AppSidebar(isDrawer: true) : null,
      body: Row(
        children: [
          if (!isMobile) const AppSidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page header only for desktop/tablet
                  if (!isMobile) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 20.0,
                      ), // Reduced padding
                      child: _PageHeader(title: 'Analytics'),
                    ),
                  ],
                  _buildRealTimeDashboard(),
                  const SizedBox(height: 20), // Reduced spacing
                  _buildEnhancedFilters(),
                  const SizedBox(height: 20), // Reduced spacing
                  // Responsive chart layout
                  if (isMobile) ...[
                    // Mobile: Stacked layout
                    _buildCard(child: _buildInteractiveLineChart()),
                    const SizedBox(height: 16),
                    _buildCard(child: _buildInteractivePieChart()),
                  ] else ...[
                    // Desktop: Side by side with proper spacing
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final availableWidth = constraints.maxWidth;
                        final cardWidth =
                            (availableWidth - 24) / 2; // 24 = spacing

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                child: _buildInteractiveLineChart(),
                              ),
                            ),
                            const SizedBox(width: 24),
                            SizedBox(
                              width: cardWidth,
                              child: _buildCard(
                                child: _buildInteractivePieChart(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20.0), // Reduced padding
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: child,
    );
  }

  Widget _buildRealTimeDashboard() {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 18), // Reduced desktop padding
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Live Dashboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    fontSize: isMobile ? 18 : 22,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // Responsive grid layout
          if (isMobile) ...[
            // Mobile: 2x2 grid
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildLiveMetric(
                        'Today\'s Visitors',
                        '$_liveTouristCount',
                        Icons.people,
                        Colors.blueAccent,
                        isMobile: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildLiveMetric(
                        'Current Revenue',
                        '₱${_liveRevenue.toStringAsFixed(0)}',
                        Icons.attach_money,
                        Colors.greenAccent,
                        isMobile: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildLiveMetric(
                        'Peak Hour',
                        _peakHour,
                        Icons.access_time,
                        Colors.orangeAccent,
                        isMobile: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildLiveMetric(
                        'In Queue',
                        '$_currentQueue',
                        Icons.queue,
                        Colors.purpleAccent,
                        isMobile: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            // Desktop: 1x4 row with flexible spacing
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final itemWidth =
                    (availableWidth - 48) / 4; // 48 = 3 * 16 (spacing)

                return Row(
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _buildLiveMetric(
                        'Today\'s Visitors',
                        '$_liveTouristCount',
                        Icons.people,
                        Colors.blueAccent,
                        isMobile: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: itemWidth,
                      child: _buildLiveMetric(
                        'Current Revenue',
                        '₱${_liveRevenue.toStringAsFixed(0)}',
                        Icons.attach_money,
                        Colors.greenAccent,
                        isMobile: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: itemWidth,
                      child: _buildLiveMetric(
                        'Peak Hour',
                        _peakHour,
                        Icons.access_time,
                        Colors.orangeAccent,
                        isMobile: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: itemWidth,
                      child: _buildLiveMetric(
                        'In Queue',
                        '$_currentQueue',
                        Icons.queue,
                        Colors.purpleAccent,
                        isMobile: false,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLiveMetric(
    String label,
    String value,
    IconData icon,
    Color color, {
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isMobile ? 16 : 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isMobile ? 10 : 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isMobile ? 18 : 24,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveLineChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tourist Count Breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.blueAccent),
              onPressed: () => _showChartInfo(
                'Line Chart shows tourist count trends over time',
              ),
              tooltip: 'Chart Info',
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 4,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.white10, strokeWidth: 1);
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(color: Colors.white10, strokeWidth: 1);
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 4,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      const titles = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                      if (value.toInt() >= 0 && value.toInt() < titles.length) {
                        return Text(
                          titles[value.toInt()],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: Colors.blueAccent,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: Colors.blueAccent,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  spots: _lineChartData,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blueAccent.withOpacity(0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) =>
                      Colors.blueAccent.withOpacity(0.9),
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      return LineTooltipItem(
                        '${barSpot.y.toInt()} tourists',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractivePieChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Revenue Percentage by Category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.blueAccent),
              onPressed: () => _showChartInfo(
                'Pie Chart shows revenue distribution by tourist category',
              ),
              tooltip: 'Chart Info',
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: _pieChartData,
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              pieTouchData: PieTouchData(
                enabled: true,
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  if (event is! FlPanEndEvent && event is! FlTapUpEvent) {
                    return;
                  }
                  if (pieTouchResponse?.touchedSection != null) {
                    final section =
                        _pieChartData[pieTouchResponse!
                            .touchedSection!
                            .touchedSectionIndex];
                    _showPieChartDetails(section);
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPieChartLegend(),
      ],
    );
  }

  Widget _buildPieChartLegend() {
    const categories = [
      'Regular',
      'Senior Citizen',
      'PWDs',
      'Children',
      'Resident',
    ];
    const colors = [
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.redAccent,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: List.generate(categories.length, (index) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              categories[index],
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        );
      }),
    );
  }

  void _showChartInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blueAccent.withOpacity(0.9),
      ),
    );
  }

  void _showPieChartDetails(PieChartSectionData section) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Category Details'),
        content: Text(
          'This section represents ${section.value}% of total revenue',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFilters() {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 18), // Reduced desktop padding
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Filter Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 16 : 18,
                  ),
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _resetFilters(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reset'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showAdvancedFilters = !_showAdvancedFilters;
                      });
                    },
                    icon: Icon(
                      _showAdvancedFilters
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: Colors.blueAccent,
                    ),
                    tooltip: 'Advanced Filters',
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // Basic Filters - Responsive layout
          if (isMobile) ...[
            // Mobile: Stacked layout
            _buildFilterDropdown('Time Period', _selectedFilter, _filters, (
              value,
            ) {
              setState(() {
                _selectedFilter = value!;
                if (value == 'Custom' && _customDateRange == null) {
                  _selectCustomDateRange();
                }
              });
            }, isMobile: true),
            const SizedBox(height: 12),
            _buildFilterDropdown('Category', _selectedCategory, _categories, (
              value,
            ) {
              setState(() {
                _selectedCategory = value!;
              });
            }, isMobile: true),
          ] else ...[
            // Desktop: Side by side with flexible layout
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final itemWidth = (availableWidth - 16) / 2; // 16 = spacing

                return Row(
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _buildFilterDropdown(
                        'Time Period',
                        _selectedFilter,
                        _filters,
                        (value) {
                          setState(() {
                            _selectedFilter = value!;
                            if (value == 'Custom' && _customDateRange == null) {
                              _selectCustomDateRange();
                            }
                          });
                        },
                        isMobile: false,
                      ),
                    ),
                    const SizedBox(width: 12), // Reduced spacing
                    SizedBox(
                      width: itemWidth,
                      child: _buildFilterDropdown(
                        'Category',
                        _selectedCategory,
                        _categories,
                        (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        isMobile: false,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],

          // Custom Date Range Display
          if (_selectedFilter == 'Custom' && _customDateRange != null) ...[
            SizedBox(height: isMobile ? 8 : 12),
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.blueAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_formatDate(_customDateRange!.start)} - ${_formatDate(_customDateRange!.end)}',
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _selectCustomDateRange(),
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.blueAccent,
                      size: 16,
                    ),
                    tooltip: 'Edit Date Range',
                  ),
                ],
              ),
            ),
          ],

          // Advanced Filters
          if (_showAdvancedFilters) ...[
            SizedBox(height: isMobile ? 12 : 16),
            const Divider(color: Colors.white24),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              'Advanced Filters',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),

            if (isMobile) ...[
              // Mobile: Stacked layout
              _buildFilterDropdown(
                'Time of Day',
                _selectedTimeOfDay,
                _timeOfDayOptions,
                (value) {
                  setState(() {
                    _selectedTimeOfDay = value!;
                  });
                },
                isMobile: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterChip(
                      'Show Trends',
                      Icons.trending_up,
                      true,
                      (value) {
                        // TODO: Implement trend filtering
                      },
                      isMobile: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip(
                      'Include Zero Values',
                      Icons.exposure_zero,
                      false,
                      (value) {
                        // TODO: Implement zero value filtering
                      },
                      isMobile: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildFilterChip('Show Annotations', Icons.note, true, (value) {
                // TODO: Implement annotation filtering
              }, isMobile: true),
            ] else ...[
              // Desktop: Grid layout with flexible spacing
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final itemWidth = (availableWidth - 16) / 2; // 16 = spacing

                  return Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: _buildFilterDropdown(
                              'Time of Day',
                              _selectedTimeOfDay,
                              _timeOfDayOptions,
                              (value) {
                                setState(() {
                                  _selectedTimeOfDay = value!;
                                });
                              },
                              isMobile: false,
                            ),
                          ),
                          const SizedBox(width: 12), // Reduced spacing
                          SizedBox(
                            width: itemWidth,
                            child: _buildFilterChip(
                              'Show Trends',
                              Icons.trending_up,
                              true,
                              (value) {
                                // TODO: Implement trend filtering
                              },
                              isMobile: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: _buildFilterChip(
                              'Include Zero Values',
                              Icons.exposure_zero,
                              false,
                              (value) {
                                // TODO: Implement zero value filtering
                              },
                              isMobile: false,
                            ),
                          ),
                          const SizedBox(width: 12), // Reduced spacing
                          SizedBox(
                            width: itemWidth,
                            child: _buildFilterChip(
                              'Show Annotations',
                              Icons.note,
                              true,
                              (value) {
                                // TODO: Implement annotation filtering
                              },
                              isMobile: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ],

          // Active Filters Summary
          if (_hasActiveFilters()) ...[
            SizedBox(height: isMobile ? 12 : 16),
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getActiveFiltersSummary(),
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    Function(String?) onChanged, {
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: Theme.of(context).cardColor,
            style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14),
            underline: Container(),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    IconData icon,
    bool value,
    Function(bool) onChanged, {
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 12,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: value
                  ? Colors.blueAccent.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: value ? Colors.blueAccent : Colors.white24,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: value ? Colors.blueAccent : Colors.white70,
                  size: isMobile ? 14 : 16,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    value ? 'Enabled' : 'Disabled',
                    style: TextStyle(
                      color: value ? Colors.blueAccent : Colors.white70,
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _customDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              surface: Theme.of(context).cardColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedFilter = 'Day';
      _selectedCategory = 'All Categories';
      _selectedTimeOfDay = 'All Day';
      _customDateRange = null;
      _showAdvancedFilters = false;
    });
  }

  bool _hasActiveFilters() {
    return _selectedFilter != 'Day' ||
        _selectedCategory != 'All Categories' ||
        _selectedTimeOfDay != 'All Day' ||
        _customDateRange != null;
  }

  String _getActiveFiltersSummary() {
    List<String> activeFilters = [];

    if (_selectedFilter != 'Day') {
      activeFilters.add('Period: $_selectedFilter');
    }
    if (_selectedCategory != 'All Categories') {
      activeFilters.add('Category: $_selectedCategory');
    }
    if (_selectedTimeOfDay != 'All Day') {
      activeFilters.add('Time: $_selectedTimeOfDay');
    }
    if (_customDateRange != null) {
      activeFilters.add('Custom Range');
    }

    return activeFilters.isEmpty
        ? 'No filters applied'
        : activeFilters.join(', ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Copied from reports_page.dart for reuse
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
