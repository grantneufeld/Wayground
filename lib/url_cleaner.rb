# encoding: utf-8

# Utility class that cleans up URLs.
# Removes extraneous parameters or hashes.
# Forces https where supported.
# Strips surrounding whitespace.
class UrlCleaner
  URL_MAP = /\A[ \t\r\n]*(?<protocol>[a-z\-]+)(?<delimiter>\:\/*)(?<user>[A-Za-z0-9_\+\-]+@)?(?<domain>[a-z0-9\-\.]+)(?<port>\:[0-9]+)?(?<path>[^\?]*)(?<params>\?.*)?[ \t\r\n]*\z/

  # Cleanup and return an URL string.
  # expects a valid URL as a String.
  def self.clean(url)
    return url if url.blank?
    url_parts = url.match URL_MAP
    return url unless url_parts
    case url_parts[:domain]
    when /facebook.com$/
      clean_facebook(url_parts)
    when /twitter.com$/
      clean_twitter(url_parts)
    else
      url
    end
  end

  # Handle URLs for Facebook.
  # Strip down event URLs to minimum, and force https.
  def self.clean_facebook(url_parts)
    protocol = url_parts[:protocol]
    protocol = 'https' if protocol == 'http'
    path = url_parts[:path]
    params = url_parts[:params]
    path_match = path.match(/^(?<eventpath>\/events\/[0-9]+)/)
    if path_match
      # strip the path and params down to just the event
      path = "#{path_match[:eventpath]}/"
      params = ''
    end
    "#{protocol}#{url_parts[:delimiter]}#{url_parts[:domain]}#{path}#{params}"
  end

  # For Twitter URLs, strip hash-bang and force https.
  def self.clean_twitter(url_parts)
    path = url_parts[:path]
    path_match = path.match(/^\/\#!(?<hashbanged>.+)/)
    if path_match
      # strip the slash-hash-bang from the path
      path = path_match[:hashbanged]
    end
    "https#{url_parts[:delimiter]}#{url_parts[:domain]}#{path}#{url_parts[:params]}"
  end

end