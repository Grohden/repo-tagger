package com.grohden.repotagger.github.api

import com.grohden.repotagger.makeDefaultHttpClient
import kotlinx.coroutines.runBlocking
import org.amshove.kluent.shouldNotBeEmpty
import kotlin.test.Ignore
import kotlin.test.Test


/**
 * We don't actually need to test github,
 * but just as a sanity check, I've wrote tests
 * for github returns and the resulting model from
 * [GithubClient]] class
 *
 * They're all ignored and in case you need
 * to be sure everything is ok just remove the
 * ignore annotation.
 */
class GithubClientTest {
    private val client = GithubClient(makeDefaultHttpClient())

    @Ignore("Don't need to test github")
    @Test
    fun `should return starred repos`() {
        val starred = runBlocking {
            client.userStarred("grohden")
        }

        starred.shouldNotBeEmpty()
    }
}
