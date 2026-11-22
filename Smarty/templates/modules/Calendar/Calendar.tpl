{*end*}
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListViewButton.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/search.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/merge.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/DataCategoryPopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/ListBasicSearchPopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/ListHigherSearchPopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/XlsImportNew/XlsImportNew.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Calendar/Calendar.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/cls_ModuleTree.js"></script>
{if $ListViewNavbarcur eq 0}
    {include file="modules/Calendar/CalendarContent.tpl"}
{elseif $ListViewNavbarcur eq 1}
    {include file='ActivityListView.tpl'}
{/if}
<script language="JavaScript" type="text/javascript" src="include/js/cls_ModuleTree.js"></script>
<script>
    var module = '{$MODULE}';
    var tmpstr='{$DATETIMESTR}';
    var datetimestr=  eval('('+ tmpstr +')')?eval('('+ tmpstr +')'):JSON.parse(tmpstr);
    var popupobj=CrmPopup.getPopupObj('last');
    var linkmodulecustom = '{$LINKMODULECUSTOM}';
    popupobj.linkmodulecustom = linkmodulecustom ? 'yes': 'no';
    popupobj.columnOptionHtml = "{$FIELDNAMES}";
    var listeditpageobj=new ListEditPagePopup(popupobj);
    listeditpageobj.setListEditEvent();
    var structureTreeobj=new structureTree();
    structureTreeobj.setEvent();
    structureTreeobj.treeWidth = '{$MODULElISTTREE.tree_width}';
