import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionUriRepository {
  static const String _connectionUriSPKey = "connection_uri";
  static const String _connectionUriEnvKey = "URI";

  late final String _defaultConnectionUri;

  final SharedPreferences preferences;

  ConnectionUriRepository({required this.preferences});

  String get currentUri {
    return preferences.getString(_connectionUriSPKey) ?? _defaultConnectionUri;
  }

  set currentUri(String uri) {
    preferences.setString(_connectionUriSPKey, uri);
  }

  Future<void> init() async {
    await dotenv.load(fileName: ".env");
    final defaultConnectionUri = dotenv.maybeGet(_connectionUriEnvKey);
    assert(
      defaultConnectionUri != null,
      "create a '.env' file in the 'client' folder "
      "with a web-socket URI as follows: "
      "URI='[here comes the uri]'",
    );
    _defaultConnectionUri = defaultConnectionUri!;
  }
}
