import 'dart:async';

import 'package:args/command_runner.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:validicitylib/api.dart';
import 'package:validicitylib/model/key.dart';
import 'package:validicitylib/config.dart';
import 'package:validicitylib/rest.dart';
import 'package:path/path.dart' as path;
import 'package:validicitytool/generic_command.dart';
import 'validicitytool.dart';

abstract class BaseCommand extends Command implements CredentialsHolder {
  RestClient client;
  ValidicityServerAPI api;
  Map<String, dynamic> result;
  File _credentialsFile;

  int intArg(String name) {
    return int.tryParse(argResults[name]);
  }

  File get credentialsFile {
    if (_credentialsFile != null) {
      return _credentialsFile;
    } else {
      var home = Platform.environment['HOME'];
      var p = path.join(home, "oauth2-credentials.json");
      return File(p);
    }
  }

  // We try to request all scopes
  List<String> scopes = ['admin', 'client', 'user', 'superuser'];

  void run() async {
    configureValidicity(globalResults);
    var url = Uri.parse(config.api.url);
    api = ValidicityServerAPI(config.api.clientID, holder: this);
    api
      ..username = config.api.username
      ..password = config.api.password
      ..scopes = scopes
      ..server = url.host
      ..responseHandler = handleResponse;
    try {
      await exec();
    } catch (e) {
      print(e);
      exit(1);
    }
    handleResult(result);
    exit(0);
  }

  void handleResult(Map result) {
    if (result != null) {
      if (config.pretty) {
        try {
          print(JsonEncoder.withIndent('  ').convert(result));
        } catch (e) {
          print("$result");
        }
      } else {
        print(result);
      }
    }
  }

  http.Response handleResponse(http.Response response) {
    if (response == null) {
      print("No response");
      return null;
    }
    if (config.verbose) {
      print("REQUEST: ${response.request}");
      print("RESPONSE STATUS: ${response.statusCode}");
      print("RESPONSE HEADERS: ${response.headers}");
      print("RESPONSE BODY: ${response.body}");
    }
    return response;
  }

  @override
  Future<String> loadCredentials() async {
    if (await credentialsFile.exists()) {
      return credentialsFile.readAsStringSync();
    } else {
      return null;
    }
  }

  @override
  Future<void> removeCredentials() async {
    if (await credentialsFile.exists()) {
      await credentialsFile.deleteSync();
    }
  }

  @override
  Future<void> saveCredentials(String credentials) async {
    await credentialsFile.writeAsString(credentials);
  }

  // Subclasses implement
  void exec();
}

class StatusCommand extends BaseCommand {
  String description = "Get status of the Validicity system.";
  String name = "status";

  StatusCommand() {}

  void exec() async {
    result = await api.status();
  }
}

class BootstrapCommand extends BaseCommand {
  String description = "Bootstrap of Validicity creating admin account etc.";
  String name = "bootstrap";

  BootstrapCommand() {
    argParser.addOption('file',
        abbr: 'f', help: "The JSON file with the bootstrap content");
  }

  void exec() async {
    var payload = loadFile(argResults['file']);
    await api.bootstrap(payload);
  }
}

class CreateKeysCommand extends BaseCommand {
  String description = "Create keys for this client in the Validicity system.";
  String name = "createkeys";

  RegisterCommand() {
    /*argParser.addOption('user',
        abbr: 'u', help: "The user to authenticate with");
    argParser.addOption('password',
        abbr: 'p', help: "The password to authenticate with");
        */
  }

  void exec() async {
    if (validicityKey != null) {
      print(
          "Keys already exist, can not create new keys. Remove existing key file first.");
    } else {
      String path = createKey();
      print("Keys created in ${path}");
    }
  }
}

class RegisterCommand extends BaseCommand {
  String description = "Register this client in the Validicity system.";
  String name = "register";

  RegisterCommand() {
    /*argParser.addOption('user',
        abbr: 'u', help: "The user to authenticate with");
    argParser.addOption('password',
        abbr: 'p', help: "The password to authenticate with");
        */
  }

  void exec() async {
    if (validicityKey == null) {
      print("Keys do not exist, you first need to create new keys");
    }
    await api.register(validicityKey.publicKey);
  }
}

class OrganisationCommand extends GenericCommand {
  OrganisationCommand()
      : super("organisation", "Working with Organisations in Validicity.") {
    //addSubcommand(InstallationAllCustomerCommand(entity));
  }
  @override
  String get name => entity;
}

class ProjectCommand extends GenericCommand {
  ProjectCommand() : super("project", "Working with Projects in Validicity.") {
    addSubcommand(UserAddProjectCommand(entity));
    addSubcommand(UserRemoveProjectCommand(entity));
    addSubcommand(UserAllProjectCommand(entity));
  }

  @override
  String get name => entity;
}

class ProjectAllOrganisationCommand extends GenericSubCommand {
  final name = "projects";

  ProjectAllOrganisationCommand(entity)
      : super(entity, "Get all Projects for a given Organisation.") {
    argParser.addOption('organisation', abbr: 'o', help: "The Organisation id");
  }

  void exec() async {
    var organisation = argResults['organisation'];
    await client.doGet('organisation/$organisation/project');
  }
}

class UserAddProjectCommand extends GenericSubCommand {
  final name = "adduser";

  UserAddProjectCommand(entity)
      : super(entity, "Add access for a User to the Project.") {
    argParser.addOption('project', abbr: 'p', help: "The Project id");
    argParser.addOption('user', abbr: 'u', help: "The User id");
  }

  void exec() async {
    var project = intArg('project');
    var user = intArg('user');
    await api.addProjectUser(project, user);
    // await client.doPost('user/$user/Project/$Project', null);
  }
}

class UserRemoveProjectCommand extends GenericSubCommand {
  final name = "removeuser";

  UserRemoveProjectCommand(entity)
      : super(entity, "Remove access for a User to an Project.") {
    argParser.addOption('project', abbr: 'p', help: "The Project id");
    argParser.addOption('user', abbr: 'u', help: "The User id");
  }

  void exec() async {
    var project = intArg('project');
    var user = intArg('user');
    await api.removeProjectUser(project, user);
    // await client.doDelete('user/$user/project/$project');
  }
}

class UserAllProjectCommand extends GenericSubCommand {
  final name = "users";

  UserAllProjectCommand(entity)
      : super(entity, "Get all Users with access to the Project.") {
    argParser.addOption('project', abbr: 'p', help: "The Project id");
  }

  void exec() async {
    var project = argResults['project'];
    await client.doGet('project/$project/users');
  }
}
