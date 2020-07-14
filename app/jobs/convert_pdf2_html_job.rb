class ConvertPdf2HtmlJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    accession_id = args.first
    pdf_path = Dir.glob("#{ Rails.root }/reports/#{ accession_id }/*_#{ accession_id }/TOC.pdf").first
    if pdf_path
      system("mkdir -p #{ Rails.root }/public/reports/#{ accession_id }")
      system("Pdf2HtmlEX #{ pdf_path } TOC.html")
      system("mv TOC.html #{ Rails.root }/public/reports/#{ accession_id }/")
    elsif args.second.present?
      sd_meta_datum = SdMetaDatum.find args.second
      pdf_path = "#{ Rails.root }/public/reports/#{ accession_id }/TOC.pdf"
      system("mkdir -p #{ Rails.root }/public/reports/#{ accession_id }")
      File.open(pdf_path, 'wb') do |file|
        file.write(sd_meta_datum.report_file.download)
      end
      system("Pdf2HtmlEX #{ pdf_path } TOC.html")
      system("mv TOC.html #{ Rails.root }/public/reports/#{ accession_id }/")
      system("rm #{pdf_path}")
    end
  end
end
