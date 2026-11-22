<script type="text/javascript" src="{$JSURL}include/js/jquery.slimscroll.min.js"></script>
<div style="margin: 10px;">
	<form name="basicSearch" action="index.php">
	    <input type="hidden" name="searchtype" value="BasicSearch">
		<input type="hidden" name="module" value="Users">
		<input type="hidden" name="action" value="UsersAjax">
		<input type="hidden" name="ajax" value="true">
		<input type="hidden" name="selectmodule" id="selectmodule" value="{$SELECTMODULE}">
		<input type="hidden" name="keyids" id="keyids" value="{$KEYIDS}">
        <input type="hidden" name="frommodule" id="frommodule" value="{$FROMMODULE}">
        <input type="hidden" name="type" id="type" value="{$TYPE}">
		<input type="hidden" name="return_columnname" id="return_columnname" value="{$RETURN_COLUMN}" >
		<input type="hidden" name="select_fieldname" id="select_fieldname" value="{$SELECTFIELDNAME}">
		<input type="hidden" name="fieldname" id="fieldname" value="{$FIELDNAME}">
        {* 海格 新建报价单不允许选择已创建过1.0版本的“特价申请编号”,复制、编辑时只能选择当前编号（重新带入信息）*}
        {if $HAIGE_POTENTIALID_ALLOWEDIT neq 'no'}
		{*zxm 202212114 关联选择单据 新的基本查找*}
		<div class="marR10  marB10 ld-flex-between ld-flex-wrap {if $tree_enable eq 'yes'}marL10{/if}" id="SelectRelatedPop">
			<div class="ld-flex-start">
				{*zxm20221214 关联选择单据基本查找组件*}
				<div id="basicsearchcolumns_real" style="width:100px;">
					{*onchange事件  去获取基本查找历史*}
					<select name="select_searchfieldname" id="select_searchfieldname" class="commonSelectPop gwidth100" style="border-radius: 4px 0 0 4px;border-right:none;">
						{$serachfieldsOptions}
					</select>
				</div>
				<div class="ld-listview-basicsearch">
					{if $SELECTREALTIONFROM eq 'entry'}
						<input type="text" class="commonSelectPop gwidth100 padR40" onkeyup="detail_keydownsearch(event,'{$FROMMODULE}','{$SELECTMODULE}','{$RETURN_COLUMN}','{$TABLEDETAIL_ROW}');" name="pop_search_text" id="pop_search_txt" value="{$KEYWORDS}" autocomplete="off" style="border-radius: 0 4px 4px 0;">
						<b style="position: absolute;right:30px;top:0;cursor: pointer" class="ld-icon-clearsearch" onclick="clearRelatedSearch(this,'{$SELECTREALTIONFROM}','{$FIELDNAME}');"></b>
						<b class="categorysear-search ld-listview-search" name="search"  click_funcitonname="fun_detail_selectReference.Search();"></b>
					{else}
						<input type="text" class="commonSelectPop gwidth100 padR40" onkeyup="keywordsearch(event,'{$FIELDNAME}');" name="pop_search_text" id="pop_search_txt" value="{$KEYWORDS}" autocomplete="off" style="border-radius: 0 4px 4px 0;">
						<b style="position: absolute;right:30px;top:0;cursor: pointer" class="ld-icon-clearsearch" onclick="clearRelatedSearch(this,'{$SELECTREALTIONFROM}','{$FIELDNAME}');"></b>
						<b class="categorysear-search ld-listview-search" onclick="selectSearch('{$FIELDNAME}');"></b>
					{/if}
				</div>
			</div>
			<div class="marL10">
				{if $ISADMIN eq 1}
					<input type="button" name="search" value="{'SETFIELD'|@getFixedLabel}" onClick="setSearch('{$SELECTMODULE}','{$FROMMODULE}','{$FIELDNAME}');" class="createauto"/>
				{/if}
				{if $Approve_Demand neq '1'&& $ISCREATE eq 'yes'}
					<!--模块明细选择源单-快速创建-->
					{if $SELECTMODULE eq 'ChannelCode'}
						<input type="button" name="search" value="{'Quickly_create'|@getFixedLabel}" onClick="RelatedPopup_channelcode_add(0,'&related=yes')" class="createauto"/>
					{else}
						{if $TABLEDETAIL_ROW >= 1}
							&nbsp;&nbsp;<input type="button" name="search" value="{'Quickly_create'|@getFixedLabel}" onClick="Detail_QCreate('{$SELECTMODULE}','{$RETURN_COLUMN}','{$TABLEDETAIL_ROW}')" class="createauto"/>
						{else}
							&nbsp;&nbsp;<input type="button" name="search" value="{'Quickly_create'|@getFixedLabel}" onClick="QCreate('{$SELECTMODULE}','select')" class="createauto"/>
						{/if}
					{/if}
				{/if}
			</div>
		</div>
{*        <div style="padding: 10px 0;">
            <p style="margin-bottom: 10px;">
                {if $LANGUAGETYPE eq 'zh'}
                {'Find_field'|@getFixedLabel}&nbsp;
                {else}
                &nbsp;&nbsp;&nbsp;&nbsp;{'Find_field'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;
                {/if}
                <input type="text" class="commonDetailedTextBox" onfocus="this.value=''" disabled="disabled"  value="{$SEARCHPROMPT}" name="search_field" id="search_field" style="width:280px" />&nbsp;&nbsp;
                 {if $ISADMIN eq 1}
                <input type="button" name="search" value="{'SETFIELD'|@getFixedLabel}" onClick="setSearch('{$SELECTMODULE}','{$FROMMODULE}','{$FIELDNAME}');" class="createauto"/>
               {/if}
            </p>
            <p style="margin-bottom: 0;">
                {'KEYWORD'|@getFixedLabel}&nbsp;
				{if $SELECTREALTIONFROM eq 'entry'}
					<input type="text" value="{$KEYWORDS}" class="commonDetailedTextBox" name="pop_search_text" id="pop_search_txt" autofocus="autofocus" onkeyup="detail_keydownsearch(event,'{$FROMMODULE}','{$SELECTMODULE}','{$RETURN_COLUMN}','{$TABLEDETAIL_ROW}');" style="width:280px"/>&nbsp;&nbsp;
					<input type="button" name="search" value="{'FINDNOW'|@getFixedLabel}" click_funcitonname="fun_detail_selectReference.Search();" class="createauto"/>
				{else}
					<input type="text" value="{$KEYWORDS}" class="commonDetailedTextBox" name="pop_search_text" id="pop_search_txt" autofocus="autofocus" onkeyup="keywordsearch(event,'{$FIELDNAME}');" style="width:280px"/>&nbsp;&nbsp;
					<input type="button" name="search" value="{'FINDNOW'|@getFixedLabel}" onClick="selectSearch('{$FIELDNAME}');" class="createauto"/>
				{/if}

                    <!--Liver 20160525,改前是if $CP eq 'yes'，增加模块判断，并且改成if (isPermitted($SELECTMODULE, 'Create', '') == 'yes')-->
                    <!--22674: 销售机会新增界面：选择客户名称、联系人名称弹出层，丢失【快速创建】按钮-->
					wyt 221110 XUQIU1000658 主题：关联选择单据（单选）字段弹出层中增加【快速创建】操作按钮
					{if $SELECTMODULE eq 'Accounts' || $SELECTMODULE eq 'Potentials' || $SELECTMODULE eq 'Contacts' || $SELECTMODULE eq 'Products' || $SELECTMODULE eq 'Vendors'|| $SELECTMODULE eq 'VendorContact'|| $SELECTMODULE eq 'ChannelCode'||$SELECTMODULE eq 'VendorContactRecords'}
                    {if $Approve_Demand neq '1'&& $ISCREATE eq 'yes'}
    					<!--模块明细选择源单-快速创建-->
							{if $SELECTMODULE eq 'ChannelCode'}
								<input type="button" name="search" value="{'Quickly_create'|@getFixedLabel}" onClick="RelatedPopup_channelcode_add(0,'&related=yes')" class="createauto"/>
							{else}
								{if $TABLEDETAIL_ROW >= 1}
									&nbsp;&nbsp;<input type="button" name="search" value="{'Quickly_create'|@getFixedLabel}" onClick="Detail_QCreate('{$SELECTMODULE}','{$RETURN_COLUMN}','{$TABLEDETAIL_ROW}')" class="createauto"/>
								{else}
									&nbsp;&nbsp;<input type="button" name="search" value="{'Quickly_create'|@getFixedLabel}" onClick="QCreate('{$SELECTMODULE}','select')" class="createauto"/>
								{/if}
							{/if}
                    {/if}
                {/if}
            </p>
        </div>*}
        {/if}
	</form>
    {if $SELECTMORERECORD eq 'yes'}
		{*//ls 20221111 XUQIU1000848  普罗定制开发表单特殊带入需求(支持多选)*}
		{if $VERSIONINFO.account eq 'probiotic'}
			<input class="saveauto" style="margin-bottom:10px;" type="button" value="{'SELECT'|@getFixedLabel}" onclick="selectMoreRecordForPuluo('{$FROMMODULE}','{$FIELDNAME}','{$SELECTMODULE}')"/>
		{else}
    	<input class="saveauto" id="btnselectMoreRecord" style="margin-bottom:10px;" type="button" value="{'SELECT'|@getFixedLabel}" onclick="selectMoreRecord('{$FROMMODULE}','{$FIELDNAME}','{$SELECTMODULE}')"/>
		{/if}
	{/if}
	{* wym 230705 BUG0068821 项目甘特图，选择“项目立项”和“客户名称”弹出层界面，显示了两个滚动条 *}

	<div style="display: flex">
		{if $POPUPMODULElISTTREE.enable eq 'yes'}
			<div id="popupListViewModuleListTree" name="popupListViewModuleListTree" style="padding-right: 10px">
				<table class="ld-drag-area" border=0 cellspacing=0 cellpadding=0 style="height: 100%" >
					<tr>
						<td valign="top" class="user-left-td">
							{include file="PopupModuleListTree.tpl"}
							<div class="sidebar-drag"></div>
						</td>
						{*<td class="tip-items-list " data-tip="" data-direction="right" data-type="position">
							<span class="tree-closeopen tree-close"></span>
						</td>*}
						<td valign="top" name="popuptreereightcontent"></td>
					</tr>
				</table>
			</div>
		{/if}

		<div id="popupListViewContents" name="popupListViewContents">
			{include file="SelectRelPopupContents.tpl"}
		</div>
	</div>
</div>
<script>
	setRelatedShowOrHideClearIcon();
</script>