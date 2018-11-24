import 'package:test/test.dart';
import 'package:zaart/cmd_init.dart';
import 'package:zaart/cmd_section.dart';
import 'package:zaart/cmd_page.dart';
import 'package:zaart/cmd_publish.dart';
import 'package:zaart/default.dart';
import 'package:zaart/utils.dart';
import 'utils.dart';

// =============================================================================
// cmd publish tests
main() {
  group("cmd-publish-tests", () {
    test("test cmdPublish() with null", () {
      var res = cmdPublish(null);
      expect(res, false);
    });

    test("test cmdPublish() with empty map", () {
      var res = cmdPublish(Map());
      expect(res, false);
    });

    test("test cmdPublish() with missing config key", () {
      var ctx = Map<String, dynamic>();
      ctx['a'] = 'a';
      var res = cmdPublish(ctx);
      expect(res, false);
    });

    test("test cmdPublish() as normal", () {
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
      context["cmd-publish"] = Map();
      context["cmd-publish"]["page"] = "a";
      context["cmd-publish"]["section"] = "_test_";

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

      res = cmdPublish(context);
      expect(res, true);
      cfg = readConfig(context["config"]);
      expect(cfg.sections[0].children[0].published, true);

      context["cmd-section"]["fun"] = "del";
      res = cmdSection(context);
      expect(res, true);

      deleteSite();
    });
  });
}
