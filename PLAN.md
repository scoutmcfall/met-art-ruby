You are working in an existing Rails API-only application.

Before generating code:

Inspect the project structure.

Reuse existing authentication, subscription, mailer, and testing patterns.

Follow conventions already used in the app.

Do NOT duplicate logic that already exists.

Ask clarifying questions if something is ambiguous.

🎯 Feature: Integrate The Metropolitan Museum of Art API

Docs: https://metmuseum.github.io/

Endpoints:

GET https://collectionapi.metmuseum.org/public/collection/v1/objects

GET https://collectionapi.metmuseum.org/public/collection/v1/objects/:objectID

Requirements
1️⃣ Service Layer

Create a service object (e.g. MetMuseum::Client) that:

Fetches object IDs from /objects

Caches IDs in Rails.cache for 24 hours

On cache miss, refetches automatically

Returns a random cached ID

Fetches object details for a given ID

Handles:

Timeouts

API failures

Empty responses

Logging errors

Use the HTTP client already used in the project (Faraday/Net::HTTP/etc).

2️⃣ Boot-Time Caching

When the app boots (initializer or background job depending on project setup):

Fetch and cache object IDs

Ensure this does not block boot if the API is unavailable

3️⃣ Endpoint: Random Art

Add:

GET /art/random

Behavior:

Use cached IDs

Pick random ID

Fetch object details

Return JSON with key fields:

objectID

title

artistDisplayName

objectDate

medium

primaryImage

department

culture

objectURL

Use existing serializer pattern if present.

4️⃣ Subscriptions (Logged-in Users Only)

Allow users to:

POST /art/:object_id/subscribe

DELETE /art/:object_id/unsubscribe

Requirements:

Persist subscription to DB

Prevent duplicates (unique index)

Require authentication

Reuse existing subscription/email patterns where possible

Return proper HTTP status codes

If a similar subscription model already exists, extend it instead of creating a new one.

🧪 Testing (Comprehensive)

Use the project’s existing testing framework (likely RSpec).

Add:

Service Specs

Fetch + cache IDs

Cache miss behavior

Random ID selection

Object detail fetch

API failure handling (stub with WebMock or existing stubbing strategy)

Request Specs

GET /art/random (success + failure)

Subscribe/unsubscribe (auth + unauth cases)

Duplicate prevention

Model Specs

Associations

Validations

Uniqueness constraint

Follow existing test style and helpers.

Architecture Rules

Keep API logic out of controllers

Use service objects

Follow RESTful routing

Keep controllers thin

Match existing code style

Avoid introducing unnecessary gems