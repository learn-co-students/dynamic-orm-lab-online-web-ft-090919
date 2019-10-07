require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

    self.column_names.each do |name|
        attr_accessor name.to_sym
    end
    # Iterates over the array of column names from Interactive Record parent class
    # Converts column names to a symbol
    # Makes them attr_accessors

end
