import 'package:flutter_test/flutter_test.dart';
import 'package:haf_spb_app/model/smart_variables_dependencies_extractor.dart';

void main() {
  test('Test branching dependencies', () {
    expect(SmartVariablesDependenciesExtractor.getVariablesDependOn("").isEmpty,
        true);

    expect(
        SmartVariablesDependenciesExtractor.getVariablesDependOn("a").isEmpty,
        true);

    expect(
        SmartVariablesDependenciesExtractor.getVariablesDependOn("abcdef")
            .isEmpty,
        true);

    expect(
        SmartVariablesDependenciesExtractor.getVariablesDependOn("[").isEmpty,
        true);

    expect(
        SmartVariablesDependenciesExtractor.getVariablesDependOn("[]").isEmpty,
        true);

    expect(SmartVariablesDependenciesExtractor.getVariablesDependOn("[abc]"),
        {"abc"});

    expect(
        SmartVariablesDependenciesExtractor.getVariablesDependOn("[abc][def]"),
        {"abc", "def"});

    expect(
        SmartVariablesDependenciesExtractor.getVariablesDependOn(
            "[abc] + [def]"),
        {"abc", "def"});

    expect(
        SmartVariablesDependenciesExtractor.getVariablesDependOn(
            "[abc] + [def]/[ghkl]"),
        {"abc", "def", "ghkl"});
  });
}
