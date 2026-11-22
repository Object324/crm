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
    AjaxJSPage( "cls_ModuleTree_js", 'include/js/cls_ModuleTree.js');
</script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/{$MODULE}/{$MODULE}.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/CustomForm01/CustomForm01_calendar.js?v={$GLOBALMINVERSION}"></script>
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

    var havelistPopupObj = 'no';

    // BUG20240614-51 先进入bug管理模块列表，点击消息进入消息模块列表，点击bug管理单据的相关对象超链接，推进成功后，消息列表刷新为bug管理列表
    if ('{$MODULE}' == 'Reminds'){
        CrmPopup.global_listPopupObj = [];
    }
    if(CrmPopup.global_listPopupObj.length > 0){
        for(let i = 0;i<CrmPopup.global_listPopupObj.length;i++){
            if(CrmPopup.global_listPopupObj[i].module == '{$MODULE}' && CrmPopup.global_listPopupObj[i].pagetype == 'listpage'){
                havelistPopupObj = 'yes';
            }
        }
    }
    if(havelistPopupObj == 'no'){
        var Listpagepopupobj=new CrmPopup();
        Listpagepopupobj.type=ListPagePopup.type;
        Listpagepopupobj.divid='pagecontent1';
        Listpagepopupobj.searchtype="";//基本查询和高级查询，32156: 单据列表：设置高级查询后，切换查看范围时，不清空高级查询条件
        Listpagepopupobj.url='{$LISTPAGEURL}';
        Listpagepopupobj.module='{$MODULE}';
        {if $MODULE eq 'Users'}
        Listpagepopupobj.user_type='{$user_type}';
        {/if}
        Listpagepopupobj.alloweditpage='{$alloweditpage}';// XUQIU20240709-03 后台设置-系统参数设置，系统参数增加“列表和详情页是否启用小编辑功能”

        if(Listpagepopupobj.module=='Approve')
        {
            Listpagepopupobj.module='{$FROMAPPROVEMODULE}';
            Listpagepopupobj.frommodule='Approve';

        }
        var current_language = "{$current_language}";


        CrmPopup.global_listPopupObj.push(Listpagepopupobj);
        Listpagepopupobj.pagetype=ListPagePopup.pagetype;//
        //edit: xll XUQIU1001172 2023/02/23 相关信息栏打开新页签
        isNewPage();
    }
