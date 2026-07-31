import 'dart:math' as math;

import 'package:astronomia/planetposition.dart';
import 'package:astronomia/solar.dart' as solar;

enum SajuSolarTerm {
  ipchun(315, 2, 4),
  gyeongchip(345, 3, 5),
  cheongmyeong(15, 4, 4),
  ipha(45, 5, 5),
  mangjong(75, 6, 5),
  soseo(105, 7, 7),
  ipchu(135, 8, 7),
  baengno(165, 9, 7),
  hanno(195, 10, 8),
  ipdong(225, 11, 7),
  daeseol(255, 12, 7),
  sohan(285, 1, 5);

  const SajuSolarTerm(
    this.targetLongitudeDegrees,
    this.approximateMonth,
    this.approximateDay,
  );

  final double targetLongitudeDegrees;
  final int approximateMonth;
  final int approximateDay;
}

abstract interface class SajuTimeScaleAdapter {
  String get version;
  double deltaTSeconds(double decimalYear);
}

/// Versioned Espenak/Meeus polynomial adapter for the qualified modern range.
final class NasaEspenakMeeusDeltaTAdapter implements SajuTimeScaleAdapter {
  const NasaEspenakMeeusDeltaTAdapter();

  @override
  String get version => 'nasa-espenak-meeus-delta-t-v1';

  @override
  double deltaTSeconds(double decimalYear) {
    if (decimalYear >= 1986 && decimalYear < 2005) {
      final t = decimalYear - 2000;
      return 63.86 +
          0.3345 * t -
          0.060374 * math.pow(t, 2) +
          0.0017275 * math.pow(t, 3) +
          0.000651814 * math.pow(t, 4) +
          0.00002373599 * math.pow(t, 5);
    }
    if (decimalYear >= 2005 && decimalYear <= 2050) {
      final t = decimalYear - 2000;
      return 62.92 + 0.32217 * t + 0.005589 * math.pow(t, 2);
    }
    if (decimalYear > 2050 && decimalYear < 2051) {
      final u = (decimalYear - 1820) / 100;
      return -20 + 32 * math.pow(u, 2) - 0.5628 * (2150 - decimalYear);
    }
    throw RangeError.value(
      decimalYear,
      'decimalYear',
      'Only civil years 1986 through 2050 are supported.',
    );
  }
}

final class RynSolarTermCalculator {
  RynSolarTermCalculator({required SajuTimeScaleAdapter timeScaleAdapter})
    : this._(timeScaleAdapter);

  RynSolarTermCalculator._(this._timeScaleAdapter)
    : _earth = Planet(planetEarth);

  factory RynSolarTermCalculator.production() => RynSolarTermCalculator(
    timeScaleAdapter: const NasaEspenakMeeusDeltaTAdapter(),
  );

  static const algorithmVersion = 'astronomia-vsop87b-apparent-root-v1';
  static const numericalConvergenceMicroseconds = 100;

  final SajuTimeScaleAdapter _timeScaleAdapter;
  final Planet _earth;

  String get timeScaleAdapterVersion => _timeScaleAdapter.version;

  DateTime utcInstant(int year, SajuSolarTerm term) {
    if (year < 1989 || year > 2050) {
      throw RangeError.range(year, 1989, 2050, 'year');
    }
    final guess = DateTime.utc(
      year,
      term.approximateMonth,
      term.approximateDay,
      12,
    );
    var low = _julianDay(guess.subtract(const Duration(days: 4)));
    var high = _julianDay(guess.add(const Duration(days: 4)));
    var lowValue = _longitudeDifference(low, year, term);
    var highValue = _longitudeDifference(high, year, term);
    if (lowValue >= 0 || highValue <= 0) {
      throw StateError(
        'Solar-term root is not bracketed for $year ${term.name}.',
      );
    }

    const targetWidthDays = numericalConvergenceMicroseconds / 86400000000;
    for (
      var iteration = 0;
      iteration < 80 && high - low > targetWidthDays;
      iteration++
    ) {
      final middle = (low + high) / 2;
      final value = _longitudeDifference(middle, year, term);
      if (value < 0) {
        low = middle;
        lowValue = value;
      } else {
        high = middle;
        highValue = value;
      }
    }
    assert(lowValue <= 0 && highValue >= 0);
    return _dateTimeFromJulianDay((low + high) / 2);
  }

  double _longitudeDifference(
    double utcJulianDay,
    int year,
    SajuSolarTerm term,
  ) {
    final decimalYear = year + (term.approximateMonth - 0.5) / 12;
    final jde =
        utcJulianDay +
        _timeScaleAdapter.deltaTSeconds(decimalYear) / Duration.secondsPerDay;
    final longitude = solar.apparentVSOP87(_earth, jde).lon;
    final target = term.targetLongitudeDegrees * math.pi / 180;
    return _normalizeSignedRadians(longitude - target);
  }

  double _normalizeSignedRadians(double value) {
    final twoPi = 2 * math.pi;
    var normalized = value % twoPi;
    if (normalized > math.pi) normalized -= twoPi;
    if (normalized < -math.pi) normalized += twoPi;
    return normalized;
  }

  double _julianDay(DateTime utc) =>
      2440587.5 +
      utc.toUtc().microsecondsSinceEpoch / Duration.microsecondsPerDay;

  DateTime _dateTimeFromJulianDay(double value) =>
      DateTime.fromMicrosecondsSinceEpoch(
        ((value - 2440587.5) * Duration.microsecondsPerDay).round(),
        isUtc: true,
      );
}
