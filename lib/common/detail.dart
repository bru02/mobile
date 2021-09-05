import 'package:filcnaplo/theme.dart';
import 'package:flutter/material.dart';

class Detail extends StatelessWidget {
  Detail(
      {Key? key,
      required this.title,
      required this.description,
      this.maxLines = 3,
      this.descColor})
      : super(key: key);

  final String title;
  final String description;
  final int? maxLines;
  final Color? descColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 18.0),
      child: SelectableText.rich(
        TextSpan(
          text: "$title: ",
          style: TextStyle(
              fontWeight: FontWeight.w600, color: AppColors.of(context).text),
          children: [
            TextSpan(
              text: description,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: descColor ??
                      AppColors.of(context).text.withOpacity(0.85)),
            ),
          ],
        ),
        minLines: 1,
        maxLines: maxLines,
      ),
    );
  }
}
