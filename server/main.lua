QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)



local MIPhone = {}
local Available = {}
local Tweets = {}
local AppAlerts = {}
local MentionedTweets = {}
local Hashtags = {}
local Calls = {}
local Adverts = {}
local GeneratedPlates = {}

local MyLikes = {}
local TweetLikes = {}


Citizen.CreateThread(function()
    local result = exports.ghmattimysql:executeSync("SELECT * FROM twitter_tweets")
    if results ~= nil then
        for i = 1, #result do
            local likes = json.decode(result[i].likes)
            TweetLikes[result[i].id] = #likes
        end
    end
end)

RegisterCommand('telal', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local phoneNumber =  getPhoneRandomNumber()
    name = Player.PlayerData.firstname.. ' ' ..Player.PlayerData.lastname
    info = {
        phone = phoneNumber,
        owner = Player.PlayerData.citizenid,
        charname = name
    }
    Player.Functions.AddItem("phone", 1, false, info)
    exports.ghmattimysql.execute('INSERT INTO phones (owner, phone_number) VALUES (@owner, @phone_number)',
	{
		['@owner']   	= Player.identifier,
        ['@phone_number']  = phoneNumber,
	})
end)

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

function getPhoneRandomNumber()
    local numBase0 = 0
    local numBase1 = 6
    local numBase2 = math.random(11111111, 99999999)
    local num = string.format(numBase0 .. "" .. numBase1 .. "" .. numBase2 .. "")
    return num
end

RegisterServerEvent('almez-phonev2:saveTwitterToDatabase')
AddEventHandler('almez-phonev2:saveTwitterToDatabase', function(firstName, lastname, message, url, time, picture, hashtag,id)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local firstname1 = xPlayer.PlayerData.firstname
    local lastname1 = xPlayer.PlayerData.lastname
    if xPlayer then
        exports.ghmattimysql:execute('INSERT INTO twitter_tweets (firstname, lastname, message, url, time, picture, owner, hashtag,id) VALUES (@firstname, @lastname, @message, @url, @time, @picture, @owner, @hashtag, @id)',{
            ['@firstname'] = firstname1,
            ['@lastname'] = lastname1,
            ['@message'] = message,
            ['@url'] = url,
            ['@time'] = time,
            ['@picture'] = picture,
            ['@owner'] = xPlayer.PlayerData.citizenid,
            ['@hashtag'] = hashtag,
            ['@id'] = id,
        })
    end
end)

RegisterServerEvent("almez-phonev2:server:ClearBankData")
AddEventHandler("almez-phonev2:server:ClearBankData", function()
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        player.SetBankData("outgoing", {})
        player.SetBankData("incoming", {})
    end
end)

RegisterServerEvent('almez-phonev2:server:AddAdvert')
AddEventHandler('almez-phonev2:server:AddAdvert', function(msg, image)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Identifier = Player.PlayerData.citizenid

    if Adverts[Identifier] ~= nil then
        Adverts[Identifier].message = msg
        Adverts[Identifier].name = Player.PlayerData.charinfo.firstname..""..Player.PlayerData.charinfo.lastname
        Adverts[Identifier].number = Player.PlayerData.charinfo.phone
        Adverts[Identifier].image = image ~= nil and image or false
    else
        Adverts[Identifier] = {
            message = msg,
            name = Player.PlayerData.charinfo.firstname..""..Player.PlayerData.charinfo.lastname,
            number = Player.PlayerData.charinfo.phone,
            image = image ~= nil and image or false
        }
    end

    TriggerClientEvent('almez-phonev2:client:UpdateAdverts', -1, Adverts,  Player.PlayerData.charinfo.firstname..""..Player.PlayerData.charinfo.lastname)
end)

function GetOnlineStatus(number)
    local Target = QBCore.GetPlayerByPhone(number)
    local retval = false
    if Target ~= nil then retval = true end
    return retval
end

RegisterServerEvent('almez-phonev2:server:updateForEveryone')
AddEventHandler('almez-phonev2:server:updateForEveryone', function(data)
    local src = source
    local twitter = data.Tweets
    local Hashtag = data.Hashtags
    local MentionedTweets = data.MentionedTweets
    local selftweets = data.SelfTweets

    TriggerClientEvent('almez-phonev2:updateForEveryone', -1, twitter, MentionedTweets, Hashtag, selftweets)
end)

RegisterServerEvent('almez-phonev2:server:updateidForEveryone')
AddEventHandler('almez-phonev2:server:updateidForEveryone', function()
    TriggerClientEvent('almez-phonev2:updateidForEveryone', -1)
end)

RegisterServerEvent("almez-phonev2:UpdateAvailableStatus")
AddEventHandler("almez-phonev2:UpdateAvailableStatus", function(data)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        Available[player.PlayerData.charinfo.phone] = data
    end
end)

RegisterServerEvent('almez-phonev2:deleteTweet')
AddEventHandler('almez-phonev2:deleteTweet', function(id)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if xPlayer then
        exports.ghmattimysql:execute('DELETE FROM twitter_tweets WHERE owner = @owner AND id = @id', {
            ['@owner'] = xPlayer.PlayerData.citizenid, 
            ['@id'] = id
        })
    end
end)



QBCore.Functions.CreateCallback('almez-phonev2:server:GetCallState', function(source, cb, ContactData)
    local Target = QBCore.GetPlayerByPhone((ContactData.number))
    if Target ~= nil then
        local available = Available[Target.PlayerData.charinfo.phone] ~= nil and Available[Target.PlayerData.charinfo.phone] or false
        if Calls[Target.PlayerData.citizenid] ~= nil then
            if Calls[Target.PlayerData.citizenid].inCall then
                cb(false, true, available)
            else
                cb(true, true, available)
            end
        else
            cb(true, true, available)
        end
    else
        cb(false, false, available)
    end
end)

RegisterServerEvent('almez-phonev2:server:SetCallState')
AddEventHandler('almez-phonev2:server:SetCallState', function(bool)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)

    if Calls[Ply.PlayerData.citizenid] ~= nil then
        Calls[Ply.PlayerData.citizenid].inCall = bool
    else
        Calls[Ply.PlayerData.citizenid] = {}
        Calls[Ply.PlayerData.citizenid].inCall = bool
    end
end)

