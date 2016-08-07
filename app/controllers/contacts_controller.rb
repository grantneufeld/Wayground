require 'contact'
require 'candidate'
require 'person'

# RESTful controller for Contact records.
# Called as a sub-controller under other controllers (such as Candidates and People)
class ContactsController < ApplicationController
  before_action :set_user
  before_action :set_item
  before_action :set_contact, only: [:show, :edit, :update, :delete, :destroy]
  before_action :prep_new, only: [:new, :create]
  before_action :prep_edit, only: [:edit, :update]
  before_action :prep_delete, only: [:delete, :destroy]
  before_action :set_section

  def index
    page_metadata(title: "Contacts for #{@item.descriptor}")
    @contacts = @item.contacts.only_public
  end

  def show
    page_metadata(title: "Contact “#{@contact.descriptor}”")
  end

  def new; end

  def create
    if @contact.save
      redirect_to(@contact.items_for_path, notice: 'The contact has been saved.')
    else
      render action: 'new'
    end
  end

  def edit; end

  def update
    if @contact.update(contact_params)
      redirect_to(@contact.items_for_path, notice: 'The contact has been saved.')
    else
      render action: 'edit'
    end
  end

  def delete
    page_metadata(title: "Delete Contact “#{@contact.name}”")
  end

  def destroy
    @contact.destroy
    redirect_to @item.items_for_path
  end

  protected

  def set_user
    @user = current_user
  end

  def set_item
    @item = nil
    if params[:candidate_id]
      level = Level.from_param(params[:level_id]).first
      election = level.elections.from_param(params[:election_id]).first
      office = level.offices.from_param(params[:ballot_id]).first
      ballot = election.ballots.where(office_id: office.id).first
      @item = ballot.candidates.from_param(params[:candidate_id]).first
    end
    if !@item && params[:person_id]
      @item = Person.from_param(params[:person_id]).first
    end
    missing unless @item
  end

  def set_contact
    @contact = @item.contacts.find(params[:id])
    unless @contact.is_public? && @contact.authority_for_user_to?(@user, :can_view)
      unauthorized
    end
    missing unless @contact
  end

  def set_section
    @site_section = :contacts
  end

  def prep_new
    requires_authority(:can_create)
    page_metadata(title: 'New Contact')
    @contact = @item.contacts.build(contact_params)
  end

  def prep_edit
    requires_authority(:can_update)
    page_metadata(title: "Edit Contact “#{@contact.descriptor}”")
  end

  def prep_delete
    requires_authority(:can_delete)
  end

  def requires_authority(action)
    unless (
      (@contact && @contact.authority_for_user_to?(@user, action)) ||
      (!@contact && @item.authority_for_user_to?(@user, action)) ||
      (@user && @user.authority_for_area(Contact.authority_area, action))
    )
      unauthorized
    end
  end

  def contact_params
    params.fetch(:contact, {}).permit(
      :position, :is_public, :confirmed_at, :expires_at, :name, :organization,
      :email, :twitter, :url, :phone, :phone2, :fax,
      :address1, :address2, :city, :province, :country, :postal
    )
  end
end
