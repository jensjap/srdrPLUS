class ImportsController < ApplicationController
  def new
    @import = ImportedFile.new
  end

  def create
    import_hash = { import_type_id: params['import_type_id'],
                    projects_user_id: params['projects_user_id'] 
                    imported_files_attributes: [ { content: params['content'],
                    file_type_id: params['file_type_id'],
                    } ] }
                          
    @import = Import.new(import_hash)

    respond_to do |format|
      if @import.save
        format.json { render :json => @import, status: :ok }
      else
        format.json { render :json => @import.errors, status: :unprocessable_entity }
      end
    end
  end
end
