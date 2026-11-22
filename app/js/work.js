var workHandleObj = {};
// 定义跳转work-main-view(work首页)的方法  及click处理定义
ViewObj['create-work-main-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        work_searchcontent = ''; // 清空搜索值，在跳转
        ViewObj.toViewCommon(to_viewid, ['搜索', '', '', '工作', '+', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        work_searchcontent = ''; // 清空搜索值，在跳转
        ViewObj.toViewCommon(to_viewid, ['搜索', '', '', '工作', '+', ''], opts_obj);

        var swiper = SwiperObj.workCategory_swiper;
        if (!(swiper instanceof Swiper)) {
            SwiperObj.workCategory_swiper = new Swiper('.swiper-container.work-category', {
                loop: false,
                slidesPerView: 5
            });
        } else if (typeof swiper.slideTo === 'function') {
            SwiperObj.workCategory_swiper.slideTo(0, 0, false); // 将slide 重置
        }
        ld('#workDataClassify').css({'opacity': 1});
        ld('#workDataClassify .swiper-slide').css('height', '2.4rem');

        var urlstring = 'smallcategory=' + smallcategory + '&bigcategory=' + bigcategory +
            '&page=1&searchcontent=' + work_searchcontent + '&method=getList';
        ld("#status").show();
        workHandleObj.getWorkList(urlstring, function () {
            ld("#status").hide();
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
            // 跳转到work搜索
            ViewObj.switchView('work-search-view', 'init', {
                __direction: 'right_in'
            });
            // 头部右边
        } else if (t_id === 'head_rig') {
            workHandleObj.workAddtion();
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        // 调用 wn-worklist-view 中的内容点击方法，防止代码重复
        ViewObj.rootScope.workpage = 'work-main-view';
        OperationObj.triggerCilckEvent(targetobj, 'body', {view_id: 'wn-worklist-view'});
    };
};

// 定义跳转work-search-view(work搜索页)的方法  及click处理定义
ViewObj['create-work-search-view'] = function (to_viewid, siwtch_type, scope) {
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['', '取消', '', '搜索', '', '搜索'], opts_obj);
        // 获取本地存储 值
        // CacheObj.set('work_search_content',[],60*60*24*30);
        var searchobj = CacheObj.get('work_search_content');
        if (searchobj) {
            searchobj.reverse();
            var listhtml = '';
            ld.each(searchobj, function (key, value) {
                listhtml += '<li class="lnr-clock">' + value + '</li>';
            });
            listhtml += '<li class="clear_history" tag="clear_history">清除搜索记录</li>';
            ld('#workSearch>ul').html(listhtml);
        }
        else {
            ld('#workSearch>ul').html('');
        }
        ld('#work-search-view').width(SwiperObj.PHONE_WIDTH);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id,
            targetobj = ld('#' + t_id),
            _this = null;
        // 头部左边
        if (t_id === 'head_left') {
            ViewObj.switchView('work-main-view', 'back', {
                __direction: 'left_out'
            });
            // 头部右边
        } else if (t_id === 'head_rig') {
            work_searchcontent = ld('#app_header input').val();
            if (empty(work_searchcontent)) {
                PopPromptBox.show('请输入搜索内容！');
                return false;
            }
            ViewObj.switchView('wn-worklist-view', 'init');
            //存入搜索记录
            var searchobj = CacheObj.get('work_search_content');
            if (!searchobj) {
                searchobj = [];
                searchobj[0] = work_searchcontent;
            } else {
                var nowTxt = ld.inArray(work_searchcontent, searchobj);//当前元素下标位置
                if (nowTxt != -1) {
                    searchobj.splice(nowTxt, 1);
                }
                searchobj[searchobj.length] = work_searchcontent;
            }
            if (searchobj.length > 10) {
                searchobj.shift();
            }
            CacheObj.set('work_search_content', searchobj, 60 * 60 * 24 * 30);
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        // 点击 ‘历史记录列表’、“清空历史记录”
        var _this = targetobj.parents('li');
        if (_this.length === 1 ||
            targetobj[0].tagName.toLowerCase() === 'li') {
            _this = _this.length ? _this : targetobj;
            // 点击清空历史记录
            if (_this.attr('tag') === 'clear_history') {
                CacheObj.del('work_search_content');
                ld('#workSearch>ul').html('');
                SwiperObj.autoHeight(0);
                // 点击历史记录列表，进入搜索
            } else {
                work_searchcontent = _this.text();
                ld('#app_header input').val(work_searchcontent);
                ld('#app_header .delCont').removeClass('ui-hide');
                ViewObj.switchView('wn-worklist-view', 'init');
            }
        }
    };
};

// 定义跳转work-release-view(work发布页面)的方法  及click处理定义
ViewObj['create-work-release-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ViewObj.rootScope.work_release_header, opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        var _this = opts_obj.target_obj,
            release_type = '',
            title_str = '',
            m_icon = 'v';
        savetype_num = 0;
        // work首页 右上角 弹出层 进入时
        if (_this.attr('class') === 'pop_workItem') {
            release_type = _this.find('a').attr('tag');
            // work发布页，发日志、周计划，月计划，头部下拉，点击进入时
        } else {
            release_type = _this.attr('tag');
        }
        switch (release_type) {
            case 'ItemLogday':  // 发日志
                savetype_num = 1;
                title_str = '日志';
                break;
            case 'ItemLogweek': // 发周计划
                savetype_num = 2;
                title_str = '周计划';
                break;
            case 'ItemLogmonth': // 发月计划
                savetype_num = 3;
                title_str = '月计划';
                break;
            default: // 发任务 ，发微博
                m_icon = '';
                savetype_num = 0;
                title_str = _this.find('span').html();
        }
        scope.__app_header = ['', '取消', m_icon, title_str, '', '发布'];
        ViewObj.rootScope.work_release_header = scope.__app_header;
        ViewObj.toViewCommon(to_viewid, scope.__app_header, opts_obj);
        logicHanderObj.toClear();//清空值
        workHandleObj.publishText(savetype_num, release_type);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id,
            targetobj = ld('#' + t_id),
            _this = null;
        // 头部左边
        if (t_id === 'head_left') {
            // 跳转到work搜索
            ViewObj.switchView('work-main-view', 'back', {
                __scroll_top: 'origin',
                __confirm_switch: true
            });
            // 头部右边
        } else if (t_id === 'head_rig' && ViewObj.rootScope.savestatus != 'yes') {
            ViewObj.rootScope.savestatus = 'yes';
            if (NetworkObj.checkNetwork()) {
                workHandleObj.save_release(function () {
                    ViewObj.rootScope.savestatus = 'no';
                    ViewObj.switchView('work-main-view', 'init', {
                        __direction: 'right_out'
                    });
                });
            }
        }
    };
    // 底部点击操作
    ViewObj[to_viewid + '-footer-click'] = function (targetobj, clickOpts) {
        var _this = null,
            switchopts = {
                'return_module': 'Work',//模块
                'searchtype': 'all',//类型 (bymodule:根据模块权限; byscope:根据授权范围; all:全部)
                'filterown': 'no',//是否过滤自己(yes:过滤, no:不过滤)
                'scopetype': 'groupuser',//显示类型( group:只显示部门; user:只显示用户; groupuser:显示部门及用户)
                'common': 1,//是否显示常用标签(0:不显示;1:常用标签下没有我的选项;2:常用标签下有我的选项)
                'isactive': 'no',//是否显示禁用用户（yes:显示,no:不显示  默认no） 
                __direction: 'none'
            };
        // 点击发送范围、执行人、点评人
        if (targetobj.parents('.bot_operbtn').length === 1) {
            if (targetobj.parent()[0].tagName.toLowerCase() === 'a') {
                _this = targetobj.parent();
            } else if (targetobj[0].tagName.toLowerCase() === 'a') {
                _this = targetobj;
            }
            switch (_this.attr('id')) {
                // 发送范围 点击
                case 'ccrangeDIV':
                    switchopts.view_name = 'sendrang-all';
                    ViewObj.switchView('cwn-sendrang-view', 'init', switchopts);
                    break;
                // 点击点评人
                case 'commentDIV':
                    switchopts.view_name = 'comment_execution_list';
                    switchopts.list_name = 'comment';
                    switchopts.scopetype = 'user';
                    switchopts.common = '0';
                    ViewObj.switchView('cwn-popuselect-view', 'init', switchopts);
                    break;
                // 点击执行人
                case 'executionDIV':
                    switchopts.view_name = 'comment_execution_list';
                    switchopts.list_name = 'execution';
                    switchopts.scopetype = 'user';
                    switchopts.common = '0';
                    ViewObj.switchView('cwn-popuselect-view', 'init', switchopts);
                    break;
            }
            // 拍照,at，关联联系人，关联客户,关联产品,定位
        } else if (targetobj.parents('.send_operation').length === 1) {
            if (targetobj.parent()[0].tagName.toLowerCase() === 'a') {
                _this = targetobj.parent();
            } else if (targetobj[0].tagName.toLowerCase() === 'a') {
                _this = targetobj;
            }
            switch (_this.attr('tag')) {
                // 拍照
                case 'photo':
                    logicHanderObj.popUpMaskToggle('tplPhone');//显示拍照获取方式弹出层和遮罩层
                    break;
                // at
                case 'atrange':
                    switchopts.view_name = 'at-release';
                    ViewObj.switchView('cwn-sendrang-view', 'init', switchopts);
                    break;
                // 关联联系人，关联客户，关联产品
                case 'relationdata':
                    ViewObj.switchView('cwn-popuselect-view', 'init', {
                        view_name: 'acct_cont_pro_relationlist',
                        list_name: _this.attr('relationtype'),
                        w_r_modulename: _this.attr('relationname'),
                        __direction: 'none'
                    });
                    break;
                // 定位
                case 'relationsign':
                    var address = ld('#sendLogSignAddress').html();
                    if (address != '') {
                        PopPromptBox.show({
                            head_text: '定位提醒',
                            main_text: '定位信息已存在，是否重新定位？',
                            btn_type: 'yesno',
                            yes_str: '确定',
                            no_str: '取消',
                            yes_fun: function () {
                                workHandleObj.positionPageInit();
                            }
                        });
                    }
                    else {
                        workHandleObj.positionPageInit();
                    }
                    break;
                // 点击更多
                case 'more_operation':
                    if (ld('.CCrange .more_operation').hasClass('ui-hide')) {
                        ld('.CCrange .more_operation').removeClass('ui-hide');
                        _this.children('.add_more').addClass('ui-hide');
                        _this.children('.del_more').removeClass('ui-hide');
                    } else {
                        ld('.CCrange .more_operation').addClass('ui-hide');
                        _this.children('.add_more').removeClass('ui-hide');
                        _this.children('.del_more').addClass('ui-hide');
                    }
                    break;
            }
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var contlist = targetobj.parents('#sendLogContlist'),
            acctlist = targetobj.parents('#sendLogAcctlist'),
            prolist = targetobj.parents('#sendLogProlist'),
            signlist = targetobj.parents('#sendLogSign'),
            list_name = '';
        if (contlist.length === 1 ||
            targetobj.attr('id') === 'sendLogContlist') {
            list_name = 'Contacts';
        } else if (acctlist.length === 1 ||
            targetobj.attr('id') === 'sendLogAcctlist') {
            list_name = 'Accounts';
        } else if (prolist.length === 1 ||
            targetobj.attr('id') === 'sendLogProlist') {
            list_name = 'Products';
        } else if (signlist.length === 1 ||
            targetobj.attr('id') === 'sendLogSign') {
            list_name = 'Sign';
        }
        if (targetobj.attr('tag') === 'addImg') {
            logicHanderObj.popUpMaskToggle('tplPhone');//显示拍照获取方式弹出层和遮罩层
        }
        if (list_name) {
            if (list_name === 'Sign') {
                if (targetobj.attr('class') === 'close') {
                    targetobj.parent().addClass('ui-hide');
                    ld('#sendLogSignAddress,#sendLogSignPoint').html('');
                }
            }
            else {
                //关闭关联客户、联系人、产品
                if (targetobj.attr('class') === 'close') {
                    targetobj.parent().addClass('ui-hide');
                    sessionStorage.removeItem('storage_work_rela_' + list_name + 'id');
                    sessionStorage.removeItem('storage_work_rela_' + list_name + 'name');
                    if (list_name === 'Accounts') {
                        t_choose_a_relationidobj = [];
                        t_choose_a_relationnameobj = [];
                    }
                    else if (list_name === 'Contacts') {
                        t_choose_c_relationidobj = [];
                        t_choose_c_relationnameobj = [];
                    }
                    else if (list_name === 'Products') {
                        t_choose_p_relationidobj = [];
                        t_choose_p_relationnameobj = [];
                    }
                } else {
                    var _id = '#wn-release-footer [relationtype=' + list_name + ']';
                    var w_r_modulename = ld(_id).attr('relationname');
                    ViewObj.switchView('cwn-popuselect-view', 'init', {
                        view_name: 'acct_cont_pro_relationlist',
                        'list_name': list_name,
                        'w_r_modulename': w_r_modulename
                    });
                }
            }
        }
    };
};

// 定义跳转work-position-view(work定位页)的方法  及click处理定义
ViewObj['create-work-position-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['', '取消', '', '地图', '', '确定'], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        loadLocationJScript();//加载地图
        ViewObj.toViewCommon(to_viewid, ['', '取消', '', '地图', '', '确定'], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id,
            targetobj = ld('#' + t_id),
            _this = null;
        // 头部左边
        if (t_id === 'head_left') {
            ViewObj.switchView('work-release-view', 'back', {
                __footer_id: 'wn-release-footer'
            });
            // 头部右边
        } else if (t_id === 'head_rig') {
            var address = ld('.positionAddress').html();
            var point = ld('.positionAddressXY').html();
            pointarr = point.split(",");//字符串转变成数组 
            if (!empty(address)) {
                ld('#sendLogSignAddress').html(address);//ld('#sendLogSignAddress').html('淮海东路85号');
                ld('#sendLogSignPoint').html(point);//ld('#sendLogSignPoint').html('121.48809,31.231474');
                ld('#sendLogSign').removeClass('ui-hide');
                ViewObj.switchView('work-release-view', 'back', {
                    __footer_id: 'wn-release-footer'
                });
            } else {
                PopPromptBox.show('您还没有定位');
                return false;
            }
        }
    };
    // 底部点击操作
    ViewObj[to_viewid + '-footer-click'] = function (targetobj, clickOpts) {
        if (targetobj.attr('id') === 'sign_address_work' || targetobj.parent().attr('id') === 'sign_address_work') {
            ViewObj.switchView('work-positionmore-view', 'init', {
                work_position: ld('.positionAddressXY').html()
            });
        }
    };
};

// 定义跳转work-positionmore-view(work定位,更多)的方法  及click处理定义
ViewObj['create-work-positionmore-view'] = function (to_viewid, siwtch_type, scope) {
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '选择地址', '', ''], opts_obj);
        workMorePosition(opts_obj.work_position);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id,
            targetobj = ld('#' + t_id),
            _this = null;
        // 头部左边
        if (t_id === 'head_left') {
            ViewObj.switchView('work-position-view', 'back', {
                __footer_id: 'work-position-footer'
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = null;
        if (targetobj.parents('li').length === 1) {
            _this = targetobj.parents('li');
        } else if (targetobj.get(0).tagName.toLowerCase() === 'li') {
            _this = targetobj;
        } else {
            return;
        }
        //alert(_this.attr('lng'));alert(_this.attr('lat'));
        var str = _this.attr('lng') + "," + _this.attr('lat');
        var address = _this.find('span').html(),
            addressinfo = '<span>' + _this.find('span').html() + '</span><i class="lnr-chevron-right"></i>';
        ld('#sign_address_work').html(addressinfo);
        ld('.positionAddress').html(address);
        ld('.positionAddressXY').html(str);
        ViewObj.switchView('work-position-view', 'back', {
            __footer_id: 'work-position-footer'
        });
    };
};

//工作进入定位页面
workHandleObj.positionPageInit = function () {
    ViewObj.switchView('work-position-view', 'init', {
        __footer_id: 'work-position-footer',
        __direction: 'none',
        view_name: 'position',
        onSwitchAfter: function () {
            ld('#allmap').height(SwiperObj.CONTENT_HEIGHT);
        }
    });
};

workHandleObj.workAddtion = function () {
    var _pop_workAdd,
        _pop_workItems = null,
        _pop_workText = null,
        _items = null,
        _marginTop = 0,
        _pop_workMask = null;
    _pop_workAdd = ld('.pop-workadd');
    var _closeBt = ld('#app_header .head-rig a[tag="workAdd"]');
    var _closeBt_parent = _pop_workAdd.find('.closebt a');
    var _closeBt_all = ld('#app_header .head-rig a[tag="workAdd"] ,.pop-workadd .closebt a');
    ld('.pop-workadd .pop-worktitle,.pop-workadd .closebt').css('top', '0px');

    if (_closeBt.hasClass('onProcess')) return;
    _pop_workAdd.removeClass('ui-hide');
    _pop_workText = _pop_workAdd.find('.pop-workholder ul li span');
    _pop_workMask = _pop_workAdd.find('.pop-workmask');
    _pop_workItems = _pop_workAdd.find('.pop-workitems');
    _items = _pop_workAdd.find('.pop-workholder ul li');
    if (!popWorkAddtionMarginTop) {
        popWorkAddtionMarginTop = 0 - _items.eq(0).height();
    }
    _marginTop = popWorkAddtionMarginTop;
    // _pop_workAdd.hide();
    _pop_workItems.css({
        width: SwiperObj.PHONE_WIDTH * 4,
        marginLeft: -SwiperObj.PHONE_WIDTH * 1.5,
        marginTop: -SwiperObj.PHONE_HEIGHT / 1.4,
    });

    var $_v_pop_closeBt = _closeBt; //动画插件声明
    var $_v_pop_closeBt_parent = _closeBt_parent;
    if (_closeBt.hasClass('icon_roate') ||
        _closeBt_parent.hasClass('icon_roate')) {
        _closeBt_all.removeClass('icon_roate');
        _closeBt_all.addClass('icon_nomal onProcess');
        _pop_workText.css('opacity', 0.5).animate({
            fontSize: '2rem',
            lineHeight: '3rem',
            paddingBottom: '0.8rem',
            letterSpacing: '6px',
            opacity: 0,
        }, 200);
        _pop_workItems.css('opacity', 0.5).animate({
            width: SwiperObj.PHONE_WIDTH * 2,
            marginLeft: -SwiperObj.PHONE_WIDTH * 0.5,
            marginTop: -SwiperObj.PHONE_HEIGHT / 4,
            opacity: 0,
        }, 200, function () {
        });
        _pop_workAdd.fadeOut(400);
        _pop_workMask.fadeOut(400);
        $_v_pop_closeBt_parent.velocity({
            rotateZ: "20deg",
            opacity: "0.3"
        }, {
            duration: 200,
            easing: "easeOutQuad",
            begin: {
                rotateZ: "45deg",
                opacity: "1"
            },
            complete: function () {
                // bug #20614
                if (ViewObj.getCurrentViewId() === 'work-main-view') {
                    ViewObj.switchFooter('cwnm-main-footer', 'display');
                }
                $_v_pop_closeBt.velocity({
                    rotateZ: "0deg",
                    opacity: "1"
                }, {
                    duration: 200,
                    easing: "easeOutQuad",
                    begin: {
                        rotateZ: "20deg",
                        opacity: "0.7"
                    },
                    display: "inline-block",
                    complete: function () {
                        setTimeout(function () {
                            _closeBt_all.removeClass('onProcess');
                        }, 500);
                    }
                });
            },
            display: "none"
        });
    } else {
        _closeBt_all.addClass('icon_roate onProcess');
        _closeBt_all.removeClass('icon_nomal');
        _pop_workAdd.hide().fadeIn(300);
        _pop_workMask.fadeIn(300);
        _pop_workText.animate({
            fontSize: '.8rem',
            lineHeight: '1.6rem',
            paddingBottom: '.6rem',
            letterSpacing: '2px',
            opacity: 1

        }, 300);
        _pop_workItems.animate({
                width: SwiperObj.PHONE_WIDTH,
                marginLeft: '0',
                marginTop: _marginTop,
                opacity: 1
            },
            300);
        $_v_pop_closeBt.velocity({
            rotateZ: "45deg",
            opacity: ".3"
        }, {
            duration: 200,
            easing: "easeOutQuad",
            begin: {
                rotateZ: "20deg",
                opacity: "1"
            },
            complete: function () {
                // machineHanderObj.hideMainBtn();
                ViewObj.switchFooter('cwnm-main-footer', 'hidden');
                $_v_pop_closeBt_parent.velocity({
                    rotateZ: "45deg",
                    opacity: "1"
                }, {
                    duration: 200,
                    easing: "easeOutQuad",
                    begin: {
                        rotateZ: "20deg",
                        opacity: "0.7"
                    },
                    display: "block",
                    complete: function () {
                        setTimeout(function () {
                            _closeBt_all.removeClass('onProcess');
                        }, 500);

                    }
                });
            },
            display: "none",
        });
    }
};
//发日志，周计划，月计划
workHandleObj.publishText = function (savetype_num, entitytype) {
    ld('.sendrangeimg').remove();
    ld('.pop-workadd,#sendLogDate').addClass('ui-hide');
    savetype = savetype_num;
    entitytypetag = entitytype;
    workreportcreate = '';
    btnshowCCname = '';
    var firstfiled = '';
    var urlstring = 'module=Home&action=ListView&method=getRangeCommentExecutor&type=' + entitytype;
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var choose_list = restobj.result.list;
        if(choose_list.ccgroup == null){
            choose_list.ccgroup = '';
        }
        if(choose_list.ccgroupname == null){
            choose_list.ccgroupname = '';
        }
        if(choose_list.ccuser == null){
            choose_list.ccuser = '';
        }
        if(choose_list.ccusername == null){
            choose_list.ccusername = '';
        }
        choose_groupidobj = choose_list.ccgroup.split(',');
        choose_groupnameobj = choose_list.ccgroupname.split(',');
        choose_useridobj = choose_list.ccuser.split(',');
        choose_usernameobj = choose_list.ccusername.split(',');
        sessionStorage.setItem('storage_work_cc_groupid', choose_groupidobj);
        sessionStorage.setItem('storage_work_cc_groupname', choose_groupnameobj);
        sessionStorage.setItem('storage_work_cc_userid', choose_useridobj);
        sessionStorage.setItem('storage_work_cc_username', choose_usernameobj);
        sessionStorage.setItem('storage_work_com_execid', choose_list.com_exec);
        sessionStorage.setItem('storage_work_com_execname', choose_list.com_execname);
        // 控制日志-点评人，任务-执行人字段显示
        if (choose_list.com_exec && choose_list.com_execname) {
            if (savetype) {
                GVObj.optperson = choose_list.com_exec;
                ld('#commentDIV').html('<span class="text-ellipsis">' + choose_list.com_execname + '</span>');
            }
            if (entitytypetag === 'ItemCocmd') {
                GVObj.execution = choose_list.com_exec;
                ld('#executionDIV').html('<span class="text-ellipsis">' + choose_list.com_execname + '</span>');
            }
        }else{
            if (savetype) {
                GVObj.optperson = choose_list.com_exec;
                ld('#commentDIV').html('<span class="text-ellipsis">点评人</span>');
            }
            if (entitytypetag === 'ItemCocmd') {
                GVObj.execution = choose_list.com_exec;
                ld('#executionDIV').html('<span class="text-ellipsis">执行人</span>');
            }
        }
        //控制发送范围字段显示
        if (choose_groupidobj[0] !== '') {
            if (choose_groupidobj.length == 1) {
                btnshowCCname = choose_groupnameobj;
            } else {
                if (ld.inArray('all', choose_groupidobj) == -1) {//未选择“所有同事”
                    btnshowCCname = '';
                    if (choose_groupidobj.length > 1) {
                        btnshowCCname = choose_groupidobj.length + '个部门';
                    }
                } else {
                    btnshowCCname = '所有、' + (choose_groupidobj.length - 1) + '个部门';
                }
            }
        }
        if (choose_groupidobj[0] !== '' && choose_useridobj[0] !== '') {
            btnshowCCname += '、';
        }
        if (choose_useridobj[0] !== '') {
            if (choose_useridobj.length == 1) {
                btnshowCCname += choose_usernameobj;
            }
            else if (choose_useridobj.length > 1) {
                btnshowCCname += '';
                btnshowCCname += choose_useridobj.length + '个同事';
            }
        }
        if (btnshowCCname) {
            ld('#wn-forword-footer .send_scop_icon,#ccrangeDIV').html('<span class="text-ellipsis">' + btnshowCCname + '</span>');
        } else {
            ld('#wn-forword-footer .send_scop_icon,#ccrangeDIV').html('<span class="text-ellipsis">发送范围</span>');
        }
        ld('#wn-release-footer [relationtype=Accounts]').attr('relationname', restobj.result.modulename.accounts);
        ld('#wn-release-footer [relationtype=Contacts]').attr('relationname', restobj.result.modulename.contacts);
        ld('#wn-release-footer [relationtype=Products]').attr('relationname', restobj.result.modulename.products);
        ld('#sendLogAcctlist .info').html('关联' + restobj.result.modulename.accounts + '<span id="sendLogAcctlistCount" class="count"></span>');
        ld('#sendLogContlist .info').html('关联' + restobj.result.modulename.contacts + '<span id="sendLogContlistCount" class="count"></span>');
        ld('#sendLogProlist .info').html('关联' + restobj.result.modulename.products + '<span id="sendLogProlistCount" class="count"></span>');
    });
    if (savetype) {
        //控制日志、周计划、月计划字段显示
        is_mandatoryStr = '';
        ld.each(workreport_field_obj['worktype_' + savetype],
            function (fldname, fldlabel) {
                fldlabelarr = fldlabel.split("&&&&&");
                fldlabel = fldlabelarr[0];
                if (firstfiled == '') {
                    firstfiled = fldname;
                }
                workreportcreate += '<textarea class="sendLog" style="line-height:1.2rem;" onblur=logicHanderObj.isFocus(\'' + fldname + '\') id="' + fldname + '" sendLog="sendLog" name="' + fldname + '" placeholder="' + fldlabel + '" autofocus="autofocus">' + fldlabelarr[1] + '</textarea>';
                if (fldlabelarr[2] == '0') {
                    is_mandatoryStr += fldname + '|||||' + fldlabel + ',';
                }
            }
        );
        ld('#sendTxt div[tag=workfield]').html(workreportcreate);
        //发布类型弹出层隐藏
        ld('#wn-release-footer [tag=comment]').removeClass('ui-hide');//点评人  
        ld('#wn-release-footer [tag=execution]').addClass('ui-hide');//执行人
    } else {
        //控制微博、任务字段显示s
        switch (entitytypetag) {
            case 'ItemWeibo'://微博
                workreportcreate = '<textarea class="sendLog sendWeibo cocmd bornone" onblur=logicHanderObj.isFocus("workexperience") id="workexperience"  name="workexperience" placeholder="请填写微博内容"></textarea>';
                break;
            case 'ItemCocmd'://任务
                workreportcreate = '<textarea class="sendLog sendWeibo cocmd bornone" onblur=logicHanderObj.isFocus("workexperience") id="workexperience"  name="workexperience" placeholder="请填写任务内容"></textarea>';
                break;
        }
        firstfiled = 'workexperience';
        ld('#sendTxt div[tag=workfield]').html(workreportcreate);
        if (entitytypetag == 'ItemCocmd') {
            var getdatetime = Tools.ServerCurentTime.timeEn();
            getdatetime = getdatetime.replace(/-/g,"/");
            var date_now = new Date(getdatetime), //取得当前日期
                next_day = new Date(date_now.valueOf() + 24 * 60 * 60 * 1000),
                dateobj = ld('#endTime').mobiscroll('getInst'); // 获取事件对象
            /*
             // 如果该事件对象已经被初始化，则不再被初始化
             if( typeof dateobj.setValue==='function' &&
             typeof dateobj.init==='function'){

             ld('#endTime').mobiscroll('init', {
             minDate: new Date(date_now.valueOf()+ 5 * 60 * 1000)
             });
             ld('#endTime').mobiscroll('setVal', next_day, true, true);
             // 初始化时间对象，并设置默认值
             }else{
             }
             */
            DateContorlObj.initDateControl('endTime', 'datetime', next_day,{
                minDate: new Date(date_now.valueOf() + 5 * 60 * 1000)
            });
            // 设置 翻译默认时间串，将转化后的时间传，赋值给ld('#endTime-translate').html()
            DateContorlObj.tranlateDateStr('endTime', 'endTime-translate', 'datetime');
            // 设置关联触发 弹出选择日期框,点击sendLogDate也弹出事件选择框
            DateContorlObj.open('endTime', 'sendLogDate');
            ld('#wn-release-footer [tag=execution],#sendLogDate').removeClass('ui-hide');
        } else {
            ld('#wn-release-footer [tag=execution]').addClass('ui-hide');//执行人
        }
        ld('#wn-release-footer [tag=comment]').addClass('ui-hide');//点评人
    }
}
//确认发布
workHandleObj.save_release = function (callback) {
    //必录项判断
    if (entitytypetag == 'ItemLogday' || entitytypetag == 'ItemLogweek' || entitytypetag == 'ItemLogmonth') {
        is_mandatoryArr = is_mandatoryStr.split(',');//字符串转化成数组
        for (var i = 0; i < is_mandatoryArr.length - 1; i++) {
            if (ld('#' + is_mandatoryArr[i].split('|||||')[0]).val() == '') {
                PopPromptBox.show(is_mandatoryArr[i].split('|||||')[1]);
                ViewObj.rootScope.savestatus = 'no';
                return false;
            }
        }
    }
    var sendLogObj = ld('#sendTxt div[tag=workfield]');
    //组装对应的字段和值
    var workfldfilter = '';
    var workfldstring = '';
    ld(sendLogObj).find('textarea').each(function () {
        workfldfilter += '&' + ld(this).attr('name') + '=' + ld(this).val();
        workfldstring += ld(this).attr('name') + ',';
    });
    workfldfilter += '&workfld=' + workfldstring;
    var sendLogSignAddress = ld('#sendLogSignAddress').html(),//定位地址
        sendLogSignPoint = '';//定位经纬度
    if (sendLogSignAddress != '') {
        sendLogSignPoint = ld('#sendLogSignPoint').html();
        sendLogSignPointArr = sendLogSignPoint.split(",");//字符串转变成数组     
    }
    var sendLogAcctlistID = JSON.parse(sessionStorage.getItem('storage_work_rela_Accountsid'));//关联的客户
    var sendLogContlistID = JSON.parse(sessionStorage.getItem('storage_work_rela_Contactsid'));//关联的联系人
    var sendLogProlistID = JSON.parse(sessionStorage.getItem('storage_work_rela_Productsid'));//关联的产品

    var ccuser = sessionStorage.getItem('storage_work_cc_userid');//发送范围 用户
    var ccgroup = sessionStorage.getItem('storage_work_cc_groupid');//发送范围 部门
    var ccusername = sessionStorage.getItem('storage_work_cc_username');//发送范围 用户名称
    var ccgroupname = sessionStorage.getItem('storage_work_cc_groupname');//发送范围 部门名称

    var uploadimgList = imgid;//上传照片
    var atuser = ld('#sendLog_at_user').val();//at 用户
    var atgroup = ld('#sendLog_at_group').val(); //at部门
    var workexperience = ld('#workexperience').val();//工作心得，用来判断微博和任务
    if (entitytypetag === 'ItemLogday' || entitytypetag === 'ItemLogweek' || entitytypetag === 'ItemLogmonth') {
        var reader = sessionStorage.getItem('storage_work_com_execid');//点评人 
        if (reader == undefined || trim(reader) == '') {
            PopPromptBox.show('请选择点评人');
            ViewObj.rootScope.savestatus = 'no';
            return;
        }
    } else if (entitytypetag == 'ItemWeibo' || entitytypetag == 'ItemCocmd') {
        savetype = 1;
        if (entitytypetag == 'ItemWeibo') {
            // 发送范围 为空时，提示
            if (empty(ccuser) && empty(ccgroup)) {
                if (ld('.bot_operbtn .sendrangeimg').length == 0) {
                    ld('.bot_operbtn').append('<div class="sendrangeimg"></div>');
                }
                ViewObj.rootScope.savestatus = 'no';
                return;
            }
        }
        if (trim(workexperience) == '' && uploadimgList == '') {
            PopPromptBox.show('您还没有填写内容');
            ViewObj.rootScope.savestatus = 'no';
            return;
        }
        else if (trim(workexperience) == '' && uploadimgList != '') {
            workexperience = '分享图片';
        }
        if (entitytypetag == 'ItemCocmd') {
            var compelete_date = DateContorlObj.getDateValue('endTime');
            var cmduser = sessionStorage.getItem('storage_work_com_execid');//执行人
            if (cmduser == undefined || trim(cmduser) == '') {
                PopPromptBox.show('请选择执行人');
                ViewObj.rootScope.savestatus = 'no';
                return;
            }
        }
    }

    var urlstring = 'module=Home&action=ListView';
    urlstring += '&method=saveSendLog' + workfldfilter;
    if (entitytypetag === 'ItemLogday' || entitytypetag === 'ItemLogweek' || entitytypetag === 'ItemLogmonth') {
        urlstring += '&entitytype=workreport';
    }
    else if (entitytypetag === 'ItemWeibo') {
        urlstring += '&entitytype=weibo';
    }
    else if (entitytypetag === 'ItemCocmd') {
        urlstring += '&entitytype=cocmd';
    }
    urlstring += '&savetype=' + savetype + '&accountlist=' + sendLogAcctlistID + '&contactlist=' + sendLogContlistID
        + '&productslist=' + sendLogProlistID + '&ccuser=' + ccuser + '&ccgroup=' + ccgroup
        + '&ccusername=' + ccusername + '&ccgroupname=' + ccgroupname + '&atuser=' + atuser
        + '&atgroup=' + atgroup + '&uploadimgList=' + uploadimgList + '&userid=' + userid;
    if (entitytypetag === 'ItemLogday' || entitytypetag === 'ItemLogweek' || entitytypetag === 'ItemLogmonth') {
        urlstring += '&reader=' + reader;
    }
    else if (entitytypetag === 'ItemCocmd') {
        urlstring += '&cmduser=' + cmduser;
        urlstring += '&startdate=' + compelete_date + '&enddate=' + compelete_date;
    }
    if (sendLogSignAddress != '') {
        urlstring += '&signaddress=' + sendLogSignAddress + '&longtitude=' + sendLogSignPointArr[0] + '&latitude=' + sendLogSignPointArr[1];
    }
    WordReportAjax(urlstring, function (rest) {
        logicHanderObj.toClear();//清空值
        callback();
    });
};

