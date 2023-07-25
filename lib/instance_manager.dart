// Singleton class to store instance and configuration details.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_manager.dart';
import 'package:steel_crypt/steel_crypt.dart';

const String debugHostname = "geosirius.webxene.com";

class InstanceManager {
  static InstanceManager? _instance;
  factory InstanceManager() => _instance ??= new InstanceManager._singleton();
  InstanceManager._singleton();       // Empty singleton constructor

  String _instanceHost = "";          // Hostname of our API server.
  bool debugInstance = false;         // Override host for debugging server.
  final Map<String, dynamic> _instanceConfig = {};

  // Setup instance manager with configuration details. Called after instance
  // data is retrieved by login/username exchange or keypair checks.
  void setupInstance(String? instanceHostname, Map<String, dynamic>? instanceConfig) {
    if (debugInstance) {
      instanceHostname = debugHostname;
    }
    if (instanceHostname != null) {
      _instanceHost = instanceHostname;
    }
    if (instanceConfig != null) {
      if (instanceConfig.containsKey('instance')) {
        (instanceConfig['instance'] as Map<String, dynamic>).forEach((key, value) {
          _instanceConfig[key] = value;
        });
      }
    }
  }

  // Get API path as URI for a client connection, for example:
  // "user/1/login" => "https://subdomain.server.com/api/user/1/login"
  // Note that common headers for auth/accept must be used if this is for Laravel backend - use apiRequest() instead to make a full API call!
  Uri apiPath(String route, [Map<String, dynamic>? parameters, String method = 'GET', pathPrefix = 'api/' ]) {
    if (_instanceHost == "") {          // setupInstance MUST be called first!
      throw Exception("Instance manager has no host setup!");
    }
    final bool useUnsecure = _instanceConfig['DEBUG_HTTP'] ?? false;
    print((pathPrefix == 'api/' ? "API" : "Asset") + " Request [" + (useUnsecure ? 'HTTP' : 'HTTPS') + "] " + route);
    return Uri(
      scheme: useUnsecure ? 'http' : 'https',
      host: _instanceHost,
      path: pathPrefix + (route.substring(0, 1) == '/' ? route.substring(1) : route),
      queryParameters:  parameters,
    );
  }

  // Make an async API request to an endpoint along with any authorization required.
  // Returns an APIResponse containing the original HTTP request as well as JSON result.
  // Note: the parameters, if a list, must be a String subclass, i.e. List<int> will NOT work!
  // Note: this should _NOT_ be used to request an asset or remote JSON file, assetRequest() must be used instead!
  Future<APIResponse> apiRequest(String route, [Map<String, dynamic>? parameters, String method = 'GET']) {
    method = method.toUpperCase().trim();
    if (method != 'GET') {
      parameters ??= {};
      parameters.putIfAbsent('_method', () => method);        // Add laravel-specific _method handling for PUT/etc. to simulate HTTP forms.
    }
    final reqPath = InstanceManager().apiPath(route, parameters, method);
    final reqHeaders = {
      ...AuthManager().authTokenHeaders,
      'Accept': 'application/json'
    };
    final reqHttp = method == 'GET' ?
      http.get(reqPath, headers: reqHeaders) :
      http.post(reqPath, headers: reqHeaders, body: (parameters is String ? parameters : jsonEncode(parameters)));
    return reqHttp.then((response) => APIResponse(response));
  }

  // Make an async request for a static asset via our API, which may or may not require API login.
  // Returns a raw HTTP response, as this may not be JSON data.
  Future<http.Response> assetRequest(String assetRoute) {
    final assetPrefix = AuthManager().isTestUser ? 'storage/gamedata.test/' : 'storage/gamedata/';
    final reqPath = InstanceManager().apiPath(assetRoute, {}, 'GET', assetPrefix);
    final reqHeaders = {
      ...AuthManager().authTokenHeaders
    };
    final reqHttp = http.get(reqPath, headers: reqHeaders);
    return reqHttp;
  }

