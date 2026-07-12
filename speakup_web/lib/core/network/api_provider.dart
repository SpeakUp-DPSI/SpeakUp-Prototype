import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'token_manager.dart';

final tokenManagerProvider = Provider<TokenManager>((ref) {
  return TokenManager();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
