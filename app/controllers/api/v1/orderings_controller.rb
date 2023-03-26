module Api
  module V1
    class OrderingsController < BaseController
      ORDERABLES = %w[
        abstract_screenings_reasons
        abstract_screenings_reasons_users
        abstract_screenings_tags
        abstract_screenings_tags_users
        extraction_forms_projects_sections
        extraction_forms_projects_sections_type1s
        extractions_extraction_forms_projects_sections_type1s
        fulltext_screenings_reasons
        fulltext_screenings_reasons_users
        fulltext_screenings_tags
        fulltext_screenings_tags_users
        key_questions_projects
        questions
        result_statistic_sections_measures
        sd_analytic_frameworks
        sd_evidence_tables
        sd_grey_literature_searches
        sd_journal_article_urls
        sd_key_questions
        sd_key_questions_sd_picods
        sd_meta_regression_analysis_results
        sd_narrative_results
        sd_network_meta_analysis_results
        sd_other_items
        sd_pairwise_meta_analytic_results
        sd_picods
        sd_prisma_flows
        sd_result_items
        sd_search_strategies
        sd_summary_of_evidences
        sf_columns
        sf_options
        sf_questions
        sf_rows
      ].freeze

      DEPENDABLES = %w[
        followup_fields
        quality_dimension_options
        quality_dimension_questions
        question_row_column_fields
        question_row_columns
        question_row_columns_question_row_column_options
        questions
        result_statistic_section_types_measures
        result_statistic_sections_measures
      ].freeze

      def update_positions
        ActiveRecord::Base.transaction do
          orderings_params['orderings'].values.each_with_index do |o, index|
            table_name = o['table']
            next unless ORDERABLES.include?(table_name)

            orderable = table_name.classify.constantize.find(o['id'])
            orderable.update!(pos: index + 1)
          end

          if ActiveModel::Type::Boolean.new.cast(orderings_params[:drop_conflicting_dependencies])
            orderings_params['lsof_orderings_to_remove_dependencies'].each do |o|
              table_name = o['table']
              next unless DEPENDABLES.include?(table_name)

              orderable = table_name.classify.constantize.find(o['id'])
              orderable.dependencies.destroy_all
            end
          end

        respond_to do |format|
          format.json { render json: {}, status: 200 }
        end
      end

      private

      def orderings_params
        params.permit(
          :drop_conflicting_dependencies,
          lsof_orderings_to_remove_dependencies: %i[id table],
          orderings: %i[id position table]
        )
      end
    end
  end
end
