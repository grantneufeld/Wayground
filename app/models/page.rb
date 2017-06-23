# Web pages.
class Page < ApplicationRecord
  acts_as_authority_controlled authority_area: 'Content'
  attr_accessor :editor, :edit_comment

  belongs_to :parent, class_name: 'Page'
  has_many :pages, as: :parent
  has_one :path, as: :item, validate: true, dependent: :destroy
  has_many :versions, as: :item, dependent: :delete_all
  has_many :external_links, as: :item

  before_create :generate_path
  before_update :update_path
  after_save :add_version

  validates(
    :filename,
    length: { within: 1..127 },
    format: {
      with: %r{\A(/|([\w_~\+\-]+)(\.[\w_]+)?/?)\z},
      message:
        'must only be letters, numbers, dashes and underscores, with an optional extension;' \
        ' e.g., “a-filename_1.txt”'
    }
  )
  validates :title, presence: true

  def generate_path
    return if path
    self.path = Path.new(sitepath: calculate_sitepath)
    path.item = self
  end

  def update_path
    if !path
      generate_path
    else
      path.update!(sitepath: calculate_sitepath)
    end
  end

  def calculate_sitepath
    "#{(parent ? parent.sitepath : '')}/#{filename}".gsub(%r{//+}, '/')
  end

  # Add a Version based on the current state of this item
  def add_version
    versions.create!(
      user: editor, edited_at: updated_at, edit_comment: edit_comment,
      filename: filename, title: title,
      values: { description: description, content: content }
    )
  end

  def breadcrumbs
    if parent
      parent.breadcrumbs << { text: parent.title, url: parent.sitepath }
    else
      []
    end
  end

  delegate :sitepath, to: :path
end
