module ActivateApp
  class App < Padrino::Application
    get '/' do
      redirect '/admin'
    end     
  end         
end
