require './eve_api/eve_account'
require 'date'
require 'time'

class EveMarketOrder
  attr_accessor :order_id, :char_id, :station_id, :vol_entered, :vol_remaining, :min_volume
  attr_accessor :order_state, :type_id, :range, :account_key, :duration, :escrow, :price
  attr_accessor :bid, :issued
end

class EveWalletTransaction
  attr_accessor :transaction_id, :transaction_date_time, :quantity, :type_name, :type_id
  attr_accessor :price, :client_id, :client_name, :station_id, :station_name, :transaction_type
  attr_accessor :transaction_for, :journal_transaction_id
end

class EveCharacter
  attr_reader :id, :account
  attr_accessor :name, :corporation_id, :corporation_name

  def initialize( id, account )
    @id = id
    @account = account
  end

  def account_balance
    key = $eve_api.cache_key_for("/char/AccountBalance.xml.aspx", self.account, :characterID => self.id)
    unless @balance = $eve_api_cache.get( key )
      xml = $eve_api.http_request( $eve_api.api_req_url('/char/AccountBalance.xml.aspx', self.account, :characterID => self.id) )
      output = EveData.new xml
      @balance = Float( output.data[ output.data.keys.first ].balance )
      $eve_api_cache.set( key, @balance, ( output.cached_until - Time.now.utc ) )
    end
    return @balance
  end

  #/char/AssetList.xml.aspx
  def assets( options = {} )
  end

  def market_orders( options = {} )
    key = $eve_api.cache_key_for("/char/MarketOrders.xml.aspx", self.account, :characterID => self.id)
    unless @market_orders = $eve_api_cache.get( key )
      @market_orders = Hash.new
      xml = $eve_api.http_request( $eve_api.api_req_url('/char/MarketOrders.xml.aspx', self.account, :characterID => self.id) )
      output = EveData.new xml
      output.data.each do |k,v|
        #brute force, should make this more elegant later.
        order = EveMarketOrder.new
        #integers
        order.order_id      = Integer(v.orderID)
        order.char_id       = Integer(v.charID)
        order.station_id    = Integer(v.stationID)
        order.vol_entered   = Integer(v.volEntered)
        order.vol_remaining = Integer(v.volRemaining)
        order.min_volume    = Integer(v.minVolume)
        order.type_id       = Integer(v.typeID)
        order.range         = Integer(v.range)
        order.account_key   = Integer(v.accountKey)
        order.order_state   = Integer(v.orderState)
        order.duration      = Integer( v.duration )

        #Times

        order.issued        = v.issued

        
        #floats
        order.price         = Float(v.price)
        order.escrow        = Float(v.escrow)

        #bool
        order.bid           = parse_boolean(v.bid)
        
        @market_orders[k] = order
      end
      $eve_api_cache.set( key, @market_orders, ( output.cached_until - Time.now.utc ) )
    end
    return @market_orders
  end

  #/char/SkillInTraining.xml.aspx
  def skill_in_training( options = {} )
    key = $eve_api.cache_key_for("/char/SkillInTraining.xml.aspx", self.account, :characterID => self.id)
    unless @skill = $eve_api_cache.get( key )
      xml = $eve_api.http_request( $eve_api.api_req_url('/char/SkillInTraining.xml.aspx', self.account, :characterID => self.id) )

      doc = REXML::Document.new xml
      skill = Hash.new

      skill['currentTQTime'] = Time.parse(doc.elements['eveapi'].elements['result'].elements['currentTQTime'].text + " UTC") rescue
      skill['trainingEndTime'] = Time.parse(doc.elements['eveapi'].elements['result'].elements['trainingEndTime'].text + " UTC") rescue
      skill['trainingStartTime'] = Time.parse(doc.elements['eveapi'].elements['result'].elements['trainingStartTime'].text + " UTC") rescue
      skill['trainingTypeID'] = doc.elements['eveapi'].elements['result'].elements['trainingTypeID'].text rescue
      skill['trainingStartSP'] = doc.elements['eveapi'].elements['result'].elements['trainingStartSP'].text rescue
      skill['trainingDestinationSP'] = doc.elements['eveapi'].elements['result'].elements['trainingDestinationSP'].text rescue
      skill['trainingToLevel'] = doc.elements['eveapi'].elements['result'].elements['trainingToLevel'].text rescue
      skill['skillInTraining'] = doc.elements['eveapi'].elements['result'].elements['skillInTraining'].text rescue

      cached_until = doc.elements['eveapi'].elements['cachedUntil'].text
      @skill = OpenStruct.new skill
      begin
        $eve_api_cache.set( key, @skill, (Time.parse( cached_until ) - Time.now.utc ) )
      rescue
      end
    end
    return @skill
  end

  def wallet_transactions( options = {} )
    key = $eve_api.cache_key_for("/char/WalletTransactions.xml.aspx", self.account, :characterID => self.id)
    unless @wallet_transactions = $eve_api_cache.get( key )
      @wallet_transactions = Hash.new

      xml = $eve_api.http_request( $eve_api.api_req_url('/char/WalletTransactions.xml.aspx', self.account, :characterID => self.id) )

      output = EveData.new xml
      output.data.each do |k,v|
        #brute force, should make this more elegant later
        transaction = EveWalletTransaction.new
        #integers
        transaction.transaction_id            = Integer(v.transactionID)
        transaction.quantity                  = Integer(v.quantity)
        transaction.type_id                   = Integer(v.typeID)
        transaction.client_id                 = Integer(v.clientID)
        transaction.station_id                = Integer(v.stationID)
        transaction.journal_transaction_id    = Integer(v.journalTransactionID)
        #Times
        transaction.transaction_date_time     = v.transactionDateTime
        #floats
        transaction.price                     = Float(v.price)
        #strings
        transaction.type_name                 = v.typeName
        transaction.client_name               = v.clientName
        transaction.station_name              = v.stationName
        transaction.transaction_type          = v.transactionType
        transaction.transaction_for           = v.transactionFor
        
        @wallet_transactions[k] = transaction
      end
      $eve_api_cache.set( key, @wallet_transactions, ( output.cached_until - Time.now.utc ) )
    end

    return @wallet_transactions
  end
end