class DbStoresController < ApplicationController
  skip_filter *_process_action_callbacks.map(&:filter)
  before_filter :set_db_store_active
  
  def create
    @db_store = DbStorage.new(params[:db_store])
    @db_store.write
  end
  
  def restore
    DbStorage.restore(params[:db_store])
  end
  
  def destroy
    DbStorage.destroy(params[:names])
  end
  
  private
  
  def set_db_store_active
    @db_store_active = true
  end
end