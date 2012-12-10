# encoding: utf-8
class BasyosController < ApplicationController
  self.mapping_override(
      {
          :basyo_cd => {
              :type => :persist,
              :query => {
                  :seek_by => :similar
              }
          },
          :basyo_name => {
              :type => :persist,
              :query => {
                  :seek_by => :similar
              }
          },
          :customer_name => {
              :type => :grid,
              :get => 'custom.customer_name',
              :sort => {
                  :field => '`customs`.`customer_name`',
                  :joins => :custom
              }
          },
          :vm_cd => {
              :type => :grid,
              :get => 'vm.vm_cd',
              :sort => {
                  :field => '`vms`.`vm_cd`',
                  :joins => :vm
              }
          },
          :bumon_name => {
              :type => :grid,
              :get => 'bumon.bumon_mei',
              :sort => {
                  :field => '`bumons`.`bumon_mei`',
                  :joins => :bumon
              }
          },
          :eigyotanto_name => {
              :type => :grid,
              :get => 'eigyotanto.user_name',
              :sort => {
                  :field => '`eigyotanto`.`user_name`',
                  :joins => '`users` `eigyotanto`'
              }
          },
          :sagyotanto_name => {
              :type => :grid,
              :get => 'sagyotanto.user_name',
              :sort => {
                  :field => '`sagyotanto`.`user_name`',
                  :joins => '`users` `sagyotanto`'
              }
          },
          :rireki_dtm => {
              :type => :logic,
              :query => {
                  :method => 'in_rireki'
              }
          },
          :turikin => {
              :type => :accessor,
              :lazy => true
          },
          :vmanzenzaikosu => {
              :type => :accessor,
              :lazy => true
          },
          :vmcolumns => {
              :association => :vmcolumns,
              :lazy => true,
              :mapping_override => {
                  :group_no => {
                      :type => :ignore
                  }
              }
          }
      }
  )

  def self.in_rireki(condition_struct, options)
    condition_struct.where([
        'rireki_kaisi_dtm <= :rireki_dtm AND rireki_syuryo_dtm >= :rireki_dtm',
        {
            :rireki_dtm => Date.parse(options[:params][:rireki_dtm]).to_s(:number)
        }
    ])
  end

  def get_customer
      struct_exec(query_condition(Custom, ['customer_name'])) { |instance|
        [
            instance.id,
            instance.customer_name
        ]
      }
  end

  def get_bumon
      struct_exec(query_condition(Bumon, ['bumon_mei'])) { |instance|
        [
            instance.id,
            instance.bumon_mei
        ]
      }
  end

  def get_vm
      struct_exec(query_condition(Vm, ['vm_cd'])) { |instance|
        [
            instance.id,
            instance.vm_cd
        ]
      }
  end

  def get_eigyotanto
      struct_exec(query_condition(User, ['user_name'])) { |instance|
        [
            instance.id,
            instance.user_name
        ]
      }
  end

  def get_sagyotanto
      struct_exec(query_condition(User, ['user_name'])) { |instance|
        [
            instance.id,
            instance.user_name
        ]
      }
    end

# GET /basyos
# GET /basyos.ext_json
  def index
    super
  end

  # GET /basyos/1
  def show
    super
  end

  # GET /basyos/new
  def new
  end

  # GET /basyos/1/edit
  def edit
  end

  # POST /basyos
  def create
    super
  end

  # PUT /basyos/1
  def update
    super
  end

  # DELETE /basyos/1
  def destroy
    super
  end
end
