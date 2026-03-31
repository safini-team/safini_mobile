import 'package:flutter/material.dart';

class AppsTab extends StatefulWidget {
  const AppsTab({super.key});

  @override
  State<AppsTab> createState() => _AppsTabState();
}

class _AppsTabState extends State<AppsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoBanner(),
                  const SizedBox(height: 24),
                  _buildAppLimitCard(
                    name: 'YouTube Kids',
                    usage: '48m used / 60m limit',
                    remaining: '12m remaining',
                    progress: 0.8,
                    limit: '60m',
                    color: Colors.orange,
                    icon: '▶️',
                    isOn: true,
                  ),
                  const SizedBox(height: 16),
                  _buildAppLimitCard(
                    name: 'Roblox',
                    usage: '15m used / 60m limit',
                    remaining: '45m remaining',
                    progress: 0.25,
                    limit: '60m',
                    color: Colors.teal,
                    icon: '🎮',
                    isOn: true,
                  ),
                  const SizedBox(height: 16),
                  _buildAppLimitCard(
                    name: 'Brawl Stars',
                    usage: '5m used / 45m limit',
                    remaining: '40m remaining',
                    progress: 0.1,
                    limit: '45m',
                    color: Colors.amber,
                    icon: '⭐',
                    isOn: true,
                  ),
                  const SizedBox(height: 16),
                  _buildAppLimitCard(
                    name: 'Minecraft',
                    usage: '30m used / 90m limit',
                    remaining: '60m remaining',
                    progress: 0.33,
                    limit: '90m',
                    color: Colors.green,
                    icon: '🟩',
                    isOn: true,
                  ),
                  const SizedBox(height: 24),
                  _buildAddAnotherAppBtn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAnotherAppBtn() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.deepPurple.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid, // Flutter doesn't have a direct 'dashed' property for Border.all
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: Colors.deepPurple),
          SizedBox(width: 8),
          Text(
            'Add Another App',
            style: TextStyle(
              color: Colors.deepPurple,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A148C), Color(0xFF311B92)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'App Limits',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Set daily screen time limits',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEE5FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Kids earn Time Coins to unlock extra minutes for these apps.',
              style: TextStyle(
                color: Color(0xFF4A148C),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppLimitCard({
    required String name,
    required String usage,
    required String remaining,
    required double progress,
    required String limit,
    required Color color,
    required String icon,
    required bool isOn,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      usage,
                      style: TextStyle(
                        fontSize: 14,
                        color: color.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isOn,
                onChanged: (val) {},
                activeColor: Colors.deepPurple,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Limit',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  _buildControlBtn(Icons.remove, color: const Color(0xFFEEE5FF)),
                  const SizedBox(width: 12),
                  Text(
                    limit,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildControlBtn(Icons.add, color: const Color(0xFFEEE5FF)),
                ],
              ),
              Text(
                remaining,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn(IconData icon, {required Color color}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.deepPurple, size: 20),
    );
  }
}
