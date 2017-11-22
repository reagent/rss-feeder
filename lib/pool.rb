class Pool

  def self.create_from(database_url)
    new(database_url, 10).native
  end

  def initialize(database_url, size)
    @database_url = database_url
    @size         = size
  end

  def native
    Pond.new(maximum_size: @size) do
      PG::Connection.open({
        host:     uri.host,
        user:     uri.user,
        password: uri.password,
        port:     uri.port || 5432,
        dbname:   uri.path[1..-1]
      })
    end
  end

  private

  def uri
    @uri ||= URI(@database_url)
  end

end