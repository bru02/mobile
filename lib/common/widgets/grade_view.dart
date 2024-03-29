import 'package:filcnaplo_kreta_api/models/grade.dart';
import 'package:filcnaplo_mobile_ui/common/bottom_card.dart';
import 'package:filcnaplo_mobile_ui/common/detail.dart';
import 'package:filcnaplo_mobile_ui/common/widgets/grade_tile.dart';
import 'package:filcnaplo/utils/format.dart';
import 'package:flutter/material.dart';
import 'grade_view.i18n.dart';

class GradeView extends StatelessWidget {
  const GradeView(this.grade, {Key? key}) : super(key: key);

  final Grade grade;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: GradeValueWidget(grade.value, fill: true),
            title: Text(
              grade.subject.name.capital(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              grade.teacher,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Text(
              grade.date.format(context),
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          // Grade Details
          Detail(
              title: "value".i18n,
              description: "${grade.value.valueName} " + percentText()),
          if (grade.description != "")
            Detail(title: "description".i18n, description: grade.description),
          if (grade.mode.description != "")
            Detail(title: "mode".i18n, description: grade.mode.description),
          if (grade.writeDate.year != 0)
            Detail(
                title: "date".i18n,
                description: grade.writeDate.format(context)),
        ],
      ),
    );
  }

  String percentText() => grade.value.weight != 100 && grade.value.weight > 0
      ? "${grade.value.weight}%"
      : "";

  static show(Grade grade, {required BuildContext context}) {
    showBottomCard(context: context, child: GradeView(grade));
  }
}
