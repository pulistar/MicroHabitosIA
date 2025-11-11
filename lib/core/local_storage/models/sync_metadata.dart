import 'package:hive/hive.dart';

part 'sync_metadata.g.dart';

@HiveType(typeId: 2)
class SyncMetadata extends HiveObject {
  @HiveField(0)
  final String key;

  @HiveField(1)
  final DateTime lastSyncTime;

  @HiveField(2)
  final bool isOnline;

  @HiveField(3)
  final int pendingSyncCount;

  SyncMetadata({
    required this.key,
    required this.lastSyncTime,
    required this.isOnline,
    this.pendingSyncCount = 0,
  });
}
