import 'package:finch_chat/utils/color.dart';
import 'package:flutter/material.dart';

ThemeData finchChatTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: FinchChatColor.primary),
  useMaterial3: true,
  drawerTheme: const DrawerThemeData(
    // Set the shape to be rectangular (no rounded corners)
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
  ),
);
