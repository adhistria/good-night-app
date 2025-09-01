## Sleep Tracker API – README

A small Rails API that supports:

1. **Clock In** and **Clock Out** sleep sessions
2. **Follow / Unfollow** between users
3. **Feed of sleep records from people a user follows** for the **previous week**, sorted by **sleep duration (desc)**

The app is namespaced under `api/v1`.

---

## Tech stack

* Ruby on Rails (API mode)
* PostgreSQL
* RSpec (request + model specs)
* Kaminari (pagination) – optional but recommended
* Docker / docker-compose

---

## Quick Start (Local)

```bash
# Install gems
bundle install

# Setup DB
rails db:create db:migrate

# Run tests
bundle exec rspec

# Start server
rails s
# -> http://localhost:3000
```

---

## Quick Start (Docker)

```bash
# Build the containers
docker-compose build

# Start the containers in background
docker-compose up -d

# Create the database (run inside the app container)
docker-compose exec app rails db:create

# Run migrations (run inside the app container)
docker-compose exec app rails db:migrate
```

> Make sure your `docker-compose.yml` exposes Rails on port 3000 and Postgres on the configured port.

---

### Endpoints summary

| Method | Path                                        | Description                                                                                                                          |
| ------ | ------------------------------------------- |--------------------------------------------------------------------------------------------------------------------------------------|
| POST   | `/api/v1/clock_in`                          | Start a sleep session for the current user. Returns **all** sleep records ordered by `created_at`.                                   |
| PATCH  | `/api/v1/clock_out/:id`                     | Finish a specific sleep session (by id). Returns **all** sleep records ordered by `created_at`.                                      |
| GET    | `/api/v1/sleep_records`                     | Return all sleep records of the current user’s following users from the previous week, ordered by sleep duration (longest first).    |
| POST   | `/api/v1/follows`                           | Follow a user. Body/params: `following_id`.                                                                                          |
| DELETE | `/api/v1/follows/:following_id`             | Unfollow a user.                                                                                                                     |

---

## Data Model

### Users

* **id** (PK)
* **name** (string, presence)

### Follows

* **id** (PK)
* **follower\_id** (FK → users)
* **following\_id** (FK → users)

### SleepRecords

* **id** (PK)
* **user\_id** (FK → users, presence)
* **clock\_in** (datetime, presence)
* **clock\_out** (datetime, nullable)
* **sleep\_duration** (integer/float; computed as `clock_out - clock_in`)

---

## Example cURL

```bash
# Clock in
curl -X POST http://localhost:3000/api/v1/clock_in -H 'X-User-Id: <user-id>'

# Clock out
curl -X PATCH http://localhost:3000/api/v1/clock_out/1 -H 'X-User-Id: <user-id>'

# Fetch following sleep record
curl http://localhost:3000/api/v1/sleep_records -H 'X-User-Id: <user-id>'

# Follow user 5
curl -X POST http://localhost:3000/api/v1/follows -d 'following_id=5' -H 'X-User-Id: <user-id>'

# Unfollow user 5
curl -X DELETE http://localhost:3000/api/v1/follows/5 -H 'X-User-Id: <user-id>'

```

