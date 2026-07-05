import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_app/screens/home_page.dart';

// The main function is the starting point of all Flutter applications.
void main() {
  // runApp takes the given Widget and makes it the root of the widget tree.
  runApp(const MyApp());
}

// MyApp is the root widget of the application.
// It is a StatelessWidget because its core configuration doesn't change over time.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp provides the foundational structure for Material Design apps,
    // handling things like navigation, theming, and layout.
    return MaterialApp(
      title: 'Todo App', // The title used by the device's task switcher
      debugShowCheckedModeBanner: false, // Hides the "DEBUG" banner in the top right
      
      // ThemeData configures the overall visual theme of the app (colors, fonts, shapes).
      theme: ThemeData(
        // ColorScheme.fromSeed automatically generates a harmonious palette 
        // of colors based on a single "seed" color.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        
        // useMaterial3 opts into the latest Material Design 3 standards.
        useMaterial3: true,
        
        // We apply a custom font (Poppins) to the entire app's text theme.
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      
      // The home property specifies the first screen displayed when the app launches.
      home: const HomePage(),
    );
  }
}
