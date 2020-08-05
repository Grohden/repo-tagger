import 'package:flutter/foundation.dart';

import 'repository_tagger_client.dart';


/// Simple tagger client cache layer
class RepositoryTaggerCacheClient implements RepositoryTaggerClient {
  RepositoryTaggerCacheClient({
    @required this.delegate,
  });

  final RepositoryTaggerClient delegate;

  Map<int, List<SimpleRepository>> _cachedStarredRepos = {};

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
  Future<List<SimpleRepository>> starredRepos({int page}) async {
    if (!_cachedStarredRepos.containsKey(page)) {
      final repos = await delegate.starredRepos(page: page);

      _cachedStarredRepos[page] = repos;
    }

    return _cachedStarredRepos[page];
  }

  @override
  Future<List<UserTag>> userTags() => delegate.userTags();
}
