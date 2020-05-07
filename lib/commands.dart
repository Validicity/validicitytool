import 'dart:async';

import 'package:args/command_runner.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:validicitylib/api.dart';
import 'package:validicitylib/config.dart';
import 'package:validicitylib/rest.dart';
import 'package:path/path.dart' as path;
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
    await api.boostrap(payload);
  }
}
