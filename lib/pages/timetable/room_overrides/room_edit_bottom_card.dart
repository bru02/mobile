import 'package:filcnaplo_mobile_ui/pages/timetable/room_overrides/helper.dart';
import 'package:filcnaplo_mobile_ui/pages/timetable/room_overrides/room_chip_row.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:filcnaplo_kreta_api/models/lesson.dart';
import 'package:filcnaplo_mobile_ui/common/bottom_card.dart';
import 'package:filcnaplo_mobile_ui/pages/timetable/day_title.dart';
import './room_edit_bottom_card.i18n.dart';

class RoomEditBottomCard extends StatefulWidget {
  const RoomEditBottomCard(this.lessons, {Key? key}) : super(key: key);

  final List<List<Lesson>> lessons;

  @override
  _RoomEditBottomCardState createState() => _RoomEditBottomCardState();
}

class _RoomEditBottomCardState extends State<RoomEditBottomCard> with SingleTickerProviderStateMixin {
  late RoomOverridesHelper helper;
  late TabController controller;
  final FocusNode focusNode = FocusNode();
  final TextEditingController textController = TextEditingController();
  final GlobalKey<FormFieldState> globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = TabController(vsync: this, length: widget.lessons.length);
    controller.animation!.addListener(() {
      setState(() {});
    });
    helper = RoomOverridesHelper(context, listen: false);
    next(diff: 0);
  }

  void next({int diff = 1}) {
    if (diff > 0 && !globalKey.currentState!.validate()) return;

    if (diff != 0) widget.lessons[controller.index].forEach((l) => helper.overrideRoom(textController.text.trim(), l));

    int target = controller.index + diff;

    if (target == -1 || target == controller.length) {
      return Navigator.pop(context);
    }
    setState(() {
      controller.animateTo(target);
    });

    String text = helper.getRoomForLesson(widget.lessons[controller.index][0]);
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
                        dayTitle: (i) => "${DateFormat('EEEE', I18n.of(context).locale.languageCode).format(widget.lessons[i][0].date)},",
                        fontSize: 28.0,
                        fontWeight: FontWeight.normal)
                  ]),
                  Row(children: [
                    DayTitle(
                        controller: controller,
                        dayTitle: (int i) {
                          List<Lesson> lessons = widget.lessons[i];
                          String lessonIndex = lessons.map((l) => l.lessonIndex).join(' - ');
                          return "$lessonIndex. ${lessons[0].subject.name}";
                        })
                  ]),
                  Row(children: [
                    Expanded(
                        child: TextFormField(
                      onFieldSubmitted: (String s) {
                        next();
                        focusNode.requestFocus();
                      },
                      validator: (String? value) {
                        return (widget.lessons.length > 1 && value != null && value.trim().isEmpty)
                            ? 'Invalid room'.i18n
                            : null;
                      },
                      key: globalKey,
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
                          icon: Icon(controller.index == 0 ? Icons.close : Icons.arrow_back_rounded),
                          tooltip: controller.index == 0 ? 'Cancel'.i18n : 'Back'.i18n,
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
                                valueColor: AlwaysStoppedAnimation<Color>(secondary.withOpacity(.8)),
                                value: ((controller.animation?.value ?? 0) + 1) / controller.length,
                              ),
                            )),
                      ),
                    IconButton(
                        icon: Icon(controller.index == controller.length - 1 ? Icons.check : Icons.arrow_forward_rounded),
                        tooltip: controller.index == controller.length - 1 ? 'Done'.i18n : 'Next'.i18n,
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

Future<void> showRoomEditBottomCard({required BuildContext context, required List<List<Lesson>> lessons, bool showHelp = false}) async =>
    await showModalBottomSheet(
        backgroundColor: Color(0),
        useRootNavigator: true,
        elevation: 0,
        context: context,
        isScrollControlled: true,
        builder: (context) => showHelp ? RoomEditHelp(lessons) : RoomEditBottomCard(lessons));

class RoomEditHelp extends StatelessWidget {
  const RoomEditHelp(List<List<Lesson>> this.lessons, {Key? key}) : super(key: key);
  final List<List<Lesson>> lessons;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BottomCard(
          child: Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Mi ez?',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                        """Elég valószínű, hogy az óráid mellet szereplő terem szám nem tükrözi a valóságot, így elég nehéz kikeresni hol lesznek az óráid.

De itt a kedvenc e-napló alkalmazásod, hogy segítsen.

Ha rákattintasz a tovább gombra végig viszünk az eheti összes óradon, és megkérünk, hogy írd le, hogy melyik teremben lesznek ténylegesen. Ha ezt megcsináltad a helyes termet fogjuk megjeleníteni szép színesen.

Megjegyzés: Ha A & B heted van akkor mind két fajta hétnél megkell ezt majd csinálnod.""",
                        softWrap: true,
                      ))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          style: TextButton.styleFrom(
                            primary: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            showRoomEditBottomCard(lessons: lessons, context: context);
                          },
                          child: Row(
                            children: [Text('Tovább'), Icon(Icons.arrow_forward)],
                          ))
                    ],
                  )
                ],
              ))),
    );
  }
}
