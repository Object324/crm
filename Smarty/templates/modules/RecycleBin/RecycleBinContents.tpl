{*
/*+********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
 <!--修改编码格式:统一编码：UTF-8-->
*}
<script language="javascript">
	//ListView_Page.content_tableid="producttable";//内容所在table的id
</script>
<form>
<div>
    <!-- List View's Buttons and Filters starts -->
	<table border=0 cellspacing=0 cellpadding=0 width=100% class="">
        <tr>
	       <!-- Buttons -->
    		<td nowrap="nowrap">
				<input type="hidden" id="search_url" value="{$SEARCH_URL}">
				<input type="hidden" name="idlist" id="idlist">
				<input name="numOfRows" id="numOfRows" type="hidden" value="{$NUMOFROWS}">
				<input name="maxrecords" type="hidden" value="{$MAX_RECORDS}" id='maxrecords'>
				<input type="hidden" id="excludedRecords" name="excludedRecords" value="{$excludedRecords}">
				<input type="hidden" name="allselectedboxes" id="allselectedboxes" value="{$ALLSELECTEDIDS}">
				<input name="current_page_boxes" id="current_page_boxes" type="hidden" value="{$CURRENT_PAGE_BOXES}">
			
				<input type="hidden" name="selected_module_translated" id="selected_module_translated" value="{$SELECTED_MODULE|@getTranstab}">
				<div class="ld-flex-between padTB5 gwidth100 ld-flex-wrap" id="ListViewBtnAndSeach" style="height: 50px;position:relative;">
					<div class="ld-flex-start ld-flex-wrap">
						<!--按钮、查看范围-->
						{*<div class="E_pop_tit_Second_Right ld-listview-btnscontent marL15">
							{if $REDUCTIONPERMIT eq 'yes'}
								<div class="ld-button" title="{'REDUCTION'|@getFixedLabel}" onclick="massRestore();">{'REDUCTION'|@getFixedLabel}</div>
							{/if}
							{if $DELPERMIT eq 'yes'}
								<div class="ld-button" title="{'DELETE'|@getFixedLabel}" onclick="Rassdelete();">{'DELETE'|@getFixedLabel}</div>
							{/if}
						</div>*}
						{*<div class="padR5 padL10"><label>{'SELECTMODULE'|@getFixedLabel}</label></div>*}
						<div class="LdShowselect" id='dv_recycle_select_module'>
							<select id="select_module" name="select_module" onChange="changeModule(this);" style="display:none">
								{foreach key=mod_name item=module from=$MODULE_NAME}
									{assign var="modulelabel" value=$module|@getTranstab}
									{if $module neq 'OftenUseReport' && $module neq 'ReportAnalysis'}
										{if $module eq $SELECTED_MODULE}
											{assign var='opttext' value=$modulelabel}
											<option value="{$module}" selected>{$modulelabel}</option>
										{else}
											<option value="{$module}">{$modulelabel}</option>
										{/if}
									{/if}
								{/foreach}
							</select>
							<div id="ld_select_module" style="margin-right: 20px;margin-left: 10px;"></div>
						</div>
						<div class="marL15 marR10 ld-flex-start ld-flex-wrap" id="basicSearchNewDiv">
							{*基本查找组件 zxm 20221212*}
							{include file='ListViewBasicSearch.tpl'}
						</div>
					</div>
					<div class="ld_listviewabtnrely" id="ld_listviewabtnrely" style="padding: 10px 15px;">
						<div class="ld_listviewchosenum">{'choose'|@getFixedLabel} <span class="chosenum">0</span> {'numbill'|@getFixedLabel}</div>
						<div class="ld_listviewchooseall" {if isset($LISTVIEWPAGECOUNT) && $LISTVIEWPAGECOUNT > 1}{else}style="display: none;"{/if}>
							<span id="selectAllRec" class="selectall" style="display:inline;" onClick="toggleSelectAll_Records('{$MODULE}',true,'selected_id')">{'SELECTALL'|@getFixedLabel} <span id="count"> {$NUMOFROWS}</span> {'RECORDNUMS'|@getFixedLabel}</span>
							<span id="deSelectAllRec" class="selectall" style="display:none;" onClick="toggleSelectAll_Records('{$MODULE}',false,'selected_id')">{'DESELECTALL'|@getFixedLabel}</span>
						</div>
						<div class="ld_listviewabtnrelylist">
							<ul>
								{if $REDUCTIONPERMIT eq 'yes'}
									<li class="listviewbtnrely" title="{'REDUCTION'|@getFixedLabel}" onclick="massRestore();"><img class="relybtnicon" src="themes/icon/button/Back.png"/><span>{'REDUCTION'|@getFixedLabel}</span></li>
								{/if}
								{if $DELPERMIT eq 'yes'}
									<li class="listviewbtnrely" title="{'DELETE'|@getFixedLabel}" onclick="Rassdelete();"><img class="relybtnicon" src="themes/icon/button/Delete.png"/><span>{'DELETE'|@getFixedLabel}</span></li>
								{/if}
							</ul>
						</div>
						<div class="ld_btnrelycancel" onClick="toggleSelectAll_Records('{$MODULE}',false,'selected_id')"><i class="btncloseicon"></i></div>
					</div>
				</div>
          	</td>
            <td>
                <!--分页-->
                {*<div class="PageDiv0" style="margin-top: 0;">
                	<div class="ld-flex-start">
                       	<div class="ld-pagenum-div">{$RECORD_COUNTS}</div>
						{$NAVIGATION}
                    </div>
                </div>*}
                <!--分页  end-->
            </td>
		</tr>
	</table>
	<!-- List View's Buttons and Filters ends -->	
	{$LISTDATA}
</div>

{if $smarty.request.mode eq 'ajax'}
	{*<div id="search_ajax" style="display:none;">
	<table width="100%" cellpadding="5" cellspacing="0"  class="searchUIBasic small" align="center" border=0>
	<tr>
		<td class="searchUIName small" nowrap align="left">
			<span class="moduleName">{'SEARCH'|@getFixedLabel}</span><br/>
		</td>
		<td class="small" nowrap align=right><b>{'SEARCH'|@getFixedLabel}</b></td>
		<td class="small"><input type="text"  class="txtBox" style="width:120px" name="search_text"/></td>
		<td class="small" nowrap>
			<div id="basicsearchcolumns_real">
				<select name="search_field" id="bas_searchfield" style="width:150px">
				{html_options  options=$SEARCHLISTHEADER }
				</select>
			</div>
			<input type="hidden" name="searchtype" value="BasicSearch">
			<input type="hidden" name="module" value="{$SELECTED_MODULE}">
			<input type="hidden" name="parenttab" value="{$CATEGORY}">
			<input type="hidden" name="action" value="index">
			<input type="hidden" name="query" value="true">
			<input type="hidden" name="search_cnt">
		</td>
		<td nowrap>
			<input name="submit" type="button" class="create" onClick="callRBSearch('Basic');" value=" {'FINDNOW'|@getFixedLabel} ">&nbsp;
		</td>
		<td valign="top" style="font-size: 15px;" onMouseOver="this.style.cursor='pointer';" onclick="moveMe('searchAcc');searchshowhide('searchAcc','')">[x]</td>
	</tr>
	<tr>
		<td colspan="7" align="center">
			<table border=0 cellspacing=0 cellpadding=0 width=100%>
				<tr>
					{$ALPHABETICAL}
				</tr>
			</table>
		</td>
	</tr>
	</table>
    </div>*}
{/if}
</form>

<!--基本查询-->
 <div  name="dv_listbasicsearch" id="dv_listbasiscsearch" class="E_pop_box LdPopWidth400px" style="display:none" >
    <!-- <div class="E_pop_tit" id="dv_listbasiscsearch_head" style="cursor:move">
        <strong class="E_ptita">{'BASICFIND'|@getFixedLabel}</strong>
        <button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" id="dv_listbasiscsearch_imgclose" title="{'CLOSE'|@getFixedLabel}"/>
    </div> -->
   {* <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td align="right">{'Find_field'|@getFixedLabel}</td>
            <td>
    			<div id="basicsearchcolumns_real">
    			<select name="search_field" id="bas_searchfield" class="commonSelectPop gwidth90">
    			 {html_options  options=$SEARCHLISTHEADER selected=$SEATCH_INPUT.search_field}
    			</select>
    			</div>
                <input type="hidden" name="searchtype" value="BasicSearch">
    		</td>
        </tr>
        <tr>
            <td align="right">{'SEARCHKEY'|@getFixedLabel}</td>
    		<td>
				<input type="text" onkeyup="Recyle_keyup_callSearch(event,'Basic')" class="commonTextBoxPop" name="search_text" value="{if 'alpbt' != $SEATCH_INPUT.type}{$SEATCH_INPUT.search_text}{/if}">
			</td>
        </tr>
    </table>*}
    <!-- <div align="center" class="E_pbtn">
        <input name="submit" onClick="return Recyle_callSearch('Basic');" class="E_pbtnok" value="{'FINDNOW'|@getFixedLabel}" type="submit">
    </div> -->
</div>
<script>
	//hzx 20231207 XUQIU1002273 PC端模块列表界面，分页样式优化
	var module = '{$MODULE}';
	var tabname = '{$TABNAME}';
	var tmp_pagedata = {
		'currentpage': {$STARTPAGE},
		'count': {$LISTVIEWRECORDCOUNT},
		'pagecount': {$LISTVIEWPAGECOUNT},
		'language': language,
		'changepage': function (pagenum) {
			if (module == 'Documents') {
				getListViewEntries_js(module, 'parenttab=' + tabname + '&start=' + pagenum + '&folderid=index');
			} else {
				getListViewEntries_js(module, 'parenttab=' + tabname + 's&start=' + pagenum);
			}
		}
	}
	AjaxJSPage('ld_Pagination','include/js/component/ld_Pagination.js');
	var listviewpagination = ld('#listviewpagination');
	var listviewpaginationobj = ld_Pagination.showPagination(listviewpagination.get(0), tmp_pagedata);

	//选择模块下拉框
	var selsect_module_arr = {$SELECT_MODULE_ARR};
	AjaxJSPage('ld_Select','include/js/component/ld_Select.js');
	var Showselect_obj = ld_Select.showSelect(ld('#ld_select_module').get(0), {
		list: selsect_module_arr,
		width: '180px',
		optionwidth: '180px',
		selecticonurl: 'themes/icon2024/customview1.png',
		selecticonhoverurl: 'themes/icon2024/customview.png',
		optionobjattr: ['value'],
		filterable: true,
		change: function (evt){
			ld('#select_module').val(evt.NavBarItem.value);
			ld('#select_module').change();
		}
	});
</script>