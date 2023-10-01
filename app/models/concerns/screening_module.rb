module ScreeningModule
  extend ActiveSupport::Concern

  SINGLE_PERPETUAL = 'single-perpetual'.freeze
  DOUBLE_PERPETUAL = 'double-perpetual'.freeze
  EXPERT_NEEDED_PERPETUAL = 'expert-needed-perpetual'.freeze
  ONLY_EXPERT_NOVICE_MIXED_PERPETUAL = 'only-expert-novice-mixed-perpetual'.freeze
  N_SIZE_SINGLE = 'n-size-single'.freeze
  N_SIZE_DOUBLE = 'n-size-double'.freeze
  N_SIZE_EXPERT_NEEDED = 'n-size-expert-needed'.freeze
  N_SIZE_ONLY_EXPERT_NOVICE_MIXED = 'n-size-only-expert-novice-mixed'.freeze
  PILOT = 'pilot'.freeze
  FULLTEXTSCREENINGTYPES = {
    SINGLE_PERPETUAL => 'Perpetual (Single)',
    DOUBLE_PERPETUAL => 'Perpetual (Double)',
    EXPERT_NEEDED_PERPETUAL => 'Perpetual (Expert Needed)',
    ONLY_EXPERT_NOVICE_MIXED_PERPETUAL => 'Perpetual (Only Mixed With Expert)',
    N_SIZE_SINGLE => 'Fixed N Size (Single)',
    N_SIZE_DOUBLE => 'Fixed N Size (Double)',
    N_SIZE_EXPERT_NEEDED => 'Fixed N Size (Expert Needed)',
    N_SIZE_ONLY_EXPERT_NOVICE_MIXED => 'Fixed N Size (Only Mixed With Expert)',
    PILOT => 'Pilot'
  }.freeze
  NON_PERPETUAL = [
    PILOT,
    N_SIZE_SINGLE,
    N_SIZE_DOUBLE,
    N_SIZE_EXPERT_NEEDED,
    N_SIZE_ONLY_EXPERT_NOVICE_MIXED
  ]
  SINGLE_SCREENINGS = [
    SINGLE_PERPETUAL,
    N_SIZE_SINGLE
  ].freeze
  DOUBLE_SCREENINGS = [
    DOUBLE_PERPETUAL,
    N_SIZE_DOUBLE,
    EXPERT_NEEDED_PERPETUAL,
    ONLY_EXPERT_NOVICE_MIXED_PERPETUAL,
    N_SIZE_EXPERT_NEEDED,
    N_SIZE_ONLY_EXPERT_NOVICE_MIXED
  ].freeze
  ALL_SCREENINGS = [PILOT].freeze

  def single_screening?
    SINGLE_SCREENINGS.include?(screening_type)
  end

  def double_screening?
    DOUBLE_SCREENINGS.include?(screening_type)
  end

  def all_screenings?
    ALL_SCREENINGS.include?(screening_type)
  end

  def tag_options
    reqs = []
    reqs << 'Yes' if yes_tag_required
    reqs << 'No' if no_tag_required
    reqs << 'Maybe' if maybe_tag_required
    reqs
  end

  def reason_options
    reqs = []
    reqs << 'Yes' if yes_reason_required
    reqs << 'No' if no_reason_required
    reqs << 'Maybe' if maybe_reason_required
    reqs
  end

  def note_options
    reqs = []
    reqs << 'Yes' if yes_note_required
    reqs << 'No' if no_note_required
    reqs << 'Maybe' if maybe_note_required
    reqs
  end
end
