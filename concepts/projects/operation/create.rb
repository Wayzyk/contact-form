# frozen_string_literal: true

class Projects::Operation::Create < Trailblazer::Operation
  step Model(Project, :new)
  step Contract::Build(constant: Projects::Contract::Create)
  step Contract::Validate()
  step Contract::Persist()
end
