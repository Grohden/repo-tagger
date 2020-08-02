package com.grohden.repotagger.dao.tables

import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable

object UserTagsTable : IntIdTable(name = "user_tags") {
    val name = text("name")
    val user = reference("user", UsersTable)
}

class UserTagDAO(id: EntityID<Int>) : IntEntity(id) {
    companion object : IntEntityClass<UserTagDAO>(UserTagsTable)

    var name by UserTagsTable.name
    var user by User referencedOn UserTagsTable.user
    var repositories by SourceRepositoryDAO via SourceRepoUserTagTable
}


fun List<UserTagDAO>.toDTOList(): List<UserTagDTO> {
    return map(::UserTagDTO)
}

class UserTagDTO(
    val id: Int,
    val name: String
) {
    constructor(dao: UserTagDAO) : this(
        id = dao.id.value,
        name = dao.name
    )
}