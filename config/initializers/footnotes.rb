if defined?(Footnotes) && Rails.env.development?
  Footnotes.run! # first of all

  # prevent rails-footnotes from outputing debug information to letter-opener mail
  notes = Footnotes::Filter.notes
  Footnotes.setup do |config|
    config.before do |controller, filter|
      if controller.class.name =~ /LetterOpenerWeb/
        filter.notes = []
      else
        filter.notes = notes
      end
    end
  end
end
