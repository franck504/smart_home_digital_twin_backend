/// Représentation complète de l'état du jumeau numérique dans l'application mobile.
class HouseState {
  final Map<String, RoomState> rooms;
  final Configuration config;
  final Energy energy;
  final Weather weather;

  HouseState({
    required this.rooms,
    required this.config,
    required this.energy,
    required this.weather,
  });

  factory HouseState.fromJson(Map<String, dynamic> json) {
    final rawRooms = json['rooms'] as Map<String, dynamic>? ?? {};
    final roomsMap = rawRooms.map((key, value) {
      final roomJson = Map<String, dynamic>.from(value as Map);
      // Garantit que le nom lisible est toujours renseigné
      roomJson['id'] = key;
      return MapEntry(key, RoomState.fromJson(roomJson));
    });

    return HouseState(
      rooms: roomsMap,
      config: Configuration.fromJson(
        Map<String, dynamic>.from(json['config'] as Map? ?? {}),
      ),
      energy: Energy.fromJson(
        Map<String, dynamic>.from(json['energy'] as Map? ?? {}),
      ),
      weather: Weather.fromJson(
        Map<String, dynamic>.from(json['weather'] as Map? ?? {}),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'rooms': rooms.map((key, value) => MapEntry(key, value.toJson())),
        'config': config.toJson(),
        'energy': energy.toJson(),
        'weather': weather.toJson(),
      };
}

/// État physique et régulation d'une pièce spécifique.
class RoomState {
  final String id;
  final String name;
  final double temperature;
  final double humidity;
  final bool presence;
  final double luminosity;
  final bool lights;
  final String climatisation; // "OFF", "HEAT", "COOL"
  final String climatisationMode; // "AUTO", "MANUAL"
  final double temperatureDeRegulation;

  RoomState({
    required this.id,
    required this.name,
    required this.temperature,
    required this.humidity,
    required this.presence,
    required this.luminosity,
    required this.lights,
    required this.climatisation,
    required this.climatisationMode,
    required this.temperatureDeRegulation,
  });

  static String _formatDefaultRoomName(String id) {
    switch (id.toLowerCase()) {
      case 'salon':
        return 'Salon';
      case 'cuisine':
        return 'Cuisine';
      case 'chambre':
        return 'Chambre';
      case 'douche':
        return 'Salle d\'eau';
      default:
        if (id.isEmpty) return 'Pièce';
        return id[0].toUpperCase() + id.substring(1);
    }
  }

  factory RoomState.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final rawName = json['name'] as String?;
    final name = (rawName != null && rawName.isNotEmpty)
        ? rawName
        : _formatDefaultRoomName(id);

    return RoomState(
      id: id,
      name: name,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 20.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 50.0,
      presence: json['presence'] as bool? ?? false,
      luminosity: (json['luminosity'] as num?)?.toDouble() ?? 0.0,
      lights: json['lights'] as bool? ?? false,
      climatisation: json['climatisation'] as String? ?? 'OFF',
      climatisationMode: json['climatisation_mode'] as String? ?? 'AUTO',
      temperatureDeRegulation:
          (json['temperature_de_regulation'] as num?)?.toDouble() ?? 22.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'temperature': temperature,
        'humidity': humidity,
        'presence': presence,
        'luminosity': luminosity,
        'lights': lights,
        'climatisation': climatisation,
        'climatisation_mode': climatisationMode,
        'temperature_de_regulation': temperatureDeRegulation,
      };
}

/// Paramètres de consigne globaux.
class Configuration {
  final double tempThresholdHigh;
  final double tempThresholdLow;
  final double batteryCriticalThreshold;
  final bool autoLightOff;
  final bool autoClimOff;
  final double luxThreshold;

  Configuration({
    required this.tempThresholdHigh,
    required this.tempThresholdLow,
    required this.batteryCriticalThreshold,
    required this.autoLightOff,
    required this.autoClimOff,
    required this.luxThreshold,
  });

  factory Configuration.fromJson(Map<String, dynamic> json) {
    return Configuration(
      tempThresholdHigh:
          (json['temp_threshold_high'] as num?)?.toDouble() ?? 26.0,
      tempThresholdLow:
          (json['temp_threshold_low'] as num?)?.toDouble() ?? 18.0,
      batteryCriticalThreshold:
          (json['battery_critical_threshold'] as num?)?.toDouble() ?? 20.0,
      autoLightOff: json['auto_light_off'] as bool? ?? true,
      autoClimOff: json['auto_clim_off'] as bool? ?? true,
      luxThreshold: (json['lux_threshold'] as num?)?.toDouble() ?? 200.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'temp_threshold_high': tempThresholdHigh,
        'temp_threshold_low': tempThresholdLow,
        'battery_critical_threshold': batteryCriticalThreshold,
        'auto_light_off': autoLightOff,
        'auto_clim_off': autoClimOff,
        'lux_threshold': luxThreshold,
      };
}

/// État de l'alimentation électrique et niveau batterie.
class Energy {
  final String source; // "solar" ou "grid"
  final double batteryLevel;
  final double consumption;

  Energy({
    required this.source,
    required this.batteryLevel,
    required this.consumption,
  });

  factory Energy.fromJson(Map<String, dynamic> json) {
    return Energy(
      source: json['source'] as String? ?? 'grid',
      batteryLevel: (json['battery_level'] as num?)?.toDouble() ?? 100.0,
      consumption: (json['consumption'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'source': source,
        'battery_level': batteryLevel,
        'consumption': consumption,
      };
}

/// Conditions météorologiques extérieures.
class Weather {
  final double outsideTemp;
  final String description;
  final String icon;
  final double solarPrediction;
  final String location;
  final String lastUpdated;

  Weather({
    required this.outsideTemp,
    required this.description,
    required this.icon,
    required this.solarPrediction,
    required this.location,
    required this.lastUpdated,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      outsideTemp: (json['outside_temp'] as num?)?.toDouble() ?? 20.0,
      description: json['description'] as String? ?? 'Ensoleillé',
      icon: json['icon'] as String? ?? '01d',
      solarPrediction: (json['solar_prediction'] as num?)?.toDouble() ?? 0.5,
      location: json['location'] as String? ?? 'Fianarantsoa',
      lastUpdated: json['last_updated'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'outside_temp': outsideTemp,
        'description': description,
        'icon': icon,
        'solar_prediction': solarPrediction,
        'location': location,
        'last_updated': lastUpdated,
      };
}

