import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/tarot/data/tarot_spread_registry.dart';

void main() {
  test('manual-safe spreads preserve canonical self-reading identities', () {
    expect(TarotSpreadRegistry.manualRecordingSpreads, hasLength(2));
    expect(TarotSpreadRegistry.oneCard.id, 'one_card');
    expect(TarotSpreadRegistry.oneCard.displayName, '1카드');
    expect(
      TarotSpreadRegistry.oneCard.positions
          .map((position) => position.id)
          .toList(),
      ['one_center'],
    );
    expect(TarotSpreadRegistry.threeCard.id, 'three_card');
    expect(TarotSpreadRegistry.threeCard.displayName, '3카드');
    expect(
      TarotSpreadRegistry.threeCard.positions
          .map((position) => position.id)
          .toList(),
      ['three_past', 'three_present', 'three_future'],
    );
    expect(
      TarotSpreadRegistry.threeCard.positions
          .map((position) => position.displayName)
          .toList(),
      ['과거', '현재', '미래'],
    );
  });
}
