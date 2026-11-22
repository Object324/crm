// JavaScript Document
var cur_pageLeftType = 'Open';//当前左侧状态
if(global_hideleftmenu=='yes'){
    var pageleft_unfold=0;//未收起是左侧导航宽度
    var pageleft_fold=0;//收起是左侧导航宽度
   
}
else{
    var pageleft_unfold=170;//未收起是左侧导航宽度
    var pageleft_fold=60;//收起是左侧导航宽度
}

var topheight=55;//快速查找所在div的高度55
var con_mt_height=8;//头部和内容中间margin距离10
var uitabsheight=50;//导航高度
var main_grid_top=60;//main_grid_top高度，报表
var main_left_width=216;//内容中左侧宽度200+内容和左右margin距离各自8
var listcontentobj;//右边列表内容
var SalesKitCount;//销售简报一行宽度
var hoverMenuName = '';//记录导航区块名称
var clickMenuName = '';

function getLeftMenuWidth() {
    if(localStorage.getItem('ldcrm_ding_status') && localStorage.getItem('ldcrm_ding_status') != ''){
        cur_pageLeftType = localStorage.getItem('ldcrm_ding_status');
    }
    else{
        cur_pageLeftType = 'Open';
    }
    if(cur_pageLeftType=='Open') {
        return pageleft_unfold;
    }
    else {
        return pageleft_fold;
    }
}
ld(function(){
    initSlimscroll();//加载主菜单滚动条
    listcontentobj=ld("#pagecontent .wrapper-panel-inner");
    ld(listcontentobj).unbind("mouseover").bind("mouseover",function(){
        ld("#pageleft .menu-thumbnail-box").hide();
    });

    tooltip('.nav-menu-footer-two', {transition: true, time: 200});
    initPageRightHeader();//加载右侧头部事件
    LeftMenu_functionobj=LeftMenu_function.getInstance();
    LeftMenu_functionobj.InitMenu();//加载左边的菜单
});

//浏览器窗口大小变化时
/*ld(window).resize(function() {
    initSlimscroll();//加载主菜单滚动条
});*/

//加载主菜单滚动条
function initSlimscroll(){
    var scrollcolor = '#fffafa';

    const style = window.getComputedStyle(ld('.nav-menu').get(0));
    const bgColor = style.backgroundColor;
    const normalizedBgColor = bgColor.toLowerCase().replace(/\s+/g, '');
    if(normalizedBgColor === 'rgba(255,255,255,1)' || normalizedBgColor === 'rgb(255,255,255)' || normalizedBgColor === '#ffffff'){
        scrollcolor = '#DCDEE0';
    }
    ld(' .sub-menu').slimscroll({
        // width: '100%', //可滚动区域宽度
        height: 'auto', //可滚动区域高度
        size: '5px', //滚动条宽度，即组件宽度
        color: scrollcolor, //滚动条颜色
        position: 'right', //组件位置：left/right
        distance: '0px', //组件与侧边之间的距离
        start: 'top', //默认滚动位置：top/bottom
        opacity: .4, //滚动条透明度
        alwaysVisible: false, //是否 始终显示组件
        disableFadeOut: true, //是否 鼠标经过可滚动区域时显示组件，离开时隐藏组件
        // railVisible: true, //是否 显示轨道
        // railColor: 'rgba(15,41,80,1)', //轨道颜色
        // railOpacity: 1, //轨道透明度
        // railDraggable: true, //是否 滚动条可拖动
        // railClass: 'slimScrollRail', //轨道div类名 
        barClass: 'slimScrollBar', //滚动条div类名
        wrapperClass: 'slimScrollDiv', //外包div类名
        allowPageScroll: true, //是否 使用滚轮到达顶端/底端时，滚动窗口
        wheelStep: 5, //滚轮滚动量
        touchScrollStep: 50, //滚动量当用户使用手势
        borderRadius: '7px', //滚动条圆角
        railBorderRadius: '7px' //轨道圆角
    });
}

//加载左侧箭头导航事件
function initPageLeftContent(){
    //菜单点击
    LeftMenu_functionobj=LeftMenu_function.getInstance();
    ld("#pageleft .page-menu > ul > li").click(function(){
        cleanMainMenuStatus();//清除主菜单效果
        ld(this).find('.page-link').addClass('selected');
    });
    //子菜单显示
    ld("#pageleft .page-menu > ul > li").hover(function (){
        ld('div.menu-thumbnail-box').hide();//隐藏子菜单
        //hzx BUG0071302 菜单栏，选中后效果固定，移动鼠标更换浮显效果
        //cleanMainMenuStatus();//清除主菜单效果
        //ld(this).find('.page-link').addClass('selected');
        //更改图标
        //var img = ld(this).find('.page-link').find('img').attr('src');
        //img = img.replace("_hover","");
        //var imgArr = img.split('.');
        //var newimg = imgArr[0]+'_hover.png';
        ld('.page-menu > ul > li div:not(.selected) img').each(function(){
            //var img = ld(this).attr('src');
            //img = img.replace("_hover","");
            var img = ld(this).attr('data-inactive');
            ld(this).attr('src', img);
        });
        var newimg = ld(this).find('.page-link').find('img').attr('data-active');
        ld(this).find('.page-link').find('img').attr('src', newimg);
        
        var popTop = ld(this).offset().top;
        var scrollTop = ld('#pageleft').scrollTop();
        var top = parseInt(popTop) - parseInt(scrollTop);
        var name=ld(this).attr("name");
        hoverMenuName = name;//记录导航区块名称
        var tmpchildobjs= LeftMenu_functionobj.childtablist[name];
        if(tmpchildobjs!=undefined){
            var html= '<ul class="menu-thumbnail-list">';
            ld.each(tmpchildobjs,function(index,objs){
                var moduleblankStr = '<span class="moduleblank" title="'+arrJsPopLabel['OPENANEWTAB']+'"></span>';
                var relid = objs['id'];
                var tabid = objs['tabid'];
                var label=objs['modulename'];
                var tmpmodulename=objs['tablabel'];
                //清除缓存、群发短信、群发邮件不需要打开新页签
                if(tmpmodulename == 'Cache' || tmpmodulename == 'MassSMS' || tmpmodulename == 'MassEmails'){
                    moduleblankStr = '';
                }
                var type=objs['tab_tablename'];//ld_tab,ld_linkmodulecustom;moduleblank
                if(type=='ld_linkmodulecustom'){
                    var entitytype = objs['entitytype'];// category custom  自定义链接的分类\
                    var  linkurl = objs['linkurl'];
                    var checkphp = objs['checkphp'];
                    var isopeninblank = objs['isopeninblank'];
                    if(isopeninblank == ''){
                        isopeninblank = 'no';
                    }
                    var linkcivid = objs['linkcvid'];
                    var specialcheck = checkphp+"::"+isopeninblank+"::"+linkcivid;
                    if(tmpmodulename=='CustomEcharts' || tmpmodulename== 'CustomTables'){
                        html+='<li tabid="'+tabid+'" relid="'+relid+'" title="'+label+'" type="'+type+'" linkurl="'+linkurl+'" module="'+tmpmodulename+'" entitytype="'+entitytype+'" specialcheck="'+specialcheck+'" ><a target="_blank" href="'+linkurl+'">'+label+moduleblankStr+'</a></li>';
                    }
                    else if(entitytype != undefined && entitytype =='category' ){
                        // @edit:dong @date:2020/12/02 @reason: bug数据分类自定义链接模块 右键打开页面错误
                        var newUrl =  linkurl.substring(linkurl.indexOf('&start',linkurl));
                        html+='<li tabid="'+tabid+'" relid="'+relid+'" title="'+label+'" type="'+type+'" linkurl="'+linkurl+'" module="'+tmpmodulename+'" entitytype="'+entitytype+'" specialcheck="'+specialcheck+'" ><a target="_blank" href="index.php?pageto_module='+tmpmodulename+'&pageto_action=index&page_addurl='+encodeURIComponent(newUrl)+'">'+label+moduleblankStr+'</a></li>';
                    }else{
                        if(linkurl.indexOf('CustomReport/JsReport/index.php?')>=0){
                            linkurl = cls_encryptyurl.Puyoung_Encryptyurlhavephp(linkurl,'');
                        }
                        html+='<li tabid="'+tabid+'" relid="'+relid+'" title="'+label+'" type="'+type+'" linkurl="'+linkurl+'"   entitytype="'+entitytype+'" specialcheck="'+specialcheck+'" ><a target="_blank" href="'+linkurl+'">'+label+moduleblankStr+'</a></li>';
                    }

                }else if(objs['uselinkurl'] == 'yes'){
                    html+='<li tabid="'+tabid+'" relid="'+relid+'" title="'+label+'" type="'+type+'" module="'+tmpmodulename+'"><a target="_self" href="'+objs['linkurl']+'">'+label+moduleblankStr+'</a></li>';
                }else{
                    html+='<li tabid="'+tabid+'" relid="'+relid+'" title="'+label+'" type="'+type+'" module="'+tmpmodulename+'"><a target="_self" href="index.php?pageto_module='+tmpmodulename+'&pageto_action=index">'+label+moduleblankStr+'</a></li>';
                }
            })
            html+='</ul>';

            ld("#pageleft .menu-thumbnail-box").show();
            var windowHeight = ld(window).height();
            var bottomHeight = parseInt(windowHeight) - parseInt(top);
            var thumbnailHeight = 0;
            var thumbnailCount = tmpchildobjs.length;
            if(thumbnailCount == 1){
                thumbnailHeight = 44;
            }
            else if(thumbnailCount > 10){
                thumbnailHeight = 480;
            }
            else{
                thumbnailHeight = thumbnailCount*45;
            }
            if(parseInt(bottomHeight) < parseInt(thumbnailHeight)){
                top = parseInt(windowHeight) - parseInt(thumbnailHeight) - parseInt(20);
            }
            ld("#pageleft .menu-thumbnail-body").html(html);
            ld('#pageleft .menu-thumbnail-box').css('top', top+'px');
            //加载子菜单滚动条
            ld(' .menu-thumbnail-body').slimscroll({
                height: 'auto',
                position: 'right',
                railOpacity: 1,
                size: "5px",
                opacity: .4,
                color: '#777777',
                wheelStep: 5,
                touchScrollStep: 50
            });
            //子菜单点击事件
            /**
             * 2020-6-1
             * 修改获取所有子菜单 包括自定义菜单
             */
            var liobjs=ld("#pageleft .menu-thumbnail-list").find("li");
            ld.each(liobjs,function(){
                ld(this).unbind("click").bind("click",function(event){
                    menucommon.childmenuclickbefore(ld(this).attr('relid'),event);
                    //ld(".statistic-analysis-sidebar").getNiceScroll().remove();
                    //ld('.main_grid .main_grid_box').getNiceScroll().remove();
                    ld(".layui-laydate").remove();//关掉首页日期弹出层
                })
            });

            //子菜单打开新标签绑定点击事件
            ld(' .moduleblank').unbind('click').bind('click',function(event){
                //edit: xll 2024/02/23 BUG20240220-19 报表分析中，模块报表、统计图设为链接模块加入菜单后，打开新页签显示错误
                LeftMenu_function.getInstance().childMenuOpenNewTab(ld(this));
            });

            //
            ld('.nav-menu-footer').hover(
                function(){
                    ld('div.menu-thumbnail-box').hide();//隐藏子菜单
                },
                function(){

                }
            );

        }
    },function (){
        var newimg = ld(this).find('.page-link').find('img').attr('data-active');
        ld(this).find('.page-link').find('img').attr('src', newimg);
    });
    //子菜单隐藏
    ld("#pageleft").hover(function (){
        if(cur_pageLeftType == 'Close'){
            showMenu();//菜单显示
        }
    },function (){
        if(cur_pageLeftType == 'Close'){
            hideMenu();//菜单隐藏
        }
        cleanMainMenuStatus();//清除主菜单效果
        if(clickMenuName != ''){
            // 标记选中导航区块
            ld(" div.page-menu li[name='"+clickMenuName+"']").find('.page-link').addClass('selected');
            // 标记选中区块颜色
            var newimg = ld(" div.page-menu li[name='"+clickMenuName+"']").find('.page-link').find('img').attr('data-active');
            ld(" div.page-menu li[name='"+clickMenuName+"']").find('.page-link').find('img').attr('src', newimg);
        }
    });
    //菜单展开收起
    ld('.dropdownmenu_ding').on('click',function(event){
        if(ld('.dropdownmenu_ding').attr('tag') == 'Open'){

            localStorage.setItem('ldcrm_ding_status', 'Close');
            closeMenu();//收起
            hideMenu();//菜单隐藏
        }
        else{
            localStorage.setItem('ldcrm_ding_status', 'Open');
            openMenu();//打开
            showMenu();//菜单显示

        }
        setWidthForAll();//计算宽度
    });

}

