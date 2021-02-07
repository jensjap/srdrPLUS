class ImportsController < ApplicationController
  def new
    @import = ImportedFile.new
  end

  def create
    unless _check_valid_file_type(params['file'])
      @import = Struct.new(:errors).new(nil)
      @import.errors = "Invalid file format"
      respond_to do |format|
        format.json { render :json => @import.errors.to_json, status: :unprocessable_entity }
      end
      return
    end

    import_hash = {
      import_type_id: params['import_type_id'],
      projects_user_id: params['projects_user_id'],
      imported_files_attributes: [
        {
          content: (params['file'] || params['content']),
          file_type_id: params['file_type_id']
        }
      ]
    }
    @import = Import.new(import_hash)
    authorize(@import.project, policy_class: ImportPolicy)

    respond_to do |format|
      if @import.save
        format.json { render :json => @import, status: :ok }
      else
        format.json { render :json => @import.errors, status: :unprocessable_entity }
      end
    end
  end
end

def _check_valid_file_type(file)
  extension = file.original_filename.match(/(\.[a-z]+$)/i)[0]
  return ['.ris', '.csv', '.txt', '.enw', '.json'].include?(extension)
end
