import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'reward_store_screen.dart';

class HomeTab extends StatefulWidget {
  final int totalCoins;
  final ValueChanged<int> onCoinsChanged;
  const HomeTab({
    super.key,
    required this.totalCoins,
    required this.onCoinsChanged,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  final List<_Quest> _quests = [
    _Quest(
      emoji: '🌍',
      iconBg: const Color(0xFFD6F5EC),
      title: 'Complete Duolingo',
      subtitle: 'Daily streak bonus!',
      coins: 20,
      completed: false,
    ),
    _Quest(
      emoji: '👟',
      iconBg: const Color(0xFFFFF0E0),
      title: 'Walk 5,000 Steps',
      subtitle: 'Keep it moving!',
      coins: 10,
      completed: false,
    ),
    _Quest(
      emoji: '✳️',
      iconBg: const Color(0xFFF0F0F5),
      title: 'Logical Puzzle',
      subtitle: 'Brain power boost',
      coins: 15,
      completed: false,
    ),
    _Quest(
      emoji: '♟',
      iconBg: const Color(0xFFE8E8F0),
      title: 'Chess Lesson',
      subtitle: 'Master the board',
      coins: 25,
      completed: false,
    ),
    _Quest(
      emoji: '📚',
      iconBg: const Color(0xFFFFE5EA),
      title: 'Read for 20 mins',
      subtitle: 'Expand your mind',
      coins: 15,
      completed: false,
    ),
    _Quest(
      emoji: '🧹',
      iconBg: const Color(0xFFFFF8D6),
      title: 'Clean your room',
      subtitle: 'Daily chore',
      coins: 30,
      completed: false,
    ),
  ];

  int get _completedCount => _quests.where((q) => q.completed).length;

  // ── Complete quest & earn coins ──────────────────────────────────────────
  void _completeQuest(int index) {
    final quest = _quests[index];
    if (quest.completed) return;

    setState(() {
      _quests[index] = _Quest(
        emoji: quest.emoji,
        iconBg: quest.iconBg,
        title: quest.title,
        subtitle: quest.subtitle,
        coins: quest.coins,
        completed: true,
      );
    });

    widget.onCoinsChanged(quest.coins);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1A1A2E),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Quest complete! +${quest.coins} 🪙',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Open Reward Store ────────────────────────────────────────────────────
  Future<void> _openRewardStore() async {
    final spent = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => RewardStoreScreen(initialCoins: widget.totalCoins),
      ),
    );
    if (spent != null && spent > 0) {
      widget.onCoinsChanged(-spent);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Purple header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            collapsedHeight: 0,
            toolbarHeight: 0,
            pinned: false,
            floating: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _buildPurpleHeader(),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFFF4F4F8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reward Store Banner
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: _buildRewardStoreBanner(),
                  ),

                  // Today's Quests header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Row(
                      children: [
                        const Text(
                          "Today's Quests",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const Spacer(),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _completedCount == _quests.length
                                ? const Color(0xFF3FD68A).withOpacity(0.15)
                                : const Color(0xFF6B3FDB).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_completedCount/${_quests.length}',
                            style: TextStyle(
                              color: _completedCount == _quests.length
                                  ? const Color(0xFF3FD68A)
                                  : const Color(0xFF6B3FDB),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quest Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: List.generate(
                        _quests.length,
                        (i) => _buildQuestCard(i),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Purple Header ────────────────────────────────────────────────────────
  Widget _buildPurpleHeader() {
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('🧒', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey, Alex! 👋',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        "Let's do some quests!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Coin pill
                  GestureDetector(
                    onTap: _openRewardStore,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('🪙',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 5),
                          Text(
                            '${widget.totalCoins}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Progress card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Today's Progress",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$_completedCount of ${_quests.length} done',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: _quests.isEmpty
                              ? 0
                              : _completedCount / _quests.length,
                        ),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        builder: (_, value, __) => LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor:
                              Colors.white.withOpacity(0.25),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFC542),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reward Store Banner ──────────────────────────────────────────────────
  Widget _buildRewardStoreBanner() {
    return GestureDetector(
      onTap: _openRewardStore,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF7B4FE5), Color(0xFF5A30C8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B3FDB).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(Icons.shopping_basket_rounded,
                    color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reward Store',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Spend your Time Coins',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  // ── Quest Card ───────────────────────────────────────────────────────────
  Widget _buildQuestCard(int index) {
    final quest = _quests[index];
    return GestureDetector(
      onTap: () => _completeQuest(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: quest.completed
              ? const Color(0xFFF8FFF8)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: quest.completed
              ? Border.all(
                  color: const Color(0xFF3FD68A).withOpacity(0.35),
                  width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: quest.completed
                    ? const Color(0xFFE8F8F0)
                    : quest.iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  quest.emoji,
                  style: const TextStyle(
                    fontSize: 26,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: quest.completed
                          ? const Color(0xFFAAAAAA)
                          : const Color(0xFF1A1A2E),
                      decoration: quest.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: const Color(0xFFAAAAAA),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    quest.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFAAAAAA),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Right badge
            if (quest.completed)
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF3FD68A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 18),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF6B3FDB).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙',
                        style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 3),
                    Text(
                      '${quest.coins}',
                      style: const TextStyle(
                        color: Color(0xFF6B3FDB),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Model ──────────────────────────────────────────────────────────────────────
class _Quest {
  final String emoji;
  final Color iconBg;
  final String title;
  final String subtitle;
  final int coins;
  final bool completed;

  const _Quest({
    required this.emoji,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.coins,
    required this.completed,
  });
}
