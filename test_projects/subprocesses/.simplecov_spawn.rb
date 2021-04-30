require "bundler/setup"
require "setup_cucumber_feature_coverage"

SimpleCov.command_name "spawn"
SimpleCov.at_fork.call(Process.pid)
SimpleCov.start
