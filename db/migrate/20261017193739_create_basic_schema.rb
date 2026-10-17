class CreateBasicSchema < ActiveRecord::Migration[8.0]
  def change
    create_enum :item_status, %w[available loaned in_repair lost withdrawn]
    create_enum :member_status, %w[active suspended closed]

    create_table :authors do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    create_table :works do |t|
      t.string :title, null: false, index: true
      t.text :description

      t.timestamps
    end

    create_table :authorships do |t|
      t.references :author, null: false, foreign_key: true
      t.references :work, null: false, foreign_key: true, index: false

      t.timestamps
    end
    add_index :authorships, %i[work_id author_id], unique: true

    create_table :editions do |t|
      t.references :work, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description, null: false
      t.string :translator
      t.string :publisher, null: false
      t.integer :published_year, null: false
      t.string :isbn, index: { unique: true, where: "isbn IS NOT NULL" }

      t.timestamps
    end

    create_table :items do |t|
      t.references :edition, null: false, foreign_key: true
      t.string :sku, null: false, index: { unique: true }
      t.enum :status, enum_type: :item_status, null: false, default: "available"
      t.string :condition, null: false
      t.date :acquired_on

      t.timestamps
    end

    create_table :members do |t|
      t.string :member_number, null: false, index: { unique: true }
      t.string :name, null: false
      t.string :email, null: false, index: { unique: true }
      t.enum :status, enum_type: :member_status, null: false, default: "active"

      t.timestamps
    end

    create_table :loans do |t|
      t.references :item, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true
      t.datetime :rented_at, null: false
      t.datetime :due_at, null: false
      t.datetime :returned_at

      t.timestamps
    end

    add_index :loans, :item_id, unique: true, where: "returned_at IS NULL",
                                name: "index_loans_on_item_id_active"
  end
end
