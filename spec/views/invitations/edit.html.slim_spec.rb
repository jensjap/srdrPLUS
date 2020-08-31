# require 'rails_helper'

# RSpec.describe "invitations/edit", type: :view do
#   before(:each) do
#     @invitation = assign(:invitation, Invitation.create!(
#       :invitable => nil,
#       :enabled => false,
#       :role => nil
#     ))
#   end

#   it "renders the edit invitation form" do
#     render

#     assert_select "form[action=?][method=?]", invitation_path(@invitation), "post" do

#       assert_select "input[name=?]", "invitation[invitable_id]"

#       assert_select "input[name=?]", "invitation[enable]"

#       assert_select "input[name=?]", "invitation[role_id]"
#     end
#   end
# end
