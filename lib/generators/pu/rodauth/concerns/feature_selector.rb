module Pu
  module Rodauth
    module Concerns
      module FeatureSelector
        def self.included(base)
          base.send :include, Configuration

          base.send :class_option, :primary, type: :boolean,
            desc: "[CONFIG] generated account is primary"
          base.send :class_option, :argon2, type: :boolean, default: false,
            desc: "[CONFIG] use Argon2 for password hashing"
          base.send :class_option, :mails, type: :boolean, default: true, desc: "[CONFIG] setup mails"
          base.send :class_option, :api_only, type: :boolean, default: false,
            desc: "[CONFIG] configure only json api support"

          config_features = {}
          base::CONFIGURATION.sort.each do |feature, opts|
            feature = feature.to_sym
            modifier = "[*]" if opts[:default]
            default_description = "[FEATURE]#{modifier} #{feature}"
            description = opts[:desc] || default_description

            base.define_method :"#{feature}?" do
              feature_selected?(feature)
            end

            if opts[:feature] != false
              base.send :class_option, feature, type: :boolean, desc: description
            else
              config_features[feature] = description
            end
          end

          config_features.each do |feature, description|
            base.send :class_option, feature, type: :boolean, desc: description
          end

          base.send :class_option, :kitchen_sink, type: :boolean, default: false,
            desc: "[CONFIG] enable all supported features"
          base.send :class_option, :defaults, type: :boolean, default: true,
            desc: "[CONFIG] enable default features (indicated with [*])"
        end

        private

        def feature_selected?(feature)
          return true if kitchen_sink?

          # base is special. so long as it is not explicitly disabled, always allow it through
          return true if feature == :base && options[:base] != false

          feature_options = configuration[feature]
          case feature
          when :json, :jwt
            return true if only_json?
          when :remember
            return false if only_json?
          when :otp
            return true if otp_unlock? || otp_lockout_email? || otp_modify_email?
          when :webauthn
            return true if webauthn_login? || webauthn_autofill? || webauthn_modify_email? || webauthn_verify_account?
          end

          return feature_options[:default] if defaults? && options[feature].nil?

          options[feature]
        end

        # Creates a hash of options to pass down options to an invoked sub generator
        def invoke_options
          # These are custom options we want to track.
          extra_options = %i[primary argon2 mails kitchen_sink defaults]
          # Append them to all the available options from our configuration
          valid_options = configuration.keys.map(&:to_sym).concat extra_options
          # Index map the list with the selection value
          opts = valid_options.map { |opt| [opt, send(:"#{opt}?")] }.to_h.compact
          # True only options. We don't care if they are false.
          %i[api_only force skip pretend quiet].each do |key|
            next unless options[key]

            opts[key] = options[key]
          end

          opts
        end

        def all_selected
          @all_selected ||= configuration.keys.select { |feature| send(:"#{feature}?") }
        end

        def selected_features
          @selected_features ||= (all_selected & feature_config.keys)
        end

        def selected_migration_features
          @selected_migration_features ||= (all_selected & migration_config.keys).map(&:to_s)
        end

        def selected_view_features
          @selected_view_features ||= (all_selected & view_config.keys).map(&:to_s)
        end

        def primary?
          options[:primary]
        end

        def argon2?
          options[:argon2]
        end

        def mails?
          defined?(ActionMailer) && options[:mails]
        end

        def only_json?
          ::Rails.application.config.api_only || !::Rails.application.config.session_store || options[:api_only]
        end

        def kitchen_sink?
          options[:kitchen_sink]
        end

        def defaults?
          options[:defaults]
        end
      end
    end
  end
end
