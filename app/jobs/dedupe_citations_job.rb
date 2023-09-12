class DedupeCitationsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"
    @project = Project.find args.first

    # This takes care of citations that have been added to the project
    # multiple times.
    @project.citations_projects
      .group_by { |x| x.citation_id }
      .select { |k, v| v.size > 1 }
      .each do |cp_id, lsof_cp|
      cp = lsof_cp.first
      Rails.logger.debug "Removing duplicate instances of #{ cp }"
      cp.dedupe
    end

    # This takes care of Citations that are duplications of each other.
    # We check by citation_type, name, pmid and abstract.
    sub_query = @project.citations
      .select(
        :citation_type_id,
        :name,
        :pmid,
        :abstract)
      .group(
        :citation_type_id,
        :name,
        :pmid,
        :abstract)
      .having("count(*) > 1")
    citations_that_have_multiple_entries = @project.citations.joins("INNER JOIN (#{ sub_query.to_sql }) as t1").distinct

    # Group citations and dedupe each group.
    cthme_groups = citations_that_have_multiple_entries.group_by { |i| [i.citation_type_id, i.name, i.pmid, i.abstract] }
    cthme_groups.each do |cthme_group|
      master_citation = cthme_group[1][0]
      cthme_group[1][1..-1].each do |cit|
        master_cp = CitationsProject.find_by(citation_id: master_citation.id, project_id: @project.id)
        cp_to_remove = CitationsProject.find_by(citation_id: cit.id, project_id: @project.id)
        if master_cp && cp_to_remove
          CitationsProject.dedupe_update_associations(master_cp, cp_to_remove)
        end
        Rails.logger.debug "Removing duplicate instances of #{ cit }"
        cit.destroy
      end
    end
  end
end
