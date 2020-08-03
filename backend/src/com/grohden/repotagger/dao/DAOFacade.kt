package com.grohden.repotagger.dao

import com.grohden.repotagger.dao.tables.*
import org.jetbrains.annotations.TestOnly
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction

/**
 * Dao interface can be used to provide concrete implementations
 * for data sources
 *
 * Currently it's only used in the DB facade
 *
 * Note: This will not scale well with
 * various entities, so it's better create entity specialized
 * DAO's.
 */
interface DAOFacade {
    /**
     * Initiate tables
     */
    fun init()

    /**
     * Finds a user repository by a given github id, or null if not found
     */
    fun findUserRepositoryByGithubId(userGithubId: Int, repoGithubId: Int): SourceRepositoryDTO?

    /**
     * Creates a user tag relation with a repository
     *
     * Note: repo id refers to internal repo id, not githubRepoId!
     */
    fun createTagRelationToRepository(tagId: Int, repoId: Int)

    /**
     * Removes a user tag relation with a repository
     *
     * Note: repo id refers to internal repo id, not githubRepoId!
     */
    fun removeUserTagFromRepository(tagId: Int, repoId: Int)

    /**
     * Creates a source repository related to a specific user
     */
    fun createUserRepository(
        userGithubId: Int,
        repoGithubId: Int,
        name: String,
        ownerName: String,
        htmlUrl: String,
        description: String?,
        language: String?,
        stargazersCount: Int,
        forksCount: Int
    ): SourceRepositoryDTO

    /**
     * Find all repositories related to a user and a tag
     */
    fun findRepositoriesByUserTag(userGithubId: Int, tagId: Int): List<SourceRepositoryDTO>

    /**
     * Finds or creates a new tag associated to a user
     */
    fun createOrFindUserTag(userGithubId: Int, tagName: String): UserTagDTO

    /**
     * Creates a user tag
     */
    fun createUserTag(userGithubId: Int, tagName: String): UserTagDTO

    /**
     * Finds all tags that a user has created in a repository
     *
     * Note: repo id refers to internal repo id, not githubRepoId!
     */
    fun findUserTagsByRepository(userGithubId: Int, repoId: Int): List<UserTagDTO>

    /**
     * Finds a single tag that a user has created
     */
    fun findUserTagById(userGithubId: Int, tagId: Int): UserTagDTO?

    /**
     * Finds all tags that a user has created
     */
    fun findUserTags(userGithubId: Int): List<UserTagDTO>
}


class EntityNotFound(subject: String) : Throwable("Entity $subject not found")

class DAOFacadeDatabase(
    private val isLogEnabled: Boolean = false,
    private val db: Database
) : DAOFacade {
    override fun init() = transaction(db) {
        if (isLogEnabled) {
            addLogger(StdOutSqlLogger)
        }

        // Create the used tables
        SchemaUtils.create(
            UserTagsTable,
            SourceRepositoryTable,
            SourceRepoUserTagTable
        )
    }


    override fun findUserRepositoryByGithubId(
        userGithubId: Int,
        repoGithubId: Int
    ): SourceRepositoryDTO? = transaction(db) {
        SourceRepositoryDAO
            .find {
                SourceRepositoryTable.repositoryGithubId eq repoGithubId and
                        (SourceRepositoryTable.userGithubId eq userGithubId)
            }
            .firstOrNull()
            ?.let(::SourceRepositoryDTO)
    }

    override fun createTagRelationToRepository(
        tagId: Int,
        repoId: Int
    ): Unit = transaction(db) {
        val tag = UserTagDAO.findById(tagId)
            ?: throw EntityNotFound("UserTag")
        val repository = SourceRepositoryDAO.findById(repoId)
            ?: throw EntityNotFound("SourceRepository")

        SourceRepoUserTagTable.insert {
            it[this.repository] = repository.id
            it[this.tag] = tag.id
        }
    }

    override fun removeUserTagFromRepository(
        tagId: Int,
        repoId: Int
    ): Unit = transaction(db) {
        // Limit is just a sanity check..
        SourceRepoUserTagTable.deleteWhere(limit = 1) {
            SourceRepoUserTagTable.repository eq repoId and
                    (SourceRepoUserTagTable.tag eq tagId)
        }
    }

    override fun createOrFindUserTag(
        userGithubId: Int,
        tagName: String
    ): UserTagDTO = transaction(db) {
        UserTagDAO
            .find {
                UserTagsTable.tagName eq tagName and
                        (UserTagsTable.userGithubId eq userGithubId)
            }
            .singleOrNull()
            ?.let(::UserTagDTO)
            ?: createUserTag(userGithubId, tagName)
    }

    override fun findRepositoriesByUserTag(
        userGithubId: Int,
        tagId: Int
    ): List<SourceRepositoryDTO> = transaction(db) {
        (SourceRepositoryTable innerJoin SourceRepoUserTagTable)
            .slice(SourceRepositoryTable.columns)
            .select {
                SourceRepoUserTagTable.repository eq SourceRepositoryTable.id and
                        (SourceRepoUserTagTable.tag eq tagId) and
                        (SourceRepositoryTable.userGithubId eq userGithubId)
            }
            .let { SourceRepositoryDAO.wrapRows(it) }
            .toList()
            .toDTOList()
    }

    override fun createUserTag(
        userGithubId: Int,
        tagName: String
    ): UserTagDTO = transaction(db) {
        UserTagDAO.new {
            this.tagName = tagName
            this.userGithubId = userGithubId
        }.let(::UserTagDTO)
    }

    override fun createUserRepository(
        userGithubId: Int,
        repoGithubId: Int,
        name: String,
        ownerName: String,
        htmlUrl: String,
        description: String?,
        language: String?,
        stargazersCount: Int,
        forksCount: Int
    ): SourceRepositoryDTO = transaction(db) {
        SourceRepositoryDAO.new {
            this.userGithubId = userGithubId
            this.repositoryGithubId = repoGithubId
            this.name = name
            this.ownerName = ownerName
            this.description = description
            this.htmlUrl = htmlUrl
            this.language = language
            this.stargazersCount = stargazersCount
            this.forksCount = forksCount
        }.let(::SourceRepositoryDTO)
    }

    override fun findUserTagsByRepository(
        userGithubId: Int,
        repoId: Int
    ): List<UserTagDTO> = transaction(db) {
        (UserTagsTable innerJoin SourceRepoUserTagTable)
            .slice(UserTagsTable.columns)
            .select {
                SourceRepoUserTagTable.tag eq UserTagsTable.id and
                        (SourceRepoUserTagTable.repository eq repoId) and
                        (UserTagsTable.userGithubId eq userGithubId)
            }
            .let { UserTagDAO.wrapRows(it) }
            .toList()
            .toDTOList()
    }

    override fun findUserTagById(
        userGithubId: Int,
        tagId: Int
    ): UserTagDTO? = transaction(db) {
        UserTagsTable
            .select {
                UserTagsTable.id eq tagId and (UserTagsTable.userGithubId eq userGithubId)
            }
            .let { UserTagDAO.wrapRows(it) }
            .firstOrNull()
            ?.let(::UserTagDTO)
    }

    override fun findUserTags(userGithubId: Int): List<UserTagDTO> = transaction(db) {
        UserTagDAO
            .find { UserTagsTable.userGithubId eq userGithubId }
            .toList()
            .toDTOList()
    }


    @TestOnly
    fun dropAll() = transaction(db) {
        SchemaUtils.drop(
            UserTagsTable,
            SourceRepositoryTable,
            SourceRepoUserTagTable
        )
    }
}