package com.grohden.repotagger.github.api

import com.google.gson.annotations.SerializedName
import io.ktor.client.HttpClient
import io.ktor.client.request.HttpRequestBuilder
import io.ktor.client.request.forms.submitForm
import io.ktor.client.request.get
import io.ktor.client.request.header
import io.ktor.client.request.url
import io.ktor.http.HttpMethod
import io.ktor.http.Parameters


private const val API_BASE = "https://api.github.com"
private const val RAW_API_BASE = "https://raw.githubusercontent.com"
private const val GITHUB_URL = "https://github.com"


data class RepositoryOwner(
    val id: Int,
    val login: String
)

data class GithubRepository(
    val id: Int,
    val name: String,
    val description: String?,
    val language: String?,
    val topics: List<String>,
    val owner: RepositoryOwner,

    @SerializedName("html_url")
    val htmlUrl: String,

    @SerializedName("default_branch")
    val defaultBranch: String,

    @SerializedName("contents_url")
    val contentsUrl: String,

    @SerializedName("stargazers_count")
    val stargazersCount: Int,

    @SerializedName("forks_count")
    val forksCount: Int
) {

    // May not be really available (no readme)
    // FIXME: this could be improved and built on
    //  on the facade layer (or service when available)
    val readmeUrl: String
        get() = "$RAW_API_BASE/${owner.login}/${name}/${defaultBranch}/README.md"
}

typealias GithubRepositories = List<GithubRepository>


data class AuthResponse(
    @SerializedName("access_token")
    val accessToken: String,

    @SerializedName("redirect_uri")
    val redirectUri: String?
)

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

    private fun HttpRequestBuilder.withToken(token: String) {
        header("Authorization", "Bearer $token")
    }

    /**
     * Lists repositories a user has starred.
     *
     * https://docs.github.com/en/rest/reference/activity#list-repositories-starred-by-the-authenticated-user
     */
    suspend fun userStarred(token: String): GithubRepositories = client.get(
        urlString = "$API_BASE/user/starred"
    ) {
        withV3Accept()
        withToken(token)
    }

    /**
     * Provides a authenticated user info
     *
     * https://docs.github.com/en/rest/reference/users#get-the-authenticated-user
     */
    suspend fun userData(token: String): RepositoryOwner = client.get(
        urlString = "$API_BASE/user"
    ) {
        withV3Accept()
        withToken(token)
    }

    /**
     * Creates the user oauth token
     *
     * https://docs.github.com/en/developers/apps/authorizing-oauth-apps#2-users-are-redirected-back-to-your-site-by-github
     */
    suspend fun accessToken(clientId: String, clientSecret: String, code: String): AuthResponse {
        val params = Parameters.build {
            this["client_id"] = clientId
            this["client_secret"] = clientSecret
            this["code"] = code
        }

        return client.submitForm(formParameters = params) {
            // Lost 1 hour to find out that github
            // doesn't use .api for oauth, nice!
            url("$GITHUB_URL/login/oauth/access_token")
            method = HttpMethod.Post
        }
    }

    /**
     * Provides repository info based on it's id
     *
     * Actually not documented. Thx github!
     */
    suspend fun repositoryById(
        id: Int,
        token: String
    ): GithubRepository = client.get(
        urlString = "$API_BASE/repositories/$id"
    ) {
        withV3Accept()
        withToken(token)
    }

    /**
     * Provides raw file contents from raw.github
     */
    suspend fun getFileContents(
        ownerLogin: String,
        name: String,
        defaultBranch: String,
        file: String,
        token: String
    ): String = client.get(
        urlString = "$RAW_API_BASE/${ownerLogin}/${name}/${defaultBranch}/${file}"
    ) {
        withToken(token)
    }
}