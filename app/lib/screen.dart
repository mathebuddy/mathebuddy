/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

library mathe_buddy_app;

import 'package:flutter/material.dart';

SingleChildScrollView? scrollView;
ScrollController? scrollController;

const double defaultFontSize = 16;

const double maxContentsWidth = 640;

GlobalKey? exerciseKey;
