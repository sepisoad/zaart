import 'dart:io';
import 'package:logging/logging.dart';
import 'config.dart';
import 'utils.dart';

// =============================================================================
// cmdPage
bool cmdPage(Map ctx) {
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

  var cmd = ctx["cmd-page"];

  if (cmd.isEmpty) {
    print("oh no, i faced an internal error!");
    Logger.root
        .severe('"cmd-page" is missing from context in cmdPage() function');
    return false;
  }

  var fun = cmd["fun"];
  var page = cmd["name"];
  var section = cmd["section"];
  var configFileName = ctx["config"];

  if (null == fun) {
    print("oh no, i faced an internal error!");
    Logger.root.severe(
        '"fun" key is missing from "cmd-page" map in cmdPage() function');
    return false;
  }

  if (null == page) {
    print("oh no, i faced an internal error!");
    Logger.root.severe(
        '"page" key is missing from "cmd-page" map in cmdPage() function');
    return false;
  }

  if (null == section) {
    print("oh no, i faced an internal error!");
    Logger.root.severe(
        '"section" key is missing from "cmd-page" map in cmdPage() function');
    return false;
  }

  if (null == configFileName) {
    print("oh no, i faced an internal error!");
    Logger.root.severe(
        '"config" key is missing from "cmd-page" map in cmdPage() function');
    return false;
  }

  Config config = readConfig(configFileName);

  switch (fun) {
    case "add":
      return _funAdd(config, configFileName, page, section);
      break;
    case "del":
      return _funDel(config, configFileName, page, section);
      break;
    default:
      return false;
  }
}

// =============================================================================
// _funAdd
bool _funAdd(Config cfg, String cfgName, String page, String section) {
  bool exists = cfg.sections.any((s) => s.name == section);

  if (!exists) {
    print("oops, '$section' section is missing from section directory");
    Logger.root.warning(
        'cmdPage() -> _funAdd($page, $section) returned false, because the'
        'section name was missing from config file');
    return false;
  }

  var sectionIdx = cfg.sections.indexWhere((s) {
    return s.name == section;
  });

  var s = cfg.sections[sectionIdx];
  exists = s.children.any((child) {
    return child.name == page;
  });

  if (exists) {
    print("oops, page '$page' is already added to '$section'");
    Logger.root.warning(
        'cmdPage() -> _funAdd($page, $section) returned false, because the'
        'page name was already added to section');
    return false;
  }

  var child = Children();
  child.name = page;
  cfg.sections[sectionIdx].children.add(child);

  var sectionDir = Directory(section);
  if (!sectionDir.existsSync()) {
    print("oops, the section '$section' folder is missing from site root");
    Logger.root.warning(
        'cmdPage() -> _funAdd($page, $section) returned false, because the'
        'section folder is missing from site root');
    return false;
  }

  var pageFileName = section + '/' + page + ".md";
  var pageFile = File(pageFileName);

  if (pageFile.existsSync()) {
    print("oops, the requested page already exists in '$section' folder!");
    Logger.root.warning(
        'cmdPage() -> _funAdd($page, $section) returned false, because the'
        'requested page already exists in section folder');
    return false;
  }

  try {
    pageFile.createSync(recursive: false);
  } catch (err) {
    print("oops, failed to create '$page' page");
    Logger.root.severe("failed to create '$page' page");
    Logger.root.severe(err.toString());
    return false;
  }

  return writeConfig(cfg.toJson(), cfgName);
}

// =============================================================================
// _funDel
bool _funDel(Config cfg, String cfgName, String page, String section) {
  bool exists = cfg.sections.any((s) => s.name == section);

  if (!exists) {
    print("oops, '$section' section is missing from section directory");
    Logger.root.warning(
        'cmdPage() -> _funDel($page, $section) returned false, because the'
        'section name was missing from config file');
    return false;
  }

  var sectionIdx = cfg.sections.indexWhere((s) => s.name == section);

  var s = cfg.sections[sectionIdx];
  exists = s.children.any((child) {
    return child.name == page;
  });

  if (!exists) {
    print(
        "oops, '$page' page is missing from '$section' sections in config file");
    Logger.root.warning(
        'cmdPage() -> _funDel($page, $section) returned false, because the'
        'page was missing from config');
    return false;
  }

  cfg.sections[sectionIdx].children.removeWhere((child) {
    return child.name == page;
  });

  var sectionDir = Directory(section);
  if (!sectionDir.existsSync()) {
    print("oops, the '$section' section directory does not exist!");
    Logger.root.warning(
        'cmdPage() -> _funDel($page, $section) returned false, because the'
        'section directory was missing from site root');
    return false;
  }

  var pageFileName = section + '/' + page + ".md";
  var pageFile = File(pageFileName);

  if (!pageFile.existsSync()) {
    print("oops, '$page' page does not exist!");
    Logger.root.warning(
        'cmdPage() -> _funDel($page, $section) returned false, because the'
        '"$page" page file is missing from section directory');
    return false;
  }

  try {
    pageFile.deleteSync(recursive: false);
  } catch (err) {
    print("oops, failed to delete '$page' page");
    Logger.root.severe("failed to delete '$page' page");
    Logger.root.severe(err.toString());
    return false;
  }

  return writeConfig(cfg.toJson(), cfgName);
}
