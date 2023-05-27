import 'web_constant_api.dart'
if (dart.library.html) 'web_constant_web.dart' as web_constant_api;

const isWeb = web_constant_api.isWeb;