class Character < Sinatra::Base
  def load_wallet_transactions
    @transactions = @character.wallet_transactions
    @buy_transactions = @transactions.select{ |k,v| v.transaction_type == "buy" }.collect{|a| a[1]}.sort{ |a,b| a.transaction_date_time <=> b.transaction_date_time }.reverse
    @sell_transactions = @transactions.select{ |k,v| v.transaction_type != "buy" }.collect{|a| a[1]}.sort{ |a,b| a.transaction_date_time <=> b.transaction_date_time }.reverse
  end


  get '/character/:id' do
    if params[:sil]
      @character = $sil.character( params[:id] )
    else
      @character = $kazal_than.character( params[:id] )
    end
    haml :'character/index.html'
  end

  get '/character/:id/market_orders' do
    if params[:sil]
      @character = $sil.character( params[:id] )
    else
      @character = $kazal_than.character( params[:id] )
    end
    @market_orders = @character.market_orders
    @open_sell_orders = @market_orders.select{ |k,v| !v.bid && v.order_state == 0 }
    haml :'character/market_orders.html'
  end

  get '/character/:id/wallet_transactions' do
    if params[:sil]
      @character = $sil.character( params[:id] )
    else
      @character = $kazal_than.character( params[:id] )
    end
    load_wallet_transactions
    haml :'character/wallet_transactions.html'
  end

  get '/character/:id/wallet_trends' do
    if params[:sil]
      @character = $sil.character( params[:id] )
    else
      @character = $kazal_than.character( params[:id] )
    end
    load_wallet_transactions
    since = Time.now.utc - 1.month
    @spent = @buy_transactions.select{ |transaction| Time.parse(transaction.transaction_date_time) > since }.each.inject(0.0) do |total, transaction|
      total = total + (transaction.price * transaction.quantity)
    end.round(2)
    @earned = @sell_transactions.select{ |transaction| Time.parse(transaction.transaction_date_time) > since }.each.inject(0.0) do |total, transaction|
      total = total + (transaction.price * transaction.quantity)
    end.round(2)
    @delta = (@earned - @spent).round(2)
    haml :'character/wallet_trends.html'
  end
end