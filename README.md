## Data structure

Schema: [`docs/schema.dbml`](docs/schema.dbml) ([dbdiagram view](https://dbdiagram.io/d/bookapi-6ad3b1ddfe5cc8bda2e5b124))

### Design decisions

- **Surrogate primary keys instead of `items.sku` / `members.member_number`**
  Business identifiers can change (relabeling, typos, new numbering scheme). They're enforced with unique indexes instead, so changing one doesn't cascade through foreign keys.

- **`loans.rented_at` separate from `created_at`**
  Business time vs. record time: the two diverge for imported historical loans, loans entered after the fact, or manual corrections.

### Out of scope

- Normalizing publishers and translators (stored as strings on `editions`)