import '../services/supabase_service.dart';
import '../providers/auth_provider.dart';

class TransactionService {
  // Create a new transaction
  static Future<Map<String, dynamic>?> createTransaction({
    required String touristCategory,
    required int count,
    required double amount,
    required double cash,
    required double changeAmount,
    required AuthProvider authProvider,
  }) async {
    try {
      final currentUser = authProvider.currentUser;
      final username = currentUser?['username'];

      if (username == null) {
        throw Exception('User not authenticated');
      }

      final response = await SupabaseService.client
          .from('transactions')
          .insert({
            'tourist_category': touristCategory,
            'count': count,
            'amount': amount,
            'cash': cash,
            'change_amount': changeAmount,
            'staff_encoder': username,
          })
          .select()
          .single();

      print('Transaction created successfully by $username');
      return response;
    } catch (e) {
      print('Error creating transaction: $e');
      rethrow;
    }
  }

  // Get all transactions for the current user
  static Future<List<Map<String, dynamic>>> getTransactions({
    required AuthProvider authProvider,
  }) async {
    try {
      final currentUser = authProvider.currentUser;
      final username = currentUser?['username'];

      if (username == null) {
        throw Exception('User not authenticated');
      }

      final response = await SupabaseService.client
          .from('transactions')
          .select()
          .eq('staff_encoder', username)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching transactions: $e');
      rethrow;
    }
  }

  // Get transaction statistics
  static Future<Map<String, dynamic>> getTransactionStats({
    required AuthProvider authProvider,
  }) async {
    try {
      final currentUser = authProvider.currentUser;
      final username = currentUser?['username'];

      if (username == null) {
        throw Exception('User not authenticated');
      }

      final response = await SupabaseService.client
          .from('transactions')
          .select('amount, tourist_category, count')
          .eq('staff_encoder', username);

      final transactions = List<Map<String, dynamic>>.from(response);

      double totalAmount = 0;
      int totalCount = 0;
      Map<String, int> categoryCount = {};

      for (final transaction in transactions) {
        totalAmount += (transaction['amount'] as num).toDouble();
        totalCount += transaction['count'] as int;

        final category = transaction['tourist_category'] as String;
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }

      return {
        'totalAmount': totalAmount,
        'totalCount': totalCount,
        'totalTransactions': transactions.length,
        'categoryCount': categoryCount,
      };
    } catch (e) {
      print('Error fetching transaction stats: $e');
      rethrow;
    }
  }

  // Get transactions by date range
  static Future<List<Map<String, dynamic>>> getTransactionsByDateRange({
    required AuthProvider authProvider,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final currentUser = authProvider.currentUser;
      final username = currentUser?['username'];

      if (username == null) {
        throw Exception('User not authenticated');
      }

      final response = await SupabaseService.client
          .from('transactions')
          .select()
          .eq('staff_encoder', username)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching transactions by date range: $e');
      rethrow;
    }
  }
}
