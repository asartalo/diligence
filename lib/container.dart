import 'package:diligence/services/review_data/review_data_bloc.dart';
import 'package:diligence/services/review_data_service.dart';
import 'package:diligence/utils/sqflite_prepare.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sqflite/sqflite.dart';

import 'config.dart';

class DiligenceContainer {
  final DiligenceConfig config;
  final Database database;

  DiligenceContainer({
    @required this.config,
    @required this.database,
  });

  List<SingleChildWidget> providers() {
    return [
      Provider(create: (_) => config),
      Provider(create: (_) => database),
      BlocProvider(create: (_) => ReviewDataBloc(ReviewDataService(database))),
    ];
  }

  static Future<DiligenceContainer> start([String envFile = '.env']) async {
    final dotEnv = DotEnv();
    await dotEnv.load(envFile);
    final config = DiligenceConfig.fromEnv(dotEnv.env);
    // We must do this so we can
    sqflitePrepare();
    final database = await openDatabase(config.dbPath);
    return DiligenceContainer(
      config: config,
      database: database,
    );
  }
}
