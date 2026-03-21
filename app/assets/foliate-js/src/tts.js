const blockTags = new Set([
    'article', 'aside', 'audio', 'blockquote', 'caption',
    'details', 'dialog', 'div', 'dl', 'dt', 'dd',
    'figure', 'footer', 'form', 'figcaption',
    'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'header', 'hgroup', 'hr', 'li',
    'main', 'math', 'nav', 'ol', 'p', 'pre', 'section', 'tr',
])

function rangeIsEmpty(range) {
    return range.collapsed || range.toString().trim() === ''
}

const quoteChars = new Set(['"', "'", '“', '”', '‘', '’'])

const isLocalLink = href => {
    if (!href) return false
    const trimmed = href.trim()
    if (!trimmed) return false
    if (trimmed.startsWith('#')) return true
    return !/^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(trimmed)
}

const shouldSkipTextNode = node => {
    const parent = node.parentElement
    if (!parent) return false
    const anchor = parent.closest('a')
    if (!anchor) return false
    return isLocalLink(anchor.getAttribute('href'))
}

const getRangeText = range => {
    const fragment = range.cloneContents()
    const walker = document.createTreeWalker(fragment, NodeFilter.SHOW_TEXT)
    let text = ''
    for (let node = walker.nextNode(); node; node = walker.nextNode()) {
        if (shouldSkipTextNode(node)) continue
        text += node.textContent ?? ''
    }
    return text
}

const findBlockAncestor = node => {
    let el = node.parentElement
    while (el && !blockTags.has(el.tagName?.toLowerCase?.())) {
        el = el.parentElement
    }
    return el ?? node.ownerDocument?.body ?? null
}

const isSentenceTerminator = (char, nextChar) => {
    if (char === '.') {
        if (!nextChar) return true
        if (quoteChars.has(nextChar)) return true
        if (/\s/.test(nextChar)) return true
        return false
    }
    return char === '!' || char === '?' || char === '。' || char === '！' || char === '？'
}

const advancePastQuotes = (text, index) => {
    let end = index
    while (end < text.length && quoteChars.has(text[end])) end++
    return end
}

function* getBlocks(doc) {
    const walker = doc.createTreeWalker(doc.body, NodeFilter.SHOW_TEXT)
    let startNode = null
    let startOffset = 0
    let currentBlock = null
    let lastNode = null
    let lastOffset = 0

    const flushRange = () => {
        if (!startNode || !lastNode) return null
        const range = doc.createRange()
        range.setStart(startNode, startOffset)
        range.setEnd(lastNode, lastOffset)
        startNode = null
        startOffset = 0
        currentBlock = null
        lastNode = null
        lastOffset = 0
        if (rangeIsEmpty(range)) return null
        return range
    }

    for (let node = walker.nextNode(); node; node = walker.nextNode()) {
        if (!node.textContent) continue
        if (shouldSkipTextNode(node)) continue

        const block = findBlockAncestor(node)

        if (!startNode) {
            startNode = node
            startOffset = 0
            currentBlock = block
        } else if (block !== currentBlock) {
            const range = flushRange()
            if (range) yield range
            startNode = node
            startOffset = 0
            currentBlock = block
        }

        const text = node.textContent
        let index = 0
        while (index < text.length) {
            const char = text[index]
            const nextChar = text[index + 1]
            if (isSentenceTerminator(char, nextChar)) {
                const endOffset = advancePastQuotes(text, index + 1)
                const range = doc.createRange()
                range.setStart(startNode, startOffset)
                range.setEnd(node, endOffset)
                if (!rangeIsEmpty(range)) yield range
                startNode = node
                startOffset = endOffset
                lastNode = node
                lastOffset = endOffset
                index = endOffset
                continue
            }
            index += 1
        }

        lastNode = node
        lastOffset = text.length

        if (startNode === node && startOffset === text.length) {
            startNode = null
            startOffset = 0
            currentBlock = null
        }
    }

    const remaining = flushRange()
    if (remaining) yield remaining
}

