# Diligence

Productivity for the unproductive.

## Development

At the moment, the desktop app has only been tested on Linux. If you have an instance of the release version of the app running while developing, run the debug mode with the `DILIGENCE_APP_ID_PREFIX` set to something (e.g. "dev") so that it won't conflict with the release version.

See the following example command below to do this on the terminal.

```sh
DILIGENCE_APP_ID_PREFIX=dev flutter run
```

This environment variable has already been set on VSCode through the launch options. See `.vscode/launch.json`.

If you also want to run the integration tests and not want it to interfere with a Diligence desktop app installation, add the app id prefix too:

```sh
DILIGENCE_APP_ID_PREFIX=test flutter test integration_test/all_tests.dart
```
