require 'test_helper'

class CitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
    @citation = citations(:one)
    @journal = journals(:one)
    @keyword_1 = keywords(:one)
    @keyword_2 = keywords(:two)
    @author_1 = authors(:one)
    @author_2 = authors(:two)
  end

  test 'should create citation' do
    assert_difference('Citation.count') do
      post citations_url, params:
        { citation: { name: @citation.name,
                      citation_type_id: @citation.citation_type_id,
                      pmid: @citation.pmid,
                      refman: @citation.refman,
                      journal_attributes: { name: @journal.name },
                      authors_attributes: { '0': { name: @author_1.name },
                                            '1': { name: @author_2.name } },
                      keywords_attributes: { '0': { name: @keyword_1.name },
                                             '1': { name: @keyword_2.name } } } }
    end
    assert_redirected_to edit_citation_url(Citation.last)
  end

  test "should get new" do
    get new_citation_url
    assert_response :success
  end

  test "should get update" do
    patch citation_url(@citation), params:
        { citation: { name: @citation.name,
                      citation_type_id: @citation.citation_type_id,
                      pmid: @citation.pmid,
                      refman: @citation.refman,
                      journal_attributes: { name: @journal.name },
                      authors_attributes: { '0': { name: @author_1.name },
                                            '1': { name: @author_2.name } },
                      keywords_attributes: { '0': { name: @keyword_1.name },
                                             '1': { name: @keyword_2.name } } } }
    assert_redirected_to edit_citation_url(@citation)
  end

  test "should get edit" do
    get edit_citation_url(@citation)
    assert_response :success
  end

  test 'should destroy citation' do
    assert_difference('Citation.count', -1) do
      delete citation_url(@citation)
    end
    assert_redirected_to citations_url
  end

end
