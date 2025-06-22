import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class EnvDisplay extends StatefulWidget {
  final Map<String, String> env;

  const EnvDisplay({super.key, required this.env});

  @override
  State<EnvDisplay> createState() => _EnvDisplayState();
}

class _EnvDisplayState extends State<EnvDisplay> {
  bool showEntries = false;

  @override
  Widget build(BuildContext context) {
    return Column(children: [_toggle(), ..._envEntries()]);
  }

  List<Widget> _envEntries() {
    if (!showEntries) {
      return [];
    }

    return widget.env.entries.sorted((a, b) => a.key.compareTo(b.key)).map((
      entry,
    ) {
      return ListTile(title: Text(entry.key), subtitle: Text(entry.value));
    }).toList();
  }

  Widget _toggle() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: TextButton(
        onPressed: () {
          setState(() {
            showEntries = !showEntries;
          });
        },
        child: Text(
          showEntries
              ? 'Hide Environment Variables'
              : 'Show Environment Variables',
        ),
      ),
    );
  }
}
