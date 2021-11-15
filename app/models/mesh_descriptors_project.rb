# == Schema Information
#
# Table name: mesh_descriptors_projects
#
#  id                 :bigint           not null, primary key
#  mesh_descriptor_id :bigint           not null
#  project_id         :bigint           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class MeshDescriptorsProject < ApplicationRecord
  belongs_to :mesh_descriptor
  belongs_to :project
end
