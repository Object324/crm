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
<link rel="stylesheet" href="{$CRMCOMMONURL}crmcommon/css/treeview/jquery.treeview.css" />
<script language="JAVASCRIPT" type="text/javascript" src="include/jquery/treeview/jquery.treeview.js"></script>

<style type="text/css">
{literal}
.ControlTable1 tr.Hoverbj:hover td a.list-group{color: #999;}
.ControlTable1 tr.Hoverbj:hover td{color: #999;}
{/literal}
</style>

<!--中间-->

<form action="index.php" method="post" name="newForm" id="form" onsubmit="puyoungJS_DialogBox.block();">
		<input type="hidden" name="module" value="Settings">
		<input type="hidden" name="action" value="createnewgroup">
		<input type="hidden" name="mode" value="create">
		<input type="hidden" name="parenttab" value="Settings">
        <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
        <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
      <div class="DivCR">       
		{if $AUTHTYPE eq 'no'}
			<div class="divButtons">
				<ul class="D_btn_box">
					<li class="D_anu_a D_menu_hova ">
						<a title="{'ADDLESSIONPLAN'|@getFixedLabel}" class="group_create" name="New">
							<b class="icon-homeimg icon-plus"></b>
							<span>{'ADDLESSIONPLAN'|@getFixedLabel}</span>
						</a>
					</li>
				</ul>
			</div>
		{/if}
			<table border="0" cellspacing="1" cellpadding="0" width="100%" class="listEntries fir-center">
				{$OUTPUT}
			</table>
      </div>
      </form>		

<!--中间 end-->


<div id="tempdiv" style="display:block;position:absolute;left:350px;top:200px;"></div>

<!-- 新增、编辑、复制部门信息 begin -->
<div id="addgroupdiv" class="D_pop_box LdPopWidth800px" style="position: absolute; z-index:9999; left: 250px; top: 150px;display: none;">
<div class="D_pop_tit">
	<strong class="D_ptita" id="groupOperation" edit="{'LBL_EDITGROUP'|@getFixedLabel}" add="{'NEWGROUP'|@getFixedLabel}">{'NEWGROUP'|@getFixedLabel}</strong>
    <a href="javascript:fninvshnew('addgroupdiv');puyoungJS_DialogBox.unblock();" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}">
    </a>
</div>
<div id="addgroupcontent">
	<table class="D_pop_bod" border="0" cellpadding="1" cellspacing="1">
		<tbody>
		<tr>
			<td nowrap="nowrap" class='DetailedTd1Label' width='20%' align='right'>
				&nbsp;<font color="red">*</font>&nbsp;
				{'GROUPNAME'|@getFixedLabel}
			</td>
			<td nowrap="nowrap" width='30%'>
				<input type="text" name='groupname' class="detailedViewTextBox" onblur="this.className='detailedViewTextBox'" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'"/>
				<input type="hidden" name='groupid' value=''/>
			</td>
			<td nowrap="nowrap" class='DetailedTd1Label' width='20%' align='right'>
				&nbsp;<font color="red">*</font>&nbsp;
				{'LBL_SUPEGROUP'|@getFixedLabel}
			</td>
			<td nowrap="nowrap" width='30%'>
				<div id="groupParent" style="display:block;">
				<input type="text" class="detailedViewTextBox" onblur="this.className='detailedViewTextBox'" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" style='width:75%;' id='addparentid_name' readonly='' />
				<input type="hidden" id='addparentid' value=''/>
				<input type="hidden" id='oldaddparentid' value=''/>
				<a class="icon-homeimg icon-select" href="javascript:;" tag='selectgroup' title="{'SELECT'|@getFixedLabel}"></a>
				<a class="icon-homeimg icon-clear" href="javascript:;" tag='clearselectgroup' title="{'CLEAR'|@getFixedLabel}"></a>
				</div>
				<div id="groupParentDetail" style="display:none;">
					<span id="groupDetailName"></span>
					<input type="hidden" id='addparentid' value=''/>
					<input type="hidden" id='oldaddparentid' value=''/>
				</div>
			</td>
		</tr>
		<tr>
			<td nowrap="nowrap" class='DetailedTd1Label' width='20%' align='right'>
				&nbsp;{'DESCRIPTION'|@getFixedLabel}
			</td>
			<td nowrap="nowrap" colspan='3'>
				<textarea class="detailedViewTextBox" onblur="this.className='detailedViewTextBox'" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" name='description'></textarea>
			</td>
		</tr>
	</tbody></table>
</div>
<div class="D_pbtn">
	<input class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" type="button"><span>&nbsp;</span>
    <input class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" type="button" onclick="fninvshnew('addgroupdiv');puyoungJS_DialogBox.unblock();">
</div>
</div>
<!-- 新增、编辑、复制部门信息 end -->

<!-- 选择部门 begin -->
<div id="selectgroupdiv" class="D_pop_box LdPopWidth500px" style="position: absolute; z-index:10002; left: 350px; top: 30%;display: none;">
<div class="D_pop_tit">
	<strong class="D_ptita">{'SELECT'|@getFixedLabel}{'Sector'|@getFixedLabel}</strong>
    <a href="javascript:hide('selectgroupdiv');" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}">
    </a>
