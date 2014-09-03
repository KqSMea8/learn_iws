#! ruby
#encoding:utf-8
require "mail"
class Myalert

  attr_reader :info,:mail_rcv,:sms_rcv

  def initialize mail_rcv,sms_rcv,info
    @mail_rcv = mail_rcv.to_s
    @sms_rcv = sms_rcv.to_s
    @info = info.to_s
		#@mail_text = "<h3>未跟进报警</h3>"
    #@mail_text_doing = "<h3>现跟进报警</h3>"
		@mail_text = "<h3>undoing alert</h3>"
    @mail_text_doing = "<h3>doing alert</h3>"
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
			#system "echo '#{@mail_text}' | /bin/mail -s \"#{@info}\" #{@mail_rcv.gsub(/,| /," ")}"
			tostr=@mail_rcv
			sub=@info
			mailtext=@mail_text
			mail=Mail.new do 
			  from 'server'
				to tostr
				subject sub
				html_part do
					content_type 'text/html;charset=GBK'
					body mailtext
				end
			end
			mail.delivery_method :sendmail
			mail.deliver
    rescue=>e
			puts e
      puts "NO MAIL"
    end
  end

  def mess text
    @mail_text << "<br>" + text
  end

  def hl text
    @mail_text << "<h4>" + text+"</h4>"
  end
 
  def mess_doing text
    @mail_text_doing << "<br>" + text
  end

  def hl_doing text
    @mail_text_doing << "<h4>" + text+"</h4>"
  end

	def combine
		@mail_text+=@mail_text_doing
	end


end
