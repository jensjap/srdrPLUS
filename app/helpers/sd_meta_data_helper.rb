module SdMetaDataHelper
  def sd_url_for(str, name=nil)
    if str.present?
      if str.is_url?
        link_to(name || str, str, target: :_blank)
      else 
        prefixed_str = 'https://' + str
        if prefixed_str.is_url?
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
