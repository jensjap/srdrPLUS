class ResetService
  def self.reset_screening!
    if Rails.env.development?
      ScreeningQualification.destroy_all
      AbstractScreening.destroy_all
      FulltextScreening.destroy_all
      CitationsProject.update_all(screening_status: 'asu')
      CitationsProject.search_index.clean_indices
      CitationsProject.first.reindex
    else
      puts 'Cannot reset outside development environment'
    end
  end
end
