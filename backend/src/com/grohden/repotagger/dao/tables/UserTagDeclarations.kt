package com.grohden.repotagger.dao.tables

import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable

object UserTagsTable : IntIdTable(name = "user_tags") {
    val tagName = text("name")
    val userGithubId = integer("user_github_id")
}

class UserTagDAO(id: EntityID<Int>) : IntEntity(id) {
    companion object : IntEntityClass<UserTagDAO>(UserTagsTable)

    var tagName by UserTagsTable.tagName
    var userGithubId by UserTagsTable.userGithubId
}


fun List<UserTagDAO>.toDTOList(): List<UserTagDTO> {
    return map(::UserTagDTO)
}

data class UserTagDTO(
    val tagId: Int,
    val tagName: String,
    val userGithubId: Int
) {
    constructor(dao: UserTagDAO) : this(
        tagId = dao.id.value,
        tagName = dao.tagName,
        userGithubId = dao.userGithubId
    )
}