/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
/**
 * this file contains all the utility functions for notebook
 */

/**
 * this function saves the contents of the notebook and restores the div once the control is moved out of the textarea
 * @param object node - the textarea div
 */
function saveContents(node, notebookid) {
	var contents = node.value;
	new Ajax.Request(
		'index.php',
		{
			queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:'module=Home&action=HomeAjax&file=SaveNotebookContents&contents='+encodeURIComponent(contents)+'&notebookid='+notebookid,
			onComplete: function(response){
				var responsedata = trim(response.responseText);
                                var responsearray = JSON.parse(responsedata);
                                if(responsearray['status'] == false){
					alert("Some error has occurred during save");
				}else{
					//success
					node.style.display = 'none';
                    var nodediv = $('notebook_div_'+notebookid);
					var temp = $('notebook_contents_'+notebookid);
					var notebook_save_message = $('notebook_save_message');

					//edit: xll 2023/10/12 BUG0072454 BUG0072454 kfbcrm-首页-编辑看板-双击记事本-页面变空白
					var PopupObj = CrmPopup.getPopupObj('last')
					if(PopupObj.divid && ld('#'+PopupObj.divid+' #notebook_textarea_'+notebookid)){
						temp = ld('#'+PopupObj.divid+' #notebook_contents_'+notebookid).get(0);
						nodediv = ld('#'+PopupObj.divid+' #notebook_div_'+notebookid).get(0);
						notebook_save_message = ld('#'+PopupObj.divid+' #notebook_save_message').get(0);
					}

					nodediv.style.display = 'none';
					temp.style.display = 'block';
					if(responsearray['contents'] == ''){
						temp.innerHTML = '<pre style="display:none;">' + responsearray['contents'] + '</pre>';
					}else{
						temp.innerHTML = '<pre>' + responsearray['contents'] + '</pre>';
					}
					//temp.innerHTML = '<pre>' + responsearray['contents'] + '</pre>';
                    
					//var notebook_dbl_click_message = $('notebook_dbl_click_message');
					//notebook_dbl_click_message.style.display = 'block';
					notebook_save_message.style.display = 'none';
				}
			}
		}
	);
}
/**
 * this function changes the div of the notebook to a textarea when double-clicked
 * @param object node - the notebook div
 */
function editContents(node, notebookid) {
	var notebook = $('notebook_textarea_'+notebookid);
	var contents = $('notebook_contents_'+notebookid);
    var notediv = $('notebook_div_'+notebookid);

	//var notebook_dbl_click_message = $('notebook_dbl_click_message');
	var notebook_save_message = $('notebook_save_message');

	//edit: xll 2023/10/12 BUG0072454 BUG0072454 kfbcrm-首页-编辑看板-双击记事本-页面变空白
	var PopupObj = CrmPopup.getPopupObj('last')
	if(PopupObj.divid && ld('#'+PopupObj.divid+' #notebook_textarea_'+notebookid)){
		notebook = ld('#'+PopupObj.divid+' #notebook_textarea_'+notebookid).get(0);
		contents = ld('#'+PopupObj.divid+' #notebook_contents_'+notebookid).get(0);
		notediv = ld('#'+PopupObj.divid+' #notebook_div_'+notebookid).get(0);
		notebook_save_message = ld('#'+PopupObj.divid+' #notebook_save_message').get(0);
	}
	notebook.value = contents.getElementsByTagName('pre')[0].innerHTML;
	node.style.display = 'none';
	notebook.style.display = 'block';
    notediv.style.display = 'block';
	//notebook_dbl_click_message.style.display = 'none';
	notebook_save_message.style.display = 'block';
	notebook.focus();
}