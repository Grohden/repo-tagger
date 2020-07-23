package com.grohden.repotagger.dao

import com.grohden.repotagger.Password

data class CreateUserInput(
    val name: String,
    val displayName: String,
    val password: Password
)

data class CreateTagInput(
    val tagName: String,
    val repoGithubId: Int
)