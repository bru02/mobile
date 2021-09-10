import 'package:filcnaplo/api/providers/rooms_provider.dart';
import 'package:filcnaplo/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    rooms.where((r) => !prevRooms.contains(r)).map((r) => rooms.indexOf(r)).forEach((i) {
      listKey.currentState!.insertItem(i);
    });
    int j = 0;
    prevRooms.where((r) => !rooms.contains(r)).map((r) => prevRooms.indexOf(r)).forEach((i) {
      print(++j);
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
      SizedBox(
          width: MediaQuery.of(context).size.width - 72,
          height: provider.rooms.length > 0 ? 48.0 : 0,
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
              itemBuilder: (ctx, i, anim) => (RoomChip(provider.rooms[i], anim, widget.onTap)),
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
                backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(.1),
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary))));
  }
}
