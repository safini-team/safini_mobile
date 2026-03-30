import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TasksTab extends StatefulWidget {
  final int totalCoins;
  final ValueChanged<int> onCoinsChanged;
  const TasksTab({
    super.key,
    required this.totalCoins,
    required this.onCoinsChanged,
  });

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  String _selectedCategory = 'All';

  late List<_QuestItem> _allQuests = [
    _QuestItem(
      emoji: '🌍',
      iconBg: const Color(0xFFD6F5EC),
      title: 'Complete Duolingo',
      subtitle: 'Daily streak bonus!',
      coins: 20,
      xp: 30,
      category: 'Learn',
      completed: true,
    ),
    _QuestItem(
      emoji: '👟',
      iconBg: const Color(0xFFFFF0E0),
      title: 'Walk 5,000 Steps',
      subtitle: 'Keep it moving!',
      coins: 10,
      xp: 15,
      category: 'Fitness',
      completed: false,
    ),
    _QuestItem(
      emoji: '🧩',
      iconBg: const Color(0xFFE0F0FF),
      title: 'Logical Puzzle',
      subtitle: 'Brain power boost',
      coins: 15,
      xp: 20,
      category: 'Logic',
      completed: false,
    ),
    _QuestItem(
      emoji: '♟️',
      iconBg: const Color(0xFFE8E8F0),
      title: 'Chess Lesson',
      subtitle: 'Master the board',
      coins: 25,
      xp: 35,
      category: 'Learn',
      completed: false,
    ),
    _QuestItem(
      emoji: '📚',
      iconBg: const Color(0xFFFFE5EA),
      title: 'Read for 20 mins',
      subtitle: 'Expand your mind',
      coins: 15,
      xp: 20,
      category: 'Learn',
      completed: false,
    ),
    _QuestItem(
      emoji: '🧹',
      iconBg: const Color(0xFFFFF8D6),
      title: 'Clean your room',
      subtitle: 'Daily chore',
      coins: 30,
      xp: 40,
      category: 'Other',
      completed: false,
    ),
  ];

  int get _completedCount => _allQuests.where((q) => q.completed).length;
  int get _earnedToday => _allQuests.where((q) => q.completed).fold(0, (sum, q) => sum + q.coins);

  List<_QuestItem> get _filteredQuests {
    if (_selectedCategory == 'All') return _allQuests;
    return _allQuests.where((q) => q.category == _selectedCategory).toList();
  }

  void _completeQuest(int index) {
    final quest = _allQuests[index];
    if (quest.completed) return;

    setState(() {
      _allQuests[index] = _QuestItem(
        emoji: quest.emoji,
        iconBg: quest.iconBg,
        title: quest.title,
        subtitle: quest.subtitle,
        coins: quest.coins,
        xp: quest.xp,
        category: quest.category,
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
        duration: const Duration(seconds: 1),
        content: Text('🎉 +${quest.coins} coins and +${quest.xp} XP!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Purple Header ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            collapsedHeight: 0,
            toolbarHeight: 0,
            pinned: false,
            floating: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _buildHeader(),
            ),
          ),

          // ── Filter Chips ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFFF4F4F8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildCategoryFilters(),
                  
                  // ── Quest List ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: _filteredQuests
                          .map((q) => _buildQuestCard(q))
                          .toList(),
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

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF6B3FDB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Coin Balance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Quests',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.totalCoins}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Summary Cards
              Row(
                children: [
                  _buildSummaryCard('$_completedCount', 'Done Today'),
                  const SizedBox(width: 12),
                  _buildSummaryCard('${_allQuests.length - _completedCount}', 'Remaining'),
                  const SizedBox(width: 12),
                  _buildSummaryCard('$_earnedToday', 'Earned Today'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = [
      {'name': 'All', 'icon': '✨'},
      {'name': 'Learn', 'icon': '📚'},
      {'name': 'Fitness', 'icon': '💪'},
      {'name': 'Logic', 'icon': '🧩'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat['name'];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat['name']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6B3FDB) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (!isSelected)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(cat['icon']!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      cat['name']!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF6B3FDB),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuestCard(_QuestItem quest) {
    final index = _allQuests.indexOf(quest);
    return GestureDetector(
      onTap: () => _completeQuest(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: quest.completed
              ? Border.all(color: const Color(0xFF6BE3B0).withOpacity(0.3), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Quest Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: quest.iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(quest.emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: quest.completed ? Colors.black.withOpacity(0.3) : const Color(0xFF1A1A2E),
                      decoration: quest.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quest.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildBadge('🪙 ${quest.coins} coins', const Color(0xFF6B3FDB).withOpacity(0.1), const Color(0xFF6B3FDB)),
                      const SizedBox(width: 8),
                      _buildBadge('⚡ ${quest.xp} XP', const Color(0xFFFFA000).withOpacity(0.1), const Color(0xFFFFA000)),
                    ],
                  ),
                ],
              ),
            ),
            // Checkmark
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: quest.completed ? const Color(0xFF6BE3B0) : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: quest.completed
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color textStyle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textStyle,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _QuestItem {
  final String emoji;
  final Color iconBg;
  final String title;
  final String subtitle;
  final int coins;
  final int xp;
  final String category;
  final bool completed;

  _QuestItem({
    required this.emoji,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.coins,
    required this.xp,
    required this.category,
    required this.completed,
  });
}
