import 'package:one_atta/core/network/network_info.dart';

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // For development, always return true
    // TODO: Implement actual network connectivity check
    return true;
  }
}
