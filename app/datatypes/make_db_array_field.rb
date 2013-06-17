# encoding: utf-8

# extension to ActiveRecord to support setting fields to map as DbArray values
ActiveRecord::Base.class_eval do

  def self.make_db_array_field(*fields)
    fields.each do |field|
      class_eval "
        def #{field}
          unless @#{field}
            value = read_attribute(:#{field})
            @#{field} = DbArray.new(db: value)
          end
          @#{field}
        end
        def #{field}=(value)
          @#{field} = DbArray.new(user: value)
          write_attribute(:#{field}, @#{field}.to_db)
          @#{field}
        end
      "
      # ugly, ugly, hack to make up for the awful fact that Rails form helpers use [field_name]_before_type_cast
      class_eval "
        def #{field}_before_type_cast
          #{field}.to_s
        end
      "
    end
  end

end
