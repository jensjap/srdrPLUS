require 'test_helper'

class SearchesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get url_for( action: 'new', controller: 'searches' )
    assert_response :success
  end

  test "should get create" do
    params = { searches: 
               { projects_search: 
                 { public: "", 
                   name: "", 
                   description: "", 
                   attribution: "", 
                   methodology_description: "", 
                   prospero: "", 
                   doi: "", 
                   notes: "", 
                   funding_source: "", 
                   members: "", 
                   "after(1i)" => "", 
                   "after(2i)" => "", 
                   "after(3i)" => "", 
                   "before(1i)" => "", 
                   "before(2i)" => "", 
                   "before(3i)" => "", 
                   "arm" => "", 
                   "outcome" => "" } } }
    post url_for( action: 'create', controller: 'searches' ), params: params

    assert_response :success
  end

end
