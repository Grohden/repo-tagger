package com.grohden.repotagger.dao.tables

import io.ktor.auth.Principal
import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable

object UsersTable : IntIdTable(name = "users") {
    val name = varchar("name", 50).uniqueIndex()
    val displayName = varchar("display_name", 256)
    val passwordHash = text("password_hash")
}

class User(id: EntityID<Int>) : IntEntity(id), Principal {
    companion object : IntEntityClass<User>(UsersTable)

    var name by UsersTable.name
    var displayName by UsersTable.displayName
    var passwordHash by UsersTable.passwordHash

    // To be able to mock.
    val idForJWT by lazy { id.value }
}
