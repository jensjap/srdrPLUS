# == Schema Information
#
# Table name: sd_meta_data_queries
#
#  id               :bigint           not null, primary key
#  query_text       :text(16777215)
#  sd_meta_datum_id :bigint
#  projects_user_id :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class SdMetaDataQuery < ApplicationRecord
  belongs_to :sd_meta_datum
  belongs_to :projects_user

  before_create :add_names_to_query_hash

  delegate :project, to: :projects_user
  delegate :user, to: :projects_user

  def query_hash
    Rack::Utils.parse_nested_query(query_text)
  end

  private

  # we are adding extra keys to the params hash we saved, so that this params can be: 
  #   1) used for naming the contents of ".query-item" element
  #   2) passed into ProjectReportLinksControllers' "options_form" action 
  def add_names_to_query_hash
    query_hash = Rack::Utils.parse_nested_query self.query_text

    query_hash['project_report_link_id'] = self.sd_meta_datum_id

    query_hash['type1_names'] ||= {}
    query_hash['type1s'].each do |efps_id, t1_id_arr|
      section_name = ExtractionFormsProjectsSection.find(efps_id).section.name
      Type1.find(t1_id_arr).each do |t1|
        query_hash['type1_names'][section_name] ||= []
        query_hash['type1_names'][section_name] << t1.name
      end
    end

    query_hash['key_question_names'] ||= []
    query_hash['kqp_ids'].each do |kqp_id|
      query_hash['key_question_names'] << KeyQuestionsProject.find(kqp_id).key_question.name
    end

    query_hash['columns'].each do |idx, column_hash|
      column_hash['export_items'].each do |idy, export_item_hash|
        if export_item_hash['type'] == 'Type2'
          query_hash['columns'][idx]['export_items'][idy]['name'] = Question.find(export_item_hash['export_id']).name
        else
          query_hash['columns'][idx]['export_items'][idy]['name'] = ResultStatisticSectionsMeasure.find(export_item_hash['export_id']).measure.name
        end
      end
    end
    self.query_text = query_hash.to_query
  end
end
