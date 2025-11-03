// lib/main.dart
// Kezdetleges Flutter alkalmazás: jelszavak listázása, alapból elrejtve.
// Kattintásra megjelenik az adott jelszó (egyszerű demo, nem production-ready).
// Teendők:
// - Lokális jelszó titkosítás és tárolás
// - E2E titkosítás
// - extension bővítmény a böngésző felől:
//   - felismerés, ajánlás domain és email alapján

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passwordmanager/Models/account.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Password List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PasswordListPage(),
    );
  }
}

class PasswordListPage extends StatefulWidget {
  const PasswordListPage({super.key});

  @override
  State<PasswordListPage> createState() => _PasswordListPageState();
}

class _PasswordListPageState extends State<PasswordListPage> {
  final List<Account> _accounts = [
    Account(
      domain: 'example.com',
      login: 'user@example.com',
      password: 's3cr3tP@ss',
    ),
    Account(domain: 'github.com', login: 'dev', password: 'ghp_ABC123xyz'),
    Account(domain: 'mail.hu', login: 'nev@mail.hu', password: 'titkos123'),
    Account(domain: 'bank.hu', login: 'customer', password: 'B4nkP@ss!'),
  ];

  String _query = '';
  final Map<int, Timer> _autoHideTimers = {};

  @override
  void dispose() {
    for (final t in _autoHideTimers.values) {
      t.cancel();
    }
    super.dispose();
  }

  void _toggleReveal(int index) {
    setState(() {
      _accounts[index].revealed = !_accounts[index].revealed;
    });

    // Ha megjelenítjük, 5 másodperc múlva automatikusan el is rejtjük (demo-szerű viselkedés)
    _autoHideTimers[index]?.cancel();
    if (_accounts[index].revealed) {
      _autoHideTimers[index] = Timer(const Duration(seconds: 5), () {
        setState(() {
          _accounts[index].revealed = false;
        });
      });
    }
  }

  void _copyPassword(int index) async {
    await Clipboard.setData(ClipboardData(text: _accounts[index].password));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Jelszó a vágólapra másolva')));
  }

  List<Account> get _filteredAccounts {
    if (_query.isEmpty) return _accounts;
    final q = _query.toLowerCase();
    return _accounts
        .where(
          (a) =>
              a.domain.toLowerCase().contains(q) ||
              a.login.toLowerCase().contains(q),
        )
        .toList();
  }

  String _obscure(String s) {
    // Visszaad annyi '•' karaktert, ahány a jelszó hossza, hogy hasonlítson az authentikátor-appokra
    return '•' * s.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jelszavak'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addDemoAccount,
            tooltip: 'Új demo fiók hozzáadása',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Keresés domain vagy login szerint...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredAccounts.length,
        itemBuilder: (context, idx) {
          final account = _filteredAccounts[idx];
          final realIndex = _accounts.indexOf(account);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _toggleReveal(realIndex),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        child: Text(
                          account.domain.isNotEmpty
                              ? account.domain[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.domain,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: Text(
                                      account.revealed
                                          ? account.password
                                          : _obscure(account.password),
                                      key: ValueKey(account.revealed),
                                      style: TextStyle(
                                        letterSpacing: 2.0,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () => _copyPassword(realIndex),
                                  tooltip: 'Másolás',
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              account.login,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        account.revealed
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _addDemoAccount() {
    setState(() {
      _accounts.insert(
        0,
        Account(
          domain: 'new.example',
          login: 'newuser',
          password: 'NewPass${DateTime.now().millisecondsSinceEpoch % 10000}',
        ),
      );
    });
  }
}
