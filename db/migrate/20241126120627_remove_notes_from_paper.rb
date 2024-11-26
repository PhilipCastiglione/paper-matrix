class RemoveNotesFromPaper < ActiveRecord::Migration[8.0]
  def change
    remove_column :papers, :notes, :text
  end
end
