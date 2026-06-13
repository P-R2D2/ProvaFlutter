import '../entities/market_asset.dart';
import '../repositories/assets_repository.dart';

class SearchAssetsUseCase {
  final AssetsRepository repository;

  SearchAssetsUseCase(this.repository);

  Future<List<MarketAsset>> call(String query) {
    return repository.searchAssets(query);
  }
}
