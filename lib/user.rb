class User
  class << self
    attr_accessor :connection
  end

  def self.to_update(threshold)
    sql = <<-SQL
      SELECT   id, username
      FROM     users
      WHERE    last_polled_at <= $1
      OR       last_polled_at IS NULL
      ORDER BY last_polled_at NULLS FIRST
    SQL

    results = @connection.exec_params(sql, [threshold])

    users = results.map do |result|
      new(result['id'].to_i, result['username'])
    end

    results.clear

    users
  end

  attr_reader :id, :username

  def initialize(id, username)
    @id       = id
    @username = username
  end

  def article_urls
    @article_urls ||= Profile.new(username).article_urls
  end

  def update_polled_at(timestamp)
    self.class.connection.exec(
      "UPDATE users SET last_polled_at = $1 WHERE id = $2",
      [timestamp, id]
    )
  end

end