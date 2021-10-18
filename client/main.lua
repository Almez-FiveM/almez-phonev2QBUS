QBCore = nil

Citizen.CreateThread(function()
    while QBCore == nil do
        TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
        Citizen.Wait(0)
    end

    while QBCore.Functions.GetPlayerData().job == nil do
        Citizen.Wait(20)
    end

    QBCore.PlayerData = QBCore.Functions.GetPlayerData()
    Wait(200)

end)

RegisterNetEvent('almez-phone:client:openPhone')
AddEventHandler('almez-phone:client:openPhone', function(pData)
        PlayerJob = QBCore.Functions.GetPlayerData().job
        PhoneData.PlayerData = QBCore.Functions.GetPlayerData()
        PhoneData.PlayerData.Name = pData.Ownername
        PhoneData.MetaData = {}
        PhoneData.PlayerData.charinfo = pData.charinfo ~= nil and pData.charinfo or {}
        PhoneData.PlayerData.identifier = pData.charinfo ~= nil and pData.charinfo.identifier or ""
        PhoneData.PhoneNumber = pData.Number
        PhoneData.Owner = pData.Owner
        PhoneData.Ownername = pData.Ownername
        if PhoneData.PlayerData.charinfo.profilepicture == nil then
            PhoneData.MetaData.profilepicture = "default"
        else
            PhoneData.MetaData.profilepicture = PhoneData.PlayerData.charinfo.profilepicture
        end

        if PhoneData.PlayerData.charinfo.background ~= nil then
            PhoneData.MetaData.background = PhoneData.PlayerData.charinfo.background
        end

        if pData.Applications ~= nil and next(pData.Applications) ~= nil then
            for k, v in pairs(pData.Applications) do
                Config.PhoneApplications[k].Alerts = v
            end
        end

        if pData.PlayerContacts ~= nil and next(pData.PlayerContacts) ~= nil then
            PhoneData.Contacts = pData.PlayerContacts
        else 
            PhoneData.Contacts = {}
        end

        if pData.Chats ~= nil and next(pData.Chats) ~= nil then
            local Chats = {}
            for k, v in pairs(pData.Chats) do
                Chats[v.number] = {
                    name = IsNumberInContacts(v.number),
                    number = v.number,
                    messages = json.decode(v.messages)
                }
            end
            PhoneData.Chats = Chats
        else
            PhoneData.Chats = {}
        end

        if pData.Invoices ~= nil and next(pData.Invoices) ~= nil then
            for _, invoice in pairs(pData.Invoices) do
                invoice.name = IsNumberInContacts(invoice.number)
            end
            PhoneData.Invoices = pData.Invoices
        end

        if pData.Hashtags ~= nil and next(pData.Hashtags) ~= nil then
            PhoneData.Hashtags = pData.Hashtags
        end
        if pData.Tweets ~= nil then
            PhoneData.Tweets = pData.Tweets
            PhoneData.id = pData.Tweets[#pData.Tweets].id + 1
        end

        if pData.SelfTweets ~= nil then
            PhoneData.SelfTweets = pData.SelfTweets
        end

        if pData.Mails ~= nil and next(pData.Mails) ~= nil then
            PhoneData.Mails = pData.Mails
        end

        if pData.Adverts ~= nil and next(pData.Adverts) ~= nil then
            PhoneData.Adverts = pData.Adverts
        end

        if pData.CryptoTransactions ~= nil and next(pData.CryptoTransactions) ~= nil then
            PhoneData.CryptoTransactions = pData.CryptoTransactions
        end

        QBCore.Functions.TriggerCallback('almez-phone:isPhoneRealOwner', function(realowner)
            if realowner ~= false then
                PhoneData.isOwner = true
            else
                PhoneData.isOwner = false
            end
        end)

        Citizen.Wait(300)

        SendNUIMessage({
            action = "LoadPhoneData",
            PhoneData = PhoneData,
            PlayerData = PhoneData.PlayerData,
            PlayerJob = PhoneData.PlayerData.job,
            applications = Config.PhoneApplications
        })

        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(true)

        SendNUIMessage({
            action = "open",
            Tweets = PhoneData.Tweets,
            AppData = Config.PhoneApplications,
            CallData = PhoneData.CallData,
            PlayerData = PhoneData.PlayerData,
        })

        SendNUIMessage({
            action = "RefreshContacts",
            Contacts = PhoneData.Contacts
        })

        PhoneData.isOpen = true

        if not PhoneData.CallData.InCall then
            DoPhoneAnimation('cellphone_text_in')
        else
            DoPhoneAnimation('cellphone_call_to_text')
        end

        SetTimeout(250, function()
            newPhoneProp()
        end)

        -- Garage Fix
        QBCore.Functions.TriggerCallback('almez-phonev2:server:GetGarageVehicles', function(vehicles)

            if vehicles ~= nil then
                for k, v in pairs(vehicles) do
                    vehicles[k].fullname = GetLabelText(GetDisplayNameFromVehicleModel(v.model))
                end
                PhoneData.GarageVehicles = vehicles
            else
                local xd = json.encode(vehicles) 
                PhoneData.GarageVehicles = {}
            end
            
        end, pData.Owner)
end)

-- Code
local PlayerJob = {}

phoneProp = 0
local phoneModel = `prop_npc_phone_02`

-- RegisterCommand("clearea", function()
--     local coords = GetEntityCoords(PlayerPedId())
--     ClearAreaOfObjects(coords.x, coords.y, coords.z, 15.0, 0)
-- end)

PhoneData = {
    MetaData = {},
    isOpen = false,
    PlayerData = nil,
    Contacts = {},
    Tweets = {},
    currentTab = nil,
    MentionedTweets = {},
    Hashtags = {},
    Chats = {},
    Invoices = {},
    CallData = {},
    RecentCalls = {},
    Garage = {},
    SelfTweets = {},
    Mails = {},
    Adverts = {},
    id = 1,
    GarageVehicles = {},
    AnimationData = {
        lib = nil,
        anim = nil,
    },
    SuggestedContacts = {},
    Alarms = {},
    CryptoTransactions = {},
}

RegisterNUICallback("updateHashtag", function(data)
    TriggerServerEvent("fizzfau-phone:updateHashtag", data)
end)

RegisterNUICallback("ClearBankData", function()
    TriggerServerEvent("almez-phonev2:server:ClearBankData")
end)

RegisterNetEvent('almez-phonev2:client:RaceNotify')
AddEventHandler('almez-phonev2:client:RaceNotify', function(message)
    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = Lang['RACE_TITLE'],
                text = message,
                icon = "fas fa-flag-checkered",
                color = "#353b48",
                timeout = 1500,
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = Lang['RACE_TITLE'],
                content = message,
                icon = "fas fa-flag-checkered",
                timeout = 3500,
                color = "#353b48",
            },
        })
    end
end)

RegisterNetEvent('almez-phonev2:client:AddRecentCall')
AddEventHandler('almez-phonev2:client:AddRecentCall', function(data, time, type)
    table.insert(PhoneData.RecentCalls, {
        name = IsNumberInContacts(data.number),
        time = time,
        type = type,
        number = data.number,
        anonymous = data.anonymous
    })
    TriggerServerEvent('almez-phonev2:server:SetPhoneAlerts', "phone")
    Config.PhoneApplications["phone"].Alerts = Config.PhoneApplications["phone"].Alerts + 1
    SendNUIMessage({
        action = "RefreshAppAlerts",
        AppData = Config.PhoneApplications
    })
end)

RegisterNetEvent('QBCore:setJob')
AddEventHandler('QBCore:setJob', function(JobInfo)
    if JobInfo.name == "police" then
        SendNUIMessage({
            action = "UpdateApplications",
            JobData = JobInfo,
            applications = Config.PhoneApplications
        })
    elseif PlayerJob.name == "police" and JobInfo.name == "unemployed" then
        SendNUIMessage({
            action = "UpdateApplications",
            JobData = JobInfo,
            applications = Config.PhoneApplications
        })
    end

    PlayerJob = JobInfo
end)

AddEventHandler('tgiann:playerdead', function(data)
    isDead = data

    if data == true then
        if PhoneData.isOpen then
            SendNUIMessage({
                action = "close",
            })
            if not PhoneData.CallData.InCall then
                DoPhoneAnimation('cellphone_text_out')
                SetTimeout(400, function()
                    StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
                    deletePhone()
                    PhoneData.AnimationData.lib = nil
                    PhoneData.AnimationData.anim = nil
                end)
            else
                PhoneData.AnimationData.lib = nil
                PhoneData.AnimationData.anim = nil
                DoPhoneAnimation('cellphone_text_to_call')
            end
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
            if PhoneData.CallData.InCall then
                SetTimeout(750, function()
                    CancelCall()
                    PhoneData.isOpen = false
                end)
            end
        end
    end
end)

RegisterNUICallback('ClearRecentAlerts', function(data, cb)
    TriggerServerEvent('almez-phonev2:server:SetPhoneAlerts', "phone", 0)
    Config.PhoneApplications["phone"].Alerts = 0
    SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
end)

