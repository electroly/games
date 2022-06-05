pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--parry ii: the quest for uncle matt
--by brian luft

function _init()
	--show cpu and ram
	show_debug_info=true

	--0=easy, 1=medium, 2=hard
	difficulty=0

	--button constants
	btn_l=0
	btn_r=1
	btn_u=2
	btn_d=3
	btn_o=4
	btn_x=5
	
	--color constants
	clr_bla=0
	clr_dblu=1
	clr_dpur=2
	clr_dgre=3
	clr_bro=4
	clr_dgra=5
	clr_lgra=6
	clr_whi=7
	clr_red=8
	clr_ora=9
	clr_yel=10
	clr_gre=11
	clr_blu=12
	clr_lav=13
	clr_pin=14
	clr_pea=15
	clr2=128 --offset
	
	pal_default={[0]=0,1,2,3,4,5,6,7,
		8,9,10,11,12,13,14,15}
	pal_dark={[0]=0,129,130,131,132,1,
		5,6,136,137,9,139,140,141,2,
		143}
	pal_black={[0]=0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0}

 --last btn state, for edge
 --triggering
 lstbtn={}
 btnup={}
 btndn={}
 for i=0,5 do
 	lstbtn[i]=false
 	btnup[i]={}
 	btndn[i]={}
 end
 
 --last stats, for edge trig.
 lststat={}
 statchg={}
 for i=46,57 do
 	lststat[i]=stat(i)
 	statchg[i]=false
 end

	init_font1()
 
	--scenes
	scn={
		title=0
		,intro=1
		,gamesuccess=2
		,gamefailed=3
		,nextgame=4
		,worldmap=5
		,levelstart=6
		,levelend=7
		--games
		,g01=10 --matt in diaper
		,g02=11 --lift weights
		,g03=12 --find parry
		,g04=13 --eat carrots
		--levels
		,l01=100 --buzz
	}
	
	playlist={}
	playlist_level=0
	
	--parry's starting position
	--on the map
	map_px=2
	map_py=3
	
	change_scene(scn.title)
end

function _update60()
	ctr+=1
	if(ctr<0)ctr=15000

	--button edge triggering
	for i=0,5 do
	 local lst=lstbtn[i]
		local now=btn(i)
		btnup[i]=lst and not now
		btndn[i]=now and not lst
		lstbtn[i]=now
	end

	--stat edge triggering
 for i=46,57 do
 	local lst=lststat[i]
 	local now=stat(i)
 	statchg[i]=lst!=now
 	lststat[i]=now
 end
	
	if scene==scn.title then
		title_update()
	elseif scene==scn.intro then
		intro_update()
	elseif scene==scn.worldmap then
		worldmap_update()
	elseif scene==scn.g01 then
		g01_update()
	elseif scene==scn.g02 then
		g02_update()
	elseif scene==scn.g03 then
		g03_update()
	elseif scene==scn.g04 then
		g04_update()
	elseif scene==scn.gamesuccess then
		gamesuccess_update()
	elseif scene==scn.gamefailed then
		gamefailed_update()
	elseif scene==scn.levelstart then
		levelstart_update()
	elseif scene==scn.levelend then
		levelend_update()
	elseif scene==scn.l01 then
		l01_update()
	end
end

function _draw()
	--disable per-line palette
	poke(0x5f5f,0)
	memset(0x5f70,0,16)

	--default palette
	pal()

	--if we just changed scene in
	--update(), then we haven't
	--yet ran update() for the new
	--scene. skip the first frame
	--so the new scene can update
	--before we draw it.
	if(ctr==0)return
	
	if scene==scn.title then
		title_draw()
	elseif scene==scn.intro then
		intro_draw()
	elseif scene==scn.worldmap then
		worldmap_draw()
	elseif scene==scn.g01 then
		g01_draw()
	elseif scene==scn.g02 then
		g02_draw()
	elseif scene==scn.g03 then
		g03_draw()
	elseif scene==scn.g04 then
		g04_draw()
	elseif scene==scn.gamesuccess then
		gamesuccess_draw()
	elseif scene==scn.gamefailed then
		gamefailed_draw()
	elseif scene==scn.levelstart then
		levelstart_draw()
	elseif scene==scn.levelend then
		levelend_draw()
	elseif scene==scn.l01 then
		l01_draw()
	end
	
	if show_debug_info then
		local mem=flr(100*stat(0)/2048)
		local cyc=flr(100*stat(1))
		print(
			"c:"..cyc.."% m:"..mem.."%",
			60,0,clr_red)
	end
end

function change_scene(n)
	if n==scn.nextgame then
		if #playlist==0 then
			n=scn.levelend
		else
			n=playlist[1]
			deli(playlist,1)
		end
	end
	
	scene=n
	scst={} --scene state
	ctr=0
	if scene==scn.title then
		title_init()
	elseif scene==scn.intro then
		intro_init()
	elseif scene==scn.worldmap then
		music(6)
		worldmap_init()
	elseif scene==scn.g01 then
		g01_init()
	elseif scene==scn.g02 then
		g02_init()
	elseif scene==scn.g03 then
		g03_init()
	elseif scene==scn.g04 then
		g04_init()
	elseif scene==scn.gamesuccess then
		gamesuccess_init()
	elseif scene==scn.gamefailed then
		gamefailed_init()
	elseif scene==scn.levelstart then
		levelstart_init()
	elseif scene==scn.levelend then
		levelend_init()
	elseif scene==scn.l01 then
		l01_init()
	end
end

--title--
function title_init()
	music(0)
	title_end_ctr=nil
end

function title_update()
	if title_end_ctr==60 then
		change_scene(scn.intro)
	elseif title_end_ctr!=nil then
		title_end_ctr+=1
	elseif btndn[5] then
		music(-1)
		sfx(0,3)
		title_end_ctr=0
	end
end

function title_draw()
	cls(1)
	sspr(0,32,32,16,centerx(32),30)
	local t="the quest for uncle matt"
	print_wavy(t,center_text(t),55,14)
	t="press ❎ to play"
	print_font1(t,centerx(font1_width(t)),80)
	t="pc keys: ❎x 🅾️c"
	print_font1(t,centerx(font1_width(t)),110)
	t="(c) 2022 brian luft"
	print_font1(t,centerx(font1_width(t)),120)
	if title_end_ctr!=nil then
		transition1(title_end_ctr/30)
	end
end
--end title--

--intro--
function intro_init()
	music(3)
	int_step=0
	int_end_ctr=nil
end

function intro_update()
	if int_end_ctr!=nil then
		int_end_ctr+=1
		if int_end_ctr==60 then
			change_scene(scn.worldmap)
		end
		return
	end
	
 if int_step==0 then
 	sfx(0,3)
 	int_step=1
	elseif int_step==7 then
		music(-1)
		int_end_ctr=0
	elseif btndn[btn_x] then
		sfx(0,3)
		int_step+=1
	end
end

function intro_draw()
	rectpattern(0,0,127,127,
		clr_dblu,clr_dblu,
		clr_dpur,clr_dpur)

	if int_step==1 then
		sam_dlg({
			"parry, wake up!"
		})
	elseif int_step==2 then
		parry_dlg({
			"ugh..."
			,""
			,"what do you want?"
		})
	elseif int_step==3 then
		sam_dlg({
			"uncle matt has been"
			,"captured by the villain"
			,"will rabbit!"
		})
	elseif int_step==4 then
		sam_dlg({
			"he is imprisoned at"
			,"franklin castle!"
		})
	elseif int_step==5 then
		parry_dlg({
			"oh no!"
			,""
			,"it's up to me to save him!"
		})
	elseif int_step>=6 then
		sam_dlg({
			"i know! that's why i told"
			,"you!"
			,""
			,"see ya!"
		})
	end
	
	if int_end_ctr!=nil then
		transition1(int_end_ctr/30)
	end
