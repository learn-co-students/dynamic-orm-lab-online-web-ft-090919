require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)

    table_info.collect { |col| col["name"] }.compact
  end

  def initialize(option = {})
    option.each do |col, value|
      self.send("#{col}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |e| e == "id"  }.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each { |col|  values << "'#{send(col)}'" unless send(col).nil?}
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE name = '#{name}'
    SQL

    DB[:conn].execute(sql)
  end

  def self.find_by(attribute)
    value = attribute.values.first == Fixnum ? attribute.values.first : "'#{attribute.values.first}'"

    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE #{attribute.keys.first} = #{value}
    SQL

    DB[:conn].execute(sql)
  end
end
