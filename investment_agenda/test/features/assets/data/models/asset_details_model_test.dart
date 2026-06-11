import 'package:flutter_test/flutter_test.dart';
import 'package:investment_agenda/features/assets/data/models/asset_details_model.dart';

void main() {
  group('AssetDetailsModel', () {
    test('should parse detailed properties from JSON successfully', () {
      final json = {
        'symbol': 'ITUB4',
        'name': 'Itau Unibanco',
        'currentPrice': 33.20,
        'dayHigh': 34.00,
        'dayLow': 32.80,
        'changePercent': 1.15,
        'currency': 'BRL',
        'updatedAt': '2026-05-30T00:00:00.000Z'
      };

      final model = AssetDetailsModel.fromJson(json);

      expect(model.symbol, 'ITUB4');
      expect(model.currentPrice, 33.20);
      expect(model.dayHigh, 34.00);
      expect(model.dayLow, 32.80);
      expect(model.changePercent, 1.15);
      expect(model.currency, 'BRL');
    });
  });
}