RegisterNUICallback('SetBackground', function(data)
    local background = data.background

    TriggerServerEvent('almez-phonev2:server:SaveMetaData', 'background', background)
end)

RegisterNUICallback('GetMissedCalls', function(data, cb)
    cb(PhoneData.RecentCalls)
end)

RegisterNUICallback('GetSuggestedContacts', function(data, cb)
    cb(PhoneData.SuggestedContacts)
end)

function IsNumberInContacts(num)
    local retval = num
    for _, v in pairs(PhoneData.Contacts) do
        if num == v.number then
            retval = v.name
            break
        end
    end
    return retval
end

RegisterNUICallback("WhatsappOptions", function(data, cb)
    if data.type == "whatsapp-clear-chat" then
        PhoneData.Chats[data.number].messages = {} 
        PhoneData.Chats[data.number].number = data.number
        PhoneData.Chats[data.number].name = data.name
    else
        -- table.remove(PhoneData.Chats, data.number)
        PhoneData.Chats[data.number] = nil
    end
    cb(PhoneData.Chats[data.number])
    TriggerServerEvent("almez-phonev2:WhatsappActions", data)
end)

-- RegisterNetEvent('almez-phonev2:client:openPhone')
-- AddEventHandler('almez-phonev2:client:openPhone', function(cb)
--     if not PhoneData.isOpen then
--         cb(OpenPhone())
--     end
-- end)

function CalculateTimeToDisplay()
    hour = GetClockHours()
    minute = GetClockMinutes()

    local obj = {}

    if minute <= 9 then
        minute = "0" .. minute
    end

    obj.hour = hour
    obj.minute = minute
    return obj
end

Citizen.CreateThread(function()
    while true do
        if PhoneData.isOpen then
            SendNUIMessage({
                action = "UpdateTime",
                InGameTime = CalculateTimeToDisplay(),
            })
        end
        Citizen.Wait(1000)
    end
end)




Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)

        if isLoggedIn then
            QBCore.Functions.TriggerCallback('almez-phonev2:server:GetPhoneData', function(pData)
                if pData.PlayerContacts ~= nil and next(pData.PlayerContacts) ~= nil then
                    PhoneData.Contacts = pData.PlayerContacts
                end

                SendNUIMessage({
                    action = "RefreshContacts",
                    Contacts = PhoneData.Contacts
                })
            end)
        end
    end
end)

RegisterNUICallback("LikedTwitterPost", function(data)

end)


RegisterNetEvent("fizzfau:phone:updateInvoices")
AddEventHandler("fizzfau:phone:updateInvoices", function()
    LoadPhone()
end)

RegisterNUICallback('HasPhone', function(data, cb)
    QBCore.Functions.TriggerCallback('almez-phonev2:server:HasPhone', function(HasPhone)
         cb(HasPhone)
     end)
 end)

RegisterNetEvent("fizzfau-callanimfix")
AddEventHandler("fizzfau-callanimfix", function()
    DoPhoneAnimation('cellphone_call_listen_base')
end)


 RegisterNUICallback("FindVehicle", function(data, cb)
    local vehicles = QBCore.Game.GetVehicles()
    for i = 1, #vehicles do
        if GetVehicleNumberPlateText(vehicles[i]) == data.vehicle.plate then
            local vehicle = vehicles[i]
            local coords = GetEntityCoords(vehicle)
            SetNewWaypoint(coords.x, coords.y)
            cb("ok")
            break
        end
    end
 end)

RegisterNUICallback("DeleteWhatsappMessage", function(data)
    local number = data.number
    local id = data.id + 1
    local id2 = data.id2 + 1
        PhoneData.Chats[number].messages[id2].messages[id].message = nil
        PhoneData.Chats[number].messages[id2].messages[id].image = nil
        PhoneData.Chats[number].messages[id2].messages[id].type = "deleted"
    TriggerServerEvent("almez-phonev2:DeleteWhatsappMessage", number, PhoneData.Chats[number].messages, id)
end)

RegisterNetEvent("almez-phonev2:UpdatePhoneChats")
AddEventHandler("almez-phonev2:UpdatePhoneChats", function(number, id)
    for i = 1, #PhoneData.Chats[number].messages do
        PhoneData.Chats[number].messages[i].messages[id].message = nil
        PhoneData.Chats[number].messages[i].messages[id].image = nil
        PhoneData.Chats[number].messages[i].messages[id].type = "deleted"
    end
end)

RegisterNUICallback('SetupGarageVehicles', function(data, cb)
    cb(PhoneData.GarageVehicles)
end)
RegisterNUICallback('Close', function()
    if not PhoneData.CallData.InCall then
        DoPhoneAnimation('cellphone_text_out')
        SetTimeout(400, function()
            StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
            deletePhone()
            PhoneData.AnimationData.lib = nil
            PhoneData.AnimationData.anim = nil
        end)
    else
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
        -- if not CS_VIDEO_CALL.active then
        DoPhoneAnimation('cellphone_text_to_call')
        -- else
        --     StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
        --     PhoneData.AnimationData.lib = nil
        --     PhoneData.AnimationData.anim = nil
        -- end
    end
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    phone = false
    SetTimeout(1000, function()
        PhoneData.isOpen = false
        EnableAllControlActions(0)
    end)
end)

RegisterNUICallback('RemoveMail', function(data, cb)
    local MailId = data.mailId

    TriggerServerEvent('almez-phonev2:server:RemoveMail', MailId)
    cb('ok')
end)

RegisterNetEvent('almez-phonev2:client:UpdateMails')
AddEventHandler('almez-phonev2:client:UpdateMails', function(NewMails)
    SendNUIMessage({
        action = "UpdateMails",
        Mails = NewMails
    })
    PhoneData.Mails = NewMails
end)

RegisterNUICallback('AcceptMailButton', function(data)
    TriggerEvent(data.buttonEvent, data.buttonData)
    TriggerServerEvent('almez-phonev2:server:ClearButtonData', data.mailId)
end)

RegisterNUICallback('AddNewContact', function(data, cb)
    table.insert(PhoneData.Contacts, {
        name = data.ContactName,
        number = data.ContactNumber,
        iban = data.ContactIban,
        image = data.ContactImage
    })
    Citizen.Wait(100)
    cb(PhoneData.Contacts)
    if PhoneData.Chats[data.ContactNumber] ~= nil and next(PhoneData.Chats[data.ContactNumber]) ~= nil then
        PhoneData.Chats[data.ContactNumber].name = data.ContactName
    end
    TriggerServerEvent('almez-phonev2:server:AddNewContact', data.ContactName, data.ContactNumber, data.ContactIban, data.ContactImage)
end)

RegisterNUICallback('GetMails', function(data, cb)
    cb(PhoneData.Mails)
end)

RegisterNUICallback('GetWhatsappChat', function(data, cb)
    if PhoneData.Chats[data.phone] ~= nil then
        cb(PhoneData.Chats[data.phone])
    else
        cb(false)
    end
end)

RegisterNUICallback('GetProfilePicture', function(data, cb)
    local number = data.number

    QBCore.Functions.TriggerCallback('almez-phonev2:server:GetPicture', function(picture)
        cb(picture)
    end, number)
end)

RegisterNUICallback('GetBankContacts', function(data, cb)
    cb(PhoneData.Contacts)
end)

RegisterNUICallback('GetBankData', function(data, cb)
    QBCore.Functions.TriggerCallback('almez-phonev2:server:GetBankData', cb)
end)

RegisterNUICallback('GetInvoices', function(data, cb)
    QBCore.Functions.TriggerCallback('almez-phonev2:server:GetInvoices',function(data)
        PhoneData.Invoices = data
        cb(data)
    end)
end)

function GetKeyByDate(Number, Date)
    local retval = nil
    if PhoneData.Chats[Number] ~= nil then
        if PhoneData.Chats[Number].messages ~= nil then
            retval = #PhoneData.Chats[Number].messages+1
            for key, chat in pairs(PhoneData.Chats[Number].messages) do
                if chat.date == Date then
                    retval = key
                    break
                end
            end
        end
    end
    return retval
end

function GetKeyByNumber(Number)
    local retval = nil
    if PhoneData.Chats then
        for k, v in pairs(PhoneData.Chats) do
            if v.number == Number then
                retval = k
                break
            end
        end
    end
    return retval
end

function ReorganizeChats(key)
    local ReorganizedChats = {}
    ReorganizedChats[key] = PhoneData.Chats[key]
    for k, chat in pairs(PhoneData.Chats) do
        if k ~= key then
            -- table.insert(ReorganizedChats, chat)
            ReorganizedChats[k] = chat
        end
    end
    PhoneData.Chats = ReorganizedChats
end

