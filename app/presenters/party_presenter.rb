# encoding: utf-8
require 'html_presenter'

# Present a political Party.
class PartyPresenter < HtmlPresenter
  attr_reader :view, :party, :user

  def initialize(params)
    @view = params[:view]
    @party = params[:party]
    @user = params[:user]
  end

  def present_as_list_item
    html_tag(:li, party_attrs) do
      view.safe_join([linked_party_name, party_ended_on], newline + html_tag(:br))
    end
  end

  def present_heading
    html_tag_with_newline(:h1, party_attrs) do
      html_escape("#{level.name} party: ") + linked_party_name + html_escape(" [#{party.abbrev}]")
    end
  end

  def present_dates(separator=nil)
    dates = []
    if party.established_on?
      dates << "Established on #{party.established_on.to_datetime.to_s(:simple_date)}.".html_safe
    end
    if party.registered_on?
      dates << "Registered on #{party.registered_on.to_datetime.to_s(:simple_date)}.".html_safe
    end
    if party.ended_on?
      dates << "Ended on #{party.ended_on.to_datetime.to_s(:simple_date)}.".html_safe
    end
    if dates.size > 0
      if separator
        separator = html_escape(separator)
      else
        separator = newline + html_tag(:br)
      end
      html_tag_with_newline(:p) do
        view.safe_join(dates, separator)
      end
    else
      nil
    end
  end

  protected

  def linked_party_name
    #debugger if party.name == 'DEBUG'
    view.link_to(party.name, [level, party])
  end

  def party_attrs
    attrs = { class: 'party-label' }
    if party.colour?
      attrs[:style] = "border-color:#{party.colour}"
    end
    unless party.is_registered
      attrs[:class] += ' party-unregistered'
    end
    attrs
  end

  def party_ended_on
    party.ended_on.to_datetime.to_s(:simple_date) if party.ended_on?
  end

  def level
    party.level
  end

end
