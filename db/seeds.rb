
# Members (library card numbers) to try borrowing with:
#   000333 Katarzyna Lewandowska - active, can borrow
#   000512 Ewa Kamińska          - active, never borrowed anything
#   000042 Jan Kowalski          - has an overdue book, borrowing is refused
#   000215 Piotr Zieliński       - suspended
#   000404 Tomasz Wójcik         - closed account

if Work.exists?
  puts "Database already seeded, skipping. Use bin/rails db:reset to start over."
  return
end

catalogue = [
  { title: "Doktryna szoku", authors: [ "Naomi Klein" ], publisher: "Muza" },
  { title: "Technofeudalizm", authors: [ "Yanis Varoufakis" ] },
  { title: "Depesze", authors: [ "Michael Herr" ] },
  { title: "Nomadland", authors: [ "Jessica Bruder" ] },
  { title: "Być gościem w katastrofie", authors: [ "Tomasz Szerszeń" ] },
  { title: "Zapomniane", authors: [ "Raja Shehadeh", "Penny Johnson" ] },
  { title: "Palestyńskie wędrówki", authors: [ "Raja Shehadeh" ] },
  { title: "Obcy w domu", authors: [ "Raja Shehadeh" ] },
  { title: "Widok cudzego cierpienia", authors: [ "Susan Sontag" ] },
  { title: "Against Interpretation and Other Essays", authors: [ "Susan Sontag" ], publisher: "Penguin Modern Classics" },
  # In Search of Lost Time: seven volumes, each a separate book
  { title: "W poszukiwaniu straconego czasu, t. 1: W stronę Swanna", authors: [ "Marcel Proust" ] },
  { title: "W poszukiwaniu straconego czasu, t. 2: W cieniu zakwitających dziewcząt", authors: [ "Marcel Proust" ] },
  { title: "W poszukiwaniu straconego czasu, t. 3: Strona Guermantes", authors: [ "Marcel Proust" ] },
  { title: "W poszukiwaniu straconego czasu, t. 4: Sodoma i Gomora", authors: [ "Marcel Proust" ] },
  { title: "W poszukiwaniu straconego czasu, t. 5: Uwięziona", authors: [ "Marcel Proust" ] },
  { title: "W poszukiwaniu straconego czasu, t. 6: Nie ma Albertyny", authors: [ "Marcel Proust" ] },
  { title: "W poszukiwaniu straconego czasu, t. 7: Czas odnaleziony", authors: [ "Marcel Proust" ] },
  { title: "Sto lat samotności", authors: [ "Gabriel García Márquez" ] },
  { title: "O miłości i innych demonach", authors: [ "Gabriel García Márquez" ] },
  { title: "Rzeka zapomnienia", authors: [ "Julio Llamazares" ] },
  { title: "Baudolino", authors: [ "Umberto Eco" ] },
  { title: "Wyspa dnia poprzedniego", authors: [ "Umberto Eco" ] },
  { title: "Jeśli zimową nocą podróżny", authors: [ "Italo Calvino" ] },
  { title: "Krótkie, ale całe historie", authors: [ "Sławomir Mrożek" ] },
  { title: "Tango", authors: [ "Sławomir Mrożek" ] },
  { title: "Mołdawia", authors: [ "Kamil Całus" ] },
  { title: "Rok Małpy", authors: [ "Patti Smith" ] }
]

# sku => [ edition title, status, condition ]
copies = {
  "000001" => [ "Sto lat samotności", "available", "worn" ],
  "000002" => [ "Sto lat samotności", "loaned", "good" ],
  "000003" => [ "Baudolino", "available", "new" ],
  "000004" => [ "Nomadland", "loaned", "good" ],
  "000005" => [ "Nomadland", "in_repair", "damaged" ],
  "000006" => [ "W poszukiwaniu straconego czasu, t. 1: W stronę Swanna", "withdrawn", "damaged" ],
  "000007" => [ "Technofeudalizm", "loaned", "new" ],
  "000008" => [ "Technofeudalizm", "available", "new" ],
  "000009" => [ "Doktryna szoku", "loaned", "worn" ],
  "000010" => [ "Jeśli zimową nocą podróżny", "available", "good" ],
  "000011" => [ "Depesze", "lost", "good" ],
  "000012" => [ "Widok cudzego cierpienia", "available", "good" ],
  "000013" => [ "Tango", "available", "worn" ],
  "000014" => [ "Palestyńskie wędrówki", "available", "good" ],
  "000015" => [ "Mołdawia", "available", "new" ],
  "000016" => [ "Rok Małpy", "available", "good" ],
  "000017" => [ "W poszukiwaniu straconego czasu, t. 1: W stronę Swanna", "available", "worn" ],
  "000018" => [ "Against Interpretation and Other Essays", "available", "good" ],
  "000019" => [ "W poszukiwaniu straconego czasu, t. 2: W cieniu zakwitających dziewcząt", "available", "worn" ],
  "000020" => [ "W poszukiwaniu straconego czasu, t. 3: Strona Guermantes", "available", "worn" ],
  "000021" => [ "W poszukiwaniu straconego czasu, t. 4: Sodoma i Gomora", "available", "worn" ],
  "000022" => [ "W poszukiwaniu straconego czasu, t. 5: Uwięziona", "available", "worn" ],
  "000023" => [ "W poszukiwaniu straconego czasu, t. 6: Nie ma Albertyny", "available", "worn" ],
  "000024" => [ "W poszukiwaniu straconego czasu, t. 7: Czas odnaleziony", "available", "worn" ],
  "000025" => [ "Być gościem w katastrofie", "available", "good" ],
  "000026" => [ "Zapomniane", "available", "good" ],
  "000027" => [ "Obcy w domu", "available", "good" ],
  "000028" => [ "O miłości i innych demonach", "available", "good" ],
  "000029" => [ "Rzeka zapomnienia", "available", "good" ],
  "000030" => [ "Wyspa dnia poprzedniego", "available", "good" ],
  "000031" => [ "Krótkie, ale całe historie", "available", "good" ]
}