RegisterNUICallback('SendMessage', function(data, cb)
    local ChatMessage = data.ChatMessage
    local ChatDate = data.ChatDate
    local ChatNumber = data.ChatNumber
    local ChatTime = data.ChatTime
    local ChatType = data.ChatType

    local Ped = PlayerPedId()
    local Pos = GetEntityCoords(Ped)
    local NumberKey = ChatNumber
    local ChatKey = GetKeyByDate(NumberKey, ChatDate)
    for k,v in pairs(PhoneData.Chats) do
        if v.lastmessage then
            v.lastmessage = false
            break
        end
    end

    if PhoneData.Chats[NumberKey] ~= nil then
        if PhoneData.Chats[NumberKey].messages[ChatKey] ~= nil then
            if ChatType == "message" then
                table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                    message = ChatMessage,
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {},
                })
            elseif ChatType == "location" then
                table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                    message = Lang("WHATSAPP_SHARED_LOCATION"),
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {
                        x = Pos.x,
                        y = Pos.y,
                    },
                })
            elseif ChatType == "image" then
                table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                    message = Lang("WHATSAPP_SHARED_IMAGE") .. ' '..ChatMessage,
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {},
                    image = data.image
                })
            end
            PhoneData.Chats[NumberKey].lastmessage = true
            TriggerServerEvent('almez-phonev2:server:UpdateMessages', PhoneData.Chats[NumberKey].messages, ChatNumber, false)
            NumberKey = ChatNumber
            -- ReorganizeChats(NumberKey)
        else
            table.insert(PhoneData.Chats[NumberKey].messages, {
                date = ChatDate,
                messages = {},
            })
            ChatKey = GetKeyByDate(NumberKey, ChatDate)
            if ChatType == "message" then
                table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                    message = ChatMessage,
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {},
                })
            elseif ChatType == "location" then
                table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                    message = Lang("WHATSAPP_SHARED_LOCATION"),
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {
                        x = Pos.x,
                        y = Pos.y,
                    },
                })
            elseif ChatType == "image" then
                table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                    message = Lang("WHATSAPP_SHARED_IMAGE") .. ' '..ChatMessage,
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {},
                    image = data.image
                })
            end
            PhoneData.Chats[NumberKey].lastmessage = true
            TriggerServerEvent('almez-phonev2:server:UpdateMessages', PhoneData.Chats[NumberKey].messages, ChatNumber, true)
            NumberKey = ChatNumber
            -- ReorganizeChats(NumberKey)
        end
    else
        PhoneData.Chats[ChatNumber] = {
            name = IsNumberInContacts(ChatNumber),
            number = ChatNumber,
            messages = {},
        }
        ChatKey = GetKeyByDate(ChatNumber, ChatDate)
        PhoneData.Chats[ChatNumber].messages[ChatKey] = {
            date = ChatDate,
            messages = {},
        }
        if ChatType == "message" then
            table.insert(PhoneData.Chats[ChatNumber].messages[ChatKey].messages, {
                message = ChatMessage,
                time = ChatTime,
                sender = PhoneData.PlayerData.citizenid,
                type = ChatType,
                data = {},
            })
        elseif ChatType == "location" then
            table.insert(PhoneData.Chats[ChatNumber].messages[ChatKey].messages, {
                message = Lang("WHATSAPP_SHARED_LOCATION"),
                time = ChatTime,
                sender = PhoneData.PlayerData.citizenid,
                type = ChatType,
                data = {
                    x = Pos.x,
                    y = Pos.y,
                },
            })
        elseif ChatType == "image" then
            table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                message = Lang("WHATSAPP_SHARED_IMAGE") .. ' '..ChatMessage,
                time = ChatTime,
                sender = PhoneData.PlayerData.citizenid,
                type = ChatType,
                data = {},
                image = data.image
            })
            
        end
        PhoneData.Chats[NumberKey].lastmessage = true
        TriggerServerEvent('almez-phonev2:server:UpdateMessages', PhoneData.Chats[ChatNumber].messages, ChatNumber, true)
        -- ReorganizeChats(ChatNumber)
    end
    Wait(150)
    QBCore.Functions.TriggerCallback('almez-phonev2:server:GetContactPicture', function(Chat)
        SendNUIMessage({
            action = "UpdateChat",
            chatData = Chat,
            chatNumber = ChatNumber,
        })
    end, PhoneData.Chats[ChatNumber])
end)

RegisterNUICallback('SharedLocation', function(data)
    local x = data.coords.x
    local y = data.coords.y

    SetNewWaypoint(x, y)
    SendNUIMessage({
        action = "PhoneNotification",
        PhoneNotify = {
            title = Lang("WHATSAPP_TITLE"),
            text = Lang("WHATSAPP_LOCATION_SET"),
            icon = "fab fa-whatsapp",
            color = "#25D366",
            timeout = 1500,
        },
    })
end)

RegisterNetEvent('almez-phonev2:client:UpdateMessages')
AddEventHandler('almez-phonev2:client:UpdateMessages', function(ChatMessages, SenderNumber, New)
    local Sender = IsNumberInContacts(SenderNumber)

    local NumberKey = SenderNumber
    for k,v in pairs(PhoneData.Chats) do
        if v.lastmessage then
            v.lastmessage = false
            break
        end
    end
    if New then
        PhoneData.Chats[SenderNumber] = {
            name = Sender,
            number = SenderNumber,
            messages = ChatMessages
        }

        PhoneData.Chats[SenderNumber].lastmessage = true
    
        if PhoneData.Chats[SenderNumber].Unread ~= nil then
            PhoneData.Chats[SenderNumber].Unread = PhoneData.Chats[SenderNumber].Unread + 1
        else
            PhoneData.Chats[SenderNumber].Unread = 1
        end

        if PhoneData.isOpen then
            if SenderNumber ~= PhoneData.PlayerData.charinfo.phone then
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = Lang("WHATSAPP_TITLE"),
                        text = Lang("WHATSAPP_NEW_MESSAGE") .. " "..IsNumberInContacts(SenderNumber).."!",
                        icon = "fab fa-whatsapp",
                        color = "#25D366",
                        timeout = 1500,
                    },
                })
            else
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = Lang("WHATSAPP_TITLE"),
                        text = Lang("WHATSAPP_MESSAGE_TOYOU"),
                        icon = "fab fa-whatsapp",
                        color = "#25D366",
                        timeout = 4000,
                    },
                })
            end
            -- ReorganizeChats(SenderNumber)
            Wait(100)
            QBCore.Functions.TriggerCallback('almez-phonev2:server:GetContactPictures', function(Chats)
                SendNUIMessage({
                    action = "UpdateChat",
                    chatData = Chats[SenderNumber],
                    chatNumber = SenderNumber,
                    Chats = Chats,
                })
            end, PhoneData.Chats)
        else
            SendNUIMessage({
                action = "Notification",
                NotifyData = {
                    title = Lang("TWITTER_TITLE"),
                    content = Lang("WHATSAPP_NEW_MESSAGE") .. " "..IsNumberInContacts(SenderNumber).."!",
                    icon = "fab fa-whatsapp",
                    timeout = 3500,
                    color = "#25D366",
                },
            })
            Config.PhoneApplications['whatsapp'].Alerts = Config.PhoneApplications['whatsapp'].Alerts + 1
            TriggerServerEvent('almez-phonev2:server:SetPhoneAlerts', "whatsapp")
        end
    else
        PhoneData.Chats[NumberKey].messages = ChatMessages
        PhoneData.Chats[NumberKey].lastmessage = true

        if PhoneData.Chats[NumberKey].Unread ~= nil then
            PhoneData.Chats[NumberKey].Unread = PhoneData.Chats[NumberKey].Unread + 1
        else
            PhoneData.Chats[NumberKey].Unread = 1
        end

        if PhoneData.isOpen then
            if SenderNumber ~= PhoneData.PlayerData.charinfo.phone then
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = Lang("WHATSAPP_TITLE"),
                        text = Lang("WHATSAPP_NEW_MESSAGE") .. " " ..IsNumberInContacts(SenderNumber).."!",
                        icon = "fab fa-whatsapp",
                        color = "#25D366",
                        timeout = 1500,
                    },
                })
            else
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = Lang("WHATSAPP_TITLE"),
                        text = Lang("WHATSAPP_MESSAGE_TOYOU"),
                        icon = "fab fa-whatsapp",
                        color = "#25D366",
                        timeout = 4000,
                    },
                })
            end

            NumberKey = SenderNumber
            -- ReorganizeChats(NumberKey)

            Wait(100)
            QBCore.Functions.TriggerCallback('almez-phonev2:server:GetContactPictures', function(Chats)
                SendNUIMessage({
                    action = "UpdateChat",
                    chatData = Chats[SenderNumber],
                    chatNumber = SenderNumber,
                    Chats = Chats,
                })
            end,  PhoneData.Chats)
        else
            SendNUIMessage({
                action = "Notification",
                NotifyData = {
                    title = "Whatsapp",
                    content = Lang("WHATSAPP_NEW_MESSAGE") .. " "..IsNumberInContacts(SenderNumber).."!",
                    icon = "fab fa-whatsapp",
                    timeout = 3500,
                    color = "#25D366",
                },
            })

            NumberKey = SenderNumber
            -- ReorganizeChats(NumberKey)

            Config.PhoneApplications['whatsapp'].Alerts = Config.PhoneApplications['whatsapp'].Alerts + 1
            TriggerServerEvent('almez-phonev2:server:SetPhoneAlerts', "whatsapp")
        end
    end
end)

