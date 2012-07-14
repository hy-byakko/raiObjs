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
      unit.name == name
    })[0]
  end

  def add_condition(condition_struct, options = {})
    controller_instance = options[:scope]
    params = controller_instance.params
    available_unit(params).each { |unit|
      condition_struct = condition_struct.where(
          controller_instance.send(unit.conditions.to_sym)) if unit.conditions
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

  def mapping_attr(source, options = {})
    available_unit.each{|unit|
      unit.mapping_to_model(
          source,
          :model => options[:model],
          :controller => options[:controller]
      )
    }
  end

  def available_unit(source)
    @unit_pool.select {|unit|
      !source[unit.ref.to_sym].blank?
    }
  end
end