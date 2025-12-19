import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../inventory/logic/inventory_provider.dart';
import '../../../inventory/data/models/ingredient_model.dart';
import '../widgets/freshness_gauge.dart';
import '../../../inventory/presentation/screens/my_fridge_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _goToFridge(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyFridgeScreen()),
    );
  }

  void _handleLogout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logged out successfully"),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        // --- NEW: PROFILE & LOGOUT DROPDOWN ---
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.account_circle, 
              size: 32, 
              color: Theme.of(context).colorScheme.primary
            ),
            tooltip: "User Profile",
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                // Header (Optional, purely visual)
                const PopupMenuItem(
                  enabled: false, // Not clickable
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hello, User!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      Text("user@gmail.com", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Divider(),
                    ],
                  ),
                ),
                // Logout Option
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red, size: 20),
                      SizedBox(width: 10),
                      Text("Logout", style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
          ),
          const SizedBox(width: 10), // Right padding
        ],
      ),
      body: inventoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text("Error loading data")),
        data: (items) {
          final totalItems = items.length;
          final now = DateTime.now();

          final expiringSoon = items.where((i) {
            final expiry = DateTime(i.expiryDate.year, i.expiryDate.month, i.expiryDate.day);
            final today = DateTime(now.year, now.month, now.day);
            final daysLeft = expiry.difference(today).inDays;
            return daysLeft >= 0 && daysLeft <= 3;
          }).toList();

          final expired = items.where((i) {
             final expiry = DateTime(i.expiryDate.year, i.expiryDate.month, i.expiryDate.day);
             final today = DateTime(now.year, now.month, now.day);
             return expiry.isBefore(today);
          }).toList();

          double rawScore = 1.0 - (expired.length * 0.1) - (expiringSoon.length * 0.05);
          final freshnessScore = rawScore.clamp(0.0, 1.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: FreshnessGauge(score: freshnessScore),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    _getHealthMessage(freshnessScore),
                    style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 30),

                const Text("Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        "Total Items", 
                        "$totalItems", 
                        Colors.blue,
                        () => _goToFridge(context),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildStatCard(
                        "Expiring Soon", 
                        "${expiringSoon.length}", 
                        Colors.orange,
                        () => _goToFridge(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                if (expired.isNotEmpty)
                  _buildFullWidthCard(
                    "Wasted Items", 
                    "${expired.length}", 
                    Colors.red,
                    () => _goToFridge(context),
                  ),

                const SizedBox(height: 30),

                if (expiringSoon.isNotEmpty) ...[
                  const Text("Use Quickly!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...expiringSoon.map((item) => Card(
                    elevation: 0,
                    color: Colors.orange[50],
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.timer, color: Colors.orange),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Expires: ${item.expiryDate.toString().split(' ')[0]}"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
                      onTap: () => _goToFridge(context),
                    ),
                  )),
                ] else if (totalItems > 0) ...[
                   Container(
                     padding: const EdgeInsets.all(20),
                     decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10)),
                     child: Row(
                       children: const [
                         Icon(Icons.check_circle, color: Colors.green),
                         SizedBox(width: 10),
                         Expanded(child: Text("Your fridge is looking great! Nothing expiring soon.")),
                       ],
                     ),
                   )
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  String _getHealthMessage(double score) {
    if (score >= 0.8) return "Excellent! Your fridge is optimized.";
    if (score >= 0.5) return "Good, but check those expiring items.";
    return "Action needed! Reduce food waste now.";
  }

  Widget _buildStatCard(String title, String value, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 5),
            Text(title, style: TextStyle(color: color.withOpacity(0.8), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidthCard(String title, String value, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color.withOpacity(0.8), fontWeight: FontWeight.w600)),
                const Text("Clean these out to improve score", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}