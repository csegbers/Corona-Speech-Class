--====================================================================--
-- Classroom Companion
--====================================================================--
 print("<-==================== Program Start ====================->") 

--====================================================================--
--  requires
--====================================================================-- 
 
local speechtable =
{
     speechtext=(" me hi Iran's six-month freeze of its nuclear programme agreed with world powers in Geneva will start by early January, in Tehran's envoy to the UN atomic watchdog said Friday"),
     language= "en",   	--	en = {id="en",desc="English",},
						--	fr = {id="fr",desc="French",},
						--	de = {id="de",desc="German",},
						--	it = {id="it",desc="Italian",},
						--	la = {id="la",desc="Latin",},
						--	es = {id="es",desc="Spanish",},
     filename = ("testspeechfile"),
     filedir = system.TemporaryDirectory,
     overwritespeechfiles = true,
     buildspeechfilesonly = false
 }  



local speechinstance = require("classspeech").new(speechtable) 
local audst, speechtable = speechinstance:PlayAudio()

-- look at the temp files created. Note: they may not exist yet as these are async calls to google.
local reterr,k,v
for k,v in pairs(speechtable) do print ("Speech table ",v.filename, v.text) end
 

-- if speechinstance then speechinstance:removeSelf(); speechinstance = nil; end



 

					 