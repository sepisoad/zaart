import 'package:test/test.dart';
import 'package:zaart/cmd-init.dart';
import 'package:zaart/cmd-section.dart';
import 'package:zaart/cmd-page.dart';
import 'package:zaart/cmd-publish.dart';
import 'package:zaart/cmd-build.dart';
import 'package:zaart/default.dart';
import 'utils.dart';

// =============================================================================
// cmd build tests
main() {
  group("cmd-build-tests", () {
    test("test cmdBuild() as normal", () {
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
      context["cmd-build"] = Map();
      context["cmd-build"]["force"] = false;

      deleteSite();
      var res = cmdInit(context);
      res = cmdSection(context);
      expect(res, true);
      res = cmdPage(context);
      expect(res, true);
      res = cmdPublish(context);
      expect(res, true);
      res = cmdBuild(context);
      expect(res, true);

      context["cmd-section"]["fun"] = "del";
      res = cmdSection(context);
      expect(res, true);

      deleteSite();
    });
  });
}
