---####____CHROMIUMAUDIO____####---

-- starting    - early May, 2016
-- last update - 05.14.2016

--[[ ToDo shit list:
hooks

]]




--##### INIT CHROMIUMAUDIO #####--
local Me = LocalPlayer()
local W = ScrW()
local H = ScrH()


--##### INIT CHROMIUM AUDIO ENGINE #####--
ChromiumAudio = ChromiumAudio or {}

ChromiumAudio.Engine = ChromiumAudio.Engine or {}
ChromiumAudio.Engine.Version = "Chromium Audio v0.605"
ChromiumAudio.Engine.Time = 10000
ChromiumAudio.Engine.Song = NULL
ChromiumAudio.Engine.Pitch = 1
ChromiumAudio.Engine.Volume = 1
ChromiumAudio.Engine.VolumeBAK = 1
ChromiumAudio.Engine.CT = 0
ChromiumAudio.Engine.ET = 0
ChromiumAudio.Engine.SongCanPos = false
ChromiumAudio.Engine.CleanUp = false
ChromiumAudio.Engine.Repeat = false
ChromiumAudio.Engine.SVDamp = 0
ChromiumAudio.Engine.TimeStr = ""
ChromiumAudio.Engine.StatusStr = ""
ChromiumAudio.Engine.FFT = {}
--ChromiumAudio.Engine.StandardURL = "http://streaming.shoutcast.com/HappyHardcorecom"
--ChromiumAudio.StandardURL = "http://cdndl.zaycev.net/455175/2485191/serbian_soldiers_-_remove_kebab_(zaycev.net).mp3"
ChromiumAudio.Engine.StandardURL = "http://cdndl.zaycev.net/365416/3760603/summer_of_haze_-_naked_bithes_angels_(zaycev.net).mp3"
ChromiumAudio.Engine.DisableCA = function()
	chat.AddText(Color(220,0,255),ChromiumAudio.Engine.Version..": Disabled!")
	hook.Remove("Think","ChrTime")
	hook.Remove("Think","ChrTimeSet")
	hook.Remove("Think","CAMWGMOD")
	hook.Remove("Think","CASD")
	hook.Remove("HUDPaint","CAP")
	hook.Remove("PlayerStartVoice","SVDampOn")
	hook.Remove("PlayerEndVoice","SVDampOff")
	hook.Remove("PostCleanupMap","CAPostCUM")
	hook.Remove("HUDPaint","CATime2Sex")
	concommand.Remove("ChromiumAudio")
	concommand.Remove("ChromiumAudioDisable")
	ChromiumAudio.Derma.BTN[7]:Remove()
	ChromiumAudio.Derma.Frame:Remove()
	if IsValid(ChromiumAudio.Engine.Song) then
		ChromiumAudio.Engine.Song:Stop()
		ChromiumAudio.Engine.Song = NULL
	end
	DSP(1)
end

--##### INIT CHROMIUM AUDIO DERMA #####--
ChromiumAudio.Derma = ChromiumAudio.Derma or {}
ChromiumAudio.Derma.Frame = vgui.Create("DFrame")
ChromiumAudio.Derma.BTN = {}
ChromiumAudio.Derma.BTNC = {}
for i = 1,6 do
	ChromiumAudio.Derma.BTN[i] = vgui.Create("DButton",ChromiumAudio.Derma.Frame)
	ChromiumAudio.Derma.BTNC[i] = Color(0,0,0,150)
