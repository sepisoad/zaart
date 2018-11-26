import 'package:logging/logging.dart';
import 'config.dart';
import 'utils.dart';

// =============================================================================
// cmdUnpublish
/// performs unpublish command
/// [ctx] is zaart context map
bool cmdUnpublish(Map ctx) {
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

  var cmd = ctx["cmd-unpublish"];

  if (cmd.isEmpty) {
    print("oh no, i faced an internal error!");
    Logger.root.severe(
        '"cmd-unpublish" is missing from context in cmdUnpublish() function');
    return false;
  }

  var page = cmd["page"];
  var section = cmd["section"];
  var configFileName = ctx["config"];

  if (null == page) {
    print("oh no, i faced an internal error!");
    Logger.root.severe(
        '"page" key is missing from "cmd-unpublish" map in cmdUnpublish() function');
    return false;
  }

  if (null == section) {
    print("oh no, i faced an internal error!");
    Logger.root.severe(
        '"section" key is missing from "cmd-unpublish" map in cmdUnpublish() function');
    return false;
  }

  if (null == configFileName) {
    print("oh no, i faced an internal error!");
    Logger.root.severe(
        '"config" key is missing from "cmd-unpublish" map in cmdUnpublish() function');
    return false;
  }

  Config config = readConfig(configFileName);
  config.sections
      .firstWhere((s) => s.name == section)
      .children
      .firstWhere((c) => c.name == page)
      .published = false;

  return writeConfig(config.toJson(), configFileName);
}
