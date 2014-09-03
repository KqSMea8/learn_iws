class Case

  attr_reader :id,:list

  def initialize id,recent=5
    ret = $db.list "select * from issue_history where issue_id = #{id} order by start_time desc limit #{recent}"
    @id = id
    @list = ret
  end


end
