import 'package:energize/entries.dart';
import 'package:flutter/material.dart';
import 'design.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'boxes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await Hive.initFlutter();
  await dotenv.load(fileName: ".env");
  Hive.registerAdapter(EntriesAdapter());
  boxEntries = await Hive.openBox<Entries>('entriesBox');
  runApp(MaterialApp(
      home: EnergizeApp()
  )
  );
}



