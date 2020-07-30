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

  /// Lists all user tags
  @GET('/tags/list')
  Future<List<UserTag>> userTags();

  /// Creates a user tag
  @GET('/tags/list')
  Future<List<UserTag>> userTags();
}
