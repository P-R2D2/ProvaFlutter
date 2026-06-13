import '../entities/asset_details.dart';
import '../repositories/assets_repository.dart';

class GetAssetDetailsUseCase {
  final AssetsRepository repository;

  GetAssetDetailsUseCase(this.repository);

  Future<AssetDetails> call(String ticker) {
    return repository.getAssetDetails(ticker);
  }
}
