class CreateExternalServiceProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :external_service_providers do |t|
      t.string :name
      t.string :description
      t.string :url

      t.timestamps
    end

    ExternalServiceProvider.create(
      name: "FEvIR Platform",
      description: "The FEvIR Platform includes many Builder Tools to create FHIR® Resources without requiring expertise in FHIR® or JSON, and Converter Tools to convert structured data to FHIR® Resources.",
      url: "https://fevir.net"
    )
  end
end
