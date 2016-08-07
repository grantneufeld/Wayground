require 'office'
require 'level'

# RESTful controller for Office records.
# Called as a sub-controller under LevelsController
class OfficesController < ApplicationController
  before_action :set_user
  before_action :set_level
  before_action :set_office, only: %i(show edit update delete destroy)
  before_action :prep_new, only: %i(new create)
  before_action :prep_edit, only: %i(edit update)
  before_action :prep_delete, only: %i(delete destroy)
  before_action :set_section

  def index
    page_metadata(title: 'Offices')
    @offices = @level.offices
  end

  def show
    page_metadata(title: "Office “#{@office.name}”")
  end

  def new; end

  def create
    if @office.save
      redirect_to([@level, @office], notice: 'The office has been saved.')
    else
      render action: 'new'
    end
  end

  def edit; end

  def update
    if @office.update(office_params)
      redirect_to([@level, @office], notice: 'The office has been saved.')
    else
      render action: 'edit'
    end
  end

  def delete
    page_metadata(title: "Delete Office “#{@office.name}”")
  end

  def destroy
    @office.destroy
    redirect_to level_offices_url(@level)
  end

  protected

  def set_user
    @user = current_user
  end

  def set_level
    @level = Level.from_param(params[:level_id]).first
    missing unless @level
  end

  def set_office
    @office = @level.offices.from_param(params[:id]).first
    missing unless @office
  end

  def set_section
    @site_section = :offices
  end

  def prep_new
    requires_authority(:can_create)
    page_metadata(title: 'New Office')
    @office = @level.offices.build(office_params)
    @office.previous = @level.offices.from_param(params[:previous_id]).first if params[:previous_id]
  end

  def prep_edit
    requires_authority(:can_update)
    page_metadata(title: "Edit Office “#{@office.name}”")
  end

  def prep_delete
    requires_authority(:can_delete)
  end

  def requires_authority(action)
    authority = @office && @office.authority_for_user_to?(@user, action)
    unauthorized unless authority || (@user && @user.authority_for_area(Office.authority_area, action))
  end

  def office_params
    params.fetch(:office, {}).permit(
      :filename, :name, :title, :established_on, :ended_on, :description, :url
    )
  end
end
