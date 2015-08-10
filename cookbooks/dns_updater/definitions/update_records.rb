#DNS Updater definition

define :update_records do

  AWS.config(:access_key_id => params[:access_key_id], :secret_access_key => params[:secret_access_key], :region => params[:region])

  hash =  {
            hosted_zone_id: node["aws"]["route53"]["zone_id"],
            change_batch:
              {
                  comment: "optional",
                  changes: [
                              {
                                action: params[:record_action],
                                resource_record_set:
                                                    {
                                                      name: params[:record_name],
                                                      type: params[:type],
                                                      ttl: params[:ttl],
                                                      resource_records: [
                                                        {
                                                          value: params[:value]
                                                        }
                                                      ]
                                                      }
                              }
                            ]
            }
          }
  AWS::Route53.new.client.change_resource_record_sets(hash)
end
