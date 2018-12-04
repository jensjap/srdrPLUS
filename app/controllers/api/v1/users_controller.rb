module Api
  module V1
    class UsersController < BaseController
      def index
        page          = ( params[ :page ] || 1 ).to_i
        page_size     = 100
        query         = params[ :q ] || ''
        user_ids_from_other_projects = current_user.
            projects.
            map{|project| project.users}.
            flatten.
            map{|user| user.id}.
            uniq

        exact_match_user_ids = User.joins(:profile).
          where(profiles: { username: query }).map{ |user| user.id }

        exact_email_match_user_ids = User.where(email: query).map{ |user| user.id }

        approximate_match_user_ids = User.joins(:profile).
            where('profiles.username LIKE ? AND users.id IN (' + user_ids_from_other_projects.join(',') + ')', 
                  "%#{ query }%").map{ |user| user.id }

        approximate_email_match_user_ids = User.
            where('users.email LIKE ? AND users.id IN (' + user_ids_from_other_projects.join(',') + ')', 
                  "%#{ query }%").map{ |user| user.id }

        all_user_ids  = (exact_match_user_ids + exact_email_match_user_ids + approximate_match_user_ids + approximate_email_match_user_ids).uniq

        all_users     = User.where(id: all_user_ids).
                        includes(:profile)

        offset        = [ page_size * ( page - 1 ), all_users.length ].min
        @users        = all_users[ offset .. offset + page_size - 1 ]
        @more         = if offset + @users.length < all_users.length then true else false end

      end
    end
  end
end

