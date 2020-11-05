import 'dart:io';
import 'dart:typed_data';

import 'package:api_mock_server/api_mock_server.dart';
import 'package:ci_integration/client/github_actions/mappers/github_action_status_mapper.dart';
import 'package:ci_integration/client/github_actions/models/github_action_conclusion.dart';
import 'package:ci_integration/client/github_actions/models/github_action_status.dart';
import 'package:ci_integration/client/github_actions/models/workflow_run.dart';
import 'package:ci_integration/client/github_actions/models/workflow_run_artifact.dart';
import 'package:ci_integration/client/github_actions/models/workflow_run_job.dart';

import '../../../test_utils/mock_server_utils.dart';

/// A mock server for the Github Actions API.
class GithubActionsMockServer extends ApiMockServer {
  /// A path to emulate a download url.
  static const String _downloadPath = '/download';

  /// Returns a base path of the Github Actions API.
  String get basePath => '/repos/owner/name/actions';

  @override
  List<RequestHandler> get handlers => [
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/workflows/workflow_id/runs',
          ),
          dispatcher: _workflowRunsResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/workflows/test/runs',
          ),
          dispatcher: _notFoundResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/runs/1/jobs',
          ),
          dispatcher: _workflowRunJobsResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/runs/test/jobs',
          ),
          dispatcher: _notFoundResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/runs/1/artifacts',
          ),
          dispatcher: _workflowRunArtifactsResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/runs/test/artifacts',
          ),
          dispatcher: _notFoundResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/artifacts/artifact_id/zip',
          ),
          dispatcher: _downloadArtifactResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(
            '$basePath/artifacts/test/zip',
          ),
          dispatcher: _notFoundResponse,
        ),
        RequestHandler.get(
          pathMatcher: ExactPathMatcher(_downloadPath),
          dispatcher: _downloadResponse,
        ),
      ];

  /// Responses with a list of all workflow runs for a specific workflow.
  Future<void> _workflowRunsResponse(HttpRequest request) async {
    final status = _extractRunStatus(request);
    final runsPerPage = MockServerUtils.extractPerPage(request);
    final pageNumber = MockServerUtils.extractPage(request);

    List<WorkflowRun> workflowRuns = _generateWorkflowRuns(status);

    MockServerUtils.setNextPageUrlHeader(
      request,
      workflowRuns.length,
      runsPerPage,
      pageNumber,
    );

    workflowRuns = MockServerUtils.paginate(
      workflowRuns,
      runsPerPage,
      pageNumber,
    );

    final _response = {
      'total_count': workflowRuns.length,
      'workflow_runs': workflowRuns.map((run) => run.toJson()).toList(),
    };

    await MockServerUtils.writeResponse(request, _response);
  }

  /// Responses with a list of all workflow run jobs for a specific workflow run.
  Future<void> _workflowRunJobsResponse(HttpRequest request) async {
    final status = _extractRunStatus(request);
    final runsPerPage = MockServerUtils.extractPerPage(request);
    final pageNumber = MockServerUtils.extractPage(request);

    List<WorkflowRunJob> workflowRunJobs = _generateWorkflowRunJobs(status);

    MockServerUtils.setNextPageUrlHeader(
      request,
      workflowRunJobs.length,
      runsPerPage,
      pageNumber,
    );

    workflowRunJobs = MockServerUtils.paginate(
      workflowRunJobs,
      runsPerPage,
      pageNumber,
    );

    final _response = {
      'total_count': workflowRunJobs.length,
      'jobs': workflowRunJobs.map((run) => run.toJson()).toList(),
    };

    await MockServerUtils.writeResponse(request, _response);
  }

  /// Responses with a list of artifacts for a specific workflow run.
  Future<void> _workflowRunArtifactsResponse(HttpRequest request) async {
    final runsPerPage = MockServerUtils.extractPerPage(request);
    final pageNumber = MockServerUtils.extractPage(request);

    List<WorkflowRunArtifact> artifacts = _generateArtifacts();

    MockServerUtils.setNextPageUrlHeader(
      request,
      artifacts.length,
      runsPerPage,
      pageNumber,
    );

    artifacts = MockServerUtils.paginate(artifacts, runsPerPage, pageNumber);

    final _response = {
      'total_count': artifacts.length,
      'artifacts': artifacts.map((artifact) => artifact.toJson()).toList(),
    };

    await MockServerUtils.writeResponse(request, _response);
  }

  /// Redirects to the artifact download URL.
  Future<void> _downloadArtifactResponse(HttpRequest request) async {
    final uri = Uri.parse(url);

    await request.response.redirect(
      Uri(host: uri.host, port: uri.port, path: _downloadPath),
      status: HttpStatus.found,
    );

    await request.response.close();
  }

  /// Returns a [Uint8List] to emulate download.
  Future<void> _downloadResponse(HttpRequest request) async {
    await MockServerUtils.writeResponse(request, Uint8List.fromList([]));
  }

  /// Adds a [HttpStatus.notFound] status code to the [HttpRequest.response]
  /// and closes it.
  Future<void> _notFoundResponse(HttpRequest request) async {
    request.response.statusCode = HttpStatus.notFound;

    await request.response.close();
  }

  /// Generates a list of [WorkflowRun]s with the given [status].
  ///
  /// If the given [status] is null, the [GithubActionStatus.completed] is used.
  List<WorkflowRun> _generateWorkflowRuns(GithubActionStatus status) {
    final runs = List.generate(100, (index) {
      final runNumber = index + 1;

      return WorkflowRun(
        id: runNumber,
        number: runNumber,
        url: 'url',
        status: status ?? GithubActionStatus.completed,
        createdAt: DateTime.now().toUtc(),
      );
    });

    return runs;
  }

  /// Generates a list of [WorkflowRunJob]s with the given [status].
  ///
  /// If the given [status] is null, the [GithubActionStatus.completed] is used.
  List<WorkflowRunJob> _generateWorkflowRunJobs(GithubActionStatus status) {
    final jobs = List.generate(100, (index) {
      final id = index + 1;

      return WorkflowRunJob(
        id: id,
        runId: 1,
        name: 'name',
        url: 'url',
        status: status ?? GithubActionStatus.completed,
        conclusion: GithubActionConclusion.success,
        startedAt: DateTime(2019),
        completedAt: DateTime(2020),
      );
    });

    return jobs;
  }

  /// Generates a list of [WorkflowRunArtifact]s.
  List<WorkflowRunArtifact> _generateArtifacts() {
    final artifacts = List.generate(100, (index) {
      final id = index + 1;

      return WorkflowRunArtifact(
        id: id,
        name: 'coverage$id.json',
        downloadUrl: 'https://api.github.com$_downloadPath',
      );
    });

    return artifacts;
  }

  /// Returns the [GithubActionStatus], based on the `status` query parameter
  /// of the given [request].
  GithubActionStatus _extractRunStatus(HttpRequest request) {
    final status = request.uri.queryParameters['status'];

    return const GithubActionStatusMapper().map(status);
  }
}
