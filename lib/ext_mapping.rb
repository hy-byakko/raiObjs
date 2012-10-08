require_dependency File.expand_path(File.join('..', 'ext_mapping', 'mapping_unit'), __FILE__)

class ExtMapping
  def initialize(options = {})
    @controller = options[:controller]
    if options[:mapping]
      @unit_pool = options[:mapping].inject([]) { |mapping, unit|
        unit[1] = {:ref => unit[1]} if unit[1].is_a?(String)
        mapping << MappingUnit.new(
            {
                :name => unit[0].to_s,
                :controller => @controller

            }.merge(unit[1])
        )
      }
    else
#未指定mapping配置时使用major_class构造mapping
      major = (options[:major] || options[:controller].major)
      @unit_pool = major.columns.inject([]) { |mapping, column|
#默认不映射 created_at, updated_at
        unless ['created_at', 'updated_at'].include?(column.name)
          mapping << MappingUnit.new(
              {
                  :name => column.name,
                  :controller => @controller
              }
          )
        end
        mapping
      }
    end
  end

  def mapping_override(new_mapping)
    new_mapping.each{|name, options|
      unit = get_unit(name)
      options = {:ref => options} if options.is_a?(String)
      options.merge!({
        :controller => @controller
      })
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
    available_units(options).each { |unit|
      condition_struct = unit.add_condition(
          condition_struct,
          :controller => options[:scope]
      )
    }
    condition_struct
  end

# 简单键映射: 将键替换成该键对应mapping_unit名的ref值
  def ref_keys(source)
    source.inject({}){|ref, source_unit|
      ref[get_unit(source_unit[0]).ref.to_sym] = source_unit[1]
      ref
    }
  end

  def default_struct(instance, options = {})
    available_units(options.merge({:motion => :get})).inject({}) { |source, unit|
      unit.struct_value(
          source,
          :model => instance,
          :controller => options[:scope]
      )
      source
    }
  end

  def mapping_attr(options = {})
    available_units(options.merge({:motion => :set})).each{|unit|
      unit.mapping_to_model(
          :model => options[:model],
          :controller => options[:scope]
      )
    }
  end

  def available_units(options = {})
    @unit_pool.select {|unit|
      unit.available(
          {
              :motion => options[:motion],
              :controller => options[:scope]
          }
      )
    }
  end
end