end
--end intro--

--worldmap--
function worldmap_init()
	--map_px, map_py already set
	map_odd=false
	map_pulse=0
	map_offx=0
	map_offy=0
	map_end_ctr=nil
	map_end_next=nil --next scene
end

function worldmap_canmove(offx,offy)
	return fget(mget(
		map_px+offx,map_py+offy),0)
end

function worldmap_update()
	if map_end_ctr!=nil then
		map_end_ctr+=1
		if map_end_ctr==60 then
			change_scene(map_end_next)
		end
		return
	end

	map_pulse+=1
	if statchg[50] then
		if (stat(50)%4)==0 then
			worldmap_flip_waves()
			map_odd=not map_odd
		end
		if (stat(50)%8)==0 then
			map_pulse=0
		end
	end
	
	if mget(map_px,map_py)!=14 and btndn[btn_x] then
		if map_px==4 and map_px==4 then
			music(-1)
			sfx(2,3)
			map_end_next=scn.l01
			map_end_ctr=0
		end
	end
	
	if map_offx<=-8 then
		map_px-=1
		map_offx=0
	elseif map_offx>=8 then
		map_px+=1
		map_offx=0
	elseif map_offx>0 then
		map_offx+=1
	elseif map_offx<0 then
		map_offx-=1
	end
	if map_offx==0 then
		if	btn(btn_l) then
			if(worldmap_canmove(-1,0))map_offx=-1
		elseif btn(btn_r) then
			if(worldmap_canmove(1,0))map_offx=1
		end
	end

	if map_offy<=-8 then
		map_py-=1
		map_offy=0
	elseif map_offy>=8 then
		map_py+=1
		map_offy=0
	elseif map_offy>0 then
		map_offy+=1
	elseif map_offy<0 then
		map_offy-=1
	end
	if map_offy==0 then
		if	btn(btn_u) then
			if(worldmap_canmove(0,-1))map_offy=-1
		elseif btn(btn_d) then
			if(worldmap_canmove(0,1))map_offy=1
		end
	end
end

function worldmap_draw()
	map(0,0,0,0,16,16)
	local parspr=2
	local px=map_offx+map_px*8
	local py=map_offy+map_py*8
	if(map_odd)parspr=3
	sproutline(parspr,0,px,py-2)
	
	rectfill(60,121,127,127,1)
	print_font1("use: ⬅️➡️⬆️⬇️❎",
		64,122)
	
	if map_end_ctr!=nil then
		transition1(map_end_ctr/30)
	end
end

function worldmap_flip_waves()
	for x=0,16 do
		for y=0,16 do
			local s=mget(x,y)
			if s==41 then
				s=23
			elseif s==23 then
				s=41
			end
			mset(x,y,s)
		end
	end
end
--end worldmap--

--l01--
function l01_init()
	music(10)
	l01_step=0
	l01_end_ctr=nil
	
	difficulty=0
	playlist={
		scn.g01
		--,scn.g02
		--,scn.g03
	}
	playlist_level=1
end

function l01_update()
	if l01_end_ctr!=nil then
		l01_end_ctr+=1
		if l01_end_ctr==60 then
			lvlstr_ts={
				"complete 3 games",
				"for buzz!"
			}
			change_scene(scn.levelstart)
		end
		return
	end

	if btndn[btn_x] then
		sfx(0,3)
		l01_step+=1
		if(l01_step==5)l01_end_ctr=0
	end
end

function l01_draw()
	rectfill(0,0,127,127,
		clr_dgre)
	if l01_step==0 then
		buzz_dlg({
			"hey, parry! parry!"
			,""
			,"wait up!"
		})
	elseif l01_step==1 then
		parry_dlg({
			"hi buzz. i'm on a mission"
			,"to save uncle matt!"
			,""
			,"can this wait?"
		})
	elseif l01_step==2 then
		buzz_dlg({
			"yes, i'm sure uncle matt"
			,"can wait!"
			,""
			,"it'll only take a minute."
		})
	elseif l01_step==3 then
		buzz_dlg({
			"i just need a few things..."
		})
	elseif l01_step>=4 then
		parry_dlg({
			"(sigh.) fine."
			,""
			,"but then i need to"
			,"get back to my quest!"
		})
	end
	
	if l01_end_ctr!=nil then
		transition1(l01_end_ctr/30)
	end
end
--end l01--

-->8
--art
function art_mattchamp(x,y,scl)
	poly_start(
		--the art doesn't start at
		--0,0; just fix it here
		x-13*scl,
		y-5*scl,
		scl,scl)
	--skin
	poly(15,{
		2820,3821,5224,5831,5742,
		7246,7551,7557,7561,7264,
		6470,6478,5386,3993,3194,
		2691,2485,2182,2375,2270,
		2164,1959,1951,2136,2428,
		2820})
	--glasses side
	poly(5,{
		5042,5055,5849,7349,7246,
	 5744,5042})
	--glasses left
	poly(0,{
		1336,2136,2839,2845,
		2251,1951,1650,1344,1336})
	--glasses right
	poly(0,{
		2839,4139,5042,
		5055,4656,3956,3153,2845,
		2839})
	--hair
	poly(4,{
		7246,5742,5831,5224,3821,
		2820,2715,3211,4006,6307,
		6911,7620,8237,7845,8150,
		8156,7562,7566,7968,7774,
		7075,6478,6470,7264,7557,
		7551,7349})
	--mouth
	poly(0,{
		2270,2871,3376,2883,2485,
		2182,2375,2270})
	--nose
	poly_line(0,{
		2845,2351,2056,1959,2362,
		2862})
	--ear
	poly_line(0,{
		6756,7059,6962,6562})
end

function art_diaper(x,y,scl)
	poly_start(x,y,scl,scl)
	--diaper
	poly(7,{
		8913,7119,5921,3921,2419,
		0912,0652,1455,2565,3176,
		3296,6596,6778,7464,8356,
		9353,8913
	})
	--top hole
	poly(5,{
		0912,2904,4803,7004,8913,
		7119,5921,3921,2419,0912})
	--left leg hole
	poly(5,{
		0652,0870,1581,3296,3176,
		2565,1455,0652})
	--right leg hole
	poly(5,{
		6596,6778,7464,8356,9353,
		9170,8285,6596})
	--left tape
	poly(14,{
		0424,2429,2734,2540,1841,
		0237,0424})
	--right tape
	poly(14,{
		9425,9637,8042,7541,7136,
		7431,7928,9425})
end

function art_parry_sitting(x,y,scl)
	poly_start(x,y,scl,scl)
	--tail
	poly(1018,{
		2061,1548,3348,3561,3665,3775,
		3899,3096,2988,2886,2781,2676,
		2473,2268,2061
	})
	--white face
	poly(7,{
		0203,1503,1705,1909,2013,1918,
		1220,1416,1311,0706,0311,0207,
		0203
	})
	--yellow body
	poly(10,{
		1705,1906,2209,2417,2719,2826,
		3135,3442,3751,3348,1548,1143,
		1035,0829,0527,0421,1220,1918,
		2013,1909,1705
	})
	--green top of head
	poly(11,{
		0203,0401,0800,1300,1803,2209,
		1906,1705,1503,0203
	})
	--brown beak
	poly(4,{
		0706,1311,1416,1220,0419,0317,
		0311,0706
	})
	--black beak outline
	poly_line(0,{
		1213,0810,0317
	})
	--blue left wing
	poly(12,{
		1548,1143,1035,0829,0527,0421,
		0224,0132,0238,0545,0848,0951,
		1355,1548
	})
	--blue right wing
	poly(12,{
		2719,2826,3135,3442,3751,3847,
		4036,3825,3721,3416,2815,2719
	})
	--black eye
	poly(0,{
		1107,1405,1507,1308,1107
	})
