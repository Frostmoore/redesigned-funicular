import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/app_config.dart';
import 'package:Assidim/core/services/api_service.dart';

/// Recupera e deserializza la configurazione dell'app dall'API principale.
class ConfigService {
  final ApiService _api;

  const ConfigService(this._api);

  Future<AppConfig> fetchConfig() async {
    final url = Uri.https(
      constants.PATH,
      constants.ENDPOINT,
      {'id': constants.ID, 'token': constants.TOKEN},
    );
    final data = await _api.get(url);
    return AppConfig.fromJson(data);
  }
}
