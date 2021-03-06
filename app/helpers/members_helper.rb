module MembersHelper
  def login_link(login_now, member)
    login_now ? t('content.member.login_now') : link_to(t('content.member.login'), login_path(member.member_id))
  end

  def give_page_link(to_member, currency_information)
    return "-" if login_member.member_id == to_member.member_id

    from_member = login_member
    link_to(
      t('content.member.presetn', name: to_member.name, currency: currency_information.name),
      confirm_give_path(from_member.member_id, to_member.member_id, currency_information.id)
    )
  end

  def get_amount_of_500_per_options_by_member(member, currency)
    get_amount_of_500_per_options(member.currency_amount(currency.currency_id))
  end

  def get_amount_of_500_per_options(max_amount)
    option_tag_list = []
    0.step(max_amount, 500) do |amount|
      option_tag_list.push(
        <<-TAG
        <option value="#{amount}">#{amount}</option>
        TAG
      )
    end
    option_tag_list.join("\n").html_safe
  end

  def create_give_action_path(from, to, currency)
    give_path(
      from.member_id,
      to.member_id,
      currency.currency_id
    )
  end

  def delete_member_link(member)
    member.deletable? ?
      link_to("Delete", member, method: :delete, confirm: t('message.confirm_delete')) :
      '<span class="muted">Delete</span>'.html_safe
  end
end

