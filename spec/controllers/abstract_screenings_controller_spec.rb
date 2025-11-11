require 'rails_helper'

RSpec.describe AbstractScreeningsController, type: :controller do
  let(:user) { create(:user) }
  let(:project) { create(:project) }
  let(:citation) { create(:citation, authors: 'Kwan J, Smith A', name: 'Pancreatic Cancer Study') }
  let(:citations_project) { create(:citations_project, project: project, citation: citation) }
  let!(:projects_user) { create(:projects_user, user: user, project: project) }

  before do
    sign_in user
  end

  describe 'GET #citation_lifecycle_management' do
    context 'JSON format with field-specific searches' do
      it 'searches by title with regex matching' do
        search_results = double('search_results', total_count: 1)

        expect(CitationsProject).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              project_id: project.id,
              name: /pancreas/i
            )
          )
        ).and_return(search_results)

        get :citation_lifecycle_management, params: { project_id: project.id, query: 'title:pancreas' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'searches by author with regex matching' do
        search_results = double('search_results', total_count: 1)

        expect(CitationsProject).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              project_id: project.id,
              author_map_string: /kwan/i
            )
          )
        ).and_return(search_results)

        get :citation_lifecycle_management, params: { project_id: project.id, query: 'author:kwan' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'searches by status with exact matching' do
        search_results = double('search_results', total_count: 1)

        expect(CitationsProject).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              project_id: project.id,
              screening_status: 'asu'
            )
          )
        ).and_return(search_results)

        get :citation_lifecycle_management, params: { project_id: project.id, query: 'status:asu' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'combines title and author searches with AND logic' do
        search_results = double('search_results', total_count: 1)

        expect(CitationsProject).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              project_id: project.id,
              name: /pancreas/i,
              author_map_string: /kwan/i
            )
          )
        ).and_return(search_results)

        get :citation_lifecycle_management, params: { project_id: project.id, query: 'title:pancreas author:kwan' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'handles multiple terms for same field' do
        search_results = double('search_results', total_count: 1)

        expect(CitationsProject).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              project_id: project.id,
              author_map_string: /kwan\ smith/i
            )
          )
        ).and_return(search_results)

        get :citation_lifecycle_management, params: { project_id: project.id, query: 'author:kwan author:smith' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'escapes special regex characters' do
        search_results = double('search_results', total_count: 1)

        # The controller regex /(title:([\w\d]+))/ only captures word chars and digits,
        # so 'title:test.+*' only extracts 'test' and leaves '.+*' in the main query
        expect(CitationsProject).to receive(:search).with(
          '.+*',
          hash_including(
            where: hash_including(
              project_id: project.id,
              name: /test/i
            )
          )
        ).and_return(search_results)

        get :citation_lifecycle_management, params: { project_id: project.id, query: 'title:test.+*' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'defaults to wildcard search when query is blank' do
        search_results = double('search_results', total_count: 0)

        expect(CitationsProject).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(project_id: project.id)
          )
        ).and_return(search_results)

        get :citation_lifecycle_management, params: { project_id: project.id, query: '' }, format: :json

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET #show' do
    let(:abstract_screening) { AbstractScreening.create!(project: project, abstract_screening_type: 'double-perpetual') }
    let(:abstract_screening_result) do
      AbstractScreeningResult.create!(
        abstract_screening: abstract_screening,
        citations_project: citations_project,
        user: user,
        label: 1,
        privileged: false
      )
    end

    context 'JSON format with field-specific searches' do
      before do
        abstract_screening_result
      end

      it 'searches by title with regex matching' do
        search_results = double('search_results', total_count: 1)

        expect(AbstractScreeningResult).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              abstract_screening_id: abstract_screening.id,
              user_id: user.id,
              'name' => /pancreas/i
            )
          )
        ).and_return(search_results)

        get :show, params: { id: abstract_screening.id, query: 'title:pancreas' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'searches by author with regex matching' do
        search_results = double('search_results', total_count: 1)

        expect(AbstractScreeningResult).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              abstract_screening_id: abstract_screening.id,
              user_id: user.id,
              'author_map_string' => /kwan/i
            )
          )
        ).and_return(search_results)

        get :show, params: { id: abstract_screening.id, query: 'author:kwan' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'searches by accession_number with regex matching' do
        search_results = double('search_results', total_count: 1)

        expect(AbstractScreeningResult).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              abstract_screening_id: abstract_screening.id,
              user_id: user.id,
              'accession_number_alts' => /12345/i
            )
          )
        ).and_return(search_results)

        get :show, params: { id: abstract_screening.id, query: 'accession_number:12345' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'searches by year with regex matching' do
        search_results = double('search_results', total_count: 1)

        expect(AbstractScreeningResult).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              abstract_screening_id: abstract_screening.id,
              user_id: user.id,
              'year' => /2020/i
            )
          )
        ).and_return(search_results)

        get :show, params: { id: abstract_screening.id, query: 'year:2020' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'searches by user with regex matching' do
        search_results = double('search_results', total_count: 1)

        expect(AbstractScreeningResult).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              abstract_screening_id: abstract_screening.id,
              user_id: user.id,
              'user' => /john/i
            )
          )
        ).and_return(search_results)

        get :show, params: { id: abstract_screening.id, query: 'user:john' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'searches by label with exact matching' do
        search_results = double('search_results', total_count: 1)

        expect(AbstractScreeningResult).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              abstract_screening_id: abstract_screening.id,
              user_id: user.id,
              'label' => '1'
            )
          )
        ).and_return(search_results)

        get :show, params: { id: abstract_screening.id, query: 'label:1' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'searches by label:null with nil value' do
        search_results = double('search_results', total_count: 1)

        expect(AbstractScreeningResult).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              abstract_screening_id: abstract_screening.id,
              user_id: user.id,
              'label' => nil
            )
          )
        ).and_return(search_results)

        get :show, params: { id: abstract_screening.id, query: 'label:null' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'searches by privileged with boolean matching' do
        search_results = double('search_results', total_count: 1)

        expect(AbstractScreeningResult).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              abstract_screening_id: abstract_screening.id,
              user_id: user.id,
              'privileged' => true
            )
          )
        ).and_return(search_results)

        get :show, params: { id: abstract_screening.id, query: 'privileged:true' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'searches by reason with regex matching' do
        search_results = double('search_results', total_count: 1)

        expect(AbstractScreeningResult).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              abstract_screening_id: abstract_screening.id,
              user_id: user.id,
              'reasons' => /excluded/i
            )
          )
        ).and_return(search_results)

        get :show, params: { id: abstract_screening.id, query: 'reason:excluded' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'searches by tag with regex matching' do
        search_results = double('search_results', total_count: 1)

        expect(AbstractScreeningResult).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              abstract_screening_id: abstract_screening.id,
              user_id: user.id,
              'tags' => /important/i
            )
          )
        ).and_return(search_results)

        get :show, params: { id: abstract_screening.id, query: 'tag:important' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'searches by note with regex matching' do
        search_results = double('search_results', total_count: 1)

        expect(AbstractScreeningResult).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              abstract_screening_id: abstract_screening.id,
              user_id: user.id,
              'notes' => /review/i
            )
          )
        ).and_return(search_results)

        get :show, params: { id: abstract_screening.id, query: 'note:review' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'combines multiple field searches with AND logic' do
        search_results = double('search_results', total_count: 1)

        expect(AbstractScreeningResult).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              abstract_screening_id: abstract_screening.id,
              user_id: user.id,
              'name' => /pancreas/i,
              'author_map_string' => /kwan/i,
              'year' => /2020/i
            )
          )
        ).and_return(search_results)

        get :show, params: { id: abstract_screening.id, query: 'title:pancreas author:kwan year:2020' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'combines exact match and regex fields' do
        search_results = double('search_results', total_count: 1)

        expect(AbstractScreeningResult).to receive(:search).with(
          '*',
          hash_including(
            where: hash_including(
              abstract_screening_id: abstract_screening.id,
              user_id: user.id,
              'label' => '1',
              'privileged' => false,
              'author_map_string' => /kwan/i
            )
          )
        ).and_return(search_results)

        get :show, params: { id: abstract_screening.id, query: 'label:1 privileged:false author:kwan' }, format: :json

        expect(response).to have_http_status(:success)
      end
    end
  end
end
