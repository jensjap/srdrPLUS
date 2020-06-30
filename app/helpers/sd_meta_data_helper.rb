module SdMetaDataHelper
  def sd_url_for(str, name=nil)
    if str.present?
      got_str = str.get_url
      if got_str
        confirm_message = got_str.start_with?('https://srdrplus.ahrq.gov') ? false : 'You are being redirected to an external website.  Continue?'
        link_to(name || got_str, got_str, target: :_blank, data: { confirm: confirm_message })
      else
        prefixed_str = 'https://' + str
        prefixed_str = prefixed_str.get_url

        if prefixed_str
          confirm_message = prefixed_str.start_with?('https://srdrplus.ahrq.gov') ? false : 'You are being redirected to an external website.  Continue?'
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
