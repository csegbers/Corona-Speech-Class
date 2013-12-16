-------------------------------------------------
--
-- classspeech.lua class
--
-------------------------------------------------


local speech = {}
local speech_mt = { __index = speech }	-- metatable

-------------------------------------------------
-- PUBLIC FUNCTIONS
--
-- COnstructor
-------------------------------------------------

function speech.new( parms )	-- constructor
 
	local newspeech = {
							typeobject				= "speechclass",
							id                      = parms.id,
	    					speechtext 				= parms.speechtext,
	    					language   				= (parms.language or "en"),      -- 'en' for example
	    					--	en = {id="en",desc="English",},
						--	fr = {id="fr",desc="French",},
						--	de = {id="de",desc="German",},
						--	it = {id="it",desc="Italian",},
						--	la = {id="la",desc="Latin",},
						--	es = {id="es",desc="Spanish",},
	    					audiofreechannelsearch  = parms.audiofreechannelsearch,
	    					filename   				= parms.filename,
	    					filedir   				= parms.filedir,
	    					audioformat             = (parms.audioformat or "wav"),
	    					speechurl               = (parms.speechurl or "http://translate.google.com/translate_tts"),
	    					speechmaxlength			= (parms.speechmaxlength or 100),   -- free will only allow 100 max so we split it up
	    					overwritespeechfiles    = (parms.overwritespeechfiles or false),
	    					buildspeechfilesonly    = (parms.buildspeechfilesonly or false),
	    					play                    = true,
	    					error                   = nil,
					  }

	return setmetatable( newspeech, speech_mt )
