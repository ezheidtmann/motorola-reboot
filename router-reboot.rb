require 'eventmachine'
require 'rubygems'
require 'em-http'
require 'nokogiri'

EM.run {
  conn = EM::HttpRequest.new('http://192.168.0.1/')

  request_options = {
    :path => 'frames.asp',
    :body => { 
      'userId' => 'admin', 
      'password' => 'motorola', 
      'btnLogin' => 'Log In' 
    }
  }

  req = conn.post request_options

  req.callback {
    doc = Nokogiri::HTML(req.response)
    doc.css('frame[name=left]').each do |frame|
      qs = URI.parse(frame['src']).query
      qs = CGI.parse(qs)

      opts = { 
        :path => '/goform/AlFrame', 
        :query => {
          'sessionId' => qs['sessionId'][0],
        },
        :body => {
          'General.Modem.state' => 2,
          'urlOk' => 'redirect.asp',
          'urlError' => 'redirect.asp?error=error',
        }
      }

      conn = EM::HttpRequest.new('http://192.168.0.1/')
      otherreq = conn.post opts
      otherreq.errback {
        p 'err'
        p otherreq.error
      }
      otherreq.callback {
        EM.stop
      }
    end

  } 
}
