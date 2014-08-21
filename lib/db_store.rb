require "db_store/engine"

module DbStore
  require "../app/classes/db_storage"
  def self.enable
    DbStorage.enable
  end
end
