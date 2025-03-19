/client/verb/creatememo(msg as message)
	set name = "Create Memo"
	set desc = "Create a global memo for all players to see later."
	set category = "OOC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)
		return

	if(!holder)
		if(!GLOB.ooc_allowed)
			to_chat(src, "<span class='danger'>OOC communications are globally muted.</span>")
			return
		if(!GLOB.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>OOC communications for dead mobs have been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='danger'>You cannot use OOC communications (muted).</span>")
			return
	if(is_banned_from(ckey, "OOC"))
		to_chat(src, "<span class='danger'>You have been banned from OOC communications.</span>")
		return
	if(QDELETED(src))
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	var/raw_msg = msg

	if(!msg)
		return

	msg = emoji_parse(msg)

	if(!holder)
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	if(!(prefs.chat_toggles & CHAT_OOC))
		to_chat(src, "<span class='danger'>You have OOC muted.</span>")
		return

	mob.log_talk("MEMO:" + raw_msg, LOG_OOC)

	send2chat("MEMO: <[key]> [raw_msg]", "ooc")

	var/keyname = key
	if(prefs.unlock_content)
		if(prefs.toggles & MEMBER_PUBLIC)
			keyname = "<font color='[prefs.ooccolor ? prefs.ooccolor : GLOB.normal_ooc_colour]'>[icon2html('icons/member_content.dmi', world, "blag")][keyname]</font>"
	if(prefs.custom_ooc)
		keyname = "<font color='[prefs.ooccolor ? prefs.ooccolor : GLOB.normal_ooc_colour]'>[keyname]</font>"
	if(prefs.hearted)
		var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/chat)
		keyname = "[sheet.icon_tag("emoji-heart")][keyname]"
	//The linkify span classes and linkify=TRUE below make ooc text get clickable chat href links if you pass in something resembling a url

	var/final_msg = "<span class='ooc'><span class='prefix'>MEMO:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></span>"

	for(var/client/C in GLOB.clients)
		if(C.prefs.chat_toggles & CHAT_OOC)
			if(holder?.fakekey in C.prefs.ignoring)
				continue
			if(holder)
				if(!holder.fakekey || C.holder)
					if(check_rights_for(src, R_ADMIN))
						final_msg = "<span class='adminooc'>[CONFIG_GET(flag/allow_admin_ooccolor) && prefs.ooccolor ? "<font color=[prefs.ooccolor]>" :"" ]<span class='prefix'>MEMO:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message linkify'>[msg]</span></span></font>"
						to_chat(C, final_msg, MESSAGE_TYPE_OOC)
					else
						final_msg = "<span class='adminobserverooc'><span class='prefix'>MEMO:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message linkify'>[msg]</span></span>"
						to_chat(C, final_msg, MESSAGE_TYPE_OOC)
				else
					if(GLOB.OOC_COLOR)
						final_msg = "<span class='oocplain'><font color='[GLOB.OOC_COLOR]'><b><span class='prefix'>MEMO:</span> <EM>[holder.fakekey ? holder.fakekey : key]:</EM> <span class='message linkify'>[msg]</span></b></font></span>"
						to_chat(C, final_msg, MESSAGE_TYPE_OOC)
					else
						final_msg = "<span class='ooc'><span class='prefix'>MEMO:</span> <EM>[holder.fakekey ? holder.fakekey : key]:</EM> <span class='message linkify'>[msg]</span></span>"
						to_chat(C, final_msg, MESSAGE_TYPE_OOC)

			else if(!(key in C.prefs.ignoring))
				if(GLOB.OOC_COLOR)
					if(check_mentor())
						final_msg = "<span class='oocplain'><font color='["#00b40f"]'><b><span class='prefix'>MEMO:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></b></font></span>"
						to_chat(C, final_msg, MESSAGE_TYPE_OOC)
					else
						final_msg = "<span class='oocplain'><font color='[GLOB.OOC_COLOR]'><b><span class='prefix'>MEMO:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></b></font></span>"
						to_chat(C, final_msg, MESSAGE_TYPE_OOC)
				else
					final_msg = "<span class='ooc'><span class='prefix'>MEMO:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></span>"
					to_chat(C, final_msg, MESSAGE_TYPE_OOC)

	var/time = time_stamp()

	var/datum/DBQuery/setmemoquery = SSdbcore.NewQuery("INSERT INTO [format_table_name("memos")] (ckey, message, datetime) VALUES (:ckey, :msg, :time)",
		list("ckey" = key, "msg" = final_msg, "time" = time)
	)
	if(!setmemoquery.warn_execute())
		qdel(setmemoquery)
		return
	qdel(setmemoquery)

