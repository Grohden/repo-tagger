part of 'repository_tagger_client.dart';

@JsonSerializable()
class UserPasswordCredential {
  UserPasswordCredential({this.name, this.password});

  final String name;
  final String password;

  factory UserPasswordCredential.fromJson(Map<String, dynamic> json) =>
      _$UserPasswordCredentialFromJson(json);

  Map<String, dynamic> toJson() => _$UserPasswordCredentialToJson(this);
}

@JsonSerializable()
class RegisterUser {
  RegisterUser({
    @required this.name,
    @required this.displayName,
    @required this.password,
  });

  final String name;
  final String displayName;
  final String password;

  factory RegisterUser.fromJson(Map<String, dynamic> json) =>
      _$RegisterUserFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterUserToJson(this);
}

@JsonSerializable()
class SourceRepository {
  SourceRepository(
      {@required this.id,
      @required this.name,
      @required this.description,
      @required this.url,
      @required this.language,
      @required this.stargazersCount});

  final int id;
  final String name;
  final String description;
  final String url;

  @JsonKey(nullable: true)
  final String language;

  @JsonKey(name: 'stargazers_count')
  final int stargazersCount;

  factory SourceRepository.fromJson(Map<String, dynamic> json) =>
      _$SourceRepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$SourceRepositoryToJson(this);
}

@JsonSerializable()
class UserTag {
  UserTag({@required this.id, @required this.name});

  final int id;
  final String name;

  factory UserTag.fromJson(Map<String, dynamic> json) =>
      _$UserTagFromJson(json);

  Map<String, dynamic> toJson() => _$UserTagToJson(this);
}
