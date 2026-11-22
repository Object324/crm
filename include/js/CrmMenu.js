ld(function(){
    getsettingleftmenu();
});

function getsettingleftmenu() {

    var url = 'index.php?module=Settings&action=SettingsAjax&file=SettingLeftRight&menufile='+pageto_menufile+'&page_addurl='+page_addurl;

    ldAjax(url,{},function(data){
        ld('#rptContentLoading').hide();
        if(data.result.parenttabs && data.result.parenttablist){
            var menudata = {
                current_user_id: data.result.current_user_id,
                collapse: 'show',
                collapsetype: 'no',
                menugroup: data.result.parenttabs,
                submenulist: data.result.parenttablist,
                pinyinAlllabel: data.result.pinyinAlllabel,
                collapsebind: {
                    show: function (){
                        ld(' .nav-menu').css('width', '200px');
                        logesettimeobj = setTimeout(function(){
                            ld(' .logo-img .logo-pic-normal').show();
                            ld(' .logo-img .logo-pic-mini').hide();
                            ld('.search-module-box input.search-module-input').show();
                        },300);
                        ld(' .main-content').css('left', '200px');
                        ld('#dropdownmenu').addClass('pageleft_unfold');
                        ld('#dropdownmenu').removeClass('pageleft_fold');
                        ld('#dropdownmenu.pageleft_unfold .search-module-box').unbind('click');
                        initSlimscroll();
                    },
                    hide: function (){
                    }
                },
                menusearchobj: ld('#search-module-input').get(0),
                menuclick: function (event) {
                    LeftMenuSettingClick(event,ld(event));
                },
            };
            if(data.result.parenttabimagelist){
                menudata['Menugroupicon'] = data.result.parenttabimagelist;
            }
            var CrmMenuobj = new ld_CrmMenu();

            CrmMenuobj.InitMenu(ld('#pageleft #dropdownmenu .nav-menu-body ul.parenttab-items').get(0),menudata);//加载左边的菜单

            var childmenufile = data.result.menufile;

            var selftype = data.result.selftype;
            var formodule=getSearchString("formodule",window.location.href);

            var firstmenuobj;
            if(childmenufile!='')
            {
                ld.each(ld(CrmMenuobj.menuchildlistobj),function(){
                    //39286: （51mis.com/kfbtest）系统设置界面，刷新浏览器后会自动跳转至首页界面
                    var action=getSearchString("action",ld(this).attr("link"));
                    //duan 202207029 服务小程序和订单小程序跳转判断，因为访问的menufile相同，所以增加判断selftype
                    if(action==childmenufile && (action!='SelfServiceConfig' || empty(selftype) || getSearchString("selftype",ld(this).attr("link"))== selftype) )
                    {
                        firstmenuobj=ld(this);
                        ld(this).attr("page_addurl","&formodule="+formodule);
                        var tmp_page_addurl=encodeURIComponent("&formodule="+formodule);
                        var stateObject = {};
                        //0041140: （61mis.com/kfbtest）设置>系统设置>页面设置：点击“客户”页面设置，然后刷新浏览器，页面设置界面显示空白
                        var newUrl=location.href+"&page_addurl="+tmp_page_addurl;
                        history.pushState(stateObject,"",newUrl);

                        return false;
                    }
                })
            }
            else
            {
                firstmenuobj=CrmMenuobj.menuchildlistobj.get(0);
            }
            if(firstmenuobj != undefined){
                firstmenuobj.click();
                ld(CrmMenuobj.LayoutObj).find('li.parenttab-li[name='+ld(firstmenuobj).attr('parenttab_name')+']').click();
                ld(firstmenuobj).attr("page_addurl",'');
            }
        }

    });
    initPageRightHeader();
}

//浏览器窗口大小变化时
/*ld(window).resize(function() {
    initSlimscroll();//加载主菜单滚动条
});*/


//加载右侧头部事件
function initPageRightHeader(){
    //右上角更多事件
    ld("#oamenubar").hover(function (){
        //ld(this).find('.ld_icon_arrowdown').addClass('ld_icon_arrowdown_active');
        ld('#oamenu').show();
    },function (){
        //ld(this).find('.ld_icon_arrowdown').removeClass('ld_icon_arrowdown_active');
        ld('#oamenu').hide();
    });
    //返回首页绑定
    ld('#BackHomeBtn').unbind('click').bind('click',function () {
        window.location.replace("index.php?pageto_module=Home&pageto_action=index")
        return ;
    });
    //返回首页绑定
    ld('#pageleft_unfold .logo-img').unbind('click').bind('click',function () {
        window.location.replace("index.php?pageto_module=Home&pageto_action=index")
        return ;
    });
}

