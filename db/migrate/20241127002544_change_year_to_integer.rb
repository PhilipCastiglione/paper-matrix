class ChangeYearToInteger < ActiveRecord::Migration[8.0]
  def change
    reversible do |direction|
      change_table :papers do |t|
        direction.up   { t.change :year, :integer }
        direction.down { t.change :year, :string }
      end
    end
  end
end
