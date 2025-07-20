import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart';

const double kMobileBreakpoint = 800.0;

class EUFInfoPage extends StatelessWidget {
  const EUFInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < kMobileBreakpoint) {
              return AppBar(
                title: const Text('EUF Information'),
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
            // Mobile layout with drawer
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [_buildMainContent(context, isMobile: true)],
              ),
            );
          } else {
            // Desktop/Tablet layout with sidebar
            return Row(
              children: [
                const AppSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      // Top header at the very top
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 32,
                          right: 32,
                          top: 0,
                          bottom: 0,
                        ),
                        child: _PageHeader(title: 'Environmental User’s Fee'),
                      ),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 24,
                            ),
                            child: _buildMainContent(
                              context,
                              isMobile: false,
                              skipHeader: true,
                            ),
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

  Widget _buildMainContent(
    BuildContext context, {
    required bool isMobile,
    bool skipHeader = false,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? 500 : 900),
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isMobile && !skipHeader)
            _PageHeader(title: 'Environmental User’s Fee'),
          if (!isMobile && !skipHeader) const SizedBox(height: 24),
          // What is EUF
          _InfoCard(
            icon: Icons.eco,
            title: 'What is EUF?',
            content:
                'The Environmental User’s Fee (EUF) is collected to fund environmental conservation and protection of Puerto Galera’s natural resources. Your contribution helps maintain the pristine beauty of our beaches, marine ecosystems, and surrounding environment.',
          ),
          const SizedBox(height: 28),
          // Fee Rates
          _SectionTitle(icon: Icons.monetization_on, title: 'EUF Rates'),
          const SizedBox(height: 12),
          isMobile
              ? Column(children: _feeRateCards())
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _feeRateCards(),
                ),
          const SizedBox(height: 32),
          // Usage
          _SectionTitle(icon: Icons.pie_chart, title: 'How Your EUF is Used'),
          const SizedBox(height: 12),
          _UsageBreakdown(isMobile: isMobile),
          const SizedBox(height: 32),
          // Projects
          _SectionTitle(
            icon: Icons.local_florist,
            title: 'Active EUF-Funded Projects',
          ),
          const SizedBox(height: 12),
          _ProjectsList(),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.blueAccent, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 28),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

List<Widget> _feeRateCards() => [
  _FeeRateCard(
    icon: Icons.person,
    title: 'Regular',
    price: '₱120',
    description: 'Per visitor',
    color: Colors.blueAccent,
  ),
  _FeeRateCard(
    icon: Icons.elderly,
    title: 'Senior Citizen',
    price: '₱96',
    description: '20% discount',
    color: Colors.greenAccent,
  ),
  _FeeRateCard(
    icon: Icons.child_care,
    title: 'Exempt Category',
    price: '₱0',
    description: 'PWD, Children under 12, Oriental Mindoro residents',
    color: Colors.orangeAccent,
  ),
];

class _FeeRateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String price;
  final String description;
  final Color color;
  const _FeeRateCard({
    required this.icon,
    required this.title,
    required this.price,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.13),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageBreakdown extends StatelessWidget {
  final List<_UsageData> usage = const [
    _UsageData(
      'ENVIRONMENTAL PROJECTS',
      0.35,
      Colors.blueAccent,
      '₱42 per fee',
    ),
    _UsageData('BARANGAY SHARE', 0.20, Colors.greenAccent, '₱24 per fee'),
    _UsageData('ADMINISTRATION', 0.30, Colors.purpleAccent, '₱36 per fee'),
    _UsageData('EMERGENCY FUND', 0.15, Colors.orangeAccent, '₱18 per fee'),
  ];
  final bool isMobile;
  const _UsageBreakdown({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (!isMobile) {
      return Column(children: usage.map((u) => _UsageBar(data: u)).toList());
    } else {
      // For mobile, add a Divider after each row except the last
      List<Widget> rows = [];
      for (int i = 0; i < usage.length; i++) {
        rows.add(_UsageBar(data: usage[i]));
        if (i < usage.length - 1) {
          rows.add(
            const Divider(color: Colors.white24, thickness: 1, height: 18),
          );
        }
      }
      return Column(children: rows);
    }
  }
}

class _UsageData {
  final String label;
  final double percent;
  final Color color;
  final String amount;
  const _UsageData(this.label, this.percent, this.color, this.amount);
}

class _UsageBar extends StatelessWidget {
  final _UsageData data;
  const _UsageBar({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              data.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: data.percent,
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: data.color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(data.percent * 100).toStringAsFixed(0)}%',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(data.amount, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _ProjectsList extends StatelessWidget {
  final List<_ProjectData> projects = const [
    _ProjectData(
      'White Beach Cleanup',
      'Weekly coastal cleanup and waste management',
      '₱120,000',
      Icons.beach_access,
      Colors.blueAccent,
    ),
    _ProjectData(
      'Mangrove Restoration',
      'Planting of 2,000 mangrove seedlings',
      '₱185,000',
      Icons.park,
      Colors.greenAccent,
    ),
    _ProjectData(
      'Water Quality Monitoring',
      'Monthly testing at 5 key beach locations',
      '₱90,000',
      Icons.water,
      Colors.purpleAccent,
    ),
  ];

  const _ProjectsList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: projects.map((p) => _ProjectCard(data: p)).toList(),
    );
  }
}

class _ProjectData {
  final String title;
  final String description;
  final String amount;
  final IconData icon;
  final Color color;
  const _ProjectData(
    this.title,
    this.description,
    this.amount,
    this.icon,
    this.color,
  );
}

class _ProjectCard extends StatelessWidget {
  final _ProjectData data;
  const _ProjectCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: data.color.withOpacity(0.13),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(data.icon, color: data.color, size: 32),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Text(
              data.amount,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: data.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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
