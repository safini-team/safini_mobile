import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

class ParentScreenTimeChart extends StatelessWidget {
  final List<double> weeklyUsage; // values between 0.0 and 1.0

  const ParentScreenTimeChart({
    super.key,
    required this.weeklyUsage,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Screen Time",
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(weeklyUsage.length, (index) {
                final heightFactor = weeklyUsage[index];
                final isToday = DateTime.now().weekday - 1 == index;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        width: 30,
                        decoration: BoxDecoration(
                          color: isToday 
                              ? const Color(0xFF8100D1) 
                              : const Color(0xFFC7A2FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FractionallySizedBox(
                          heightFactor: 1.0, // Base bar
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isToday 
                                  ? const Color(0xFF8100D1) 
                                  : const Color(0xFFC7A2FF).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            height: 120 * heightFactor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[index],
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
