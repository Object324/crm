/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
if (typeof(ModCommentsCommon) == 'undefined') {
	ModCommentsCommon = {
		modulename : '',
		addComment : function(domkeyid, parentid) {
			var textBoxField = $('txtbox_'+domkeyid);
			var contentWrapDOM = $('contentwrap_'+domkeyid);
			if (textBoxField.value == '') {
				return;
			}
			var url = 'module=ModComments&action=ModCommentsAjax&file=DetailViewAjax&ajax=true&Create=true&ajxaction=WIDGETADDCOMMENT&parentid='+encodeURIComponent(parentid);
			url += '&comment=' + encodeURIComponent(textBoxField.value);
			url += '&related_to_type=' + this.modulename;
			lingdangJS_DialogBox.block();
			$("status").style.display="inline";
			new Ajax.Request('index.php',{
				queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
					 $("status").style.display="none"; 
					lingdangJS_DialogBox.unblock();
					
					var responseTextTrimmed = trim(response.responseText);
					if (responseTextTrimmed.substring(0, 10) == ':#:SUCCESS') {
						textBoxField.value = '';
						contentWrapDOM.innerHTML = responseTextTrimmed.substring(10)+contentWrapDOM.innerHTML;
					}else if(responseTextTrimmed.substring(0, 10) == ':#:FAILURE'){
						alert(arrJsPopLabel['OPERATION_DENIED']);
					}else{
						window.location.href="index.php?module="+this.modulename+"&action=DetailView&record="+encodeURIComponent(parentid); 
					}
				}}
			);
		},
		reloadContentWithFiltering : function(widget, parentid, criteria, targetdomid, indicator) {
			if($(indicator)) $(indicator).style.display="inline";
			
			var url = 'module=ModComments&action=ModCommentsAjax&file=ModCommentsWidgetHandler&ajax=true';
			url += '&widget=' + encodeURIComponent(widget) + '&parentid='+encodeURIComponent(parentid);
			url += '&criteria='+ encodeURIComponent(criteria);
			
			new Ajax.Request('index.php',{
				queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
					if($(indicator)) $(indicator).style.display="none";
                    
					var results=response.responseText.split('###SUCCESS###');
                    result = results[0];
                    result = trim(result);
					 if($(targetdomid)) $(targetdomid).innerHTML = result;
				}}
			);
		}
	}
}