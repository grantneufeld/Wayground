# Assign remote Sources and queue them for processing.
class SourcesController < ApplicationController
  include ActionView::Helpers::OutputSafetyHelper

  before_action :set_user
  before_action :set_source, except: %i(index new create)
  before_action :requires_view_authority, only: %i(index show)
  before_action :requires_create_authority, only: %i(new create)
  before_action :requires_update_authority, only: %i(edit update processor runprocessor)
  before_action :requires_delete_authority, only: %i(delete destroy)
  before_action :set_section
  before_action :set_new_source, only: %i(new create)

  def index
    page_metadata(title: 'Sources')
    @sources = Source.all
  end

  def show
    page_metadata(title: @source.name, description: @source.description)
  end

  def new; end

  def create
    if @source.save
      redirect_to @source
    else
      render action: 'new'
    end
  end

  def edit
    page_metadata(title: "Edit Source: #{@source.name}")
  end

  def update
    if @source.update(source_params)
      redirect_to @source
    else
      page_metadata(title: "Edit Source: #{@source.name}")
      render action: 'edit'
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
    page_metadata(title: "Processed Source: #{@source.name}")
    processor = @source.run_processor(@user, params[:approve] == 'all')
    flash.now.notice = safe_join(runprocessor_messages(processor), '<br />'.html_safe)
    @sourced_items = runprocessor_items(processor).map { |item| item.sourced_items.first }
    @sourced_items.compact!
    render template: 'sources/show'
  end

  protected

  def runprocessor_messages(processor)
    messages = ['Processing complete.']
    new_events_size = processor.new_events.size
    messages << "#{new_events_size} items were created." if new_events_size.positive?
    updated_events_size = processor.updated_events.size
    messages << "#{updated_events_size} items were updated." if updated_events_size.positive?
    skipped_ievents_size = processor.skipped_ievents.size
    messages << "#{skipped_ievents_size} items were skipped." if skipped_ievents_size.positive?
    messages
  end

  def runprocessor_items(processor)
    processor.new_events + processor.updated_events
  end

  def set_user
    @user = current_user
  end

  # Most of the actions for this controller receive the id of an Source as a parameter.
  def set_source
    @source = Source.find(params[:id])
  end

  # The actions for this controller require authorization.
  def requires_authority(action)
    source_allowed = @source && @source.authority_for_user_to?(@user, action)
    unless source_allowed || (@user && @user.authority_for_area('Source', action))
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
    @source = Source.new(source_params)
  end

  def source_params
    params.fetch(:source, {}).permit(
      :description, :method, :options, :post_args, :processor, :refresh_after_at, :title, :url
    )
  end
end
