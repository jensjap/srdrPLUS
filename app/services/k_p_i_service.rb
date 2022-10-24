class KPIService
  def initialize(project)
    @project = project
    @kpis = Hash.new { 0 }
    calculate_kpis
  end

  def calculate_kpis
    @project.citations_projects.each do |cp|
      if cp.screening_qualifications.any? { |sq| sq.qualification_type == 'ft-rejected' }
        @kpis[:ftr] += 1
      elsif cp.screening_qualifications.any? { |sq| sq.qualification_type == 'as-rejected' }
        @kpis[:asr] += 1
      elsif cp.screening_qualifications.any? { |sq| sq.qualification_type == 'ft-accepted' }
        @kpis[:ene] += 1
        @kpis[:eip] += 1
        @kpis[:ec] += 1
      elsif cp.screening_qualifications.any? { |sq| sq.qualification_type == 'as-accepted' }
        @kpis[:ftu] += 1
        @kpis[:ftps] += 1
        @kpis[:ftic] += 1
      elsif cp.screening_qualifications.blank?
        if cp.abstract_screening_results.blank?
          @kpis[:asu] += 1
        elsif cp.abstract_screening_results.any? { |asr| asr.label == -1 } &&
              cp.abstract_screening_results.any? { |asr| asr.label == 1 }
          @kpis[:asic] += 1
        else
          @kpis[:asps] += 1
        end
      end
    end
  end

  def find_kpi(kpi)
    @kpis[kpi]
  end
end
