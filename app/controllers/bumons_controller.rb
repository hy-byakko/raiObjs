# encoding: utf-8
class BumonsController < ApplicationController
  self.mapping_override(
      {
          :bumon_cd => {
              :type => :persist,
              :query => {
                  :seek_by => :similar
              }
          },
          :bumon_mei => {
              :type => :persist,
              :query => {
                  :seek_by => :similar
              }
          },
          :customer_name => {
              :type => :persist,
              :read_only => true,
              :get => 'syozokubumonlist'
          },
          :parent => {
              :type => :persist,
              :read_only => true,
              :get => 'syozokubumonlist'
          },
          :kind => {
              :type => :persist,
              :read_only => true,
              :get => 'kind.kind_name'
          }
      }
  )

  # GET /bumons
  def index
    super
  end

  def get_bumon_data
    struct_exec(query_condition(Kind.where(:kindcategory_cd => 32), ['kind_name'])) { |instance|
      [
          instance.id,
          instance.kind_name
      ]
    }
  end

  def get_parent_data
    conditions = Bumon
    unless params[:id].blank?
      self_kakyuu_ids = Bumon.find(params[:id]).bumonkakyuus.collect { |bumonkakyuu|
        bumonkakyuu.bumon_id
      }
      conditions.where('id NOT IN (?)', self_kakyuu_ids)
    end
    struct_exec(query_condition(conditions, ['bumon_mei'])) { |instance|
      [
          instance.id,
          instance.bumon_mei
      ]
    }
  end

# GET /bumons/1
  def show
    super
  end

# GET /bumons/new
  def new
    super
  end

# GET /bumons/1/edit
  def edit
    super
  end

# POST /bumons
  def create
    super
  end

  def update
    super
  end

  def destroy
    super
  end
end
