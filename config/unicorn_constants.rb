module UnicornConstants
  NUM_WORKERS = 2

  def self.my_worker_num
    me = $0.match(/worker\[(\d*)\]/)[1].to_i
  end
end
