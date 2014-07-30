require 'spec_helper'

describe DbStorage do  
  context "initializing a new db_store" do
    before do
      @db_store = DbStorage.new(name: "Foo Bar")
      Timecop.freeze
      @now = Time.now.strftime("%D %I:%M %p")
    end
    subject { @db_store }
    it("stores the name") { @db_store.name.should eq("Foo Bar") }
    it "should make a db_store directory" do
      File.directory?("#{Rails.root}/db_store_test").should eq(true)
    end
    it "should call mysqldump" do
      DbStorage.should_receive("system").with(/mysqldump/).and_return(true)
      @db_store.write
    end
    context "after writing" do
      before do 
        @db_store.write
        @file_path = "#{Rails.root}/db_store_test/foobar.sql"
        @catalog_path = "#{Rails.root}/db_store_test/catalog.txt"
      end
      it "should destroy a store" do
        DbStorage.destroy(["Foo Bar"])
        File.exist?(@file_path).should eq(false)
        expect(DbStorage.catalog.list.count).to eq(0)
      end
      it "should create a sql file" do
        File.exist?(@file_path).should eq(true)
        lines = File.readlines(@file_path)
        lines.count.should_not eq(0)
      end
      it "should create a file to store the catalog" do
        File.exist?(@catalog_path).should eq(true)
      end
      it "should put an entry in the catalog" do
        catalog = DbStorage.catalog.list
        expect(catalog.count).to eq(1)
        catalog[0].keys.should eq(["name", "filename", "migration", "created"])
        catalog[0]["name"].should eq("Foo Bar")
        catalog[0]["created"].should eq(@now)
        catalog[0]["filename"].should eq("foobar.sql")
        catalog[0]["migration"].should eq(ActiveRecord::Migrator.current_version)
      end
      it "should add another item to the catalog" do
        db_store = DbStorage.new(name: "Biz Bam")
        db_store.write
        catalog = DbStorage.catalog.list
        expect(catalog.count).to eq(2)
        catalog[0]["name"].should eq("Biz Bam")
        catalog[1]["name"].should eq("Foo Bar")
      end
      it "should return a list of the names in the catalog" do
        DbStorage.names.should eq(["Foo Bar"])
      end
      it "should replace a duplicate named item in the catalog" do
        db_store = DbStorage.new(name: "Foo Bar")
        db_store.write
        catalog = DbStorage.catalog.list
        expect(catalog.length).to eq(1)
        expect(catalog[0]["name"]).to eq("Foo Bar")
      end
      it "should restore the database" do
        DbStorage.should_receive("system").with(/mysql /).and_return(true)
        DbStorage.restore(name: "Foo Bar")
      end
      it "shouldn't run migration when sql is current" do
        # DbStorage.should_not_receive(:migrate)
        # DbStorage.restore(name: "Foo Bar")
      end
      it "should run migration when sql is stale" do
        # file = File.read(@catalog_path)
        # migration = ActiveRecord::Migrator.current_version.to_s
        # File.open(@catalog_path, "w") { |f| f.puts file.gsub(migration, "111") }
        # # Rake::Task["db:migrate"].should_receive(:invoke)
        # DbStorage.should_receive(:migrate)
        # DbStorage.restore(name: "Foo Bar")
      end
    end
  end
  after do
    FileUtils.rm Dir.glob("#{Rails.root}/db_store_test/*")
    Dir.rmdir("#{Rails.root}/db_store_test")
  end
end