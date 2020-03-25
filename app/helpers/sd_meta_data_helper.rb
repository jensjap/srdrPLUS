module SdMetaDataHelper
  def sd_url_for(str, name=nil)
    if str.present?
      if str.is_url?
        link_to(name || str, str, target: :_blank)
      else 
        str
      end
    else
      "-----"
    end
  end
end
