import 'package:flutter/material.dart';
import '../models/route_step.dart';

class RouteStepWidget extends StatelessWidget {
  final RouteStep step;
  final bool isLast;
  final bool showArrived;

  const RouteStepWidget({
    super.key,
    required this.step,
    this.isLast = false,
    this.showArrived = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _getStepColor(),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  _getStepIcon(),
                  color: Colors.white,
                  size: 14,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.instruction,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${step.fromStation} → ${step.toStation}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (step.lineNumber != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStepColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'خط ${step.lineNumber}',
                          style: TextStyle(
                            color: _getStepColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    if (step.price != null || step.durationMinutes != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (step.price != null) ...[
                            Icon(Icons.attach_money, size: 16, color: Colors.green[700]),
                            const SizedBox(width: 4),
                            Text(
                              '${step.price!.toStringAsFixed(0)} ج.م',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          if (step.price != null && step.durationMinutes != null)
                            const SizedBox(width: 16),
                          if (step.durationMinutes != null) ...[
                            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${step.durationMinutes} دقيقة',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStepColor() {
    switch (step.mode) {
      case TransportMode.microbus:
        return Colors.orange;
      case TransportMode.bus:
        return Colors.blue;
      case TransportMode.car:
        return Colors.green;
      case TransportMode.walk:
        return Colors.grey;
    }
  }

  IconData _getStepIcon() {
    switch (step.mode) {
      case TransportMode.microbus:
        return Icons.airport_shuttle;
      case TransportMode.bus:
        return Icons.directions_bus;
      case TransportMode.car:
        return Icons.directions_car;
      case TransportMode.walk:
        return Icons.directions_walk;
    }
  }
}