</script>
<script>
{literal}
    function CalendarTabClick(tabindex,popupobj) {
        var tmppopupobj=CrmPopup.getPopupObj('last');
        var action='index';
        if(tabindex==0) {
            action+='&calendar_logtype=CalendarView';
        }
        else {
            action+='&calendar_logtype=ListView';
            action+="&isshowModuleListTree=yes";
            //列表界面刷新时更新界面小编辑图标对应事件
            if(tmppopupobj.type == 'listpage'){
                if(listeditpageobj==undefined){
                    getJsScript('include/js/SystemPopup/ListEditPagePopup.js',function(){
                        var listeditpageobj=new ListEditPagePopup(tmppopupobj);
                    })
                }
                listeditpageobj.init();
                listeditpageobj.setListEditEvent();
            }
        }

        if(tmppopupobj.type!=ListPagePopup.type&&tmppopupobj.type!='calendarview') {
            action+="&ajax=yes";
        }
        ldAjaxHtmlNoProgress("index.php?module=Calendar&action=CalendarAjax&file="+action,'',function(data){
            //var popupobj=CrmPopup.getPopupObj('last');
            if(tabindex==1){
                popupobj.type=ListPagePopup.type;
            }
            else {
                popupobj.type="calendarview";
            }
            listcontentobj.html(data);
            //BUG20240603-63 ls 240604 日程管理：列表视图，刚从日历视图切换时不显示关闭、编辑操作栏。刷新浏览器后才显示
            // 重新加载宽度
            /*if(empty(tmppopupobj.listresizeobj)){
                var listresizeobj=new List_ResizeTable(tmppopupobj);
                tmppopupobj.listresizeobj=listresizeobj;
            }
            tmppopupobj.listresizeobj.setReiszeTable_Init(tmppopupobj.module,'ajax');*/
        })
    }
    function HighersearchPopup()
    {
        setListButtonColor("categoryAdvsear");
        var popupobj = CrmPopup.getPopupObj("last");
        getJsScript('include/js/cls_advanceFilter.js',function () {
            var cls_advanceFilterObj = new cls_advanceFilter();
            cls_advanceFilterObj.setPrevPopupobj(popupobj);
            cls_advanceFilterObj.setColumnOptionHtml(popupobj.columnOptionHtml);
            cls_advanceFilterObj.setFilterValue(popupobj.advft_criteria,popupobj.advft_criteria_groups);
            cls_advanceFilterObj.showAdvanceFilterPopup('yes',function () {
                callSearch('Advanced');
            })
        });
    }

    function getUrlString(searchtype) {
        var popupobj = CrmPopup.getPopupObj("last");
        gPopupAlphaSearchUrl = '';

        if (document.getElementById("SmOwnerSearchScope") != null)
            var searchScope = encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
        else
            var searchScope = '';
        var urlstring = '';

        if (searchtype == 'Basic') {
            search_fld_val = CrmPopup.findHtmlobj(popupobj.divid, "search_field").val();
            //zkt 20220614 BUG0052740（示图）单据编号值，直接从微信复制出来的，从表面看是空格，实际是转义字符，导致搜索不到
            var search_text_value = trim(CrmPopup.findHtmlobj(popupobj.divid, 'search_text').val());
            search_txt_val = encodeURIComponent(search_text_value);

            urlstring = 'search_field=' + search_fld_val + '&searchtype=BasicSearch&search_text=' + search_txt_val + '&';
            //wym XUQIU1001090 单据序时簿列表界面，基本查找增加“全部字段”功能
            if (search_fld_val == 'all') {
                var optionvalues = ld("select[name=search_field]").find(' option').map(function () {
                    if (ld(this).val() != 'all') {
                        return ld(this).val();
                    }
                }).get();
                var search_fld_val_arr = JSON.stringify(optionvalues);
                urlstring += 'search_field_arr=' + search_fld_val_arr + '&';
            }
            urlstring = urlstring + 'SearchScope=' + searchScope + '&';
            //urlstring = urlstring + 'parenttab='+p_tab[0].value+ '&';

            urlstring = urlstring + 'viewid=' + document.getElementById("viewname").value + '&';
            urlstring = urlstring + 'viewname=' + document.getElementById("viewname").value + '&';
        } else if (searchtype == 'Advanced') {
            var advanceFilterObj = popupobj.advanceFilterObj;
            if (advanceFilterObj != undefined && !advanceFilterObj.checkAdvancedFilter()){
                return false;
            }

            var advft_criteria = advanceFilterObj.advft_criteria;
            if (advft_criteria != '') {
                var advft_criteria_groups = advanceFilterObj.advft_criteria_groups;
                urlstring += '&advft_criteria=' + encodeURIComponent(advft_criteria) + '&advft_criteria_groups=' + advft_criteria_groups + '&';

            }
            urlstring = urlstring + 'SearchScope=' + searchScope + '&';

            urlstring = urlstring + 'viewid=' + document.getElementById("viewname").value + '&';
            urlstring = urlstring + 'viewname=' + document.getElementById("viewname").value + '&';
            urlstring += 'searchtype=advance&'
        }
        // @edit:dong @date:2020/08/24 @reason: 添加平铺查找
        else if (searchtype == 'Tiled') {
            if (!tiled_checkAdvancedFilter()) return false;
            var tiledsearch_criteria = $('tiledsearch_criteria').value;
            var tiledsearch_criteria_groups = $('tiledsearch_criteria_groups').value;
            urlstring += '&advft_criteria=' + encodeURIComponent(tiledsearch_criteria) + '&advft_criteria_groups=' + tiledsearch_criteria_groups + '&';
            urlstring = urlstring + 'SearchScope=' + searchScope + '&';

            urlstring = urlstring + 'viewid=' + document.getElementById("viewname").value + '&';
            urlstring = urlstring + 'viewname=' + document.getElementById("viewname").value + '&';
            urlstring += 'searchtype=tiled&'
        }

        if (searchtype == 'Advanced') {
            var prevpopupobj = CrmPopup.getPopupObj("lastprev");
            if (typeof prevpopupobj != 'undefined') //BUG20240108-58
                var searchfrom = prevpopupobj.type;
        } else {
            var searchfrom = popupobj.type;
        }
        urlstring += 'searchfrom=' + searchfrom + '&';
        /**
         * 搜索条件，增加wareid仓库ID条件
         * @reason 0012618 库存台帐：选择任意一个仓库的页签，然后鼠标点击数据分类“全部”，结果查出的是【全部仓库】的台帐库存数据
         * @author Tujt 2014-11-19
         */
        var wareid = 0;
        if (document.getElementById('wareid') != undefined && document.getElementById('wareid').value > 0) {
            wareid = document.getElementById("wareid").value;
        }
        urlstring += 'wareid=' + wareid + '&';
        var module = '{$MODULE}';
        if (module == 'Approve') {
            if (ld('#fromapprovemodule') != undefined) {
                urlstring += '&fromapprovemodule=' + ld('#fromapprovemodule').val() + '&';
            }
            if (ld('#approvestatus') != undefined) {
                urlstring += '&approvestatus=' + ld('#approvestatus').val() + '&';
            }
        }
        return urlstring;
    }
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

    function callSearch(searchtype) {
        var popupobj = CrmPopup.getPopupObj("last");
        var prevpopupobj = CrmPopup.getPopupObj("lastprev");
        var urlstring = getUrlString(searchtype);
        if (urlstring == false) {
            return false;
        }
        //保存搜索历史
        save_search_history(urlstring, popupobj.module);
        if (prevpopupobj != undefined && prevpopupobj.module == 'Calendar' && prevpopupobj.pagetype == 'calendarview'){
            hidedv_listhighersearch();
            if (typeof calendar != 'undefined'){
                prevpopupobj.clearHighSearch = false;
                calendar.refetchEvents();
            }
            return false;
        }

        searchtype_btn = searchtype;
        var divid = 'ListViewContents';
        urlstring += 'query=true&file=ListView&module='+popupobj.module+'&action='+popupobj.module+'Ajax&ajax=true&search=true';

        if (document.getElementById("isshowModuleListTree") != undefined && document.getElementById("isshowModuleListTree").value == 'yes') {
            urlstring += "&isshowModuleListTree=yes";
        }
        //平铺查找点击查找后平铺查找框不显示
        if (searchtype == 'Tiled') {
            if (ld("#" + popupobj.divid + " #Autohideafterfinding").length > 0 && ld("#" + popupobj.divid + " #Autohideafterfinding").is(':checked') == true) {
                urlstring += '&tiledSearchdisplay=none';
                ld("#" + popupobj.divid + ' #tiledSearch').hide();
            }
        }
        var listview_page = new ListView_Page(popupobj.module, urlstring, divid);
        listview_page.callback_fun = function () {
            if (document.getElementById('listview_advanced') != undefined) {
                document.getElementById('listview_advanced').disabled = false;
            }
            // popupobj.CancelEvent();
            popupobj = CrmPopup.getPopupObj("last");
            popupobj.searchtype = searchtype;

            if (popupobj.frommodule == 'Approve') {
                setContentHeight(popupobj.frommodule);//审批列表页面高度
            } else {
                setContentHeight(popupobj.module);//计算内容高度
            }
            popupobj.listresizeobj.setReiszeTable_Init(popupobj.module, 'ajax');
            if (searchtype != 'Tiled') {
                if (!ld('#tiledSearch').is(":hidden"))
                    TiledSearchShow();
            }
        }
        listview_page.page();
        if (searchtype == 'Basic') {
            setShowOrHideClearIcon();
        } else {
            if (popupobj.advanceFilter=='yes' && popupobj.advanceFilterObj != undefined){
                popupobj.CancelEvent();
            }
        }
        return false;
    }

    function basicsearchPopup(){
        //基本查询弹出框
        setListButtonColor("categorysear");
        var Popupobj=new ListBasicSearchPopup.load("",callSearch,"","LdPopWidth400px",module,['Basic'],btn_findnow_label,"","");
        Popupobj.show(ld("div[name=dv_listbasicsearch]").html());
        //显示搜索历史
        Popupobj.searchtype = 'BasicSearch';
        Popupobj.searchmode = 'showhistory';
        show_history(Popupobj);
    }

    function TiledSearchShow() {
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

    function hidedv_listhighersearch(){
        //  ld('#dv_listhighersearch').css("display",'none');
        var popupobj=CrmPopup.getPopupObj("last");
        popupobj.CancelEvent();
    }

    {/literal}
</script>