end

 
function speech:PlayAudio()

	 self.mysplit = function(inputstr, isepin, maxlength, splitonsentence)
		        local isep = (isepin or " ")
		        local sep = isep
		        if sep == nil then sep = "%s" end
		        local t={} ; local i=1; local str 
		        t[i] = ""
		        local newsentence = false
		        local strremovestuff = string.gsub(inputstr, '\n', ' ' )
		        strremovestuff = string.gsub(strremovestuff, '\r', ' ' )
		        for str in string.gmatch( strremovestuff , "([^"..sep.."]+)") do
		                if (string.len(t[i])  + string.len(str) + string.len(isep) >  maxlength) or (newsentence == true) then
		                   i = i + 1
		                   t[i] = str 
		                else
		                   if t[i] ~= "" then  t[i] = t[i] .. isep end
		                   t[i] = t[i] .. str
		                end
		                --print (str,string.find(str,"%."),string.find(str,"%?"))
		                --=========================
		                --== End of sentence ? Go ahead and split
		                --== This way the pause is more natural
		                --== just incase the sentence wiould be split otherwise
		                --========================
		                if  ((splitonsentence or false) == true and (string.find(str,"%.") ~= nil or string.find(str,"%?") ~= nil) ) then
		                   newsentence = true
		                else
		                   newsentence = false
		                end
		        end
		        return t
	 end
	 self.fileExists = function( srcName, srcPath )
	    local results = false                -- assume no errors
		local path = system.pathForFile(srcName, srcPath )
		if path then -- file exists
				local file = io.open( path, "r" )
		 
				if file then -- nil if no file found
						io.close( file )
						results = true
				end
		end
		return results  
	end


	self.urlencode =   function  (str)
	  if (str) then
		str = string.gsub (str, "\n", "\r\n")
		str = string.gsub (str, "([^%w ])",
			function (c) return string.format ("%%%02X", string.byte(c)) end)
		str = string.gsub (str, " ", "+")
	  end
	  return str
	end	


	 local t = self.mysplit(self.speechtext," ", self.speechmaxlength,true)
	 local i
	 local rettable = {}

	 local function CheckFinished( parms )
	 	print ("CheckFinish",parms.pos)
	 	if self.play == true and parms.pos == #t then
	 		Runtime:dispatchEvent{ name="speechevents" ,target=self,type="finish"}
	 	end
	 end


	 self.PlaySpeechFile = function(event)
		if self.play == true and self.buildspeechfilesonly == false then
			if ( event.isError ) then
				    self.error = "Network error -  download failed"
					print ("Error:", self.error)
					CheckFinished({pos=#t,error=self.error})
					self.play = false
			else
					if event.pos < #t   then 
					   event.nextfile = self.filename .. "seq" .. event.pos + 1 .. "." .. self.audioformat
					else 
					   event.nextfile = nil
					end

                    --======================
                    --== if on a slow connection and the next file is unavailbe we basially stop
                    --======================
					if event.fn  and self.fileExists(event.fn,event.fp)  == true  then  
					   --============================
					   --== for some unknown reason android likes adio load even though that is not the case when we record and playback
					   --== so wav files are ok so long as not recorded via android - not true now 9/7/2012
					   --===============================  
						--print ( "play File " , event.fn,ct.archformat() )
					----	if ct.archformat() == "media" then
					----	native.showAlert( "have filer",event.fn,{ "OK" }) 
					----		media.playSound( event.fn, event.fp,function() self.PlaySpeechFile({isError=event.isError,fn=event.nextfile,fp=event.fp,pos=event.pos+1}) end)
					----	else
					
					
							--self.audiostream = audio.loadSound( event.fn,event.fp )
							print ("PLAYPLAY",event.fn,event.fp)
							self.audiostream = audio.loadStream( event.fn,event.fp )
							local freechannel = audio.findFreeChannel((self.audiofreechannelsearch or 0))
							self.audiostreamchannel = audio.play( self.audiostream,{channel=freechannel,onComplete=function() self.PlaySpeechFile({isError=event.isError,fn=event.nextfile,fp=event.fp,pos=event.pos+1}) end}) 
 	    	                Runtime:dispatchEvent{ name="speechevents" ,target=self,file=event.fn,type="play"}
                    else
 						CheckFinished({pos=#t})
					end
			end
		else
			CheckFinished({pos=event.pos})
		end
	 end

    self.fncAudioStop = function(   )
		if self.audiostreamchannel then
			  audio.stop( self.audiostreamchannel )
			  self.audiostreamchannel = nil
		end
		if self.audiostream then 
			  audio.dispose( self.audiostream ) 
			  self.audiostream = nil 
		end
	end
	 
	 self.PlaySpeech = function( event )
			if event.pos == 1 then self.fncAudioStop();  self.PlaySpeechFile(event) end
	 end 
	 
	 for i = 1,#t ,1 do
			local finalfn =  self.filename .. "seq" .. i .. "." .. self.audioformat 
			rettable[i] = {} ; rettable[i].filename = finalfn;  rettable[i].text = t[i]
			if (self.fileExists(finalfn,self.filedir)  == false or self.overwritespeechfiles == true) and self.play == true then
			   local urlfinal = self.speechurl .. "?tl=" .. self.language .. "&q=" .. self.urlencode(t[i])
			   print (urlfinal)
			   network.download(urlfinal,"GET", 
								function(event) if i == 1 then  self.PlaySpeech({isError=event.error,fn=finalfn,fp=self.filedir,pos=i })  else if self.buildspeechfilesonly == true then CheckFinished({pos=i}) end end  end ,
								finalfn, self.filedir
								)    
			else
			   if i == 1 then 
			   	  self.PlaySpeech({isError=false,fn=finalfn,fp=self.filedir,pos=i })
			   else 
			   	  if self.buildspeechfilesonly == true then CheckFinished({pos=i}) end
			   end
			end
	 end
	 
	 return self.audiostreamchannel,rettable

end


function speech:removeSelf()
    self.play = false
    if self.audiostreamchannel then
          print ("AUDIO STOP Channel",self.audiostreamchannel)
		  audio.stop( self.audiostreamchannel )
		  self.audiostreamchannel = nil
	end
	if self.audiostream then
	      print ("AUDIO STOP Stream")
		  audio.dispose( self.audiostream ) 
		  self.audiostream = nil 
	end
    
end

return speech