import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/events_provider.dart';
import 'providers/places_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/home/home_screen.dart';

class LittleAtlasApp extends StatelessWidget {
  const LittleAtlasApp({super.key});

  static const Color atlasGreen = Color(0xFF2E7D5F);

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
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: atlasGreen),
              textTheme: GoogleFonts.nunitoTextTheme(),
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                backgroundColor: atlasGreen,
                foregroundColor: Colors.white,
                titleTextStyle: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
