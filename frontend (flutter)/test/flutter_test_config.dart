import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Configuration globale pour éviter les erreurs de plugins dans les tests
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Désactiver les plugins qui ne sont pas disponibles dans l'environnement de test
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('plugins.flutter.io/path_provider', (message) async {
    return null; // Retourne null pour éviter l'exception
  });
  
  return testMain();
}