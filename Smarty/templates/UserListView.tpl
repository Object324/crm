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
<!--中间-->
<div class="List3Box">
    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
	{if $BLOCKIDSETTING neq '' && $FIELDIDSETTING neq ''}
    <td class="TdLeft" valign="top" style="width:200px;">
        {include file='SetMenuNew.tpl'}
    </td>
	{else}
		<link href="themes/softed/Control.css" rel="stylesheet" type="text/css" />
	{/if}
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
    <form action="index.php" method="post" name="EditView" id="form" onsubmit="puyoungJS_DialogBox.block();">
        <input type='hidden' name='module' value='Users'/>
        <input type='hidden' name='action' value='EditView'/>
        <input type='hidden' name='return_action' value='ListView'/>
        <input type='hidden' name='return_module' value='Users'/>
        <input type='hidden' name='parenttab' value={$PARENTTAB}/>
        <input type="hidden" name="blockidsetting" id="blockidsetting" value="{$BLOCKIDSETTING}"/>
        <input type="hidden" name="fieldidsetting" id="fieldidsetting" value="{$FIELDIDSETTING}"/>
      <div class="DivCR">
		{if $BLOCKIDSETTING neq '' && $FIELDIDSETTING neq ''}
         <div class="ControlDiv1">
            <span class="Url fontbold">{'CONTROLPANEL'|@getFixedLabel} &gt; {'LBL_USERS'|@getFixedLabel}
                <font>（{'LBL_USER_DESCRIPTION'|@getFixedLabel}）</font>
            </span>
        </div>
		{/if}
