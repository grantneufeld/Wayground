require 'url_cleaner'

# Utility class that cleans up text.
class TextCleaner
  # Remove extraneous characters from a string.
  # Leading and trailing whitespace on lines.
  # White-space runs.
  def self.clean(string)
    return nil unless string
    # clear trailing whitespace,
    string.gsub(/\r\n?/, "\n").gsub(/[ \t]+$/, '').
      # leading whitespace,
      gsub(/^[ \t]+/, '').
      # whitespace runs,
      gsub(/([ \t])[ \t]+/, '\1').
      # excessive blank lines.
      gsub(/(\n\n)\n+/, '\1')
  end
end
