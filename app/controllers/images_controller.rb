require 'image'

# Access Images.
class ImagesController < ApplicationController
  before_action :set_user
  before_action :set_image, except: %i(index new create)
  before_action :prep_new, only: %i(new create)
  before_action :prep_edit, only: %i(edit update)
  before_action :prep_delete, only: %i(delete destroy)
  before_action :set_section

  def index
    page_metadata(title: 'Images')
    @images = Image.all
  end

  def show
    title = 'Image' + (@image.title? ? " “#{@image.title}”" : '')
    page_metadata(title: title, description: @image.description)
  end

  def new
  end

  def create
    if @image.save
      redirect_to(@image, notice: 'The image has been saved.')
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @image.update(image_params)
      redirect_to(@image, notice: 'The image has been saved.')
    else
      render action: 'edit'
    end
  end

  def delete
    page_metadata(title: "Delete Image “#{@image.title}”")
  end

  def destroy
    @image.destroy
    redirect_to images_url
  end

  protected

  def set_user
    @user = current_user
  end

  def set_image
    @image = Image.find(params[:id])
  end

  def set_section
    @site_section = :images
  end

  def prep_new
    requires_authority(:can_create)
    page_metadata(title: 'New Image')
    @image = Image.new(image_params)
  end

  def prep_edit
    requires_authority(:can_update)
    page_metadata(title: "Edit Image “#{@image.title}”")
  end

  def prep_delete
    requires_authority(:can_delete)
  end

  def requires_authority(action)
    image_allowed = @image && @image.has_authority_for_user_to?(@user, action)
    unless image_allowed || (@user && @user.authority_for_area(Image.authority_area, action))
      raise Wayground::AccessDenied
    end
  end

  def image_params
    params.fetch(:image, {}).permit(
      :title, :alt_text, :description, :attribution, :attribution_url,
      :license_url,
      image_variants_attributes: %i(height width format style url)
    )
  end
end
