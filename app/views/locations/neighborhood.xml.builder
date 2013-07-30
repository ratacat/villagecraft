xml.instruct!
xml.kml :xmlns => "http://earth.google.com/kml/2.1" do
  xml.Document do 
    xml.Style :id => "astyle" do
      xml.LineStyle do |line|
        line.color("28B45014")
        line.width("2")
      end
      xml.PolyStyle do |poly|
        poly.color("28B45014")
        poly.colorMode("normal")
        poly.fill("1")
        poly.outline("1")
      end
    end
    
    xml.Placemark do |pm|
      pm.styleUrl("astyle")
      xml << kml
    end
  end
  
end
