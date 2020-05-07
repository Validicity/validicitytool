import 'package:args/command_runner.dart';
import 'package:validicitytool/commands.dart';
import 'package:validicitytool/validicitytool.dart';

/// Print version and exit
printVersion(v) {
  if (v) {
    print('0.1.0');
    exit(0);
  }
}

main(List<String> arguments) async {
  var runner = CommandRunner(
      "validicitytool", "Administration tool for Validicity.")
    ..argParser.addOption("config",
        abbr: "c",
        defaultsTo: "validicitytool.yaml",
        valueHelp: "config file name",
        callback: (fn) => configFile = fn)
    /*..addCommand(CustomerCommand())
        ..addCommand(ProjectCommand())
        ..addCommand(SampleCommand())
        ..addCommand(UserCommand())*/
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
