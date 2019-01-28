json.project do
  json.id @project.id
  json.name @project.name
  json.description @project.description
  json.users  @project.projects_users do |pu|
    json.set! pu.id do
      json.email pu.user.email
      json.profile do
        json.username pu.user.profile.username
        json.first_name pu.user.profile.first_name
        json.middle_name pu.user.profile.middle_name
        json.last_name pu.user.profile.last_name
        json.organization do
          json.id pu.user.profile.organization.id
          json.name pu.user.profile.organization.name
        end
      end
      json.roles  pu.roles do |r|
        json.set! r.id do
          json.name r.name
        end
      end

      json.term_groups pu.projects_users_term_groups_colors do |putgc|
        json.set! putgc.term_group.id do
          json.color do 
            json.id putgc.color.id
            json.name putgc.color.name
            json.hex_code putgc.color.hex_code
          end
          json.name putgc.term_group.name
          json.terms putgc.terms do |term|
            json.set! term.id do
              json.name term.name
            end
          end
        end
      end
    end
  end

  json.key_questions @project.key_questions_projects do |kqp|
    json.set! kqp.key_question.id do
      json.name kqp.key_question.name
      #json.position kqp.ordering.position  ####### need to make sure kqp has ordering and position -Birol
    end
  end

  json.citations @project.citations_projects do |cp|
    json.set! cp.citation.id do
      json.name cp.citation.name
      json.abstract cp.citation.abstract
      json.journal do
        json.id cp.citation.journal.id
        json.name cp.citation.journal.name
      end
      json.keywords cp.citation.keywords do |kw|
        json.set! kw.id do
          json.name kw.name
        end
      end
      json.authors cp.citation.authors do |a|
        json.set! a.id do
          json.name a.name
        end
      end
      json.labels cp.labels do |ll|
        json.set! ll.id do
          json.labeler_user_id ll.projects_users_role.user.id 
          json.labeler_role_id ll.projects_users_role.role.id
          json.label_type_id ll.label_type.id
          
          json.reasons ll.reasons do |r|
            json.set! r.id do
              json.name r.name
            end
          end
        end
      end

      json.tags cp.taggings do |tt|
        json.set! tt.tag.id do
          json.creator_user_id tt.projects_users_role.user.id
          json.creator_role_id tt.projects_users_role.role.id
          json.name tt.tag.name
        end
      end

      json.notes cp.notes do |n|
        json.set! n.id do
          json.creator_user_id n.projects_users_role.user.id
          json.creator_role_id n.projects_users_role.role.id
          json.value n.value
        end
      end
    end
  end

  json.tasks @project.tasks do |tt|
    json.set! tt.id do
      json.task_type do
        json.id tt.task_type.id
        json.name tt.task_type.name
      end
      json.num_assigned tt.num_assigned
      json.assignments tt.assignments do |a|
        json.set! a.id do
          json.assignee_user_id a.projects_users_role.user.id
          json.assignee_role_id a.projects_users_role.role.id
          json.done_so_far a.done_so_far
          json.date_due a.date_due
          json.done a.done
        end
      end
    end
  end

  json.extraction_form do
    efp = @project.extraction_forms_projects.first
    ef = efp.extraction_form
    json.id ef.id

    json.sections efp.extraction_forms_projects_sections do |efps|
      json.set! efps.section.id do
        json.name efps.section.name
        json.position efps.ordering.position
        
        json.extraction_forms_projects_section_type do
          json.id efps.extraction_forms_projects_section_type.id
          json.name efps.extraction_forms_projects_section_type.name
        end

        if efps.extraction_forms_projects_section_option.present?
          json.extraction_forms_projects_section_option do
            json.id efps.extraction_forms_projects_section_option.id
            json.by_type1 efps.extraction_forms_projects_section_option.by_type1
            json.include_total efps.extraction_forms_projects_section_option.include_total
          end
        end

        if not efps.type1s.empty?
          json.type1s efps.type1s do |t1|
            json.set! t1.id do
              json.name t1.name
              json.description t1.description
            end
          end
        end

        if efps.link_to_type1.present?
          json.linked_type1 efps.link_to_type1.id
        end

        if not efps.questions.empty?
          json.questions efps.questions do |q|
            json.set! q.id do
              json.name q.name
              json.description q.description
              json.position q.ordering.position
              json.key_questions q.key_questions_projects do |kqp|
                json.set! kqp.key_question.id do
                  json.name kqp.key_question.name
                end
              end
              json.question_rows q.question_rows do |qr|
                json.set! qr.id do
                  json.name qr.name
                  json.question_row_columns qr.question_row_columns do |qrc|
                    json.set! qrc.id do
                      json.name qrc.name
                      json.question_row_column_type do
                        json.id qrc.question_row_column_type.id
                        json.name qrc.question_row_column_type.name
                      end
                      json.question_row_column_options qrc.question_row_column_options do |qrco|
                        json.set! qrco.id do
                          json.name qrco.name
                        end
                      end
                      json.question_row_column_fields qrc.question_row_column_fields do |qrcf|
                        json.set! qrcf.id do
                          json.name qrcf.name
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  if not @project.extractions.empty? do
    json.extractions @project.extractions do |ex|
      json.set! ex.id do
        json.citation_id ex.citations_project.citation.id
        json.extractor_user_id ex.projects_users_role.user.id
        json.extractor_role_id ex.projects_users_role.role.id
        json.sections ex.extractions_extraction_forms_projects_sections do |eefps|
          json.set! eefps.extraction_forms_projects_sections.section.id do
            #if not eefps.extractions_extraction_forms_projects_sections_type1s.empty?
            #  json.type1s eefps.extractions_extraction_forms_projects_sections_type1s do |eefpst1|
            #    t1 = eefpst1.type1
            #    json.set! t1.id do
            #      if eefpst1.type1_type.present?
            #        json.type1_type do
            #          json.id eefpst1.type1_type.id
            #          json.name eefpst1.type1_type.name
            #        end
            #      end
            #      json.name t1.name
            #      json.description t1.description
            #      
            #      if not eefpst1.extractions_extraction_forms_projects_sections_type1_rows.empty?
            #        json.populations eefpst1.extractions_extraction_forms_projects_sections_type1_rows do |p|
            #          json.set! p.population_name.id do
            #            json.name p.population_name.name
            #            json.timepoints p.extractions_extraction_forms_projects_sections_type1_row_columns do |tp|
            #              json.set! tp.timepoint_name.id do
            #                json.name tp.timepoint_name.name
            #              end
            #            end
            #          end
            #        end
            #      end
            #    end
            #  end
            #end
            
            #json.linked_type1 eefps.link_to_type1.id

            #json.records Record.where(recordable: eefps.extractions_extraction_forms_projects_sections_question_row_column_fields) do |r|
            #  json.set! r.recordable.question_row_column_fields do 
            #    json.name r.name
            #  end
            #end

            #if eefps.
          end
          end
        end
      end
    end
  end
end
