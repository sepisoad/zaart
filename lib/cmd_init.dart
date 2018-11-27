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
  bool _isInitializedFlag;
  try {
    _isInitializedFlag = isInitialized(ctx);
  } catch (err) {
    Logger.root.severe(err.toString());
    return false;
  }

  if (_isInitializedFlag) {
    Logger.root.warning('cmdInit function returned immediately because'
        '${ctx["config"]} is already here');
    print('hmm, seems that there is already an initialized site');
    return false;
  }

  var configFile = File(ctx["config"]);
  try {
    configFile.createSync(recursive: false);
  } catch (err) {}

  if (FileSystemEntity.isFileSync(INDEX_MD)) {
    var msg = 'found an existing "$INDEX_MD" file';
    Logger.root.warning(msg);
    print(msg);
  } else {
    var indexFile = File(INDEX_MD);
    indexFile.createSync(recursive: false);
    indexFile.writeAsStringSync(INDEX_MD_CONTENT);
  }

  if (FileSystemEntity.isFileSync(LAYOUT_DIR)) {
    var msg = 'found an existing "$LAYOUT_DIR" directory';
    Logger.root.warning(msg);
    print(msg);
  } else {
    var layoutDir = Directory(LAYOUT_DIR);
    layoutDir.createSync(recursive: false);

    var layoutCss = File(LAYOUT_DIR + "/" + ZAART_CSS);
    layoutCss.createSync(recursive: false);
    layoutCss.writeAsStringSync(ZAART_CSS_CONTENT);

    var layoutJs = File(LAYOUT_DIR + "/" + ZAART_JS);
    layoutJs.createSync(recursive: false);
    layoutJs.writeAsStringSync(ZAART_JS_CONTENT);
  }

  var cfg = Config()
    ..author = "UNKNOWN"
    ..name = "UNDEFINED"
    ..layout = ZAART_LAYOUT_INCLUDES;

  configFile.writeAsStringSync(json.encode(cfg.toJson()));

  return true;
}
