#!/usr/bin/env ruby

class Conf < Hash

  def initialize config_file=nil
    self.merge! default_value
    if config_file
      begin
        c = YAML.load_file(config_file)
        self.merge! c
      rescue => e
        raise "Could not read YAML file #{config_file}: #{e}"
      end
    end
  end

  def default_value
    {
      "db"=>{
        "ip"=>"10.46.148.28", 
        "port"=>"8584",
        "user"=>"iws", 
        "passwd"=>"iws", 
        "database"=>"iws",
      },
      "enviro"=>"itebeta",
      "missing_thr"=>5,
      "log_path"=>"./log/iws.log",
    }
  end

end
