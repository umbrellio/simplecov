# frozen_string_literal: true

module SimpleCov
  #
  # Profiles are SimpleCov configuration procs that can be easily
  # loaded using SimpleCov.start :rails and defined using
  #   SimpleCov.profiles.define :foo do
  #     # SimpleCov configuration here, same as in  SimpleCov.configure
  #   end
  #
  class Profiles
    def initialize(instance: SimpleCov.instance)
      @instance = instance
    end

    def [](key)
      storage[key]
    end

    #
    # Define a SimpleCov profile:
    #   SimpleCov.profiles.define 'rails' do
    #     # Same as SimpleCov.configure do .. here
    #   end
    #
    def define(name, &blk)
      name = name.to_sym
      raise "SimpleCov Profile '#{name}' is already defined" unless storage[name].nil?

      storage[name] = blk
    end

    #
    # Applies the profile of given name on SimpleCov.configure
    #
    def load(name)
      name = name.to_sym
      raise "Could not find SimpleCov Profile called '#{name}'" unless storage.key?(name)

      instance.configure(&storage[name])
    end

  private

    attr_reader :instance

    def storage
      @storage ||= {}
    end
  end
end