end
ChromiumAudio.Derma.BTN[7] = vgui.Create("DButton")
ChromiumAudio.Derma.BTNC[7] = Color(0,0,0,150)
ChromiumAudio.Derma.URLForm = vgui.Create("DTextEntry",ChromiumAudio.Derma.Frame)
ChromiumAudio.Derma.ProgressBar = vgui.Create("DProgress",ChromiumAudio.Derma.Frame)
ChromiumAudio.Derma.TimeBar = vgui.Create("DLabel",ChromiumAudio.Derma.Frame)
ChromiumAudio.Derma.StatusBar = vgui.Create("DLabel",ChromiumAudio.Derma.Frame)
ChromiumAudio.Derma.SystemBar = vgui.Create("DLabel",ChromiumAudio.Derma.Frame)
ChromiumAudio.Derma.PitchSlider = vgui.Create("DNumSlider",ChromiumAudio.Derma.Frame)
ChromiumAudio.Derma.VolumeSlider = vgui.Create("DNumSlider",ChromiumAudio.Derma.Frame)
ChromiumAudio.Derma.FFTCB = vgui.Create("DCheckBoxLabel",ChromiumAudio.Derma.Frame)
ChromiumAudio.Derma.SDCB = vgui.Create("DCheckBoxLabel",ChromiumAudio.Derma.Frame)
ChromiumAudio.Derma.MGCB = vgui.Create("DCheckBoxLabel",ChromiumAudio.Derma.Frame)
ChromiumAudio.Derma.SVDCB = vgui.Create("DCheckBoxLabel",ChromiumAudio.Derma.Frame)
ChromiumAudio.Derma.RSCB = vgui.Create("DCheckBoxLabel",ChromiumAudio.Derma.Frame)


--##### INIT CHROMIUM AUDIO STRINGS #####--
ChromiumAudio.Strings = ChromiumAudio.Strings or {}

ChromiumAudio.Strings.Notice = ChromiumAudio.Strings.Notice or {}
ChromiumAudio.Strings.Notice.Play = "Song is Playing."
ChromiumAudio.Strings.Notice.PlayStream = "Stream is Playing."
ChromiumAudio.Strings.Notice.Pause = "Song is Paused."
ChromiumAudio.Strings.Notice.Stop = "Song is Stopped."
ChromiumAudio.Strings.Notice.NoSong = "No Song is Loaded."
ChromiumAudio.Strings.Notice.Buffering = "Buffering..."

ChromiumAudio.Strings.Status = ChromiumAudio.Strings.Status or {}
ChromiumAudio.Strings.Status.Playing = GMOD_CHANNEL_PLAYING
ChromiumAudio.Strings.Status.Paused = GMOD_CHANNEL_PAUSED
ChromiumAudio.Strings.Status.Stopped = GMOD_CHANNEL_STOPPED
ChromiumAudio.Strings.Status.Buffering = GMOD_CHANNEL_STALLED


--##### INIT FUNCTIONS #####--


--## INIT FFT ##--
function SetFFT(tbl,chan,size)
	if IsValid(chan) then
		chan:FFT(tbl,size)
	else return end
end

function ShowFFT()
	local mult = H/2
	for i = 1, #ChromiumAudio.Engine.FFT do
		
		local kek = {}
		kek[i] = math.Clamp(ChromiumAudio.Engine.FFT[i]*mult*2,0,mult)
		surface.SetDrawColor(HSVToColor(i%360,1,1))
		surface.DrawRect(-4+i*4,H-kek[i],4,kek[i]*2)
	end
end

--## INIT SONG ##--
function CreateSong(url)
	sound.PlayURL(url,"noblock",function( st )
		if IsValid(st) then
			ChromiumAudio.Engine.Song = st
			st:SetPlaybackRate(ChromiumAudio.Engine.Pitch)
			st:SetVolume(ChromiumAudio.Engine.Volume)
			st:Play()
		end
	end)
end


--## INIT SHIT FUNCS ##--

function DSP(num)
	Me:SetDSP(num,false)
end

function MWGMOD()
	if system.HasFocus() then
		ChromiumAudio.Engine.Volume = ChromiumAudio.Engine.VolumeBAK
	else
		if ChromiumAudio.Engine.Volume != 0 then
			ChromiumAudio.Engine.VolumeBAK = ChromiumAudio.Engine.Volume
		end
		ChromiumAudio.Engine.Volume = 0
	end
end

function InitDerma(Derma,Text,Posx,Posy,Sizex,Sizey,STC)
	Derma:SetText(Text)
	Derma:SetPos(Posx,Posy)
	Derma:SetSize(Sizex,Sizey)
	if STC then
		Derma:SizeToContents()
	end
end

function PlayerStartVoice(ply)
	--if ply:IsVoiceAudible() then
		ChromiumAudio.Engine.SVDamp = 1
		print(1)
		ChromiumAudio.Engine.VolumeBAK = ChromiumAudio.Engine.Volume
		timer.Create("CAPSV1",0.1,10,function()
			ChromiumAudio.Engine.Volume = math.Clamp(ChromiumAudio.Engine.Volume-0.1,0.1,1) end)
	--end
