# Diligence

[![build](https://github.com/asartalo/diligence/actions/workflows/ci.yml/badge.svg)](https://github.com/asartalo/diligence/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/asartalo/diligence/badge.svg?branch=main)](https://coveralls.io/github/asartalo/diligence?branch=main)
[![LICENSE: GPLv3](https://img.shields.io/github/license/asartalo/diligence.svg?color=purple)](https://github.com/asartalo/diligence/blob/master/LICENSE)


Diligence is a free and open-source, tree-based, task management system.

## Tree-based?

The idea is to break down tasks as much as you need into "actionable" tasks to lessen overwhelm increasing the chance you'll complete them. If you've done outlining before, this should be familiar to you.

## Installation

As of the moment, Diligence is available as an AppImage and as a snap on the Snap Store.

### Linux

- [AppImage](https://github.com/asartalo/diligence/releases/download/0.1.11/Diligence-x64.AppImage)
- [Snap Store](https://snapcraft.io/diligence)

For the source code and other (future) binaries, head onto [Releases](https://github.com/asartalo/diligence/releases).

## Roadmap

Visit the [Diligence Project Page](https://github.com/users/asartalo/projects/1/views/1) to get a sense of what's on the pipeline.

## Development

Development happens on the main branch. When we're ready to release, we merge those changes to the release branch.

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

### Updating the SQLite Schema

SQLite is currently used as the backing store. To update the schema, we use database migrations. These are currently defined in `lib/services/migrations.dart`. There are however some important considerations when adding new migrations:

1. Some column operations are tricky to do in SQLite like modifying foreign key constraints. Basically the strategy is to 1.) rename the current table; 2.) create a new table that is basically the old one with the column changes; 3.) copy over the data from the old table to the new table; 4.) Delete the old table. This works but there will be errors when some columns have references to data that no longer exists in some other table. Before doing this, make sure to clean up your data on the old table first removing orphaned references first.

### Ubuntu Issues (and probably others...)

You might need to install libsqlite3.

```sh
sudo apt install libsqlite3-dev
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

## Preparing for Release

Create a pull-request from the main to the release branch. Only use "Merge pull request" option when resolving the pull request and not"Squash and merge". Only use "Squash and merge" when merging feature branches to the main branch.
