import 'dart:io';
import 'package:logging/logging.dart';
import 'package:html/parser.dart';
import 'package:markdown/markdown.dart';
import 'package:mustache/mustache.dart';
import 'config.dart';
import 'defaults.dart';
import 'utils.dart';

/// _PageType enum
enum _PageType { single, parent, child }

// =============================================================================
// cmdBuild
/// performs build command
/// [ctx] is zaart context map
bool cmdBuild(Map ctx) {
  // look for an intialized site
  bool _isInitializedFlag;
  try {
    _isInitializedFlag = isInitialized(ctx);
  } catch (err) {
    Logger.root.severe(err.toString());
    return false;
  }

  // if no site initialized return
  if (!_isInitializedFlag) {
    return false;
  }

  // read config file
  var isForced = ctx['cmd-build']['force'];
  var cfgFName = ctx['config'];
  var cfg = readConfig(cfgFName);

  // create build dir if not exists
  var buildDir = Directory(BUILD_DIR);
  if (!buildDir.existsSync()) {
    try {
      buildDir.createSync(recursive: false);
    } catch (err) {
      print("oh no, i cannot create or access build directory");
      Logger.root.severe('failed to create build directory');
      Logger.root.severe(err);
      return false;
    }
  }

  // copy theme dir to build dir (only css and js files)
  var srcthemeDir = Directory(THEME_DIR);
  var dstThemeDir = Directory(BUILD_DIR + '/' + THEME_DIR);
  try {
    dstThemeDir.createSync(recursive: false);
    srcthemeDir.listSync(recursive: false).forEach((f) {
      if (f is Directory) {
        return;
      }

      var name = f.uri.toString();
      if (!(name.endsWith('.css') || name.endsWith('.js'))) {
        return;
      }

      var file = File(name);
      file.copySync(BUILD_DIR + '/' + name);
    });
  } catch (err) {
    print("oh no, i cannot copy theme directory to build directory");
    Logger.root.severe('failed to copy them directory to build directory');
    Logger.root.severe(err);
    return false;
  }

  // build pages one by one
  cfg.pages.forEach((p) {
    _buildPage(BUILD_DIR, PAGES_DIR, THEME_DIR, cfg, p, isForced, false, null);
    if (p.children != null && p.children.length > 0) {
      p.children.forEach((c) => _buildPage(
          BUILD_DIR, PAGES_DIR, THEME_DIR, cfg, c, isForced, true, p));
    }
  });

  return true;
}

// =============================================================================
// _buildPage function
bool _buildPage(String buidDir, String pagesDir, String themeDir, Config cfg,
    Page page, bool isForced, bool isChild, Page parent) {
  _PageType pgType;
  bool hasChildren = page.children.length > 0;

  // if this page has children create a directory with page name as well
  if (hasChildren) {
    pgType = _PageType.parent;
    var dirName = buidDir + '/' + page.name;
    var dir = Directory(dirName);
    try {
      dir.createSync(recursive: false);
    } catch (err) {
      print('oops, i cannot create "$dirName" directory');
      Logger.root.severe('failed to create "$dirName" directory');
      Logger.root.severe(err);
      return false;
    }
  } else if (isChild) {
    pgType = _PageType.child;
  } else {
    pgType = _PageType.single;
  }

  // build source and destination path of page
  var srcPath = pagesDir + '/';
  var dstPath = buidDir + '/';

  // if this is a child page prefix it with parent name
  if (isChild) {
    srcPath += parent.name + '/';
    dstPath += parent.name + '/';
  }

  srcPath += page.name + '.md';
  dstPath += page.name + '.html';

  var srcFileContent = "";
  var dstFileContent = "";

  // read from source file
  var srcFile = File(srcPath);
  try {
    srcFile.openSync(mode: FileMode.read);
    srcFileContent = srcFile.readAsStringSync();
  } catch (err) {
    print('oops, i cannot read from "$srcPath" file');
    Logger.root.severe('failed to read from "$srcPath" file');
    Logger.root.severe(err);
    return false;
  }

  // compile source file
  try {
    switch (pgType) {
      case _PageType.single:
        dstFileContent = _compilePage(cfg, page, null, srcFileContent);
        break;
      case _PageType.parent:
        dstFileContent = _compilePage(cfg, page, parent, srcFileContent);
        break;
      case _PageType.child:
        dstFileContent = _compilePage(cfg, page, parent, srcFileContent);
        break;
    }
  } catch (err) {
    print('oops, i cannot compile "$srcPath" file');
    Logger.root.severe('failed to compile "$srcPath" file');
    Logger.root.severe(err);
    return false;
  }

  // write to destination file
  var dstFile = File(dstPath);
  try {
    dstFile.openSync(mode: FileMode.writeOnly);
    dstFile.writeAsStringSync(dstFileContent);
  } catch (err) {
    print('oops, i cannot write to "$dstPath" file');
    Logger.root.severe('failed write to "$dstPath" file');
    Logger.root.severe(err);
    return false;
  }

  return true;
}

// =============================================================================
// _compilePage function
String _compilePage(
  Config config,
  Page page,
  Page parent,
  String srcContent,
) {
  var tmplHtml = "";
  try {
    var file = File(THEME_DIR + '/' + page.layout);
    tmplHtml = file.readAsStringSync();
  } catch (err) {
    print('oops, i cannot read template file');
    Logger.root.severe('failed to read template file');
    Logger.root.severe(err);
  }

  var bodyHtml =
      markdownToHtml(srcContent, extensionSet: ExtensionSet.gitHubWeb);

  var html = HtmlParser(tmplHtml);
  var doc = html.parse();
  var bodyElem = doc.querySelector(PLACEHOLDER_TAG);
  bodyElem.innerHtml = bodyHtml;

  var musTmpl = Template(doc.outerHtml, lenient: true, name: 'OH NO MAZAFAK');
  var finalHtml = musTmpl.renderString(
      {'site': config, 'page': page, 'parent': parent, 'now': DateTime.now()});

  return finalHtml;
}
