package com.grohden.repotagger.cache

import org.amshove.kluent.shouldBe
import org.amshove.kluent.shouldBeEqualTo
import kotlin.test.Test

class LRUCacheTest {
    @Test
    fun `should not grow with duplicated keys`() {
        val instance = LRUCache<String, String>(4)

        instance.apply {
            put("bazz", "1")
            put("bar", "1")
            put("bar", "2")
            put("bar", "3")
        }

        instance.size shouldBe 2
    }

    @Test
    fun `should respect capacity`() {
        val instance = LRUCache<String, String>(4)

        instance.apply {
            put("1", "1")
            put("2", "1")
            put("3", "1")
            put("4", "1")
            put("5", "1")
        }

        instance.size shouldBe 4
    }

    @Test
    fun `should update cache contents for same key`() {
        val instance = LRUCache<String, String>(4)

        instance.apply {
            put("bar", "1")
            put("bar", "2")
            put("bar", "3")
        }

        instance.get("bar") shouldBeEqualTo "3"
    }

    @Test
    fun `should evict last updated when at limit`() {
        val instance = LRUCache<String, String>(4)

        instance.apply {
            put("1", "1")
            put("2", "2")
            put("3", "3")
            put("4", "4")
            put("5", "5")
        }

        instance.get("1") shouldBe null
        instance.get("2") shouldBe "2"
        instance.get("5") shouldBe "5"
    }

}