</div>
<div id="selectgroupcontent" style='padding:10px;'>
	{$TREEHTML}
</div>                                                                                                                                                                                   
</div>
<!-- 选择部门 end -->

<!-- 删除部门 begin -->
<div id="delgroupdiv" class="D_pop_box LdPopWidth400px" style="position: absolute; z-index:9999; left: 350px; top: 120px;display: none;">
<div class="D_pop_tit">
	<strong class="D_ptita">{'DELETE'|@getFixedLabel}{'Sector'|@getFixedLabel}</strong>
    <a href="javascript:fninvshnew('delgroupdiv');puyoungJS_DialogBox.unblock();" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}">
    </a>
</div>
<div id="delgroupcontent" style='padding:10px;'>
	<table class="D_pop_bod" border="0" cellpadding="1" cellspacing="1">
		<tbody><tr>
			<td nowrap="nowrap" class='DetailedTd1Label' width='30%' align='right'>
				&nbsp;{'TODELETEGROUP'|@getFixedLabel}
			</td>
			<td>
				<span id='delete_groupname'></span>
				<input type="hidden" id='delgroupid' value=''/>
			</td>
		</tr><tr>
			<td nowrap="nowrap" class='DetailedTd1Label' align='right'>
				&nbsp;{'LBL_USERTOTRANSFER'|@getFixedLabel}
			</td>
			<td nowrap="nowrap">
				<input type="text" class="detailedViewTextBox" onblur="this.className='detailedViewTextBox'" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" style='width:150px;' id='delusertogroup_name'/>
				<input type="hidden" id='delusertogroup' value=''/>
				<input type="hidden" id='olddelusertogroup' value=''/>
				<a class="icon-homeimg icon-select" href="javascript:;" tag='delusertogroup' title="{'SELECT'|@getFixedLabel}"></a>
				<a class="icon-homeimg icon-clear" href="javascript:;" tag='cleardelusertogroup' title="{'CLEAR'|@getFixedLabel}"></a>
			</td>
		</tr>
		<tr id='dellowertogroupTr'>
			<td nowrap="nowrap" class='DetailedTd1Label' align='right'>
				&nbsp;{'LBL_GROUPOTRANSFER'|@getFixedLabel}
			</td>
			<td nowrap="nowrap">
				<input type="text" class="detailedViewTextBox" onblur="this.className='detailedViewTextBox'" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" style='width:150px;' id='dellowertogroup_name'/>
				<input type="hidden" id='dellowertogroup' value=''/>
				<input type="hidden" id='olddellowertogroup' value=''/>
				<a class="icon-homeimg icon-select" href="javascript:;" tag='dellowertogroup' title="{'SELECT'|@getFixedLabel}"></a>
				<a class="icon-homeimg icon-clear" href="javascript:;" tag='cleardellowertogroup' title="{'CLEAR'|@getFixedLabel}"></a>
			</td>
		</tr></tbody>
	</table>
