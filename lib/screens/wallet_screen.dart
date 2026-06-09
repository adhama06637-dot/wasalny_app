import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'Ride_screen.dart';
import 'app_colors.dart';

class WalletScreen extends StatelessWidget {
  final bool showBottomNav;
  const WalletScreen({super.key, this.showBottomNav = true});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: appGradient(), borderRadius: BorderRadius.circular(18)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('My Balance', style: TextStyle(color: Colors.white70)), Text('${provider.walletBalance} EGP', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold))])), ElevatedButton(onPressed: () => provider.topUpWallet(100), child: const Text('+ Top Up'))])),
        const SizedBox(height: 20),
        const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        ...provider.bookings.map((booking) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14), decoration: cardDecoration(), child: Row(children: [const CircleAvatar(child: Icon(Icons.directions_car)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Ride ${booking.start ?? ''} - ${booking.end ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)), Text(booking.payment_status, style: const TextStyle(color: AppColors.muted, fontSize: 12))])), Text('-${(booking.cost ?? 0).toStringAsFixed(0)} EGP', style: const TextStyle(fontWeight: FontWeight.bold))]))),
        Container(margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(16), decoration: cardDecoration(), child: ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.credit_card, color: AppColors.primary), title: const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.bold)), trailing: const Icon(Icons.chevron_right), onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment methods opened'))))),
      ]),
      bottomNavigationBar: showBottomNav ? const RideBottomNav(currentIndex: 2) : null,
    );
  }
}