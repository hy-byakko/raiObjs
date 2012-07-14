# encoding: utf-8
class MappingUnit
#默认映射动作, 对应的值为未指定时的默认值
  MOTION = [
#远程数据映射为对应模型上的字段时调用的方法/set_method为远程数据映射到本地时, 调用本地controller相应的方法名
      :set,
      #本地模型数据映射为远程模型的数据时取值的方法/get_method为本地数据映射到远程时, 调用本地controller相应的方法名
      :get
  ]

  def initialize(options = {})
    @name = options[:name]

#远程模型的字段名, 取值/赋值时皆调用此字段
    @ref = (options[:ref] || to_ext_name(options[:name]))

    MOTION.each { |key|
      if options.has_key?(key)
        motion_build(key, options[key], :model)
      elsif options.has_key?((key.to_s + '_method').to_sym)
        motion_build(key, options[(key.to_s + '_method').to_sym], :controller)
      else
        motion_build(key, options[:name], :model)
      end
    }

# conditions将会尝试调用controller内相应名称的方法, 并认为该方法的返回值即为搜索条件.where()内的参数
    if options[:conditions]
      @conditions = (options[:conditions] || to_ext_name(options[:name]))
    else
      case options[:seek_by]
        when :similar

        else

      end
    end
  end

  def motion_build(key, value, scope)
    motion_value = (value || key).to_s
    self.send((key.to_s + '=').to_sym, motion_value)
    self.send((key.to_s + '_scope=').to_sym, scope)
  end

  def override(options = {})
    options.each { |attr, value|
      self.send((attr.to_s + '=').to_sym, value)
    }
  end

  def to_ext_name(str)
    return str if str.blank?
    camelize_str = str.camelize
    camelize_str[0] = camelize_str[0].downcase
    camelize_str
  end

# options = {
#   :model => model实例
#   :controller => controller实例
# }
  def struct_value(target, options = {})
    value = nil

    case @get_scope
      when :model
        value = options[:model].value_with_string(@get)
      when :controller
        value = options[:controller].send(@get.to_sym, options[:model])
    end

    target[@ref.to_sym] = value if value
  end

  def mapping_to_model(source, options = {})
    case @set_scope
      when :model
        options[:model].send((@set.to_s + '=').to_sym, source[@ref.to_sym])
      when :controller
        options[:controller].send(@set.to_sym, source, options[:model])
    end
  end

  attr_accessor :name, :set, :get, :ref, :conditions, :set_scope, :get_scope
end