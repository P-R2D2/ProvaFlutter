import 'package:flutter/material.dart';
import '../../domain/entities/market_asset.dart';
import '../../domain/entities/asset_details.dart';
import '../../domain/usecases/search_assets_usecase.dart';
import '../../domain/usecases/get_asset_details_usecase.dart';
import '../../data/datasources/assets_remote_data_source.dart';

class AssetsProvider extends ChangeNotifier {
  final SearchAssetsUseCase searchUseCase;
  final GetAssetDetailsUseCase getDetailsUseCase;

  List<MarketAsset> _searchResults = [];
  AssetDetails? _selectedAssetDetails;
  bool _isSearching = false;
  bool _isLoadingDetails = false;
  String? _errorMessage;
  bool _isRetryableError = false;

  String? _lastQuery;
  String? _lastTicker;
  bool _lastActionWasDetails = false;

  List<MarketAsset> get searchResults => _searchResults;
  AssetDetails? get selectedAssetDetails => _selectedAssetDetails;
  bool get isSearching => _isSearching;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get errorMessage => _errorMessage;
  bool get isRetryableError => _isRetryableError;

  AssetsProvider({
    required this.searchUseCase,
    required this.getDetailsUseCase,
  });

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    _lastQuery = query;
    _lastActionWasDetails = false;
    _isSearching = true;
    _errorMessage = null;
    _isRetryableError = false;
    notifyListeners();

    try {
      final results = await searchUseCase(query);
      _searchResults = results;
    } on AssetsServerException catch (e) {
      _errorMessage = e.message;
      _isRetryableError = e.retryable;
      _searchResults = [];
    } catch (e) {
      _errorMessage = 'Não foi possível buscar ativos';
      _isRetryableError = true;
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> getDetails(String ticker) async {
    _lastTicker = ticker;
    _lastActionWasDetails = true;
    _isLoadingDetails = true;
    _selectedAssetDetails = null;
    _errorMessage = null;
    _isRetryableError = false;
    notifyListeners();

    try {
      final details = await getDetailsUseCase(ticker);
      _selectedAssetDetails = details;
    } on AssetsServerException catch (e) {
      _errorMessage = e.message;
      _isRetryableError = e.retryable;
    } catch (e) {
      _errorMessage = 'Não foi possível carregar os detalhes do ativo';
      _isRetryableError = true;
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  void retryLastAction() {
    if (_lastActionWasDetails && _lastTicker != null) {
      getDetails(_lastTicker!);
    } else if (!_lastActionWasDetails && _lastQuery != null) {
      search(_lastQuery!);
    }
  }

  void clearSearch() {
    _searchResults = [];
    _selectedAssetDetails = null;
    _errorMessage = null;
    _isRetryableError = false;
    _lastQuery = null;
    notifyListeners();
  }
}
