require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require 'pry'

class Student < InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

    def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []

    table_info.each do |column|
      column_names << column["name"]
    end

    column_names.compact
  end

  self.column_names.each do |col_name|
  attr_accessor col_name.to_sym
  end

    def initialize(options={})
      options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def some_instance_method
    self.class.some_class_method
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
   if self.id
     self.update
   else
     sql = <<-SQL
     INSERT INTO students (name, grade)
     VALUES (?, ?)
     SQL

     DB[:conn].execute(sql, self.name, self.grade)
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

    def update
      sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end

    def self.create(name, grade)
      student = Student.new(name, grade)
      student.save
      student
    end

    def self.new_from_db(row)
      new_student = self.new(row[1], row[2], row[0])
      new_student
    end

    def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(hash)
    # binding.pry
    column = hash.keys[0]
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE #{column} = ?
    SQL
    DB[:conn].execute(sql, hash[column])

  end

end
