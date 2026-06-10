import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../models/route.dart' as app_route;
import '../providers/app_provider.dart';
import 'app_colors.dart';

class CaptainRequestsScreen extends StatelessWidget {
  final app_route.Route route;
  const CaptainRequestsScreen({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Passenger Requests', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final requests = provider.getRequestsForRoute(route.id);
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(gradient: appGradient(), borderRadius: BorderRadius.circular(18)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${route.start} → ${route.end}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('${route.time} • ${route.cost.round()} EGP/seat • ${route.available_seats ?? 0} seats', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(route.car_model ?? 'Private car', style: const TextStyle(color: Colors.white70)),
                ]),
              ),
              const SizedBox(height: 18),
              Row(children: [
                const Expanded(child: Text('Requests from riders', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
                Chip(label: Text('${requests.length}')),
              ]),
              const SizedBox(height: 10),
              if (requests.isEmpty)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: cardDecoration(radius: 16),
                  child: const Column(children: [
                    Icon(Icons.people_outline_rounded, size: 42, color: AppColors.muted),
                    SizedBox(height: 10),
                    Text('No passenger requests yet', style: TextStyle(fontWeight: FontWeight.w900)),
                    SizedBox(height: 4),
                    Text('When riders request to join your private car ride, they will appear here.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
                  ]),
                )
              else
                ...requests.map((request) => _RequestCard(routeId: route.id, request: request)),
            ],
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String routeId;
  final Booking request;
  const _RequestCard({required this.routeId, required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(radius: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 10),
          Expanded(child: Text('Rider ${request.user_name ?? request.user_id}', style: const TextStyle(fontWeight: FontWeight.w900))),
          _StatusChip(status: request.status),
        ]),
        const SizedBox(height: 10),
        Text('${request.start ?? ''} → ${request.end ?? ''}', style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('${request.time ?? ''} • ${(request.cost ?? 0).round()} EGP', style: const TextStyle(color: AppColors.muted)),
        if (request.status == 'requested' || request.status == 'booked') ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => context.read<AppProvider>().rejectRideRequest(routeId, request), child: const Text('Reject'))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(onPressed: () => context.read<AppProvider>().approveRideRequest(routeId, request), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: const Text('Accept'))),
          ]),
        ],
      ]),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final approved = status == 'approved';
    final rejected = status == 'rejected';
    final color = approved ? Colors.green : rejected ? Colors.red : AppColors.secondary;
    return Chip(label: Text(status), labelStyle: TextStyle(color: color, fontWeight: FontWeight.w800), backgroundColor: color.withOpacity(.1));
  }
}