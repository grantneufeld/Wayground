# Storage of raw file data. Should only be accessed through the Document model.
class Datastore < ActiveRecord::Base
  attr_accessible :data
end
