import 'package:flutter/foundation.dart';

import 'repository_tagger_client.dart';


/// Simple tagger client cache layer
class RepositoryTaggerCacheClient implements RepositoryTaggerClient {
  RepositoryTaggerCacheClient({
    @required this.delegate,
  });

  final RepositoryTaggerClient delegate;

  List<SimpleRepository> _cachedStarredRepos = [];

  @override
  Future<UserTag> addTag(CreateTagInput input) => delegate.addTag(input);

  @override
  Future<DetailedRepository> detailedRepo(int id) => delegate.detailedRepo(id);

  @override
  Future<bool> hasSession() => delegate.hasSession();

  @override
  Future<String> oauth() => delegate.oauth();

  @override
  Future removeTag({int githubId, int userTagId}) => delegate.removeTag(
        githubId: githubId,
        userTagId: userTagId,
      );

  @override
  Future<TagRepositoriesResponse> repositoriesByTag(int id) =>
      delegate.repositoriesByTag(id);

  @override
  Future<List<SimpleRepository>> starredRepos() async {
    if (_cachedStarredRepos.isEmpty) {
      final repos = await delegate.starredRepos();

      _cachedStarredRepos = repos;
    }

    return _cachedStarredRepos;
  }

  @override
  Future<List<UserTag>> userTags() => delegate.userTags();
}
