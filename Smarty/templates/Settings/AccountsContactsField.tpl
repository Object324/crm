<script language="javascript">
function moveUp(selecttypes)
{ldelim}
  var elem =(selecttypes=='selectedtab')?document.getElementById('selectedtabColumns'):document.getElementById('menu_profieldid');
		if(elem.options.selectedIndex>=0){ldelim}
			for (var i=1;i<elem.options.length;i++){ldelim}
				if(elem.options[i].selected == true){ldelim}
					//swap with one up
					var first = elem.options[i-1];
					var second = elem.options[i];
					var temp = new Array();

					temp.value = first.value;
					temp.innerHTML = first.innerHTML;

					first.value = second.value;
					first.innerHTML = second.innerHTML;

					second.value = temp.value;
					second.innerHTML = temp.innerHTML;

					first.selected = true;
					second.selected = false;
				{rdelim}
			{rdelim}
		{rdelim}
	
{rdelim}
function moveDown(selecttypes)
{ldelim}
  var elem =(selecttypes=='selectedtab')?document.getElementById('selectedtabColumns'):document.getElementById('menu_profieldid');
		if(elem.options.selectedIndex>=0){ldelim}
			for (var i=elem.options.length-2;i>=0;i--){ldelim}
				if(elem.options[i].selected == true){ldelim}
					//swap with one down
					var first = elem.options[i+1];
					var second = elem.options[i];
					var temp = new Array();

					temp.value = first.value;
					temp.innerHTML = first.innerHTML;

					first.value = second.value;
					first.innerHTML = second.innerHTML;

					second.value = temp.value;
					second.innerHTML = temp.innerHTML;

					first.selected = true;
					second.selected = false;
				{rdelim}
			{rdelim}
		{rdelim}
{rdelim}

/*
edit:weiyannan
date:2023-11-14
resson:XUQIU1002049 系统穿梭框界面样式统一 后台设置--其他设置--客户和联系人关联字段
*/
getJsScript('include/js/DragTransfer.js', function () {
    var tableobj = ld(".AccountsContactsTable");
    var LeftObj = tableobj.find(" .commonMultipleSelect:first");
    var RightObj = tableobj.find(" .commonMultipleSelect:last");
    var Drag_Transfer = new DragTransfer();
    Drag_Transfer.SetDragTransfer(tableobj, LeftObj, RightObj, 'reset', '300');
});

</script>
<!-- End -->
<form name="menu" action="index.php" method="post">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="action" value="AccountsContactsField"/>
<input type="hidden" name="edittype" value="Add"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_ACCOUNTS_CONTACTS_FIELDS'|@getFixedLabel}<font>（{'LBL_ACCOUNTS_CONTACTS_DESCRIPTION'|@getFixedLabel}）</font>
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="saveAccountsContactsvalidate()" title="{'SAVE'|@getFixedLabel}">{'SAVE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        {*wym 240119 BUG20240119-48 客户和联系人关联字段，滚动条下滑时有阴影，但是并没有固定表头的效果，应该只是做区块用，没有阴影*}
        <div class="cont_wrap">
            <table border="0" cellspacing="0" cellpadding="0" width="100%" class="settingTable">
                <tr>
                    <th colspan="2">
                        {'BLOCKINFOMATION'|@getFixedLabel}
                    </th>
                </tr>
                <tr>
                    <td width="20%"><span class="redFont">*</span>{'CNTAG'|@getFixedLabel}</td>
                    <td><input type="text" class="ld-input-inner gwidth50" name="zhname" id="zhname" value="{$BLOCKINFO.zh_blockname}" size ="40"></td>
                </tr>
                <tr>
                    <td><span class="redFont">*</span>{'ENTAG'|@getFixedLabel}</td>
                    <td><input type="text" class="ld-input-inner gwidth50" name="enname" id="enname" value="{$BLOCKINFO.en_blockname}" size="40"></td>
                </tr>
                <tr>
                    <td>{'DISPLAYPOSITION'|@getFixedLabel}</td>
                    <td>
                        <select name="display_type" id="display_type" class="ld-select-inner" style="width:120px;">
                            <option value="0" {if $BLOCKINFO.display_position eq 0}selected="true"{/if}>{'THEFIRSTBLOCK'|@getFixedLabel}</option>
                            <option value="1" {if $BLOCKINFO.display_position eq 1}selected="true"{/if}>{'THELASTBLOCK'|@getFixedLabel}</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td>{'WHETHERTODISPLAY'|@getFixedLabel}</td>
                    <td><input type="checkbox" name="isdisplay" id="isdisplay" value="1" {if $BLOCKINFO.is_display eq 0}checked{/if}></td>
                </tr>
            </table>
            <table class="marT15 padL10 AccountsContactsTable" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="270">
                        <b style="color:#666;">{'Available_fields'|@getFixedLabel}</b>
                        <select multiple ondblclick="addColumn('tabList','selectedtabColumns')" id="tabList" name="tabList" class="commonMultipleSelect marT15" style="height: 200px;width:250px;" >
                            {foreach key = fieldid item = fieldlabel from =$ALLFIELDS name=pname}
                                <option value="{$fieldid}">{$fieldlabel}</option>
                            {/foreach}
                        </select>
                        <input type="hidden" name="selectedfields" />
                    </td>
                    <td align="left" width="65">
                        <a class="icon-newhomearr icon-mright" href="javascript:;" title="{'MOVERIGHT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('tabList','selectedtabColumns');"></a>
                        <br />
                        <a class="icon-newhomearr icon-mleft" style="margin-top:15px;" href="javascript:;"title="{'MOVELEFT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('selectedtabColumns','tabList');" ></a>
                    </td>
                    <td width="250">
                        <b style="color:#666;">{'Selected_Fields'|@getFixedLabel}</b>
                        <select multiple ondblclick="addColumn('selectedtabColumns','tabList')" id="selectedtabColumns" name="selectedtabColumns" class="commonMultipleSelect marT15" style="height: 200px;width:250px;" size="11">
                            {foreach key = fieldid item = fieldlabel from = $CHILDFIELDS name=pname}                                                             
                                <option value="{$fieldid}">{$fieldlabel}</option>
                            {/foreach}
                        </select>
                    </td>
                    <td align="left" style="padding-left:20px;">
                        <a class="icon-newhomearr icon-mup" href="javascript:;" title="{'MOVEUP'|@getFixedLabel}" onclick="moveUp('selectedtab');"></a>
                        <br />
                        <a class="icon-newhomearr icon-mdown" style="margin-top:15px;" href="javascript:;" title="{'MOVEDOWN'|@getFixedLabel}" onclick="moveDown('selectedtab');"></a>
                    </td>
                </tr>              
            </table>
            <div class="listRloesHelp">
                {'SHOWMODULES'|@getFixedLabel}{'MAOHAO'|@getFixedLabel}{$ALLMODULENAME}
            </div>
        </div>
    </div>
</div>
</form>