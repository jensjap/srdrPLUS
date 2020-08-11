# require 'rails_helper'

# RSpec.describe "invitations/new", type: :view do
#   before(:each) do
#     assign(:invitation, Invitation.new(
#       :invitable => nil,
#       :enabled => false,
#       :role => nil
#     ))
#   end

#   it "renders new invitation form" do
#     render

#     assert_select "form[action=?][method=?]", invitations_path, "post" do

#       assert_select "input[name=?]", "invitation[invitable_id]"

#       assert_select "input[name=?]", "invitation[enable]"

#       assert_select "input[name=?]", "invitation[role_id]"
#     end
#   end
# end
