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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Screen Time",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(weeklyUsage.length, (index) {
                final heightFactor = weeklyUsage[index];
                final isHighlight = index == 4; // FRI is highlighted in the image
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F0FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                FractionallySizedBox(
                                  heightFactor: heightFactor,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isHighlight 
                                          ? const Color(0xFF8B46FF) 
                                          : const Color(0xFFA17DFF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          days[index],
                          style: TextStyle(
                            color: isHighlight ? const Color(0xFF8B46FF) : Colors.grey[400],
                            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
