require 'active_record'
require 'authority_controlled'

# Link a Person to an Office as the holder of that office (an election winner).
class OfficeHolder < ApplicationRecord
  acts_as_authority_controlled authority_area: 'Democracy', item_authority_flag_field: :always_viewable
  # attr_accessible :start_on, :end_on

  belongs_to :office
  belongs_to :person
  belongs_to :previous, class_name: 'OfficeHolder'

  validates :office_id, presence: true
  validates :person_id, presence: true
  validate :validate_previous_office_holder
  validates :start_on, presence: true
  validate :validate_dates

  def validate_previous_office_holder
    if previous
      errors.add(:previous, 'cannot be an office holder for a different office') if previous.office != office
      if previous.start_on > start_on
        errors.add(:previous, 'cannot be an office holder that starts on a later date')
      end
    end
  end

  def validate_dates
    errors.add(:end_on, 'must be on or after the start date') if end_on? && start_on? && end_on < start_on
  end
end
