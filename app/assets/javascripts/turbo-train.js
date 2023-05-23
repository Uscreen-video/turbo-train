import { Turbo } from "@hotwired/turbo-rails"

export default class TurboTrain extends HTMLElement {
  static get observedAttributes() {
    return [ 'href' ];
  }

  constructor() {
    super();
  }

  connectedCallback() {
    this.eventSource = new EventSource(this.href);
    Turbo.connectStreamSource(this.eventSource);
  }

  disconnectedCallback() {
    Turbo.disconnectStreamSource(this.eventSource);
  }

  get href() {
    return this.getAttribute('href');
  }
}

if (
  typeof window !== 'undefined' &&
  !window.customElements.get('turbo-train-stream-source')
) {
  window.customElements.define('turbo-train-stream-source', TurboTrain)
}
