# frozen_string_literal: true

require "setup_cucumber_feature_coverage"

SimpleCov.start

Dir["lib/*.rb"].each {|file| require_relative "../#{file}" }
