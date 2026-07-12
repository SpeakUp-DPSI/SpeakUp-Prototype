import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_provider.dart';
import '../../data/datasources/follow_up_remote_data_source.dart';

final followUpRemoteDataSourceProvider = Provider<FollowUpRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return FollowUpRemoteDataSource(apiClient);
});
