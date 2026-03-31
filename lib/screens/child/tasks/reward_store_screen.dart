import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RewardStoreScreen extends StatefulWidget {
  final int initialCoins;
  const RewardStoreScreen({super.key, required this.initialCoins});

  @override
  State<RewardStoreScreen> createState() => _RewardStoreScreenState();
}

class _RewardStoreScreenState extends State<RewardStoreScreen>
    with SingleTickerProviderStateMixin {
  late int _coins;
  int _totalSpent = 0;
  late TabController _tabController;

  // ── App Time items ─────────────────────────────────────────────────────
  final List<_StoreItem> _appTimeItems = [
    _StoreItem(emoji: '▶️', iconBg: Color(0xFFFFE5E5), title: 'YouTube Kids',  subtitle: '+30 Minutes', price: 100),
    _StoreItem(emoji: '🎮', iconBg: Color(0xFFE5E5FF), title: 'Roblox',         subtitle: '+20 Minutes', price: 150),
    _StoreItem(emoji: '⭐', iconBg: Color(0xFFFFF8D6), title: 'Brawl Stars',    subtitle: '+15 Minutes', price: 80),
    _StoreItem(emoji: '🟩', iconBg: Color(0xFFE5F5E5), title: 'Minecraft',      subtitle: '+45 Minutes', price: 200),
    _StoreItem(emoji: '🏎️',iconBg: Color(0xFFFFEEDD), title: 'Racing Game',    subtitle: '+25 Minutes', price: 120),
  ];

  // ── Avatar items ───────────────────────────────────────────────────────
  final List<_AvatarItem> _avatarItems = [
    _AvatarItem(emoji: '👕', label: 'Green Shirt',    price: 0,   owned: true,  equipped: true),
    _AvatarItem(emoji: '🧑',  label: 'Cool Dude',     price: 450, owned: false, equipped: false),
    _AvatarItem(emoji: '🚀',  label: 'Rocket Pack',   price: 0,   owned: true,  equipped: false, isFree: true),
    _AvatarItem(emoji: '🧙',  label: 'Wizard',        price: 300, owned: false, equipped: false),
    _AvatarItem(emoji: '⚔️', label: 'Sword & Shield', price: -1,  owned: false, equipped: false, isLocked: true, lockLabel: 'LV.25'),
  ];

  @override
  void initState() {
    super.initState();
    _coins = widget.initialCoins;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Purchase helpers ───────────────────────────────────────────────────
  void _buyAppItem(_StoreItem item) {
    if (item.purchased) return;
    if (_coins < item.price) {
      _showNotEnoughDialog(item.price - _coins);
      return;
    }
    setState(() {
      item.purchased = true;
      _coins -= item.price;
      _totalSpent += item.price;
    });
    _showSuccessSnack('🎉 Unlocked ${item.title}! Enjoy your time!');
  }

  void _buyAvatarItem(_AvatarItem item, int index) {
    if (item.isLocked || item.equipped) return;
    if (item.owned) {
      setState(() {
        for (var a in _avatarItems) { a.equipped = false; }
        _avatarItems[index].equipped = true;
      });
      _showSuccessSnack('✅ Equipped ${item.label}!');
      return;
    }
    if (_coins < item.price) {
      _showNotEnoughDialog(item.price - _coins);
      return;
    }
    setState(() {
      _avatarItems[index].owned = true;
      _avatarItems[index].equipped = true;
      for (var i = 0; i < _avatarItems.length; i++) {
        if (i != index) _avatarItems[i].equipped = false;
      }
      _coins -= item.price;
      _totalSpent += item.price;
    });
    _showSuccessSnack('🎉 Got ${item.label}! Looking fresh!');
  }

  void _showNotEnoughDialog(int needed) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Not enough coins!',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1A1A2E)),
        ),
        content: Text(
          'You need $needed more coins.\nComplete more quests to earn them!',
          style: const TextStyle(color: Color(0xFF666680), fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B3FDB),
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnack(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1A1A2E),
        duration: const Duration(seconds: 2),
        content: Text(msg,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _totalSpent);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F8),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAppTimeTab(),
                  _buildAvatarTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7B4FE5), Color(0xFF5A30C8)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar row
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context, _totalSpent),
                  ),
                  const Expanded(
                    child: Text(
                      'Reward Store',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  // Coin pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text('$_coins',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(width: 4),
                        Text('COINS',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tab bar
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: const Color(0xFF6B3FDB),
                unselectedLabelColor: Colors.white,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14),
                unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'App Time'),
                  Tab(text: 'Avatar Items'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Time Tab ────────────────────────────────────────────────────────
  Widget _buildAppTimeTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(children: const [
          Text('⏱', style: TextStyle(fontSize: 18)),
          SizedBox(width: 6),
          Text('Unlock Extra Time',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E))),
        ]),
        const SizedBox(height: 14),
        ..._appTimeItems.map((item) => _buildAppTimeCard(item)),
        const SizedBox(height: 16),
        _buildEarnMoreBanner(),
      ],
    );
  }

  Widget _buildAppTimeCard(_StoreItem item) {
    final canAfford = _coins >= item.price;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: item.purchased ? const Color(0xFFF0FFF4) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: item.purchased
            ? Border.all(
                color: const Color(0xFF3FD68A).withValues(alpha: 0.4),
                width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _buyAppItem(item),
          splashColor: const Color(0xFF6B3FDB).withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: item.iconBg,
                      borderRadius: BorderRadius.circular(14)),
                  child: Center(
                      child: Text(item.emoji,
                          style: const TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: item.purchased
                              ? const Color(0xFF888888)
                              : const Color(0xFF1A1A2E),
                          decoration: item.purchased
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: const Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(item.subtitle,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B3FDB),
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                if (item.purchased)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                        color: Color(0xFF3FD68A), shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 20),
                  )
                else
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: canAfford
                            ? [
                                const Color(0xFF7B4FE5),
                                const Color(0xFF5A30C8)
                              ]
                            : [
                                const Color(0xFFCCCCDD),
                                const Color(0xFFBBBBCC)
                              ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text('${item.price}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Avatar Tab ──────────────────────────────────────────────────────────
  Widget _buildAvatarTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(children: const [
          Text('👕', style: TextStyle(fontSize: 18)),
          SizedBox(width: 6),
          Text('Outfits & Items',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E))),
        ]),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: _avatarItems.length,
          itemBuilder: (_, i) => _buildAvatarCell(_avatarItems[i], i),
        ),
        const SizedBox(height: 16),
        _buildEarnMoreBanner(),
      ],
    );
  }

  Widget _buildAvatarCell(_AvatarItem item, int index) {
    Color bg = Colors.white;
    Color? borderColor;
    double borderWidth = 0;

    Widget badge;

    if (item.equipped) {
      bg = const Color(0xFF6B3FDB);
      badge = const Text('EQUIPPED',
          style: TextStyle(
              color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800));
    } else if (item.isLocked) {
      bg = const Color(0xFFF0F0F0);
      badge = Text(item.lockLabel ?? 'LOCKED',
          style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 9,
              fontWeight: FontWeight.w700));
    } else if (item.isFree || item.owned) {
      borderColor = const Color(0xFF3FD68A);
      borderWidth = 2;
      badge = item.isFree
          ? const Text('FREE',
              style: TextStyle(
                  color: Color(0xFF3FD68A),
                  fontSize: 10,
                  fontWeight: FontWeight.w800))
          : Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('🪙', style: TextStyle(fontSize: 9)),
              const SizedBox(width: 2),
              Text('${item.price}',
                  style: const TextStyle(
                      color: Color(0xFF6B3FDB),
                      fontSize: 9,
                      fontWeight: FontWeight.w800)),
            ]);
    } else {
      badge = Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('🪙', style: TextStyle(fontSize: 9)),
        const SizedBox(width: 2),
        Text('${item.price}',
            style: const TextStyle(
                color: Color(0xFF6B3FDB),
                fontSize: 9,
                fontWeight: FontWeight.w800)),
      ]);
    }

    return GestureDetector(
      onTap: item.isLocked ? null : () => _buyAvatarItem(item, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: borderColor != null
              ? Border.all(color: borderColor, width: borderWidth)
              : null,
          boxShadow: [
            BoxShadow(
              color: item.equipped
                  ? const Color(0xFF6B3FDB).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 34)),
            const SizedBox(height: 4),
            badge,
          ],
        ),
      ),
    );
  }

  // ── Earn More Banner ────────────────────────────────────────────────────
  Widget _buildEarnMoreBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEE8FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('Earn More Coins',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6B3FDB))),
          const SizedBox(height: 4),
          const Text(
            'Complete your daily quests to earn more coins!',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: Color(0xFF888899), height: 1.4),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => Navigator.pop(context, _totalSpent),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: const Color(0xFF6B3FDB), width: 1.5),
              ),
              child: const Text('Go to Tasks',
                  style: TextStyle(
                      color: Color(0xFF6B3FDB),
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data Models ────────────────────────────────────────────────────────────────
class _StoreItem {
  final String emoji;
  final Color iconBg;
  final String title;
  final String subtitle;
  final int price;
  bool purchased = false;

  _StoreItem({
    required this.emoji,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.price,
  });
}

class _AvatarItem {
  final String emoji;
  final String label;
  final int price;
  bool owned;
  bool equipped;
  final bool isFree;
  final bool isLocked;
  final String? lockLabel;

  _AvatarItem({
    required this.emoji,
    required this.label,
    required this.price,
    this.owned = false,
    this.equipped = false,
    this.isFree = false,
    this.isLocked = false,
    this.lockLabel,
  });
}
