import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_provider.dart';
import '../../data/datasources/mediation_remote_data_source.dart';

final mediationRemoteDataSourceProvider = Provider<MediationRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return MediationRemoteDataSource(apiClient);
});
