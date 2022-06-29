hs = {}
if obj.status ~= nil then
  if obj.status.state == "Ready" then
    hs.message = "Created SqlManagedInstance"
    hs.status = "Healthy"
    return hs
  end
  if obj.status.state == "Failed" then
    hs.status = "Degraded"
    hs.message = "Failed to provision SqlManagedInstance"
    return hs
  end
end

hs.status = "Progressing"
hs.message = "Creating SqlManagedInstance"
return hs