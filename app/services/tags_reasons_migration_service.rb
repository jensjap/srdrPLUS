class TagsReasonsMigrationService
  def self.run_migration
    run_as_tags_migrations
    run_fs_tags_migrations
    run_as_reasons_migrations
    run_fs_reasons_migrations
  end

  def self.run_as_tags_migrations
    AbstractScreeningsTag.left_joins(:abstract_screening).where(abstract_screening: { id: nil }).destroy_all
    AbstractScreeningsTag.includes(abstract_screening: :project).all.each do |ast|
      screening_type = 'abstract'
      ProjectsTag.find_or_create_by(
        tag: ast.tag,
        project: ast.abstract_screening.project,
        screening_type:
      )
    end
    AbstractScreeningsTagsUser.left_joins(:abstract_screening).where(abstract_screening: { id: nil }).destroy_all
    AbstractScreeningsTagsUser.includes(abstract_screening: :project).all.each do |astu|
      screening_type = 'abstract'
      ProjectsTag.find_or_create_by(
        tag: astu.tag,
        project: astu.abstract_screening.project,
        screening_type:
      )
    end
  end

  def self.run_fs_tags_migrations
    FulltextScreeningsTag.left_joins(:fulltext_screening).where(fulltext_screening: { id: nil }).destroy_all
    FulltextScreeningsTag.includes(fulltext_screening: :project).all.each do |fst|
      screening_type = 'fulltext'
      ProjectsTag.find_or_create_by(
        tag: fst.tag,
        project: fst.fulltext_screening.project,
        screening_type:
      )
    end
    FulltextScreeningsTagsUser.left_joins(:fulltext_screening).where(fulltext_screening: { id: nil }).destroy_all
    FulltextScreeningsTagsUser.includes(fulltext_screening: :project).all.each do |fstu|
      screening_type = 'fulltext'
      ProjectsTag.find_or_create_by(
        tag: fstu.tag,
        project: fstu.fulltext_screening.project,
        screening_type:
      )
    end
  end

  def self.run_as_reasons_migrations
    AbstractScreeningsReason.left_joins(:abstract_screening).where(abstract_screening: { id: nil }).destroy_all
    AbstractScreeningsReason.includes(abstract_screening: :project).all.each do |asr|
      screening_type = 'abstract'
      ProjectsReason.find_or_create_by(
        reason: asr.reason,
        project: asr.abstract_screening.project,
        screening_type:
      )
    end
    AbstractScreeningsReasonsUser.left_joins(:abstract_screening).where(abstract_screening: { id: nil }).destroy_all
    AbstractScreeningsReasonsUser.includes(abstract_screening: :project).all.each do |asru|
      screening_type = 'abstract'
      ProjectsReason.find_or_create_by(
        reason: asru.reason,
        project: asru.abstract_screening.project,
        screening_type:
      )
    end
  end

  def self.run_fs_reasons_migrations
    FulltextScreeningsReason.left_joins(:fulltext_screening).where(fulltext_screening: { id: nil }).destroy_all
    FulltextScreeningsReason.includes(fulltext_screening: :project).all.each do |fsr|
      screening_type = 'fulltext'
      ProjectsReason.find_or_create_by(
        reason: fsr.reason,
        project: fsr.fulltext_screening.project,
        screening_type:
      )
    end
    FulltextScreeningsReasonsUser.left_joins(:fulltext_screening).where(fulltext_screening: { id: nil }).destroy_all
    FulltextScreeningsReasonsUser.includes(fulltext_screening: :project).all.each do |fsru|
      screening_type = 'fulltext'
      ProjectsReason.find_or_create_by(
        reason: fsru.reason,
        project: fsru.fulltext_screening.project,
        screening_type:
      )
    end
  end
end
