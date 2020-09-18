import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:metrics/base/presentation/widgets/icon_label_button.dart';
import 'package:metrics/base/presentation/widgets/tappable_area.dart';
import 'package:metrics/common/presentation/metrics_theme/widgets/metrics_theme.dart';
import 'package:metrics/common/presentation/strings/common_strings.dart';
import 'package:metrics/common/presentation/widgets/metrics_card.dart';
import 'package:metrics/project_groups/presentation/state/project_groups_notifier.dart';
import 'package:metrics/project_groups/presentation/strings/project_groups_strings.dart';
import 'package:metrics/project_groups/presentation/view_models/project_group_card_view_model.dart';
import 'package:metrics/project_groups/presentation/widgets/delete_project_group_dialog.dart';
import 'package:metrics/project_groups/presentation/widgets/edit_project_group_dialog.dart';
import 'package:provider/provider.dart';

/// A widget that represents [ProjectGroupCardViewModel].
class ProjectGroupCard extends StatefulWidget {
  /// A [ProjectGroupCardViewModel] with project group data to display.
  final ProjectGroupCardViewModel projectGroupCardViewModel;

  /// Creates the [ProjectGroupCard] with the given [projectGroupCardViewModel].
  ///
  /// The [projectGroupCardViewModel] must not be null.
  const ProjectGroupCard({
    Key key,
    @required this.projectGroupCardViewModel,
  })  : assert(projectGroupCardViewModel != null),
        super(key: key);

  @override
  _ProjectGroupCardState createState() => _ProjectGroupCardState();
}

class _ProjectGroupCardState extends State<ProjectGroupCard> {
  /// The length of the icon box side.
  static const double _iconBoxSide = 20.0;

  @override
  Widget build(BuildContext context) {
    const _buttonIconPadding = EdgeInsets.only(right: 8.0);
    final theme = MetricsTheme.of(context).projectGroupCardTheme;

    return Material(
      child: TappableArea(
        mouseCursor: SystemMouseCursors.basic,
        builder: (context, isHovered, child) {
          return MetricsCard(
            decoration: BoxDecoration(
              border: Border.all(color: theme.borderColor),
              borderRadius: BorderRadius.circular(4.0),
              color: isHovered ? theme.hoverColor : theme.backgroundColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                child,
                if (isHovered)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconLabelButton(
                        onPressed: () => _showProjectGroupDialog(context),
                        iconPadding: _buttonIconPadding,
                        iconBuilder: (context, isHovered) {
                          return Image.network(
                            'icons/edit.svg',
                            width: _iconBoxSide,
                            height: _iconBoxSide,
                            fit: BoxFit.contain,
                            color: isHovered
                                ? theme.primaryButtonStyle.hoverColor
                                : theme.primaryButtonStyle.color,
                          );
                        },
                        labelBuilder: (context, isHovered) {
                          return Text(
                            CommonStrings.edit,
                            style: TextStyle(
                              color: isHovered
                                  ? theme.primaryButtonStyle.hoverColor
                                  : theme.primaryButtonStyle.color,
                            ),
                          );
                        },
                      ),
                      IconLabelButton(
                        onPressed: () => _showProjectGroupDeleteDialog(context),
                        iconPadding: _buttonIconPadding,
                        iconBuilder: (context, isHovered) {
                          return Image.network(
                            'icons/delete.svg',
                            width: _iconBoxSide,
                            height: _iconBoxSide,
                            fit: BoxFit.contain,
                            color: isHovered
                                ? theme.accentButtonStyle.hoverColor
                                : theme.accentButtonStyle.color,
                          );
                        },
                        labelBuilder: (context, isHovered) {
                          return Text(
                            CommonStrings.delete,
                            style: TextStyle(
                              color: isHovered
                                  ? theme.accentButtonStyle.hoverColor
                                  : theme.accentButtonStyle.color,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                widget.projectGroupCardViewModel.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: theme.titleStyle,
              ),
            ),
            Text(
              _projectGroupsCount,
              style: theme.subtitleStyle,
            ),
          ],
        ),
      ),
    );
  }

  /// Provides a project groups count for the given [projectGroupViewModel].
  String get _projectGroupsCount {
    final projectsCount = widget.projectGroupCardViewModel.projectsCount;

    if (projectsCount == null || projectsCount == 0) {
      return ProjectGroupsStrings.noProjects;
    }

    return ProjectGroupsStrings.getProjectsCount(projectsCount);
  }

  /// Shows a [DeleteProjectGroupDialog] with an active project group.
  Future<void> _showDeleteProjectGroupDialog() async {
    final projectGroupsNotifier = Provider.of<ProjectGroupsNotifier>(
      context,
      listen: false,
    );

    projectGroupsNotifier.initDeleteProjectGroupDialogViewModel(
      widget.projectGroupCardViewModel.id,
    );

    if (projectGroupsNotifier.deleteProjectGroupDialogViewModel == null) return;

    await _showProjectGroupDialog(DeleteProjectGroupDialog());

    projectGroupsNotifier.resetDeleteProjectGroupDialogViewModel();
  }

  /// Shows an [EditProjectGroupDialog] with an active project group.
  Future<void> _showEditProjectGroupDialog() async {
    final projectGroupsNotifier = Provider.of<ProjectGroupsNotifier>(
      context,
      listen: false,
    );

    projectGroupsNotifier.initProjectGroupDialogViewModel(
      widget.projectGroupCardViewModel.id,
    );

    if (projectGroupsNotifier.projectGroupDialogViewModel == null) return;

    await _showProjectGroupDialog(EditProjectGroupDialog());

    projectGroupsNotifier.resetProjectGroupDialogViewModel();
  }

  /// Shows the given [dialog] with the barrier color from the metrics theme.
  Future<void> _showProjectGroupDialog(Widget dialog) async {
    final barrierColor =
        MetricsTheme.of(context).projectGroupDialogTheme.barrierColor;

    await showDialog(
      barrierColor: barrierColor,
      context: context,
      builder: (_) => dialog,
    );
  }
}
