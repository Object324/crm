ld(function(){
    listcontentobj=ld("#pagecontent .wrapper-panel-inner");
    tooltip('.nav-menu-footer-two', {transition: true, time: 200});
    initPageRightHeader();//加载右侧头部事件
    LeftMenu_functionobj=PrmMenu_function.getInstance();
    LeftMenu_functionobj.InitMenu();//加载菜单
});

var LeftMenu_functionobj;
function PrmMenu_function() {
    var that=this;
    this.childtablist=[];
    var rightwidth=window.innerWidth;

    this.InitMenu = function () {
        ld.ajax({
            url:"index.php?module=Users&action=UsersAjax&file=getParentTabList&user_type=prm&pageto_module="+pageto_module+ "&pageto_action="+pageto_action+"&cur_menuid="+cur_menuid+"&pageto_record="+pageto_record+"&pageto_menufile="+pageto_menufile+"&page_addurl="+encodeURIComponent(page_addurl)+"&bodywidth="+rightwidth+"&pageto_create="+pageto_create+"&view_type="+view_type,
            type: 'POST',
            dataType:'json',
            timeout:20000,
            success:function(data){
                if(data.code=='-2')
                {
                    window.location.href="index.php?action=LoginCheck&module=Users";
                }
                that.childtablist=data.result.parenttablist;

                var menukey = 0;
                var tmp_prmmenulist = [];
                for(let i = 0;i<that.childtablist.prmnenu.length;i++){
                    that.childtablist.prmnenu[i].label = that.childtablist.prmnenu[i].modulename;
                    tmp_prmmenulist.push(that.childtablist.prmnenu[i]);
                    if(data.result.selectedparenttabrel != ''){
                        if(data.result.selectedparenttabrel == that.childtablist.prmnenu[i].id){
                            menukey = i;
                        }
                    }
                }


                getJsScript('include/js/component/ld_NavBar.js', function () {
                    var navbarobj=ld_NavBar.ShowNavBar(ld('#Prm_menu_div').get(0),tmp_prmmenulist,{
                        NavBarSelKey : menukey,
                        OnClick : function(evt){

                            menucommon.childmenuclick(evt.NavBarItem,event);
                        },
                    });

                    //后台设置入口按钮绑定事件
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
                    if(data.result.selectedparenttabrel == '' && menukey == 0){
                        tmps = tmp_prmmenulist[0];
                    }
                    var  event={};
                    navbarobj.getCurNavBarItem().target.click();
                })
                /*AjaxJSPage('ld_NavBar','include/js/component/ld_NavBar.js');
                ld_NavBar.ShowNavBar(ld('#Prm_menu_div').get(0),tmp_prmmenulist,{
                    NavBarSelKey : menukey,
                    OnClick : function(evt){
                        menucommon.childmenuclick(evt.NavBarItem,event);
                    },
                });*/


            }
        })
    }
}
PrmMenu_function.getInstance=function(){
    if(LeftMenu_functionobj==undefined){
        LeftMenu_functionobj=new PrmMenu_function();
    }
    return LeftMenu_functionobj;
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
    //右上角快速创建事件
    /*ld("#quickcreatebar").hover(function (){
        ld('#quickcreate').show();
        //chj 2021/3/2 公海池参数“公海成员客户序时簿“新建”功能下拉选项”中没有选择“普通成员”，公海成员快速创建弹出层和设置快速创建弹出层中应该不显示“客户”模块
        if(ld('#create_commonaccount').val() != undefined && ld('#create_commonaccount').val() != 'undefined'){
            if(ld('#create_commonaccount').val() == 'no'){
                ld('#quickcreate [tag=Accounts]').hide();
            }else{
                ld('#quickcreate [tag=Accounts]').show();
            }
        }else{
            ld('#quickcreate [tag=Accounts]').show();
        }
    },function (){
        ld('#quickcreate').hide();
    });*/
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
        // ld(" .quickly-title").css('display','none');
        //edit:can 2020-12-31 044055: （61mis.com/kfbcrm）首页-快速创建-设置快速创建显示的功能模块；点击设置按钮，选择模块保存后；再次点击设置按钮，会出现没反应状况
        ld("#quickcreate").hide();
        UnifiedQuickcreate_SelectModuleForm(ld(this));
    });
    //快速创建事件绑定
    ld('.quickly .list .quicklymodule').on('click',function(event){
        var quick_module = ld(this).attr('tag');
        var _edit = ld(this).attr('edit');
        if(!empty(quick_module)){
            ld('#quickcreate').hide();
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

function getLeftMenuWidth() {
    return 0;
}