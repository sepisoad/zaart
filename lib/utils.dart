import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'config.dart';

// =============================================================================
// isInitialized
/// is used to check if any initialized site is found on the path
/// [ctx] is zaart context map
bool isInitialized(Map ctx) {
  if (ctx == null) {
    print("oops, i faced an internal error!");
    print("please contact developer(s)!");
    throw Exception('isInitialized() is called with null');
  }

  if (ctx.isEmpty) {
    print("oops, i faced an internal error!");
    print("please contact developer(s)!");
    throw Exception('isInitialized() is called with empty map');
  }

  var config = ctx["config"];

  if (config == null) {
    print("oops, i faced an internal error!");
    print("please contact developer(s)!");
    throw Exception('isInitialized() config key is missing from map');
  }

  var file = File(config);
  return file.existsSync();
}

// =============================================================================
// readConfig
/// reads site condig from [path] and returns a `Config` object
Config readConfig(String path) {
  File file;
  String jsCfgStr;

  try {
    file = File(path);
    jsCfgStr = file.readAsStringSync();
  } catch (err) {
    print("oh no, i cannot read config file!");
    Logger.root.severe(err.toString());
    return null;
  }

  Map<String, dynamic> jsCfg = json.decode(jsCfgStr);

  try {
    return Config.fromJson(jsCfg);
  } catch (err) {
    print("oh no, config file has some bad syntax in it!");
    Logger.root.severe(err.toString());
    return null;
  }
}

// =============================================================================
// writeConfig
/// converts a `Config` objects to its json representation and writes it
/// into file
bool writeConfig(Map<String, dynamic> cfg, String path) {
  File file;
  try {
    file = File(path);
    var jsCfg = json.encode(cfg);
    file.writeAsStringSync(jsCfg);
  } catch (err) {
    print("oh no, i cannot write into config file!");
    Logger.root.severe(err.toString());
    return false;
  }

  return true;
}

// =============================================================================
// getDirList
/// returns a list of `String`s, each represent a section name.
List<String> getDirList() {
  var list = List<String>();
  var dir = Directory(".");

  var folders = dir.listSync(recursive: false, followLinks: false);
  folders.forEach((FileSystemEntity folder) {
    var stat = folder.statSync();
    var uri = folder.uri.toString();

    if (stat.type.toString() != "directory") return;
    if (uri.startsWith(".") == true) return;

    if (uri.endsWith("/")) {
      uri = uri.substring(0, uri.length - 1);
    }

    list.add(uri);
  });

  return list;
}

// =============================================================================
// renameMd2Html
/// helper function that renames a string ending with '.md' to '.html'
String renameMd2Html(String name) {
  var res = name.replaceFirst(RegExp(r'.md$'), '.html');
  return res;
}
