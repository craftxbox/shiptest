/datum/species/vulpkanin
	name = "\improper Vulpkanin"
	id = SPECIES_VULPKANIN
	default_color = "CA4D00"
	species_traits = list(HAIR, FACEHAIR, MUTCOLORS,MUTCOLORS_SECONDARY,EYECOLOR,EMOTE_OVERLAY)
	inherent_traits = list(TRAIT_HEARING_SENSITIVE)
	default_features = list("mcolor" = "FFF", "tail_vulp" = "Fluffy", "tail_vulp_marks" = "None", "body_marking_vulp" = "None", "head_marking_vulp" = "None", "body_size" = "Normal")
	mutant_bodyparts = list("tail_vulp", "tail_vulp_marks", "body_marking_vulp", "head_marking_vulp")
	skinned_type = /obj/item/stack/sheet/animalhide/corgi // Could not bother.
	disliked_food = GROSS | CLOTH
	liked_food = MEAT | RAW
	digitigrade_customization = DIGITIGRADE_FORCED
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	loreblurb = "Vulpkanin are bipedal canid-like beings from the Vazzend binary system, having been forced from their homeworld by a cataclysmic event and scattered throughout the Orion Sector. \
	While Vulpkanin are chiefly led by independent planetary governments, they also serve under a loose federation known as The Assembly.<br/><br/> \
	Their religious systems traditionally pay tribute to an all-infusing universal will called 'Racht'. \
	Vulpkanin groups are minor players in galactic affairs, as they are largely concerned with the restoration of their homeworld."

	bodytype = BODYTYPE_SNOUT
	mutanttongue = /obj/item/organ/tongue/vulpkanin
	species_language_holder = /datum/language_holder/vulpkanin

	species_chest = /obj/item/bodypart/chest/vulpkanin
	species_head = /obj/item/bodypart/head/vulpkanin
	species_l_arm = /obj/item/bodypart/l_arm/vulpkanin
	species_r_arm = /obj/item/bodypart/r_arm/vulpkanin
	species_digi_l_leg = /obj/item/bodypart/leg/left/vulpkanin
	species_digi_r_leg = /obj/item/bodypart/leg/right/vulpkanin

/datum/species/vulpkanin/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)

	// this entire switch block makes me sad :(
	switch(C.dna.features["tail_vulp"])
		if("Fluffy")
			switch(C.dna.features["tail_vulp_marks"])
				if("Fade")
					mutant_organs |= /obj/item/organ/tail/vulpkanin/fluffy/fade
				if("Tip")
					mutant_organs |= /obj/item/organ/tail/vulpkanin/fluffy/tip
				else
					mutant_organs |= /obj/item/organ/tail/vulpkanin/fluffy
		if("Nine Sune")
			switch(C.dna.features["tail_vulp_marks"])
				if("Fade")
					mutant_organs |= /obj/item/organ/tail/vulpkanin/ninesune/fade
				if("Tip")
					mutant_organs |= /obj/item/organ/tail/vulpkanin/ninesune/tip
				else
					mutant_organs |= /obj/item/organ/tail/vulpkanin/ninesune
		if("Paintbrush")
			switch(C.dna.features["tail_vulp_marks"])
				if("Fade")
					mutant_organs |= /obj/item/organ/tail/vulpkanin/paintbrush/fade
				if("Tip")
					mutant_organs |= /obj/item/organ/tail/vulpkanin/paintbrush/tip
				else
					mutant_organs |= /obj/item/organ/tail/vulpkanin/paintbrush
		if("Seven Sune")
			switch(C.dna.features["tail_vulp_marks"])
				if("Fade")
					mutant_organs |= /obj/item/organ/tail/vulpkanin/sevensune/fade
				if("Tip")
					mutant_organs |= /obj/item/organ/tail/vulpkanin/sevensune/tip
				else
					mutant_organs |= /obj/item/organ/tail/vulpkanin/sevensune
		if("Sleek")
			switch(C.dna.features["tail_vulp_marks"])
				if("Fade")
					mutant_organs |= /obj/item/organ/tail/vulpkanin/sleek/fade
				if("Tip")
					mutant_organs |= /obj/item/organ/tail/vulpkanin/sleek/tip
				else
					mutant_organs |= /obj/item/organ/tail/vulpkanin/sleek
		if("Up")
			switch(C.dna.features["tail_vulp_marks"])
				if("Fade")
					mutant_organs |= /obj/item/organ/tail/vulpkanin/up/fade
				if("Tip")
					mutant_organs |= /obj/item/organ/tail/vulpkanin/up/tip
				else
					mutant_organs |= /obj/item/organ/tail/vulpkanin/up

	return ..()

// /datum/species/vulpkanin/spec_death(gibbed, mob/living/carbon/human/H)
// 	if(H)
// 		stop_wagging_tail(H)

// /datum/species/vulpkanin/spec_stun(mob/living/carbon/human/H,amount)
// 	if(H)
// 		stop_wagging_tail(H)
// 	. = ..()

/datum/species/vulpkanin/can_wag_tail(mob/living/carbon/human/H)
	return FALSE; // i do not have the sprites, sorry :(

	//return ("tail_vulp" in mutant_bodyparts) || ("waggingtail_vulp" in mutant_bodyparts)

// /datum/species/vulpkanin/is_wagging_tail(mob/living/carbon/human/H)
// 	return ("waggingtail_vulp" in mutant_bodyparts)

// /datum/species/vulpkanin/start_wagging_tail(mob/living/carbon/human/H)
// 	if("tail_vulp" in mutant_bodyparts)
// 		mutant_bodyparts |= "waggingtail_vulp"
// 		mutant_bodyparts -= "tail_vulp"
// 	H.update_body()

// /datum/species/vulpkanin/stop_wagging_tail(mob/living/carbon/human/H)
// 	if("waggingtail_vulp" in mutant_bodyparts)
// 		mutant_bodyparts -= "waggingtail_vulp"
// 		mutant_bodyparts |= "tail_vulp"
// 	H.update_body()
