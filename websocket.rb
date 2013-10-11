require 'em-websocket'
require 'json'

def emulator_control_pannel(command)
	t1 = Time.now

	sdk_root="/home/ubuntu/android-sdk-linux/platform-tools/"
	command_JSON = JSON.parse(command)
	device = command_JSON['device']
#	device = "emulator-5558"
	puts(command_JSON['action'])
	if(command_JSON['action'] == "click")
		parameters = command_JSON['x'] +" "+command_JSON['y']
		runC  = sdk_root+"adb -s "+device+" shell input tap "+parameters
		system(runC)
	end

	if (command_JSON['action'] == 'swipe')
		parameters = command_JSON["xi"] +" "+command_JSON["yi"]
		parameters = parameters + " " + command_JSON["xf"] + " " +command_JSON["yf"]
		command  = sdk_root+"adb -s "+device+" shell input swipe "+parameters
		system(command)
	end

	if(command_JSON['action'] == 'back')
		command  = sdk_root+"adb -s "+device+" shell input keyevent 4"
      	system(command)
    end

	if(command_JSON['action'] == 'unlock')
		command = sdk_root+"adb -s "+device+" shell input keyevent 82"
		system(command)
	end

	if(command_JSON["action"] == "install")
		url = "wget '"+ command_JSON["url"] + "' -O "+  sdk_root+"temp"+device+".apk "
		system(url)
		install_apk =   "cd "+sdk_root+" && ./adb -s "+device+" install temp"+device+".apk "
		system(install_apk)

   		class_name = command_JSON["class_name"]
    	package_name = command_JSON["package_name"]
    	
    	launch_app = "cd "+sdk_root+" && ./adb -s "+device+" shell am start -a android.intent.action.MAIN " + package_name + "/." + class_name
    	system(launch_app)
    	
	end
	t2 = Time.now
    puts(time_diff_secs(t1,t2))
    return {
    	:time => time_diff_secs(t1,t2).to_s,
    	:action => command_JSON["action"]
    }
end

def time_diff_secs(start, finish)
   (finish - start)
end
	

EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 5900) do |ws|
  ws.onopen    { puts("we are connect")}
  ws.onmessage do |msg|
  	begin
  		result=emulator_control_pannel(msg)	
  	rescue Exception => e
  		puts(e)
  	end	
  	ws.send result.to_json
  	 
  end
  ws.onclose   { puts "WebSocket closed" }
end

