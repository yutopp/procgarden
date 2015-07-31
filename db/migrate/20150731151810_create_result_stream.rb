class CreateResultStream < ActiveRecord::Migration
  def change
    create_table :result_streams do |t|
      t.belongs_to :exec_task

      t.integer :fd, null: false
      t.binary :buffer, null: false, :limit => 10.megabyte

      t.timestamps null: false
    end
  end
end
