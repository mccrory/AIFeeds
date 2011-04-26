require 'net/smtp'

# send an email to gmail
def send_email_gmail(gmail_email, password, message, from_address, to_address)
  smtp = Net::SMTP.new('smtp.gmail.com', 587)
  smtp.enable_starttls
  smtp.start("smtp.gmail.com", gmail_email, password, :login) do
    smtp.send_message(message, from_address, to_address)
  end
end

# prepare an smtp message
def build_message(subject, from_name, from_address, to_name, to_address, body, html=false)
  message = ""
  message << "From: #{from_name} <#{from_address}>\n"
  message << "To: #{to_name} <#{to_address}>\n"
  message << "Subject: #{subject}\n"
  message << "Date: #{Time.now}\n"
  if html
    message << "MIME-Version: 1.0\n"
    message << "Content-type: text/html\n"
  end
  message << "#{body}\n"
  return message
end

if __FILE__ == $0
  puts "What is your gmail email?"
  myemail = gets.strip  
  puts "What is your gmail password?"
  password = gets.strip  

  # build message
  message = build_message("AIFeed Test Message", "AIFeed", myemail, "You", myemail, "<h1>hello world</h1>", true)
  # send message
  send_email_gmail(myemail, password, message, myemail, myemail)
  puts "done"
end