end

function PlayerEndVoice(ply)
	if ply:IsVoiceAudible() then
		ChromiumAudio.Engine.SVDamp = 0
		print(0)
		timer.Create("CAPSV0",0.1,10,function()
			ChromiumAudio.Engine.Volume = math.Clamp(ChromiumAudio.Engine.Volume+0.1,0.1,ChromiumAudio.Engine.VolumeBAK) end)
	end
end


function PostCleanupMap()
	if ChromiumAudio.Engine.CleanUp then
		timer.Create("CACUP",0.2,1,function()
			chat.AddText(Color(255,0,0),ChromiumAudio.Engine.Version..": The Map Was Cleaned Up! Re-Playing...")
			ChromiumAudio.Engine.Song:Play()
			ChromiumAudio.Engine.CleanUp = false
		end)
	end
end

hook.Add("PostCleanupMap","CAPostCUM",PostCleanupMap)


surface.CreateFont("CAFont",{font="coolvetica",size=24,weight=400,blursize=0.5,scanlines=0,antialias=true})


----#### INIT CODE ####----

chat.AddText(Color(220,0,255),ChromiumAudio.Engine.Version..": Enabled!")


--## INIT FRAME ##--
ChromiumAudio.Derma.Frame:SetSize(400,400)
ChromiumAudio.Derma.Frame:SetPos(W/2-ChromiumAudio.Derma.Frame:GetWide()/2,H/2-ChromiumAudio.Derma.Frame:GetTall()/2)
ChromiumAudio.Derma.Frame:SetTitle(ChromiumAudio.Engine.Version)
ChromiumAudio.Derma.Frame:SetVisible(true)
ChromiumAudio.Derma.Frame:Center()
ChromiumAudio.Derma.Frame.Paint = function(self,w,h)
	draw.RoundedBox(0,0,0,w,h,Color(0,0,0,200))
	local TexturedQuadStructure = {texture=surface.GetTextureID('models/props_lab/warp_sheet'),color=Color(255,0,255,255),x=0,y=0,w=400,h=400}
	--local TexturedQuadStructure = {texture=surface.GetTextureID('models/props_combine/cit_splode1'),color=Color(255,255,255,255),x=-200,y=-200,w=800,h=800}
	draw.TexturedQuad( TexturedQuadStructure )
	

end
ChromiumAudio.Derma.Frame:SetDeleteOnClose( false )
ChromiumAudio.Derma.Frame:ShowCloseButton( false )
ChromiumAudio.Derma.Frame:SetScreenLock( true )
ChromiumAudio.Derma.Frame:MakePopup()



--## INIT URL FORM ##--
InitDerma(ChromiumAudio.Derma.URLForm,ChromiumAudio.Engine.StandardURL,0,40,ChromiumAudio.Derma.Frame:GetWide()/1.1,20,false)
ChromiumAudio.Derma.URLForm:CenterHorizontal()
ChromiumAudio.Derma.URLForm:SetEditable(true)

ChromiumAudio.Derma.URLForm.OnTextChanged = function()
	ChromiumAudio.Derma.URLForm:SetTextColor(Color(0,0,0,255))
end

ChromiumAudio.Derma.URLForm.OnEnter = function()
	ChromiumAudio.Derma.URLForm:SetTextColor(Color(220,0,255,255))
	if IsValid(ChromiumAudio.Engine.Song) then ChromiumAudio.Engine.Song:Stop() end
	CreateSong(ChromiumAudio.Derma.URLForm:GetValue())
end

--## INIT SYSTEM BAR ##--
InitDerma(ChromiumAudio.Derma.SystemBar,"LOADING",40,320,0,0,true)
ChromiumAudio.Derma.SystemBar:SetFont("CAFont")
ChromiumAudio.Derma.SystemBar:SetTextColor(Color(220,0,255,255))
function ChromiumAudio.Derma.SystemBar:Think()
	self:SetText( os.date("[%X] - [%d/%m/%Y]") )
	self:SizeToContents()
end


--## INIT PROGRESS BAR ##--
ChromiumAudio.Derma.ProgressBar:CenterHorizontal()
ChromiumAudio.Derma.ProgressBar:SetPos(0,360)
ChromiumAudio.Derma.ProgressBar:SetSize(400,40)



