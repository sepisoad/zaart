import 'package:test/test.dart';
import 'package:zaart/cmd-init.dart';
import 'package:zaart/default.dart';
import 'utils.dart';

// =============================================================================
// cmd init tests
main() {
  test("test cmdInit() with null", () {
    bool res = cmdInit(null);
    expect(res, false);
  });

  test("test cmdInit() with empty map", () {
    bool res = cmdInit(Map());
    expect(res, false);
  });

  test("test cmdInit() with empty map", () {
    var context = Map();
    context["shit"] = "shit";

    bool res = cmdInit(context);
    expect(res, false);
  });

  test("test cmdInit() with default values", () {
    var context = Map();
    context["name"] = "test-gen-site";
    context["config"] = ZAART_CONFIG;

    deleteSite();
    bool res = cmdInit(context);
    deleteSite();
    expect(res, true);
  });
}
