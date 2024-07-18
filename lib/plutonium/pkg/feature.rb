module Plutonium
  module Pkg
    module Feature
      extend ActiveSupport::Concern
      include Plutonium::Pkg::Base

      included do
        initializer :append_migrations do |app|
          unless app.root.to_s.match root.to_s
            config.paths["db/migrate"].expanded.each do |expanded_path|
              app.config.paths["db/migrate"] << expanded_path
            end
          end
        end
      end
    end
  end
end
