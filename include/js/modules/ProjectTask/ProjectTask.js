/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/


/**
 *reason:项目计划保存，关闭，删除时，反写项目字段"已完成项目计划数"。
 *edit:cyb
 *date:2015-11-13
 *
function UpdateProjectInfo(recordid){   
     var urlstring='module=ProjectTask&action=UpdateProjectInfo&recordid='+recordid;   
 	 new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:urlstring,
			onComplete: function(response) {
			    }
       }
	 ); 
}*/