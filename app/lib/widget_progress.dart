/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the progress widget.

import 'package:flutter/material.dart';
import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/mbcl/src/course.dart';

class ProgressWidget extends StatefulWidget {
  final MbclCourse course;

  const ProgressWidget(this.course, {Key? key}) : super(key: key);

  @override
  State<ProgressWidget> createState() {
    return ProgressState();
  }
}

class ProgressState extends State<ProgressWidget> {
  @override
  void initState() {
    super.initState();
    widget.course.loadUserData(); // TODO: no async OK???
  }

  @override
  Widget build(BuildContext context) {
    var body = Text('TODO: progress widget');

    return Scaffold(
        appBar: buildAppBar(true, this, null),
        body: body,
        backgroundColor: Colors.white);
  }
}
