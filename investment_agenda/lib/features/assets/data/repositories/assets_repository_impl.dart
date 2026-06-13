import '../../domain/entities/market_asset.dart';
import '../../domain/entities/asset_details.dart';
import '../../domain/repositories/assets_repository.dart';
import '../datasources/assets_remote_data_source.dart';

class AssetsRepositoryImpl implements AssetsRepository {
  final AssetsRemoteDataSource remoteDataSource;
  final Future<String> Function() getToken;

  AssetsRepositoryImpl({
    required this.remoteDataSource,
    required this.getToken,
  });

  @override
  Future<List<MarketAsset>> searchAssets(String query) async {
    final token = await getToken();
    return remoteDataSource.searchAssets(query, token);
  }

  @override
  Future<AssetDetails> getAssetDetails(String ticker) async {
    final token = await getToken();
    return remoteDataSource.getAssetDetails(ticker, token);
  }
}
