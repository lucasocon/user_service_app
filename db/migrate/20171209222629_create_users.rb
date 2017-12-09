class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, limit: 200
      t.string :phone_number, null: false, limit: 20
      t.string :full_name, limit: 200
      t.string :password, null: false, limit: 100
      t.string :key, null: false, limit: 100
      t.string :account_key, limit: 100
      t.string :metadata, limit: 2000

      t.timestamps
    end
  end
end
