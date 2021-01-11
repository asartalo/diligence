# Diligence

Productivity for the unproductive.

# Development

Uses [commitlint](https://commitlint.js.org/#/) and [husky](https://github.com/typicode/husky)

## Getting the Database Version

As of the moment, Diligence uses sqflite library. Because of this and if for some reason you need to know the database version, just call:

```dart
database.getVersion();
```

If you need to check the version number from the database itself, run this query:

```sql
PRAGMA user_version;
```