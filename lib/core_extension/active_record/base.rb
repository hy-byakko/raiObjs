# encoding: utf-8
require "record_mapping"
module CoreExtension
  module ActiveRecord
    module Base
# 得到Mapping结果
      def mapping_exec(options = {})
        (options[:mapping] || self.class.mapping).struct(self, options)
      end

      def mapping_attr(options)
        (options[:mapping] || self.class.mapping).mapping_attr(self, options)
        self
      end

      def match_attr(source, options = {})
        source = self.class.key_to_symbol(source)
        redundant_attr = (options[:redundant_attr] || [:id, :created_at, :updated_at])
        options[:filter] && redundant_attr += options[:filter]
        self.attributes.each { |key, value|
          unless redundant_attr.index(key.to_sym)
            new_value = source[key.to_sym]
            case options[:ignore]
              when :blank
                self[key] = new_value unless new_value.blank?
              else
                self[key] = new_value unless new_value.nil?
            end
          end
        }
        self
      end

      def value_with_string(str)
        bridge = self
        if str.is_a?(String)
          return self.instance_eval str if /\[.*\]/ =~ str
          str = str.split('.')
          if str[0] == 'self'
            str.shift
            bridge = bridge.value_with_string(str.join('.'))
          else
            str.each { |unit|
              bridge = bridge.send unit.to_sym
            }
          end
        end
        bridge
      end

#
# Uriagefull.find(1).copy_to(UriagefullDiscard, :associate => {
#     :kaisyukbnuricols => {
#         :filter => [:uriagefull_id]
#     },
#     :uriagefullcols => {
#         :filter => [:uriagefull_id]
#     }
# })
      def copy_to(target_class, options = {})
        instance = target_class.new
        instance.match_attr(self.attributes, :redundant_attr => []).save
        if options[:associate]
          options[:associate].each { |associate, associate_options|
            associate_object = self.send(associate.to_sym)
            case associate_object
              when ActiveRecord::Base
                instance.send(associate.to_sym).new.match_attr(associate_object.attributes, associate_options).save
              else
                associate_object.each { |sub_instance|
                  instance.send(associate.to_sym).new.match_attr(sub_instance.attributes, associate_options).save
                }
            end
          }
        end
      end

      def self.included(active_record)
