# encoding: utf-8
class User < ActiveRecord::Base
  belongs_to :bumon, :foreign_key => "bumon_id"
  belongs_to :kind, :primary_key => "id", :foreign_key => "syokumu_id"

  has_many :userroles
  has_many :roles, :through => :userroles
  has_many :carnyukos
  has_many :userbumonchgs

  validates_uniqueness_of :user_cd, :case_sensitive => false
  validates :user_cd, :user_name, :bumon_id, :sex, :password, :presence => true
  validates :user_cd, :length =>{:maximum => 5}
  validates_length_of :password, :email, :maximum => 50
  validates :user_name, :tel_no, :length => {:maximum => 20}
  validates :tel_no, :format => {:with => /^$|(\d+-?)+$/, :message => '由半角数字和"-"组成'}
  validates :bumon_id, :syokumu_id, :length => { :maximum => 10 }
  validates :birth_dtm, :nyusya_dtm, :length =>{ :maximum => 8 }
end
