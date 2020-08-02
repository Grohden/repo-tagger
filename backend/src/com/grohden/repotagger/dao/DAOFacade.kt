package com.grohden.repotagger.dao

import com.grohden.repotagger.PasswordHash
import com.grohden.repotagger.dao.tables.*
import io.ktor.auth.UserPasswordCredential
import org.jetbrains.annotations.TestOnly
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import java.io.Closeable

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
     * Create a user based on [user]
     */
    fun createUser(user: CreateUserInput): User

    /**
     * Finds a user repository by a given github id, or null if not found
     *
     * [githubId] the github id for this repository
     */
    fun findUserRepositoryByGithubId(user: User, githubId: Int): SourceRepositoryDTO?

    /**
     * Creates a user tag relation with a repository
     */
    fun createTagRelationToRepository(tagId: Int, repositoryId: Int)

    /**
     * Removes a user tag relation with a repository
     */
    fun removeUserTagFromRepository(tagId: Int, repositoryId: Int)

    /**
     * Creates a source repository related to a specific user
     */
    fun createUserRepository(
        user: User,
        name: String,
        githubId: Int,
        description: String,
        url: String
    ): SourceRepositoryDTO

    /**
     * Find all repositories related to a user and a tag
     */
    fun findRepositoriesByUserTag(userId: Int, tagId: Int): List<SourceRepositoryDTO>

    /**
     * Find a user based on [credentials], which means that
     * at least userName and password should be matching
     *
     * Note: Implementations are expected to be applying a hash
     * function to compare the given password.
     */
    fun findUserByCredentials(credentials: UserPasswordCredential): User?

    /**
     * Find a user based on it's id
     */
    fun findUserById(id: Int): User?

    /**
     * Find a user based on it's name
     */
    fun findUserByUserName(name: String): User?

    /**
     * Finds or creates a new tag associated to a user
     */
    fun createOrFindUserTag(user: User, tagName: String): UserTagDTO

    /**
     * Creates a user tag
     */
    fun createUserTag(user: User, tagName: String): UserTagDTO

    /**
     * Finds all tags that a user has created in a repository
     */
    fun findUserTagsByRepository(userId: Int, repositoryId: Int): List<UserTagDTO>

    /**
     * Finds a single tag that a user has created
     */
    fun findUserTagById(userId: Int, tagId: Int): UserTagDTO?

    /**
     * Finds all tags that a user has created
     */
    fun findUserTags(user: User): List<UserTagDTO>
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
            UsersTable,
            UserTagsTable,
            SourceRepositoryTable,
            SourceRepoUserTagTable
        )
    }

    override fun createUser(user: CreateUserInput): User = transaction(db) {
        User.new {
            name = user.name.toLowerCase()
            displayName = user.displayName
            passwordHash = PasswordHash.hash(user.password)
        }
    }

    override fun findUserRepositoryByGithubId(
        user: User,
        githubId: Int
    ): SourceRepositoryDTO? = transaction(db) {
        SourceRepositoryDAO
            .find {
                SourceRepositoryTable.githubId eq githubId and
                        (SourceRepositoryTable.user eq user.id)
            }
            .firstOrNull()
            ?.let(::SourceRepositoryDTO)
    }

    override fun createTagRelationToRepository(
        tagId: Int,
        repositoryId: Int
    ): Unit = transaction(db) {
        val tag = UserTagDAO.findById(tagId)
            ?: throw EntityNotFound("UserTag")
        val repository = SourceRepositoryDAO.findById(repositoryId)
            ?: throw EntityNotFound("SourceRepository")

        SourceRepoUserTagTable.insert {
            it[this.repository] = repository.id
            it[this.tag] = tag.id
        }
    }

    override fun removeUserTagFromRepository(
        tagId: Int,
        repositoryId: Int
    ): Unit = transaction(db) {
        // Limit is just a sanity check..
        SourceRepoUserTagTable.deleteWhere(limit = 1) {
            SourceRepoUserTagTable.repository eq repositoryId and
                    (SourceRepoUserTagTable.tag eq tagId)
        }
    }

    override fun findUserByCredentials(credentials: UserPasswordCredential): User? = transaction(db) {
        val hashed = PasswordHash.hash(credentials.password)
        val effectiveName = credentials.name.toLowerCase()

        User.find {
            UsersTable.name eq effectiveName and (UsersTable.passwordHash eq hashed)
        }.firstOrNull()
    }

    override fun findUserById(id: Int): User? = transaction(db) {
        User.findById(id)
    }

    override fun findUserByUserName(name: String): User? = transaction(db) {
        User
            .find { UsersTable.name eq name.toLowerCase() }
            .firstOrNull()
    }

    override fun createOrFindUserTag(user: User, tagName: String): UserTagDTO = transaction(db) {
        UserTagDAO
            .find { UserTagsTable.name eq tagName }
            .singleOrNull()
            ?.let(::UserTagDTO)
            ?: createUserTag(user, tagName)
    }

    override fun findRepositoriesByUserTag(
        userId: Int,
        tagId: Int
    ): List<SourceRepositoryDTO> = transaction(db) {
        (SourceRepositoryTable innerJoin SourceRepoUserTagTable)
            .slice(SourceRepositoryTable.columns)
            .select {
                SourceRepoUserTagTable.repository eq SourceRepositoryTable.id and
                        (SourceRepoUserTagTable.tag eq tagId) and
                        (SourceRepositoryTable.user eq userId)
            }
            .let { SourceRepositoryDAO.wrapRows(it) }
            .toList()
            .toDTOList()
    }

    override fun createUserTag(user: User, tagName: String): UserTagDTO = transaction(db) {
        UserTagDAO.new {
            this.user = user
            this.name = tagName
        }.let(::UserTagDTO)
    }

    override fun createUserRepository(
        user: User,
        name: String,
        githubId: Int,
        description: String,
        url: String
    ): SourceRepositoryDTO = transaction(db) {
        SourceRepositoryDAO.new {
            this.user = user
            this.name = name
            this.githubId = githubId
            this.url = url
            this.description = description
        }.let(::SourceRepositoryDTO)
    }

    override fun findUserTagsByRepository(
        userId: Int,
        repositoryId: Int
    ): List<UserTagDTO> = transaction(db) {
        (UserTagsTable innerJoin SourceRepoUserTagTable)
            .slice(UserTagsTable.columns)
            .select {
                SourceRepoUserTagTable.tag eq UserTagsTable.id and
                        (SourceRepoUserTagTable.repository eq repositoryId) and
                        (UserTagsTable.user eq userId)
            }
            .let { UserTagDAO.wrapRows(it) }
            .toList()
            .toDTOList()
    }

    override fun findUserTagById(
        userId: Int,
        tagId: Int
    ): UserTagDTO? = transaction(db) {
        UserTagsTable
            .select {
                UserTagsTable.id eq tagId and
                        (UserTagsTable.user eq userId)
            }
            .let { UserTagDAO.wrapRows(it) }
            .firstOrNull()
            ?.let(::UserTagDTO)
    }

    override fun findUserTags(user: User): List<UserTagDTO> = transaction(db) {
        UserTagDAO
            .find { UserTagsTable.user eq user.id }
            .toList()
            .toDTOList()
    }


    @TestOnly
    fun dropAll() = transaction(db) {
        SchemaUtils.drop(
            UsersTable,
            UserTagsTable,
            SourceRepositoryTable,
            SourceRepoUserTagTable
        )
    }
}