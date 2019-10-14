require 'pry'
require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord



  def self.table_name
    new_name = "#{self}s".downcase
  end

  def self.column_names
    column_names = []
    sql = "PRAGMA table_info(#{self.table_name})"
     info = DB[:conn].execute(sql)
     info.each do |column|
       column_names << column["name"]
     end
     column_names
  end


  def initialize(options={})
  options.each do |property, value|
    self.send("#{property}=", value)
  end
end

def table_name_for_insert
  self.class.table_name
end

def col_names_for_insert
  self.class.column_names.delete_if {|col| col == "id"}.join(", ")
end

def values_for_insert
    values = "'#{self.name}', '#{self.grade}'"
end

def save
  DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")

  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
end

def self.find_by_name(name)
  DB[:conn].execute("SELECT * FROM students WHERE name = ?;", name)
end

def self.find_by(thing)
  DB[:conn].execute("SELECT * FROM #{self.table_name}
  WHERE #{thing.keys.first.to_s} = ?;",thing.values)

end

end