----#### INIT CHECK BOXES ####----


--## INIT AUTO-REPEAT CHECK BOX ##--
InitDerma(ChromiumAudio.Derma.RSCB,"Auto-Repeat",220,180,0,0,true)
ChromiumAudio.Derma.RSCB:SetValue(0)
ChromiumAudio.Derma.RSCB.OnChange = function(self,bool)
	if bool then
		ChromiumAudio.Engine.Repeat = true
	else
		ChromiumAudio.Engine.Repeat = false
	end
end

--## INIT FFT CHECK BOX ##--
InitDerma(ChromiumAudio.Derma.FFTCB,"FFT",220,200,0,0,true)
ChromiumAudio.Derma.FFTCB:SetValue(0)
local FFTCBE = false
ChromiumAudio.Derma.FFTCB.OnChange = function(self,bool)
	if bool then
		hook.Add("HUDPaint","CAP",ShowFFT)
	else
		hook.Remove("HUDPaint","CAP")
	end
end

--## INIT SONG DAMP CHECK BOX ##--
InitDerma(ChromiumAudio.Derma.SDCB,"Damp Env Sounds",220,220,0,0,true)
ChromiumAudio.Derma.SDCB:SetValue(0)
ChromiumAudio.Derma.SDCB.OnChange = function(self,bool)
	if bool then
		hook.Add("Think","CASD",function() DSP(133) end)
	else
		hook.Remove("Think","CASD")
		DSP(1)
	end
end

--## INIT MINIMIZE GMOD CHECK BOX ##--
InitDerma(ChromiumAudio.Derma.MGCB,"Damp when GMOD is Minimized",220,240,0,0,true)
ChromiumAudio.Derma.MGCB:SetValue(0)
ChromiumAudio.Derma.MGCB.OnChange = function(self,bool)
	if bool then
		hook.Add("HUDPaint","CAMWGMOD",MWGMOD)
	else
		hook.Remove("HUDPaint","CAMWGMOD")
		DSP(1)
	end
end

--## INIT VOICE DAMP CHECK BOX ##--
InitDerma(ChromiumAudio.Derma.SVDCB,"Damp on Voice",220,260,0,0,true)
ChromiumAudio.Derma.SVDCB:SetValue(0)
ChromiumAudio.Derma.SVDCB.OnChange = function(self,bool)
	if bool then
		hook.Add("PlayerStartVoice","SVDampOn",PlayerStartVoice)
		hook.Add("PlayerEndVoice","SVDampOff",PlayerEndVoice)
	else
		hook.Remove("PlayerStartVoice","SVDampOn")
		hook.Remove("PlayerEndVoice","SVDampOff")
	end
end


--## INIT SOUND TIME ##--

ChromiumAudio.Derma.StatusBar:SetPos(40,240)
ChromiumAudio.Derma.StatusBar:SetSize(200,20)
ChromiumAudio.Derma.StatusBar:SetFont("CAFont")

ChromiumAudio.Derma.TimeBar:SetPos(40,280)
ChromiumAudio.Derma.TimeBar:SetSize(200,20)
ChromiumAudio.Derma.TimeBar:SetFont("CAFont")


