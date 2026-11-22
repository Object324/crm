var crmHandleObj = {};
// 定义跳转到crm-nearbyaccounts-view（附近客户）的方法及click处理定义
ViewObj['create-crm-nearbyaccounts-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '附近客户', '搜索', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '附近客户', '搜索', ''], opts_obj);
        GVObj.crmObj.liststatus = 0;
        scope.prve_header = ViewObj.getInfo('prev_header');
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        if (t_id === 'head_left') {
            GVObj.crmObj.liststatus = 0;
            ViewObj.switchView('crm-main-view', 'back',
                {
                    __scroll_top: 'origin',
                    __app_header: scope.prve_header
                });
        }
        else if (t_id === 'head_rig') {
            GVObj.crmObj.liststatus = 0;
            ViewObj.switchView('crm-nearbyaccounts-search-view', 'init');
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = null,
            urlstring = '';
        //距离切换
        if (targetobj.parent().attr('class') === 'sign-distance') {
            var pointvalue = 12,
                kilometre = targetobj.attr('kilometre');
            ld('.sign-distance a').removeClass('active');
            if (kilometre === '5000') {
                pointvalue = 12;
                ld(targetobj).addClass('active');
            }
            else {
                pointvalue = 11;
                ld(targetobj).addClass('active');
            }
            //定位：CRM-附近客户—定位传值
            theLocationIOSCrm(ViewObj.rootScope.nearbylongitude, ViewObj.rootScope.nearbylatitude, kilometre, pointvalue);
        }
        //定位到当前位置
        else if (targetobj.parent().attr('class') === 'sign-current') {
            loadLocationJScript();
        }
        //明细
        else if (targetobj.parents('#mapAroundlist').length === 1) {
            if (targetobj.parents('li').length === 1) {
                _this = targetobj.parents('li');
            } else if (targetobj.get(0).tagName.toLowerCase() === 'li') {
                _this = targetobj;
            } else {
                return;
            }
            recordID = _this.attr('record');
            if (recordID === undefined) return; // 若没有取到 recordID值，直接返回
            
            var urlstring = 'module=Accounts';
            var urlstringcheck = urlstring + '&action=DetailView&CheckPermitted=yes&record=' + recordID + '&mode=detail&approvepage=no';
            WordReportAjax(urlstringcheck, function (rest) {
                if (empty(rest)) return false;
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                if (restobj.code != -1) {
                    ViewObj.rootScope.loadCrmdetail = function (options) {
                        ViewObj.switchView('cwn-crmdetail-view', 'init', ld.extend({
                            'url_string': urlstring,
                            view_name: 'nearbyaccounts'
                        }, options));
                    };
                    ViewObj.rootScope.loadCrmdetail();
                } else {
                    PopPromptBox.show(restobj.msg);
                    ld("#status").hide();
                    return;
                }
            });
        }
    };
};

// 定义跳转到crm-nearbyaccounts-search-view（搜索附近客户）的方法及click处理定义
ViewObj['create-crm-nearbyaccounts-search-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '附近客户', '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        var pubclearhtml = '',
            urlstring = '';
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '附近客户', '', ''], opts_obj);
        pubclearhtml = '<div id="divSearchNearby"></div>' +
            '<div id="listbox" class="pubclear pubDetialC"></div>';
        ld('#crm-nearbyaccounts-search-view').html(pubclearhtml);
        urlstring = 'module=Accounts&action=NearbyAccounts&distance=' + ViewObj.rootScope.nearbydistance +
            '&cuurlongitude=' + ViewObj.rootScope.nearbylongitude + '&cuurlatitude=' + ViewObj.rootScope.nearbylatitude +
            '&page=1&searchcontent=&orderby=asc';
        crmHandleObj.getNearbyAccountsList(urlstring, function () {
            ld("#status").hide();
            if (ViewObj.rootScope.createpermit === 'yes' || ViewObj.rootScope.quickcreate === 'yes') {
                scope.__app_header.splice(4, 2, '+', '');
                ViewObj.setAppHeader(scope.__app_header);
            }
            ViewObj.onSwitchAfter(opts_obj);
        });
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        if (t_id === 'head_left') {
            GVObj.crmObj.liststatus = 0;
            ViewObj.switchView('crm-nearbyaccounts-view', 'back');
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = null,
            urlstring = '';
        //距离切换
        if (targetobj.parents('#listbox').length === 1) {
            if (targetobj.parents('li').length === 1) {
                _this = targetobj.parents('li');
            } else if (targetobj.get(0).tagName.toLowerCase() === 'li') {
                _this = targetobj;
            } else {
                return;
            }
            recordID = _this.attr('record');
            if (recordID === undefined) return; // 若没有取到 recordID值，直接返回
            ViewObj.rootScope.loadCrmdetail = function (options) {
                ViewObj.switchView('cwn-crmdetail-view', 'init', ld.extend({
                    'url_string': 'module=Accounts',
                    view_name: 'nearbyaccountssearch'
                }, options));
            };
            ViewObj.rootScope.loadCrmdetail();
        }
    };
};

