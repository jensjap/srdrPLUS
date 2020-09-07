task add_api_key: [:environment] do
  User.all.each do |user|
    user.regenerate_api_key unless user.api_key
  end
end
  
task regenerate_all_api_keys: [:environment] do
  User.all.each(&:regenerate_api_key)
end