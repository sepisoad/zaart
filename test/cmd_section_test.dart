import 'package:test/test.dart';
import 'package:zaart/cmd_init.dart';
import 'package:zaart/cmd_section.dart';
import 'package:zaart/default.dart';
import 'package:zaart/utils.dart';
import 'utils.dart';

// =============================================================================
// cmd section tests
main() {
  group("cmd-section-tests", () {
    test("test cmdSection() with null", () {
      var res = cmdSection(null);
      expect(res, false);
    });

    test("test cmdSection() with empty map", () {
      var res = cmdSection(Map());
      expect(res, false);
    });

    test("test cmdSection() with missing config key", () {
      var ctx = Map<String, dynamic>();
      ctx['a'] = 'a';
      var res = cmdSection(ctx);
      expect(res, false);
    });

    test("test cmdSection() without 'fun'", () {
      var context = Map();
      context["name"] = "test-gen-site";
      context["config"] = ZAART_CONFIG;
      context["cmd-section"] = Map();
      context["cmd-section"]["arg"] = "lol";

      deleteSite();
      cmdInit(context);
      bool res = cmdSection(context);
      deleteSite();
      expect(res, false);
    });

    test("test cmdSection() without 'arg'", () {
      var context = Map();
      context["name"] = "test-gen-site";
      context["config"] = ZAART_CONFIG;
      context["cmd-section"] = Map();
      context["cmd-section"]["fun"] = "add";

      deleteSite();
      cmdInit(context);
      bool res = cmdSection(context);
      deleteSite();
      expect(res, false);
    });

    test("test cmdSection() as normal", () {
      var context = Map();
      context["name"] = "test-gen-site";
      context["config"] = ZAART_CONFIG;
      context["cmd-section"] = Map();
      context["cmd-section"]["fun"] = "add";
      context["cmd-section"]["arg"] = "lol";

      deleteSite();
      cmdInit(context);
      bool res = cmdSection(context);
      expect(res, true);

      var cnf = readConfig(ZAART_CONFIG);
      expect(cnf.sections.length, 1);
      expect(cnf.sections[0].name, 'lol');

      context["cmd-section"]["fun"] = "del";
      res = cmdSection(context);
      expect(res, true);
      cnf = readConfig(ZAART_CONFIG);
      expect(cnf.sections.length, 0);

      deleteSite();
    });
  });
}
