class Activity < PublicActivity::Activity
  def self.activities_n_counts(n)
    fancy_windowing_sql = %Q(
      SELECT max(id) AS max_id, min(id) as min_id, count(id) AS like_id_count 
      FROM ( 
        SELECT id, 
               owner_id, 
               created_at, 
               row_number() OVER (ORDER BY id) - row_number() OVER (PARTITION BY trackable_id, trackable_type, owner_id, owner_type, key ORDER BY id) AS grp 
        FROM activities 
        ORDER BY id) t 
      GROUP BY grp, owner_id 
      ORDER BY max_id 
      DESC LIMIT #{n};
    )    
    records_array = ActiveRecord::Base.connection.execute(fancy_windowing_sql)
    ids = []
    counts = []
    like_ids = []
    mins = []
    maxs = []
    records_array.each do |e|
      ids << e['max_id']
      counts << e["like_id_count"].to_i
      mins << e['min_id']
    end
    PublicActivity::Activity.where(:id => ids).order(:id).reverse_order.each_with_index.map do |a, i|
      {:activity => a, :count => counts[i], :oldest_id => mins[i]}
    end
  end
  
end