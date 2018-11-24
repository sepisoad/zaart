import 'dart:io';
import 'package:logging/logging.dart';
import 'package:markdown/markdown.dart';
import 'package:mustache/mustache.dart';
import 'defaults.dart';
import 'utils.dart';

// TODO:
// i am not happy with build command logic
// this module needs to be refactored

// =============================================================================
// cmdBuild
bool cmdBuild(Map ctx) {
  bool _isInitialized;
  try {
    _isInitialized = isInitialized(ctx);
  } catch (err) {
    Logger.root.severe(err.toString());
    return false;
  }

  if (!_isInitialized) {
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
  cfg.sections.forEach((s) => s.children.forEach((c) {
        if (c.published) {
          srcPages.add(s.name + '/' + c.name.replaceAll(".md", ""));
        }
      }));

  var dstPages = <String>[];
  // TODO: enhance this fucking hack
  Directory(BUILD_DIR)
      .listSync(followLinks: false, recursive: false)
      .forEach((ent) {
    if (ent is Directory) {
      var dirName = ent.uri.toString().replaceAll("build/", "");
      if (dirName == LAYOUT_DIR + "/") return;
      Directory(ent.uri.toString())
          .listSync(followLinks: false, recursive: false)
          .forEach((s) {
        if (s is File) {
          var fileName = s.uri.toString();
          if (fileName.contains(".html")) {
            var pageName =
                fileName.replaceAll("build/", "").replaceAll(".html", "");
            dstPages.add(pageName);
          }
        }
      });
    }

    if (ent is File) {
      var fileName = ent.uri.toString();
      if (fileName.contains(".html")) {
        var pageName =
            fileName.replaceAll("build/", "").replaceAll(".html", "");
        dstPages.add(pageName);
      }
    }
  });

  var isSync = dstPages.every((dst) => srcPages.any((src) => src == dst));
  if (isSync) {
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

  buildList.add("index");

  buildList.forEach((page) {
    var srcFile = File(page + ".md");
    var dstFile = File(BUILD_DIR + "/" + page + ".html");

    try {
      dstFile.createSync(recursive: true);
      var srcMarkdownData = srcFile.readAsStringSync();
      var dstHtmlData =
          markdownToHtml(srcMarkdownData, extensionSet: ExtensionSet.gitHubWeb);
      var html = DEFAULT_HTML;
      var layoutPath = ((String path) {
        var basePath = "";
        var arr = path.split("/");
        var count = arr.length - 1;

        if (count <= 0) {
          return basePath;
        }
        for (var i = 0; i < count; i++) {
          basePath = "../" + basePath;
        }

        return basePath;
      })(srcFile.uri.toString());
      html = html.replaceFirst(RegExp(r'--TITLE--'), cfg.name);
      html = html.replaceFirst(RegExp(r'--BODY--'), dstHtmlData);
      html = html.replaceFirst(RegExp(r'--CSS--'), layoutPath);
      html = html.replaceFirst(RegExp(r'--JS--'), layoutPath);
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
