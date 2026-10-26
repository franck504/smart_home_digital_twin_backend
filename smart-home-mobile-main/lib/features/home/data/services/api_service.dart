import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/house_state_model.dart';

/// Client HTTP pour interagir avec les endpoints REST du Jumeau Numérique.
class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Uri _uri(String path, [Map<String, String>? queryParams]) {
    final sanitizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final urlString = '$sanitizedBase$path';
    final parsed = Uri.parse(urlString);
    if (queryParams != null && queryParams.isNotEmpty) {
      return parsed.replace(queryParameters: queryParams);
    }
    return parsed;
  }

  /// Récupère l'état global du jumeau numérique.
  Future<HouseState> getState() async {
    final response = await _client
        .get(_uri('/state'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      return HouseState.fromJson(Map<String, dynamic>.from(decoded as Map));
    } else {
      throw Exception('Erreur serveur lors de la récupération de l\'état: ${response.statusCode}');
    }
  }

  /// Allume ou éteint la lumière d'une pièce.
  Future<void> toggleLight(String room, bool state) async {
    final url = _uri('/control/$room/light', {'state': state.toString()});
    final response = await _client.post(url).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Échec de la commande lumière ($room): ${response.statusCode}');
    }
  }

  /// Bascule le mode de climatisation ("AUTO" ou "MANUAL").
  Future<void> setClimatisationMode(String room, String mode) async {
    final url = _uri('/control/$room/climatisation/mode', {'mode': mode});
    final response = await _client.post(url).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Échec du changement de mode clim ($room): ${response.statusCode}');
    }
  }

  /// Force manuellement l'état de la climatisation ("OFF", "HEAT", "COOL").
  Future<void> setClimatisation(String room, String value) async {
    final url = _uri('/control/$room/climatisation/set', {'value': value});
    final response = await _client.post(url).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Échec du forçage de la clim ($room): ${response.statusCode}');
    }
  }

  /// Définit la consigne de température de régulation (automatiquement mode AUTO).
  Future<void> setTargetTemp(String room, double temp) async {
    final url = _uri('/control/$room/climatisation/target_temp', {'temp': temp.toString()});
    final response = await _client.post(url).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Échec du réglage de la consigne ($room): ${response.statusCode}');
    }
  }

  /// Met à jour la ville pour les prévisions météo.
  Future<void> setWeatherLocation(String city) async {
    final url = _uri('/config/weather/location', {'city': city});
    final response = await _client.post(url).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Échec du changement de ville: ${response.statusCode}');
    }
  }

  /// Simule une présence humaine dans une pièce (endpoint de simulation).
  Future<void> setPresence(String room, bool state) async {
    final url = _uri('/control/$room/presence', {'state': state.toString()});
    final response = await _client.post(url).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Échec de la simulation de présence ($room): ${response.statusCode}');
    }
  }

  /// Simule un niveau de batterie (endpoint de simulation).
  Future<void> setBatteryLevel(double level) async {
    final url = _uri('/control/energy/battery', {'level': level.toString()});
    final response = await _client.post(url).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Échec de la simulation batterie: ${response.statusCode}');
    }
  }
}

