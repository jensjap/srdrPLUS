module Methods
 def set_bucket(bucket)
   @bucket = bucket
 end
 def set_public(val)
   @public = val
 end
end
ActiveStorage::Service.module_eval { attr_writer :bucket }
ActiveStorage::Service.module_eval { attr_writer :public }
ActiveStorage::Service.class_eval { include Methods }