RegisterNetEvent("almez-phonev2:client:BankNotify")
AddEventHandler("almez-phonev2:client:BankNotify", function(text)
    SendNUIMessage({
        action = "Notification",
        NotifyData = {
            title = Lang("BANK_TITLE"),
            content = text,
            icon = "fas fa-university",
            timeout = 3500,
            color = "#ff002f",
        },
    })
end)

-- Citizen.CreateThread(function()
--     while true do
--         if PhoneData.isOpen then
--             SendNUIMessage({
--                 action = "updateTweets",
--                 tweets = PhoneData.Tweets,
--                 selfTweets = PhoneData.SelfTweets,
--             })
--         end
--         Citizen.Wait(2000)
--     end
-- end)

RegisterNetEvent('almez-phonev2:client:NewMailNotify')
AddEventHandler('almez-phonev2:client:NewMailNotify', function(MailData)
    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = Lang("MAIL_TITLE"),
                text = Lang("MAIL_NEW") .. " " .. MailData.sender,
                icon = "fas fa-envelope",
                color = "#ff002f",
                timeout = 1500,
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = Lang("MAIL_TITLE"),
                content = Lang("MAIL_NEW") .. " " .. MailData.sender,
                icon = "fas fa-envelope",
                timeout = 3500,
                color = "#ff002f",
            },
        })
    end
    Config.PhoneApplications['mail'].Alerts = Config.PhoneApplications['mail'].Alerts + 1
    TriggerServerEvent('almez-phonev2:server:SetPhoneAlerts', "mail")
end)

RegisterNUICallback('PostAdvert', function(data)
    TriggerServerEvent('almez-phonev2:server:AddAdvert', data.message, data.image)
end)

RegisterNetEvent('almez-phonev2:client:UpdateAdverts')
AddEventHandler('almez-phonev2:client:UpdateAdverts', function(Adverts, LastAd)
    PhoneData.Adverts = Adverts

    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = Lang("ADVERTISEMENT_TITLE"),
                text = Lang("ADVERTISEMENT_NEW") .. " " .. LastAd,
                icon = "fas fa-ad",
                color = "#ff8f1a",
                timeout = 2500,
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = Lang("ADVERTISEMENT_TITLE"),
                content = Lang("ADVERTISEMENT_NEW") .. " " .. LastAd,
                icon = "fas fa-ad",
                timeout = 2500,
                color = "#ff8f1a",
            },
        })
    end
    SendNUIMessage({
        action = "RefreshAdverts",
        Adverts = PhoneData.Adverts
    })
end)

RegisterNUICallback('LoadAdverts', function(data, cb)
    -- SendNUIMessage({
    --     action = "RefreshAdverts",
    --     Adverts = PhoneData.Adverts
    -- })
    cb(PhoneData.Adverts)
end)

RegisterNUICallback('ClearAlerts', function(data, cb)
    local ChatKey = data.number

    if PhoneData.Chats[ChatKey].Unread ~= nil then
        local newAlerts = (Config.PhoneApplications['whatsapp'].Alerts - PhoneData.Chats[ChatKey].Unread)
        Config.PhoneApplications['whatsapp'].Alerts = newAlerts
        TriggerServerEvent('almez-phonev2:server:SetPhoneAlerts', "whatsapp", newAlerts)

        PhoneData.Chats[ChatKey].Unread = 0

        SendNUIMessage({
            action = "RefreshWhatsappAlerts",
            Chats = PhoneData.Chats,
        })
        SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
    end
end)

RegisterNUICallback('PayInvoice', function(data, cb)
    local sender = data.sender
    local amount = data.amount
    local invoiceId = data.invoiceId

    QBCore.Functions.TriggerCallback('almez-phonev2:server:CanPayInvoice', function(CanPay)
        if CanPay then
            PayInvoice(cb,invoiceId)
        else
            cb(false)
        end
    end, amount)
end)

function PayInvoice(cb,invoiceId)
    cb(true)
    TriggerServerEvent('gcPhone:faturapayBill', invoiceId)
    Citizen.Wait(1000)
    QBCore.Functions.TriggerCallback('almez-phonev2:server:GetInvoices', function(Invoices, Bank)
        PhoneData.Invoices = Invoices

    end)
end

RegisterNUICallback('DeclineInvoice', function(data, cb)
    local sender = data.sender
    local amount = data.amount
    local invoiceId = data.invoiceId

    QBCore.Functions.TriggerCallback('almez-phonev2:server:DeclineInvoice', function(CanPay, Invoices)
        PhoneData.Invoices = Invoices
        cb('ok')
    end, sender, amount, invoiceId)
end)

RegisterNUICallback('EditContact', function(data, cb)
    local NewName = data.CurrentContactName
    local NewNumber = data.CurrentContactNumber
    local NewIban = data.CurrentContactIban
    local OldName = data.OldContactName
    local OldNumber = data.OldContactNumber
    local OldIban = data.OldContactIban
    local image = data.ContactImage
    for k, v in pairs(PhoneData.Contacts) do
        if v.name == OldName and v.number == OldNumber then
            v.name = NewName
            v.number = NewNumber
            v.iban = NewIban
            v.image = image
        end
    end
    if PhoneData.Chats[NewNumber] ~= nil and next(PhoneData.Chats[NewNumber]) ~= nil then
        PhoneData.Chats[NewNumber].name = NewName
    end
    Citizen.Wait(100)
    cb(PhoneData.Contacts)
    TriggerServerEvent('almez-phonev2:server:EditContact', NewName, NewNumber, NewIban, OldName, OldNumber, OldIban, image)
end)

function GenerateTweetId()
    local tweetId = "TWEET-"..math.random(11111111, 99999999)
    return tweetId
end

RegisterNetEvent('almez-phonev2:client:DeleteHashtags')
AddEventHandler('almez-phonev2:client:DeleteHashtags', function(hashtag)
    SendNUIMessage({
        action = "UpdateHashtags",
        Hashtags = hashtag,
    })
end)


RegisterNetEvent('almez-phonev2:client:UpdateHashtags')
AddEventHandler('almez-phonev2:client:UpdateHashtags', function(Handle, msgData)
    if PhoneData.Hashtags[Handle] ~= nil then
        table.insert(PhoneData.Hashtags[Handle].messages, msgData)
    else
        PhoneData.Hashtags[Handle] = {
            messages = {}
        }
        table.insert(PhoneData.Hashtags[Handle].messages, msgData)
    end

    SendNUIMessage({
        action = "UpdateHashtags",
        Hashtags = PhoneData.Hashtags,
    })
end)



RegisterNUICallback('GetHashtagMessages', function(data, cb)
    if PhoneData.Hashtags[data.hashtag] ~= nil and next(PhoneData.Hashtags[data.hashtag]) ~= nil then
        cb(PhoneData.Hashtags[data.hashtag])
    else
        cb(nil)
    end
end)

local function getIndex(tab, val)
    local index = nil
    for i, v in ipairs (tab) do
        if (v.id == val) then
          index = i
          break
        end
    end
    return index
end

local invopened = false

RegisterNetEvent("almez-phonev2:invopened")
AddEventHandler("almez-phonev2:invopened", function(bool)
    invopened = bool
end)


RegisterNUICallback('isInHomePage', function(data, cb)

end)

RegisterNUICallback('DeleteTweet', function(data, cb)
    TriggerServerEvent("almez-phonev2:deleteTweet", data.id)
    local idx = getIndex(PhoneData.SelfTweets, data.id)
    local idx2 = getIndex(PhoneData.Tweets, data.id)
    -- local idx3 = getIndex(PhoneData.MentionedTweets, data.id)

    table.remove(PhoneData.SelfTweets,idx)
    table.remove(PhoneData.Tweets,idx2)
    -- table.remove(PhoneData.MentionedTweets,idx3)

    for k,v in pairs(PhoneData.Hashtags) do 
        for i = 1, #v.messages do 
            if data.id == v.messages[i].id then
                table.remove(v.messages, i)
                break
            end
        end
    end
    TriggerServerEvent('almez-phonev2:server:updateForEveryone', PhoneData)
end)

RegisterNUICallback('GetTweets', function(data, cb)
    cb(PhoneData.Tweets)
end)

RegisterNUICallback('GetCitizenId', function(data, cb)
    cb(PhoneData.PlayerData.citizenid)
end)

RegisterNUICallback('GetSelfTweets', function(data, cb)
    cb(PhoneData.SelfTweets)
end)


RegisterNUICallback('UpdateProfilePicture', function(data)
    local pf = data.profilepicture

    TriggerServerEvent('almez-phonev2:server:SaveMetaData', 'profilepicture', pf)
end)

local patt = "[?!@#]"

RegisterNetEvent("almez-phonev2:updateForEveryone")
AddEventHandler("almez-phonev2:updateForEveryone", function(tweets,mention,hash,selftweets)
    PhoneData.Tweets = tweets
    -- PhoneData.SelfTweets = selftweets
    -- PhoneData.MentionedTweets = mention
    SendNUIMessage({
        action = "updateTweets",
        tweets = PhoneData.Tweets,
        selfTweets = PhoneData.SelfTweets,
    })
    PhoneData.Hashtags = hash
    SendNUIMessage({
        action = "UpdateHashtags",
        Hashtags = PhoneData.Hashtags,
    })

end)

