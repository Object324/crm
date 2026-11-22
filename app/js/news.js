// newsObj定义在common.js中
// 定义跳转news-main-view(news首页)的方法  及click处理定义
ViewObj['create-news-main-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['', '', '', '消息', '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['', '', '', '消息', '', ''], opts_obj);
        ld('#news-main-view').html(ld('#tplNewsHome').html());
        newsObj.getNewsMainViewData(function () {
            machineHanderObj.updateMainBtn();
            ViewObj.onSwitchAfter(opts_obj);
        });
    }
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = targetobj.parents('li[tag]');
        if (_this.length || targetobj[0].tagName.toLowerCase() === 'li') {
            _this = _this.length ? _this : targetobj;
            ViewObj.switchView('news-second-view', 'init', {
                view_name: _this.attr('tag'),
                __init_delay: 'none'
            })
        }
    };
};

// 定义跳转news-second-view(news二级页)的方法  及click处理定义
ViewObj['create-news-second-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '消息', '', scope.title_str, '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        var initFun = newsObj.getNewsSecondPage,
            tplnode = '';
        scope.view_name = opts_obj.view_name;
        switch (opts_obj.view_name) {
            case 'work_remind':
                scope.title_str = '工作提醒';
                GVObj.newstype = 'work';
                initFun = newsObj.getNewsSecondForWork;
                tplnode = 'tplNewsSecondForWork';
                break;
            case 'message_remind':
                scope.title_str = '消息提醒';
                GVObj.newstype = 'message';
                tplnode = 'tplNewsSecondForNews';
                break;
            case 'approve_remind':
                scope.title_str = '审批提醒';
                GVObj.newstype = 'approve'; //审批提醒二级目录
                tplnode = 'tplNewsSecondForApprove';
                break;
            case 'notice_remind':
                scope.title_str = '公告提醒';
                GVObj.newstype = 'notice';
                tplnode = 'tplNewsSecondForNotice';
                break;
        }
        ld('#news-second-view').html(ld('#' + tplnode).html());
        ViewObj.toViewCommon(to_viewid, ['<', '消息', '', scope.title_str, '', ''], opts_obj);
        initFun(GVObj.newstype, function () {
            ViewObj.onSwitchAfter(opts_obj);
        });
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id,
            targetobj = ld('#' + t_id),
            _this = null;
        // 头部左边
        if (t_id === 'head_left') {
            ViewObj.switchView('news-main-view', 'init', {
                __direction: 'right_out'
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = targetobj.parents('li');
        if (_this.length || targetobj[0].tagName.toLowerCase() === 'li') {
            _this = _this.length ? _this : targetobj;
            GVObj.newstype = _this.attr('tag');
            var urlstring = 'type=' + GVObj.newstype + '&page=1',//默认是第一页
                switchopts = {};
            switchopts.title_str = _this.find('span.news_left_tit').html();
            //列表
            switch (GVObj.newstype) {
                case 'approvelist'://工作提醒
                case 'replylist':
                case 'atworklist':
                case 'atreplylist':
                case 'mylaunchlist':
                case 'mypraiselist':
                    ViewObj.rootScope.newspage = 'worklist';
                    var urlstring = 'module=Home&action=ListView&method=getWorkRemindsAppList&smallcategory=' + GVObj.news_smallcategory +
                        '&bigcategory=' + GVObj.newstype + '&page=1&searchcontent=' + work_searchcontent;//默认是第一页
                    switch (GVObj.newstype) {
                        case 'approvelist':  // 故意没有写break;
                            GVObj.news_smallcategory = 'workreport'; // 设置全局变量
                            switchopts.addsubtitle = true; // 传参显示（待处理：显示切换标签“日志/任务”）
                            switchopts.view_name = 'news_work_list';
                        case 'atworklist':   // 故意没有写break;
                        case 'mylaunchlist': // 故意没有写break;
                            urlstring = 'smallcategory=' + GVObj.news_smallcategory +
                                '&bigcategory=' + GVObj.newstype +
                                '&page=1&searchcontent=' + work_searchcontent +
                                '&method=getWorkRemindsAppList';//默认是第一页
                            switchopts.url_string = urlstring;
                            ViewObj.switchView('wn-worklist-view', 'init', switchopts);
                            return; // 跳转页面并返回方法，不执行后面操作
                            break;
                        case 'replylist':
                        case 'atreplylist':
                            ViewObj.rootScope.newspage = 'thirdlist';
                            switchopts.view_name = 'myreply_list';
                            switchopts.url_string = urlstring;
                            break;
                        case 'mypraiselist':
                            ViewObj.rootScope.newspage = 'thirdlist';
                            switchopts.view_name = 'mypraise_list';
                            switchopts.url_string = urlstring;
                            break;
                    }
                    break;
                case 'unread'://消息提醒
                case 'readen':
                case 'email':
                    switchopts.view_name = 'message_list';
                    switchopts.url_string = 'module=Home&action=ListView&method=getRemindsList&' + urlstring;
                    break;
                case 'Pendingapproval'://审批提醒
                case 'Approved':
                case 'Last30day':
                    if(GVObj.newstype == 'Pendingapproval'){
                        ViewObj.rootScope.approvetype = 0;
                    }
                    else if(GVObj.newstype == 'Approved'){
                        ViewObj.rootScope.approvetype = 1;
                    }
                    else{
                        ViewObj.rootScope.approvetype = 2;
                    }
                    switchopts.view_name = 'approve_module_list';
                    switchopts.back_viewname = scope.view_name;
                    ViewObj.rootScope.approvetitle = switchopts.title_str;
                    ViewObj.switchView('newsapprove-list-view', 'init', switchopts);
                    return;
                case 'noticeunread'://公告提醒
                case 'noticereaden':
                case 'noticerelease':
                    switchopts.view_name = 'notice_list';
                    switchopts.url_string = 'module=Home&action=ListView&method=getNoticeList&' + urlstring;
                    break;
            }
            switchopts.back_viewname = scope.view_name;
            ld('#news-third-view').html('<div id="listbox" class="pubclear pubDetialC"></div>');
            ViewObj.switchView('news-third-view', 'init', switchopts);
        }
    };
};

// 定义跳转news-third-view(news三级页面)的方法及click处理定义
ViewObj['create-news-third-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', scope.title_str, '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        scope.title_str = opts_obj.title_str;
        scope.view_name = opts_obj.view_name;
        scope.back_viewname = opts_obj.back_viewname;
        ViewObj.toViewCommon(to_viewid, ['<', '', '', scope.title_str, '', ''], opts_obj);
        newsObj.getNewsThirdList(opts_obj.view_name, opts_obj.url_string, function () {
            ViewObj.onSwitchAfter(opts_obj);
        });
    }
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id,
            targetobj = ld('#' + t_id),
            _this = null;
        // 头部左边
        if (t_id === 'head_left') {
            if(scope.back_viewname === "approve_module_list"){
                ViewObj.switchView('newsapprove-list-view', 'init', {
                    view_name: scope.back_viewname,
                    title_str: ViewObj.rootScope.approvetitle,
                    __direction: 'right_out'
                });
            }else{
                ViewObj.switchView('news-second-view', 'init', {
                    view_name: scope.back_viewname,
                    __direction: 'right_out'
                });
            }
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = targetobj.parents('li');
        if (scope.view_name === 'message_list') {
            return;
        } else if (( scope.view_name === 'approve_list' || scope.view_name === 'notice_list'  )
            && ( _this.length || targetobj[0].tagName.toLowerCase() === 'li')) {
            _this = _this.length ? _this : targetobj;
            if (scope.view_name === 'approve_list') {
                module = ViewObj.rootScope.approvemodule;
                approvemodule = ViewObj.rootScope.approvemodule;
            }
            else if(scope.view_name === 'notice_list'){
                module = 'PublicAnnouncement';
            }
            recordID = _this.attr('record'); // 全局变量赋值       
            var urlstring = 'module=' + module + '&action=DetailView&CheckPermitted=yes&record=' + recordID + '&mode=detail&approvepage=no';
            WordReportAjax(urlstring, function (rest) {
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                if (restobj.code != -1) {
                    // 点击列表项进入明细
                    ViewObj.switchView('cwn-crmdetail-view', 'init', {
                        target_obj: _this,
                        view_name: scope.view_name,
                        __footer_id: 'crm-detail-footer'    
                    });
                } else {
                    PopPromptBox.show(restobj.msg);
                    ld("#status").hide();
                    return;
                }
            });
        } else if ((scope.view_name === 'myreply_list' || scope.view_name === 'mypraise_list')
            && (targetobj.parents('.area-list').length === 1 && scope.view_name != 'message_list')
            || targetobj.attr('class') === 'area-list') {
            if (targetobj.parent('.a-user-pic').length === 1) {
                var curid = targetobj.parent('.a-user-pic').attr('userid');//用户ID
                if (curid === userid) {
                    ViewObj.switchView('all-userinfo-view', 'init', {
                        view_name: 'onlymeinfo'
                    });
                }
                else {
                    var curname = targetobj.parent('.a-user-pic').next().find('.a-user-intro').html();//用户名
                    curname = curname.split('：')[0];
                    ViewObj.switchView('wn-userinfo-view', 'init', {
                        'curid': curid,
                        'curimg': ld(targetobj)[0].outerHTML,
                        'curinfo': curname//目前只读取用户名，暂无角色权限信息
                    });
                }
            } else {
                _this = targetobj.parents('.area-list').length === 1 ? targetobj.parents('.area-list') : targetobj;
                var title_str = _this.attr('reporttypestr') ? _this.attr('reporttypestr') : _this.find('[reporttypestr]').attr('reporttypestr'),
                    workreportid = _this.attr('workreportid') ? _this.attr('workreportid') : _this.find('[workreportid]').attr('workreportid');

                ViewObj.rootScope.loadWorkDetail = function (options) {
                    ViewObj.switchView('wn-workdetail-view', 'init', ld.extend({
                        'workreportid': workreportid,
                        __app_header: ['<', '', '', title_str, '-', '-'],
                        __footer_id: 'wn-workdetail-footer'
                    }, options));
                }
                ViewObj.rootScope.loadWorkDetail();
            }
        }
    };
};

// 定义跳转newsapprove-list-view(news审批提醒中模块列表)的方法及click处理定义
ViewObj['create-newsapprove-list-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', scope.title_str, '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ld('#newsapprove-list-view').html('');        
        scope.title_str = opts_obj.title_str;
        scope.view_name = opts_obj.view_name;
        scope.back_viewname = opts_obj.back_viewname;
        ViewObj.toViewCommon(to_viewid, ['<', '', '', scope.title_str, '', ''], opts_obj);
        var urlstring = 'module=Approve&action=ApproveListViewCount&approvestatus='+ ViewObj.rootScope.approvetype;
        WordReportAjax(urlstring, function (rest) {
            if (empty(rest)) return false;
            var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest),
                list = restobj.result.list;
            var listhtml = '<ul class="newstwo-lists">';
            if(list != '' && list != null){
                ld.each(list, function (index, list) {
                    listhtml += '<li tag="'+ list.module +'">'+
                                    '<a><span class="news_left_tit">'+ list.label +'</span><i class="lnr-chevron-right"></i>'+
                                    '<span class="news_num"><i class="approveno">'+ list.num +'</i></span></a>'+
                                '</li>';
                });
            }
            listhtml += '</ul>';
            ld('#newsapprove-list-view').html(listhtml);
            ViewObj.onSwitchAfter(opts_obj);
        });
    }
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id,
            targetobj = ld('#' + t_id),
            _this = null;
        // 头部左边
        if (t_id === 'head_left') {
            // 跳转到news二级页面
            ViewObj.switchView('news-second-view', 'init', {
                view_name: scope.back_viewname,
                __direction: 'right_out'
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = targetobj.parents('li');
        if(targetobj.parents('li').length === 1){
            if(_this.attr('tag') != undefined){
                ViewObj.rootScope.approvemodule = _this.attr('tag');
            }
            if(_this.find('span:first-child').html() != undefined){
                ViewObj.rootScope.approvemodulename = _this.find('span:first-child').html();
            }        
            var urlstring = 'module=Approve&action=ListView&fromapprovemodule=' + ViewObj.rootScope.approvemodule + 
                            '&page=1&approvestatus=' + ViewObj.rootScope.approvetype;           
            var switchopts = {};
            switchopts.title_str = ViewObj.rootScope.approvemodulename;
            switchopts.view_name = 'approve_list';
            switchopts.url_string = urlstring;
            switchopts.back_viewname = scope.view_name;
            ld('#news-third-view').html('<div id="listbox" class="pubclear pubDetialC"></div>');
            ViewObj.switchView('news-third-view', 'init', switchopts);
        }
    };
};

document.addEventListener('touchmove', function (e) {
    e.preventDefault();
}, false);
document.addEventListener('DOMContentLoaded', function () {
    ld(document).ready(function () {
        newsObj.newsInit();
    });
}, false);
//节点加载事件，在onload之前
ld(function () {
    String.prototype.len = function () {// 给string增加个len ()方法，计算string的字节数
        return this.replace(/[^\x00-\xff]/g, "xx").length;
    };
});

//NEWS加载
newsObj.newsInit = function () {
    machineHanderObj.setAppVersion();//返回原生版本号
    setTimeout(function () {
        if (phoneversion == 'ios') {
            iosObj.getDeviceInfo();
        } else if (phoneversion == 'android') {
            GVObj.deviceID = javatojs.getDeviceId();
        }
    }, 5000);
    FastClick.attach(document.body); // 减少手机端 点击事件延迟
    SwiperObj.setSwiperSzie();       // 设置当前全局滚动适应屏幕大小
    category = 'news';
    newsObj.RefreshNews(10);
    ViewObj.switchView('news-main-view', 'init');
    setTimeout(function () {
        if (phoneversion == 'ios' || phoneversion == 'android') {
            newsObj.setDevice();//设置手机UDID
        }
    }, 15000);
}
newsObj.setDevice = function () {
    var urlstring = 'module=Users&action=setDevice&deviceID=' + GVObj.deviceID;
    WordReportAjax(urlstring, function (rest) {
    });
}
newsObj.getNewsMainViewData = function (callback) {
    var urlstring = 'module=Home&action=ListView&method=getNews';
    WordReportAjax(urlstring, function (rest) {
        ld("#status").hide();
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        //工作提醒
        var wrobj = ld('li[tag=work_remind]');
        wrobj.attr('class', restobj.work.display);
        if (restobj.work.total > 0) {
            wrobj.find('span:last').removeClass('ui-hide').html(restobj.work.total);
        }
        else {
            wrobj.find('span:last').addClass('ui-hide');
        }
        //消息提醒
        var mrobj = ld('li[tag=message_remind]');
        mrobj.attr('class', restobj.message.display);
        if (restobj.message.total > 0) {
            mrobj.find('span:last').removeClass('ui-hide').html(restobj.message.total);
        }
        else {
            mrobj.find('span:last').addClass('ui-hide');
        }
        //审批提醒
        var arobj = ld('li[tag=approve_remind]');
        arobj.attr('class', restobj.approve.display);
        if (restobj.approve.total > 0) {
            arobj.find('span:last').removeClass('ui-hide').html(restobj.approve.total);
        }
        else {
            arobj.find('span:last').addClass('ui-hide');
        }
        //公告提醒
        var nrobj = ld('li[tag=notice_remind]');
        nrobj.attr('class', restobj.notice.display);
        if (restobj.notice.total > 0) {
            nrobj.find('span:last').removeClass('ui-hide').html(restobj.notice.total);
        }
        else {
            nrobj.find('span:last').addClass('ui-hide');
        }
        if (callback) callback();
    }, {onlyhead_tip: true});
}
//每隔1分钟刷新数据
newsObj.RefreshNews = function (secs) {
    if (--secs > 0) {
        setTimeout("newsObj.RefreshNews(" + secs + ")", 6000);
    } else {
        newsObj.getNewsMainViewData();
        newsObj.RefreshNews(10);//再次刷新
    }
}
//获取消息二级页面信息，工作提醒
newsObj.getNewsSecondForWork = function (newstype, callback) {
    var urlstring = 'module=Home&action=ListView&method=getNewsSecondForWork&type=' + newstype;
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        ld('li[tag=approvelist]').find('span:last').html(restobj.work.approve);
        ld('li[tag=replylist]').find('span:last').html(restobj.work.reply);
        ld('li[tag=atworklist]').find('span:last').html(restobj.work.atwork);
        ld('li[tag=atreplylist]').find('span:last').html(restobj.work.atreply);
        ld('li[tag=mylaunchlist]').find('span:last').html(restobj.work.mylaunch);
        ld('li[tag=mypraiselist]').find('span:last').html(restobj.work.mypraise);
        if (callback) {
            callback();
        }
    });
}
//消息、审批、公告提醒事件
newsObj.getNewsSecondPage = function (newstype, callback) {
    var urlstring = 'module=Home&action=ListView&method=getNewsSecondPage&type=' + newstype;
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        if (newstype === 'message') {
            ld('li[tag=unread]').find('span:last').html(restobj.message.unread);
        }
        else if (newstype === 'approve') {
            ld('li[tag=Pendingapproval]').find('span:last').html(restobj.approve.pending);
        }
        else if (newstype === 'notice') {
            ld('li[tag=noticeunread]').find('span:last').html(restobj.notice.pending);
        }
        if (callback) {
            callback();
        }
    });
};