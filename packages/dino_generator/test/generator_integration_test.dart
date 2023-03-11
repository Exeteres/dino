import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart';
import 'package:dino_generator/src/generator_composition_root.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

Future<void> main() async {
  final testCases = await locateTestCases();

  final compositionRoot = GeneratorCompositionRoot();
  final dartFormatter = DartFormatter();

  for (final testCase in testCases) {
    test('generate code for ${testCase.name}', () async {
      var result = await invokeGeneratorForCase(compositionRoot, testCase);

      result = "part of 'input.dart';\n" + result;
      result = dartFormatter.format(result);

      expect(result, TestCaseMatcher(testCase));
    });
  }
}

class TestCase {
  TestCase(this.name, this.path, this.input, this.output);

  final String name;
  final String path;
  final String input;
  final String? output;
}

Future<List<TestCase>> locateTestCases() async {
  final testCasesFutures =
      await Directory('test/cases/lib').list().map(tryGetTestCase).toList();

  final testCases = await Future.wait(testCasesFutures);

  return testCases.where((e) => e != null).cast<TestCase>().toList();
}

Future<TestCase?> tryGetTestCase(FileSystemEntity entity) async {
  if (entity is! Directory) {
    return null;
  }

  final inputFile = File(path.join(entity.path, 'input.dart'));

  if (!await inputFile.exists()) {
    return null;
  }

  var inputContent = await inputFile.readAsString();
  inputContent = inputContent.replaceAll('\r\n', '\n');

  String? outputContent;

  final outputFile = File(path.join(entity.path, 'input.g.dart'));

  if (await outputFile.exists()) {
    outputContent = await outputFile.readAsString();
    outputContent = outputContent.replaceAll('\r\n', '\n');
  }

  return TestCase(
    path.basename(entity.path),
    path.normalize(entity.path),
    inputContent,
    outputContent,
  );
}

Future<String> invokeGeneratorForCase(
  GeneratorCompositionRoot compositionRoot,
  TestCase testCase,
) {
  final inputId = AssetId.parse(
    'generator_test_cases|${path.join('lib', testCase.name, 'input.dart')}',
  );

  return resolveSource(
    testCase.input,
    (resolver) async {
      final library = await resolver.libraryFor(inputId);

      return await compositionRoot.process(LibraryReader(library)) ?? '';
    },
    inputId: inputId,
  );
}

class TestCaseMatcher implements Matcher {
  final TestCase _testCase;

  TestCaseMatcher(this._testCase);

  @override
  Description describe(Description description) {
    return description.add('matches output for ${_testCase.name}');
  }

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    return mismatchDescription.add(
      'does not match output for ${_testCase.name}\n'
      'An anctual output has been written to '
      '${path.join(_testCase.path, 'output.mismatch.dart')}',
    );
  }

  @override
  bool matches(item, Map matchState) {
    final actual = item as String;

    if (_testCase.output == null) {
      File(path.join(_testCase.path, 'input.g.dart')).writeAsStringSync(actual);

      return true;
    }

    final mismatchFile = File(
      path.join(_testCase.path, 'input.mismatch.g.dart'),
    );

    if (_testCase.output != actual) {
      mismatchFile.writeAsStringSync(actual);

      return false;
    }

    if (mismatchFile.existsSync()) {
      mismatchFile.deleteSync();
    }

    return true;
  }
}
