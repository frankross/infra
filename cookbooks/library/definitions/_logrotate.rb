define :_logrotate  do
  path = params[:path]
  logrotate_app "#{params[:name]}" do
    cookbook "logrotate"
    path "#{path}"
    frequency "daily"
    rotate 3
  end
end