RegisterNetEvent("almez-phonev2:updateidForEveryone")
AddEventHandler("almez-phonev2:updateidForEveryone", function()
    PhoneData.id  = PhoneData.id + 1
    -- SendNUIMessage({
    --     action = "updateTweets",
    --     tweets = PhoneData.Tweets,
    --     selfTweets = PhoneData.SelfTweets,
    -- })
end)

RegisterNUICallback('PostNewTweet', function(data, cb)
    local TweetMessage = {
        firstName = PhoneData.PlayerData.charinfo.firstname,
        lastName = PhoneData.PlayerData.charinfo.lastname,
        message = data.Message,
        url = data.url,
        time = data.Date,
        id =  PhoneData.id,
        picture = data.Picture,
        hashtag = data.Hashtag,
    }
    TriggerServerEvent("almez-phonev2:saveTwitterToDatabase", TweetMessage.firstName, TweetMessage.lastName, TweetMessage.message, TweetMessage.url, TweetMessage.time, TweetMessage.picture, TweetMessage.hashtag, PhoneData.id)
    TriggerServerEvent("almez-phonev2:server:updateidForEveryone")
    local TwitterMessage = data.Message
    local MentionTag = TwitterMessage:split("@")
    local Hashtag = TwitterMessage:split("#")

    -- for i = 2, #Hashtag, 1 do
    --     local Handle = Hashtag[i]:split(" ")[1]
    --     if Handle ~= nil or Handle ~= "" then
    --         local InvalidSymbol = string.match(Handle, patt)
    --         if InvalidSymbol then
    --             Handle = Handle:gsub("%"..InvalidSymbol, "")
    --         end
            -- TriggerServerEvent('almez-phonev2:server:UpdateHashtags', Handle, TweetMessage)
    if data.Hashtag ~= nil then
            TriggerServerEvent('almez-phonev2:server:UpdateHashtags', data.Hashtag, TweetMessage)
    --     end
    end

    for i = 2, #MentionTag, 1 do
        local Handle = MentionTag[i]:split(" ")[1]
        if Handle ~= nil or Handle ~= "" then
            local Fullname = Handle:split("_")
            local Firstname = Fullname[1]
            table.remove(Fullname, 1)
            local Lastname = table.concat(Fullname, " ")

            if (Firstname ~= nil and Firstname ~= "") and (Lastname ~= nil and Lastname ~= "") then
                if Firstname ~= PhoneData.PlayerData.charinfo.firstname and Lastname ~= PhoneData.PlayerData.charinfo.lastname then
                    TriggerServerEvent('almez-phonev2:server:MentionedPlayer', Firstname, Lastname, TweetMessage)
                else
                    SetTimeout(2500, function()
                        SendNUIMessage({
                            action = "PhoneNotification",
                            PhoneNotify = {
                                title = Lang("TWITTER_TITLE"),
                                text = Lang("MENTION_YOURSELF"),
                                icon = "fab fa-twitter",
                                color = "#1DA1F2",
                            },
                        })
                    end)
                end
            end
        end
    end
    Citizen.Wait(200) --test123
    table.insert(PhoneData.Tweets, TweetMessage)
    table.insert(PhoneData.SelfTweets, TweetMessage)
    TriggerServerEvent('almez-phonev2:server:updateForEveryone', PhoneData)
    cb(PhoneData.Tweets)
    TriggerServerEvent('almez-phonev2:server:UpdateTweets', TweetMessage)
    SendNUIMessage({
        action= "updateTest",
        selftTweets= PhoneData.SelfTweets
    })
end)


local takePhoto = false
RegisterNUICallback('PostNewImage', function(data, cb)
    SetNuiFocus(false, false)
    CreateMobilePhone(1)
    CellCamActivate(true, true)
    takePhoto = true
    while takePhoto do
        Citizen.Wait(0)
        if IsControlJustPressed(1, 27) then -- Toogle Mode
            frontCam = not frontCam
            CellFrontCamActivate(frontCam)
        elseif IsControlJustPressed(1, 177) then -- CANCEL
			DestroyMobilePhone()
			CellCamActivate(false, false)
            cb(nil)
			takePhoto = false
			break
        elseif IsControlJustPressed(1, 176) then
            exports['screenshot-basic']:requestScreenshotUpload(Config.Webhook, 'files[]', function(data2)
                local resp = json.decode(data2)
                DestroyMobilePhone()
                CellCamActivate(false, false)
                cb(resp.attachments[1].proxy_url)
            end)
            takePhoto = false
            break
        end
        HideHudComponentThisFrame(7)
		HideHudComponentThisFrame(8)
		HideHudComponentThisFrame(9)
		HideHudComponentThisFrame(6)
		HideHudComponentThisFrame(19)
        HideHudAndRadarThisFrame()
    end
    DestroyMobilePhone()
	CellCamActivate(false, false)
    OpenPhone()
    
end)

RegisterNetEvent('almez-phonev2:client:TransferMoney')
AddEventHandler('almez-phonev2:client:TransferMoney', function(amount, newmoney)
    if PhoneData.isOpen then
        SendNUIMessage({ action = "UpdateBank", NewBalance = newmoney })
    end
end)

RegisterNetEvent('almez-phonev2:client:UpdateTweets')
AddEventHandler('almez-phonev2:client:UpdateTweets', function(src, NewTweetData)
--
end)

RegisterNUICallback('GetMentionedTweets', function(data, cb)
    cb(PhoneData.MentionedTweets)
end)

RegisterNUICallback('GetHashtags', function(data, cb)
    if PhoneData.Hashtags ~= nil and next(PhoneData.Hashtags) ~= nil then
        cb(PhoneData.Hashtags)
    else
        cb(nil)
    end
end)

RegisterNetEvent('almez-phonev2:client:GetMentioned')
AddEventHandler('almez-phonev2:client:GetMentioned', function(TweetMessage, AppAlerts)
    Config.PhoneApplications["twitter"].Alerts = AppAlerts
    if not PhoneData.isOpen then
        SendNUIMessage({ action = "Notification", NotifyData = { title = Lang("TWITTER_GETMENTIONED"), content = TweetMessage.message, icon = "fab fa-twitter", timeout = 3500, color = nil, }, })
    else
        SendNUIMessage({ action = "PhoneNotification", PhoneNotify = { title = Lang("TWITTER_GETMENTIONED"), text = TweetMessage.message, icon = "fab fa-twitter", color = "#1DA1F2", }, })
    end
    local TweetMessage = {firstName = TweetMessage.firstName, lastName = TweetMessage.lastName, message = TweetMessage.message, time = TweetMessage.time, picture = TweetMessage.picture}
    table.insert(PhoneData.MentionedTweets, TweetMessage)
    SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
    SendNUIMessage({ action = "UpdateMentionedTweets", Tweets = PhoneData.MentionedTweets })
end)

RegisterNUICallback('ClearMentions', function()
    Config.PhoneApplications["twitter"].Alerts = 0
    SendNUIMessage({
        action = "RefreshAppAlerts",
        AppData = Config.PhoneApplications
    })
    TriggerServerEvent('almez-phonev2:server:SetPhoneAlerts', "twitter", 0)
    SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
end)

RegisterNUICallback('ClearGeneralAlerts', function(data)
    SetTimeout(400, function()
        Config.PhoneApplications[data.app].Alerts = 0
        SendNUIMessage({
            action = "RefreshAppAlerts",
            AppData = Config.PhoneApplications
        })
        TriggerServerEvent('almez-phonev2:server:SetPhoneAlerts', data.app, 0)
        SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
    end)
end)

function string:split(delimiter)
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find( self, delimiter, from  )
    while delim_from do
      table.insert( result, string.sub( self, from , delim_from-1 ) )
      from  = delim_to + 1
      delim_from, delim_to = string.find( self, delimiter, from  )
    end
    table.insert( result, string.sub( self, from  ) )
    return result
end

RegisterNUICallback('TransferMoney', function(data, callback)
    local cb = callback
    local amount = tonumber(data.amount)

    QBCore.Functions.TriggerCallback('almez-phonev2:server:TransferMoney', function(transfer, bankdata, message)
        if transfer then
            local amaountata = tonumber(bankdata) - amount
            local cbdata = {
                CanTransfer = true,
                Message = nil,
                NewAmount = amaountata
            }
            cb(cbdata)
        else
            local cbdata = {
                CanTransfer = false,
                Message = message,
                NewAmount = nil,
            }
            cb(cbdata)
        end
    end,data.iban, amount, data.description)
end)

RegisterNUICallback('GetWhatsappChats', function(data, cb)
    QBCore.Functions.TriggerCallback('almez-phonev2:server:GetContactPictures', function(Chats)
        cb(Chats)
    end, PhoneData.Chats)
end)

