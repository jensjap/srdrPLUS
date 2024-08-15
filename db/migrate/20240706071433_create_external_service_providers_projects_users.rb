class CreateExternalServiceProvidersProjectsUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :external_service_providers_projects_users do |t|
      t.references :external_service_provider, null: false, foreign_key: true, type: :bigint, index: { name: "index_esppu_on_esp_id" }
      t.references :project, null: false, foreign_key: true, type: :integer, index: { name: "index_esppu_on_project_id" }
      t.references :user, null: false, foreign_key: true, type: :integer, index: { name: "index_esppu_on_user_id" }
      t.string :api_token

      t.timestamps
    end
  end
end
