class Activity < PublicActivity::Activity
  def self.activities_n_counts(n)
    # returns an arrays of ids, like_ids, and a count; each record looks something like this:
    # {"id"=>"451", "like_ids"=>"{456,451,452,453,454,455}", "like_id_count"=>"6"}
    fancy_windowing_sql = %Q(
      SELECT min(id) AS id, array_agg(id) AS like_ids, count(id) AS like_id_count 
      FROM ( 
        SELECT id, 
               owner_id, 
               created_at, 
               row_number() OVER (ORDER BY id) - row_number() OVER (PARTITION BY trackable_id, trackable_type, owner_id, owner_type, key ORDER BY id) AS grp 
        FROM activities 
        ORDER BY id) t 
      GROUP BY grp, owner_id 
      ORDER BY max(id) 
      DESC LIMIT #{n};
    )    
    records_array = ActiveRecord::Base.connection.execute(fancy_windowing_sql)
    ids = []
    counts = []
    like_ids = []
    records_array.each do |e|
      ids << e['id']
      counts << e["like_id_count"].to_i
      like_ids << e["like_ids"]
    end
    PublicActivity::Activity.where(:id => ids).order(:id).reverse_order.each_with_index.map do |a, i|
      {:activity => a, :count => counts[i], :like_ids => like_ids[i]}
    end
  end
  
end