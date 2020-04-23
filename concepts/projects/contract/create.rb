# frozen_string_literal: true

class Projects::Contract::Create < Reform::Form
  property :name
  property :project_type

  validates :name, :project_type, presence: true
  validates_uniqueness_of :name

end