<!--PROT202  用户管理改进  zyh 20150424-->
        <div class="ControlDiv2">
            <div class="F_l">
                <div style="color:#999;">
                    {$REGISTERINFO}
                </div>
            </div>
            <div class="F_r"> 
                {if $TESTFILE eq 1}
                    {if $BLOCKIDSETTING eq '' && $FIELDIDSETTING eq ''}
                        <input type="button" name="createuserbtn" value="{'ADDLESSIONPLAN'|@getFixedLabel}" class="createauto" onclick="listviewbutton_click(this,'Users','Create',event);return false;"/>
                    {else}                                                                
                        <input type="button" name="createuserbtn" value="{'ADDLESSIONPLAN'|@getFixedLabel}" class="createauto" onclick='createuser_click(this);'/>
                    {/if}
					{if $ISADMIN eq 'on'}
						<input class="createauto" type="button" value="{'LBL_PAGE_SET'|@getFixedLabel}" onclick="listviewbutton_click(this,'Users','Settings',event);return false;" name="pagesetup" />
					{/if}
                {/if}
            </div>
        </div>
        <div id='usertitleDiv' style="padding:10px 12px 0px 10px;">
                <ul class="userSearch"  style="border:1px solid #dadada;border-bottom:0px;" >
                    <li><span>{'Find_field'|@getFixedLabel}</span>
                        <select name="search_field" id="bas_searchfield" onchange="selectchange(this);">
                            {foreach key=fld item=head from=$XLLB name=headerforeach}
                                <option value="{$fld}" {if $UserSeach.fieldname eq $fld} selected {/if}>{$head}</option>
                            {/foreach}
                        </select>
                    </li>
                    <li><span>{'Find_Keyword'|@getFixedLabel}</span>
						<!-- 账号 -->
						<input type="text" id="user_name_value" style="display:{if $UserSeach.fieldname eq 'user_name'}{else}none{/if};" name="user_name_value" value="{$UserSeach.fieldvalue}" onkeyup="searchUser_keyup(event);" />
						<!-- 姓名 -->
						<input type="text" style="display:{if $UserSeach.fieldname eq 'last_name'}{else}none{/if};" id="last_name_value" name="last_name_value" value="{$UserSeach.fieldvalue}" onkeyup="searchUser_keyup(event);" />
						<!-- 角色权限 -->
						<select id="profileid_value" style="display:{if $UserSeach.fieldname eq 'profileid'}{else}none{/if};" name="profileid_value" style="">
							<option value="Y" {if $UserSeach.fieldname eq 'Y'} selected {/if}>{'ISNULL'|@getFixedLabel}</option>
							<option value="N" {if $UserSeach.fieldname eq 'N'} selected {/if}>{'ISNOTNULL'|@getFixedLabel}</option>
							{foreach key=profileid item=profilename from=$PROFILEINFO}
								<option value="{$profileid}" {if $UserSeach.fieldname eq $profileid} selected {/if}>{$profilename}</option>
							{/foreach}
						</select>
						<!-- Email -->
						<input type="text" style="display:{if $UserSeach.fieldname eq 'email1'}{else}none{/if};" id="email1_value" name="email1_value" value="{$UserSeach.fieldvalue}" onkeyup="searchUser_keyup(event);" />
						<!-- 手机 -->
						<input type="text" style="display:{if $UserSeach.fieldname eq 'phone_mobile'}{else}none{/if};" id="phone_mobile_value" name="phone_mobile_value" value="{$UserSeach.fieldvalue}" onkeyup="searchUser_keyup(event);" />
						<!-- 职位级别 -->
						<select id="userlevel_value" style="display:{if $UserSeach.fieldname eq 'userlevele'}{else}none{/if};" name="userlevel_value" style="">
							{foreach key=level item=name from=$USERLEVEL}
								<option value="{$level}" {if $UserSeach.fieldname eq $level} selected {/if}>{$level}</option>
							{/foreach}
						</select>
						<!-- 系统管理员 -->
						<select id="is_admin_value" style="display:{if $UserSeach.fieldname eq 'is_admin'}{else}none{/if};" name="is_admin_value" style="">
							<option value="on" {if $UserSeach.fieldname eq 'on'} selected {/if}>{'YES'|@getFixedLabel}</option>
							<option value="off" {if $UserSeach.fieldname eq 'off'} selected {/if}>{'NO'|@getFixedLabel}</option>
						</select>
						<!-- 状态 -->
						<select id="status_value" style="display:{if $UserSeach.fieldname eq 'status'}{else}none{/if};" name="status_value" style="">
							<option value="Active" {if $UserSeach.fieldname eq 'Active'} selected {/if}>{'ACTIVATE'|@getFixedLabel}</option>
							<option value="Inactive" {if $UserSeach.fieldname eq 'Inactive'} selected {/if}>{'INACTIVATE'|@getFixedLabel}</option>
						</select>
                        <!--<input type="text" id="i_text" name="i_text" value="{$UserSeach.fieldvalue}" onkeyup="searchUser_keyup(event);" />
                        <select name="s_text" id="s_text" style="display:none;"></select> -->
                    </li>
                  
                    
                    <li>
                    <div class="ControlDiv2" style="height:auto;">
                    <input name="searchuserbtn" type="button" class="createauto" onClick="callSearch();" value="{'FINDNOW'|@getFixedLabel}"/>
                    </div>
                    </li>
                    
					
                    <!-- <li style="float:right;">
                        {if $TESTFILE eq 1}
                         <input type="button" name="createuserbtn" value="{'ADDLESSIONPLAN'|@getFixedLabel}" class="createauto" onclick='createuser_click(this);'/>
                         {/if}
                    </li> -->
                </ul>
        </div>

        <div id="ListViewContents" class="pad10" >
            {include file="UserListViewContents.tpl"}
        </div>         
                         
      </div>
      </form>       
    </td>
  </tr>
