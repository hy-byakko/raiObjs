# encoding: utf-8
class Vmcolumn < ActiveRecord::Base
  belongs_to :basyo, :foreign_key => 'basyo_id'
  belongs_to :syohin, :foreign_key => 'syohin_id'

  has_many :colrentfeejokens
  has_many :kaisyukbnuricols
  has_many :vmcolumnprices, :dependent => :destroy

  validates :basyo_id, :column_no, :syohin_id, :ondo, :fullsyohinsu, :setteisu, :presence => true
  validates_uniqueness_of :basyo_id, :scope => :column_no, :case_sensitive => false, :message => '该点位对应的货道编号已存在!'
  validates_length_of :column_no, :maximum => 4
  validates_length_of :syohin_id, :maximum => 10
  validates_length_of :setteisu, :maximum => 6
  validates_length_of :fullsyohinsu, :maximum => 6
  validates_length_of :ondo, :maximum => 1
  validate :setteisu, :less_fullsyohinsu

  protected
  def less_fullsyohinsu
    self.errors.add(:setteisu, "补货基准数不能大于满仓数") if self.fullsyohinsu < self.setteisu unless self.setteisu.nil?
  end
end
