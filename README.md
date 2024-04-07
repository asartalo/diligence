# Diligence

[![build](https://github.com/asartalo/diligence/actions/workflows/ci.yml/badge.svg)](https://github.com/asartalo/diligence/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/asartalo/diligence/badge.svg?branch=main)](https://coveralls.io/github/asartalo/diligence?branch=main)
[![LICENSE: GPLv3](https://img.shields.io/github/license/asartalo/diligence.svg?color=purple)](https://github.com/asartalo/diligence/blob/master/LICENSE)


Diligence is a free and open-source, tree-based, task management system.

## Tree-based?

The idea is to break down tasks as much as you need into "actionable" tasks to lessen overwhelm increasing the chance you'll complete them. If you've done outlining before, this should be familiar to you.

## Installation

As of the moment, only an AppImage is available for download. See [Releases](https://github.com/asartalo/diligence/releases).

### Linux

- [AppImage](https://github.com/asartalo/diligence/releases/download/0.1.5/Diligence-x64.AppImage)

## Roadmap

Visit the [Diligence Project Page](https://github.com/users/asartalo/projects/1/views/1) to get a sense of what's on the pipeline.

## Development

The desktop app has only been tested on Linux. If you have an instance of the release version of the app running while developing, run the debug mode with the `DILIGENCE_APP_ID_PREFIX` set to something (e.g. "dev") so that it won't conflict with the release version.

See the following example command below to do this on the terminal.

```sh
DILIGENCE_APP_ID_PREFIX=dev flutter run
```

This environment variable has already been set on VSCode through the launch options. See `.vscode/launch.json`.

If you also want to run the integration tests and not want it to interfere with a Diligence desktop app installation, add the app id prefix too:

```sh
DILIGENCE_APP_ID_PREFIX=test flutter test integration_test/all_tests.dart
```

### Testing Builds for Ubuntu

In Ubuntu you can run the following

```sh
snapcraft
```

This creates a snap file `diligence_<VERSION>_amd64.snap`. Install it with the following command:

```sh
sudo snap install ./diligence_<VERSION>_amd64.snap --dangerous
```
