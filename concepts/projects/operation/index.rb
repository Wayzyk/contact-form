# frozen_string_literal: true

class Projects::Operation::Index < Trailblazer::Operation
  step :model

  def model(ctx, **)
    ctx[:model] = ::Project.all
  end
end
