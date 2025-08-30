class CreateFollows < ActiveRecord::Migration[8.0]
  def change
    create_table :follows do |t|
      t.bigint :follower_id
      t.bigint :following_id

      t.timestamps
    end

    add_index :follows, :follower_id
    add_index :follows, :following_id
    add_index :follows, [:follower_id, :following_id], unique: true
  end
end
