require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase.pluralize
        # Turns the class name to a lower cased string
        # Pluralizes it to make table name
    end

    def self.column_names
        sql = "pragma table_info('#{table_name}')"
        # Sets 'sql' to an array of hashes containing the table's info by column (NOT row)
        table_info = DB[:conn].execute(sql)
        # Sets the variable 'table_info' to the query sent to the database
        table_info.collect do |column|
            column["name"]
        end.compact
        # Iterates over the array of hashes
        # Gets the name of each column through 'name' and stores it into an array
        # Uses .compact to get rid of nil values
    end

    def initialize(options = {}) 
        options.each do |k, v|
            self.send("#{k}=", v)
        end
        # Iterates over hash ass assigns each kv pair to itself
        # The attr_accessors are in the Student child class
    end

    def table_name_for_insert
        self.class.table_name
        # Calls on table_name method
    end

    def col_names_for_insert
        self.class.column_names[1..-1].join(", ")
        # self.class.column_names{.delete_if {|name| name == "id"}}.join(", ")
        # Returns column_name method but gets rid of id (database assigns that)
        # Joins the array into a string to be SQL appropriate
    end

    def values_for_insert
        self.class.column_names.collect do |name|
            "'#{send(name)}'" unless send(name).nil?
        end.compact.join(", ")
    end

    def save
        sql = <<-SQL
        INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
        VALUES (#{values_for_insert})
        SQL
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * from #{self.table_name} WHERE name = ?", name)
    end

    def self.find_by(hash)
        raw_value = hash.values.first
        value = raw_value.class == Integer ? raw_value : "'#{raw_value}'"
        sql = <<-SQL
        SELECT *
        FROM #{self.table_name}
        WHERE #{hash.keys.first} = #{value}
        SQL
        DB[:conn].execute(sql)
    end

end