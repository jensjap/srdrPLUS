json.total_count TimepointName.count
json.items do
  json.array!(@timepoint_names) do |tpn|
    json.extract! tpn, :id, :name, :unit
  end
end
