require 'image'

# Access Images.
class ImagesController < ApplicationController
  before_action :set_user
  before_action :set_image, except: [:index, :new, :create]
  before_action :prep_new, only: [:new, :create]
  before_action :prep_edit, only: [:edit, :update]
  before_action :prep_delete, only: [:delete, :destroy]
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
    if @image.update(params[:image])
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
    @image = Image.new(params[:image])
  end

  def prep_edit
    requires_authority(:can_update)
    page_metadata(title: "Edit Image “#{@image.title}”")
  end

  def prep_delete
    requires_authority(:can_delete)
  end

  def requires_authority(action)
    unless (
      (@image && @image.has_authority_for_user_to?(@user, action)) ||
      (@user && @user.has_authority_for_area(Image.authority_area, action))
    )
      raise Wayground::AccessDenied
    end
  end

end
