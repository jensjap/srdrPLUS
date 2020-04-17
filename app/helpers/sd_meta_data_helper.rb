module SdMetaDataHelper
  def sd_url_for(str, name=nil)
    if str.present?
      got_str = str.get_url
      if got_str
        link_to(name || got_str, got_str, target: :_blank)
      else 
        prefixed_str = 'https://' + str
        prefixed_str = prefixed_str.get_url

        if prefixed_str
          link_to(name || prefixed_str, prefixed_str, target: :_blank)
        else
          str
        end
      end
    else
      "-----"
    end
  end
end