hook.Add("Think","ChrTime",function()

	if IsValid(ChromiumAudio.Engine.Song) then


		if ChromiumAudio.Engine.Song:GetState() == ChromiumAudio.Strings.Status.Playing then
			SetFFT(ChromiumAudio.Engine.FFT,ChromiumAudio.Engine.Song,FFT_1024)
			
			ChromiumAudio.Engine.CleanUp = true

			ChromiumAudio.Engine.Song:SetPlaybackRate(math.Clamp(ChromiumAudio.Engine.Pitch,0.0001,2))
			ChromiumAudio.Engine.Song:SetVolume(ChromiumAudio.Engine.Volume)

			ChromiumAudio.Engine.Time = ChromiumAudio.Engine.Song:GetLength()
			local CurPos = math.Round(ChromiumAudio.Engine.Song:GetTime()*(1/ChromiumAudio.Engine.Pitch) )
			local EndPos = math.Round(ChromiumAudio.Engine.Song:GetLength()*(1/ChromiumAudio.Engine.Pitch))
			ChromiumAudio.Engine.CT = CurPos
			ChromiumAudio.Engine.ET = EndPos
			ChromiumAudio.Engine.Time = EndPos


			if ChromiumAudio.Engine.Song:IsOnline() and ChromiumAudio.Engine.Song:GetLength() <= 0.1 then
				ChromiumAudio.Engine.TimeStr = "[ ∞ ]"
				ChromiumAudio.Engine.StatusStr = ChromiumAudio.Strings.Notice.PlayStream
				ChromiumAudio.Engine.SongCanPos = false
				ChromiumAudio.Derma.ProgressBar:SetFraction(1)
			else
				ChromiumAudio.Engine.TimeStr = "[ "..string.ToMinutesSeconds( CurPos ).." / "..string.ToMinutesSeconds( EndPos ).." ]"
				ChromiumAudio.Engine.StatusStr = ChromiumAudio.Strings.Notice.Play
				ChromiumAudio.Engine.SongCanPos = true
				ChromiumAudio.Derma.ProgressBar:SetFraction(CurPos/EndPos)
			end

			ChromiumAudio.Derma.TimeBar:SetText(ChromiumAudio.Engine.TimeStr)
			ChromiumAudio.Derma.StatusBar:SetText(ChromiumAudio.Engine.StatusStr)
		end
	
		if ChromiumAudio.Engine.Song:GetState() == ChromiumAudio.Strings.Status.Paused then
			for i=1,#ChromiumAudio.Engine.FFT do
				ChromiumAudio.Engine.FFT[i] = ChromiumAudio.Engine.FFT[i] - 0.01
			end
			
			ChromiumAudio.Engine.CleanUp = false
			
			ChromiumAudio.Derma.TimeBar:SetText(ChromiumAudio.Engine.TimeStr)
			ChromiumAudio.Derma.StatusBar:SetText(ChromiumAudio.Strings.Notice.Pause)
		end

		if ChromiumAudio.Engine.Song:GetState() == ChromiumAudio.Strings.Status.Stopped then
			for i=1,#ChromiumAudio.Engine.FFT do
				ChromiumAudio.Engine.FFT[i] = ChromiumAudio.Engine.FFT[i] - 0.01
			end
			
			ChromiumAudio.Engine.CleanUp = false
			if ChromiumAudio.Engine.Repeat then
				ChromiumAudio.Engine.Song:Play()
			end
			
			ChromiumAudio.Derma.TimeBar:SetText("[ ... ]")
			ChromiumAudio.Derma.StatusBar:SetText(ChromiumAudio.Strings.Notice.Stop)
		end

		if ChromiumAudio.Engine.Song:GetState() == ChromiumAudio.Strings.Status.Buffering then
			for i=1,#ChromiumAudio.Engine.FFT do
				ChromiumAudio.Engine.FFT[i] = ChromiumAudio.Engine.FFT[i] - 0.01
			end
			
			ChromiumAudio.Engine.CleanUp = false
			
			ChromiumAudio.Derma.TimeBar:SetText("[ ... ]")
			ChromiumAudio.Derma.StatusBar:SetText(ChromiumAudio.Strings.Notice.Buffering)
		end
	else
		ChromiumAudio.Derma.TimeBar:SetText("[ ... ]")	
		ChromiumAudio.Engine.CleanUp = false
		ChromiumAudio.Engine.SongCanPos = false
		ChromiumAudio.Derma.StatusBar:SetText(ChromiumAudio.Strings.Notice.NoSong)
		for i=1,#ChromiumAudio.Engine.FFT do
			ChromiumAudio.Engine.FFT[i] = ChromiumAudio.Engine.FFT[i] - 0.01
		end
	end

end)


--## INIT TIME POSING ##--
function ChromiumAudio.Derma.Frame:OnMousePressed( MOUSE_LEFT )
	local x, y = self:LocalCursorPos()
	if ChromiumAudio.Engine.SongCanPos and (y >= self:GetTall()-40) then
		local Time = ((x/self:GetWide()) * ChromiumAudio.Engine.ET) * ChromiumAudio.Engine.Pitch
		ChromiumAudio.Engine.Song:SetTime( Time )
	else return end
end

local function CADermaPosTrue(panel,X,Y)
	if (X >= panel:GetWide() - 400) and (X <= panel:GetWide()) then
		if (Y <= panel:GetTall()) and (Y >= panel:GetTall()-40) then
			return true
		else return false end
	else return false end
