# encoding: utf-8
class Bumon < ActiveRecord::Base
  has_many :bumonsyozokus, :foreign_key => 'bumon_id'
  has_many :bumonkakyuus, :class_name => 'Bumonsyozoku', :foreign_key => 'syozokbumon_id'
  belongs_to :kind, :foreign_key => 'bumonlevel_id'
  has_many :userbumonchgs
  has_many :users

  validates_uniqueness_of :bumon_cd, :case_sensitive => false
  validates :bumon_cd, :presence => true, :length => {:maximum => 4} #部门编号的属性
  validates :bumon_mei, :presence => true, :length => {:maximum => 30}
  validates :bumonlevel_id, :presence => true, :length => {:maximum => 4}
  validates :jusyo, :length => {:maximum => 100}
  validates :yubin_no, :format => {:with =>/^$|^\d{6}$/, :message => "由六位数字组成！"}     #验证邮编为空或者6位数字
  validates :tel_no, :fax_no, :length => {:maximum => 20}, :format => {:with =>/^$|^(\d+-?)+$/, :message => '由半角数字和"-"组成'}
end
