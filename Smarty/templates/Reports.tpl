{*<!--

/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/

-->*}

{*<!-- module header -->*}
<!--修改编码格式:统一编码：UTF-8-->
{*{include file="Buttons_List1.tpl"}*}
<!-- Toolbar -->


<div id="reportContents">
	{include file="ReportContents.tpl"}
</div>
<!-- Reports Table Ends Here -->

<!-- POPUP LAYER FOR CREATE NEW REPORT -->
<div style="display:none;border:0px;" id="reportLay" class="D_pop_box LdPopWidth300px">
    
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'Creating_a_Report'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('reportLay');puyoungJS_DialogBox.unblock();" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod" cellspacing="1" cellpadding="0" border="0">
      <tr>
        <td align='right' width="20%">{'Reporting_Module'|@getFixedLabel}:</td>
		<td width="30%">
			<select name="selectModuleElement" id="selectModuleElement" style="border: 1px solid #eee;width:150px;">
				{foreach item=modulelabel key=modulename from=$REPT_MODULES}
					<option value="{$modulename}">{$modulelabel|@getTranstab}</option>
				{/foreach}
			</select>
        </td>
      </tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'LBL_Creates'|@getFixedLabel}" onclick="CreateReport('selectModuleElement'); fninvshnew('reportLay');"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('reportLay');"/> 
    </div>
</div>
<!-- END OF POPUP LAYER -->

<!-- Add new Folder UI starts -->
<div id="orgLay" style="display:none;" class="D_pop_box LdPopWidth300px">
    <div class="D_pop_tit">
    	<strong class="D_ptita" id="editfolder_info">{$MOD.LBL_ADD_NEW_GROUP}</strong>
        <a href="javascript:closeEditReport();" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod" cellspacing="1" cellpadding="0" border="0">
      <tr>
        <td align='right' width="20%">{'Folder_name'|@getFixedLabel}</td>
		<td width="30%">
            <input id="folder_id" name="folderId" type="hidden" value=''/>
			<input id="fldrsave_mode" name="folderId" type="hidden" value='save'/>
			<input id="folder_name" name="folderName"  type="text" style="border: 1px solid #eee;"/>
        </td>
      <tr>
        <td align='right' width="20%">{'Folder_Description'|@getFixedLabel}</td>
		<td width="30%">
            <input id="folder_desc" name="folderDesc"  type="text" style="border: 1px solid #eee;" />
			
        </td>
      </tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="AddFolder();"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="closeEditReport();"/>  
    </div>
</div>
<!-- Add new folder UI ends -->




{*<!-- Contents -->*}
	
{literal}
<script>
function createrepFolder(oLoc,divid)
{
    {/literal}
	$('editfolder_info').innerHTML=' {'New_Report_Folder'|@getFixedLabel} ';
	{literal}
	getObj('fldrsave_mode').value = 'save';	
	$('folder_id').value = '';
	$('folder_name').value = '';
	$('folder_desc').value='';
	fnvshobj(oLoc,divid);
}
function closeEditReport()
{
	$('folder_id').value = '';
	$('folder_name').value = '';
	$('folder_desc').value='';
	fninvshnew('orgLay')
}
function DeleteFolder(id)
{
	var title = 'folder'+id;
	var fldr_name = getObj(title).innerHTML;
	{/literal}
        if(confirm("{$APP.DELETE_FOLDER_CONFIRMATION}"+fldr_name +"' ?"))
        {literal}
	{
		new Ajax.Request(
			'index.php',
	                {queue: {position: 'end', scope: 'command'},
        	                method: 'post',
                	        postBody: 'action=ReportsAjax&mode=ajax&file=DeleteReportFolder&module=Reports&record='+id,
                        	onComplete: function(response) {
    							var item = trim(response.responseText);
                                if(item.charAt(0)=='<')
                                {
    						        getObj('customizedrep').innerHTML = item;
	                            }
                                else
                                {
                                    getObj('customizedrep').innerHTML = item;
                                }
                               
                        	}
                	}
        	);
	}
	else
	{
		return false;
	}
}

