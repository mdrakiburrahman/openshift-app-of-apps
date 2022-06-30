hs = {}

if obj.status ~= nil then
  if obj.status.state == "Ready" then
    hs.message = "ActiveDirectoryConnector deployment finished"
    hs.status = "Healthy"
    return hs
  end
  if obj.status.state == "Failed" then
    hs.message = "Failed to deploy ActiveDirectoryConnector"
    hs.status = "Degraded"
    return hs
  end
  if obj.status.state == "Error" then
    hs.message = "Failed to deploy ActiveDirectoryConnector"
    hs.status = "Degraded"
    return hs
  end
end

hs.status = "Progressing"
hs.message = "ActiveDirectoryConnector deployment in progress"
return hs