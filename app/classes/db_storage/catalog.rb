class DbStorage::Catalog
  STORAGE_DIR = Rails.env.test? ? "#{Rails.root}/db_store_test" : "#{Rails.root}/db_store"
  FILENAME = "#{STORAGE_DIR}/catalog.txt"

  def initialize
    setup_filesystem
    read
  end

  def add(db_store)
    add_item(db_store)
    write
  end

  def read
    return @list = [] if File.zero?(FILENAME)
    @list = JSON.parse(File.read(FILENAME))
  end

  def list
    @list || []
  end

  def find(name)
    @list.find { |store| store["name"] == name }
  end

  def names
    @list.collect { |store| store["name"] }
  end

  def remove(names)
    removed = []
    @list.reject! do |store|
      if names.include?(store["name"])
        removed << store
        true
      end
    end
    write
    removed
  end

  private

  def write
    File.open(FILENAME, "w") { |f| f.puts(JSON.generate(@list)) }
  end

  def add_item(db_store)
    replace(db_store) || insert(db_store)
  end

  def replace(db_store)
    if i = @list.find_index { |item| item["name"] == db_store.name }
      @list[i] = catalog_entry(db_store)
    end
  end

  def insert(db_store)
    @list.insert(0, catalog_entry(db_store))
  end

  def catalog_entry(db_store)
    {
      name: db_store.name,
      filename: db_store.filename,
      migration: db_store.migration,
      created: Time.now.strftime("%D %I:%M %p")
    }
  end

  def setup_filesystem
    FileUtils.mkdir_p(STORAGE_DIR)
    FileUtils.touch(FILENAME)
  end
end
