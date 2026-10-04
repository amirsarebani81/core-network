require 'asciidoctor-multipage'

class MultipageHtml5Converter
  alias_method :cn_pruned_outline, :convert_outline

  def convert_outline(node, opts = {})
    doc = node.document
    return cn_pruned_outline(node, opts) unless node.id == doc.attr('docname')

    opts[:page_id] = node.id
    root_file = %(#{doc.attr('docname')}#{doc.attr('outfilesuffix')})
    root = %(<span class="toc-root toc-current"><a href="#{root_file}">#{doc.doctitle}</a></span>)
    %(<p>#{root}</p>#{generate_outline(doc.mp_root.full_outline, opts)})
  end
end
