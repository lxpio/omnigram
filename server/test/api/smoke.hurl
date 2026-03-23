# Omnigram API Smoke Tests
# Run: hurl --test --variable host=http://localhost:8080 server/test/api/smoke.hurl

# ============================================================
# L0: Health & System
# ============================================================

GET {{host}}/healthz
HTTP 200

GET {{host}}/sys/ping
HTTP 200

# ============================================================
# L1: Auth Flow
# ============================================================

# Login
POST {{host}}/auth/login
Content-Type: application/json
{
  "username": "{{username}}",
  "password": "{{password}}"
}
HTTP 200
[Captures]
token: jsonpath "$.token"

# Get user info
GET {{host}}/user/userinfo
Authorization: Bearer {{token}}
HTTP 200
[Asserts]
jsonpath "$.username" exists

# ============================================================
# L2: Reader — Books CRUD
# ============================================================

# List books
GET {{host}}/reader/books
Authorization: Bearer {{token}}
HTTP 200

# Get reading stats
GET {{host}}/reader/stats
Authorization: Bearer {{token}}
HTTP 200

# Get recent books
GET {{host}}/reader/recent
Authorization: Bearer {{token}}
HTTP 200

# Get favorites
GET {{host}}/reader/fav
Authorization: Bearer {{token}}
HTTP 200

# ============================================================
# L3: Tags & Shelves
# ============================================================

# List tags
GET {{host}}/reader/tags
Authorization: Bearer {{token}}
HTTP 200

# List shelves
GET {{host}}/reader/shelves
Authorization: Bearer {{token}}
HTTP 200

# ============================================================
# L4: Sync Endpoints
# ============================================================

# Full sync
POST {{host}}/sync/full
Authorization: Bearer {{token}}
Content-Type: application/json
{
  "last_sync_time": 0
}
HTTP 200

# Delta sync
POST {{host}}/sync/delta
Authorization: Bearer {{token}}
Content-Type: application/json
{
  "last_sync_time": 0
}
HTTP 200

# ============================================================
# L5: System (Admin)
# ============================================================

# System info
GET {{host}}/sys/info
Authorization: Bearer {{token}}
HTTP 200

# Scan status
GET {{host}}/sys/scan/status
Authorization: Bearer {{token}}
HTTP 200

# ============================================================
# L6: Search
# ============================================================

GET {{host}}/reader/search?q=test
Authorization: Bearer {{token}}
HTTP 200

# ============================================================
# L7: Companion Config
# ============================================================

GET {{host}}/user/companion
Authorization: Bearer {{token}}
HTTP 200

# ============================================================
# L8: TTS Health
# ============================================================

GET {{host}}/tts/health
Authorization: Bearer {{token}}
HTTP 200

# ============================================================
# L9: AI Status
# ============================================================

GET {{host}}/sys/ai/status
Authorization: Bearer {{token}}
HTTP 200
