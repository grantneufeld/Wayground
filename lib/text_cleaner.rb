require 'url_cleaner'

# Utility class that cleans up text.
class TextCleaner
  # Remove extraneous characters from a string.
  # Leading and trailing whitespace on lines.
  # White-space runs.
  def self.clean(string)
    return nil if string.nil?
    # clear trailing whitespace, leading whitespace, whitespace runs, excessive blank lines
    string.gsub(/\r\n?/, "\n").gsub(/[ \t]+$/, '').gsub(/^[ \t]+/, '').gsub(/([ \t])[ \t]+/, '\1').gsub(/(\n\n)\n+/, '\1')
  end
end