  // Decrypt any transparently-encrypted JSON asset files using our internal key. This will automatically detect
  // transparent encryption if it exists and process it, or if not encrypted simply return the original JSON.
  Future<String> decryptTransparentAsset(String jsonStr) {
    // These transparently encrypted files are formatted as '#TRANSPARENT<version number digit><encrypted gzipped base64>'.
    if (jsonStr.length <= 13 || !jsonStr.startsWith('#TRANSPARENT')) {
      return Future(() => jsonStr);
    }
    String jsonVersion = jsonStr.substring(12, 13);
    if (jsonVersion != '1') {
      throw const FormatException("Invalid or unhandled version tag in transparent encrypted asset file");
    }
    // Ciphertext, IV, etc. are all stored as JSON in the rest of the text.
    var cipherObj = jsonDecode(jsonStr.substring(13));
    if (cipherObj is! Map || !cipherObj.containsKey('iv') || !cipherObj.containsKey('value') || !cipherObj.containsKey('mac')) {
      throw const FormatException("Transparent encrypted asset file is invalid");
    }

    var aes = AesCrypt(key: 'n3/IxlLPUnbLvJnXpCUXi3WvTO6kK9za5DEDSKieJB0=', padding: PaddingAES.pkcs7);
    var plaintext = aes.cbc.decrypt(enc: cipherObj['value'], iv: cipherObj['iv']);
    // TODO: We don't check the MAC here yet... I think laravel uses HMAC SHA-256

    return Future(() => plaintext);
  }

  // API endpoint to make a report from the logged-in user (or guest).
  // Returns a future boolean of if this report was submitted successfully.
  // reportType must be a string recognized by the backend to categorize, but we do not restrict it currently (e.g. user_feedback)
  // TODO: List all types of report possible? Maybe use an enum?
  // Example usage: await InstanceManager().reportEndpoint("user_feedback", { "message": "Hello world", "page_involved": "Countries" });
  Future<bool> reportEndpoint(String reportType, Map<String, dynamic> reportData) {
    final reportJSON = const JsonEncoder().convert(reportData);
    final apiReportPromise = InstanceManager().apiRequest("report", {
      'type': reportType.toLowerCase().trim(),
      'data': reportJSON,
    }, 'POST');
    return apiReportPromise.then((apiReport) => apiReport.success(APIResponseJSON.map) ? true : false);
  }

  // API endpoint to save profile data from a logged-in user. Does not work with guests.
  // Returns a future boolean of if this profile was saved successfully.
  // Example usage: await InstanceManager().saveProfileData({ "score": 50, "lives": 100 });
  Future<bool> saveProfileData(Map<String, dynamic> newProfile) {
    if (AuthManager().state != AuthState.complete) {
      throw Exception("Tried to save profile data with an invalid AuthState!");
    }
    final profileJSON = const JsonEncoder().convert(newProfile);
    final apiSavePromise = InstanceManager().apiRequest("users/${AuthManager().loginUser['id']}/profile", {
      'data': profileJSON,
    }, 'POST');
    return apiSavePromise.then((apiSave) => apiSave.success(APIResponseJSON.map) ? true : false);
  }

}

enum APIResponseJSON {
  failed,         // Failed to decode the JSON result
  list,           // JSON returned a List<dynamic>
  map,            // JSON returned a Map<String, dynamic>
  unknown,        // JSON returned something else (raw variable?)
}

class APIResponse {
  late http.Response response;
  late dynamic result;        // JSON could be List<dynamic>, Map<String, dynamic>, etc.
  APIResponseJSON resultType = APIResponseJSON.failed;

  APIResponse(http.Response httpResponse) {
    response = httpResponse;
    try {
      result = jsonDecode(response.body);
      if (result is List) {
        resultType = APIResponseJSON.list;
      } else if (result is Map) {
        resultType = APIResponseJSON.map;
      } else {
        resultType = APIResponseJSON.unknown;
      }
    } catch (ex) {
      resultType = APIResponseJSON.failed;
    }
  }

  // Return if this is a success or not. If we require a specific type or JSON (list/map),
  // we can pass this in to check here as well.
  bool success([APIResponseJSON? requiredType]) {
    return response.statusCode == 200 && resultType != APIResponseJSON.failed &&
        (requiredType == null || requiredType == resultType);
  }
}