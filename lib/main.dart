import 'package:flutter/material.dart';
import 'models/app_models.dart';
import 'screens/adhkar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/more_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/tasbih_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialSettings = await StorageService.instance.loadSettings();
  runApp(AthanProApp(initialSettings: initialSettings));
}

class AthanProApp extends StatefulWidget {
  final PrayerSettings initialSettings;
  const AthanProApp({super.key, required this.initialSettings});

  @override
  State<AthanProApp> createState() => _AthanProAppState();
}

class _AthanProAppState extends State<AthanProApp> {
  late PrayerSettings _settings;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  void _updateSettings(PrayerSettings updated) {
    setState(() => _settings = updated);
    StorageService.instance.saveSettings(updated);
  }

  @override
  Widget build(BuildContext context) {
    const emerald = Color(0xFF0D9488);

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: emerald,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0B1416),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0B1416),
        centerTitle: true,
        elevation: 0,
      ),
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: emerald,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF6F5F0),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF6F5F0),
        centerTitle: true,
        elevation: 0,
      ),
    );

    final pages = [
      HomeScreen(settings: _settings, onUpdateSettings: _updateSettings),
      AdhkarScreen(vibrateEnabled: _settings.vibrateEnabled),
      QiblaScreen(settings: _settings),
      TasbihScreen(vibrateEnabled: _settings.vibrateEnabled),
      MoreScreen(settings: _settings, onUpdateSettings: _updateSettings),
    ];

    return MaterialApp(
      title: 'آذان برو',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: Scaffold(
        body: IndexedStack(index: _navIndex, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _navIndex,
          onDestinationSelected: (i) => setState(() => _navIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.access_time_outlined),
              selectedIcon: Icon(Icons.access_time_filled),
              label: 'المواقيت',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'الأذكار',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'القبلة',
            ),
            NavigationDestination(
              icon: Icon(Icons.touch_app_outlined),
              selectedIcon: Icon(Icons.touch_app),
              label: 'السبحة',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'المزيد',
            ),
          ],
        ),
      ),
    );
  }
}
