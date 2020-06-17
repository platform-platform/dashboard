import 'package:flutter/material.dart';
import 'package:metrics/base/presentation/widgets/padded_card.dart';
import 'package:metrics/common/presentation/metrics_theme/state/theme_notifier.dart';
import 'package:metrics/project_groups/presentation/strings/project_groups_strings.dart';
import 'package:metrics/project_groups/presentation/state/project_groups_notifier.dart';
import 'package:metrics/project_groups/presentation/widgets/add_project_group_dialog.dart';
import 'package:provider/provider.dart';

/// An [AddProjectGroupCard] widget that represents a metrics card with an ability
/// to control touch events.
class AddProjectGroupCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const symmetricPadding = EdgeInsets.symmetric(vertical: 4.0);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return InkWell(
      onTap: () => _showProjectGroupDialog(context),
      child: PaddedCard(
        backgroundColor:
            themeNotifier.isDark ? Colors.grey[900] : Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Padding(
              padding: symmetricPadding,
              child: Icon(
                Icons.add,
                size: 72.0,
              ),
            ),
            Padding(
              padding: symmetricPadding,
              child: Text(
                ProjectGroupsStrings.addProjectGroup,
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a [ProjectGroupDialog] with an active project group.
  Future<void> _showProjectGroupDialog(BuildContext context) async {
    Provider.of<ProjectGroupsNotifier>(context, listen: false)
        .setActiveProjectGroup();

    await showDialog(
      context: context,
      child: AddProjectGroupDialog(),
    );
  }
}
