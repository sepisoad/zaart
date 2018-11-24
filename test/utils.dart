import 'dart:io';
import 'package:zaart/default.dart';
import 'package:zaart/config.dart';

//
// ██╗   ██╗████████╗██╗██╗     ███████╗
// ██║   ██║╚══██╔══╝██║██║     ██╔════╝
// ██║   ██║   ██║   ██║██║     ███████╗
// ██║   ██║   ██║   ██║██║     ╚════██║
// ╚██████╔╝   ██║   ██║███████╗███████║
//  ╚═════╝    ╚═╝   ╚═╝╚══════╝╚══════╝
//

// =============================================================================
// deleteFile
deleteFile(name) {
  try {
    var file = File(name);
    file.deleteSync(recursive: true);
  } catch (err) {}
}

// =============================================================================
// getSampleConfigObject1

Config getSampleConfigObject1() {
  var author = "mr. tester";
  var cnf = Config();
  cnf.name = "test";
  cnf.author = author;
  cnf.sections = <Section>[
    Section()
      ..name = 'section-1'
      ..children = <Children>[
        Children()
          ..name = "s1-1"
          ..date = DateTime.now()
          ..author = author
          ..published = true
          ..tags = <String>["tag1", "tag2", "tag3"],
        Children()
          ..name = "s1-2"
          ..date = DateTime.now()
          ..author = author
          ..published = false
          ..tags = <String>["tag3", "tag4", "tag5"]
      ],
    Section()
      ..name = 'section-2'
      ..children = <Children>[
        Children()
          ..name = "s2-1"
          ..date = DateTime.now()
          ..author = author
          ..published = true
          ..tags = <String>["tag2", "tag5", "tag3"],
        Children()
          ..name = "s2-2"
          ..date = DateTime.now()
          ..author = author
          ..published = false
          ..tags = <String>["tag1", "tag4", "tag6"]
      ],
  ];

  return cnf;
}

// =============================================================================
// deleteSite

deleteSite() {
  var indexFile = File(INDEX_PAGE);
  var configFile = File(ZAART_CONFIG);
  var buildDir = Directory(BUILD_DIR);
  var layoutDir = Directory(LAYOUT_DIR);

  try {
    indexFile.deleteSync();
  } catch (err) {}
  try {
    configFile.deleteSync();
  } catch (err) {}
  try {
    buildDir.deleteSync(recursive: true);
  } catch (err) {}
  try {
    layoutDir.deleteSync(recursive: true);
  } catch (err) {}
}
