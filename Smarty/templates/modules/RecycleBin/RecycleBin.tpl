{*<!--
/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
<!--修改编码格式:统一编码：UTF-8-->
-->*}
<script language="JavaScript" type="text/javascript" src="include/js/search.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListViewButton.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/ListBasicSearchPopup.js"></script>

{*{include file='Buttons_List.tpl'}*}
<div id="searchingUI" style="display:none;text-align:center;">
  <img src="{'searching.gif'|@lingdang_imageurl:$THEME}" alt="{$APP.LBL_SEARCHING}"  title="{$APP.LBL_SEARCHING}">
</div>

<div class="main_grid lfloat main_grid_list">
  <div class="main_grid_top">
    
  </div>
  <div class="main_grid_box main_grid_box_recyclebin">
    <div class="grid-analysis-box">
      <div class="grid-analysis-header">
      </div>
      <div class="cont_wrap clear_float">
        <input type="hidden" value="{$BATCHNUM}" id='batchnum' />
        {*<form name="basicSearch" action="index.php" onsubmit="return false;">
          <div id="searchAcc" style="display: none;/*position:relative;*/">
            <table width="100%" cellpadding="5" cellspacing="0"  class="searchUIBasic" align="center" border=0>
              <tr>
                <td class="searchUIName small" nowrap align="left">
                  <span class="moduleName">{$APP.LBL_SEARCH}</span><br>   
                </td>
                <td class="small" nowrap align=right><b>{$APP.LBL_SEARCH_FOR}</b></td>
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
                <td class="small"><input type="text"  class="txtBox" style="width:120px" name="search_text"></td>
                <!--<td class="small" nowrap><b>{$APP.LBL_IN}</b>&nbsp;</td>-->
                <td class="small" nowrap>
                  <input name="submit" type="button" class="create" onClick="callRBSearch('Basic');" value="{$APP.LBL_SEARCH_NOW_BUTTON}">&nbsp;</td>
                <td class="small" style="font-size: 15px;" valign="top" onMouseOver="this.style.cursor='pointer';" onclick="moveMe('searchAcc');searchshowhide('searchAcc','')">[x]</td>
              </tr>
              <tr>
                <td colspan="7" align="center" class="small">
                  <table border=0 cellspacing=0 cellpadding=0 width=100%>
                    <tr>
                      {$ALPHABETICAL}
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </div>
        </form>*}

        <div id="modules_datas" style="width:100%;">
          {if $SELECTED_MODULE|@get_file_address:'ProductDetails' == true||$SELECTED_MODULE|@get_file_address:'ContactsDetails' == true||$SELECTED_MODULE|@get_file_address:'VendorsDetails' == true||$SELECTED_MODULE|@get_file_address:($SELECTED_MODULE|cat:'DetailFieldsHtml') == true}
            {include file="modules/$MODULE/ProductRecycleBinContents.tpl"}
          {else}
            {include file="modules/$MODULE/RecycleBinContents.tpl"}
          {/if}
        </div>
      </div>
    </div>
  </div>
    <div name="listviewpagination" id="listviewpagination" style="display: flex;align-items: center;height: 50px;width: 100%;"></div>
</div>

<div style="display: none;" class="LdPop_box LdPopWidth450px" id="rb_empty_conf_id">
    <div class="Title"><img src="themes/softed/tier/icon_loto.png" class="Logo" />
      <span class="Name">{'EMPTYRECYCLEBIN'|@getFixedLabel}</span>
  		<a href="javascript:fninvshnew('rb_empty_conf_id');">
  			<img src="themes/softed/tier/icon_close.png" class="Close" />
  		</a>
  	</div>
    <div class="Content_div">
    	<table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td class="Note">
        		<b>{'SUREDELETEDATABASERECORDS'|@getFixedLabel}？</b>
            </td>
          </tr>
        </table>
    </div>
    <div class="Bottom">
        <div class="Bottom_div width145">
            <input type="button" class="Button_saveGreen width60" onclick="return emptyRecyclebin('rb_empty_conf_id');" value="{'YES'|@getFixedLabel}"/><span>&nbsp;</span>
	        <input type="button" class="Button_backOrg width60" onclick="fninvshnew('rb_empty_conf_id');" value="{'NO'|@getFixedLabel}"/>
        </div>
    </div>
