package com.grohden.repotagger.dao

import com.grohden.repotagger.PasswordHash
import com.grohden.repotagger.dao.tables.*
import io.ktor.auth.UserPasswordCredential
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
interface DAOFacade : Closeable {
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
    fun findUserRepositoryByGithubId(
        user: User,
        githubId: Int
    ): SourceRepositoryDAO?

    /**
     * TODO
     */
    fun findUserRepositories(userId: Int): List<SourceRepositoryDAO>


    /**
     * Associates a user tag to a repository
     *
     * [tag] the tag to be associated
     * [repository] the repository to be associated
     */
    fun addUserTagInRepository(tag: UserTagDAO, repository: SourceRepositoryDAO)

    /**
     * Creates a source repository related to a specific user
     */
    fun createUserRepository(
        user: User,
        name: String,
        githubId: Int,
        description: String,
        url: String
    ): SourceRepositoryDAO

    fun findRepositoriesByUserTag(
        userId: Int,
        tagId: Int
    ): List<SourceRepositoryDAO>

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
     *
     * [user] the user which own this tag
     * [name] the name of the tag
     */
    fun createOrFindUserTag(user: User, name: String): UserTagDAO

    /**
     * Creates a user tag
     *
     * [user] the user which will own this tag
     * [name] the name of the tag
     */
    fun createUserTag(user: User, name: String): UserTagDAO

    fun findUserTagsByRepository(
        userId: Int,
        repositoryId: Int
    ): List<UserTagDTO>

    /**
     * Finds all tags that a user has created
     *
     * [user] the user that owns these tags
     */
    fun findUserTags(user: User): List<UserTagDAO>
}


class EntityNotFound(subject: String) : Throwable("Entity $subject not found")

class DAOFacadeDatabase(private val db: Database) : DAOFacade {
    override fun init() = transaction(db) {
        // Create the used tables
        addLogger(StdOutSqlLogger)
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
    ): SourceRepositoryDAO? = transaction(db) {
        SourceRepositoryDAO.find {
            SourceRepositoryTable.githubId eq githubId and
                    (SourceRepositoryTable.user eq user.id)
        }.firstOrNull()
    }

    override fun findUserRepositories(userId: Int): List<SourceRepositoryDAO> = transaction(db) {
        TODO()
    }

    override fun addUserTagInRepository(
        tag: UserTagDAO,
        repository: SourceRepositoryDAO
    ): Unit = transaction(db) {
        SourceRepoUserTagTable.insert {
            it[this.repository] = repository.id
            it[this.tag] = tag.id
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

    override fun createOrFindUserTag(user: User, name: String): UserTagDAO = transaction(db) {
        UserTagDAO
            .find { UserTagsTable.name eq name }
            .singleOrNull()
            ?: createUserTag(user, name)
    }

    override fun findRepositoriesByUserTag(
        userId: Int,
        tagId: Int
    ): List<SourceRepositoryDAO> = transaction(db) {
        (SourceRepositoryTable innerJoin SourceRepoUserTagTable)
            .slice(SourceRepositoryTable.columns)
            .select {
                SourceRepoUserTagTable.repository eq SourceRepositoryTable.id and
                        (SourceRepoUserTagTable.tag eq tagId) and
                        (SourceRepositoryTable.user eq userId)
            }
            .let { SourceRepositoryDAO.wrapRows(it) }
            .toList()
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

    override fun createUserTag(
        user: User,
        name: String
    ): UserTagDAO = transaction(db) {
        UserTagDAO.new {
            this.user = user
            this.name = name
        }
    }

    override fun createUserRepository(
        user: User,
        name: String,
        githubId: Int,
        description: String,
        url: String
    ): SourceRepositoryDAO = transaction(db) {
        SourceRepositoryDAO.new {
            this.user = user
            this.name = name
            this.githubId = githubId
            this.url = url
            this.description = description
        }
    }

    override fun findUserTags(user: User): List<UserTagDAO> = transaction(db) {
        UserTagDAO
            .find { UserTagsTable.user eq user.id }
            // Eager fetch, for testing.
            .toList()
    }

    override fun close() {}
}