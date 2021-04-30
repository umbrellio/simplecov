# frozen_string_literal: true

require "simplecov"

SimpleCov.configure do
  enable_coverage :line
  enable_coverage :branch
  enable_coverage :method
  add_filter "tmp/"
  add_filter "spec/"
  track_files "lib/**/*.rb"
end

SimpleCov.collate(Dir["tmp/*/.resultset.json"])
