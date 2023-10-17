class AddJsonToExportTypes < ActiveRecord::Migration[7.0]
  def up
    ExportType.create(name: '.json')
  end

  def down
    ExportType.find_by(name: '.json').&destroy
  end
end
