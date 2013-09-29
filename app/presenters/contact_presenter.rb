# encoding: utf-8
require 'html_presenter'

# Present a Contact.
class ContactPresenter < HtmlPresenter
  attr_reader :view, :contact, :user

  def initialize(params)
    @view = params[:view]
    @contact = params[:contact]
    @user = params[:user]
  end

  def present_attributes(separator=nil)
    separator ||= newline
    view.safe_join(
      ([
        present_url, present_email, present_phone, present_phone2, present_fax,
        present_address, present_twitter
      ].delete_if { |part| part.blank? }), separator
    )
  end

  def present_attributes_short(separator=nil)
    separator ||= newline
    view.safe_join(
      ([
        present_url, present_email, present_phone, present_address_short, present_twitter
      ].delete_if { |part| part.blank? }), separator
    )
  end

  def present_url
    return html_blank unless contact.url.present?
    html_tag_with_newline(:span, class: 'home', title: 'Website') do
      html_tag(:span, class: 'label') { 'Website: '.html_safe } +
      view.link_to(url_for_print(contact.url), contact.url, class: 'url')
    end
  end

  def present_email
    return html_blank unless contact.email.present?
    html_tag_with_newline(:span, class: 'emailadr', title: 'Email') do
      html_tag(:span, class: 'label') { 'Email: '.html_safe } +
      view.link_to(contact.email, "mailto:#{contact.email}", class: 'email')
    end
  end

  def present_phone
    return html_blank unless contact.phone.present?
    html_tag_with_newline(:span, class: 'phone', title: 'Phone') do
      html_tag(:span, class: 'label') { 'Phone: '.html_safe } +
      html_tag(:span, class: 'tel') { contact.phone }
    end
  end

  def present_phone2
    return html_blank unless contact.phone2.present?
    html_tag_with_newline(:span, class: 'phone', title: 'Phone') do
      html_tag(:span, class: 'label') { 'Phone: '.html_safe } +
      html_tag(:span, class: 'tel') { contact.phone2 }
    end
  end

  def present_fax
    return html_blank unless contact.fax.present?
    html_tag_with_newline(:span, class: 'fax tel', title: 'Fax') do
      html_tag(:span, class: 'label type') { 'Fax: '.html_safe } +
      html_tag(:span, class: 'value') { contact.fax }
    end
  end

  def present_address(separator=nil)
    return html_blank unless address_info_present?
    separator ||= ';'.html_safe + newline
    html_tag_with_newline(:span, class: 'address', title: 'Address') do
      html_tag(:span, class: 'label') { 'Address: '.html_safe } +
      html_tag(:span, class: 'adr') do
        parts = []
        part = present_street_address
        parts << part unless part.blank?
        part = present_locality
        parts << part unless part.blank?
        view.safe_join(parts, separator)
      end
    end
  end

  def present_address_short
    return html_blank unless contact.address1.present? || contact.address2.present?
    html_tag_with_newline(:span, class: 'address', title: 'Address') do
      html_tag(:span, class: 'label') { 'Address: '.html_safe } +
      html_tag(:span, class: 'adr') { present_street_address }
    end
  end

  def present_street_address
    return html_blank unless contact.address1.present? || contact.address2.present?
    html_tag(:span, class: 'street-address') do
      address_chunks = [contact.address1, contact.address2]
      address_chunks.delete_if { |chunk| chunk.blank? }
      view.safe_join(address_chunks, '; '.html_safe)
    end
  end

  def present_locality
    return html_blank unless contact.city || contact.province || contact.country
    parts = []
    parts << html_tag(:span, class: 'locality') { contact.city } if contact.city
    parts << html_tag(:span, class: 'region') { contact.province } if contact.province
    parts << html_tag(:span, class: 'country-name') { contact.country } if contact.country
    parts << html_tag(:span, class: 'postal-code') { contact.postal } if contact.postal
    view.safe_join(parts, ', '.html_safe)
  end

  def present_twitter
    return html_blank unless contact.twitter.present?
    html_tag_with_newline(:span, class: 'twitter', title: 'Twitter') do
      html_tag(:span, class: 'label') { 'Twitter: '.html_safe } +
      view.link_to("@#{contact.twitter}", "https://twitter.com/#{contact.twitter}", class: 'url')
    end
  end

  def present_dates(separator=nil)
    dates = []
    if contact.confirmed_at?
      dates << "Established at #{contact.confirmed_at.to_datetime.to_s(:time_date)}.".html_safe
    end
    if contact.expires_at?
      if contact.expires_at > Time.now
        dates << "Expires at #{contact.expires_at.to_datetime.to_s(:time_date)}.".html_safe
      else
        dates << "Expired at #{contact.expires_at.to_datetime.to_s(:time_date)}.".html_safe
      end
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
      html_blank
    end
  end

  def present_actions
    result = html_blank
    if user.present?
      if contact.has_authority_for_user_to?(user, :can_update)
        result += view.link_to('Edit', ([:edit] + contact.items_for_path), class: 'action edit')
        result += newline
      end
      if contact.has_authority_for_user_to?(user, :can_delete)
        result += view.link_to('Delete',
          ([:delete] + contact.items_for_path), class: 'action delete',
          data: { confirm: 'Are you sure?' }, method: :delete
        )
        result += newline
      end
    end
    result
  end

protected

  def address_info_present?
    contact.address1.present? || contact.address2.present? || contact.city.present? ||
    contact.province.present? || contact.country.present?
  end

end
