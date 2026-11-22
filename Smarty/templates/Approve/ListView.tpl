<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<link rel="stylesheet" type="text/css" href="{$CSSURL}themes/softed/Paymentplan.css" />
{*{include file='Buttons_List1.tpl'}*}
<div id="searchingUI" style="display:none;">
        <table border=0 cellspacing=0 cellpadding=0 width=100%>
        <tr>
                <td align=center>
                <img src="{'searching.gif'|@lingdang_imageurl:$THEME}" alt="{$APP.LBL_SEARCHING}"  title="{$APP.LBL_SEARCHING}">
                </td>
        </tr>
        </table>

</div>

<div id="approvestepresult" class="D_pop_box LdPopWidth800px" style="display: none; z-index: 9999; top: 498px; left: 555px; visibility: visible;"></div>
{*<!-- Contents -->*}
<table border=0 cellspacing=0 cellpadding=0 width=100% align=center>
     <tr>
  
	<td valign="top" width=100% >
	

	   <!-- PUBLIC CONTENTS STARTS-->
    <div id="ListViewContents"  style="width:100%;">
	  {include file="Approve/ListViewEntries.tpl"}
    </div>
     </td>
        
   </tr>
</table>

<!-- 选单审批 begin -->
<div id="menuapprovaldiv" class="D_pop_box LdPopWidth1100px" style="position: absolute; z-index:9999; left: 160px; top: 150px;display: none;">
<form action="index.php" method="post" name="menuapprovalform">

<input name="module" value="Approve" type="hidden">
<input name="action" value="menuapproval" type="hidden">
<input name="record" value="" type="hidden">
<input name="fld_module" value="Accounts" type="hidden">

<div class="D_pop_tit">
	<strong class="D_ptita">{'APPROVE_USER_MENUAPPROVAL'|@getFixedLabel}</strong>
    <a href="javascript:fninvshnew('menuapprovaldiv');" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}">
    </a>
</div>

<!-- Search Approved Begin -->
<table width="100%" cellpadding="5" cellspacing="0"  class="D_pop_bod" align="center" border=0>
	<tr>
		<td colspan="2">
		<table cellpadding="0">
		<tr>
			<td>{'Related_modules'|@getFixedLabel}</td>
			<td>
				<select name="menuapproval_search_mod">
					{foreach key=f_key item=f_item from=$MENUAPPROVALMOD}
						<option value="{$f_item}">{$f_key|@getTranstab}</option>
					{/foreach}
				</select>
			</td>
			<td>{'Find_field'|@getFixedLabel}</td>
			<td>
				<select name="menuapproval_search_field" style="width:150px">
					{foreach key=header item=searchobj from=$SEARCH_ARRAY name='approve_search_opts'}
						{if $SEARCH_FIELD != '' && $SEARCH_FIELD == $header}
							{assign var="SELECTED" value="selected"}
						{else}
							{assign var="SELECTED" value=""}
						{/if}
						<option value="{$header}" {$SELECTED}>{$header|@getFixedLabel}</option>
					{/foreach}
				</select>
			</td>
			<td align=right>{'Find_Keyword'|@getFixedLabel}</td>
			<td>
				<input type="text" class="detailedViewTextBox" style="width:120px" 
				value="" name="menuapproval_search_text" id="menuapproval_search_text">
			</td>
			<td nowrap>
				<input name="button" type="button" class="createauto" id='menuapproval_searchbtn' value="{'FINDANDADDAPPROVALLIST'|@getFixedLabel}">&nbsp;
			</td>
			</tr>
		</table>
		</td>
	</tr>
    <tr>
		<!-- Buttons -->
		<td align="left">
			<ul class="D_btn_box">
				<li class="D_anu_a">
					<a title="{'APPROVE_BATCHAPPROVED'|@getFixedLabel}"  id='menuappruval_approvebtn'>
					<b class="icon-homeimg icon-check"></b><span>{'APPROVE_BATCHAPPROVED'|@getFixedLabel}</span></a>
				</li>
				<li class="D_anu_a">
					<a title="{'Remove'|@getFixedLabel}" id='menuappruval_removebtn'>
					<b class="icon-homeimg icon-del"></b><span>{'Remove'|@getFixedLabel}</span></a>
				</li>
			</ul>
		</td>
	</tr>
