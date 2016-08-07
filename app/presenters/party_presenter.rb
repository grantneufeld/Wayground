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

  def present_heading(is_no_link = false)
    html_tag_with_newline(:h1, party_attrs) do
      (is_no_link ? party.name : linked_party_name) + html_escape(" [#{party.abbrev}]")
    end
  end

  def present_dates(separator = nil)
    dates = []
    if party.established_on?
      dates << "Established on #{party.established_on.to_datetime.to_s(:simple_date)}.".html_safe
    end
    if party.registered_on?
      dates << "Registered on #{party.registered_on.to_datetime.to_s(:simple_date)}.".html_safe
    end
    dates << "Ended on #{party.ended_on.to_datetime.to_s(:simple_date)}.".html_safe if party.ended_on?
    output_dates(dates, separator)
  end

  protected

  def linked_party_name
    view.link_to(party.name, [level, party])
  end

  def party_attrs
    attrs = { class: 'party-label' }
    attrs[:style] = "border-color:#{party.colour}" if party.colour?
    attrs[:class] += ' party-unregistered' unless party.is_registered
    attrs
  end

  def party_ended_on
    party.ended_on.to_datetime.to_s(:simple_date) if party.ended_on?
  end

  def level
    party.level
  end

  def output_dates(dates, separator)
    if dates.size.positive?
      separator =
        if separator
          html_escape(separator)
        else
          newline + html_tag(:br)
        end
      html_tag_with_newline(:p) { view.safe_join(dates, separator) }
    end
  end
end
