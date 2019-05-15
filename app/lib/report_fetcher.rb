require 'open-uri'
require 'csv'
require 'net/ftp'

class ReportFetcher
  FTP_URI = 'ftp://ftp.ncbi.nlm.nih.gov/pub/litarch/'.freeze
  CSV_DIRECTORY_URI = 'ftp://ftp.ncbi.nlm.nih.gov/pub/litarch/file_list.csv'.freeze

  REPORTS_DIRECTORY = "#{Rails.root}/reports".freeze
  REPORT_DIRECTORY_FILE = "#{REPORTS_DIRECTORY}/file_list.csv".freeze

  def self.run_daily_update
    puts 'listing or creating report directory'
    self.list_or_create_report_directory

    puts 'downloading or refreshing report directory file'
    self.download_or_refresh_report_directory_file

    puts 'list or download new report tars'
    self.list_or_download_new_reports_tars(self.read_list_of_cer_report_metas)
  end

  def self.list_or_create_report_directory
    FileUtils.mkdir_p(REPORTS_DIRECTORY) unless File.directory?(REPORTS_DIRECTORY)
  end

  def self.download_or_refresh_report_directory_file
    open(REPORT_DIRECTORY_FILE, 'wb') do |file|
      file << open(CSV_DIRECTORY_URI).read
    end
  end

  def self.read_list_of_cer_report_metas
    csv_text = File.read(REPORT_DIRECTORY_FILE)
    csv = CSV.parse(csv_text, :headers => true)
    cer_report_metas = []
    csv.each { |row| cer_report_metas << row if row['File'].include?("/cer") }
    cer_report_metas
  end

  def self.list_or_download_new_reports_tars(cer_report_metas)
    ftp = Net::FTP.new('ftp.ncbi.nlm.nih.gov')
    ftp.login

    cer_report_metas.each do |report_meta|
      accession_id = report_meta['Accession ID']
      directory_report_location = report_meta['File']
      ftp_report_location = "/pub/litarch/#{directory_report_location}"
      report_download_directory = "#{REPORTS_DIRECTORY}/#{accession_id}"
      report_download_location = "#{report_download_directory}/report.tar.gz"

      unless File.exist?(report_download_location)
        FileUtils.mkdir_p("#{report_download_directory}") unless File.directory?(report_download_directory)
        ftp.getbinaryfile(ftp_report_location, report_download_location)
        puts "Downloaded: #{report_download_location}"
        `tar zxvf '#{report_download_location}' -C '#{report_download_directory}'`
        puts "Extracted: #{report_download_location}"
      else
        puts "Already exists--skipping: #{report_download_location}"
      end
    end
    nil
  end
end