import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routes/app_router.dart';
import 'theme/inav_theme.dart';
import 'theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  final themeProvider = await ThemeProvider.load();
  runApp(INavApp(themeProvider: themeProvider));
}

class INavApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  const INavApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return ThemeProviderScope(
      notifier: themeProvider,
      child: AnimatedBuilder(
        animation: themeProvider,
        builder: (_, __) => MaterialApp.router(
          title: 'iNav Technologies',
          theme: buildINavTheme(),
          darkTheme: buildINavDarkTheme(),
          themeMode: themeProvider.mode,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
