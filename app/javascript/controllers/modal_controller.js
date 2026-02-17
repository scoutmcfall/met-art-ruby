import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "content"]

  connect() {
    // close on ESC
    this.keyHandler = (e) => { if (e.key === "Escape") this.close() }
    document.addEventListener("keydown", this.keyHandler)
  }

  disconnect() {
    document.removeEventListener("keydown", this.keyHandler)
  }

  async open(event) {
    const objectId = event.currentTarget.dataset.objectId
    if (!objectId) return
    this.showLoading()
    try {
      const res = await fetch(`/met_objects/${objectId}`)
      if (!res.ok) throw new Error("fetch_failed")
      const json = await res.json()
        this.contentTarget.innerHTML = Object.entries(json)
        .filter(([key, value]) => value) // only show truthy values
        .map(([key, value]) => `<div><strong>${key}:</strong> ${value}</div>`)
        .join("")
    } catch (e) {
      this.contentTarget.textContent = "Failed to load object details."
    }
    // Show the modal container (this.element) so CSS can display it
    this.element.classList.add("open")
    this.element.setAttribute("aria-hidden", "false")
  }

  close() {
    this.element.classList.remove("open")
    this.element.setAttribute("aria-hidden", "true")
  }

  showLoading() {
    this.contentTarget.textContent = "Loading..."
  }
}
