/// Configuration réseau centralisée du Jumeau Numérique.
class ApiConstants {
  ApiConstants._();

  /// Port par défaut du serveur FastAPI.
  static const int defaultPort = 8000;

  /// IP par défaut (10.0.2.2 pour l'émulateur Android vers localhost,
  /// ou 127.0.0.1 pour simulateur iOS / Web / Desktop).
  static const String defaultIp = '10.0.2.2';

  /// Construit l'URL HTTP de base pour une adresse IP donnée.
  static String baseUrl(String ip, [int port = defaultPort]) {
    final cleanIp = sanitizeIp(ip);
    return 'http://$cleanIp:$port';
  }

  /// Construit l'URL WebSocket pour une adresse IP donnée.
  static String wsUrl(String ip, [int port = defaultPort]) {
    final cleanIp = sanitizeIp(ip);
    return 'ws://$cleanIp:$port/ws';
  }

  /// Nettoie les entrées utilisateur pour extraire l'adresse IP pure.
  static String sanitizeIp(String input) {
    var sanitized = input.trim();
    if (sanitized.startsWith('http://')) {
      sanitized = sanitized.substring(7);
    } else if (sanitized.startsWith('https://')) {
      sanitized = sanitized.substring(8);
    } else if (sanitized.startsWith('ws://')) {
      sanitized = sanitized.substring(5);
    } else if (sanitized.startsWith('wss://')) {
      sanitized = sanitized.substring(6);
    }

    // Supprimer le port éventuel en fin d'adresse pour éviter http://ip:8000:8000
    if (sanitized.contains(':')) {
      sanitized = sanitized.split(':').first;
    }
    // Supprimer tout slash final
    if (sanitized.endsWith('/')) {
      sanitized = sanitized.substring(0, sanitized.length - 1);
    }

    return sanitized.isEmpty ? defaultIp : sanitized;
  }
}
