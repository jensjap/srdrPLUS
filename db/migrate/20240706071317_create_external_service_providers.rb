class CreateExternalServiceProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :external_service_providers do |t|
      t.string :name
      t.string :description
      t.string :url

      t.timestamps
    end
  end
end
