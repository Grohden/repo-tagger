package com.grohden.repotagger

import com.grohden.repotagger.api.DetailedRepository
import com.grohden.repotagger.api.SimpleRepository
import com.grohden.repotagger.api.TagRepositoriesResponse
import com.grohden.repotagger.dao.CreateTagInput
import com.grohden.repotagger.dao.tables.UserTagDTO
import com.grohden.repotagger.extensions.fromJson
import com.grohden.repotagger.utils.*
import io.ktor.http.HttpStatusCode
import io.ktor.server.testing.cookiesSession
import org.amshove.kluent.*
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test

class RepositoryTest : BaseTest() {
    private val defaultRepoId = 130309267

    @BeforeTest
    fun setupBefore() {
        memoryDao.init()
    }

    @AfterTest
    fun setupAfter() {
        memoryDao.dropAll()
    }

    @Test
    fun `should list all tags of a repository`() = testApp {
        cookiesSession {
            login()

            val tags = listOf(
                CreateTagInput(
                    tagName = "javascript",
                    repoGithubId = defaultRepoId
                ),
                CreateTagInput(
                    tagName = "dart",
                    repoGithubId = defaultRepoId
                )
            ).also { list ->
                list.forEach { createTag(it) }
            }

            repositoryDetails(defaultRepoId).apply {
                requestHandled shouldBe true
                response.status() shouldBeEqualTo HttpStatusCode.OK
                response.content shouldNotBe null

                val remoteTags = response.content!!.let {
                    gson.fromJson<DetailedRepository>(it)
                }.userTags.map { it.tagName }

                remoteTags shouldContainAll (tags.map { it.tagName })
            }
        }
    }


    @Test
    fun `should list all repositories of a tag`() = testApp {
        cookiesSession {
            login()

            val firstTag = createTag(
                CreateTagInput(
                    tagName = "dart",
                    repoGithubId = defaultRepoId
                )
            ).let { gson.fromJson<UserTagDTO>(it.response.content!!) }

            val secondTag = createTag(
                CreateTagInput(
                    tagName = "dart",
                    repoGithubId = defaultRepoId + 1
                )
            ).let { gson.fromJson<UserTagDTO>(it.response.content!!) }

            // Should be the same tag
            firstTag.tagId shouldBeEqualTo secondTag.tagId


            listRepositoriesOfATag(firstTag.tagId).apply {
                requestHandled shouldBe true
                response.status() shouldBeEqualTo HttpStatusCode.OK
                response.content shouldNotBe null

                val remoteTags = response.content!!.let {
                    gson.fromJson<TagRepositoriesResponse>(it)
                }.repositories.map { it.githubId }

                remoteTags shouldContainAll listOf(
                    defaultRepoId,
                    defaultRepoId + 1
                )
            }
        }
    }


    @Test
    fun `should delete a tag of a repository`() = testApp {
        cookiesSession {
            login()
            val tag = createTag(
                CreateTagInput(
                    tagName = "dart",
                    repoGithubId = defaultRepoId
                )
            ).let { gson.fromJson<UserTagDTO>(it.response.content!!) }

            deleteRepoTag(defaultRepoId, tag.tagId).apply {
                requestHandled shouldBe true
                response.status() shouldBeEqualTo HttpStatusCode.OK
                response.content shouldBe null
            }


            listRepositoryTags(defaultRepoId).apply {
                val tags = gson.fromJson<List<UserTagDTO>>(response.content!!)

                tags.shouldBeEmpty()
            }
        }
    }

    @Test
    fun `should delete a orphan tag from db`() = testApp {
        cookiesSession {
            login()
            val tag = createTag(
                CreateTagInput(
                    tagName = "dart",
                    repoGithubId = defaultRepoId
                )
            ).let { gson.fromJson<UserTagDTO>(it.response.content!!) }

            deleteRepoTag(defaultRepoId, tag.tagId).apply {
                requestHandled shouldBe true
                response.status() shouldBeEqualTo HttpStatusCode.OK
                response.content shouldBe null
            }


            listAllTags().apply {
                val tags = gson.fromJson<List<UserTagDTO>>(response.content!!)

                tags.shouldBeEmpty()
            }
        }
    }

    @Test
    fun `should respond error for a not found tag`() = testApp {
        cookiesSession {
            login()
            deleteRepoTag(defaultRepoId, 42).apply {
                requestHandled shouldBe true
                response.status() shouldBeEqualTo HttpStatusCode.NotFound
                response.content shouldBe null
            }
        }
    }
}
