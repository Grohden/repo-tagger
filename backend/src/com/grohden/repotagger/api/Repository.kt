package com.grohden.repotagger.api

import com.grohden.repotagger.dao.DAOFacade
import com.grohden.repotagger.dao.tables.SourceRepositoryDTO
import com.grohden.repotagger.dao.tables.UserTagDTO
import com.grohden.repotagger.github.api.GithubClient
import com.grohden.repotagger.requireSession
import io.ktor.application.call
import io.ktor.http.HttpStatusCode
import io.ktor.response.respond
import io.ktor.routing.Route
import io.ktor.routing.delete
import io.ktor.routing.get
import io.ktor.routing.route

/**
 * Represents a detailed repository, meaning that
 * it contains user related values (tags)
 */
data class DetailedRepository(
    val githubId: Int,
    val name: String,
    val description: String?,
    val htmlUrl: String,
    val language: String?,
    val ownerName: String,
    val stargazersCount: Int,
    val forksCount: Int,
    val userTags: List<UserTagDTO>,
    val readmeContents: String?
)

/**
 * Represents a more simpler repository, meaning
 * that it has the necessary data to be used
 * on a list
 */
data class SimpleRepository(
    val githubId: Int,
    val name: String,
    val description: String?,
    val language: String?,
    val ownerName: String,
    val stargazersCount: Int,
    val forksCount: Int
)

fun List<SourceRepositoryDTO>.toSimpleRepositoryList(): List<SimpleRepository> {
    return map { repo ->
        SimpleRepository(
            githubId = repo.repositoryGithubId,
            name = repo.name,
            ownerName = repo.ownerName,
            description = repo.description,
            language = repo.language,
            stargazersCount = repo.stargazersCount,
            forksCount = repo.forksCount
        )
    }
}


fun Route.repository(
    dao: DAOFacade,
    githubClient: GithubClient
) {
    route("/repository") {
        /**
         * List user starred repositories
         *
         * return s a list of [SimpleRepository]
         */
        get("/starred") {
            val session = call.requireSession()
            // FIXME: this needs a cache
            val starred = githubClient.userStarred(session.token)
            val list = starred.map { githubRepo ->
                SimpleRepository(
                    githubId = githubRepo.id,
                    name = githubRepo.name,
                    ownerName = githubRepo.owner.login,
                    description = githubRepo.description,
                    language = githubRepo.language,
                    stargazersCount = githubRepo.stargazersCount,
                    forksCount = githubRepo.forksCount
                )
            }

            call.respond(list)
        }

        /**
         * List all tags associated to a repository
         *
         * returns a list of [UserTagDTO]
         */
        get("/{githubId}/tags") {
            val session = call.requireSession()
            val repoGithubId = call.requireIntParam("githubId")
            val taggerRepo = dao.findUserRepositoryByGithubId(
                userGithubId = session.githubUserId,
                repoGithubId = repoGithubId
            )
            val tags = taggerRepo?.let {
                dao.findUserTagsByRepository(
                    userGithubId = session.githubUserId,
                    repoId = taggerRepo.repoId
                )
            } ?: listOf()

            call.respond(HttpStatusCode.OK, tags)
        }

        /**
         * List a repository in a more detailed manner given a github id
         *
         * returns a list of [DetailedRepository]
         */
        get("/details/{githubId}") {
            val repoGithubId = call.requireIntParam("githubId")
            val session = call.requireSession()
            val taggerRepo = dao.findUserRepositoryByGithubId(
                userGithubId = session.githubUserId,
                repoGithubId = repoGithubId
            )
            val tags = taggerRepo?.let {
                dao.findUserTagsByRepository(
                    userGithubId = session.githubUserId,
                    repoId = it.repoId
                )
            } ?: listOf()
            val githubRepo = githubClient.repositoryById(
                id = repoGithubId,
                token = session.token
            )

            // TODO: skip this for tests
            val readme: String? = try {
                githubClient.getFileContents(
                    ownerLogin = githubRepo.owner.login,
                    name = githubRepo.name,
                    defaultBranch = githubRepo.defaultBranch,
                    file = "README.md",
                    token = session.token
                )
            } catch (pokemon: Throwable) {
                // TODO: use default logger instead
                print(pokemon.message)
                null
            }

            call.respond(
                HttpStatusCode.OK, DetailedRepository(
                    githubId = githubRepo.id,
                    name = githubRepo.name,
                    ownerName = githubRepo.owner.login,
                    description = githubRepo.description,
                    htmlUrl = githubRepo.htmlUrl,
                    language = githubRepo.language,
                    stargazersCount = githubRepo.stargazersCount,
                    userTags = tags,
                    readmeContents = readme,
                    forksCount = githubRepo.forksCount
                )
            )
        }

        /**
         * Removes a tag registry from a repository
         *
         * Receives a repository githubId and a userTagId
         *
         * Returns OK response
         */
        delete("{githubId}/remove-tag/{userTagId}") {
            val session = call.requireSession()
            val repoGithubId = call.requireIntParam("githubId")
            val tagId = call.requireIntParam("userTagId")

            val tag = dao.findUserTagById(
                tagId = tagId,
                userGithubId = session.githubUserId
            ) ?: throw NotFound("tag not found")
            val repo = dao.findUserRepositoryByGithubId(
                userGithubId = session.githubUserId,
                repoGithubId = repoGithubId
            ) ?: throw NotFound("repository not found")

            dao.removeUserTagFromRepository(
                tagId = tag.tagId,
                repoId = repo.repoId
            )

            dao.removeIfOrphanTag(tag.tagId)

            call.respond(HttpStatusCode.OK)
        }
    }
}