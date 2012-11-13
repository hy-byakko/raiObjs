# encoding: utf-8
require_dependency File.expand_path(File.join('..', 'mapping_unit'), __FILE__)

module RecordMapping
  class AssociationUnit < MappingUnit
    def initialize(options = {})
      super(options)

      @association = options[:association]

      association_reflection = options[:record_class].reflect_on_association(options[:association])
      @type = association_reflection.macro

      if options[:mapping]
        @association_mapping = RecordMapping::Base.new(
            :mapping => options[:mapping],
            :container => options[:container],
            :record_class => association_reflection.class_name.constantize
        )
      else
        @association_mapping = association_reflection.class_name.constantize.mapping
      end

      @association_mapping.mapping_override(options[:mapping_override]) if options[:mapping_override]
    end

    def override(options)
      @motion = {}
      super(options)
    end

    def struct_value(target, options = {})
      value = nil

      association = options[:instance].send(@association.to_sym)
      if association
        value = association.is_a?(Array) ? association.inject([]) { |result, association_unit|
          result << association_unit.mapping_exec(:mapping => @association_mapping)
        } : association.mapping_exec(:mapping => @association_mapping)
      end

      target[@ref.to_sym] = value if value
    end

    def mapping_to_model(options)

    end
  end
end