import 'package:logging/logging.dart';
import 'config.dart';
import 'utils.dart';

// =============================================================================
// cmdPublish
/// performs publish command
/// [ctx] is zaart context map
bool cmdPublish(Map ctx) {
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

  var cmd = ctx["cmd-publish"];

  if (cmd.isEmpty) {
    print("oh no, i faced an internal error!");
    Logger.root.severe(
        '"cmd-publish" is missing from context in cmdPublish() function');
    return false;
  }

  var page = cmd["page"];
  var section = cmd["section"];
  var configFileName = ctx["config"];

  if (null == page) {
    print("oh no, i faced an internal error!");
    Logger.root.severe(
        '"page" key is missing from "cmd-publish" map in cmdPublish() function');
    return false;
  }

  if (null == section) {
    print("oh no, i faced an internal error!");
    Logger.root.severe(
        '"section" key is missing from "cmd-publish" map in cmdPublish() function');
    return false;
  }

  if (null == configFileName) {
    print("oh no, i faced an internal error!");
    Logger.root.severe(
        '"config" key is missing from "cmd-publish" map in cmdPublish() function');
    return false;
  }

  Config config = readConfig(configFileName);
  config.sections
      .firstWhere((s) => s.name == section)
      .children
      .firstWhere((c) => c.name == page)
      .published = true;

  return writeConfig(config.toJson(), configFileName);
}
