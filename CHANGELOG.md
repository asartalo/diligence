# 0.1.12 (2025-05-29)

## Bug Fixes

- upgraded sdks to flutter 3.27.4 and dart  3.8 ([8b54ad7](commit/8b54ad7))
- focus page not updating when changing tasks on there ([8409d1d](commit/8409d1d))
- upgraded project ([17b688a](commit/17b688a))

## Features

- **focus:** no focused items text ([09e10eb](commit/09e10eb))
- show ancestry of tasks in focus view ([881b28e](commit/881b28e))

# 0.1.11 (2024-10-26)

## Bug Fixes

- attempt cross-platform config save ([1532aa1](commit/1532aa1))

# 0.1.10 (2024-08-24)

## Bug Fixes

- workaround jobs not firing ([d63241e](commit/d63241e))
- better config file saving ([3dc4119](commit/3dc4119))
- scrolling issues on settings page ([c367e55](commit/c367e55))
- overflow problem on home screen ([9f0aeba](commit/9f0aeba))
- remove debug info on show more button ([80e351a](commit/80e351a))
- double focus on checkbox ([1fe13d2](commit/1fe13d2))

## Features

- logging to file settings ([4aa5549](commit/4aa5549))
- proper logging with setting level ([98a09c6](commit/98a09c6))

# 0.1.9 (2024-07-23)

## Bug Fixes

- multiple items focus persist ([24d92ed](commit/24d92ed))
- deleting task from focus view removes it immediately ([d486dd8](commit/d486dd8))
- update focus queue when pressing focus on notice ([967688b](commit/967688b))

# 0.1.8 (2024-06-22)

## Features

- responsive design focus screen ([812bb63](commit/812bb63))
- tweak checkbox design ([2cf9796](commit/2cf9796))
- show version info on settings ([4208808](commit/4208808))

# 0.1.7 (2024-06-02)

## Bug Fixes

- wrong status bar colors ([aa8c22c](commit/aa8c22c))
- only use .env if it exists ([e79761a](commit/e79761a))

## Features

- better UI for setting database path ([e5f4987](commit/e5f4987))
- set and save configuration files ([09382cb](commit/09382cb))
- basic config validation ([4d821db](commit/4d821db))
- database path in settings is selectable ([2b8ce4a](commit/2b8ce4a))
- change configuration from toml to yaml ([285ccd2](commit/285ccd2))
- wip use toml config instead of env ([261e359](commit/261e359))
- database path in settings is selectable ([ee7d4e9](commit/ee7d4e9))

# 0.1.6 (2024-05-03)

## Bug Fixes

- formatting and copyright info ([667d548](commit/667d548))
- better timing in clock updates ([1bddc15](commit/1bddc15))
- change focus order of buttons ([e2b8c42](commit/e2b8c42))

## Features

- reminders and notifications for reminders ([50fb365](commit/50fb365))
- job queueing system ([3c7b104](commit/3c7b104))
- tasks can have deadlines ([1b86286](commit/1b86286))

# 0.1.5 (2024-03-31)

## Bug Fixes

- scroll and render issues in focus screen ([b2ab15a](commit/b2ab15a))

# 0.1.4 (2024-03-30)

## Bug Fixes

- settings page and test ([81117cb](commit/81117cb))
- ensure setState is not called after dispose ([1feab2a](commit/1feab2a))
- hide unfinished review page ([e8771a1](commit/e8771a1))
- focus highlight remains after hovering task menu ([1ba1e7c](commit/1ba1e7c))
- focusing ancestor task focuses not done leaves ([37d4864](commit/37d4864))
- linux snap logo ([ab18142](commit/ab18142))
- title bar in linux app is lowercase ([8837105](commit/8837105))
- removing _isFocused private method ([ac279a6](commit/ac279a6))
- android build issues ([ad7cb56](commit/ad7cb56))
- use application directory for db path ([0aeefc4](commit/0aeefc4))
- problems updating and deleting task ([f380f88](commit/f380f88))
- flicker when moving tasks ([3c6f4ef](commit/3c6f4ef))
- ordering tasks ([7b0bc03](commit/7b0bc03))

## Features

- settings screen ([8f8c01d](commit/8f8c01d))
- a more functional home screen ([a263a4c](commit/a263a4c))
- logical task toggle when moving tasks between subtrees ([d7d430f](commit/d7d430f))
- improved focus page layout ([911cc4f](commit/911cc4f))
- app bar clock shows acurate time ([227c431](commit/227c431))
- focused task then adding children logic ([2a5d902](commit/2a5d902))
- basic focus page layout ([87761e2](commit/87761e2))
- unfocus tasks ([3661610](commit/3661610))
- done logic when deleting and adding tasks ([3c6330d](commit/3c6330d))
- queue main features added ([380ca8f](commit/380ca8f))
- marking ancestor task done unfocuses descendants ([616932a](commit/616932a))
- "doneAt, createdAt and updatedAt" ([8116a5d](commit/8116a5d))
- wip snap store deployment ([8f628de](commit/8f628de))
- generated icons ([ac85274](commit/ac85274))
- icons ([e346804](commit/e346804))
- focus page task queue ([6bab3bb](commit/6bab3bb))
- wip focus tasks ([137b997](commit/137b997))
- expand task after adding a child task ([06b9aa8](commit/06b9aa8))
- tasks can be moved between parents ([c73a022](commit/c73a022))
- only show expand tasks toggle for tasks that have children ([5b85129](commit/5b85129))
- tasks can now have child tasks ([2d3b9f9](commit/2d3b9f9))
- ability to delete tasks ([0b5c348](commit/0b5c348))
- ability to edit tasks, details ([c6831cd](commit/c6831cd))
- long press to drag tasks ([b3596c1](commit/b3596c1))
- update sdk and dependencies ([42a1df8](commit/42a1df8))
- can add tasks ([fa6ba83](commit/fa6ba83))
- tasks page ([71dedcb](commit/71dedcb))
- wip task tree model ([9025d7b](commit/9025d7b))
- theme update ([139ec1a](commit/139ec1a))
- home page and persistent appbar ([3ff87ab](commit/3ff87ab))
- working sqlite3 db implementation ([5386c76](commit/5386c76))
- update dependencies ([acb69ac](commit/acb69ac))
- null-safety and piechart cache ([43cf9b7](commit/43cf9b7))

# 0.1.0 (2021-02-17)

## Features

- null-safety and piechart cache ([43cf9b7](commit/43cf9b7))
