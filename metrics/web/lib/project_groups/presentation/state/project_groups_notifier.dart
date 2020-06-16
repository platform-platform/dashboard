import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:metrics/common/domain/entities/firestore_error_code.dart';
import 'package:metrics/common/domain/entities/firestore_exception.dart';
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
import 'package:metrics/project_groups/presentation/models/project_group_firestore_error_message.dart';
import 'package:metrics/project_groups/presentation/view_models/selected_project_group_dialog_view_model.dart';
import 'package:metrics/project_groups/presentation/view_models/project_group_card_view_model.dart';
import 'package:metrics/project_groups/presentation/view_models/project_selection_view_model.dart';
import 'package:metrics_core/metrics_core.dart';
import 'package:rxdart/rxdart.dart';

/// Creates a new instance of the [ProjectGroupsNotifier].
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

  /// Holds the project group firestore error message.
  ProjectGroupFirestoreErrorMessage _projectGroupSavingError;

  /// A [List] that holds all loaded [ProjectGroup].
  List<ProjectGroup> _projectGroups;

  /// A [List] that holds view models of all loaded [ProjectGroup].
  List<ProjectGroupCardViewModel> _projectGroupCardViewModels;

  /// A [List] that holds view models of all loaded [Project].
  List<ProjectSelectionViewModel> _projectSelectorViewModels;

  /// Holds the data for a selected project group dialog.
  SelectedProjectGroupDialogViewModel _selectedProjectGroupDialogViewModel;

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
        ) {
    _subscribeToProjectsNameFilter();
  }

  /// Provides an error description that occurred during loading project groups data.
  String get errorMessage => _errorMessage;

  /// Provides an error description that occurred during loading projects data.
  String get projectsErrorMessage => _projectsErrorMessage;

  /// Provides an error description that occurred during the
  /// project group firestore saving operation.
  ProjectGroupFirestoreErrorMessage get projectGroupSavingError =>
      _projectGroupSavingError;

  /// Provides a list of project selector view model, filtered by the project name filter.
  List<ProjectSelectionViewModel> get projectSelectorViewModels {
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

  /// Provides data for a selected project group dialog.
  SelectedProjectGroupDialogViewModel get selectedProjectGroupDialogViewModel =>
      _selectedProjectGroupDialogViewModel;

  /// Subscribes to a projects name filter.
  void _subscribeToProjectsNameFilter() {
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

  /// Creates the [SelectedProjectGroupDialogViewModel] using the given [projectGroupId].
  void setActiveProjectGroup([String projectGroupId]) {
    final projectGroup = _projectGroups.firstWhere(
      (projectGroup) => projectGroup.id == projectGroupId,
      orElse: () => null,
    );

    final projectIds = projectGroup?.projectIds ?? [];

    _projectSelectorViewModels = _projectSelectorViewModels
        .map(
          (project) => ProjectSelectionViewModel(
            id: project.id,
            name: project.name,
            isChecked: projectIds?.contains(project.id),
          ),
        )
        .toList();

    _selectedProjectGroupDialogViewModel = SelectedProjectGroupDialogViewModel(
      id: projectGroup?.id,
      name: projectGroup?.name,
      selectedProjectIds: List<String>.from(projectIds),
    );

    notifyListeners();
  }

  void resetFilterName() {
    _projectNameFilter = null;
  }

  /// Change checked status for [ProjectSelectionViewModel] by [projectId].
  void toggleProjectCheckedStatus({String projectId, bool isChecked}) {
    if (projectId == null && isChecked == null) return;

    final projectIds = _selectedProjectGroupDialogViewModel.selectedProjectIds;

    if (isChecked) {
      projectIds.add(projectId);
    } else {
      projectIds.remove(projectId);
    }

    final projectIndex = _projectSelectorViewModels
        .indexWhere((project) => project.id == projectId);

    final project = _projectSelectorViewModels[projectIndex];

    _projectSelectorViewModels[projectIndex] = ProjectSelectionViewModel(
      id: project.id,
      name: project.name,
      isChecked: isChecked,
    );

    _selectedProjectGroupDialogViewModel = SelectedProjectGroupDialogViewModel(
      id: _selectedProjectGroupDialogViewModel.id,
      name: _selectedProjectGroupDialogViewModel.name,
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
  /// Adds a new project group, if the given [projectGroupId] is `null`.
  /// Otherwise updates the project group with the given id.
  Future<void> saveProjectGroup(
    String projectGroupId,
    String projectGroupName,
    List<String> projectIds,
  ) async {
    resetProjectGroupSavingErrorMessage();

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
    } on FirestoreException catch (exception) {
      _projectGroupSavingErrorHandler(exception.code);
    }
  }

  /// Deletes the project group with the given [projectGroupId].
  Future<void> deleteProjectGroup(String projectGroupId) async {
    resetProjectGroupSavingErrorMessage();

    try {
      await _deleteProjectGroupUseCase(
        DeleteProjectGroupParam(projectGroupId: projectGroupId),
      );
    } on FirestoreException catch (exception) {
      _projectGroupSavingErrorHandler(exception.code);
    }
  }

  /// Resets the [projectGroupSavingErrorMessage].
  void resetProjectGroupSavingErrorMessage() {
    _projectGroupSavingError = null;
    notifyListeners();
  }

  /// Sets current project with a loading error message to the given [projects]
  /// and [projectsErrorMessage] respectively.
  void updateProjects(
      List<ProjectModel> projects, String projectsErrorMessage) {
    _projectsErrorMessage = projectsErrorMessage;

    if (projects == null) return;

    final projectIds =
        _selectedProjectGroupDialogViewModel?.selectedProjectIds ?? [];
    _projectSelectorViewModels = projects
        .map((project) => ProjectSelectionViewModel(
              id: project.id,
              name: project.name,
              isChecked: projectIds.contains(project.id),
            ))
        .toList();
    notifyListeners();
  }

  /// Updates the current project groups with the given [newProjectGroups] list.
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
  void _projectGroupSavingErrorHandler(FirestoreErrorCode code) {
    _projectGroupSavingError = ProjectGroupFirestoreErrorMessage(code);
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    _projectNameFilterSubject.close();
    super.dispose();
  }
}
