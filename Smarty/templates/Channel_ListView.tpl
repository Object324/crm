{*<!--
/*+********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script type="text/javascript">
DocmentWriteJs("include/js/ListViewButton.js","ListViewButton_js");
DocmentWriteJs("include/js/SystemPopup/ListBasicSearchPopup.js","ListBasicSearchPopup_js");
DocmentWriteJs("include/js/SystemPopup/DataCategoryPopup.js","DataCategoryPopup_js");

</script>

<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/DividendOrder/NewDividendOrder.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/search.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/webuploader.js?v={$GLOBALMINVERSION}"></script>

{if $MODULE eq 'Users'}
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Roles.js?v={$GLOBALMINVERSION}"></script>
{/if}
{if $MODULE eq 'SocialPromotion'}
	<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/colpick/colpick.js?v={$GLOBALMINVERSION}"></script>
	<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/colpick/plugin.js?v={$GLOBALMINVERSION}"></script>
	<link rel="stylesheet" type="text/css" href="{$CSSURL}themes/softed/SocialPromotion.css?v={$GLOBALMINVERSION}"/>
{/if}
<script type="text/javascript">
     var USER_GROUP_LIST_ID='{$USER_GROUP_LIST_ID}';//用户列表
    ld('body').css('overflow','hidden');
	jQuery.noConflict();
    //利于基本查询LISTPAGEURL变量
     var Listpagepopupobj=new CrmPopup();
	Listpagepopupobj.type=ListPagePopup.type;
	var linkmodulecustom = '{$LINKMODULECUSTOM}';
	Listpagepopupobj.linkmodulecustom = linkmodulecustom ? 'yes': 'no';
	Listpagepopupobj.divid='pagecontent1';
	Listpagepopupobj.searchtype="";//基本查询和高级查询，32156: 单据列表：设置高级查询后，切换查看范围时，不清空高级查询条件
	Listpagepopupobj.url='{$LISTPAGEURL}';
	Listpagepopupobj.module='{$MODULE}';
    
    if(Listpagepopupobj.module=='Approve')
    {
        Listpagepopupobj.module='{$FROMAPPROVEMODULE}';
        Listpagepopupobj.frommodule='Approve';

    }
        
    
    CrmPopup.global_listPopupObj.push(Listpagepopupobj);
    Listpagepopupobj.pagetype=ListPagePopup.pagetype;//
</script>
<script language="JavaScript" type="text/JavaScript">
    var moveupLinkObj,moveupDisabledObj,movedownLinkObj,movedownDisabledObj;
   
    
   
    var editviewinfojsonobj='{$FIELDINFOJSON}';
    
    
    if(editviewinfojsonobj!=null&&editviewinfojsonobj!=undefined&&editviewinfojsonobj!=''){
    	var fieldinfoobjs=  eval('('+ editviewinfojsonobj +')')?eval('('+ editviewinfojsonobj +')'):JSON.parse(editviewinfojsonobj);
   	}
    Listpagepopupobj.fields=fieldinfoobjs;
   
    function setObjects() 
    {ldelim}
        availListObj=getObj("availList")
        selectedColumnsObj=getObj("selectedColumns")
    {rdelim}

    function addColumn() 
    {ldelim}
    	setObjects();
        for (i=0;i<selectedColumnsObj.length;i++) 
        {ldelim}
            selectedColumnsObj.options[i].selected=false
        {rdelim}

        for (i=0;i<availListObj.length;i++) 
        {ldelim}
            if (availListObj.options[i].selected==true) 
            {ldelim}            	
            	var rowFound=false;
            	var existingObj=null;
                for (j=0;j<selectedColumnsObj.length;j++) 
                {ldelim}
                    if (selectedColumnsObj.options[j].value==availListObj.options[i].value) 
                    {ldelim}
                        rowFound=true
                        existingObj=selectedColumnsObj.options[j]
                        break
                    {rdelim}
                {rdelim}

                if (rowFound!=true) 
                {ldelim}
                    var newColObj=document.createElement("OPTION")
                    newColObj.value=availListObj.options[i].value
                    if (browser_ie) newColObj.innerText=availListObj.options[i].innerText
                    else if (browser_nn4 || browser_nn6) newColObj.text=availListObj.options[i].text
                    selectedColumnsObj.appendChild(newColObj)
                    availListObj.options[i].selected=false
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

    function delColumn() 
    {ldelim}
    	setObjects();
        for (i=selectedColumnsObj.options.length;i>0;i--) 
        {ldelim}
            if (selectedColumnsObj.options.selectedIndex>=0)
            selectedColumnsObj.remove(selectedColumnsObj.options.selectedIndex)
        {rdelim}
    {rdelim}
    
    function formSelectColumnString()
    {ldelim}
            var selectedColStr = "";
            setObjects();
            for (i=0;i<selectedColumnsObj.options.length;i++) 
            {ldelim}
                selectedColStr += selectedColumnsObj.options[i].value + ",";
            {rdelim}
            if (selectedColStr == "")
            {ldelim}
                confirm_str = '{'SELECTLEASTONEFIELD'|@getFixedLabel}';
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            	return false;
            {rdelim}
           	var _module = document.mergeDuplicates.module.value;
    		var _action = "FindDuplicateRecords";
    		var url = 'index.php?module='+_module+'&action='+_module+'Ajax&file='+_action+'&selectedColumnsString='+selectedColStr+'&get_rows=yes';
            {literal}
            ldAjax(url,{},function(data){
                if(data.code=='-1')
                {
                     RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                    return false;
                }
               var popupobj= CrmPopup.load(data.result.title,"","","950",_module,"","","","");
               CrmPopup.setPopupobjHtmlContent_scroll(popupobj,data.result.content);
               
                mergeSelect();
				DelProgressObjs();
            })
            {/literal}
	
        return true;
    {rdelim}
	setObjects();		
</script>	
<script language="javascript" type="text/javascript">
var tmpstr='{$DATETIMESTR}';
var datetimestr=  eval('('+ tmpstr +')')?eval('('+ tmpstr +')'):JSON.parse(tmpstr);
var searchtype_btn = '';
var noneLabel;
{literal}
	
{/literal}
</script>

<script language="javascript">
	function checkgroup()
	{ldelim}
	  if($("group_checkbox").checked)
	  {ldelim}
	  document.change_ownerform_name.lead_group_owner.style.display = "block";
	  document.change_ownerform_name.lead_owner.style.display = "none";
	  {rdelim}
	  else
	  {ldelim}
	  document.change_ownerform_name.lead_owner.style.display = "block";
	  document.change_ownerform_name.lead_group_owner.style.display = "none";
	  {rdelim}
	{rdelim}

	function getUrlString(searchtype)
	{ldelim}
		var popupobj=CrmPopup.getPopupObj("last");
		gPopupAlphaSearchUrl = '';

		if(document.getElementById("SmOwnerSearchScope")!=null)
			var searchScope= encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
		else
			var searchScope='';
		var urlstring = '';
     
		if(searchtype == 'Basic')
		{ldelim}
			search_fld_val= CrmPopup.findHtmlobj(popupobj.divid,"search_field").val();
           
			search_txt_val= encodeURIComponent(CrmPopup.findHtmlobj(popupobj.divid,'search_text').val());
			var p_tab = document.getElementsByName("parenttab");
			urlstring = 'search_field='+search_fld_val+'&searchtype=BasicSearch&search_text='+search_txt_val+'&';
			urlstring=urlstring+'SearchScope='+searchScope+'&';
			//urlstring = urlstring + 'parenttab='+p_tab[0].value+ '&';
		   
			urlstring= urlstring+'viewid='+document.getElementById("viewname").value+'&';
			urlstring= urlstring+'viewname='+document.getElementById("viewname").value+'&';
		{rdelim}
		else if(searchtype == 'Advanced')
		{ldelim}
         
				if(!checkAdvancedFilter()) return false;
              
				var advft_criteria = $('advft_criteria').value;
				var advft_criteria_groups = $('advft_criteria_groups').value;
				urlstring += '&advft_criteria='+encodeURIComponent(advft_criteria)+'&advft_criteria_groups='+advft_criteria_groups+'&';
				urlstring=urlstring+'SearchScope='+searchScope+'&';
			   
				urlstring= urlstring+'viewid='+document.getElementById("viewname").value+'&';
				urlstring= urlstring+'viewname='+document.getElementById("viewname").value+'&';
				urlstring += 'searchtype=advance&'
		{rdelim}
		// @edit:dong @date:2020/08/24 @reason: 添加平铺查找
		else if(searchtype == 'Tiled')
		{ldelim}
			if(!tiled_checkAdvancedFilter()) return false;
			var tiledsearch_criteria = $('tiledsearch_criteria').value;
			var tiledsearch_criteria_groups = $('tiledsearch_criteria_groups').value;
			urlstring += '&advft_criteria='+encodeURIComponent(tiledsearch_criteria)+'&advft_criteria_groups='+tiledsearch_criteria_groups+'&';
			urlstring=urlstring+'SearchScope='+searchScope+'&';

			urlstring= urlstring+'viewid='+document.getElementById("viewname").value+'&';
			urlstring= urlstring+'viewname='+document.getElementById("viewname").value+'&';
			urlstring += 'searchtype=tiled&'
		{rdelim}
		/**
		 * 搜索条件，增加wareid仓库ID条件
		 * @reason 0012618 库存台帐：选择任意一个仓库的页签，然后鼠标点击数据分类“全部”，结果查出的是【全部仓库】的台帐库存数据
		 * @author Tujt 2014-11-19
		 */
		var wareid = 0;
		if(document.getElementById('wareid') != undefined && document.getElementById('wareid').value > 0){ldelim}
			wareid = document.getElementById("wareid").value;
	    {rdelim}
		urlstring += 'wareid='+wareid+'&';
		var module = '{$MODULE}';
		if(module == 'Approve'){ldelim}
			if(ld('#fromapprovemodule') != undefined){ldelim}
				urlstring += '&fromapprovemodule='+ld('#fromapprovemodule').val()+'&';
			{rdelim}
			if(ld('#approvestatus') != undefined){ldelim}
				urlstring += '&approvestatus='+ld('#approvestatus').val()+'&';
			{rdelim}
		{rdelim}
		return urlstring;
	{rdelim}

	function callSearch(searchtype)
	{ldelim}
		var popupobj=CrmPopup.getPopupObj("last");
		var urlstring = getUrlString(searchtype);
        if(urlstring==false){
            return false;
        }
		searchtype_btn = searchtype;
      
		var divid='ListViewContents';
		if(module=='Users')
		{ldelim}
			divid='ListViewContents';
		{rdelim}
		// @edit:dong @date:2020/11/09 @reason: bug0043159 增加属性 数据分类转为模块 搜索后数据分类继续可用。
		urlstring  +=  'query=true&file=index&module={$MODULE}&action={$MODULE}Ajax&ajax=true&search=true';
		if (searchtype == 'Advanced' )
		{ldelim}
			var prevpopupobj=CrmPopup.getPopupObj("lastprev");
			if(typeof prevpopupobj != 'undefined')
				var searchfrom=prevpopupobj.type;
		{rdelim}
		else
		{ldelim}
			var searchfrom=popupobj.type;
		{rdelim}
		urlstring += '&searchfrom='+searchfrom;

		var listview_page=new ListView_Page(popupobj.module,urlstring,divid);
		listview_page.callback_fun=function()
		{ldelim}
				popupobj.CancelEvent();
				popupobj=CrmPopup.getPopupObj("last");
				popupobj.searchtype=searchtype;
                setContentHeight(popupobj.module);//计算内容高度
			   popupobj.listresizeobj.setReiszeTable_Init(popupobj.module,'ajax');

			// @edit:dong @date:2020/08/19 @reason: general 以改为jquery赋值 不需要再次执行script
            // //重新给listpageurl变量赋值
			// var scriptTags = document.getElementById(divid).getElementsByTagName("script");
			// for(var i = 0; i< scriptTags.length; i++){
			// 			var scriptTag = scriptTags[i];
			// 			eval(scriptTag.innerHTML);
			// }

			//if(module == 'Accounts'){
			 //edit:can 20200819 42443: （61mis.com/kfbcrm）（客户问题：唐山通乐）电话小管家>联系人模块列表界面>基本查找：输入值进行搜索，搜索后“联系人手机”字段的电话小图标没有显示出来。（需要补丁）
				IsFrameElement();
			// }
		
		{rdelim}
	     listview_page.page();
	    
	        //alert(urlstring +'query=true&file=index&module={$MODULE}&action={$MODULE}Ajax&ajax=true&search=true');
		return false
	{rdelim}
	callSearch.funname='callSearch';

	
</script>
<div id="searchingUI" style="display:none;text-align:center;">
    <img src="{'searching.gif'|@lingdang_imageurl:$THEME}" alt="{$APP.LBL_SEARCHING}"  title="{$APP.LBL_SEARCHING}">
</div>
<input type="hidden" name="oem_crm" id="oem_crm" value="{'oem_crm'|@getCommonVersion}" />

<table border=0 cellspacing=0 cellpadding=0 width=100% align=center>
    <tr>
    	{if $MODULE eq 'Users'}
        <td valign="top" width="260" class="user-left-td">
			{assign var='editpermit' value="Users"|@isPermitted:"EditView"  }
			{assign var='createpermit' value='Users'|@isPermitted:"Create" }
			{assign var='delpermit' value='Users'|@isPermitted:"Delete"}
			{if $ISKEHU neq 'yes'}
            	<div class="user-abutton user-left-div">
	                {if $editpermit  eq 'yes'}
	                    <a href="javascript:;" onclick="Op_UserGroup.EditGroup()" {if $delpermit eq 'yes'|| $createpermit eq 'yes'} style="border-right: #DBDBDB 1px solid" {/if}><span>{'EDITGROUP'|@getFixedLabel}</span></a>
	                {/if}
	                {if  $createpermit eq 'yes'}
	                    <a href="javascript:;" onclick="Op_UserGroup.AddGroup()" {if $delpermit eq 'yes'} style="border-right: #DBDBDB 1px solid" {/if}><span>{'NEWSUBGROUP'|@getFixedLabel}</span></a>
	                {/if}
	                {if $delpermit eq 'yes'}
	                    <a href="javascript:;" onclick="Op_UserGroup.deleteGroup()"><span>{'DELETEGROUP'|@getFixedLabel}</span></a>
	                {/if}
	             </div>
            {else}
            	<div style="font-size:16px;padding-top: 10px;padding-bottom: 10px;line-height: 20px;text-align: center;background-color: #F9FAFC;border-bottom: 1px #eee solid;">部门成员管理</div>
			{/if}
        	{$GROUPTREEHTML}
        </td>
        <td valign="top" >
      	{else}
        <td valign="top" width="100%" >
      	{/if}
		    {if $SEATCH_INPUT.searchtype == 'advance'}
		    <div id="advSearch" style="display:inline;">
		        <script language="JavaScript" type="text/javascript" src="include/js/search.js"></script>
		    {else}
			<div id="advSearch" style="display:none;">
		    {/if}
			    <input type="hidden" value="{$BATCHNUM}" id='batchnum' />
			    <form name="advSearch" method="post" action="index.php" onSubmit="return callSearch('Advanced');">
			    	<input name="publicaccountstatus" id="publicaccountstatus" type="hidden" value="{$PUBLICACCOUNTSTATUS}">
			    	<input name="buttontype" id="buttontype" type="hidden" value="{$BUTTONTYPE}">
				</form>
			</div>

			<div id="mergeDup" class="D_pop_box LdPopWidth600px" style="display:none;"></div>	 
	   
            <div id="ListViewContents" style="width:100%;">
				{include file="Channel_ListViewEntries.tpl"}
            </div>
        </td>
    </tr>
</table>

<!--
更新操作
edit：lmx
date：20140219
reason：产品序时簿界面新增复制按钮表单
-->
<form  action="index.php"  method="POST" name="CopyDetailView">
<input type="hidden" value="" name="return_module">
<input type="hidden" value="" name="return_action">
<input type="hidden" value="" name="module">
<input type="hidden" value="" name="record">
<input type="hidden" name="action">
<input type="hidden" value="" name="isDuplicate">
</form>

<div id="dv_listhighersearch" style="display:none;max-height:400px;" class="LdPopWidth800px">
	<div class="E_pop_tit" id="dv_listhighersearch_head" style="cursor:move">
		<strong class="E_ptita">{'CUSTOMIZESEARCH'|@getFixedLabel}</strong>
		<button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" id="dv_listhighersearch_imgclose"/>
	</div>
    <table cellpadding="2" cellspacing="0" width="100%" align="center" border=0>
		<tr>
			<td align="center" class="small pad0" width=90% >
				{include file='AdvanceFilter.tpl' SOURCE='customview' PAGEMODE='list' COLUMNS_BLOCK=$FIELDNAMES}
			</td>
		</tr>
	</table>
	<div class="E_pbtn">
        <input name="button" onClick="callSearch('Advanced');" class="E_pbtnok" value="{'FINDNOW'|@getFixedLabel}" type="button">
        <span>&nbsp;</span>
        <input class="E_pbtncancel" value={"CANCEL"|@getFixedLabel}  type="button" onclick="hidedv_listhighersearch();">
    </div>
</div>
{if $senioruserid neq ""}
    <input type="hidden" id="scope_senioruserids" value="{$senioruserid}"/>
{/if}
<div class="List3Box">
<!--两秒自动消失的提示，单据编号重复的提示-->

</div>
<script>
	var firstVisit = '{$FIRSTVISIT}';
   var popupobj=CrmPopup.getPopupObj('last');
    popupobj.listresizeobj=new List_ResizeTable(popupobj);
    setContentHeight(popupobj.module);//计算内容高度 
    
    var modulebillduptip='{$MODULEBILLNOTIP}';
	var version_account = '{$VERSION_ACCOUNT}';
    var FieldWidthSetting='{$FieldWidthSetting}';
   var FieldWidthSettingobj;
    var ReleanAccountReason='{"RELEASEACCOUNTTREASON"|@getFixedLabel}';
    var createpopdividendorder='{$CREATEPOPDIVIDENDORDER}';
    var recordid='{$RECORDID}';
	var module = '{$MODULE}';
    var listeditpageobj=new ListEditPagePopup(popupobj);
    listeditpageobj.setListEditEvent();
	var searchtype = '{$SEATCH_INPUT.searchtype}';
	if(searchtype == 'advance'){
		setListButtonColor("categoryAdvsear");
	}
    var haigersavetip='{$HaigeSaveTip}';
    {literal}
     if(FieldWidthSetting!='')
    {
        
            var FieldWidthSettingobj=eval('('+ FieldWidthSetting +')')?eval('('+ FieldWidthSetting +')'):JSON.parse(FieldWidthSetting);
         
    }
    //设置div宽度
    popupobj.listresizeobj.setReiszeTable_Init(module,'');
    if(module=='Users'){
        
      
    Op_UserGroup.setEvent();
    Op_UserGroup.init();


    }
    //编号重复的提示
    ld(function(){
		if(module == 'HelpDesk')
			bw_sync();
	
        // 用户首次访问社交推广模块 展示帮助信息
		if(module =='SocialPromotion' && firstVisit != '1'){
			userFristVisit(module)
		}
	})
   if(haigersavetip!=''&&haigersavetip!=undefined)
          RemindsMsg("","LdPopWidth400px","",module,"yes","yes",haigersavetip);
     //编号重复的提示
   // setdupBillNoTip(modulebillduptip,Listpagepopupobj.fields);
    function setListButtonColor(liid)
    {
        // ld("#"+liid).parent().find("div").css("background-color","");
        ld("#"+liid).parent().find('li[tag=firstnode]').each(function(){
            if(!empty(ld(this).attr('id'))){
                ld("#"+ld(this).attr('id')).find("b").css({'background-position':''});
                ld("#"+ld(this).attr('id')).find("a").css("color","");
            }
        });
        setTimeout(function(){ld('#dv_listbasiscsearch ').find('.txtBox').focus() }, 100)
    }

	function basicsearchPopup() {
		//基本查询弹出框
		setListButtonColor("categorysear");
		$("status").style.display = "none";
		var Popupobj = new ListBasicSearchPopup.load("", callSearch, "", "LdPopWidth400px", module, ['Basic'], btn_findnow_label, "", "");

		Popupobj.show(ld("div[name=dv_listbasicsearch]").html());
	}

	function HighersearchPopup() {
		setListButtonColor("categoryAdvsear");
		$("status").style.display = "none";
		var Popupobj = new ListHigherSearchPopup.load("", callSearch, "", "LdPopWidth800px", module, "", "", "", "");
		Popupobj.show();
	}

	function TiledSearchShow() {
		//进度条隐藏
		$("status").style.display = "none";
		//搜索div展示
		ld('#tiledSearch').toggle();
		//重置列表区域高度
		if(ld('#tiledSearch').is(":hidden")){
			chang_content_table_divid_height('hidden')
		}else{
			chang_content_table_divid_height('show')
		}
		//chj 2020/11/9 43166: 点击标签查找，再点击平铺查找，界面异常
		var popupobj=CrmPopup.getPopupObj("last");
		if(ld("#"+popupobj.divid+" [name=listtag_div]").css('display') != 'none'){
			ld("#"+popupobj.divid+" [name=listtag_div]").hide();
		}
	}
    {/literal}

    function disableStyle(id)
    {ldelim}basicsearchPopup
    	if(browser_ie && (gBrowserAgent.indexOf("msie 7.")!=-1))//for IE 7
            {ldelim}
                    //document.body.removeChild($('freeze'));
            {rdelim}else if(browser_ie)
            {ldelim}
                 var oDivfreeze = $('divId');
                 oDivfreeze.style.height = document.documentElement['clientHeight'] + 'px';
            {rdelim}
            $('divId').style.display = 'block';
    {rdelim}
     function createDividendOrder(recordid)
     {ldelim}
       
      NewDividendOrder(null,'CreateDividendOrder',recordid);
     {rdelim}
     if(createpopdividendorder=='yes')
     {ldelim}
      
        createDividendOrder(recordid);
    {rdelim}
    getJsScript('include/js/ldcrm.category.js',function(){ldelim}
        setContentHeight('{$MODULE}');//计算内容高度
    {rdelim});
	IsFrameElement();
  
    function hidedv_listhighersearch(){ldelim}
      //  ld('#dv_listhighersearch').css("display",'none');
      var popupobj=CrmPopup.getPopupObj("last");
      popupobj.CancelEvent();
    {rdelim}  

    if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
    {ldelim}
        //通讯录
        cls_wxOpenDataobj.bindAllOpenData();
    {rdelim}

   // 用户首次访问模块 展示帮助信息
   function userFristVisit(module) {ldelim}
	   var that = this;
	   var ajaxurl = 'index.php?module='+module+'&action='+module+'Ajax&file=FristVisit';
	   ldAjax(ajaxurl,'', function (data) {
		   var popupobj = CrmPopup.load(data.result.title, that.clickOktext, "", 800, module, "", data.result.oktext, "", '');
		   CrmPopup.setPopupobjHtmlContent_scroll(popupobj,data.result.content);
		   // console.log(data.result.fieldValue)
		   DelProgressObjs();
	   })
	   that.clickOktext = function () {
		   popupobj.CancelEvent();
	   }
	   {rdelim}
</script>   