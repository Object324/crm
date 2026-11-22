{literal}
<style type="text/css">
.pad{
	padding-left:10px;
}
</style>
{/literal}

<!--中间-->
<div class="List3Box">
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="TdLeft" valign="top" style="width:200px;">
    	{include file='SetMenuNew.tpl'}
    </td>
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
	{literal}
    <form name="EditView" action="index.php" method="post" onSubmit="if(validate()) { puyoungJS_DialogBox.block();} else { return false; }">
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="action" value="SaveAccountSet"/>
    <input type="hidden" name="return_module" value="Settings"/>
    <input type="hidden" name="return_action" value="AccountSet"/>
    {/literal}
    <input type="hidden" name="isset" value="{$ISET}"/>
    <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
      <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
    
    <div class="DivCR" id="dv_accountset">       
         <div class="ControlDiv1">
            <span class="Url2">{'CONTROLPANEL'|@getFixedLabel} &gt; {'LBL_ACCOUNT_SET'|@getFixedLabel}</span>
            {if 'oem_crm'|@getCommonVersion eq 'no'}<a class="help_txt" href="javascript:;" onclick="getLinksUrl('','Settings','publicAccountSet');">{'ONLINEHELP'|@getFixedLabel}</a>{/if}
        </div>
        <div class="ControlDiv2">
             <div class="F_l"> </div>
             <div class="F_r">
               <input type="submit" title="{'SAVE'|@getFixedLabel}" value="{'SAVE'|@getFixedLabel}" name="save" class="saveauto" style="float:right"/>
             </div>
        </div>
        <div class="pad10">
             <div class="PublicseaSet">
               <ul>
                  <li class="PublicTitle">{'PUBLICCUSTOMERSET'|@getFixedLabel}</li>
                  <li>
                    <span class="pad">{'ACTIVATEPUBLICCUST'|@getFixedLabel}</span>
                    {if $ISET eq 1}
                        <input type="checkbox" class="inputBornone" name="status" onclick="publicStatusChange(this)" /> 
                    {else}
                        <input type="checkbox" class="inputBornone" name="status" onclick="publicStatusChange(this)" checked="checked"/> 
                    {/if}
                  </li>
                  <li>
                    <span class="pad">{'UNALLOCATECUSTOMERADMIN'|@getFixedLabel}</span>
                    {if $ISET eq 1}
                        <input type="checkbox" class="inputBornone" name="getProfile" onclick="getProfileChange(this)" value="1" disabled="true"/> 
                    {else}
                        {if $GETPROFILE eq 1}
                            <input type="checkbox" class="inputBornone" name="getProfile"  onclick="getProfileChange(this)" value="1"/> 
                        {else}
                             <input type="checkbox" class="inputBornone" name="getProfile" onclick="getProfileChange(this)" value="0" checked/> 
                        {/if}
                    {/if}
                  </li> 
                  <li>
                    <span class="pad">{'CUSTOMERCONTROLPUBLIC'|@getFixedLabel}</span>
                     {if $ISET eq 1}
                        <input type="checkbox" class="inputBornone" name="dataProfile" onclick="dataProfileChange(this)" value="1" disabled="true"/> 
                     {else}
                         {if $DATAPROFILE eq 1}
                             <input type="checkbox" class="inputBornone" name="dataProfile" onclick="dataProfileChange(this)" value="1" /> 
                         {else}
                            <input type="checkbox" class="inputBornone" name="dataProfile" onclick="dataProfileChange(this)" value="0" checked/> 
                         {/if}
                     {/if}
                  </li>
                  <!-- 
                    reason 公海客户改进
                    by andy
                    date 20140717
                    verson v5.4
                 -->
                  <li>
                    <span class="pad">
                    {'WEHERTODISPLAYTHEPUBLICCUSTOMERES'|@getFixedLabel}
                    {if $ISET eq 1}
                        <input type="checkbox" class="inputBornone" name="wheathershow" onclick="dataProfileChange(this)" value="1"  disabled="true"/>
                    {else}
                        {if $wheathershow eq 0}
                            <input type="checkbox" class="inputBornone" name="wheathershow" onclick="dataProfileChange(this)" value="0" checked/> 
                        {else}
                            <input type="checkbox" class="inputBornone" name="wheathershow" onclick="dataProfileChange(this)" value="1" />
                        {/if}                    
                    {/if}   
                    </span>
                  </li>
                  <!--yyx 2015-4-21 begin 控制面板公海参数设置里增加‘序时簿“新建”功能下拉按钮选项-->
                  <li style="clear: both;margin-top: -5px;">
                    <div style="float: left;margin-top: 4px;padding-left: 10px;">
                      {'NEWBUTTONDROP-DOWNOPTIONS'|@getFixedLabel}
                    </div>
                    {assign var=fldname value='newdropdownoption'}
                    <select id="newdropdownoption"  name="newdropdownoption" style="display:none">
                      {foreach key=key item=item from=$buttonarray}  {*$buttonarray为公海参数值数组*}
                        <option value="{$key}" {if $key == $buttontype}selected{/if}>{$item}</option>
                      {/foreach}
                    </select>
                    <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" style="position:absolute; margin-left:6px;margin-top:-2px;" onMouseLeave="cmb_mouseleave(event,'{$fldname}','dv_accountset')">
                     	<a style="width:100px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','dv_accountset')" href="javascript:void(0)" tabindex="-1"
                         name="cmb_a_{$fldname}">
                        <span name="cmb_span_optiontext_{$fldname}">{$buttonarray.$buttontype}</span>
                        <div>
                            <b></b>
                        </div>
                	    </a>
                	    <div style=" left:-9000px;width: 108px; top: 20px;" class="chzn-drop" name='dv_drop_{$fldname}' >
                			<div class="chzn-search">
                			<input class="search_bg" type="text" autocomplete="off" style="width: 96px;" tabindex="0"  name='txt_search_{$fldname}' onclick="com_chosen(event,'{$fldname}','dv_accountset')" onKeyUp="com_chosen(event,'{$fldname}','dv_accountset')">
                			</div>
                			 <ul class="chzn-results" name="cmb_ul_{$fldname}">
                        	{foreach key=key item=item from=$buttonarray}
                    			{assign var="i" value=$i+1}   
             	              <li  class="active-result" style="padding: 6px 7px;" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}','dv_accountset')" onmouseover="cmb_limouseover(event,'{$fldname}','dv_accountset')"> {$item}</li>
                	        {/foreach}
                          <li class="" name="li_chzn_{$fldname}" style="padding: 6px 7px;">{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                			 </ul>
                	    </div>
                    </div>
                  </li>
				          <!--快速创建客户默认的客户公海状态-->
                  <li style="clear: both;margin-top: 19px;">
                    <div style="float: left;margin-top: 4px;padding-left: 10px;">
                      {'quicklycreatedefaultaccount'|@getFixedLabel}
                    </div>
				            {assign var=fldname value='publicaccount'}
                    <select id="publicaccount"  name="publicaccount" style="display:none">
                      {foreach key=key item=item from=$publicaccountarray}
                        <option value="{$key}" {if $key == $publicaccount}selected{/if}>{$item}</option>
                      {/foreach}
                    </select>
                    <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" style="position:absolute; margin-left:6px;margin-top:-2px;" onMouseLeave="cmb_mouseleave(event,'{$fldname}','dv_accountset')">
                     	<a style="width:100px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','dv_accountset')" href="javascript:void(0)" tabindex="-1"
                         name="cmb_a_{$fldname}">
                        <span name="cmb_span_optiontext_{$fldname}">{$publicaccountarray.$publicaccount}</span>
                        <div>
                          <b></b>
                        </div>
                	    </a>
                	    <div style=" left:-9000px;width: 108px; top: 20px;" class="chzn-drop" name='dv_drop_{$fldname}' >
                			<div class="chzn-search">
                			<input class="search_bg" type="text" autocomplete="off" style="width: 96px;" tabindex="0"  name='txt_search_{$fldname}' onclick="com_chosen(event,'{$fldname}','dv_accountset')" onKeyUp="com_chosen(event,'{$fldname}','dv_accountset')">
                			</div>
                			 <ul class="chzn-results" name="cmb_ul_{$fldname}">
                        	{foreach key=key item=item from=$publicaccountarray}
                    			{assign var="j" value=$j+1}   
             	              <li  class="active-result" style="padding: 6px 7px;" name="dv_chzn_{$j }_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}','dv_accountset')" onmouseover="cmb_limouseover(event,'{$fldname}','dv_accountset')"> {$item}</li>
                	        {/foreach}
                          <li class="" name="li_chzn_{$fldname}" style="padding: 6px 7px;">{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                			 </ul>
                	    </div>
                    </div>
                  </li>
                  <!--yyx 2015-4-21 end-->
                  <li style="clear: both;margin-top: 22px;">
                    <span class="pad">
                        {'AFTERCONVERTINGMODIFYTHEOWNER'|@getFixedLabel}
                        <input fieldonly='' type="hidden" tabindex="" name="userid" id ="userid" value="{$userid}" />
                        <input type="text" id="user_name" name="user_name" value="{$user_name}"/>
                    </span>
                        <a class="icon-homeimg icon-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="window.open('index.php?module=Users&action=Popup','test','width=840,height=602,resizable=1,scrollbars=1,top=150,left=200');"></a>
                        <a class="icon-homeimg icon-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_user()"></a>
                    
                  </li>
        				  <li>
          					<span class="pad">
          						{'AFTERRELEASINGTHEALLOCATEDHIGNSEAS'|@getFixedLabel}
          						<input fieldonly='' type="hidden" tabindex="" name="allotuserid" id ="allotuserid" value="{$allotuser_id}" />
                      <input type="text" id="allotuser_name" name="allotuser_name" value="{$allotuser_name}"/>
          					</span>
          					  <a class="icon-homeimg icon-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="window.open('index.php?module=Users&action=Popup&allotaccount=true','test','width=840,height=602,resizable=1,scrollbars=1,top=150,left=200');"></a>
                      <a class="icon-homeimg icon-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_publicaccount()"></a>
        				  </li>
                  <li><span class="pad colorC0">{'EXPLAIN'|@getFixedLabel}：{'PRESSCUSTOMER'|@getFixedLabel}</span></li> 
                  <li><span class="pad colorC0" style="display: block;">{'MAINFEATURES'|@getFixedLabel}：{'CUSTOMERSALESFULFILLED'|@getFixedLabel}</span></li>
                  <li><span class="pad colorC0">{'PUBLICCUSTOMERPRIVILEGEINCLUDE'|@getFixedLabel}</span></li>
               </ul>
             </div>
              <div class="PublicseaSet">
                <ul>
                  <li class="PublicTitle">{'AUTORECOVERPUBLICCUST'|@getFixedLabel}</li>
                  <li class="paddT5">
                     <span class="pad">{'DATEPUBLICCUSTOMER'|@getFixedLabel}
                     &nbsp;<input type="text" name="days" style="width:50px;" value="{$DAYS}"/>&nbsp;
                     {'DAYSNOTCREATE'|@getFixedLabel}
                      <select  name="bills">
                        {foreach item=data key=index from=$DATA}
                        {if $BILLS eq $index}
                        <option value="{$index}" selected>{$data}</option>
                        {else}
                        <option value="{$index}">{$data}</option>
                        {/if}
                        {/foreach}
                      </select>
                     </span>
                  </li>
               </ul>
             </div>
                <!-- 
                    reason 公海客户限制改进
                    by andrew
                    date 20140825
                 -->
             <div class="PublicseaSet">
               <ul>
                  <li class="PublicTitle">{'maximumnumberofhighseascustomers'|@getFixedLabel}</li>
                  <li class="paddT10" style="padding-left:10px;"><input type="radio" style="margin-top: -3px;" class="inputBornone" name="astricttype" {if $ASTRICTTYPE eq 1} checked="checked" {/if} value="1" onclick="changeastricttype('1','')"/>
                     {'Accordingtotheusercontrol'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'Eachuser'|@getFixedLabel}&nbsp;
                     <input id='select_user_ASTRICTTYPE' type="text"  {if $ASTRICTTYPE eq 2}disabled = true {/if} name="count" style="width:50px;" value="{$COUNT}"/>
                  </li>
                  <li style="padding-left:10px;">
                     <input type="radio" style="margin-top: -3px;" class="inputBornone" name="astricttype" {if $ASTRICTTYPE eq 2} checked="checked" {/if} value="2" onclick="changeastricttype('2',{if $COUNT eq ''}0{else}{$COUNT}{/if})"/> {'Accordingtotherolcontrol'|@getFixedLabel}
                  </li>
                  <!--li><span class="pad colorC0">{"EXPLAIN"|@getFixedLabel}：{'LIMITUSERPUBLICCUST'|@getFixedLabel}</span></li-->
                  <!--li><strong>{'USERMAXNUMCUSTOMER'|@getFixedLabel}</strong></li-->
                  <li  class="paddT10" id='select_role_ASTRICTTYPE' {if $ASTRICTTYPE eq 1}style="display:none;padding-left:10px;"{else}style="padding-left:10px;"{/if} >{$ROLETREE}</li>
               </ul>
             </div>
            <div>
                <table width="100%" class="marT10 borderALL" cellspacing="0" cellpadding="0" border="0">
                  <tr>
                    <td class="PublicTitle" width="100%" colspan="3"> {'SETPUBLICCUSTOMERADMIN'|@getFixedLabel} </td>
                  </tr>
                  <tr>
                    <td colspan="2" class="pad paddT10">{'AVAILABLEMEMBER'|@getFixedLabel} </td>
                    <td class="pad paddT5">{'MEMBERSSELECTED'|@getFixedLabel}</td>
                  </tr>
                  <tr>
                    <td width="40%" class="pad paddT10">
                       <select class="crmFormList" size="10" multiple="" id='AllUsersAdmin' name="AllUsersAdmin" ondblclick="addColumn('AllUsersAdmin','selectedAdminColumns')"></select>
                    </td>
                    <td align="center">
                        <a class="icon-newhomearr icon-mright" href="javascript:;" title="{'MOVERIGHT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('AllUsersAdmin','selectedAdminColumns');" style="margin-left:-27px;"></a><br />
                        <a class="icon-newhomearr icon-mleft" href="javascript:;" title="{'MOVELEFT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('selectedAdminColumns','AllUsersAdmin')" style="margin-left:-27px;margin-top:15px;"></a>
                   </td>
                    <td width="40%" class="pad paddT10">
                        <select id="selectedAdminColumns" class="crmFormList" size="10" multiple="" name="selectedAdminColumns" ondblclick="addColumn('selectedAdminColumns','AllUsersAdmin')">
                        {foreach item=data key=index from=$ADMINACCOUNT}
                            {foreach item=item key=key from=$data} 
                                <option value="{$key}">{$item}</option>
                            {/foreach}                    
                        {/foreach}
                        </select>
                        <input type="hidden" name="selectedcolumnsforadmin"/>
                    </td>
                  </tr>
                   <tr>
                     <td colspan="3" class="pad paddT10">
                     <p class="colorC0">{'EXPLAIN'|@getFixedLabel}：{'EXTENDPUBLICCUSTOMER'|@getFixedLabel}</p>
                     <p class="colorRed paddT10">{'NOTE'|@getFixedLabel}：{'ADMINATUOPRIVLEGE'|@getFixedLabel}</p>
                     <td>
                </tr>
                <tr><td>&nbsp;</td></tr>
                </table>


				<table width="100%" class="marT10 borderALL" cellspacing="0" cellpadding="0" border="0">
					<tr>
						<td class="PublicTitle" width="100%" colspan="3">{'PUBLICUSERSET'|@getFixedLabel}</td>
					</tr>
					<tr>
						<td colspan="3" class="pad paddT10">
							<div id='view_scope'>
							&nbsp;<input class="templateprintRadio" type="radio" style="margin-top: -4px;" {if $USERSACCOUNT_TYPE eq 'all'}checked="" {/if} value="all" name="radioUser" onclick="CustomScope.setAllUser();">&nbsp;{'ALLTHEUSERS'|@getFixedLabel}
							&nbsp;&nbsp;&nbsp;<input class="templateprintRadio" style="margin-top: -4px;" {if $USERSACCOUNT_TYPE eq 'group'}checked="" {/if} type="radio" undefined="" onclick="CustomScope.setScopeGroup('{$USERSACCOUNT}')" value="group" name="radioUser">&nbsp;{'SETBYDEPARTMENT'|@getFixedLabel}
							&nbsp;&nbsp;&nbsp;<input class="templateprintRadio" style="margin-top: -4px;" {if $USERSACCOUNT_TYPE eq 'user'}checked="" {/if} type="radio" undefined="" onclick="CustomScope.setScopeUser('{$USERSACCOUNT}');" value="user" name="radioUser">&nbsp;{'SETBYUSERS'|@getFixedLabel}{'APPLICABLESCOPE'|@getFixedLabel}
							<input id="customscope_type" class="templateprintuser" type="hidden" value="{$USERSACCOUNT_TYPE}" name="customscope_type">
							<input id="customscope_ids" class="templateprintuser" type="hidden" value="{$USERSACCOUNT}" name="customscope_ids">
							</div>
						</td>
					</tr>
					<tr>
						<td colspan="3" class="pad paddT10">
						<p class="colorC0">{'EXPLAIN'|@getFixedLabel}：{'USERSPUBLICCUSTOMER'|@getFixedLabel}</p>
						<p class="colorRed paddT10">{'NOTE'|@getFixedLabel}：{'ADMINATUOPRIVLEGE'|@getFixedLabel}</p>
						<td>
					</tr>
					<tr><td>&nbsp;</td></tr>
				</table>
        </div>

        </div>         
                 
      </div>
      </form>		
    </td>
  </tr>
</table>
</div>
<!--中间 end-->
<script type="text/javascript">
var userIdArr=new Array({$USERIDSTR});
var userNameArr=new Array({$USERNAMESTR});
var userIdArrUSER=new Array({$USERIDSTRUSERS});
var userNameArrUSER=new Array({$USERNAMESTRUSERS});
var userlabel='{'LBL_USERS'|@getFixedLabel}';
constructSelectOptions(userIdArr,userNameArr);//管理员赋值
//constructSelectOptionsUsers(userIdArrUSER,userNameArrUSER);//用户赋值下拉框
function constructSelectOptions(idArr,nameArr){ldelim}
	var form=document.forms['EditView'];
	//var nowNamePrefix=userlabel+"::";
    var nowNamePrefix=userlabel;
	if(nameArr.length>0){ldelim}
		constructedOptionValue = idArr;
		constructedOptionName = nameArr;
		for(var i=0;i<constructedOptionName.length;i++){ldelim}
			//var nowName=userlabel+"::"+constructedOptionName[i];
            var nowName=constructedOptionName[i];
			var nowId=constructedOptionValue[i];
			form.AllUsersAdmin.options[i]=new Option(nowName,nowId);
			//form.AllUsers.options[i]=new Option(nowName,nowId);
		{rdelim}
	{rdelim}
	
{rdelim}
//用户赋值
function constructSelectOptionsUsers(idArr,nameArr){ldelim}
	var form=document.forms['EditView'];
	//var nowNamePrefix=userlabel+"::";
	var nowNamePrefix=userlabel;
	if(nameArr.length>0){ldelim}
		constructedOptionValue = idArr;
		constructedOptionName = nameArr;
		for(var i=0;i<constructedOptionName.length;i++){ldelim}
			//var nowName=userlabel+"::"+constructedOptionName[i];
            var nowName=constructedOptionName[i];
			var nowId=constructedOptionValue[i];
			//form.AllUsersAdmin.options[i]=new Option(nowName,nowId);
			form.AllUsers.options[i]=new Option(nowName,nowId);
		{rdelim}
	{rdelim}
	
{rdelim}
function dataProfileChange(obj)
{ldelim}
    if(obj.checked)
    {ldelim}
        obj.value=0;
    {rdelim}
    else
    {ldelim}
        obj.value=1;
    {rdelim}
{rdelim}
function getProfileChange(obj)
{ldelim}
    if(obj.checked)
    {ldelim}
        obj.value=0;
    {rdelim}
    else
    {ldelim}
        obj.value=1;
    {rdelim}
{rdelim}

function publicStatusChange(obj)
{ldelim}
    var form=document.forms['EditView'];
     if (obj.checked)
     {ldelim}
        form.dataProfile.disabled=false;
        form.getProfile.disabled=false;
        form.wheathershow.disabled=false;
        form.dataProfile.checked=true;	
        //form.getProfile.checked=true;0013772: 控制面板--公海参数：公海设置，当勾选启用公海客户时，希望默认不勾选公海未分配客户不允许领取。
        form.wheathershow.checked=true;
        form.dataProfile.value=0;
        form.getProfile.value=0;
        form.wheathershow.value=0;
     {rdelim}
     else
     {ldelim}
        form.dataProfile.checked=false;	
        form.getProfile.checked=false;
        form.wheathershow.checked=false;
        form.dataProfile.disabled=true;
        form.getProfile.disabled=true;
        form.wheathershow.disabled=true;
        form.dataProfile.value=1;
        form.getProfile.value=1;
        form.wheathershow.value=1;
     {rdelim}
{rdelim}
/*
function addColumn(type){ldelim}
if(type){ldelim}
	var obj=getObj('AllUsers');
	var selectobj=getObj('selectedColumns');
{rdelim}
else{ldelim}
	var obj=getObj('AllUsersAdmin');
	var selectobj=getObj('selectedAdminColumns');
{rdelim}
	for (i=0;i<selectobj.length;i++) 
            {ldelim}
                selectobj.options[i].selected=false
            {rdelim}

            for (i=0;i<obj.length;i++) 
            {ldelim}
                if (obj.options[i].selected==true) 
                {ldelim}            	
                	var rowFound=false;
                	var existingObj=null;
                    for (j=0;j<selectobj.length;j++) 
                    {ldelim}
                        if (selectobj.options[j].value==obj.options[i].value) 
                        {ldelim}
                            rowFound=true
                            existingObj=selectobj.options[j]
                            break
                        {rdelim}
                    {rdelim}

                    if (rowFound!=true) 
                    {ldelim}
                        var newColObj=document.createElement("OPTION")
                        newColObj.value=obj.options[i].value
                        if (browser_ie) newColObj.innerText=obj.options[i].innerText
                        else if (browser_nn4 || browser_nn6) newColObj.text=obj.options[i].text
                        selectobj.appendChild(newColObj)
                        obj.options[i].selected=false
                        newColObj.selected=true
                        rowFound=false
                    {rdelim} 
                    else 
                    {ldelim}
                        if(existingObj != null) existingObj.selected=true
                    {rdelim}
                {rdelim}
            {rdelim}
{rdelim}
*/
function delColumn(type){ldelim}
	if(type){ldelim}
	var selectobj=getObj('selectedColumns');
	{rdelim}
	else{ldelim}
	var selectobj=getObj('selectedAdminColumns');
	{rdelim}
	for (i=selectobj.options.length;i>0;i--) 
	{ldelim}
		if (selectobj.options.selectedIndex>=0)
	selectobj.remove(selectobj.options.selectedIndex)
	{rdelim}
{rdelim}
function clear_user()
{ldelim}
    var form=document.forms['EditView'];
    form.userid.value='';
    form.user_name.value='';
{rdelim}
function clear_publicaccount()
{ldelim}
    var form=document.forms['EditView'];
    form.allotuserid.value='';
    form.allotuser_name.value='';
{rdelim}
function validate(){ldelim}
    var form=document.forms['EditView'];
    if(form.status!=undefined && form.status.checked){ldelim}
    form.isset.value=0;
    var expre=/^[0-9]*[1-9][0-9]*$/;
    if(form.days!=undefined && form.days.value !=''){ldelim}
        if(!(expre.test(trim(form.days.value)))){ldelim}
            var confirm_str = arrJsPopLabel['DAYSNUMONLYINT'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            form.days.focus();
            return false;
        {rdelim}
    {rdelim}
    else{ldelim}
        var confirm_str = arrJsPopLabel['DAYSNUMONLYINT'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        form.days.focus();
        return false;
    {rdelim}
    //alert(form.astricttype[1].checked);
    if(form.count!=undefined && form.count.value !=''&&form.astricttype[1].checked!=true){ldelim}
    //alert(1);
        if(!(expre.test(trim(form.count.value)))){ldelim}
            var confirm_str = arrJsPopLabel['NUMONLYINT'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            form.count.focus();
            return false;
        {rdelim}
    {rdelim}
    else if(form.astricttype[1].checked!=true){ldelim}
        var confirm_str = arrJsPopLabel['NUMONLYINT'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        form.count.focus();
        return false;
    {rdelim}
    {rdelim}
    else{ldelim}
        form.isset.value=1;
    {rdelim}
    
    var selectedcolumnsforadmin=getObj('selectedcolumnsforadmin');
    var selectedcolumnsforuser=getObj('selectedcolumnsforuser');
    for(var i=0;i<form.selectedAdminColumns.length;i++){ldelim}
        selectedcolumnsforadmin.value +=form.selectedAdminColumns.options[i].value+",";
    {rdelim}
    for(var i=0; i<form.selectedColumns.length;i++){ldelim}
        selectedcolumnsforuser.value +=form.selectedColumns.options[i].value+",";
    {rdelim}
        var confirm_str = arrJsPopLabel['CUSTPARAMETERSAVEDSUCCESS'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
    return true;
{rdelim}
</script>