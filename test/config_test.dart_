import 'package:test/test.dart';
import 'package:zaart/utils.dart';
import 'package:zaart/defaults.dart';
import 'utils.dart';

// =============================================================================
// config tests
main() {
  test("test writeConfig() as noraml", () {
    var path = ZAART_CONFIG;
    deleteSite();
    var wcfg = getSampleConfigObject1();
    var jsCfg = wcfg.toJson();
    var res = writeConfig(jsCfg, path);
    expect(res, true);
    var rcfg = readConfig(path);
    expect(rcfg != null, true);
    expect(wcfg.name == rcfg.name, true);
    expect(wcfg.author == rcfg.author, true);
    expect(wcfg.sections.length == rcfg.sections.length, true);
    expect(wcfg.sections[0].name == rcfg.sections[0].name, true);
    expect(wcfg.sections[0].children.length == rcfg.sections[0].children.length,
        true);
    expect(
        wcfg.sections[0].children[0].name == rcfg.sections[0].children[0].name,
        true);
    expect(
        wcfg.sections[0].children[0].author ==
            rcfg.sections[0].children[0].author,
        true);
    expect(
        wcfg.sections[0].children[0].date == rcfg.sections[0].children[0].date,
        true);
    expect(
        wcfg.sections[0].children[0].published ==
            rcfg.sections[0].children[0].published,
        true);
    expect(
        wcfg.sections[0].children[0].tags.length ==
            rcfg.sections[0].children[0].tags.length,
        true);
    expect(
        wcfg.sections[0].children[0].tags[0] ==
            rcfg.sections[0].children[0].tags[0],
        true);
  });
  deleteSite();
}