<!-- Search Approved End -->
    <tr>
        <td>
            <div class="fixedheaderDiv">
        	<table class="listEntries fir-center" border="0" cellspacing="1" cellpadding="0" width="100%">
        		<colgroup>
                   <col width="25"/>
                   <col width="68"/>
                   <col width="140"/>
                   <col width="68"/>
                   <col width="68"/>
                   <col width="100"/>
                   <col width="85"/>
                   <col width="155"/>
                   <col width="85"/>
                   <col width="128"/>
                </colgroup>
                <tbody><tr>
        			<th>
        				{if $ISAPPROVE eq 1}
        				<input type="checkbox"  name="mentallselect" id="mentallselect" onClick="approveallselect(this,'menuselectid');">
        				{else}
        					{'SEQUENCE'|@getFixedLabel}
        				{/if}
        			</th>
        			{foreach name="listviewforeach" item=header from=$LISTHEADER name=menuapprovalList}
        			<th>{$header|@getFixedLabel}</th>
        			{/foreach}
        		</tr>
                </tbody>
        	</table>
            </div>
            <div id="menuapprovalcontent" style='overflow-y: scroll;height:300px;'>
                <table class="listEntries fir-center" border="0" cellspacing="1" cellpadding="0" width="100%" id='menuapprovallistTab'>
                 <colgroup>
                   <col width="25"/>
                   <col width="68"/>
                   <col width="140"/>
                   <col width="68"/>
                   <col width="68"/>
                   <col width="100"/>
                   <col width="85"/>
                   <col width="155"/>
                   <col width="85"/>
                   <col width="128"/>
                </colgroup>
                    <tbody></tbody>
                </table>
            </div>
        
        </td>
    </tr>
</table>

<!-- Search Approved End -->
</form>
</div>
<!-- 选单审批 end -->

<!-- 选单审批 选择审批流程 begin -->
<div id="menubatchapproved" class="D_pop_box  LdPopWidth350px" style="position: absolute; z-index:9998; left: 200px; top: 150px;display: none;">

<div class="D_pop_tit">
	<strong class="D_ptita">{'APPROVE_USER_MENUAPPROVAL'|@getFixedLabel}-{'APPROVE_BATCHAPPROVED'|@getFixedLabel}</strong>
    <a href="javascript:CloseTheWindow('menubatchapproved');" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}">
    </a>
</div>
<div id="subappcontent2">
<table class="D_pop_bod" border="0" cellpadding="1" cellspacing="1">
    <tbody>
	<tr>
        <td nowrap="nowrap">
			&nbsp;{'SELECTAPPROVALPROC'|@getFixedLabel}&nbsp;
			<select id="menu_approveid" style="width:120px;">
				<option value=""></option>
			</select>
		</td>
	</tr>
    {*editor：gyq_05  reason:选单审批新增单选按钮，同时修改显隐JS date:2016 3 3*}
	<tr>
        <td  >
            <input type="radio" value='0' name='menubatchapptype' />
			&nbsp;{'editingprocessd'|@getFixedLabel}&nbsp;
			<select id="menu_stepid" style="width:120px;">
				<option value=""></option>
			</select><br/>
            &nbsp;　　{'NEXTOPERATOR'|@getFixedLabel}&nbsp;
            <select id="menu_nextuserid" style="width:120px;">
                <option value=""></option>
            </select>
		</td>
	</tr>

	<tr>
		<td>
			<a href='' id='displayorhidden' setype='1' disp="{'DISPLAY'|@getFixedLabel}" hidd="{'HIDDEN'|@getFixedLabel}" style="text-decoration:underline;">{'DISPLAY'|@getFixedLabel}</a>
		</td>
	</tr>
	<tr>
        <td nowrap="nowrap">
			<input type="radio" value='1' name='menubatchapptype' class="last2param"/>&nbsp;{'AISTEOTP'|@getFixedLabel}
		</td>
	</tr>
	<tr>
		<td nowrap="nowrap">
			<input type="radio" value='2' name='menubatchapptype' class="last2param"/>&nbsp;{'AFTPE'|@getFixedLabel}
		</td>
    </tr><tr>
		<td nowrap="nowrap">
			{'REMARK'|@getFixedLabel} :<br>
			<textarea name="approveddescri" id="approveddescri2" rows="4" style="resize:none;padding: 8px;"></textarea>
		</td>
    </tr>
</tbody></table>
</div>
<div class="D_pbtn">
	<input class="D_pbtnok" id='batchmenuapprovedbtn' value="{'SAVE'|@getFixedLabel}" type="button"><span>&nbsp;</span>
    <input class="D_pbtncancel" id='cencalmenuapprovedbtn' value="{'CANCEL'|@getFixedLabel}" onclick="CloseTheWindow('menubatchapproved');" type="button">
</div>
</form>
</div>

<input type="hidden" id="maxperpagelist" value='{$MAXPERPAGELIST}'>
<!-- 选单审批 选择审批流程 end -->
<script type="text/javascript">
var lbl_please_select = "{'LBL_PLEASE_SELECT'|@getFixedLabel}";//请选择
var lbl_approvalstep = "{'APPROVALSTEP'|@getFixedLabel}";//审批步骤
var lbl_nextoperator = "{'NEXTOPERATOR'|@getFixedLabel}";//下一步处理人
</script>