function AddFolder()
{
	if(getObj('folder_name').value.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
	{
		{/literal}
                alert('{$APP.FOLDERNAME_CANNOT_BE_EMPTY}');
                return false;
                {literal}
	}
	else if(getObj('folder_name').value.replace(/^\s+/g, '').replace(/\s+$/g, '').length > 20 )
	{
		{/literal}
                alert('{$APP.FOLDER_NAME_ALLOW_20CHARS}');
                return false;
                {literal}
	}
	else if((getObj('folder_name').value).match(/['"<>/\+]/) || (getObj('folder_desc').value).match(/['"<>/\+]/))
    {
            alert(alert_arr.SPECIAL_CHARS+' '+alert_arr.NOT_ALLOWED+alert_arr.NAME_DESC);
            return false;
    }	
	/*else if((!CharValidation(getObj('folder_name').value,'namespace')) || (!CharValidation(getObj('folder_desc').value,'namespace')))
	{
			alert(alert_arr.NO_SPECIAL +alert_arr.NAME_DESC);
			return false;
	}*/
	else
	{
		var foldername = encodeURIComponent(getObj('folder_name').value);
		new Ajax.Request(
                        'index.php',
                        {queue: {position: 'end', scope: 'command'},
                                method: 'post',
                                postBody: 'action=ReportsAjax&mode=ajax&file=CheckReport&module=Reports&check=folderCheck&folderName='+foldername,
                                onComplete: function(response) {
				var folderid = getObj('folder_id').value;
				var resresult =response.responseText.split("::");
				var mode = getObj('fldrsave_mode').value;
				if(resresult[0] != 0 &&  mode =='save' && resresult[0] != 999)
				{
					{/literal}
					alert("{$APP.FOLDER_NAME_ALREADY_EXISTS}");
					return false;
					{literal}
				}
				else if(((resresult[0] != 1 && resresult[0] != 0) || (resresult[0] == 1 && resresult[0] != 0 && resresult[1] != folderid )) &&  mode =='Edit' && resresult[0] != 999)
					{
						{/literal}
                                                alert("{$APP.FOLDER_NAME_ALREADY_EXISTS}");
                                                return false;
                                                {literal}
					}
				else if(response.responseText == 999) // 999 check for special chars
					{
                                                {/literal}
                                                alert("{$APP.SPECIAL_CHARS_NOT_ALLOWED}");
                                                return false;
                                                {literal}
					}
				else
					{
						fninvshnew('orgLay');
						var folderdesc = encodeURIComponent(getObj('folder_desc').value);
						getObj('folder_name').value = '';
						getObj('folder_desc').value = '';
						foldername = foldername.replace(/^\s+/g, '').replace(/\s+$/g, '');
                                                foldername = foldername.replace(/&/gi,'*amp*');
                                                folderdesc = folderdesc.replace(/^\s+/g, '').replace(/\s+$/g, '');
                                                folderdesc = folderdesc.replace(/&/gi,'*amp*');
						if(mode == 'save')
						{
							url ='&savemode=Save&foldername='+foldername+'&folderdesc='+folderdesc;
						}
						else
						{
							var folderid = getObj('folder_id').value;
							url ='&savemode=Edit&foldername='+foldername+'&folderdesc='+folderdesc+'&record='+folderid;
						}
						getObj('fldrsave_mode').value = 'save';
						new Ajax.Request(
				                        'index.php',
				                        {queue: {position: 'end', scope: 'command'},
			                                method: 'post',
			                                postBody: 'action=ReportsAjax&mode=ajax&file=SaveReportFolder&module=Reports'+url,
			                                onComplete: function(response) {
			                                        var item = response.responseText;
                        			                getObj('customizedrep').innerHTML = item;
			                                }
						}
			                      
				                );
					}
				}
			}
			);
		
	}
}


function EditFolder(id,name,desc)
{
{/literal}
	$('editfolder_info').innerHTML= '  {'Rename_the_folder'|@getFixedLabel}  '; 	
{literal}
	getObj('folder_name').value = name;
	getObj('folder_desc').value = desc;
	getObj('folder_id').value = id;
	getObj('fldrsave_mode').value = 'Edit';
}
function massDeleteReport()
{
	var folderids = getObj('folder_ids').value;
	var folderid_array = folderids.split(',')
	var idstring = '';
	var count = 0;
	for(i=0;i < folderid_array.length;i++)
	{
		var selectopt_id = 'selected_id'+folderid_array[i];
		var objSelectopt = getObj(selectopt_id);
		if(objSelectopt != null)
		{
			var length_folder = getObj(selectopt_id).length;
			if(length_folder != undefined)
			{
				var cur_rep = getObj(selectopt_id);
				for(row = 0; row < length_folder ; row++)
				{
					var currep_id = cur_rep[row].value;
					if(cur_rep[row].checked)
					{
						count++;
						idstring = currep_id +':'+idstring;
					}
				}
			}else
			{	
				if(getObj(selectopt_id).checked)
				{
					count++;
					idstring = getObj(selectopt_id).value +':'+idstring;
				}
			}
		}
	}
	if(idstring != '')
	{	{/literal}
                if(confirm("{$APP.DELETE_CONFIRMATION}"+count+"{$APP.RECORDS}"))
                {literal}
       		{
			new Ajax.Request(
                        'index.php',
                        {queue: {position: 'end', scope: 'command'},
                                method: 'post',
                                postBody: 'action=ReportsAjax&mode=ajax&file=Delete&module=Reports&idlist='+idstring,
                                onComplete: function(response) {
                                        var item = response.responseText;
                                        	getObj('customizedrep').innerHTML = item;
                                }
                        }
                );
		}else
		{
			return false;
		}
			
	}else
	{
		{/literal}
                alert('{$APP.SELECT_ATLEAST_ONE_REPORT}');
                return false;
                {literal}
	}
}
function DeleteReport(id)
{
	{/literal}
        if(confirm("{$APP.DELETE_REPORT_CONFIRMATION}"))
        {literal}
	{
		new Ajax.Request(
                        'index.php',
                        {queue: {position: 'end', scope: 'command'},
                                method: 'post',
                                postBody: 'action=ReportsAjax&file=Delete&module=Reports&record='+id,
                                onComplete: function(response) {
					getObj('reportContents').innerHTML = response.responseText;
                                }
                        }
                );
	}else
	{
		return false;
	}
}
function MoveReport(id,foldername)
{
	fninvshnew('folderLay');
	var folderids = getObj('folder_ids').value;
	var folderid_array = folderids.split(',')
	var idstring = '';
	var count = 0;
	for(i=0;i < folderid_array.length;i++)
	{
		var selectopt_id = 'selected_id'+folderid_array[i];
		var objSelectopt = getObj(selectopt_id);
		if(objSelectopt != null)
		{
			var length_folder = getObj(selectopt_id).length;
			if(length_folder != undefined)
			{
				var cur_rep = getObj(selectopt_id);
				for(row = 0; row < length_folder ; row++)
				{
					var currep_id = cur_rep[row].value;
					if(cur_rep[row].checked)
					{
						count++;
						idstring = currep_id +':'+idstring;
					}
				}
			}else
			{	
				if(getObj(selectopt_id).checked)
				{
					count++;
					idstring = getObj(selectopt_id).value +':'+idstring;
				}
			}
		}
	}
	if(idstring != '')
	{
		{/literal}
                if(confirm("{$APP.MOVE_REPORT_CONFIRMATION}"+foldername+"{$APP.FOLDER}"))
                {literal}
        	{
			new Ajax.Request(
                        'index.php',
                        {queue: {position: 'end', scope: 'command'},
                                method: 'post',
                                postBody: 'action=ReportsAjax&file=ChangeFolder&module=Reports&folderid='+id+'&idlist='+idstring,
                                onComplete: function(response) {
                                	        getObj('reportContents').innerHTML = response.responseText;
                	                }
                        	}
	                );
		}else
		{
			return false;
		}
			
	}else
	{
		{/literal}
                alert('{$APP.SELECT_ATLEAST_ONE_REPORT}');
                return false;
                {literal}
	}
}
</script>
{/literal}