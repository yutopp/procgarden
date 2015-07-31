class Entry < ActiveRecord::Base
  VisibilityPublic = 0
  VisibilityProtected = 1
  VisibilityPrivate = 2

  belongs_to :user

  has_many :source_codes, autosave: true
  validates_associated :source_codes
  has_many :tickets, autosave: true
  validates_associated :tickets

  #has_many :tags
  #has_many :language_name_tags
end
