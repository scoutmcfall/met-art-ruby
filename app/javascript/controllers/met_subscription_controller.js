import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    objectId: Number,
    title: String,
    src: String,
    artist: String
  }

  connect() {
    // no-op
  }

  async subscribe(event) {
    event.preventDefault()
    const id = this.objectIdValue
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    try {
      const res = await fetch(`/art/${id}/subscribe`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': token,
          'Accept': 'application/json'
        }
      })

      if (res.status === 201) {
        const data = await res.json().catch(() => null)
        this._addArtCard(data)
        this._swapToUnsubscribeButton()
      } else if (res.ok) {
        // created with no body
        this._addArtCard(null)
        this._swapToUnsubscribeButton()
      } else {
        console.error('Subscribe failed', res)
      }
    } catch (e) {
      console.error(e)
    }
  }

  async unsubscribe(event) {
    event.preventDefault()
    const id = this.objectIdValue
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    try {
      const res = await fetch(`/art/${id}/unsubscribe`, {
        method: 'DELETE',
        headers: { 'X-CSRF-Token': token }
      })
      if (res.status === 204 || res.ok) {
        this._removeArtCard()
        this._swapToSubscribeButton()
      } else {
        console.error('Unsubscribe failed', res)
      }
    } catch (e) {
      console.error(e)
    }
  }

  _addArtCard(data) {
    const list = document.querySelector('.arts-list')
    if (!list) return

    const artId = data?.id || ''
    const name = data?.name || this.titleValue || 'New Art'
    const createdAt = data?.created_at ? new Date(data.created_at) : new Date()

    const article = document.createElement('article')
    article.className = 'card'
    if (data?.met_object_id) {
      article.dataset.metId = data.met_object_id
    } else if (this.objectIdValue) {
      article.dataset.metId = this.objectIdValue
    }

    const body = document.createElement('div')
    body.className = 'card-body'

    // If we have an image URL from server or the Met object src, show it
    const imageUrl = data?.featured_image_url || this.srcValue
    if (imageUrl) {
      const img = document.createElement('img')
      img.src = imageUrl
      img.alt = name
      img.loading = 'lazy'
      img.className = 'card-image'
      article.appendChild(img)
    }

    const h3 = document.createElement('h3')
    if (artId) {
      const a = document.createElement('a')
      a.href = `/arts/${artId}`
      a.textContent = name
      h3.appendChild(a)
    } else {
      h3.textContent = name
    }

    const meta = document.createElement('div')
    meta.className = 'meta'
    meta.textContent = `Added: ${createdAt.toDateString()}`

    body.appendChild(h3)
    body.appendChild(meta)
    article.appendChild(body)
    list.prepend(article)
  }

  _removeArtCard() {
    const list = document.querySelector('.arts-list')
    if (!list) return
    const selector = `[data-met-id="${this.objectIdValue}"]`
    const node = list.querySelector(selector)
    if (node) node.remove()
  }

  _swapToUnsubscribeButton() {
    const btn = this.element.querySelector('[data-action="click->met-subscription#subscribe"]')
    if (!btn) return
    btn.textContent = 'Unsubscribe'
    btn.dataset.action = 'click->met-subscription#unsubscribe'
    btn.classList.remove('btn-primary')
  }

  _swapToSubscribeButton() {
    const btn = this.element.querySelector('[data-action="click->met-subscription#unsubscribe"]')
    if (!btn) return
    btn.textContent = 'Subscribe'
    btn.dataset.action = 'click->met-subscription#subscribe'
    btn.classList.add('btn-primary')
  }
}