</div>
<div class="D_pbtn">
	<input class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" type="button"><span>&nbsp;</span>
    <input class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" type="button" onclick="fninvshnew('delgroupdiv');puyoungJS_DialogBox.unblock();">
</div>
</div>
<!-- 删除部门 end -->


<!-- 查看成员 begin -->
<div id="userviewdiv" class="D_pop_box LdPopWidth600px" style="position: absolute; z-index:10001; left: 350px; top: 120px;display: none;">
<div class="D_pop_tit">
	<strong class="D_ptita">{'SETMEMBERS'|@getFixedLabel}</strong>
    <a href="javascript:fninvshnew('userviewdiv');puyoungJS_DialogBox.unblock();" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}">
    </a>
</div>




<div id="userviewcontent" style='text-align:center;'>

		<table class="D_pop_bod" width="100%"  border="0" cellspacing="1" cellpadding="1">
			<tr>
				<td  width="15%" align="left"><font color="red">*</font><strong>{'GROUPNAME'|@getFixedLabel}</strong></td>
				<td   align="left"><span id="view_groupname"></span></td>
			</tr>
			<tr>
				<td  align="left"><strong>{'DESCRIPTION'|@getFixedLabel}</strong></td>
				<td   colspan="3" align="left"><span id="view_groupdesc"></span></td>
			</tr>
		</table>

	<table class="D_pop_bod D_pop_bod_line" border="0" cellpadding="1" cellspacing="0">
        <tr>
            <td colspan="2" align="left"><b>{'AVAILABLEMEMBER'|@getFixedLabel}</b></td>
            <td colspan="2" align="left"><b>{'MEMBERSSELECTED'|@getFixedLabel}</b></td>
        </tr>
        <tr>
            <td colspan="2" align="left"><input style="color: #999;width:198px;" class="proName" type="text" onkeyup="clickSelectMember(this,'AssmablyList')" value="{'PLEASEINPUTYOUWANTTOFINDTHEUSER'|@getFixedLabel}" onblur="return clickOnBlurMember(this)" onfocus="return clickOnFoucusMember(this)" name="allmember" /></td>
            <td colspan="2" align="left"><input style="color: #999;width:198px;" class="proName" type="text" onkeyup="clickSelectMember(this,'selectedAssmablyColumns')" value="{'PLEASEINPUTYOUWANTTOFINDTHEUSER'|@getFixedLabel}" onblur="return clickOnBlurMember(this)" onfocus="return clickOnFoucusMember(this)" name="allmember" /></td>
        </tr>
        <tr>
		  <td width="200" style="padding-top: 10px;">
			<input type="hidden" value="" id="AssmablyColumnsString" name="AssmablyColumnsString">
			<select style="overflow:auto; height: 180px;width:200px;border:1px solid #666666;font-family:Arial, Helvetica, sans-serif;font-size:12px;" class="crmFormList" name="AssmablyList" id="AssmablyList" multiple="" ondblclick="addColumn('AssmablyList','selectedAssmablyColumns')"><!--ondblclick="addColumn();-->
				{foreach key=User_Key item=User_value from=$Merge_SmOwner}
                    {foreach key=User_id item=User_name from=$User_value}
							<option value="{$User_Key}">{$User_id }</option>
                    {/foreach}
                {/foreach}
			</select>
			<input type="hidden" id="userviewid">
		  </td>
		  <td width="50" style="padding-top: 10px;">
			<a class="icon-newhomearr icon-mright" href="javascript:;" onclick="copySelectedOptionsSettingModule('AssmablyList','selectedAssmablyColumns');"title="{'MOVERIGHT'|@getFIxedLabel}"></a>
			<a class="icon-newhomearr icon-mleft" style="margin-top:15px;" href="javascript:;" onclick="copySelectedOptionsSettingModule('selectedAssmablyColumns','AssmablyList');" title="{'MOVELEFT'|@getFIxedLabel}"></a>
		  </td>
		  <td width="200" style="padding-top: 10px;">
			<input type="hidden" value="" id="selectedAssmablyColumnsString" name="selectedAssmablyColumnsString">
			<select size="11" style="overflow:auto; height: 180px;width:200px;border:1px solid #666666;font-family:Arial, Helvetica, sans-serif;font-size:12px;" class="crmFormList" name="selectedAssmablyColumns" id="selectedAssmablyColumns" multiple="" ondblclick="addColumn('selectedAssmablyColumns','AssmablyList')">
				{foreach key=User_id item=User_name from=$RoleUserArr}
					<option value="{$User_id}">{$User_name}</option>
                {/foreach}
			</select>
			
		  </td>
		  <td width="50" style="padding-top: 10px;">
			<a class="icon-newhomearr icon-mup" href="javascript:;" onclick="ModuleDetailmoveUp('selectedAssmablyColumns');" title="{'MOVEUP'|@getFIxedLabel}"></a>
			<a class="icon-newhomearr icon-mdown" style="margin-top:15px;" href="javascript:;" onclick="ProductDetailmoveDown('selectedAssmablyColumns');" title="{'MOVEDOWN'|@getFIxedLabel}"></a>
		  </td>
	   </tr>
	</table>