var logesettimeobj = null;
//菜单显示
function showMenu(){

    ld(' .nav-menu').css('width', pageleft_unfold+'px');
    ld(' .page-link a').css('max-width', '140px');
    ld(' .page-link .parenttabrel-item').css('max-width', '140px');
    logesettimeobj = setTimeout(function(){
        ld(' .logo-img .logo-pic-normal').show();
        ld(' .logo-img .logo-pic-mini').hide();
        ld('.search-module-box input.search-module-input').show();
    },300);
    ld('#ding_btn').show();
    ld(' .search-module-area').show();

    ld('#suspensionmenu').addClass('pageleft_unfold');
    ld('#suspensionmenu').removeClass('pageleft_fold');

    if(cur_pageLeftType == 'Close'){

    }else{
        ld('.dropdownmenu_ding').find('.leftmenu-fonticon').html('&#xe622;');
        ld('.dropdownmenu_ding').find('span').text(arrJsPopLabel['CollapseNavigation']);
        ld('.dropdownmenu_ding').attr('data-tip',arrJsPopLabel['CollapseNavigation']);
    }
    ld('.nav-menu-footer-two').eq(0).attr('data-direction','top')  ;

    if(ld('#dropdownmenu').length > 0){
        dropdownMenuShowBind();
    }

    initSlimscroll();

}
//菜单隐藏
function hideMenu(){
    clearTimeout(logesettimeobj);
    cleanMainMenuStatus();//清除主菜单效果
    ld('div.menu-thumbnail-box').hide();//隐藏子菜单
    ld(' .nav-menu').css('width', pageleft_fold+'px');
    ld(' .page-link a').css('max-width', '24px');
    ld(' .page-link .parenttabrel-item').css('max-width', '24px');

    ld(' .logo-img .logo-pic-normal').hide();
    ld(' .logo-img .logo-pic-mini').show();
    ld('.search-module-box input.search-module-input').hide();
    ld('#ding_btn').hide();

    ld('#suspensionmenu').addClass('pageleft_fold');
    ld('#suspensionmenu').removeClass('pageleft_unfold');


    ld('.dropdownmenu_ding').find('.leftmenu-fonticon').html('&#xe621;');
    ld('.dropdownmenu_ding').removeClass('dingicon_hide').addClass('dingicon_show');
    ld('.dropdownmenu_ding').find('span').text(arrJsPopLabel['ExpandNavigation']);
    ld('.dropdownmenu_ding').attr('data-tip',arrJsPopLabel['ExpandNavigation']);
    ld('.nav-menu-footer-two').eq(0).attr('data-direction','right')  ;
    // ld(' .search-module-area').hide();
    if(ld('#dropdownmenu').length > 0) {
        dropdownMenuHideBind();
    }
    initSlimscroll();
}
//清除主菜单效果
function cleanMainMenuStatus(){
    ld('.page-menu > ul > li div:first-child').each(function(){
        ld(this).removeClass('selected');
    });
    ld('.page-menu > ul > li div img').each(function(){
        //var img = ld(this).attr('src');
        //img = img.replace("_hover","");
        var img = ld(this).attr('data-inactive');
        ld(this).attr('src', img);
    });
}
//锁定事件
function initDingFunction(){
    if(localStorage.getItem('ldcrm_ding_status') && localStorage.getItem('ldcrm_ding_status') != ''){
        cur_pageLeftType = localStorage.getItem('ldcrm_ding_status');
    }
    else{
        cur_pageLeftType = 'Open';
    }
    if(!empty(LeftMenu_functionobj.selectedparenttab) && !empty(LeftMenu_functionobj.selectedparenttabrel)){
        var selectedobj = ld('#pageleft #dropdownmenu .parenttab-items').find('li.parenttab-li[name="'+LeftMenu_functionobj.selectedparenttab+'"]');
        if(selectedobj.length > 0){
            selectedobj.addClass('selected');
            selectedobj.children().addClass('selected');
            if(cur_pageLeftType == 'Open'){
                if(selectedobj.find('.parenttabrel-items ul li:not(.parenttitle_li)').length > 1){
                    selectedobj.find('.parenttabrel-items').show();
                }
                var imgobg = selectedobj.children().find('[name=parenttabicon]');
                if(imgobg.length > 0){
                    var imgurl = imgobg.data('active');
                    if(imgobg.get(0).tagName == 'IMG'){
                        imgobg.attr('src',imgurl);
                    }else{
                        imgobg.text(imgurl);
                    }
                }

            }

            var selectrelobj = selectedobj.find('.parenttabrel-items').find('.parenttab-item .parenttabrel-item[relid='+LeftMenu_functionobj.selectedparenttabrel+']');
            if(selectrelobj.length > 0){
                selectrelobj.parent().addClass('selected');
            }
        }
    }
    if(cur_pageLeftType == 'Close'){
        hideMenu();//菜单隐藏
        closeMenu();//收起
    }
    else{
        openMenu();//打开
        showMenu();//菜单显示
    }
    setWidthForAll();//计算宽度
}

//收起
function closeMenu(){
    cur_pageLeftType = 'Close';
    ld(' .main-content').css('left', pageleft_fold+'px');
    ld('#ding_btn').attr('tag', 'Close');
    ld('#ding_btn').removeClass('dingOn');

    ld(' .nav-menu').css('width', pageleft_fold+'px');
    ld('.dropdownmenu_ding').attr('tag', 'Close');
    // ld('#rptContentLoading').css('left', 'calc(50% + 20px)');
}
//打开
function openMenu(){
    cur_pageLeftType = 'Open';
    ld(' .main-content').css('left', pageleft_unfold+'px');
    ld('#ding_btn').attr('tag', 'Open');
    ld('#ding_btn').addClass('dingOn');

    ld(' .nav-menu').css('width', pageleft_unfold+'px');
    ld('.dropdownmenu_ding').attr('tag', 'Open');
    // ld('#rptContentLoading').css('left', 'calc(50% + 75px)');
}

function hidequickcreate() {
    if (!ld('#quickcreate').get(0).contains(event.target)) {
        ld('#quickcreate').hide();
        ld("body").off('click',hidequickcreate);
    }
}

//加载右侧头部事件
function initPageRightHeader(){
    //拨号input值的变化事件
    ld("#callnumber_yiwei").bind("input propertychange", function() {
        var call_string = ld(this).val();
        if(call_string != ''){
            ld('.page-topsec-inputbox span.call-clear-btn').addClass('show');
        }
        else{
            ld('.page-topsec-inputbox span.call-clear-btn').removeClass('show');
        }
    });
    //删除拨号input值事件
    ld('.page-topsec-inputbox .call-clear-btn').click(function(){
        ld('#callnumber_yiwei').val('');
        ld('.page-topsec-inputbox span.call-clear-btn').removeClass('show');
    });
    //全局搜索input值的变化事件
    ld("#pagehead #query_string").bind("input propertychange", function() {
        var query_string = ld(this).val();
        if(query_string != ''){
            ld(this).parent().find('span.search-clear-btn').addClass('show');
        }
        else{
            ld(this).parent().find('span.search-clear-btn').removeClass('show');
        }
    });
    //删除全局搜索input值事件
    ld('.page-topsec-inputbox .search-clear-btn').click(function(){
        ld(this).parent().find('#query_string').val('');
        ld(this).parent().find('#query_string').focus();
        ld(this).parent().find('span.search-clear-btn').removeClass('show');
    });
    ld("#quickcreatebar").off('click').on('click',function () {
        event.stopPropagation();
        if(ld('#quickcreate').css('display') == 'none'){
            ld('#quickcreate').show();
            if(ld('#create_commonaccount').val() != undefined && ld('#create_commonaccount').val() != 'undefined'){
                if(ld('#create_commonaccount').val() == 'no'){
                    ld('#quickcreate [tag=Accounts]').hide();
                }else{
                    ld('#quickcreate [tag=Accounts]').show();
                }
            }else{
                ld('#quickcreate [tag=Accounts]').show();
            }
            ld("body").on('click',hidequickcreate);
        }
        else{
            hidequickcreate();
        }
    });
    //快速创建设置事件绑定
    ld('.quickly .quickly-title .quicklyset-btn').on('click',function(event){
        // ld(" .quickly-title").css('display','none');
        //edit:can 2020-12-31 044055: （61mis.com/kfbcrm）首页-快速创建-设置快速创建显示的功能模块；点击设置按钮，选择模块保存后；再次点击设置按钮，会出现没反应状况
        ld("#quickcreate").hide();
        UnifiedQuickcreate_SelectModuleForm(ld(this));
    });
    ld('.quickly .quickcreate-search-area #quickcreate-setting-btn').on('click',function(event){
        event.stopPropagation();
        ld('#quickcreate').hide();
        ld("body").off('click',hidequickcreate);
        UnifiedQuickcreate_SelectModuleForm(ld(this));
    });
    //快速创建事件绑定
    ld('.quickly .list .quicklymodule').on('click',function(event){
        event.stopPropagation();
        var quick_module = ld(this).attr('tag');
        var _edit = ld(this).attr('edit');
        if(!empty(quick_module)){
            ld('#quickcreate').hide();
            ld("body").off('click',hidequickcreate);
            var url="";
            //edit:can 2020-11-12 报价单快速创建
            AjaxJSPage(quick_module + "_js", 'include/js/modules/' + quick_module + '/' + quick_module + '.js');
            if(_edit == 2){
                var popupobj=CrmPopup.getPopupObj("last");
                var objparams=new CreatePagePopup.params();
                objparams.params['createdtype'] = 'quickcreate';
                if( quick_module == 'Accounts'){
                    url += '&quickcreate_publicaccount=yes';    //公海参数设置创建的客户类型 快速创建默认，公海参数默认客户类型
                }

                CreatePagePopup.showpage(quick_module,url,objparams,event);
            }
            else{
                listviewbutton_click(this,quick_module,'Create');
            }
        }
    });

    //右上角消息
    ld("#noticebar").hover(function (){
        ld('#noticeHeader').show();
        //异地登录
        surl = "index.php?module=Reminds&action=RemindsAjax&file=index";
        ldAjaxNoProgress(surl,"",function(data){
            if(data.code==DataCode.logincontrol)
            {
                Tools.Relogin();
            }
        })
    },function (){
        ld('#noticeHeader').hide();
    });
    //右上角更多事件
    ld("#oamenubar").hover(function (){
        //ld(this).find('.ld_icon_arrowdown').addClass('ld_icon_arrowdown_active');
        ld('#oamenu').show();
    },function (){
        //ld(this).find('.ld_icon_arrowdown').removeClass('ld_icon_arrowdown_active');
        ld('#oamenu').hide();
    });
}

