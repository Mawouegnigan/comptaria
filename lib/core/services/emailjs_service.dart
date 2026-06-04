import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailJSService {
  // ── Clés EmailJS ───────────────────────────────────
  static const String _serviceId  = 'service_sh1odsb';
  static const String _templateId = 'template_ux4g40x';
  static const String _publicKey  = '2ky-NvPQT1Zh8vUJH';

  // ── Envoyer un avis ────────────────────────────────
  static Future<bool> envoyerAvis({
    required String nom,
    required int note,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id':  _serviceId,
          'template_id': _templateId,
          'user_id':     _publicKey,
          'template_params': {
            'nom':     nom.isEmpty ? 'Anonyme' : nom,
            'note':    '$note',
            'message': message,
          },
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}