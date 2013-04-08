class MainController < ApplicationController

  require 'mechanize'

  def index
    @cities = City.where( session_id: session[:session_id] ).order("updated_at DESC")
  end

  def search
    city = params[:search]
    validate(city)
  end

  def validate(city)
    agent = Mechanize.new
    agent.get("http://sinoptik.ua")
    form = agent.page.forms.first
    form.search_city = city
    form.submit
    if agent.page.uri.to_s =~ /search_city/     # add OR something else on agent.page
      flash[:notice] = "город #{city} еще не построили, либо sinoptik.ua не знает о нем"
      redirect_to action: 'index'
    else
      parse(agent)
    end
  end

  def parse(agent)
    city = City.new
    city.name = CGI::unescape(agent.page.uri.to_s).split("-").last.mb_chars.capitalize.to_s
    city.min_t = agent.page.search(".min span").text.split("°")
    city.max_t = agent.page.search(".max span").text.split("°")
    city.session_id = session[:session_id]

    week_chance = []
    agent.page.links_with(href: /2013/).each do |link|
      link.click
      day_chance = []
      agent.page.search("tr:nth-child(8) td").each do |chance|
        day_chance << chance.text.to_i
      end
    week_chance << day_chance.max
    end
    city.precip_chance = week_chance

    if city.save
      flash[:notice] = "бд обновлена"
      redirect_to action: 'index'
    else
      flash[:notice] = "ошибка при добавлении в БД"
      redirect_to action: 'index'
    end
  end


#  def bigmir
#    agent = Mechanize.new
#    agent.get("http://weather.bigmir.net/")
#    form = agent.page.forms.first
#    form.q = "Черкассы"
#    form.submit
#    agent.page.links_with(text: /ерка/ )[0].click
#    agent.page.links_with(href: /forecast/ )[0].click
#    @bigmir = agent.page.search("td:nth-child(3) b").text.split("%")
#  end

end

