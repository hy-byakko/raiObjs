# encoding: utf-8
class Vmcolumn < ActiveRecord::Base

  belongs_to :basyo, :foreign_key => 'basyo_id'
  belongs_to :syohin, :foreign_key => 'syohin_id'

  has_many :colrentfeejokens
  has_many :kaisyukbnuricols
  has_many :vmcolumnprices , :dependent => :destroy

  def basyolist
    basyo && basyo.basyo_name
  end

  def syohinlist
    syohin && syohin.syohin_name
  end

  def vmcolumnprice(kaisyukbn_id)
    Vmcolumnprice.where(:vmcolumn_id => self.id, :kaisyukbn_id => kaisyukbn_id).first
  end
  
  validates :basyo_id,  :column_no, :syohin_id,:ondo, :fullsyohinsu, :setteisu,:presence => true
  validates_uniqueness_of :basyo_id, :scope => :column_no, :case_sensitive => false,:message =>'该点位对应的货道编号已存在!'
  validates_length_of :column_no, :maximum=>4
  validates_length_of :syohin_id, :maximum=>10
  validates_length_of :setteisu, :maximum=>6
  validates_length_of :fullsyohinsu, :maximum=>6
  validates_length_of :ondo, :maximum=>1
  validate :setteisu, :less_fullsyohinsu
#  validates_inclusion_of :price,
#                            :in => 0.00..99999.99,
#                            :message => "必须输入0到99999.99之间的数字！"
#  validates_inclusion_of :columntanka,
#                            :in => 0.00..99999.99,
#                            :message => "必须输入0到99999.99之间的数字！"
#  validates_inclusion_of :hotentanka,
#                            :in => 0.00..99999.99,
#                            :message => "必须输入0到99999.99之间的数字！"

protected
  def less_fullsyohinsu
    self.errors.add(:setteisu, "补货基准数不能大于满仓数") if self.fullsyohinsu < self.setteisu unless self.setteisu.nil?
  end
end
