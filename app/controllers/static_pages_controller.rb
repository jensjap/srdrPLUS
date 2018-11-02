class StaticPagesController < ApplicationController
  before_action :skip_authorization, :skip_policy_scope, only: [:home, :help, :about]
  skip_before_action :authenticate_user!, only: [:home, :help, :about]

  SORT = {  'updated-at': { updated_at: :desc },
            'created-at': { created_at: :desc }
  }.stringify_keys

  def home
  end

  def help
  end

  def about
  end
end
