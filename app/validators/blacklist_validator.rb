class BlacklistValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    BLACKLIST.each do |word|
      if value =~ /\s(#{word})\s/i
        record.errors.add attribute.to_s, "Please don't use words like #{word} in your reviews."
        return
      end
    end
  end
end
