require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
    self.column_names.each do |property|
        attr_accessor property.to_sym
    end
end