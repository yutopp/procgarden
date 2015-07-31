class Ticket < ActiveRecord::Base
  belongs_to :entry

  has_one :compile, :class_name => "ExecTask", :foreign_key => "compile_ticket_id"
  has_one :link, :class_name => "ExecTask", :foreign_key => "link_ticket_id"
  has_many :execs, :class_name => "ExecTask", :foreign_key => "exec_ticket_id"
end
