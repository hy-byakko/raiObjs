def watch(*arguments)
  MyToolKit.watch(*arguments)
end

#class Object
#  def get_bunding
#    return self.bunding
#  end
#end

module MyToolKit
  MY_PATH = File.expand_path('..', __FILE__)

  def MyToolKit.file_read(path, config = {})
    case File.extname(path)
      when '.json'
        JSON.parse(File.open(path).read)
    end
  end

  def MyToolKit.log(*arguments)
    config = {
        :path => MY_PATH + '/' + 'MyLog_' + Time.new.to_i.to_s + '.log',
        :name => nil
    }

    config.merge!(arguments.last[:options]) if arguments.last.is_a?(Hash) && arguments.last[:options]

    path = (config[:path] || config[:name])

    logger = Logger.new(path)
    logger.info(MyToolKit.message_struct(*arguments))
    logger.close
  end

  def MyToolKit.watch(*arguments)
    #binding = unit.send :binding
    print(MyToolKit.message_struct(*arguments))
  end

  def MyToolKit.message_struct(*arguments)
    <<-_MESSAGE

################################# Separator #################################

Report from #{caller(3)[0]}
The var#{'s' if arguments.size > 1} you watched is
    #{arguments.inject('') { |message, argument|
      message << "\n" + format_unit(argument, 0) + "\n"
    }}
#################################### END ####################################

    _MESSAGE
  end

  #def const_missing(name)
  #  super(name)
  #end

  def MyToolKit.format_unit(unit, deep)
    case unit
      when Hash
        str = ''
        str << "{\n"
        str << unit.collect { |key, value|
          "\t" * (deep + 1) + (format_unit key, deep + 1) + ' => ' + (format_unit value, deep + 1)
        }.join(",\n")
        str << "\n" + "\t" * deep + "}"
        return str
      when Array
        str = ''
        str << "[\n"
        str << unit.collect { |sub_unit|
          "\t" *(deep + 1) + (format_unit sub_unit, deep + 1)
        }.join(",\n")
        str << "\n" + "\t" * deep + "]"
        return str
      when String
        return '"' + unit + '"'
      when Symbol
        return ':' + unit.to_s
      when NilClass
        return 'nil'
      else
        return unit.to_s
    end
  end
end
