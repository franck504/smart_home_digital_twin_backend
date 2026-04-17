import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class IpNotifier extends Notifier<String> {
  static const _ipKey = 'backend_ip';

  @override
  String build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString(_ipKey) ?? ApiConstants.currentIp;
  }


  Future<void> updateIp(String newIp) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_ipKey, newIp);
    state = newIp;
  }
}

final ipProvider = NotifierProvider<IpNotifier, String>(() {
  return IpNotifier();
});