//关联数据底部已选择
workHandleObj.showselectedRelationdata = function () {
    var relationtypeName = ViewObj.getPrevInfo('header')[3].substr(2);
    var seehtml = '',
        btnshowRelationname = '';
    if (relationtype === 'Accounts') {
        //t_choose_a_relationidobj = JSON.parse(sessionStorage.getItem(relationidkey));//id
        //t_choose_a_relationnameobj = JSON.parse(sessionStorage.getItem(relationnamekey));//name
        if (empty(t_choose_a_relationidobj)) {
            t_choose_a_relationidobj = [];
            t_choose_a_relationnameobj = [];
        }
        if (t_choose_a_relationidobj.length == 1) {
            btnshowRelationname = t_choose_a_relationnameobj;
        } else {
            if (t_choose_a_relationidobj.length > 1) {
                btnshowRelationname += t_choose_a_relationidobj.length + '个' + relationtypeName;
            }
        }
        ld.each(t_choose_a_relationidobj, function (key, id) {
            seehtml += '<li id="relation' + relationtype + '_' + id + '">' + t_choose_a_relationnameobj[key] + '</li>';
        });
    }
    else if (relationtype === 'Contacts') {
        //t_choose_c_relationidobj = JSON.parse(sessionStorage.getItem(relationidkey));//id
        //t_choose_c_relationnameobj = JSON.parse(sessionStorage.getItem(relationnamekey));//name
        if (empty(t_choose_c_relationidobj)) {
            t_choose_c_relationidobj = [];
            t_choose_c_relationnameobj = [];
        }
        if (t_choose_c_relationidobj.length == 1) {
            btnshowRelationname = t_choose_c_relationnameobj;
        } else {
            if (t_choose_c_relationidobj.length > 1) {
                btnshowRelationname += t_choose_c_relationidobj.length + '个' + relationtypeName;
            }
        }
        ld.each(t_choose_c_relationidobj, function (key, id) {
            seehtml += '<li id="relation' + relationtype + '_' + id + '">' + t_choose_c_relationnameobj[key] + '</li>';
        });
    }
    else if (relationtype === 'Products') {
        //t_choose_p_relationidobj = JSON.parse(sessionStorage.getItem(relationidkey));//id
        //t_choose_p_relationnameobj = JSON.parse(sessionStorage.getItem(relationnamekey));//name
        if (empty(t_choose_p_relationidobj)) {
            t_choose_p_relationidobj = [];
            t_choose_p_relationnameobj = [];
        }
        if (t_choose_p_relationidobj.length == 1) {
            btnshowRelationname = t_choose_p_relationnameobj;
        } else {
            if (t_choose_p_relationidobj.length > 1) {
                btnshowRelationname += t_choose_p_relationidobj.length + '个' + relationtypeName;
            }
        }
        ld.each(t_choose_p_relationidobj, function (key, id) {
            seehtml += '<li id="relation' + relationtype + '_' + id + '">' + t_choose_p_relationnameobj[key] + '</li>';
        });
    }
    ld('#wn-choosenview-footer>span').html('已选择：' + btnshowRelationname);
    ld('#chosenlist_' + relationtype).html(seehtml);
}
//获取关联列表
workHandleObj.getRelationList = function (urlstring, callback) {
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest),
            content_holder = ld('#cwn-popuselect-view>div.content-wrapper');

        SwiperObj.ListPageObj.setListPageIndex(restobj.result.curpagenum, ViewObj.getInfo('to_viewid'));
        SwiperObj.ListPageObj.setHasNextPage(restobj.result.havenextpage, ViewObj.getInfo('to_viewid'));
        if (restobj.result.list != '') {
            var listhtml = '';
            //列表循环
            ld.each(restobj.result.list, function (key, list) {
                if (empty(list)) return false;
                if(!list.title){
                    if (!list.A) {
                        list.A = '--';
                    }
                    if (!list.B) {
                        list.B = '--';
                    }
                    if (!list.C) {
                        list.C = '--';
                    }
                    if (!list.D) {
                        list.D = '--';
                    }
                    if (relationtype == 'Accounts') {
                        listhtml += '<li id="' + relationtype + '_' + list.curid + '" dataid="' + list.curid + '" class="lnr-square" name="' + list.A + '" item="popu_select"><h5>' + list.A + '</h5>' +
                            '<p><span>' + list.B + '</span> | <span>' + list.C + ' | ' + list.D + '</span></p>' +
                            '</li>';
                    } else if (relationtype == 'Contacts') {
                        listhtml += '<li id="' + relationtype + '_' + list.curid + '" dataid="' + list.curid + '" class="lnr-square" name="' + list.A + '" item="popu_select"><h5>' + list.A + '</h5>' +
                            '<p><span>' + list.B + '</span> | <span>' + list.D + '</span></p>' +
                            '</li>';
                    } else if (relationtype == 'Products') {
                        listhtml += '<li id="' + relationtype + '_' + list.curid + '" dataid="' + list.curid + '" class="lnr-square" name="' + list.A + '" item="popu_select"><h5>' + list.A + '</h5>' +
                            '<p><span>' + list.B + '</span> | <span>' + list.C + '</span></p>' +
                            '</li>';
                    }
                }
                else{
                    listhtml += '<li id="' + relationtype + '_' + list.curid + '" dataid="' + list.curid + '" class="lnr-square" name="' + list.title + '" item="popu_select">' +
                                    '<h5>' + list.title + '</h5>';
                                    ld.each(list.field, function (keyfield, listfield) {
                                        var listfieldOne = listfield[0],
                                            listfieldTwo = listfield[1];
                                        if(listfieldOne == undefined) listfieldOne = '';
                                        if(listfieldTwo == undefined) listfieldTwo = '';
                    listhtml +=         '<p><span>' + listfieldOne + '</span> | <span>' + listfieldTwo + '</span></p>';
                                    });
                    listhtml += '</li>';
                }
            });
            var list_class = 'crm-lists';
            //计算多少行
            if (!empty(restobj.result.list)) {
                if(restobj.result.list[0].title){
                    var i = 1;
                    ld.each(restobj.result.list[0].field, function (listfieldkey, listfieldinfo) {
                        i++;
                    });
                    list_class = 'crm-lists line'+i;
                }
            }
            listhtml = '<ul class="'+ list_class +' relatopt">' + listhtml + '</ul>';
            if (SwiperObj.is_addMore) { // 加载 时 不需清空原来的值
                content_holder.html(content_holder.html() + listhtml);
            } else {                    // 刷新 搜索 时 需要清空 当前的值
                content_holder.html(listhtml);
            }
            workHandleObj.showselectedRelationdata();//计算底部已选择 
            //选中已选择的数据
            if (GVObj.workObj.liststatus != 'search') {
                if (relationtype === 'Accounts') {
                    if (!empty(t_choose_a_relationidobj)) {
                        ld.each(t_choose_a_relationidobj, function (key, id) {
                            ld('#' + relationtype + '_' + id).attr('class', 'lnr-checkmark-square');
                        });
                    }
                }
                else if (relationtype === 'Contacts') {
                    if (!empty(t_choose_c_relationidobj)) {
                        ld.each(t_choose_c_relationidobj, function (key, id) {
                            ld('#' + relationtype + '_' + id).attr('class', 'lnr-checkmark-square');
                        });
                    }
                }
                else if (relationtype === 'Products') {
                    if (!empty(t_choose_p_relationidobj)) {
                        ld.each(t_choose_p_relationidobj, function (key, id) {
                            ld('#' + relationtype + '_' + id).attr('class', 'lnr-checkmark-square');
                        });
                    }
                }
            }
            callback();
        } else {
            var listhtml = logicHanderObj.NoinfoNotice(restobj.result.list2.moduletitle);
            content_holder.html(listhtml);
            callback();
        }
    });
}
//加载工作列表
workHandleObj.getWorkList = function (urldata, callback) {
    var urlstring = 'module=Home&action=ListView';
    if ('' !== urldata) urlstring += '&' + urldata;
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var tplnode = ld('#tplnode').html();
        var listhtml = '';
        if (empty(restobj.report)) {
            var message_info = '数据';
            if (smallcategory === 'weibo') {
                message_info = '微博';
            }
            else if (smallcategory === 'cocmd') {
                message_info = '任务';
            }
            else if (smallcategory === 'logday') {
                message_info = '日志';
            }
            else if (smallcategory === 'logweek') {
                message_info = '周计划';
            }
            else if (smallcategory === 'logmonth') {
                message_info = '月计划';
            }
            listhtml = logicHanderObj.NoinfoNotice(message_info);
        }
        var userimage, userimg, node, maxlength = 0;
        var signcls, accountlist, accountcls, contactlist, contactcls, productslist, productscls;
        var readerbuttontit, keyreport, workimglist, workimgcls, workattlist, workattcls;
        SwiperObj.ListPageObj.setListPageIndex(restobj.summary.curpagenum, ViewObj.getInfo('to_viewid'));
        SwiperObj.ListPageObj.setHasNextPage(restobj.summary.havenextpage, ViewObj.getInfo('to_viewid'));
        if (GVObj.newstype == 'approvelist') {//news 页面 消息提醒>未处理  切换右上角数字
            if (GVObj.news_smallcategory === 'workreport') {
                if (restobj.summary.othericontype == '1') {
                    ld('#pending_node>a>i[tag=cocmdn]').addClass('cird-num');
                }
                else {
                    ld('#pending_node>a>i[tag=cocmdn]').removeClass('cird-num');
                }
                if (restobj.summary.icontype == '1') {
                    ld('#pending_node>a>i[tag=logn]').addClass('cird-num');
                }
                else {
                    ld('#pending_node>a>i[tag=logn]').removeClass('cird-num');
                }
            }
            else if (GVObj.news_smallcategory === 'cocmd') {
                if (restobj.summary.othericontype == '1') {
                    ld('#pending_node>a>i[tag=logn]').addClass('cird-num');
                }
                else {
                    ld('#pending_node>a>i[tag=logn]').removeClass('cird-num');
                }
                if (restobj.summary.icontype == '1') {
                    ld('#pending_node>a>i[tag=cocmdn]').addClass('cird-num');
                }
                else {
                    ld('#pending_node>a>i[tag=cocmdn]').removeClass('cird-num');
                }
            }
            if (restobj.summary.workreport_display == 'yes') {
                ld('#pending_node>a>i[tag=logn]').html(restobj.summary.workreport_count);
                ld('#pending_node>a>i[tag=logn]').removeClass('ui-hide');
            }
            else {
                ld('#pending_node>a>i[tag=logn]').addClass('ui-hide');
            }
            if (restobj.summary.cocmd_display == 'yes') {
                ld('#pending_node>a>i[tag=cocmdn]').html(restobj.summary.cocmd_count);
                ld('#pending_node>a>i[tag=cocmdn]').removeClass('ui-hide');
            }
            else {
                ld('#pending_node>a>i[tag=cocmdn]').addClass('ui-hide');
            }
        }
        //获取日志自定义字段结果集
        if (empty(workreport_field_obj)) {//放在公共变量里，不用每次都读取
            var setype = '';
            var workfldarr = {};
            //日志
            dayfieldnum = restobj.field.workreport.dayreport.fieldcount;
            ld.each(restobj.field.workreport.dayreport.fieldinfo, function (key, fieldinfo) {
                if (empty(fieldinfo)) return false;
                workfldarr[fieldinfo.name] = fieldinfo.label + '&&&&&' + fieldinfo.defaultvalue + '&&&&&' + fieldinfo.is_mandatory;
            });
            workreport_field_obj['worktype_' + 1] = workfldarr;
            //周计划
            workfldarr = {};
            weekfieldnum = restobj.field.workreport.weekreport.fieldcount;
            ld.each(restobj.field.workreport.weekreport.fieldinfo, function (key, fieldinfo) {
                if (empty(fieldinfo)) return false;
                workfldarr[fieldinfo.name] = fieldinfo.label + '&&&&&' + fieldinfo.defaultvalue + '&&&&&' + fieldinfo.is_mandatory;
            });
            workreport_field_obj['worktype_' + 2] = workfldarr;
            //月计划
            workfldarr = {};
            monthfieldnum = restobj.field.workreport.monthreport.fieldcount;
            ld.each(restobj.field.workreport.monthreport.fieldinfo, function (key, fieldinfo) {
                if (empty(fieldinfo)) return false;
                workfldarr[fieldinfo.name] = fieldinfo.label + '&&&&&' + fieldinfo.defaultvalue + '&&&&&' + fieldinfo.is_mandatory;
            });
            workreport_field_obj['worktype_' + 3] = workfldarr;
        }
        //列表循环
        ld.each(restobj.report, function (key, report) {
            if (empty(report)) return false;
            userimage = 'images/defaultuser.png';
            if (!empty(report.userimage)) {
                userimage = 'http://' + loginurl + '/' + report.userimage;
            }
            userimg = '<img src="' + userimage + '" alt="" class="name-img" onload="logicHanderObj.loadimg(this)">';
            signcls = 'ui-hide';
            if (!empty(report.signaddress)) {
                signcls = '';
            }
            accountlist = '';
            accountcls = 'ui-hide';
            if (!empty(report.Accounts)) {
                accountcls = '';
                var accountclscount = 0;
                ld.each(report.Accounts, function (key, accountobj) {
                    accountlist += accountobj.name + '、';
                    accountclscount++;
                });
                accountlist = accountlist.substr(0, accountlist.length - 1);
            }
            contactlist = '';
            contactcls = 'ui-hide';
            if (!empty(report.Contacts)) {
                contactcls = '';
                var contactclscount = 0;
                ld.each(report.Contacts, function (key, contactsobj) {
                    contactlist += contactsobj.name + '、';
                    contactclscount++;
                });
                contactlist = contactlist.substr(0, contactlist.length - 1);
            }
            productslist = '';
            productscls = 'ui-hide';
            if (!empty(report.Products)) {
                productscls = '';
                var productsclscount = 0;
                ld.each(report.Products, function (key, productsobj) {
                    productslist += productsobj.name + '、';
                    productsclscount++;
                });
                productslist = productslist.substr(0, productslist.length - 1);
            }
            //点评、关键回复
            readerbuttontit = '回复';
            keyreport = 'ui-hide';
            if ('yes' == report.readerbutton) {
                readerbuttontit = '点评';
            }
            else {
                if (0 != report.approved)
                    keyreport = '';
            }
            if (report.entitytype == 'cocmd' || report.entitytype == 'weibo') {
                readerbuttontit = '回复';
            }
            //关联图片
            workimglist = '';
            workimgcls = 'ui-hide';
            //关联附件
            workattlist = '';
            workattcls = 'ui-hide';
            if (!empty(report.workachment)) {
                if (!empty(report.workachment['image'])) {
                    workimgcls = '';
                    var img_index = 0,
                        tem_url = '';
                    workimglist = '<li class="workimg-upload pictrue-fold picture-preview" achmentid="' + key + '">';
                    ld.each(report.workachment.image, function (key, workimgobj) {
                        var imgpath = workimgobj.path.value + workimgobj.name.value;
                        if (img_index === 0) {
                            tem_url = 'http://' + loginurl + '/' + imgpath;
                        }
                        img_index += 1;
                        workimglist += '<span img-detail="http://' + loginurl + '/' + imgpath + '" style="display:none;"></span>';
                    });
                    workimglist += '<img src="' + tem_url + '" alt="" class=""><span>' + img_index + '张</span></li>';
                }
                if (!empty(report.workachment['att'])) {
                    workattcls = '';
                    var tem_url = '';
                    workattlist = '<li><span><i class="lnr-attachment"></i>';
                    ld.each(report.workachment.att, function (key, workattobj) {
                        var attpath = workattobj.path.value + workattobj.file_name.value;
                        if (img_index === 0) {
                            tem_url = 'http://' + loginurl + '/' + attpath;
                        }
                        workattlist += workattobj.file_name.value + '、';
                    });
                    workattlist = workattlist.substr(0, workattlist.length - 1);
                    workattlist += '</span></li>';
                }
            }
            //点赞数量
            var praiseStr = '';
            if (report.praisecount > 0) {
                praiseStr = report.praisecount;
            } else {
                praiseStr = '赞';
            }
            //控制微博、日志、任务字段显示
            workreportlabel = '';
            var workfldarr = {'worksummary': 'summary', 'workexperience': 'experience'}
            switch (report.entitytype) {
                case 'weibo'://微博
                case 'cocmd'://任务
                    //转换表情路径
                    if(report.experience){
                        report.experience = report.experience.replace(new RegExp("themes/softed", "gm"), 'images');
                    }
                    else{
                        report.experience = '';
                    }
                    workreportlabel = '<p class="font16 black">' + Tools.escape2Html(report.experience) + '</p>';
                    break;
                case 'workreport'://发日志
                    ld.each(workreport_field_obj['worktype_' + report.workreporttype],
                        function (fldname, fldlabel) {
                            if (workfldarr[fldname] != undefined) fldname = workfldarr[fldname];
                            fldlabelarr = fldlabel.split("&&&&&");
                            fldlabel = fldlabelarr[0];
                            //转换表情路径
                            if(report[fldname]){
                                report[fldname] = report[fldname].replace(new RegExp("themes/softed", "gm"), 'images');    
                            }
                            else{
                                report[fldname] = '';
                            }
                            workreportlabel += '<h3 class="font16">' + fldlabel + '</h3><p class="font16 black">' + Tools.escape2Html(report[fldname]) + '</p>';
                        }
                    );
                    break;
            }
            node = Tools.sprintf(tplnode,
                report.curid,
                report.curid,
                report.userid,
                report.username,
                report.entitytypename,//类别
                report.workreportstatusclass,//样式
                report.workreportstatus,//状态
                report.workreporttime,//时间
                report.curid,
                report.reader.startDateDescription,//日志，任务内容前描述，微博没有描述
                workreportlabel,//中间自定义字段显示的地方
                workimgcls,//图片显示
                workimglist,
                workattcls,//附件显示
                workattlist,
                signcls,//签到
                report.longtitude,
                report.latitude,
                report.signaddress,
                accountcls,//关联客户
                accountclscount,//个数
                accountlist,
                contactcls,//关联联系人
                contactclscount,//个数
                contactlist,
                productscls,//关联产品
                productsclscount,//个数
                productslist,
                report.curid,//回复
                report.readerbutton,//点评、回复状态
                report.entitytype,
                readerbuttontit,//点评、回复文字
                report.curid,
                report.replycount,//回复数量
                report.curid,//点赞
                report.ispraiseclass,//是否点赞
                praiseStr, //点赞数量                    
                report.curid//转发		
            );
            node = strtr(node, 'name-img', userimg);//用户图片
            if (report.praisecount > 0) {//点赞数量
                node = strtr(node, 'praise-num', 'num');
            }
            else {
                node = strtr(node, 'praise-num', 'num ui-hide');
            }
            if (report.replycount > 0) {//回复数量
                node = strtr(node, 'reply-num', 'num');
            }
            else {
                node = strtr(node, 'reply-num', 'num ui-hide');
            }
            listhtml += node;
        });
        // 根据当前页面view_id 来确定 填充容器 view_id 可能是 work-main-view 或者 wn-worklist-view
        var c_vid = ViewObj.getCurrentViewId(),
            content_holder = ld('#' + c_vid);
        if (c_vid === 'wn-worklist-view' || c_vid === 'wn-replayfileat-view' || c_vid === 'wn-userinfo-view') {
            content_holder = ld('#' + c_vid + ' .pubDetialC');
        }
        // 如果是刷新就 不清空原来的内容
        if (SwiperObj.is_addMore) {
            content_holder.html(content_holder.html() + listhtml);
            // 搜索和 刷新都要清空原来的内容
        } else {
            content_holder.html(listhtml);
        }
        callback();
    });
};
//明细界面
workHandleObj.getWorkDetailView = function (urldata, callback, workreportid) {
    ld('#work_detailbox').html('');
    var urlstring = 'module=Home&action=ListView&method=getDetailView';
    if ('' != urldata) urlstring += '&' + urldata;
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var tplnode = ld('#tpldetailnode').html();
        var detailhtml = '';
        var detailispraise = '';
        var userimage, userimg, node, maxlength = 0, ispraise;
        var signcls, accountlist, accountcls, contactlist, contactcls, productslist, productscls;
        var readerbuttontit, keyreport, workimglist, workimgcls, workattlist, workattcls;
        //明细关键回复ishave:1 有关键回复 0 无关键回复
        var keyreplytitle = '';
        var keyreply = 'ui-hide';
        if (restobj.reply.ishave == 1) {
            keyreply = '';
            if (restobj.report[0].entitytype == 'workreport') {
                keyreplytitle = '以下为直属领导的点评';
            }
            else if (restobj.report[0].entitytype == 'cocmd') {
                keyreplytitle = '以下为任务关键节点的回复';
            }
        }
        ld.each(restobj.report, function (key, report) {
            if (empty(report)) return false;
            //单据模块
            ld('#header_detail_name').html(report.entitytypename);
            userimage = 'images/defaultuser.png';
            if (!empty(report.userimage)) {
                userimage = 'http://' + loginurl + '/' + report.userimage;
            }
            userimg = '<img src="' + userimage + '" alt="" class="name-img" onload="logicHanderObj.loadimg(this)">';
            //是否点赞
            ispraise = 'hand';
            if ('yes' == report.ispraise) {
                ispraise = 'hand handred';
            }

            signcls = 'ui-hide';
            if (!empty(report.signaddress)) {
                signcls = '';
            }
            accountlist = '';
            accountcls = 'ui-hide';
            if (!empty(report.Accounts)) {
                accountcls = '';
                var accountclscount = 0;
                ld.each(report.Accounts, function (key, accountobj) {
                    accountlist += '<a class="fontblue" href="javascript:void(0);" detailID=\'' + accountobj.curid + '\' module="Accounts" titlename="客户" tag="seeCrmBilldetail">' + accountobj.name + '</a>' + '、';
                    accountclscount++;
                })
                accountlist = accountlist.substr(0, accountlist.length - 1);
            }
            contactlist = '';
            contactcls = 'ui-hide';
            if (!empty(report.Contacts)) {
                contactcls = '';
                var contactclscount = 0;
                ld.each(report.Contacts, function (key, contactsobj) {
                    contactlist += '<a class="fontblue" href="javascript:void(0);" detailID=\'' + contactsobj.curid + '\' module="Contacts" titlename="联系人" tag="seeCrmBilldetail">' + contactsobj.name + '</a>' + '、';
                    contactclscount++;
                })
                contactlist = contactlist.substr(0, contactlist.length - 1);
            }
            productslist = '';
            productscls = 'ui-hide';
            if (!empty(report.Products)) {
                productscls = '';
                var productsclscount = 0;
                ld.each(report.Products, function (key, productsobj) {
                    productslist += '<a class="fontblue" href="javascript:void(0);" detailID=\'' + productsobj.curid + '\' module="Products" titlename="产品" tag="seeCrmBilldetail">' + productsobj.name + '</a>' + '、';
                    productsclscount++;
                })
                productslist = productslist.substr(0, productslist.length - 1);
            }
            //点评、关键回复
            readerbuttontit = '回复';
            //关联图片
            workimglist = '';
            workimgcls = 'ui-hide';
            //关联附件
            workattlist = '';
            workattcls = 'ui-hide';
            if (!empty(report.workachment)) {
                if (!empty(report.workachment['image'])) {
                    workimgcls = '';
                    var img_index = 0,
                        tem_url = '';
                    workimglist = '<li class="workimg-upload pictrue-fold picture-preview" achmentid="' + key + '">';
                    ld.each(report.workachment.image, function (key, workimgobj) {
                        var imgpath = workimgobj.path.value + workimgobj.name.value;
                        if (img_index === 0) {
                            tem_url = 'http://' + loginurl + '/' + imgpath;
                        }
                        img_index += 1;
                        workimglist += '<span img-detail="http://' + loginurl + '/' + imgpath +
                            '" style="display:none;"></span>';
                    });
                    workimglist += '<img src="' + tem_url + '" alt="" class=""><span>' + img_index + '张</span></li>';
                }
                if (!empty(report.workachment['att'])) {
                    workattcls = '';
                    var tem_url = '';
                    workattlist = '<li><span><i class="lnr-attachment"></i>';
                    ld.each(report.workachment.att, function (key, workattobj) {
                        var attpath = workattobj.path.value + workattobj.file_name.value;
                        if (img_index === 0) {
                            tem_url = 'http://' + loginurl + '/' + attpath;
                        }
                        workattlist += workattobj.file_name.value + '、';
                    });
                    workattlist = workattlist.substr(0, workattlist.length - 1);
                    workattlist += '</span></li>';
                }
            }

            ld('#tplMoreOperation>.btnsub').addClass('ui-hide');
            if (report.cocmdcancel == 'yes') {//判断任务取消是否显示
                ld('#tplMoreOperation>[tag=more-cocmdcancel]').removeClass('ui-hide');
            }
            if (report.isDel == 'yes') {//是否删除
                ld('#tplMoreOperation>[tag=more-delete]').removeClass('ui-hide');
            }
            //明细更多显示
            var c_header = ViewObj.getInfo('current_header');
            if (report.cocmdcancel == 'yes' || report.isDel == 'yes') {
                c_header.splice(4, 2, '...', '');
                ViewObj.setAppHeader(c_header);
            } else {
                c_header.splice(4, 2, '', '');
                ViewObj.setAppHeader(c_header);
            }
            //明细界面回复部分
            detailispraise = ispraise;
            detailentitytype = report.entitytype;
            detailreplytype = report.readerbutton;
            if (empty(report.workreporttype)) report.workreporttype = 1;
            if (empty(report.praisecount)) report.praisecount = 0;
            //控制微博、日志、任务字段显示
            workreportlabel = '';
            var workfldarr = {'worksummary': 'summary', 'workexperience': 'experience'};
            switch (report.entitytype) {
                case 'weibo'://微博
                case 'cocmd'://任务
                    //转换表情路径
                    if(report.experience){
                        report.experience = report.experience.replace(new RegExp("themes/softed", "gm"), 'images');
                    }
                    else{
                        report.experience = '';
                    }
                    workreportlabel = '<p class="font16 black">' + Tools.escape2Html(report.experience) + '</p>';
                    break;
                case 'workreport'://发日志
                    ld.each(workreport_field_obj['worktype_' + report.workreporttype],
                        function (fldname, fldlabel) {
                            if (workfldarr[fldname] != undefined) fldname = workfldarr[fldname];
                            fldlabelarr = fldlabel.split("&&&&&");
                            fldlabel = fldlabelarr[0];
                            //转换表情路径
                            if(report[fldname]){
                                report[fldname] = report[fldname].replace(new RegExp("themes/softed", "gm"), 'images');    
                            }
                            else{
                                report[fldname] = '';
                            }
                            workreportlabel += '<h3 class="font16">' + fldlabel + '</h3><p class="font16 black">' + Tools.escape2Html(report[fldname]) + '</p>';
                        }
                    );
                    break;
            }
            node = Tools.sprintf(tplnode,
                report.curid,
                report.userid,
                report.username,
                report.entitytypename,//类别
                report.workreportstatusclass,//样式
                report.workreportstatus,//状态
                report.workreporttime,//时间
                report.relateUserDescription,
                report.reader.startDateDescription,//日志，任务内容前描述，微博没有描述
                workreportlabel,//中间自定义字段显示的地方
                workimgcls,//图片显示
                workimglist,
                workattcls,//附件显示
                workattlist,
                signcls,//签到
                report.longtitude,
                report.latitude,
                report.signaddress,
                accountcls,//关联客户
                accountclscount,//个数
                accountlist,
                contactcls,//关联联系人
                contactclscount,//个数
                contactlist,
                productscls,//关联产品
                productsclscount,//个数
                productslist,
                keyreply,//是否有关键回复
                keyreplytitle,//关键回复标题
                restobj.reply.replyusername,//关键回复人名称
                restobj.reply.content,//关键回复内容
                restobj.reply.createdtime,//关键回复时间
                report.curid,
                report.replycount,
                report.replycount,//回复数量
                report.curid,
                report.praisecount,
                report.praisecount //点赞数量
            );
            node = strtr(node, 'name-img', userimg);//用户图片
            if (report.praisecount > 0) {//点赞数量
                node = strtr(node, 'praise-num', 'num');
            } else {
                node = strtr(node, 'praise-num', 'num ui-hide');
            }
            if (report.replycount > 0) {//回复数量
                node = strtr(node, 'reply-num', 'num');
            } else {
                node = strtr(node, 'reply-num', 'num ui-hide');
            }
            detailhtml += node;
        });
        ld('#work_detailbox').html(detailhtml).css({'width': SwiperObj.PHONE_WIDTH});
        GVObj.workrecord = workreportid;
        //获取回复列表
        workHandleObj.getReplyList(workreportid, callback);
        //明细点赞
        if (detailispraise == 'hand') {
            ld('#wn-workdetail-footer [tag=praiseIcon]').attr('class', 'lnr-good');
        } else {
            ld('#wn-workdetail-footer [tag=praiseIcon]').attr('class', 'lnr-gooded');
        }
        //明细回复
        ld('#wn-workdetail-footer>ul>li>[tag=reply]').attr('entitytype', detailentitytype);
        ld('#wn-workdetail-footer>ul>li>[tag=reply]').attr('replytype', detailreplytype);
    });
}
//获取回复列表
workHandleObj.getReplyList = function (workreport, callback) {
    var urlstring = 'module=Home&action=ListView&method=getReplyList&workreportid=' + workreport;
    WordReportAjax(urlstring, function (rest) {
        var replynode = ld('#tplDetailReply').html();
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        if (empty(restobj.list)) {
            var replyhtml = '<div class="no_reply_con">' +
                '<i class="lnr-comment"></i>' +
                '<p>还没有人回复哦<br>快来发一条回复吧！</p>' +
                '</div>';
        } else {
            var replyhtml = '',
                node = '',
                userimg = '',
                userimage = '';
            if (restobj.list) {
                ld.each(restobj.list, function (key, list) {
                    //转换表情路径
                    list.content = Tools.escape2Html(list.content.replace(new RegExp("themes/softed", "gm"), 'images'));
                    node = Tools.sprintf(replynode,
                        list.curid,
                        list.replyuserid,
                        list.replyusername,
                        list.createdtime,
                        list.content
                    );
                    userimage = 'images/defaultuser.png';
                    if (!empty(list.userimage)) {
                        userimage = 'http://' + loginurl + '/' + list.userimage;
                    }
                    userimg = '<img src="' + userimage + '" alt="" class="name-img" onload="logicHanderObj.loadimg(this)">';
                    node = strtr(node, 'name-img', userimg);//用户图片
                    node = strtr(node, 'no_reply_con', 'no_reply_con ui-hide');
                    replyhtml += node;
                });
            }
        }
        ld('#detailReply').html(replyhtml);
        ld('#detailReply,#detailPraise').addClass('ui-hide');
        ld('#detailReply').removeClass('ui-hide');
        SwiperObj.autoHeight(-1);
        if (callback) callback();
    });
}
//获取点赞列表
workHandleObj.getPraiseList = function (workreport, callback) {
    var urlstring = 'module=Home&action=ListView&method=getPraiseList&workreportid=' + workreport;
    WordReportAjax(urlstring, function (rest) {
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var praisehtml = '';
        if (!empty(restobj.list)) {
            if (restobj.list) {
                ld.each(restobj.list, function (key, list) {
                    praisehtml += list.praiseusername + ',';
                });
                praisehtml = praisehtml.substr(0, praisehtml.length - 1);
                praisehtml = '<div style="padding:.5rem;">' + praisehtml + '</div>';
            }
        } else {
            praisehtml = '<div class="no_reply_con">' +
                '<i class="lnr-good"></i>' +
                '<p>还没有人赞过<br/>觉得好就赞一下吧！</p>' +
                '</div>';
        }
        praisehtml = praisehtml.substring(0, praisehtml.length - 1);
        ld('#detailPraise').html(praisehtml);
        ld('#detailReply').addClass('ui-hide');
        ld('#detailPraise').removeClass('ui-hide');
        SwiperObj.autoHeight(-1);
        if (callback) callback();
    });
}
//列表点赞数量赋值
workHandleObj.listPraiseCount = function (handobj) {
    var good = ld(handobj).find('i').attr('class');
    var num = ld(handobj).text();
    if (empty(num) || 1 > num) num = 0;
    else num = parseInt(num);
    if (isNaN(num)) num = 0;
    if (good == 'lnr-good') {//点赞
        num += 1;
        ld(handobj).find('i').attr('class', 'lnr-gooded');
        ld(handobj).find('span').html(num);
    }
    else {//取消点赞
        num -= 1;
        ld(handobj).find('i').attr('class', 'lnr-good');
        if (num <= 0) {
            ld(handobj).find('span').text('赞');
        }
        else {
            ld(handobj).find('span').text(num);
        }
    }
}
//列表回复数量赋值
workHandleObj.listReplyCount = function (temp_str) {
    var num = ld('.replyCount' + GVObj.workrecord).html();
    num++;
    if (num == 1) {
        ld('.replyCount' + GVObj.workrecord).html('1').parent().removeClass('ui-hide').prev().html('回复').attr('tag', 'no');
    }
    else if (num > 1) {
        ld('.replyCount' + GVObj.workrecord).html(num);
    }
    if (temp_str != '') {
        ld('.replyCount' + GVObj.workrecord).parent().prev().parents('.area-list').find('span.a_user_bz_status').addClass('fontgreen').html(temp_str);
    }
}
//个人信息中，加载工作列表
workHandleObj.getDocumentList = function (doc_type, urldata, callback) {
    var urlstring = 'module=Home&action=ListView&method=getDocumentList' + 
                    '&smallcategory=all&bigcategory=1&page=1&searchcontent=' + urldata;
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var listhtml = '';
        //文档
        if(doc_type==='document'){
            listhtml = '<ul class="replayfileat_file">';
            ld.each(restobj.report.list, function (key, list) {
                if(list.workachment.att!=''){
                    ld.each(list.workachment.att, function (attkey, attlist) {
                        //listhtml += '<span>'+attlist.file_name.value+'</span>';
                        listhtml += '<li class="area-list">' + 
                                    '    <div></div>' + 
                                    '    <span class="text-ellipsis">' + 
                                    '        <i class="text-ellipsis">'+attlist.file_name.value+'</i>' + 
                                    '       （'+ attlist.size.value + '）' + list.workreporttime + 
                                    '    </span>' + 
                                    '    <a reporttypestr="'+ list.entitytypename +'" workreportid="'+ list.curid +'">查看<br/>原文</a>' + 
                                    '</li>';
                    });
                }                
            });
            listhtml += '</ul>';
        }
        //图片
        else if(doc_type==='picture'){
            ld.each(restobj.report.list, function (key, list) {
                if(list.workachment.image!=''){
                    ld.each(list.workachment.image, function (imagekey, imagelist) {
                        listhtml += '<span>'+imagelist.file_name.value+'</span>';
                    });
                }
            });
        }

        var c_vid = ViewObj.getCurrentViewId(),
            content_holder = ld('#' + c_vid + ' .pubDetialC');
        // 如果是刷新就 不清空原来的内容
        if (SwiperObj.is_addMore) {
            content_holder.html(content_holder.html() + listhtml);
            // 搜索和 刷新都要清空原来的内容
        } else {
            content_holder.html(listhtml);
        }
        callback();
    });
};