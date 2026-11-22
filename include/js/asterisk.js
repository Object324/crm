/**
 *{*修改编码格式:统一编码：UTF-8*}
 * this file will poll the LD_asteriskincomingcalls table
 * for any incoming calls
 *
 * the variable ASTERISK_POLLTIME  denotes the number of milli-seconds after which the crm gets polled
 * the variable ASRERISK_DIV_TIMEOUT denotes the number of milli-seconds after which the incoming call information div times out (i.e. hidden)
 */
function _defAsteriskTimer(){
	var asteriskTimer = null;
	var ASTERISK_POLLTIME = 5000;	//lingdangcrm polls the asterisk server for incoming calls after every 3 seconds for now
	var ASTERISK_INCOMING_DIV_TIMEOUT = 15;	//the incoming call div is present for this number of seconds
	function AsteriskCallback() {
		var url = "module=PBXManager&action=PBXManagerAjax&file=TraceIncomingCall&mode=ajax&ajax=true";
		new Ajax.Request(
			'index.php',
			{
				queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response){
					popupText = trim(response.responseText);
					if(popupText != '' && popupText != 'failure'){
						var div = popupText;
						Popup_lingdang = _defPopup();
						Popup_lingdang.content = div;
						Popup_lingdang.displayPopup(Popup_lingdang.content,ASTERISK_INCOMING_DIV_TIMEOUT);
					}
				}
			}
		);
	}

	function AsteriskRegisterCallback(timeout) {
		if(timeout == null) timeout = ASTERISK_POLLTIME;
		if(asteriskTimer == null) {
			AsteriskCallback();
			asteriskTimer = setInterval(AsteriskCallback, timeout);
		}
	}

	return {
		registerCallback: AsteriskRegisterCallback,
		pollTimer: ASTERISK_POLLTIME
	};
}

AsteriskTimer = _defAsteriskTimer();

AsteriskTimer.registerCallback(AsteriskTimer.pollTimer);