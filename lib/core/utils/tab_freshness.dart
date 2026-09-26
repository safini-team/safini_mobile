/// How long a tab's data counts as current when the parent switches back to
/// it. Pull-to-refresh, app resume and pushes always refetch; only a tab
/// switch inside this window reuses what is already on screen.
const Duration tabFreshFor = Duration(seconds: 30);

/// Whether data loaded at [loadedAt] can be shown again without a refetch.
bool isTabFresh(DateTime? loadedAt) =>
    loadedAt != null && DateTime.now().difference(loadedAt) < tabFreshFor;
