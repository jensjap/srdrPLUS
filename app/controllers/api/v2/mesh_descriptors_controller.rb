class Api::V2::MeshDescriptorsController < Api::V2::BaseController
  SERVICE_ADDRESS = "https://id.nlm.nih.gov/mesh/lookup/descriptor".freeze

  resource_description do
    short 'End-Points index list of MeSH Descriptors in the system'
    formats [:json]
  end

  api :GET, '/v2/mesh_descriptors.json', 'Full list of MeSH Descriptors.'
  param_group :paginate, Api::V2::BaseController
  returns desc: 'Index of MeSH Descriptors in the system; paginate (optional); query (optional)' do
    property :is_paginated, :boolean, desc: 'Is response paginated or not.'
    property :page, Integer, desc: 'Page returned.'
    property :per_page, Integer, desc: 'Number of resources returned per page.'
    property :evidence_variables, array_of: Hash do
      property :id, Integer, desc: 'Resource ID.'
      property :url, String, desc: 'URL of resource.'
      property :name, String, desc: 'Resource name (human readable).'
    end
  end
  def index
    @mesh_descriptors = Array.new
    project_id = params[:project_id]
    page       = params[:page]
    per_page   = params[:per_page]
    query      = params[:q]
    url        = SERVICE_ADDRESS + "?match=contains&year=current&limit=20&label=" + query.to_s

    begin
      response = HTTParty.get(url)
    rescue Exception => e
      response = nil
    end

    if response.nil? || response.code.eql?(400) || response.body.nil? || response.body.empty?
      @mesh_descriptors = nil
    else
      response.each do |resp|
        mesh_descriptor_tmp = MeshDescriptor
          .create_with(resource_uri: resp["resource"])
          .find_or_create_by(name: resp["label"])
        @mesh_descriptors << {
          id:           mesh_descriptor_tmp.id,
          text:         mesh_descriptor_tmp.name,
          resource_uri: mesh_descriptor_tmp.resource_uri
        }
      end
    end
  end
end

