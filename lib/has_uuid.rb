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
    module UUID
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def has_uuid(options = {})
          class_eval <<-EOV
          include ActiveRecord::Has::UUID::InstanceMethods
          before_validation :set_uuid
          validates :uuid, :presence => {}, :uniqueness => {}
          EOV

          if options[:length]
            instance_eval <<-EOV
            def generate_candidate
              UUIDTools::UUID.random_create.to_s[0..(#{options[:length] - 1})]
            end
            EOV
          else
            instance_eval <<-EOV
            def generate_candidate
              UUIDTools::UUID.random_create.to_s
            end
            EOV
          end
        end

        def generate_uuid
          candidate = self.send(:generate_candidate)
          self.find_by_uuid(candidate) ? generate_uuid : candidate
        end

        def from_param(param)
          self.first :conditions => {:uuid => param}
        end
        
      end

      module InstanceMethods
        def to_param
          self.uuid
        end
        
        def set_uuid
          if self.uuid.blank?
            self.uuid = self.class.generate_uuid
          end
        end
      end
    end
  end
end
