=begin
Copyright (c) 2013 Benjamin Teitelbaum

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
=end
module ActiveRecord
  module Has
    module StartAndEndTime
      extend ActiveSupport::Concern

      # add your static(class) methods here
      module ClassMethods
        def starting_after(t)
          where(%Q(#{self.quoted_table_name}."start_time" > ?), t )
        end

        def starting_before(t)
          where(%Q(#{self.quoted_table_name}."start_time" < ?), t )
        end

        def ending_after(t)
          where(%Q(#{self.quoted_table_name}."end_time" > ?), t )
        end

        def ending_before(t)
          where(%Q(#{self.quoted_table_name}."end_time" < ?), t )
        end

        def future
          starting_after(Time.now)
        end

        def past
          starting_before(Time.now)
        end
      end
    end
  end
end

# include the extension 
ActiveRecord::Base.send(:include, ActiveRecord::Has::StartAndEndTime)
