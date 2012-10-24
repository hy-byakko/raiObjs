require_dependency File.expand_path(File.join('..', 'record_mapping', 'attribute_unit'), __FILE__)

#
# MappingRule
# {
#   :user_name => :persist #当字段为Symbol时, 认为该字段为type类型, 默认Mapping皆为该种形式
#   :department_name => {
#     :ref => 'departmentName' #远程映射字段
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
  def add_condition(options = {})
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

# 执行查询并返回最终Mapping完之后的结果集, 组装方式由传入的代码块/Proc/默认映射处理来决定.
  def struct_exec(condition_struct = nil, options = {})
    total_length = condition_struct.count
    total_length = total_length.size if total_length.is_a?(Hash)

    condition_struct = condition_struct.limit(options[:params][:limit].to_i) if options[:params][:limit]
    condition_struct = condition_struct.offset(options[:params][:start].to_i) if options[:params][:start]

#Todo: 涉及复杂情况下排序的设计 暂时不启用
#"sort"=>"[{\"property\":\"bumonCd\",\"direction\":\"ASC\"}
#if params['sort']
#  JSON.parser(params['sort']).each{|sort_unit|
#
#  }
#end

    instances = condition_struct.all

    data_source = instances.inject([]) { |source, instance|
      if block_given?
        source << (yield instance)
      elsif options[:handle]
        source << (options[:handle].call(instance))
      else
        source << instance.mapping_exec(:mapping => self)
      end
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

  def mapping_attr(options = {})
    options[:motion] ? options[:motion] | [:set] : options[:motion] = [:set]
    available_units(options).each{|unit|
      unit.mapping_to_model(
          :instance => options[:model]
      )
    }
  end

  def available_units(options = {})
    @unit_pool.select {|unit|
      unit.available(options)
    }
  end
end