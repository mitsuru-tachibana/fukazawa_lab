class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :pass
      t.string :name
      t.string :bio

      t.timestamps
    end
  end
end
