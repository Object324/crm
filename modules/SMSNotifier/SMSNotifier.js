/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
if(typeof(SMSNotifier) == 'undefined') {
	var SMSNotifier = {
		
		checkstatus : function(record) {
			SMSNotifier.loadstatus(record, true);
		},
		
		loadstatus : function(record, query) {
			var wrapper = $('tblStatusInformation');
			
			if(typeof(query) == 'undefined') query = false;
			
			if(wrapper) {
				var url = 'module=SMSNotifier&action=SMSNotifierAjax&ajax=true&file=SMSNotifierStatusWidget&record=' + record;
				if(query) {
					url += '&mode=query';
				}
				
				$('vtbusy_info').show();
				
				new Ajax.Request('index.php', {
                     queue: {position: 'end', scope: 'command'},
                     method: 'post',
                     postBody:  url,
                     onComplete: function(response)
                     {
                     	wrapper.innerHTML = response.responseText;
                     	$('vtbusy_info').hide();
                     }
             	});				
			}	
		}
		
	};
}