/client/verb/sendmemo(dest as text, msg as message)
	set name = "Send Memo"
	set desc = "Send a memo to a specific player."
	set category = "OOC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)
		return

	if(!holder)
		if(!GLOB.ooc_allowed)
			to_chat(src, "<span class='danger'>OOC communications are globally muted.</span>")
			return
		if(!GLOB.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>OOC communications for dead mobs have been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='danger'>You cannot use OOC communications (muted).</span>")
			return
	if(is_banned_from(ckey, "OOC"))
		to_chat(src, "<span class='danger'>You have been banned from OOC communications.</span>")
		return
	if(QDELETED(src))
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	var/raw_msg = msg

	if(!msg)
		return

	msg = emoji_parse(msg)

	if(!holder)
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	if(!(prefs.chat_toggles & CHAT_OOC))
		to_chat(src, "<span class='danger'>You have OOC muted.</span>")
		return

	mob.log_talk("MEMO:" + raw_msg, LOG_OOC)

	// send2chat("MEMO: <[key]> [raw_msg]", "ooc")

	var/keyname = key
	if(prefs.unlock_content)
		if(prefs.toggles & MEMBER_PUBLIC)
			keyname = "<font color='[prefs.ooccolor ? prefs.ooccolor : GLOB.normal_ooc_colour]'>[icon2html('icons/member_content.dmi', world, "blag")][keyname]</font>"
	if(prefs.custom_ooc)
		keyname = "<font color='[prefs.ooccolor ? prefs.ooccolor : GLOB.normal_ooc_colour]'>[keyname]</font>"
	if(prefs.hearted)
		var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/chat)
		keyname = "[sheet.icon_tag("emoji-heart")][keyname]"
	//The linkify span classes and linkify=TRUE below make ooc text get clickable chat href links if you pass in something resembling a url

	var/final_msg = "<span class='ooc'><span class='prefix'>MEMO:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></span>"

	for(var/client/C in GLOB.clients)
		if(C.prefs.chat_toggles & CHAT_OOC)
			if(holder?.fakekey in C.prefs.ignoring)
				continue
			if(holder)
				if(!holder.fakekey || C.holder)
					if(check_rights_for(src, R_ADMIN))
						final_msg = "<span class='adminooc'>[CONFIG_GET(flag/allow_admin_ooccolor) && prefs.ooccolor ? "<font color=[prefs.ooccolor]>" :"" ]<span class='prefix'>MEMO:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message linkify'>[msg]</span></span></font>"
						to_chat(C, final_msg, MESSAGE_TYPE_OOC)
					else
						final_msg = "<span class='adminobserverooc'><span class='prefix'>MEMO:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message linkify'>[msg]</span></span>"
						to_chat(C, final_msg, MESSAGE_TYPE_OOC)
				else
					if(GLOB.OOC_COLOR)
						final_msg = "<span class='oocplain'><font color='[GLOB.OOC_COLOR]'><b><span class='prefix'>MEMO:</span> <EM>[holder.fakekey ? holder.fakekey : key]:</EM> <span class='message linkify'>[msg]</span></b></font></span>"
						to_chat(C, final_msg, MESSAGE_TYPE_OOC)
					else
						final_msg = "<span class='ooc'><span class='prefix'>MEMO:</span> <EM>[holder.fakekey ? holder.fakekey : key]:</EM> <span class='message linkify'>[msg]</span></span>"
						to_chat(C, final_msg, MESSAGE_TYPE_OOC)

			else if(!(key in C.prefs.ignoring))
				if(GLOB.OOC_COLOR)
					if(check_mentor())
						final_msg = "<span class='oocplain'><font color='["#00b40f"]'><b><span class='prefix'>MEMO:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></b></font></span>"
						to_chat(C, final_msg, MESSAGE_TYPE_OOC)
					else
						final_msg = "<span class='oocplain'><font color='[GLOB.OOC_COLOR]'><b><span class='prefix'>MEMO:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></b></font></span>"
						to_chat(C, final_msg, MESSAGE_TYPE_OOC)
				else
					final_msg = "<span class='ooc'><span class='prefix'>MEMO:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></span>"
					to_chat(C, final_msg, MESSAGE_TYPE_OOC)

	var/time = time_stamp()

	var/datum/DBQuery/setmemoquery = SSdbcore.NewQuery("INSERT INTO [format_table_name("direct_memos")] (keyfrom, keyto, message, datetime) VALUES (:ckey, :dest, :msg, :time)",
		list("ckey" = key, "dest" = dest, "msg" = final_msg, "time" = time)
	)
	if(!setmemoquery.warn_execute())
		qdel(setmemoquery)
		return
	qdel(setmemoquery)

