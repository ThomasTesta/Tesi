import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/api/api_client.dart';
import '../core/storage/session_store.dart';
import '../features/auth/data/auth_api.dart';
import '../features/auth/state/auth_controller.dart';
import '../features/sightings/data/sightings_api.dart';
import '../features/sightings/state/sightings_controller.dart';


class AppDI {
  static const baseUrl = 'https://isi-seawatch.csr.unibo.it/api';

  static List<SingleChildWidget> providers() {
    return [
      Provider<SessionStore>(create: (_) => SessionStore()),

      ProxyProvider<SessionStore, ApiClient>(
        update: (_, store, __) => ApiClient(baseUrl: baseUrl, sessionStore: store),
      ),

      ProxyProvider<ApiClient, AuthApi>(
        update: (_, client, __) => AuthApi(client),
      ),

      ChangeNotifierProxyProvider2<AuthApi, SessionStore, AuthController>(
        create: (_) => AuthController(
          api: AuthApi(ApiClient(baseUrl: baseUrl, sessionStore: SessionStore())),
          store: SessionStore(),
        ),
        update: (_, api, store, __) => AuthController(api: api, store: store),
      ),
      ProxyProvider<ApiClient, SightingsApi>(
  update: (_, client, __) => SightingsApi(client),
),

ChangeNotifierProxyProvider<SightingsApi, SightingsController>(
  create: (_) => SightingsController(api: SightingsApi(
    ApiClient(baseUrl: AppDI.baseUrl, sessionStore: SessionStore()),
  )),
  update: (_, api, prev) => prev ?? SightingsController(api: api),
),

    ];
  }
}
