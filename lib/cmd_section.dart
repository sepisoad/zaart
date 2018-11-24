import 'dart:io';
import 'package:logging/logging.dart';
import 'config.dart';
import 'default.dart';
import 'utils.dart';

// =============================================================================
// cmdSection
bool cmdSection(Map ctx) {
  bool _isInitialized;
  try {
    _isInitialized = isInitialized(ctx);
  } catch (err) {
    Logger.root.severe(err.toString());
    return false;
  }

  if (!_isInitialized) {
    return false;
  }

  var cmd = ctx["cmd-section"];

  if (cmd.isEmpty) {
    print("oh no, i faced an internal error!");
    Logger.root.severe(
        '"cmd-section" is missing from context in cmdSection() function');
    return false;
  }

  var fun = cmd["fun"];
  var arg = cmd["arg"];

  if (null == fun) {
    print("oh no, i faced an internal error!");
    Logger.root.severe(
        '"fun" key is missing from "cmd-section" map in cmdSection() function');
    return false;
  }

  if (null == arg) {
    print("oh no, i faced an internal error!");
    Logger.root.severe(
        '"arg" key is missing from "cmd-section" map in cmdSection() function');
    return false;
  }

  var configFileName = ctx["config"];
  Config config = readConfig(configFileName);

  switch (fun) {
    case "add":
      return _funAdd(config, configFileName, arg);
    case "del":
      return _funDel(config, configFileName, arg);
      break;
    default:
      return false;
  }
}

// =============================================================================
// _funAdd
bool _funAdd(Config cfg, String cfgName, String name) {
  bool exists = cfg.sections.any((section) {
    return section == name;
  });

  if (exists) {
    print("oops, the '$name' entry was already added to config file");
    Logger.root
        .warning('cmdSection() -> _funAdd($name) returned false, because the'
            'section name was already added to config file');
    return false;
  }

  cfg.sections.add(Section()
    ..name = name
    ..children = []);
  var dirs = getDirList();
  exists = dirs.any((dir) {
    if (dir == name) return true;
    return false;
  });
  if (exists) {
    print("oops, i found a directory with exactly the same name '$name'");
    Logger.root.warning(
        'cmdSection() -> _funAdd($name) returned false, because the'
        'destination path contains an existing directory with the same name');
    return false;
  }

  try {
    var newDir = Directory(name);
    newDir.createSync();

    var indexPage = name + "/" + INDEX_PAGE;
    var indexFile = File(indexPage);
    indexFile.createSync();
  } catch (err) {
    print("oh no, i cannot create a directory for '$name' section");
    Logger.root.warning('faild to create "$name" sectio directory');
    Logger.root.warning(err.toString());
    return false;
  }

  return writeConfig(cfg.toJson(), cfgName);
}

// =============================================================================
// _funDel
bool _funDel(Config cfg, String cfgName, String name) {
  bool exists = cfg.sections.any((section) {
    return section.name == name;
  });
  if (!exists) {
    print("oops, i cannot find '$name' section in config file");
    Logger.root
        .warning('cmdSection() -> _funDel($name) returned false, because the'
            'section name was not found in config file');
    return false;
  }

  cfg.sections.removeWhere((section) {
    return section.name == name;
  });

  var dirs = getDirList();
  exists = dirs.any((dir) {
    if (dir == name) return true;
    return false;
  });
  if (exists) {
    try {
      var newDir = Directory(name);
      newDir.deleteSync(recursive: true);
    } catch (err) {
      print("oh no, i cannot delete '$name' section directory");
      Logger.root.warning('faild to delete "$name" section directory');
      Logger.root.warning(err.toString());
      return false;
    }
  }

  return writeConfig(cfg.toJson(), cfgName);
}