end

function ChromiumAudio.Derma.Frame:Think()
	local x, y = self:LocalCursorPos()

	if ChromiumAudio.Engine.SongCanPos and CADermaPosTrue(self,x,y) then
		local String = string.ToMinutesSeconds( (x/self:GetWide()) * ChromiumAudio.Engine.ET )
		ChromiumAudio.Derma.StatusBar:SetText(String)
	end
end


--## INIT VOLUME ##--
InitDerma(ChromiumAudio.Derma.VolumeSlider,"Sound Volume",180,70,200,40,false)
ChromiumAudio.Derma.VolumeSlider:SetMin( 0 )
ChromiumAudio.Derma.VolumeSlider:SetMax( 1 )
ChromiumAudio.Derma.VolumeSlider:SetDecimals( 3 )
ChromiumAudio.Derma.VolumeSlider:SetValue(1)

ChromiumAudio.Derma.VolumeSlider.OnValueChanged = function()
	ChromiumAudio.Engine.Volume = ChromiumAudio.Derma.VolumeSlider:GetValue()
	ChromiumAudio.Engine.VolumeBAK = ChromiumAudio.Derma.VolumeSlider:GetValue()
end



--## INIT PITCH SONG ##--
InitDerma(ChromiumAudio.Derma.PitchSlider,"Sound Pitch",180,110,200,40,false)
ChromiumAudio.Derma.PitchSlider:SetMin(0)
ChromiumAudio.Derma.PitchSlider:SetMax(2)
ChromiumAudio.Derma.PitchSlider:SetDecimals(3)
ChromiumAudio.Derma.PitchSlider:SetValue(1)

ChromiumAudio.Derma.PitchSlider.OnValueChanged = function()
	ChromiumAudio.Engine.Pitch = ChromiumAudio.Derma.PitchSlider:GetValue()
end





---### INIT BUTTONS ###---


--## LOAD BUTTON ##--
InitDerma(ChromiumAudio.Derma.BTN[6],"Load",50,70,100,20,false)

ChromiumAudio.Derma.BTN[6].DoClick = function( btn )
	ChromiumAudio.Derma.URLForm:SetTextColor(Color(220,0,255,255))

	if IsValid(ChromiumAudio.Engine.Song) and (ChromiumAudio.Engine.Song:GetState() ~= ChromiumAudio.Strings.Status.Buffering) then
		ChromiumAudio.Engine.Song:Stop()
		--ChromiumAudio.Song = NULL
	end
	ChromiumAudio.Derma.TimeBar:SetText("[ Buffering... ]")
	ChromiumAudio.Derma.StatusBar:SetText(ChromiumAudio.Strings.Notice.Buffering)
	CreateSong( ChromiumAudio.Derma.URLForm:GetValue() )
	timer.Create("LoadSong",1,1,function()
		if IsValid(ChromiumAudio.Engine.Song) and (ChromiumAudio.Engine.Song:GetState() ~= (ChromiumAudio.Strings.Status.Playing or ChromiumAudio.Strings.Status.Buffering)) then
			ChromiumAudio.Engine.Song:Play()
		end
	end)
end


--## PLAY BUTTON ##--
InitDerma(ChromiumAudio.Derma.BTN[1],"Play",50,100,100,20,false)

ChromiumAudio.Derma.BTN[1].DoClick = function( btn )
	if IsValid(ChromiumAudio.Engine.Song) then
		ChromiumAudio.Engine.Song:Play()
	else return end
end


--## PAUSE BUTTON ##--
InitDerma(ChromiumAudio.Derma.BTN[2],"Pause",50,130,100,20,false)

ChromiumAudio.Derma.BTN[2].DoClick = function( btn )
	if IsValid(ChromiumAudio.Engine.Song) then
		ChromiumAudio.Engine.Song:Pause()
	else return end
end


--## STOP BUTTON ##--
InitDerma(ChromiumAudio.Derma.BTN[3],"Stop",50,160,100,20,false)

