class ImportedFilesController < ApplicationController
  def new
    @imported_file = ImportedFile.new
  end

  def create
    imported_file_hash = { content: params['file'],
                           import_type_id: params['import_type_id'],
                           file_type_id: params['file_type_id'],
                           projects_user_id: params['projects_user_id'] }
                           
    @imported_file = ImportedFile.new(imported_file_hash)

    respond_to do |format|
      if @imported_file.save
        format.json { render :json => @imported_file, status: :ok }
      else
        format.json { render :json => @imported_file.errors, status: :unprocessable_entity }
      end
    end
  end
end
