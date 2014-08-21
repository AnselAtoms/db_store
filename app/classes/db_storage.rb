class DbStorage
  attr_accessor :name, :filename, :migration
  
  STORAGE_DIR = Rails.env.test? ? "#{Rails.root}/db_store_test" : "#{Rails.root}/db_store"

  def self.enabled?
    @@enabled
  end

  def self.enable
    @@enabled = true
  end
  
  def initialize(params)
    @name = params[:name]
    @filename = get_filename
    @migration = ActiveRecord::Migrator.current_version
    self.class.setup_filesystem
  end

  def write
    write_sql
    Catalog.new.add(self)
  end
  
  def self.restore(params)
    store = catalog.find(params[:name])
    # migration = ActiveRecord::Migrator.current_version
    write_db(store)
    # migrate(store) if stale?(store, migration)
  end
    
  def self.setup_filesystem
    FileUtils.mkdir_p STORAGE_DIR
  end
  
  def self.catalog
    Catalog.new
  end
  
  def self.names
    catalog.names
  end
  
  def self.destroy(names)
    catalog.remove(names).each do |store|
      remove_file(store)
    end
  end
  
  def self.remove_file(store)
    FileUtils.rm("#{STORAGE_DIR}/#{store["filename"]}")
  end
  
  def self.write_db(store)
    sql_command("mysql", "< #{STORAGE_DIR}/#{store["filename"]}")
  end
  
  def self.sql_command(cmd, arg)
    config = get_db_config
    command_str = "#{cmd} -u #{config[:username]} -p#{config[:password]}"
    command_str << " -h #{config[:host]}" if config[:host]
    command_str << " #{config[:database]} #{arg}"
    raise "#{cmd} failed" unless system(command_str)
  end
  
  def self.get_db_config
    config = Rails.configuration.database_configuration
    {
      host:     config[Rails.env]["host"],
      database: config[Rails.env]["database"],
      username: config[Rails.env]["username"],
      password: config[Rails.env]["password"],
    }
  end
  
  def self.stale?(store, migration)
    store["migration"] != migration
  end
  
  def self.migrate(store)
    # result = system("RAILS_ENV=#{Rails.env} rake db:migrate")
    # sql_command("mysqldump", "> #{STORAGE_DIR}/#{store["filename"]}")
  end
  
  private
  
  def get_filename
    @name.downcase.gsub(/[^0-9a-z]/, '') + ".sql"
  end  
  
  def write_sql
   self.class.sql_command("mysqldump", "> #{STORAGE_DIR}/#{@filename}")
  end
      
end
