#encoding: utf-8
class WebUser
  def initialize(scope)
    @scope = scope
    session[:web_user] ||= {}
    user_cd = get_state(:user_cd)
    login '0001', 'password' if !user_cd # && Rails.env == 'development'
    @instance ||= User.find_by_user_cd(user_cd) if user_cd
  end

  def authorize?
    !@instance.nil?
  end

  def is_guest?
    @instance.nil?
  end

  def set_state(key, value)
    session[:web_user][key.to_sym] = value
  end

  def get_state(key)
    session[:web_user][key.to_sym]
  end

  def login(user_cd, password)
    if authenticate(user_cd, password)
      set_state(:user_cd, @instance.user_cd)
      set_state(:user_name, @instance.user_name)
      self
    end
  end

  def logout
    @scope.reset_session
  end

  def role_symbols
    @role_symbols ||= (@instance ? @instance.roles.collect { |role|
      role.role_cd.to_sym
    }.push(:guest).uniq : [:guest])
  end

  def admin?
    role_symbols.any? { |role_symbol|
      ['01'.to_sym].include? role_symbol
    }
  end

  def self_visible_only?
    @instance.roles.all? { |role|
      role.rights.all? { |right|
        right.right_name == 'selfView'
      }
    }
  end

  def visible_bumons
    bumons = []
    current_controller = @scope.controller_name
    @instance.userroles.each { |userrole|
      userrole.role.rights.each { |right|
        if right.resource.resource_name == current_controller
          case right.action.action_name
            when 'selfView', 'peerView'
              bumons <<  userrole.bumon
            when 'subView'
              userrole.bumon.kakyuu_bumons.each { |kakyuu_bumon|
                bumons << kakyuu_bumon
              }
          end
        end
      }
    }
    bumons.uniq { |bumon|
      bumon.id
    }
  end

  def visible_users
    users = []
    current_controller = @scope.controller_name
    @instance.userroles.each { |userrole|
      userrole.role.rights.each { |right|
        if right.resource.resource_name == current_controller
          case right.action.action_name
            when 'selfView'
              users << @instance
            when 'subView'
              userrole.bumon.kakyuu_bumons.each { |kakyuu_bumon|
                users = users + kakyuu_bumon.users
              }
            when 'peerView'
              users = users + userrole.bumon.users
          end
        end
      }
    }
    users.uniq { |user|
      user.id
    }
  end

  def visible_basyos
    visible_users.inject([]){|basyos, user|
      basyos += Basyo.where(:sagyotanto_id => user.id).where(
          'rireki_kaisi_dtm <= :current_time AND rireki_syuryo_dtm >= :current_time',
          {:current_time => Time.new.strftime('%Y%m%d%H%M%S')}
      ).all
    }.compact.uniq { |basyo|
      basyo.id
    }
  end

  def visible_vms
    visible_basyos.collect{|basyo|
      basyo.vm
    }.compact.uniq { |vm|
      vm.id
    }
  end

  def visible_bumon_ids
    visible_bumons.collect { |bumon|
      bumon.id
    }
  end

  def visible_user_ids
    visible_users.collect { |user|
      user.id
    }
  end

  def visible_basyo_ids
    visible_basyos.collect { |basyo|
      basyo.id
    }
  end

  def visible_vm_ids
    visible_vms.collect { |vm|
      vm.id
    }
  end

  def ext_current_user
    {
        :userCd => @instance.user_cd,
        :name => @instance.user_name,
        :role => self.role_symbols.join(','),
        :bumon => @instance.bumon.bumon_mei
    }
  end

  attr_accessor :instance

  private
  def authenticate(user_cd, password)
    @instance = User.find_by_user_cd(user_cd)
    if @instance
      @instance = nil if @instance.password != password
    end
    @instance
  end

  def session
    @scope.send :session
  end
end

#Bumon.user_identify(options={}).where(:name => 'sample')