#
# 在定义Model时调用此函数将会使第一个参数所对应的属性在被创建时自动赋值, 类似于主键的自动生成. 区别仅在于此函数生成的序列号
# (sequence)带有一定的规则(regulation).
# 序列号的表现形式是一个带有序号(sequence_count)的字符串.例:
#   规则形如:         %{time-%m%d}%{self.bumon_cd}G%{sequence-5}%{A}
#   则生成的序列号为:    1021        0010          G  00152        A
# 其原理依赖于数据库中额外的一张序列表(sequences), 该表记录了满足特定情况的序号, 主键为种类(kind)和组合值(combo_value).
# 种类与组合值默认值为"±". 仅在键相同时, 不同的序列号才会采用同一条的序列表记录.
#
# 参数:
# attribute为将会被赋值的属性名(Symbol)
# options中参数:kind, 用来指定该序列号的种类(String)
#          参数:regulation, 用来指定该序列号的规则(String), 形如上文所述%{...}为动态填充内容, 其中"time", "sequence"
#          为保留字段, "time"后跟随的为时间格式, "sequence"后为序号所占位数. 形如"self.attr"则会获取实例指向的值. 除保留
#          字段, 其他动态填充的值将会被认为是组合值的一部分. 上例生成的组合值为"bumon_cd0010±A".
#
# 其他使用方式:
# 最优先应用指定:method的情况, 需要的参数为:combo_value(Array), 每项为String或"self.attr"
# code_generate :denpyo_no, :combo_value => ['self.bumon_id']
# def denpyo_no_rule(v)
#   'NO' + v.to_s + 'GPRS'
# end
# 其次适用:regulation(:rule)原则.
# 最后当不指定:method和:rule的情况, 寻找attribute_rule方法, 需要参数:combo_value
#
        def active_record.code_generate(attribute, options = {})
          stuff_method_name = ('auto_' + attribute.to_s + '_generate').to_sym
          sequence_conditions = {
              :kind => (options[:kind] || '±')
          }
          type = :method
          if options[:method]
            eval_method_name = options[:method].to_sym
          elsif options[:regulation] || options[:rule]
            type = :auto
            code_rule = (options[:regulation] || I18n.t('activerecord.kinds.' + options[:rule].to_s))
          else
            eval_method_name = (attribute.to_s + '_rule').to_sym
          end

          define_method(stuff_method_name) do
            case type
              when :auto
                instance_values = []
                nmb_lengths = []
                code = code_rule.gsub(/%\{(\{[^\}]*\}|[^\}])*\}/) { |unit|
                  param = unit[2..-2]
                  param = param.split('-')
                  stuff = ''
                  case param[0]
                    when 'time'
                      option = param[1]
                      stuff = Time.now.strftime(option) if option
                    when 'sequence'
                      nmb_lengths << param[1] ? param[1] : 15
                      stuff = '±' + 'sequence' + '±'
                    else
                      if param[0].split('.').first == 'self'
                        stuff = self.value_with_string(param[0])
                        instance_value = param[0].split('.')[1..-1].join('.') + stuff.to_s
                      else
                        stuff = param[0]
                        instance_value = stuff
                      end
                      instance_values << instance_value
                  end
                  stuff
                }
                raise 'Code generate rule need sequence.' if nmb_lengths.empty?
                combo_value = instance_values.empty? ? '±' : instance_values.join('±')
                sequence_conditions[:combo_value] = combo_value
              when :method
                instance_values = []
                if options[:combo_value]
                  options[:combo_value].each { |unit|
                    if unit.split('.').first == 'self'
                      unit = unit.split('.')[1..-1].join('.') + self.value_with_string(unit)
                    end
                    instance_values << unit
                  }
                end
                combo_value = instance_values.empty? ? '±' : instance_values.join('±')
                sequence_conditions[:combo_value] = combo_value
            end

            sequence_class = self.class.const_get(:Sequence)
            sequence_instance = sequence_class.where(sequence_conditions).first
            sequence_instance = sequence_class.create(sequence_conditions) if sequence_instance.nil?
            sequence_class.update_counters(sequence_instance.id, :sequence_count => 1)
            sequence = sequence_instance.sequence_count

            if type == :auto
              code.gsub!(/±sequence±/) {
                nmb_length = nmb_lengths.shift
                sprintf('%0' + nmb_length.to_s + 'd', sequence)
              }
            else
              code = self.send eval_method_name, sequence
            end
            self[attribute.to_sym] = code
          end

          self.send :before_create, stuff_method_name
        end

        def active_record.key_to_symbol(source)
          case
            when source.is_a?(Array)
              result = []
              source.each { |item|
                result << key_to_symbol(item)
              }
            when source.is_a?(Hash)
              result = {}
              source.each { |key, value|
                result[key.to_sym] = key_to_symbol(value)
              }
            else
              result = source
          end
          result
        end

#
# Bumon.visible(current_user).all #=>Add 'user_id IN (1,2,3)' in sql.
# Bumon.visible(current_user, :field => 'bumon_id').all #=>Add 'bumon_id IN (1, 2, 3)' in sql.
#                                                          Use 'visible_bumon_ids' to find id array.
# Bumon.visible(current_user, :field => ['user_id', 'bumon_id']).all
# Bumon.visible(current_user, :field => {:user_id => 'visible_user_ids', :bumon_id => 'visible_bumon_ids' }).all
        def active_record.visible(current_user, options = {})
          return self if current_user.admin?
          case options[:field]
            when Hash
              field_list = options[:field].to_a
            when String
              field_list = [options[:field]]
            when Array
              field_list = options[:field]
            else
              field_list = ['user_id']
          end

          field_list.inject(self) { |decorator, field|
            if field.is_a?(Array)
              attr = field[0]
              method = field[1]
            else
              attr = field
              method = "visible_#{field}s"
            end
            decorator.where(attr.to_sym => current_user.send(method.to_sym))
          }
        end

#
# self.mapping = {
#     :id => 'id',
#     :bumon_cd => 'bumonCd',
#     :bumon_mei => 'bumonMei',
#     :bumonlevel_id => 'bumonlevelId',
#     :yubin_no => 'yubinNo',
#     :tel_no => 'telNo',
#     :fax_no => 'faxNo',
#     :jusyo => 'jusyo'
# }
        def active_record.mapping=(mapping)
          @record_mapping = RecordMapping::Base.new(
              :mapping => mapping,
              :container => self
          )
        end

        def active_record.mapping
          @record_mapping ||= RecordMapping::Base.new(
              :container => self
          )
        end

        def active_record.mapping_override(new_mapping)
          mapping.mapping_override(new_mapping)
        end

# 添加查询条件, 查询并返回最终Mapping完之后的结果集
        def active_record.query(options)
          condition = mapping.add_condition(options)
          condition = mapping.add_sort(options.merge({
              :condition_struct => condition
          }))
          mapping.struct_exec(condition, options)
        end
      end
    end
  end
end