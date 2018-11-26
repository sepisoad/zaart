import 'dart:io';
import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'defaults.dart';
import 'cmd_init.dart';
import 'cmd_section.dart';
import 'cmd_page.dart';
import 'cmd_build.dart';

// =============================================================================
// zaart
/// entry point for zaart command line application.
/// this function parses [args]. args are passed into this tool from
/// command prompt
zaart(List<String> args) async {
  _setupLogger();

  var context = Map();
  context["name"] = DEFAULT_NAME;
  context["config"] = ZAART_CONFIG;
  context["cmd-init"] = Map();
  context["cmd-section"] = Map();
  context["cmd-page"] = Map();
  context["cmd-publish"] = Map();
  context["cmd-unpublish"] = Map();
  context["cmd-build"] = Map();

  var argParser = ArgParser();
  _defInitCmd(argParser, context);
  _defSectionCmd(argParser, context);
  _defPageCmd(argParser, context);
  _defPublishCmd(argParser, context);
  _defUnpublishCmd(argParser, context);
  _defBuildCmd(argParser, context);

  argParser.addFlag("help", abbr: "h", defaultsTo: false, callback: _printHelp);

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
    case "section":
      cmdSection(context);
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
_setupLogger() {
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

void _printHelp(bool val) async {
  if (!val) return;
  print("usage: zaart [command] (options: value) (flags)\n"
      "commands:\n"
      "✔ init => is used to initialize a new site\n"
      "  ↳ --name: [NAME] => is used to set site name, defaults to"
      "'$DEFAULT_NAME'\n"
      "  ↳ -n: [NAME] => short form of --name\n\n"
      "  examples:\n"
      "    ‣ zaart init -n 'my sample site'\n"
      "\n"
      "✔ section => is used to manages sections\n"
      "  ↳ add: is used to add a new section\n"
      "  ↳ del: is used to delete an existing section\n"
      "  ↳ --name: [NAME] => is used to set section name\n"
      "  ↳ -n: [NAME] => short form of --name\n\n"
      "  examples:\n"
      "    ‣ zaart section add -n blog\n"
      "    ‣ zaart section del -n blog\n"
      "\n"
      "✔ page => is used to manages pages\n"
      "  ↳ add: is used to add a new page\n"
      "  ↳ del: is used to delete an existing page\n"
      "  ↳ --name: [NAME] => is used to set page name\n"
      "  ↳ -n: [NAME] => short form of --name\n"
      "  ↳ --section: [NAME] => is used to set the page parent section\n"
      "  ↳ -s: [NAME] => short form of --section\n\n"
      "  examples:\n"
      "    ‣ zaart page add -n post1 -s blog\n"
      "    ‣ zaart page del -n post1 -s blog\n"
      "\n"
      "✔ publish => is used to mark a page for being pulished\n"
      "  ↳ --name: [NAME] => is used to set page name\n"
      "  ↳ -n: [NAME] => short form of --name\n"
      "  ↳ --section: [NAME] => is used to set the page parent section\n"
      "  ↳ -s: [NAME] => short form of --section\n\n"
      "  examples:\n"
      "    ‣ zaart publish -n post1 -s blog\n"
      "\n"
      "✔ unpublish => is used to mark a page for not being pulished\n"
      "  ↳ --name: [NAME] => is used to set page name\n"
      "  ↳ -n: [NAME] => short form of --name\n"
      "  ↳ --section: [NAME] => is used to set the page parent section\n"
      "  ↳ -s: [NAME] => short form of --section\n\n"
      "  examples:\n"
      "    ‣ zaart unpublish -n post1 -s blog\n"
      "\n"
      "✔ build => is used to build site with files marked as published\n"
      "  ↳ --force => is used to force a rebuild\n"
      "  ↳ -f => short form of --force\n\n"
      "  examples:\n"
      "    ‣ zaart build\n"
      "    ‣ zaart build -f\n"
      "\n");

  exit(0);
}

// =============================================================================
// _defInitCmd
_defInitCmd(ArgParser root, Map ctx) {
  var cmd = root.addCommand("init");
  cmd.addOption("name",
      abbr: "n",
      defaultsTo: DEFAULT_NAME,
      help: "use this option set the name of site,"
          "otherwise '$DEFAULT_NAME' is used",
      valueHelp: '"my sample site"', callback: (val) async {
    ctx["name"] = val;
  });
}

// =============================================================================
// _defSectionCmd
_defSectionCmd(ArgParser root, Map ctx) {
  var cmd = root.addCommand("section");
  var add = cmd.addCommand("add");
  var del = cmd.addCommand("del");

  add.addOption("name", abbr: "n", defaultsTo: null, callback: (val) async {
    ctx["cmd-section"]["fun"] = "add";
    ctx["cmd-section"]["arg"] = val;
  });

  del.addOption("name", abbr: "n", defaultsTo: null, callback: (val) async {
    ctx["cmd-section"]["fun"] = "del";
    ctx["cmd-section"]["arg"] = val;
  });
}

// =============================================================================
// _defPageCmd
_defPageCmd(ArgParser root, Map ctx) {
  var cmd = root.addCommand("page");
  var add = cmd.addCommand("add");
  var del = cmd.addCommand("del");

  add.addOption("name", abbr: "n", defaultsTo: null, callback: (val) async {
    ctx["cmd-page"]["fun"] = "add";
    ctx["cmd-page"]["name"] = val;
  });

  add.addOption("section", abbr: "s", defaultsTo: null, callback: (val) async {
    ctx["cmd-page"]["fun"] = "add";
    ctx["cmd-page"]["section"] = val;
  });

  del.addOption("name", abbr: "n", defaultsTo: null, callback: (val) async {
    ctx["cmd-page"]["fun"] = "del";
    ctx["cmd-page"]["name"] = val;
  });

  del.addOption("section", abbr: "s", defaultsTo: null, callback: (val) async {
    ctx["cmd-page"]["fun"] = "del";
    ctx["cmd-page"]["section"] = val;
  });
}

// =============================================================================
// _defPublishCmd
_defPublishCmd(ArgParser root, Map ctx) {
  var cmd = root.addCommand("publish");

  cmd.addOption("page", abbr: "p", defaultsTo: null, callback: (val) async {
    ctx["cmd-publish"]["page"] = val;
  });

  cmd.addOption("section", abbr: "s", defaultsTo: null, callback: (val) async {
    ctx["cmd-publish"]["section"] = val;
  });
}

// =============================================================================
// _defUnpublishCmd
_defUnpublishCmd(ArgParser root, Map ctx) {
  var cmd = root.addCommand("unpublish");

  cmd.addOption("page", abbr: "p", defaultsTo: null, callback: (val) async {
    ctx["cmd-unpublish"]["page"] = val;
  });

  cmd.addOption("section", abbr: "s", defaultsTo: null, callback: (val) async {
    ctx["cmd-unpublish"]["section"] = val;
  });
}

// =============================================================================
// _defBuildCmd
_defBuildCmd(ArgParser root, Map ctx) {
  var cmd = ArgParser();
  root.addCommand("build", cmd);
  cmd.addFlag("force", abbr: "f", defaultsTo: false, help: "builds site",
      callback: (val) async {
    ctx["cmd-build"]["force"] = val;
  });
}
