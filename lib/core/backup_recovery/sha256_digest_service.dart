import 'dart:io';
import 'dart:typed_data';

/// Streaming SHA-256 used only to detect accidental backup-artifact corruption.
///
/// This service does not provide encryption, authentication, signatures, or
/// password hashing. Callers hashing database payloads must use [digestFile]
/// rather than buffering the complete file in memory.
abstract interface class Sha256DigestService {
  Sha256Accumulator start();

  Future<String> digestFile(File file, {int chunkSize = 65536});
}

abstract interface class Sha256Accumulator {
  void add(List<int> bytes);

  String close();
}

final class DartSha256DigestService implements Sha256DigestService {
  const DartSha256DigestService();

  @override
  Sha256Accumulator start() => _DartSha256Accumulator();

  @override
  Future<String> digestFile(File file, {int chunkSize = 65536}) async {
    if (chunkSize <= 0) {
      throw ArgumentError.value(chunkSize, 'chunkSize', 'Must be positive.');
    }

    final accumulator = start();
    final input = await file.open();
    try {
      while (true) {
        final bytes = await input.read(chunkSize);
        if (bytes.isEmpty) {
          return accumulator.close();
        }
        accumulator.add(bytes);
      }
    } finally {
      await input.close();
    }
  }
}

final class _DartSha256Accumulator implements Sha256Accumulator {
  static const _mask32 = 0xffffffff;
  static const _initialState = <int>[
    0x6a09e667,
    0xbb67ae85,
    0x3c6ef372,
    0xa54ff53a,
    0x510e527f,
    0x9b05688c,
    0x1f83d9ab,
    0x5be0cd19,
  ];
  static const _roundConstants = <int>[
    0x428a2f98,
    0x71374491,
    0xb5c0fbcf,
    0xe9b5dba5,
    0x3956c25b,
    0x59f111f1,
    0x923f82a4,
    0xab1c5ed5,
    0xd807aa98,
    0x12835b01,
    0x243185be,
    0x550c7dc3,
    0x72be5d74,
    0x80deb1fe,
    0x9bdc06a7,
    0xc19bf174,
    0xe49b69c1,
    0xefbe4786,
    0x0fc19dc6,
    0x240ca1cc,
    0x2de92c6f,
    0x4a7484aa,
    0x5cb0a9dc,
    0x76f988da,
    0x983e5152,
    0xa831c66d,
    0xb00327c8,
    0xbf597fc7,
    0xc6e00bf3,
    0xd5a79147,
    0x06ca6351,
    0x14292967,
    0x27b70a85,
    0x2e1b2138,
    0x4d2c6dfc,
    0x53380d13,
    0x650a7354,
    0x766a0abb,
    0x81c2c92e,
    0x92722c85,
    0xa2bfe8a1,
    0xa81a664b,
    0xc24b8b70,
    0xc76c51a3,
    0xd192e819,
    0xd6990624,
    0xf40e3585,
    0x106aa070,
    0x19a4c116,
    0x1e376c08,
    0x2748774c,
    0x34b0bcb5,
    0x391c0cb3,
    0x4ed8aa4a,
    0x5b9cca4f,
    0x682e6ff3,
    0x748f82ee,
    0x78a5636f,
    0x84c87814,
    0x8cc70208,
    0x90befffa,
    0xa4506ceb,
    0xbef9a3f7,
    0xc67178f2,
  ];

  final List<int> _state = List<int>.of(_initialState);
  final Uint8List _tail = Uint8List(64);
  int _tailLength = 0;
  int _totalBytes = 0;
  bool _closed = false;

  @override
  void add(List<int> bytes) {
    if (_closed) {
      throw StateError('SHA-256 accumulator is already closed.');
    }
    for (final byte in bytes) {
      if (byte < 0 || byte > 0xff) {
        throw RangeError.range(byte, 0, 0xff, 'byte');
      }
      _tail[_tailLength++] = byte;
      _totalBytes += 1;
      if (_tailLength == 64) {
        _compress(_tail);
        _tailLength = 0;
      }
    }
  }

  @override
  String close() {
    if (_closed) {
      throw StateError('SHA-256 accumulator is already closed.');
    }
    _closed = true;

    final bitLength = _totalBytes * 8;
    _tail[_tailLength++] = 0x80;
    if (_tailLength > 56) {
      while (_tailLength < 64) {
        _tail[_tailLength++] = 0;
      }
      _compress(_tail);
      _tailLength = 0;
    }
    while (_tailLength < 56) {
      _tail[_tailLength++] = 0;
    }
    for (var index = 7; index >= 0; index -= 1) {
      _tail[_tailLength++] = (bitLength >> (index * 8)) & 0xff;
    }
    _compress(_tail);
    _tailLength = 0;

    return _state.map((word) => word.toRadixString(16).padLeft(8, '0')).join();
  }

  void _compress(Uint8List block) {
    final schedule = Uint32List(64);
    for (var index = 0; index < 16; index += 1) {
      final offset = index * 4;
      schedule[index] =
          (block[offset] << 24) |
          (block[offset + 1] << 16) |
          (block[offset + 2] << 8) |
          block[offset + 3];
    }
    for (var index = 16; index < 64; index += 1) {
      schedule[index] =
          (_smallSigma1(schedule[index - 2]) +
              schedule[index - 7] +
              _smallSigma0(schedule[index - 15]) +
              schedule[index - 16]) &
          _mask32;
    }

    var a = _state[0];
    var b = _state[1];
    var c = _state[2];
    var d = _state[3];
    var e = _state[4];
    var f = _state[5];
    var g = _state[6];
    var h = _state[7];

    for (var index = 0; index < 64; index += 1) {
      final choice = (e & f) ^ ((~e) & g);
      final majority = (a & b) ^ (a & c) ^ (b & c);
      final first =
          (h +
              _bigSigma1(e) +
              choice +
              _roundConstants[index] +
              schedule[index]) &
          _mask32;
      final second = (_bigSigma0(a) + majority) & _mask32;
      h = g;
      g = f;
      f = e;
      e = (d + first) & _mask32;
      d = c;
      c = b;
      b = a;
      a = (first + second) & _mask32;
    }

    _state[0] = (_state[0] + a) & _mask32;
    _state[1] = (_state[1] + b) & _mask32;
    _state[2] = (_state[2] + c) & _mask32;
    _state[3] = (_state[3] + d) & _mask32;
    _state[4] = (_state[4] + e) & _mask32;
    _state[5] = (_state[5] + f) & _mask32;
    _state[6] = (_state[6] + g) & _mask32;
    _state[7] = (_state[7] + h) & _mask32;
  }

  static int _rotateRight(int value, int count) =>
      ((value >>> count) | (value << (32 - count))) & _mask32;

  static int _bigSigma0(int value) =>
      _rotateRight(value, 2) ^
      _rotateRight(value, 13) ^
      _rotateRight(value, 22);

  static int _bigSigma1(int value) =>
      _rotateRight(value, 6) ^
      _rotateRight(value, 11) ^
      _rotateRight(value, 25);

  static int _smallSigma0(int value) =>
      _rotateRight(value, 7) ^ _rotateRight(value, 18) ^ (value >>> 3);

  static int _smallSigma1(int value) =>
      _rotateRight(value, 17) ^ _rotateRight(value, 19) ^ (value >>> 10);
}
