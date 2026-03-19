import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/events_provider.dart';
import 'providers/places_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';

class LittleAtlasApp extends StatelessWidget {
  const LittleAtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => PlacesProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Little Atlas',
            debugShowCheckedModeBanner: false,
            locale: settings.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('el'),
              Locale('ru'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
