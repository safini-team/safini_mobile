import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileTab extends StatefulWidget {
  final int totalCoins;
  final String initialName;
  final ValueChanged<String> onNameChanged;

  const ProfileTab({
    super.key,
    required this.totalCoins,
    required this.initialName,
    required this.onNameChanged,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
  }

  void _showComingSoon() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Text('🏆 ', style: TextStyle(fontSize: 20)),
            Text('Achievements'),
          ],
        ),
        content: const Text('Coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF6B3FDB), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _editName() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change My Name', style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: "Enter your name",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                widget.onNameChanged(_nameController.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B3FDB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openAvatarCustomization() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyAvatarScreen(totalCoins: widget.totalCoins)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Purple Header ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF6B3FDB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Avatar with Badge
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          image: const DecorationImage(
                            image: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Leo'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFA000),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Text('🚀', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Name and Edit Icon
                  GestureDetector(
                    onTap: _editName,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.initialName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.edit_outlined, color: Colors.white.withOpacity(0.7), size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Level Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('⭐ ', style: TextStyle(fontSize: 14)),
                        Text(
                          'Level 5 Hero',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Main Content ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level Progress Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'LEVEL PROGRESS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.black26,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '275 / 300 XP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      value: 275 / 300,
                      minHeight: 12,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFA000)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '25 XP to Level 6',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Stats row
                  Row(
                    children: [
                      _buildStatCard('250', 'Coins', const Color(0xFFFFF8E1), const Color(0xFFFFA000)),
                      const SizedBox(width: 12),
                      _buildStatCard('6', 'Quests Done', const Color(0xFFF3E5F5), const Color(0xFF6B3FDB)),
                      const SizedBox(width: 12),
                      _buildStatCard('5', 'Day Streak', const Color(0xFFFFF3E0), const Color(0xFFFF7043)),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButton(
                    icon: '🎨',
                    iconBg: const Color(0xFFEDE7F6),
                    title: 'Customize Avatar',
                    subtitle: 'Change outfit, hair & more',
                    onTap: _openAvatarCustomization,
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    icon: '🏆',
                    iconBg: const Color(0xFFFFF9C4),
                    title: 'Achievements',
                    subtitle: '6 unlocked',
                    onTap: _showComingSoon,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color bg, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
             Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
              ),
              child: Text(
                label == 'Coins' ? '🪙' : (label == 'Quests Done' ? '⚡' : '🔥'),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.black.withOpacity(0.4),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}

// ── My Avatar Screen ───────────────────────────────────────────────────────
class MyAvatarScreen extends StatefulWidget {
  final int totalCoins;
  const MyAvatarScreen({super.key, required this.totalCoins});

  @override
  State<MyAvatarScreen> createState() => _MyAvatarScreenState();
}

class _MyAvatarScreenState extends State<MyAvatarScreen> {
  String _selectedCategory = 'OUTFITS';

  final List<Map<String, dynamic>> _outfits = [
    {'icon': '👕', 'price': 0, 'owned': true, 'equipped': false, 'label': 'FREE'},
    {'icon': '🦸', 'price': 450, 'owned': false, 'equipped': false, 'label': '450'},
    {'icon': '🚀', 'price': 0, 'owned': true, 'equipped': true, 'label': 'ON'},
    {'icon': '🧙', 'price': 300, 'owned': false, 'equipped': false, 'label': '300'},
    {'icon': '⚔️', 'price': 1000, 'owned': false, 'equipped': false, 'label': 'LV.25', 'locked': true},
    {'icon': '🤖', 'price': 500, 'owned': false, 'equipped': false, 'label': '500'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1B2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Avatar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🪙 ', style: TextStyle(fontSize: 14)),
                Text(
                  '${widget.totalCoins}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Avatar Preview
          Center(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text('🧒', style: TextStyle(fontSize: 100)),
                   Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA000),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1F1B2E), width: 2),
                      ),
                      child: const Text('🚀', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
           Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Text('5', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFFFFA000))),
          ),

          const Spacer(),

          // Customization Panel
          Container(
            width: double.infinity,
            height: 480,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              children: [
                // Categories
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCategoryItem('👕', 'OUTFITS'),
                    _buildCategoryItem('😊', 'FACE'),
                    _buildCategoryItem('✂️', 'HAIR'),
                    _buildCategoryItem('🎒', 'BACK'),
                  ],
                ),
                const SizedBox(height: 32),
                // Items Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _outfits.length,
                    itemBuilder: (context, index) {
                      final item = _outfits[index];
                      final isEquipped = item['equipped'] == true;
                      return _buildItemCard(item, isEquipped);
                    },
                  ),
                ),
                // Save Button
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B3FDB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      shadowColor: const Color(0xFF6B3FDB).withOpacity(0.4),
                    ),
                    child: const Text(
                      'Save My Look!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String icon, String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6B3FDB).withOpacity(0.1) : const Color(0xFFF4F4F8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isSelected ? const Color(0xFF6B3FDB) : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, bool isEquipped) {
    return Container(
      decoration: BoxDecoration(
        color: isEquipped ? const Color(0xFF6B3FDB) : const Color(0xFFF4F4F8),
        borderRadius: BorderRadius.circular(20),
        border: isEquipped ? Border.all(color: Colors.white.withOpacity(0.2), width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item['icon'], style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          if (item['locked'] == true)
            Column(
              children: [
                const Icon(Icons.lock_outline_rounded, color: Colors.black26, size: 14),
                const SizedBox(height: 2),
                Text(
                  item['label'],
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black26),
                ),
              ],
            )
          else if (isEquipped)
            const Text(
              'ON',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 if (item['price'] > 0) ...[
                   const Text('🪙 ', style: TextStyle(fontSize: 10)),
                    Text(
                      '${item['price']}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFFFA000)),
                    ),
                 ] else
                  const Text(
                    'FREE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF6BE3B0)),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
