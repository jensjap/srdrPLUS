# == Schema Information
#
# Table name: mesh_descriptors
#
#  id           :bigint           not null, primary key
#  name         :text(65535)
#  resource_uri :text(65535)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class MeshDescriptor < ApplicationRecord
end
