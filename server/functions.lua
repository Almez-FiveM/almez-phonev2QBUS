QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
QBCore.Functions.CreateUseableItem('phone', function (source, item)
    openPhone(source, item)
    getCurrentPhoneNumber(source, item)
    getCurrentOwner(source, item)
end)

local MIPhone = {}
local Tweets = {}
local AppAlerts = {}
local MentionedTweets = {}
local Hashtags = {}
local Calls = {}
local Adverts = {}
local GeneratedPlates = {}

currentNumber = nil
function getCurrentPhoneNumber(source, item)
    currentNumber = item.info.phone
    return currentNumber
end

currentOwner = nil
function getCurrentOwner(source, item)
    currentOwner = item.info.owner
    return currentOwner
end

function openPhone(source, item)
    local src = source


    local owner = item.info.owner
    local number = item.info.phone
    local ownername = item.info.charname
    local PhoneData = {
        Applications = {},
        PlayerContacts = {},
        MentionedTweets = {},
        Chats = {},
        Hashtags = {},
        SelfTweets = {},
        Invoices = {},
        Garage = {},
        Mails = {},
        Adverts = {},
        CryptoTransactions = {},
        Tweets = {},
        Number = number,
        Owner = owner,
        Ownername = item.info.charname
    }
    PhoneData.Adverts = Adverts

    ExecuteSql(false, "SELECT * FROM player_contacts WHERE `phone_number` = '"..number.."' ORDER BY `name` ASC", function(result)
        local Contacts = {}
        if result[1] ~= nil then
            for k, v in pairs(result) do
                v.status = GetOnlineStatus(v.number)
            end
            PhoneData.PlayerContacts = result
        else 
            PhoneData.PlayerContacts = {}
        end
        

        ExecuteSql(false, "SELECT * FROM twitter_tweets", function(result)
            if result[1] ~= nil then
                PhoneData.Tweets = result
            else
                PhoneData.Tweets = {}
            end


            ExecuteSql(false, "SELECT * FROM twitter_tweets WHERE owner_phone = '"..number.."'", function(result)
                if result ~= nil then
                    PhoneData.SelfTweets = result
                else
                    PhoneData.SelfTweets = {}
                end
        ExecuteSql(false, "SELECT * FROM owned_vehicles WHERE `citizenid` = '"..currentOwner.."'", function(garageresult)

            if garageresult[1] ~= nil then
                PhoneData.Garage = garageresult
            else
                PhoneData.Garage = {}
            end

            ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `phone_number` = "'..number..'" ORDER BY `date` ASC', function(mails)

                if mails[1] ~= nil then
                    for k, v in pairs(mails) do
                        if mails[k].button ~= nil then
                            mails[k].button = json.decode(mails[k].button)
                        end
                    end
                    PhoneData.Mails = mails
                end

                ExecuteSql(false, "SELECT * FROM phone_messages WHERE `owner_number` = '"..number.."'", function(messages)
                    if messages ~= nil and next(messages) ~= nil then 
                        PhoneData.Chats = messages
                    else
                        PhoneData.Chats = {}
                    end

                    if AppAlerts[number] ~= nil then 
                        PhoneData.Applications = AppAlerts[number]
                    else 
                        PhoneData.Applications = {}
                    end
                   
                    if MentionedTweets[number] ~= nil then 
                        PhoneData.MentionedTweets = MentionedTweets[number]
                    else
                        PhoneData.MentionedTweets = {}
                    end

                    if Hashtags ~= nil and next(Hashtags) ~= nil then
                        PhoneData.Hashtags = Hashtags
                    end

                    PhoneData.charinfo = GetCharacter(src)

                    if Config.UseESXBilling then
                        ExecuteSql(false, "SELECT * FROM billing  WHERE `citizenid` = '"..owner.."'", function(invoices)
                            if invoices[1] ~= nil then
                                for k, v in pairs(invoices) do
                                    ExecuteSql(true, "SELECT phone_number FROM `phones` WHERE `owner` = '"..v.sender.."' AND `active` = 1", function(res)
                                        if res[1] ~= nil then
                                            v.number = res[1].phone_number
                                        end
                                    end)
                                end
                                PhoneData.Invoices = invoices
                            end
                            TriggerClientEvent('almez-phone:client:openPhone', source, PhoneData)
                        end)
                    else 
                        PhoneData.Invoices = {}
                        TriggerClientEvent('almez-phone:client:openPhone', source, PhoneData)
                    end
                end)
            end)
            end) 
        end)
    end)
    end)

end