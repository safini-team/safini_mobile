import 'package:flutter/material.dart';

class ParentFamilyScreen extends StatelessWidget {
  const ParentFamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Family",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF43008F), Color(0xFF8100D1)],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          const Text(
            "YOUR CHILDREN",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildChildProfileCard(),
          const SizedBox(height: 16),
          _buildAddChildCard(),
          const SizedBox(height: 32),
          const Text(
            "PARENT ACCOUNT",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildParentAdminCard(),
          const SizedBox(height: 32),
          _buildTipsSection(),
          const SizedBox(height: 32),
          _buildSwitchLogoutButton(),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildChildProfileCard() {
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
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF8B46FF), width: 2),
                    ),
                    child: const Center(
                      child: Text("👦", style: TextStyle(fontSize: 48)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B46FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Text(
                      "Lv.5",
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Alex",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
                    ),
                    Text(
                      "Age 10 • Boy",
                      style: TextStyle(color: Colors.grey[400], fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(Icons.monetization_on_rounded, "150", "Coins", const Color(0xFFFFD700)),
                        _buildStatItem(Icons.stars_rounded, "1", "Quests", const Color(0xFF00C566)),
                        _buildStatItem(Icons.local_fire_department_rounded, "5", "Streak", const Color(0xFFFF3B30)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility_outlined, size: 20),
                  label: const Text("View as Kid"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B46FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.settings_outlined, size: 20),
                  label: const Text("Edit"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildAddChildCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F0FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, color: Color(0xFF8B46FF), size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Add Another Child", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text("Set up a new profile", style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 18),
        ],
      ),
    );
  }

  Widget _buildParentAdminCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFF5F5F5),
            child: Text("👨", style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Parent", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text("Family Admin", style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Admin",
              style: TextStyle(color: Color(0xFF8B46FF), fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text("🌟", style: TextStyle(fontSize: 20)),
              SizedBox(width: 12),
              Text(
                "Tips for Parents",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTipBullet("Set meaningful tasks that teach responsibility"),
          _buildTipBullet("Balance screen time rewards with outdoor activities"),
          _buildTipBullet("Celebrate achievements with your child"),
          _buildTipBullet("Adjust coin values to match effort levels"),
        ],
      ),
    );
  }

  Widget _buildTipBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, color: Color(0xFF8B46FF), size: 8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchLogoutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B30).withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFF3B30).withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.logout_rounded, color: Color(0xFFFF3B30), size: 22),
          SizedBox(width: 12),
          Text(
            "Switch to Kid Mode / Logout",
            style: TextStyle(
              color: Color(0xFFFF3B30),
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
