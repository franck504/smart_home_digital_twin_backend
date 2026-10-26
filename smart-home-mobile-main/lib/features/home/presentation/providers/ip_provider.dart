import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

class IpNotifier extends Notifier<String> {
  static const _ipKey = 'backend_ip';

  @override
  String build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedIp = prefs.getString(_ipKey);
    return savedIp != null && savedIp.isNotEmpty
        ? ApiConstants.sanitizeIp(savedIp)
        : ApiConstants.defaultIp;
  }

  /// Met à jour l'adresse IP de manière persistante et notifie les écouteurs réactifs.
  Future<void> updateIp(String newIp) async {
    final sanitized = ApiConstants.sanitizeIp(newIp);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_ipKey, sanitized);
    state = sanitized;
  }
}

final ipProvider = NotifierProvider<IpNotifier, String>(() {
  return IpNotifier();
});
