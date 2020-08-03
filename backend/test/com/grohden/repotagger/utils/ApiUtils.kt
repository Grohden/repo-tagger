package com.grohden.repotagger.utils

import com.google.gson.Gson
import com.grohden.repotagger.dao.CreateTagInput
import io.ktor.http.ContentType
import io.ktor.http.HttpMethod
import io.ktor.server.testing.TestApplicationCall
import io.ktor.server.testing.TestApplicationEngine
import io.ktor.server.testing.handleRequest
import io.ktor.server.testing.setBody


fun TestApplicationEngine.createTag(
    input: CreateTagInput
): TestApplicationCall {
    return handleRequest(HttpMethod.Post, "/api/tag/add") {
        withContentType(ContentType.Application.Json)
        setBody(Gson().toJson(input))
    }
}


fun TestApplicationEngine.listAlTags(): TestApplicationCall {
    return handleRequest(HttpMethod.Get, "/api/tag/list") {
        withContentType(ContentType.Application.Json)
    }
}

fun TestApplicationEngine.listRepositoryTags(repoGithubId: Int): TestApplicationCall {
    return handleRequest(
        HttpMethod.Get,
        "/api/repository/${repoGithubId}/tags"
    )
}

fun TestApplicationEngine.listRepositoriesOfATag(tagId: Int): TestApplicationCall {
    return handleRequest(HttpMethod.Get, "/api/tag/${tagId}/repositories") {
        withContentType(ContentType.Application.Json)
    }
}

fun TestApplicationEngine.repositoryDetails(
    repoGithubId: Int
): TestApplicationCall {
    return handleRequest(
        HttpMethod.Get,
        "/api/repository/details/$repoGithubId"
    ) {
        withContentType(ContentType.Application.Json)
    }
}

fun TestApplicationEngine.deleteRepoTag(
    repoGithubId: Int,
    tagId: Int
): TestApplicationCall {
    return handleRequest(
        HttpMethod.Delete,
        "/api/repository/${repoGithubId}/remove-tag/${tagId}"
    )
}