class ListIterator {
    #arr = []
    #iter
    #index = -1
    #f
    constructor(iter, f = x => x) {
        this.#iter = iter
        this.#f = f
    }
    current() {
        if (this.#arr[this.#index]) return this.#f(this.#arr[this.#index])
    }
    first() {
        const newIndex = 0
        if (this.#arr[newIndex]) {
            this.#index = newIndex
            return this.#f(this.#arr[newIndex])
        }
    }
    last() {
        for (const value of this.#iter) this.#arr.push(value)
        const newIndex = this.#arr.length - 1
        if (this.#arr[newIndex]) {
            this.#index = newIndex
            return this.#f(this.#arr[newIndex])
        }
    }
    prev() {
        const newIndex = this.#index - 1
        if (this.#arr[newIndex]) {
            this.#index = newIndex
            return this.#f(this.#arr[newIndex])
        }
    }
    next() {
        const newIndex = this.#index + 1
        if (this.#arr[newIndex]) {
            this.#index = newIndex
            return this.#f(this.#arr[newIndex])
        }
        while (true) {
            const { done, value } = this.#iter.next()
            if (done) break
            this.#arr.push(value)
            if (this.#arr[newIndex]) {
                this.#index = newIndex
                return this.#f(this.#arr[newIndex])
            }
        }
    }
    #ensure(index) {
        while (this.#arr[index] == null) {
            const { done, value } = this.#iter.next()
            if (done) break
            this.#arr.push(value)
            if (this.#arr.length - 1 >= index) break
        }
        return this.#arr[index]
    }
    prepare() {
        const newIndex = this.#index + 1
        if (this.#arr[newIndex]) return this.#f(this.#arr[newIndex])
        while (true) {
            const { done, value } = this.#iter.next()
            if (done) break
            this.#arr.push(value)
            if (this.#arr[newIndex]) return this.#f(this.#arr[newIndex])
        }
    }
    peek(count = 1, offset = 1) {
        if (count <= 0) return []
        const startIndex = Math.max(this.#index + offset, 0)
        const results = []
        const endIndex = startIndex + count
        for (let idx = startIndex; idx < endIndex; idx++) {
            const value = this.#arr[idx] ?? this.#ensure(idx)
            if (!value) break
            results.push(this.#f(value))
        }
        return results
    }
    find(f) {
        const index = this.#arr.findIndex(x => f(x))
        if (index > -1) {
            this.#index = index
            return this.#f(this.#arr[index])
        }
        while (true) {
            const { done, value } = this.#iter.next()
            if (done) break
            this.#arr.push(value)
            if (f(value)) {
                this.#index = this.#arr.length - 1
                return this.#f(value)
            }
        }
    }
}

export class TTS {
    #list
    #lastMark
    #getCfi
    constructor(doc, textWalker, highlight, getCfi) {
        this.doc = doc
        this.highlight = highlight
        this.#getCfi = getCfi
        this.#list = new ListIterator(getBlocks(doc), range => {
            return [getRangeText(range), range]
        })
    }

    #getText(text, getNode) {
        if (!text) return ''
        if (!getNode) return text
        const tempElement = document.createElement('div')
        tempElement.innerHTML = text
        let node = getNode(tempElement)?.previousSibling
        while (node) {
            const next = node.previousSibling ?? node.parentNode?.previousSibling
            node.parentNode.removeChild(node)
            node = next
        }
        return tempElement.textContent
    }

    #ensureCurrentEntry() {
        const current = this.#list.current()
        if (current) return current
        return this.#list.first() ?? this.#list.next()
    }

    #resultFrom(entry, { highlight = false } = {}) {
        if (!entry) return null
        const [text, range] = entry
        if (!text || !range) return null
        const plainText = this.#getText(text)
        let cfi = null
        if (highlight && this.highlight && range.cloneRange) {
            cfi = this.highlight(range.cloneRange()) ?? null
        }
        if (!cfi && this.#getCfi && range.cloneRange) {
            cfi = this.#getCfi(range.cloneRange())
        }
        return { text: plainText, cfi }
    }

    start() {
        this.#lastMark = null
        const entry = this.#list.first()
        if (!entry) return this.next()
        return this.#resultFrom(entry, { highlight: true })?.text
    }

    end() {
        this.#lastMark = null
        const entry = this.#list.last()
        if (!entry) return this.next()
        return this.#resultFrom(entry, { highlight: true })?.text
    }

    resume() {
        const entry = this.#list.current()
        if (!entry) return this.next()
        return this.#resultFrom(entry)?.text
    }

    prev(paused) {
        this.#lastMark = null
        const entry = this.#list.prev()
        if (paused && entry?.[1]) this.highlight(entry[1].cloneRange())
        return this.#resultFrom(entry)?.text
    }

    next(paused) {
        this.#lastMark = null
        const entry = this.#list.next()
        if (paused && entry?.[1]) this.highlight(entry[1].cloneRange())
        return this.#resultFrom(entry)?.text
    }

    // get next text without moving the iterator
    prepare() {
        const entry = this.#list.prepare()
        return this.#resultFrom(entry)?.text
    }

    from(range) {
        this.#lastMark = null
        const entry = this.#list.find(range_ =>
            range.compareBoundaryPoints(Range.END_TO_START, range_) <= 0)
        if (entry?.[1]) this.highlight(entry[1].cloneRange())
        return this.#resultFrom(entry)?.text
    }

    currentDetail() {
        const entry = this.#ensureCurrentEntry()
        return this.#resultFrom(entry)
    }

    collectDetails(count = 1, { includeCurrent = false, offset = 1 } = {}) {
        if (!Number.isFinite(count) || count <= 0) return []
        const details = []
        if (includeCurrent) {
            const entry = this.#ensureCurrentEntry()
            const detail = this.#resultFrom(entry)
            if (detail) details.push(detail)
        }
        const needed = count - details.length
        if (needed <= 0) return details
        const entries = this.#list.peek(needed, offset)
        for (const entry of entries) {
            const detail = this.#resultFrom(entry)
            if (detail) details.push(detail)
        }
        return details
    }

    highlightCfi(cfi) {
        if (!cfi) return null
        const entry = this.#list.find(range => {
            const candidate = this.#getCfi?.(range.cloneRange?.())
            return candidate === cfi
        })
        if (!entry) return null
        return this.#resultFrom(entry, { highlight: true })
    }
}
