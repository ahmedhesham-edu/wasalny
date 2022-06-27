import 'package:flutter/material.dart';

class BranDivider extends StatelessWidget {
  const BranDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1.0,
      color:Color(0xFFe2e2e2),
      thickness: 1.0,
    );
  }
}
