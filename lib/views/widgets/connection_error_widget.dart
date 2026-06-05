import 'dart:io';
import 'package:flutter/material.dart';

class ConnectionErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const ConnectionErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // Verifica se o erro é de falta de internet para customizar a mensagem/ícone
    final isNoInternet = error is SocketException;

    return Center(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isNoInternet ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
            size: 64,
            color: Colors.orange.shade700,
          ),
          const SizedBox(height: 16),
          Text(
            isNoInternet ? 'Opa! Sem internet' : 'Algo deu errado',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString().replaceAll('Exception: ', ''),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar Novamente'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}