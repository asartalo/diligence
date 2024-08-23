import 'package:flutter/material.dart';

abstract class SnackbarMessage {
  String get content;
  IconData get icon;
}

class InfoSnackbarMessage implements SnackbarMessage {
  @override
  String content;

  @override
  IconData icon = Icons.info;

  InfoSnackbarMessage(this.content);
}

class ErrorSnackbarMessage implements SnackbarMessage {
  @override
  String content;

  @override
  IconData icon = Icons.error;

  ErrorSnackbarMessage(this.content);
}

mixin Snacker on Widget {
  void showSnack(BuildContext context, SnackbarMessage message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(message.icon),
          Text(message.content),
        ],
      ),
    ));
  }
}
