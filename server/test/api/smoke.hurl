# Omnigram API Smoke Tests
# Run: hurl --test --variable host=http://localhost:8080 \
#            --variable account=admin --variable password=admin123 \
#            server/test/api/smoke.hurl

# ============================================================
# L0: Health & System (no auth)
# ============================================================

GET {{host}}/healthz
HTTP 200

GET {{host}}/sys/ping
HTTP 200

# ============================================================
# L1: Auth Flow
# ============================================================

# Get access token (returns Bearer token for subsequent requests)
POST {{host}}/auth/token
Content-Type: application/json
{
  "account": "{{account}}",
  "password": "{{password}}"
}
HTTP 200
[Captures]
token: jsonpath "$.access_token"
[Asserts]
jsonpath "$.token_type" == "Bearer"
jsonpath "$.access_token" isString
jsonpath "$.expired_in" > 0

# Verify bad credentials are rejected
POST {{host}}/auth/token
Content-Type: application/json
{
  "account": "{{account}}",
  "password": "wrong_password"
}
HTTP 404

# Get user info
GET {{host}}/user/userinfo
Authorization: Bearer {{token}}
HTTP 200
[Asserts]
jsonpath "$.name" isString

# ============================================================
# L2: Reader — Books
# ============================================================

# List books (page_size required, 0 returns empty)
GET {{host}}/reader/books?page_size=5
Authorization: Bearer {{token}}
HTTP 200
[Asserts]
jsonpath "$.total" isInteger
jsonpath "$.books" isCollection

# Capture first book ID for detail tests (if books exist)
GET {{host}}/reader/books?page_size=1
Authorization: Bearer {{token}}
HTTP 200
[Captures]
book_count: jsonpath "$.total"

# Get reading stats
GET {{host}}/reader/stats
Authorization: Bearer {{token}}
HTTP 200

# Get library index (homepage)
GET {{host}}/reader/index?random=3&recent=3
Authorization: Bearer {{token}}
HTTP 200

# Get recent books
GET {{host}}/reader/recent?limit=5&offset=0
Authorization: Bearer {{token}}
HTTP 200

# Get favorites
GET {{host}}/reader/fav?limit=5&offset=0
Authorization: Bearer {{token}}
HTTP 200

# ============================================================
# L3: Tags & Shelves
# ============================================================

# List tags
GET {{host}}/reader/tags
Authorization: Bearer {{token}}
HTTP 200

# Create a tag
POST {{host}}/reader/tags
Authorization: Bearer {{token}}
Content-Type: application/json
{
  "tag": "hurl-test-tag"
}
HTTP 200
[Asserts]
jsonpath "$.data.tag" == "hurl-test-tag"

# Delete the tag we just created (param is tag name, not numeric id)
DELETE {{host}}/reader/tags/hurl-test-tag
Authorization: Bearer {{token}}
HTTP 200

# List shelves
GET {{host}}/reader/shelves
Authorization: Bearer {{token}}
HTTP 200

# Create a shelf
POST {{host}}/reader/shelves
Authorization: Bearer {{token}}
Content-Type: application/json
{
  "name": "hurl-test-shelf",
  "description": "Created by smoke test"
}
HTTP 200
[Captures]
shelf_id: jsonpath "$.data.id"

# Get shelf detail
GET {{host}}/reader/shelves/{{shelf_id}}
Authorization: Bearer {{token}}
HTTP 200

# Delete the shelf we just created
DELETE {{host}}/reader/shelves/{{shelf_id}}
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
# L8: Stats
# ============================================================

GET {{host}}/reader/stats/overview
Authorization: Bearer {{token}}
HTTP 200

GET {{host}}/reader/stats/daily
Authorization: Bearer {{token}}
HTTP 200
