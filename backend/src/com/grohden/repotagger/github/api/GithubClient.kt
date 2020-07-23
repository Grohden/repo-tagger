package com.grohden.repotagger.github.api

import com.google.gson.annotations.SerializedName
import io.ktor.client.HttpClient
import io.ktor.client.request.HttpRequestBuilder
import io.ktor.client.request.get
import io.ktor.client.request.header

data class GithubRepository(
    val id: Int,
    val name: String,
    val description: String,
    val url: String,
    val language: String?,

    @SerializedName("stargazers_count")
    val stargazersCount: Int
)

typealias GithubRepositories = List<GithubRepository>

data class UserData(
    val id: Int,
    val login: String
)

private const val API_BASE = "https://api.github.com"

/**
 * Github api client
 *
 * Provides BASIC interaction with github api,
 * responses should only care about needed data,
 * ignoring not required ones
 */
class GithubClient(private val client: HttpClient) {
    private fun HttpRequestBuilder.withV3Accept() {
        header("accept", "application/vnd.github.v3+json")
    }

    /**
     * Lists repositories a user has starred.
     *
     * https://docs.github.com/en/rest/reference/activity#list-repositories-starred-by-a-user
     */
    suspend fun userStarred(userName: String): GithubRepositories = client.get(
        urlString = "$API_BASE/users/$userName/starred"
    ) { withV3Accept() }

    /**
     * Provides publicly available information about someone with a GitHub account.
     *
     * https://docs.github.com/en/rest/reference/users#get-a-user
     */
    suspend fun userData(userName: String): UserData = client.get(
        urlString = "$API_BASE/users/$userName"
    ) { withV3Accept() }

    /**
     * Provides repository info based on it's id
     *
     * Actually not documented. Thx github!
     */
    suspend fun repositoryById(id: Int): GithubRepository = client.get(
        urlString = "$API_BASE/repositories/$id"
    ) { withV3Accept() }
}