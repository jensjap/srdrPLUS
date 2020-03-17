module SdMetaDataHelper
  def sd_url_for(str, name=nil)
    if str.present?
      if str.is_url?
        link_to(name || str, str, target: :_blank)
      else 
        str
      end
    else
      "N/A"
    end
  end
end
