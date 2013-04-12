#------------------------------------------------------------------------------
# Horizontal Whitespace
#------------------------------------------------------------------------------
# allow_hard_tabs         True to let hard tabs be considered a single space.
#                         Default:      false
#
# allow_trailing_line_spaces
#                         True to skip detecting extra spaces at the ends of
#                         lines.
#                         Default:      false
#
# indentation_spaces      The number of spaces to consider a proper indent.
#                         Default:      2
#
# max_line_length         The maximum number of characters in a line before
#                         tailor complains.
#                         Default:      80
# spaces_after_comma      Number of spaces to expect after a comma.
#                         Default:      1
#
# spaces_before_comma     Number of spaces to expect before a comma.
#                         Default:      0
#
# spaces_after_lbrace     The number of spaces to expect after an lbrace ('{').
#                         Default:      1
#
# spaces_before_lbrace    The number of spaces to expect before an lbrace ('{').
#                         Default:      1
#
# spaces_before_rbrace    The number of spaces to expect before an rbrace ('}').
#                         Default:      1
#
# spaces_in_empty_braces  The number of spaces to expect between braces when
#                         there's nothing in the braces (i.e. {}).
#                         Default:      0
#
# spaces_after_lbracket   The number of spaces to expect after an
#                         lbracket ('[').
#                         Default:      0
#
# spaces_before_rbracket  The number of spaces to expect before an
#                         rbracket (']').
#                         Default:      0
#
# spaces_after_lparen     The number of spaces to expect after an
#                         lparen ('(').
#                         Default:      0
#
# spaces_before_rparen    The number of spaces to expect before an
#                         rbracket (')').
#                         Default:      0
#
#------------------------------------------------------------------------------
# Naming
#------------------------------------------------------------------------------
# allow_camel_case_methods
#                         Setting to true skips detection of camel-case method
#                         names (i.e. def myMethod).
#                         Default:      false
#
# allow_screaming_snake_case_classes
#                         Setting to true skips detection of screaming
#                         snake-case class names (i.e. My_Class).
#                         Default:      false
#
#------------------------------------------------------------------------------
# Vertical Whitespace
#------------------------------------------------------------------------------
# max_code_lines_in_class The number of lines of code in a class to allow before
#                         tailor will warn you.
#                         Default:      300
#
# max_code_lines_in_method
#                         The number of lines of code in a method to allow
#                         before tailor will warn you.
#                         Default:      30
#
# trailing_newlines       The number of newlines that should be at the end of
#                         the file.
#                         Default:      1
#
Tailor.config do |config|
  config.formatters 'text', 'yaml'
  #config.file_set 'lib/**/*.rb' do |style|
  #  style.allow_camel_case_methods false, level: :error
  #  style.allow_hard_tabs false, level: :error
  #  style.allow_screaming_snake_case_classes false, level: :error
  #  style.allow_trailing_line_spaces false, level: :error
  #  style.allow_invalid_ruby false, level: :warn
  #  style.indentation_spaces 2, level: :error
  #  style.max_code_lines_in_class 300, level: :error
  #  style.max_code_lines_in_method 30, level: :error
  #  style.max_line_length 80, level: :error
  #  style.spaces_after_comma 1, level: :error
  #  style.spaces_after_lbrace 1, level: :error
  #  style.spaces_after_lbracket 0, level: :error
  #  style.spaces_after_lparen 0, level: :error
  #  style.spaces_before_comma 0, level: :error
  #  style.spaces_before_lbrace 1, level: :error
  #  style.spaces_before_rbrace 1, level: :error
  #  style.spaces_before_rbracket 0, level: :error
  #  style.spaces_before_rparen 0, level: :error
  #  style.spaces_in_empty_braces 0, level: :error
  #  style.trailing_newlines 1, level: :error
  #end
end
