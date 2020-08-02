package com.grohden.repotagger.api

import com.google.gson.annotations.SerializedName
import com.grohden.repotagger.dao.DAOFacade
import com.grohden.repotagger.dao.tables.User
import com.grohden.repotagger.dao.tables.UserTagDTO
import com.grohden.repotagger.dao.tables.toDTOList
import com.grohden.repotagger.github.api.GithubClient
import io.ktor.application.call
import io.ktor.auth.authenticate
import io.ktor.auth.authentication
import io.ktor.http.HttpStatusCode
import io.ktor.response.respond
import io.ktor.routing.Route
import io.ktor.routing.delete
import io.ktor.routing.get
import io.ktor.routing.route

/**
 * Represents a detailed repository, meaning that
 * it contains user related values
 *
 * Note: this is basically the same
 * as the [SourceRepository] model, but that model
 * is exclusive for github api, so it shouldn't contain
 * any domain specific data.
 */
data class DetailedRepository(
    val id: Int,
    val name: String,
    val description: String,
    val url: String,
    val language: String?,

    @SerializedName("stargazers_count")
    val stargazersCount: Int,

    @SerializedName("user_tags")
    val userTags: List<UserTagDTO>
)

fun Route.repository(dao: DAOFacade, github: GithubClient) {
    authenticate {
        route("/repository") {
            /**
             * List user starred repositories
             */
            get("/starred") {
                val user = call.authentication.principal<User>()!!
                val starred = github.userStarred(user.name)

                call.respond(starred)
            }

            /**
             * List repositories that are related to the given tag id
             *
             * returns a list of [SourceRepositoryDTO]
             */
            get("/all-by-tag/{tagId}") {
                val tagId = call.parameters["tagId"]!!.toInt()
                val user = call.authentication.principal<User>()!!
                val repos = dao
                    .findRepositoriesByUserTag(user.id.value, tagId)

                call.respond(HttpStatusCode.OK, repos)
            }

            /**
             * List a repository in a more detailed manner given a github id
             *
             * returns a list of [DetailedRepository]
             */
            get("/details/{githubId}") {
                val githubId = call.parameters["githubId"]!!.toInt()
                val user = call.authentication.principal<User>()!!
                val taggerRepo = dao.findUserRepositoryByGithubId(user, githubId)
                val tags = taggerRepo?.let {
                    dao.findUserTagsByRepository(user.id.value, it.id)
                } ?: listOf()
                val githubRepo = github.repositoryById(githubId)

                call.respond(
                    HttpStatusCode.OK, DetailedRepository(
                        id = githubRepo.id,
                        name = githubRepo.name,
                        description = githubRepo.description,
                        url = githubRepo.url,
                        language = githubRepo.language,
                        stargazersCount = githubRepo.stargazersCount,
                        userTags = tags
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
                val user = call.authentication.principal<User>()!!
                val githubId = call.parameters["githubId"]!!.toInt()
                val tagId = call.parameters["userTagId"]!!.toInt()

                val tag = dao.findUserTagById(
                    tagId = tagId,
                    userId = user.id.value
                )!!
                val repo = dao.findUserRepositoryByGithubId(
                    user = user,
                    githubId = githubId
                )!!

                dao.removeUserTagFromRepository(tag.id, repo.id)
                call.respond(HttpStatusCode.OK)
            }
        }
    }
}