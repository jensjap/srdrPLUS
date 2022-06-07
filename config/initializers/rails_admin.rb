# RailsAdmin.config do |config|
#   config.asset_source = :sprockets

#   ### Popular gems integration

#   ## == Devise ==
#   config.authenticate_with do
#     warden.authenticate! scope: :user
#   end
#   config.current_user_method(&:current_user)

#   ## == Cancan ==
#   # config.authorize_with :cancan

#   ## == Pundit ==
#   # config.authorize_with :pundit

#   ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

#   ## == Gravatar integration ==
#   ## To disable Gravatar integration in Navigation Bar set to false
#   # config.show_gravatar true

#   config.actions do
#     dashboard                     # mandatory
#     index                         # mandatory
#     new
#     export
#     bulk_delete
#     show
#     edit
#     delete
#     show_in_app

#     ## With an audit adapter, you can add:
#     # history_index
#     # history_show
#   end
# end
