import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:metrics/common/presentation/constants/duration_constants.dart';
import 'package:metrics/common/presentation/models/project_model.dart';
import 'package:metrics/common/presentation/strings/common_strings.dart';
import 'package:metrics/project_groups/domain/entities/project_group.dart';
import 'package:metrics/project_groups/domain/usecases/add_project_group_usecase.dart';
import 'package:metrics/project_groups/domain/usecases/delete_project_group_usecase.dart';
import 'package:metrics/project_groups/domain/usecases/parameters/add_project_group_param.dart';
import 'package:metrics/project_groups/domain/usecases/parameters/delete_project_group_param.dart';
import 'package:metrics/project_groups/domain/usecases/parameters/update_project_group_param.dart';
import 'package:metrics/project_groups/domain/usecases/receive_project_group_updates.dart';
import 'package:metrics/project_groups/domain/usecases/update_project_group_usecase.dart';
import 'package:metrics/project_groups/presentation/view_models/active_project_group_dialog_view_model.dart';
import 'package:metrics/project_groups/presentation/view_models/project_group_card_view_model.dart';
import 'package:metrics/project_groups/presentation/view_models/project_selector_view_model.dart';
import 'package:metrics_core/metrics_core.dart';
import 'package:rxdart/rxdart.dart';

/// The [ChangeNotifier] that holds the project groups state.
///
/// Stores the [ProjectGroupViewModel]s.
class ProjectGroupsNotifier extends ChangeNotifier {
  /// Provides an ability to receive project group updates.
  final ReceiveProjectGroupUpdates _receiveProjectGroupUpdates;

  /// Provides an ability to update the project group.
  final UpdateProjectGroupUseCase _updateProjectGroupUseCase;

  /// Provides an ability to delete the project group.
  final DeleteProjectGroupUseCase _deleteProjectGroupUseCase;

  /// Provides an ability to add the project group.
  final AddProjectGroupUseCase _addProjectGroupUseCase;

  /// A [PublishSubject] that provides the ability to filter projects by the name.
  final _projectNameFilterSubject = PublishSubject<String>();

  /// The stream subscription needed to be able to stop listening
  /// to the project group updates.
  StreamSubscription _projectGroupsSubscription;

  /// Holds the error message that occurred during loading project groups data.
  String _errorMessage;

  /// Holds the error message that occurred during updating projects data.
  String _projectsErrorMessage;

  /// Holds the error message that occurred during the firestore saving operation.
  String _projectGroupSavingErrorMessage;

  /// A[List] that holds all loaded [ProjectGroup].
  List<ProjectGroup> _projectGroups;

  /// A[List] that holds view models of all loaded [ProjectGroup].
  List<ProjectGroupCardViewModel> _projectGroupCardViewModels;

  /// A[List] that holds view models of all loaded [Project].
  List<ProjectSelectorViewModel> _projectSelectorViewModels;

  /// Holds data of active project group dialog.
  ActiveProjectGroupDialogViewModel _activeProjectGroupDialogViewModel;

  /// Optional filter value that represents a part (or full) project name used to limit the displayed data.
  String _projectNameFilter;

  /// Creates the project groups store.
  ///
  /// The given use cases must not be null.
  ProjectGroupsNotifier(
    this._receiveProjectGroupUpdates,
    this._addProjectGroupUseCase,
    this._updateProjectGroupUseCase,
    this._deleteProjectGroupUseCase,
  ) : assert(
          _receiveProjectGroupUpdates != null &&
              _addProjectGroupUseCase != null &&
              _updateProjectGroupUseCase != null &&
              _deleteProjectGroupUseCase != null,
          'The use cases must not be null',
        );

  /// Provides an error description that occurred during loading project groups data.
  String get errorMessage => _errorMessage;

  /// Provides an error description that occurred during loading projects data.
  String get projectsErrorMessage => _projectsErrorMessage;

  /// Provides an error description that occurred during the firestore saving operation.
  String get projectGroupSavingErrorMessage => _projectGroupSavingErrorMessage;

  /// Provides a list of project selector view model, filtered by the project name filter.
  List<ProjectSelectorViewModel> get projectSelectorViewModels {
    if (_projectNameFilter == null || _projectSelectorViewModels == null) {
      return _projectSelectorViewModels;
    }

    return _projectSelectorViewModels
        .where((project) => project.name
            .toLowerCase()
            .contains(_projectNameFilter.toLowerCase()))
        .toList();
  }

  /// Provides a list of project group card view models.
  List<ProjectGroupCardViewModel> get projectGroupCardViewModels =>
      _projectGroupCardViewModels;

  /// Provides a list of all loaded project group.
  List<ProjectGroup> get projectGroups => _projectGroups;

  /// Provides data for active project group dialog.
  ActiveProjectGroupDialogViewModel get activeProjectGroupDialogViewModel =>
      _activeProjectGroupDialogViewModel;

  /// Subscribes to a projects name filter.
  void subscribeToProjectsNameFilter() {
    _projectNameFilterSubject
        .debounceTime(DurationConstants.debounce)
        .listen((value) {
      _projectNameFilter = value;
      notifyListeners();
    });
  }

  /// Adds projects filter using [value] provided.
  void filterByProjectName(String value) {
    _projectNameFilterSubject.add(value);
  }

