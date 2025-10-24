import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:proyectos_cliente/pantallas/pantalla_dashboard.dart';
import 'package:proyectos_cliente/pantallas/pantalla_inicio_sesion.dart';
import 'package:proyectos_cliente/servicios/servicio_autenticacion.dart';
import 'package:proyectos_cliente/utilidades/estilos.dart';

import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Concurso de Proyectos EPIS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colores.primario,
        scaffoldBackgroundColor: Colores.fondo,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colores.primario,
          foregroundColor: Colores.blanco,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colores.primario,
            foregroundColor: Colores.blanco,
            shape: RoundedRectangleBorder(
              borderRadius: Estilos.bordeRedondeado,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: Estilos.bordeRedondeado,
          ),
          elevation: 2,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: Estilos.bordeRedondeado,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: Estilos.bordeRedondeado,
            borderSide: const BorderSide(color: Colores.primario),
          ),
        ),
      ),
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const PantallaSplash(); // Show splash screen while waiting
          }

          if (snapshot.hasError) {
            // Handle initialization error
            return Scaffold(
              body: Center(
                child: Text('Error initializing Firebase: ${snapshot.error}'),
              ),
            );
          }

          // Firebase is initialized, proceed to authentication check
          return const AuthWrapper();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const PantallaSplash(); // Or a loading indicator
        }
        if (snapshot.hasData) {
          return const PantallaDashboard();
        } else {
          return const PantallaInicioSesion();
        }
      },
    );
  }
}

class PantallaSplash extends StatelessWidget {
  const PantallaSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.primario,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colores.blanco,
                borderRadius: Estilos.bordeRedondeadoGrande,
              ),
              child: const Icon(
                Icons.school,
                size: 80,
                color: Colores.primario,
              ),
            ),
            const SizedBox(height: 32),
            
            const Text(
              'Concurso de Proyectos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colores.blanco,
              ),
            ),
            const Text(
              'EPIS',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colores.blanco,
              ),
            ),
            const SizedBox(height: 48),
            
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colores.blanco),
            ),
          ],
        ),
      ),
    );
  }
}
