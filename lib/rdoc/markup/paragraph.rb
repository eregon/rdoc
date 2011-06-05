##
# A Paragraph of text

class RDoc::Markup::Paragraph < RDoc::Markup::Raw

  ##
  # The optional indent in number of spaces

  attr_accessor :indent

  ##
  # Calls #accept_paragraph on +visitor+

  def accept visitor
    visitor.accept_paragraph self
  end

end

