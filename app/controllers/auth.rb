ActivateApp::App.controller do
    
  get '/auth/failure' do
    flash.now[:error] = "<strong>Hmm.</strong> There was a problem signing you in."
    erb :'accounts/sign_in'
  end
  
  %w(get post).each do |method|
    send(method, "/auth/:provider/callback") do      
      account = if env['omniauth.auth']['provider'] == 'account'
        Account.find(env['omniauth.auth']['uid'])
      else
        env['omniauth.auth'].delete('extra')
        @provider = Provider.object(env['omniauth.auth']['provider'])
        ProviderLink.find_by(provider: @provider.display_name, provider_uid: env['omniauth.auth']['uid']).try(:account)
      end
      if current_account # already signed in; attempt to connect            
        if account # someone's already connected
          flash[:error] = "Someone's already connected to that account!"
        else # connect; Account never reaches here
          flash[:notice] = "<i class=\"fa fa-#{@provider.icon}\"></i> Connected!"
          current_account.provider_links.build(provider: @provider.display_name, provider_uid: env['omniauth.auth']['uid'], omniauth_hash: env['omniauth.auth'])
          current_account.picture_url = @provider.image.call(env['omniauth.auth']) unless current_account.picture
          current_account.save
        end
        redirect url(:accounts, :edit)
      else # not signed in
        if account # sign in
          session['account_id'] = account.id
          flash[:notice] = "Signed in!"
          if session[:return_to]
            redirect session[:return_to]
          else
            redirect url(:home)
          end
        else
          flash.now[:notice] = "<i class=\"fa fa-#{@provider.icon}\"></i> We need a few more details to finish creating your account&hellip;"
          session['omniauth.auth'] = env['omniauth.auth']
          @account = Account.new
          @account.name = env['omniauth.auth']['info']['name']
          @account.email = env['omniauth.auth']['info']['email']  
          @account.picture_url = @provider.image.call(env['omniauth.auth'])
          @account.provider_links.build(provider: @provider.display_name, provider_uid: env['omniauth.auth']['uid'], omniauth_hash: env['omniauth.auth'])
          erb :'accounts/build'
        end
      end
    end
  end 
  
end