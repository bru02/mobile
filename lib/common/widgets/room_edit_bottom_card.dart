import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:filcnaplo/api/providers/rooms_provider.dart';
import 'package:filcnaplo/theme.dart';
import 'package:filcnaplo_kreta_api/models/lesson.dart';
import 'package:filcnaplo_mobile_ui/common/bottom_card.dart';
import 'package:filcnaplo_mobile_ui/pages/timetable/day_title.dart';
import 'room_edit_bottom_card.i18n.dart';

class RoomEditBottomCard extends StatefulWidget {
  const RoomEditBottomCard(this.lessons, {Key? key}) : super(key: key);

  final List<List<Lesson>> lessons;

  @override
  _RoomEditBottomCardState createState() => _RoomEditBottomCardState();
}

class _RoomEditBottomCardState extends State<RoomEditBottomCard>
    with SingleTickerProviderStateMixin {
  late RoomsProvider provider;
  late FocusNode focusNode;
  late TabController controller;
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = TabController(vsync: this, length: widget.lessons.length);
    controller.animation!.addListener(() {
      setState(() {});
    });
    focusNode = FocusNode();
    provider = Provider.of<RoomsProvider>(context, listen: false);
    next(diff: 0);
  }

  void next({int diff = 1}) {
    if (diff != 0)
      widget.lessons[controller.index]
          .forEach((l) => provider.overwriteRoom(textController.text, l));

    int target = controller.index + diff;

    if (target == -1 || target == controller.length) {
      return Navigator.pop(context);
    }
    setState(() {
      controller.animateTo(target);
    });

    String text =
        provider.getRoomForLesson(widget.lessons[controller.index][0]);
    textController.value = textController.value.copyWith(
      text: text,
      selection: TextSelection(baseOffset: 0, extentOffset: text.length),
      composing: TextRange.empty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color secondary = Theme.of(context).colorScheme.secondary;
    return BottomCard(
        child: Container(
            padding: const EdgeInsets.all(24.0),
            child: ClipRect(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    DayTitle(
                        controller: controller,
                        dayTitle: (i) =>
                            "${DateFormat('EEEE', I18n.of(context).locale.languageCode).format(widget.lessons[i][0].date)},",
                        fontSize: 28.0,
                        fontWeight: FontWeight.normal)
                  ]),
                  Row(children: [
                    DayTitle(
                        controller: controller,
                        dayTitle: (int i) {
                          List<Lesson> lessons = widget.lessons[i];
                          String lessonIndex =
                              lessons.map((l) => l.lessonIndex).join(' - ');
                          return "$lessonIndex. ${lessons[0].subject.name}";
                        })
                  ]),
                  Row(children: [
                    Expanded(
                        child: TextField(
                      onSubmitted: (String s) {
                        next();
                        focusNode.requestFocus();
                      },
                      controller: textController,
                      focusNode: focusNode,
                      autofocus: true,
                      cursorColor: secondary,
                      decoration: InputDecoration(
                        isDense: true,
                        helperText: "Classroom".i18n,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: secondary),
                        ),
                      ),
                    )),
                  ]),
                  RoomChipRow((room) {
                    textController.text = room;
                    next();
                  }),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    if (widget.lessons.length > 1)
                      IconButton(
                          icon: Icon(controller.index == 0
                              ? Icons.close
                              : Icons.arrow_back_rounded),
                          tooltip: controller.index == 0
                              ? 'Cancel'.i18n
                              : 'Back'.i18n,
                          onPressed: () {
                            next(diff: -1);
                          },
                          color: Colors.grey[500]),
                    if (widget.lessons.length > 1)
                      Expanded(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 6,
                              child: LinearProgressIndicator(
                                backgroundColor: secondary.withOpacity(.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    secondary.withOpacity(.8)),
                                value:
                                    ((controller.animation?.value ?? 0) + 1) /
                                        controller.length,
                              ),
                            )),
                      ),
                    IconButton(
                        icon: Icon(controller.index == controller.length - 1
                            ? Icons.check
                            : Icons.arrow_forward_rounded),
                        tooltip: controller.index == controller.length - 1
                            ? 'Done'.i18n
                            : 'Next'.i18n,
                        onPressed: () {
                          next();
                        },
                        color: Colors.grey[500])
                  ]),
                ],
              ),
            )));
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    textController.dispose();
    super.dispose();
  }
}

Future<void> showRoomEditBottomCard(
        {required BuildContext context,
        required List<List<Lesson>> lessons}) async =>
    await showModalBottomSheet(
        backgroundColor: Color(0),
        useRootNavigator: true,
        elevation: 0,
        context: context,
        isScrollControlled: true,
        builder: (context) => RoomEditBottomCard(lessons));

class RoomChipRow extends StatefulWidget {
  RoomChipRow(this.onTap, {Key? key}) : super(key: key);

  final Function(String)? onTap;

  @override
  _RoomChipRowState createState() => _RoomChipRowState();
}

class _RoomChipRowState extends State<RoomChipRow> {
  late RoomsProvider provider;
  late int initialLength;
  late List<String> prevRooms;
  late GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  void onProviderUpdate() {
    List<String> rooms = provider.rooms;
    rooms
        .where((r) => !prevRooms.contains(r))
        .map((r) => rooms.indexOf(r))
        .forEach((i) {
      listKey.currentState!.insertItem(i);
    });
    prevRooms
        .where((r) => !rooms.contains(r))
        .map((r) => prevRooms.indexOf(r))
        .forEach((i) {
      listKey.currentState!.removeItem(i, (ctx, anim) {
        return RoomChip(prevRooms[i], anim, null);
      });
    });
    prevRooms = rooms;
  }

  @override
  void initState() {
    super.initState();
    provider = Provider.of<RoomsProvider>(context, listen: false);
    provider.addListener(this.onProviderUpdate);
    prevRooms = provider.rooms;
    initialLength = prevRooms.length;
  }

  @override
  void dispose() {
    provider.removeListener(this.onProviderUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      if (provider.rooms.length > 0)
        SizedBox(
            width: MediaQuery.of(context).size.width - 72,
            height: 48.0,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.of(context).background,
                  ],
                  stops: const [0, 0.9, 1],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstOut,
              child: AnimatedList(
                key: listKey,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                initialItemCount: initialLength,
                itemBuilder: (ctx, i, anim) =>
                    (RoomChip(provider.rooms[i], anim, widget.onTap)),
              ),
            ))
    ]);
  }
}

class RoomChip extends StatelessWidget {
  RoomChip(this.room, this.anim, this.onTap);
  final String room;
  final Animation<double> anim;
  final Function(String)? onTap;
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(right: 3.0),
        child: SizeTransition(
            sizeFactor: anim,
            axis: Axis.horizontal,
            child: InputChip(
                label: Text(room),
                onPressed: onTap != null ? () => onTap!(room) : null,
                backgroundColor:
                    Theme.of(context).colorScheme.secondary.withOpacity(.1),
                labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary))));
  }
}
