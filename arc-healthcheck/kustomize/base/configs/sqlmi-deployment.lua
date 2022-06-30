hs = {}

if obj.status ~= nil then
  if obj.status.state == "Ready" then
    hs.message = "SqlManagedInstance deployment finished"
    hs.status = "Healthy"
    return hs
  end
  if obj.status.state == "Failed" then
    hs.message = "Failed to deploy SqlManagedInstance"
    hs.status = "Degraded"
    return hs
  end
end

hs.status = "Progressing"
hs.message = "SqlManagedInstance deployment in progress"
return hs