end

function art_parry_flap1(x,y,scl)
	--offset so it fits talons
	x-=27*scl
	y+=18*scl
	poly_start(x,y,scl,scl)
	polys({
		--tail
		"1018 4324 5924 5231 4537 4137 3343 3930 4324",
		"1018 4137 4537 4142 3449 4040 4137",
		"1018 4537 4449 4156 4651 4843 5231 4537",
		"1018 5224 5231 5443 6054 5847 5942 6239 6132 5924 5224",
		"1018 5924 6132 6539 7445 6838 6733 5924",
		--left wing
		"0010 0019 0313 0410 0709 0906 1605 2504 1513 0019",
		"0010 0722 1513 2504 3802 4505 4708 4718 4821 5224 4324 3228 2128 1427 1024 0722",
		"0012 6607 7405 7909 8414 8820 7711 7208 6607",
		"0012 0410 0904 2702 3802 1006 0709 0410",
		"9999 0009 2312 1124",
		"9999 0009 2613 2128",
		"9999 0009 2814 2728",
		"9999 0009 3014 3228",
		"9999 0009 3516 3726",
		"9999 0009 3918 4025",
		--right wing
		"0010 5224 5521 5718 5714 5910 6108 6607 7208 7711 8820 9931 9638 8537 7434 6728 5924 5224",
		"9999 0009 6213 6125",
		"9999 0009 6418 6527",
		"9999 0009 6818 7132",
		"9999 0009 7218 7735",
		"9999 0009 7720 8236",
		"9999 0009 8121 8837",
		"9999 0009 8522 9638",
		--top of head
		"0011 4718 4914 5213 5514 5718 5416 5016 4718",
		--face
		"0007 4718 5016 5416 5718 5521 5224 4821 4718",
		--beak
		"0004 5018 5220 5221 5422 4922 5018"
	})	
end

function art_parry_flap2(x,y,scl)
	x-=24*scl
	y+=10*scl
	poly_start(x,y,scl,scl)
	polys({
		--tail
		"1018 2653 3935 3743 2653",
		"1018 3935 3743 3362 3948 4335 3935",
		"1018 4335 3948 4165 4366 4757 4952 5249 4836 4335",
		"1018 4836 5249 5860 5545 5236 4836",
		"1018 5236 5545 6252 5538 5236",
		--right wing
		"0010 5237 5522 5615 5812 6016 6027 5531 5236",
		"0010 5812 6910 7516 8120 8525 8128 7729 6633 6027 6016 5812",
		"0010 6910 7409 8719 8622 8120 7516 6910",
		"0010 7409 8719 9622 9915 9312 8409 7409",
		"0012 5522 5414 5710 6608 8509 7409 6910 5812 5615 5522",
		"9999 0009 6421 6633",
		"9999 0009 6919 7729",
		"9999 0009 7516 8322",
		"9999 0009 8114 8719",
		--left wing
		"0010 0610 1105 3003 3806 4409 4535 3935 3727 2121 1418 0610",
		"0012 1105 3201 4409 3806 3003 1105",
		"9999 0009 2607 0610",
		"9999 0009 2709 1316",
		"9999 0009 3212 2121",
		"9999 0009 3612 3125",
		"9999 0009 4018 3727",
		--face
		"0007 4231 4824 5231 5236 4836 4535 4231",
		"9999 0000 4931 5133",
		"9999 0000 4730 4631",
		--beak
		"0004 4732 4933 4934 4636 4732",
		--top of head
		"0011 4528 4825 5226 5330 4827 4528"
	})
end

function art_parry_talons(x,y,scl)
	poly_start(x,y,scl,scl)
	--left talon
	poly(4,{
		1548,1355,1561,1961,1755,2048,
		1548
	})
	--right talon
	poly(4,{
		2749,3053,2958,3360,3459,3553,
		3348,2749
	})
end

function art_barbell(x,y)
	x-=19
	y+=19
	sspr(0,64,16,16,x,y)
	x+=16
	for i=1,4 do
		sspr(16,64,8,16,x,y)
		x+=8
	end
	sspr(0,64,16,16,x,y,16,16,true)
end

function art_timer(maxctr)
	sspr(48,32,16,16,112,112)
	local pct=ctr/maxctr
	local i=flr(pct*8)
	if(i<8)spr(72+i,116,116)
end

function art_portrait_parry(x,y)
	poly_start(x,y,1,1)
	polys({
		--inside of mouth
		"0000 6128 6239 6945 7136 7636 7126 6128"
		--top of head
		,"0011 7303 7707 6207 5505 6002 7303"
		--face
		,"0007 4613 5008 5505 6207 7707 8013 7513 7215 6917 6522 6326 6031 5735 5941 5338 4935 4731 4725 4920 4618 4613"
		--beak top
		,"0004 8013 8120 8032 7938 7741 7543 7436 7133 6631 6229 6326 6522 6917 7215 7513 8013"
		--beak bottom
		,"0004 6228 6536 6640 6743 7046 6445 5941 5734 6031 6228"
		--tongue
		,"0014 6733 6736 6839 7139 7237 7034 6733"
		--eye
		,"0000 5412 5614 5617 5318 5215 5412"
		--neck
		,"0000 4516 4125 4228 4431 4636 5040 5744 6045 6445 5941 5338 4935 4731 4725 4920 4618 4613 4516"
		--chest
		,"0010 4613 4021 3731 3639 4143 4650 4459 3871 3280 2590 2699 6399 6795 7090 7279 7373 7563 7355 7151 7046 6445 6045 5744 5040 4636 4431 4228 4125 4516 4613"
		--left wing
		,"0012 3639 4143 4650 4459 3871 3280 2590 2198 1799 1691 1779 1867 1961 2153 2545 2840 3639"
		--right wing
		,"0012 7341 7746 7851 7758 7563 7355 7151 7045 7042 7341"
		--face lines
		,"9999 0000 5622 5122 4920"
		,"9999 0000 5724 5027 4824"
		,"9999 0000 5727 5329 4932"
		,"9999 0000 6119 5916 6012 5908"
		,"9999 0000 6415 6212 6311 6108"
		,"9999 0000 6613 6610 6509 6613"
	})
end


function art_portrait_sam(x,y)
	poly_start(x,y,1,1)
	polys({
		--body
		"0000 7416 8016 8420 8725 8930 9034 8945 9052 9355 9657 9960 9966 5766 6162 6259 7148 6339 6138 6429 7416"
		--beak top
		,"0009 2212 2813 3016 2919 2622 3922 5024 6227 6929 7122 7416 6712 6110 5609 4808 3908 3009 2610 2212"
		--beak top black part
		,"0000 2622 1923 1425 1128 1121 1516 1913 2212 2813 3016 2919 2622"
		--beak bottom
		,"0009 1244 1242 1737 2434 2932 3531 4030 5029 6330 6731 6138 2639 2040 1244"
		--white part of body
		,"0007 7231 7831 8030 8332 8435 8439 8345 8252 7858 7461 6561 6259 6251 6345 6443 6341 6339 6538 6837 7134 7231"
		--orange part around eye
		,"0009 7519 7720 8023 8126 8129 8030 7831 7231 7229 7324 7322 7519"
		--blue part around eye
		,"0001 7523 7823 7926 7729 7529 7427 7425 7523"
		--eye
		,"0000 7624 7826 7627 7526 7624"
	})
end

