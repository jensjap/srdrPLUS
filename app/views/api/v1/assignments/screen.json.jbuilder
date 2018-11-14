json.unlabeled_citations_projects do
  json.array!(@unlabeled_citations_projects) do |citations_project|
    citation = citations_project.citation

    json.citations_project_id citations_project.id
    json.name citation.name
    json.abstract citation.abstract
    json.pmid citation.pmid
    json.refman citation.refman
    if citation.journal.present?
      json.journal do
        json.publication_date citation.journal.publication_date
        json.name citation.journal.name
        json.volume citation.journal.volume
        json.issue citation.journal.issue
      end
    end
    json.authors do
      json.array! citation.authors, :id, :name
    end
    json.keywords do
      json.array! citation.keywords, :id, :name
    end
    
    ## Not sure if we will ever display taggings that are not created by the screener, but we currently send the projects_users_role info regardless
    json.taggings citations_project.taggings do |tagging|
      json.id tagging.id
      json.tag do
        json.name tagging.tag.name
        json.id tagging.tag.id
      end
      json.user do 
        json.username tagging.projects_users_role.user.profile.username
        json.id tagging.projects_users_role.user.id
      end
    end

    json.notes citations_project.notes do |note|
      json.id note.id
      json.value note.value
      json.user do
        json.username note.projects_users_role.user.profile.username
        json.id note.projects_users_role.user.id
      end
    end
  end
end

json.labeled_citations_projects do
  json.array!(@past_labels) do |label|
    citation = label.citations_project.citation
    citations_project = label.citations_project

    json.citations_project_id citations_project.id
    json.name citation.name
    json.abstract citation.abstract
    json.pmid citation.pmid
    json.refman citation.refman
    if citation.journal.present?
      json.journal do
        json.publication_date citation.journal.publication_date
        json.name citation.journal.name
        json.volume citation.journal.volume
        json.issue citation.journal.issue
      end
    end
    json.authors do
      json.array! citation.authors, :id, :name
    end
    json.keywords do
      json.array! citation.keywords, :id, :name
    end

    json.taggings citations_project.taggings do |tagging|
      json.id tagging.id
      json.tag do
        json.name tagging.tag.name
        json.id tagging.tag.id
      end
      json.user do
        json.username tagging.projects_users_role.user.profile.username
        json.id tagging.projects_users_role.user.id
      end
    end

    json.notes citations_project.notes do |note|
      json.id note.id
      json.value note.value
      json.user do
        json.username note.projects_users_role.user.profile.username
        json.id note.projects_users_role.user.id
      end
    end

    json.label do
      json.id label.id
      json.value label.value
      json.projects_users_role_id label.projects_users_role_id
      json.created_at label.created_at
      json.updated_at label.updated_at
    end
  end
end
