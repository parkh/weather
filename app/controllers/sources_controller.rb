class SourcesController < ApplicationController

  require 'mechanize'

  def search
    city_name = params[:search]

    agent = Mechanize.new
    agent.get("http://sinoptik.ua")
    form = agent.page.forms.first
    form.search_city = city_name
    form.submit
    if CGI::unescape(agent.page.uri.to_s) =~ /погода-/ && CGI::unescape(agent.page.uri.to_s) !~ /search_city/
      if params[:commit] == "sinoptik"
        parse_sinoptik(city_name)
      elsif params[:commit] == "meteo"
        parse_meteo(city_name)
      end
    else
      flash[:notice] = "Город #{city_name} еще не построили, либо ни Sinoptik.ua, ни Meteo.ua пока не знают о нем."
      redirect_to controller: 'main', action: 'index'
    end
  end

  def parse_sinoptik(city_name)
    agent = Mechanize.new
    agent.get("http://sinoptik.ua")
    form = agent.page.forms.first
    form.search_city = city_name
    form.submit

    city = City.new
    city.name = agent.page.search(".cityNameShort strong").text
    city.min_t = agent.page.search(".min span").text.split("°")
    city.max_t = agent.page.search(".max span").text.split("°")
    city.user_id = session[:user_id]

    save(city)
  end

  def parse_meteo(city_name)
    agent = Mechanize.new
    agent.get("http://meteo.ua")
    form = agent.page.form_with(id: "search-form")
    form.field.value = city_name
    form.submit

    if CGI::unescape(agent.page.uri.to_s) =~ /search-forecast-by-city-name/
      page = agent.page
      node = page.search(".main_cont p:nth-child(2) a").first
      Mechanize::Page::Link.new(node, agent, page).click
    end

    city = City.new
    city.name = agent.page.search(".src_title .txt_pink").text
    city.min_t = agent.page.search(".wwt_min span:nth-child(2)").text.split("°")
    city.max_t = agent.page.search(".wwt_max span:nth-child(2)").text.split("°")
    city.user_id = session[:user_id]

    save(city)
  end

  def save(city)
    if city.save
      flash[:notice] = "Город найден и добавлен в базу данных."
      redirect_to controller: 'main', action: 'index'
    else
      flash[:notice] = "Парсируемый сайт выдал что-то непредсказуемое..."
      redirect_to controller: 'main', action: 'index'
    end
  end

end
