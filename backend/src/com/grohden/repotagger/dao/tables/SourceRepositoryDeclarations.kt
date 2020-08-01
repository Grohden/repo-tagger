package com.grohden.repotagger.dao.tables

import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable

/**
 * Represents a github source repository
 *
 * It contains basic data about it
 *
 * FIXME: we don't need to store
 *  name or description, just the githubId should be
 *  enough
 *
 * Note: it's not recommended to expose
 * the id field to api consumers, instead
 * expose the github id and manage this entity based
 * on userId and githubId.
 */
object SourceRepositoryTable : IntIdTable(name = "source_repository") {
    val name = varchar("name", 100)
    val description = text("description")
    val url = text("url")
    val user = reference("user", UsersTable)
    val githubId = integer("github_id")
}

class SourceRepositoryDAO(id: EntityID<Int>) : IntEntity(id) {
    companion object : IntEntityClass<SourceRepositoryDAO>(SourceRepositoryTable)

    var name by SourceRepositoryTable.name
    var githubId by SourceRepositoryTable.githubId
    var description by SourceRepositoryTable.description
    var url by SourceRepositoryTable.url
    var user by User referencedOn SourceRepositoryTable.user
}

fun List<SourceRepositoryDAO>.toDTOList(): List<SourceRepositoryDTO> {
    return map { SourceRepositoryDTO(it) }
}

class SourceRepositoryDTO(
    var name: String,
    var description: String,
    var url: String
) {
    constructor(dao: SourceRepositoryDAO) : this(
        name = dao.name,
        description = dao.description,
        url = dao.url
    )
}
