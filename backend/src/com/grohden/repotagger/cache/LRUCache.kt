package com.grohden.repotagger.cache


private data class Node<K, V>(
    val key: K,
    val value: V,
    var next: Node<K, V>? = null,
    var prev: Node<K, V>? = null
)

/**
 * Simple LRU cache (I think)
 *
 * This is basically a linked list with a replacement
 * and get algorithm that reposition it's head and tail
 */
class LRUCache<K, V>(
    private val capacity: Int
) {
    val size get() = cache.size

    private var head: Node<K, V>? = null
    private var tail: Node<K, V>? = null
    private val cache: HashMap<K, Node<K, V>> = hashMapOf()

    private fun replaceWithNewHead(node: Node<K, V>) {
        if (head == null) {
            node.prev = tail
            node.next = null
            head = node

            return
        }

        head?.takeIf { node.key != it.key }?.let { oldHead ->
            oldHead.next = node
            node.prev = oldHead
            node.next = null
            head = node
        }
    }

    private fun replaceWithNewTail(node: Node<K, V>) {
        if (tail == null) {
            node.next = head
            node.prev = null
            tail = node

            return
        }

        tail?.takeIf { node.key != it.key }?.let { oldTail ->
            oldTail.prev = node
            node.next = oldTail
            node.prev = null
            tail = node
        }
    }

    fun get(key: K): V? {
        val node = cache[key] ?: return null

        replaceWithNewHead(node)

        return node.value
    }


    /**
     * Similar to [get] but uses a default provider
     * in case the value is not found in cache, and also
     * puts this new value in cache
     *
     * TODO: review the suspend usage
     */
    suspend fun getOrDefaultAndPut(key: K, orElse: suspend () -> V): V {
        return get(key) ?: orElse().also { put(key, it) }
    }

    fun put(key: K, value: V) {
        val node = Node(key, value).also {
            cache[key] = it
        }

        replaceWithNewHead(node)

        if (cache.size >= capacity) {
            cache.remove(tail!!.key)
        }

        (tail ?: node).let(this::replaceWithNewTail)
    }
}