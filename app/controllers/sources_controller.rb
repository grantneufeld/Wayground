# Assign remote Sources and queue them for processing.
class SourcesController < ApplicationController
  before_action :set_user
  before_action :set_source, except: [:index, :new, :create]
  before_action :requires_view_authority, only: [:index, :show]
  before_action :requires_create_authority, only: [:new, :create]
  before_action :requires_update_authority, only: [:edit, :update, :processor, :runprocessor]
  before_action :requires_delete_authority, only: [:delete, :destroy]
  before_action :set_section
  before_action :set_new_source, only: [:new, :create]

  def index
    page_metadata(title: 'Sources')
    @sources = Source.all
  end

  def show
    page_metadata(title: @source.name, description: @source.description)
  end

  def new
  end

  def create
    if @source.save
      redirect_to @source
    else
      render :action => 'new'
    end
  end

  def edit
    page_metadata(title: "Edit Source: #{@source.name}")
  end

  def update
    if @source.update(params[:source])
      redirect_to @source
    else
      page_metadata(title: "Edit Source: #{@source.name}")
      render :action => 'edit'
    end
  end

  def delete
    page_metadata(title: "Delete Source: #{@source.name}")
  end

  def destroy
    @source.destroy
    redirect_to(sources_url)
  end

  def processor
    page_metadata(title: "Process Source: #{@source.name}")
  end

  def runprocessor
    page_metadata(title: "Process Source: #{@source.name}")
    processor = @source.run_processor(@user, params[:approve] == 'all')
    msgs = ['Processing complete.']
    msgs << "#{processor.new_events.size} items were created." if processor.new_events.size > 0
    msgs << "#{processor.updated_events.size} items were updated." if processor.updated_events.size > 0
    msgs << "#{processor.skipped_ievents.size} items were skipped." if processor.skipped_ievents.size > 0
    redirect_to @source, :notice => msgs.join('<br />').html_safe
  end

  protected

  def set_user
    @user = current_user
  end

  # Most of the actions for this controller receive the id of an Source as a parameter.
  def set_source
    @source = Source.find(params[:id])
  end

  # The actions for this controller require authorization.
  def requires_authority(action)
    unless (
      (@source && @source.has_authority_for_user_to?(@user, action)) ||
      (@user && @user.has_authority_for_area('Source', action))
    )
      raise Wayground::AccessDenied
    end
  end
  def requires_view_authority
    requires_authority(:can_view)
  end
  def requires_create_authority
    requires_authority(:can_create)
  end
  def requires_update_authority
    requires_authority(:can_update)
  end
  def requires_delete_authority
    requires_authority(:can_delete)
  end

  def set_section
    @site_section = :sources
  end

  def set_new_source
    page_metadata(title: 'New Source')
    @source = Source.new(params[:source])
  end

end
