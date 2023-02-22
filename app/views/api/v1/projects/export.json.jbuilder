json.project do
  json.id @project.id
  json.name @project.name
  json.description @project.description
  json.attribution @project.attribution
  json.methodology_description @project.methodology_description
  json.prospero @project.prospero
  json.doi @project.doi
  json.notes @project.notes
  json.funding_source @project.funding_source

  json.users do
    @project.projects_users.each do |pu|
      json.set! pu.user.id do
        json.email pu.user.email
        json.profile do
          json.username pu.user.username
          json.first_name pu.user.profile.first_name
          json.middle_name pu.user.profile.middle_name
          json.last_name pu.user.profile.last_name
          json.time_zone pu.user.profile.time_zone
          json.organization do
            json.id pu.user.profile.organization.id
            json.name pu.user.profile.organization.name
          end
          json.degrees do
            pu.user.profile.degrees.each do |degree|
              json.set! degree.id do
                json.name degree.name
              end
            end
          end
        end
      end
    end
  end

  json.key_questions do
    @project.key_questions_projects.each do |kqp|
      json.set! kqp.key_question.id do
        json.name kqp.key_question.name
        # json.position kqp.ordering.position  ####### need to make sure kqp has ordering and position -Birol
      end
    end
  end

  json.citations do
    @project.citations_projects.each do |cp|
      json.set! cp.citation.id do
        json.name cp.citation.name
        json.abstract cp.citation.abstract
        json.refman cp.citation.refman
        json.pmid cp.citation.pmid
        json.journal do
          json.id cp.citation.journal&.id
          json.name cp.citation.journal&.name
          json.volume cp.citation.journal&.volume
          json.issue cp.citation.journal&.issue
        end
        json.keywords do
          cp.citation.keywords.each do |kw|
            json.set! kw.id do
              json.name kw.name
            end
          end
        end
        json.authors cp.citation.authors
      end
    end
  end

  json.extraction_forms do
    @project.extraction_forms_projects.each do |efp|
      json.set! efp.id do
        json.sections do
          efp.extraction_forms_projects_sections.each do |efps|
            json.set! efps.id do
              json.section do
                json.id efps.section.id
                json.name efps.section.name
              end
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

              json.extraction_forms_projects_sections_type1s do
                efps.extraction_forms_projects_sections_type1s.each do |efpst1|
                  json.set! efpst1.id do
                    t1 = efpst1.type1
                    t1_type = efpst1.type1_type
                    json.type1 do
                      json.id t1.id
                      json.name t1.name
                      json.description t1.description
                    end
                    if t1_type.present?
                      json.type1_type do
                        json.id t1_type.id
                        json.name t1_type.name
                      end
                    end
                  end
                end
              end

              json.link_to_type1 efps.link_to_type1.id if efps.link_to_type1.present?

              json.questions do
                efps.questions.each do |q|
                  json.set! q.id do
                    json.name q.name
                    json.description q.description
                    json.position q.ordering.position
                    json.key_questions do
                      q.key_questions_projects.each do |kqp|
                        json.set! kqp.key_question.id do
                          json.name kqp.key_question.name
                        end
                      end
                    end
                    json.dependencies do
                      q.dependencies.each do |dep|
                        json.set! dep.id do
                          json.prerequisitable_id dep.prerequisitable_id
                          json.prerequisitable_type dep.prerequisitable_type
                        end
                      end
                    end
                    json.question_rows do
                      q.question_rows.order('id ASC').each do |qr|
                        json.set! qr.id do
                          json.name qr.name
                          json.question_row_columns do
                            qr.question_row_columns.order('id ASC').each do |qrc|
                              json.set! qrc.id do
                                json.name qrc.name
                                json.question_row_column_type do
                                  json.id qrc.question_row_column_type.id
                                  json.name qrc.question_row_column_type.name
                                end
                                json.question_row_columns_question_row_column_options do
                                  qrc.question_row_columns_question_row_column_options.order('id ASC').each do |qrcqrco|
                                    json.set! qrcqrco.id do
                                      qrco = qrcqrco.question_row_column_option
                                      json.name qrcqrco.name
                                      json.question_row_column_option do
                                        json.id qrco.id
                                        json.name qrco.name
                                      end
                                    end
                                  end
                                end
                                json.question_row_column_fields do
                                  qrc.question_row_column_fields.order('id ASC').each do |qrcf|
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
            end
          end
        end
      end
    end
  end

  json.extractions do
    @project.extractions.each do |ex|
      json.set! ex.id do
        json.citation_id ex.citations_project.citation.id
        json.extractor_user_id ex.user.id
        json.extractor_role ex.projects_user.highest_role_string
        json.sections do
          ex.extractions_extraction_forms_projects_sections.each do |eefps|
            json.set! eefps.extraction_forms_projects_section.id do
              json.extractions_extraction_forms_projects_sections_type1s do
                eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
                  t1 = eefpst1.type1
                  json.set! eefpst1.id do
                    json.type1 do
                      json.id t1.id
                      json.name t1.name
                      json.description t1.description
                    end

                    if eefpst1.type1_type.present?
                      json.type1_type do
                        json.id eefpst1.type1_type.id
                        json.name eefpst1.type1_type.name
                      end
                    end
                    json.units eefpst1.units

                    json.populations do
                      eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |pop|
                        json.set! pop.id do
                          json.population_name do
                            json.id pop.population_name.id
                            json.name pop.population_name.name
                          end

                          json.result_statistic_sections do
                            pop.result_statistic_sections.each do |rss|
                              json.set! rss.id do
                                json.result_statistic_section_type do
                                  json.id rss.result_statistic_section_type.id
                                  json.name rss.result_statistic_section_type.name
                                end
                                json.comparisons do
                                  rss.comparisons.each do |c|
                                    json.set! c.id do
                                      json.is_anova c.is_anova
                                      json.set! :comparate_groups do
                                        c.comparate_groups.each do |cg|
                                          json.set! cg.id do
                                            json.set! :comparates do
                                              cg.comparates.each do |ct|
                                                json.set! ct.id do
                                                  json.comparable_element do
                                                    ce = ct.comparable_element
                                                    json.id ce.id
                                                    json.comparable_type ce.comparable_type
                                                    json.comparable_id ce.comparable_id
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

                                json.result_statistic_sections_measures do
                                  rss.result_statistic_sections_measures.each do |rssm|
                                    m = rssm.measure
                                    json.set! rssm.id do
                                      json.measure do
                                        json.id m.id
                                        json.name m.name
                                      end

                                      json.records do
                                        json.tps_comparisons_rssms do
                                          rssm.tps_comparisons_rssms.each do |tcr|
                                            tcr.records.each do |r|
                                              json.set! r.id do
                                                json.timepoint_id tcr.timepoint.id
                                                json.comparison_id tcr.comparison.id
                                                json.record_name r.name
                                              end
                                            end
                                          end
                                        end
                                        json.tps_arms_rssms do
                                          rssm.tps_arms_rssms.each do |tar|
                                            tar.records.each do |r|
                                              json.set! r.id do
                                                json.timepoint_id tar.timepoint.id
                                                json.arm_id tar.extractions_extraction_forms_projects_sections_type1.id
                                                json.record_name r.name
                                              end
                                            end
                                          end
                                        end
                                        json.comparisons_arms_rssms do
                                          rssm.comparisons_arms_rssms.each do |car|
                                            car.records.each do |r|
                                              json.set! r.id do
                                                json.comparison_id car.comparison.id
                                                json.arm_id car.extractions_extraction_forms_projects_sections_type1.id
                                                json.record_name r.name
                                              end
                                            end
                                          end
                                        end
                                        json.wacs_bacs_rssms do
                                          rssm.wacs_bacs_rssms.each do |wbr|
                                            wbr.records.each do |r|
                                              json.set! r.id do
                                                json.wac_id wbr.wac.id
                                                json.bac_id wbr.bac.id
                                                json.record_name r.name
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

                          json.timepoints do
                            pop.extractions_extraction_forms_projects_sections_type1_row_columns.each do |tp|
                              json.set! tp.id do
                                json.timepoint_name do
                                  json.id tp.timepoint_name.id
                                  json.name tp.timepoint_name.name
                                  json.unit tp.timepoint_name.unit
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

              json.link_to_type1 eefps.link_to_type1.id if eefps.link_to_type1.present?

              json.records do
                Record.where(recordable: eefps.extractions_extraction_forms_projects_sections_question_row_column_fields).each do |r|
                  json.set! r.id do
                    json.question_row_column_field_id r.recordable.question_row_column_field.id
                    json.extractions_extraction_forms_projects_sections_type1_id r.recordable.extractions_extraction_forms_projects_sections_type1_id
                    json.name r.name
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
