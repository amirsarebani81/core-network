require 'cgi'

dir = ARGV.fetch(0) { abort 'usage: postprocess-html.rb <html-dir>' }
main_path = File.join(dir, 'main.html')
abort "#{main_path} not found" unless File.exist?(main_path)

def strip_tags(html)
  html.gsub(/<[^>]+>/, '').gsub(/\s+/, ' ').strip
end

def attr_escape(text)
  CGI.escapeHTML(CGI.unescapeHTML(text))
end

def numbered_page_list(html)
  toc = html[%r{<div id="toc".*?<div id="content"}m] || ''
  html.sub(%r{<div class="ulist">\s*<ul>(.*?)</ul>}m) do |whole|
    items = $1
    links = items.scan(%r{<li>\s*<p><a href="([^"#]+\.html)">(.*?)</a></p>\s*</li>}m)
    next whole if links.empty? || items.scan(/<li>/).size != links.size

    entries = links.map do |(href, title)|
      number = strip_tags(toc[%r{<a href="#{Regexp.escape(href)}">(.*?)</a>}m, 1].to_s)[/\A(\d+(?:\.\d+)*)\./, 1]
      prefix = number ? %(<span class="cn-num">#{number}</span> ) : ''
      %(<li>\n<p>#{prefix}<a href="#{href}">#{title}</a></p>\n</li>)
    end
    %(<div class="ulist cn-pagelist">\n<ul>\n#{entries.join("\n")}\n</ul>)
  end
end

def landing_toc(html)
  outline = html[%r{<div id="toc" class="toc2">.*?(<ul class="sectlevel1">.*</ul>)\s*</div>\s*</div>\s*<div id="content"}m, 1]
  abort 'main.html: no table of contents found' unless outline
  html = html.sub(%r{<div id="toc" class="toc2">.*?(?=</div>\s*<div id="content")}m, '')
  html = html.sub(/<body id="main" class="([^"]*)"/) do
    %(<body id="main" class="#{$1.split.reject { |c| c.start_with?('toc') }.join(' ')}")
  end
  html.sub(%r{<div class="ulist">\s*<ul>.*?</ul>\s*</div>}m) do
    %(<nav class="cn-book-toc" aria-labelledby="cn-book-toc-title">\n) +
      %(<div id="cn-book-toc-title" class="cn-book-toc-title">Table of Contents</div>\n#{outline}\n</nav>)
  end
end

Dir.glob(File.join(dir, '*.html')).sort.each do |path|
  html = File.read(path)
  next if html.include?('<meta property="og:site_name"') # already processed
  is_main = File.basename(path) == 'main.html'
  book_title = html[%r{<title>(.*?)</title>}m, 1].to_s.strip
  description = html[/<meta name="description" content="([^"]*)"/, 1].to_s

  if is_main
    page_title = book_title
  else
    heading_re = %r{(<div id="content">.*?<h([23]) id="[^"]*")([^>]*>)(.*?)(</h\2>)}m
    match = html.match(heading_re)
    abort "#{path}: no page heading found" unless match
    heading = strip_tags(match[4]).sub(/\A[\d.]+\s+/, '')
    page_title = "#{heading} | #{book_title}"
    html.sub!(heading_re) { "#{$1} data-pagefind-meta=\"title\"#{$3}#{$4}#{$5}" }
    html.sub!(%r{<title>.*?</title>}m) { "<title>#{page_title}</title>" }
    html.sub!('<div id="content">', '<div id="content" data-pagefind-body>')
    html.sub!('<div class="paragraph nav-footer">', '<div class="paragraph nav-footer" data-pagefind-ignore>')
  end

  og = [
    %(<meta property="og:type" content="#{is_main ? 'website' : 'article'}">),
    %(<meta property="og:site_name" content="#{attr_escape(book_title)}">),
    %(<meta property="og:title" content="#{attr_escape(page_title)}">),
  ]
  og << %(<meta property="og:description" content="#{description}">) unless description.empty?
  html.sub!('type="image/svg" href=', 'type="image/svg+xml" href=')
  html.sub!('</head>') { og.join("\n") + "\n</head>" }

  html = is_main ? landing_toc(html) : numbered_page_list(html)
  File.write(path, html)
end
