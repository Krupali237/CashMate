
import 'package:app/import_export.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.teal,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black,
      ),
      iconTheme: IconThemeData(color: Colors.black),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(Colors.teal),
      trackColor: MaterialStateProperty.all(Colors.teal.shade100),
    ),
    iconTheme: IconThemeData(color: Colors.black),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF121212),
    primaryColor: Colors.teal,
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(Colors.teal),
      trackColor: MaterialStateProperty.all(Colors.teal.shade700),
    ),
    iconTheme: IconThemeData(color: Colors.white),
  );
}
