// Diligence - A Task Management App
//
// Copyright (C) 2024 Wayne Duran <asartalo@gmail.com>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../diligence_config.dart';
import '../../services/notices/notice_queue.dart';
import './app_bar.dart';
import 'diligence_drawer.dart';
import 'notice_area.dart';

class CommonScreen extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget? floatingActionButton;

  const CommonScreen({
    super.key,
    required this.title,
    required this.child,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Hero(
          tag: 'appbar',
          child: Builder(builder: (context) => appBar(context, title)),
        ),
      ),
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          Builder(
            builder: (BuildContext context) => child,
          ),
          NoticeArea(noticeQueue: Provider.of<NoticeQueue>(context)),
        ],
      ),
      floatingActionButton: floatingActionButton,
      drawer: Builder(
        builder: (context) => DiligenceDrawer(
          config: Provider.of<DiligenceConfig>(context),
        ),
      ),
    );
  }
}
