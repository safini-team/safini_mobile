import 'package:safini/features/models/domain/models/family_model.dart';

/// Children oldest first, the order of every child selector. A tab that has
/// nobody picked opens on the first one, the oldest (SAF-269). Children of
/// the same age keep the family's order.
List<ChildSummaryModel> oldestFirst(Iterable<ChildSummaryModel> children) {
  final indexed = children.toList().asMap().entries.toList()
    ..sort((a, b) {
      final byAge = b.value.age.compareTo(a.value.age);
      return byAge != 0 ? byAge : a.key.compareTo(b.key);
    });
  return [for (final entry in indexed) entry.value];
}
