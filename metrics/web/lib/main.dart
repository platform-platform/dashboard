import 'package:flutter/material.dart';
import 'package:metrics/features/auth/presentation/state/user_metrics_store.dart';
import 'package:metrics/features/common/presentation/injector/widget/injection_container.dart';
import 'package:metrics/features/common/presentation/metrics_theme/widgets/metrics_theme_builder.dart';
import 'package:metrics/features/common/presentation/routes/route_generator.dart';
import 'package:metrics/features/common/presentation/strings/common_strings.dart';
import 'package:metrics/features/common/presentation/widgets/loading_placeholder.dart';
import 'package:metrics/features/common/presentation/widgets/page_placeholder.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return InjectionContainer(
      child: MetricsThemeBuilder(
        builder: (context, store) {
          final isDark = store?.isDark ?? true;

          return WhenRebuilder<UserMetricsStore>(
            models: [Injector.getAsReactive<UserMetricsStore>()],
            onWaiting: () => const LoadingPlaceholder(),
            onIdle: () => const LoadingPlaceholder(),
            onError: (error) => PagePlaceholder(
                text: CommonStrings.getLoadingErrorMessage('$error')),
            onData: (UserMetricsStore userMetricsStore) {
              return MaterialApp(
                title: CommonStrings.projectName,
                initialRoute: '/',
                onGenerateRoute: (settings) => RouteGenerator.generateRoute(
                  settings: settings,
                  isLoggedIn: userMetricsStore.isLoggedIn,
                ),
                theme: ThemeData(
                  brightness: isDark ? Brightness.dark : Brightness.light,
                  primarySwatch: Colors.teal,
                  fontFamily: 'Bebas Neue',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
