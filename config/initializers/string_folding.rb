# encoding: utf-8

class String

  # Apply “folding” to a string, inserting a character sequence every number of characters.
  # @fold_length[Fixnum] - The number of characters from the string per fold.
  # @firstline_pre[Fixnum] - The number of characters to subtract from the first line (used to allow for a line prefix external to the string).
  # @fold_string[String] - The string to insert at each fold point.
  # @fold_string_affect_size[Fixnum] - The number of characters added by each fold that affect the count.
  def fold!(fold_length=75, firstline_pre=0, fold_string="\r\n ", fold_string_affect_size=1)
    if (self.size + firstline_pre) > fold_length
      lines = []
      # The first line does not have a fold character on it, so treat it separately from the rest.
      lines << self.slice!(0,(fold_length - firstline_pre))
      # Split the string into fold-sized chunks.
      while self.size > (fold_length - fold_string_affect_size) do
        lines << self.slice!(0,(fold_length - fold_string_affect_size))
      end
      if self.size > 0
        # There is a last bit left over from folding - add it as the last line.
        lines << self[0..-1]
      end
      # Merge the fold-split string chunks using the fold_string to separate them.
      self.clear
      self << lines.join(fold_string)
    else
      # This String is shorter than the fold_length, so no folding needed.
      self
    end
  end

  # Encode restricted characters for icalendar.
  def icalendar_encoding
    self.
      # backslash-escape backslash, comma, and semi-colon
      gsub('\\', '\\\\\\').gsub(',', "\\,").gsub(';', "\\;").
      # convert linebreaks to the string backslash-n ('\n')
      gsub(/(\r\n?|\n)/, "\\n").
      # convert double-quote to fancy-quotes to avoid the restriction on the '"' char
      gsub(/\"([^\"]*)\"/, '“\1”').gsub(/\"/, '“')
  end
end
