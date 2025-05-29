import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

final uniqueIdProvider = Provider<UniqueIdGenerator>((ref) {
  return UniqueIdGenerator();
});

class UniqueIdGenerator {
  String generateId() {
    final random = Random();
    final number = random.nextInt(90000) + 10000; 
    return 'DL$number';
  }
}