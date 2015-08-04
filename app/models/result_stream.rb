require 'base64'

class ResultStream < ActiveRecord::Base
  def to_show_hash
    return {
      fd: fd,
      buffer: Base64.strict_encode64(buffer),
    }
  end
end
