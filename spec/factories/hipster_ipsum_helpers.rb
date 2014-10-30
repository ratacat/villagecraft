require 'net/http'
require 'open-uri'

module HipsterIpsumHelpers
  def self.generate(options = {})
    defaults = {
      :paras => 2, # paras = [1 - 99]
      :type => 'hipster-latin', # type = ['hipster-latin', 'hipster-centric'] (default 'hipster-latin')
      :html => false # strips html from output, replaces p tags with newlines
    }
    options.reverse_merge!(defaults)
    
    uri       = "http://hipsterjesus.com/api/?paras=#{options[:paras]}&type=#{options[:type]}&html=#{options[:html]}"
    request   = URI.parse(uri)
    response  = Net::HTTP.get_response(request).body
    JSON.parse(response)['text']
  end
end
