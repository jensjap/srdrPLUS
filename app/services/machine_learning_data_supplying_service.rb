class MachineLearningDataSupplyingService

  def self.get_abstract_label(project_id)
    project = Project.find(project_id)
    project_data = []

    for asr in project.abstract_screening_results do
      label_data = {
        'ti' => '',
        'abs' => '',
        'label' => ''
      }
      citation = asr.citation

      ti = citation.name.gsub('"', "'")
      if ti.nil? || ti.empty?
        next
      else
        label_data['ti'] = ti
      end

      abs = citation.abstract.gsub('"', "'")
      if abs.nil? || abs.empty?
        next
      else
        label_data['abs'] = abs
      end

      label = asr.label
      if label.nil?
        next
      else
        if label == 1
          label_data['label'] = '1'
        elsif label == -1
          label_data['label'] = '0'
        else
          next
        end
      end

      project_data.append(label_data)
    end

    return project_data
  end

end