//加载左侧搜索模块事件
function initleftMenuSearchModule(){
    //搜索模块input值的变化事件
    /*ld("#search-module-input").bind("input propertychange", function() {
        var querymodule_string = ld(this).val();
        LeftMenu_functionobj.leftMenuSearchModule(querymodule_string);
    });
    ld('#search-module-input').focus(function(){
        var querymodule_string = ld(this).val();
        LeftMenu_functionobj.leftMenuSearchModule(querymodule_string);
    });
    ld("#search-module-input").hover(function(){
        var querymodule_string = ld(this).val();
        LeftMenu_functionobj.leftMenuSearchModule(querymodule_string);
    });
    */
    ld('#search-module-input').unbind('focus').bind('focus',function(){
        var obj = ld("#pageleft .search-module-area #menusearchpopup");
        if(obj.get(0).style.display == 'none'){
            LeftMenu_functionobj.MenuSearch_default();
        }
    });
    ld('#search-module-input').blur(function(){
        ld("#pageleft .search-module-area #menusearchpopup").hide();
    });
    let debounceTimeout;
    ld('#search-module-input').bind("input propertychange", function(){
        if(empty(ld(this).val())){

        }else{
            ld('.search-module-box span.searchmodule-clear-btn').removeClass('show');
        }
        clearTimeout(debounceTimeout);
        // Set a new timeout
        debounceTimeout = setTimeout(() => {
            if(!empty(ld(this).val())){
                LeftMenu_functionobj.MenuSearch_bytext(ld(this).val());
            }else{
                LeftMenu_functionobj.MenuSearch_default();
            }
        }, 500);  // 1 second delay

    });
    //删除模块input值的变化事件
    ld('.search-module-box .searchmodule-clear-btn').click(function(){
        ld('#search-module-input').val('');
        ld('#search-module-input').focus();
        ld('.search-module-box span.searchmodule-clear-btn').removeClass('show');
    });
}

//新菜单收起
function dropdownMenuHideBind() {

    var dropdownmenuobj = ld('#dropdownmenu ul.parenttab-items');

    if(dropdownmenuobj.find('li.parenttab-li.selected').length > 0){
        const style = window.getComputedStyle(ld('#pageleft_unfold.nav-menu').get(0));
        const bgColor = style.backgroundColor;
        const normalizedBgColor = bgColor.toLowerCase().replace(/\s+/g, '');
        if(normalizedBgColor === 'rgba(255,255,255,1)' || normalizedBgColor === 'rgb(255,255,255)' || normalizedBgColor === '#ffffff'){
            dropdownmenuobj.find('li.parenttab-li.selected').children().css('background','#F7F8FA');
        }else{
            dropdownmenuobj.find('li.parenttab-li.selected').children().css('background','rgb(255,255,255,0.06)');
        }

        var imgobg = dropdownmenuobj.find('li.parenttab-li.selected').find('[name=parenttabicon]');
        if(imgobg.length > 0){
            var imgurl = imgobg.data('active');
            if(imgobg.get(0).tagName == 'IMG'){
                imgobg.attr('src',imgurl);
            }else{
                imgobg.text(imgurl);
            }
        }
    }

    ld('#dropdownmenu').addClass('pageleft_fold');
    ld('#dropdownmenu').removeClass('pageleft_unfold');
    //加载子菜单滚动条
    ld('#dropdownmenu .parenttabrel-items ul').css('max-width','480px');
    var parentrelulobj = ld('#dropdownmenu .parenttabrel-items ul');
    ld.each(parentrelulobj,function(){
        ld(this).slimscroll({
            height: 'auto',
            position: 'right',
            railOpacity: 1,
            size: "5px",
            opacity: .4,
            color: '#777777',
            wheelStep: 5,
            touchScrollStep: 50
        });
    });

    ld('#dropdownmenu.pageleft_fold ul.parenttab-items li.parenttab-li').unbind('click');
    dropdownmenuobj.find('li.parenttab-li').find('.parenttabrel-items').hide();
    ld('#dropdownmenu.pageleft_fold ul.parenttab-items li.parenttab-li').hover(
        function () {
            if(ld(this).find('.parenttabrel-items').length > 0){
                ld(this).find('.parenttabrel-items').show();

                var top = ld(this).offset().top;

                if(top + ld(this).find('.parenttabrel-items ul').get(0).offsetHeight > window.innerHeight){
                    if(ld(this).find('.parenttabrel-items ul').get(0).offsetHeight > top+ld(this).get(0).offsetHeight){
                        ld(this).find('.parenttabrel-items').css('top',0);
                        ld(this).find('.parenttabrel-items').css('bottom','unset');
                    }else{
                        ld(this).find('.parenttabrel-items').css('top','unset');
                        ld(this).find('.parenttabrel-items').css('bottom',window.innerHeight-top-ld(this).get(0).offsetHeight);
                    }

                }else{
                    ld(this).find('.parenttabrel-items').css('top',top);
                    ld(this).find('.parenttabrel-items').css('bottom','unset');
                }

                const style = window.getComputedStyle(ld('#pageleft_unfold.nav-menu').get(0));
                const bgColor = style.backgroundColor;
                const normalizedBgColor = bgColor.toLowerCase().replace(/\s+/g, '');
                ld(this).find('.parenttabrel-items ul').css('background',normalizedBgColor);
                ld(this).find('.parenttabrel-items ul').find('.parenttabrel-item').css('max-width','140px');
                ld(this).find('.parenttabrel-items ul').find('a').css('max-width','140px');
            }
        },
        function(){
            if(ld(this).find('.parenttabrel-items').length > 0){
                ld(this).find('.parenttabrel-items').hide();
            }
        }
    );
    ld('#dropdownmenu.pageleft_fold .search-module-box').unbind('click').bind('click',function () {
        localStorage.setItem('ldcrm_ding_status', 'Open');
        openMenu();//打开
        showMenu();//菜单显示
        setWidthForAll();//计算宽度
        setTimeout(function(){
            ld('#search-module-input').focus();
        },300);

    });

}
//新菜单展开
function dropdownMenuShowBind() {

    ld('#dropdownmenu').addClass('pageleft_unfold');
    ld('#dropdownmenu').removeClass('pageleft_fold');

    var dropdownmenuobj = ld('#dropdownmenu ul.parenttab-items');

    dropdownmenuobj.find('li.parenttab-li.selected').children().css('background','unset');

    if (dropdownmenuobj.find('.parenttabrel-items ul').parent().hasClass('slimScrollDiv')) {

        dropdownmenuobj.find('.parenttabrel-items ul').slimScroll({ destroy: true });
        //ld('#dropdownmenu').find('.parenttabrel-items ul').unwrap();
    }
    ld('#dropdownmenu.pageleft_unfold ul.parenttab-items li.parenttab-li').off("mouseenter mouseleave");
    if(dropdownmenuobj.find('li.parenttab-li.selected').find('.parenttabrel-items ul li:not(.parenttitle_li)').length > 1){
        dropdownmenuobj.find('li.parenttab-li.selected').find('.parenttabrel-items').show();
    }

    ld('#dropdownmenu.pageleft_unfold ul.parenttab-items li.parenttab-li').unbind('click').bind('click',function(){
        var imgobj = ld(this).children().find('img');
        var fonticonobj = imgobj = ld(this).find('.leftmenu-fonticon');

        var selimgobj = ld('#dropdownmenu.pageleft_unfold ul.parenttab-items li.parenttab-li').children().find('img');
        ld.each(selimgobj,function(){
            ld(this).attr('src',ld(this).data('inactive'));
        })
        var selfonticonobj = ld('#dropdownmenu.pageleft_unfold ul.parenttab-items li.parenttab-li').children().find('.leftmenu-fonticon');
        ld.each(selfonticonobj,function(){
            ld(this).text(ld(this).data('inactive'));
        })
        if(ld(this).hasClass('selected')){
            ld(this).removeClass('selected');
            ld(this).children().removeClass('selected');
            if(imgobj.length > 0){
                imgobj.attr('src',imgobj.data('inactive'));
            }
            if(fonticonobj.length > 0){
                fonticonobj.text(fonticonobj.data('inactive'));
            }

        }else{
            ld('#dropdownmenu.pageleft_unfold ul.parenttab-items li.parenttab-li.selected').children().removeClass('selected');
            ld('#dropdownmenu.pageleft_unfold ul.parenttab-items li.parenttab-li.selected').removeClass('selected');
           // console.log(ld('#dropdownmenu.pageleft_unfold ul.parenttab-items li.parenttab-li').find('.parenttabrel-items'));
            ld('#dropdownmenu.pageleft_unfold ul.parenttab-items li.parenttab-li').find('.parenttabrel-items').hide();
            ld(this).addClass('selected');
            ld(this).children().addClass('selected');

            if(imgobj.length > 0){
                imgobj.attr('src',imgobj.data('active'));
            }
            if(fonticonobj.length > 0){
                fonticonobj.text(fonticonobj.data('active'));
            }
        }
        if(ld(this).find('.parenttabrel-items ul li:not(.parenttitle_li)').length > 1){
            ld(this).find('.parenttabrel-items').slideToggle("fast");
        }else{
            ld(this).find('.parenttabrel-items ul li .parenttabrel-item').click();
            ld(this).find('.parenttabrel-items').hide();
        }

    });

    ld('#dropdownmenu.pageleft_unfold .search-module-box').unbind('click');

}

//左侧菜单  后台设置入口按钮绑定事件
function bindSettingsupClick() {
    if(ld('#leftmenu_settingsup').length > 0){
        ld('#leftmenu_settingsup').unbind('click').bind('click',function(){
            OpenNewWebTab(`index.php?pageto_module=Settings&pageto_action=index`);
            return ;
        });
    }
}

