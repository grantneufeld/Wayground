# encoding: utf-8

# extension to ActiveRecord to support setting fields to map as DbArray values
ActiveRecord::Base.class_eval do

  def self.make_db_array_field(*fields)
    fields.each do |field|
      class_eval "
        def #{field}
          unless @#{field}
            value = read_attribute(:#{field})
            @#{field} = DbArray.new(value) if value
          end
          @#{field}
        end
        def #{field}=(value)
          @#{field} = DbArray.new(value)
          write_attribute(:#{field}, @#{field}.to_s)
          @#{field}
        end
      "
    end
  end

end
