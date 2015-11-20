require "concurrent"
class MainController < ApplicationController
  @@votes_left = 0
  # @@form_url = "https://docs.google.com/forms/d/1XnhCLV_BKFUD9vOcJdtskRzjpCHap__sp_vhyqwJvjo/viewform"
  @@form_url = "https://docs.google.com/forms/d/19FfLH0u7x4L13Uh-BoEFmnCybM4WMWG6jprDNDtrVZE/viewform"
  def index
    @total_votes = Vote.first.count
    @max_votes = 200
    @votes_left = @@votes_left
    @form_url = @@form_url
  end

  def submit_votes
    number_of_votes = params["vote"]["number"].to_i
    randomize = params["randomize"] ? true : false
    @@votes_left += number_of_votes
    Concurrent::Future.execute { vote(number_of_votes, randomize) }
    index
    render action: "index"
  end

  def vote(number_of_times, randomize)
    agent = Mechanize.new
    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    agent.get @@form_url
    form = agent.page.forms[0]
    form.radiobutton_with(:value => /Lincoln High School/).check
    number_of_times.times do
      Vote.first.increment!(:count, 1)
      form.submit
      @@votes_left -= 1
      if randomize
        rand = 5 * rand()
        puts "sleeping for #{rand}"
        sleep rand
      end
    end


  end
end
