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

  /// Logs a user based on given [credential]
  ///
  /// Returns a [token] which should be user for authenticated
  /// requests
  @POST('/login')
  Future<String> login(@Body() UserPasswordCredential credential);

  /// Registers a user on the system
  ///
  /// Returns a confirmation string or error if the user
  /// already exists in database
  @POST('/register')
  Future<String> register(@Body() RegisterUser user);

  /// Lists a authorized user starred repositories
  @GET('/repository/starred')
  Future<List<SourceRepository>> starredRepos();

  /// Lists a authorized user repository details (with user tags)
  /// given based on the given id
  @GET('/repository/details/{id}')
  Future<DetailedSourceRepository> detailedRepo(@Path('id') int id);

  /// Add a new tag on a repository
  @POST('/tag/add')
  Future<UserTag> addTag(@Body() CreateTagInput input);

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
