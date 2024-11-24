import { Turbo } from "@hotwired/turbo-rails"


export default class TurboTrain extends HTMLElement {
  static get observedAttributes() {
    return [ 'href' ]
  }

  error = null

  #eventSource = null

  constructor() {
    super()
  }

  connectedCallback() {
    this.init()
  }

  // Public API - client can trigger initialization manually
  init = () => {
    this.#eventSource = new EventSource(this.href)
    this.#eventSource.addEventListener('message', this.#onMessage)
    this.#eventSource.addEventListener('error', this.#onError)
    this.#eventSource.addEventListener('open', this.#onOpen)

    if (this.shouldConnectTurboStream) {
      Turbo.connectStreamSource(this.#eventSource)
    }
  }

  disconnectedCallback() {
    this.destroy()
  }

  // Public API - client can trigger destruction manually
  destroy = () => {
    this.#eventSource?.close()
    if (this.shouldConnectTurboStream) {
      Turbo.disconnectStreamSource(this.#eventSource)
    }
    this.#eventSource?.removeEventListener('message', this.#onMessage)
    this.#eventSource?.removeEventListener('error', this.#onError)
    this.#eventSource?.removeEventListener('open', this.#onOpen)
  }

  get href() {
    return this.getAttribute('href')
  }

  // By default component should always connect to turbo stream
  // Only in case when we want to listen for event with JS we don't need to connect to turbo stream
  get shouldConnectTurboStream() {
    return !this.hasAttribute('no-turbo-stream')
  }

  // Humanize event source ready state
  get state() {
    if (!this.#eventSource) return null

    switch (this.#eventSource.readyState) {
      case EventSource.CONNECTING:
        return 'connecting'
      case EventSource.OPEN:
        return 'open'
      case EventSource.CLOSED:
        return 'closed'
    }
  }

  #onMessage = (event) => {
    this.error = null
    const data = JSON.parse(event.data)
    this.#emit('message', { detail: data })
  }

  #onError = (error) => {
    this.error = error
    this.#emit('error', { detail: error })
  }

  #onOpen = (event) => {
    this.#emit('open', { detail: event })
  }

  #emit = (name, options = {}) => {
    const event = new CustomEvent(name, {
      bubbles: true,
      cancelable: false,
      composed: true,
      detail: {},
      ...options
    })
    this.dispatchEvent(event)
    return event
  }
}

if (
  typeof window !== 'undefined' &&
  !window.customElements.get('turbo-train-stream-source')
) {
  window.customElements.define('turbo-train-stream-source', TurboTrain)
}
