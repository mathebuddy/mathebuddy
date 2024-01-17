/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

/// This file implements the help widget.

import 'package:flutter/material.dart';
import 'package:mathebuddy/appbar.dart';
import 'package:mathebuddy/mbcl/src/course.dart';

class HelpWidget extends StatefulWidget {
  final MbclCourse course;

  const HelpWidget(this.course, {Key? key}) : super(key: key);

  @override
  State<HelpWidget> createState() {
    return HelpState();
  }
}

class HelpState extends State<HelpWidget> {
  @override
  void initState() {
    super.initState();
    widget.course.loadUserData(); // TODO: no async OK???
  }

  @override
  Widget build(BuildContext context) {
    var body = Text('TODO: help widget');
    return Scaffold(
        appBar: buildAppBar(this, null, null),
        body: body,
        backgroundColor: Colors.white);
  }
}
