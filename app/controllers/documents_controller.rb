# encoding: utf-8

class DocumentsController < ApplicationController
  before_filter :set_document, :except => [:index, :new, :create]
  before_filter :requires_view_authority, :only => [:download, :show]
  before_filter :requires_create_authority, :only => [:new, :create]
  before_filter :requires_update_authority, :only => [:edit, :update]
  before_filter :requires_delete_authority, :only => [:delete, :destroy]
  before_filter :set_section

  # GET /download/:id/:filename
  def download
    @document.assign_headers(response)
    render :text => @document.data #, :content_type => @document.content_type
  end

  # GET /documents
  # GET /documents.xml
  def index
    @documents = Document.find_for_user(current_user)
    @page_title = 'Documents Index'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @documents }
    end
  end

  # GET /documents/1
  # GET /documents/1.xml
  def show
    @page_title = "Document “#{@document.filename}”"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @document }
    end
  end

  # GET /documents/new
  # GET /documents/new.xml
  def new
    @document = Document.new
    @page_title = 'New Document'

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @document }
    end
  end

  # POST /documents
  # POST /documents.xml
  def create
    @document = Document.new(params[:document])
    @document.user = current_user

    respond_to do |format|
      if @document.save
        format.html { redirect_to(@document, :notice => 'Document was successfully created.') }
        format.xml  { render :xml => @document, :status => :created, :location => @document }
      else
        @page_title = 'New Document'
        format.html { render :action => "new" }
        format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /documents/1/edit
  def edit
    @page_title = "Edit Document #{@document.filename}"
  end

  # PUT /documents/1
  # PUT /documents/1.xml
  def update
    respond_to do |format|
      if @document.update_attributes(params[:document])
        format.html { redirect_to(@document, :notice => 'Document was successfully updated.') }
        format.xml  { head :ok }
      else
        @page_title = "Edit Document #{@document.filename}"
        format.html { render :action => "edit" }
        format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /documents/1/delete
  def delete
    @page_title = "Delete Document #{@document.filename}"
  end

  # DELETE /documents/1
  # DELETE /documents/1.xml
  def destroy
    @document.destroy

    respond_to do |format|
      format.html { redirect_to(documents_url) }
      format.xml  { head :ok }
    end
  end

  protected

  # The actions for this controller, other than viewing, require authorization.
  def requires_authority(action)
    unless (
      (@document && @document.has_authority_for_user_to?(current_user, action)) ||
      (current_user && current_user.has_authority_for_area(Document.authority_area, action))
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

  # Most of the actions for this controller receive the id of an Authority as a parameter.
  def set_document
    @document = Document.find(params[:id])
  end

  def set_section
    @site_section = 'Documents'
  end
end
