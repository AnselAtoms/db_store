require "db_store/engine"

module DbStore
  require "../app/classes/db_storage.rb"
  def self.enable
    DbStorage.enable
  end
end
