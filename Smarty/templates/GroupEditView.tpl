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
<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="javascript">

function dup_validation()
{ldelim}
	var mode = getObj('mode').value;
	var groupname = $('groupName').value;
	var groupid = getObj('groupId').value;
	if(mode == 'edit')
		var reminstr = '&mode='+mode+'&groupName='+groupname+'&groupid='+groupid;
	else
		var reminstr = '&groupName='+groupname;
	puyoungJS_DialogBox.block();
	//var status = CharValidation(groupname,'namespace');
	//if(status)
	//{ldelim}
	new Ajax.Request(
		'index.php',
		{ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
			method: 'post',
			postBody: 'module=Users&action=UsersAjax&file=SaveGroup&ajax=true&dup_check=true'+reminstr,
			onComplete: function(response) {ldelim}
				if(response.responseText.indexOf('SUCCESS') >-1)
					document.newGroupForm.submit();
				else {ldelim}
					puyoungJS_DialogBox.unblock();
					RemindsMsg("","LdPopWidth400px","","yes","",response.responseText);
				{rdelim}
			{rdelim}
		{rdelim}
		);
	//{rdelim}
	//else
	//	alert(alert_arr.NO_SPECIAL+alert_arr.IN_GROUPNAME)
{rdelim}
var constructedOptionValue;
var constructedOptionName;

var roleIdArr=new Array({$ROLEIDSTR});
var roleNameArr=new Array({$ROLENAMESTR});
var userIdArr=new Array({$USERIDSTR});
var userNameArr=new Array({$USERNAMESTR});
var grpIdArr=new Array({$GROUPIDSTR});
var grpNameArr=new Array({$GROUPNAMESTR});

function showOptions()
{ldelim}
	var selectedOption=document.newGroupForm.memberType.value;
	//Completely clear the select box
	document.forms['newGroupForm'].availList.options.length = 0;

	if(selectedOption == 'groups')
	{ldelim}
		constructSelectOptions('groups',grpIdArr,grpNameArr);		
	{rdelim}
	else if(selectedOption == 'roles')
	{ldelim}
		constructSelectOptions('roles',roleIdArr,roleNameArr);		
	{rdelim}
	else if(selectedOption == 'rs')
	{ldelim}
	
		constructSelectOptions('rs',roleIdArr,roleNameArr);	
	{rdelim}
	else if(selectedOption == 'users')
	{ldelim}
		constructSelectOptions('users',userIdArr,userNameArr);		
	{rdelim}
{rdelim}

function constructSelectOptions(selectedMemberType,idArr,nameArr)
{ldelim}
	var i;
	var findStr=document.newGroupForm.findStr.value;
	if(findStr.replace(/^\s+/g, '').replace(/\s+$/g, '').length !=0)
	{ldelim}
		
		var k=0;
		for(i=0; i<nameArr.length; i++)
		{ldelim}
			if(nameArr[i].indexOf(findStr) ==0)
			{ldelim}
				constructedOptionName[k]=nameArr[i];
				constructedOptionValue[k]=idArr[i];
				k++;			
			{rdelim}
		{rdelim}
	{rdelim}
	else
	{ldelim}
		constructedOptionValue = idArr;
		constructedOptionName = nameArr;	
	{rdelim}
    
    
    /**
     *@edit:andy 
     *@date:
     *@reason:部门编辑左右选择框改进
     *@version:
     */
	var selectedOption=document.getElementById('selectedColumns')['options'];//有下拉框对象数组
    //alert(selectedOption[0].value)
    var optionLen=selectedOption.length
    //将右下拉框放入数组，等下和左边选择框比对，在其中的下拉项去掉
    var rightOptionValues=[];
    for(var i=0;i<optionLen;i++)
    {ldelim}
        rightOptionValues[i]=selectedOption[i].value;
    {rdelim}
    //alert(rightOptionValues)
    
    
	//Constructing the selectoptions
	var j;
    var optis=0;//赋值初始下标
	var nowNamePrefix;	
	for(j=0;j<constructedOptionName.length;j++)
	{ldelim}
		if(selectedMemberType == 'roles')
		{ldelim}
			//nowNamePrefix = 'Roles::'
            nowNamePrefix = arrJsPopLabel['LBL_ROLES']+'::'
		{rdelim}
		else if(selectedMemberType == 'rs')
		{ldelim}
			//nowNamePrefix = 'RoleAndSubordinates::'
            nowNamePrefix = arrJsPopLabel['ROLEANDSUBORDINATE']+'::'
		{rdelim}
		else if(selectedMemberType == 'groups')
		{ldelim}
			//nowNamePrefix = 'Groups::'
            nowNamePrefix=arrJsPopLabel['USERGROUPLIST']+"::"
		{rdelim}
		else if(selectedMemberType == 'users')
		{ldelim}
			//nowNamePrefix = 'User::'
            nowNamePrefix = arrJsPopLabel['LBL_USERS']+'::'
		{rdelim}

		var nowName = nowNamePrefix + constructedOptionName[j];
		var nowId = selectedMemberType + '::'  + constructedOptionValue[j]
        
        /**
         *@edit:andy 
         *@date:
         *@reason:部门编辑左右选择框改进
         *@version:
         */
        if(rightOptionValues.indexOf(nowId)>-1 )//和左边选择框比对，在其中的下拉项去掉
            //alert(nowId)
            continue;
        //end 改进
		document.forms['newGroupForm'].availList.options[optis ++] = new Option(nowName,nowId);	
	{rdelim}
	//clearing the array
	constructedOptionValue = new Array();
        constructedOptionName = new Array();	
				

{rdelim}

function validate()
{ldelim}
	formSelectColumnString();
	if( !emptyCheck( "groupName", arrJsPopLabel['GROUPNAME'],"text" ) )
		return false;
	//check to restrict the & < > , characters
	var str = $("groupName").value;
	var re1=/[&\<\>\,]/
        if (re1.test(str))
        {ldelim}
			var confirm_str = alert_arr.SPECIAL_CHARACTERS+" & < > , "+alert_arr.NOT_ALLOWED;
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        {rdelim}
	
	if(document.newGroupForm.selectedColumnsString.value.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
	{ldelim}
		var confirm_str = arrJsPopLabel['GROUPSHOULDHAVEONEMEMBER'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	{rdelim}
	dup_validation();return false;	
{rdelim}
</script>

<!--中间-->
<div class="List3Box">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="TdLeft" valign="top" style="width:200px;">
    	{include file='SetMenuNew.tpl'}
    </td>
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
    {literal}
	<form name="newGroupForm" action="index.php" method="post" onSubmit="if(validate()) { puyoungJS_DialogBox.block();} else { return false; }">
	{/literal}
		<input type="hidden" name="module" value="Users">
		<input type="hidden" name="action" value="SaveGroup">
		<input type="hidden" name="mode" value="{$MODE}">
		<input type="hidden" name="parenttab" value="Settings">
		<input type="hidden" name="groupId" value="{$GROUPID}">
		<input type="hidden" name="returnaction" value="{$RETURN_ACTION}">
        <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
        <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
      <div class="DivCR">       
         <div class="ControlDiv1">
            <span class="Url fontbold">
                {'CONTROLPANEL'|@getFixedLabel} &gt; 
                <a href="index.php?module=Settings&action=listgroups&parenttab=Settings&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}">{'USERGROUPLIST'|@getFixedLabel}</a> &gt; 
                {if $MODE eq 'edit'}
			     {'EDIT'|@getFixedLabel} &quot;{$GROUPNAME}&quot; 
				{else}	
			     {'NEWGROUP'|@getFixedLabel}
				{/if}
            </span>
        </div>
        <div class="ControlDiv2">
        	<span class="F_l"><font size='2'>
            {if $MODE eq 'edit'}
			     {'EDITINGPROPERTIESOF'|@getFixedLabel} &nbsp;&quot;{$GROUPNAME}&quot; {'GROUP_GROUP'|@getFixedLabel}
			{else}
			     {'NEWGROUP'|@getFixedLabel}
			{/if}
            </font></span>
            <input type="button" class="cancelauto" name="cancel" value="{'CANCEL'|@getFixedLabel}" onClick="window.history.back()">
	        {if $MODE eq 'edit'}
			     <input type="submit" class="saveauto" name="add" value="{'SAVE'|@getFixedLabel}" onClick="return validate()">
			{else}
			     <input type="submit" class="saveauto" name="add" value="{'SAVE'|@getFixedLabel}" onClick="return validate()">
			{/if}
	     </div>
        <div class="pad10" >
			<table width="100%"  border="0" cellspacing="0" cellpadding="5">
                <tr class="TitleHeading">
                    <td colspan="2" height="20">
                     {if $MODE eq 'edit'}
					<strong>{'USERGROUPLIST'|@getFixedLabel} &quot;{$GROUPNAME}&quot; </strong>
					{else}
					<strong>{'NEWGROUP'|@getFixedLabel}</strong>
					{/if}
		            </td>
                </tr>
                <tr>
					<td width="15%" class="cellLabel borderT"><font color="red">*</font><strong>{'GROUPNAME'|@getFixedLabel}</strong></td>
					<td width="85%" class="borderBR" ><input id="groupName" name="groupName" type="text" value="{$GROUPNAME}" class="controlInput"/></td>
				</tr>
				<tr>
					<td class="cellLabel"><strong>{'DESCRIPTION'|@getFixedLabel}</strong></td>
					<td class="borderBR"><input name="description" type="text" value="{$DESCRIPTION}" class="controlInput"/> </td>
				</tr>
         	</table>
            
            <table width="100%" class="borderALL BorTnone" border="0" cellspacing="0" cellpadding="5">
                <tr class="TitleHeading" style="border-top:none;">
					<td colspan="2" height="20"><strong>{'MEMBER'|@getFixedLabel}</strong></td>
              	</tr>
				<tr>
					<td colspan="2" >
						<table width="95%"  border="0" align="center" cellpadding="5" cellspacing="0">
						<tr>
							<td colspan="3">
								{'STATUS'|@getFixedLabel}:&nbsp;
								<select id="memberType" name="memberType" onchange="showOptions()">
								<option value="groups" selected>{'USERGROUPLIST'|@getFixedLabel}</option>
								<option value="roles">{'LBL_ROLES'|@getFixedLabel}</option>
								<option value="rs">{'ROLEANDSUBORDINATE'|@getFixedLabel}</option>
								<option value="users">{'LBL_USERS'|@getFixedLabel}</option>
								</select>
								<input type="hidden" name="findStr"/>
							</td>
						</tr>
                  		 <tr>
							<td width="30%">{'AVAILABLEMEMBER'|@getFixedLabel}<br/>
								<select id="availList" name="availList" style="width:100%;margin-top:5px;" size="8" multiple="multiple"  ondblclick="addColumn('availList','selectedColumns')"></select>
								<input type="hidden" name="selectedColumnsString"/>
					       </td>
							<td align="center">
							    <a class="icon-homearr icon-mright" href="javascript:;" title="{'RIGHT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('availList','selectedColumns')"></a></br>
								<a class="icon-homearr icon-mleft" href="javascript:;" title="{'LEFT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('selectedColumns','availList')" ></a>
							</td>
							<td>{'MEMBERSSELECTED'|@getFixedLabel} &nbsp;{$GROUPNAME}<br/>
								<select id="selectedColumns" name="selectedColumns" style="width:300px;margin-top:5px;" size="8" multiple="multiple" ondblclick="addColumn('selectedColumns','availList')">
								<!--左边-->
                                {foreach item=element from=$MEMBER}
							         <option value="{$element.0}">{$element.1}</option>
                                
								{/foreach}
								</select>
							</td>
						</tr>
						<tr>
							<td colspan="3">
							<font class="greyFont6">{'GROUPINFO1'|@getFixedLabel}</font>
							</td>
						</tr>
						</table>
					</td>
				</tr>
            </table>

        </div>         
                 
      </div>
      </form>		
    </td>
  </tr>
</table>
</div>
<!--中间 end-->

<script language="JavaScript" type="text/JavaScript">    
var moveupLinkObj,moveupDisabledObj,movedownLinkObj,movedownDisabledObj;
function setObjects() 
{ldelim}
availListObj=getObj("availList")
selectedColumnsObj=getObj("selectedColumns")

{rdelim}



function formSelectColumnString()
{ldelim}
var selectedColStr = "";
for (i=0;i<selectedColumnsObj.options.length;i++) 
{ldelim}
selectedColStr += selectedColumnsObj.options[i].value + ";";
{rdelim}
document.newGroupForm.selectedColumnsString.value = selectedColStr;
{rdelim}
setObjects();
showOptions();
</script>