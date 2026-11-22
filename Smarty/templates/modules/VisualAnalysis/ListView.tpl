
<!--修改编码格式:统一编码：UTF-8-->
<input type="hidden" id="from_module" value="{$from_module}">
<input type="hidden" id="edithomefromlist" value="yes">
<link rel="stylesheet" type="text/css" href="themes/softed/Homeboard.css"/>
<script>
    var current_language = '{$languageType}';
</script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Home/Home.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Home/Homeboard.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Home/Homestuff.js"></script>
<form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();" style="height:100%;">
    <input type="hidden" name="module" value="Home">
    <input type="hidden" name="action" value="HomeboardListview">
    <div id="VisualAnalysis_index" class="ld_VisualAnalysis_index" style="height:100%;">
        <div class="main_grid_top ld_VisualAnalysis_top" >
            {*<div class="ld_VisualAnalysis_Title" data-modulename="{$from_module|@getTranstab}">
                <span onclick="return_HomeListView('')">
                    {$from_module|@getTranstab}
                </span>
            </div>*}
            <div class="ld_VisualAnalysis_Search">
                <div class="SearchType">
                    <select id="BoardSearchType" class="commonSelectPop gwidth100 " style="">
                        {foreach key=SearchType item=SearchTypeLabel from=$SEARCHTYPELIST}
                            <option value="{$SearchType}">{$SearchTypeLabel}</option>
                        {/foreach}
                    </select>
                </div>
                <div class="ld-listview-basicsearch ld_VisualAnalysis_listviewSearch">
                    <input type="text" class="commonSelectPop gwidth100 padR40" id="BoardSearchValue"
                           placeholder="{'SEARCHKEYWORDS'|@getFixedLabel}" onkeyup="SearchBoardSubmit(event,
                           this)" value="" autocomplete="off" style="border-radius: 0 4px 4px 0;padding-right:40px;">
                    <b style="position: absolute;right:30px;top:0;cursor: pointer;display:none"
                       class="ld-icon-clearsearch" onclick="clearBoardSearch(this);"></b>
                    <b class="categorysear-search ld-listview-search" onclick="SearchBoard(this)"></b>
                    <div style="position: absolute;right:0;top:30px;width:100%;background-color: #fff;z-index:902;">
                        <ol class="D_more_menua" id="basicSearchList">
                        </ol>
                    </div>
                </div>
            </div>

            <div class="ld_VisualAnalysis_ShowType" value="{$SHOWTYPE}">
                <div class="ld_VisualAnalysis_Card ld_VisualAnalysis_Icondiv_Sel tip-items-list" name="Card"
                     data-tip="{'CARDVIEW'|@getFixedLabel}" data-direction="top" data-type="position">
                    <img id="VisualAnalysis_Card_Icon_Sel" class="ld_VisualAnalysis_Card_Icon" name="Icon_sel"
                         src="themes/icon2023/VisualAnalysis_Card_sel.png"
                         alt="">
                    <img id="VisualAnalysis_Card_Icon" class="ld_VisualAnalysis_Card_Icon" name="Icon"
                         src="themes/icon2023/VisualAnalysis_Card.png" alt="" style="display: none;">
                </div>
                <div class="ld_VisualAnalysis_List ld_VisualAnalysis_Icondiv tip-items-list" name="List"
                     data-tip="{'LISTVIEW'|@getFixedLabel}" data-direction="top" data-type="position">
                    <img id="VisualAnalysis_List_Icon" class="ld_VisualAnalysis_List_Icon" name="Icon"
                         src="themes/icon2023/VisualAnalysis_List_sel.png" alt="">
                    <img id="VisualAnalysis_List_Icon_sel" class="ld_VisualAnalysis_List_Icon" name="Icon_sel"
                         src="themes/icon2023/VisualAnalysis_List.png" alt="" style="display: none;">
                </div>
            </div>

            <div class="ld_VisualAnalysis_Manage ld-listview-btnscontent">
                {if $PERMITARR['Create'] eq 'yes'}
                    <div class="create-entity-toolbar prelative">
                        <a href="javascript:;" class="ld-button ld-button-primary" onclick="editHomeboard(0,'VisualAnalysis')">
                            {'CREATE'|@getFixedLabel}
                        </a>
                    </div>
                {else}
                    <div class="create-entity-toolbar prelative">
                        <a href="javascript:;" class="ld-button" onclick="HomeboardListview('VisualAnalysis')">
                            {'Management_Data_Kanban'|@getFixedLabel}
                        </a>
                    </div>
                {/if}
            </div>

        </div>

        <div class="ld_VisualAnalysis_Content" style="height:100%;">
            {include file="modules/VisualAnalysis/ListViewContent.tpl"}
        </div>

    </div>
