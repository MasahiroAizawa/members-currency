class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.integer :currency_id
      t.string :name
      t.integer :publisher
      t.string :unit

      t.timestamps
    end
  end
end
