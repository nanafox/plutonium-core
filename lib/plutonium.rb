require "active_support"

require_relative "plutonium/version"
require_relative "plutonium/railtie" if defined?(Rails::Railtie)

module Plutonium
  # require_relative "active_model/validations/array_validator"
  # require_relative "active_model/validations/attached_validator"
  # require_relative "active_model/validations/url_validator"

  extend ActiveSupport::Autoload

  class Error < StandardError; end

  def self.root
    Pathname.new File.expand_path("../", __dir__)
  end

  def self.lib_root
    root.join("lib", "plutonium")
  end

  def self.stylesheet
    if Plutonium::Config.development
      file = JSON.parse(File.read(root.join("assets.manifest")))["plutonium-dev.css"]
      "/plutonium-assets/build/#{file}"
    else
      raise NotImplementedError, "TODO: implement asset resolution for prod"
      # @stylesheet ||= begin
      #   file = JSON.parse(File.read(root.join("assets.manifest")))["plutonium.css"]
      #   "/plutonium-assets/#{file}"
      # end
    end
  end

  autoload :Config

  eager_autoload do
    autoload :Auth
    autoload :Builders
    autoload :ComponentRegistry
    autoload :Core
    autoload :Helpers
    autoload :Packaging
    autoload :Policy
    autoload :Reactor
  end
end

require_relative "../app/views/components/base" if defined?(Rails)
