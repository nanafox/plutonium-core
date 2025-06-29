require "rabl"

# https://github.com/nesquena/rabl#configuration

Rabl.configure do |config|
  config.cache_sources = !Rails.env.development? # Defaults to false
  config.raise_on_missing_attribute = !Rails.env.production? # Defaults to false

  # config.cache_all_output = false
  # config.cache_engine = Rabl::CacheEngine.new # Defaults to Rails cache
  # config.perform_caching = false
  # config.escape_all_output = false
  # config.json_engine = nil # Class with #dump class method (defaults JSON)
  # config.msgpack_engine = nil # Defaults to ::MessagePack
  # config.bson_engine = nil # Defaults to ::BSON
  # config.plist_engine = nil # Defaults to ::Plist::Emit
  # config.include_json_root = true
  # config.include_msgpack_root = true
  # config.include_bson_root = true
  # config.include_plist_root = true
  # config.include_xml_root  = false
  # config.include_child_root = true
  # config.enable_json_callbacks = false
  # config.xml_options = { :dasherize  => true, :skip_types => false }
  # config.view_paths = []
  # config.replace_nil_values_with_empty_strings = true # Defaults to false
  # config.replace_empty_string_values_with_nil_values = true # Defaults to false
  # config.exclude_nil_values = true # Defaults to false
  # config.exclude_empty_values_in_collections = true # Defaults to false
  # config.camelize_keys = :upper # Defaults to false
end

# Extend Rabl source lookup to make it compatible with Rails view lookup
module Rabl
  module Sources
    module RailsViewLookupExtension
      private

      # Returns the rabl template path for Rails
      def fetch_rails_source(file, options = {})
        # use Rails template resolution mechanism if possible (find_template)
        source_format = request_format if defined?(request_format)

        lookup_proc = lambda do |partial|
          context_scope.lookup_context.find(file, context_scope.lookup_context.prefixes, partial, [],
            {formats: [source_format]})
        end

        template = begin
          lookup_proc.call(false)
        rescue
          nil
        end

        template ||= begin
          lookup_proc.call(true)
        rescue
          nil
        end

        template&.identifier
      end
    end

    prepend RailsViewLookupExtension
  end
end

# Rails 8 compatible template handler registration
Rails.application.config.to_prepare do
  unless ActionView::Template::Handlers.extensions.include?(:rabl)
    # Create a proper callable handler for Rails 8
    rabl_handler = lambda do |template, source|
      # Rails 8 expects the handler to return Ruby code that will be evaluated
      # The code should return the rendered content
      %{
        rabl_engine = Rabl::Engine.new(#{source.inspect})
        rabl_engine.render(self, assigns.merge(local_assigns))
      }
    end

    ActionView::Template.register_template_handler(:rabl, rabl_handler)
  end
end

Rabl.register!
