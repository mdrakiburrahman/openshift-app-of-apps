hs = {}

if obj.status == nil or obj.status.conditions == nil then
  return hs
end

for i, condition in ipairs(obj.status.conditions) do
  if condition.type == "Complete" then
    hs.message = "Job run finished"
    hs.status = "Healthy"
    return hs
  end
  if condition.type == "Failed" then
    hs.message = condition.message
    hs.status = "Degraded"
    return hs
  end
end

hs.status = "Progressing"
hs.message = "Proceeding with Job run..."
return hs