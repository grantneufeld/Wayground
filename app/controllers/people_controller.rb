require 'person'

# Access to Person records.
class PeopleController < ApplicationController
  before_action :set_user
  before_action :set_person, only: %i(show edit update delete destroy)
  before_action :prep_new, only: %i(new create)
  before_action :prep_edit, only: %i(edit update)
  before_action :prep_delete, only: %i(delete destroy)
  before_action :set_section

  def index
    page_metadata(title: 'People')
    @people = Person.order(:fullname).all
  end

  def show
    page_metadata(title: @person.fullname)
  end

  def new; end

  def create
    if @person.save
      redirect_to(@person, notice: 'The person has been saved.')
    else
      render action: 'new'
    end
  end

  def edit; end

  def update
    if @person.update(person_params)
      redirect_to(@person, notice: 'The person has been saved.')
    else
      render action: 'edit'
    end
  end

  def delete
    page_metadata(title: "Delete Person “#{@person.fullname}”")
  end

  def destroy
    @person.destroy
    redirect_to people_url
  end

  protected

  def set_user
    @user = current_user
  end

  def set_person
    @person = Person.from_param(params[:id]).first
    missing unless @person
  end

  def set_section
    @site_section = :people
  end

  def prep_new
    requires_authority(:can_create)
    page_metadata(title: 'New Person')
    @person = Person.new(person_params)
  end

  def prep_edit
    requires_authority(:can_update)
    page_metadata(title: "Edit Person “#{@person.fullname}”")
  end

  def prep_delete
    requires_authority(:can_delete)
  end

  def requires_authority(action)
    authority = @person && @person.authority_for_user_to?(@user, action)
    unauthorized unless authority || (@user && @user.authority_for_area(Person.authority_area, action))
  end

  def person_params
    params.fetch(:person, {}).permit(:filename, :fullname, :aliases_string, :bio)
  end
end