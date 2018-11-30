import 'package:test/test.dart';
import 'package:zaart/cmd_init.dart';
import 'package:zaart/cmd_section.dart';
import 'package:zaart/cmd_page.dart';
import 'package:zaart/cmd_unpublish.dart';
import 'package:zaart/defaults.dart';
import 'package:zaart/utils.dart';
import 'utils.dart';

// =============================================================================
// cmd unpublish tests
main() {
  group("cmd-unpublish-tests", () {
    test("test cmdUnpublish() with null", () {
      var res = cmdUnpublish(null);
      expect(res, false);
    });

    test("test cmdUnpublish() with empty map", () {
      var res = cmdUnpublish(Map());
      expect(res, false);
    });

    test("test cmdUnpublish() with missing config key", () {
      var ctx = Map<String, dynamic>();
      ctx['a'] = 'a';
      var res = cmdUnpublish(ctx);
      expect(res, false);
    });

    test("test cmdUnpublish() as normal", () {
      var context = Map();
      context["name"] = "test-gen-site";
      context["config"] = ZAART_CONFIG;
      context["cmd-section"] = Map();
      context["cmd-section"]["fun"] = "add";
      context["cmd-section"]["arg"] = "_test_";
      context["cmd-page"] = Map();
      context["cmd-page"]["fun"] = "add";
      context["cmd-page"]["section"] = "_test_";
      context["cmd-page"]["name"] = "a";
      context["cmd-unpublish"] = Map();
      context["cmd-unpublish"]["page"] = "a";
      context["cmd-unpublish"]["section"] = "_test_";

      deleteSite();
      cmdInit(context);
      bool res = cmdSection(context);
      expect(res, true);

      res = cmdPage(context);
      expect(res, true);
      var cfg = readConfig(context["config"]);
      expect(cfg.sections.length, 1);
      expect(cfg.sections[0].children.length, 1);
      expect(cfg.sections[0].children[0].name, context["cmd-page"]["name"]);

      res = cmdUnpublish(context);
      expect(res, true);
      cfg = readConfig(context["config"]);
      expect(cfg.sections[0].children[0].published, false);

      context["cmd-section"]["fun"] = "del";
      res = cmdSection(context);
      expect(res, true);

      deleteSite();
    });
  });
}
