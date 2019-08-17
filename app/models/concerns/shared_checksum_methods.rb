module SharedApprovableMethods
  extend ActiveSupport::Concern
  
  included do
    def set_extraction_stale
  #    time_now = DateTime.now.to_i
  #    UpdateExtractionChecksumJob.set(wait: 2.minute).perform_later(time_now.to_i, self.id)
      extraction = nil
      case recordable.class.name
      when 'ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField'
        extraction = recordable.extraction
      when 'ResultStatisticSection'
      else
        extraction = recordable.result_statistic_section.extraction
      end
      extraction.extraction_checksum.update( is_stale: true ) 
    end
  end
end
