class Alert

  attr_reader :info,:mail_rcv,:sms_rcv

  def initialize mail_rcv,sms_rcv,info
    @mail_rcv = mail_rcv.to_s
    @sms_rcv = sms_rcv.to_s
    @info = info.to_s
    @mail_text = ""
  end

  def send_sms
    return nil if !@sms_rcv || @sms_rcv == ''
    @sms_rcv.split(/,|;| /).each do | person | 
      system "/bin/gsmsend -s emp01.baidu.com:15003 -s emp02.baidu.com:15003 #{person}@\"#{@info}\""
    end
  end

  def send_mail
    return nil if !@mail_rcv || @mail_rcv == ''
    begin
      system "echo '#{@mail_text}' | /bin/mail -s \"#{@info}\" #{@mail_rcv.gsub(/,| /," ")}"
    rescue
      puts "NO MAIL"
    end
  end

  def << text
    @mail_text << "\n" + text
  end

end
