class Activity < PublicActivity::Activity
  def self.activities_n_counts(options={})
    defaults = {
      :limit => 20,
      :owner => nil,
      :trackable => nil
    }
    options.reverse_merge!(defaults)
    
    @where_conditions = []
    if options[:owner]
      @where_conditions << %Q("activities"."owner_id" = #{options[:owner].id} AND "activities"."owner_type" = 'User')
    end
    if options[:trackable]
      @where_conditions << %Q("activities"."trackable_id" = #{options[:trackable].id} AND "activities"."trackable_type" = '#{options[:trackable].class.to_s}')
    end
    @where_clause = %Q(WHERE #{@where_conditions.join(" AND ")}) unless @where_conditions.blank?
    
    fancy_windowing_sql = %Q(
      SELECT max(id) AS max_id, min(id) as min_id, count(id) AS like_id_count, array_agg(id) AS like_ids
      FROM ( 
        SELECT id, 
               owner_id, 
               created_at, 
               row_number() OVER (ORDER BY id) - row_number() OVER (PARTITION BY trackable_id, trackable_type, owner_id, owner_type, key, parameters ORDER BY id) AS grp 
        FROM activities 
        #{@where_clause} 
        ORDER BY id) t 
      GROUP BY grp, owner_id 
      ORDER BY max_id 
      DESC LIMIT #{options[:limit]};
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
      es_like_ids = eval('[' + e["like_ids"][1..-2] + ']')
      like_ids << es_like_ids
      mins << e['min_id']
    end
    PublicActivity::Activity.where(:id => ids).order(:id).reverse_order.each_with_index.map do |a, i|
      {:activity => a, :count => counts[i], :oldest_id => mins[i], :like_ids => like_ids[i]}
    end
  end
  
end