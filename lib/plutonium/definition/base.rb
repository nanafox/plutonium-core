# frozen_string_literal: true

module Plutonium
  module Definition
    # Base class for Plutonium definitions
    #
    # @abstract Subclass and override {#customize_fields}, {#customize_inputs},
    #   {#customize_filters}, {#customize_scopes}, and {#customize_sorters}
    #   to implement custom behavior.
    #
    # @example
    #   class MyDefinition < Plutonium::Definition::Base
    #     field :name, as: :string
    #     input :email, as: :email
    #     filter :status, type: :select, collection: %w[active inactive]
    #     scope :active, default: true
    #     sorter :created_at
    #
    #     def customize_fields
    #       field :custom_field, as: :integer
    #     end
    #   end
    #
    # @note This class is not thread-safe. Ensure proper synchronization
    #   if used in a multi-threaded environment.
    class Base
      include DefineableProps
      include ConfigAttr
      include Actions

      class IndexPage < Plutonium::UI::Page::Index; end

      class NewPage < Plutonium::UI::Page::New; end

      class ShowPage < Plutonium::UI::Page::Show; end

      class EditPage < Plutonium::UI::Page::Edit; end

      class Form < Plutonium::UI::Form::Resource; end

      class Table < Plutonium::UI::Table::Resource; end

      # fields
      defineable_props :field, :input

      # queries
      defineable_props :filter, :scope, :sorter

      # pages
      config_attr \
        :index_page_title, :index_page_description,
        :show_page_title, :show_page_description,
        :new_page_title, :new_page_description,
        :edit_page_title, :edit_page_description

      def initialize
        super
      end

      def index_page_class
        self.class::IndexPage
      end

      def new_page_class
        self.class::NewPage
      end

      def show_page_class
        self.class::ShowPage
      end

      def edit_page_class
        self.class::EditPage
      end

      def form_class
        self.class::Form
      end

      def collection_class
        self.class::Table
      end
    end
  end
end