RegisterNUICallback('CallContact', function(data, cb)
    QBCore.Functions.TriggerCallback('almez-phonev2:server:GetCallState', function(CanCall, IsOnline, IsAvailable)
        local status = {
            CanCall = CanCall,
            IsOnline = IsOnline,
            InCall = PhoneData.CallData.InCall,
            IsAvailable = IsAvailable,
            image = data.ContactData.image
        }
        
        cb(status)
        if CanCall and not status.InCall and (data.ContactData.number ~= PhoneData.PlayerData.charinfo.phone) and not IsAvailable then
            CallContact(data.ContactData, data.Anonymous)
        end
    end, data.ContactData)
end)

RegisterNUICallback("UpdateAvailableStatus", function(data, cb)
    TriggerServerEvent("almez-phonev2:UpdateAvailableStatus", data.available)
    cb("ok")
end)

function GenerateCallId(caller, target)
    local CallId = math.ceil(((tonumber(caller) + tonumber(target)) / 100 * 1))
    return CallId
end

CallContact = function(CallData, AnonymousCall)
    local RepeatCount = 0
    PhoneData.CallData.CallType = "outgoing"
    PhoneData.CallData.InCall = true
    PhoneData.CallData.TargetData = CallData
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.CallId = GenerateCallId(PhoneData.PlayerData.charinfo.phone, CallData.number)


    TriggerServerEvent('almez-phonev2:server:CallContact', PhoneData.CallData.TargetData, PhoneData.CallData.CallId, AnonymousCall)
    TriggerServerEvent('almez-phonev2:server:SetCallState', true)

    for i = 1, Config.CallRepeats + 1, 1 do
        if not PhoneData.CallData.AnsweredCall then
            if RepeatCount + 1 ~= Config.CallRepeats + 1 then
                if PhoneData.CallData.InCall then
                    RepeatCount = RepeatCount + 1
                    TriggerServerEvent("InteractSound_SV:PlayOnSource", "demo", 0.1)
                else
                    break
                end
                Citizen.Wait(Config.RepeatTimeout)
            else
                CancelCall()
                break
            end
        else
            break
        end
    end
end

Citizen.CreateThread(function()
    while true do
        if not PhoneData.isOpen then 
            SetNuiFocusKeepInput(false, false)
        end
        Citizen.Wait(1000)
    end
end)

CancelCall = function()
    TriggerServerEvent('almez-phonev2:server:CancelCall', GetPlayerServerId(PlayerId()), PhoneData.CallData)
    if PhoneData.CallData.CallType == "ongoing" then
        -- if Config.Tokovoip then
        --     exports.tokovoip_script:removePlayerFromRadio(PhoneData.CallData.CallId)
        -- else
        --     exports["mumble-voip"]:SetCallChannel(0)
        -- end
    end
    
    PhoneData.CallData.CallType = nil
    PhoneData.CallData.InCall = false
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.TargetData = {}
    PhoneData.CallData.CallId = nil

    if not PhoneData.isOpen then
        StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
        deletePhone()
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
    else
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
    end

    TriggerServerEvent('almez-phonev2:server:SetCallState', false)

    if not PhoneData.isOpen then
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = Lang("PHONE_TITLE"),
                content = Lang("PHONE_CALL_END"),
                icon = "fas fa-phone-volume",
                timeout = 3500,
                color = "#e84118",
            },
        })
    else
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = Lang("PHONE_TITLE"),
                text = Lang("PHONE_CALL_END"),
                icon = "fas fa-phone-volume",
                color = "#e84118",
            },
        })

        SendNUIMessage({
            action = "SetupHomeCall",
            CallData = PhoneData.CallData,
        })

        SendNUIMessage({
            action = "CancelOutgoingCall",
        })
    end
end

RegisterNetEvent('almez-phonev2:client:CancelCall')
AddEventHandler('almez-phonev2:client:CancelCall', function()
    if PhoneData.CallData.CallType == "ongoing" then
        SendNUIMessage({
            action = "CancelOngoingCall"
        })

    end
    PhoneData.CallData.CallType = nil
    PhoneData.CallData.InCall = false
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.TargetData = {}

    if not PhoneData.isOpen then
        StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
        deletePhone()
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
    else
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
    end

    TriggerServerEvent('almez-phonev2:server:SetCallState', false)

    if not PhoneData.isOpen then
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = Lang("PHONE_TITLE"),
                content = Lang("PHONE_CALL_END"),
                icon = "fas fa-phone-volume",
                timeout = 3500,
                color = "#e84118",
            },
        })
    else
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = Lang("PHONE_TITLE"),
                text = Lang("PHONE_CALL_END"),
                icon = "fas fa-phone-volume",
                color = "#e84118",
            },
        })

        SendNUIMessage({
            action = "SetupHomeCall",
            CallData = PhoneData.CallData,
        })

        SendNUIMessage({
            action = "CancelOutgoingCall",
        })
    end
end)

RegisterNetEvent('almez-phonev2:client:GetCalled')
AddEventHandler('almez-phonev2:client:GetCalled', function(CallerNumber, CallId, AnonymousCall)
    local RepeatCount = 0
    local CallData = {
        number = CallerNumber,
        name = IsNumberInContacts(CallerNumber),
        anonymous = AnonymousCall
    }


    if AnonymousCall then
        CallData.name = "Gizli Numara"
    end

    PhoneData.CallData.CallType = "incoming"
    PhoneData.CallData.InCall = true
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.TargetData = CallData
    PhoneData.CallData.CallId = CallId

    TriggerServerEvent('almez-phonev2:server:SetCallState', true)

    SendNUIMessage({
        action = "SetupHomeCall",
        CallData = PhoneData.CallData,
    })

    for i = 1, Config.CallRepeats + 1, 1 do
        if not PhoneData.CallData.AnsweredCall then
            if RepeatCount + 1 ~= Config.CallRepeats + 1 then
                if PhoneData.CallData.InCall then
                    RepeatCount = RepeatCount + 1
                    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 2.5, "ringing", 0.1)
                    if not PhoneData.isOpen then
                        SendNUIMessage({
                            action = "IncomingCallAlert",
                            CallData = PhoneData.CallData.TargetData,
                            Canceled = false,
                            AnonymousCall = AnonymousCall,
                        })
                    end
                else
                    SendNUIMessage({
                        action = "IncomingCallAlert",
                        CallData = PhoneData.CallData.TargetData,
                        Canceled = true,
                        AnonymousCall = AnonymousCall,
                    })
                    TriggerServerEvent('almez-phonev2:server:AddRecentCall', "missed", CallData)
                    break
                end
                Citizen.Wait(Config.RepeatTimeout)
            else
                SendNUIMessage({
                    action = "IncomingCallAlert",
                    CallData = PhoneData.CallData.TargetData,
                    Canceled = true,
                    AnonymousCall = AnonymousCall,
                })
                TriggerServerEvent('almez-phonev2:server:AddRecentCall', "missed", CallData)
                break
            end
        else
            TriggerServerEvent('almez-phonev2:server:AddRecentCall', "missed", CallData)
            break
        end
    end
end)

RegisterNUICallback('CancelOutgoingCall', function()
    CancelCall()
end)

RegisterNUICallback('DenyIncomingCall', function()
    CancelCall()
end)

RegisterNUICallback('CancelOngoingCall', function()
    CancelCall()
end)

RegisterNUICallback('AnswerCall', function()
    AnswerCall()
end)

function AnswerCall()
    if (PhoneData.CallData.CallType == "incoming" or PhoneData.CallData.CallType == "outgoing") and PhoneData.CallData.InCall and not PhoneData.CallData.AnsweredCall then
        PhoneData.CallData.CallType = "ongoing"
        PhoneData.CallData.AnsweredCall = true
        PhoneData.CallData.CallTime = 0

        SendNUIMessage({ action = "AnswerCall", CallData = PhoneData.CallData})
        SendNUIMessage({ action = "SetupHomeCall", CallData = PhoneData.CallData})

        TriggerServerEvent('almez-phonev2:server:SetCallState', true)

        if PhoneData.isOpen then
            DoPhoneAnimation('cellphone_text_to_call')
        else
            DoPhoneAnimation('cellphone_call_listen_base')
        end

        Citizen.CreateThread(function()
            while true do
                if PhoneData.CallData.AnsweredCall then
                    PhoneData.CallData.CallTime = PhoneData.CallData.CallTime + 1
                    SendNUIMessage({
                        action = "UpdateCallTime",
                        Time = PhoneData.CallData.CallTime,
                        Name = PhoneData.CallData.TargetData.name,
                    })
                else
                    break
                end

                Citizen.Wait(1000)
            end
        end)

        TriggerServerEvent('almez-phonev2:server:AnswerCall', GetPlayerServerId(PlayerId()), PhoneData.CallData)
        -- if Config.Tokovoip then
        --         exports.tokovoip_script:addPlayerToRadio(PhoneData.CallData.CallId, 'Phone')
        -- else
        --     exports["mumble-voip"]:SetCallChannel(PhoneData.CallData+1)
        -- end
    else
        PhoneData.CallData.InCall = false
        PhoneData.CallData.CallType = nil
        PhoneData.CallData.AnsweredCall = false

        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = Lang("PHONE_TITLE"),
                text = Lang("PHONE_NOINCOMING"),
                icon = "fas fa-phone-volume",
                color = "#e84118",
            },
        })
    end