</div>

<script>
     var Listpagepopupobj=new CrmPopup();
	Listpagepopupobj.type=ListPagePopup.type;
	//Listpagepopupobj.divid='ListViewContents';
	Listpagepopupobj.searchtype="";//基本查询和高级查询，32156: 单据列表：设置高级查询后，切换查看范围时，不清空高级查询条件
     Listpagepopupobj.divid="pagecontent1";
	Listpagepopupobj.module='{$MODULE}';
    CrmPopup.global_listPopupObj.push(Listpagepopupobj);
  {literal}
  
    function basicsearchPopup(){
      var module=ld("#select_module").val();
      //基本查询弹出框   
      //setListButtonColor("categorysear"); 
      $("status").style.display="none";
      var Popupobj=new ListBasicSearchPopup.load("",Recyle_callSearch,"","LdPopWidth400px",module,['Basic'],btn_findnow_label,"","");
      Popupobj.show(ld("div[name=dv_listbasicsearch]").html());
    }
    
    function Recyle_callSearch(searchtype){
        //var popupobj=CrmPopup.getPopupObj("last");
        gPopupAlphaSearchUrl = '';
        var selected_module=ld("#select_module").val();
        var searchScope='SmOwner_Search_All';
        var urlstring ="";
 	   //    var search_fld_val= CrmPopup.findHtmlobj(popupobj.divid,"search_field").val();
        //   var  search_text_val= trim(CrmPopup.findHtmlobj(popupobj.divid,'search_text').val());
        // var  search_txt_val= encodeURIComponent(search_text_val);
        var search_fld_val= ld('#basicSearchNewDiv').find('[name=search_field]').val();
          var  search_text_val= ld('#basicSearchNewDiv').find('[name=search_text]').val();
        //BUG20240401-08 ls 240401 回收站，基本查询缺少查询“全部字段”的功能
        if(search_fld_val=='all'){
            var optionvalues = ld("select[name=search_field]").find(' option').map(function() {
                if(ld(this).val()!='all'){
                    return ld(this).val();
                }
            }).get();
            var search_fld_val_arr=JSON.stringify(optionvalues);
            urlstring += 'search_field_arr='+search_fld_val_arr;
        }
        var  search_txt_val= encodeURIComponent(search_text_val);
       		
        urlstring += '&search_field='+search_fld_val+'&searchtype=BasicSearch&search_text='+search_txt_val+'&';
        urlstring=urlstring+'SearchScope='+searchScope;
        urlstring+="&action=RecycleBinAjax&module=RecycleBin&mode=ajax&file=ListView&selected_module="+selected_module+"&query=true";
        // $("status").style.display="inline";
       
        var divid='modules_datas';
        ldAjaxHtmlNoProgress('index.php', urlstring,function(ajaxhtml)
        {
            // $("status").style.display="none";
            // popupobj.CancelEvent();
            // popupobj=CrmPopup.getPopupObj("last");
            //popupobj.searchtype=searchtype;
            ld("#modules_datas").html(ajaxhtml);
            // $("searchAcc").innerHTML = $("search_ajax").innerHTML;
            // $("search_ajax").innerHTML = '';
        });
       	return false
    }
    Recyle_callSearch.funname="Recyle_callSearch";
    function Recyle_keyup_callSearch (event,type){
        var e=event||window.event;
        if(e.keyCode ==13)
        {
            Recyle_callSearch('');
        }
    }
    function HighersearchPopup(){
      // setListButtonColor("categoryAdvsear");
      $("status").style.display="none";
      var Popupobj=new ListHigherSearchPopup.load("",callSearch,"","LdPopWidth800px",module,"","","","");
      Popupobj.show();
    }
    
    if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
     {
                   //通讯录(pc端企业微信)
                 
                   cls_wxOpenDataobj.bindAllOpenData();
     }
  {/literal}
</script>