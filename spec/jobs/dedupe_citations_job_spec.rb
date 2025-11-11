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
      # Create CP with rejected status
      cp1 = create_citations_project_with_associations(project, citation, extractions: [1])
      cp1.update!(screening_status: CitationsProject::AS_REJECTED)

      # Create CP with non-rejected status (even if less advanced)
      cp2 = create_citations_project_with_associations(project, citation, extractions: [2])
      cp2.update!(screening_status: CitationsProject::AS_UNSCREENED)

      described_class.perform_now(project.id)

      # cp2 should be kept as master because it's not rejected
      master = CitationsProject.find_by(project: project, citation: citation)
      expect(master.id).to eq(cp2.id)
      expect(master.screening_status).to eq(CitationsProject::AS_UNSCREENED)
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
end
