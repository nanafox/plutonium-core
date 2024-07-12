# frozen_string_literal: true

module Plutonium
  module Pkg
    module App
      extend ActiveSupport::Concern
      include Base
      include Concerns::ResourceRegistration
      include ResourceRoutesDrawer

      included do
        isolate_namespace to_s.deconstantize.constantize
      end

      class_methods do
        include Plutonium::Concerns::ResourceValidatable

        attr_reader :scoped_entity_class, :scoped_entity_strategy, :scoped_entity_param_key

        def scope_to_entity(entity_class, strategy: :path, param_key: nil)
          validate_resource! entity_class

          @scoped_entity_class = entity_class
          @scoped_entity_strategy = strategy
          @scoped_entity_param_key = param_key || entity_class.model_name.singular_route_key.to_sym
        end

        def scoped_to_entity?
          scoped_entity_class.present?
        end

        def draw_custom_routes(&block)
          @custom_routes_block = block
        end

        def draw_resource_routes
          ActiveSupport::Notifications.instrument("plutonium.app.draw_resource_routes", app: module_parent.to_s) do
            draw_resource_routes_internal
          end
        end

        def dom_id
          module_parent_name.underscore.dasherize
        end
      end
    end
  end
end
