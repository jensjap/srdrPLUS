class MigratingRolesService
  def self.migrate_purs
    ProjectsUser.all.each do |pu|
      permissions = pu.projects_users_roles.inject(0) do |sum, pur|
        case pur.role.name
        when Role::LEADER
          1
        when Role::CONSOLIDATOR
          2
        when Role::CONTRIBUTOR
          4
        when Role::AUDITOR
          8
        end + sum
      end

      pu.update(permissions:)
    end
  end

  def self.permission_check
    correct = 0
    incorrect = 0
    ProjectsUser.all.each do |pu|
      permissions = 0
      pu.projects_users_roles.each do |pur|
        permissions += case pur.role.name
                       when Role::LEADER
                         1
                       when Role::CONSOLIDATOR
                         2
                       when Role::CONTRIBUTOR
                         4
                       when Role::AUDITOR
                         8
                       else
                         99_999
                       end
      end

      if permissions == pu.permissions
        correct += 1
      else
        incorrect += 1
      end
    end
    puts "correct: #{correct}"
    puts "incorrect: #{incorrect}"
  end
end
