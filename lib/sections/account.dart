import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/core/storage/app_storage.dart';
import 'package:Assidim/sections/account/account_header.dart';
import 'package:Assidim/sections/account/account_polizze.dart';
import 'package:Assidim/sections/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  // ─── Inizializzazione biometria e auto-login ────────────────────────────────

  Future<void> _init() async {
    final provider = context.read<AppProvider>();
    final storage = provider.storage;

    // Se non loggato tramite auto-login del Provider, mostra login
    if (!provider.isAuthenticated) return;

    final bioPerm = await storage.getBiometricsPermission();

    if (bioPerm == null) {
      // Prima volta: chiedi consenso biometria
      await _askBiometricsConsent(storage);
    } else if (bioPerm == true) {
      final bioUsed = await storage.hasBiometricsBeenUsed();
      if (!bioUsed) {
        // Ha dato consenso ma non ha ancora usato la biometria
        final success = await _authenticate();
        if (success) {
          await storage.setBiometricsUsed();
        } else {
          await provider.logout();
        }
      } else {
        // Già autenticato con biometria in precedenza: richiedi di nuovo
        final success = await _authenticate();
        if (!success) await provider.logout();
      }
    }
    // bioPerm == false → nessuna biometria, procedi normalmente
  }

  Future<bool> _authenticate() async {
    if (!await _localAuth.canCheckBiometrics) return false;
    if (!await _localAuth.isDeviceSupported()) return false;
    try {
      return await _localAuth.authenticate(
        localizedReason:
            'Accedi con i tuoi dati biometrici per semplificare il login.',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> _askBiometricsConsent(AppStorage storage) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => Theme(
        data: Theme.of(ctx).copyWith(dialogBackgroundColor: Colors.white),
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text('Autenticazione Biometrica'),
          content: const HtmlWidget(
            '<p style="text-align:center;">Vuoi consentire a questa app di '
            'autenticarti tramite <strong>impronta digitale</strong> o '
            '<strong>riconoscimento facciale</strong>?<br>I tuoi dati non '
            'verranno <strong>mai trasmessi</strong> fuori dal tuo dispositivo.</p>',
          ),
          actions: [
            ElevatedButton(
              style: constants.STILE_BOTTONE,
              onPressed: () async {
                await storage.setBiometricsPermission(true);
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                final ok = await _authenticate();
                if (ok) {
                  await storage.setBiometricsUsed();
                }
              },
              child: const Text('Sì, Acconsento'),
            ),
            ElevatedButton(
              style: constants.STILE_BOTTONE_ROSSO,
              onPressed: () async {
                await storage.setBiometricsPermission(false);
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
              },
              child: const Text('No, non mostrare più'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Image.asset('lib/assets/polizze_header.jpg', fit: BoxFit.fitWidth),
          ),
          FutureBuilder<void>(
            future: _initFuture,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(color: constants.COLORE_PRINCIPALE),
                  ),
                );
              }

              final user = provider.currentUser;
              if (user == null) {
                return const LoginForm();
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const AccountHeader(),
                    constants.SPACER,
                    const AccountPolizze(),
                    constants.SPACER,
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
