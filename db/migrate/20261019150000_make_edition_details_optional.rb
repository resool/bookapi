class MakeEditionDetailsOptional < ActiveRecord::Migration[8.1]
  def change
    change_column_null :editions, :description, true
    change_column_null :editions, :publisher, true
    change_column_null :editions, :published_year, true
  end
end