  /// Creates the [ActiveProjectGroupDialogViewModel] using the given [projectGroupId].
  void setActiveProjectGroup([String projectGroupId]) {
    _projectNameFilter = null;

    final projectGroup = _projectGroups.firstWhere(
      (projectGroup) => projectGroup.id == projectGroupId,
      orElse: () => null,
    );

    final projectIds = projectGroup?.projectIds ?? [];

    _projectSelectorViewModels = _projectSelectorViewModels
        .map(
          (project) => ProjectSelectorViewModel(
            id: project.id,
            name: project.name,
            isChecked: projectIds?.contains(project.id),
          ),
        )
        .toList();

    _activeProjectGroupDialogViewModel = ActiveProjectGroupDialogViewModel(
      id: projectGroup?.id,
      name: projectGroup?.name,
      selectedProjectIds: List<String>.from(projectIds),
    );

    notifyListeners();
  }

  /// Change checked status for [ProjectSelectorViewModel] by [projectId].
  void toggleProjectCheckedStatus({String projectId, bool isChecked}) {
    final projectIds = _activeProjectGroupDialogViewModel.selectedProjectIds;

    if (isChecked) {
      projectIds.add(projectId);
    } else {
      projectIds.remove(projectId);
    }

    final projectIndex = _projectSelectorViewModels
        .indexWhere((project) => project.id == projectId);

    final project = _projectSelectorViewModels[projectIndex];

    _projectSelectorViewModels[projectIndex] = ProjectSelectorViewModel(
      id: project.id,
      name: project.name,
      isChecked: isChecked,
    );

    _activeProjectGroupDialogViewModel = ActiveProjectGroupDialogViewModel(
      id: _activeProjectGroupDialogViewModel.id,
      name: _activeProjectGroupDialogViewModel.name,
      selectedProjectIds: projectIds,
    );

    notifyListeners();
  }

  /// Subscribes to project groups.
  Future<void> subscribeToProjectGroups() async {
    final projectGroupsStream = _receiveProjectGroupUpdates();
    _errorMessage = null;
    await _projectGroupsSubscription?.cancel();
    _projectGroupsSubscription = projectGroupsStream.listen(
      _projectGroupsListener,
      onError: _errorHandler,
    );
  }

  /// Unsubscribes from project groups.
  Future<void> unsubscribeFromProjectGroups() async {
    await _cancelSubscriptions();
    notifyListeners();
  }

  /// Saves the project group data with the given [projectGroupId].
  ///
  /// If [projectIds] is null, a new project group is added,
  /// otherwise existing ones are updated.
  Future<bool> saveProjectGroup(
    String projectGroupId,
    String projectGroupName,
    List<String> projectIds,
  ) async {
    resetProjectGroupSavingError();

    try {
      if (projectGroupId == null) {
        await _addProjectGroupUseCase(
          AddProjectGroupParam(
            projectGroupName: projectGroupName,
            projectIds: projectIds,
          ),
        );
      } else {
        await _updateProjectGroupUseCase(
          UpdateProjectGroupParam(
            projectGroupId,
            projectGroupName,
            projectIds,
          ),
        );
      }
    } catch (e) {
      _projectGroupSavingErrorHandler(e);
    }

    return _projectGroupSavingErrorMessage == null;
  }

  /// Deletes project group data from Firestore with the given [projectGroupId].
  Future<bool> deleteProjectGroup(String projectGroupId) async {
    resetProjectGroupSavingError();

    try {
      await _deleteProjectGroupUseCase(
        DeleteProjectGroupParam(projectGroupId: projectGroupId),
      );
    } catch (e) {
      _projectGroupSavingErrorHandler(e);
    }

    return _projectGroupSavingErrorMessage == null;
  }

  /// Sets [_projectGroupSavingErrorMessage] to null.
  void resetProjectGroupSavingError() {
    _projectGroupSavingErrorMessage = null;
    notifyListeners();
  }

  /// Updates list of project selector view models and projects error message.
  void updateProjects(List<ProjectModel> projects, String projectsErrorMessage) {
    _projectsErrorMessage = projectsErrorMessage;

    if(projects == null) return;

    final projectIds =
        _activeProjectGroupDialogViewModel?.selectedProjectIds ?? [];
    _projectSelectorViewModels = projects
        .map((project) => ProjectSelectorViewModel(
              id: project.id,
              name: project.name,
              isChecked: projectIds.contains(project.id),
            ))
        .toList();
    notifyListeners();
  }

  /// Listens to project group updates.
  void _projectGroupsListener(List<ProjectGroup> newProjectGroups) {
    if (newProjectGroups == null) return;

    _projectGroups = newProjectGroups;
    _projectGroupCardViewModels = newProjectGroups
        .map((project) => ProjectGroupCardViewModel(
              id: project.id,
              name: project.name,
              projectsCount: project.projectIds.length,
            ))
        .toList();

    notifyListeners();
  }

  /// Cancels created subscription.
  Future<void> _cancelSubscriptions() async {
    await _projectGroupsSubscription?.cancel();
    _projectGroups = null;
  }

  /// Saves the error [String] representation to [_errorMessage].
  void _errorHandler(error) {
    if (error is PlatformException) {
      _errorMessage = error.message;
      return notifyListeners();
    }

    _errorMessage = CommonStrings.unknownErrorMessage;
    notifyListeners();
  }

  /// Saves the error [String] representation to [_projectGroupSavingErrorMessage].
  void _projectGroupSavingErrorHandler(error) {
    _projectGroupSavingErrorMessage = CommonStrings.unknownErrorMessage;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    _projectNameFilterSubject.close();
    super.dispose();
  }
}
