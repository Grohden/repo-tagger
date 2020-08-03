package com.grohden.repotagger.dao.tables

import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable

/**
 * Represents a github source repository
 *
 * It contains only an association between a user and a repo githubId
 *
 * Note: it's not recommended to expose
 * the id field to api consumers, instead
 * expose the github id and manage this entity based
 * on userId and githubId.
 */
object SourceRepositoryTable : IntIdTable(name = "source_repository") {
    val userGithubId = integer("user_github_id")
    val repositoryGithubId = integer("repository_github_id")
    val name = text("repo_name")
    val ownerName = text("repo_owner_name")
    val htmlUrl = text("repo_url")
    val language = text("repo_language").nullable()
    val description = text("repo_description").nullable()
    val stargazersCount = integer("stargazersCount")
    val forksCount = integer("forksCount")
}

class SourceRepositoryDAO(id: EntityID<Int>) : IntEntity(id) {
    companion object : IntEntityClass<SourceRepositoryDAO>(SourceRepositoryTable)

    var userGithubId by SourceRepositoryTable.userGithubId
    var repositoryGithubId by SourceRepositoryTable.repositoryGithubId
    var name by SourceRepositoryTable.name
    var ownerName by SourceRepositoryTable.ownerName
    var htmlUrl by SourceRepositoryTable.htmlUrl
    var language by SourceRepositoryTable.language
    var description by SourceRepositoryTable.description
    var stargazersCount by SourceRepositoryTable.stargazersCount
    var forksCount by SourceRepositoryTable.forksCount
}

fun List<SourceRepositoryDAO>.toDTOList(): List<SourceRepositoryDTO> {
    return map { SourceRepositoryDTO(it) }
}

data class SourceRepositoryDTO(
    val repoId: Int,
    val userGithubId: Int,
    val repositoryGithubId: Int,
    val name: String,
    val ownerName: String,
    val htmlUrl: String,
    val language: String?,
    val description: String?,
    val stargazersCount: Int,
    val forksCount: Int
) {
    constructor(dao: SourceRepositoryDAO) : this(
        repoId = dao.id.value,
        userGithubId = dao.userGithubId,
        repositoryGithubId = dao.repositoryGithubId,
        name = dao.name,
        ownerName = dao.ownerName,
        htmlUrl = dao.htmlUrl,
        language = dao.language,
        description = dao.description,
        stargazersCount = dao.stargazersCount,
        forksCount = dao.forksCount
    )
}
