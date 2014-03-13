BLACKLIST = []
IO.foreach("#{Rails.root}/config/blacklist.txt") { |line| BLACKLIST << line.chomp }