</table>
</div>
<!--中间 end-->
<div id="ShowSetUeryScopdiv" class="D_pop_box LdPopWidth400px" style="display:none;position:absolute;left:33%;top:35%;width:" ></div>
<div id="tempdiv" style="display:block;position:absolute;left:350px;top:200px;"></div>
{literal}
<script>
function getListViewEntries_js(module,url){
    if(module == 'Users'){
		if(document.getElementById('blockidsetting') != undefined){
			url += '&blockidsetting='+document.getElementById('blockidsetting').value;
		}
		if(document.getElementById('fieldidsetting') != undefined){
			url += '&fieldidsetting='+document.getElementById('fieldidsetting').value;
		}
        new Ajax.Request('index.php', {
                queue: {position: 'end', scope: 'command'},
                method: 'post',
                postBody: 'module=Users&action=UsersAjax&file=ListView&ajax=true&query_session=1&'+url,
                onComplete: function(response) {
                    $("ListViewContents").innerHTML= response.responseText;
                }
            }
        );
    }
    else{
        new Ajax.Request('index.php',{
                queue: {position: 'end', scope: 'command'},
                method: 'post',
                postBody: 'module=Users&action=UsersAjax&file=ListView&ajax=true&'+url,
                onComplete: function(response) {
                    $("ListViewContents").innerHTML= response.responseText;
                }
            }
        );
    }
}




 
/*
用户管理改进
PROT202
zyh
20150423
查找事件
加入session=1
*/
function callSearch(){
    var fieldname = document.getElementById('bas_searchfield');
    var blockidsetting = document.getElementById('blockidsetting');
    var fieldidsetting = document.getElementById('fieldidsetting');
	var searchname = fieldname.value + '_value';
	var searchvalue = ld('#'+searchname).val();
	//if(searchvalue != ''){
		var datafilter = 'module=Users&action=UsersAjax&file=ListView&ajax=true&query_session=1&query=true';
		datafilter += '&fieldname='+fieldname.value;
		datafilter += '&fieldvalue='+searchvalue;
		datafilter += '&blockidsetting='+blockidsetting.value;
		datafilter += '&fieldidsetting='+fieldidsetting.value;
		ld.ajax({
				url:'index.php',
				data:datafilter,
				type:'post',
				success:function(rest){
					document.getElementById('ListViewContents').innerHTML = rest;
			} 
		});	
	//} 
}

/*
用户管理改进
PROT202
zyh
20150423
查找字段下拉列表
*/
function selectchange(obj){
    if(obj.value == '') return false;
	var searchtext = ['user_name_value','last_name_value','profileid_value','email1_value','phone_mobile_value','userlevel_value','is_admin_value','status_value'];
	var searchname = obj.value + '_value';
	if(ld('#'+searchname) != undefined){
		for (var i=0;i<searchtext.length;i++){
			if(searchtext[i] == searchname){
				ld('#'+searchtext[i]).show();
			}else{
				ld('#'+searchtext[i]).hide();
			}
		}
		var searchvalue = ld('#'+searchname).val();
	}
    /*var st1 = document.getElementById('s_text');
    var st2 = document.getElementById('i_text');
    var selected = '';
        if(obj.value =='profileid' || obj.value=='is_admin' || obj.value=='status'|| obj.value=='userlevel'){
            st2.style.display="none";
            st1.style.display="";
			var datafilter = 'module=Users&action=UsersAjax&file=ListView&ajax=true&select='+obj.value;
			new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody: datafilter,
				onComplete: function(response) {
					if(rest == '') return false;
                    var rest = JSON.parse(response.responseText);
                    var selectarray = rest.selectarray;
                    st1.length=0;
					/* if(obj.value == 'profileid'){
                        if(st2.value == 'Y'){
							ld("#s_text").append( "<option value=\"Y\" selected>"+arrJsPopLabel['ISNULL']+"</option>" );
							ld("#s_text").append( "<option value=\"N\">"+arrJsPopLabel['ISNOTNULL']+"</option>" );
                        }else if(st2.value == 'N'){
                            ld("#s_text").append( "<option value=\"Y\">"+arrJsPopLabel['ISNULL']+"</option>" );
							ld("#s_text").append( "<option value=\"N\" selected>"+arrJsPopLabel['ISNOTNULL']+"</option>" );
                        }else{
                            ld("#s_text").append( "<option value=\"Y\">"+arrJsPopLabel['ISNULL']+"</option>" );
							ld("#s_text").append( "<option value=\"N\">"+arrJsPopLabel['ISNOTNULL']+"</option>" );
                        }
                    }*/
                    /*for(var i in selectarray){
						ld("#s_text").append( "<option value=\""+i+"\">"+selectarray[i]+"</option>" );
                    }
				}
			}
			);
        }else{
            st2.style.display="";
            st2.value = '';
            st1.style.display="none";
        }*/
}



/*
自动加载上次查找条件
zyh
20150428
*/
var hsh = document.getElementById('bas_searchfield');
if(hsh.value=='profileid' || hsh.value=='is_admin' || hsh.value=='status'){
    document.getElementById('bas_searchfield').onchange();   
}

function searchUser_keyup(event){
    var e = event || window.event;
    if(e.keyCode == 13){
        ld('#usertitleDiv ').find('input[name=searchuserbtn]').click();
    }
}
function createuser_click(obj){
    ld('form[name=EditView]').submit();
}
{/literal}
</script>