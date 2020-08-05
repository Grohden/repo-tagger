part of 'repository_tagger_client.dart';

@JsonSerializable()
class CreateTagInput {
  CreateTagInput({
    this.tagName,
    this.repoGithubId,
  });

  final String tagName;
  final int repoGithubId;

  factory CreateTagInput.fromJson(Map<String, dynamic> json) =>
      _$CreateTagInputFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTagInputToJson(this);
}

/// Represents a detailed repository, meaning that
/// it contains user related values (tags)
@JsonSerializable()
class DetailedRepository {
  DetailedRepository({
    @required this.githubId,
    @required this.name,
    @required this.description,
    @required this.htmlUrl,
    @required this.language,
    @required this.ownerName,
    @required this.stargazersCount,
    @required this.forksCount,
    @required this.userTags,
    @required this.readmeContents,
  });

  int githubId;
  String name;
  String description;
  String htmlUrl;
  String language;
  String ownerName;
  int stargazersCount;
  int forksCount;
  List<UserTag> userTags;
  String readmeContents;

  factory DetailedRepository.fromJson(Map<String, dynamic> json) =>
      _$DetailedRepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$DetailedRepositoryToJson(this);
}

/// Represents a more simpler repository, meaning
/// that it has the necessary data to be used
/// on a list
@JsonSerializable()
class SimpleRepository {
  SimpleRepository({
    @required this.githubId,
    @required this.name,
    @required this.description,
    @required this.url,
    @required this.language,
    @required this.ownerName,
    @required this.stargazersCount,
    @required this.forksCount,
  });

  int githubId;
  String name;
  String description;
  String url;
  String language;
  String ownerName;
  int stargazersCount;
  int forksCount;

  factory SimpleRepository.fromJson(Map<String, dynamic> json) =>
      _$SimpleRepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$SimpleRepositoryToJson(this);
}

@JsonSerializable()
class UserTag {
  UserTag({@required this.tagId, @required this.tagName});

  final int tagId;
  final String tagName;

  factory UserTag.fromJson(Map<String, dynamic> json) =>
      _$UserTagFromJson(json);

  Map<String, dynamic> toJson() => _$UserTagToJson(this);
}
