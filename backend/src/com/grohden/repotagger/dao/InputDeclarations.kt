package com.grohden.repotagger.dao


data class CreateUserInput(
    val name: String,
    val password: String
)

data class CreateTagInput(
    val tagName: String,
    val repoGithubId: Int
)