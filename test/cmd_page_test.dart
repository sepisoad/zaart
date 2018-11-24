import 'package:test/test.dart';
import 'package:zaart/cmd_init.dart';
import 'package:zaart/cmd_section.dart';
import 'package:zaart/cmd_page.dart';
import 'package:zaart/defaults.dart';
import 'package:zaart/utils.dart';
import 'utils.dart';

// =============================================================================
// cmd page tests
main() {
  group("cmd-page-tests", () {
    test("test cmdPage() with null", () {
      var res = cmdPage(null);
      expect(res, false);
    });

    test("test cmdPage() with empty map", () {
      var res = cmdPage(Map());
      expect(res, false);
    });

    test("test cmdPage() with missing config key", () {
      var ctx = Map<String, dynamic>();
      ctx['a'] = 'a';
      var res = cmdPage(ctx);
      expect(res, false);
    });

    test("test cmdPage() without 'fun'", () {
      var context = Map();
      context["name"] = "test-gen-site";
      context["config"] = ZAART_CONFIG;
      context["cmd-page"] = Map();
      context["cmd-page"]["page"] = "lol";

      deleteSite();
      cmdInit(context);
      bool res = cmdPage(context);
      deleteSite();
      expect(res, false);
    });

    test("test cmdPage() without 'page'", () {
      var context = Map();
      context["name"] = "test-gen-site";
      context["config"] = ZAART_CONFIG;
      context["cmd-page"] = Map();
      context["cmd-page"]["fun"] = "add";

      deleteSite();
      cmdInit(context);
      bool res = cmdPage(context);
      deleteSite();
      expect(res, false);
    });

    test("test cmdPage() without 'section'", () {
      var context = Map();
      context["name"] = "test-gen-site";
      context["config"] = ZAART_CONFIG;
      context["cmd-page"] = Map();
      context["cmd-page"]["fun"] = "add";
      context["cmd-page"]["page"] = "a";

      deleteSite();
      cmdInit(context);
      bool res = cmdPage(context);
      deleteSite();
      expect(res, false);
    });

    test("test cmdPage() as normal", () {
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

      context["cmd-page"]["fun"] = "del";
      res = cmdPage(context);
      expect(res, true);
      cfg = readConfig(context["config"]);
      expect(cfg.sections.length, 1);
      expect(cfg.sections[0].children.length, 0);

      context["cmd-section"]["fun"] = "del";
      res = cmdSection(context);
      expect(res, true);

      deleteSite();
    });
  });
}
