# encoding: utf-8
class Bumon < ActiveRecord::Base
  has_many :bumonsyozokus, :foreign_key => 'bumon_id'
  has_many :bumonkakyuus, :class_name => 'Bumonsyozoku', :foreign_key => 'syozokbumon_id'
  belongs_to :kind, :foreign_key => 'bumonlevel_id'
  has_many :userbumonchgs
  has_many :users

  def syozokubumonlist(flag=true)
    if flag 
      #找到该部门的上级部门
      #parent_bumon = Bumon.find(:first, :conditions => "id = (select syozokbumon_id from bumonsyozokus where bumon_id = #{self.id} and syozokulevel = 1)")
      parent_bumon = Bumon.where(["id = (select syozokbumon_id from bumonsyozokus where bumon_id = #{self.id} and syozokulevel = 1)"]).first
      parent_bumon && parent_bumon.bumon_mei
    else
      {:joins=>"left outer join (select bumon_id, syozokbumon_id from bumonsyozokus where syozokulevel =1) parent_bumons  on bumons.id =parent_bumons.bumon_id left outer join (select id, bumon_mei from bumons) b on b.id = parent_bumons.syozokbumon_id ",:order=>"b.bumon_mei"}     
    end
  end

  def bumonlevellist(flag=true)
    if flag
      kind && kind.kind_name
    else
      {:include=>[:kind],:order=>"kinds.kind_name"}
    end
  end

  def kakyuu_bumons(without_self = true)
    bumonkakyuu_list = without_self ? bumonkakyuus.reject{|bumonkakyuu|
      bumonkakyuu.syozokulevel == 0
    } : bumonkakyuus
    bumonkakyuu_list.collect{|bumonkakyuu|
      bumonkakyuu.bumon
    }
  end

  validates_uniqueness_of :bumon_cd, :case_sensitive => false
  validates :bumon_cd, :presence => true, :length => {:maximum => 4} #部门编号的属性
  validates :bumon_mei, :presence => true, :length => {:maximum => 30}
  validates :bumonlevel_id, :presence => true, :length => {:maximum => 4}
  validates :jusyo, :length => {:maximum => 100}
  validates :yubin_no, :format => {:with =>/^$|^\d{6}$/, :message => "由六位数字组成！"}     #验证邮编为空或者6位数字
  validates :tel_no, :fax_no, :length => {:maximum => 20}, :format => {:with =>/^$|^(\d+-?)+$/, :message => '由半角数字和"-"组成'}
end
