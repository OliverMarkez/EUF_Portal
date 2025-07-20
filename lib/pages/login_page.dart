import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

const double kMobileBreakpoint = 800.0;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double formMaxWidth = 400;
    final double logoMaxWidth = 180;
    final double logoMaxHeight = 180;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < kMobileBreakpoint) {
            // Mobile layout
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 420 ? 12 : 24,
                vertical: 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  // Login Form
                  Container(
                    constraints: BoxConstraints(maxWidth: formMaxWidth),
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        FractionallySizedBox(
                          widthFactor: 0.5,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: logoMaxWidth,
                              maxHeight: logoMaxHeight,
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/portal_pics/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'EUF PORTAL',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 35),
                        Text(
                          'Access for authorized personnel only',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        // Username TextField
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: formMaxWidth),
                          child: TextField(
                            controller: _usernameController,
                            onChanged: (value) {
                              // Clear error when user starts typing
                              if (_errorMessage != null) {
                                setState(() {
                                  _errorMessage = null;
                                });
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: 'Username',
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Password TextField
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: formMaxWidth),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            onChanged: (value) {
                              // Clear error when user starts typing
                              if (_errorMessage != null) {
                                setState(() {
                                  _errorMessage = null;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.white54,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white54,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: formMaxWidth),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                              ),
                              const Text('Remember Me'),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  // TODO: Implement forgot password action
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            final errorToShow =
                                _errorMessage ?? authProvider.error;
                            print(
                              'Consumer builder called - errorToShow: $errorToShow',
                            );
                            print('_errorMessage: $_errorMessage');
                            print('authProvider.error: ${authProvider.error}');
                            if (errorToShow != null) {
                              print('Showing error message: $errorToShow');
                              return Column(
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    errorToShow,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            }
                            print('No error message to show');
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: formMaxWidth),
                            child: Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: 22,
                                    ),
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : () =>
                                            _handleLogin(context, authProvider),
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text('Log in'),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                        Text(
                          'Tourism Office | Treasurer\'s Office',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Desktop/Tablet layout
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Login Form
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48.0,
                                vertical: 40.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'EUF PORTAL',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontSize: 42,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                    'Access for authorized personnel only',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 16),
                                  ),
                                  const SizedBox(height: 18),
                                  // Username TextField
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 450,
                                    ),
                                    child: TextField(
                                      controller: _usernameController,
                                      onChanged: (value) {
                                        // Clear error when user starts typing
                                        if (_errorMessage != null) {
                                          setState(() {
                                            _errorMessage = null;
                                          });
                                        }
                                      },
                                      decoration: const InputDecoration(
                                        hintText: 'Username',
                                        prefixIcon: Icon(
                                          Icons.person,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  // Password TextField
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 450,
                                    ),
                                    child: TextField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      onChanged: (value) {
                                        // Clear error when user starts typing
                                        if (_errorMessage != null) {
                                          setState(() {
                                            _errorMessage = null;
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Password',
                                        prefixIcon: const Icon(
                                          Icons.lock,
                                          color: Colors.white54,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.white54,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 450,
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                        ),
                                        const Text('Remember Me'),
                                        Spacer(),
                                        GestureDetector(
                                          onTap: () {
                                            // TODO: Implement forgot password action
                                          },
                                          child: const Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                              color: Colors.blueAccent,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      final errorToShow =
                                          _errorMessage ?? authProvider.error;
                                      print(
                                        'Desktop Consumer builder called - errorToShow: $errorToShow',
                                      );
                                      if (errorToShow != null) {
                                        print(
                                          'Desktop showing error message: $errorToShow',
                                        );
                                        return Column(
                                          children: [
                                            const SizedBox(height: 8),
                                            Text(
                                              errorToShow,
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        );
                                      }
                                      print('Desktop no error message to show');
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                  Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 450,
                                      ),
                                      child: Consumer<AuthProvider>(
                                        builder: (context, authProvider, child) {
                                          return ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 0,
                                                    vertical: 24,
                                                  ),
                                              minimumSize:
                                                  const Size.fromHeight(48),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                            onPressed: authProvider.isLoading
                                                ? null
                                                : () => _handleLogin(
                                                    context,
                                                    authProvider,
                                                  ),
                                            child: authProvider.isLoading
                                                ? const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  )
                                                : const Text('Log in'),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 180),
                                  Text(
                                    'Tourism Office | Treasurer\'s Office',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Right: Logo background
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 650,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                                bottomLeft: Radius.circular(32),
                                bottomRight: Radius.circular(32),
                              ),
                              image: const DecorationImage(
                                image: AssetImage(
                                  'assets/portal_pics/bg_logo.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/portal_pics/logo.png',
                                fit: BoxFit.contain,
                                width: 220,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _handleLogin(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    if (!mounted) return;

    print('Login attempt started');
    setState(() {
      _errorMessage = null;
    });

    // Check for empty fields
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      print('Empty fields detected');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Enter your username and password';
      });
      print('Set error message: $_errorMessage');
      return;
    }

    print('Calling authProvider.signIn');
    final success = await authProvider.signIn(
      _usernameController.text,
      _passwordController.text,
    );

    print('Login result: $success');

    if (!mounted) return;

    if (!success) {
      print('Login failed, setting error message');
      setState(() {
        _errorMessage = 'Invalid username or password';
      });
      print('Error message set: $_errorMessage');
    } else {
      print('Login successful, clearing error message');
      // Clear any previous error messages on successful login
      setState(() {
        _errorMessage = null;
      });
    }
  }
}