end

RegisterNUICallback("getDataFromNumber", function(data, cb)
    local found = false
    for k,v in pairs(PhoneData.Contacts) do
        if v.number == data.number then
            found = true
            cb({image = v.image, name = v.name})
            return
        end
    end   
    if not found then
        cb({image = "", name = false})
    end
end)

RegisterNUICallback("getImageFromNumber", function(data, cb)
    local found = false
    for k,v in pairs(PhoneData.Contacts) do
        if v.number == data.number then
            found = true
            cb(v.image)
            return
        end
    end   
    if not found then
        cb("")
    end
end)

RegisterNetEvent('almez-phonev2:client:AnswerCall')
AddEventHandler('almez-phonev2:client:AnswerCall', function()
    if (PhoneData.CallData.CallType == "incoming" or PhoneData.CallData.CallType == "outgoing") and PhoneData.CallData.InCall and not PhoneData.CallData.AnsweredCall then
        PhoneData.CallData.CallType = "ongoing"
        PhoneData.CallData.AnsweredCall = true
        PhoneData.CallData.CallTime = 0
        SendNUIMessage({ action = "AnswerCall", CallData = PhoneData.CallData})
        SendNUIMessage({ action = "SetupHomeCall", CallData = PhoneData.CallData})

        TriggerServerEvent('almez-phonev2:server:SetCallState', true)
        -- if not CS_VIDEO_CALL.ACTIVE then
            if not PhoneData.CallData.InCall  then
                DoPhoneAnimation('cellphone_text_to_call')
            else
                DoPhoneAnimation('cellphone_call_listen_base')
            end
        -- end

        Citizen.CreateThread(function()
            while true do
                if PhoneData.CallData.AnsweredCall then
                    PhoneData.CallData.CallTime = PhoneData.CallData.CallTime + 1
                    SendNUIMessage({
                        action = "UpdateCallTime",
                        Time = PhoneData.CallData.CallTime,
                        Name = PhoneData.CallData.TargetData.name,
                    })
                else
                    break
                end

                Citizen.Wait(1000)
            end
        end)
        -- if Config.Tokovoip then 
        --     exports.tokovoip_script:addPlayerToRadio(PhoneData.CallData.CallId, 'Phone')
        -- else
        --     exports["mumble-voip"]:SetCallChannel(PhoneData.CallData+1)
        -- end
    else
        PhoneData.CallData.InCall = false
        PhoneData.CallData.CallType = nil
        PhoneData.CallData.AnsweredCall = false

        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = Lang("PHONE_TITLE"),
                text = Lang("PHONE_NOINCOMING"),
                icon = "fas fa-phone-volume",
                color = "#e84118",
            },
        })
    end
end)

AddEventHandler('onResourceStop', function(resource)
     if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
     end
end)

RegisterNUICallback("fizzfau-inputcheck", function(data)
    SetNuiFocusKeepInput(data.input)
end)

RegisterNUICallback('FetchSearchResults', function(data, cb)
    QBCore.Functions.TriggerCallback('almez-phonev2:server:FetchResult', function(result)
        cb(result)
    end, data.input)
end)

RegisterNUICallback('FetchVehicleResults', function(data, cb)
    QBCore.Functions.TriggerCallback('almez-phonev2:server:GetVehicleSearchResults', function(result)
        if result ~= nil then
            for k, v in pairs(result) do
                result[k].isFlagged = false
            end
        end
        cb(result)
    end, data.input)
end)

RegisterNUICallback('FetchVehicleScan', function(data, cb)
    local vehicle = QBCore.Game.GetClosestVehicle()
    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetEntityModel(vehicle)

    QBCore.Functions.TriggerCallback('almez-phonev2:server:ScanPlate', function(result)
        result.isFlagged = false
        result.label = model
        cb(result)
    end, plate)
end)

RegisterNetEvent('almez-phonev2:client:addPoliceAlert')
AddEventHandler('almez-phonev2:client:addPoliceAlert', function(alertData)
    if PlayerJob.name == 'police' then
        SendNUIMessage({
            action = "AddPoliceAlert",
            alert = alertData,
        })
    end
end)

RegisterNUICallback('SetAlertWaypoint', function(data)
    local coords = data.alert.coords

    TriggerEvent('notification', Lang("GPS_SET") .. data.alert.title)
    SetNewWaypoint(coords.x, coords.y)
end)

RegisterNUICallback('RemoveSuggestion', function(data, cb)
    local data = data.data

    if PhoneData.SuggestedContacts ~= nil and next(PhoneData.SuggestedContacts) ~= nil then
        for k, v in pairs(PhoneData.SuggestedContacts) do
            if (data.name[1] == v.name[1] and data.name[2] == v.name[2]) and data.number == v.number and data.bank == v.bank then
                table.remove(PhoneData.SuggestedContacts, k)
            end
        end
    end
end)

RegisterNetEvent('almez-phonev2:client:GiveContactDetails')
AddEventHandler('almez-phonev2:client:GiveContactDetails', function()
    local ped = PlayerPedId()

    local player, distance = QBCore.Game.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local PlayerId = GetPlayerServerId(player)
        TriggerServerEvent('almez-phonev2:server:GiveContactDetails', PlayerId)
    else
        TriggerEvent('notification', Lang("NO_ONE"), 2)
    end
end)

RegisterNUICallback('DeleteContact', function(data, cb)
    local Name = data.CurrentContactName
    local Number = data.CurrentContactNumber
    local Account = data.CurrentContactIban

    for k, v in pairs(PhoneData.Contacts) do
        if v.name == Name and v.number == Number then
            table.remove(PhoneData.Contacts, k)
            if PhoneData.isOpen then
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = Lang("PHONE_TITLE"),
                        text = Lang("CONTACTS_REMOVED"),
                        icon = "fas fa-phone-volume",
                        color = "#04b543",
                        timeout = 1500,
                    },
                })
            else
                SendNUIMessage({
                    action = "Notification",
                    NotifyData = {
                        title = Lang("PHONE_TITLE"),
                        content = Lang("CONTACTS_REMOVED"),
                        icon = "fas fa-phone-volume",
                        timeout = 3500,
                        color = "#04b543",
                    },
                })
            end
            break
        end
    end
    Citizen.Wait(100)
    cb(PhoneData.Contacts)
    if PhoneData.Chats[Number] ~= nil and next(PhoneData.Chats[Number]) ~= nil then
        PhoneData.Chats[Number].name = Number
    end
    TriggerServerEvent('almez-phonev2:server:RemoveContact', Name, Number)
end)

RegisterNetEvent('almez-phonev2:client:AddNewSuggestion')
AddEventHandler('almez-phonev2:client:AddNewSuggestion', function(SuggestionData)
    table.insert(PhoneData.SuggestedContacts, SuggestionData)

    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = Lang("PHONE_TITLE"),
                text = Lang("CONTACTS_NEWSUGGESTED"),
                icon = "fa fa-phone-alt",
                color = "#04b543",
                timeout = 1500,
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = Lang("PHONE_TITLE"),
                content = Lang("CONTACTS_NEWSUGGESTED"),
                icon = "fa fa-phone-alt",
                timeout = 3500,
                color = "#04b543",
            },
        })
    end

    Config.PhoneApplications["phone"].Alerts = Config.PhoneApplications["phone"].Alerts + 1
    TriggerServerEvent('almez-phonev2:server:SetPhoneAlerts', "phone", Config.PhoneApplications["phone"].Alerts)
end)

RegisterNUICallback('GetCryptoData', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-crypto:server:GetCryptoData', function(CryptoData)
        cb(CryptoData)
    end, data.crypto)
end)

RegisterNUICallback('BuyCrypto', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-crypto:server:BuyCrypto', function(CryptoData)
        cb(CryptoData)
    end, data)
end)

RegisterNUICallback('SellCrypto', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-crypto:server:SellCrypto', function(CryptoData)
        cb(CryptoData)
    end, data)
end)

RegisterNUICallback('TransferCrypto', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-crypto:server:TransferCrypto', function(CryptoData)
        cb(CryptoData)
    end, data)
end)

RegisterNetEvent('almez-phonev2:client:RemoveBankMoney')
AddEventHandler('almez-phonev2:client:RemoveBankMoney', function(amount)
    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = Lang("BANK_TITLE"),
                text = "There is Γé¼"..amount.." withdraw from your bank!",
                icon = "fas fa-university",
                color = "#ff002f",
                timeout = 3500,
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = Lang("BANK_TITLE"),
                content = "There is Γé¼"..amount.." withdraw from your bank!",
                icon = "fas fa-university",
                timeout = 3500,
                color = "#ff002f",
            },
        })
    end
end)

RegisterNetEvent('almez-phonev2:client:AddTransaction')
AddEventHandler('almez-phonev2:client:AddTransaction', function(Title, Message, SenderData, TransactionData)
    local Data = {
        TransactionTitle = Title,
        TransactionMessage = Message,
    }

    table.insert(PhoneData.CryptoTransactions, Data)

    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = Lang("CRYPTO_TITLE"),
                text = Message,
                icon = "fas fa-chart-pie",
                color = "#04b543",
                timeout = 1500,
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = Lang("CRYPTO_TITLE"),
                content = Message,
                icon = "fas fa-chart-pie",
                timeout = 3500,
                color = "#04b543",
            },
        })
    end

    SendNUIMessage({
        action = "UpdateTransactions",
        CryptoTransactions = PhoneData.CryptoTransactions
    })

    TriggerServerEvent('almez-phonev2:server:AddTransaction', Data)
