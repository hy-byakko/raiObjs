# encoding: utf-8
# author 朱定辉
class Kind < ActiveRecord::Base
  has_many :keihijokens
  has_many :users
  has_many :vmcnts
  belongs_to :kindcategorie, :foreign_key => 'kindcategory_cd', :primary_key => "kindcategory_cd"

  validates :kindcategory_cd, :kind_cd, :kind_name, :presence => true

  validates_uniqueness_of :kind_cd, :scope => [:kindcategory_cd], :case_sensitive => false
  validates_uniqueness_of :kind_name, :scope => [:kindcategory_cd], :case_sensitive => false

  validates_length_of :kindcategory_cd, :maximum => 2
  validates_length_of :kind_cd, :maximum => 2
  validates_length_of :kind_name, :maximum => 20

end
