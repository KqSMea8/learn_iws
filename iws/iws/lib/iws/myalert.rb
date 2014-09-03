#! ruby
#encoding:utf-8
require "mail"
class Myalert

  attr_reader :info,:mail_rcv,:sms_rcv

  def initialize mail_rcv,sms_rcv,info
    @mail_rcv = mail_rcv.to_s
    @sms_rcv = sms_rcv.to_s
    @info = info.to_s
		#@mail_text = '<h3>未跟进报警</h3><table border="1" style="color:#333333;border-color:#999999;border-collapse:collapse;width:80%;"><tr style="background:#b5cfd2"><td>产品线</td><td>来源</td><td>规则</td><td>wd</td><td>wt</td><td>tn</td><td>trace</td><td>detail</td></tr>'
    #@mail_text_doing = "<h3>现跟进报警</h3>"
		@mail_text = '<h3>undoing alert</h3><table border="1" style="color:#333333;border-color:#999999;border-collapse:collapse;width:80%;"><tr style="background:#b5cfd2"><td>proline</td><td>source</td><td>rulename</td><td>wd</td><td>wt</td><td>dn</td><td>trace</td><td>detail</td></tr>'
    @mail_text_doing = '<h3>doing alert</h3><table border="1" style="color:#333333;border-color:#999999;border-collapse:collapse;width:80%;"><tr style="background:#b5cfd2"><td>proline</td><td>source</td><td>rulename</td><td>wd</td><td>wt</td><td>dn</td><td>trace</td><td>detail</td></tr>'
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

  def td text
    @mail_text << "<td>" + text+"</td>"
  end

  def tr 
    @mail_text << '<tr style="background:#dcddc0">'
  end

	def trend 
		@mail_text << "</tr>"
	end
	
  def td_doing text
    @mail_text_doing << "<td>" + text+"</td>"
  end

  def tr_doing
    @mail_text_doing << '<tr style="background:#dcddc0">'
  end

	def trend_doing  
		@mail_text_doing << "</tr>"
	end

	def tabend
		@mail_text << "</table>"
	end
 	def tabend_doing
		@mail_text_doing << "</table>"
	end
	def combine
		@mail_text+="<br>"+@mail_text_doing
	end

	def << text
		@mail_text+= "<br>"+text
	end
	def putsout
		puts @mail_text
	end
end
