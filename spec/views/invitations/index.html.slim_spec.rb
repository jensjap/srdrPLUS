# require 'rails_helper'

# RSpec.describe "invitations/index", type: :view do
#   before(:each) do
#     assign(:invitations, [
#       Invitation.create!(
#         :invitable => nil,
#         :enabled => false,
#         :role => nil
#       ),
#       Invitation.create!(
#         :invitable => nil,
#         :enabled => false,
#         :role => nil
#       )
#     ])
#   end

#   it "renders a list of invitations" do
#     render
#     assert_select "tr>td", :text => nil.to_s, :count => 2
#     assert_select "tr>td", :text => false.to_s, :count => 2
#     assert_select "tr>td", :text => nil.to_s, :count => 2
#   end
# end
