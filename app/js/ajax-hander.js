//全局事件处理对象
var EventHanderObj = {
    currentAjax: null//AJAX定义
};
//处理刷新
EventHanderObj.refreshAjax = function (callback) {
    var c_category = category,
        c_viewId = ViewObj.getCurrentViewId();
    switch (c_viewId) {
        case 'cwn-popuselect-view':
            if (category === 'crm') {
                EventHanderObj.refreshCrmPopupRfList(callback);
            } else if (category === 'work') {
                EventHanderObj.refreshWorkRelationList(callback);
            }
            break;
        // crm 列表页刷新
        case 'crm-list-view':
            EventHanderObj.refreshCrmList(callback);
            break;
        // work首页 以及 work搜索列表页、news 工作提醒页
        case 'work-main-view': //故意没有写 break
        case 'wn-worklist-view':
            if (category === 'news') {
                EventHanderObj.refreshNewsList(callback);
            } else if (category === 'work') {
                EventHanderObj.refreshWorkList(callback);
            }
            break;
        case 'wn-userinfo-view'://工作协同-个人信息页刷新
            EventHanderObj.refreshWorkList(callback);
            break;
        case 'wn-replayfileat-view':
        case 'news-third-view':// news 三级页面刷新（除news页 work-list-view外）
            EventHanderObj.refreshNewsList(callback);
            break;
        // crm news work 关联信息页刷新
        case 'cwn-relationlist-view':
            EventHanderObj.refreshCrmRelationList(callback);
            break;
        //附近客户
        case 'crm-nearbyaccounts-search-view':
            EventHanderObj.refreshNearbyaccountsList(callback);
            break;
    }
};
//crm列表刷新
EventHanderObj.refreshCrmList = function (callback) {
    var urlstring = '',
        category_key = '',
        category_value = '';
    if (module === 'Accounts') {
        category_key = 'category_Accounts_all';
        if(ViewObj.rootScope.accountresult==='ALLACCOUNT'){
            category_key = 'category_Accounts_all';
        }
        else if(ViewObj.rootScope.accountresult==='PUBLICALLOCATE'){
            category_key = 'category_Accounts_public';
        }
        else if(ViewObj.rootScope.accountresult==='NOALLOCATE'){
            category_key = 'category_Accounts_no';
        }
    }
    else {
        if (module != 'Approve') {
            category_key = 'category_' + module;
        }
    }
    if (module != 'Approve') {
        category_value = CacheObj.get(category_key);
        if(category_value == '' || category_value == null){
            category_value = 'SmOwner_Search_Me';
        }
    }
    if (GVObj.crmObj.liststatus === 0) {//其他列表
        if (module == 'Approve') {            
            urlstring = 'fromapprovemodule=' + ViewObj.rootScope.approvemodule + '&page=' + SwiperObj.ListPageObj.getListPageIndex();
        }
        else{
            urlstring = 'module=' + module + '&action=index&viewid=' + category_value + 
                    '&page=' + SwiperObj.ListPageObj.getListPageIndex() + '&searchcontent=' + searchcontent;
        }
        getCRMList(urlstring, function () {
            if (ld.isFunction(callback)) {
                callback();
            }
        });
    } else {
        //签到列表，刷新
        var choosename = ld('#divTab>div>.curr').attr('choosename');
        if (choosename == 'undefined' || choosename === '') {
            choosename = 'curmonth';//默认本月
        }
        urlstring = 'module=Singin&action=index' + '&signuserid=' + signuserid + '&viewid=' + choosename;
        getSign(urlstring, function () {
            if (ld.isFunction(callback)) {
                callback();
            }
        });
    }
};
//crm相关信息列表刷新
EventHanderObj.refreshCrmRelationList = function (callback) {
    var urlstring = 'module=' + newmodule + '&action=index' +
        '&viewid=SmOwner_Search_All&page=' + SwiperObj.ListPageObj.getListPageIndex() +
        '&searchcontent=' + searchcontent; // 默认是第一页
    getRelatedList(urlstring, function () {
        if (typeof callback !== 'undefined') {
            callback();
        }
    });
};
//crm 关联弹出页 刷新
EventHanderObj.refreshCrmPopupRfList = function (callback) {
    var popmoduleName = moduleNameStr;
    if (moduleNameStr === 'UsersMore') {
        popmoduleName = 'Users';
    }
    var urlstring = 'module=' + popmoduleName + '&action=Pop' +
        popmoduleName + '&searchcontent=' + searchcontentDetail;
    if (moduleNameStr != 'Users') {
        urlstring += '&page=' + SwiperObj.ListPageObj.getListPageIndex();
    }
    if (popmodule === 'photo' || popmodule === 'sign') {
        urlstring += '&noprfiledata=true';
    }
    if (moduleNameStr !== 'Accounts' && GVObj.crmObj.parentid !== 0 && ViewObj.rootScope.parentstatus === 'yes') {
        urlstring += '&parentid=' + GVObj.crmObj.parentid;
    }
	var keyids = '';
	if(GVObj.crmObj.parentid != undefined){
		keyids = GVObj.crmObj.parentid;
	}
	urlstring += '&frommodule=' + module + '&keyids='+GVObj.crmObj.parentid;
    if(moduleNameStr === 'ShareUsers'){
        urlstring = 'module=Users&action=changeShareUser&method=getShareUser&scopetype=user&searchcontent=&searchtype=byscope&filterrecordid=' + recordID;
        getShareUsersList(urlstring, function () {
            if (typeof callback !== 'undefined') {
                callback();
            }
        })
    }
    else{
        getChooseModuleList(urlstring, function () {
            if (typeof callback !== 'undefined') {
                callback();
            }
        });
    }
};
//work首页页面 刷新
EventHanderObj.refreshWorkList = function (callback) {
    var urlstring = 'smallcategory=' + smallcategory + '&bigcategory=' +
        bigcategory + '&page=' + SwiperObj.ListPageObj.getListPageIndex() + '&searchcontent=' +
        work_searchcontent + // 默认是第一页
        '&method=getList';
    var view_id = ViewObj.getCurrentViewId();
    if( view_id === 'wn-userinfo-view'){
        urlstring = urlstring + '&viewuserid=' + ld("#wn-userinfo-view .userinfo ul li").attr('curid');
    }
    else if(view_id === 'wn-replayfileat-view'){
        urlstring = urlstring + '&viewuserid=' + ld('#atmine_tab').attr('curid');
    }
    workHandleObj.getWorkList(urlstring, function () {
        if (typeof callback === 'function') {
            callback();
        }
    });
};
//work相关信息弹出页
EventHanderObj.refreshWorkRelationList = function (callback) {
    var urlstring = '';
    urlstring = 'module=' + relationtype + '&action=Pop' + relationtype;
    if (relationtype === 'Accounts') {
        urlstring += '&noprfiledata=true';
    }
    if (!SwiperObj.is_addMore) {//搜索和 刷新都要清空原来的内容
        if (relationtype === 'Accounts') {
            t_choose_a_relationidobj = [], t_choose_a_relationnameobj = [];//关联数据id,关联数据名称，临时保存 客户
        }
        else if (relationtype === 'Contacts') {
            t_choose_c_relationidobj = [], t_choose_c_relationnameobj = [];//关联数据id,关联数据名称，临时保存 联系人
        }
        else if (relationtype === 'Products') {
            t_choose_p_relationidobj = [], t_choose_p_relationnameobj = [];//关联数据id,关联数据名称，临时保存 产品
        }
    }
    urlstring += '&searchcontent=' + ViewObj.rootScope.work_rel_search + '&page=' + SwiperObj.ListPageObj.getListPageIndex();
    workHandleObj.getRelationList(urlstring, function () {
        if (typeof callback === 'function') {
            callback();
        }
    });
};
//news页面刷新
EventHanderObj.refreshNewsList = function (callback) {
    var news_type = GVObj.newstype,
        viewname = '',
        urlstring = '';  // 用局部变量替换全局变量
    switch (news_type) {
        case 'approvelist'://  工作提醒 --> 待处理、@我的工作、我发出的工作
        case 'atworklist':
        case 'mylaunchlist':
            urlstring = 'smallcategory=' + GVObj.news_smallcategory + '&bigcategory=' + news_type +
                '&page=' + SwiperObj.ListPageObj.getListPageIndex() +
                '&searchcontent=' + work_searchcontent +
                '&method=getWorkRemindsAppList';
            var view_id = ViewObj.getCurrentViewId();
            if(view_id === 'wn-replayfileat-view'){
                urlstring = urlstring + '&viewuserid=' + ld('#atmine_tab').attr('curid');
            }
            workHandleObj.getWorkList(urlstring, function () {
                if (typeof callback === 'function') {
                    callback();
                }
            });
            return;// 返回方法，不执行后面操作
            break;
        case 'replylist':// 工作提醒 --> 我发出工作的回复、@我的回复
        case 'atreplylist':
            urlstring = 'module=Home&action=ListView&method=getWorkRemindsAppList&' +
                'smallcategory=' + GVObj.news_smallcategory + '&bigcategory=' + news_type +
                '&page=' + SwiperObj.ListPageObj.getListPageIndex() +
                '&searchcontent=' + work_searchcontent;
            var view_id = ViewObj.getCurrentViewId();
            if(view_id === 'wn-replayfileat-view'){
                urlstring = urlstring + '&viewuserid=' + ld('#atmine_tab').attr('curid');
            }
            viewname = 'myreply_list';
            break;
        case 'mypraiselist'://  工作提醒 --> 我收到的赞
            urlstring = 'module=Home&action=ListView&method=getWorkRemindsAppList&' +
                'smallcategory=' + GVObj.news_smallcategory + '&bigcategory=' + news_type +
                '&page=' + SwiperObj.ListPageObj.getListPageIndex() +
                '&searchcontent=' + work_searchcontent;
            viewname = 'mypraise_list';
            break;
        case 'unread'://消息提醒
        case 'readen':
        case 'email':
            viewname = 'message_list';
            urlstring = 'module=Home&action=ListView&method=getRemindsList&' +
                'type=' + news_type + '&page=' + SwiperObj.ListPageObj.getListPageIndex();
            break;
        case 'Pendingapproval'://审批提醒
        case 'Approved':
        case 'Last30day':
            urlstring = 'module=Approve&action=ListView&fromapprovemodule=' + ViewObj.rootScope.approvemodule + 
                        '&page=' + SwiperObj.ListPageObj.getListPageIndex() + '&approvestatus=' + ViewObj.rootScope.approvetype;     
            viewname = 'approve_list';
            break;
        case 'noticeunread'://公告提醒
        case 'noticereaden':
        case 'noticerelease':
            viewname = 'notice_list';
            urlstring = 'module=Home&action=ListView&method=getNoticeList&' +
                'type=' + news_type + '&page=' + SwiperObj.ListPageObj.getListPageIndex();
            break;
    }
    newsObj.getNewsThirdList(viewname, urlstring, function () {
        if (typeof callback === 'function') {
            callback();
        }
    });
};
// 异步获取 crm、应用首页
EventHanderObj.initCrmAndApplyMenuView = function (viewModule, callback) {
    var urlstring = '',
        img_h = Math.ceil(SwiperObj.PHONE_WIDTH / 10);
    if (viewModule === "CRM") {
        urlstring = 'module=Home&action=ListView&method=getCRMModules';
    } else if (viewModule === "应用") {
        urlstring = 'module=Home&action=ListView&method=getApplyModules'
    }
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest),
            listmodule = '',
            listmodulename = '',
            listhtml = '',
            listhtml2 = '',
            home_list = '',
            showtype = restobj.result.showtype;//1方格;2列表

        if(restobj.result.list){
            home_list = restobj.result.list;
            if(home_list){
                ld.each(home_list, function (main_key, main_list) {
                    listhtml2 += '<ul class="crm-homelists">';
                    ld.each(main_list, function (key, list) {
                        listmodule = list.module;
                        listmodulename = list.title;
                        //方格显示  
                        listhtml += '<li module="' + listmodule + '" modulename="' + listmodulename + '"><img style="width:' + img_h + 'px;height:' + img_h + 'px;" src="images/crm_' + listmodule + '.png"><span>' + listmodulename + '</span></li>';
                        //列表显示
                        listhtml2 += '<li module="' + listmodule + '" modulename="' + listmodulename + '"><a href="javascript:void(0);" class="crm_' + listmodule + '"><img src="images/crm_' + listmodule + '_s.png"></a><span>' + listmodulename + '<i class="lnr-chevron-right"></i></span></li>';
                    });
                    listhtml2 += '</ul>';
                });
            }
            else{
                listhtml = '<div class="no_message_tip"><img alt="" src="images/no_message_picture.png"><p>您没有模块权限</p></div>';
                listhtml2 = '<div class="no_message_tip"><img alt="" src="images/no_message_picture.png"><p>您没有模块权限</p></div>';
            }
        }
        else{
            home_list = restobj.result.blocklist;
            if(home_list){
                ld.each(home_list, function (main_key, main_list) {
                    listhtml += '<ul class="crm-hometable">';
                    listhtml2 += '<ul class="crm-homelists">';
                    if(main_list.blockname != ''){
                        listhtml += '<p>'+main_list.blockname+'</p>';
                        listhtml2 += '<p>'+main_list.blockname+'</p>';
                    }
                    ld.each(main_list.list, function (key, list) {
                        listmodule = list.module;
                        listmodulename = list.title;
                        //方格显示  
                        listhtml += '<li module="' + listmodule + '" modulename="' + listmodulename + '"><img style="width:' + img_h + 'px;height:' + img_h + 'px;" src="images/crm_' + listmodule + '.png"><span>' + listmodulename + '</span></li>';
                        //列表显示
                        listhtml2 += '<li module="' + listmodule + '" modulename="' + listmodulename + '"><a href="javascript:void(0);" class="crm_' + listmodule + '"><img src="images/crm_' + listmodule + '_s.png"></a><span>' + listmodulename + '<i class="lnr-chevron-right"></i></span></li>';
                    });
                    listhtml += '</ul>';
                    listhtml2 += '</ul>';
                });    
            }
            else{
                listhtml = '<div class="no_message_tip"><img alt="" src="images/no_message_picture.png"><p>您没有模块权限</p></div>';
                listhtml2 = '<div class="no_message_tip"><img alt="" src="images/no_message_picture.png"><p>您没有模块权限</p></div>';
            }
        }

        //判断crm菜单默认显示：1方格显示，2列表显示
        ld('#crmSudoku,#crmList').addClass('ui-hide');
        //方格显示
        if(restobj.result.list) {
            ld('#crmSudoku').html('<ul class="crm-hometable">' + listhtml + '</ul>');
        }
        else{
            ld('#crmSudoku').html(listhtml);
        }
        //列表显示
        ld('#crmList').html(listhtml2);
        if (showtype == '1') {
            ViewObj.setAppHeader(['', '', '', viewModule, '列表', '']);
            GVObj.main_header = ['', '', '', viewModule, '列表', ''];
            ld('#crmSudoku').removeClass('ui-hide');            
        } else {
            ViewObj.setAppHeader(['', '', '', viewModule, '方格', '']);
            GVObj.main_header = ['', '', '', viewModule, '方格', ''];
            ld('#crmList').removeClass('ui-hide');
        }
        ld("#status").hide();
        callback();
    });
};
//中止AJAX请求
EventHanderObj.stopAjax = function () {
    //如若上一次AJAX请求未完成，则中止请求
    if (EventHanderObj.currentAjax) {
        ld('#status').hide();
        EventHanderObj.currentAjax.abort()
    }
};
// 点击头部数据分类 的选项
EventHanderObj.pulldownMenuClick = function (targetobj, options) {
    var _this = targetobj;
    OperationObj.triggerCilckEvent(ld('#poplayerMask'));
    if (_this.get(0).tagName.toLowerCase() === 'li') { // 当前点击元素为li时执行
        var c_vid = ViewObj.getCurrentViewId();

        searchcontent = ''; // 全局变量赋值
        // crm一级列表页 头部分类
        if (c_vid === 'crm-list-view') {
            var title = _this.attr('title'),
                urlstring = '';
            //其他列表
            if (GVObj.crmObj.liststatus == 0) {
                ViewObj.rootScope.SearchScope = _this.attr('name'); //  全局变量赋值
                if (module == 'Accounts') {
                    urlstring = 'module=Accounts&action=index&page=1&viewid=' + ViewObj.rootScope.SearchScope;//默认是第一页
                } else {
                    urlstring = 'module=' + module + '&action=index' +
                                '&viewid=' + ViewObj.rootScope.SearchScope + '&page=1&searchcontent=' + searchcontent;//默认是第一页
                }
                var category_key = '';
                if (module == 'Accounts') {
                    if(ViewObj.rootScope.accountresult==='ALLACCOUNT'){
                        category_key = 'category_' + module + '_all';
                    }
                    else if(ViewObj.rootScope.accountresult==='PUBLICALLOCATE'){
                        category_key = 'category_' + module + '_public';
                    }
                    else if(ViewObj.rootScope.accountresult==='NOALLOCATE'){
                        category_key = 'category_' + module + '_no';
                    }
                } else {
                    category_key = 'category_' + module;
                }
                CacheObj.set(category_key, ViewObj.rootScope.SearchScope, 60 * 60 * 24 * 30);
                // 重新获取数据
                ViewObj.switchView('crm-list-view', 'init', {
                    __app_header: ['<', '', 'v', title, '-', '-'],
                    url_string: urlstring
                });
            } else {
                //签到列表，如果选择同事，弹出同事列表
                if (_this.attr('name') == '我的签到') {
                    var urlstring = 'module=Singin&action=index';
                    urlstring += '&signuserid=' + userid + '&viewid=curmonth';
                    ViewObj.switchView('crm-list-view', 'init', {
                        __app_header: ['<', '', 'v', title, '', ''],
                        url_string: urlstring
                    });
                } else {
                    ViewObj.switchView('cwn-popuselect-view', 'init', {
                        view_name: 'users_list',
                        'return_module': 'OftenUseReport',//模块，常用报表
                        'searchtype': 'byscope',//类型 (bymodule:根据模块权限; byscope:根据授权范围; all:全部)
                        'filterown': 'no',//是否过滤自己(yes:过滤, no:不过滤)
                        'scopetype': 'user',//显示类型( group:只显示部门; user:只显示用户; groupuser:显示部门及用户)
                        'common': 0,//是否显示常用标签(0:不显示;1:常用标签下没有我的选项;2:常用标签下有我的选项)
                        'isactive': 'no',//是否显示禁用用户（yes:显示,no:不显示  默认no）
                        'popup_type':'no',//分配
                        itemFun: function (target_item, related_obj) {
                            var signuserid = target_item.attr('tag').replace('user', '');//  全局变量赋值
                            var header_title = target_item.find('span>i').html();
                            urlstring = 'module=Singin&action=index' +
                                '&signuserid=' + signuserid + '&viewid=curmonth';

                            ViewObj.switchView('crm-list-view', 'init', {
                                __app_header: ['<', '', 'v', header_title, '', ''],
                                url_string: urlstring,
                                'signuserid': signuserid,
                                __direction: 'right_out'
                            });
                        }
                    });
                }
            }
            //  crm费用报销->选择源原单头部
        } else if (c_vid.indexOf('popuselect') > -1) {
            moduleNameStr = _this.attr('title');
            var urlstring = 'module=' + moduleNameStr + '&action=Pop' + moduleNameStr +
                '&page=1&searchcontent=' + searchcontentDetail + '&parentid=' + GVObj.crmObj.parentid;

            ld('#head_mid span:visible').html('选择' + _this.attr('name'));
            getChooseModuleList(urlstring, function () { });
            // work发布页 点击
        } else if (c_vid === 'work-release-view') {
            ViewObj.switchView('work-release-view', 'init', {
                target_obj: targetobj,
                __footer_id: 'wn-release-footer'
            });
        }
    }
};
// 点击工作页面 发布页
EventHanderObj.workPopAddtion = function (targetobj, options) {
    var _this = targetobj.parents('.pop_workItem');
    // 点击关闭按钮
    if (targetobj.attr('class') &&
        targetobj.attr('class').indexOf('lnr-plus') > -1 &&
        targetobj.parents('.pop-workadd').length === 1) {
        if (targetobj.hasClass('onProcess')) return;
        workHandleObj.workAddtion();
        // 点击选项
    } else if (_this.length === 1 ||
        targetobj.attr('class') === 'pop_workItem') {
        _this = _this.length ? _this : targetobj;
        var type = _this.find('a').attr('tag');
        workHandleObj.workAddtion();
        if (!ld('.pop-workadd').is(':hidden')) {
            ld('.pop-workadd').hide();
        }
        // 进入发布页面
        ViewObj.switchView('work-release-view', 'init', {
            target_obj: _this,
            __footer_id: 'wn-release-footer',
            __direction: 'none'
        });
    }
};
//crm列表刷新
EventHanderObj.refreshNearbyaccountsList = function (callback) {
    var urlstring = 'module=Accounts&action=NearbyAccounts&distance=' + ViewObj.rootScope.nearbydistance +
        '&cuurlongitude=' + ViewObj.rootScope.nearbylongitude + '&cuurlatitude=' + ViewObj.rootScope.nearbylatitude +
        '&page=' + SwiperObj.ListPageObj.getListPageIndex() +
        '&searchcontent=' + searchcontent + '&orderby=asc';
    crmHandleObj.getNearbyAccountsList(urlstring, function () {
        if (ld.isFunction(callback)) {
            callback();
        }
    });
};
//应用-相册
ld('#tplPhone>[tag=btnsub_photo]').unbind('click').on('click', function (event) {
    ViewObj.rootScope.imagefrom = '从相册选择';    
    logicHanderObj.popUpMaskToggle('tplPhone');
    machineHanderObj.getPictureNative('photo');
});
//应用-拍照
ld('#tplPhone>[tag=btnsub_camera]').unbind('click').on('click', function (event) {
    ViewObj.rootScope.imagefrom = '手机拍照';    
    logicHanderObj.popUpMaskToggle('tplPhone');
    machineHanderObj.getPictureNative('camera');
});

//模块-相册
ld('#tplFileatt>[tag=btnsub_photo]').unbind('click').on('click', function (event) {
    logicHanderObj.popUpMaskToggle('tplFileatt');
    machineHanderObj.getAttNative('photo');
});
//模块-视频
ld('#tplFileatt>[tag=btnsub_video]').unbind('click').on('click', function (event) {
    logicHanderObj.popUpMaskToggle('tplFileatt');
    machineHanderObj.getAttNative('video');
});
//模块-手机文件
ld('#tplFileatt>[tag=btnsub_fileatt]').unbind('click').on('click', function (event) {
    logicHanderObj.popUpMaskToggle('tplFileatt');
    machineHanderObj.getAttNative('fileatt');
});