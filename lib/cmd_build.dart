import 'dart:io';
import 'package:logging/logging.dart';
import 'package:markdown/markdown.dart';
import 'package:mustache/mustache.dart';
import 'defaults.dart';
import 'utils.dart';

// =============================================================================
// cmdBuild
/// performs build command
/// [ctx] is zaart context map
bool cmdBuild(Map ctx) {
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

  var isForced = ctx["cmd-build"]["force"];

  var buildDir = Directory(BUILD_DIR);
  if (!buildDir.existsSync()) {
    try {
      buildDir.createSync(recursive: false);
    } catch (err) {
      print("oh no, i faced an internal error!");
      Logger.root.severe('failed to create build directory');
      Logger.root.severe(err);
      return false;
    }
  }

  var cfg = readConfig(ctx["config"]);

  var srcPages = <String>[];
  srcPages.add(INDEX_NAME);
  cfg.sections.forEach((s) => srcPages.add(s.name + "/index"));
  cfg.sections.forEach((s) => s.children.forEach((c) {
        if (c.published) {
          srcPages.add(s.name + '/' + c.name.replaceAll(".md", ""));
        }
      }));

  var dstPages = <String>[];

  Directory(BUILD_DIR).listSync(recursive: true).forEach((e) {
    if (e is Directory) return;
    if (e.uri.toString().startsWith(BUILD_DIR + "/" + LAYOUT_DIR)) return;
    dstPages.add(e.uri
        .toString()
        .replaceFirst(BUILD_DIR + "/", "")
        .replaceFirst(".html", ""));
  });

  var isSync = dstPages.every((dst) => srcPages.any((src) => src == dst));
  if (!isSync) {
    print("oops, seems that you have some out of sync pages");
    print(
      "that means that you have sections or pages in your build directory"
          " that are not part of your config file",
    );
    Logger.root.warning("found some out of sync pages");
  }

  var buildList = <String>[];
  if (isForced) {
    srcPages.forEach((page) => buildList.add(page));
  } else {
    srcPages.removeWhere((src) => dstPages.any((dst) => src == dst));
    srcPages.forEach((page) => buildList.add(page));
  }

  var includes = ZAART_LAYOUT_INCLUDES.expand((i) => [i]).toList();
  var cssIncludes = <String>[];
  var jsIncludes = <String>[];

  var layoutDir = Directory(LAYOUT_DIR);
  try {
    var list = layoutDir.listSync(recursive: false, followLinks: false);
    list.forEach((f) {
      includes.add(f.uri.toString());
    });
  } catch (err) {
    //WTF: warning log
    print(err);
  }

  includes.forEach((item) {
    if (item.endsWith(".js")) {
      jsIncludes.add(item);
    } else if (item.endsWith(".css")) {
      cssIncludes.add(item);
    }
  });

  buildList.forEach((page) {
    var srcFile = File(page + ".md");
    var dstFile = File(BUILD_DIR + "/" + page + ".html");

    try {
      dstFile.createSync(recursive: true);
      var srcMarkdownData = srcFile.readAsStringSync();
      var dstHtmlData =
          markdownToHtml(srcMarkdownData, extensionSet: ExtensionSet.gitHubWeb);
      var html = INDEX_HTML_CONTENT;
      var fixLayoutPath = (String page, String layout) {
        var res = layout;
        var depth = page.split("/").length - 1;
        for (var count = 0; count < depth; count++) {
          res = "../" + res;
        }

        return res;
      };

      html = html.replaceFirst(RegExp(r'--TITLE--'), cfg.name);
      html = html.replaceFirst(RegExp(r'--BODY--'), dstHtmlData);
      var cssIncludesStr = "";
      var jsIncludesStr = "";

      cssIncludes.forEach((css) {
        if (css.startsWith("http://") || css.startsWith("https://")) {
          cssIncludesStr += '<link href="$css" rel="stylesheet">';
        } else {
          cssIncludesStr +=
              '<link href="${fixLayoutPath(page, css)}" rel="stylesheet">';
        }
      });

      jsIncludes.forEach((js) {
        if (js.startsWith("http://") || js.startsWith("https://")) {
          jsIncludesStr += '<script src="$js"></script>';
        } else {
          jsIncludesStr += '<script src="${fixLayoutPath(page, js)}"></script>';
        }
      });

      html = html.replaceFirst(RegExp(r'--CSS--'), cssIncludesStr);
      html = html.replaceFirst(RegExp(r'--JS--'), jsIncludesStr);
      dstFile.writeAsStringSync(html);
    } catch (err) {
      print("oops, failed to build page '${dstFile.uri.toString()}'");
      Logger.root.warning("failed to build page '${dstFile.uri.toString()}'");
      Logger.root.warning(err.toString());
      return;
    }
  });

  var srcLayoutDir = Directory(LAYOUT_DIR);
  if (!srcLayoutDir.existsSync()) {
    print("oops, layout directory is missing from site root");
    print("i can still build the site for you however the resulting"
        "site will looks ugly!");
    return true;
  }

  var dstLayoutPath = BUILD_DIR + "/" + LAYOUT_DIR;
  var dstLayoutDir = Directory(dstLayoutPath);
  try {
    dstLayoutDir.createSync(recursive: false);
    var files = srcLayoutDir.listSync();
    files.forEach((file) {
      var dstFileName = BUILD_DIR + "/" + file.uri.toString();
      var dstFile = File(dstFileName);
      var srcFile = File(file.uri.toString());
      dstFile.writeAsStringSync(srcFile.readAsStringSync());
    });
  } catch (err) {
    print("oops, I failed to copy layout folder into build directory");
    print("please report this issue <3");
    return true;
  }

  // passing through mustache engine
  buildList.forEach((val) {
    var htmlFile = File(BUILD_DIR + "/" + val + ".html");
    var unprocessedHtml = htmlFile.readAsStringSync();
    var tmpl = Template(unprocessedHtml);
    var finalHtml = tmpl.renderString(cfg);
    htmlFile.deleteSync();
    htmlFile.createSync();
    htmlFile.writeAsStringSync(finalHtml);
  });

  return true;
}
