import 'dart:io';
import 'dart:convert';
import 'defaults.dart';
import 'utils.dart';
import 'package:logging/logging.dart';

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

  if (FileSystemEntity.isFileSync(ROOT_INDEX_PAGE)) {
    var msg = 'found an existing "$ROOT_INDEX_PAGE" file';
    Logger.root.warning(msg);
    print(msg);
  } else {
    var indexFile = File(ROOT_INDEX_PAGE);
    indexFile.createSync(recursive: false);
    indexFile.writeAsStringSync(DEFAULT_INDEX);
  }

  if (FileSystemEntity.isFileSync(LAYOUT_DIR)) {
    var msg = 'found an existing "$LAYOUT_DIR" directory';
    Logger.root.warning(msg);
    print(msg);
  } else {
    var layoutDir = Directory(LAYOUT_DIR);
    layoutDir.createSync(recursive: false);

    var layoutCss = File(LAYOUT_DIR + "/" + LAYOUT_CSS);
    layoutCss.createSync(recursive: false);
    layoutCss.writeAsStringSync(DEFAULT_CSS);

    var layoutJs = File(LAYOUT_DIR + "/" + LAYOUT_JS);
    layoutJs.createSync(recursive: false);
    layoutJs.writeAsStringSync(DEFAULT_JS);
  }

  var config = Map();
  config["name"] = ctx["name"];
  config["author"] = "UNKNOWN";
  config["sections"] = List<String>();
  var configJson = json.encode(config);
  configFile.writeAsStringSync(configJson);

  return true;
}