//加载主菜单滚动条
function initSlimscroll(){
    ld(' .sub-menu').slimscroll({
        // width: '100%', //可滚动区域宽度
        height: 'auto', //可滚动区域高度
        size: '5px', //滚动条宽度，即组件宽度
        color: '#DCDEE0', //滚动条颜色
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

function ld_CrmMenu() {

    let that = this;

    //用户id
    this.current_user_id = 1;

    //菜单容器对象
    this.LayoutObj = null;

    //是否默认收起
    this.collapse = 'hide';

    //展开收起绑定事件
    this.collapsebind = {show:null,hide:null};

    //是否开启展开收起功能
    this.collapsetype =  'no';

    //一级菜单
    this.menugroup = {};

    //二级菜单
    this.submenulist ={};

    //拼音
    this.pinyinAlllabel = {};

    //字体颜色
    this.menufont = '#3B4859';

    //一级菜单icon
    this.Menugroupicon = {};

    //菜单点击事件
    this.menuclick = null;

    //搜索事件
    this.menusearchobj = null;

    this.menuchildlistobj = null;

    //初始化菜单
    this.InitMenu = function (obj,menudata) {
        this.LayoutObj = obj;

        if(menudata.current_user_id){
            this.current_user_id = menudata.current_user_id;
        }
        if(menudata.collapse){
            this.collapse = menudata.collapse;
        }
        if(menudata.collapsetype){
            this.collapsetype = menudata.collapsetype;
        }
        if(menudata.collapsebind){
            this.collapsebind = menudata.collapsebind;
        }
        if(menudata.menugroup){
            this.menugroup = menudata.menugroup;
        }
        if(menudata.submenulist){
            this.submenulist = menudata.submenulist;
        }
        if(menudata.pinyinAlllabel){
            this.pinyinAlllabel = menudata.pinyinAlllabel;
        }
        if(menudata.Menugroupicon){
            this.Menugroupicon = menudata.Menugroupicon;
        }
        if(menudata.menufont){
            this.menufont = menudata.menufont;
        }
        if(menudata.menuclick){
            this.menuclick = menudata.menuclick;
        }
        if(menudata.menusearchobj){
            this.menusearchobj = menudata.menusearchobj;
        }



        if(this.LayoutObj != undefined && this.LayoutObj != null){
            this.Dropdownmenuhtml();
        }



    }

    //生成下拉菜单html
    this.Dropdownmenuhtml = function(){
        that.expandmenuhtml = '';
        ld.each(that.menugroup,function(tmpname,tmplabel){
            if(that.submenulist[tmpname]==undefined||that.submenulist[tmpname]<=0){
                return true;
            }
            if(tmpname == 'ENTERPRISE_MANAGEMENT'){
                that.expandmenuhtml += '<li class="parenttab-title fontnowrap">'+arrJsPopLabel['systemmanagement']+'</li>'
            }else if(tmpname == 'MODULE_MENU_MANAGEMENT'){
                that.expandmenuhtml += '<li class="parenttab-title fontnowrap">'+arrJsPopLabel['crmmanagement']+'</li>'
            }else if(tmpname == 'LBL_INTERFACE_SETTINGS'){
                that.expandmenuhtml += '<li class="parenttab-title fontnowrap">'+arrJsPopLabel['Integratedmanagement']+'</li>'
            }
            that.expandmenuhtml += '<li class="parenttab-li" title="'+tmplabel+'" name="'+tmpname+'">' +
                '<div class="parenttab-item nochildren page-link">' +
                '<a>';
            var randNum = Math.random();
            randNum = randNum.toFixed(4);

            if(that.Menugroupicon[tmpname]) {
                that.expandmenuhtml += '<img src="' + that.Menugroupicon[tmpname]['inactive'] + '?a=' + randNum + '" data-inactive="' + that.Menugroupicon[tmpname]['inactive'] + '?a=' + randNum + '" data-active="' + that.Menugroupicon[tmpname]['active'] + '?a=' + randNum + '">';
                that.expandmenuhtml += '<span>' +
                    '<div class="parenttab-item-title">'+tmplabel+'</div>';
            }else{
                that.expandmenuhtml += '<span style="max-width: 100%;">' +
                    '<div class="parenttab-item-title">'+tmplabel+'</div>';
            }
            var tmpchildobjs= that.submenulist[tmpname];
            //@edit:zhaosk @date:2024/08/08 @reason:后台设置首页不要箭头
            if(tmpchildobjs.length<2){}
            else
                that.expandmenuhtml += '<div class="ld_icon_arrowdown" style="border-right: 1px solid '+that.menufont+';border-top: 1px solid '+that.menufont+';"></div>';
            
            that.expandmenuhtml += '</span></a></div>';


            if(tmpchildobjs!=undefined){
                that.expandmenuhtml += '<div class="parenttabrel-items"><ul>';
                that.expandmenuhtml += '<li class="parenttitle_li page-link"><a><div class="hoverparenttablabel">'+tmplabel+'</div></a></li>';
                ld.each(tmpchildobjs,function(index,objs){

                    that.expandmenuhtml+='<li><div class="parenttab-item page-link">';
                    that.expandmenuhtml+='<a class="parenttabrel_point">.</a>';
                    var moduleblankStr = '<i class="moduleblank" title="'+arrJsPopLabel['OPENANEWTAB']+'"></i>';

                    that.expandmenuhtml+='<div class="parenttabrel-item" parenttab_name="'+tmpname+'"';
                    ld.each(objs,function (attrname,attrvalue) {
                        that.expandmenuhtml += ' '+attrname+'="'+attrvalue+'"';
                    });
                    that.expandmenuhtml+='><a>'+objs.label+'</a></div>';



                    that.expandmenuhtml+='</div></li>';

                })
                that.expandmenuhtml+='</ul></div>';
            }

            that.expandmenuhtml += '</li>';

        });
        ld(that.LayoutObj).html(that.expandmenuhtml);
        that.showmenuafter();
        that.Menuafterbind();
    }

    //生成菜单后操作
    this.showmenuafter = function () {

        if(that.collapse == 'hide'){

        }else{
            that.menushow();
        }
    }

    //菜单绑定事件
    this.Menuafterbind = function () {

        //菜单悬浮色
        ld(that.LayoutObj).find('li .parenttab-item').hover(
            function(){
                const style = window.getComputedStyle(ld('#pageleft_unfold.nav-menu').get(0));
                const bgColor = style.backgroundColor;
                const normalizedBgColor = bgColor.toLowerCase().replace(/\s+/g, '');
                if(normalizedBgColor === 'rgba(255,255,255,1)' || normalizedBgColor === 'rgb(255,255,255)' || normalizedBgColor === '#ffffff'){
                    ld(this).css('background','#F7F8FA');
                }else{
                    ld(this).css('background','rgb(255,255,255,0.06)');
                }

                if(ld(this).find('img').length > 0){
                    var imgobg = ld(this).find('img');
                    var imgurl = imgobg.data('active');
                    if(imgurl != ''){
                        imgobg.attr('src',imgurl);
                    }
                }
            },
            function (){
                ld(this).css('background','');
                if(ld(this).hasClass('selected')){

                }else{
                    if(ld(this).find('img').length > 0){
                        var imgobg = ld(this).find('img');
                        var imgurl = imgobg.data('inactive');
                        if(imgurl != ''){
                            imgobg.attr('src',imgurl);
                        }
                    }
                }

            }
        );

        //绑定菜单点击事件
        var liobjs=ld(that.LayoutObj).find("li.parenttab-li .parenttabrel-items").find('.parenttab-item .parenttabrel-item');
        that.menuchildlistobj = liobjs;
        ld.each(liobjs,function(){
            ld(this).unbind("click").bind("click",function(event){
                event.stopPropagation();

                var imgobg = ld(that.LayoutObj).find('li.parenttab-li.selected').find('img');
                if(imgobg.length > 0){
                    var imgurl = imgobg.data('inactive');
                    if(imgurl != ''){
                        imgobg.attr('src',imgurl);
                    }
                }
                ld(that.LayoutObj).find('.parenttabrel-items .parenttab-item.selected').removeClass('selected');
                ld(this).parent().addClass('selected');
                if(that.collapse == 'hide'){
                    ld(that.LayoutObj).find('li.parenttab-li.selected').children().css('background','unset');
                    ld(that.LayoutObj).find('li.parenttab-li.selected').removeClass('selected');
                    ld(that.LayoutObj).find('li.parenttab-li.selected').children().removeClass('selected');
                    ld(that.LayoutObj).find('li.parenttab-li .parenttabrel-items').find('.parenttab-item').removeClass('selected');
                    ld(that.LayoutObj).find('li.parenttab-li .parenttabrel-items').hide();

                    ld(that.LayoutObj).find('li.parenttab-li[name='+ld(this).attr('parenttab_name')+']').addClass('selected')
                    ld(that.LayoutObj).find('li.parenttab-li[name='+ld(this).attr('parenttab_name')+']').children().addClass('selected');

                    const style = window.getComputedStyle(ld('#pageleft_unfold.nav-menu').get(0));
                    const bgColor = style.backgroundColor;
                    const normalizedBgColor = bgColor.toLowerCase().replace(/\s+/g, '');
                    if(normalizedBgColor === 'rgba(255,255,255,1)' || normalizedBgColor === 'rgb(255,255,255)' || normalizedBgColor === '#ffffff'){
                        ld(that.LayoutObj).find('li.parenttab-li[name='+ld(this).attr('parenttab_name')+']').children().css('background','#F7F8FA');
                    }else{
                        ld(that.LayoutObj).find('li.parenttab-li[name='+ld(this).attr('parenttab_name')+']').children().css('background','rgb(255,255,255,0.06)');
                    }
                }
                var activeimgobg = ld(that.LayoutObj).find('li.parenttab-li[name='+ld(this).attr('parenttab_name')+']').find('img');
                if(activeimgobg.length > 0){
                    var activeimgurl = activeimgobg.data('active');
                    if(activeimgurl != ''){
                        activeimgobg.attr('src',activeimgurl);
                    }
                }

                if(that.menuclick != null){
                    that.menuclick(this);
                }
            })
        });

        //绑定搜索事件
        if(that.menusearchobj != null){
            that.Menusearchbind();
        }
    }

    //绑定菜单搜索事件
    this.Menusearchbind = function () {

        ld(that.menusearchobj).unbind('focus').bind('focus',function(){
            ld('#menusearchpopup').show();
        });
        ld('#search-module-input').blur(function(){
            ld('#menusearchpopup').hide();
        });
        let debounceTimeout;
        ld(that.menusearchobj).bind("input propertychange", function(){
            if(empty(ld(this).val())){

            }else{
                ld('.search-module-box span.searchmodule-clear-btn').removeClass('show');
            }
            clearTimeout(debounceTimeout);
            // Set a new timeout
            debounceTimeout = setTimeout(() => {
                if(!empty(ld(this).val())){
                    ld('.search-module-box span.searchmodule-clear-btn').addClass('show');
                    that.MenuSearch_bytext(ld(this).val());
                }else{

                }
            }, 500);  // 1 second delay

        });
        //删除模块input值的变化事件
        ld('.search-module-box .searchmodule-clear-btn').click(function(){
            ld('#search-module-input').val('');
            ld('#menusearchpopup').hide();
            ld('.search-module-box span.searchmodule-clear-btn').removeClass('show');
        });
    }

    //搜索
    this.MenuSearch_bytext=function(querymodule_string) {

        ld("#menusearchpopup").mousedown(function (event) {
            event.preventDefault();
        });

        querymodule_string = querymodule_string.replace("'", "").toLowerCase();
        hoverMenuName = '';//记录导航区块名称
        getJsScript('include/js/multipingyin.js', function(){
            if (querymodule_string != '') {
                var tmpchildobjs = that.submenulist;//二级菜单的数据
                if (tmpchildobjs != undefined) {
                    var html = '<div class="menusearchpopup_div">';
                    var count = 0;
                    var pinyinAlllabel = that.pinyinAlllabel;

                    var subcount = 0;
                    var blockhtml = '';
                    ld.each(tmpchildobjs, function (name, objs) {
                        subcount = 0;
                        blockhtml = '';
                        ld.each(objs, function (index, obj) {

                            var label = obj['label'];

                            var pinyinlabel = makePy(label).join("").toLowerCase();

                            if (empty(pinyinAlllabel[label])) {
                                pinyinAlllabel[label] = 'xxxx';
                            }
                            if (label.indexOf(querymodule_string) >= 0 || pinyinlabel.indexOf(querymodule_string) >= 0 || pinyinAlllabel[label].indexOf(querymodule_string) >= 0) {
                                count++;
                                subcount++;
                                var reg = new RegExp(querymodule_string, "g");
                                var show_label = label.replace(reg, '<span style="color: var(--ld-button-font-hover-default-color) !important;">'+querymodule_string+'</span>');
                                blockhtml += '<div class="menucontent_item" parenttab_name="'+name+'"';
                                ld.each(obj,function (attrname,attrvalue) {
                                    blockhtml += ' '+attrname+'="'+attrvalue+'"';
                                });
                                blockhtml += '><a>' + show_label + '</a></div>';
                            }
                        });
                        if (subcount > 0) {
                            html += '<div class="menusearch_block ">' +
                                '            <div class="menusearch_blocktitle">' +
                                '                <span>' + that.menugroup[name] + '</span>' +
                                '            </div>' +
                                '            <div class="menusearch_blockcontent">';
                            html += blockhtml;
                            html += '</div></div>';
                        }
                    });
                    html += '</div>';

                    if (count > 0) {
                        ld("#menusearchpopup").html(html);
                        var menu_itemobj = ld("#menusearchpopup").find('.menucontent_item');
                        ld.each(menu_itemobj,function(objindex,menu_item){
                            //每个搜索内容绑定点击事件
                            ld(menu_item).unbind('click').bind('click',function(){
                                ld('#search-module-input').blur();
                                var submenuobj = ld(that.LayoutObj).find("li.parenttab-li .parenttabrel-items").find('.parenttab-item .parenttabrel-item[fieldid='+ld(this).attr('fieldid')+']');
                                submenuobj.click();
                                if(ld(that.LayoutObj).find('li.parenttab-li[name='+ld(this).attr('parenttab_name')+']').hasClass('selected')){

                                }else{
                                    ld(that.LayoutObj).find('li.parenttab-li[name='+ld(this).attr('parenttab_name')+']').click();
                                }
                            });
                        });
                    } else {
                        //空态
                        html = '<div class="menusearch_nonecontent">' +
                            '<img src="themes/icon2023/ld-no-records.png?v=8635">' +
                            '<div>' + arrJsPopLabel['nofindcontentwithworkbefore'] + '"' + querymodule_string + '"' + arrJsPopLabel['nofindcontentwithworkafter'] + '</div>' +
                            '<div>' + arrJsPopLabel['Pleasetrynewkeywords'] + '</div>' +
                            '</div>';
                        ld("#menusearchpopup").html(html);
                    }
                }
            }
        });
    }

    //菜单展开事件
    this.menushow = function () {
        ld(this.LayoutObj).find('.page-link a').css('max-width', '170px');
        ld(this.LayoutObj).find('.page-link .parenttabrel-item').css('max-width', '170px');

        ld(this.LayoutObj).find('li.parenttab-li.selected').children().css('background','unset');

        if (ld(this.LayoutObj).find('.parenttabrel-items ul').parent().hasClass('slimScrollDiv')) {
            ld(this.LayoutObj).find('.parenttabrel-items ul').slimScroll({ destroy: true });
        }
        ld(this.LayoutObj).find('li.parenttab-li').off("mouseenter mouseleave");


        ld(this.LayoutObj).find('li.parenttab-li.selected').find('.parenttabrel-items').show();


        ld(this.LayoutObj).find('li.parenttab-li').unbind('click').bind('click',function(){
            var imgobj = ld(this).children().find('img');
            if(imgobj.length > 0){
                var selimgobj = ld(that.LayoutObj).find('li.parenttab-li').children().find('img');
                ld.each(selimgobj,function(){
                    ld(this).attr('src',ld(this).data('inactive'));
                })
            }

            if(ld(this).hasClass('selected')){
                ld(this).removeClass('selected');
                ld(this).children().removeClass('selected');
                if(imgobj.length > 0){
                    imgobj.attr('src',imgobj.data('inactive'));
                }
            }else{
                ld(that.LayoutObj).find('li.parenttab-li.selected').children().removeClass('selected');
                ld(that.LayoutObj).find('li.parenttab-li.selected').removeClass('selected');
                ld(that.LayoutObj).find('li.parenttab-li').find('.parenttabrel-items').hide();
                ld(this).addClass('selected');
                ld(this).children().addClass('selected');
                if(imgobj.length > 0){
                    imgobj.attr('src',imgobj.data('active'));
                }

            }
            if(ld(this).find('.parenttabrel-items ul li:not(.parenttitle_li)').length > 1){
                ld(this).find('.parenttabrel-items').slideToggle("fast");
            }else{
                //@edit:zhaosk @date:2024/08/08 @reason:子菜单只有一项时，点击即为选中
                ld(this).addClass('selected');
                ld(this).children().addClass('selected');
                ld(this).find('.parenttabrel-items ul li .parenttabrel-item').click();
                ld(this).find('.parenttabrel-items').hide();
            }
        });

        if(that.collapsebind.show && that.collapsebind.show != null){
            that.collapsebind.show();
        }
    }
}




var pageleft_unfold=170;//未收起是左侧导航宽度
var pageleft_fold=60;//收起是左侧导航宽度

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