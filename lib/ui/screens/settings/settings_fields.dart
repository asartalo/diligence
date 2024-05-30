import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../../../diligence_config.dart';

typedef ConfigUpdateCallback = void Function(DiligenceConfig config);

class SettingsFields extends StatefulWidget {
  final DiligenceConfig config;
  final ConfigUpdateCallback onUpdateConfig;
  const SettingsFields({
    super.key,
    required this.config,
    required this.onUpdateConfig,
  });

  @override
  State<SettingsFields> createState() => _SettingsFieldsState();
}

class _SettingsFieldsState extends State<SettingsFields> {
  // bool _editingDatabasePath = false;

  DiligenceConfig get config => widget.config;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text('Database Path'),
          subtitle: databasePathField(),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final fileName = basename(config.dbPath);
              final containingDirectory = dirname(config.dbPath);
              final result = await getSaveLocation(
                suggestedName: fileName,
                initialDirectory: containingDirectory,
              );

              if (result != null) {
                widget.onUpdateConfig(config.copyWith(
                  dbPath: result.path,
                ));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget databasePathField() {
    // if (_editingDatabasePath) {
    //   return TextField(
    //     controller: TextEditingController(text: config.dbPath),
    //     onSubmitted: (value) {
    //       setState(() {
    //         _editingDatabasePath = false;
    //       });
    //       widget.onUpdateConfig(config.copyWith(
    //         dbPath: value,
    //       ));
    //     },
    //   );
    // }

    return SelectableText(widget.config.dbPath);
  }
}
