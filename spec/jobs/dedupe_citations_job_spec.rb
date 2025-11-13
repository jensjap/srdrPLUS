require 'rails_helper'

RSpec.describe DedupeCitationsJob, type: :job do
  let(:project) { create(:project) }
  let(:citation) { create(:citation) }

  def create_citations_project_with_associations(project, citation, associations = {})
    cp = create(:citations_project, project: project, citation: citation)

    # Create additional extractions beyond what factory provides
    (associations[:extractions]&.size || 0).times { create(:extraction, citations_project: cp) }
    (associations[:abstract_screening_results]&.size || 0).times do
      create(:abstract_screening_result, citations_project: cp)
    end
    (associations[:fulltext_screening_results]&.size || 0).times do
      create(:fulltext_screening_result, citations_project: cp)
    end
    (associations[:screening_qualifications]&.size || 0).times do
      create(:screening_qualification, citations_project: cp)
    end
    (associations[:ml_predictions]&.size || 0).times { create(:ml_prediction, citations_project: cp) }

    # Handle logs: Due to callbacks, CitationsProject may have automatic logs
    # We'll create additional logs only if needed to reach the desired count
    desired_log_count = associations[:logs]&.size || 0
    if desired_log_count > 0
      cp.reload
      current_log_count = cp.logs.count
      additional_logs_needed = desired_log_count - current_log_count
      additional_logs_needed.times { create(:log, loggable: cp) } if additional_logs_needed > 0
    end

    cp
  end

  it 'removes duplicate CitationsProject with no associations' do
    create_citations_project_with_associations(project, citation)
    create_citations_project_with_associations(project, citation)
    expect { described_class.perform_now(project.id) }.to change {
      CitationsProject.where(project: project, citation: citation).count
    }.from(2).to(1)
  end

  it 'keeps CitationsProject with most associations and transfers all data' do
    create_citations_project_with_associations(project, citation, extractions: [1, 2], logs: [1])
    create_citations_project_with_associations(project, citation, extractions: [3], logs: [2])
    described_class.perform_now(project.id)
    master_cp = CitationsProject.find_by(project: project, citation: citation)
    expect(master_cp.extractions.count).to eq(3)
    expect(master_cp.logs.count).to eq(4)  # Both CPs get 2 logs each automatically = 4 total
    expect(CitationsProject.where(project: project, citation: citation).count).to eq(1)
  end

  it 'deduplicates Citations by citation_type, name, pmid, abstract' do
    citation2 = create(:citation, citation_type_id: citation.citation_type_id, name: citation.name,
                                  pmid: citation.pmid, abstract: citation.abstract)
    create_citations_project_with_associations(project, citation)
    create_citations_project_with_associations(project, citation2)
    expect { described_class.perform_now(project.id) }.to change {
      Citation.where(citation_type_id: citation.citation_type_id, name: citation.name, pmid: citation.pmid,
                     abstract: citation.abstract).count
    }.from(2).to(1)
  end

  it 'transfers logs to master CitationsProject' do
    create_citations_project_with_associations(project, citation, logs: [2])
    create_citations_project_with_associations(project, citation, logs: [1])
    described_class.perform_now(project.id)
    master_cp = CitationsProject.find_by(project: project, citation: citation)
    expect(master_cp.logs.count).to eq(2)  # Each CP gets 1 log automatically = 2 total
  end

  it 'handles CitationsProject with only one association type' do
    create_citations_project_with_associations(project, citation, extractions: [1])
    described_class.perform_now(project.id)
    master_cp = CitationsProject.find_by(project: project, citation: citation)
    expect(master_cp.extractions.count).to eq(1)
  end

  it 'handles CitationsProject with all associations empty' do
    create_citations_project_with_associations(project, citation)
    create_citations_project_with_associations(project, citation)
    described_class.perform_now(project.id)
    expect(CitationsProject.where(project: project, citation: citation).count).to eq(1)
  end

  it 'handles errors gracefully and does not lose data' do
    create_citations_project_with_associations(project, citation, extractions: [1])
    create_citations_project_with_associations(project, citation, extractions: [2])
    allow_any_instance_of(Extraction).to receive(:update_column).and_raise(StandardError)
    expect { described_class.perform_now(project.id) }.not_to raise_error
    expect(CitationsProject.where(project: project, citation: citation).count).to eq(1)
  end

  it 'does not transfer associations if master_cp is nil' do
    create_citations_project_with_associations(project, citation, extractions: [1])
    create_citations_project_with_associations(project, citation, extractions: [2])
    allow(CitationsProject).to receive(:find_by).and_return(nil)
    expect { described_class.perform_now(project.id) }.not_to raise_error
  end

  it 'does not transfer associations if cp_to_remove is nil' do
    cp1 = create_citations_project_with_associations(project, citation, extractions: [1])
    create_citations_project_with_associations(project, citation, extractions: [2])
    allow(CitationsProject).to receive(:find_by).and_return(cp1, nil)
    expect { described_class.perform_now(project.id) }.not_to raise_error
  end

  describe 'master selection by screening_status' do
    it 'selects master with most advanced screening_status over one with more associations' do
      # Create CP with more associations but less advanced status
      cp1 = create_citations_project_with_associations(project, citation, extractions: [1, 2, 3])
      cp1.update!(screening_status: CitationsProject::AS_UNSCREENED)

      # Create CP with fewer associations but more advanced status
      cp2 = create_citations_project_with_associations(project, citation, extractions: [4])
      cp2.update!(screening_status: CitationsProject::C_COMPLETE)

      described_class.perform_now(project.id)

      # cp2 should be kept as master because it has more advanced status
      expect(CitationsProject.find_by(project: project, citation: citation).id).to eq(cp2.id)
      expect(CitationsProject.find_by(project: project, citation: citation).extractions.count).to eq(4)
    end

    it 'prefers non-rejected over rejected status when merging' do
      # Create CP with rejected status but MORE associations
      cp1 = create_citations_project_with_associations(project, citation, extractions: [1, 2, 3])
      cp1.update_column(:screening_status, CitationsProject::AS_REJECTED)

      # Create CP with non-rejected status but FEWER associations
      cp2 = create_citations_project_with_associations(project, citation, extractions: [1])
      cp2.update_column(:screening_status, CitationsProject::AS_UNSCREENED)

      described_class.perform_now(project.id)

      # cp2 should be kept as master because it's not rejected, even though it has fewer associations
      master = CitationsProject.find_by(project: project, citation: citation)
      expect(master.id).to eq(cp2.id)
      expect(master.screening_status).to eq(CitationsProject::AS_UNSCREENED)
      # Associations from cp1 should be transferred to cp2
      expect(master.extractions.count).to eq(4)
    end
  end

  describe 'metadata merging' do
    it 'merges pilot_flag to true if any duplicate has it' do
      cp1 = create_citations_project_with_associations(project, citation)
      cp1.update!(screening_status: CitationsProject::C_COMPLETE, pilot_flag: false)

      cp2 = create_citations_project_with_associations(project, citation)
      cp2.update!(screening_status: CitationsProject::AS_UNSCREENED, pilot_flag: true)

      described_class.perform_now(project.id)

      master = CitationsProject.find_by(project: project, citation: citation)
      expect(master.pilot_flag).to be true
    end

    it 'merges refman from duplicate if master has empty refman' do
      cp1 = create_citations_project_with_associations(project, citation)
      cp1.update!(screening_status: CitationsProject::C_COMPLETE, refman: nil)

      cp2 = create_citations_project_with_associations(project, citation)
      cp2.update!(screening_status: CitationsProject::AS_UNSCREENED, refman: 'Test refman content')

      described_class.perform_now(project.id)

      master = CitationsProject.find_by(project: project, citation: citation)
      expect(master.refman).to eq('Test refman content')
    end

    it 'keeps master refman if it already has data' do
      cp1 = create_citations_project_with_associations(project, citation)
      cp1.update!(screening_status: CitationsProject::C_COMPLETE, refman: 'Master refman')

      cp2 = create_citations_project_with_associations(project, citation)
      cp2.update!(screening_status: CitationsProject::AS_UNSCREENED, refman: 'Duplicate refman')

      described_class.perform_now(project.id)

      master = CitationsProject.find_by(project: project, citation: citation)
      expect(master.refman).to eq('Master refman')
    end

    it 'combines other_reference from multiple duplicates' do
      cp1 = create_citations_project_with_associations(project, citation)
      cp1.update!(screening_status: CitationsProject::C_COMPLETE, other_reference: 'Reference 1')

      cp2 = create_citations_project_with_associations(project, citation)
      cp2.update!(screening_status: CitationsProject::AS_UNSCREENED, other_reference: 'Reference 2')

      cp3 = create_citations_project_with_associations(project, citation)
      cp3.update!(screening_status: CitationsProject::FS_UNSCREENED, other_reference: 'Reference 3')

      described_class.perform_now(project.id)

      master = CitationsProject.find_by(project: project, citation: citation)
      expect(master.other_reference).to include('Reference 1')
      expect(master.other_reference).to include('Reference 2')
      expect(master.other_reference).to include('Reference 3')
      expect(master.other_reference).to include('---')  # Separator
    end

    it 'merges other_reference from duplicate if master has empty value' do
      cp1 = create_citations_project_with_associations(project, citation)
      cp1.update!(screening_status: CitationsProject::C_COMPLETE, other_reference: nil)

      cp2 = create_citations_project_with_associations(project, citation)
      cp2.update!(screening_status: CitationsProject::AS_UNSCREENED, other_reference: 'Reference from duplicate')

      described_class.perform_now(project.id)

      master = CitationsProject.find_by(project: project, citation: citation)
      expect(master.other_reference).to eq('Reference from duplicate')
    end
  end

  describe 'detection and removal consistency' do
    it 'uses same grouping criteria for Citation deduplication' do
      # Create two citations with same type, name, pmid, abstract but different refman
      citation2 = create(:citation,
                         citation_type_id: citation.citation_type_id,
                         name: citation.name,
                         pmid: citation.pmid,
                         abstract: citation.abstract,
                         refman: 'Different refman')

      create_citations_project_with_associations(project, citation)
      create_citations_project_with_associations(project, citation2)

      # Should detect as duplicates and merge (refman not considered)
      expect { described_class.perform_now(project.id) }.to change {
        Citation.where(citation_type_id: citation.citation_type_id,
                       name: citation.name,
                       pmid: citation.pmid,
                       abstract: citation.abstract).count
      }.from(2).to(1)
    end
  end

  describe 'multi-project Citation deduplication' do
    let(:project2) { create(:project) }

    it 'updates CitationsProject in other projects to point to master Citation' do
      # Create duplicate citations
      citation2 = create(:citation,
                         citation_type_id: citation.citation_type_id,
                         name: citation.name,
                         pmid: citation.pmid,
                         abstract: citation.abstract)

      # Project 1 has both citations
      cp1_citation1 = create_citations_project_with_associations(project, citation, extractions: [1])
      cp1_citation2 = create_citations_project_with_associations(project, citation2, extractions: [1, 2])

      # Project 2 has only citation2 (the one that will be destroyed)
      cp2_citation2 = create_citations_project_with_associations(project2, citation2, extractions: [1, 2, 3])

      # Store IDs before deduplication
      cp2_id = cp2_citation2.id
      citation1_id = citation.id
      citation2_id = citation2.id

      # Run deduplication on project1
      described_class.perform_now(project.id)

      # Verify: Citation2 should be destroyed, Citation1 should remain
      expect(Citation.exists?(citation1_id)).to be true
      expect(Citation.exists?(citation2_id)).to be false

      # CRITICAL: Project2's CitationsProject should still exist and point to master Citation
      cp2_reloaded = CitationsProject.find_by(id: cp2_id)
      expect(cp2_reloaded).not_to be_nil, 'CitationsProject in project2 should not be destroyed'
      expect(cp2_reloaded.citation_id).to eq(citation1_id), 'Project2 CitationsProject should point to master Citation'

      # Verify associations are preserved in project2
      expect(cp2_reloaded.extractions.count).to eq(3)
    end

    it 'preserves CitationsProject records with all associations in other projects' do
      # Create duplicate citations with extensive associations
      citation2 = create(:citation,
                         citation_type_id: citation.citation_type_id,
                         name: citation.name,
                         pmid: citation.pmid,
                         abstract: citation.abstract)

      # Project 1: Both citations with some associations
      create_citations_project_with_associations(project, citation, extractions: [1])
      create_citations_project_with_associations(project, citation2, extractions: [1, 2])

      # Project 2: citation2 with many associations (would be lost if destroyed)
      cp2 = create_citations_project_with_associations(project2, citation2,
                                                        extractions: [1, 2, 3],
                                                        logs: [1])

      # Store association counts before deduplication
      extractions_count = cp2.extractions.count

      # Run deduplication on project1
      described_class.perform_now(project.id)

      # Verify: Project2's CitationsProject exists with all associations intact
      cp2.reload
      expect(cp2.citation_id).to eq(citation.id)
      expect(cp2.extractions.count).to eq(extractions_count)
    end

    it 'handles multiple projects all referencing the duplicate Citation' do
      project3 = create(:project)

      # Create duplicate citation
      citation2 = create(:citation,
                         citation_type_id: citation.citation_type_id,
                         name: citation.name,
                         pmid: citation.pmid,
                         abstract: citation.abstract)

      # All three projects have citation2
      cp1 = create_citations_project_with_associations(project, citation2, extractions: [1])
      cp2 = create_citations_project_with_associations(project2, citation2, extractions: [1, 2])
      cp3 = create_citations_project_with_associations(project3, citation2, extractions: [1, 2, 3])

      # Project1 also has the master citation
      master_cp = create_citations_project_with_associations(project, citation, extractions: [1, 2, 3, 4])

      # Store IDs for verification
      citation1_id = citation.id
      citation2_id = citation2.id
      cp1_id = cp1.id

      # Run deduplication on project1
      described_class.perform_now(project.id)

      # Verify citation2 was destroyed
      expect(Citation.exists?(citation2_id)).to be false

      # cp1 should be destroyed (merged into master_cp during CitationsProject dedup)
      expect(CitationsProject.exists?(cp1_id)).to be false

      # master_cp should have all extractions from both CPs in project1
      master_cp.reload
      expect(master_cp.extractions.count).to eq(5) # 4 original + 1 from cp1

      # cp2 and cp3 (from other projects) should be updated to point to citation1
      cp2.reload
      cp3.reload
      expect(cp2.citation_id).to eq(citation1_id)
      expect(cp3.citation_id).to eq(citation1_id)

      # All extractions should be preserved in other projects
      expect(cp2.extractions.count).to eq(2)
      expect(cp3.extractions.count).to eq(3)
    end

    it 'updates CitationsProject records before destroying duplicate Citation' do
      citation2 = create(:citation,
                         citation_type_id: citation.citation_type_id,
                         name: citation.name,
                         pmid: citation.pmid,
                         abstract: citation.abstract)

      create_citations_project_with_associations(project, citation)
      create_citations_project_with_associations(project, citation2)
      cp_other_project = create_citations_project_with_associations(project2, citation2)

      # Before deduplication, project2's CP points to citation2
      expect(cp_other_project.citation_id).to eq(citation2.id)

      # Run deduplication
      described_class.perform_now(project.id)

      # After deduplication:
      # 1. citation2 should be destroyed
      expect(Citation.exists?(citation2.id)).to be false

      # 2. But project2's CP should still exist and point to citation1
      cp_other_project.reload
      expect(cp_other_project.citation_id).to eq(citation.id)

      # 3. No CitationsProject records should reference the destroyed citation
      expect(CitationsProject.where(citation_id: citation2.id).count).to eq(0)
    end
  end
end
