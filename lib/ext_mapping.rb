require_dependency File.expand_path(File.join('..', 'ext_mapping', 'mapping_unit'), __FILE__)

class ExtMapping
  def initialize(options = {})
    @controller = options[:controller]
    @unit_pool = options[:controller].major.columns.inject([]) { |mapping, column|
#默认不映射 created_at, updated_at
      unless ['created_at', 'updated_at'].include?(column.name)
        mapping << MappingUnit.new(:name => column.name)
      end
      mapping
    }
  end

  def mapping_override(new_mapping)
    new_mapping.each{|name, options|
      unit = get_unit(name)
      unit ? unit.override(options) : @unit_pool << MappingUnit.new(
          {:name => name.to_s}.merge(options)
      )
    }
  end

  def get_unit(name)
    (@unit_pool.select { |unit|
      unit.name == name.to_s
    })[0]
  end

  def add_condition(condition_struct, options = {})
    available_unit(options[:scope].params).each { |unit|
      condition_struct = unit.add_condition(
          condition_struct,
          :controller => options[:scope]
      )
    }
    condition_struct
  end

  def default_struct(instance, options = {})
    @unit_pool.inject({}) { |source, unit|
      unit.struct_value(
          source,
          :model => instance,
          :controller => options[:scope]
      )
      source
    }
  end

  def mapping_attr(options = {})
    available_unit(options[:scope].params).each{|unit|
      unit.mapping_to_model(
          :model => options[:model],
          :controller => options[:scope]
      )
    }
  end

  def available_unit(source)
    @unit_pool.select {|unit|
      !source[unit.ref.to_sym].blank?
    }
  end
end