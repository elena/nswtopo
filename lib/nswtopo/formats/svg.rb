module NSWTopo::Formats
  module Svg
    def render_svg(path, **options)
      if uptodate? "map.svg"
        path.write read("map.svg")
      else
        width, height = extents.times(1000.0 / scale)
        xml = REXML::Document.new
        xml << REXML::XMLDecl.new(1.0, "utf-8")
        attributes = {
          "version" => 1.1,
          "baseProfile" => "full",
          "width"  => "#{width}mm",
          "height" => "#{height}mm",
          "viewBox" => "0 0 #{width} #{height}",
          "xmlns" => "http://www.w3.org/2000/svg",
          "xmlns:xlink" => "http://www.w3.org/1999/xlink",
          "xmlns:ev" => "http://www.w3.org/2001/xml-events", # TODO: necessary?
          "xmlns:sodipodi" => "http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd",
          "xmlns:inkscape" => "http://www.inkscape.org/namespaces/inkscape",
        }
        svg = xml.add_element "svg", attributes
        defs = svg.add_element "defs"
        svg.add_element "sodipodi:namedview", "borderlayer" => true
        svg.add_element "rect", "x" => 0, "y" => 0, "width" => width, "height" => height, "fill" => "white"
        layers.each do |layer|
          group = svg.add_element "g", "id" => layer.name, "inkscape:groupmode" => "layer"
          layer.render group, defs
        end
        string, formatter = String.new, REXML::Formatters::Pretty.new
        formatter.compact = true
        formatter.write xml, string
        # TODO: enable next line, maybe have --force option to force SVG regeneration
        # write "map.svg", string
        path.write string
        # TODO: catch interrupts when saving to path (e.g. #safely)
      end
    end
  end
end
