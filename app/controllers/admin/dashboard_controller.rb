class Admin::DashboardController < ApplicationController
  def index
    dash_auth! :index, :dashboard
  end
  
  def recent_activity
    dash_auth! :recent_activity, :dashboard
    
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
      DESC LIMIT #{ACTIVITIES_PER_PAGE};
    )    
    records_array = ActiveRecord::Base.connection.execute(fancy_windowing_sql)
    ids = records_array.map {|e| e["id"]}
    counts = records_array.map {|e| e["like_id_count"].to_i}
    @activities_n_counts = [PublicActivity::Activity.where(:id => ids).order(:id).reverse_order, counts].transpose
  end
  
  protected
  
  def dash_auth!(action, subject)
    authorize! action, subject, :message => "The admin dashboard is only for admins in admin mode."
  end
  
end