RegisterServerEvent('almez-phonev2:server:RemoveMail')
AddEventHandler('almez-phonev2:server:RemoveMail', function(MailId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    ExecuteSql(false, 'DELETE FROM `player_mails` WHERE `mailid` = "'..MailId..'" AND `identifier` = "'..Player.PlayerData.citizenid..'"')
    SetTimeout(100, function()
        ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `identifier` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` ASC', function(mails)
            if mails[1] ~= nil then
                for k, v in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
            end
    
            TriggerClientEvent('almez-phonev2:client:UpdateMails', src, mails)
        end)
    end)
end)

function GenerateMailId()
    return math.random(111111, 999999)
end

RegisterServerEvent('almez-phonev2:server:sendNewMail')
AddEventHandler('almez-phonev2:server:sendNewMail', function(mailData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if mailData.button == nil then
        ExecuteSql(false, "INSERT INTO `player_mails` (`identifier`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES ('"..Player.PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0')")
    else
        ExecuteSql(false, "INSERT INTO `player_mails` (`identifier`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES ('"..Player.PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0', '"..json.encode(mailData.button).."')")
    end
    TriggerClientEvent('almez-phonev2:client:NewMailNotify', src, mailData)

    SetTimeout(200, function()
        ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `identifier` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` DESC', function(mails)
            if mails[1] ~= nil then
                for k, v in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
            end
    
            TriggerClientEvent('almez-phonev2:client:UpdateMails', src, mails)
        end)
    end)
end)

