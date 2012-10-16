class Account < Sinatra::Base
  get '/account/account_status' do
    if params[:sil]
      @status = $sil.account_status
    else
      @status = $kazal_than.account_status
    end
    haml :'account/account_status.html'
  end

  get '/account/api_key_info' do
    if params[:sil]
      @key_info = $sil.api_key_info
    else
      @key_info = $kazal_than.api_key_info
    end
    haml :'account/api_key_info.html'
  end

  get '/account/characters' do
    if params[:sil]
      @characters = $sil.characters
    else
      @characters = $kazal_than.characters
    end
    haml :'account/characters.html'
  end
end