function art_portrait_buzz(x,y)
	poly_start(x,y,0.35,0.35)
	polys({
		--right wing
		"0005 5028 4920 4910 5006 5202 5500 5805 6111 6312 6515 6523 6325 5028"
		--body, black parts
		,"0000 3927 5023 5523 6125 8845 9150 9253 9461 9363 8863 8465 7069 6766 5157 4957 4353 4247 2746 2343 2339 2436 2631 3029 3428 3927"
		,"0000 2746 2750 2854 2563 2665 3153 3548 3746 2746"
		--body, yellow parts
		,"0010 4543 4338 4235 4132 4126 4423 5023 5028 5032 5334 4940 4743 4543"
		,"0010 5941 6539 6936 7535 8035 8338 8640 8943 8646 8050 7651 7253 6752 6648 6643 5941"
		,"0010 7357 7658 7960 8064 8072 7677 7173 7069 7059 7357"
		,"0010 5759 6560 6764 6766 6568 5663 5661 5759"
		--body, white parts
		,"0007 9461 9467 9273 8878 8580 7879 7776 8072 8065 8465 8863 9363 9461"
		--legs
		,"9999 0000 3846 3653 3662 3172"
		,"9999 0000 4247 4156 4064 4169 4073 3875"
		,"9999 0000 5157 5166 4675 4484"
		,"9999 0000 5659 5768 5276 5282 5085"
		,"9999 0000 6262 6075 5979 5886 5687"
		,"9999 0000 7173 6888 7098"
		--left wing
		,"0006 5136 5434 6724 8011 8507 9104 9503 9608 9313 9019 8823 8429 7933 7335 6835 6534 5935 5437 5237 5136"
		--antennas
		,"9999 0000 2830 2825 2120 1017"
		,"9999 0000 2535 2129 1729 0730 0133"
		--eye
		,"0007 3235 3537 3239 3038 3036 3235"
	})
end
-->8
--games

function default_maxtime()
	if(difficulty==1)return 400
	if(difficulty==2)return 200
	return 600
end

--levelstart--
function levelstart_init()
	--caller set:
	--lvlstr_ts
end

function levelstart_update()
	if(ctr==180 or btndn[btn_x])change_scene(scn.nextgame)
end

function levelstart_draw()
	cls(clr_dblu)
	draw_dlg(lvlstr_ts,20,clr_dgra)
end
--end levelstart--

--levelend--
function levelend_init()
	music(-1)
	sfx(29,3)
end

function levelend_update()
	if ctr==180 then
		if playlist_level==1 then
			mset(4,3,14)
			mset(10,5,29)
			mset(5,7,45)
			for x=5,9 do
				mset(x,3,60)
			end
			mset(10,3,44)
			mset(10,4,28)
			for y=4,6 do
				mset(4,y,28)
			end
			mset(4,7,61)
		end
		change_scene(scn.worldmap)
	end
end

function levelend_draw()
	cls(clr_dblu)
	draw_dlg({"parry cleared the level!"},20,clr_blu)
end
--end levelend--

