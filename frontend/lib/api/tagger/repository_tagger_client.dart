import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

part 'repository_tagger_client.g.dart';

part 'repository_tagger_models.dart';

/// A repository tagger client for dart
@RestApi()
abstract class RepositoryTaggerClient {
  /// Creates a github tagger api client
  factory RepositoryTaggerClient(
    Dio dio, {
    @required String baseUrl,
  }) = _RepositoryTaggerClient;

  /// Lists a authorized user starred repositories
  @GET('/repository/starred')
  Future<List<SimpleRepository>> starredRepos({
    @Query('page') int page,
  });

  /// Lists all repositories associated with a tag
  @GET('/tag/{tagId}/repositories')
  Future<TagRepositoriesResponse> repositoriesByTag(@Path('tagId') int id);

  /// Lists a authorized user repository details (with user tags)
  /// given based on the given id
  @GET('/repository/details/{id}')
  Future<DetailedRepository> detailedRepo(@Path('id') int id);

  /// Add a new tag on a repository
  @POST('/tag/add')
  Future<UserTag> addTag(@Body() CreateTagInput input);

  /// Requires oauth redirection from server
  @GET('/oauth')
  Future<String> oauth();

  /// Checks if this app/browser has session
  @GET('/has-session')
  Future<bool> hasSession();

  /// Removes a tag from a repository
  @DELETE('/repository/{githubId}/remove-tag/{userTagId}')
  Future removeTag({
    @required @Path('githubId') int githubId,
    @required @Path('userTagId') int userTagId,
  });

  /// Lists all user tags
  @GET('/tag/list')
  Future<List<UserTag>> userTags();
}
