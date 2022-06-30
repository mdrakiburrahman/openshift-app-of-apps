hs = {}
hs.status = "Progressing"
hs.message = "MachineSet deployment operation in progress"
if obj.status ~= nil then
  if obj.status.readyReplicas == obj.status.replicas then
    hs.message = "MachineSet deployment finished - desired number of Machines ready"
    hs.status = "Healthy"
    return hs
  end
end
return hs