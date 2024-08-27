require 'markly'
require 'prawn'
require 'yaml'
require 'prawn/table'
require 'erb'
module Utils
  class Md2Pdf
    DEFAULT_STYLE = {
      h1: {
        size: 22,
        color: '000000',
        align: :center
      },
      h2: {
        size: 20,
        color: '000000',
        align: :left
      },
      h3: {
        size: 18,
        color: '000000',
        align: :left
      },
      h4: {
        size: 16,
        color: '000000',
        align: :left
      },
      h5: {
        size: 14,
        color: '000000',
        align: :left
      },
      p: {
        size: 12,
        color: '000000'
      },
      list: {
        indent: 20
      },
      list_item: {
        size: 12,
        color: '000000',
        bullet: '•'
      },
      table: {
        size: 12,
        color: '000000',
        colors: %w[ffffff f0f0f0],
        position: :left
      },
      image: {
        size: 12,
        color: '000000'
      }
    }.freeze

    def call(hcert_data:, qrcode:, hcert:)
      file = ERB.new(File.read('app/utils/euvabeco_hr.md.erb')).result(binding)
      _, fm, md = file.match(/---\s*\n(.*?)\n---\s*\n(.*)/m).to_a
      front_matter = YAML.safe_load(fm, symbolize_names: true)
      @computed_style =
        if front_matter[:style]
          front_matter[:style]
            .keys
            .each_with_object(DEFAULT_STYLE.dup) do |key, hash|
              hash[key] = DEFAULT_STYLE[key].merge(front_matter[:style][key])
            end
        else
          DEFAULT_STYLE
        end
      document = Markly.parse(md, extensions: %i[table])

      info = { title: front_matter[:title], author: 'Syadem', data: front_matter[:data] }
      pdf = Prawn::Document.new(info:)
      # pdf.font_families.update(
      #   'CustomFont' => {
      #     normal: './DejaVuSansCondensed.ttf',
      #     bold: './DejaVuSansCondensed-Bold.ttf',
      #     italic: './DejaVuSansCondensed-Oblique.ttf'
      #   }
      # )
      # pdf.font('CustomFont')
      pdf.default_leading(5)
      pdf.font_size(9)
      render_document(document, pdf)
      pdf.render
    end

    private

    def header_style(content, header_level)
      color = @computed_style["h#{header_level}".to_sym][:color]
      font_size = @computed_style["h#{header_level}".to_sym][:size]
      "<color rgb='#{color}'><font size='#{font_size}'>#{content}</font></color>"
    end

    def paragraph_style(content)
      "#{content}"
    end

    def emph_style(content)
      "<i>#{content}</i>"
    end

    def render_header(node, pdf)
      content = ''
      node.each { |subnode| content << subnode.string_content if subnode.type == :text }
      pdf.move_down(5) if node.header_level != 1
      pdf.text(
        header_style(content, node.header_level),
        inline_format: true,
        align: @computed_style["h#{node.header_level}".to_sym][:align]
      )
      pdf.move_down(5)
    end

    def render_strong(node)
      content = ''
      node.each { |subnode| content << subnode.string_content if subnode.type == :text }
      "<b>#{content}</b>"
    end

    def render_paragraph(node, pdf = nil)
      start_cursor = pdf.cursor if pdf
      content = ''
      node.each do |subnode|
        case subnode.type
        when :text
          content << subnode.string_content
        when :emph
          content << render_emph(subnode)
        when :softbreak
          content << "\n"
        when :strong
          content << render_strong(subnode)
        when :paragraph
          content << render_paragraph(subnode)
        when :image
          pdf.text(paragraph_style(content), inline_format: true)
          content = ''
          render_image(subnode, pdf, start_cursor)
        else
          $stderr.puts "Unknown node type: #{subnode.type}"
        end
      end
      pdf ? pdf.text(paragraph_style(content), inline_format: true) : content
    end

    def render_emph(node)
      content = ''
      node.each { |subnode| content << subnode.string_content if subnode.type == :text }
      emph_style(content)
    end

    def render_list_item(node, pdf)
      style = @computed_style[:list_item]
      content = ''
      node.each do |subnode|
        if subnode.type == :paragraph
          content << "#{style[:bullet]} "
          content << render_paragraph(subnode)
          content << "\n"
        end
      end
      content
    end

    def render_list(node, pdf = nil)
      content = ''
      node.each { |subnode| content << render_list_item(subnode, pdf) if subnode.type == :list_item }
      style = @computed_style[:list]
      return content unless pdf

      pdf.text(content, inline_format: true, indent_paragraphs: style[:indent])
    end

    def render_table(node, pdf)
      table =
        node.map do |subnode|
          case subnode.type
          when :table_row
            subnode.flat_map { |subsubnode| subsubnode.map(&:string_content) }
          when :table_header
            subnode.flat_map { |subsubnode| subsubnode.map { |n| table_header_style(n.string_content) } }
          end
        end
      row_colors = @computed_style[:table][:colors]
      pdf.table(table, row_colors:, cell_style: { inline_format: true }, position: @computed_style[:table][:postion]) { cells.borders = [] }
    end

    def table_header_style(content)
      "<b>#{content}</b>"
    end

    def render_blockquote(node, pdf)
      node.each do |subnode|
        pdf.indent(10) do
          case subnode.type
          when :paragraph
            render_paragraph(subnode, pdf)
          when :list
            pdf.text(render_list(subnode), inline_format: true)
          else
            $stderr.puts "Quote: #{subnode.type}"
          end
        end
      end
    end

    def render_image(node, pdf, position = pdf.cursor)
      style = @computed_style[:image]
      style = style[node.first.string_content.to_sym] if style[node.first.string_content.to_sym]
      options = {}
      options = options.merge({ at: [pdf.bounds.right - 100, position] }) if style[:float] == 'right'
      img_io =
        (
          if node.url.start_with?('data:image/png;base64,')
            StringIO.new(Base64.decode64(node.url[22..-1]))
          else
            File.open(node.url)
          end
        )
      pdf.image(img_io, width: style[:width], **options, center: true)
      pdf.move_down(10)
    end

    def render_document(node, pdf)
      node.each do |subnode|
        case subnode.type
        when :header
          render_header(subnode, pdf)
        when :paragraph
          render_paragraph(subnode, pdf)
        when :list
          render_list(subnode, pdf)
        when :table
          render_table(subnode, pdf)
        when :blockquote
          render_blockquote(subnode, pdf)
        when :html
          $stderr.puts "HTML: #{subnode.inspect}"
        when :image
          render_image(subnode, pdf)
        else
          $stderr.puts "Unknown node type: #{subnode.type}"
        end
      end
    end
  end
end
