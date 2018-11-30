import 'dart:io';
import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'defaults.dart';
import 'cmd_init.dart';
import 'cmd_page.dart';
import 'cmd_build.dart';

const _version = "0.0.14";

// =============================================================================
// zaart
/// entry point for zaart command line application.
/// this function parses [args]. args are passed into this tool from
/// command prompt
void zaart(List<String> args) async {
  _setupLogger();

  var context = Map();
  context["name"] = DEFAULT_TITLE;
  context["config"] = ZAART_CONFIG_FILE;
  context["cmd-init"] = Map();
  context["cmd-page"] = Map();
  context["cmd-publish"] = Map();
  context["cmd-unpublish"] = Map();
  context["cmd-build"] = Map();

  var argParser = ArgParser();
  _defInitCmd(argParser, context);
  _defPageCmd(argParser, context);
  _defBuildCmd(argParser, context);

  argParser.addFlag("help", abbr: "h", defaultsTo: false, callback: _printHelp);
  argParser.addFlag("version",
      abbr: "v", defaultsTo: false, callback: _printVersion);

  ArgResults res;

  try {
    res = argParser.parse(args);
  } catch (err) {
    Logger.root.severe(err);
    print("i do not understand what you mean!");
    print("use help command for more HELP!");
    print(err);
    return;
  }

  if (res.command == null) {
    print("what do you want me to do for you?");
    if (res.arguments.length > 0) {
      print("command '${res.arguments[0]}' is not known!");
    }
    return;
  }

  switch (res.command.name) {
    case "init":
      cmdInit(context);
      break;
    case "page":
      cmdPage(context);
      break;
    case "build":
      cmdBuild(context);
      break;
    default:
      print("oops, '${res.command.name}' is not a valid command");
      break;
  }
}

// =============================================================================
// _setupLogger
void _setupLogger() {
  var logFile = File(LOG_FILE_NAME);
  try {
    logFile.createSync(recursive: false);
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      logFile.writeAsString('${rec.time} ${rec.level} ${rec.message}');
    });
  } catch (err) {
    print("oops, for some reason i cannot open log file");
    print("that's whay i will print log messages here in console");
    print("don't worry i'll try no to be too verbose ;)");
    print("i hope you don't mind");

    Logger.root.level = Level.WARNING;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.time} ${rec.level} ${rec.message}');
    });
  }
}

// =============================================================================
// _printVersion
void _printHelp(bool val) async {
  if (!val) return;
  print("usage: zaart [command] (options: value) (flags)\n"
      "commands:\n"
      "✔ init => is used to initialize a new site\n"
      "  ↳ --title: [TITLE] => is used to set site titel, defaults to"
      "'$DEFAULT_TITLE'\n"
      "  ↳ -t: [TITLE] => short form of --titel"
      "  ↳ --author: [AUTHOR] => is used to set site author, defaults to"
      "'$DEFAULT_AUTHOR'\n"
      "  ↳ -a: [AUTHOR] => short form of --author\n\n"
      "  ↳ --layout: [LAYOUT] => is used to set site layout, defaults to"
      "'$ZAART_LANDING_LAYOUT_FILE'\n"
      "  ↳ -l: [LAYOUT] => short form of --layout\n\n"
      "  examples:\n"
      "    ‣ zaart init -t 'my sample site' -a 'daron malakian' -l 'my.layout'\n"
      "\n"
      "✔ page => is used to manages pages\n"
      "  ↳ add: is used to add a new page\n"
      "  ↳ del: is used to delete an existing page\n"
      "  ↳ --name: [NAME] => is used to set page name\n"
      "  ↳ -n: [NAME] => short form of --name\n"
      "  ↳ --layout: [NAME] => is used to set the page layout\n"
      "  ↳ -l: [NAME] => short form of --layout\n\n"
      "  examples:\n"
      "    ‣ zaart page add -n blog\n"
      "    ‣ zaart page add -n blog/post1 \n"
      "    ‣ zaart page del -n blog/post1\n"
      "    ‣ zaart page del -n blog\n"
      "\n"
      "✔ build => is used to build site with files marked as published\n"
      "  examples:\n"
      "    ‣ zaart build\n"
      "\n");

  exit(0);
}

// =============================================================================
// _printVersion
_printVersion(bool val) {
  if (!val) return;
  print("zaart! version: $_version");
  exit(0);
}

// =============================================================================
// _defInitCmd
void _defInitCmd(ArgParser root, Map ctx) {
  var cmd = root.addCommand("init");
  cmd.addOption("title",
      abbr: "t",
      defaultsTo: DEFAULT_TITLE,
      help: "set site title,"
          "otherwise '$DEFAULT_TITLE' is used", callback: (val) async {
    ctx["title"] = val;
  });
  cmd.addOption("author",
      abbr: "a",
      defaultsTo: DEFAULT_AUTHOR,
      help: "sets site's author name,"
          "otherwise '$DEFAULT_AUTHOR' is used", callback: (val) async {
    ctx["author"] = val;
  });
  cmd.addOption("layout",
      abbr: "l",
      defaultsTo: ZAART_LANDING_LAYOUT_FILE,
      help: "sets site's author name,"
          "otherwise '$ZAART_LANDING_LAYOUT_FILE' is used",
      callback: (val) async {
    ctx["layout"] = val;
  });
}

// =============================================================================
// _defPageCmd
void _defPageCmd(ArgParser root, Map ctx) {
  var cmd = root.addCommand("page");
  var add = cmd.addCommand("add");
  var del = cmd.addCommand("del");

  add.addOption("name", abbr: "n", defaultsTo: null, callback: (val) async {
    ctx["cmd-page"]["fun"] = "add";
    ctx["cmd-page"]["name"] = val;
  });

  add.addOption("layout", abbr: "l", defaultsTo: ZAART_SINGLE_LAYOUT_FILE,
      callback: (val) async {
    ctx["cmd-page"]["fun"] = "add";
    ctx["cmd-page"]["layout"] = val;
  });

  del.addOption("name", abbr: "n", defaultsTo: null, callback: (val) async {
    ctx["cmd-page"]["fun"] = "del";
    ctx["cmd-page"]["name"] = val;
  });
}

// =============================================================================
// _defBuildCmd
void _defBuildCmd(ArgParser root, Map ctx) {
  var cmd = ArgParser();
  root.addCommand("build", cmd);
  cmd.addFlag("force", abbr: "f", defaultsTo: false, help: "builds site",
      callback: (val) async {
    ctx["cmd-build"]["force"] = val;
  });
}
