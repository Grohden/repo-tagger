package com.grohden.repotagger.dao.tables

import org.jetbrains.exposed.dao.Entity
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.sql.Table

/**
 * Represents a many-to-many relationship between
 * a tags and repositories
 */
object SourceRepoUserTagTable : Table("source_repository_user_tag") {
    val repository = reference("repository", SourceRepositoryTable)
    val tag = reference("user_tag", UserTagsTable)

    override val primaryKey = PrimaryKey(
        repository,
        tag,
        name = "PK_SourceRepositoryUserTag_sr_ut"
    )
}

class SourceRepoUserTagDAO(id: EntityID<String>) : Entity<String>(id) {
    var tag by UserTagDAO referencedOn
            SourceRepoUserTagTable.tag

    var repository by SourceRepositoryDAO referencedOn
            SourceRepoUserTagTable.repository
}