RegisterServerEvent('almez-phonev2:server:sendNewMailToOffline')
AddEventHandler('almez-phonev2:server:sendNewMailToOffline', function(steam, mailData)
    local Player = QBCore.Functions.GetPlayerByCitizenId(steam)

    if Player ~= nil then
        local src = Player.PlayerData.source

        if mailData.button == nil then
            ExecuteSql(false, "INSERT INTO `player_mails` (`identifier`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES ('"..Player.PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0')")
            TriggerClientEvent('almez-phonev2:client:NewMailNotify', src, mailData)
        else
            ExecuteSql(false, "INSERT INTO `player_mails` (`identifier`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES ('"..Player.PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0', '"..json.encode(mailData.button).."')")
            TriggerClientEvent('almez-phonev2:client:NewMailNotify', src, mailData)
        end

        SetTimeout(200, function()
            ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `identifier` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` DESC', function(mails)
                if mails[1] ~= nil then
                    for k, v in pairs(mails) do
                        if mails[k].button ~= nil then
                            mails[k].button = json.decode(mails[k].button)
                        end
                    end
                end
        
                TriggerClientEvent('almez-phonev2:client:UpdateMails', src, mails)
            end)
        end)
    else
        if mailData.button == nil then
            ExecuteSql(false, "INSERT INTO `player_mails` (`identifier`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES ('"..PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0')")
        else
            ExecuteSql(false, "INSERT INTO `player_mails` (`identifier`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES ('"..PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0', '"..json.encode(mailData.button).."')")
        end
    end
end)

RegisterServerEvent('almez-phonev2:server:sendNewEventMail')
AddEventHandler('almez-phonev2:server:sendNewEventMail', function(steam, mailData)
    if mailData.button == nil then
        ExecuteSql(false, "INSERT INTO `player_mails` (`identifier`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES ('"..PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0')")
    else
        ExecuteSql(false, "INSERT INTO `player_mails` (`identifier`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES ('"..PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0', '"..json.encode(mailData.button).."')")
    end
    SetTimeout(200, function()
        ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `identifier` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` DESC', function(mails)
            if mails[1] ~= nil then
                for k, v in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
            end
    
            TriggerClientEvent('almez-phonev2:client:UpdateMails', src, mails)
        end)
    end)
end)

RegisterServerEvent('almez-phonev2:server:ClearButtonData')
AddEventHandler('almez-phonev2:server:ClearButtonData', function(mailId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    ExecuteSql(false, 'UPDATE `player_mails` SET `button` = "" WHERE `mailid` = "'..mailId..'" AND `identifier` = "'..Player.PlayerData.citizenid..'"')
    SetTimeout(200, function()
        ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `identifier` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` DESC', function(mails)
            if mails[1] ~= nil then
                for k, v in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
            end
    
            TriggerClientEvent('almez-phonev2:client:UpdateMails', src, mails)
        end)
    end)
end)

RegisterServerEvent('almez-phonev2:server:MentionedPlayer')
AddEventHandler('almez-phonev2:server:MentionedPlayer', function(firstName, lastName, TweetMessage)
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)

        if Player ~= nil then
            local character = GetCharacter(src)
            if (character.firstname == firstName and character.lastname == lastName) then
                MIPhone.SetPhoneAlerts(Player.PlayerData.citizenid, "twitter")
   
                MIPhone.AddMentionedTweet(Player.PlayerData.citizenid, TweetMessage)
                TriggerClientEvent('almez-phonev2:client:GetMentioned', Player.PlayerData.source, TweetMessage, AppAlerts[Player.PlayerData.citizenid]["twitter"])

            else
                ExecuteSql(false, "SELECT * FROM `players` WHERE `firstname`='"..firstName.."' AND `lastname`='"..lastName.."'", function(result)
                    if result[1] ~= nil then
                        local MentionedTarget = result[1].PlayerData.citizenid
                        MIPhone.SetPhoneAlerts(MentionedTarget, "twitter")
                        MIPhone.AddMentionedTweet(MentionedTarget, TweetMessage)
                    end
                end)
            end
        end
	end
end)



RegisterServerEvent('almez-phonev2:server:CallContact')
AddEventHandler('almez-phonev2:server:CallContact', function(TargetData, CallId, AnonymousCall)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.GetPlayerByPhone(TargetData.number)
    if Target ~= nil then
        TriggerClientEvent('almez-phonev2:client:GetCalled', Target.PlayerData.source, Ply.PlayerData.charinfo.phone, CallId, AnonymousCall)
    end
end)

-- QBCore(V1_Final) Fix
QBCore.Functions.CreateCallback('almez-phonev2:server:GetBankData', function(source, cb)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)

    if xPlayer then
        local data = {
            bank = tonumber(xPlayer.PlayerData.money["bank"]),
            iban = xPlayer.PlayerData.charinfo.iban,
        }
        cb(data)
    end
    -- cb({bank = xPlayer.getAccount('bank').money, iban = xPlayer.PlayerData.iban, incomings = xPlayer.PlayerData.bankdata["incoming"], outgoings = xPlayer.PlayerData.bankdata["outgoing"]})
end)

RegisterServerEvent("gcPhone:faturapayBill")
AddEventHandler("gcPhone:faturapayBill", function(_id)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	local id = _id
	exports.ghmattimysql:execute('SELECT * FROM billing WHERE id = @id', {
		['@id'] = id
	}, function(result)
		if result[1] then
			local sender = result[1].sender
			local job = result[1].target
			local amount = result[1].amount
			local xTarget = QBCore.Functions.GetPlayerByCitizenId(sender)

			if job == "player" then
				if xTarget then
					if xPlayer.Functions.RemoveMoney('bank', amount) then
						exports.ghmattimysql:scalar('DELETE from billing WHERE id = @id', {
							['@id'] = id
						}, function()
							xTarget.Functions.AddMoney('bank', amount)
							TriggerClientEvent("QBCore:Notify", xPlayer.PlayerData.source, amount ..'$ Tutarındaki Faturayı Ödediniz')
							TriggerClientEvent('gcPhone:updateFaturalar', xPlayer.PlayerData.source)
							TriggerClientEvent("QBCore:Notify", xTarget.PlayerData.source, 'Bir kişi '.. amount ..'$ Değerindeki Faturayı Ödedi!')
							TriggerEvent('DiscordBot:ToDiscord', 'fatura', amount.."$ Fatura Ödedi İşletme: "..job, xPlayer.PlayerData.source, xTarget.PlayerData.source)
						end)
					else
						TriggerClientEvent("QBCore:Notify", xPlayer.PlayerData.source, 'Bu faturayı ödeyebilmeniz için yeterli paranız yok')
					end
				else
					TriggerClientEvent("QBCore:Notify", xPlayer.PlayerData.source, 'Faturaya Kesen Oyuncu Online Olmadığı İçin Faturayı Ödeyemedin!', 'error')
				end
			else
				local playerMoney  = QBCore.Shared.Round(amount / 100 * 10)
				local societyMoney = QBCore.Shared.Round(amount / 100 * 90)
				if job == "hotdog" or job == "taco" or job == "chicken" or job == "burger" or job == "popsdiner" or job == "balik" or job == "kahve" or job == "japon" then
					playerMoney  = QBCore.Shared.Round(amount / 100 * 50)
					societyMoney = QBCore.Shared.Round(amount / 100 * 50)
				end
				if xPlayer.Functions.RemoveMoney('bank', amount) then
					exports.ghmattimysql:scalar('DELETE from billing WHERE id = @id', {
						['@id'] = id
					}, function()	
						TriggerClientEvent("QBCore:Notify", xPlayer.PlayerData.source, amount ..'$ Tutarındaki Faturayı Ödediniz')
						QBCore.Functions.addJobMoney(job, societyMoney)
						TriggerClientEvent('gcPhone:updateFaturalar', xPlayer.PlayerData.source)
						if xTarget then
							xTarget.Functions.AddMoney('bank', playerMoney) -- player
							TriggerEvent('DiscordBot:ToDiscord', 'fatura', amount.."$ Fatura Ödedi! İşletme: "..job, xPlayer.PlayerData.source, xTarget.PlayerData.source)
							TriggerClientEvent("QBCore:Notify", xTarget.PlayerData.source, 'Bir kişi '.. amount ..'$ Değerindeki Faturayı Ödediği için Hesabınıza '.. playerMoney ..'$ Yatırıldı')
						else
							TriggerEvent('DiscordBot:ToDiscord', 'fatura', amount.."$ Fatura Ödedi! İşletme: "..job, xPlayer.PlayerData.source)
						end
					end)
				else
					TriggerClientEvent("QBCore:Notify", xPlayer.PlayerData.source, 'Bu faturayı ödeyebilmeniz için yeterli paranız yok')
				end
			end
		end
	end)
end)

-- QBCore(V1_Final) Fix
QBCore.Functions.CreateCallback('almez-phonev2:server:CanPayInvoice', function(source, cb, amount)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    cb(xPlayer.PlayerData.money["bank"] >= amount)
end)

QBCore.Functions.CreateCallback('almez-phonev2:server:GetInvoices', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    ExecuteSql(false, "SELECT * FROM billing  WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(invoices)
        if invoices[1] ~= nil then
           
            
            cb(invoices, Player.PlayerData.money["bank"])
        else
            cb({})
        end
    end)
end)

RegisterServerEvent('almez-phonev2:server:DeleteHashtags')
AddEventHandler('almez-phonev2:server:DeleteHashtags', function(data)
    TriggerClientEvent('almez-phonev2:client:DeleteHashtags', -1, data)
end)

RegisterServerEvent('almez-phonev2:server:UpdateHashtags')
AddEventHandler('almez-phonev2:server:UpdateHashtags', function(Handle, messageData)
    if Hashtags[Handle] ~= nil and next(Hashtags[Handle]) ~= nil then
        table.insert(Hashtags[Handle].messages, messageData)
    else
        Hashtags[Handle] = {
            hashtag = Handle,
            messages = {}
        }
        table.insert(Hashtags[Handle].messages, messageData)
    end
    TriggerClientEvent('almez-phonev2:client:UpdateHashtags', -1, Handle, messageData)
end)

MIPhone.AddMentionedTweet = function(identifier, TweetData)
    if MentionedTweets[identifier] == nil then MentionedTweets[identifier] = {} end
    table.insert(MentionedTweets[identifier], TweetData)
end

MIPhone.SetPhoneAlerts = function(identifier, app, alerts)
    if identifier ~= nil and app ~= nil then
        if AppAlerts[identifier] == nil then
            AppAlerts[identifier] = {}
            if AppAlerts[identifier][app] == nil then
                if alerts == nil then
                    AppAlerts[identifier][app] = 1
                else
                    AppAlerts[identifier][app] = alerts
                end
            end
        else
            if AppAlerts[identifier][app] == nil then
                if alerts == nil then
                    AppAlerts[identifier][app] = 1
                else
                    AppAlerts[identifier][app] = 0
                end
            else
                if alerts == nil then
                    AppAlerts[identifier][app] = AppAlerts[identifier][app] + 1
                else
                    AppAlerts[identifier][app] = AppAlerts[identifier][app] + 0
                end
            end
        end
    end
end

QBCore.Functions.CreateCallback('almez-phonev2:server:GetContactPictures', function(source, cb, Chats)
    for k, v in pairs(Chats) do
        local Player = QBCore.GetPlayerByPhone(v.number)
        
        QBCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `number` = '"..v.number.."'", function(result)
            if result[1] ~= nil then
                local MetaData = json.decode(result[1].metadata)

                if MetaData.profilepicture ~= nil then
                    v.picture = MetaData.profilepicture
                else
                    v.picture = "default"
                end
            end
        end)
    end
    SetTimeout(100, function()
        cb(Chats)
    end)
end)

QBCore.Functions.CreateCallback('almez-phonev2:server:GetContactPicture', function(source, cb, Chat)
    local Player = QBCore.GetPlayerByPhone(Chat.number)

    QBCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `number` = '"..Chat.number.."'", function(result)
        if result[1] ~= nil then
            local MetaData = json.decode(result[1].metadata)

            if MetaData.profilepicture ~= nil then
                Chat.picture = MetaData.profilepicture
            else
                Chat.picture = "default"
            end
        else
            Chat.picture = 'default'
        end
    end)
    SetTimeout(100, function()
        cb(Chat)
    end)
end)

QBCore.Functions.CreateCallback('almez-phonev2:server:GetPicture', function(source, cb, number)
    local Player = QBCore.GetPlayerByPhone(number)
    local Picture = nil

    QBCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `number` = '"..number.."'", function(result)
        if result[1] ~= nil then
            local MetaData = json.decode(result[1].metadata)

            if MetaData.profilepicture ~= nil then
                Picture = MetaData.profilepicture
            else
                Picture = "default"
            end
            cb(Picture)
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('almez-phonev2:server:SetPhoneAlerts')
AddEventHandler('almez-phonev2:server:SetPhoneAlerts', function(app, alerts)
    local src = source
    local Identifier = QBCore.Functions.GetPlayer(src).PlayerData.citizenid
    MIPhone.SetPhoneAlerts(Identifier, app, alerts)
end)

RegisterServerEvent('almez-phonev2:server:UpdateTweets')
AddEventHandler('almez-phonev2:server:UpdateTweets', function(TweetData, type)
    Tweets = NewTweets
    local TwtData = TweetData
    local src = source
    local players = QBCore.Functions.GetPlayers()
    for i = 1, #players do
        -- if src ~= players[i] then
            TriggerClientEvent('almez-phonev2:client:UpdateTweets', players[i], src, TwtData, type)
        -- end
    end
end)



QBCore.Functions.CreateCallback('almez-phonev2:server:TransferMoney',function(source,cb, iban, amount, description)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local retval = false
    local message = ''
    if xPlayer ~= nil and amount ~= nil and amount > 0 and iban ~= nil then
        local zPlayer = QBCore.GetPlayerByIban(iban)
        local bankMoney = xPlayer.PlayerData.money["bank"]
        if bankMoney >= amount then
            if zPlayer ~= nil then
                local PhoneItem = zPlayer.Functions.GetItemByName("phone")
                zPlayer.Functions.AddMoney('bank', amount, "phone-transfered-from-"..xPlayer.PlayerData.citizenid)
                xPlayer.Functions.RemoveMoney('bank', amount, "phone-transfered-to-"..zPlayer.PlayerData.citizenid)

                if PhoneItem ~= nil then
                    TriggerClientEvent('almez-phonev2:client:TransferMoney', zPlayer.PlayerData.source, amount, zPlayer.PlayerData.money["bank"])
                    TriggerClientEvent('mythic_notify:client:SendAlert',  zPlayer.PlayerData.source, { type = 'inform', text = 'Hesabına para transferi yapıldı: $' .. amount .. ', yatıran IBAN: ' .. xPlayer.PlayerData.charinfo.iban .. ''})
                end

                -- local ts = os.time()
                -- local time = os.date('%Y-%m-%d %H:%M', ts)
                -- local inComing = zPlayer.PlayerData.bankdata['incoming'] ~= nil and zPlayer.PlayerData.bankdata['incoming'] or {}
                -- inComing[#zPlayer.PlayerData.bankdata['incoming']+1] = {
                --     sender = xPlayer.PlayerData.firstname.. " " ..xPlayer.PlayerData.lastname,
                --     reciever = zPlayer.PlayerData.firstname.. " " ..zPlayer.PlayerData.lastname,
                --     sender_iban = xPlayer.PlayerData.iban,
                --     reciever_iban = zPlayer.PlayerData.iban,
                --     timestamp = time,
                --     description = description,
                --     amount = amount
                -- }
                -- zPlayer.SetBankData('incoming', inComing)

                -- local outGoing = xPlayer.PlayerData.bankdata['outgoing'] ~= nil and xPlayer.PlayerData.bankdata['outgoing'] or {}
                -- outGoing[#xPlayer.PlayerData.bankdata['outgoing']+1] = {
                --     sender = xPlayer.PlayerData.firstname.. " " ..xPlayer.PlayerData.lastname,
                --     reciever = zPlayer.PlayerData.firstname.. " " ..zPlayer.PlayerData.lastname,
                --     sender_iban = xPlayer.PlayerData.iban,
                --     reciever_iban = zPlayer.PlayerData.iban,
                --     timestamp = time,
                --     description = description,
                --     amount = amount
                -- }
                -- xPlayer.SetBankData('outgoing', outGoing)
                TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.PlayerData.source, { type = 'inform', text = iban.. " numaralı hesaba $" ..amount..  " gönderdin."})
                retval = true
            else
                local moneyInfo = json.decode(result[1].money)
                moneyInfo.bank = round((moneyInfo.bank + amount))
                QBCore.Functions.ExecuteSql(false, "UPDATE `players` SET `money` = '"..json.encode(moneyInfo).."' WHERE `citizenid` = '"..result[1].citizenid.."'")
                xPlayer.Functions.RemoveMoney('bank', amount, "phone-transfered")
                retval = true
            
            end
        else
            message = 'Bankanda girdiğin miktarda para bulunmuyor!'
        end
    else
        message = 'Bir hata oluştu! Tekrar dene'
    end
    Citizen.Wait(350)
    cb(retval, xPlayer.PlayerData.money["bank"], message)
end)


RegisterServerEvent('almez-phonev2:server:EditContact')
AddEventHandler('almez-phonev2:server:EditContact', function(newName, newNumber, newIban, oldName, oldNumber, oldIban, image)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    ExecuteSql(false, "UPDATE `player_contacts` SET `name` = '"..newName.."', `number` = '"..newNumber.."', `iban` = '"..newIban.."', `image` = '"..image.."' WHERE `identifier` = '"..Player.PlayerData.citizenid.."' AND `name` = '"..oldName.."' AND `number` = '"..oldNumber.."'")
end)

RegisterServerEvent('almez-phonev2:server:RemoveContact')
AddEventHandler('almez-phonev2:server:RemoveContact', function(Name, Number)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    ExecuteSql(false, "DELETE FROM `player_contacts` WHERE `name` = '"..Name.."' AND `number` = '"..Number.."' AND `identifier` = '"..Player.PlayerData.citizenid.."'")
end)

RegisterServerEvent('almez-phonev2:server:AddNewContact')
AddEventHandler('almez-phonev2:server:AddNewContact', function(name, number, iban, image)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    ExecuteSql(false, "INSERT INTO `player_contacts` (`identifier`, `name`, `number`, `iban`, `image`) VALUES ('"..Player.PlayerData.citizenid.."', '"..tostring(name).."', '"..tostring(number).."', '"..tostring(iban).."', '"..image.."')")
end)

RegisterServerEvent('almez-phonev2:server:UpdateMessages')
AddEventHandler('almez-phonev2:server:UpdateMessages', function(ChatMessages, ChatNumber, New)
    local src = source
    local SenderData = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `number`= '"..ChatNumber.."'", function(Player)
        if Player[1] ~= nil then
            local TargetData = QBCore.Functions.GetPlayerByCitizenId(Player[1].citizenid)

            if TargetData ~= nil then
                QBCore.Functions.ExecuteSql(false, "SELECT * FROM `phone_messages` WHERE `identifier` = '"..SenderData.PlayerData.citizenid.."' AND `number` = '"..ChatNumber.."'", function(Chat)
                    if Chat[1] ~= nil then
                        -- Update for target
                        --QBCore.Functions.ExecuteSql(false, "UPDATE `phone_messages` SET `messages` = '"..json.encode(ChatMessages).."' WHERE `identifier` = '"..TargetData.PlayerData.citizenid.."' AND `number` = '"..SenderData.PlayerData.phone.."'")
                        exports["ghmattimysql"]:execute("UPDATE `phone_messages` SET `messages` = @messages WHERE`identifier` = @identifier AND `number` = @number", {
                            ["@identifier"] = TargetData.PlayerData.citizenid,
                            ["@messages"] = json.encode(ChatMessages),
                            ["@number"] = SenderData.PlayerData.charinfo.phone,
                        })
                        -- Update for sender
                        --QBCore.Functions.ExecuteSql(false, "UPDATE `phone_messages` SET `messages` = '"..json.encode(ChatMessages).."' WHERE `identifier` = '"..SenderData.PlayerData.citizenid.."' AND `number` = '"..TargetData.PlayerData.phone.."'")
                        exports["ghmattimysql"]:execute("UPDATE `phone_messages` SET `messages` = @messages WHERE`identifier` = @identifier AND `number` = @number", {
                            ["@identifier"] = SenderData.PlayerData.citizenid,
                            ["@messages"] = json.encode(ChatMessages),
                            ["@number"] = SenderData.PlayerData.charinfo.phone,
                        })
                        -- Send notification & Update messages for target
                        TriggerClientEvent('almez-phonev2:client:UpdateMessages', TargetData.PlayerData.source, ChatMessages, SenderData.PlayerData.charinfo.phone, false)
                    else
                        -- Insert for target
                        --QBCore.Functions.ExecuteSql(false, "INSERT INTO `phone_messages` (`identifier`, `number`, `messages`) VALUES ('"..TargetData.PlayerData.citizenid.."', '"..SenderData.PlayerData.phone.."', '"..json.encode(ChatMessages).."')")
                        exports["ghmattimysql"]:execute("INSERT INTO `phone_messages` (`identifier`, `number`, `messages`) VALUES (@identifier, @number, @messages)", {
                            ["@identifier"] = TargetData.PlayerData.citizenid,
                            ["@number"] = SenderData.PlayerData.charinfo.phone,
                            ["@messages"] = json.encode(ChatMessages),
                        })
                        -- Insert for sender
                        --QBCore.Functions.ExecuteSql(false, "INSERT INTO `phone_messages` (`identifier`, `number`, `messages`) VALUES ('"..SenderData.PlayerData.citizenid.."', '"..TargetData.PlayerData.phone.."', '"..json.encode(ChatMessages).."')")
                        exports["ghmattimysql"]:execute("INSERT INTO `phone_messages` (`identifier`, `number`, `messages`) VALUES (@identifier, @number, @messages)", {
                            ["@identifier"] = SenderData.PlayerData.citizenid,
                            ["@number"] = TargetData.PlayerData.charinfo.phone,
                            ["@messages"] = json.encode(ChatMessages),
                        })
                        -- Send notification & Update messages for target
                        TriggerClientEvent('almez-phonev2:client:UpdateMessages', TargetData.PlayerData.source, ChatMessages, SenderData.PlayerData.charinfo.phone, true)
                    end
                end)
            else
                QBCore.Functions.ExecuteSql(false, "SELECT * FROM `phone_messages` WHERE `identifier` = '"..SenderData.PlayerData.citizenid.."' AND `number` = '"..ChatNumber.."'", function(Chat)
                    if Chat[1] ~= nil then
                        -- Update for target
                        --QBCore.Functions.ExecuteSql(false, "UPDATE `phone_messages` SET `messages` = '"..json.encode(ChatMessages).."' WHERE `identifier` = '"..Player[1].citizenid.."' AND `number` = '"..SenderData.PlayerData.phone.."'")
                        exports["ghmattimysql"]:execute("UPDATE `phone_messages` SET `messages` = @messages WHERE`identifier` = @identifier AND `number` = @number", {
                            ["@identifier"] = Player[1].citizenid,
                            ["@messages"] = json.encode(ChatMessages),
                            ["@number"] =  SenderData.PlayerData.charinfo.phone,
                        })
                        -- Update for sender
                       -- QBCore.Functions.ExecuteSql(false, "UPDATE `phone_messages` SET `messages` = '"..json.encode(ChatMessages).."' WHERE `identifier` = '"..SenderData.PlayerData.citizenid.."' AND `number` = '"..Player[1].phone.."'")
                        exports["ghmattimysql"]:execute("UPDATE `phone_messages` SET `messages` = @messages WHERE`identifier` = @identifier AND `number` = @number", {
                            ["@identifier"] = SenderData.PlayerData.citizenid,
                            ["@messages"] = json.encode(ChatMessages),
                            ["@number"] = Player[1].number,
                        })
                    else
                        -- Insert for target
                        --QBCore.Functions.ExecuteSql(false, "INSERT INTO `phone_messages` (`identifier`, `number`, `messages`) VALUES ('"..Player[1].citizenid.."', '"..SenderData.PlayerData.phone.."', '"..json.encode(ChatMessages).."')")
                        exports["ghmattimysql"]:execute("INSERT INTO `phone_messages` (`identifier`, `number`, `messages`) VALUES (@identifier, @number, @messages)", {
                            ["@identifier"] = Player[1].citizenid,
                            ["@number"] = SenderData.PlayerData.charinfo.phone,
                            ["@messages"] = json.encode(ChatMessages),
                        })
                        -- Insert for sender
                        --QBCore.Functions.ExecuteSql(false, "INSERT INTO `phone_messages` (`identifier`, `number`, `messages`) VALUES ('"..SenderData.PlayerData.citizenid.."', '"..Player[1].phone.."', '"..json.encode(ChatMessages).."')")
                        exports["ghmattimysql"]:execute("INSERT INTO `phone_messages` (`identifier`, `number`, `messages`) VALUES (@identifier, @number, @messages)", {
                            ["@identifier"] = SenderData.PlayerData.citizenid,
                            ["@number"] = Player[1].number,
                            ["@messages"] = json.encode(ChatMessages),
                        })
                    end
                end)
            end
        end
    end)
end)

RegisterServerEvent('almez-phonev2:server:AddRecentCall')
AddEventHandler('almez-phonev2:server:AddRecentCall', function(type, data)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local Hour = os.date("%H")
    local Minute = os.date("%M")
    local label = Hour..":"..Minute

    TriggerClientEvent('almez-phonev2:client:AddRecentCall', Ply.PlayerData.source, data, label, type)
    local Trgt = QBCore.GetPlayerByPhone(data.number)
    if Trgt ~= nil then
        TriggerClientEvent('almez-phonev2:client:AddRecentCall', Trgt.PlayerData.source, {
            name = Ply.PlayerData.charinfo.firstname..""..Ply.PlayerData.charinfo.lastname,
            number =  Ply.PlayerData.charinfo.phone,
            anonymous = anonymous
        }, label, "outgoing")
    end
end)

RegisterServerEvent('almez-phonev2:server:CancelCall')
AddEventHandler('almez-phonev2:server:CancelCall', function(id,ContactData)
    id = tonumber(id)
    if ContactData.TargetData ~= nil then
        local Ply = QBCore.GetPlayerByPhone(ContactData.TargetData.number)
        if Ply ~= nil then
            local sourcetarget = QBCore.Functions.GetPlayerByCitizenId(Ply.PlayerData.citizenid)
            exports['saltychat']:EndCall(id, sourcetarget.PlayerData.source)
            TriggerClientEvent('almez-phonev2:client:CancelCall', sourcetarget.PlayerData.source)
        end
    end
end)

RegisterServerEvent('almez-phonev2:server:AnswerCall')
AddEventHandler('almez-phonev2:server:AnswerCall', function(id,CallData)
    id = tonumber(id)
    local Ply = QBCore.GetPlayerByPhone(CallData.TargetData.number)
    if Ply ~= nil then
        local sourcetarget = QBCore.Functions.GetPlayerByCitizenId(Ply.PlayerData.citizenid)
        exports['saltychat']:EstablishCall(id, sourcetarget.PlayerData.source)
        TriggerClientEvent('almez-phonev2:client:AnswerCall', sourcetarget.PlayerData.source)
    end
end)

RegisterServerEvent('almez-phonev2:server:SaveMetaData')
AddEventHandler('almez-phonev2:server:SaveMetaData', function(MData,data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player and data and MData then
        QBCore.Functions.ExecuteSql(false, "SELECT metadata FROM `players` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(result)
            local MetaData = json.decode(result[1].metadata)
            MetaData[MData] = data
            QBCore.Functions.ExecuteSql(false, "UPDATE `players` SET `metadata` = '"..json.encode(MetaData).."' WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'")
        end)
    
        Player.Functions.SetMetaData(MData, data)
    end
end)

function escape_sqli(source)
    local replacements = { ['"'] = '\\"', ["'"] = "\\'" }
    return source:gsub( "['\"]", replacements ) -- or string.gsub( source, "['\"]", replacements )
end

QBCore.Functions.CreateCallback('almez-phonev2:server:FetchResult', function(source, cb, search)
    local src = source
    local search = escape_sqli(search)
    local searchData = {}
    local ApaData = {}
    local character = GetCharacter(src)
    -- ExecuteSql(false, "SELECT * FROM `users` WHERE firstname LIKE '%"..search.."%'", function(result)
    --     if result[1] ~= nil then
            for k, v in pairs(result) do
                local driverlicense = false
                local weaponlicense = false
                local doingSomething = true

                if Config.UseQBCoreLicense then
                    CheckLicense(v.PlayerData.citizenid, 'weapon', function(has)
                        if has then
                            weaponlicense = true
                        end

                        CheckLicense(v.PlayerData.citizenid, 'drive', function(has)
                            if has then
                                driverlicense = true
                            end
                            
                            doingSomething = false
                        end)
                    end)
                else
                    doingSomething = false
                end


                while doingSomething do Wait(1) end
                
                table.insert(searchData, {
                    identifier = v.PlayerData.citizenid,
                    firstname = character.firstname,
                    lastname = character.lastname,
                    birthdate = character.dateofbirth,
                    phone = character.phone,
                    gender = character.sex,
                    weaponlicense = weaponlicense,
                    driverlicense = driverlicense,
                })
            end
            cb(searchData)
        -- else
            -- cb(nil)
        -- end
    -- end)
end)

function CheckLicense(target, type, cb)
	local target = target

	if target then
		exports.ghmattimysql:execute('SELECT COUNT(*) as count FROM user_licenses WHERE type = @type AND owner = @owner', {
			['@type'] = type,
			['@owner'] = target
		}, function(result)
			if tonumber(result[1].count) > 0 then
				cb(true)
			else
				cb(false)
			end
		end)
	else
		cb(false)
	end
end

QBCore.Functions.CreateCallback('almez-phonev2:server:GetVehicleSearchResults', function(source, cb, search)
    local src = source
    local search = escape_sqli(search)
    local searchData = {}
    local character = GetCharacter(src)

    ExecuteSql(false, 'SELECT * FROM `owned_vehicles` WHERE `plate` LIKE "%'..search..'%" OR `owner` = "'..search..'"', function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                ExecuteSql(true, 'SELECT * FROM `players` WHERE `citizenid` = "'..result[k].PlayerData.citizenid..'"', function(player)
                    if player[1] ~= nil then 
                        local vehicleInfo = { ['name'] = json.decode(result[k].vehicle).model }
                        if vehicleInfo ~= nil then 
                            table.insert(searchData, {
                                plate = result[k].plate,
                                status = true,
                                owner = character.firstname .. " " .. character.lastname,
                                identifier = result[k].PlayerData.citizenid,
                                label = vehicleInfo["name"]
                            })
                        else
                            table.insert(searchData, {
                                plate = result[k].plate,
                                status = true,
                                owner = character.firstname .. " " .. character.lastname,
                                identifier = result[k].PlayerData.citizenid,
                                label = "Name not found"
                            })
                        end
                    end
                end)
            end
        elseif GeneratedPlates[search] ~= nil then
            table.insert(searchData, {
                plate = GeneratedPlates[search].plate,
                status = GeneratedPlates[search].status,
                owner = GeneratedPlates[search].owner,
                identifier = GeneratedPlates[search].PlayerData.citizenid,
                label = "Brand unknown.."
            })
        else
            local ownerInfo = GenerateOwnerName()
            GeneratedPlates[search] = {
                plate = search,
                status = true,
                owner = ownerInfo.name,
                identifier = ownerInfo.PlayerData.citizenid,
            }
            table.insert(searchData, {
                plate = search,
                status = true,
                owner = ownerInfo.name,
                identifier = ownerInfo.PlayerData.citizenid,
                label = "Brand unknown .."
            })
        end
        cb(searchData)
    end)
end)

QBCore.Functions.CreateCallback('almez-phonev2:server:ScanPlate', function(source, cb, plate)
    local src = source
    local vehicleData = {}
    local character = GetCharacter(src)
    if plate ~= nil then 
        ExecuteSql(false, 'SELECT * FROM `owned_vehicles` WHERE `plate` = "'..plate..'"', function(result)
            if result[1] ~= nil then
                ExecuteSql(true, 'SELECT * FROM `players` WHERE `citizenid` = "'..result[1].PlayerData.citizenid..'"', function(player)
                    vehicleData = {
                        plate = plate,
                        status = true,
                        owner = character.firstname .. " " .. character.lastname,
                        identifier = result[1].PlayerData.citizenid,
                    }
                end)
            elseif GeneratedPlates ~= nil and GeneratedPlates[plate] ~= nil then 
                vehicleData = GeneratedPlates[plate]
            else
                local ownerInfo = GenerateOwnerName()
                GeneratedPlates[plate] = {
                    plate = plate,
                    status = true,
                    owner = ownerInfo.name,
                    identifier = ownerInfo.PlayerData.citizenid,
                }
                vehicleData = {
                    plate = plate,
                    status = true,
                    owner = ownerInfo.name,
                    identifier = ownerInfo.PlayerData.citizenid,
                }
            end
            cb(vehicleData)
        end)
    else
        TriggerClientEvent('notification', src, Lang('NO_VEHICLE'), 2)
        cb(nil)
    end
end)

function GenerateOwnerName()
    local names = {
        [1] = { name = "Jan Bloksteen", identifier = "DSH091G93" },
        [2] = { name = "Jay Dendam", identifier = "AVH09M193" },
        [3] = { name = "Ben Klaariskees", identifier = "DVH091T93" },
        [4] = { name = "Karel Bakker", identifier = "GZP091G93" },
        [5] = { name = "Klaas Adriaan", identifier = "DRH09Z193" },
        [6] = { name = "Nico Wolters", identifier = "KGV091J93" },
        [7] = { name = "Mark Hendrickx", identifier = "ODF09S193" },
        [8] = { name = "Bert Johannes", identifier = "KSD0919H3" },
        [9] = { name = "Karel de Grote", identifier = "NDX091D93" },
        [10] = { name = "Jan Pieter", identifier = "ZAL0919X3" },
        [11] = { name = "Huig Roelink", identifier = "ZAK09D193" },
        [12] = { name = "Corneel Boerselman", identifier = "POL09F193" },
        [13] = { name = "Hermen Klein Overmeen", identifier = "TEW0J9193" },
        [14] = { name = "Bart Rielink", identifier = "YOO09H193" },
        [15] = { name = "Antoon Henselijn", identifier = "QBC091H93" },
        [16] = { name = "Aad Keizer", identifier = "YDN091H93" },
        [17] = { name = "Thijn Kiel", identifier = "PJD09D193" },
        [18] = { name = "Henkie Krikhaar", identifier = "RND091D93" },
        [19] = { name = "Teun Blaauwkamp", identifier = "QWE091A93" },
        [20] = { name = "Dries Stielstra", identifier = "KJH0919M3" },
        [21] = { name = "Karlijn Hensbergen", identifier = "ZXC09D193" },
        [22] = { name = "Aafke van Daalen", identifier = "XYZ0919C3" },
        [23] = { name = "Door Leeferds", identifier = "ZYX0919F3" },
        [24] = { name = "Nelleke Broedersen", identifier = "IOP091O93" },
        [25] = { name = "Renske de Raaf", identifier = "PIO091R93" },
        [26] = { name = "Krisje Moltman", identifier = "LEK091X93" },
        [27] = { name = "Mirre Steevens", identifier = "ALG091Y93" },
        [28] = { name = "Joosje Kalvenhaar", identifier = "YUR09E193" },
        [29] = { name = "Mirte Ellenbroek", identifier = "SOM091W93" },
        [30] = { name = "Marlieke Meilink", identifier = "KAS09193" },
    }
    return names[math.random(1, #names)]
end





QBCore.Functions.CreateCallback('almez-phonev2:server:GetGarageVehicles', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local Vehicles = {}

    QBCore.Functions.ExecuteSql(false, "SELECT * FROM `owned_vehicles` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                local VehicleData = QBCore.Shared.Vehicles[v.vehicle]

                local VehicleGarage = "None"
                if v.garage ~= nil then
                    if Garages[v.garage] ~= nil then
                        VehicleGarage = Garages[v.garage]["label"]
                    end
                end

                local VehicleState = "In"
                if v.state == 0 then
                    VehicleState = "Out"
                elseif v.state == 2 then
                    VehicleState = "Impounded"
                end

                local vehdata = {}
                if VehicleData ~= nil then
                    vehdata = {
                        fullname = VehicleData["name"],
                        brand = VehicleData["name"],
                        model = VehicleData["name"],
                        plate = v.plate,
                        garage = VehicleGarage,
                        state = VehicleState,
                        fuel = v.fuel,
                        engine = v.engine,
                        body = v.body,
                    }
                end

                table.insert(Vehicles, vehdata)
            end
            cb(Vehicles)
        else
            cb(nil)
        end
    end)
end)

QBCore.Functions.CreateCallback('almez-phonev2:server:GetCharacterData', function(source, cb)
    local src = source or id
    local Player = QBCore.Functions.GetPlayer(src)
    local data = Player.PlayerData
    local charinfo = {
        firstname = Player.PlayerData.charinfo.firstname,
        lastname = Player.PlayerData.charinfo.lastname,
        iban = Player.PlayerData.charinfo.iban,
        phone = Player.PlayerData.charinfo.phone,
        identifier = Player.PlayerData.citizenid,
        background = Player.PlayerData.metadata.background,
        profilepicture = Player.PlayerData.metadata.profilepicture
    }
    cb(Player.PlayerData.charinfo)
end)

-- Inventory Fix
QBCore.Functions.CreateCallback('almez-phonev2:server:HasPhone', function(source, cb)
    local xPlayer = QBCore.Functions.GetPlayer(source)

    if xPlayer ~= nil then
        local HasPhone = xPlayer.Functions.GetItemByName("white_phone").amount or xPlayer.Functions.GetItemByName("blue_phone").amount or xPlayer.Functions.GetItemByName("green_phone").amount
        if HasPhone ~= nil then
            cb(true)
        else
            cb(false)
        end
    end
end)

RegisterServerEvent('almez-phonev2:server:GiveContactDetails')
AddEventHandler('almez-phonev2:server:GiveContactDetails', function(PlayerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local character = GetCharacter(src)

    local SuggestionData = {
        name = {
            [1] = Player.PlayerData.charinfo.firstname,
            [2] = Player.PlayerData.charinfo.lastname
        },
        number = Player.PlayerData.charinfo.phone,
        bank = Player.PlayerData.money["bank"],
    }

    TriggerClientEvent('almez-phonev2:client:AddNewSuggestion', PlayerId, SuggestionData)
end)

RegisterServerEvent('almez-phonev2:server:AddTransaction')
AddEventHandler('almez-phonev2:server:AddTransaction', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    ExecuteSql(false, "INSERT INTO `crypto_transactions` (`identifier`, `title`, `message`) VALUES ('"..Player.PlayerData.citizenid.."', '"..escape_sqli(data.TransactionTitle).."', '"..escape_sqli(data.TransactionMessage).."')")
end)

QBCore.Functions.CreateCallback('cash-telephone:server:GetCurrentLawyers', function(source, cb)
    local Lawyers = {}
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if Player.PlayerData.job.name == "lawyer" then
                table.insert(Lawyers, {
                    name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    phone = Player.PlayerData.charinfo.phone,
                })
            end
        end
    end
    cb(Lawyers)
end)

QBCore.Functions.CreateCallback('cash-telephone:server:GetCurrentpolices', function(source, cb)
    local polices = {}
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if Player.PlayerData.job.name == "police" and Player.PlayerData.job.grade > 7 then
                table.insert(polices, {
                    name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    phone = Player.PlayerData.charinfo.phone,
                })
            end
        end
    end
    cb(polices)
end)

function GetCharacterName(source)
    local Player = QBCore.Functions.GetPlayer(source)
	local result = exports.ghmattimysql:executeSync('SELECT * FROM players WHERE steam = @identifier', {
		['@identifier'] = Player.identifier
	})

    return result[1]
end

function GetCharacter(source)
	local result = exports.ghmattimysql:executeSync('SELECT * FROM players WHERE steam = @identifier', {
		['@identifier'] = currentOwner
	})

    return result[1]
end

function ExecuteSql(wait, query, cb)
	local rtndata = {}
	local waiting = true
	exports.ghmattimysql:execute(query, {}, function(data)
		if cb ~= nil and wait == false then
			cb(data)
		end
		rtndata = data
		waiting = false
	end)
	if wait then
		while waiting do
			Citizen.Wait(5)
		end
		if cb ~= nil and wait == true then
			cb(rtndata)
		end
    end
    
	return rtndata
end

function Lang(item)
    local lang = Config.Languages[Config.Language]

    if lang and lang[item] then
        return lang[item]
    end

    return item
end

QBCore.Functions.CreateCallback('cash-telephone:server:GetCurrentDrivers', function(source, cb)

    local drivers = {}
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if Player.PlayerData.job.name == "taxi" then
                table.insert(drivers, {
                    name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    phone = Player.PlayerData.charinfo.phone,
                })
            end
        end
    end
    cb(drivers)
end)

QBCore.Functions.CreateCallback('cash-telephone:server:GetCurrentMecano', function(source, cb)
    local drivers = {}
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if Player.PlayerData.job.name == "mechanic" then                
                table.insert(drivers, {
                    name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    phone = Player.PlayerData.charinfo.phone,
                })
            end
        end
    end
    cb(drivers)
end)

QBCore.Functions.CreateCallback('cash-telephone:server:GetCurrentDoctor', function(source, cb)
    local drivers = {}
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if Player.PlayerData.job.name == "ambulance" then
                table.insert(drivers, {
                    name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    phone = Player.PlayerData.charinfo.phone,
                })
            end
        end
    end
    cb(drivers)
end)


QBCore.Functions.CreateCallback("fizzfau-phone:LikedTweet", function(source, cb, data)
    local player = QBCore.Functions.GetPlayer(source)
    local id = tonumber(data.id)
    MyLikes[player.PlayerData.citizenid] = MyLikes[player.PlayerData.citizenid] ~= nil and MyLikes[player.PlayerData.citizenid] or {}
    MyLikes[player.PlayerData.citizenid][id] = data.bool
    TweetLikes[id] = data.bool == true and (TweetLikes[id] ~= nil and TweetLikes[id] + 1 or 1) or (TweetLikes[id] ~= nil and TweetLikes[id] - 1 or 0)
    cb(MyLikes, TweetLikes)


    exports.ghmattimysql:execute("SELECT likes FROM twitter_tweets WHERE id = @id", {
        ["@id"] = id
    }, function(result)
        if result ~= nil and result[1] ~= nil then
            local likes = json.decode(result[1].likes)
            if data.bool then
                table.insert(likes, player.PlayerData.citizenid)
            else
                for i = 1, #likes do
                    if likes[i] == player.PlayerData.citizenid then
                        table.remove(likes, i)
                        break
                    end
                end
            end
            exports.ghmattimysql:execute("UPDATE twitter_tweets SET likes = @likes WHERE id = @id", {
                ["@id"] = id,
                ["@likes"] = json.encode(likes)
            })
        end
    end)
    local players = QBCore.Functions.GetPlayers()
    for i = 1, #players do
        if source ~= players[i] then
            TriggerClientEvent("fizzfau-phone:updateLikes", players[i], id, TweetLikes)
        end
    end
end)


RegisterServerEvent("almez-phonev2:WhatsappActions")
AddEventHandler("almez-phonev2:WhatsappActions", function(data)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        if data.type == "whatsapp-clear-chat" then
            -- exports.ghmattimysql:execute("SELECT messages FROM phone_messages WHERE citizenid = '" .. player.PlayerData.citizenid.. "' AND number = '" ..data.number.. "'", function(results)
                exports.ghmattimysql:execute("UPDATE phone_messages SET `messages` = '[]' WHERE identifier = '" .. player.PlayerData.citizenid.. "' AND number = '" ..data.number.. "'")
            -- end)
        elseif data.type == "delete-message" then

        else
            exports.ghmattimysql:execute("DELETE FROM phone_messages WHERE identifier = '" .. player.PlayerData.citizenid.. "' AND number = '" ..data.number.. "'")
        end
    end
end)