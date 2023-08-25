local QBCore = exports['qb-core']:GetCoreObject()
local isCreating = false
local cam = nil

local facialOptions = {}
local canEdit = {
  {name = "Mother", clothingType = "face", max = 45, type = "number", textureCount = 45},
  {name = "Father", clothingType = "face2", max = 45, type = "number", textureCount = 45},
  {name = "Hair", clothingType = "hair", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 45},
  {name = "Eyebrows", clothingType = "eyebrows", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 45},
  {name = "Beard", clothingType = "beard", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 45},
  {name = "Blush", clothingType = "blush", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 45},
  {name = "Lipstick", clothingType = "lipstick", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 45},
  {name = "Make-Up", clothingType = "makeup", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 45},
  {name = "Ageing", clothingType = "ageing", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 45},
  {name = "Eye Color", clothingType = "eye_color", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Freckles", clothingType = "moles", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 45},
  -- {name = "Nose 0", clothingType = "nose_0", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Nose 1", clothingType = "nose_1", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Nose 2", clothingType = "nose_2", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Nose 3", clothingType = "nose_3", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Nose 4", clothingType = "nose_4", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Nose 5", clothingType = "nose_5", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Eyebrow Height", clothingType = "eyebrown_high", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Eyebrow Depth", clothingType = "eyebrown_forward", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Cheek 1", clothingType = "cheek_1", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Cheek 2", clothingType = "cheek_2", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Cheek 3", clothingType = "cheek_3", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Eye Opening", clothingType = "eye_opening", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Lip Filler", clothingType = "lips_thickness", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Jaw Bone Width", clothingType = "jaw_bone_width", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Jaw Bone Rear Length", clothingType = "jaw_bone_back_lenght", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Chimp Bone Height", clothingType = "chimp_bone_lowering", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Chimp Bone Length", clothingType = "chimp_bone_lenght", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Chimp Bone Width", clothingType = "chimp_bone_width", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Chimp Hole", clothingType = "chimp_hole", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},
  -- {name = "Neck Thickness", clothingType = "neck_thikness", max = GetNumberOfPedDrawableVariations(PlayerPedId(), 2), type = "number", textureCount = 0},


}

for i = 1, #canEdit, 1 do
  facialOptions[#facialOptions + 1] = {
    name = canEdit[i].name,
    isRequired = true,
    max = canEdit[i].max,
    type = canEdit[i].type,
    event = 'qb-singlecharacter:ChangeAppearance',
    set = {
        name = canEdit[i].name,
        clothingType = canEdit[i].clothingType,
        type = "item",
      },
  }
  if canEdit[i].textureCount and canEdit[i].textureCount > 0 then
    facialOptions[#facialOptions + 1] = {
      name = canEdit[i].name .. " Texture",
      isRequired = true,
      max = canEdit[i].textureCount,
      type = "number",
      event = 'qb-singlecharacter:ChangeAppearance',
      set = {
          name = canEdit[i].name .. " Texture",
          clothingType = canEdit[i].clothingType,
          type = "texture",
      }
    }
  end
end


local facialData = {}
for i = 1, #facialOptions, 1 do
  facialData[facialOptions[i].name] = facialOptions[i]
end

local Genders = {
  ["0"] = "mp_m_freemode_01",
  ["1"] = "mp_f_freemode_01",
}

local createCamera = function()
  cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 40.0, false, 0)
  print(cam)
  SetCamActive(cam, true)
  RenderScriptCams(true, false, 1, true, true)
  return cam
end

local function GetPositionByRelativeHeading(ped, head, dist)
  local pedPos = GetEntityCoords(ped)

  local finPosx = pedPos.x + math.cos(head * (math.pi / 180)) * dist
  local finPosy = pedPos.y + math.sin(head * (math.pi / 180)) * dist

  return finPosx, finPosy
end

local moveCamera = function(offset, camZo)
  local pedPos = GetEntityCoords(PlayerPedId())
  local cx, cy = GetPositionByRelativeHeading(PlayerPedId(), GetEntityHeading(PlayerPedId()) + 90, offset)
  print(cx, cy)
  print(pedPos, camZo)
  SetCamCoord(cam, cx, cy, pedPos.z + camZo)
  print(GetCamCoord(cam))
  PointCamAtCoord(cam, pedPos.x, pedPos.y, pedPos.z + camZo)
end


RegisterNetEvent('qb-singlecharacter:camera:head', function(params)
    print("Change to head camera")
    moveCamera(0.75, 0.65)
  end)

  RegisterNetEvent('qb-singlecharacter:camera:body', function(params)
    print("Change to body camera")
    moveCamera(2.0, 0.2)
end)

RegisterNetEvent('qb-singlecharacter:ChangeAppearance', function(params)
    local variation = facialData[params.key].set
    variation.articleNumber = tonumber(params.value)
    TriggerEvent('qb-clothes:client:NewCharacterChangeVariation', variation)
end)

RegisterNetEvent('qb-singlecharacter:ChangeGender', function(params)
  local toChange = params.key
  local value = params.value
  print(toChange, value)
  print(Genders[tostring(params.value)])
  TriggerEvent('qb-clothes:client:NewCharacter', Genders[tostring(params.value)])
end)


NewCharacter = function()
  isCreating = true
  if GetIsLoadingScreenActive() then
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
  end
  DoScreenFadeIn(2500)
  createCamera()
  moveCamera(0.75, 0.65)
  local data = exports['UserInterface']:openInterface({
    Header = "Welcome!",
    canClose = "false",
    Body= {
      {
        name= "Character",
        icon= "fas fa-user",
        showIcon= true,
        showText= true,
        options= {
          {
            type= "text",
            isRequired= true,
            name= "First Name",
          },
          {
            type= "text",
            isRequired= true,
            name= "Last Name",
          },
          {
            type= 'select',
            isRequired= true,
            name= "Gender",
            event= 'qb-singlecharacter:ChangeGender',
            options= {
              {
                name= "Male",
                value= 0,
              },
              {
                name= "Female",
                value= 1,
              },
            }
          }
        },
      },
      {
        name= "Heritage",
        icon= "fas fa-user",
        showIcon= true,
        showText= true,
        options= facialOptions,
      },
    },
    Footer = {
      {
        {
          type= "button",
          name="Head",
          icon= "fas fa-user",
          showIcon= true,
          showText= false,
          event= "qb-singlecharacter:camera:head",
        },
        {
          type= "button",
          name="Body",
          icon= "fas fa-user",
          showIcon= true,
          showText= false,
          event= "qb-singlecharacter:camera:body",
        }
      },
      {
          {
            isSubmit= true,
            type= "button",
            name="Confirm",
            icon= "fas fa-play",
            showIcon= false,
            showText= true,
            event= "Submit",
          },
      }
    }
  })
  TriggerServerEvent('qb-singlecharacter:server:createCharacter', data)
  TriggerEvent('qb-clothes:client:NewCharacterSaveSkin', SaveSkin)
  DestroyCam(cam, false)
  DestroyAllCams(true)
  RenderScriptCams(false, false, 1, true, true)
  print(json.encode(data))
end
