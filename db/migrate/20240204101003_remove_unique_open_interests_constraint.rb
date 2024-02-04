class RemoveUniqueOpenInterestsConstraint < ActiveRecord::Migration[6.0] # Make sure the version matches your Rails version
  def up
    # Use execute to run a raw SQL statement to remove the unique constraint
    execute <<-SQL
      ALTER TABLE open_interests DROP CONSTRAINT IF EXISTS unique_open_interests;
    SQL
  end

  def down
    # Optionally, recreate the unique constraint if you need to rollback this migration
    execute <<-SQL
      ALTER TABLE open_interests ADD CONSTRAINT unique_open_interests UNIQUE (symbol, day, interval, content);
    SQL
  end
end