/client/verb/readmemos()
	set name = "Read Memos"
	set desc = "Read all memos that have been created."
	set category = "OOC"

	var/datum/DBQuery/getmemosquery = SSdbcore.NewQuery("SELECT * FROM [format_table_name("memos")] ORDER BY datetime DESC LIMIT 10")
	if(!getmemosquery.Execute(async = TRUE))
		to_chat(src, "<span class='danger'>Failed to read memos.</span>")
		qdel(getmemosquery)
		return
	else
		var/list/memos = list()
		while(getmemosquery.NextRow())
			memos += list(getmemosquery.item)
		qdel(getmemosquery)

		if(!length(memos))
			to_chat(src, "<span class='danger'>There are no memos to read.</span>")
			return

		for(var/memo in memos)
			var/msg = memo[3]
			var/datetime = memo[4]
			msg = replacetext(msg, "<span class='prefix'>MEMO:", "<span class='prefix'>\[[datetime]\]:</span>")
			to_chat(src, msg, MESSAGE_TYPE_OOC)

		to_chat(src, "<span class='notice'>End of memos.</span>")

/client/verb/readdirectmemos()
	set name = "Read Direct Memos"
	set desc = "Read all direct memos that have been sent to you specifically."
	set category = "OOC"

	var/datum/DBQuery/getmemosquery = SSdbcore.NewQuery("SELECT * FROM [format_table_name("direct_memos")] WHERE (keyto = ?) ORDER BY datetime DESC",
		list(key)
	)
	if(!getmemosquery.Execute(async = TRUE))
		to_chat(src, "<span class='danger'>Failed to read direct memos.</span>")
		qdel(getmemosquery)
		return
	else
		var/list/memos = list()
		while(getmemosquery.NextRow())
			memos += list(getmemosquery.item)
		qdel(getmemosquery)

		if(!length(memos))
			to_chat(src, "<span class='danger'>There are no direct memos to read.</span>")
			return

		for(var/memo in memos)
			var/msg = memo[4]
			var/datetime = memo[5]
			msg = replacetext(msg, "<span class='prefix'>MEMO:", "<span class='prefix'>\[DIRECT: [datetime]\]:</span>")
			to_chat(src, msg, MESSAGE_TYPE_OOC)

		to_chat(src, "<span class='notice'>End of direct memos.</span>")

