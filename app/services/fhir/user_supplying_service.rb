class UserSupplyingService

  def find_by_user_id(user_id)
    user = User.find(user_id)

    first_name = user.first_name
    middle_name = user.middle_name
    last_name = user.last_name

    FhirResourceService.get_practitioner(
      srdrplus_type: 'User',
      id_prefix: '16',
      srdrplus_id: user.id,
      first_name: first_name,
      middle_name: middle_name,
      last_name: last_name
    )
  end

end
