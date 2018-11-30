import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'defaults.dart';
import 'config.dart';
import 'utils.dart';

// =============================================================================
// cmdInit
/// performs init command
/// [ctx] is zaart context map
bool cmdInit(Map ctx) {
  // look for any pre initialized site
  bool _isInitializedFlag;
  try {
    _isInitializedFlag = isInitialized(ctx);
  } catch (err) {
    Logger.root.severe(err.toString());
    return false;
  }

  // if initialized before return immediately
  if (_isInitializedFlag) {
    Logger.root.warning('cmdInit function returned immediately because'
        '${ctx["config"]} is already here');
    print('hmm, seems that there is already an initialized site');
    return false;
  }

  // create config object
  var indexPage = Page(
      name: INDEX_NAME,
      author: ctx['author'],
      layout: ctx['layout'],
      published: true,
      date: DateTime.now(),
      tags: <String>[],
      children: []);
  var cfg = Config(
      title: ctx['title'],
      author: ctx['author'],
      theme: ZAART_THEME,
      pages: [indexPage]);

  // create config file and write config object into it
  var configFile = File(ctx["config"]);
  try {
    configFile.createSync(recursive: false);
    configFile.writeAsStringSync(json.encode(cfg.toJson()));
  } catch (err) {
    print('oops, i cannot create $ZAART_CONFIG_FILE config file');
    Logger.root.severe('failed to create $ZAART_CONFIG_FILE file');
    Logger.root.severe(err.toString());
    return false;
  }

  // create 'pages' directory
  var pagesDir = Directory(PAGES_DIR);
  if (!pagesDir.existsSync()) {
    try {
      pagesDir.createSync();
    } catch (err) {
      print('oops, i cannot create $PAGES_DIR directory');
      Logger.root.severe('failed to create $PAGES_DIR directory');
      Logger.root.severe(err.toString());
      return false;
    }
  }

  // create 'theme' directory
  var themeDir = Directory(THEME_DIR);
  if (!themeDir.existsSync()) {
    try {
      themeDir.createSync();
    } catch (err) {
      print('oops, i cannot create $THEME_DIR directory');
      Logger.root.severe('failed to create $THEME_DIR directory');
      Logger.root.severe(err.toString());
      return false;
    }
  }

  // create index file in pages dir
  var indexPageFile = File(PAGES_DIR + '/' + indexPage.name + '.md');
  try {
    indexPageFile.createSync(recursive: false);
    indexPageFile.writeAsStringSync('hello zaart user');
  } catch (err) {
    print('oops, i cannot create $INDEX_MD_FILE file');
    Logger.root.severe('failed to create $INDEX_MD_FILE file');
    Logger.root.severe(err.toString());
    return false;
  }

  // create zaart theme css amd js files
  var themeCssFile = File(THEME_DIR + '/' + ZAART_CSS_FILE);
  var themeJsFile = File(THEME_DIR + '/' + ZAART_JS_FILE);
  try {
    themeCssFile.createSync(recursive: false);
    themeJsFile.createSync(recursive: false);
    themeCssFile.writeAsStringSync(ZAART_THEME_CSS);
    themeJsFile.writeAsStringSync(ZAART_THEME_JS);
  } catch (err) {
    print('oops, i cannot create zaart theme files');
    Logger.root.severe('failed to create zaart theme files');
    Logger.root.severe(err.toString());
    return false;
  }

  // create zaart layout files
  var singleLayoutFile = File(THEME_DIR + '/' + ZAART_SINGLE_LAYOUT_FILE);
  var parentLayoutFile = File(THEME_DIR + '/' + ZAART_PARENT_LAYOUT_FILE);
  var childLayoutFile = File(THEME_DIR + '/' + ZAART_CHILD_LAYOUT_FILE);
  var landingLayoutFile = File(THEME_DIR + '/' + ZAART_LANDING_LAYOUT_FILE);
  try {
    singleLayoutFile.createSync(recursive: false);
    parentLayoutFile.createSync(recursive: false);
    childLayoutFile.createSync(recursive: false);
    landingLayoutFile.createSync(recursive: false);
    singleLayoutFile.writeAsStringSync(ZAART_SINGLE_LAYOUT_HTML);
    parentLayoutFile.writeAsStringSync(ZAART_PARENT_LAYOUT_HTML);
    childLayoutFile.writeAsStringSync(ZAART_CHILD_LAYOUT_HTML);
    landingLayoutFile.writeAsStringSync(ZAART_LANDING_LAYOUT_HTML);
  } catch (err) {
    print('oops, i cannot create zaart layout files');
    Logger.root.severe('failed to create zaart layout files');
    Logger.root.severe(err.toString());
    return false;
  }

  return true;
}
