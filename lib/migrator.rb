class Migrator

  class Migration
    def initialize(connection, path)
      @connection, @path = connection, path
    end

    def execute
      unless migration_run?
        @connection.exec(sql)
        record_migration
      end
    end

    private

    def migration_run?
      count = 0

      result = @connection.exec_params(
        "SELECT COUNT(*) AS count FROM migrations WHERE version = $1",
        [version]
      )

      count = result[0]["count"].to_i
      result.clear()

      count == 1
    end

    def sql
      File.read(@path)
    end

    def record_migration
      @connection.exec_params(
        "INSERT INTO migrations (version) VALUES ($1)", 
        [version.to_s]
      )
    end

    def version
      matches = File.basename(@path).match(/\A(\d+)/)
      matches[1].to_i
    end
  end

  def initialize(connection, migrations_path)
    @connection      = connection
    @migrations_path = migrations_path
  end

  def migrate
    create_migrations_table
    migrations.map(&:execute)
  end

  private

  def connection
    @connection.tap do |conn|
      conn.set_notice_receiver {|r| } # ignore notices
    end
  end

  def files
    Dir.glob(@migrations_path.expand_path.join("*.sql")).sort
  end

  def migrations
    files.map {|f| Migration.new(connection, f) }
  end

  def create_migrations_table
    connection.exec("
      CREATE TABLE IF NOT EXISTS migrations (
        version INTEGER NOT NULL UNIQUE
      );
    ")
  end
end