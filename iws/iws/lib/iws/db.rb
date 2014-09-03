#!/usr/bin/env ruby   

class Db

  @@dbh = 0

  def initialize config
    @db_cfg = config
    connect
  end

  def connect config=nil
    db = @db_cfg if !config
    begin
      @@dbh = Mysql.new(db["ip"],db["user"],db["passwd"],db["database"],db["port"].to_i)
    rescue => e
      raise "mysql connect error, #{e}"
    end
  end

  def query query
    puts query if (defined? $debug) && ($debug == true)
    n = 0
    begin 
      @@dbh.query query        
    rescue
      n += 1
      connect
      retry if n < 3
    end
  end

  def list query
    list = []
    res = query query   
    res.each_hash do | row |
      list << row
    end
    res.free
    return list
  end

  def one query
    list(query)[0]
  end

  def findOne query
    one query
  end

  def select(table,where_form=nil)
    if where_form
      query "select * from `#{table}` where #{where_form}"
    else
      query "select * from `#{table}`"
    end
  end
  
  def select_list(table,where_form=nil)
    if where_form
      list "select * from `#{table}` where #{where_form}"
    else
      list "select * from `#{table}`"
    end
  end

  def select_one(table,where_form=nil)
    if where_form
      one "select * from `#{table}` where #{where_form}"
    else
      one "select * from `#{table}`"
    end
  end

  def method_missing(method_id, *arguments, &block)
    if match = /([a-zA-Z]*)_([_a-zA-Z]\w*)_by_([_a-zA-Z]\w*)/.match(method_id.to_s) || match = /([a-zA-Z]*)_([_a-zA-Z]\w*)/.match(method_id.to_s)
      if match[3]
        self.send(match[1], "SELECT * FROM `#{match[2]}` where `#{match[3]}` = '#{arguments[0]}'")
      else
        self.send(match[1], "SELECT * FROM `#{match[2]}`")
      end
    else
      super
    end
  end

  def respond_to?(method_id, include_private = false)
    if match = /([a-zA-Z]*)_([_a-zA-Z]\w*)_by_([_a-zA-Z]\w*)/.match(method_id.to_s) || match = /([a-zA-Z]*)_([_a-zA-Z]\w*)/.match(method_id.to_s)
      true
    else
      super
    end
  end

end
