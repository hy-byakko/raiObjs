# encoding: utf-8
module CoreExtension
  module ActiveRecord
    module Base

      def mapping_attr(options = {})
        options[:scope].class.mapping.mapping_attr(
            :model => self,
            :scope => options[:scope]
        ) if options[:scope]
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
# '±%{self.bumon}%{time-md}G%{serial-15}'
# value = 'G0101FA144'
# value = 'G(?<time_md>[0-9]{4}\)(?<serial_f_5>[0-9A-F]{5})'
# reg = Regexp.new(value)
# match_data = reg.match value
# match_data.names.each{|rule_unit|
#   rule_unit = "{\k<#{rule_unit}>}"
#   value.gsub!(reg, rule_unit.to_sym => '1')
# }
#
# code_generate :denpyo_no, :combo_value => ['self.bumon_id']
# def denpyo_no_rule(v)
#   'NO' + v.to_s + 'GPRS'
# end
#
# code_rule = "%{time-%m%d}%{self.bumon_id}G%{sequence-15}%{G}"
# 必要参数为:kind
# 最优先应用指定:method的情况, 需要的参数为:combo_value(Array), 每项为String或'self.attr'获取实例指向的值
# 其次适用:regulation(:rule)原则, 以规则内容生成combo_value, ['time', 'sequence']为保留字段
# 最后当不指定:method和:rule的情况, 寻找attribute_rule方法, 需要参数:combo_value
#
        def active_record.code_generate(attribute, options = {})
          stuff_method_name = ('auto_' + attribute.to_s + '_generate').to_sym
          sequence_conditions = {
              :kind => options[:kind]
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

      end
    end
  end
end