ChromiumAudio.Derma.BTN[3].DoClick = function( btn )
	if IsValid(ChromiumAudio.Engine.Song) then
		ChromiumAudio.Engine.Song:Stop()
		--ChromiumAudio.Song = NULL
		ChromiumAudio.Derma.TimeBar:SetText("[...]")
		ChromiumAudio.Derma.StatusBar:SetText(ChromiumAudio.Strings.Notice.NoSong)
	else return end
end


--## OPTIONS BUTTON ##--
InitDerma(ChromiumAudio.Derma.BTN[4],"Options",50,190,100,20,false)

ChromiumAudio.Derma.BTN[4].DoClick = function( btn )
	local Menu1 = DermaMenu()
	Menu1:AddOption("Hide Panel", function() ChromiumAudio.Derma.Frame:SetVisible(false) end )
	Menu1:AddOption("Stop All Sounds", function() RunConsoleCommand("stopsound") end )
	Menu1:AddOption("Disable "..ChromiumAudio.Engine.Version, ChromiumAudio.Engine.DisableCA)
	Menu1.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(220,0,255,150))
	end
	Menu1:Open()
end


--## HIDE BUTTON ##--
InitDerma(ChromiumAudio.Derma.BTN[5],"Hide",360,0,40,20,false)

ChromiumAudio.Derma.BTN[5].DoClick = function(btn)
	ChromiumAudio.Derma.Frame:SetVisible(false)
end


--## BUTTON COLORING ##--
for i = 1,7 do
	ChromiumAudio.Derma.BTN[i]:SetTextColor(Color(255,255,255))
	ChromiumAudio.Derma.BTN[i].Paint = function(self,w,h)
		--local TexturedQuadStructure = {texture=surface.GetTextureID('models/alyx/emptool_glow'),color=Color(255,255,255,255),x=-50,y=-50,w=200,h=200}
		--draw.TexturedQuad( TexturedQuadStructure )
		draw.RoundedBox(0,0,0,w,h,ChromiumAudio.Derma.BTNC[i])
	end
	ChromiumAudio.Derma.BTN[i].OnCursorEntered = function()
		ChromiumAudio.Derma.BTNC[i] = Color(0,100,255,50)
		ChromiumAudio.Derma.BTN[i]:SetTextColor(Color(220,0,255,255))
		ChromiumAudio.Derma.BTN[i].Paint = function(self,w,h)
			local TexturedQuadStructure = {texture=surface.GetTextureID('models/props_combine/portalball001_sheet'),color=Color(255,255,255,255),x=0,y=0,w=w,h=h*4}
			draw.TexturedQuad( TexturedQuadStructure )
			draw.RoundedBox(0,0,0,w,h,ChromiumAudio.Derma.BTNC[i])
		end
	end
	ChromiumAudio.Derma.BTN[i].OnCursorExited = function()
		ChromiumAudio.Derma.BTNC[i] = Color(0,0,0,150)
		ChromiumAudio.Derma.BTN[i]:SetTextColor(Color(255,255,255))
		ChromiumAudio.Derma.BTN[i].Paint = function(self,w,h)
			--local TexturedQuadStructure = {texture=surface.GetTextureID('models/alyx/emptool_glow'),color=Color(255,255,255,255),x=-50,y=-50,w=200,h=200}
			--draw.TexturedQuad( TexturedQuadStructure )
			draw.RoundedBox(0,0,0,w,h,ChromiumAudio.Derma.BTNC[i])
		end
	end
end



--## MAXIMIZE BUTTON ##--
InitDerma(ChromiumAudio.Derma.BTN[7],ChromiumAudio.Engine.Version,W/2,H-20,120,20,false)
ChromiumAudio.Derma.BTN[7]:SetTextColor(Color(255,255,255))
ChromiumAudio.Derma.BTN[7]:CenterHorizontal()

ChromiumAudio.Derma.BTN[7].DoClick = function( btn )
	ChromiumAudio.Derma.Frame:SetVisible(true)
	ChromiumAudio.Derma.Frame:MakePopup()
end



--## INIT CONSOLE COMMAND ##--
concommand.Add("ChromiumAudio_Show", function() ChromiumAudio.Derma.Frame:SetVisible(true) end)
concommand.Add("ChromiumAudio_Hide", function() ChromiumAudio.Derma.Frame:SetVisible(false) end)
concommand.Add("ChromiumAudio_Disable", ChromiumAudio.Engine.DisableCA)


------------------ END ------------------
