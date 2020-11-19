module OrdersHelper
  def hide_card(card_num)
    if card_num.length > 4
      hidden_num =  "*" * card_num.length
      hidden_num[-4..-1] = card_num[-4..-1]
    else
      hidden_num = card_num
    end
    return hidden_num
  end
end