members = [
  { member_number: "000017", name: "Anna Nowak", email: "anna.nowak@example.com", status: "active" },
  { member_number: "000042", name: "Jan Kowalski", email: "jan.kowalski@example.com", status: "active" },
  { member_number: "000108", name: "Maria Wiśniewska", email: "maria.w@example.com", status: "active" },
  { member_number: "000215", name: "Piotr Zieliński", email: "piotr.z@example.com", status: "suspended" },
  { member_number: "000333", name: "Katarzyna Lewandowska", email: "kasia.l@example.com", status: "active" },
  { member_number: "000404", name: "Tomasz Wójcik", email: "tomasz.w@example.com", status: "closed" },
  { member_number: "000512", name: "Ewa Kamińska", email: "ewa.k@example.com", status: "active" }
]

ActiveRecord::Base.transaction do
  author_ids = Author.insert_all!(
    catalogue.flat_map { |book| book[:authors] }.uniq.map { |name| { name: } },
    returning: %w[name id]
  ).rows.to_h

  work_ids = Work.insert_all!(catalogue.map { |book| { title: book[:title] } }, returning: %w[title id]).rows.to_h

  Authorship.insert_all!(
    catalogue.flat_map do |book|
      book[:authors].map { |name| { work_id: work_ids.fetch(book[:title]), author_id: author_ids.fetch(name) } }
    end
  )

  edition_ids = Edition.insert_all!(
    catalogue.map { |book| { work_id: work_ids.fetch(book[:title]), title: book[:title], publisher: book[:publisher] } },
    returning: %w[title id]
  ).rows.to_h

  item_ids = Item.insert_all!(
    copies.map { |sku, (title, status, condition)| { sku:, edition_id: edition_ids.fetch(title), status:, condition: } },
    returning: %w[sku id]
  ).rows.to_h

  member_ids = Member.insert_all!(members, returning: %w[member_number id]).rows.to_h

  now = Time.current
  today = Date.current
  period = Settings.loan_period_days.days

  loans = [
    # History (returned)
    [ "000001", "000017", now - 200.days, nil, now - 175.days ],
    [ "000001", "000042", now - 150.days, nil, now - 110.days ], # returned late
    [ "000002", "000108", now - 100.days, nil, now - 72.days ],
    [ "000004", "000042", now - 80.days, nil, now - 45.days ],   # returned late
    [ "000008", "000333", now - 70.days, nil, now - 41.days ],
    [ "000013", "000108", now - 60.days, nil, now - 29.days ],
    [ "000006", "000404", now - 400.days, nil, now - 380.days ],

    # Active (the copies above are marked as loaned)
    [ "000002", "000017", now - 27.days, (today + 3).in_time_zone.change(hour: 18), nil ], # reminder: due in 3 days
    [ "000004", "000108", now - 30.days, today.in_time_zone.change(hour: 18), nil ],       # reminder: due today
    [ "000007", "000042", now - 40.days, nil, nil ],                                      # overdue
    [ "000009", "000215", now - 45.days, nil, nil ]                                       # overdue, member suspended
  ]

  Loan.insert_all!(
    loans.map do |sku, member_number, rented_at, due_at, returned_at|
      { item_id: item_ids.fetch(sku), member_id: member_ids.fetch(member_number),
        rented_at:, due_at: due_at || rented_at + period, returned_at: }
    end
  )
end

puts "Seeded #{Work.count} works, #{Edition.count} editions, #{Item.count} copies, #{Member.count} members, #{Loan.count} loans."
