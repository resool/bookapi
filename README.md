# bookapi

Library API for staff: manage books and copies, lend them to members, track loan history and send due-date reminders.

Rails 8.1 (API only), Ruby 3.4, PostgreSQL 17, Solid Queue.

## Setup

```bash
docker compose up --build
```

The application is available at `http://localhost:3000`. On the first start the database is created and seeded.

Compose runs three services:

- `db` – PostgreSQL
- `web` – Rails server (runs `db:prepare` before starting)
- `jobs` – Solid Queue worker, runs the recurring reminder jobs

Tests:

```bash
docker compose run --rm -e RAILS_ENV=test web bin/rails db:prepare
docker compose run --rm web bundle exec rspec
```

### Seed data

Books come from my own shelf. Useful identifiers:

| Member card | Name | Status |
|---|---|---|
| `000017` | Anna Nowak | active, loan due in 3 days |
| `000042` | Jan Kowalski | active, has an overdue loan |
| `000108` | Maria Wiśniewska | active, loan due today |
| `000215` | Piotr Zieliński | suspended |
| `000404` | Tomasz Wójcik | closed |

Copies: `000001` has a loan history, `000003` is available, `000002` is loaned, `000005` is in repair.

## Endpoints

Swagger UI: `http://localhost:3000/api-docs`. There are two documents:

**Staff API V1** (`/staff-api/v1`)

| Requirement | Endpoint |
|---|---|
| Add a book | `POST /books` – new title (work, edition, authors) with its first copy |
| | `POST /editions/:id/books` – another copy of an existing edition |
| Delete a book | `DELETE /books/:sku` |
| List books with status | `GET /books` (paginated) |
| Book details with loan history | `GET /books/:sku` |
| Change status to borrowed | `POST /books/:sku/loans` with `member_number` |
| Change status to available | `POST /books/:sku/return` |

**Public API V1** (`/public-api/v1`)

- `GET /books` – editions in circulation with the number of available copies

Examples:

```bash
curl localhost:3000/staff-api/v1/books/000001

curl -X POST localhost:3000/staff-api/v1/books/000003/loans \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: $(uuidgen)" \
  -d '{"member_number": "000017"}'

curl -X POST localhost:3000/staff-api/v1/books/000003/return
```

Responses use `{ "data": ... }`, paginated lists add `meta` (`page`, `limit`, `count`, `pages`). Errors are returned as `{ "errors": [{ "code", "message" }] }`.

## Data structure

Schema: [`docs/schema.dbml`](docs/schema.dbml) ([dbdiagram view](https://dbdiagram.io/d/bookapi-6ad3b1ddfe5cc8bda2e5b124))

A book is stored as three entities:

- `works` – the book itself, e.g. "Anne of Green Gables"
- `editions` – a published edition; the title can differ between editions, e.g. "Ania z Zielonego Wzgórza" vs "Anne z Zielonych Szczytów"
- `items` – a physical copy with a 6-digit `sku`

Besides that there are `authors` (linked to works through `authorships`), `members` (library card holders) and `loans`, which keep the full borrowing history.

## Design decisions

- **Borrowing and returning instead of a generic status update**
  The task asks for an endpoint changing the status. A loan needs a member and creates history, so it is modelled as two actions: `POST /loans` and `POST /return`. Other statuses (`in_repair`, `lost`) are in the schema, but no endpoint changes them yet.

- **Deleting a copy withdraws it**
  `DELETE /books/:sku` sets the status to `withdrawn` instead of removing the row, so the loan history is kept. Loaned copies cannot be deleted.

- **Surrogate primary keys instead of `items.sku` / `members.member_number`**
  Business identifiers can change (relabelling, typos, a new numbering scheme). They are enforced with unique indexes instead, so changing one doesn't cascade through foreign keys.

- **`loans.rented_at` separate from `created_at`**
  Business time vs. record time: they differ for imported historical loans, loans entered after the fact, or manual corrections.

- **Concurrent loans**
  A copy is claimed with a conditional `UPDATE ... WHERE status = 'available'`, and a partial unique index (`loans.item_id WHERE returned_at IS NULL`) guarantees one active loan per copy at the database level.

- **Idempotency keys**
  `POST` endpoints that create records accept an `Idempotency-Key` header. A retried request returns the stored response instead of creating a duplicate. Keys are stored in PostgreSQL, so no additional infrastructure (e.g. Redis) is needed.

- **Members can't borrow** when suspended, closed or having overdue loans.

### Out of scope

- Authentication (allowed by the task)
- Managing members (they exist only in seeds)
- Normalizing publishers and translators (stored as strings on `editions`)
- Membership card history

## Notifications

There are two reminder emails:

- the loan ends in X days (default X = 3), sent every day at 8am
- the loan ends today, sent every day at 9am

Each reminder is sent once per loan (tracked with `*_reminder_sent_at` columns on `loans`).

In development emails are not sent: they are written to `tmp/mails` and logged. Templates can be previewed at `http://localhost:3000/rails/mailers`.

Seeds contain loans due today and in 3 days, so reminders can be triggered without waiting for the schedule:

```bash
docker compose exec web bin/rails runner 'Reminders::BeforeDueDateJob.perform_now; Reminders::DueDateJob.perform_now'
ls tmp/mails
```

Reminder options (enabled/disabled, how many days before the due date) and the loan period live in `config/settings.yml` and can be overridden with environment variables without changing code (the [config](https://github.com/rubyconfig/config) gem). For example, to send the first reminder 5 days before the due date:

```bash
SETTINGS__REMINDERS__BEFORE_DUE_DATE__DAYS_BEFORE=5
```

Settings are read on boot, so the `web` and `jobs` processes need a restart.

## CI

GitHub Actions run on every pull request; all checks are required to merge into `main`:

- security – brakeman, bundler-audit
- tests – rspec, seeds check
- linters – rubocop, reek
- docs – the committed Swagger files must match the specs

The same checks can be run locally with `bin/ci`.

## Next steps

1. **Authentication** – bearer token for the Staff API.
2. **"Notify me when available"** – returning a copy publishes an `ItemReturned` event; if the edition had no available copies before, `InformWhenAvailableJob` notifies the members waiting for it.
3. **Search in the Public API** – full-text search, or semantic search with pgvector ([neighbor](https://github.com/ankane/neighbor)).
4. **Adding several copies at once** – a bulk variant of `POST /editions/:id/books`.
5. **Expiring idempotency keys** – a recurring job removing keys older than e.g. 24h.
6. **Counting available copies in SQL** – the Public API loads available copies to count them; a `COUNT` subquery or a counter cache would scale better.
7. **Validating settings** – a schema for `Settings`, so an invalid environment variable fails on boot.
