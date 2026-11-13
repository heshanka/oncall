import 'package:flutter_test/flutter_test.dart';
import 'package:oncall/main.dart';

void main() {
  test('rotation matches given schedule', () {
    expect(personFor(DateTime(2026, 11, 10)), 'Heshanka');
    expect(personFor(DateTime(2026, 11, 11)), 'Mahdi');
    expect(personFor(DateTime(2026, 11, 12)), 'Saleh');
    expect(personFor(DateTime(2026, 11, 13)), 'Kevser');
    expect(personFor(DateTime(2026, 11, 14)), 'Heshanka');
    expect(personFor(DateTime(2026, 11, 9)), 'Kevser');
    expect(personFor(DateTime(2027, 3, 30)), personFor(DateTime(2027, 3, 26)));
  });

  test('upcomingFor lists a person\'s next dates', () {
    final days = upcomingFor('Mahdi', DateTime(2026, 11, 14), count: 3);
    expect(days, [
      DateTime(2026, 11, 15),
      DateTime(2026, 11, 19),
      DateTime(2026, 11, 23),
    ]);
    expect(upcomingFor('Heshanka', DateTime(2026, 11, 14), count: 1), [
      DateTime(2026, 11, 14),
    ]);
  });
}
