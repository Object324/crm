/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/

function set_return_specific(projectid, projectname) {    
    //getOpenerObj used for DetailView
    var fldName = getOpenerObj("projectid_display");
    var fldId = getOpenerObj("projectid");
    fldName.value = projectname;
    fldId.value = projectid;
}
function add_data_to_relatedlist(entity_id,recordid) {
	new Ajax.Request(
	'index.php',
	{
		queue: {
			position: 'end',
			scope: 'command'
		},
		method: 'post',
		postBody:"module=Project&action=updateRelations&destination_module= Products&entityid="+entity_id+"&parentid="+recordid,
		onComplete: function(response) {
			var popupobj=CrmPopup.getPopupObj('lastprev');
			var divid = popupobj.divid;
			var related_id = CrmPopup.findHtmlobj(divid,'hidden_related_id_Accounts').val();
			var viewid = CrmPopup.findHtmlobj(divid,'viewname_Accounts').val();
			cancelCrmPopup();
			showRelatedCustomView(related_id,viewid);
			setRelatedResizeTable_Init('Project');
			set_rel_count();
		}
	}
	);
}