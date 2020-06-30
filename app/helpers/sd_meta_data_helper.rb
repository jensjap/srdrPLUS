module SdMetaDataHelper
  def prospero_url_for(str)
    if not str.present?
      "-----"
    end
    link_to(str, "https://www.crd.york.ac.uk/prospero/display_record.asp?ID=#{str}", target: :_blank, data: { confirm: 'You are being redirected to an external site' })
  end

  def sd_url_for(str, name=nil)
    if str.present?
      got_str = str.get_url
      if got_str
        confirm_message = got_str.include?('https://srdrplus.ahrq.gov/') ? false : 'You are being redirected to an external website.  Continue?'
        link_to(name || got_str, got_str, target: :_blank, data: { confirm: confirm_message })
      else
        prefixed_str = 'https://' + str
        prefixed_str = prefixed_str.get_url

        if prefixed_str
          confirm_message = prefixed_str.include?('https://srdrplus.ahrq.gov/') ? false : 'You are being redirected to an external website.  Continue?'
          link_to(name || prefixed_str, prefixed_str, target: :_blank, data: { confirm: confirm_message })
        else
          str
        end
      end
    else
      "-----"
    end
  end
end