</form>

<div id="tempdiv" style="display:block;position:absolute;left:350px;top:200px;"></div>
<script type="text/javascript">
    {literal}

    //tooltip('.tip-items-list', {transition: true, time: 200});
    {/literal}
    var ShowTypeObj = ld('.ld_VisualAnalysis_ShowType').find('div');
    ld(ShowTypeObj).each(function (index, obj) {
        var that = this;
        ld(this).bind('mouseenter',function(){
            ShowTypeSelected(that);
        });
        ld(this).bind('mouseleave',function(){
            var ShowType = ld(that).parent().attr('value');
            var ShowObj = ld(that).parent().find('[name='+ShowType+']');
            ShowObj.trigger('mouseenter');
        });
        ld(this).bind('click',function(){
            var ShowType = ld(that).attr('name');
            ld(that).parent().attr('value',ShowType);
            return_HomeListView(ShowType); //跳转页面
            save_ShowTypeChoosen(ShowType);
        });
    });
    ld(ShowTypeObj[0]).trigger('mouseleave'); //加载页面时触发一次

    function ShowTypeSelected(obj){
        ld(obj).addClass('ld_VisualAnalysis_Icondiv_Sel');
        ld(obj).removeClass('ld_VisualAnalysis_Icondiv');
        ld(obj).find('img [name=Icon_sel]').css('display','');
        ld(obj).find('img [name=Icon]').css('display','none');
        ld(obj).siblings('div').addClass('ld_VisualAnalysis_Icondiv');
        ld(obj).siblings('div').removeClass('ld_VisualAnalysis_Icondiv_Sel');
    }

    var Toolobj = ld('#VisualAnalysis_Tool');
    var Manage_Listobj = ld('.ld_VisualAnalysis_Manage_List');
    Manage_Listobj.bind('click',function(event){
        Manage_Listobj.focus();
        event.preventDefault();//取消元素默认的行为
        event.stopPropagation();//阻止事件冒泡到父元素
        if(! Toolobj.is(':visible')){ //是否可见属性visible
            //绑定失焦事件
            Toolobj.unbind('blur').bind('blur',function (){
                setTimeout(function(){
                    //火狐的focus只能在 blur之前，故增加setTimeout使判断生效
                    if(!Manage_Listobj.is(':focus'))
                        Toolobj.hide();
                },0);
            });
            //展示
            Toolobj.show();
            Toolobj.focus();
        }else{
            Toolobj.hide();
        }
    });

    var SearchTypeObj = ld("#VisualAnalysis_index #BoardSearchType");
    var SearchValueObj = ld("#VisualAnalysis_index #BoardSearchValue");
    SearchValueObj.bind('focus',function (){
        SearchTypeObj.addClass('ld-border-color-3b7cff');
        SearchValueObj.addClass('ld-border-color-3b7cff');
    });
    SearchValueObj.bind('blur',function (){
        SearchTypeObj.removeClass('ld-border-color-3b7cff');
        SearchValueObj.removeClass('ld-border-color-3b7cff');
    });



    setBoxHeight();
    function setBoxHeight(){
        var ShowType = ld("#VisualAnalysis_index .ld_VisualAnalysis_top .ld_VisualAnalysis_ShowType").attr('value');
        ld('body').css('overflow','hidden');
        var a = ld('.header').outerHeight(),//头部高度
            b = ld('.ld_VisualAnalysis_top').outerHeight(),//顶部高度
            c = ld('.ld_VisualAnalysis_middle').outerHeight(),//中间div高度
            d_height = 0,
            s_height = ld(window).height();

        if(a==null) a=0;
        if(b==null) b=0;
        d_height = s_height-a-b-c;
        //var ContentObj = ld('.ld_VisualAnalysis_box .grid-analysis-box');
        var ContentObj = ld('.ld_VisualAnalysis_box');
        if(ShowType == 'List'){
            ContentObj = ld('.ld_VisualAnalysis_box #resize_content_table_divid');
            //减去列头高度
            var headerHeight = ld('.ld_VisualAnalysis_box #resize_header_table_divid').find('div').outerHeight();
            d_height = d_height - headerHeight;
        }
        ContentObj.css('height',d_height-20);
    }
    setTableWidth();
    function setTableWidth(){
        var ShowType = ld("#VisualAnalysis_index .ld_VisualAnalysis_top .ld_VisualAnalysis_ShowType").attr('value');
        var a = ld('.ld_VisualAnalysis_pagetype').outerWidth()//页签宽度
        a = isNaN(a) ? 0 : a;
        ld(".ld_VisualAnalysis_listview_table").css("width",getRightWidth()-a-11);
        if(ShowType == 'List'){
            ld('#resize_header_table_divid .ld_VisualAnalysis_table').css("width",getRightWidth()-a);
            ld('#resize_content_table_divid .ld_VisualAnalysis_table').css("width",getRightWidth()-a);
        }
    }

    function return_HomeListView(ShowType){
        var module = 'VisualAnalysis';
        var url='index.php?module='+module+'&action='+module+'Ajax&file=ListView&ajax=true'+'&ShowType='+ShowType;
        var indexobj = ld('.ld_VisualAnalysis_Content');
        indexobj.css('background-color','#FFF');
        ldAjax(url,"",function(data){
            if(data.code == 1){
                indexobj.html(data.result.content);
                {literal}

                 tooltip('.tip-items-list', {transition: true, time: 200});
                {/literal}
                setBoxHeight();
                setTableWidth();
                var indexntitleobj = ld("#VisualAnalysis_index .ld_VisualAnalysis_Title");
                //var indexntitle = ld("#VisualAnalysis_index .ld_VisualAnalysis_Title .ld_VisualAnalysis_Title_modulename");
                var indexntitle = ld("#VisualAnalysis_index .ld_VisualAnalysis_Title").data('modulename');
                indexntitleobj.html('<span>'+indexntitle+'</span>');//zxm 20240819 BUG20240816-71
            }
            ld('#rptContentLoading').hide();
        });
    }

    function BoardListByType(obj){
        var module = getUrlParam("pageto_module");
        var indexobj = ld("#VisualAnalysis_index");
        var ShowType = indexobj.find(".ld_VisualAnalysis_top .ld_VisualAnalysis_ShowType").attr('value');
        var BoardType = ld(obj).attr('name');
        var url='index.php?module='+module+'&action='+module+'Ajax&file=ListView&ajax=true'+'&ShowType='+ShowType+'&BoardType='+BoardType;
        var indexContentObj = indexobj.find('.ld_VisualAnalysis_Content');
        ldAjax(url,"",function(data){
            if(data.code == 1){
                indexContentObj.html(data.result.content);
                setBoxHeight();
                setTableWidth();
            }
            ld('#rptContentLoading').hide();
        });
    }

    function SaveBoardOperate_Collect(obj,event,boardid,actiontype){
        var event = event || window.event;
        //event.stopPropagation();//阻止事件冒泡到父元素
        SaveBoardOperate(obj,boardid,actiontype);
    }

    function Collect_div_click(event){
        //出发标签点击事件，阻止冒泡到看板点击事件
        event.stopPropagation();//阻止事件冒泡到父元素
    }

    function SaveBoardOperate(obj,boardid,actiontype){
        var module = getUrlParam("pageto_module");
        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=SaveHomeboard'+'&boardid='+boardid
            +'&actiontype='+actiontype;
        if(actiontype == 'collect'){
            var collect = ld(obj).attr('value');
            var collectobj = ld("#VisualAnalysis_index .ld_VisualAnalysis_middle [name=Collection]");
            if(collectobj.length == 0)
                collectobj = ld("#VisualAnalysis_index .ld_VisualAnalysis_pagetype [name=Collection]");
            var collectnum_obj = collectobj.find(".board_num");
            var collectnum = collectnum_obj.text();
            if(collect == 'yes'){
                //已收藏的看板，点击则取消收藏
                collectnum_obj.text(parseInt(collectnum)-1);
                var PageTabobj = ld('#VisualAnalysis_index .ld_VisualAnalysis_middle .ld_VisualAnalysis_ChoosenColor');
                if(PageTabobj.length > 0 && PageTabobj.attr('name') == "Collection") {
                    var CardObj = ld(obj).parents('.ld_VisualAnalysis_listview_Card');
                    if(CardObj.siblings().length == 0){
                        var NoneHtml =
                            '<div class="wtc_img"><img src="themes/icon2023/ld-no-records.png">' +
                                '<div class="wtc_title">' + arrJsPopLabel['NODATAFOUND'] + '</div>' +
                            '</div>';
                        CardObj.parent().html(NoneHtml);
                    }
                    CardObj.remove();
                }
                else{
                    ld(obj).removeClass('ld_VisualAnalysis_collected');
                    ld(obj).addClass('ld_VisualAnalysis_collect');
                    ld(obj).attr('value','no');
                    ld(obj).parent().attr('data-tip',arrJsPopLabel['COLLET']);
                }
            }else{
                //未收藏的看板，点击则收藏
                collectnum_obj.text(parseInt(collectnum)+1);
                ld(obj).removeClass('ld_VisualAnalysis_collect');
                ld(obj).addClass('ld_VisualAnalysis_collected');
                ld(obj).attr('value','yes');
                ld(obj).parent().attr('data-tip',arrJsPopLabel['UNCOLLET']);
            }
            url += '&collect='+collect;
        }else if(actiontype == 'view'){

        }else{

        }
        ldAjax(url,"",function(data){
            if(data.code == 1){
                //操作成功
            }
            ld('#rptContentLoading').hide();
        });
    }

    function save_ShowTypeChoosen(ShowType){
        var module = getUrlParam("pageto_module");
        var save_type = 'VisualAnalysis_ShowType';
        var save_value = ShowType;
        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=fieldstorage'+'&save_type='+save_type+'&save_value='+save_value;
        ldAjax(url,"",function(data){
            if(data.code == 1){
                //操作成功
            }
            ld('#rptContentLoading').hide();
        });
    }


    function SearchBoard(obj){
        var module = getUrlParam("pageto_module");
        var SearchTypeObj = ld("#VisualAnalysis_index #BoardSearchType");
        var SearchType = '';
        if(SearchTypeObj.length > 0){
            SearchType = SearchTypeObj.val();
        }
        var SearchValue = ld(obj).parent().find(".commonSelectPop").val();
        var parent_class =  ld(obj).parent().parent().attr('class');
        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=ListView&ajax=true'+'&SearchType='+SearchType+'&SearchValue='+encodeURIComponent(SearchValue);
        ldAjax(url,"",function(data){
            if(data.code == 1){
                //操作成功
                var indexContentObj = ld("#VisualAnalysis_index .ld_VisualAnalysis_Content");
                indexContentObj.html(data.result.content);
                setBoxHeight();
                setTableWidth();
                var SearchValueObj = ld("#VisualAnalysis_index ." + parent_class + " .commonSelectPop");
                SearchValueObj.focus().val(SearchValue);
                SearchTypeObj.val(SearchType);
                if(SearchValue.length != 0){
                    ld(SearchValueObj).siblings('.ld-icon-clearsearch').css('display','');
                }else{
                    ld(SearchValueObj).siblings('.ld-icon-clearsearch').css('display','none');
                }
            }
            ld('#rptContentLoading').hide();
        });
    }

    function SearchBoardSubmit(event,obj){
        var e = event || window.event;
        if(e.keyCode == 13){
            SearchBoard(obj);
        }
        //edit: xll 2023/11/09 BUG0074831 报表分析-管理驾驶舱，搜索栏，输入值的时候，后边没有“×”
        var ClearObj = ld(obj).parent().find(".ld-icon-clearsearch");
        var SearchValue = ld(obj).parent().find(".commonSelectPop").val();
        if(SearchValue !== undefined && SearchValue !== '')
            ClearObj.show();
        else
            ClearObj.hide();
    }

    function clearBoardSearch(obj){
        ld(obj).hide();
        ld(obj).siblings(".commonSelectPop").val('');
        ld(obj).siblings(".commonSelectPop").focus();
    }

    function CardBoardOperate(event,obj,boardid,type,boardtype){
        var e = event || window.event;
        event.stopPropagation();//阻止事件冒泡到父元素
        if(type == 'edit')
            editHomeboard(boardid,'VisualAnalysis');
        else if(type == 'scope')
            homeboardlist_scope(boardid,obj,boardtype);
        else if(type == 'delete')
            deleteHomeboard(boardid,'VisualAnalysis');
        else
            return false;
    }

    function ViewBoardShow(data){
        var indexcontentobj=ld("#pagecontent .wrapper-panel-inner #VisualAnalysis_index .ld_VisualAnalysis_Content");
        indexcontentobj.css('background-color','rgb(230, 233, 240)');
        indexcontentobj.html(data);
        var boardname = indexcontentobj.find("#home_index .home-header-top-setting .homeboard_name").attr('boardname');
        var indexntitleobj = ld("#VisualAnalysis_index .ld_VisualAnalysis_Title");
        //var indexntitle = indexntitleobj.find('.ld_VisualAnalysis_Title_modulename').prop('outerHTML');
        var indexntext = indexntitleobj.data('modulename');
        var indexntitle = '<span class="ld_VisualAnalysis_Title_modulename" onclick="return_HomeListView(\'\')">'+indexntext+'</span>';
        indexntitle += "&nbsp -> &nbsp" + boardname;
        indexntitleobj.html(indexntitle);
    }

    function VisualAnalysis_Tool_hide(obj){
        ld(obj).parent().parent().hide();
    }

</script>
