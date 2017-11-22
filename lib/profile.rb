class Profile

  def initialize(username)
    @username = username
  end

  def article_urls
    success? ? urls : []
  end

  private

  def response
    @response ||= Net::HTTP.get_response(profile_uri)
  end

  def success?
    response.is_a?(Net::HTTPSuccess)
  end

  def profile_uri
    URI("https://www.viget.com/about/team/#{@username}")
  end

  def urls
    doc = Nokogiri::HTML(response.body)

    doc.css(".author-articles li a.author-articles__title").map do |a|
      a['href']
    end
  end

end