--====================================================================--
-- Classroom Companion
--====================================================================--
 print("<-==================== Program Start ====================->") 
 
local speechtable =
   {
speechtext=(" four score and seven years ago our forefathers. with world powers in Geneva will start by early January. in Tehran's envoy to the UN atomic watchdog said Friday"),
      --speechtext=(" four score and seven years ago our forefathers"),
    language= "en",   	
     filename = ("testspeechfile"),
     filedir = system.TemporaryDirectory,
     overwritespeechfiles = true,
     buildspeechfilesonly = false
   }  
 
local speechinstance = require("classspeech").new(speechtable) 

local function fncspeechevents( event )
       print ("event:", event.target.typeobject, event.type)
       if event.type == "play" then
           print (event.file, event.target.language,type(event.target))
       end
       if event.type == "finish" then
           print ("finshed")
           Runtime:removeEventListener("speechevents", fncspeechevents )
           speechinstance:removeSelf( )
           speechinstance = nil
       end
 end

Runtime:addEventListener( "speechevents", fncspeechevents )

local audst, speechtable = speechinstance:PlayAudio()



 

					 