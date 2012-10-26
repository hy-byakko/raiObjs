require_dependency File.expand_path(File.join('..', 'record_mapping', 'attribute_unit'), __FILE__)

#
# MappingRule
# {
#   :user_name => :persist #当字段为Symbol时, 认为该字段为type类型, 默认Mapping皆为该种形式
#   等同于
#        :user_name => {
#           :type => :persist
#        }
#   或者
#        :user_name => {
#           :get => "user_name",
#           :set => "user_name",
#           :ref => "user_name",
#           :query => {
#               :field => "username",
#               :seek_by => :equal
#           },
#           :sort => "user_name"
#        }
#   :department_name => {
#     :ref => 'departmentName' #远程映射字段 或者使用 :change_style => true 转化为此格式
#     :type => :persist
#   }
#   :email => {
#     :set => 'email' #非类型指定时不适用默认方法
#   }
#   :password => {
#     :type => :persist,
#     :read_only => true #只读, set动作失效
#   }
# }
#

class RecordMapping
  def initialize(options = {})
# ActiveRecord宿主联接
    @container = options[:container]
    @unit_pool = []
    if options[:mapping]
      options[:mapping].inject(@unit_pool) { |mapping, unit|
        unit[1] = {:type => unit[1]} if unit[1].is_a?(Symbol)
        mapping << AttributeUnit.new(
            {
                :name => unit[0].to_s
            }.merge(unit[1])
        )
      }
    else
# 未指定mapping配置时使用active_record构造mapping
      @unit_pool = record_class.columns.inject([]) { |mapping, column|
# 默认不映射 created_at, updated_at
        unless ['created_at', 'updated_at'].include?(column.name)
          mapping << AttributeUnit.new(
              {
                  :name => column.name,
                  :type => :persist
              }
          )
        end
        mapping
      }
    end
  end

# 获得当前Mapping所映射的Record类
  def record_class
    (@container.superclass == ApplicationController) ? @container.major : @container
  end

  def mapping_override(new_mapping)
    return unless new_mapping
    new_mapping.each{|name, options|
      unit = get_unit(name)
      options = {:type => options} if options.is_a?(String)
      unit ? unit.override(options) : @unit_pool << AttributeUnit.new(
          {:name => name.to_s}.merge(options)
      )
    }
  end

  def get_unit(name)
    (@unit_pool.select { |unit|
      unit.name == name.to_s
    })[0]
  end

# 为options内的:condition_struct添加查询条件(当此值未传递时以RecordClass为起始条件)
# :params为controller的params
  def add_condition(options)
    condition_struct = (options[:condition_struct] || record_class)
    available_units({
        :motion => [:query]
                    }).each { |unit|
      condition_struct = unit.add_condition(condition_struct, {
          :params => options[:params],
          :container => @container
      })
    }
    condition_struct
  end

# 为查询结构添加排序条件 接受由适配器解析而来的 :sort_params 参数 结构为 [{:property => "user_cd", :direction => "ASC"}]
  def add_sort(options)
    condition_struct = (options[:condition_struct] || record_class)
    return condition_struct unless options[:sort_params]
    available_units({
                        :motion => [:sort]
                    }).each { |unit|
      condition_struct = unit.add_sort(condition_struct, {
          :sort_params => options[:sort_params],
          :container => @container
      })
    }
    condition_struct
  end

# 执行查询并返回最终Mapping完之后的结果集, 组装方式由映射决定.
  def struct_exec(condition_struct, options = {})
    total_length = condition_struct.count
    total_length = total_length.size if total_length.is_a?(Hash)

    condition_struct = condition_struct.limit(options[:params][:limit].to_i) if options[:params][:limit]
    condition_struct = condition_struct.offset(options[:params][:start].to_i) if options[:params][:start]

    instances = condition_struct.all

    data_source = instances.inject([]) { |source, instance|
      source << instance.mapping_exec(:mapping => self)
      source
    }

    {
        :total_length => total_length,
        :source => data_source
    }
  end

# 简单键映射: 将键替换成该键对应mapping_unit名的ref值
  def ref_keys(source)
    source.inject({}){|ref, source_unit|
      ref[get_unit(source_unit[0]).ref.to_sym] = source_unit[1]
      ref
    }
  end

  def struct(instance, options = {})
    options[:motion] ? options[:motion] | [:get] : options[:motion] = [:get]
    available_units(options).inject({}) { |result, unit|
      unit.struct_value(
          result,
          :instance => instance
      )
      result
    }
  end

  def mapping_attr(instance, options = {})
    options[:motion] ? options[:motion] | [:set] : options[:motion] = [:set]
    available_units(options).each{|unit|
      unit.mapping_to_model(
          :params => options[:params],
          :instance => instance
      )
    }
  end

  def available_units(options = {})
    @unit_pool.select {|unit|
      unit.available(options)
    }
  end
end