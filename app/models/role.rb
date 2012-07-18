# encoding: utf-8
class Role < ActiveRecord::Base
  has_many :userroles
  has_many :users, :through => :userroles

  has_many :rolerights
  has_many :rights, :through => :rolerights

  belongs_to :bumon

  validates_uniqueness_of :role_cd, :role_name, :case_sensitive => false
  validates :role_cd, :role_name, :presence => true
end