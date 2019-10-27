class AddKeyQuestionReferencesToImportedFile < ActiveRecord::Migration[5.0]
  def change
    add_reference :imported_files, :key_question, index: true
  end
end
