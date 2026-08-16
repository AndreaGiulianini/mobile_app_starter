import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Fails CI when someone adds a key to one ARB and forgets the other —
/// gen-l10n only warns, and warnings scroll by.
void main() {
  Set<String> keysOf(String path) {
    final Map<String, dynamic> arb =
        json.decode(File(path).readAsStringSync()) as Map<String, dynamic>;
    return arb.keys.where((String key) => !key.startsWith('@')).toSet();
  }

  test('app_it.arb carries exactly the keys of the app_en.arb template', () {
    final Set<String> en = keysOf('lib/l10n/app_en.arb');
    final Set<String> it = keysOf('lib/l10n/app_it.arb');

    expect(
      it.difference(en),
      isEmpty,
      reason: 'keys present in Italian but missing from the English template',
    );
    expect(
      en.difference(it),
      isEmpty,
      reason: 'keys missing an Italian translation',
    );
  });
}
