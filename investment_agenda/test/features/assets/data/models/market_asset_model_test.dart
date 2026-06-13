import 'package:flutter_test/flutter_test.dart';
import 'package:investment_agenda/features/assets/data/models/market_asset_model.dart';

void main() {
  group('MarketAssetModel', () {
    test('should parse from JSON successfully', () {
      final json = {'symbol': 'VALE3', 'name': 'Vale S.A.'};
      final model = MarketAssetModel.fromJson(json);

      expect(model.symbol, 'VALE3');
      expect(model.name, 'Vale S.A.');
    });

    test('should serialize to JSON successfully', () {
      const model = MarketAssetModel(symbol: 'PETR4', name: 'Petrobras');
      final json = model.toJson();

      expect(json['symbol'], 'PETR4');
      expect(json['name'], 'Petrobras');
    });
  });
}
