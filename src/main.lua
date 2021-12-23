local isOpen
local isReady
local exportCb
local scriptCam

local function setOpen(o)
  isOpen = o
  SetNuiFocus(o,false)
end

local function createCam(pos,rot,fov)
  local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x,pos.y,pos.z, rot.x,rot.y,rot.z, fov or GetGameplayCamFov(), false, 0)

  SetCamCoord(pos.x,pos.y,pos.z)
  SetCamRot(cam,rot.x,rot.y,rot.z,2)

  return cam
end

local function panCam(dialogue,ped)
  local pos = GetEntityCoords(ped) + (GetEntityForwardVector(ped)*1.5) + vector3(0,0,0.65)
  local rot = GetEntityRotation(ped,2)
  rot = vector3(rot.x,rot.y,rot.z + 180.0)

  local tempCam = createCam(GetGameplayCamCoord(),GetGameplayCamRot(2))  
  local cam = createCam(pos,rot)

  SetCamActive(tempCam,true)
  RenderScriptCams(true,false,1,true,true)

  SetCamActiveWithInterp(cam,tempCam,1500,true,true)  
  Wait(1000)

  local animLength = math.max(1,dialogue:len()) * 50
  PlayFacialAnim(ped,"mic_chatter","mp_facial")

  Citizen.SetTimeout(math.floor(animLength),function()    
    PlayFacialAnim(ped,"mood_normal_1","facials@gen_male@base")
  end)

  Wait(500)

  DestroyCam(tempCam)
  scriptCam = cam
end

local function destroyCam()
  local tempCam = createCam(GetGameplayCamCoord(),GetGameplayCamRot(2))  

  SetCamActiveWithInterp(tempCam,scriptCam,1500,true,true)  
  Wait(1500)

  RenderScriptCams(false,false)
  DestroyCam(scriptCam)
  DestroyCam(tempCam)
  scriptCam = nil
end

Citizen.CreateThread(function()
  while not isReady do
    SendNUIMessage({
      type = "config",
      resourceName = GetCurrentResourceName()
    })

    Wait(500)
  end

  while true do
    local waitTime = 100

    if isOpen then
      local ped = PlayerPedId()
      SetEntityLocallyInvisible(ped)

      HideHudAndRadarThisFrame()
      InvalidateIdleCam()
      
      waitTime = 0
    end

    Wait(waitTime)
  end
end)

RegisterNUICallback('ready',function()
  isReady = true
end)

RegisterNUICallback('close',function(data)
  if not isOpen then
    return
  end

  setOpen(false)

  if scriptCam then
    destroyCam()
  end

  if exportCb then
    exportCb(data)
    exportCb = nil
  end
end)

exports('Open',function(opts)
  if not isReady or isOpen then
    return print("dialogue not ready or already in use")
  end

  if type(opts) ~= "table" then
    return error("options not passed as a table",2)
  end

  setOpen(true)

  if opts.targetEnt then
    panCam(opts.dialogue or "",opts.targetEnt)
  end

  SendNUIMessage({
    type = "open",
    dialogue = opts.dialogue or "",
    options = opts.options or {}
  })

  exportCb = opts.cb
end)
