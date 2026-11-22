{if $smarty.request.ajax neq ''}
&#&#&#{$ERROR}&#&#&#
{/if}
<input type="hidden" name="searchtype" value="BasicSearch">
<input type="hidden" name="module" value="{$MODULE}" id="curmodule">
<input name="maxrecords" type="hidden" value="{$MAX_RECORDS}" id='maxrecords'>
<input type="hidden" name="parenttab" value="{$CATEGORY}">
<input type="hidden" name="action" value="index">
<input type="hidden" name="query" value="true">
<input type="hidden" name="search_cnt">

{*ls 2022-07-08 BUG0053720 日程管理（列表视图）切换管理分类之后，点击下一页，管理分类自动切换为默认的(不能放到ActivityListView.tpl，切换数据分类时需要局部刷新)*}
<input type="hidden" id="viewname" name="viewname" value="{$VIEWID}"/>
<input type="hidden" value="{$BATCHNUM}" id='batchnum' />

<form name="massdelete" method="POST" id="massdelete" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="publicaccounttype" value="{$ACCOUNTTYPE}" />
    <input name='search_url' id="search_url" type='hidden' value='{$SEARCH_URL}'>
    <input name="idlist" id="idlist" type="hidden">
    <input name="change_owner" type="hidden">
    <input name="change_status" type="hidden">
    <input name="action" type="hidden">
    <input name="step" type="hidden">
    <input name="excludedRecords" type="hidden" id="excludedRecords" value="">
    <input name="numOfRows" id="numOfRows" type="hidden" value="{$NUMOFROWS}">
    <input name="allids" type="hidden" id="allids" value="{$ALLIDS}">
    <input name="selectedboxes" id="selectedboxes" type="hidden" value="{$SELECTEDIDS}">
    <input name="allselectedboxes" id="allselectedboxes" type="hidden" value="{$ALLSELECTEDIDS}">
    <input name="current_page_boxes" id="current_page_boxes" type="hidden" value="{$CURRENT_PAGE_BOXES}">
    <input name="assign_name" id="assign_name" type="hidden" value="{$id}">
    <div class="main_grid lfloat main_grid_list">
        <div class="main_grid_top">
            {*zxm 20221202老的代码挪到了这里*}
            {*{include file='ListViewBtnAndSeachForC.tpl'}*}
            <div class="clear"></div>
        </div>
        <div class="main_grid_box">
            <div class="grid-analysis-box">
                <div class="grid-analysis-header">
                </div>
                <div class="cont_wrap clear_float">
                    {assign var=operating value='OPERATING'|@getFixedLabel}
                    <div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;">
                        <div style=" visibility: visible; top: 194px;overflow:hidden" id="resize_header_table_divid">
                            <div class="ui-jqgrid-hbox" style="float:left; padding-right:20px">
                                <table class="listEntries fir-center" name="resize_header_tableid" id="resize_header_tableid"  border="0" cellspacing="1" cellpadding="0" style="width:{$TOTALWIDTH}px">
                                    <!-- Table Headers -->
                                    <tr>
                                        {if $LIST_NOCHECKBOX neq 'no'}
                                        <th class="firstChild" style="text-align:center;width:{$CHKBOXWIDTH}px" tag="0" headername='chkbox' headermodule='{$MODULE}' >
                                            <input class="checkbox-item j-all-checkbox" type="checkbox" name="selectall"  id="selectCurrentPageRec" onClick=toggleSelect_ListView(this.checked,"selected_id")>
                                        </th>
                                        {/if}
                                        {foreach name="listviewforeach" item=header key=i from=$LISTHEADER}
                                            {if $header neq $operating}
                                                {*liushuai 20230713 BUG0069036 日程管理-列表视图-单据列表-拖动修改列宽，点及其他模块再返回，就恢复默认的列宽，没有记住上次的修改*}
                                                <th style="width:{$LISTHEADERWIDTH[$i]}px" tag="{$i+1}" headermodule='{$HEADERNAME.module[$i]}'  headername='{$HEADERNAME.fieldname[$i]}' >{$header}</th>
                                            {else}
                                                <th width="{$OPERATIONWIDTH}" tag="{$i+1}">{$header} </th>
                                            {/if}     
                                        {/foreach}
                                    </tr>                            
                                </table>
                            </div>
                        </div>
                        <div style="overflow:auto;height:301px;" id="resize_content_table_divid">
                            <table class="listEntries fir-center marT-53" id="resize_content_tableid" name="resize_content_tableid"  style="width:{$TOTALWIDTH}px" border="0" cellspacing="1" cellpadding="0" >
                                <tr name="tr_header">
                                    {*zkt 20221012 BUG0057553日程管理列表视图界面，点击“进度漏斗”阶段选项弹出层界面，列表数据显示列字段值错位，操作列显示阴影*}
                                    {if $LIST_NOCHECKBOX neq 'no'}
                                    <th class="firstChild" style="text-align:center;width:{$CHKBOXWIDTH}px" tag="0" headername='chkbox' headermodule='{$MODULE}'>
                                        <input type="checkbox"  name="selectall" id="selectCurrentPageRec"  onClick=toggleSelect_ListView(this.checked,"selected_id")>
                                    </th>
                                    {/if}
                                    {foreach name="listviewforeach" item=header key=i from=$LISTHEADER}
                                        {if $header neq $operating}
                                            <th style="width:{$LISTHEADERWIDTH[$i]}px" tag="{$i+1}" headermodule='{$HEADERNAME.module[$i]}' headername="{$HEADERNAME.fieldname[$i]}">{$header}</th>
                                        {else}
                                            <th width="{$OPERATIONWIDTH}" tag="{$i+1}" >{$header}</th>
                                        {/if}     
                                    {/foreach}
                                </tr>
                                <tbody>
                                    <tr>
                                        {*<td id="linkForSelectAll" class="linkForSelectAll" style="display:none;" colspan="{$LISTHEADERCOUNT}" onclick="toggleSelectAll_parent_td(this)">
                                            <span id="selectAllRec" class="selectall" style="display:inline;" onClick="toggleSelectAll_Records('{$MODULE}',true,'selected_id')">{'SELECTALL'|@getFixedLabel} <span id="count"> {$NUMOFROWS}</span> {'RECORDNUMS'|@getFixedLabel}</span>
                                            <span id="deSelectAllRec" class="selectall" style="display:none;" onClick="toggleSelectAll_Records('{$MODULE}',false,'selected_id')">{'DESELECTALL'|@getFixedLabel}</span>
                                        </td>*}
                                    </tr>
                                    {$DEAILHTML}                        
                                    {if $TOTALFLDHTML != ''}
                                        {$TOTALFLDHTML}
                                    {/if}                        
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div name="listviewpagination" id="listviewpagination" style="display: flex;align-items: center;height: 50px;width: 100%;">
        </div>
    </div> 
