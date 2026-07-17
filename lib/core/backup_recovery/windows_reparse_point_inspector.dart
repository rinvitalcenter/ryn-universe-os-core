import 'dart:ffi';
import 'dart:io';

const int _fileAttributeReparsePoint = 0x00000400;
const int _invalidFileAttributes = 0xffffffff;

/// Fail-closed Windows inspection for reparse points in existing path parts.
///
/// This inspector is read-only and does not establish permanent path safety.
/// A caller must invoke it during initial path validation, immediately before
/// partial-directory creation, immediately before final rename, after resolving
/// the final parent, and before candidate or package readback. A prior safe
/// result must never be cached as permanent proof because a path component can
/// change between validation and use.
///
/// Runtime callers must supply a path selected by their typed path contract;
/// this class does not accept or select runtime profiles itself.
final class WindowsReparsePointInspector {
  const WindowsReparsePointInspector();

  static final RegExp _invalidComponentCharacters = RegExp(
    r'[<>:"/\\|?*\x00-\x1F]',
  );
  static final RegExp _reservedDeviceName = RegExp(
    r'^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(?:\.|$)',
    caseSensitive: false,
  );

  /// Returns true only when every existing component is verified as a regular
  /// non-reparse filesystem entry. Unsupported platforms and inspection errors
  /// fail closed without including the supplied path in an error message.
  bool isSafe(String path) {
    if (!Platform.isWindows || path.isEmpty || path.contains('\u0000')) {
      return false;
    }

    try {
      final components = _absoluteComponents(path);
      if (components == null || components.isEmpty) {
        return false;
      }
      final kernel = _WindowsKernel32();
      for (var index = 0; index < components.length; index += 1) {
        final component = components[index];
        final type = FileSystemEntity.typeSync(component, followLinks: false);
        if (type == FileSystemEntityType.notFound) {
          return index > 0;
        }
        if (type == FileSystemEntityType.link) {
          return false;
        }
        final attributes = kernel.getFileAttributes(component);
        if (attributes == _invalidFileAttributes) {
          return false;
        }
        if ((attributes & _fileAttributeReparsePoint) != 0) {
          return false;
        }
      }
      return true;
    } on Object {
      return false;
    }
  }

  List<String>? _absoluteComponents(String input) {
    final raw = File(input).absolute.path.replaceAll('/', r'\');
    if (raw.startsWith(r'\\?\') || raw.startsWith(r'\\.\')) {
      return null;
    }

    late final String root;
    late final List<String> remainder;
    if (RegExp(r'^[A-Za-z]:\\').hasMatch(raw)) {
      root = '${raw[0].toUpperCase()}:\\';
      remainder = raw.substring(3).split(r'\');
    } else if (raw.startsWith(r'\\')) {
      final parts = raw.substring(2).split(r'\');
      if (parts.length < 2 || parts[0].isEmpty || parts[1].isEmpty) {
        return null;
      }
      root = '\\\\${parts[0]}\\${parts[1]}';
      remainder = parts.sublist(2);
    } else {
      return null;
    }

    final normalized = <String>[];
    for (final part in remainder) {
      if (part.isEmpty || part == '.') {
        continue;
      }
      if (part == '..') {
        if (normalized.isEmpty) {
          return null;
        }
        normalized.removeLast();
        continue;
      }
      if (_invalidComponentCharacters.hasMatch(part) ||
          part.endsWith('.') ||
          part.endsWith(' ') ||
          _reservedDeviceName.hasMatch(part)) {
        return null;
      }
      normalized.add(part);
    }

    final result = <String>[root];
    var current = root;
    for (final part in normalized) {
      current = current.endsWith(r'\') ? '$current$part' : '$current\\$part';
      result.add(current);
    }
    return result;
  }
}

typedef _GetFileAttributesWNative = Uint32 Function(Pointer<Uint16>);
typedef _GetFileAttributesWDart = int Function(Pointer<Uint16>);
typedef _GetProcessHeapNative = Pointer<Void> Function();
typedef _GetProcessHeapDart = Pointer<Void> Function();
typedef _HeapAllocNative =
    Pointer<Void> Function(Pointer<Void>, Uint32, UintPtr);
typedef _HeapAllocDart = Pointer<Void> Function(Pointer<Void>, int, int);
typedef _HeapFreeNative = Int32 Function(Pointer<Void>, Uint32, Pointer<Void>);
typedef _HeapFreeDart = int Function(Pointer<Void>, int, Pointer<Void>);

final class _WindowsKernel32 {
  _WindowsKernel32() {
    final kernel = DynamicLibrary.open('kernel32.dll');
    _getFileAttributes = kernel
        .lookupFunction<_GetFileAttributesWNative, _GetFileAttributesWDart>(
          'GetFileAttributesW',
        );
    _getProcessHeap = kernel
        .lookupFunction<_GetProcessHeapNative, _GetProcessHeapDart>(
          'GetProcessHeap',
        );
    _heapAlloc = kernel.lookupFunction<_HeapAllocNative, _HeapAllocDart>(
      'HeapAlloc',
    );
    _heapFree = kernel.lookupFunction<_HeapFreeNative, _HeapFreeDart>(
      'HeapFree',
    );
  }

  late final _GetFileAttributesWDart _getFileAttributes;
  late final _GetProcessHeapDart _getProcessHeap;
  late final _HeapAllocDart _heapAlloc;
  late final _HeapFreeDart _heapFree;

  int getFileAttributes(String path) {
    final heap = _getProcessHeap();
    if (heap.address == 0) {
      return _invalidFileAttributes;
    }
    final byteLength = (path.codeUnits.length + 1) * sizeOf<Uint16>();
    final allocation = _heapAlloc(heap, 0, byteLength);
    if (allocation.address == 0) {
      return _invalidFileAttributes;
    }

    try {
      final units = allocation.cast<Uint16>().asTypedList(
        path.codeUnits.length + 1,
      );
      units.setRange(0, path.codeUnits.length, path.codeUnits);
      units[path.codeUnits.length] = 0;
      return _getFileAttributes(allocation.cast<Uint16>());
    } finally {
      _heapFree(heap, 0, allocation);
    }
  }
}
