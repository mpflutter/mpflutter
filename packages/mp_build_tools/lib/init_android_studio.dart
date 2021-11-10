import 'dart:io';

void main(List<String> args) {
  try {
    Directory('.idea').createSync();
  } catch (e) {}
  File('.idea/workspace.xml').writeAsStringSync('''
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="RunManager" selected="Dart Command Line App.MPFlutter">
    <configuration name="Build MPFlutter Plugins" type="DartCommandLineRunConfigurationType" factoryName="Dart Command Line Application" activateToolWindowBeforeRun="false">
      <option name="checkedMode" value="false" />
      <option name="filePath" value="\$PROJECT_DIR\$/scripts/build_plugins.dart" />
      <method v="2" />
    </configuration>
    <configuration name="MPFlutter" type="DartCommandLineRunConfigurationType" factoryName="Dart Command Line Application" singleton="false">
      <option name="filePath" value="\$PROJECT_DIR\$/lib/main.dart" />
      <method v="2">
        <option name="RunConfigurationTask" enabled="true" run_configuration_name="Build MPFlutter Plugins" run_configuration_type="DartCommandLineRunConfigurationType" />
      </method>
    </configuration>
    <configuration name="main.dart" type="FlutterRunConfigurationType" factoryName="Flutter">
      <option name="filePath" value="\$PROJECT_DIR\$/DO_NOT_RUN_THIS_TASK.dart" />
      <method v="2" />
    </configuration>
    <list>
      <item itemvalue="Dart Command Line App.MPFlutter" />
      <item itemvalue="Dart Command Line App.Build MPFlutter Plugins" />
      <item itemvalue="Flutter.main.dart" />
    </list>
  </component>
</project>
''');
}
