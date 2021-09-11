import 'dart:math';
import 'package:filcnaplo/api/providers/overrides_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:filcnaplo_kreta_api/models/lesson.dart';
import 'package:filcnaplo_kreta_api/providers/timetable_provider.dart';

class RoomOverridesHelper {
  late BuildContext _context;
  late OverridesProvider provider;

  RoomOverridesHelper(BuildContext context, {bool listen = true}) {
    _context = context;
    provider = Provider.of<OverridesProvider>(context, listen: listen);
  }

  Future<void> overrideRoom(String room, Lesson l) async {
    if (room == l.room) room = '';
    await provider.override(l, 'room', room, recurring: true);
  }

  List<String> get rooms {
    return provider.getRecurringOverridesOfKind('room')..sort();
  }

  String getRoomForLesson(Lesson l) {
    return provider.getOverrideOfKind(l, 'room') ?? l.room.replaceAll("_", " ");
  }

  bool hasOverride(Lesson l) {
    return provider.getOverrideOfKind(l, 'room') != null;
  }

  List<List<Lesson>> getEditableLessons() {
    List<Lesson> lessons = Provider.of<TimetableProvider>(_context, listen: false).lessons;

    Map<String, int> roomOccurances = Map();

    lessons.forEach((l) {
      if (!roomOccurances.containsKey(l.room)) {
        roomOccurances[l.room] = 1;
      } else {
        roomOccurances[l.room] = roomOccurances[l.room]! + 1;
      }
    });

    // If more than 5 unique rooms are present originally,
    // (need to test in the wild)
    // there is a good chance that
    // all the rooms are correct by default so no need to edit
    if (roomOccurances.keys.length > 5) return [];

    int highestOccurance = roomOccurances.values.length > 0 ? roomOccurances.values.reduce(min) : 0;

    List<List<Lesson>> ret = [];

    lessons
        .where((l) =>
            !hasOverride(l) &&
            // Sometimes a few classrooms are correct, we don't want to edit those
            roomOccurances[l.room] == highestOccurance &&
            l.subject.id != '')
        .forEach((l) {
      // Handle double lessons
      if (ret.isNotEmpty) {
        Lesson prev = ret.last.last;
        if (prev.subject == l.subject && _sameDate(prev.date, l.date) && int.tryParse(prev.lessonIndex)! + 1 == int.tryParse(l.lessonIndex))
          ret.last.add(l);
        else
          ret.add([l]);
      } else {
        ret.add([l]);
      }
    });

    return ret;
  }

  bool _sameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