--gamesuccess--
function gamesuccess_init()
	if(#playlist==0)change_scene(scn.nextgame)
end

function gamesuccess_update()
	if(ctr==120)change_scene(scn.nextgame)
end

function gamesuccess_draw()
	cls(1)
	local t="good job!"
	print_font1(t,
		centerx(font1_width(t)),
		30)
	local s="s"
	if(#playlist==1)s=""
	t=#playlist.." game"..s.." left"
	print_font1(t,
		centerx(font1_width(t)),
		40)

	if (flr(ctr/30)%2)==0 then
		art_parry_sitting(
			55,70,0.4)
	else
		art_parry_flap1(45,
			50,0.8)
	end
	art_parry_talons(
		55,70,0.4)
end
--end gamesuccess--

--gamefailed--
function gamefailed_init()
	music(-1)
	sfx(28,3)
end

function gamefailed_update()
	if(ctr==240)change_scene(scn.worldmap)
end

function gamefailed_draw()
	cls(0)
	local ts={
		{t="oh no!",y=50}
		,{t="you ran out of time!",y=70}
	}
	for _,x in pairs(ts) do
		print_font1(x.t,centerx(font1_width(x.t)),x.y)
	end
end
--end gamefailed--

--g01--
function g01_init()
	g01_matx=40
	g01_maty=5
	g01_matscl=0.4
	g01_drop=false
	g01_spd=1
	g01_dprscl=0.3 --diaper scale
	g01_dprx=0
	g01_dpry=115-100*g01_dprscl			
	g01_success_ctr=nil
	g01_maxtime=default_maxtime()
end

function g01_update()
	if g01_success_ctr!=nil then
		if ctr-g01_success_ctr>60 then
			change_scene(scn.gamesuccess)
		end
		return
	end

	if ctr>g01_maxtime then
		change_scene(scn.gamefailed)
		return
	end

	--matt-diaper collision
	local matw=72*g01_matscl
	if g01_maty
			>=116-g01_matscl*100 then
		local dprw=100*g01_dprscl
		local matdprdist=abs(
			(g01_matx+matw/2)
			-(g01_dprx+dprw/2))
		if matdprdist<0.35*dprw then
			sfx(10,3)
			g01_success_ctr=ctr
		else
			g01_drop=false
			g01_matx=40
			g01_maty=5
			sfx(0,3)
		end
		return
	end

	--matt
	if g01_drop then
		g01_maty+=2
	else
		if btn(0) then
			--move matt left
			g01_matx=max(g01_matx-1.6,1)
		end
		if btn(1) then
		 --move matt right
			g01_matx=min(g01_matx+1.6,
				128-matw)
		end
		if btndn[3] then
			--drop matt
			g01_drop=true
			sfx(11,3)
		end
	end

	--diaper	
	local half=
		(120-100*g01_dprscl)/2
	g01_dprx=4+half
		+flr(half*sin(
			g01_spd*ctr/120))
end

function g01_draw()
	cls(9)

	art_diaper(g01_dprx,
		g01_dpry,g01_dprscl)

	art_mattchamp(
		flr(g01_matx),
		flr(g01_maty),
		g01_matscl)

	draw_footer(
		"put matt in his diaper!",
		"use: ⬅️➡️⬇️",
		g01_maxtime,
		g01_success_ctr)
end
--end g01--

--g02--
function g02_init()
	g02_flap=0
	g02_flapcd=0 --cooldown
	g02_success_ctr=nil
	g02_y=70
	g02_vy=0
	g02_maxtime=default_maxtime()
end

function g02_update()
	local grav=0.115
	local impulse=1.4
	if(difficulty==1)impulse=1.35
	if(difficulty==2)impulse=1.3
	
	if g02_success_ctr==nil then
		if g02_y<=-5 then
			sfx(10,3)
			g02_success_ctr=ctr
		end
	else
		if ctr-g02_success_ctr>60 then
			change_scene(scn.gamesuccess)
		end
		return
	end

	if ctr>g02_maxtime then
		change_scene(scn.gamefailed)
		return
	end

	if(g02_flapcd>0)g02_flapcd-=1
	g02_y+=g02_vy
	g02_vy+=grav
	if(g02_y>=70)g02_vy,g02_y=0,70
	if btndn[4] then
		if g02_flap==2
				and g02_flapcd>0 then
			g02_vy-=impulse
			g02_y-=1
			sfx(12,3)
		end
		g02_flap=1
		g02_flapcd=30
	elseif btndn[5] then
		g02_flap=2
		g02_flapcd=30
	elseif g02_flapcd==0 then
		g02_flap=0
	end
end

function g02_draw()
	cls(0)

	--sky
	rectfill(0,0,127,22,1)
	recthalftone(0,23,127,44,1,2)
	rectfill(0,45,127,66,2)
	recthalftone(0,67,127,88,2,14)
	rectfill(0,89,127,113,14)
		
	local px=50
	local py=g02_y
	if g02_flap==0 then
		art_parry_sitting(px+5,py+9,0.3)
	elseif g02_flap==1 then
		art_parry_flap1(px,py,0.5)
	elseif g02_flap==2 then
		art_parry_flap2(px,py,0.5)
	end
	art_barbell(px,py)
	art_parry_talons(px+5,py+10,0.3)

	local maxtime=default_maxtime()

	draw_footer(
		"lift the weights!",
		"use: ❎🅾️",
		g02_maxtime,
		g02_success_ctr)
end
--end g02--

--g03--
function g03_init()
	g03_success_ctr=nil
	g03_maxtime=1.75*default_maxtime()
	g03_spotx=64
	g03_spoty=60
	g03_spotr=25
	if(difficulty==1)g03_spotr=22
	if(difficulty==2)g03_spotr=20
	--put parry outside spotlight
	repeat
		g03_px=flr(rnd(128))
		g03_py=flr(rnd(114))
	until g03_dist()>1.1
end

--<1 = hit
function g03_dist()
	local centx=g03_px+5
	local centy=g03_py+8
	return dist(g03_spotx,
		g03_spoty,centx,centy)
		/g03_spotr
end

function g03_update()
	--parry-spotlight collision
	if g03_success_ctr==nil then
		if g03_dist()<0.5 then
			g03_success_ctr=ctr
			sfx(10,3)
		end
	else
		if ctr-g03_success_ctr>60 then
			change_scene(scn.gamesuccess)
		end
		return
	end

	if ctr>g03_maxtime then
		change_scene(scn.gamefailed)
		return
	end

	--move spotlight vert
	if btn(btn_u) and
			g03_spoty>0 then
		g03_spoty-=1
	elseif btn(btn_d) and
			g03_spoty<112 then
		g03_spoty+=1
	end
	
	--move spotlight horiz
	if btn(btn_l) and
			g03_spotx>0 then
		g03_spotx-=1
	elseif btn(btn_r) and
			g03_spotx<128 then
		g03_spotx+=1
	end
end

function g03_draw()
	cls(7)
	if g03_success_ctr==nil then
		art_parry_sitting(
			g03_px,g03_py,0.25)
	else
		art_parry_flap1(g03_px-5,
			g03_py-9,0.45)
	end
	art_parry_talons(
		g03_px,g03_py,0.25)
	local bb_l=g03_spotx-g03_spotr
	local bb_r=g03_spotx+g03_spotr
	local bb_t=g03_spoty-g03_spotr
	local bb_b=g03_spoty+g03_spotr
	if(bb_l>0)rectfill(0,0,bb_l-1,127,0)
	rectfill(bb_r+1,0,127,127,0)
	if(bb_t>0)rectfill(0,0,127,bb_t-1,0)
	rectfill(0,bb_b+1,127,127,0)		
	for y=bb_t,bb_b,1 do
		for x=bb_l,bb_r,1 do
			if dist(x,y,g03_spotx,
					g03_spoty)>g03_spotr then
				pset(x,y,0)
			else
				break
			end
		end
		for x=bb_r,bb_l,-1 do
			if dist(x,y,g03_spotx,
					g03_spoty)>g03_spotr then
				pset(x,y,0)
			else
				break
			end
		end
	end

	draw_footer(
		"find parry!",
		"use: ⬅️➡️⬆️⬇️",
		g03_maxtime,
		g03_success_ctr)
end
--end g03--

--g04--
function g04_init()
	g04_success_ctr=nil
	g04_maxtime=2.5*default_maxtime()
	g04_trees={} --{x,y}
	g04_carrots={} --{x,y}
	g04_px=64
	g04_py=64
	g04_dir=false --false=left,true=right
	--trees
	for i=1,flr(difficulty*2.5) do
		local forestpt={}
		repeat
			forestpt=g04_rnd()
		until dist(forestpt.x,forestpt.y,64,64)>30
		for j=1,10 do
			local treex=forestpt.x+flr(rnd(20))-10
			local treey=forestpt.y+2*j-4
			add(g04_trees,{x=treex,y=treey})
		end
	end
	--carrots
	for i=1,(difficulty+3)*3 do
		local ok=true
		local pt={}
		repeat
			ok=true
			pt=g04_rnd()
			for _,t in pairs(g04_trees) do
				if dist(t.x,t.y,pt.x,pt.y)<16 or
						dist(64,64,pt.x,pt.y)<10 then
					ok=false
				end
			end
		until ok
		add(g04_carrots,pt)
	end
end

function g04_rnd()
	local cx=4+flr(rnd(124))
	local cy=4+flr(rnd(108))
	return {x=cx,y=cy}
end

function g04_hittest(x,y)
	for _,t in pairs(g04_trees) do
		if dist(t.x,t.y,x,y)<7 then
			return true
		end
	end
	return false
end

function g04_update()
	if g04_success_ctr==nil then
		if ctr>g04_maxtime then
			change_scene(scn.gamefailed)
			return
		end

		if #g04_carrots==0 then
			sfx(10,3)
			g04_success_ctr=ctr
		end

		for i,c in pairs(g04_carrots) do
			if dist(c.x,c.y,g04_px,g04_py)<8 then
				sfx(27,3)
				deli(g04_carrots,i)
				break
			end
		end
		
		local px=g04_px
		local py=g04_py
		local dir=g04_dir
		if btn(btn_l) then 
			px-=1
			dir=false
		elseif btn(btn_r) then
			px+=1
			dir=true
		end
		if(btn(btn_u))py-=1
		if(btn(btn_d))py+=1
		if(px<0)px=128
		if(px>128)px=0
		if(py<0)py=116
		if(py>118)py=0
		if(not g04_hittest(px,py))g04_px,g04_py,g04_dir=px,py,dir
	else
		if ctr-g04_success_ctr>60 then
			change_scene(scn.gamesuccess)
		end
	end
end

function g04_draw()
	pal(clr_lav,clr2+clr_gre,1)
	pal(pal_default,2)
	poke(0x5f5f,0x10)
	poke(0x5f7e,0xFC)
	poke(0x5f7f,0xFF)

	local dance=flr((stat(50)%8)/4)
	local dance2=flr((stat(50)%4)/2)
	recthalftone(0,0,128,128,clr_lav,clr_dblu)
	for _,b in pairs(g04_trees) do
		local n=136+dance
		spr(n,b.x-4,b.y-4)
	end

	for _,c in pairs(g04_carrots) do
		spr(135,c.x-4,c.y-4)
	end

	sspr(24+16*dance2,64,16,16,g04_px-8,g04_py-8,16,16,g04_dir)

	draw_footer(
		"eat the carrots!",
		"use: ⬅️➡️⬆️⬇️",
		g04_maxtime,
		g04_success_ctr)
end
--end g04--

-->8
--utilities

---font1
function init_font1()
	font1={}
	font1.charmap={} --x,y,w,h
	local h=5
	
	local lettersx={0,4,8,12,16,20,24,28,32,35,39,43,46,51,55,59,63,67,71,75,79,83,88,93,97,100,103}
	local lettersy=48
	local letters="abcdefghijklmnopqrstuvwxyz"
	for i=1,#letters do
		local ch=sub(letters,i,i)
		local charmap={}
		charmap.x=lettersx[i]
	 charmap.y=lettersy
		charmap.w=lettersx[i+1]-charmap.x
		charmap.h=h
		font1.charmap[ch]=charmap
	end
	
	local numbersx={0,3,6,9,12,15,18,21,24,27,30,38,46,53,60,67,74,75,77,79,81,83,84,85,89,91}
	local numbersy=53
	local numbers="0123456789⬅️➡️⬆️⬇️❎🅾️., ():!?'"
	for i=1,#numbers do
		local ch=sub(numbers,i,i)
		local charmap={}
		charmap.x=numbersx[i]
		charmap.y=numbersy
		charmap.w=numbersx[i+1]-charmap.x
		charmap.h=h
		font1.charmap[ch]=charmap
	end
end

function print_font1(t,x,y,c)
	if(c!=nil)pal(7,c)
	for i=1,#t do
		local ch=sub(t,i,i)
		local rct=font1.charmap[ch]
		if rct!=nil then
			sspr(rct.x,rct.y,rct.w,rct.h,x,y)
			x+=rct.w+1
		end
	end
	if(c!=nil)pal(7,7)
end

function font1_width(t)
	local x=0
	for i=1,#t do
		local ch=sub(t,i,i)
		local rct=font1.charmap[ch]
		if rct!=nil then
			x+=rct.w+1
		end
	end
	return x
end
---end font1

function draw_dlg(ts,y,bg)
	bg=bg or clr_dpur
	local maxw=0
	for _,t in pairs(ts) do
		maxw=max(font1_width(t),maxw)
	end	
	local x=centerx(maxw+16)
	local w=maxw+15
	local h=15+#ts*6
	rectfill(x+3,y+3,x+w-4,y+h-4,
		bg)
	y+=8
	for _,t in pairs(ts) do
		print_font1(t,x+8,y)
		y+=6
	end
end

function print_wavy(t,x,y,c)
	local clock=-2*3.14159*ctr/400
	for i=1,#t do
		local ch=sub(t,i,i)
		local yoff=2*cos(clock+0.075*i)
		print(ch,x+(i-1)*4,y+yoff,c)
	end
end

function centerx(w)
	return 64-w/2
end

function center_text(t)
	return 64-#t*2
end

function poly_start(x,y,sclx,scly)
	ply={}
	ply.x=x
	ply.y=y
	ply.sclx=sclx
	ply.scly=scly
end

function poly_line(c,pts)
	local prevx=nil
	local prevy=nil
	for _,n in pairs(pts) do
		local px=flr(n/100)
		local py=n%100
		if(prevx!=nil)line(ply.x+prevx*ply.sclx,ply.y+prevy*ply.sclx,ply.x+px*ply.scly,ply.y+py*ply.scly,c)
		prevx=px
		prevy=py
	end
end

function poly(c,pts)
	local px=ply.x
	local py=ply.y
	local sx=ply.sclx
	local sy=ply.scly
	local pts2={}
	for i=1,#pts do
		local x=px+flr(pts[i]/100)*sx
		local y=py+pts[i]%100*sy
		add(pts2,x)
		add(pts2,y)
	end
	render_poly(pts2,c)
end

function polys(ts)
 --space-sep four digit ints
	--line: 9999 cccc xxyy...
	--poly: cccc xxyy...
	--tt: 10:line 20:poly
	--cc: color
	for _,t in pairs(ts) do
		local lst={}
		local isline=false
		for i=1,#t,5 do
			local n=tonum(sub(t,i,i+3))
			if n==9999 then
				isline=true
			else
				add(lst,n)
			end
		end
		local cccc=lst[1]
		deli(lst,1)
		if isline then
			poly_line(cccc,lst)
		else
			poly(cccc,lst)
		end
		lst={}
	end
end

--the following function is by
--scgrn: https://www.lexaloffle.com/bbs/?tid=28312
----
-- draws a filled convex polygon
-- v is an array of vertices
-- {x1, y1, x2, y2} etc
function render_poly(v,col)
 col=col or 5

 -- initialize scan extents
 -- with ludicrous values
 local x1,x2={},{}
 for y=0,127 do
  x1[y],x2[y]=128,-1
 end
 local y1,y2=128,-1

 -- scan convert each pair
 -- of vertices
 for i=1, #v/2 do
  local next=i+1
  if (next>#v/2) next=1

  -- alias verts from array
  local vx1=flr(v[i*2-1])
  local vy1=flr(v[i*2])
  local vx2=flr(v[next*2-1])
  local vy2=flr(v[next*2])

  if vy1>vy2 then
   -- swap verts
   local tempx,tempy=vx1,vy1
   vx1,vy1=vx2,vy2
   vx2,vy2=tempx,tempy
  end 

  -- skip horizontal edges and
  -- offscreen polys
  if vy1~=vy2 and vy1<128 and
   vy2>=0 then

   -- clip edge to screen bounds
   if vy1<0 then
    vx1=(0-vy1)*(vx2-vx1)/(vy2-vy1)+vx1
    vy1=0
   end
   if vy2>127 then
    vx2=(127-vy1)*(vx2-vx1)/(vy2-vy1)+vx1
    vy2=127
   end

   -- iterate horizontal scans
   for y=vy1,vy2 do
    if (y<y1) y1=y
    if (y>y2) y2=y

    -- calculate the x coord for
    -- this y coord using math!
    local x=(y-vy1)*(vx2-vx1)/(vy2-vy1)+vx1

    if (x<x1[y]) x1[y]=x
    if (x>x2[y]) x2[y]=x
   end 
  end
 end

 -- render scans
 for y=y1,y2 do
  local sx1=flr(max(0,x1[y]))
  local sx2=flr(min(127,x2[y]))

  local c=col*16+col
  local ofs1=flr((sx1+1)/2)
  local ofs2=flr((sx2+1)/2)
  memset(0x6000+(y*64)+ofs1,c,ofs2-ofs1)
  pset(sx1,y,c)
  pset(sx2,y,c)
 end 
end

function recthalftone(
		x1,y1,x2,y2,c1,c2)
	rectpattern(x1,y1,x2,y2,
		c1,c2,
		c2,c1)
end

function rectpattern(
		x1,y1,x2,y2,c1a,c1b,c2a,c2b)
	local bytes={
		c1a|(c1b<<4)
		,c2a|(c2b<<4)
	}
	local len=flr((x2-x1+1)/2)
	
	for y=y1,y2 do
		local ptr=0x6000+64*y+flr(x1/2)
		memset(ptr,bytes[y%2+1],len)
		ptr+=64
	end
end

function draw_footer(t1,t2,
		maxtime,success_ctr)
	rectfill(0,114,127,127,bg or 0)
	if success_ctr==nil then
		print_font1(t1,2,116)
		print_font1(t2,2,123)
		art_timer(maxtime)
	end
end

function dist(x1,y1,x2,y2)
	return sqrt(
		(x2-x1)^2+(y2-y1)^2)
end

function parry_dlg(ts)
	art_portrait_parry(-10,10)
	char_dlg(ts,"parry",clr2+clr_lav)
end

function sam_dlg(ts)
	art_portrait_sam(28,20)
	char_dlg(ts,"sam",clr2+clr_red)
end

function buzz_dlg(ts)
	art_portrait_buzz(70,
		20+flr(10*sin(ctr/128)))
	char_dlg(ts,"buzz",
		clr_ora,
		clr_yel,
		clr_bla,
		clr2+clr_whi)
end

function char_dlg(ts,name,
		bg,bg2,fg,border)
	fg=fg or clr_whi
	bg2=bg2 or bg
	local y=81
	rectfill(
		0,y,
		4*#name+7,y+6,
		clr_whi)
	print(name,4,y+1,clr_bla)

	y+=7
	
	--use 2nd palette for bottom
	
	--enable per-line palette
	poke(0x5f5f,0x10)
	--set up 2nd palette
	pal({
		[0]=bg,bg2,fg,border or 0
	},2)
	--apply 2nd palette to bottom
	for i=0x5f70+y/8,0x5f7e do
		poke(i,0xff)
	end
	
	recthalftone(
		0,y,
		127,120,
		--2nd palette
		0,
		1)
	y+=3
	for _,t in pairs(ts) do
		if border!=nil then
			for i=-1,1 do
				for j=-1,1 do
					print_font1(t,4+i,y+j,
						--2nd palette
						border and 3)
				end
			end
		end
		print_font1(t,4,y,
			--2nd palette
			2)
		y+=7
	end

	rectfill(
		0,120,
		127,127,
		clr_bla)
	print_font1("❎ continue",4,122)
end

function sproutline(n,c,x,y)
  for i=1,15 do
    pal(i,c)
  end
  for i=-1,1 do
  	for j=-1,1 do
  		spr(n,x+i,y+j)
  	end
  end
  pal()
  spr(n,x,y)
end

function transition1(pct)
	--per-line palette
	poke(0x5f5f,0x10)
	if pct<0.5 then
		pal(pal_dark,2)
		pct*=2
	elseif pct<0.99 then
		pal(pal_dark,1)
		pal(pal_black,2)
		pct=pct*2-1
	else
		pal()
		cls(0)
	end

	local ysplit=flr(64*pct)
	for blk=0,15 do
		local byte=0
		for bit=7,0,-1 do
			byte=byte<<1
			local y=blk*8+bit
			if(y<=ysplit)byte=byte|1
			if(y>=128-ysplit)byte=byte|1
		end
		poke(0x5f70+blk,byte)
	end
end

__gfx__
0000000011111111000bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333333333
000000001111111100075400000bb000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333333333
00700700111111110006740000075400000000000000000000000000000000000000000000000000000000000000000000000000000000003365653333333333
000770001111111100caac0000067400000000000000000000000000000000000000000000000000000000000000000000000000000000003356565333353533
00077000111111110ccaacc00ccaacc0000000000000000000000000000000000000000000000000000000000000000000000000000000003365655333335333
00700700111111110cca9cc0cccaaccc000000000000000000000000000000000000000000000000000000000000000000000000000000003356565333353533
00000000111111110c0990c00c0990c0000000000000000000000000000000000000000000000000000000000000000000000000000000003335555333333333
00000000111111110040400000040400000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333333333
111566111111111115665111333333333333333333333333333113331111111133b3343333333b33338333333333383333336533333333333333653333336533
11663361166661116633661133333333333333333a3333333333113311cc11113bbb33b333a3bbb3388e333a33338e8333337533333333333333753333337533
163333366333365633333361333a333333333a333333333333311333cc11cc113bbb3bbb3333bbb3e8e883333338e88e33336533337777333333653333336533
5633a33333333363333e3365333333333333333333331131311313331111111133433bbb333334338e88e333333e88e833337533117777513333753333337533
6333333333a3333333a3333633333833333333333331311313113333111111113b333343333b3333366636366363666333336533137777537676533367676533
63333333333333a33333333633333333333333333331133333333333c11cc11cbbb33b3333bbb333367636366363676333337533317777535555753355555333
163333333333333333333365333333333a33333333113333333333a31cc11c11bbb3bbb333bbb333360656676665606333336533333555533333653333333333
16333333a33333333a3333613333333333333333333113333e333333111111113433bbb333343333376656666765667333337533333333333333753333333333
116333333833a3333333361133333333333333333333333333333611333133333333333311111111360757066065606333333333333133333333653333533333
1163333333333333333365113333a33333333333333a3333333361113333133a33333b33cc111111366656666665766333333333333313333333753335553633
11633a33333333a333a336113333333333e333333333333331111116333113333333bbb311cc11cc360656076065606333333333337777333333653355056563
163333333a3333333333336133333333333333331133113111111611333133333b33bbb311111111366656666665676333333333337777533333753305566666
6333333333333333a333333633333333333a333313113113a33311113a331333bbb3343311111111360756766665607367673333337777537676567655676656
16633333333a3333333333363333333333333333311333333333331133331133bbb333331cc11cc1376656644675666355557533337777535555355560777505
11563333333333833333a3613333333333333333333333333333a3613331313334333a33111cc11c366656644665766333336533333555533333333307767750
116333a3333333333333365133333333333333833333333333333651333113333333333311111111366756644665666333337533333113333333333376777670
1163333333333333a333336133333611116333333333333333333333333a13331111111133333333336666333333333333333333333365333333333333399333
163333333a333333333333653a3361111116333333333a3333333333333311331661111133333333363335333333333333333333333375333333333333933933
633333a333333a333333a3363336111111116333333333333333a33333331133633661663333a333363aaaaa3377773333333333333365333333333333933933
63a33e3333333333333333363336511665163a333666333333333333333311633333363333333333363959593377775333333333333375333333333339999993
633333333333333333333336333366633663333365116333333336633a3611133333333333333333363959593377775376767676333337673333367639aaaa93
1633333336333333333333613333333333333333611163333333615663311116333a333333633333363959593377775355555555333335553333755539aaaa93
16363366656336636633361133a3333e3333333311156333a3365111163111113333333366166336363959593335555333333333333333333333653339aaaa93
116566111116651611666111333333333a3333331116333333336111116116113333333311111661363aaaaa3333333333333333333333333333753339999993
00777777000000000000000000000000000000000000000000000002424000000033330000333300003333000044440000444400008888000088880000888800
077777777777000000000000000000000000000000000000000000242400000003bbbb3003bb333003bb3330049944400499444008ee888008ee888008ee8880
75077000077770000000000000000000000000000000000000000777777000003bbbbbb33bbb33b33bbb333349994444499944448eee88888eee888888ee8888
00077000007770000000000000000000000000000000000000007666666700003bbbbbb33bbb3bb33bbb333349994444499944448eee88888eee8888888e8888
000770000077700000000000000000000000000000000000000766666666d0003bbbbbb33bbbbbb33bbbbbb349999444499944448eee88888888888888888888
0007700000777000000000000000000000000000000000000076666666666d003bbbbbb33bbbbbb33bbbbbb349999944499944448ee888888888888888888888
0007777777770000000000000000000000000000000000000076666666666d7003bbbb3003bbbb3003bbbb300499994004994440088888800888888008888880
0007777777700000000000000000000e00000000000000000076666666666d700033330000333300003333000044440000444400008888000088880000888800
00077700000000000000000000eeeee200000000000000000076666666666d600000000000000000000000000000000000000000000000000000000000000000
0007750077007700770070700e2e0e0000000000000000000076666666666dd00000000000000000000000000000000000000000000000000000000000000000
005770070070707070707070000e0e0000000000000000000076666666666d000000000000000000000000000000000000000000000000000000000000000000
007770077770770077007070000e0e000000000000000000000766666666d0000000000000000000000000000000000000000000000000000000000000000000
057770070070707070705770000e0e0000000000000000000000d666666d00000000000000000000000000000000000000000000000000000000000000000000
077770770770707070700070000e0eee000000000000000000000dddddd000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007007000eeeee2000000000000000000000024240000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000077500ee20000000000000000000000000002424000000000000000000000000000000000000000000000000000000000000000000000
07707770077077777770777707777007777777770070707707770070770777007707770077777777007700077000770077077770000000000000000000000000
70077007700770077000700770007007070007070707007070777077007700770077007700007007007700077000707077070070000000000000000000000000
77077770700070077770770070777777070007077007007070770777007770770077707777007007007070707070707700770700000000000000000000000000
70777007700070077000700070077007070707070707007000770077007707070707070000707007007070707070770700077000000000000000000000000000
70077770077777707777700007707007777077070077777000770070770700007077007777000700770007000707070077707770000000000000000000000000
7770707707707077770777777777770ee2eee00eee2ee00ee2ee00ee2ee00eeeee00eeeee0000000770070770070000000000000000000000000000000000000
707770007007707700700007707707ee22eeeeeeee22eeee222eeeee2eeeee2e2eeee222ee000007007777007070000000000000000000000000000000000000
707070070070777770770007777077e222222ee222222ee22222ee22222eeee2eeeee2e2ee000007007070070700000000000000000000000000000000000000
707070700007007007707070707007ee22eeeeeeee22eeeee2eeeee222eeee2e2eeee222ee007007007700000000000000000000000000000000000000000000
0777777777700077700707007777700ee2eee00eee2ee00ee2ee00ee2ee00eeeee00eeeee0770000770070070000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000003b0b00bbb330000bbb300000000000000000000000000000000000000000000000000
00760760760000000000000000000000000000000000000000000000000b3bb00b3bb33000b3bbb0000000000000000000000000000000000000000000000000
006706706700000000000000000000077700000000000700000000000009bb0003b3bb0000bb3bb0000000000000000000000000000000000000000000000000
00760760760000000000000000000007ff7770000000777000770000004993b0b3b3b3300b3b3b30000000000000000000000000000000000000000000000000
0067067067000000000000000000007ff7fff00000007ff0007f77000099900000b343b003bb3b30000000000000000000000000000000000000000000000000
0566066066000000000000000000007f7ff00000000007ff07fff700009900000004400000044000000000000000000000000000000000000000000000000000
0566566566577777777777770000007f7ff000000000077f07f00000099000000004500000045000000000000000000000000000000000000000000000000000
656656656656666666666666000000777f0000000000007f7f000000094000000004440000044400000000000000000000000000000000000000000000000000
55665665665666666666666600000777770000000000007777000000000000000000000000000000000000000000000000000000000000000000000000000000
05665665665555555555555500007757770000000000077777000000006600000000000000000000000000000000000000000000000000000000000000000000
056606606600000000000000000e7777777000000000777577700000065665000000000000000000000000000000000000000000000000000000000000000000
00650650650000000000000000057777777000000007e77777700000667666600000000000000000000000000000000000000000000000000000000000000000
00560560560000000000000000015577770000000007577777700000666656660000000000000000000000000000000000000000000000000000000000000000
00650650650000000000000000000777700000000005155777000000066666610000000000000000000000000000000000000000000000000000000000000000
00560560560000000000000000000000000000000000077770000000065666500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000006655000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000010000000000000000000000000001010101000000000000000000000000010101000000000000000000000000010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2929292929292929292929292929292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1710381112171710113811113811121700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29203a2133381134212824142436322900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17203d3c3b0f0f0f0f0f0f192122171700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292023280f14181819230f143632292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
172021210f19181815253f252617171700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
293039350f15252516240f133338122900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
171717200f3f0f0f0f0f0f0f3f13221700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292929303137352f2f2f2f2f0f28222900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
171717171717200f0f0f0f0f0f36321700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292929292929200f363135210f22292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
171710113811343f221720193f22171700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929201a1b14190f222930313932292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1717202a2b3f0f0f221717171717171700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929303931393931322929292929292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1717171717171717171717171717171700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
050200002701027030270302703021030210302101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
491e00001f0501c050180001f0501c050000001f050000001a0501a0501a0501a050000000000000000000001f0501c050000001f0501c050000001f05000000210502105021050210501f0501f0500000000000
010a00001f7551c755287051f7551c755287051f7551c755287050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
490f00201a633000033b603000031a62300003000030000321633000033b62300003216230000300003000031a633000033b603000031a623000030000300003216333b6233b6233b62321623000030000300003
491e00001f0501c050186001f0501c050000001f050000001a0501a0501a0501c050180502400000000000001f0501c050000001f0501c050000002305024603240502405024050240502b0002b0000000000000
011e0020197321c7322073200702197321c7322073200702197321c7322073200702197321c73220732007021b7321e73221732007021b7321e73221732007021b7321e73221732007021b7321e7322173200702
011e0000195501955019550005001b5501c5501e550205502355021550005001e550205502055020550005002355021550005001e55020550205502055000000205501c550000001b55019550195501955000000
010f00201962300000000000000020633000000000000000000000000000000000000000000000000000000019623000001962300000000000000000000000002b63300000000000000000000000000000000000
011e00001c7322073223732000001c7322073223732000001c7322073225732000001c7322073225732000001b7322073225732000001b73220732257320000020732237321b732000001c7321c7321c73200000
011e00001955015500195501e500195501955015550000001e5500000020550205001c5501c50000000000001e5501c500205501e5501b5001b5501c5001c5001c5501050010500105000d5500d5500d55000000
010400002475024750247500000029750297502975000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000025350243502435023350223501f3501d35019350143500f35009350013500135000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000500001d6501e630166201d6001e6001e6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011100001a7401e74021740157001a7401e74021740007001a7401e74021740007001a7401e740217400070013740177401a7400070013740177401a7400070013740177401a7400070013740177401a74000000
0111000015720197201c7200000015720197201c7200000015720197201c7200000015720197201c7200000013720177201a7200070013720177201a7200070013720177201a7200070013720177201a72000700
011100000b643000030e6030e6033d6330000300003000030b643000030b6030b6433d633000030b643000030b643000030b603000033d6330000300003000030b643000030b643000033d6330b6430000300003
011100001a5701e5001e5001e5702150021500215701e50023570000000000000000000000000000000000001e57021570235702157023570215701e570000001c57000000000000000000000000000000000000
001100001c5701a5701c5001c5701a57021500195001c50025570000000000000000235702157000000000001a5701a5701a5701a570000000000000000000000000000000000000000000000000000000000000
001100001c5701c57000000000001a5701957000000000001c5701c5701c5701c5700000000000000000000028570000002857000000265702557000000000002857028570285702857000000000000000000000
001100001c570000001a500000001a570000001957000000175700000000000000001957000000000002350017570000000000000000155700000000000000000000000000000000000000000000000000000000
a92000002112624126281262b1262110624126281262b1062112624126281262b1262110624126281262b1062112624126281262b1262110624126281262b1062112624126281262b1262110624126281262b106
491000201764300603006030060330633006030060300603176430060300603176433063300603176430060300603006031764300603306330060300603006030060300603176430060330633176431764300000
012000001e0521c0521e0521f0521a0521f0521a052000021e0521c0521705200002000020000200002000021e0521c0521e0521f0521a0521f0521a052000021e0521e052170520000200002000020000200002
a9200000211261a1261812618126211061a1261812618106211261a1261812618126211061a12618126181061f126231261a126231261f106231261a126231061f126231261a126231261f106231261a12623106
012000001c0521a0521c0521a0521c0521e05217052000021e0521e052170521a0021c0021e00217002000001c0521a0521c0521a0521c0521e05217052000021e0521e052170521a00200000000000000000000
012000001a0521c0521c0021705217052170521705217002170521800218052000001a0521c0001c052000001a0521c0521c00217052170521705217052170020000000000000000000000000000000000000000
01100020210522100221052000001f0521e0521c052000001f0521e0521c0521c0021c052000000000000000210522100221052000001f0521e0521c052000001f0521e0521c0521c0021a052000000000000000
5904000018344183401d3401d33500304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304
490300002d1502d1502d1502b1502815126151211511d1511a15116150131501115011150101500f1500d1500c1500a1500815006100041000110000100001000010000100001000010000100001000010000100
000a000028050280002800028050280002d05015000150001500000000210000000021000200001a0001800000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 01034344
02 04034344
04 41424344
01 05060744
00 05060744
02 08090744
01 0d0f1044
00 0e0f1144
00 0d0f1244
02 0e0f1344
01 14151644
00 17151844
00 14151a44
02 17151944

