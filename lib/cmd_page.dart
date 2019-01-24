import 'dart:io';
import 'package:logging/logging.dart';
import 'config.dart';
import 'defaults.dart';
import 'utils.dart';

// =============================================================================
// cmdPage
/// performs page command
/// [ctx] is zaart context map
bool cmdPage(Map ctx) {
  bool _isInitializedFlag;
  try {
    _isInitializedFlag = isInitialized(ctx);
  } catch (err) {
    Logger.root.severe(err.toString());
    return false;
  }

  if (!_isInitializedFlag) {
    return false;
  }

  var cmd = ctx["cmd-page"];

  if (cmd.isEmpty) {
    print("oh no, i faced an internal error!");
    Logger.root
        .severe('"cmd-page" is missing from context in cmdPage() function');
    return false;
  }

  String fun = cmd["fun"];
  String page = cmd["name"];
  String layout = cmd["layout"];
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

  if (null == configFileName) {
    print("oh no, i faced an internal error!");
    Logger.root.severe(
        '"config" key is missing from "cmd-page" map in cmdPage() function');
    return false;
  }

  String parent;

  if (page.contains('\\')) {
    page = page.replaceAll('\\', '/');
  }

  if (page.contains('/')) {
    var arr = page.split('/');
    if (arr.length > 2) {
      print("oops, you can only have at most 1 level of depth in page name");
      print("for example: [page] or [page]/[child]");
      Logger.root.warning('page name $page is not acceptable');
      return false;
    }
    parent = arr[0];
    page = arr[1];
  } else {
    parent = null;
  }

  Config config = readConfig(configFileName);

  switch (fun) {
    case "add":
      return _funAdd(config, configFileName, page, parent, layout);
      break;
    case "del":
      return _funDel(config, configFileName, page, parent);
      break;
    default:
      return false;
  }
}

// =============================================================================
// _funAdd
bool _funAdd(Config cfg, String cfgName, String pageName, String parentName,
    String layout) {
  Page parent = null;
  Page page = null;

  if (null != parentName) {
    parent =
        cfg.pages.firstWhere((p) => p.name == parentName, orElse: () => null);
    if (null == parent) {
      print('oops, i cannot find any parent page with this name');
      Logger.root.warning('parent page name $page was not found');
      return false;
    }
    page = parent.children
        .firstWhere((p) => p.name == pageName, orElse: () => null);
  } else {
    page = cfg.pages.firstWhere((p) => p.name == pageName, orElse: () => null);
  }

  if (null != page) {
    print('oops, there is already another page with this name');
    Logger.root.warning('parent page name $page is redundent');
    return false;
  }

  page = Page(
      author: cfg.author,
      layout: layout,
      date: DateTime.now(),
      name: pageName,
      tags: [],
      children: []);
  if (null != parent) {
    parent.children.insert(0, page);
  } else {
    cfg.pages.add(page);
  }

  var pagePath = PAGES_DIR;
  if (null != parent) {
    pagePath += '/' + parentName;
  }
  pagePath += '/' + pageName + '.md';

  var pageFile = File(pagePath);
  try {
    pageFile.createSync(recursive: true);
  } catch (err) {
    print('oops, i cannot create "$pagePath" page');
    Logger.root.severe('failed to create $pagePath');
    Logger.root.severe(err);
    return false;
  }

  return writeConfig(cfg.toJson(), cfgName);
}

// =============================================================================
// _funDel
bool _funDel(
  Config cfg,
  String cfgName,
  String pageName,
  String parentName,
) {
  Page parent;
  Page page;

  if (null != parentName) {
    parent =
        cfg.pages.firstWhere((p) => p.name == parentName, orElse: () => null);
    if (null == parent) {
      print('oops, i cannot find any parent page with this name');
      Logger.root.warning('parent page name $page was not found');
      return false;
    }
    page = parent.children
        .firstWhere((p) => p.name == pageName, orElse: () => null);
  } else {
    page = cfg.pages.firstWhere((p) => p.name == pageName, orElse: () => null);
  }

  if (null == page) {
    print('oops, i cannot find any page with this name');
    Logger.root.warning('page name $page was not found');
    return false;
  }

  var pagePath = PAGES_DIR;
  if (null != parent) {
    pagePath += '/' + parentName;
  }
  pagePath += '/' + pageName + '.md';

  var pageFile = File(pagePath);
  try {
    pageFile.deleteSync(recursive: true);
  } catch (err) {
    print('oops, i cannot delete "$pagePath" page');
    Logger.root.severe('failed to delete $pagePath');
    Logger.root.severe(err);
    return false;
  }

  if (null != parent) {
    parent.children.removeWhere((c) => c.name == pageName);
  } else {
    cfg.pages.removeWhere((p) => p.name == pageName);
  }

  return writeConfig(cfg.toJson(), cfgName);
}
