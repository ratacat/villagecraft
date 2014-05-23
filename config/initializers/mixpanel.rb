MIXPANEL = YAML.load_file("#{::Rails.root}/config/mixpanel.yml").symbolize_keys()
