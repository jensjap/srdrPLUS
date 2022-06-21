json.set! :data do
  json.array! @abstrackrs do |abstrackr|
    json.partial! 'abstrackrs/abstrackr', abstrackr: abstrackr
    json.url  "
              #{link_to 'Show', abstrackr }
              #{link_to 'Edit', edit_abstrackr_path(abstrackr)}
              #{link_to 'Destroy', abstrackr, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end