end)

RegisterNUICallback('GetCryptoTransactions', function(data, cb)
    local Data = {
        CryptoTransactions = PhoneData.CryptoTransactions
    }
    cb(Data)
end)

RegisterNUICallback('GetAvailableRaces', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-lapraces:server:GetRaces', function(Races)
        cb(Races)
    end)
end)

RegisterNUICallback('JoinRace', function(data)
    TriggerServerEvent('qb-lapraces:server:JoinRace', data.RaceData)
end)

RegisterNUICallback('LeaveRace', function(data)
    TriggerServerEvent('qb-lapraces:server:LeaveRace', data.RaceData)
end)

RegisterNUICallback('StartRace', function(data)
    TriggerServerEvent('qb-lapraces:server:StartRace', data.RaceData.RaceId)
end)

RegisterNetEvent('almez-phonev2:client:UpdateLapraces')
AddEventHandler('almez-phonev2:client:UpdateLapraces', function()
    SendNUIMessage({
        action = "UpdateRacingApp",
    })
end)

RegisterNUICallback('GetRaces', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-lapraces:server:GetListedRaces', function(Races)
        cb(Races)
    end)
end)

RegisterNUICallback('GetTrackData', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-lapraces:server:GetTrackData', function(TrackData, CreatorData)
        TrackData.CreatorData = CreatorData
        cb(TrackData)
    end, data.RaceId)
end)

RegisterNUICallback('SetupRace', function(data, cb)
    TriggerServerEvent('qb-lapraces:server:SetupRace', data.RaceId, tonumber(data.AmountOfLaps))
end)

RegisterNUICallback('HasCreatedRace', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-lapraces:server:HasCreatedRace', function(HasCreated)
        cb(HasCreated)
    end)
end)

RegisterNUICallback('IsInRace', function(data, cb)
    local InRace = false
    cb(InRace)
end)

RegisterNUICallback('IsAuthorizedToCreateRaces', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-lapraces:server:IsAuthorizedToCreateRaces', function(NameAvailable)
        local data = {
            IsAuthorized = true,
            IsBusy = false,
            IsNameAvailable = NameAvailable,
        }
        cb(data)
    end, data.TrackName)
end)

RegisterNUICallback('StartTrackEditor', function(data, cb)
    TriggerServerEvent('qb-lapraces:server:CreateLapRace', data.TrackName)
end)

RegisterNUICallback('GetRacingLeaderboards', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-lapraces:server:GetRacingLeaderboards', function(Races)
        cb(Races)
    end)
end)

RegisterNUICallback('RaceDistanceCheck', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-lapraces:server:GetRacingData', function(RaceData)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local checkpointcoords = RaceData.Checkpoints[1].coords
        local dist = GetDistanceBetweenCoords(coords, checkpointcoords.x, checkpointcoords.y, checkpointcoords.z, true)
        if dist <= 115.0 then
            if data.Joined then
                TriggerEvent('qb-lapraces:client:WaitingDistanceCheck')
            end
            cb(true)
        else
            TriggerEvent('notification', 'You are too far from the race. Your navigation is set to the race.', 2)
            SetNewWaypoint(checkpointcoords.x, checkpointcoords.y)
            cb(false)
        end
    end, data.RaceId)
end)

RegisterNUICallback('IsBusyCheck', function(data, cb)
    if data.check == "editor" then
        cb(false)
    else
        cb(false)
    end
end)

RegisterNUICallback('CanRaceSetup', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-lapraces:server:CanRaceSetup', function(CanSetup)
        cb(CanSetup)
    end)
end)

RegisterNUICallback('GetPlayerHouses', function(data, cb)
    QBCore.Functions.TriggerCallback('almez-phonev2:server:GetPlayerHouses', function(Houses)
        cb(Houses)
    end)
end)

RegisterNUICallback('RemoveKeyholder', function(data)
    TriggerServerEvent('qb-houses:server:removeHouseKey', data.HouseData.name, {
        identifier = data.HolderData.identifier,
        firstname = data.HolderData.charinfo.firstname,
        lastname = data.HolderData.charinfo.lastname,
    })
end)

RegisterNUICallback('FetchPlayerHouses', function(data, cb)
    QBCore.Functions.TriggerCallback('almez-phonev2:server:MeosGetPlayerHouses', function(result)
        cb(result)
    end, data.input)
end)

RegisterNUICallback('SetGPSLocation', function(data, cb)
    local ped = PlayerPedId()

    SetNewWaypoint(data.coords.x, data.coords.y)
    TriggerEvent('notification', 'Lokasyon haritada işaretlendi!')
end)

RegisterNUICallback('SetApartmentLocation', function(data, cb)
    local ApartmentData = data.data.appartmentdata
    local TypeData = Apartments.Locations[ApartmentData.type]

    SetNewWaypoint(TypeData.coords.enter.x, TypeData.coords.enter.y)
    TriggerEvent('notification', 'GPS is set!')
end)

RegisterNUICallback('GetCurrentLawyers', function(data, cb)
    QBCore.Functions.TriggerCallback('cash-telephone:server:GetCurrentLawyers', function(lawyers)
        cb(lawyers)
    end)
end)

RegisterNUICallback('GetCurrentpolices', function(data, cb)
    QBCore.Functions.TriggerCallback('cash-telephone:server:GetCurrentpolices', function(lawyers)
        cb(lawyers)
    end)
end)

RegisterNUICallback("GetCurrentDrivers", function(data, cb)
    QBCore.Functions.TriggerCallback('cash-telephone:server:GetCurrentDrivers', function(drivers)
        cb(drivers)
    end)
end)

RegisterNUICallback("GetCurrentMecano", function(data, cb)
    QBCore.Functions.TriggerCallback('cash-telephone:server:GetCurrentMecano', function(drivers)
        cb(drivers)
    end)
end)

RegisterNUICallback("GetCurrentDoctor", function(data, cb)
    QBCore.Functions.TriggerCallback('cash-telephone:server:GetCurrentDoctor', function(drivers)
        cb(drivers)
    end)
end)

Lang = function(item)
    local lang = Config.Languages[Config.Language]

    if lang and lang[item] then
        return lang[item]
    end

    return item
end

RegisterNUICallback('GetLangData', function(data, cb)
    cb({ table = Config.Languages, current = Config.Language })
end)

-- RegisterCommand('test', function()
--     TriggerServerEvent("almez-phonev2:server:sendNewMail", { sender = "FireLeaf", subject = "Test!", message = "https://discord.gg/BYK9XEP2sz"})
-- end)


RegisterCommand("telfix", function()
    SendNUIMessage({
        action = "close",
    })
    if not PhoneData.CallData.InCall then
        DoPhoneAnimation('cellphone_text_out')
        SetTimeout(400, function()
            StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
            deletePhone()
            PhoneData.AnimationData.lib = nil
            PhoneData.AnimationData.anim = nil
        end)
    else
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
        DoPhoneAnimation('cellphone_text_to_call')
    end
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SetTimeout(500, function()
        PhoneData.isOpen = false
    end)
end)

RegisterNUICallback("LikedTweet", function(data, cb)
    QBCore.Functions.TriggerCallback("fizzfau-phone:LikedTweet", function(MyLikes, TweetLikes)
        for k, v in pairs(PhoneData.Tweets) do
            for i,j in pairs(MyLikes[PhoneData.PlayerData.citizenid]) do
                if v.id == i then
                    v.liked = j
                    v.count = TweetLikes[i]
                end
            end
        end
        cb(PhoneData.Tweets)
    end, data)
end)

RegisterNetEvent("fizzfau-phone:updateLikes")
AddEventHandler("fizzfau-phone:updateLikes", function(id, TweetLikes)
    for k, v in pairs(PhoneData.Tweets) do
        if v.id == id then
            v.count = TweetLikes[id]
        end
    end
end)

RegisterNUICallback("SetAlarm", function(data)
    PhoneData.Alarms[#PhoneData.Alarms + 1] = data.clock
end)

RegisterNUICallback("GetAlarmData", function(data, cb)
    cb(PhoneData.Alarms)
end)

RegisterNUICallback("DeleteAlarm", function(data)
    if PhoneData.Alarms[tonumber(data.id) + 1] then
        table.remove(PhoneData.Alarms, tonumber(data.id) + 1)
    end
end)

Citizen.CreateThread(function()
    while true do
        local a, b, c, d, e = GetLocalTime()
        for i = 1, #PhoneData.Alarms do
            if PhoneData.Alarms[i] == d..":"..e then
                TriggerEvent("almez-phonev2:PlayAlarmSound")
            end
        end
        Citizen.Wait(60000)
    end
end)

exports('phoneIsOpen', function()
    return PhoneData.isOpen
end)