</div>
<div class="D_pbtn">
	<input class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" type="button"><span>&nbsp;</span>
    <input class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" type="button" onclick="fninvshnew('userviewdiv');puyoungJS_DialogBox.unblock();">
</div>
</div>
<!-- 查看成员 end -->

<script>
var allmember= "{'PLEASEINPUTYOUWANTTOFINDTHEUSER'|@getFixedLabel}";
var lbl_groupname = "{'GROUPNAME'|@getFixedLabel}";
var parentgroup = '上级部门';
var lbl_delusertogroup = '{"LBL_USERTOTRANSFER"|@getFixedLabel}';
var lbl_dellowertogroup = '{"LBL_GROUPOTRANSFER"|@getFixedLabel}';
var issubmit = 1;var usercombo = '{$USERCOMBO}';
var userobj = eval('('+ usercombo +')')?eval('('+ usercombo +')'):JSON.parse(usercombo);
{literal}
ld(function(){
	ld('.group_create').on('click',function(){//新增
		var urlfilter = {'mode':'create'};
		ShowGroupView(urlfilter,function(){
			ld('#groupOperation').html(arrJsPopLabel.NEWGROUP);
			ld('#addgroupdiv input[name=groupid]').val('');
			ld('#addgroupdiv input[name=groupname]').val('');
			ld('#addparentid').val('');
			ld('#oldaddparentid').val('');
			ld('#addparentid_name').val('');
			ld('#addgroupdiv textarea[name=description]').val('');
			ld('#addgroupdiv .D_pop_tit .D_ptita').html(ld('#addgroupdiv .D_pop_tit .D_ptita').attr('add'));
		});
		//新增部门  上级部门选择框显示
		ld("#groupParentDetail").hide();
		ld("#groupParent").show();
	});
	ld('.listEntries a[btn=addBtn]').on('click',function(){//新增下级
		var urlfilter = {'mode':'create'};
		var obj = ld(this);
		ShowGroupView(urlfilter,function(){
			var groupname = ld(obj).parent().parent().find('td:eq(1)').attr('groupname');
			ld('#addparentid').val(ld(obj).attr('record'));
			ld('#addparentid_name').val(groupname);
			ld('#addgroupdiv input[name=groupid]').val('');
			ld('#addgroupdiv input[name=groupname]').val('');
			ld('#addgroupdiv input[name=groupname]').focus();
			ld('#addgroupdiv .D_pop_tit .D_ptita').html(ld('#addgroupdiv .D_pop_tit .D_ptita').attr('add'));
		});
	});
	ld('.listEntries a[btn=editBtn]').on('click',function(){//编辑
		var urlfilter = {'mode':'edit'};
		var obj = ld(this);
		ShowGroupView(urlfilter,function(){
			var groupname = ld(obj).parent().parent().find('td:eq(1)').attr('groupname');
			var parentid = ld(obj).parent().parent().find('td:eq(1)').attr('parentid');
			var parentname = ld(obj).parent().parent().find('td:eq(1)').attr('parentname');
			var descri = ld(obj).parent().parent().find('td:eq(1)').attr('descri');
			ld('#addgroupdiv input[name=groupid]').val(ld(obj).attr('record'));
			ld('#addgroupdiv input[name=groupname]').val(groupname);
			ld('#addgroupdiv input[name=groupname]').focus();
			ld('#groupOperation').html(arrJsPopLabel.EDITGROUP);
			if(parentid < 0){
				ld("#groupParentDetail").show();
				ld("#groupParent").hide();
				ld('#groupDetailName').html(parentname);
			}
			else{
				ld("#groupParentDetail").hide();
				ld("#groupParent").show();
			}
			ld('#addparentid').val(parentid);
			ld('#oldaddparentid').val(ld(obj).attr('record'));
			ld('#addparentid_name').val(parentname);
			ld('#addgroupdiv .D_pop_tit .D_ptita').html(ld('#addgroupdiv .D_pop_tit .D_ptita').attr('edit'));
			ld('#addgroupdiv textarea[name=description]').val(descri);
		});
	});
	ld('.listEntries a[btn=copyBtn]').on('click',function(){//复制
		var urlfilter = {'mode':'copy'};
		var obj = ld(this);
		ShowGroupView(urlfilter,function(){
			var groupname = ld(obj).parent().parent().find('td:eq(1)').attr('groupname');
			var parentid = ld(obj).parent().parent().find('td:eq(1)').attr('parentid');
			var parentname = ld(obj).parent().parent().find('td:eq(1)').attr('parentname');
			var descri = ld(obj).parent().parent().find('td:eq(1)').attr('descri');
			ld('#addgroupdiv input[name=groupid]').val('');
			ld('#addgroupdiv input[name=groupname]').val('');
			ld('#addgroupdiv input[name=groupname]').focus();
			ld('#addparentid').val(parentid);
			ld('#oldaddparentid').val('');
			ld('#addparentid_name').val(parentname);
			ld('#addgroupdiv textarea[name=description]').val(descri);
		});
	});
	ld('.listEntries a[btn=delBtn]').on('click',function(){//删除
		//判断当前部门是否有下级
		var g_idx = ld(this).parent().parent().attr('idx');
		g_idx ++;
		var g_depth = ld(this).parent().parent().attr('depth');
		g_depth ++;
		var n_depth = ld(this).parent().parent().parent().find('tr:eq('+g_idx+')').attr('depth');
		var isnext = true;//默认当前部门有下级部门
		if(g_depth != n_depth){
			isnext = false;//当前部门没有下级部门
		}

		var groupname = ld(this).parent().parent().find('td:eq(1)').attr('groupname');
		ld('#delete_groupname').html(groupname);
		ld('#delgroupid').val(ld(this).attr('record'));
		ld('#olddelusertogroup').val(ld(this).attr('record'));
		ld('#olddellowertogroup').val(ld(this).attr('record'));
		ld('#delusertogroup').val('');
        ld('#delusertogroup_name').val('');//打开删除页的时候初始化
        ld('#dellowertogroup_name').val('');
		ld('#dellowertogroup').val('');
		//转移关联用户到
		ld('#delgroupdiv a[tag=delusertogroup]').on('click',function(){
			selectGroup('delusertogroup');//初始化选择部门弹出层
		});
		//清除所选部门按钮
		ld('#delgroupdiv a[tag=cleardelusertogroup]').on('click',function(){
			ld('#delusertogroup').val('');
			ld('#delusertogroup_name').val('');
		});
		//转移下级部门到
		ld('#delgroupdiv a[tag=dellowertogroup]').on('click',function(){
			selectGroup('dellowertogroup');
		});
		//清除所选部门按钮
		ld('#delgroupdiv a[tag=cleardellowertogroup]').on('click',function(){
			ld('#dellowertogroup').val('');
			ld('#dellowertogroup_name').val('');
		});
		if(isnext){
			ld('#dellowertogroupTr').css('display','');
		}else{//没有下级部门
			ld('#dellowertogroupTr').css('display','none');
		}
		//删除保存事件绑定
		ld('#delgroupdiv .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
			if(empty(ld('#delusertogroup').val())){
				var confirm_str = lbl_delusertogroup+' '+arrJsPopLabel.CANOTEMPTY;
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
			if(isnext && empty(ld('#dellowertogroup').val())){
				var confirm_str = lbl_dellowertogroup+' '+arrJsPopLabel.CANOTEMPTY;
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
			if(confirm(arrJsPopLabel.SUREWANTDELETE)){
				var urlstring = 'module=Settings&action=SettingsAjax&file=listgroups';
				urlstring += '&method=deleted&del_id='+ld('#delgroupid').val();
				urlstring += '&userto='+ld('#delusertogroup').val();
				if(isnext){
					urlstring += '&groupto='+ld('#dellowertogroup').val();
				}
				if(1 != issubmit) return false;
				issubmit = 2;
				RequestAjax(urlstring,function(rest){
					issubmit = 1;//考虑用ajax刷新页面
					DelProgressObjs();
					window.location.reload();//刷新当前页
				});
			}else{
				fninvshnew('delgroupdiv');puyoungJS_DialogBox.unblock();
			}
			//if(1 != issubmit) return false;
			//issubmit = 2;
		});
		// fnvshNrm('delgroupdiv');//显示选择用户弹出层
		fnvshobj(ld(this).get(0),'delgroupdiv');
	});
	ld('.listEntries a[btn=viewBtn]').on('click',function(){//查看成员
		var groupname = ld(this).parent().parent().find('td:eq(1)').attr('groupname');//部门名称
		var groupdesc = ld(this).parent().parent().find('td:eq(1)').attr('descri');//部门描述
		
		var groupid = ld(this).attr('record');
		var urlstring = 'module=Settings&action=SettingsAjax&file=listgroups';
		urlstring += '&method=getGroupUser&groupid='+groupid;
		RequestAjax(urlstring,function(rest){
			//清空可用成员、已选择成员
			ld('#selectedAssmablyColumns').get(0).length = 0;
			ld('#AssmablyList').get(0).length = 0;
			ld('#userviewid').val(groupid);
			if(!empty(rest)){
				var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
				ld.each(restobj,function(userid,username){
					ld('#selectedAssmablyColumns').append('<option value=\''+userid+'\'>'+username+'</option>');
				});
			}
            //部门设置：设置成员弹出层，“可用成员”和“选择的成员”中按照用户名字母排序
            //bug 0015315
            ld.each(userobj.user,function(key_idx,user1){
                ld.each(user1,function(username,user2){
                	if(!empty(restobj) && restobj[userobj['record'][key_idx]] != undefined)
                		return true;
                	ld('#AssmablyList').append('<option value=\''+userobj['record'][key_idx]+'\'>'+username+'</option>');
                });
            });
			ld('#view_groupname').html(groupname);
			ld('#view_groupdesc').html(groupdesc);     
            ld('input[name=allmember]').val(allmember);//清除input前面输入的值
            ld('input[name=allmember]').css('color','#999');  //设置input中的格式            
			ld('#userviewdiv .D_pbtn .D_pbtnok').on('click',function(){
				var userid = '';
				ld('#selectedAssmablyColumns option').each(function(){
					userid += ld(this).val()+',';
				});
				var urlstring = 'module=Settings&action=SettingsAjax&file=listgroups';
				urlstring += '&method=saveofuser&groupid='+ld('#userviewid').val();
				urlstring += '&userid='+userid;
				if(1 != issubmit) return false;
				issubmit = 2;
				RequestAjax(urlstring,function(rest){
					issubmit = 1;//考虑用ajax刷新页面
					ld('#userviewdiv .D_pbtn .D_pbtncancel').click();
					DelProgressObjs();
					//window.location.reload();//刷新当前页
				});
			});
			//fnvshNrm('userviewdiv');
			fnvshobj(ld(this).get(0),'userviewdiv');
			DelProgressObjs();
		});
	});
	//点击部门名称显示编辑部门界面
	ld('.listEntries .list-group').on('click',function(){
		//调用编辑按钮方法
		ld(this).parent().parent().find('td:eq(3) a[btn=editBtn]').click();
	});
});

/**
 * 显示部门弹出层
 * @project PROT180 角色权限改进
 * @author Tujt 2015-03-18
 */
function ShowGroupView(obj,callback){
	//选择部门点击事件
	ld('#addgroupdiv a[tag=selectgroup]').on('click',function(){
		selectGroup('addparentid');//初始化选择部门弹出层
	});
	//清除所选部门按钮
	ld('#addgroupdiv a[tag=clearselectgroup]').on('click',function(){
		ld('#addparentid').val('');
		ld('#addparentid_name').val('');
	});
	//保存按钮事件
	ld('#addgroupdiv .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
		ld('#addgroupdiv input[name=groupname]').val(trim(ld('#addgroupdiv input[name=groupname]').val()));
		var groupname = ld('#addgroupdiv input[name=groupname]').val();
		if(empty(groupname)){//部门名称不能为空
			ld('#addgroupdiv input[name=groupname]').focus();
			var confirm_str = lbl_groupname+' '+arrJsPopLabel.CANOTEMPTY;
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}
		if(empty(ld('#addparentid').val())){//上级部门不能为空
			var confirm_str = parentgroup+' '+arrJsPopLabel.CANOTEMPTY;
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}
		var urlstring = 'module=Settings&action=SettingsAjax&file=listgroups';
		var ustring = urlstring+'&method=checkGroupName&groupname='+groupname;
		if(ld('#addgroupdiv input[name=groupid]').val() > 0){
			ustring += '&groupid='+ld('#addgroupdiv input[name=groupid]').val();
		}
		if(1 != issubmit) return false;
		issubmit = 2;
		RequestAjax(ustring,function(rest){
			var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
			if(1 == restobj){
				issubmit = 1;
				var confirm_str = arrJsPopLabel['GROUPNAME'] +' '+ arrJsPopLabel['CANOTREPEATED'];
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				ld('#addgroupdiv input[name=groupname]').focus();
				return false;
			}
			//保存部门
			urlstring += '&method=save&groupname='+encodeURIComponent(groupname);
			urlstring += '&parentid='+ld('#addparentid').val();
			urlstring += '&description='+encodeURIComponent(ld('#addgroupdiv textarea[name=description]').val());
			urlstring += '&groupid='+ld('#addgroupdiv input[name=groupid]').val();
			RequestAjax(urlstring,function(rest){
				issubmit = 1;//考虑用ajax刷新页面
				DelProgressObjs();
				window.location.reload();//刷新当前页
			});
			DelProgressObjs();
		});
	});
	callback();//回传函数
	//fnvshNrm('addgroupdiv');//显示选择用户弹出层
	fnvshobj(ld(this).get(0),'addgroupdiv');
	ld('#addgroupdiv input[name=groupname]').focus();
}

/**
 * 初始化选择部门弹出层
 * @author Tujt 2015-03-20
 */
var isinit = 1;
function selectGroup(field){
    show('selectgroupdiv');
	if(1 == isinit)
		ld('#selectgroupList').treeview();
	isinit = 2;
	//unbind 移除原有节点的click点击事件
	ld('#selectgroupdiv span').unbind('click').on('click',function(event){
		var parentid = ld('#old'+field+'').val();
		var parentgroup = ld(this).attr('parent');
		var isselect = true;
		if(!empty(parentgroup) && !empty(parentid)){//不允许选择自己和自己的下级
			var parentgrouparr = parentgroup.split('::');
			ld.each(parentgrouparr,function(key,val){
				if(parentid == val){
					isselect = false;
					return true;
				}
			})
		}
		if(isselect){
			ld('#'+field+'').val(ld(this).attr('record'));
			ld('#'+field+'_name').val(ld(this).find('label').html());
			hide('selectgroupdiv');
		}
		return false;
	});
}
{/literal}
</script>