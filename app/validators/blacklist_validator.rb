class BlacklistValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if BLACKLIST.any? {|word| value.include?(word)}
      record.errors.add attribute.to_s, "I am sure you can express yourself a little bit nicer"
    end
  end
end
