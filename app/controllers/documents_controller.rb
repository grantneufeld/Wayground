# Access Documents.
class DocumentsController < ApplicationController
  before_action :set_document, except: %i[index new create]
  before_action :requires_view_authority, only: %i[download show]
  before_action :requires_create_authority, only: %i[new create]
  before_action :requires_update_authority, only: %i[edit update]
  before_action :requires_delete_authority, only: %i[delete destroy]
  before_action :set_section

  def download
    @document.assign_headers(response)
    render body: @document.data
  end

  def index
    @documents = paginate(Document.for_user(current_user))
    page_metadata(title: 'Documents Index')
  end

  def show
    page_metadata(title: "Document “#{@document.filename}”", description: @document.description)
  end

  def new
    @document = Document.new
    page_metadata(title: 'New Document')
  end

  def create
    @document = Document.new(document_params)
    @document.user = current_user

    if @document.save
      redirect_to(@document, notice: 'Document was successfully created.')
    else
      page_metadata(title: 'New Document')
      render action: 'new'
    end
  end

  def edit
    page_metadata(title: "Edit Document #{@document.filename}")
  end

  def update
    if @document.update(document_params)
      redirect_to(@document, notice: 'Document was successfully updated.')
    else
      page_metadata(title: "Edit Document #{@document.filename}")
      render action: 'edit'
    end
  end

  def delete
    page_metadata(title: "Delete Document #{@document.filename}")
  end

  def destroy
    @document.destroy
    redirect_to(documents_url)
  end

  protected

  # The actions for this controller, other than viewing, require authorization.
  def requires_authority(action)
    user = current_user
    document_allowed = @document && @document.authority_for_user_to?(user, action)
    can_do = document_allowed || (user && user.authority_for_area(Document.authority_area, action))
    raise Wayground::AccessDenied unless can_do
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

  # Most of the actions for this controller receive the id of an Authority as a parameter.
  def set_document
    @document = Document.find(params[:id])
  end

  def set_section
    @site_section = :documents
  end

  def document_params
    params.fetch(:document, {}).permit(:file, :custom_filename, :description, :is_authority_controlled, :data)
  end
end
