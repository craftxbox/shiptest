/mob/dead/new_player/Login()
	if(!client)
		return
	if(CONFIG_GET(flag/use_exp_tracking))
		client.set_exp_from_db()
		client.set_db_player_flags()
	if(!mind)
		mind = new /datum/mind(key)
		mind.active = TRUE
		mind.set_current(src)

	. = ..()
	if(!. || !client)
		return FALSE

	var/motd = global.config.motd
	if(motd)
		to_chat(src, "<div class=\"motd\">[motd]</div>", handle_whitespace=FALSE)

	if(SSdbcore.IsConnected())
		var/datum/DBQuery/getmemosquery = SSdbcore.NewQuery("SELECT * FROM [format_table_name("memos")] ORDER BY datetime DESC LIMIT 10")
		if(!getmemosquery.Execute(async = TRUE))
			qdel(getmemosquery)
			return
		else
			var/list/memos = list()
			while(getmemosquery.NextRow())
				memos += list(getmemosquery.item)
			qdel(getmemosquery)

			if(!length(memos))
				to_chat(src, "<span class='notice'>There are no memos to read.</span>")
				return

			for(var/memo in memos)
				var/msg = memo[3]
				var/datetime = memo[4]
				msg = replacetext(msg, "<span class='prefix'>MEMO:", "<span class='prefix'>\[[datetime]\]:</span>")
				to_chat(src, msg, MESSAGE_TYPE_OOC)

			to_chat(src, "<span class='notice'>End of memos.</span>")

		var/datum/DBQuery/getDirectMemosQuery = SSdbcore.NewQuery("SELECT * FROM [format_table_name("direct_memos")] WHERE (keyto = ?) ORDER BY datetime DESC",
			list(client.ckey)
		)
		if(!getDirectMemosQuery.Execute(async = TRUE))
			qdel(getDirectMemosQuery)
			return
		else
			var/list/memos = list()
			while(getDirectMemosQuery.NextRow())
				memos += list(getDirectMemosQuery.item)
			qdel(getDirectMemosQuery)

			if(!length(memos))
				to_chat(src, "<span class='danger'>There are no direct memos to read.</span>")
				return

			for(var/memo in memos)
				var/msg = memo[4]
				var/datetime = memo[5]
				msg = replacetext(msg, "<span class='prefix'>MEMO:", "<span class='prefix'>\[DIRECT: [datetime]\]:</span>")
				to_chat(src, msg, MESSAGE_TYPE_OOC)

			to_chat(src, "<span class='notice'>End of direct memos.</span>")

	if(GLOB.admin_notice)
		to_chat(src, "<span class='notice'><b>Admin Notice:</b>\n \t [GLOB.admin_notice]</span>")

	var/spc = CONFIG_GET(number/soft_popcap)
	if(spc && living_player_count() >= spc)
		to_chat(src, "<span class='notice'><b>Server Notice:</b>\n \t [CONFIG_GET(string/soft_popcap_message)]</span>")

	sight |= SEE_TURFS

	client.playtitlemusic()


	// Check if user should be added to interview queue
	if (!client.holder && CONFIG_GET(flag/panic_bunker) && CONFIG_GET(flag/panic_bunker_interview) && !(client.ckey in GLOB.interviews.approved_ckeys))
		var/required_living_minutes = CONFIG_GET(number/panic_bunker_living)
		var/living_minutes = client.get_exp_living(TRUE)
		if (required_living_minutes > living_minutes)
			register_for_interview()
			return
	client.interviewee = FALSE

	new_player_panel()
	if(SSticker.current_state < GAME_STATE_SETTING_UP)
		var/tl = SSticker.GetTimeLeft()
		to_chat(src, "Please set up your character and select \"Ready\". The game will start [tl > 0 ? "in about [DisplayTimeText(tl)]" : "soon"].")
