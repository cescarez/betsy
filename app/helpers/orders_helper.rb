module OrdersHelper
  def hide_card(card_num)
    hidden_num =  "*" * card_num.length
    hidden_num[-4..-1] = card_num[-4..-1]
    return hidden_num
  end
end
