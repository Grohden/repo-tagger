package com.grohden.repotagger

import com.grohden.repotagger.dao.CreateTagInput
import com.grohden.repotagger.dao.tables.UserTagDTO
import com.grohden.repotagger.extensions.fromJson
import com.grohden.repotagger.utils.createTag
import com.grohden.repotagger.utils.listAllTags
import io.ktor.http.HttpStatusCode
import io.ktor.server.testing.cookiesSession
import org.amshove.kluent.shouldBe
import org.amshove.kluent.shouldBeEqualTo
import org.amshove.kluent.shouldContain
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test

class UserTagTest : BaseTest() {
    @BeforeTest
    fun setupBefore() {
        memoryDao.init()
    }

    @AfterTest
    fun setupAfter() {
        memoryDao.dropAll()
    }

    @Test
    fun `should create and list tag`() = testApp {
        cookiesSession {
            login()
            createTag(
                CreateTagInput(
                    tagName = "jojo",
                    repoGithubId = 130309267
                )
            ).apply {
                requestHandled shouldBe true
                response.status() shouldBeEqualTo HttpStatusCode.Created
                response.content.let {
                    gson.fromJson(it, UserTagDTO::class.java)
                }.tagName shouldBeEqualTo "jojo"
            }


            listAllTags().apply {
                requestHandled shouldBe true
                response.status() shouldBeEqualTo HttpStatusCode.OK
                val tags = response.content!!.let {
                    gson.fromJson<List<UserTagDTO>>(it)
                }.map { it.tagName }


                tags shouldContain "jojo"
            }
        }
    }
}
