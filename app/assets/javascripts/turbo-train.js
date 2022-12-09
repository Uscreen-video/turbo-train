import { connectStreamSource, disconnectStreamSource } from "@hotwired/turbo";

export default class TurboTrain extends HTMLElement {
  static get observedAttributes() {
    return [ 'href', 'session', 'name' ];
  }

  constructor() {
    super();
  }

  connectedCallback() {
    this.eventSource = new EventSource(`${this.href}/mercure?topic=${this.name}&authorization=${this.session}`);
    connectStreamSource(this.eventSource);
  }

  disconnectedCallback() {
    disconnectStreamSource(this.eventSource);
  }

  get href() {
    return this.getAttribute('href');
  }

  get session() {
    return this.getAttribute('session');
  }

  get name() {
    return this.getAttribute('name');
  }
}

if (
  typeof window !== 'undefined' &&
  !window.customElements.get('turbo-train-stream-source')
) {
  window.customElements.define('turbo-train-stream-source', TurboTrain)
}
