require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = <<-SQL
      PRAGMA table_info(#{table_name})
    SQL
    DB[:conn].execute(sql).map { |col| col["name"] }
  end

  def initialize(data = {})
    data.each do |key, val|
      send("#{key}=", val)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.reject { |col_name| col_name == "id" }.join(", ")
  end

  def values_for_insert
    self.class.column_names.map do |col_name|
      "'#{send(col_name)}'" if send(col_name)
    end.compact.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE name = ?
    SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(data)
    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE #{data.keys.first.to_s} = ?
    SQL
    DB[:conn].execute(sql, data.values.first)
  end
end
