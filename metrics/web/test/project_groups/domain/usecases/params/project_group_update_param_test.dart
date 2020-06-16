import 'package:metrics/project_groups/domain/usecases/parameters/update_project_group_param.dart';
import 'package:test/test.dart';

void main() {
  group("ProjectGroupUpdateParam", () {
    const id = 'id';
    const name = 'name';
    const List<String> projectIds = [];

    test("throws an ArgumentError when created with null id", () {
      expect(
        () => UpdateProjectGroupParam(null, name, projectIds),
        throwsArgumentError,
      );
    });

    test("throws an ArgumentError when created with null name", () {
      expect(
        () => UpdateProjectGroupParam(id, null, projectIds),
        throwsArgumentError,
      );
    });

    test("throws an ArgumentError when created with null project ids", () {
      expect(
        () => UpdateProjectGroupParam(id, name, null),
        throwsArgumentError,
      );
    });
  });
}
