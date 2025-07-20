import 'package:euf_portal/pages/analytics_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/transaction_page.dart';
import '../pages/euf_info_page.dart';
import '../pages/reports_page.dart';
import '../pages/admin_page.dart';
import '../providers/auth_provider.dart';
import '../pages/login_page.dart';

const double kMobileBreakpoint = 800.0;

class AppSidebar extends StatelessWidget {
  final bool isDrawer;

  const AppSidebar({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isDrawer ? 250 : 210,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/portal_pics/logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          _buildSidebarItem(
            context,
            icon: Icons.dashboard,
            label: 'Transaction',
            targetPage: const TransactionPage(),
            currentPageType: TransactionPage,
            isDrawer: isDrawer,
          ),
          _buildSidebarItem(
            context,
            icon: Icons.bar_chart,
            label: 'Reports',
            targetPage: const ReportsPage(),
            currentPageType: ReportsPage,
            isDrawer: isDrawer,
          ),
          _buildSidebarItem(
            context,
            icon: Icons.analytics,
            label: 'Analytics',
            targetPage: const AnalyticsPage(),
            currentPageType: AnalyticsPage,
            isDrawer: isDrawer,
          ),
          _buildSidebarItem(
            context,
            icon: Icons.info_outline,
            label: 'EUF Info',
            targetPage: const EUFInfoPage(),
            currentPageType: EUFInfoPage,
            isDrawer: isDrawer,
          ),
          _buildSidebarItem(
            context,
            icon: Icons.admin_panel_settings,
            label: 'Admin',
            targetPage: const AdminPage(),
            currentPageType: AdminPage,
            isDrawer: isDrawer,
          ),
          const Spacer(),
          _buildSidebarItem(
            context,
            icon: Icons.logout,
            label: 'Logout',
            onTap: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.signOut();
              // Navigate to LoginPage and remove all previous routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            isDrawer: isDrawer,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    Widget? targetPage,
    Type? currentPageType,
    VoidCallback? onTap,
    required bool isDrawer,
  }) {
    final bool isSelected =
        currentPageType != null &&
        ModalRoute.of(context)?.settings.name == currentPageType.toString();
    final Color iconColor = isSelected ? Colors.white : Colors.white70;
    final Color textColor = isSelected ? Colors.white : Colors.white70;
    final Color selectedBg = Theme.of(
      context,
    ).colorScheme.primary.withOpacity(0.15);

    if (isDrawer) {
      return ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(label, style: TextStyle(color: textColor)),
        onTap:
            onTap ??
            () {
              Navigator.pop(context);
              if (targetPage != null) {
                if (ModalRoute.of(context)?.settings.name !=
                    targetPage.runtimeType.toString()) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => targetPage,
                      settings: RouteSettings(
                        name: targetPage.runtimeType.toString(),
                      ),
                    ),
                  );
                }
              }
            },
      );
    } else {
      // Horizontal icon + label for sidebar (desktop)
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: isSelected
            ? BoxDecoration(
                color: selectedBg,
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap:
              onTap ??
              () {
                if (targetPage != null) {
                  if (ModalRoute.of(context)?.settings.name !=
                      targetPage.runtimeType.toString()) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => targetPage,
                        settings: RouteSettings(
                          name: targetPage.runtimeType.toString(),
                        ),
                      ),
                    );
                  }
                }
              },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