//获取列表
crmHandleObj.getNearbyAccountsList = function (urlstring, callback) {
    WordReportAjaxNew(urlstring, function (rest, callbackstatus) {
        if (callbackstatus == 'success') {
            if (empty(rest)) return false;
            var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
            var listhtml = '<ul class="crm-lists nearby">';
            // 搜索框显示    
            ListSearchBox.display({
                parent_id: 'divSearchNearby',
                tip_text: '搜索附近客户',
                value_text: searchcontent,
                searchFun: function (searchstr) {
                    searchcontent = searchstr; // 全局变量赋值
                    // 将当前页设置为第一页
                    SwiperObj.ListPageObj.setListPageIndex(1);
                    // 调用刷新方法
                    EventHanderObj.refreshAjax(function () {
                        SwiperObj.autoHiddenAddMore();
                        SwiperObj.autoHeight(0);
                    });
                }
            });
            if (phoneversion == 'ios') {
                ld('#search_content+i').css('top', '0.45rem');
            }

            SwiperObj.ListPageObj.setListPageIndex(restobj.result.curpagenum, ViewObj.getInfo('to_viewid'));
            SwiperObj.ListPageObj.setHasNextPage(restobj.result.havenextpage, ViewObj.getInfo('to_viewid'));

            if (empty(restobj.result.list1)) {
                listhtml = logicHanderObj.NoinfoNotice('数据');
            }
            else {
                ld.each(restobj.result.list1, function (key, list) {
                    listhtml += '<li record="' + list.accountid + '" class="swiper-slide lnr-chevron-right">' +
                        '<h5 class="text-ellipsis" tag="0">' + list.accountname + '</h5><p>' +
                        '<span class="text-ellipsis">距您' + list.juli + '米&nbsp;&nbsp;' +
                        list.address + '</span></p></li>';
                });
            }
            listhtml += '</ul>';

            if (SwiperObj.is_addMore) {//如果是加载就 不清空原来的内容
                ld('#crm-nearbyaccounts-search-view .pubDetialC').html(ld('#crm-nearbyaccounts-search-view .pubDetialC').html() + listhtml);
            } else {//搜索和 刷新都要清空原来的内容
                ld('#crm-nearbyaccounts-search-view .pubDetialC').html(listhtml);
            }
            callback();
        } else {
            if (SwiperObj.is_refreshPage) {
                ld('#list-refresh-holder').addClass('ui-hide');
                ld('.list-refresh-icon').attr('class', 'list-refresh-icon');
                ld('.list-refresh-label').html('下拉刷新');
                SwiperObj.ListPageObj.setListPageIndex(1, 'crm-list-view');
                SwiperObj.autoHeight(0);//回到头部
                SwiperObj.is_refreshPage = false;//标记不能刷新
                SwiperObj.view_refreshing = false;//标记刷新完成
            }
            if (SwiperObj.is_addMore) {
                ld('.list-addmore-label').html('更多...');
                ld('.list-addmore-icon').addClass('ui-hide');
                SwiperObj.autoHeight(-1);  //滚动条保持原位
                SwiperObj.is_addMore = false;//标记不能加载
                SwiperObj.more_loading = false; //标记加载完成  
            }
        }
    });
}

