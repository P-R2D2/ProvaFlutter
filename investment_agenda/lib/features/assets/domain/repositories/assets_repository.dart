import '../entities/market_asset.dart';
import '../entities/asset_details.dart';

abstract class AssetsRepository {
  Future<List<MarketAsset>> searchAssets(String query);
  Future<AssetDetails> getAssetDetails(String ticker);
}
