module ActiveRecord
  module ModelSchema
    module ClassMethods
      def quoted_table_column(column_name)
        "#{quoted_table_name}.#{connection.quote_column_name(column_name)}"
      end
    end
  end
end
  