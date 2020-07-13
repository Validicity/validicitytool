import 'package:args/command_runner.dart';
import 'package:validicitytool/commands.dart';
import 'package:validicitytool/validicitytool.dart';
import 'package:validicitytool/pubspec.dart';

/// Print version and exit
printVersion(v) {
  if (v) {
    print(Pubspec.version);
    exit(0);
  }
}

main(List<String> arguments) async {
  var runner =
      CommandRunner("validicitytool", "Administration tool for Validicity.")
        ..argParser.addOption("config",
            abbr: "c",
            defaultsTo: "validicitytool.yaml",
            valueHelp: "config file name",
            callback: (fn) => configFile = fn)
        ..addCommand(OrganisationCommand())
        ..addCommand(UserCommand())
        ..addCommand(ProjectCommand())
        ..addCommand(SampleCommand())
        ..addCommand(BootstrapCommand())
        ..addCommand(StatusCommand())
        ..argParser.addFlag('version',
            negatable: false,
            help: 'Show version of validicitytool',
            callback: printVersion)
        ..argParser.addFlag('verbose',
            help: 'Show more information when executing commands',
            abbr: 'v',
            defaultsTo: null)
        ..argParser.addFlag('pretty',
            help: 'Pretty print JSON in results', abbr: 'p', defaultsTo: null);
  await runner.run(arguments);
  exit(0);
}
