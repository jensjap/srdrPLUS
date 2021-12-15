class AddProjectIdReferenceToDataAudits < ActiveRecord::Migration[5.0]
  def change
    add_reference :data_audits, :project
  end
end
