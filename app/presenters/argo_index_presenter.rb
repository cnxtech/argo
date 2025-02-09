# frozen_string_literal: true

class ArgoIndexPresenter < Blacklight::IndexPresenter
  include DorObjectHelper

  ##
  # Override default Blacklight presenter method, to provide citation when
  # rendering the index title label. Because of some strangeness with the
  # #render_thumbnail_tag method from Blacklight, we need to check if its not
  # the default id and if so call super.
  # @see https://github.com/projectblacklight/blacklight/blob/c04e80b690bdbd71482d3d91cc168d194d0b6a51/app/presenters/blacklight/document_presenter.rb#L110
  def label(field, _opts = {})
    if field != @document.id
      super
    else
      render_citation(@document)
    end
  end
end
