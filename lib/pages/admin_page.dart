import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../widgets/app_sidebar.dart';

const double kMobileBreakpoint = 800.0;

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < kMobileBreakpoint) {
              return AppBar(
                title: const Text('Admin'),
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
                children: [_buildCreateUserSection(context)],
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
                        child: _PageHeader(title: 'Admin'),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: _buildCreateUserSection(context),
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

  Widget _buildCreateUserSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New Staff User',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          if (_message != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _message!.contains('Success')
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _message!,
                style: TextStyle(
                  color: _message!.contains('Success')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createUser,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Create User'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createUser() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _message = 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // First create the user in Supabase auth
      final authResponse = await SupabaseService.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
      );

      if (authResponse.user != null) {
        // Then insert into staff table
        await SupabaseService.client.from('staff').insert({
          'id': authResponse.user!.id,
          'username': _usernameController.text,
          'email': _emailController.text,
        });

        setState(() {
          _message = 'Success! User created successfully.';
          _usernameController.clear();
          _emailController.clear();
          _passwordController.clear();
        });
      } else {
        setState(() {
          _message = 'Failed to create user. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
