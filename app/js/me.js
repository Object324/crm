var meHandleObj = {};
// 定义跳转me-main-view(me首页)的方法  及click处理定义
ViewObj['create-me-main-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['', '', '', '我', '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon('me-main-view', ['', '', '', '我', '', ''], opts_obj);
        var urlstring = 'module=Home&action=ListView&method=getMeInfo&type=home';
        ld("#status").show();
        WordReportAjax(urlstring, function (rest) {
            ld("#status").hide();
            if (empty(rest)) return false;
            var report = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
            var listhtml = '', imagenameStr = '';
            userimage = 'images/defaultuser.png';
            if (!empty(report.userinfo.imagename)) {
                userimage = 'http://' + loginurl + '/' + report.userinfo.imagename;
            }
            imagenameStr = '<img tag="userimage" src="' + userimage + '" onload="logicHanderObj.loadimg(this)">';
            var userlevelinfo = report.userinfo.profilename;
            if (report.userinfo.userlevel != '') {
                userlevelinfo += ' - ' + report.userinfo.userlevel;
            }

            var hrefStr = '', kefuphoneStr = '';
            if (phoneversion == 'ios') {
                hrefStr = 'href="tel:' + mobileOnline + '"';
            } else {
                hrefStr = "onclick=androidObj.callPhone('" + mobileOnline + "');";
            }
            kefuphoneStr = '<a ' + hrefStr + ' class="c-call">' + mobileOnline + '</a>';
            scope.phone_mobile = report.userinfo.phone_mobile;
            listhtml += '<div class="me-user"><div id="image_new_home" class="picture-preview">' +
                imagenameStr + '</div>' + '<div class="info" tag="edit_medetail"><h3>' +
                report.userinfo.last_name + '</h3><p>' + userlevelinfo + '</p><i class="lnr-chevron-right"></i></div></div>' +
                '<ul class="me-homelists">' +
                '   <li tag="crmset">' +
                '       <i><img src="images/setting_setting.png"/></i><span>模块设置<i class="lnr-chevron-right"></i></span>' +
                '   </li>' +
                '   <li tag="remindsset">' +
                '       <i><img src="images/setting_remind.png"/></i><span>提醒设置<i class="lnr-chevron-right"></i></span>' +
                '   </li>' +
                '</ul>' +
                '<ul class="me-homelists">';
            if (report.userinfo.telephone_view == 1) {
                listhtml += '<li tag="adressbook">' +
                    '   <i><img src="images/setting_address.png"/></i><span>通讯录<i class="lnr-chevron-right"></i></span>' +
                    '</li>';
            }
            listhtml += '   <li tag="feedback">' +
                '       <i><img src="images/setting_feedback.png"/></i><span>意见反馈<i class="lnr-chevron-right"></i></span>' +
                '   </li>' +
                '</ul>' +
                '<ul class="me-homelists">' +
                /*
                '   <li tag="kefuqq">'+
                '      <i><img src="images/my_setting.png"></i><span>客服企业QQ<p>2456586517</p></span>'+
                '   </li>'+
                */
                '   <li tag="kefuphone">' +
                '      <i><img src="images/setting_customertel.png"/></i><span>客服电话<i class="lnr-chevron-right"></i><p>' + kefuphoneStr + '</p></span>' +
                '   </li>' +
                '</ul>' +
                '<ul class="me-homelists">' +
                '  <li tag="sysset">' +
                '      <i><img src="images/setting_system.png"/></i><span>系统设置<i class="lnr-chevron-right"></i></span>' +
                '  </li>' +
                '</ul>';
            ld('#me-main-view').html(listhtml);
            ViewObj.onSwitchAfter(opts_obj);
        });
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = targetobj.parents('li[tag]');
        if (_this.length === 1 ||
            targetobj[0].tagName.toLowerCase() === 'li') {
            _this = _this.length ? _this : targetobj;
            switch (_this.attr('tag')) {
                case 'crmset':
                case 'remindsset':
                    ViewObj.switchView('all-userinfo-view', 'init', {
                        view_name: _this.attr('tag')
                    });
                    break;
                case 'adressbook':
                    ViewObj.switchView('me-adressbook-view', 'init', {});
                    break;
                case 'aboutus':
                    ViewObj.switchView('cwn-lookup-view', 'init', {
                        view_name: 'me_aboutus',
                        __app_header: ['<', '', '', '关于我们', '', ''],
                        __init_delay: 'none'
                    })
                    break;
                case 'feedback':
                    ViewObj.switchView('me-feedback-view', 'init', {
                        phone_mobile: scope.phone_mobile,
                        __footer_id: 'me-feedback-footer'
                    });
                    break;
                case 'sysset':
                    ViewObj.switchView('me-setting-view', 'init', {
                        __app_header: ['<', '', '', '系统设置', '', ''],
                        __init_delay: 0
                    });
                    break;
            }
            // 点击进入修改设置、资料页
        } else if (targetobj.parents('.me-user').length === 1 ||
            targetobj.attr('class') === 'me-user') {
            ViewObj.switchView('all-userinfo-view', 'init', {
                view_name: 'edit_medetail'
            });
        }
    };
};
// 定义跳转me-adressbook-view(通讯录)的方法  及click处理定义
ViewObj['create-me-adressbook-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '通讯录', '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '通讯录', '', ''], opts_obj);
        ListSearchBox.display({
            parent_obj: ld('#me-adressbook-view>.top-wrapper'),
            value_text: '',
            tip_text: '请输入姓名',
            searchFun: function (searchstr, callback) {
                var item_num = 0,
                    searchstrValue = searchstr.toLowerCase();
                ld('#me-adressbook-view .no-before li').each(function (index, el) {
                    var _this = ld(this),
                        eachValue = _this.find('i').html().toLowerCase();
                    if (eachValue.indexOf(searchstrValue) > -1) {
                        item_num++;
                        if (item_num === 1) {
                            ld('#me-adressbook-view .tip').remove();
                        }
                        _this.show();
                    } else {
                        _this.hide();
                    }
                });
                if (!item_num) {
                    ld('#me-adressbook-view .tip').remove();
                    ld('#me-adressbook-view .content-wrapper ')
                        .append('<div class="tip">暂无数据</div>');
                }
                callback();
            }
        });
        var urlstring = 'module=Home&action=ListView&method=getGroupUsers' +
            '&return_module=adressbook&searchtype=all&filterown=no' +
            '&scopetype=groupuser&common=0&isactive=no&searchcontent=';
        WordReportAjax(urlstring, function (rest) {
            if (rest == '') return false;
            var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
            var userhtml = '';
            if (restobj.Colleague == '') {
                userhtml = '<div class="tip">暂无数据</div>';
            }
            else {
                ViewObj.rootScope.temp_res = restobj.Department;//部门
                ViewObj.rootScope.current_level = 0;
                ViewObj.rootScope.getDepViewOpts = function () {
                    return {
                        viewid: 'temp-' + ViewObj.rootScope.current_level + '-view',
                        refreshable: false,
                        app_header: ['<', '', '', '公司部门', '', ''],
                        headerLeftBt: function () {
                            if (ViewObj.rootScope.current_level >= 1) {
                                ViewObj.rootScope.current_level -= 1;
                            }
                        },
                        initFun: function (opts_obj) {
                            var html_str = '',
                                name_str = '',
                                temp_res = ViewObj.rootScope.temp_res,
                                phonedisplay = '',
                                current_key = opts_obj.current_key ? parseInt(opts_obj.current_key) : -1,
                                temp_user = opts_obj.current_key ? temp_res[opts_obj.current_key].users : null,
                                relmobile = /^1\d{10}$/,
                                relhome = /^((\d{3})|((\d{3})-)|(\d{4})|((\d{4})-))?(\d{7,8})$/,
                                parentid = -1,
                                flag = true,
                                flag_dep = false,
                                item_allnum = 0;

                            ld('#' + ViewObj.getCurrentViewId()).html('<div class="top-wrapper"></div>');
                            // 构造部门
                            if (typeof opts_obj.has_subdep === 'undefined' ||
                                opts_obj.has_subdep === true) {
                                if (current_key != -1) {
                                    html_str += '<div class="liststit">部门</div>';
                                }
                                html_str += '<div class="department">';
                                html_str += '<ul class="listimg listimg-one square-img">';
                                flag = false;

                                for (var key in temp_res) {
                                    if (parseInt(temp_res[key].depth) === ViewObj.rootScope.current_level) {
                                        name_str = temp_res[key].groupname;
                                        flag_dep = false;
                                        for (var key_i in temp_res) {
                                            // 有下级部门
                                            if (parseInt(temp_res[key_i].parentid) === parseInt(key)) {
                                                flag_dep = true;
                                                break;
                                            }
                                        }
                                        if (parseInt(temp_res[key].parentid) === current_key) {
                                            item_allnum++;
                                            if (flag_dep) {
                                                html_str += '<li class="arrow-right" key="' + key + '" ><img src="images/defaultgroups.png">' +
                                                    '<span class="center text-ellipsis"><i style="padding-top: 0px;">' + name_str + '</i></span>' +
                                                    '<i class="lnr-chevron-right"></i></li>';

                                            } else {
                                                html_str += '<li key="' + key + '" ><img src="images/defaultgroups.png">' +
                                                    '<span class="center text-ellipsis"><i style="padding-top: 0px;">' + name_str + '</i></span></li>';
                                            }
                                        }
                                    }
                                }
                                html_str += '</ul></div>';
                            }
                            // 构造成员
                            if (ld.isArray(temp_user) && temp_user.length) {
                                html_str += '<div class="liststit">同事</div>';
                                html_str += '<div class="uers">';
                                html_str += '<ul class="listimg no-before">';
                                flag = false;
                                var infohtml = '';
                                ld.each(temp_user, function (index, node) {
                                    phonedisplay = 'visi-hide';
                                    if ((relmobile.test(node.phone_mobile.value)) ||
                                        (relhome.test(node.phone_home.value))) {
                                        phonedisplay = '';
                                    }
                                    if (node.profilename.value != '' && node.userlevel.value != '') {
                                        infohtml = node.profilename.value + '-' + node.userlevel.value;
                                    } else if (node.profilename.value != '') {
                                        infohtml = node.profilename.value;
                                    } else if (node.userlevel.value != '') {
                                        infohtml = node.userlevel.value;
                                    }
                                    item_allnum++;
                                    html_str += '<li class="usersfirst" id="userid' +
                                        node.userid.value + '"><div><img src="http://' + loginurl + '/' + node.userimgpath.value +
                                        '" onload="logicHanderObj.loadimg(this)"/></div>' +
                                        '<span class="center text-ellipsis"><i>' + node.lastname.value + '</i>' +
                                        infohtml + '</span><a tag="call" class="right lnr-phone-handset ' + phonedisplay +
                                        '" phonemobile="' + node.phone_mobile.value + '&&' + node.phone_home.value + '"></a></li>';
                                });
                                html_str += '</ul></div>';
                            }
                            // 当又8条数据时，就显示搜索框
                            if (item_allnum >= 8) {
                                ListSearchBox.display({
                                    parent_obj: ld('#' + ViewObj.getCurrentViewId() + ' .top-wrapper'),
                                    value_text: '',
                                    tip_text: '请输入部门名称或者姓名',
                                    searchFun: function (searchstr, callback) {
                                        var item_num = 0,
                                            text_str = '',
                                            c_vid = ViewObj.getCurrentViewId(),
                                            department = ld('#' + c_vid + ' .department'),
                                            uers = ld('#' + c_vid + ' .uers');
                                        ld('#' + ViewObj.getCurrentViewId() + ' li').each(function (index, el) {

                                            text_str = ld(this).parents('.department').length ?
                                                ld(this).text() : ld(this).find('i').text();
                                            if (text_str.indexOf(searchstr) > -1) {
                                                item_num++;
                                                if (item_num === 1) {
                                                    ld('#' + c_vid + ' .tip').remove();
                                                }
                                                ld(this).show();
                                            } else {
                                                ld(this).hide();
                                            }
                                        });
                                        ld('#' + c_vid + ' .tip').remove();
                                        if (!department.find('li:visible').length) {
                                            department.prepend('<div class="tip">暂无数据</div>');
                                        }
                                        if (!uers.find('li:visible').length) {
                                            uers.prepend('<div class="tip">暂无数据</div>');
                                        }
                                    }
                                });
                            }
                            // 当没有一条数据时
                            if (flag) {
                                html_str += '<div class="tip">该部门没有成员</div>';
                            }
                            ld('#' + ViewObj.getCurrentViewId()).append(html_str);
                            ViewObj.onSwitchAfter(opts_obj);
                        },
                        bodyClick: function (targetobj) {
                            var _this = targetobj.parents('li');
                            if (_this.length === 1 ||
                                targetobj[0].tagName.toLowerCase() === 'li') {
                                _this = _this.length ? _this : targetobj;
                                //点击部门
                                if (_this.attr('key')) {
                                    ViewObj.rootScope.current_level += 1;
                                    var viewid = 'temp-' + ViewObj.rootScope.current_level + '-view';

                                    ViewObj.createView(ViewObj.rootScope.getDepViewOpts());
                                    ViewObj.switchView(viewid, 'init', {
                                        __app_header: ['<', '', '', _this.text(), '', ''],
                                        current_key: _this.attr('key'),
                                        has_subdep: _this.hasClass('arrow-right')
                                    });
                                    //点击同事
                                } else {
                                    /*
                                    这里先隐藏，不要删除，以后还要用
                                    var nameStr = _this.find('span:first').html(),
                                        user_nameStr = '<i>'+_this.find('span:first').find('i').html()+'</i>',
                                        phonemobileArr = _this.find('a').attr('phonemobile').split('&&'); 
                                    ViewObj.switchView('cwn-lookup-view','init',{
                                        view_name : 'me_adressbook_userinfo',
                                        'adressbookuserids' : _this.attr('id').replace("userid", ""),
                                        'imgsrc' : _this.find('img').attr('src'),
                                        'last_name' : _this.find('span:first').find('i').html(),
                                        'profilename' : nameStr.replace(user_nameStr,''),                    
                                        'mobilephone' : phonemobileArr[0],
                                        'telephone' : phonemobileArr[1],
                                        __app_header : ['<','','','个人信息','','']
                                    });
                                    */
                                }
                            }
                        }
                    }
                };

                userhtml += '<ul class="listimg listimg-one square-img">' +
                    '<li class="adressbookfirst" key="0" tag="department">' +
                    '<img src="images/defaultgroups.png">' +
                    '<span class="center text-ellipsis"><i style="padding-top: 0px;">公司部门</i></span>' +
                    '<i class="lnr-chevron-right"></i>' +
                    '</li>' +
                    '<li class="adressbookfirst ui-hide" tag="collection">' +
                    '<img src="images/ico_collect.png">' +
                    '<span class="center text-ellipsis"><i>个人收藏夹</i></span>' +
                    '<i class="lnr-chevron-right"></i>' +
                    '</li></ul>';
                userhtml += '<ul class="listimg no-before">';
                var infohtml = '';
                ld.each(restobj.Colleague, function (userkey, userobj) {
                    if (!userobj.lastname.value) userobj.lastname.value = '--';
                    if(userobj.userlevel == undefined){
                        infohtml = userobj.description.value;
                    }
                    else{
                        if (userobj.profilename.value != '' && userobj.userlevel.value != '') {
                            infohtml = userobj.profilename.value + '-' + userobj.userlevel.value;
                        } else if (userobj.profilename.value != '') {
                            infohtml = userobj.profilename.value;
                        } else if (userobj.userlevel.value != '') {
                            infohtml = userobj.userlevel.value;
                        }
                    }
                    var phonedisplay = 'visi-hide';
                    var relmobile = /^1\d{10}$/;
                    var relhome = /^((\d{3})|((\d{3})-)|(\d{4})|((\d{4})-))?(\d{7,8})$/;
                    if ((relmobile.test(userobj.phone_mobile.value)) ||
                        (relhome.test(userobj.phone_home.value))) {
                        phonedisplay = '';
                    }
                    userhtml += '<li class="usersfirst" id="userid' + userobj.userid.value + '"><div><img src="http://' + loginurl + '/' +
                        userobj.userimgpath.value + '" onload="logicHanderObj.loadimg(this)"/></div><span class="center text-ellipsis"><i>' +
                        userobj.lastname.value + '</i>' + infohtml +
                        '</span><a tag="call" class="right lnr-phone-handset ' + phonedisplay + '" phonemobile="' +
                        userobj.phone_mobile.value + '&&' + userobj.phone_home.value +
                        '"></a></li>';
                });
                userhtml += '</ul>';
            }
            ld('#me-adressbook-view>.content-wrapper').html(userhtml);
            ViewObj.onSwitchAfter(opts_obj);
        });
    }
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 头部左边
        if (t_id === 'head_left') {
            ViewObj.switchView('me-main-view', 'back');
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = targetobj.parents('li.adressbookfirst');
        if (_this.length === 1 ||
            targetobj.hasClass('adressbookfirst')) {
            _this = _this.length ? _this : targetobj;
            var tagStr = _this.attr('tag');
            if (tagStr === 'department') {//部门
                ViewObj.createView(ViewObj.rootScope.getDepViewOpts());
                ViewObj.switchView('temp-0-view', 'init');
            } else if (tagStr === 'collection') {//收藏
                ViewObj.switchView('cwn-popuselect-view', 'init', {
                    view_name: 'me_telphonelist'
                });
            }
        }
        else {
            /*
            这里先隐藏，不要删除，以后还要用
            _this=targetobj.parents('li.usersfirst');
            if(_this.length===1 || 
                targetobj.hasClass('usersfirst')){
                _this=targetobj.parents('li.usersfirst');
                _this = _this.length ? _this : targetobj;
                var nameStr = _this.find('span:first').html(),
                    user_nameStr = '<i>'+_this.find('span:first').find('i').html()+'</i>',
                    phonemobileArr = _this.find('a').attr('phonemobile').split('&&');
                ViewObj.switchView('cwn-lookup-view','init',{
                    view_name : 'me_adressbook_userinfo',
                    'adressbookuserids' : _this.attr('id').replace("userid", ""),
                    'imgsrc' : _this.find('img').attr('src'),
                    'last_name' : _this.find('span:first').find('i').html(),
                    'profilename' : nameStr.replace(user_nameStr,''),                    
                    'mobilephone' : phonemobileArr[0],
                    'telephone' : phonemobileArr[1],
                    __app_header : ['<','','','个人信息','','']
                });
            }
            */
        }
    };
};
// 定义跳转me-setting-view(设置)的方法  及click处理定义
ViewObj['create-me-setting-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '系统设置', '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '系统设置', '', ''], opts_obj);
        ld('#me-setting-view .logo-ver').find('p').html(mobileProductName + ' &nbsp;&nbsp; ' + mobileProductVersion);
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        if (t_id === 'head_left') {// 头部左边
            ViewObj.switchView('me-main-view', 'back');//跳转到crm新增编辑页面        
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = targetobj.parents('li[tag]');
        if (_this.length === 1 ||
            targetobj[0].tagName.toLowerCase() === 'li') {
            _this = _this.length ? _this : targetobj;
            switch (_this.attr('tag')) {
                case 'aboutus':
                    var aboutinfo = '<div class="roll-a">' +
                        '<p>产品名称：' + mobileProductName + '<br/>版本号：' + mobileProductVersion + ' (' + mobileDate + ')</p>' +
                        '<p>开发者：' + mobileCompany + '<br/>Copyright 2008-' + new Date().getFullYear() + '</p>' +
                        '<p>服务电话：' + mobileOnline + '</p>' +
                        '</div>';
                    PopPromptBox.show({
                        head_text: '关于',
                        main_text: aboutinfo
                    });
                    break;
                case 'contactusus':
                    var href = '';
                    if (phoneversion == 'ios') {
                        href = 'href="tel:' + mobileOnline + '"';
                    } else {
                        href = "onclick=androidObj.callPhone('" + mobileOnline + "');";
                    }
                    ld('#callHotline .btnsub').html('<a ' + href + ' class="c-call">咨询热线：' + mobileOnline + '</a>');
                    ld('#layerMask').css('display', 'block');
                    ld('#callHotline').removeClass('ui-hide');
                    break;
                case 'cache':
                    meHandleObj.cachelocalStorage();//清除缓存
                    logicHanderObj.syssetremind('清除缓存成功');
                    break;
            }
            // 点击退出按钮
        } else if (targetobj.attr('class') === 'me-exit') {
            PopPromptBox.show({
                main_text: '您确定退出吗？',
                btn_type: 'yesno',
                yes_str: '确定',
                no_str: '取消',
                yes_fun: function () {
                    var urlstring = 'module=Users&action=Logout';
                    WordReportAjax(urlstring, function (rest) {
                        if (phoneversion == 'ios') {
                            cacheData('d4', 'no');
                            cacheData('e5', 'yes');
                            try {
                                window.echo = cordova.exec(
                                    function (okParam) {
                                        //alert('okParam' + okParam);
                                    },
                                    function (error) {
                                        //alert('error' + error);
                                    }, 'CDVDevice', 'LoginOut', []);
                            } catch (e) {
                                //alert('error:' + e.message);
                            }
                        } else if (phoneversion == 'android') {
                            javatojs.LoginOut();
                        } else {
                            var url = 'http://' + loginurl + '/app/login.html?a1=' + enterprisename + '&b2=' +
                                individualname + '&c3=' + loginpwd + '&d4=no&e5=yes';
                            window.top.location.href = url;
                        }
                    });
                }
            });
        }
    };
};
// 定义跳转me-feedback-view(me反馈页面)的方法  及click处理定义
ViewObj['create-me-feedback-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '意见反馈', '', '历史'], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '意见反馈', '', '历史'], opts_obj);
        // var feedbackcreate = '<textarea class="fb-text" style="line-height:1.2rem;" ' +
        //     'id="feedBackContent" name="feedBackContent" placeholder="请输入您的反馈内容（字数300字以内）" ' +
        //     'autofocus="autofocus"></textarea>';
        var feedbackcreate = '<textarea class="fb-text" id="feedBackContent" name="feedBackContent" placeholder="请输入您的反馈内容（字数300字以内）" data-autosize-on="true" style="overflow: hidden; overflow-wrap: break-word; height: 10rem;"></textarea>';
        ld('#me-feedback-view div:first').html(feedbackcreate);
        ld('#me-feedback-view .contact-cell span').html(opts_obj.phone_mobile);
        ld('#feedBackContent').val('');
        autosize(ld('#me-feedback-view textarea'));
        logicHanderObj.getFocus('feedBackContent');//获取焦点  
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        if (t_id === 'head_left') {// 头部左边
            ViewObj.switchView('me-main-view', 'back');//跳转到crm新增编辑页面        
            // 头部右边
        } else if (t_id === 'head_rig') {
            ViewObj.switchView('cwn-popuselect-view', 'init', {
                __refreshable: false,
                title_str: '反馈历史',
                select_mode: 'single',
                show_search: false,
                choose_style: '',
                auto_back: false,
                multi_autotoggle: false,
                initFun: function (callback) {
                    var urlstring = 'module=FeedBack&action=index&enterprise=' + enterprisename;
                    WordReportAjax(urlstring, function (rest) {
                        if (rest == '') return false;
                        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                        // 构造字符串
                        var html_str = '<ul class="crm-lists fb">',
                            list_res = restobj.result.list;
                        ld.each(list_res, function (key, msg_obj) {
                            var f_class = '';
                            if(msg_obj.status == '已处理'){
                                f_class = 'f_on';
                            }
                            html_str += '<li class="r-cell" id="' + msg_obj.id + '">' + 
                                            '<h5>' + msg_obj.content + '</h5>' + 
                                            '<p><span>' + msg_obj.createdate + '</span><a class="list-btn '+ f_class +'">' + msg_obj.status + '</a></p>' + 
                                        '</li>';
                        });
                        html_str += '</ul>';
                        if (empty(list_res)) {
                            html_str = logicHanderObj.NoinfoNotice('反馈历史');
                        }
                        ld('#cwn-popuselect-view>.content-wrapper').html(html_str);
                        callback();
                    });
                },
                itemFun: function (target_item, related_obj) {
                    ViewObj.switchView('cwn-lookup-view', 'init', {
                        __app_header: ['<', '', '', '反馈详情', '', ''],
                        view_name: 'me_feedback_detail',
                        feedback_id: target_item.attr('id')
                    });
                },
                headerRigBtFun: function (related_obj) {
                }
            });
        }
    };
    // 底部点击操作
    ViewObj[to_viewid + '-footer-click'] = function (targetobj, clickOpts) {
        if(ViewObj.rootScope.feedsavestatus != 'yes'){
            ViewObj.rootScope.feedsavestatus = 'yes';
            var input_str = ld('#feedBackContent').val(),
                phone = ld('#me-feedback-view .contact-cell span').html(),
                urlstring = 'module=FeedBack&action=Save&content=' + input_str +'&dns=' + loginurl + '&enterprise=' + enterprisename + '&username=&phone=' + phone;
            if (input_str === '') {
                return;
            }
            WordReportAjax(urlstring, function (rest) {
                if (empty(rest)) return false;
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                if (restobj.code == '1') {//code:---1成功，-1：错误
                    ViewObj.rootScope.feedsavestatus = 'no';
                    logicHanderObj.syssetremind(restobj.result.success);//成功提示
                    setTimeout(function () {
                        ViewObj.switchView('me-main-view', 'back', {
                            __scroll_top: 'origin'
                        });
                    }, 300);
                } else {
                    ViewObj.rootScope.feedsavestatus = 'no';
                    logicHanderObj.syssetremind(restobj.msg);
                }
            });
            return false;
        }
    };
};
document.addEventListener('touchmove', function (e) {
    e.preventDefault();
}, false);
document.addEventListener('DOMContentLoaded', function () {
    ld(document).ready(function () {
        meHandleObj.meInit();
    });
}, false);
//节点加载事件，在onload之前
ld(function () {
    // 判断当前浏览器是否支持indexOf、remove事件，不支持则添加
    if (typeof Array.indexOf !== 'function') {//数组包含
        Array.prototype.indexOf = function (args) {
            var index = -1;
            for (var i = 0, l = this.length; i < l; i++) {
                if (this[i] === args) {
                    index = i;
                    break;
                }
            }
            return index;
        }
    }
    String.prototype.len = function () {// 给string增加个len ()方法，计算string的字节数
        return this.replace(/[^\x00-\xff]/g, "xx").length;
    }
    autosize(ld('textarea'));//textarea根据内容自动调整大小
});
//ME加载
meHandleObj.meInit = function () {
    FastClick.attach(document.body); // 减少手机端 点击事件延迟
    SwiperObj.setSwiperSzie();       // 设置当前全局滚动适应屏幕大小
    category = 'me';
    getJsScript('js/me.js', function () {
        ViewObj.switchView('me-main-view', 'init');
    });
}
//保存CRM设置
meHandleObj.saveModuleSet = function (moudleset, userid) {
    var urlstring = 'module=Home&action=ListView&method=savemoduleset&modulename=' + moudleset;
    WordReportAjax(urlstring, function (rest) {
    });
}
//保存提醒设置
meHandleObj.saveRemindSet = function (remindset, openstatus, userid) {
    var urlstring = 'module=Home&action=ListView&method=saveRemindSet' +
        '&remindset=' + remindset + '&openstatus=' + openstatus;
    WordReportAjax(urlstring, function (rest) {
    });
}
//清除缓存
meHandleObj.cachelocalStorage = function () {
    var cache_obj = [];
    //仪表盘，周月统计
    cache_obj[0] = 'd_cache_ws_lable';
    cache_obj[1] = 'd_cache_ws_view';
    cache_obj[2] = 'd_cache_ws_name';
    cache_obj[3] = 'd_cache_ws_time';
    //仪表盘，销售漏斗
    cache_obj[4] = 'd_cache_sf_lable';
    cache_obj[5] = 'd_cache_sf_view';
    cache_obj[6] = 'd_cache_sf_name';
    cache_obj[7] = 'd_cache_sf_time';
    //仪表盘，签约额度同比
    cache_obj[8] = 'd_cache_ct_lable';
    cache_obj[9] = 'd_cache_ct_view';
    cache_obj[10] = 'd_cache_ct_name';
    //仪表盘，最近6个月销售情况
    cache_obj[11] = 'd_cache_ss_lable';
    cache_obj[12] = 'd_cache_ss_view';
    cache_obj[13] = 'd_cache_ss_name';
    //仪表盘，回款额月度同比
    cache_obj[14] = 'd_cache_ra_lable';
    cache_obj[15] = 'd_cache_ra_view';
    cache_obj[16] = 'd_cache_ra_name';

    //仪表盘，签约数量龙虎榜
    cache_obj[17] = 'd_cache_sn_lable';
    cache_obj[18] = 'd_cache_sn_view';
    cache_obj[19] = 'd_cache_sn_name';
    cache_obj[20] = 'd_cache_sn_status';
    //仪表盘，签约金额龙虎榜
    cache_obj[21] = 'd_cache_sa_lable';
    cache_obj[22] = 'd_cache_sa_view';
    cache_obj[23] = 'd_cache_sa_name';
    cache_obj[24] = 'd_cache_sa_status';
    //仪表盘，回款金额龙虎榜
    cache_obj[25] = 'd_cache_pa_lable';
    cache_obj[26] = 'd_cache_pa_view';
    cache_obj[27] = 'd_cache_pa_name';
    //仪表盘，费用佣金统计表
    cache_obj[28] = 'd_cache_ca_lable';
    cache_obj[29] = 'd_cache_ca_view';
    cache_obj[30] = 'd_cache_ca_name';
    cache_obj[31] = 'd_cache_ca_status';
    //仪表盘，日志统计表
    cache_obj[32] = 'd_cache_dl_lable';
    cache_obj[33] = 'd_cache_dl_view';
    cache_obj[34] = 'd_cache_dl_name';
    //仪表盘，周计划统计表
    cache_obj[35] = 'd_cache_wl_lable';
    cache_obj[36] = 'd_cache_wl_view';
    cache_obj[37] = 'd_cache_wl_name';
    //仪表盘，月计划统计表
    cache_obj[38] = 'd_cache_ml_lable';
    cache_obj[39] = 'd_cache_ml_view';
    cache_obj[40] = 'd_cache_ml_name';

    //工作，搜索
    cache_obj[41] = 'work_search_content';
    ld.each(cache_obj, function (key, id) {
        CacheObj.del(id);
    });
    //window.localStorage.normalLogin = 'false';
}