class Product

  attr_reader :id,:name,:kpi1,:kpi2,:mttr,:mtbf,:noah2url

  def initialize desc
    if desc.to_i != 0
      ret = $db.findOne_product_by_id desc
    elsif desc.kind_of? String
      ret = $db.findOne_product_by_name desc
    end
    @id = ret["id"]
    @name = ret["name"]
    @noah2url = ret['noah2url']
  end

  def get_kpi last = 0
    now = DateTime.now                                                                                 
    d2c = now - ( 30 * last )    
    kpi1 = 0.0
    kpi2 = 100.0
    weight = 0.0
    mttr = 0.0
    cnt = 0

    issue_list = IssueList.new @id
    issue_list.each do |issue|
      issue_kpi = issue.kpi last
      i_weight = issue.weight.to_f
      if i_weight > 0
        kpi1 += issue_kpi["stability"].to_f * i_weight
        kpi2 -= 100.0 - issue_kpi["stability"].to_f
        weight += i_weight
        cnt += issue_kpi["cnt"].to_i
        mttr += issue_kpi["mttr"].to_f * issue_kpi["cnt"].to_i
      end
    end
    kpi1 = weight>0? kpi1/weight : 1
    mttr = cnt>0? mttr/cnt : 0
    mtbf = cnt>0? 30.0/cnt : 30

    @kpi1 = kpi1
    @kpi2 = kpi2
    @mttr = mttr
    @mtbf = mtbf
    @cnt = cnt
  end

  def update_kpi last = 0
    get_kpi last
    now = DateTime.now                                         
    d2c = now - ( 30 * last )    
    $db.query "REPLACE INTO `product_kpi` (`month`, `product_id`, `stability1`, `stability2`, `mttr`, `mtbf`, `cnt`) VALUES ('#{d2c.strftime("%Y-%m-01")}', #{@id}, #{@kpi1}, #{@kpi2}, #{@mttr}, #{@mtbf}, #{@cnt});"
  end

  def kpi last = 0
    now = DateTime.now                                                                                 
    d2c = now - ( 30 * last )    
    ret = $db.findOne "select * from product_kpi where product_id = #{id} and date_format(month,'%Y-%m') = '#{d2c.strftime("%Y-%m")}'"
    if ret
      ret["stability1"] = ret["stability1"].to_f
      ret["stability2"] = ret["stability2"].to_f
      ret["mttr"] = ret["mttr"].to_f
      ret["mtbf"] = ret["mtbf"].to_f
    end
    ret
  end

  def kpi_today
    k1 = 0.0
    k2 = 100.0
    weight = 0
    issue_list = IssueList.new @id
    issue_list.each do |issue|
      issue_kpi = issue.kpi_today
      i_weight = issue.weight.to_f
      if i_weight > 0 && issue_kpi
        k1 += issue_kpi * i_weight
        k2 -= 100.0 - issue_kpi
        weight += i_weight
      end
    end
    k1 = weight>0? k1/weight : 1
    k2
  end

end

class ProductList < Array   
  def initialize 
    ret = $db.query_product
    ret.each_hash do | row |
      p = Product.new row["id"]
    self << p
    end
  end

  def self.fetch_name id
    ret = $db.findOne_product_by_id id
    ret["name"]
  end

  def self.fetch_id proname
    ret = $db.findOne_product_by_name proname
    ret["id"].to_i
  end

end