var LeftMenu_functionobj;
function LeftMenu_function(){
    var that=this;
    this.parenttabinfo=[];
    this.parenttabimagelist=[];
    this.childtablist=[];
    this.expandmenuhtml='';//菜单展开html
    var rightwidth=getRightWidth();
    this.pinyinAlllabel=[];
    this.flesh = 'no';
    this.InitMenu=function(){
        ld.ajax({
            url:"index.php?module=Users&action=UsersAjax&file=getParentTabList&pageto_module="+pageto_module+ "&pageto_action="+pageto_action+"&cur_menuid="+cur_menuid+"&pageto_record="+pageto_record+"&pageto_menufile="+pageto_menufile+"&page_addurl="+encodeURIComponent(page_addurl)+"&bodywidth="+rightwidth+"&pageto_create="+pageto_create+"&view_type="+view_type,
            type: 'POST',
            dataType:'json',
            timeout:20000,
            success:function(data){
                if(data.code=='-2')
                {
                    window.location.href="index.php?action=LoginCheck&module=Users";
                }
                that.parenttabinfo=data.result.parenttabs;//一级菜单
                that.childtablist=data.result.parenttablist;//二级菜单
                that.parenttabimagelist=data.result.parenttabimagelist;//一级菜单的图片
                global_bodywidth=data.result.bodywidth;
                that.current_user_id=data.result.current_user_id;//成员id
                that.cur_menuid = data.result.cur_menuid;
                //下拉菜单
                if(data.result.menutype && data.result.menutype == '2'){

                    if(data.result.menufont && !empty(data.result.menufont)){
                        that.menufont = data.result.menufont;
                    }
                    if(data.result.selectedparenttab && data.result.selectedparenttabrel){
                        that.selectedparenttab = data.result.selectedparenttab;
                        that.selectedparenttabrel = data.result.selectedparenttabrel;
                    }
                    that.getDropDownMenuHtml();

                }else{
                    that.getParentMenuHtml();
                }
                //后台设置入口按钮绑定事件
                bindSettingsupClick();

                that.pinyinAlllabel=data.result.pinyinAlllabel;
                var default_module=data.result.default_module,
                    default_label=data.result.default_label;
                var tmps={};
                tmps['module']=default_module;
                tmps['label']=default_label;
                tmps['record']=0;

                if(data.result.record>0){
                    tmps['record']=data.result.record;
                }
                if(data.result.default_action!=''){
                    tmps['file']=data.result.default_action;
                }
                if(data.result.default_url!=''){
                    tmps['url']=data.result.default_url;
                }
                if(data.result.childmenufile!=''){
                    // 39286: （51mis.com/kfbtest）系统设置界面，刷新浏览器后会自动跳转至首页界面
                    tmps['childmenufile']=data.result.childmenufile;
                }
                //alert(data.result.page_addurl);
                tmps['page_addurl'] = '';
                if(data.result.page_addurl!=''){
                    tmps['page_addurl']=data.result.page_addurl;
                }
                if(data.result.pageto_create!=''){
                    tmps['pageto_create']=data.result.pageto_create;
                }
                if(data.result.view_type!=''){
                    tmps['view_type']=data.result.view_type;
                }
                //菜单id
                tmps['relid'] = that.cur_menuid;
                menucommon.childmenuclick(tmps);
                initDingFunction();
            }
        })
    }

    this.LeftMenu_flesh=function () {
        this.flesh = 'yes';
        ld.ajax({
            url:"index.php?module=Users&action=UsersAjax&file=getParentTabList&leftmenu_left=yes",
            type: 'POST',
            dataType:'json',
            timeout:20000,
            success:function(data){
                if(data.code=='-2')
                {
                    window.location.href="index.php?action=LoginCheck&module=Users";
                }
                if(data.result.menucontent){

                    ld('aside#pageleft').html(data.result.menucontent);
                }
                that.parenttabinfo=data.result.parenttabs;//一级菜单
                that.childtablist=data.result.parenttablist;//二级菜单
                that.parenttabimagelist=data.result.parenttabimagelist;//一级菜单的图片
                global_bodywidth=data.result.bodywidth;
                that.current_user_id=data.result.current_user_id;//成员id

                //下拉菜单
                if(data.result.menutype && data.result.menutype == '2'){
                    ld("#pageleft").off("mouseenter mouseleave");
                    if(data.result.menufont && !empty(data.result.menufont)){
                        that.menufont = data.result.menufont;
                    }
                    /*if(data.result.selectedparenttab && data.result.selectedparenttabrel){
                        that.selectedparenttab = data.result.selectedparenttab;
                        that.selectedparenttabrel = data.result.selectedparenttabrel;
                    }*/
                    that.getDropDownMenuHtml();

                }else{
                    that.getParentMenuHtml();
                }

                //后台设置入口按钮绑定事件
                bindSettingsupClick();
                that.pinyinAlllabel=data.result.pinyinAlllabel;

                initDingFunction();

                initSlimscroll();//加载主菜单滚动条
                listcontentobj=ld("#pagecontent .wrapper-panel-inner");
                ld(listcontentobj).unbind("mouseover").bind("mouseover",function(){
                    ld("#pageleft .menu-thumbnail-box").hide();
                });

                //新版菜单搜索框颜色
                if(ld('#dropdownmenu').length > 0){
                    const style = window.getComputedStyle(ld('#pageleft_unfold.nav-menu').get(0));
                    const bgColor = style.backgroundColor;
                    const normalizedBgColor = bgColor.toLowerCase().replace(/\s+/g, '');
                    if(normalizedBgColor === 'rgba(255,255,255,1)' || normalizedBgColor === 'rgb(255,255,255)' || normalizedBgColor === '#ffffff'){

                    }else{
                        ld('.search-module-area').css('background-color','rgba(255,255,255,0.16)');
                        ld('.search-module-area').find('input#search-module-input').css('color','#fff');
                    }
                }

                this.flesh = 'no';
            }
        })
    }
    this.doesNotContain = function(str, elements) {
        for (let element of elements) {
            if (str.includes(element)) {
                return true;
            }
        }
        return false;
    }
    //下拉菜单
    this.getDropDownMenuHtml=function(){

        var dropdownmenuobj = ld("#pageleft #dropdownmenu .nav-menu-body ul.parenttab-items");
        var elementsToCheck = [".jpg", ".png", ".jpeg",".jpe",".gif"];
        if(that.expandmenuhtml=='' || that.flesh == 'yes'){
            if(that.flesh == 'yes'){
                that.expandmenuhtml = '';
            }

            ld.each(that.parenttabinfo,function(tmpname,tmplabel){
                if(that.childtablist[tmpname]==undefined||that.childtablist[tmpname].length <=0){
                    return true;
                }

                that.expandmenuhtml += '<li class="parenttab-li" title="'+tmplabel+'" name="'+tmpname+'">' +
                    '<div class="parenttab-item nochildren page-link">' +
                    '<a>';
                var randNum = Math.random();
                randNum = randNum.toFixed(4);
                if (that.doesNotContain(that.parenttabimagelist[tmpname]['inactive'], elementsToCheck)) {
                    that.expandmenuhtml += '<img name="parenttabicon" src="'+that.parenttabimagelist[tmpname]['inactive']+'?a='+randNum+'" data-inactive="'+that.parenttabimagelist[tmpname]['inactive']+'?a='+randNum+'" data-active="'+that.parenttabimagelist[tmpname]['active']+'?a='+randNum+'">';
                }else{
                    that.expandmenuhtml += '<div name="parenttabicon" class="leftmenu-fonticon marR10" data-inactive="'+that.parenttabimagelist[tmpname]['inactive']+'" data-active="'+that.parenttabimagelist[tmpname]['active']+'">'+that.parenttabimagelist[tmpname]['inactive']+'</div>';
                }
                that.expandmenuhtml += '<span>' +
                    '<div class="parenttab-item-title">'+tmplabel+'</div>';

                var tmpchildobjs= that.childtablist[tmpname];

                if(tmpchildobjs && tmpchildobjs.length > 1){
                    that.expandmenuhtml += '<div class="ld_icon_arrowdown" style="border-right: 1px solid '+that.menufont+';border-top: 1px solid '+that.menufont+';"></div>';

                }else{
                    that.expandmenuhtml += '<i class="moduleblank" name="parentblank" title="'+arrJsPopLabel['OPENANEWTAB']+'"></i>';
                }


                that.expandmenuhtml += '</span></a></div>';


                if(tmpchildobjs!=undefined){
                    that.expandmenuhtml += '<div class="parenttabrel-items"><ul>';
                    that.expandmenuhtml += '<li class="parenttitle_li page-link"><a><div class="hoverparenttablabel">'+tmplabel+'</div></a></li>';
                    ld.each(tmpchildobjs,function(index,objs){

                        that.expandmenuhtml+='<li><div class="parenttab-item page-link">';
                        that.expandmenuhtml+='<a class="parenttabrel_point">.</a>';
                        var moduleblankStr = '<i class="moduleblank" title="'+arrJsPopLabel['OPENANEWTAB']+'"></i>'

                        var relid = objs['id'];
                        var label=objs['modulename'];
                        var tmpmodulename=objs['tablabel'];
                        if(tmpmodulename == 'Cache' || tmpmodulename == 'MassSMS' || tmpmodulename == 'MassEmails'){
                            moduleblankStr = '';
                        }
                        var tabid = objs['tabid'];
                        var type=objs['tab_tablename'];//ld_tab,ld_linkmodulecustom;
                        if(type=='ld_linkmodulecustom'){
                            var entitytype = objs['entitytype'];// category custom  自定义链接的分类\
                            var  linkurl = objs['linkurl'];
                            var checkphp = objs['checkphp'];
                            var isopeninblank = objs['isopeninblank'];
                            if(isopeninblank == ''){
                                isopeninblank = 'no';
                            }
                            var linkcivid = objs['linkcvid'];
                            var specialcheck = checkphp+"::"+isopeninblank+"::"+linkcivid;
                            if(tmpmodulename=='CustomEcharts' || tmpmodulename== 'CustomTables'){
                                that.expandmenuhtml+='<div class="parenttabrel-item" parenttab="'+tmpname+'" tabid="'+tabid+'" relid="'+relid+'" title="'+label+'" type="'+type+'" linkurl="'+linkurl+'" module="'+tmpmodulename+'" entitytype="'+entitytype+'" specialcheck="'+specialcheck+'" ><a target="_blank" href="'+linkurl+'">'+label+moduleblankStr+'</a></div>';
                            }
                            else if(entitytype != undefined && entitytype =='category' ){
                                // @edit:dong @date:2020/12/02 @reason: bug数据分类自定义链接模块 右键打开页面错误
                                var newUrl =  linkurl.substring(linkurl.indexOf('&start',linkurl));
                                that.expandmenuhtml+='<div class="parenttabrel-item" parenttab="'+tmpname+'"  tabid="'+tabid+'" relid="'+relid+'" title="'+label+'" type="'+type+'" linkurl="'+linkurl+'" module="'+tmpmodulename+'" entitytype="'+entitytype+'" specialcheck="'+specialcheck+'" ><a target="_blank" href="index.php?pageto_module='+tmpmodulename+'&pageto_action=index&page_addurl='+encodeURIComponent(newUrl)+'">'+label+moduleblankStr+'</a></div>';
                            }else{
                                if(linkurl.indexOf('CustomReport/JsReport/index.php?')>=0){
                                    linkurl = cls_encryptyurl.Puyoung_Encryptyurlhavephp(linkurl,'');
                                }
                                that.expandmenuhtml+='<div class="parenttabrel-item" parenttab="'+tmpname+'"  tabid="'+tabid+'" relid="'+relid+'" title="'+label+'" type="'+type+'" linkurl="'+linkurl+'"   entitytype="'+entitytype+'" specialcheck="'+specialcheck+'" ><a target="_blank" href="'+linkurl+'">'+label+moduleblankStr+'</a></div>';
                            }

                        }else if(objs['uselinkurl'] == 'yes'){
                            that.expandmenuhtml+='<div class="parenttabrel-item" parenttab="'+tmpname+'"  tabid="'+tabid+'" relid="'+relid+'" title="'+label+'" type="'+type+'" module="'+tmpmodulename+'"><a target="_self" href="'+objs['linkurl']+'">'+label+moduleblankStr+'</a></div>';
                        }
                        else{
                            that.expandmenuhtml+='<div class="parenttabrel-item" parenttab="'+tmpname+'"  tabid="'+tabid+'" relid="'+relid+'" title="'+label+'" type="'+type+'" module="'+tmpmodulename+'"><a target="_self" href="index.php?pageto_module='+tmpmodulename+'&pageto_action=index">'+label+moduleblankStr+'</a></div>';
                        }

                        that.expandmenuhtml+='</div></li>';

                    })
                    that.expandmenuhtml+='</ul></div>';
                }

                that.expandmenuhtml += '</li>';


            });

            dropdownmenuobj.html(that.expandmenuhtml);
        }


        //绑定菜单点击事件
        var liobjs=dropdownmenuobj.find("li.parenttab-li .parenttabrel-items").find('.parenttab-item .parenttabrel-item');
        ld.each(liobjs,function(){
            ld(this).unbind("click").bind("click",function(event){

                menucommon.childmenuclickbefore(ld(this).attr('relid'),event);

                ld(".layui-laydate").remove();//关掉首页日期弹出层

                var parenttab = ld(this).attr("parenttab");


                var imgobg = dropdownmenuobj.find('li.parenttab-li.selected').find('[name=parenttabicon]');
                if(imgobg.length > 0){
                    var imgurl = imgobg.data('inactive');
                    if(imgobg.get(0).tagName == 'IMG'){
                        imgobg.attr('src',imgurl);
                    }else{
                        imgobg.text(imgurl);
                    }
                }


                dropdownmenuobj.find('li.parenttab-li').find('.parenttabrel-items .parenttab-item.selected').removeClass('selected');
                if(localStorage.getItem('ldcrm_ding_status') == 'Close'){
                    dropdownmenuobj.find('li.parenttab-li.selected').children().css('background','unset');
                    dropdownmenuobj.find('li.parenttab-li.selected').children().removeClass('selected');
                    dropdownmenuobj.find('li.parenttab-li.selected').removeClass('selected');
                    dropdownmenuobj.find('li.parenttab-li .parenttabrel-items').find('.parenttab-item').removeClass('selected');

                    dropdownmenuobj.find('li.parenttab-li[name="'+parenttab+'"]').addClass('selected');
                    dropdownmenuobj.find('li.parenttab-li[name="'+parenttab+'"]').children().addClass('selected');


                    const style = window.getComputedStyle(ld('#pageleft_unfold.nav-menu').get(0));
                    const bgColor = style.backgroundColor;
                    const normalizedBgColor = bgColor.toLowerCase().replace(/\s+/g, '');
                    if(normalizedBgColor === 'rgba(255,255,255,1)' || normalizedBgColor === 'rgb(255,255,255)' || normalizedBgColor === '#ffffff'){
                        dropdownmenuobj.find('li.parenttab-li[name="'+parenttab+'"]').children().css('background','#F7F8FA');
                    }else{
                        dropdownmenuobj.find('li.parenttab-li[name="'+parenttab+'"]').children().css('background','rgb(255,255,255,0.06)');
                    }
                }
                ld(this).parent().addClass('selected');

                var activeimgobg = dropdownmenuobj.find('li.parenttab-li[name="'+parenttab+'"]').find('[name=parenttabicon]');
                if(activeimgobg.length > 0){
                    var activeimgurl = activeimgobg.data('active');
                    if(activeimgobg.get(0).tagName == 'IMG'){
                        activeimgobg.attr('src',activeimgurl);
                    }else{
                        activeimgobg.text(activeimgurl);
                    }
                }
            })
        });

        //菜单展开收起
        ld('.dropdownmenu_ding').on('click',function(event){
            if(ld('.dropdownmenu_ding').attr('tag') == 'Open'){

                localStorage.setItem('ldcrm_ding_status', 'Close');
                closeMenu();//收起
                hideMenu();//菜单隐藏
            }
            else{
                localStorage.setItem('ldcrm_ding_status', 'Open');
                openMenu();//打开
                showMenu();//菜单显示
            }
            setWidthForAll();//计算宽度
        });


        //菜单悬浮色
        dropdownmenuobj.find('li .parenttab-item').hover(
            function(){

                const style = window.getComputedStyle(ld('#pageleft_unfold.nav-menu').get(0));
                const bgColor = style.backgroundColor;
                const normalizedBgColor = bgColor.toLowerCase().replace(/\s+/g, '');
                if(normalizedBgColor === 'rgba(255,255,255,1)' || normalizedBgColor === 'rgb(255,255,255)' || normalizedBgColor === '#ffffff'){
                    ld(this).css('background','#F7F8FA');
                }else{
                    ld(this).css('background','rgb(255,255,255,0.06)');
                }

                var imgobg = ld(this).find('[name=parenttabicon]');
                if(imgobg.length > 0){
                    var imgurl = imgobg.data('active');
                    if(imgobg.get(0).tagName == 'IMG'){
                        imgobg.attr('src',imgurl);
                    }else{
                        imgobg.text(imgurl);
                    }
                }
            },
            function (){
                ld(this).css('background','');
                if(ld(this).hasClass('selected')){

                }else{
                    var imgobg = ld(this).find('[name=parenttabicon]');
                    if(imgobg.length > 0){
                        var imgurl = imgobg.data('inactive');
                        if(imgobg.get(0).tagName == 'IMG'){
                            imgobg.attr('src',imgurl);
                        }else{
                            imgobg.text(imgurl);
                        }
                    }
                }

            }
        );

        //只有一个子菜单直接进入该子菜单
        ld(' .moduleblank').unbind('click').bind('click',function(event){
            if(ld(this).attr('name') == 'parentblank'){
                ld(this).parent().parent().parent().parent().find('.parenttabrel-items .moduleblank').click();
            }else{
                LeftMenu_function.getInstance().childMenuOpenNewTab(ld(this));
            }

        });

        //收起时的菜单绑定
        dropdownMenuHideBind();
        initleftMenuSearchModule();//加载左侧搜索模块事件
    }

    //悬浮菜单
    this.getParentMenuHtml=function(){
        if(that.expandmenuhtml=='' || that.flesh == 'yes'){
            if(that.flesh == 'yes'){
                that.expandmenuhtml = '';
            }
            ld.each(that.parenttabinfo,function(tmpname,tmplabel){
                if(that.childtablist[tmpname]==undefined||that.childtablist[tmpname]<=0){
                    return true;
                }
                that.expandmenuhtml+='<li title="'+tmplabel+'" name="'+tmpname+'">';
                that.expandmenuhtml+='  <div class="page-link">';
                that.expandmenuhtml+='      <a href="javascript:">';
                //zxm 2021-1206 菜单图标
                var randNum = Math.random();
                randNum = randNum.toFixed(4);
                that.expandmenuhtml+='<img src="'+that.parenttabimagelist[tmpname]['inactive']+'?a='+randNum+'" data-inactive="'+that.parenttabimagelist[tmpname]['inactive']+'?a='+randNum+'" data-active="'+that.parenttabimagelist[tmpname]['active']+'?a='+randNum+'"><span>'+tmplabel+'</span>'
                that.expandmenuhtml+='</a>';
                that.expandmenuhtml+="  </div>";
                that.expandmenuhtml+="</li>";
            });
        }
        ld("#pageleft_unfold .page-menu ul").html(that.expandmenuhtml);
        initPageLeftContent();//加载左侧箭头导航事件
        initleftMenuSearchModule();//加载左侧搜索模块事件
    }
    /*
    this.getApproveCount = function (){
      

        ldAjaxHtml('index.php','module=Approve&action=ApproveAjax&file=getApproveCount&ajax=true',function (response) {
            var rest = response.responseText;
            rest = trim(rest);
            if(rest > 0){
                document.getElementById('headerapprovecount').innerHTML = '('+trim(rest)+')';
            }
        });
    }*/


    this.childmenuclick=function(obj,event){
        //initDingFunction();//锁定事件
        var module=obj['module'];
        if(module != 'Home' && module != 'Cache' && module != 'RecycleBin' && obj['relid'] && parseInt(obj['relid']) > 0){
            var tablename = obj['type'];
            if (tablename == 'ld_linkmodulecustom' ){
                if (obj['entitytype'] == 'category'){
                    tablename += '_'+obj['entitytype'];
                }else {
                    module = '';
                }
            }
            this.saveCommonFunctions(parseInt(obj['relid']),module,obj['tabid'],tablename);
        }
        //刷新消息提醒数量
        getRemindsCount();
        //刷新审批数量
        that.getApproveCount();
        ld(".first-drawer-wrapper").remove();//删除抽屉
        clickMenuName = hoverMenuName;//记录导航区块名称
        var tmppopupobj= CrmPopup.getPopupObj("last");
        if(tmppopupobj!=undefined&&obj['module']!='Cache')
        {
            //zkt 20220408 50889: （81mis.com/kfbcrm）（列表编辑）列表处的浮显按钮，有时会不消失掉，进入系统设置里面后还在
            //列表界面出现时更新界面小编辑图标不显示
                if(typeof listeditpageobj=="undefined"|| listeditpageobj==undefined){
                    getJsScript('include/js/SystemPopup/ListEditPagePopup.js',function(){
                        var listeditpageobj=new ListEditPagePopup(tmppopupobj);
                        listeditpageobj.Noshoweidtbutton();
                    })
                }
                else{
                    listeditpageobj.Noshoweidtbutton();
                }
        }
        if(obj.type == 'ld_linkmodulecustom'){
            //zkt 【禹王：自定义报表增加对“帆软”开发的报表的访问解析支持】
            if(obj.specialcheck!=undefined && obj.specialcheck!=''&&obj.specialcheck.indexOf("::")>=0)
            {
                var specialcheck = obj.specialcheck;
                var specialcheckarr = specialcheck.split("::");
                var checkphp = specialcheckarr[0];
                var isopeninblank = specialcheckarr[1];
                var linkcivid = specialcheckarr[2];
                if(checkphp!=''&&obj.linkurl.indexOf("crm_access_token")==-1)
                {

                    var  checkurl='index.php?module=Users&action=UsersAjax&file='+checkphp+'&ajax=true&reportid='+linkcivid;
                    ld.ajax({
                        url: checkurl,
                        type: 'POST',
                        data:'',
                        dataType:'json',
                        async: false,//
                        timeout: 70000,

                        success: function(data)
                        {
                           if(data.code == 1)
                           {
                                obj.linkurl +=data.result.token;
                                DelProgressObjs();
                           }
                           else if(data.code == -1)
                           {
                                RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                                return false;
                           }
                        }
                    });
                }
                var openurl = obj.linkurl;
                if(isopeninblank=='yes')
                {
                     StopEvent(event);
                    window.open (openurl,'target');
                    return false;
                }

            }


            var ahrefobj=event.srcElement||event.target;
            //0049720: （http://crm.landleaf-tech.com/ [^]）（郎绿-邹晓宇）客户设置了个链接模块（百度）但是访问被拒绝了，百度说是给nginx配置文件中加入X-Frame-Options属性的值
            //zkt 百度新页面打开
            if(ld(ahrefobj).attr("href").toLocaleLowerCase().indexOf("www.baidu.com")>=0)
            {
                return false;
            }
            //zxm 20221103 报表分析 常用报表的链接模块 打开新页签 //20221130 常用报表的模块变成ReportAnalysis
            if(ld(ahrefobj).attr("href").indexOf("pageto_module=ReportAnalysis&pageto_action=newindex")>=0||ld(ahrefobj).attr("href").indexOf("pageto_module=ReportAnalysis&pageto_action=OftenUseReport")>=0)
            {
                obj.module = 'ReportAnalysis';
                return false;
            }
            if(window.location.href!=undefined && window.location.href.toLocaleLowerCase().indexOf("https")>=0&&ld(ahrefobj).attr("href").toLocaleLowerCase().indexOf("http:")>=0)
            {
                //edit:can 2020-10-20 42944: （https://61mis.com/kfbtest [^]）客户问题（普阳会计），首页->政务服务网，链接模块定制中的链接模块打不开，界面显示空白（需要补丁）
                return false;
            }
        }
        StopEvent(event);
        if(event!=undefined&&event!=''){
            EmptyProgressObjs();
        }


        EmptyProgressObjs();//清空
        var label=obj['label'];

        //群发短信
        if(module=='MassSMS'){
            ld("#pageleft .menu-thumbnail-box").hide();
            getMassSmsPopup();
            return false;
        }
        if(module=='MassVMS'){
            ld("#pageleft .menu-thumbnail-box").hide();
            getMassVmsPopup();
            return false;
        }
        //zkt 20240329 XUQIU20240228-01 搜客宝（工商优化2.0）
        /*if(module=='ldsoukebao'){
            StopEvent(event);
            window.open (obj.linkurl,'_blank');
            return false;
        }*/
        //群发邮件
        if(module=='MassEmails'){
            getJsScript('include/js/GroupEmail.js',function(){
                ld("#pageleft .menu-thumbnail-box").hide();
                var surl = "index.php?module=Emails&action=EmailsAjax&file=GroupEmail&return_module="+module;
                getJsScript('include/js/GroupEmail.js', function () {
                    GroupEmail.openEmailWindow(surl);
                });
            });
            return false;
        }
        var rightwidth=getRightWidth();
        if(obj.module=="Settings"){
            if(obj.file=='index'||obj.file==''||obj.file==undefined){
                obj.file='SettingLeftRight';
            }
            that.settingmenuclick(obj);
            return false;
        }
        // ls 2021-10-26 【ID1001109】增加“小程序商城设置”
        if(obj.module=="ShopSettings" || obj.module=="CardSettings"){
            if(obj.file==''||obj.file==undefined){
                obj.file='index';
            }
            that.settingmenuclick(obj);
            return false;
        }
        if(obj.module=='listroles'){
            obj.module='Settings';
            obj.file='listroles';
            that.settingmenuclick(obj);
            return false;
        }
        if(obj.module=='LoginPolicy'){
            obj.module='Settings';
            obj.file='loginpolicy';
            that.settingmenuclick(obj);
            return false;
        }

        //清除缓存
        if(module=='Cache'){
            clearcaches();
            return false;
        }


        // XUQIU1001905 liushuai 20230920 企微会话存档组织架构显示第二版（前置判断）
        if (module == 'WechatSession') {
            var wechatflag = true;
            var  checkurl='index.php?module='+module+'&action='+module+'Ajax&file=Operation&ajax=true&operationtype=checksyncnstatus';
            ld.ajax({
                url: checkurl,
                type: 'POST',
                data:'',
                dataType:'json',
                async: false,//
                timeout: 70000,
                success: function(data)
                {
                    if(data.code == -1)
                    {
                        RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                        wechatflag = false;
                        return false;
                    }
                }
            });
            if (!wechatflag){
                return false;
            }
        }

        var newUrl="";
        if(module=='OftenUseReport'){

            //edit:can 2021-01-13 044253: （106.14.77.199:85/crm）报表-常用报表（上海昶艾）；登录后在首页仍转圈加载时直接点击进常用报表模块，打开的报表界面会是7.X版本的界面，且一直转圈
            if(obj.file!=undefined&&obj.file!=''&&obj.file!='index'){
                var urlstring="index.php?module="+module+"&file="+obj.file+"&action="+module+"Ajax";
                newUrl="index.php?pageto_module="+module+"&pageto_action="+obj.file;
            }
            else{
                var urlstring="index.php?module="+module+"&file=newindex&action="+module+"Ajax";
                newUrl="index.php?pageto_module="+module+"&pageto_action=newindex";
            }
            if(obj.childmenufile!=""&&obj.childmenufile!=undefined){
                urlstring+="&report_name="+obj.childmenufile;
            }
            // urlstring += "&frommodule=ReportAnalysis";
            // var tmphref =  ld(ahrefobj).attr("href");
            // if(typeof tmphref=='string'){
            //     tmphref = tmphref.replace("index.php?pageto_module=OftenUseReport&pageto_action=newindex","");
            //     urlstring += tmphref;
            // }
        }
        else if(module=='MassEmails'){
            var urlstring="index.php?module=Emails&file=GroupEmail&action=EmailsAjax&datajson=no";
            var page_addurl=encodeURIComponent("&datajson=no");

            newUrl="index.php?pageto_module=MassEmails&pageto_action=GroupEmail&page_addurl="+page_addurl;
        }
        else{
            if(obj.file!=undefined&&obj.file!=''){
                var urlstring="index.php?module="+module+"&file="+obj.file+"&action="+module+"Ajax";

                newUrl="index.php?pageto_module="+module+"&pageto_action="+obj.file;
                if(obj.file=="LinkModuleCustom"){
                    newUrl+="&cur_menuid="+obj['relid'];
                }
            }
            else{
                var urlstring="index.php?module="+module+"&file=index&action="+module+"Ajax";
                newUrl="index.php?pageto_module="+module+"&pageto_action=index";
            }
            if(module!='Calendar'){
                urlstring += '&isshowModuleListTree=yes';
            }
        }
        /**
         * 2020-6-1
         * 自定义模块链接
         */
        // 左侧子菜单点击
        if(obj.type == 'ld_linkmodulecustom'&&ld(ahrefobj).attr("href").indexOf("pageto_module=OftenUseReport&pageto_action=newindex&page_addurl=")<0){

            if(obj.entitytype =='custom') {
                // @edit:dong @date:2020/09/17 @reason:  自定义模块链接 bug 0042531
                //原来使用的home模块 现在改为Users模块 用户模块不会被关闭
                var urlstring = "index.php?module=Users&file=LinkModuleCustom&action=UsersAjax&link=" + encodeURIComponent(encodeURIComponent(obj.linkurl))+"&id="+obj['relid'];//实际请求地址
                //  //正确的请求地址
                var page_addurl = encodeURIComponent("&link=" + encodeURIComponent(obj.linkurl));
                newUrl = "index.php?pageto_module=Users&pageto_action=LinkModuleCustom&cur_menuid="+obj['relid']+"&page_addurl=" + page_addurl; //页面显示地址

            }
            else if(obj.module=='CustomTables')
            {
              var report_id= getSearchString("report_id",  ld(obj).attr("linkurl"));
              var report_type= getSearchString("report_type",  ld(obj).attr("linkurl"));
               ld("#pageleft .menu-thumbnail-box").hide();
               if(!empty(report_type)){
                   getJsScript('include/js/modules/ReportAnalysis/ReportAnalysis.js', function () {
                       var ReportAnalysisObj = new ReportAnalysis();
                       ReportAnalysisObj.init();
                       ReportAnalysisObj.showTableDetail(report_id,report_type);
                   });
               }else{
                   //老的链接 不带report_type 需要去查询一下
                   var url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=CustomTablesListView&function_name=getReportType&report_id='+report_id;

                   //zkt 20231013 XUQIU1001341 SQL注入
                   ldAjaxNoProgress(url,'',function (data) {
                       getJsScript('include/js/modules/ReportAnalysis/ReportAnalysis.js', function () {
                           var ReportAnalysisObj = new ReportAnalysis();
                           ReportAnalysisObj.init();
                           ReportAnalysisObj.showTableDetail(report_id,data.result.report_type);
                       });
                   });
               }
                return false;
            }
            else if(obj.module=='CustomEcharts') {
                ld("#pageleft .menu-thumbnail-box").hide();
                var report_id= getSearchString("report_id",  ld(obj).attr("linkurl"));
                var report_type= getSearchString("report_type",  ld(obj).attr("linkurl"));
                getJsScript('include/js/modules/ReportAnalysis/ReportAnalysis.js', function () {
                    var ReportAnalysisObj = new ReportAnalysis();
                    ReportAnalysisObj.showEchartDetail(report_id,report_type);
                });
                return false;
            }
            else{
                //obj.entitytype =='category'
                // @edit:dong @date:2020/10/28 @reason: 数据分类变模块
                 var urlstring =obj.linkurl+"&bodywidth="+getRightWidth(); //正确的请求地址
                 if(module!='Calendar'){
                    urlstring += '&isshowModuleListTree=yes';
                }
                 //chj 2021/1/13 43348: (61mis.com/kfbcrm)链接模块-客户_客户查询；该模块是通过客户模块中数据分类中设为链接模块设置的；“数据分类”不应显示出来，且通过操作共享、批量编辑、转公海、查看范围等出现界面小刷新时会导致“管理分类”显示出来；
                 var page_addurl = encodeURIComponent(obj.linkurl);
                
                newUrl = "index.php?pageto_module="+obj.module+"&pageto_action=LinkModuleCustom&page_addurl="+page_addurl; //页面显示地址
            }
        }
        //登录后进入系统的页面 config中修改$default_module 及 $default_action
        if(obj.url != undefined &&　obj.url != '' && obj.file!=undefined &&obj.file!=''){
            var urlstring="index.php?module="+module+"&file="+obj.file+"&action=HomeAjax&link="+encodeURIComponent(encodeURIComponent(obj.url));
            var page_addurl=encodeURIComponent("&link="+encodeURIComponent(obj.url));
            newUrl="index.php?pageto_module="+module+"&pageto_action="+obj.file+"&page_addurl="+page_addurl;
        }
        // end 2020-6-1

        if(obj.page_addurl!=''&&obj.page_addurl!=undefined){
            urlstring+=obj.page_addurl;
            //解决审批中心刷新两次，界面空白
            newUrl+="&page_addurl="+encodeURIComponent(obj.page_addurl);
        }
        urlstring+="&bodywidth="+rightwidth;

        ldAjaxHtml(urlstring,{},function(data){
            CrmPopup.global_listPopupObj=[];
            ld(" .detail_path li").html(label);
            if(module == 'Users'){
                ld(" .detail_path li").addClass('detail_path_users');
            }
            else{
                ld(" .detail_path li").removeClass('detail_path_users');
            }

            // 0045308: （61mis.com/kfbcrm）成员登录后，在浏览器页签重复显示当前登录用户姓名，请去掉浏览器页签中的显示登录名
            // if(iskehu001=='yes'||currentuser_name==''){
            //     ld(document).attr("title",label);
            // }
            // else{
            //     ld(document).attr("title",currentuser_name+"-"+label);
            // }
            ld(document).attr("title",label);
            if(module=='MassEmails')
                getJsScript('include/js/GroupEmail.js', function () {
                    GroupEmail.initControl();
                });
            RemoveAllJsFileText();
            //zxm 20221115 报表模块js动态获取pageto_module值 错误获取成上一次页面的值了
            var stateObject = {};
            history.pushState(stateObject,"",newUrl);
            if(obj.type != 'ld_linkmodulecustom') {
                //BUG0074545 lius 20231027 销售的账号点开工作汇报看不到内容，需要刷新页面才有(AjaxJSPage 改为不再重复加载，工作汇报需要再次加载显示列表数据)。
                if (module == 'CooperativeWork') {
                    dynamicJsScript['Coordination_js'] = null;
                    ld("#Coordination_js").remove();
                }
                AjaxJSPage(module + "_js", 'include/js/modules/' + module + '/' + module + '.js');
            }

            listcontentobj.html(data);
            //搜客宝 hzx 20240424
            if(module=='ldsoukebao' || module=='ldsoukebaomap'){
                listcontentobj.css('margin','0').css('height','100%');
            }else{
                listcontentobj.css('margin','var(--ld-block-interval-width) var(--ld-block-interval-width) 0 var(--ld-block-interval-width)').css('height','calc(100% - var(--ld-block-interval-width)');
            }
            /*报错 先注释getJsScript("include/js/cls_ShortKey.js",function(){
                if(popupobj && popupobj.searchsmowershortkeyobj==undefined)
                  popupobj.searchsmowershortkeyobj=new cls_ShortKey(popupobj);//
                var shortkeyobj=popupobj.searchsmowershortkeyobj
                var TriggerDirectionobj=ld("#showselectsearchscope").find("[name=cmb_span_optiontext_SmOwnerSearchScope]");
                var directionparentobj=ld("#showselectsearchscope").find("[name=cmb_ul_SmOwnerSearchScope]");
                shortkeyobj.setSelectedClassName("highlighted");
                shortkeyobj.setEventByClass(TriggerDirectionobj,directionparentobj,"active-result",function(event,selectobj){
                    event.srcElement=event.target=ld(selectobj).get(0);
                    cmb_limouseover(event, 'SmOwnerSearchScope', 'showselectsearchscope')

                }, function(event,selectobj){

                    cmb_liclick(ld(selectobj).attr("userid"), 'SmOwnerSearchScope', 'showselectsearchscope')
                })
            })*/
            //var newUrl = "index.php";//修改从项目名后开始
            ld(" .Category [name=hiddenlabel]").css('display','none');
            //提醒
            ActivityReminderCallback();
            DelProgressObjs();
            if(obj.record!=undefined&&obj.record>0){
                //防止两个进度条
                if(obj.view_type == 'edit'){
                    var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",module,"","","","",obj.record);
                    Popupobj.prevshow();
                    PageRecordPopup.params['refreshpage']='no';
                    PageRecordPopup.showpage(module,obj.record,obj.page_addurl,PageRecordPopup.params);
                }else{
                    DetailViewPage.showpage(module,obj.record,obj.page_addurl,{});
                }
            }
            if(obj.pageto_create=='yes'){
                var objparams=  new CreatePagePopup.params();
                var callfilename=getSearchString("callfilename",obj.page_addurl);

                if(callfilename!=undefined&&callfilename!=''){
                    objparams.params['callcenter']='yes'; //创建页面（呼叫中心）
                }
                if(getSearchString("jiuweiid",obj.page_addurl)!=undefined&&getSearchString("jiuweiid",obj.page_addurl)!='')
                    objparams.params['callcenter']='yes'; //创建页面（呼叫中心）
                CreatePagePopup.showpage(module,obj.page_addurl,objparams);
            }
            ld('div.tool_tip').remove();//删除tip
            if(module=="TrackLocationMap")
            {
                getJsScript("https://map.qq.com/api/gljs?v=1.exp&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X&libraries=geometry",function(){
                    var trackpositionobj=TrackPosition.getInstance();
                    trackpositionobj.init('TrackLocationContainer');
                    TrackLocationMap.trackpositionobj=trackpositionobj;
                    trackpositionobj.drawpoint(trackposition_arr);


                })


            }
      });
    }

    that.settingmenuclick=function(obj){
        var newUrl = "index.php";//修改从项目名后开始
        var module=obj.module;
        var file=obj.file;
        var label=obj.label;
        if(module=='Users'&&(file=='index'||file=='listview')){
            //39378: （51mis.com/kfbtest）设置：点击“成员管理”没有反应

            menucommon.childmenuclick(obj);
            return false;
        }
        EmptyProgressObjs();
        var urlstring="index.php?module="+module+"&file="+file+"&action="+module+"Ajax";
        //39286: （51mis.com/kfbtest）系统设置界面，刷新浏览器后会自动跳转至首页界面
        newUrl="index.php?pageto_module="+module+"&pageto_action="+file;
        if(obj.childmenufile!=undefined&&obj.childmenufile!=''){
            urlstring+="&menufile="+obj.childmenufile;
            newUrl+="&menufile="+obj.childmenufile;
        }
         //duan 202207029 服务小程序和订单小程序跳转判断，因为访问的menufile相同，所以增加判断selftype
        if(obj.page_addurl!=undefined&&obj.page_addurl!=''&&obj.childmenufile=='SelfServiceConfig'){
            urlstring+="&page_addurl="+obj.page_addurl;
            newUrl+="&page_addurl="+obj.page_addurl;
        }
        ldAjax(urlstring,{},function(data){
            CrmPopup.global_listPopupObj=[];
            ld(" .detail_path li").html(label);
            if (obj.file == 'listroles') {
                if( data.result.helpUrl.ListRoles!=""){
                    var helpHtml="<b title="+arrJsPopLabel['PRODUCTHELPMANUAL']+" class=\"icon-homeimg icon-askgrey-helptips\" onclick=\"OpenNewWebTab('"+data.result.helpUrl.ListRoles+"','_blank')\"></b>";
                    ld(" .detail_path li").html(label+helpHtml);
                }
            }
            // 0045308: （61mis.com/kfbcrm）成员登录后，在浏览器页签重复显示当前登录用户姓名，请去掉浏览器页签中的显示登录名
            // if(iskehu001=='yes'||currentuser_name==''){
            //     ld(document).attr("title",label);
            // }
            // else{
            //     ld(document).attr("title",currentuser_name+"-"+label);
            // }
            ld(document).attr("title",label);
            listcontentobj.html(data.result.content);

            var stateObject = {};
            history.pushState(stateObject,"",newUrl);
            DelProgressObjs();
        });
    }

    this.leftMenuSearchModule=function(querymodule_string){
        hoverMenuName = '';//记录导航区块名称
        getScriptBackWithURL('include/js/multipingyin.js',null);
        if(querymodule_string != ''){
            ld('.search-module-box span.searchmodule-clear-btn').addClass('show');
            var tmpchildobjs= LeftMenu_functionobj.childtablist;//二级菜单的数据
            if(tmpchildobjs!=undefined){
                var modulenameArr = [];//diony 20230925 用来去重
                var html= '<ul class="menu-thumbnail-list">';
                var count = 0;
                var pinyinAlllabel = LeftMenu_functionobj.pinyinAlllabel;

                ld.each(tmpchildobjs,function(index,objs){
                    ld.each(objs,function(index,obj){
                        var relid = obj['id'];
                        var label=obj['modulename'];
                        var tmpmodulename=obj['tablabel'];
                        var tabid=obj['tabid'];
                        var moduleblankStr = '<span class="moduleblank" title="'+arrJsPopLabel['OPENANEWTAB']+'"></span>';
                        if(tmpmodulename == 'Cache' || tmpmodulename == 'MassSMS' || tmpmodulename == 'MassEmails'){
                            moduleblankStr = '';
                        }
                        var type=obj['tab_tablename'];//ld_tab,ld_linkmodulecustom;
                        //ls 2021-08-04 【ID1001788】左侧菜单导航中搜索，建议增加拼音搜索
                        var pinyinlabel = makePy(label).join("").toLowerCase();
                        if(empty(pinyinAlllabel[label])){
                            pinyinAlllabel[label]='xxxx';
                        }
                        if(label.indexOf(querymodule_string) >= 0 || pinyinlabel.indexOf(querymodule_string) >= 0 || pinyinAlllabel[label].indexOf(querymodule_string) >= 0){
                            if(modulenameArr.indexOf(label) > -1){//diony 20230925 用来去重
                                return true;
                            }
                            modulenameArr.push(label);
                            count++;
                            if(type=='ld_linkmodulecustom'){
                                var entitytype = obj['entitytype'];// category custom  自定义链接的分类\
                                var linkurl = obj['linkurl'];
                                var checkphp = objs['checkphp'];
                                var isopeninblank = objs['isopeninblank'];
                                if(isopeninblank == ''){
                                    isopeninblank = 'no';
                                }
                                var linkcivid = objs['linkcvid'];
                                var specialcheck = checkphp+"::"+isopeninblank+"::"+linkcivid;
                                if(entitytype != undefined && entitytype =='category'){
                                    // @edit:dong @date:2020/12/02 @reason: bug数据分类自定义链接模块 右键打开页面错误
                                    var newUrl =  linkurl.substring(linkurl.indexOf('&start',linkurl));
                                    html+='<li tabid="'+tabid+'" relid="'+relid+'" title="'+label+'" type="'+type+'" linkurl="'+linkurl+'" module="'+tmpmodulename+'" entitytype="'+entitytype+'" specialcheck="'+specialcheck+'" ><a target="_blank" href="index.php?pageto_module='+tmpmodulename+'&pageto_action=index&page_addurl='+encodeURIComponent(newUrl)+'">'+label+moduleblankStr+'</a></li>';
                                }
                                else{
                                    if(linkurl.indexOf('CustomReport/JsReport/index.php?')>=0){
                                        linkurl = cls_encryptyurl.Puyoung_Encryptyurlhavephp(linkurl,'');
                                    }
                                    html+='<li tabid="'+tabid+'" relid="'+relid+'" title="'+label+'" type="'+type+'" linkurl="'+linkurl+'"   entitytype="'+entitytype+'" specialcheck="'+specialcheck+'" ><a target="_blank" href="'+linkurl+'">'+label+moduleblankStr+'</a></li>';
                                }
                            }
                            else{
                                //zkt 20240407 BUG20240407-02 左边菜单->查找模块->搜客宝->点击无法打开搜客宝模块，浏览器地址栏显示 about:blank
                                if(tmpmodulename == 'ldsoukebao' && 1==2){
                                    var  linkurl = obj['linkurl'];
                                    html+='<li tabid="'+tabid+'" relid="'+relid+'" title="'+label+'" type="'+type+'" linkurl="'+linkurl+'" module="'+tmpmodulename+'" ><a target="_blank" href="'+linkurl+'">'+label+moduleblankStr+'</a></li>';
                                }else if(objs['uselinkurl'] == 'yes'){
                                    html+='<li tabid="'+tabid+'" relid="'+relid+'" title="'+label+'" type="'+type+'" module="'+tmpmodulename+'"><a target="_self" href="'+obj['linkurl']+'">'+label+moduleblankStr+'</a></li>';
                                }else{
                                    html+='<li tabid="'+tabid+'" relid="'+relid+'" title="'+label+'" type="'+type+'" module="'+tmpmodulename+'"><a target="_self" href="index.php?pageto_module='+tmpmodulename+'&pageto_action=index">'+label+moduleblankStr+'</a></li>';
                                }

                            }
                        }
                    });
                });
                html+='</ul>';
                if(count > 0){
                    ld("#pageleft .menu-thumbnail-box").show();
                    ld("#pageleft .menu-thumbnail-body").html(html);
                    ld('#pageleft .menu-thumbnail-box').css('top', '75px');
                }
                else{
                    var html= '<ul class="menu-thumbnail-list">';
                    html+='<li><a href="javascript:;">' + arrJsPopLabel['NORELATEDMODULES'] + '</a></li>';
                    html+='</ul>';
                    ld("#pageleft .menu-thumbnail-box").show();
                    ld("#pageleft .menu-thumbnail-body").html(html);
                    ld('#pageleft .menu-thumbnail-box').css('top', '75px');
                }
                //加载子菜单滚动条
                ld(' .menu-thumbnail-body').slimscroll({
                    height: 'auto',
                    position: 'right',
                    railOpacity: 1,
                    size: "5px",
                    opacity: .4,
                    color: '#777777',
                    wheelStep: 5,
                    touchScrollStep: 50
                });
                if(count > 0){
                    //子菜单点击事件
                    /**
                     * 2020-6-1
                     * 修改获取所有子菜单 包括自定义菜单
                     */
                    var liobjs=ld("#pageleft .menu-thumbnail-list").find("li");
                    ld.each(liobjs,function(){
                        ld(this).unbind("click").bind("click",function(event){
                            menucommon.childmenuclickbefore(ld(this).attr('relid'),event);
                        });
                    });
                }
                //子菜单打开新标签绑定点击事件
                ld(' .moduleblank').unbind('click').bind('click',function(event){
                    //edit: xll 2024/02/23 BUG20240220-19 报表分析中，模块报表、统计图设为链接模块加入菜单后，打开新页签显示错误
                    LeftMenu_function.getInstance().childMenuOpenNewTab(ld(this));
                });
            }
        }
        else{
            ld('.search-module-box span.searchmodule-clear-btn').removeClass('show');
            ld("#pageleft .menu-thumbnail-box").hide();
        }
    }

    /**
     * 打开新页签方法，特殊模块使用 BroadcastChannel 频道实现页签间通信
     * @param jqObj 打开新页签的 DOM Jquery 对象
     */
    this.childMenuOpenNewTab = function (jqObj) {
        StopEvent(event);
        var url = jqObj.parent().attr('href'),
            liObj = ld(jqObj.parents('li')[0]),
            type = liObj.attr('type'),
            module = liObj.attr('module'),
            pageToModule = '';
        if(type === 'ld_linkmodulecustom') {
            var newTabData;
            if(module === 'CustomTables') {
                pageToModule = 'ReportAnalysis';
                newTabData = {
                    module: 'CustomTables',
                    report_id : getSearchString("report_id",  url),
                    report_type : getSearchString("report_type",  url),
                }
            }
            else if(module === 'CustomEcharts') {
                pageToModule = 'ReportAnalysis';
                newTabData = {
                    module: 'CustomEcharts',
                    report_id : getSearchString("report_id",  url),
                    report_type : getSearchString("report_type",  url),
                }
            }
            if(pageToModule !== ''){
                //关闭当前页面对应模块的频道对象监听，即删除旧的频道对象
                if(typeof that.getChannelByModule[pageToModule] === "function") {
                    var oldChannel = that.getChannelByModule[pageToModule]();
                    if (oldChannel !== undefined) {
                        oldChannel.close();
                    }
                }
                //创建模块对应的频道并发送消息
                var channel = new BroadcastChannel(`openNewTab_${pageToModule}`);
                channel.newTabData = newTabData
                // 发送消息： 接收新页签的准备信息，再进行发送
                channel.onmessage = function(event) {
                    var message = event.data;
                    if(message === 'ready'){
                        var channel = event.target;
                        channel.postMessage(channel.newTabData);
                        //发送完毕断开连接，即不再发送
                        channel.close();
                    }
                };
                //打开新页签
                OpenNewWebTab(`index.php?pageto_module=${pageToModule}&pageto_action=index`);
                return ;
            }
        }
        OpenNewWebTab(url);
    }
    this.getChannelByModule =  {
        ReportAnalysis : function () {
            if(typeof ReportAnalysisObj !== "undefined" && ReportAnalysisObj.channel)
                return ReportAnalysisObj.channel
            return undefined;
        },
    }

    //增加常用模块
    this.saveCommonFunctions=function(relid,module,tabid,tablename){
        var url = 'index.php?module=Users&action=UsersAjax&file=commonMenu&mode=save&relid='+relid+'&clickmodule='+module+'&tabname='+tablename+'&tabid='+tabid;
        ldAjaxNoProgress(url,'',function (data) {

        });
    }

    //获取搜索历史页面和常用功能
    this.MenuSearch_default=function(){
        ld("#pageleft .menu-thumbnail-box").hide();
        ld("#pageleft .search-module-area #menusearchpopup").show();
        ld(".layui-laydate").remove();//关掉首页日期弹出层

        ld("#pageleft .search-module-area #menusearchpopup").unbind('mousedown').mousedown(function (event) {
            event.preventDefault();
        });
        ld("#pageleft .search-module-area #menusearchpopup").unbind("mouseover").bind("mouseover",function(){
            ld("#pageleft .menu-thumbnail-box").hide();
        });

        let that = this;

        if(empty(ld('#search-module-input').val())){
            var url = 'index.php?module=Users&action=UsersAjax&file=commonMenu&mode=getsearch_default';
            ldAjaxNoProgress(url,'',function (data) {
                if(data.code == 1){
                    ld("#pageleft .search-module-area #menusearchpopup").html(data.result.content);

                    //常用功能
                    var commonobjs=ld("#pageleft .search-module-area #menusearchpopup").find(".menucontent_item");
                    ld.each(commonobjs,function(){
                        ld(this).unbind("click").bind("click",function(event){
                            ld('#rptContentLoading').show();
                            if(ld('#dropdownmenu').length > 0){
                                event.preventDefault();
                                var parenttab = ld(this).attr("parenttab");
                                var relid = ld(this).attr("relid");
                                var submenuobj = ld('#dropdownmenu ul.parenttab-items li.parenttab-li[name="'+parenttab+'"]').find('.parenttabrel-item[relid='+relid+']');
                                submenuobj.click();
                                if(ld('#dropdownmenu ul.parenttab-items li.parenttab-li[name="'+parenttab+'"]').hasClass('selected')){

                                }else{
                                    ld('#dropdownmenu ul.parenttab-items li.parenttab-li[name="'+parenttab+'"]').click();
                                }
                            }
                            else{
                                menucommon.childmenuclickbefore(ld(this).attr('relid'),event);
                            }

                        })
                    });

                    //搜索历史绑定
                    var historyobjs=ld("#pageleft .search-module-area #menusearchpopup").find(".menuhistory_tag");
                    ld.each(historyobjs,function(){
                        ld(this).unbind("click").bind("click",function(event){
                            var searchtext = ld(this).data('searchtext');
                            ld('#search-module-input').val(searchtext);
                            that.MenuSearch_bytext(searchtext);
                        })
                    });

                    //删除搜索记录
                    var deletehistoryobj=ld("#pageleft .search-module-area #menusearchpopup").find(".menu_deletehistory");
                    deletehistoryobj.unbind("click").bind("click",function(event){

                        var confirm_str = arrJsPopLabel['menudeletesearchhistorytip'];
                        RemindsMsg("", "LdPopWidth400px", "", "yes", "", confirm_str);
                        ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                            var url = 'index.php?module=Users&action=UsersAjax&file=commonMenu&mode=deletehistory';
                            ldAjaxNoProgress(url,'',function (data) {
                                ld('#search-module-input').focus();
                            });
                        })
                    });
                    ld(' .moduleblank').unbind('click').bind('click',function(event){
                        //edit: xll 2024/02/23 BUG20240220-19 报表分析中，模块报表、统计图设为链接模块加入菜单后，打开新页签显示错误
                        LeftMenu_function.getInstance().childMenuOpenNewTab(ld(this));
                    });
                }
            });
        }

    }

    //查询
    this.MenuSearch_bytext=function(querymodule_string){

        ld("#pageleft .search-module-area #menusearchpopup").unbind('mousedown').mousedown(function (event) {
            event.preventDefault();
        });
        ld("#pageleft .search-module-area #menusearchpopup").unbind("mouseover").bind("mouseover",function(){
            ld("#pageleft .menu-thumbnail-box").hide();
        });

        querymodule_string = querymodule_string.replace("'", "").toLowerCase();
        hoverMenuName = '';//记录导航区块名称
        let that = this;
        getJsScript('include/js/multipingyin.js', function(){
            if(querymodule_string != ''){
                ld('.search-module-box span.searchmodule-clear-btn').addClass('show');
                var tmpchildobjs= LeftMenu_functionobj.childtablist;//二级菜单的数据
                if(tmpchildobjs!=undefined){
                    var html= '<div class="menusearchpopup_div">';
                    var count = 0;
                    var pinyinAlllabel = LeftMenu_functionobj.pinyinAlllabel;

                    var subcount = 0;
                    var blockhtml= '';
                    ld.each(tmpchildobjs,function(name,objs){
                        subcount = 0;
                        blockhtml = '';
                        ld.each(objs,function(index,obj){
                            var relid = obj['id'];
                            var label=obj['modulename'];
                            var tmpmodulename=obj['tablabel'];
                            var tabid = obj['tabid'];
                            var moduleblankStr = '<i class="moduleblank" title="'+arrJsPopLabel['OPENANEWTAB']+'"></i>';
                            if(tmpmodulename == 'Cache' || tmpmodulename == 'MassSMS' || tmpmodulename == 'MassEmails'){
                                moduleblankStr = '';
                            }
                            var type=obj['tab_tablename'];
                            var pinyinlabel = makePy(label).join("").toLowerCase();

                            if(empty(pinyinAlllabel[label])){
                                pinyinAlllabel[label]='xxxx';
                            }
                            if(label.indexOf(querymodule_string) >= 0 || pinyinlabel.indexOf(querymodule_string) >= 0 || pinyinAlllabel[label].indexOf(querymodule_string) >= 0){
                                count++;
                                subcount++;
                                var reg = new RegExp(querymodule_string, "g");
                                var show_label = label.replace(reg, '<span style="color: var(--ld-button-font-hover-default-color) !important;">'+querymodule_string+'</span>');
                                if(type=='ld_linkmodulecustom'){
                                    var entitytype = obj['entitytype'];// category custom  自定义链接的分类\
                                    var linkurl = obj['linkurl'];
                                    var linkmodulename = obj['linkmodulename'];
                                    var checkphp = objs['checkphp'];
                                    var isopeninblank = objs['isopeninblank'];
                                    if(isopeninblank == ''){
                                        isopeninblank = 'no';
                                    }
                                    var linkcivid = objs['linkcvid'];
                                    var specialcheck = checkphp+"::"+isopeninblank+"::"+linkcivid;
                                    if(entitytype != undefined && entitytype =='category'){
                                        // @edit:dong @date:2020/12/02 @reason: bug数据分类自定义链接模块 右键打开页面错误
                                        var newUrl =  linkurl.substring(linkurl.indexOf('&start',linkurl));
                                        blockhtml+='<div class="menucontent_item" tabid="'+tabid+'" parenttab="'+name+'" relid="'+relid+'" title="'+label+'" type="'+type+'" linkurl="'+linkurl+'" linkmodulename="'+linkmodulename+'" module="'+tmpmodulename+'" entitytype="'+entitytype+'" specialcheck="'+specialcheck+'" ><a target="_blank" href="index.php?pageto_module='+tmpmodulename+'&pageto_action=index&page_addurl='+encodeURIComponent(newUrl)+'">'+show_label+moduleblankStr+'</a></div>';

                                    }
                                    else{
                                        if(linkurl.indexOf('CustomReport/JsReport/index.php?')>=0){
                                            linkurl = cls_encryptyurl.Puyoung_Encryptyurlhavephp(linkurl,'');
                                        }
                                        blockhtml+='<div class="menucontent_item" tabid="'+tabid+'" parenttab="'+name+'" relid="'+relid+'" title="'+label+'" type="'+type+'" linkurl="'+linkurl+'" linkmodulename="'+linkmodulename+'"   entitytype="'+entitytype+'" specialcheck="'+specialcheck+'" ><a target="_blank" href="'+linkurl+'">'+show_label+moduleblankStr+'</a></div>';

                                    }
                                }else if(obj['uselinkurl']){
                                    blockhtml+='<div class="menucontent_item" tabid="'+tabid+'" parenttab="'+name+'" relid="'+relid+'" title="'+label+'" type="'+type+'" module="'+tmpmodulename+'"><a target="_self" href="'+obj['linkurl']+'">'+show_label+moduleblankStr+'</a></div>';
                                }
                                else{
                                    blockhtml+='<div class="menucontent_item" tabid="'+tabid+'" parenttab="'+name+'" relid="'+relid+'" title="'+label+'" type="'+type+'" module="'+tmpmodulename+'"><a target="_self" href="index.php?pageto_module='+tmpmodulename+'&pageto_action=index">'+show_label+moduleblankStr+'</a></div>';

                                }
                            }
                        });
                        if(subcount > 0){
                            html += '<div class="menusearch_block ">' +
                                '            <div class="menusearch_blocktitle">' +
                                '                <span>'+that.parenttabinfo[name]+'</span>' +
                                '            </div>' +
                                '            <div class="menusearch_blockcontent">';
                            html += blockhtml;
                            html += '</div></div>';
                        }
                    });
                    html+='</div>';

                    if(count > 0){
                        ld("#pageleft .search-module-area #menusearchpopup").html(html);

                        var commonobjs=ld("#pageleft .search-module-area #menusearchpopup").find(".menucontent_item");
                        ld.each(commonobjs,function(){
                            ld(this).unbind("click").bind("click",function(event){
                                ld('#rptContentLoading').show();
                                if(ld('#dropdownmenu').length > 0){
                                    event.preventDefault();
                                    var parenttab = ld(this).attr("parenttab");
                                    var relid = ld(this).attr("relid");
                                    var submenuobj = ld('#dropdownmenu ul.parenttab-items li.parenttab-li[name="'+parenttab+'"]').find('.parenttabrel-item[relid='+relid+']');
                                    submenuobj.click();
                                    if(ld('#dropdownmenu ul.parenttab-items li.parenttab-li[name="'+parenttab+'"]').hasClass('selected')){


                                    }else{
                                        ld('#dropdownmenu ul.parenttab-items li.parenttab-li[name="'+parenttab+'"]').click();
                                    }
                                }
                                else{
                                    menucommon.childmenuclickbefore(ld(this).attr('relid'),event);
                                }



                                var searchtext = ld('#search-module-input').val().replace("'", "");
                                if(searchtext != ''){
                                    var url = 'index.php?module=Users&action=UsersAjax&file=commonMenu&mode=savesearchhistory&searchtext='+searchtext;
                                    ldAjaxNoProgress(url,'',function (data) {
                                        //ld('#search-module-input').val('');
                                    });
                                }
                                ld('#search-module-input').blur();
                            });
                        });
                    }else{
                        //空态
                        html = '<div class="menusearch_nonecontent">' +
                            '<img src="themes/icon2023/ld-no-records.png?v=8635">' +
                            '<div>'+arrJsPopLabel['nofindcontentwithworkbefore']+'"'+querymodule_string+'"'+arrJsPopLabel['nofindcontentwithworkafter']+'</div>' +
                            '<div>'+arrJsPopLabel['Pleasetrynewkeywords']+'</div>' +
                            '</div>';
                        ld("#pageleft .search-module-area #menusearchpopup").html(html);
                    }
                }
            }
            ld(' .moduleblank').unbind('click').bind('click',function(event){
                //edit: xll 2024/02/23 BUG20240220-19 报表分析中，模块报表、统计图设为链接模块加入菜单后，打开新页签显示错误
                LeftMenu_function.getInstance().childMenuOpenNewTab(ld(this));
            });
        });

    }
}
LeftMenu_function.getInstance=function(){
    if(LeftMenu_functionobj==undefined){
        LeftMenu_functionobj=new LeftMenu_function();
    }
    return LeftMenu_functionobj;
}

