# frozen_string_literal: true

require "setup_cucumber_feature_coverage"

SimpleCov.start do
  track_files "lib/euc_jp_not_declared_tracked.rb"
end

require_relative "../lib/utf8.rb"
require_relative "../lib/euc_jp.rb"
require_relative "../lib/euc_jp_not_declared.rb"
