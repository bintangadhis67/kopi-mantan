import 'package:flutter_test/flutter_test.dart';
import 'package:kopi_mantan/theme.dart';

void main() {
  test('format rupiah', () {
    expect(rp(33000), 'Rp33.000');
    expect(rp(1250000), 'Rp1.250.000');
  });
}
