class CreatePapers < ActiveRecord::Migration[8.0]
  def change
    create_table :papers do |t|
      t.string :url
      t.string :title
      t.boolean :read, default: false
      t.string :authors
      t.string :year
      t.text :auto_summary
      t.text :notes

      t.timestamps
    end
  end
end
