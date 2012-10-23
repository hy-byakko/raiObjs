module DomainModel
  class Base
    def self.query

    end

    def save

    end

    def destroy

    end
  end

  module EntityMapping
    def mapping=(mapping)
      @mapping = EntityMapping.new(
          :mapping => mapping,
          :entity_class => self.internal_entity,
          :container => self
      )
    end

    def mapping
      @mapping ||= EntityMapping.new(
          :entity_class => self.internal_entity,
          :container => self
      )
    end

    attr_accessor :internal_entity
  end

  Base.extend(EntityMapping)
end