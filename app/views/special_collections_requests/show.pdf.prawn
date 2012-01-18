pdf.font "Helvetica"
pdf.font_size = 11

lefts = [3, 243, 518]
widths = [240, 275, 235]
texts = []

texts << "SHELF COPY


THIS SLIP IS TO BE ARCHIVED, NOT TRASHED!"

texts << "PATRON COPY"
texts << "DESK COPY"

fine_prints = []
fine_prints << ''
fine_prints << 'Please use a cradle for all books.

Please inform staff if you would like material kept on reserve for you.  The period of reserve is two weeks beyond the latest charge-use; vault materials may be reserved for two days.  Please do not submit a “new” request for material that you have on reserve.'
fine_prints << ''

lefts.each_with_index do |left, index|

  pdf.bounding_box([left,570], :width => widths[index], :height => 550) do
    pdf.stroke_bounds
    pdf.bounding_box([15,545], :width => 210, :height => 540) do
      pdf.text "Name: #{@special_collections_request.name}"
      pdf.text "Id: #{@special_collections_request.user_id}"
      
      pdf.move_down(5)
  
      pdf.text "Request ID: #{@special_collections_request.id}"
      pdf.text "Title: #{@document.value_for :title_display}"
      pdf.text "Author: #{@document.value_for :author_display}"
    
      pdf.move_down(10)
        
      pdf.text "Location / Barcode : Call Number:"
    
      last = 'xyz'
      @special_collections_request.special_collections_request_items.map do |item|
        pdf.move_down(5) and pdf.text "#{item.location}" if item.location != last
        pdf.text " - #{item.barcode} : #{item.call_number}"
        last = item.location
      end

      pdf.move_down(10)
    
      pdf.text "User note: #{@special_collections_request.user_note}"
    
      pdf.move_down(10)
    
      pdf.text "Staff note: #{@special_collections_request.staff_note}"
    
      pdf.bounding_box([-15, 140], :width => widths[index], :height => 20) do
        pdf.move_down 10
			 	pdf.bounding_box [pdf.bounds.left + 5, pdf.bounds.top - 5],
			    :width  => pdf.bounds.width - (5 * 2), 
			    :height => pdf.bounds.height - (5 * 2) do
          pdf.font_size(10) do
            pdf.text "REQUEST: #{@date}"
          end
        end
        pdf.stroke do
          pdf.line pdf.bounds.top_left,    pdf.bounds.top_right
          pdf.line pdf.bounds.bottom_left, pdf.bounds.bottom_right
        end
      end
      
      pdf.move_down(10)
      pdf.text texts[index], :align => :center, :style => :bold
      pdf.font_size(9) do
        pdf.text fine_prints[index], :align => :center, :style => :bold
      end
    end
  end
end