</form>

{$SELECT_SCRIPT}
<!--基本查询-->
{include file="basicSearch.tpl"}
<div id="SubmitApprove" class="D_pop_box LdPopWidth500px" style="display:none;"></div>
<script id="listajaxentries">
    var module = '{$MODULE}';
    var popupobj=CrmPopup.getPopupObj("last");
    if(popupobj.divid == 'dv_listhighersearch'){
        popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
        if(popupobj){

        }else{
            popupobj = CrmPopup.getPopupObj('lastprev');
        }
    }
    setContentHeight(popupobj.module);//计算内容高度 
	popupobj.url='{$LISTPAGEURL}';
    popupobj.page_list_query='{$Encrypt_page_list_query}';

    /*标签*/
	if(Listpagepopupobj != undefined && Listpagepopupobj.fields != undefined){
		ld.each(Listpagepopupobj.fields,function(ikey,tag){
			if(tag.uitype == 301){
				ld('#module_tag_list_search').show();
				return false; 
			}
		});
	}

    var isstructuretree=ld(" #structuretree");
    if (isstructuretree.length>0){
        // ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
        popupobj.list_TreeWhere = '{$Encrypt_TreeWhere}';
        if (typeof structureTreeobj == "undefined" || structureTreeobj == undefined){
            var structureTreeobj=new structureTree();
        }
        structureTreeobj.getModuleTreeCount(popupobj);
    }

    //hzx 20231207 XUQIU1002273 PC端模块列表界面，分页样式优化
    var tabname = '{$TABNAME}';
    var tmp_pagedata = {
        'currentpage': {$STARTPAGE},
        'count': {$LISTVIEWRECORDCOUNT},
        'pagecount': {$LISTVIEWPAGECOUNT},
        'language': language,
        'changepage': function (pagenum){
            if(module == 'Documents'){
                getListViewEntries_js(module,'parenttab='+tabname+'&start='+pagenum+'&folderid=index');
            }else {
                getListViewEntries_js(module,'parenttab='+tabname+'s&start='+pagenum);
            }

        },
        'pagepernumarr': {$LISTVIEWPERPAGENUM},
        'changepagecount': function (evt){
            var pagecount=evt.NavBarItem.value;
            setMaxEntriesPerPage(module,pagecount,tabname);
        }
    }
    AjaxJSPage('ld_Pagination','include/js/component/ld_Pagination.js');
    var last_crmpopup = CrmPopup.getPopupObj("last");
    var tmp_divid = '';
    if(last_crmpopup.pagetype == 'advance_stage_chuantou'){
        tmp_divid = last_crmpopup.divid;
    }
    else if(last_crmpopup.pagetype == 'detailview_modulepage' || last_crmpopup.type == 'relatelistpage'){
        var prevpopup = CrmPopup.getPopupObj("lastprev");
        if(prevpopup.pagetype == 'advance_stage_chuantou' || prevpopup.pagetype == ListPagePopup.type) {
            tmp_divid = prevpopup.divid;
        }else if(prevpopup.pagetype = 'detailview_modulepage'){
            tmp_divid = CrmPopup.getlastPopupObjByType('listpage').divid;
        }
    }
    else{
        if(last_crmpopup.type == 'none'){
            tmp_divid = CrmPopup.getlastPopupObjByType('listpage').divid;
        }else{
            tmp_divid = popupobj.divid;
        }
    }
    var listviewpagination = ld('#'+tmp_divid+' #listviewpagination');
    var listviewpaginationobj = ld_Pagination.showPagination(listviewpagination.get(0), tmp_pagedata);
    popupobj.listviewpaginationobj = listviewpaginationobj;

    ld('#selectAllRec span#count').html({$LISTVIEWRECORDCOUNT});
</script>