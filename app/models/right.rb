# encoding: utf-8
class Right < ActiveRecord::Base
  belongs_to :resource, :class_name => 'Resource'
  belongs_to :action
end