</script>
{if $MODULE eq 'Calendar'}
    <script type="text/javascript" src="modules/Calendar/Calendar.js"></script>
    <script type="text/javascript" src="modules/Calendar/script.js"></script>
{elseif $MODULE neq 'Home' && $MODULE neq 'PickList' && $MODULE neq 'ReportLog'
&& $MODULE neq 'EmailListtmp' && $MODULE neq 'CommunicationLog'
&& $MODULE neq 'Comprehensivereport' && $MODULE neq 'Administration' && $MODULE neq 'MassSMS'}
    {*	49063: （http://211.149.136.145:85/crm [^]）亚丫丁公寓（客户）；进入合同订单详情页面，在相关页签里面找到收款计划，点击新建按钮没有任何反应，导致无法新建收款计划(登录后直接进入链接模块会由于未加载模块js报错)*}

{/if}


<script language="JavaScript" type="text/JavaScript">
    var moveupLinkObj,moveupDisabledObj,movedownLinkObj,movedownDisabledObj;



    var editviewinfojsonobj=JSON.stringify({$FIELDINFOJSON});


    if(editviewinfojsonobj!=null&&editviewinfojsonobj!=undefined&&editviewinfojsonobj!=''){
        var fieldinfoobjs=  eval('('+ editviewinfojsonobj +')')?eval('('+ editviewinfojsonobj +')'):JSON.parse(editviewinfojsonobj);
    }
    Listpagepopupobj.fields=fieldinfoobjs;
    //获取分录字段信息
    var detailfieldjsonobj=JSON.stringify({$DETAIILFIELDINFOJSON});
    var detailfieldinfoobjs = [];
    if(detailfieldjsonobj!=null&&detailfieldjsonobj!=undefined&&detailfieldjsonobj!=''){
        detailfieldinfoobjs=  eval('('+ detailfieldjsonobj +')')?eval('('+ detailfieldjsonobj +')'):JSON.parse(detailfieldjsonobj);
    }
    Listpagepopupobj.detailfields=detailfieldinfoobjs;

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
        var url = 'index.php?module='+_module+'&action='+_module+'Ajax&file='+_action+'&selectedColumnsString='+selectedColStr+'&get_rows=yes&duplicateviewwidth=950';
        {literal}
        ldAjax(url,'',function(data){
            if(data.code=='-1')
            {
                RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                return false;
            }
            var popupobj= CrmPopup.load(data.result.title,"","","950",_module,"","","","");
            popupobj.createHeadHtml=function() {
                this.popupheadhtml='<div class="E_pop_tit" id="'+this.divid+'_head" style="cursor:move">';
                this.popupheadhtml+='<strong class="E_ptita">'+this.headtitle+'</strong>';

                this.popupheadhtml+='<button class="ld-fonticon ld-fonticon-close" value="'+arrJsPopLabel['LBL_CLOSE']+'" title="'+arrJsPopLabel['LBL_CLOSE']+'" id="'+this.divid+'_imgclose"></button>';
                this.popupheadhtml+='<a style="float: right;" href="javascript:;" name="ResetListWidth">' +arrJsPopLabel['ResetListWidth']+ '</a>';
                this.popupheadhtml+='</div>';
            }
            CrmPopup.setPopupobjHtmlContent_scroll(popupobj,data.result.content);
            popupobj.headname='Findduplicates';
            popupobj.center();

            // 需要去掉的给高度
            popupobj.reduceBodyHeight = 0;
            // 设置内容最大高度
            popupobj.setPopBodyMaxHeight(".dvpopupsroll");

            //恢复预设列宽
            ld("#"+popupobj.divid).find(' [name=ResetListWidth]').unbind('click').on('click',function(){
                var popupobj=CrmPopup.getPopupObj("last");
                var module = popupobj.module;
                var viewid = ld("#"+popupobj.divid).find(' [name=duplicate_viewid]').val();
                var url = 'index.php?module=Users&action=UsersAjax&file=ResetListWidth&frommodule='+module+'&viewname='+viewid+'&type=mergduplicate_customview';
                ldAjaxHtmlNoProgress(url,{},function(rest){
                    if (empty(rest)){
                        DelProgressObjs();
                        return false;
                    }
                    if (rest.indexOf('success')>=0 ) {
                        DelProgressObjs();
                        var pagenumobj = ld("#"+popupobj.divid).find(" [name=pagenum]");
                        ld(pagenumobj).change();
                        //zkt 20220930 BUG0057278客户=自动查重合并弹出界面，点击”恢复预设列宽“，此时已经重置成功，不需要”取消“按钮了
                        // RemindsMsg("", "LdPopWidth400px", module, "yes", "", arrJsPopLabel['ResetSuccess']);
                        MessagePopup.TipZero_success(arrJsPopLabel['ResetSuccess']);
                    }
                })
            });

            //zkt 20220928 XUQIU1000659  自动查重合并，合并弹出层中显示列增加拖动功能（李发林）
            //加载弹出框列表
            ListView_Page.fullwidth_divid = 'hdScrolllistentries_yy';
            ListView_Page.header_table_divid='resize_header_table_divid';//列头table所在div的id
            ListView_Page.header_tableid='resize_header_tableid';//列头所在table的id

            ListView_Page.content_tableid="resize_content_tableid";//内容所在table的id
            ListView_Page.content_table_divid="resize_content_table_divid";//内容table所在div的id
            var listresizeobj=new List_ResizeTable(popupobj);
            popupobj.listresizeobj=listresizeobj;
            listresizeobj.setPopupResizeTable_Init(_module, '');
            //zxm 20230406 BUG0063113 kfbcrm 联系人----自动查重合并---按照联系人名称查重----查出数据后，联系人手机字段不显示电话符号----任意点击一条合并后，电话符号才显示
            IsFrameElement();
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
            //zxm  20230327 序时簿列表基本查找样式修改了 不是弹出框了
            //search_fld_val= CrmPopup.findHtmlobj(popupobj.divid,"search_field").val();
            search_fld_val= ld("select[name=search_field]").val();
            //wym XUQIU1001090 单据序时簿列表界面，基本查找增加“全部字段”功能
            if(search_fld_val=='all'){
                var optionvalues = ld("select[name=search_field]").eq(0).find(' option').map(function() {
                    if(ld(this).val()!='all'){
                        return ld(this).val();
                    }
                }).get();
                var search_fld_val_arr=JSON.stringify(optionvalues);
                urlstring += 'search_field_arr='+search_fld_val_arr;
            }
            //zkt 20220614 BUG0052740（示图）单据编号值，直接从微信复制出来的，从表面看是空格，实际是转义字符，导致搜索不到
            //var search_text_value = trim(CrmPopup.findHtmlobj(popupobj.divid,'search_text').val());
            var search_text_value = trim(ld("input[name=search_text]").val());
            //edit:duan date:2024/11/4 reason:往后台传特殊字符时,用JSON.stringify 方法进行转义
            search_text_value = JSON.stringify(search_text_value).slice(1, -1); // 去掉外面的引号

            search_txt_val= encodeURIComponent(search_text_value);

            urlstring += '&search_field='+search_fld_val+'&searchtype=BasicSearch&search_text='+search_txt_val+'&';
            urlstring=urlstring+'SearchScope='+searchScope+'&';
            //urlstring = urlstring + 'parenttab='+p_tab[0].value+ '&';

            urlstring= urlstring+'viewid='+document.getElementById("viewname").value+'&';
            urlstring= urlstring+'viewname='+document.getElementById("viewname").value+'&';
            {rdelim}
        else if(searchtype == 'Advanced')
        {ldelim}
            var advft_criteria = '';
            var advft_criteria_groups = '';
            if(popupobj.advanceFilterObj) {

                var advanceFilterobj = popupobj.advanceFilterObj;
                if (advanceFilterobj != undefined && !advanceFilterobj.checkAdvancedFilter()) {
                    return false;
                }

                advft_criteria = advanceFilterobj.advft_criteria;
                if(advft_criteria!='')
                {ldelim}
                    advft_criteria_groups = advanceFilterobj.advft_criteria_groups;
                    {rdelim}
            }
            else if(popupobj.advft_criteria){
                advft_criteria = popupobj.advft_criteria;
                if(advft_criteria!='')
                {ldelim}
                    advft_criteria_groups = popupobj.advft_criteria_groups;
                    {rdelim}
            }
            if(advft_criteria != ''){
                urlstring += 'advft_criteria='+encodeURIComponent(advft_criteria)+'&advft_criteria_groups='+encodeURIComponent(advft_criteria_groups)+'&';
            }

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
        // edit: xll 2024/11/22 XUQIU1001599 单据序时簿列表界面，高级查找增加“平铺”和“清除筛选值”功能
        else if(searchtype === 'AdvanceTiled')
        {ldelim}
            var listPopupObj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
            if(listPopupObj && listPopupObj.AdvanceFilterTiledObj) {
                var advanTiledObj = listPopupObj.AdvanceFilterTiledObj;
                if(advanTiledObj && !advanTiledObj.checkAdvancedFilter() ){
                    return false;
                }
                advft_criteria = advanTiledObj.getSearchAdvftCriteria();
                if(advft_criteria!='')
                {ldelim}
                    advft_criteria_groups = advanTiledObj.advft_criteria_groups;
                    {rdelim}
                if(advft_criteria != ''){ldelim}
                    urlstring += 'advft_criteria='+encodeURIComponent(advft_criteria)+'&advft_criteria_groups='+advft_criteria_groups+'&';
                    {rdelim}

                urlstring=urlstring+'SearchScope='+searchScope+'&';

                urlstring= urlstring+'viewid='+document.getElementById("viewname").value+'&';
                urlstring= urlstring+'viewname='+document.getElementById("viewname").value+'&';
                urlstring += 'searchtype=advance&'
            }
            {rdelim}


        if (searchtype == 'Advanced' )
        {ldelim}
            var prevpopupobj=CrmPopup.getPopupObj("lastprev");
            if(typeof prevpopupobj != 'undefined') //BUG20240108-58
                var searchfrom=prevpopupobj.type;
            {rdelim}
        else
        {ldelim}
            var searchfrom=popupobj.type;
            {rdelim}
        urlstring += 'searchfrom='+searchfrom+'&';
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
        var listPopupobj = CrmPopup.getlastPopupObjByPageType('listpage');
        if(module == 'Users' && listPopupobj.user_type){
            urlstring += 'user_type='+listPopupobj.user_type+'&';
        }
        return urlstring;
        {rdelim}

    function callSearch(searchtype)
    {ldelim}
        var popupobj=CrmPopup.getPopupObj("last");
        var urlstring = getUrlString(searchtype);
        if(urlstring==false){
            return false;
        }
        if(document.getElementById('listview_advanced') != undefined){
            document.getElementById('listview_advanced').disabled = true;
        }

        save_search_history(urlstring,popupobj.module);

        //alert(ld("#"+prevpopupobj.divid+' [name=search_field]').val());
        searchtype_btn = searchtype;

        var divid='ListViewContents';
        if(module=='Users')
        {ldelim}
            divid='ListViewContents';
            {rdelim}
        // @edit:dong @date:2020/11/09 @reason: bug0043159 增加属性 数据分类转为模块 搜索后数据分类继续可用。
        urlstring  +=  'query=true&file=index&module={$MODULE}&action={$MODULE}Ajax&ajax=true&search=true';

        if(document.getElementById("isshowModuleListTree")!=undefined&&document.getElementById("isshowModuleListTree").value=='yes')
        {ldelim}

            urlstring += "&isshowModuleListTree=yes";
            {rdelim}
        //平铺查找点击查找后平铺查找框不显示
        if(searchtype=='Tiled')
        {ldelim}
            if(ld("#"+popupobj.divid+" #Autohideafterfinding").length>0 && ld("#"+popupobj.divid+" #Autohideafterfinding").is(':checked') == true){
                urlstring += '&tiledSearchdisplay=none';
                ld("#"+popupobj.divid+' #tiledSearch').hide();
            }
            {rdelim}
        popupobj.searchtype = searchtype;
        if(searchtype == 'Advanced'){
            var prevpopupobj = CrmPopup.getPopupObj('lastprev');
            prevpopupobj.searchtype = searchtype;
        }
        var listview_page=new ListView_Page(popupobj.module,urlstring,divid);
        listview_page.callback_fun=function()
        {ldelim}
            if(document.getElementById('listview_advanced') != undefined){
                document.getElementById('listview_advanced').disabled = false;
            }
            {*zxm 20221206 基本查找不弹框
            if(searchtype=="Basic")*}
            {*{ldelim}*}
            {*    var prevpopupobj=CrmPopup.getPopupObj('lastprev');*}
            {*    ld("#"+prevpopupobj.divid+' [name=search_field]').val(ld("#"+popupobj.divid+' [name=search_field]').val());*}
            {*{rdelim}*}
            // popupobj.CancelEvent();
            popupobj=CrmPopup.getPopupObj("last");
            popupobj.searchtype=searchtype;


            popupobj.listresizeobj.setReiszeTable_Init(popupobj.module,'ajax');
            if(searchtype !='Tiled'){
                if(!ld('#tiledSearch').is(":hidden"))
                    TiledSearchShow();
            }
            // 亿海蓝问题 缩小屏幕之后再点搜索按钮 横向滚动条看不见了 往后挪一下等头部搜索框加载完再获取top会更准确
            if(popupobj.frommodule == 'Approve') {
                setContentHeight(popupobj.frommodule);//审批列表页面高度
            }else{
                setContentHeight(popupobj.module);//计算内容高度
            }

            //if(module == 'Accounts'){
            IsFrameElement();


            {rdelim}

        listview_page.page();
        if(searchtype=='Basic'){
            setShowOrHideClearIcon();
        }else{
            if (popupobj.advanceFilter=='yes' && popupobj.advanceFilterObj != undefined){
                popupobj.CancelEvent();
            }
        }
        //alert(urlstring +'query=true&file=index&module={$MODULE}&action={$MODULE}Ajax&ajax=true&search=true');
        return false
        {rdelim}
    callSearch.funname='callSearch';


</script>
{if $MODULE eq 'Approve'}
    <!--41807: (61mis.com/kfbcrm)审批中心>待处理>选择“客户”>序时簿界面：点击右上角“>”下一页没反应，需要刷新浏览器才能用-->
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Approve/Approve.js?v={$GLOBALMINVERSION}"></script>
    {*	{include file='Approve/ListView_Header.tpl'}*}
{/if}
<div id="searchingUI" style="display:none;text-align:center;">
    <img src="{'searching.gif'|@lingdang_imageurl:$THEME}" alt="{$APP.LBL_SEARCHING}"  title="{$APP.LBL_SEARCHING}">
</div>

<input type="hidden" name="oem_crm" id="oem_crm" value="{'oem_crm'|@getCommonVersion}" />
{*hzx 20231215 列表页面页签优化*}
{*{if $MODULE == 'Stock' || $MODULE == 'OutboundOrder' || $MODULE == 'InventoryAccount' || $MODULE == 'InventoryQuery'|| $MODULE == 'Checks'}
	<input type="hidden" id="wareid" name="wareid" value="{$WAREHOUSEID}" />
	<div class="D_Tab_div_more tabHieght" id="tabWareHouse">
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		  <tr>
			<td valign="top" class="L">
				<ul class="Tab_div_more_ul">
					<li><a onclick="getWarehouse(0,this);return false;" {if $WAREHOUSEID eq 0} class="On on" {else} class="on" {/if} >{'ALLWAREHOUSE'|@getFixedLabel}</a></li>
					{foreach item=value from=$WAREHOUSES}
						{if $value.id eq $WAREHOUSEID}
							<li><a onclick="getWarehouse({$value.id},this);return false;" class="On" title="{$value.name}">{$value.name}</a></li>
						{else}
							<li><a onclick="getWarehouse({$value.id},this);return false;" title="{$value.name}">{$value.name}</a></li>
						{/if}
					{/foreach}
					{if $MOREWAREHOUSES|@count gt 0}
						{if $WAREHOUSEID neq ''}
							{assign var=c value='On'}
						{else}
							{assign var=c value='on'}
						{/if}
						<li><a id="morewarehouseid" class="{$c}">{'MORE'|@getFixedLabel}:</a></li>
					{/if}
				</ul>
				{if $MOREWAREHOUSES|@count gt 0}
					<div id="ware_select_more" class="tab-more">
						{include file='MoreWareHouseSelect.tpl'}
					</div>
				{/if}
			</td>
		  </tr>
		</table>
	</div>
{elseif $MODULE eq 'WorkSheet'}
    <input type="hidden" id="wareid" name="wareid" value="{$WAREHOUSEID}" />
	<div class="ld-ui-tabs" id="tabWareHouse">
		<ul class="ld-ui-tabs-nav">
			{foreach key=index item=value from=$ALLSTATUS}
				{if $index eq $STATU}
					<li class="ld-ui-tabs-active" onclick="getWorkSheetStatus('{$index}',this)"><a href="javascript:;" >{$value}</a></li>
				{else}
					<li onclick="getWorkSheetStatus('{$index}',this)"><a href="javascript:;" >{$value}</a></li>
				{/if}
			{/foreach}
		</ul>
	</div>
{elseif $MODULE eq 'WorkReportList'}

{/if}*}
<input name="viewmode" type="hidden" value="{$VIEWMODE}">
{if $SHOWKANBAN eq 'yes' && $VIEWMODE eq 'kanban' && ($MODULE eq 'Potentials' || $MODULE eq 'Project')}
    {include file='KanbanView.tpl'}
{else}
    <div id="ld-listview-screen" class="ld-listview-screen ld-bg-color">
        {include file='ListViewPageScreen.tpl'}
    </div>
    <table class="ld-drag-area" border=0 cellspacing=0 cellpadding=0 width=100% align=center>
        <tr>
            {if $MODULE eq 'Users'}
            <td valign="top" class="user-left-td">
                {assign var='editpermit' value="Users"|@isPermitted:"EditView"  }
                {assign var='createpermit' value='Users'|@isPermitted:"Create" }
                {assign var='delpermit' value='Users'|@isPermitted:"Delete"}
                {if $ISKEHU neq 'yes'}
                    {*<div class="user-abutton user-left-div">
                        {if $editpermit  eq 'yes'}
                            <a href="javascript:;" onclick="Op_UserGroup.EditGroup()" {if $delpermit eq 'yes'|| $createpermit eq 'yes'} style="border-right: #DBDBDB 1px solid" {/if}><span>{'EDITGROUP'|@getFixedLabel}</span></a>
                        {/if}
                        {if  $createpermit eq 'yes'}
                            <a href="javascript:;" onclick="Op_UserGroup.AddGroup()" {if $delpermit eq 'yes'} style="border-right: #DBDBDB 1px solid" {/if}><span>{'NEWSUBGROUP'|@getFixedLabel}</span></a>
                        {/if}
                        {if $delpermit eq 'yes'}
                            <a href="javascript:;" onclick="Op_UserGroup.deleteGroup()"><span>{'DELETEGROUP'|@getFixedLabel}</span></a>
                        {/if}
                     </div>*}
                    {*新建、编辑、删除部门子菜单*}
                    <div id="user-libutton-box" class="user-libutton-box" style="display: none;overflow: hidden;height: auto;">
                        <div class="user-libutton-body">
                            <ul class="user-libutton-list">
                                {if $editpermit  eq 'yes'}
                                    <li><a href="javascript:;" name="editgroup"><span>{'EDITGROUP'|@getFixedLabel}</span></a></li>
                                {/if}
                                {if  $createpermit eq 'yes'}
                                    <li><a href="javascript:;" name="addgroup"><span>{'NEWSUBGROUP'|@getFixedLabel}</span></a></li>
                                {/if}
                                {if $delpermit eq 'yes'}
                                    <li><a href="javascript:;" name="deletegroup"><span>{'DELETEGROUP'|@getFixedLabel}</span></a></li>
                                {/if}
                                {if $IS_ADMIN eq 1}
                                    <li><a href="javascript:;" name="fieldSetting"><span>{'ACTIVITYFIELDSETTINGS'|@getFixedLabel}</span></a></li>
                                    <li><a href="javascript:;" name="hidegroup"><span>{'HIDEGROUP'|@getFixedLabel}</span></a></li>
                                    <li><a href="javascript:;" name="recovergroup"><span>{'RECOVERGROUP'|@getFixedLabel}</span></a></li>
                                {/if}
                                {* zsk2024/5/24XUQIU1001465 成员管理，组织架构->根部门，更多下拉选项中增加“字段设置”参数 增加字段设置菜单项*}
                            </ul>
                        </div>
                    </div>
                {else}
                    <div id="users_left_top_title" style="font-size:16px;padding-top: 10px;padding-bottom: 10px;line-height: 20px;text-align: center;background-color: #F9FAFC;border-bottom: 1px #eee solid;{if $MODULElISTTREE.tree_expand eq 'no'}display:none;{/if}">部门成员管理</div>
                {/if}
                <div>
                    <span id="listviewtreeopen" class="listviewtreeopen {if $CURRENT_USER->user_type == 'prm'}treeinner{/if}" data-tip="" data-direction="right" data-type="position"></span>
                    <div id="structuretree" class="webkit-scrollbar" style="width:{$MODULElISTTREE.tree_width}px;{if $MODULElISTTREE.tree_expand eq 'no'}display:none;{/if}">
                        {$GROUPTREEHTML}
                    </div>
                    <div class="sidebar-drag"></div>
                </div>
            </td>
            {*<td class="tip-items-list" data-tip="" data-direction="right" data-type="position">
                <span class="tree-closeopen tree-close"></span>
            </td>*}
            <td valign="top">
                {elseif $MODULElISTTREE.enable eq 'yes'}
            <td valign="top" class="user-left-td" ">
            {include file="ModuleListTree.tpl"}
            <div class="sidebar-drag"></div>
            </td>
            {*<td class="tip-items-list" data-tip="" data-direction="right" data-type="position">
                <span class="tree-closeopen tree-close"></span>
            </td>*}
            <td valign="top">
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
                    </div>

                    <div id="mergeDup" class="D_pop_box LdPopWidth600px" style="display:none;"></div>

                    <input type="hidden" id="iskanbanshow" value="no" />
                    <div id="ListViewContents" style="width:100%;">
                        {if $MODULE eq 'Approve'}
                            <script type="text/javascript">

                                AjaxJSPage('{$FROMAPPROVEMODULE}'+"_js",'include/js/modules/'+'{$FROMAPPROVEMODULE}'+'/'+'{$FROMAPPROVEMODULE}'+'.js');
                            </script>
                            {if get_file_address($FROMAPPROVEMODULE,'ProductDetails') == true || get_file_address($MODULE,'DocumentsDetails') || get_file_address($FROMAPPROVEMODULE,'VendorsDetails') || get_file_address($FROMAPPROVEMODULE,'ContactsDetails')|| get_file_address($FROMAPPROVEMODULE,$FROMAPPROVEMODULE|cat:'DetailFieldsHtml')}
                                {include file="ProductListViewEntries.tpl"}

                            {else}
                                {include file="ListViewEntries.tpl"}
                            {/if}
                        {else}
                            {if get_file_address($MODULE,'ProductDetails') == true || $MODULE eq 'MarketSpread'|| get_file_address($MODULE,'DocumentsDetails') || get_file_address($MODULE,'AttachmentDetails') || get_file_address($MODULE,'VendorsDetails') || get_file_address($MODULE,'ContactsDetails')|| get_file_address($MODULE,$MODULE|cat:'DetailFieldsHtml')}
                                {include file="ProductListViewEntries.tpl"}
                                {*{else if $VERSION_ACCOUNT eq 'shenglawei' && $MODULE eq 'CustomForm01' && $customform01_type eq  'calendar'}
                                {include file="CustomForm01Calendar.tpl"}*}
                            {else}
                                {include file="ListViewEntries.tpl"}
                            {/if}
                        {/if}
                    </div>
            </td>
        </tr>
    </table>

    <!---基金->计提--->

    <div id="div_fund_accured_pop" class="D_pop_box LdPopWidth350px" style="display:none;">
        <div id="fund_accured_pop_content"></div>
    </div>

    <div id="delayaccount" class="D_pop_box LdPopWidth350px" style="display:none;width:30%;">
        <div id="delayaccount_form_div"></div>
    </div>

    <!--END-->
    <div id="printview" class="E_pop_box LdPopWidth350px" style="display:none;">
        <div class="E_pop_tit">
            <strong class="E_ptita">{'PRINT'|@getFixedLabel}</strong>
            <button class="ld-fonticon ld-fonticon-close" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('printview');"></button>
        </div>
        <div id="printview_form_div"></div>
    </div>
    <!--END-->
    <div id="productlistview" class="layerPopup" style="display:none;width:500px;">
        <table width="100%" border="0" cellpadding="3" cellspacing="0" class="layerHeadingULine">
            <tr id="productlistviewheading">
                <td class="layerPopupHeading" align="left" width="60%">表格设置</td>
                <td>&nbsp;</td>
                <td align="right" width="40%"><img onClick="fninvshnew('productlistview');" title="{'CLOSE'|@getFixedLabel}" alt="{'CLOSE'|@getFixedLabel}" style="cursor:pointer;" src="{'Close.png'|@lingdang_imageurl:$THEME}" align="absmiddle" border="0"></td>
            </tr>
        </table>
        <div id="productlistview_form_div"></div>

    </div>
    <!--END-->
    <div id="detialnationview" class="D_pop_box" style="display:none;width:750px;">
        <div id="detialnationview_div"></div>

    </div>
    <!-- END -->
    <!--END-->
    <div id="smssettings" class="D_pop_box" style="display:none;width:750px;">
        <div id="smssettings_div"></div>

    </div>
    <!-- END -->

    <!--如何创建派息单-->
    <div id="howTodevidend" style="display:none;">
        <div class="ld-titlename">
            {'How_to_create_devidend'|@getFixedLabel}
        </div>
        <div class="ld-public-content-small divPopOverflow">
            {'How_to_create_devidend_desc1'|@getFixedLabel}<br>
            {'How_to_create_devidend_desc2'|@getFixedLabel}<br>
            {'How_to_create_devidend_desc3'|@getFixedLabel}
        </div>
    </div>

    <!--如何退货-->
    <div id="howToReturn" style="display:none;">
        <div class="ld-titlename">
            {'HOWTOGOODS'|@getFixedLabel}
        </div>
        <div class="ld-public-content-small divPopOverflow">
            {'Returns_SalesOrder_allow_creation'|@getFixedLabel}；<br>
            {'wsfftntroboiotstroictbhrt'|@getFixedLabel}。
        </div>
    </div>
    <!--销售退款单如何退款-->
    <div id="howToCashBack" style="display:none;">
        <div class="ld-titlename">
            {'HOWTOCASHBACK'|@getFixedLabel}
        </div>
        <div class="ld-public-content-small divPopOverflow">
            {'THESALESREFUNDORDERISFORSALERETURNS'|@getFixedLabel}<br>
            {'WHENTHERETURNLISTISSOLD'|@getFixedLabel}
        </div>
    </div>
    <!--采购退款单如何退款-->
    <div id="howToPurchaseCashBack" style="display:none;">
        <div class="ld-titlename">
            {'HOWTOCASHBACK'|@getFixedLabel}
        </div>
        <div class="ld-public-content-small divPopOverflow">
            {'TPURCHASEREFUNDORDERISFORPURCHASEORDER'|@getFixedLabel}；<br>
            {'INORDERTOPURCHASEARETURNLIST'|@getFixedLabel}。
        </div>
    </div>
    <!---客户释放 GYQ1230-->
    <div id="ReleanseAccountDiv" class="E_pop_box LdPopWidth600px" style="display:none;">
        <div class="E_pop_tit">
            <strong class="E_ptita">{'RELEASE'|@getFixedLabel}</strong>
            <button class="ld-fonticon ld-fonticon-close" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('ReleanseAccountDiv');"></button>
        </div>
        <form name="formreleasaccount" method="post">
            <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
                <tbody>
                <tr>
                    <td class="ld-form-item-label">
                        <font color="red">*</font>{'RELEASEACCOUNTTREASON'|@getFixedLabel}
                    </td>
                    <td class="ld-form-item-content">
                        <textarea style="height: 90px;resize: none;" class="ld-textarea-inner" name="releaseAccountReasons"></textarea>
                    </td>
                </tr>
                </tbody>
            </table>
        </form>
        <div class="E_pbtn">
            <input type="button" class="E_pbtnok D_ptconfrim" value="{'CONFIRMED'|@getFixedLabel}" /><span>&nbsp;</span>
            <input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('ReleanseAccountDiv');"/>
        </div>
    </div>

    <!--如何创建付款计划-->
    <div id="howTosendpayment" style="display:none;">
        <div class="ld-titlename">
            {'How_to_send_create_plan'|@getFixedLabel}
        </div>
        <div class="ld-public-content-small divPopOverflow">
            {'How_to_send_create_plan1'|@getFixedLabel}<br>
            {'How_to_send_create_plan2'|@getFixedLabel}<br>
            {'How_to_send_create_plan3'|@getFixedLabel}
        </div>
    </div>

    <!--如何创建报价变更单-->
    <div id="howToquoteschange" style="display:none;">
        <div class="ld-titlename">
            {'How_to_create_quoteschange'|@getFixedLabel}
        </div>
        <div class="ld-public-content-small divPopOverflow">
            {'How_to_create_quoteschange_infos'|@getFixedLabel}
        </div>
    </div>

    <!--如何创建预算变更单-->
    <div id="howTobudgetchange" style="display:none;">
        <div class="ld-titlename">
            {'How_to_create_budgetchange'|@getFixedLabel}
        </div>
        <div class="ld-public-content-small divPopOverflow">
            {'How_to_create_budgetchange_infos'|@getFixedLabel}
        </div>
    </div>

    <!--如何维护部门和成员-->
    <div id="howtomaintain" style="display:none;">
        <div class="ld-titlename">
            {'howtomaintrandepartanduser'|@getFixedLabel}
        </div>
        <div class="ld-public-content-small divPopOverflow">
            {'howtomaintrandepartanduserinfo1'|@getFixedLabel}<br>
            {'howtomaintrandepartanduserinfo2'|@getFixedLabel}<br>
            {'howtomaintrandepartanduserinfo3'|@getFixedLabel}<br>
            <!-- BUG0069532 （客户001）客户001成员管理点击“如何维护部门和成员”--如何创建--新增“继续按钮”按钮--跳转到企业微信管理后台，新增员工可以直接跳转到企业微信管理后台登录界面 -->
            <a target="_blank" href="https://work.weixin.qq.com/">{'howtomaintrandepartanduserinfo4'|@getFixedLabel}</a>
        </div>
    </div>

    <!--如何创建服务回访单-->
    <div id="howToservicereturn" style="display:none;">
        <div class="ld-titlename">
            {'How_to_create_return'|@getFixedLabel}
        </div>
        <div class="ld-public-content-small divPopOverflow">
            {$HOWTOCREATERETURN1}<br>
            {$HOWTOCREATERETURN2}
        </div>
    </div>

    <!--如何创建回款计划-->
    <div id="howTopayment" style="display:none;">
        <div class="ld-titlename">
            {'How_to_create_plan'|@getFixedLabel}
        </div>
        <div class="ld-public-content-small divPopOverflow">
            {'How_to_create_plan1'|@getFixedLabel}<br>
            {'How_to_create_plan2'|@getFixedLabel}<br>
            {'How_to_create_plan3'|@getFixedLabel}
        </div>
    </div>

    <!--如何采购退货-->
    <div id="howToPurchaseReturn" style="display:none;">
        <div class="ld-titlename">
            {'HOWTOPURCHASERETURN'|@getFixedLabel}
        </div>
        <div class="ld-public-content-small divPopOverflow">
            {'RETURNPURCHASE1'|@getFixedLabel}<br>
            {'RETURNPURCHASE2'|@getFixedLabel}<br>
            {'RETURNPURCHASE3'|@getFixedLabel}
        </div>
    </div>

    <div id="divSendInform_content" class="D_pop_box LdPopWidth900px" style="display:none;z-index:100000;">
        <div id="divSendInform_content_div"></div>
    </div>

    <div id="divId" class="veil_newnobg" style="position:absolute;width:100%;display:none;top:0px;left:0px;z-index:9999;">
        <table border="0" cellpadding="0" cellspacing="0" align="center" style="vertical-align:middle;width:100%;height:100%;">
            <tbody><tr>
                <td class="big" align="center">
                    <img src="{$IMAGEURL}themes/images/plsWaitAnimated.gif?v={$GLOBALMINVERSION}"/>
                </td>
            </tr>
            </tbody>
        </table>
    </div>
    <div id="CreateDividendOrder" class="D_pop_box LdPopWidth900px" style="display:none;">
        <div id="DividendOrder_form_div"></div>
    </div>


    <div id="list_dividend_rate_recalculate" class="E_pop_box LdPopWidth400px" style="display:none;">
        <div class="E_pop_tit">
            <strong id="titlename" class="E_ptita">{'RATERECALCULATE'|@getFixedLabel} </strong>
            <button class="ld-fonticon ld-fonticon-close" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('list_dividend_rate_recalculate');"></button>
        </div>
        <div id="dividend_rate_recalculate_div">
            <table width="100%" cellspacing="1" cellpadding="2" border="0" align="center" class="D_pop_bod">
                <tr>
                    <td rowspan="2" class="DetailedTd1Label" width="30%" align="center">{'DATARANGE'|@getFixedLabel}</td>
                    <td><input type="radio" name="dividendorder_rate_radio_datascope" checked="" id="dividendorder_rate_radio_search_result"/>{'SEARCHRESULTSRATERECALCULATE'|@getFixedLabel}</td>
                </tr>
                <tr>
                    <td><input type="radio" name="dividendorder_rate_radio_datascope" id="dividendorder_rate_radio_select_record"/>{'RERECALCULATESELECTED'|@getFixedLabel}</td>
                </tr>
                <tr>
                    <td rowspan="2" class="DetailedTd1Label" align="center">{'RERECALCULATEMETHOD'|@getFixedLabel}</td>
                    <td><input type="radio" name="dividendorder_rate_radio_method" checked=""  id="dividendorder_rate_radio_del_no"/>{'DELETENODIVIDENDRECAL'|@getFixedLabel}</td>
                </tr>
                <tr>
                    <td><input type="radio" name="dividendorder_rate_radio_method" id="dividendorder_rate_radio_del_all"/>{'DELETEALLRECORDSRECAL'|@getFixedLabel}</td>
                </tr>
            </table>
        </div>
        <div class="E_pbtn">
            <input type="button" value="{'CONFIRMED'|@getFixedLabel}" class="E_pbtnok" onclick="fun_Dividend.getInstance().List_Recalculate()">
            <span>&nbsp;</span>
            <input type="button" onclick="fninvshnew('list_dividend_rate_recalculate');" value="{'CANCEL'|@getFixedLabel}" class="E_pbtncancel">
        </div>
    </div>
    <div id="bw_sync_helpdesk_div" class="D_pop_box LdPopWidth350px" style="display:none; height:100px;line-height:100px;">
        <div id="cell" style="text-align:center;">
            <p>{'GETTINGDATAFROMBANGWO8PLEASEWAITFORAMEMENT'|@getFixedLabel}</p>
        </div>
    </div>
    <!-- 批量审批 begin -->
    <div id="batchapproved" class="E_pop_box LdPopWidth600px" style="position: absolute; z-index:9998; left: 200px; top: 150px;display: none;">
        <form action="index.php" method="post" name="frmbatchapproved">
            <input name="module" value="Approve" type="hidden">
            <input name="action" value="SubmitApprove" type="hidden">
            <input name="record" value="" type="hidden">
            <input name="fld_module" value="Accounts" type="hidden">
            <input name="is_approve_module" id="is_approve_module" value="{$FROMAPPROVEMODULE}" type="hidden">
            <input name="is_approve_status" id="is_approve_status" value="{$APPROVESTATUS}" type="hidden">
        </form>
        <input type="hidden" value="{$BATCHNUM}" id='batchnum' />
    </div>
    <div id="orgLay" class="E_pop_box LdPopWidth400px" style="display:none;">
        <div class="E_pop_tit">
            <strong class="E_ptita">{'ADDFOLDER'|@getFixedLabel}</strong>
            <button class="ld-fonticon ld-fonticon-close" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="closeFolderCreate();"></button>
        </div>
        <table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
            <tr>
                <td align="right"><font color="red">*</font>{'Folder_name'|@getFixedLabel}:</td>
                <td>
                    <input id="folder_id" name="folderId" type="hidden" value=''/>
                    <input id="fldrsave_mode" name="folderId" type="hidden" value='save'/>
                    <input id="folder_name" name="folderName"  type="text" style="border:1px solid #eee"/>
                    &nbsp;&nbsp;{'20word_limit'|@getFixedLabel}
                </td>
            </tr>
            <tr>
                <td align="right">{'DESCRIPTION'|@getFixedLabel}:</span></td>
                <td>
                    <input id="folder_desc" name="folderDesc" type="text" style="border:1px solid #eee"/>
                    &nbsp;&nbsp;{'50word_limit'|@getFixedLabel}
                </td>
            </tr>
        </table>
        <div class="E_pbtn">
            <input type="button" class="E_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="AddFolder();"/><span>&nbsp;</span>
            <input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="closeFolderCreate();"/>
        </div>
    </div>
    <div id="emptyfolder" class="E_pop_box LdPopWidth600px" style="display:none;">
        <div class="E_pop_tit">
            <strong class="E_ptita">{'VIEWEMPTYFOLDER'|@getFixedLabel}</strong>
            <button class="ld-fonticon ld-fonticon-close" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('emptyfolder');"></button>
        </div>
        <div class="scrollContent" style="height:auto;max-height:260px;">
            <table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
                <tr>
                    <td align="center">
                        <table class="DocumentsEmptyfolderPop" cellspacing="1" cellpadding="0" border="0" width="100%">
                            {foreach item=folder from=$EMPTY_FOLDERS}
                                <tr align="left">
                                    <td>{$folder.foldername}</td>
                                    {if $IS_ADMIN eq "on" && $folder.folderid neq "1"}
                                        <td width="30">
                                            <a class="icon-homeimg icon-sdel" href="javascript:;" onclick="DeleteFolderCheck({$folder.folderid});"></a>
                                        </td>
                                    {else}
                                        <td>&nbsp;</td>
                                    {/if}
                                </tr>
                            {/foreach}
                        </table>
                    </td>
                </tr>
            </table>
        </div>
    </div>

    <div id="movefolderlist" class="E_pop_box LdPopWidth600px" style="display:none;">
        <div class="E_pop_tit">
            <strong class="E_ptita">{'Move_to'|@getFixedLabel}</strong>
            <button class="ld-fonticon ld-fonticon-close" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('movefolderlist');"></button>
        </div>
        <table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
            <tr>
                <td>
                    <ul class="LdPop_ul1 DocumentsMovePop">
                        {foreach item=folder from=$ALL_FOLDERS}
                            <li>
                                <a href="javascript:;" onClick="MoveFile('{$folder.folderid}','{$folder.foldername}');" > {$folder.foldername}</a>
                            </li>
                        {/foreach}
                    </ul>
                </td>
            </tr>
        </table>
    </div>
    <!-- 批量审批 end -->



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
    {if $senioruserid neq ""}
        <input type="hidden" id="scope_senioruserids" value="{$senioruserid}"/>
    {/if}
    <div class="List3Box">
        <!--两秒自动消失的提示，单据编号重复的提示-->

    </div>

{/if}

<script>
    var firstVisit = '{$FIRSTVISIT}';
    //BUG0068295  关联创建打开新页签 获取到的为最后一个CrmPopup为新增界面  应该改为列表界面
    //var popupobj=CrmPopup.getPopupObj('last');
    var popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);

    popupobj.columnOptionHtml = "{$FIELDNAMES}";
    popupobj.criteria_groups_arr = '';

    popupobj.listresizeobj=new List_ResizeTable(popupobj);

    setContentHeight(popupobj.module);//计算内容高度
    var linkmodulecustom = '{$LINKMODULECUSTOM}';
    popupobj.linkmodulecustom = linkmodulecustom ? 'yes': 'no';
    var modulebillduptip='{$MODULEBILLNOTIP}';
    var version_account = '{$VERSION_ACCOUNT}';
    var FieldWidthSetting='{$FieldWidthSetting}';
    var FieldWidthSettingobj;
    var ReleanAccountReason='{"RELEASEACCOUNTTREASON"|@getFixedLabel}';
    var createpopdividendorder='{$CREATEPOPDIVIDENDORDER}';
    var recordid='{$RECORDID}';
    var module = '{$MODULE}';
    var searchtype = '{$SEATCH_INPUT.searchtype}';
    if(searchtype == 'advance'){
        setListButtonColor("categoryAdvsear");
    }
    //duan  20240801 BUG20240731-02 记录高级查询的Json内容，在切换页签的时候重新生成高级查询条件
    if(!empty(popupobj.list_criterid_groups_json)){
        // showListAdvanceSearchJson(popupobj.list_criterid_groups_json);
    }

    var haigersavetip='{$HaigeSaveTip}';
    var listeditpageobj=new ListEditPagePopup(popupobj);
    listeditpageobj.setListEditEvent();
    var tree_enable='{$MODULElISTTREE.enable}';
    if(tree_enable == 'yes' || module == 'Users'){
        var structureTreeobj=new structureTree();
        structureTreeobj.setEvent();
        structureTreeobj.treeWidth = '{$MODULElISTTREE.tree_width}';
    }
    //lmq 230614 表格行高设置
    popupobj.TableLineHightSet = '{$TableLineHightSet}';

    // edit: xll 2024/11/22 XUQIU1001599 单据序时簿列表界面，高级查找增加“平铺”和“清除筛选值”功能
    popupobj.AdvanceTiled_advft_criteria = '{$AdvanceTiled_advft_criteria}';

    {literal}
    if(FieldWidthSetting!='')
    {

        var FieldWidthSettingobj=eval('('+ FieldWidthSetting +')')?eval('('+ FieldWidthSetting +')'):JSON.parse(FieldWidthSetting);

    }
    //设置div宽度
    popupobj.listresizeobj.setReiszeTable_Init(module,'');

    //
    ld('#'+popupobj.divid+' #resize_content_table_divid').scroll(function (){
        if(ld(this).scrollTop() > 0){
            if(ld('#'+popupobj.divid+' #resize_header_table_divid div:first-child').hasClass('ld-setting-tabtop-shadow')){
            }else{
                ld('#'+popupobj.divid+' #resize_header_table_divid div:first-child').addClass('ld-setting-tabtop-shadow');
            }
        }else{
            ld('#'+popupobj.divid+' #resize_header_table_divid div:first-child').removeClass('ld-setting-tabtop-shadow');
        }
    });

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
        //显示搜索历史
        Popupobj.searchtype = 'BasicSearch';
        popupobj.searchmode = 'showhistory';
        show_history(Popupobj);
    }

    function HighersearchPopup() {
        setListButtonColor("categoryAdvsear");
        // $("status").style.display = "none";

        var popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
        if(popupobj == null || popupobj == undefined){
            popupobj = CrmPopup.getlastPopupObjByType('maplist');
        }
        getJsScript('include/js/cls_advanceFilter.js',function () {
            var cls_advanceFilterObj = new cls_advanceFilter();
            cls_advanceFilterObj.setPrevPopupobj(popupobj);
            if(ld('#'+popupobj.divid+' #AdvanceTiledSearch').length > 0){
                cls_advanceFilterObj.setShowTile('yes');
            }
            cls_advanceFilterObj.setColumnOptionHtml(popupobj.columnOptionHtml);
            cls_advanceFilterObj.setFilterValue(popupobj.advft_criteria,popupobj.advft_criteria_groups);
            cls_advanceFilterObj.showAdvanceFilterPopup('yes',function () {
                callSearch('Advanced');
            })
        });

    }

    // edit: xll 2024/11/22 XUQIU1001599 单据序时簿列表界面，高级查找增加“平铺”和“清除筛选值”功能
    function ShowAdvanceTiled() {
        var popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
        var AdvanceTiledSearchobj = ld('#'+popupobj.divid+' #AdvanceTiledSearch');
        if(AdvanceTiledSearchobj.length == 0){
            return false;
        }
        var advanceTiledObj = popupobj.AdvanceFilterTiledObj;
        if(!advanceTiledObj || !AdvanceTiledSearchobj.get(0).AdvanceFilterTiledObj) {
            AjaxJSPage('AdvanceFilterTiled_js', 'include/js/AdvanceFilterTiled.js');
            advanceTiledObj = popupobj.AdvanceFilterTiledObj = AdvanceFilterTiled.getInstance(AdvanceTiledSearchobj,popupobj);
            advanceTiledObj.setPrevPopupobj(popupobj);
            advanceTiledObj.setColumnOptionHtml(popupobj.columnOptionHtml);
            advanceTiledObj.setFilterValue(popupobj.advft_criteria, popupobj.advft_criteria_groups);
        }
        advanceTiledObj.showAdvanceFilter(popupobj.AdvanceTiled_advft_criteria)
        advanceTiledObj.setEvents();
    }

    ShowAdvanceTiled();

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
    // function ldSelectPageNum(obj,pagenum,totalrows){
    //     var divobj = ld(obj).parent().parent().parent();
    //     divobj.find('#pagenum').val(pagenum);
    //     divobj.find('#pagenum_show').html(pagenum+'/'+totalrows+'&nbsp;&nbsp;<b class="down"></b><b style="visibility: hidden">'+totalrows+'</b>');
    //     divobj.find('#pagenum').change();
    // }
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

    /**
     * zxm
     * 2020-1029
     * 获客文章 设置公众号参数 app_id app_secret
     */
    function weixinSetAppid()
    {ldelim}
        var surl = 'index.php?module=Settings&action=SettingsAjax&file=listsetappid';
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth900px",'Settings',"","","","");
        crmPopupobj.prevshow();
        ldAjaxNoProgress(surl,"",function(data){
            if(data.code==1){
                crmPopupobj.setParams(data.result.title,weixinSaveAppid,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
                crmPopupobj.show(data.result.content);
            }
        })
        {rdelim}
    function weixinSaveAppid()
    {ldelim}
        var popupobj = CrmPopup.getPopupObj("last");
        var url = 'index.php?module=Settings&action=SettingsAjax&file=listsetappid&mode=edit';
        var params = ld("#"+popupobj.divid+" .ajax_form").serialize();
        ldAjax(url,params,function(data){
            if(data.code==1){
                popupobj.CancelEvent();
            }else{
                var confirm_str = data.msg;
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            }
            ld('#rptContentLoading').hide();
        })
        {rdelim}
</script>