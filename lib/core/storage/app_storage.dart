import 'dart:io';

import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Builds the app's [HydratedBloc] storage without letting a corrupted box
/// brick the app forever: one wipe-and-retry, then an in-memory fallback so
/// the app still boots (favourites just don't persist that session).
Future<Storage> buildHydratedStorage(String path) async {
  final HydratedStorageDirectory directory = HydratedStorageDirectory(path);
  try {
    return await HydratedStorage.build(storageDirectory: directory);
  } catch (_) {
    // A box killed mid-write fails every subsequent build, and the data in it
    // is already lost — deleting it is recovery, not data loss.
    _deleteHydratedBox(path);
    try {
      return await HydratedStorage.build(storageDirectory: directory);
    } catch (_) {
      return InMemoryStorage();
    }
  }
}

void _deleteHydratedBox(String path) {
  final Directory directory = Directory(path);
  if (!directory.existsSync()) {
    return;
  }
  for (final FileSystemEntity entity in directory.listSync()) {
    final String name = entity.path.split(Platform.pathSeparator).last;
    // HydratedStorage writes `hydrated_box.hive` plus its lock/compaction
    // siblings; all of them go together or the box will not reopen.
    if (name.startsWith('hydrated_box.')) {
      try {
        entity.deleteSync();
      } on FileSystemException {
        // Best effort; the in-memory fallback covers the rest.
      }
    }
  }
}

/// Last resort when the on-disk box cannot be (re)built.
class InMemoryStorage implements Storage {
  final Map<String, dynamic> _store = <String, dynamic>{};

  @override
  dynamic read(String key) => _store[key];

  @override
  Future<void> write(String key, dynamic value) async {
    _store[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }

  @override
  Future<void> close() async {}
}
