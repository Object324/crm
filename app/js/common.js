/**************** Swiper 3.0  start***************************/
document.body.addEventListener('touchstart', function () {
}, false);
//全局方法对象
var commonHandleObj = {};
var newsObj = {};
// 滚动对象
var SwiperObj = {
    more_range: 30,        // 加载更多 范围 设置（拖动底部多远时可以触发加载）根据实际调试
    refresh_range: 30,     // 加载更多 范围 设置（拖动定部多远时可以触发刷新）根据实际调试
    more_loading: false,   // 是否正处于 加载（正处于加载时，不能再加载或者刷新，刷新完毕变为false）
    view_refreshing: false,// 是否正处于 刷新（正处于加载时，不能再加载或者刷新，刷新完毕变为false）

    // 标记变量 是否 可以刷新（拖离页面顶部超过设定的范围，变为true，刷新完毕变为false）
    is_refreshPage: false,

    // 标记变量 是否 可以加载（拖离页面底部超过设定的范围，变为true，加载完毕变为false）
    is_addMore: false,
    is_currentViewRefreshable: false,  // 当前页面是否可刷新
    PHONE_HEIGHT: window.innerHeight,  // 屏幕高度
    PHONE_WIDTH: window.innerWidth,    // 屏幕宽度
    CONTENT_HEIGHT: 0,                 // 显示内容高度（除去头部高度）
    SWIPER_HOLDER: ld('#home-page'), // 全局swiper滚动dom的JQ对象  
    // 设置全局滚动的高度宽度适应屏幕大小
    setSwiperSzie: function () {
        //设置显示内容高度（除去头部高度）
        SwiperObj.CONTENT_HEIGHT = SwiperObj.PHONE_HEIGHT - ld('header').get(0).offsetHeight;
        SwiperObj.SWIPER_HOLDER.css({  // 设置 滚动页 显示高度
            'width': SwiperObj.PHONE_WIDTH + 'px',
            'height': SwiperObj.CONTENT_HEIGHT + 'px'
        });
        ld('body').css({        // 设置 页面 填充屏幕
            'width': SwiperObj.PHONE_WIDTH + 'px',
            'height': SwiperObj.PHONE_HEIGHT + 'px',
            'overflow': 'hidden'
        });
        ld('header,footer').on('touchmove', function (event) { // 禁止 页面 头部 尾部滑动
            var e = event || window.event;
            e.preventDefault();
            e.stopPropagation();
            return false;
        });
        // 监视发布页面变化重新设置高度
        ld('#work-release-view,#wn-replayforword-view,#crm-createedit-view,' +
            '#cwn-popuedit-view,#me-feedback-view').resize(function () {

            SwiperObj.autoHeight(-1);
        });
        // 设置底部调整 
        ld('#adjust-bottom-holder').height('50px');
    },
    // 检查当前页面是否能刷新（含有refreshable类表示，可刷新）
    // 返回 true/false 
    isCurrentViewRefreshable: function () {
        var _reslut = ld('#' + ViewObj.getCurrentViewId()).hasClass('refreshable');
        SwiperObj.SWIPER_HOLDER.height(SwiperObj.CONTENT_HEIGHT + 'px');
        if (_reslut) {//需要刷新            
            ld('#list-addmore-holder').removeClass('ui-hide');//将显示内容高度设置为原始高度
        } else {
            ld('#list-addmore-holder').addClass('ui-hide');
        }
        SwiperObj.is_currentViewRefreshable = _reslut;
        return _reslut;
    },
    // 检查当前页面是否能够滚动(含有 noscoll 类，表示不能滚动)
    // 返回 true/false
    isCurrentViewScrollable: function () {
        var c_viweId = ViewObj.getCurrentViewId(),
            _reslut = !ld('#' + c_viweId).hasClass('noscoll');
        if (_reslut) { // 需要滚动
            SwiperObj.autoHiddenAddMore();
            if (ld('#lineheadstatus').is(':hidden')) {
                SwiperObj.homePage_swiper.unlockSwipes(); // 解除禁止滚动
            }
        } else {
            ld('.list-addmore-label').html('');
            SwiperObj.homePage_swiper.lockSwipes(); // 禁止滚动
            ld('#' + c_viweId + ',#home-page').height(SwiperObj.CONTENT_HEIGHT);
        }
        return _reslut;
    },
    // 列表内容不满一页的时候隐藏“更多”
    autoHiddenAddMore: function () {
        var compare = ld('#' + ViewObj.getCurrentViewId()).height() +
            ld('#adjust-bottom-holder').height() -
            SwiperObj.homePage_swiper.height;
        if (compare < 0) {
            ld('.list-addmore-label').html('');
        } else {
            ld('.list-addmore-label').html('更多...');
        }
        return this;
    },
    // 重新设定滚动对象高度(当页面内容发生变化时)
    /* 参数：
     which_swiper 哪一个滚动对象,默认全局 页面滚动
     translate(高度设定后，滚动条距离顶部的长度) 为-1时，不需要修改。（只变化高度，滚动条位置不变）
     */
    autoHeight: function (translate, which_swiper) {
        var s = which_swiper instanceof Swiper ? which_swiper : SwiperObj.homePage_swiper;
        var t = typeof translate === 'number' ? translate : -1;
        if (t !== -1) {
            s.setWrapperTranslate(translate);//设置滚动条位置
        }
        if (typeof s.onResize === 'function') {
            s.onResize();//更新高度 ，单次执行的时，滚动条消失
            s.onResize();//更新高度 ，执行两次后，显示滚动条
        }
        return this;
    },
    // 判断滚动对象 是否能销毁
    isDestroyable: function (swiper_obj) {
        var _reslut = false;
        if (swiper_obj instanceof Swiper &&
            typeof swiper_obj.destroy === 'function') {
            _reslut = true;
        }
        return _reslut;
    },
    // 所有可刷新列表 分别对应一个 1.页数 2.下一页参数
    // 列表 页数对象
    ListPageObj: (function () {
        var refreshable_views = {};
        // 动态获取可刷新页面
        ld('#home-page .swiper-slide.refreshable').each(function (index, el) {
            refreshable_views[el.id] = {
                page_index: 1,
                has_nextPage: 'no'
            }
        });

        return {
            // 动态设置一个页面为刷新页面
            addRefreshableView: function (viewId) {
                var obj = ld('#' + viewId);
                if (!obj.length) return;
                obj.addClass('refreshable')
                refreshable_views[viewId] = {
                    page_index: 1,
                    has_nextPage: 'no'
                }
            },
            // 动态设置一个页面为不可刷新页面
            removeRefreshableView: function (viewId) {
                var obj = ld('#' + viewId);
                if (!obj.length) return;
                obj.removeClass('refreshable');
                if (refreshable_views[viewId]) {
                    refreshable_views[viewId] = null;
                }
            },
            // 设置viewId当前为第几页 
            setListPageIndex: function (value, viewId) {
                if (typeof viewId === 'string' &&
                    refreshable_views[viewId]) {

                    refreshable_views[viewId].page_index = value;

                } else if (SwiperObj.is_currentViewRefreshable &&
                    typeof value === 'number') {
                    if (!refreshable_views[ViewObj.getCurrentViewId()]) return;
                    refreshable_views[ViewObj.getCurrentViewId()].page_index = value;
                }
            },
            // 获取viewId当前页数 
            getListPageIndex: function () {
                if (!refreshable_views[ViewObj.getCurrentViewId()]) return;
                if (SwiperObj.is_currentViewRefreshable) {
                    return refreshable_views[ViewObj.getCurrentViewId()].page_index;
                }
            },
            // 设置viewId是否有下一页 
            setHasNextPage: function (value, viewId) {
                if (typeof viewId === 'string' &&
                    refreshable_views[viewId]) {
                    refreshable_views[viewId].has_nextPage = value;
                } else if (SwiperObj.is_currentViewRefreshable &&
                    typeof value === 'number') {
                    if (!refreshable_views[ViewObj.getCurrentViewId()]) return;
                    refreshable_views[ViewObj.getCurrentViewId()].has_nextPage = value;
                }
            },
            // 获取viewId是否有下一页
            getHasNextPage: function () {
                if (!refreshable_views[ViewObj.getCurrentViewId()]) return;
                if (SwiperObj.is_currentViewRefreshable) {
                    return refreshable_views[ViewObj.getCurrentViewId()].has_nextPage;
                }
            }
        };
    })(),
    // 所有可刷新列表,刷新,加载功能
    homePage_swiper: new Swiper('.swiper-container-g', {
        scrollbar: '.swiper-scrollbar-g', //  全局滚动条
        direction: 'vertical', // 竖直滚动
        slidesPerView: 'auto', // 自动显示内容
        mousewheelControl: true, // 开启鼠标控制
        freeMode: true, // 开启自由滑动模式
        autoHeight: true, // 开启自适应高度
        freeModeMomentum: true,
        freeModeMomentumRatio: 0.7,
        resistance: true,//开启 页面拖离屏幕头部或者尾部 
        resistanceRatio: 0.8,//设置反抗力度 ，数字越小 反抗力度越大 （根据实际设置）
        onTouchMove: function (s) { // 开始结束
            // 在滑动时 取消所有的 焦点
            // 1.当前为可刷新页面 
            // 2.没有(正在)加载
            // 3.没有(正在)刷新时 同时满足 才执行    
            if (SwiperObj.is_currentViewRefreshable && !SwiperObj.more_loading && !SwiperObj.view_refreshing) {
                var wrapper_translate = s.getWrapperTranslate('y');
                if (wrapper_translate > 10) {//当处于头部时， 判断是否可以刷新
                    var compare_refresh = wrapper_translate - SwiperObj.refresh_range;//当前偏移量和刷新范围比较
                    if (compare_refresh <= 0) {//在范围内 标记不能刷新
                        ld('#list-refresh-holder').removeClass('ui-hide');
                        ld('.list-refresh-icon').attr('class', 'list-refresh-icon pull-down lnr-arrow-down');
                        ld('.list-refresh-label').html('下拉刷新');//还原 提示信息
                        SwiperObj.is_refreshPage = false;// 标记不能刷新
                    } else { // 超出了范围 标记可以刷新
                        SwiperObj.is_refreshPage = true;      //标记可以刷新 
                        ld('.list-refresh-icon').attr('class', 'list-refresh-icon pull-up lnr-arrow-down');
                        ld('.list-refresh-label').html('释放开始刷新');//修改 提示信息
                    }
                } else {
                    //页面全部展开总高度（屏幕高度无限高时）
                    var all_height = ld('#' + ViewObj.getCurrentViewId()).height() +
                            ld('#adjust-bottom-holder').height(),
                        veiw_height = s.height,//屏幕 显示（页面） 高度
                        offset_height = veiw_height - all_height;//划到底部时，隐藏 页面的高度（偏移量）
                    if (all_height > veiw_height) {//当处于尾部时，并且 显示超过一页
                        if (SwiperObj.ListPageObj.getHasNextPage() === 'yes') {//有下一页时
                            //当前偏移量和加载范围比较
                            var compare_more = wrapper_translate -
                                (offset_height - SwiperObj.more_range);
                            if (compare_more > 0) { //在范围内  
                                SwiperObj.is_addMore = false;//标记可以加载
                                ld('.list-addmore-label').html('更多...');//还原 提示信息
                            } else {              //超出了范围
                                SwiperObj.is_addMore = true; //标记可以加载
                                ld('.list-addmore-label').html('松开加载更多...');//修改 提示信息
                            }
                        } else {
                            ld('.list-addmore-label').html('');
                        }
                    }
                }
            }
        },
        onTouchEnd: function (s) { // 拉动结束
            //1.当前为可刷新页面 2.没有加载、3.没有刷新时 同时满足 才执行
            if (SwiperObj.is_currentViewRefreshable && !SwiperObj.more_loading && !SwiperObj.view_refreshing) {
                //可以开始刷新
                if (SwiperObj.is_refreshPage &&
                    NetworkObj.isOnline()) {
                    SwiperObj.view_refreshing = true;
                    ld('.list-refresh-icon').attr('class', 'list-refresh-icon pull-refreshing');
                    ld('.list-refresh-label').html('正在刷新...');
                    SwiperObj.ListPageObj.setListPageIndex(1);
                    setTimeout(function () {
                        EventHanderObj.refreshAjax(function () {//处理事件
                            ld('#list-refresh-holder').addClass('ui-hide');
                            ld('.list-refresh-icon').attr('class', 'list-refresh-icon');
                            ld('.list-refresh-label').html('下拉刷新');
                            SwiperObj.ListPageObj.setListPageIndex(1);
                            SwiperObj.autoHeight(0);//回到头部
                            SwiperObj.is_refreshPage = false;//标记不能刷新
                            SwiperObj.view_refreshing = false;//标记刷新完成
                        });
                    }, 100);
                    //可以开始加载更多            
                } else if (SwiperObj.is_addMore &&
                    NetworkObj.isOnline()) {
                    ld('#list-refresh-holder').addClass('ui-hide');
                    ld('.list-refresh-label').html('下拉刷新');

                    SwiperObj.more_loading = true;  //标记正在加载
                    ld('.list-addmore-label').html('加载中...');
                    ld('.list-addmore-icon ').removeClass('ui-hide');
                    var c_pageindex = SwiperObj.ListPageObj.getListPageIndex();
                    SwiperObj.ListPageObj.setListPageIndex(c_pageindex += 1);
                    setTimeout(function () {
                        EventHanderObj.refreshAjax(function () {
                            ld('.list-addmore-label').html('更多...');
                            ld('.list-addmore-icon').addClass('ui-hide');
                            SwiperObj.autoHeight(-1);  //滚动条保持原位
                            SwiperObj.is_addMore = false;//标记不能加载
                            SwiperObj.more_loading = false; //标记加载完成  
                        });
                    }, 100);

                } else {
                    if (!NetworkObj.isOnline()) {
                        NetworkObj.showNetworkTips('head_tip', 'show');
                        SwiperObj.is_addMore = false;
                        SwiperObj.more_loading = false;
                        SwiperObj.view_refreshing = false;
                        SwiperObj.is_refreshPage = false;
                        var addmore_str = ld('.list-addmore-label').html();
                        if (addmore_str && addmore_str.indexOf('.') > -1) {
                            addmore_str = '更多...';
                        } else {
                            addmore_str = '';
                        }
                        if (ld('#linecontentstatus').is('hidden')) {
                            ld('.list-addmore-label').html(addmore_str);
                            return;
                        }
                        ld('.list-addmore-label').html(addmore_str).addClass('ui-hide');
                    }
                    ld('#list-refresh-holder').addClass('ui-hide');
                    ld('.list-refresh-label').html('下拉刷新');
                }
            }
        },
        onTap: function (s, event) { // 点击加载更多
            var e = window.event || event,
                obj = e.target || e.srcElement,
                t = ld(obj);
            if (SwiperObj.is_currentViewRefreshable &&
                t.attr('class') === 'list-addmore-label' &&
                t.html().indexOf('更多.') > -1 &&
                NetworkObj.isOnline() &&
                SwiperObj.ListPageObj.getHasNextPage() === 'yes') {

                SwiperObj.is_addMore = true;      //标记可以加载
                SwiperObj.more_loading = true;  //标记正在加载
                ld('.list-addmore-label').html('加载中...');
                ld('.list-addmore-icon ').removeClass('ui-hide');
                var c_pageindex = SwiperObj.ListPageObj.getListPageIndex();
                SwiperObj.ListPageObj.setListPageIndex(c_pageindex += 1);
                EventHanderObj.refreshAjax(function () {
                    ld('.list-addmore-label').html('更多...');
                    ld('.list-addmore-icon').addClass('ui-hide');
                    SwiperObj.autoHeight(-1);//滚动条保持原位
                    SwiperObj.is_addMore = false;//标记不能加载
                    SwiperObj.more_loading = false; //标记加载完成  
                });
            } else {
                if (!NetworkObj.isOnline()) {
                    NetworkObj.showNetworkTips('head_tip', 'show');
                    SwiperObj.more_loading = false;
                    SwiperObj.is_addMore = false;
                }
            }
        }
    })
};

// 全局网络对象 
var NetworkObj = (function () {
    // 网络状态
    var newtwork_status = {
            is_online: true, // 是否链接网络
            is_poor_network: false // 是否网络差
        },
        temp_footerid = ''; // 记录 当前的footer_id
    // 设置静态页面（内容写死的页面）
    var isStaticView = function (viewid) {
        // 页面不需要动态读取数据，就在这里添加成，静态页（在网络提示的时候，不出现刷新按钮）
        var viewlist = 'news-main-view,news-second-view,work-release-view',
            flag = false;
        if (viewlist.indexOf(viewid) > -1) {
            flag = true;
        }
        return flag;
    };
    // 监控网络变化
    document.addEventListener("offline", function () {
        newtwork_status.is_online = false;
    }, false);
    /                                                                                                                /
    // 监控网络变化
    document.addEventListener("online", function () {
        newtwork_status.is_online = true;
    }, false);
    return {
        // 检查网络，并给出对应提示
        checkNetwork: function (optins) {
            NetworkObj.isOnline();
            var is_on = newtwork_status.is_online ? true : false,
                is_poor = newtwork_status.is_poor_network ? true : false,
                is_static = isStaticView(ViewObj.getCurrentViewId()) ? true : false,
                optins = ld.isPlainObject(optins) ? optins : {};
            showNetworkTips = NetworkObj.showNetworkTips;
            // 没网  或者 有网，但网络差
            if (!is_on || (is_on && is_poor)) {
                ld('#status').hide();
                if (is_poor) {
                    newtwork_status.is_poor_network = false;
                }
                // 显示 头部提示
                showNetworkTips('head_tip', 'show', optins);
                // 标明 不显示body_tip时 ， 非静态页面， 需要显示刷新按钮
                if (!optins.onlyhead_tip) {
                    if (optins.network_bodytip === false || is_static) {
                        showNetworkTips('body_tip', 'hide', optins);
                    } else {
                        // 显示刷新按钮
                        showNetworkTips('body_tip', 'show', optins);
                    }
                }
                ld('#poplayerMask').hide();
            } else {
                showNetworkTips('all', 'hide', optins);
            }
            return is_on;
        },
        // 设置网络 （调试时使用）
        setOnline: function (status) {
            if (status) {
                newtwork_status = {
                    is_online: true
                };
            } else {
                newtwork_status = {
                    is_online: false
                };
            }
        },
        // 判断当前网络状态
        isOnline: function () {
            if (phoneversion === 'ios') {
                /*
                 if (typeof navigator !== 'undefined' &&
                 navigator.connection) {
                 var networkState = navigator.connection.type,
                 states = {};
                 states[Connection.UNKNOWN] = 0;
                 states[Connection.NONE] = 0;
                 states[Connection.ETHERNET] = 10;
                 states[Connection.WIFI] = 1;
                 states[Connection.CELL_2G] = 2;
                 states[Connection.CELL_3G] = 3;
                 states[Connection.CELL_4G] = 4;
                 states[Connection.CELL] = 5;
                 if (states[networkState] === 0) {
                 newtwork_status.is_online = false;
                 } else {
                 newtwork_status.is_online = true;
                 }
                 }
                 */
                newtwork_status.is_online=true;
                if(typeof(cordova.exec)!="undefined" && typeof(cordova.exec)!=undefined){
                    //alert(typeof(cordova.exec));
                    try {
                        window.echo = cordova.exec(
                            function(okParam){
                                //alert('okParam' + okParam.networkstate);//Tools.print_array(okParam);
                                if(okParam.networkstate==='yes'){
                                    newtwork_status.is_online=true;
                                }
                                else{
                                    newtwork_status.is_online=false;
                                }
                            },
                            function(error) {
                                //alert('error1' + error);
                            },'CDVDevice', 'isOnline',[]);
                    }catch (e) {
                        //alert('error2:' + e.message);
                    }
                }
            } else if (phoneversion === 'android') {
                newtwork_status.is_online = androidObj.isOnline();
            }
            return newtwork_status.is_online;
        },
        // 设置网络状态
        setNetWorkStatus: function (settings) {
            if (settings) {
                if (typeof settings.is_poor_network === 'boolean') {
                    newtwork_status.is_poor_network = settings.is_poor_network;
                }
            }
            return this;
        },
        // 显示或者关闭网络提示 
        showNetworkTips: function (tip_type, sh_switch, options) {
            // console.log('is_on  : '+newtwork_status.is_online +
            //             '   is_poor  : '+newtwork_status.is_poor_network);
            // console.log('tip_type: '+tip_type+' sh_switch: '+sh_switch);
            var tip_obj = null,
                options = ld.isPlainObject(options) ? options : {},
                c_vid = ViewObj.getCurrentViewId();

            if (options.is_switchview) {
                temp_footerid = options.footerid;
            } else {
                temp_footerid = ld('#app-footer>div[is_show="true"]').attr('id');
            }
            var content_height = SwiperObj.CONTENT_HEIGHT - ld('#' + temp_footerid).height();
            if (tip_type === 'head_tip') {
                tip_obj = ld('#lineheadstatus');
            } else if (tip_type === 'body_tip') {
                tip_obj = ld('#linecontentstatus');
            } else if (tip_type === 'all') {
                tip_obj = ld('#lineheadstatus,#linecontentstatus')
            } else if (tip_type === 'pop') {
                ld('#linestatus').show();
                setTimeout(function () {
                    ld('#linestatus').hide();
                }, 2000);
            }

            if (sh_switch === 'show') {
                // BUG:登录后加载news页面时，ios弹出“无网络”
                if (tip_type === 'head_tip') {
                    if (!(ViewObj.getCurrentViewId() &&
                        ViewObj.getPrevInfo('viewid'))) {
                        return;
                    }
                }
                // 显示 body刷新提示时 ，需要隐藏当前view与底部footer,锁定home_swiper的滚动
                if (tip_type === 'body_tip' || tip_type === 'all') {
                    if (ld('#linecontentstatus').is(':hidden') &&
                        ViewObj.getInfo('transform_state') === 'transforming') {
                        setTimeout(function () {
                            ld('#linecontentstatus').show();
                            if (tip_type === 'all') {
                                ld('#lineheadstatus').show();
                                ld('#poplayerMask').hide();
                            }
                        }, 300);
                    } else {
                        tip_obj.show();
                    }
                    ld('#' + c_vid).addClass('ui-hide');
                    SwiperObj.homePage_swiper.lockSwipes();
                    // 隐藏当前页面底部footer
                    ViewObj.switchFooter(ld('#app-footer>div[is_show="true"]').attr('id'), 'hidden');
                } else {
                    tip_obj.show();
                }
                return;
            } else if (sh_switch === 'hide') {
                // 解除滚动锁定
                ld('#' + c_vid).removeClass('ui-hide');
                if (SwiperObj.isCurrentViewScrollable()) {
                    SwiperObj.homePage_swiper.unlockSwipes();
                }
                tip_obj.hide();
            }
            // 没有切换页面
            if (!options.is_switchview) {
                // 头部提示显示
                if (!ld('#lineheadstatus').is(':hidden') &&
                    (ViewObj.getInfo('transform_state') !== 'transforming') &&
                    ld('#linecontentstatus').is(':hidden')) {
                    if (SwiperObj.SWIPER_HOLDER.height() !== (content_height - 48)) {
                        SwiperObj.SWIPER_HOLDER.height(content_height - 48);
                        SwiperObj.autoHeight(-1);
                    }
                    // 显示当前页
                    ld('#' + c_vid).removeClass('ui-hide');
                    if (isStaticView(c_vid)) {
                        SwiperObj.autoHeight(0).autoHiddenAddMore();
                    }
                    // 头部提示没有显示
                } else {
                    if (SwiperObj.SWIPER_HOLDER.height() !== content_height) {
                        SwiperObj.SWIPER_HOLDER.height(content_height);
                        SwiperObj.autoHeight(-1);
                    }
                }
            }
        },
        // 网络差或者获取数据出错时，处理方法
        httpRequestTimeoutFun: function (text_status, options) {
            var options = ld.isPlainObject(options) ? options : {},
                getTip = function (opt) {
                    // 没网时，直接提示
                    if (!NetworkObj.isOnline()) {
                        NetworkObj.checkNetwork(opt);
                        // 有网但是网络差时，提示
                    } else if (text_status === 'timeout' ||
                        text_status === 'error') {
                        NetworkObj.setNetWorkStatus({
                            is_online: true,
                            is_poor_network: true
                        }).checkNetwork(opt);
                    }
                };
            // 正在刷新时，网络不佳
            if (SwiperObj.is_refreshPage ||
                SwiperObj.view_refreshing) {
                // console.log('刷新网络不佳!');
                options.network_bodytip = false;
                ld('#list-refresh-holder').addClass('ui-hide');
                ld('.list-refresh-icon').attr('class', 'list-refresh-icon');
                ld('.list-refresh-label').html('下拉刷新');
                SwiperObj.ListPageObj.setListPageIndex(1);
                SwiperObj.autoHeight(0);//回到头部
                SwiperObj.is_refreshPage = false;//标记不能刷新
                SwiperObj.view_refreshing = false;//标记刷新完成               
                // 正在加载时，网络不佳    
            } else if (SwiperObj.is_addMore ||
                SwiperObj.more_loading) {
                // console.log('加载网络不佳!');
                options.network_bodytip = false;
                ld('.list-addmore-label').html('更多...');
                ld('.list-addmore-icon').addClass('ui-hide');
                SwiperObj.autoHeight(-1);  //滚动条保持原位
                SwiperObj.is_addMore = false;//标记不能加载
                SwiperObj.more_loading = false; //标记加载完成                 
            }
            // else{
            //     console.log('网络差！处理');
            // }
            getTip(options);
        }
    };
})();

// 全局图片预览效果对象
var PicturePreviewObj = (function () {
    var previews = {}, // 存储图片链接列表
        show_model = '',         // 记录是从哪里点击图片
        w = SwiperObj.PHONE_WIDTH,
        h = SwiperObj.PHONE_HEIGHT,
        switch_effect = 'slide', // 切换效果 overflow,clue可选
        now_loadid = 0,
        old_loadid = 1,
        loadid_array = [],
        holder_obj = null;
    // 图片预览界面，操作对象
    var opreation = {
        // 显示图片预览
        getDsiplay: function (targetobj, img_index, show_deletebt) {
            // 在同一个页面里，连续点击同一个图片，预览，不重新加载
            // 点击不同图片,预览时，重新加载
            ViewObj.switchFooter('cwnm-main-footer', 'hidden');
            var s = SwiperObj.picturePreview_swiper;
            now_loadid = parseInt(holder_obj.parent().attr('loaded'), 10);
            old_loadid = parseInt(ld('#picture-preview-holder').attr('loaded'), 10);
            // 第二次预览相同的照片，并且是多张图片排列显示时
            if (typeof now_loadid === 'number' &&
                now_loadid === old_loadid && ViewObj.getCurrentViewId() != 'all-userinfo-view') {

                ld('#picture-preview-holder').css('opacity', 0).removeClass('ui-hide');
                if (typeof img_index === 'number' && !isNaN(img_index)) {
                    SwiperObj.picturePreview_swiper.slideTo(img_index - 1);
                    ld('#picture-preview-holder .imgbg-num').html((img_index) + '/' + s.slides.length);
                    if (show_deletebt) {
                        ld('#picture-preview-holder a[tag="delete"]').show();
                        ld(s.slides).each(function (index, el) {
                            setImagPosition(ld(this).find('img'));
                        });
                    } else {
                        ld('#picture-preview-holder a[tag="delete"]').hide();
                    }
                }
                ld('#picture-preview-holder').css('opacity', 1);
                return;
            }
            // 预览不同的照片
            if (typeof now_loadid !== 'unmber') {
                do {
                    now_loadid = Math.ceil(Math.random() * 10000);
                } while (ld.inArray(now_loadid, loadid_array) !== -1);

                ld('#picture-preview-holder').removeClass('ui-hide').attr('loaded', now_loadid);
                holder_obj.parent().attr('loaded', now_loadid);
                loadid_array.push(now_loadid);
            } else {
                ld('#picture-preview-holder').removeClass('ui-hide').attr('loaded', now_loadid);
            }

            var img_datas = holder_obj.find('[img-detail]'),
                img_srcdata = [],
                img_infodata = [];
            // 单张模式显示
            if (!img_datas.length) {
                show_model = 'single';
                img_srcdata.push(holder_obj.find('img').attr('src'));
                // 多张张模式显示
            } else {
                if (holder_obj.hasClass('picture-rang')) {
                    show_model = 'multi-rang';
                    img_datas.each(function (index, el) {
                        var temp = ld(this).find('img').attr('src');
                        img_srcdata.push(temp);
                    });
                } else if (holder_obj.hasClass('pictrue-fold')) {
                    show_model = 'multi-flod';
                    img_datas.each(function (index, el) {
                        img_srcdata.push(ld(this).attr('img-detail'));
                        if (module == 'SinginList') {
                            img_infodata.push(ld(this).attr('tag'));
                        }
                    });
                }
                // 当不具备删除功能 且 只有一张图片时 变为单张模式
                if (!show_deletebt && img_srcdata.length === 1) {
                    show_model = 'single';
                }
            }
            initPicturePreview(show_model, img_srcdata, img_infodata, img_index, show_deletebt);
        },
        // 删除图片
        deletePictrue: function (img_index, imgs_cunt) {
            if (module == 'Singin') {
                if (ld('#signUploadImg img').length < 10) {
                    ld('#signUploadImg div[tag=sign_addimg]').removeClass('ui-hide');
                }
            }
            var s = SwiperObj.picturePreview_swiper;
            holder_obj.find('[img-detail]').eq(img_index).remove();
            holder_obj.find('[img-detail]').each(function (index, el) {
                ld(this).find('img').attr('img_num', index + 1);
            });
            SwiperObj.picturePreview_swiper.removeSlide(img_index);
            //imgid
            ld('#picture-preview-holder .imgbg-num').html((s.activeIndex + 1) + '/' + s.slides.length);
            // 当删完所有图片时，返回上一个页面
            if (imgs_cunt === 1) {
                PicturePreviewObj.getBack();
                holder_obj = null;
            }
            if (imgid != '') {
                var imgidArr = imgid.split(',');
                imgidArr.splice(img_index, 1);
                imgid = imgidArr.join(',');
            }
        },
        // 添加图片
        addPictrue: function (imgsrc) {
            if (module == 'Singin') {
                if (ld('#signUploadImg img').length >= 10) {
                    ld('#signUploadImg div[tag=sign_addimg]').addClass('ui-hide');
                }
            }
            if (imgsrc && holder_obj.parent().attr('loaded')) {
                var add_img = '<div class="swiper-slide swiper-slide-active"><img src="' +
                    imgsrc + '" ></div>';
                SwiperObj.picturePreview_swiper.appendSlide(add_img);

            }
        },
        // 返回
        getBack: function () {
            ld('#picture-preview-holder').addClass('ui-hide');
            ViewObj.switchFooter('cwnm-main-footer', 'display');
        }
    };
    // 设置图片位置 垂直居中 横向满屏
    var setImagPosition = function (imgobj) {
        var i = imgobj,
            img_h = i.height();
        i.css({
            'width': w,
            'margin': '0px',
            'marginTop': -(img_h / 2)
        });
    };
    // 初始化 全局图片预览滚动对象
    var initPicturePreview = function (model, srcdata, infodata, img_index, show_deletebt) {
        if (SwiperObj.isDestroyable(SwiperObj.picturePreview_swiper)) {
            try {
                SwiperObj.picturePreview_swiper.destroy(true, true);
            } catch (e) {
            }
        }
        if (srcdata.length === 0) return;
        var img_tpl = '<div class="swiper-slide"><img src="relace_content" title="relace_title"></div>',
            pic_holder = ld('#picture-preview-holder'),
            deletbt = ld('#picture-preview-holder a[tag="delete"]'),
            img_num = 0,
            htmlStr = '';
        // 单张模式
        if (model === 'single') {
            htmlStr = '<div class="swiper-slide swiper-no-swiping"><img src="' + srcdata[0] + '"></div>';
            pic_holder.find('.imgbg-top').hide();
            // 多张模式
        } else if (model.indexOf('multi') > -1) {
            ld.each(srcdata, function (index, img_src) {
                if (infodata != '') {
                    htmlStr += img_tpl.replace('relace_content', srcdata[index]).replace('relace_title', infodata[index]);
                }
                else {
                    htmlStr += img_tpl.replace('relace_content', srcdata[index]);
                }
                img_num += 1;
            });
            if (show_deletebt) {
                deletbt.show();
            } else {
                deletbt.hide();
            }
            var imgDelete = ld('#picture-preview-holder a[tag="delete"]');
            if (infodata != '' && module == 'SinginList') {
                imgDelete.css({
                    'font-size': '16px',
                    'float': 'right',
                    'display': 'inline-block',
                    'margin-right': '-20px'
                });
                imgDelete.html('<span>' + infodata[0] + '</span>').attr('class', '');
                imgDelete.show();
            }
            else {
                imgDelete.attr('style', '');
                var c_viewId = ViewObj.getCurrentViewId();
                if( c_viewId === 'work-main-view' || c_viewId === 'wn-workdetail-view' ||
                    c_viewId === 'cwn-crmdetail-view' || c_viewId === 'wn-worklist-view' ||
                    c_viewId === 'wn-userinfo-view' || c_viewId === 'wn-replayfileat-view'){
                    imgDelete.html('').attr('class', '');
                }
                else{
                    imgDelete.html('').attr('class', 'lnr-trash');
                }
            }

            pic_holder.find('.imgbg-top').show();//3
            pic_holder.find('.imgbg-num').html('1/' + img_num);
        }
        ld('#loading').show();
        pic_holder.find('.swiper-wrapper').css('opacity', 0).html(htmlStr);
        //创建全局 图片预览横向swiper滚动
        var swiper_opts = {
            direction: 'horizontal',
            preloadImages: true,
            updateOnImagesReady: true,
            width: w,
            height: h,
            slidesPerView: 1,
            effect: switch_effect,
            onTransitionEnd: function (s) {
                var imgTitle = ld('#picture-preview-holder .swiper-wrapper img:eq(' + s.activeIndex + ')');
                var imgDelete = ld('#picture-preview-holder a[tag="delete"]');
                if (infodata != '' && module == 'SinginList') {
                    imgDelete.css({
                        'font-size': '16px',
                        'float': 'right',
                        'display': 'inline-block',
                        'margin-right': '-20px'
                    });
                    imgDelete.html('<span>' + imgTitle.attr('title') + '</span>').attr('class', '');
                    imgDelete.show();
                }
                else {
                    imgDelete.attr('style', '');
                    var c_viewId = ViewObj.getCurrentViewId();
                    if( c_viewId === 'work-main-view' || c_viewId === 'wn-workdetail-view' ||
                        c_viewId === 'cwn-crmdetail-view' || c_viewId === 'wn-worklist-view' ||
                        c_viewId === 'wn-userinfo-view' || c_viewId === 'wn-replayfileat-view'){
                        imgDelete.html('').attr('class', '');
                    }
                    else{
                        imgDelete.html('').attr('class', 'lnr-trash');
                    }
                }
                ld('#picture-preview-holder .imgbg-num').html((s.activeIndex + 1) + '/' + s.slides.length);
            },
            onImagesReady: function (s) {
                ld(s.slides).each(function (index, el) {
                    setImagPosition(ld(this).find('img'));
                });
                ld('#loading').hide();
                pic_holder.find('.swiper-wrapper').css('opacity', 1);
            }
        };
        if (model === 'single') {
            swiper_opts.noSwiping = true;
        } else if (model === 'multi-rang') {
            swiper_opts.initialSlide = img_index - 1;
        }
        SwiperObj.picturePreview_swiper = new Swiper('.swiper-container.picture-preview-swiper', swiper_opts);
        ld('#picture-preview-holder .picture-preview-swiper').css({'width': w, 'height': h});
    };
    // 绑定事件公共方法
    var addEvent = function (obj, evtype, fn, useCapture) {
        if (obj.addEventListener) {
            obj.addEventListener(evtype, fn, useCapture);
        } else if (obj.attachEvent) {
            obj.attachEvent("on" + evtype, fn);//IE不支持事件捕获 
        } else {
            obj["on" + evtype] = fn;//事实上这种情况不会存在 
        }
    };
    // 事件绑定
    var bingPictruePreviewEvent = (function () {
        //事件 处理函数
        var dispose = function (event) {
            var e = event || window.event,
                t = e.target || e.srcElement,
                target_obj = ld(t),
                _this = null;

            _this = target_obj.parents('.picture-preview');
            // 点击带有 picture-preview class标记的元素，表示处理预览
            if (_this.length === 1) {
                holder_obj = _this;
                if (target_obj.attr('tag') === 'img-addbt') {
                    if(module=='Singin'){
                        var urlstring = 'module=Home&action=ListView&method=getSignPhoto';
                        WordReportAjax(urlstring,function(rest){
                            if (empty(rest)) return false;
                            var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                            if(restobj.result.value == '0'){//是
                                ld('#tplPhone div[tag=btnsub_photo]').removeClass('ui-hide');
                            }
                            else if(restobj.result.value == '1'){//否
                                ld('#tplPhone div[tag=btnsub_photo]').addClass('ui-hide');
                            }
                            logicHanderObj.popUpMaskToggle('tplPhone');//显示拍照获取方式弹出层和遮罩层
                        });
                    }
                    else{
                        ld('#tplPhone div[tag=btnsub_photo]').removeClass('ui-hide');
                        logicHanderObj.popUpMaskToggle('tplPhone');//显示拍照获取方式弹出层和遮罩层    
                    }
                } else {
                    var img_num = parseInt(target_obj.attr('img_num')),
                        show_deletebt = _this.attr('show-deletebt') === 'true' ? true : false;
                    // 显示图像预览
                    e.stopPropagation(); // 停止事件冒泡
                    opreation.getDsiplay(target_obj, img_num, show_deletebt);
                }
                //点击 图片预览其他操作
            } else if (target_obj.parents('#picture-preview-holder').length === 1) {
                // 如果为 单图显示 ，点击直接返回
                if (show_model === 'single') {
                    opreation.getBack();
                    // 多图显示时
                } else {
                    // 点击返回按钮
                    if (target_obj.attr('tag') === 'cancel') {
                        opreation.getBack();
                        // 点击删除按钮
                    } else if (target_obj.attr('tag') === 'delete' && module != 'SinginList') {
                        var imgs = ld('#picture-preview-holder h5.imgbg-num').html().split('/');
                        opreation.deletePictrue((imgs[0] - 1), parseInt(imgs[1]));
                    }
                }
                e.stopPropagation(); // 停止事件冒泡   
                return;
            }
        };
        // 捕捉事件委托（在ie8之前无效）
        addEvent(ld('#app-body')[0], 'click', dispose, true);
    })();
    return {
        // 清空滚动对象缓存的数据，释放内存
        clearPicturePreview: function () {
            // 清除图片预览滚动对象
            if (SwiperObj.isDestroyable(SwiperObj.picturePreview_swiper)) {
                try {
                    SwiperObj.picturePreview_swiper.destroy(true, true);
                } catch (e) {
                } // 防止调用 .destroy 时报错
            }
            ld('#picture-preview-holder .swiper-wrapper').html('');
            ld('#picture-preview-holder').attr('loaded', '-1');
            loadid_array = [];
        },
        // 返回键
        getBack: opreation.getBack,
        // 添加图片
        addPictrue: opreation.addPictrue
    };
})();

// 全局提示框对象
/* 参数：
 （1）如果是 string类型,弹出“确定”提示框框
 （2）如果是 object类型，需要提供如下属性

 head_text string  头部标题（默认: ''）
 main_text string  提示信息 (默认:'')
 btn_type  string  提示框按钮类型，可选值
 ('yes'只带“确定按钮”吗,'yesno'带“确定、取消”按钮 ) (默认:'yes')
 yes_str   string  确定按钮显示文字 (默认:'确定')
 yes_fun   function  点击确定按钮执行的操作 (默认: undefined)

 只有btn_type 为'yesno'时，才会有下面属性
 no_str    string    取消按钮显示文字 (默认:'取消')
 no_fun    function  点击取消按钮执行的操作 (默认: undefined)

 eg: 举例
 PopPromptBox.show({
 head_text : '',
 main_text : '你确定要退出吗？',
 btn_type  : 'yesno',
 yes_str   : '我意已决',
 yesbt_postion : 'left'
 yes_fun   : function(){ exit(); },
 no_str    : '再玩会',
 no_fun    : function(){ play(); }
 });
 */
var PopPromptBox = (function () {
    var cancelFun = null,
        sureFun = null,
        show_mianbt = true;
    // 绑定事件
    ld('#pop-prompt-box').on('click', function (event) {
        var e = event || window.event,
            targetobj = ld(e.target || e.srcElement),
            info = targetobj.attr('tag');
        // 点击弹出框底部
        if (targetobj.attr('class') === 'pop-foot' ||
            targetobj.parents('.pop-foot').length === 1) {
            if (!info) return;
            // 取消弹出效果
            PopPromptBox.hide();
            if (ViewObj.getCurrentViewId().indexOf('main') > -1 && show_mianbt) {
                ViewObj.switchFooter('cwnm-main-footer', 'display');
            }
            if (info === 'sure' &&
                ld.isFunction(sureFun)) {
                sureFun(); //  点击确定键执行
            } else if (info === 'cancel' &&
                ld.isFunction(cancelFun)) {
                cancelFun(); // 点击取消键执行
            }
        }
    });
    return {
        // 显示警告弹出框
        show: function (options) {
            var pop_head = ld('#pop-prompt-box>.pop-head'),
                pop_main = ld('#pop-prompt-box>.pop-main'),
                pop_foot = ld('#pop-prompt-box>.pop-foot');
            // 首页有弹出框时 隐藏底部按钮
            if (ViewObj.getCurrentViewId().indexOf('main') > -1) {
                // machineHanderObj.hideMainBtn();
                ViewObj.switchFooter('cwnm-main-footer', 'hidden');
            }
            ld('.orderDiv').addClass('ui-hide');
            // 参数 为字符串时，直接显示
            if (typeof options === 'string') {
                pop_head.hide();
                pop_main.html(options);
                pop_foot.html('<a tag="cancel">好的</a>');
                pop_foot.find('a').css({'width': '90%'});
                sureFun = null;
                cancelFun = null;
            } else if ($.isPlainObject(options)) {
                show_mianbt = typeof options.show_mianbt === 'boolean' ? options.show_mianbt : true;

                if (options.head_text) {
                    pop_head.html(options.head_text);
                    pop_head.show();
                } else {
                    pop_head.hide();
                }
                if (options.main_text !== '') {
                    pop_main.html(options.main_text);
                } else {
                    alert('传入main_text属性！');
                }
                if (options.btn_type) {
                    var type = options.btn_type.toLowerCase();
                    if (type === 'yesno') {
                        if (options.yesbt_position === 'left') {
                            pop_foot.html('<a tag="sure">确定</a><a tag="cancel">取消</a>');
                        } else if (!options.yesbt_position ||
                            options.yesbt_position === 'right') {
                            pop_foot.html('<a tag="cancel">取消</a><a tag="sure">确定</a>');
                        }
                        pop_foot.find('a').css({'width': '45%'});
                        if (options.yes_str !== '') {
                            pop_foot.find('a[tag="sure"]').html(options.yes_str);
                        }
                        if (options.no_str !== '') {
                            pop_foot.find('a[tag="cancel"]').html(options.no_str);
                        }
                        if (ld.isFunction(options.yes_fun)) {
                            sureFun = options.yes_fun;
                        } else {
                            sureFun = null;
                        }
                        if (ld.isFunction(options.no_fun)) {
                            cancelFun = options.no_fun;
                        } else {
                            cancelFun = null;
                        }
                    }
                } else {
                    if (ViewObj.getCurrentViewId() === 'me-setting-view') {
                        pop_foot.html('<a tag="cancel">确定</a>');
                    }
                    else {
                        pop_foot.html('<a tag="sure">确定</a>');
                    }
                    pop_foot.find('a').css({'width': '90%'});
                    if (options.yes_str && options.yes_str !== '') {
                        pop_foot.find('a').eq(0).html(options.yes_str);
                    }
                    if (ld.isFunction(options.yes_fun)) {
                        sureFun = options.yes_fun;
                    }
                }
            } else {
                return;
            }
            ld('#pop-prompt-box,#layerMask').show();
        },
        // 关闭弹出框
        hide: function () {
            ld('#pop-prompt-box,#layerMask,#pop-prompt-box>.pop-head').hide();
        }
    };
})();

// 全局搜索框对象
/*
 参数： object类型
 属性：
 parent_id  string 搜索框父元素 (默认: '' )
 parent_obj object 一个父容器 dom或者 jq对象
 当parent_id,parent_obj（优先） 同时存在时
 value_text string 搜索框的值 (默认： '')
 tip_text   string 搜索框提示文字 (默认： '')
 searchFun  function 点击搜索按钮执行的方法 (默认： undefined)
 eg
 ListSearchBox.display({
 parent_id : '',//id，或者父容器：jq对象
 value_text : '你好',
 tip_text : '请输入姓名',
 searchFun : function(searchstr,callback){
 callback();//执行后更改页面高度
 }
 });
 */
var ListSearchBox = (function () {
    var searchFun = null,
        search_html =   '<div tag="search-box" class="search-warp ui-hide">' +
                            '<i class="lnr-magnifier"></i>' +
                            '<input tag="search-text" name="serach-text" type="text"  value=""/>' +
                            '<i tag="search-del-icon" class="lnr-cross-circle" style="display:none;" ></i>' +
                            '<input tag="search-bt" type="button"  value="搜索">' +
                        '</div>';
    // 事件绑定
    ld('#app-body').on('click', function (event) {
        var e = event || window.event,
            targetobj = ld(e.target) || ld(e.srcElement),
            obj_tag = targetobj.attr('tag'),
            _this = null;
        // 点击搜索框
        if (targetobj.parents('div[tag="search-box"]')) {
            // 点击搜索框中文本框，绑定属性事件
            if (obj_tag === 'search-text') {
                _this = targetobj;
                var evt = ld._data(_this[0], 'events'),
                    icon = _this.parent().find('.lnr-cross-circle');
                if (!(evt && evt['propertychange'])) {
                    // 确保多次点击只是绑定一次事件
                    _this.on('input propertychange', function () {
                        if (_this.val().length === 0) {
                            icon.hide();
                        } else {
                            icon.show();
                        }
                    });
                }
                // 点击搜索按钮执行事先传入的搜索方法
            } else if (obj_tag === 'search-bt') {
                _this = targetobj;
                var searchstr = _this.parent().find('input[type="text"]').val();
                if (ld.isFunction(searchFun)) {
                    searchFun(searchstr, function () {
                        SwiperObj.autoHeight(0).autoHiddenAddMore();
                    });
                }
                // 点击文本框右侧‘删除’按钮
            } else if (obj_tag === 'search-del-icon') {
                _this = targetobj;
                _this.parent().find('input[type="text"]').val('');
                searchcontent = ''; // 全局变量赋值
                searchcontentDetail = '' // 全局变量赋值
               _this.hide();

                ld('#cwn-popuselect-view li').each(function (index, el) {
                    var _this = ld(this);
                    _this.show();
                });
                ld('#me-adressbook-view li').each(function (index, el) {
                    var _this = ld(this);
                    _this.show();
                });
                ld('#cwn-popuselect-view .no_message_tip').remove();
                SwiperObj.autoHeight(0).autoHiddenAddMore();
            } else {
                return;
            }
        }
    });
    return {
        // 显示搜索框
        display: function (options) {
            var opts = ld.isPlainObject(options) ? options : {},
                parent_id = opts.parent_id,
                value_text = opts.value_text,
                tip_text = opts.tip_text,
                parent_obj = opts.parent_obj;

            // 给搜索方法赋值    
            searchFun = opts.searchFun;

            // 为传入parent_id时返回
            if (!parent_obj && parent_id) {
                parent_obj = ld('#' + parent_id);
            }
            if (!parent_obj) return;

            // 将search html字符串赋值给父容器
            parent_obj.html(search_html);
            search_box = parent_obj.find('div[tag="search-box"]');
            search_box.removeClass('ui-hide');

            search_box.find('input[type="text"]').val(value_text)
                .attr('placeholder', tip_text);
            //当有搜索内容时，显示‘x’图标
            if (value_text) {
                search_box.find('.lnr-cross-circle').show();
            }
        }
    }
})();
// 全局缓存对象
var CacheObj = (function () {
    return {
        // 设置缓存键值
        set: function (key, value, cTime) {
            if (!key) return;

            var cValue = {};
            cValue.data = value;
            if (cTime && parseInt(cTime) > 0) {
                cValue.expire = (new Date().getTime() / 1000) + cTime;
            } else {
                cValue.expire = 0;
            }
            try {
                window.localStorage.setItem(key, JSON.stringify(cValue));
            } catch (oException) {
                if (oException.name == 'QuotaExceededError') {
                    console.log('超出本地存储限额！');
                }
            }
        },
        // 获取缓存值
        get: function (key) {
            if (!key) return;
            try {
                var result = JSON.parse(window.localStorage.getItem(key));
                if (!result) {
                    result = '';
                    // 当超过缓存时间后，将获取不到值
                } else if (result.expire > 0 && result.expire <= (new Date().getTime() / 1000)) {
                    result = '';
                } else {
                    result = result.data;
                }
            } catch (err) {
                var result = '';
            }
            return result;
        },
        // 删除缓存值
        del: function (key) {
            if (!key) return;
            window.localStorage.removeItem(key);
        },
        // 清空所有缓存
        clear: function () {
            window.localStorage.clear();
        },
        // 获取所有的缓存值
        getAll: function () {
            window.localStorage.valueOf();
        }
    }
})();
// 全局页面对象，包含页面跳转，点击事件处理定义
// 注意 每当修改footerid viewid时，需要到 all_viewsId，all_footersId注册，否则无效
var ViewObj = (function () {
    var crrent_category = '',   // 当前处于news,work,crm,apply,me页面
        is_selfSwitch = false,  // 自己页面跳转到在自己页面
        current_viewId = '',    // 当前页面的vewid
        toview_id = '',        // 将要跳转的页面viewId
        current_header = [],   // 当前头部
        prev_header = [],      // 上一个页面头部
        transform_state = 'none', // 页面切换状态
        is_getdataend = false, // 获取数据结束
        is_datafetching = false, // 正在获取数据
        prev_Info = {            // 记录上一个页面的信息
            viewid: '',       // 页面ID  
            footerid: '',    // 底部按钮ID
            header: [],      // 头部
            options: {
                onExitBefore: null,  // 退出页面前执行的方法
                onExitViewbeAfter: null // 退出页面后执行的方法
            }
        },       // 记录跳转到当前页面 的页面id
        // 所有页面的id,按照不同页面分类
        all_viewsId = {
            all:'all-userinfo-view,',
            crm_work_news: 'cwn-popuselect-view,cwn-relationlist-view,cwn-relationdetail-view,' +
            'cwn-crmdetail-view,cwn-crmdetailsub-view,cwn-lookup-view,cwn-popuedit-view,' +
            'cwn-seeposition-view,cwn-sendrang-view,cwn-attview-view',
            // 工作列表，工作明细，回复，转发，选择范围
            work_news: 'wn-worklist-view,wn-workdetail-view,wn-replayforword-view,wn-userinfo-view,wn-replayfileat-view,',
            crm_news: 'cn-approval-view',  // 审批，反审批
            //crm_work : '',
            crm: 'crm-main-view,crm-list-view,crm-sign-view,crm-photo-view,crm-checkrepeat-view' +
            'crm-createedit-view,crm-createeditsub-view,crm-signchooseAdr-view,crm-uploadlog-view' +
            'crm-dashboard-view,crm-dashboarddetail-view,crm-dashboardsearch-view,crm-nearbyaccounts-view' +
            'crm-nearbyaccounts-search-view,approve-list-view',
            work: 'work-main-view,work-search-view,work-release-view,work-position-view,work-positionmore-view',
            news: 'news-main-view,news-second-view,news-third-view,newsapprove-list-view',
            me: 'me-main-view,me-setting-view,me-adressbook-view,me-feedback-view'
        },
        // 所有页面的底部,按照不同页面分类
        all_footersId = {
            crm_work_news_me: 'cwnm-main-footer,crm-detail-footer,crm-addproduct-footer,crm-addexpense-footer,crm-addoadetail-footer',
            // 回复转发，
            work_news: 'wn-at-footer,wn-choosenview-footer,wn-release-footer,wn-workdetail-footer,wn-forword-footer',
            //crm_work : '',  
            crm: 'crm-photo-footer',  // 编辑 ，添加产品，费用报销，发照片，OA表单
            work: 'work-position-footer,',  // 日志，任务发布,@,明细
            //news : '',
            me: 'me-feedback-footer'
        },
        scoller_TopStack = {},   // 保存每一个view的滚动条与顶部的距离
        viewreset_stack = {};   //  保存页面切换轨迹

    // 检查是否是有效的 viewid 或者 footerid
    /*var checkValid=function(target,test_id){
     // 检查参数是否为 字符串
     var targetobj =null,
     result =false,
     key ='';

     if(target==='viewid'){
     targetobj=all_viewsId;
     }else if(target==='footerid'){
     targetobj=all_footersId;
     }else{
     alert('ViewObj_beat中checkValid方法target参数，\n'+'传参错误(footerid或者viewid)');
     return;
     }
     for(key in targetobj){
     if(targetobj.hasOwnProperty(key)){

     if(targetobj[key].indexOf(test_id)>-1){
     result=test_id;
     break;
     }
     }
     }
     return result;
     };*/
    // 检查字符串数组，当数组中全部为字符串时返回真，否则报错
    /*var checkStrArray=function(testArray,methodname){
     if(!$.isArray(testArray)) return;
     $.each(testArray,function(index,value){
     if(typeof value !== 'string'){
     alert('ViewObj_beat对象中'+methodname+'()方法字符串数组传参有错！');
     return false;
     }
     });
     return true;
     };*/
    // 获取 非空字符串，若为''，或者非字符串，报错
    /*var getValidStr=function(testStr,methodname){
     if(typeof testStr !=='string'){
     alert('ViewObj.'+methodname+'()方法字符串传参有错！');
     return false;
     }
     if($.trim(testStr)===''){
     alert('ViewObj.'+methodname+'()方法字符串为""');
     return false;
     }
     return testStr;
     };*/
    // 构造头部html字符串 必须传入六个字串组成的数组
    // ['左图标'，'左文字'，'中图标'，'中文字'，'右图标'，'右文字']
    // 不存在时，传入''，空字符串
    var createHeaderHtml = function (head_array, no_oldtitle) {
        // 检查参数head_array是否为 字符串数组
        //checkStrArray(head_array,'createHeaderHtml');
        /*if(head_array.length!==6){
         alert('createHeaderHtml(),必须传入有六个字符串组成的数组！');
         return false;
         }*/
        header_array = head_array; // 记录头部信息
        var header_html = '',
            l_icon = head_array[0],
            l_text = head_array[1],
            m_icon = head_array[2],
            m_text = head_array[3],
            r_icon = head_array[4],
            r_text = head_array[5],

            l_icon_class = '',
            m_html = '',
            r_icon_class = '',
            l_tag = m_tag = r_tag = 'true';
        // 头部左边
        if (l_icon === '' && l_text === '') {
            l_tag = 'none';
        } else if (l_icon === '-' && l_text === '-') {
            l_icon = '';
            l_text = '';
        } else {
            if (l_icon === '<') { // "<" 图标
                l_icon_class = 'lnr-chevron-left';
            } else if (l_icon === '搜索') { // "搜索"图标，工作首页面
                l_icon_class = 'lnr-magnifier';
            } else {
                l_icon_class = 'text-noly';
            }
        }
        // 头部中间
        if (m_icon === '' && m_text === '') {
            m_tag = 'none';
        } else if (m_icon === '-' && m_text === '-') {
            m_icon = '';
            m_text = '';
        } else {
            var tem_html = '',
                tmp_str = ld('#head_mid .new-title').html();
            if (!no_oldtitle) {
                m_html = '<div class="trans-hander old-title">' + (!empty(tmp_str) ? tmp_str : '') + '</div>';
            }

            if (m_icon === 'v') {// "v" 图标，下拉分类 
                tem_html = '<span classify="true">' + m_text + '</span><i class="lnr-chevron-down"></i>';
            } else if (m_icon === '') {// 没有图标    
                if (m_text === '搜索') {
                    tem_html = '<p class="lnr-magnifier"><input type="text" autofocus="autofocus" placeholder="搜索" ' +
                        'class="search-txt"><i class="delCont lnr-cross-circle ui-hide"></i></p>';
                } else {
                    tem_html = '<span classify="false">' + m_text + '</span>';
                }
            }
            tem_html = '<div class="trans-hander new-title">' + tem_html + '</div>';
            m_html += tem_html;
        }
        // 头部右边
        if (r_icon === '' && r_text === '') {
            r_tag = 'none';
        } else if (r_icon === '-' && r_text === '-') {
            r_icon = '';
            r_text = '';
        } else {
            if (r_icon === '+') {// "+" ，创建
                r_icon_class = 'lnr-plus';
            } else if (r_icon === '...') {// "..." ，更多 
                r_icon_class = 'lnr-more';
            } else if (r_icon === '相机') {// "拍照" ，CRM拍照页面 
                r_icon_class = 'lnr-camera2';
            } else if (r_icon === '列表') {// "列表" ，CRM、应用首页面 
                r_icon_class = 'lnr-menu';
            } else if (r_icon === '方格') {// "方格" ，CRM、应用首页面 
                r_icon_class = 'lnr-grid';
            } else if (r_icon === '搜索') { // "搜索" ，CRM附近客户
                r_icon_class = 'lnr-magnifier';
            }
        }
        // 构造头部字符串
        header_html = '<div id="head_left" tag="' + l_tag + '" class="head-left">' +
            '<a href="javascript:void(0);" class="' + l_icon_class + '" ><span>' + l_text + '</span></a>' +
            '</div>' +
            '<div id="head_mid" tag="' + m_tag + '" class="head-mid">' + m_html + '</div>' +
            '<div id="head_rig" tag="' + r_tag + '" class="head-rig">' +
            '<a href="javascript:void(0);" class="' + r_icon_class + '" style="font-size:1.5rem;line-height:2.7rem;right: 0.1rem;"><span>' +
            r_text + '</span></a>' +
            '</div>';
        return header_html;
    };
    // 在切换动画开始前进行的操作
    var onTransFormViewBegin = function (current_viewId, to_viewid) {
        transform_state = 'none';
        // 隐藏 “更多” 标签
        ld('#list-addmore-holder').addClass('ui-hide');
        // 设置可视内容高度
        SwiperObj.SWIPER_HOLDER.height(SwiperObj.CONTENT_HEIGHT);
        // work 首页头部分类 特殊控制
        if (to_viewid === 'work-main-view') { // 进入 work首页
            ld('#workDataClassify,#home-page .adjust-head').removeClass('ui-hide');
        } else if (current_viewId === 'work-main-view') { // 离开work首页
            ld('#home-page .adjust-head').addClass('ui-hide');
        }
    };
    // 在切换动画完成后进行的操作
    var onTransformViewEnd = function (head_array, direction, options) {
        // transform_state 三个状态 'none','transforming','transformend'
        // 异步处理， 当状态为'transformend'表示切换结束
        if (transform_state === 'none') {
            transform_state = 'transforming';
            if (prev_Info.viewid === 'work-main-view') { // 退出 work首页           
                ld('#workDataClassify').addClass('ui-hide');
            }
        } else if (transform_state === 'transforming') {
            transform_state = 'transformend';
        }
        // 'transformend'表示切换页面结束
        if (transform_state === 'transformend') {
            // 头部带有输入框 添加事件监听(work search页)
            if (head_array[3] === '搜索') {
                var del_icon = ld('#app_header .delCont'),
                    seach_input = ld('#app_header input'),
                    evt = ld._data(seach_input[0], 'events');
                // 保证不重复添加绑定事件
                if (!(evt && evt['propertychange'])) {
                    // 根据内容变化 显示右边小图标
                    seach_input.on('input propertychange', function () {
                        if (empty(ld(this).val())) {
                            del_icon.addClass('ui-hide');
                        } else {
                            del_icon.removeClass('ui-hide');
                        }
                    });
                    // 清空搜索框
                    del_icon.unbind('click').on('click', function (event) {
                        seach_input.val('');
                        del_icon.addClass('ui-hide');

                        // 在work 搜索页面 点击'x'时，返回搜索页面
                        if (ViewObj.getCurrentViewId() === 'wn-worklist-view') {
                            ViewObj.switchView('work-search-view', 'init', {
                                __direction: 'right_out'
                            });
                        }
                    });
                }
            }
            // 检查 当前页面 是否 需要滚动（不需要滚动则不需要检查是否刷新）
            if (options.__direction !== 'none' && SwiperObj.isCurrentViewScrollable()) {
                SwiperObj.isCurrentViewRefreshable();  // 检查 将要跳转的页面 是否 需要刷新
                SwiperObj.autoHiddenAddMore();         // 自动隐藏 ‘更多’
            }
            if ((typeof options.__init_delay === 'unmber' || direction === 'left_in') && ld('#linecontentstatus').is(':hidden')) {
                ld('#' + current_viewId).removeClass('ui-hide');
            }
        }
        if (transform_state === 'transformend' && is_getdataend) {
            ViewObj.onSwitchAfter(options);
        }
    };
    // 页面切换动画效果
    var transformView = function (to_viewid, head_array, options) {
        var c_viewobj = ld('#' + current_viewId), //  当前view(需要隐藏的view) 
            to_viewobj = ld('#' + to_viewid), // 将要跳转的view(需要显示的view)
            new_title = null, // 新的头部
            old_title = null, // 旧的头部
            title_width = ld('#head_mid').width(), // 页面顶部中间title的宽度
            // 切换方向
            direction = options.__switch_type === 'init' ? 'left_in' : 'right_out',
            // 切换持续时间
            duration = options.__duration ? options.__duration : 300,
            title_direction = 1, // 切换方向 表示向右
            trans_distance = SwiperObj.PHONE_WIDTH,// 切换宽度（屏幕宽度）
            translate = scoller_TopStack[to_viewid],// 滚动条距离顶部高度
            trans_init = {
                tv_css: {}, // 切换时css设置
                cv_css: {}
            };
        // 获得最终的 滚动条距离顶部高度
        translate = typeof translate === 'number' ? translate : 0;
        // 获得最终的 切换方向
        direction = typeof options.__direction === 'string' ? options.__direction : direction;

        if (direction === 'none') { // 当 切换方向是none时，即没有切换过渡效果
            // 两次传入头部不相同 时更换头部
            if (prev_Info.header.toString() !==
                head_array.toString()) {

                ld('#app_header').html(createHeaderHtml(head_array));
                ld('.trans-hander.new-title').css('left', '0px').show();
                ld('.trans-hander.old-title').hide();
            }
            onTransFormViewBegin(current_viewId, to_viewid); // 执行切换页面前方法
            c_viewobj.addClass('ui-hide'); // 隐藏当前页面
            if (ld('#linecontentstatus').is(':hidden')) { // 无网络刷新按钮，隐藏时
                to_viewobj.removeClass('ui-hide'); // 显示跳转页面
            }
            transform_state = 'transformend';//修改切换状态，
            onTransformViewEnd(head_array, direction, options); // 执行切换页面后方法
        } else {
            trans_init = {
                tv_css: {
                    boxShadow: '-2px 0px 4px #eee',
                    delay: 0,
                    zIndex: 2,
                    easing: 'easeOutCubic'
                },
                cv_css: {
                    boxShadow: 'none',
                    delay: 100,
                    zIndex: 1,
                    easing: 'easeOutQuad'
                }
            }
            if (direction.indexOf('out') > -1) {
                trans_init.temp = trans_init.tv_css;
                trans_init.tv_css = trans_init.cv_css;
                trans_init.cv_css = trans_init.temp;
            }
            switch (direction) {
                case 'left_in':
                    trans_init.tv_css.left = trans_distance + 'px';
                    trans_init.cv_css.left = -trans_distance / 4 + 'px';
                    break;
                case 'left_out':
                    trans_init.tv_css.left = trans_distance / 4 + 'px';
                    trans_init.cv_css.left = -trans_distance + 'px';
                    trans_init.cv_css.boxShadow = '2px 0px 4px #eee';
                    break;
                case 'right_in':
                    title_direction = -1;
                    trans_init.tv_css.boxShadow = '2px 0px 4px #eee';
                    trans_init.tv_css.left = -trans_distance + 'px';
                    trans_init.cv_css.left = trans_distance / 4 + 'px';
                    break;
                case 'right_out':
                    title_direction = -1;
                    trans_init.tv_css.left = -trans_distance / 4 + 'px';
                    trans_init.cv_css.left = trans_distance + 'px';
                    break;
            }
            // 临时替换页！（这句话是切换页面效果核心）
            var temp_dom = ld('#home-page').clone().attr('id', 'temp_trans')
                    .html(ld('#home-page>.swiper-wrapper')
                        .clone().html(ld('#home-page .adjust-head').prop('outerHTML') +
                            c_viewobj.prop('outerHTML'))),
                temp_t = to_viewobj,
                temp_c = c_viewobj,
                // 切换页面 延迟显示（将要显示的页面）
                init_delay = direction === 'left_in' ? 200 : 'none';
            init_delay = options.__init_delay ? options.__init_delay : init_delay;

            temp_dom.insertAfter(ld('#home-page'));

            c_viewobj = ld('#temp_trans').css({
                position: 'absolute',
                zIndex: 2
            });
            to_viewobj = ld('#home-page').css({
                position: 'absolute',
                zIndex: 1,
            });
            // 执行页面跳转前 方法
            onTransFormViewBegin(current_viewId, to_viewid);

            temp_t.addClass('ui-hide');// 隐藏跳转页面
            temp_c.addClass('ui-hide'); // 隐藏当前页面 

            // 不需要延迟显示（将要跳转页面）
            if (init_delay === 'none') {
                if (ld('#linecontentstatus').is(':hidden')) { // 无网络刷新按钮，隐藏时
                    temp_t.removeClass('ui-hide');// 显示跳转页面
                }
                init_delay = 0;
            }
            temp_c = null, temp_t = null, temp_dom = null;
            // 设置页面滚动条位置
            if (options.__scroll_top === 'origin') {
                SwiperObj.autoHeight(translate);
            } else {
                SwiperObj.autoHeight(-1);
            }

            // 两次传入头部不相同 时更换头部
            if (prev_Info.header.toString() !==
                head_array.toString()) {

                ld('#app_header').html(createHeaderHtml(head_array));
                // velocity 插件，写动画
                new_title = ld('.trans-hander.new-title').css({
                    left: (title_direction * title_width) + 'px',
                    opacity: 0.3
                }).velocity({
                    left: 0 + 'px',
                    opacity: 1
                }, {
                    duration: (duration - 100),
                    easing: trans_init.tv_css.easing,
                    complete: function (_this) {
                        new_title.css('left', '0px').show();
                    },
                    display: 'block',
                    mobileHA: true
                });
                old_title = ld('.trans-hander.old-title').css({
                    left: 0 + 'px',
                    opacity: 1
                }).velocity({
                    left: -title_direction * title_width + 'px',
                    opacity: 0
                }, {
                    duration: (duration - 100),
                    easing: trans_init.cv_css.easing,
                    complete: function (_this) {
                        old_title.css('left', -title_direction * title_width + 'px').hide();
                    },
                    display: 'none',
                    mobileHA: true
                });

            }
            c_viewobj.css({
                left: 0 + 'px',
                zIndex: trans_init.cv_css.zIndex,
                boxShadow: trans_init.cv_css.boxShadow
            }).velocity({// velocity 插件，写动画
                left: trans_init.cv_css.left
            }, {
                duration: duration,
                easing: trans_init.cv_css.easing,
                complete: function (_this) {
                    setTimeout(function () {
                        onTransformViewEnd(head_array, direction, options);
                        c_viewobj.remove();
                    }, init_delay);
                },
                display: 'none',
                delay: trans_init.cv_css.delay,
                mobileHA: true
            });
            to_viewobj.css({
                zIndex: trans_init.tv_css.zIndex,
                left: trans_init.tv_css.left,
                boxShadow: trans_init.tv_css.boxShadow
            }).velocity({// velocity 插件，写动画
                left: 0 + 'px'
            }, {
                duration: duration * 3 / 4,
                easing: trans_init.tv_css.easing,
                complete: function (_this) {
                    setTimeout(function () {
                        onTransformViewEnd(head_array, direction, options);
                        ld(_this).css({
                            position: 'relative',
                            boxShadow: 'none',
                            zIndex: 1
                        });
                    }, init_delay);
                },
                display: 'block',
                delay: trans_init.tv_css.delay,
                mobileHA: true
            });
        }
    };
    // 跳转页面之前执行的方法
    var onSwitchBefore = function (to_viewid, switch_type, options) {
        var opts = options,
            s_type = switch_type,
            t_vid = to_viewid;
        // 在刷新或加载时，清除上一个ajax请求
        if (SwiperObj.is_refreshPage ||
            SwiperObj.view_refreshing ||
            SwiperObj.is_addMore ||
            SwiperObj.more_loading ||
            is_datafetching) {
            EventHanderObj.stopAjax();
        }
        // 滚动条
        ld('.swiper-scrollbar.swiper-scrollbar-g').addClass('ui-hide');
        if (ld.isFunction(prev_Info.options.onExitBefore)) {
            prev_Info.options.onExitBefore();
            prev_Info.options.onExitBefore = null;
        }
        if (ld.isFunction(opts.onExitBefore)) {
            prev_Info.options.onExitBefore = opts.onExitBefore;
        }
        if (opts.__switch_type === 'init' && !options.__view_reset && !is_selfSwitch) {

            viewreset_stack[t_vid] = ld('#' + t_vid).html();
            //alert('记录html   ~'+t_vid);
        }
        // 关闭头部数据分类
        if (ld('#head_mid span:visible.select').length === 1) {
            logicHanderObj.headerDataClassify();
        }

        // 验证参数
        if (s_type !== 'back' && opts.__scroll_top === 'origin') {
            alert('只有 switchView 以 back 方式跳转时，才能设置origin属性！');
            return false;
        }

        // 设置页面 是否能够刷新
        if (!ld('#' + t_vid).hasClass('noscoll')) {
            if (opts.__refreshable === true) {
                SwiperObj.ListPageObj.addRefreshableView(t_vid);
            } else if (opts.__refreshable === false) {
                SwiperObj.ListPageObj.removeRefreshableView(t_vid);
            }
        }


        // 执行参数中的onSwitchBefore 方法
        if (ld.isFunction(opts['onSwitchBefore'])) {
            opts['onSwitchBefore']();
        }
    };
    // 页面退出时执行的方法
    var onExitAfter = function (options) {
        if (ld.isFunction(prev_Info.options.onExitAfter)) {

            prev_Info.options.onExitAfter();
            prev_Info.options.onExitAfter = null;
        }

        if (ld.isFunction(options.onExitAfter)) {
            prev_Info.options.onExitAfter = options.onExitAfter;
        }
        if (options.__switch_type === 'back' || options.__view_reset) {
            ld('#' + prev_Info.viewid).html(viewreset_stack[prev_Info.viewid]);
            //alert('还原html   ~'+prev_Info.viewid);
        }
    };
    // 定义ViewObj_beat全局对象 
    var view = {
        rootScope: {}, // 临时！！存储viwe信息,回到首页时清空数据
        // 设置头部
        setAppHeader: function (header_array) {
            ld('#app_header').html(createHeaderHtml(header_array, true));
            prev_Info.header = header_array;
            current_header = header_array;
        },
        // 获取view相关的信息
        getInfo: function (info) {
            var result = '';
            switch (info) {
                // 获取切换效果状态
                case 'transform_state':
                    if (ld('#temp_trans').length === 1) {
                        result = 'transforming';
                    } else {
                        result = 'transformend';
                    }
                    break;
                // 是否正在获取数据
                case 'is_datafetching':
                    result = is_datafetching;
                    break;
                // 上一个viewId       
                case 'prev_viewid':
                    result = prev_Info.viewid;
                    break;
                //  当前头部           
                case 'current_header':
                    result = current_header;
                    break;
                // 跳转页面 viewId
                case 'to_viewid':
                    result = toview_id;
                    break;
                // 上一个 头部      
                case 'prev_header':
                    result = prev_header;
                    break;
            }
            return result;
        },
        // 获得当前页面的view_id
        getCurrentViewId: function () {
            return current_viewId;
        },
        // 获得当前页面的前一个页面的信息
        getPrevInfo: function (info) {
            if (info === 'viewid' ||
                info === 'footerid' ||
                info === 'header') {

                return prev_Info[info];

            } else {
                alert('ViewObj.getPrevInfo("") ,传入参数出错！\n' +
                    '请选择其中一个：viewid/footerid/header');
            }
        },
        // 设置 某一个view的滚动条高度
        // __scoller_top只能设置将要跳转view 的滚动条高度
        setScrollTop: function (view_id, translate) {
            // 检查参数是否为非'',字符串
            /*if(!checkValid('viewid',getValidStr(view_id,'setScollTop')) ){
             return;
             }*/
            scoller_TopStack[view_id] = translate;
        },
        // 每次切换页面都要执行的操作
        toViewCommon: function (to_viewid, head_array, options) {
            // 检查参数to_viewid是否有效viewid、检查参数是否为非'',字符串
            /*if(!checkValid('viewid',getValidStr(to_viewid,'toViewCommon')) ){
             return;
             }*/
            var opts = ld.isPlainObject(options) ? options : {};

            if (!ld('#poplayerMask').is(':hidden')) {
                OperationObj.triggerCilckEvent(ld('#poplayerMask'));
            }
            // 跳转页面前需要记录一下，滚动条位置
            scoller_TopStack[current_viewId] = SwiperObj.homePage_swiper.getWrapperTranslate('y');

            // 当传入__app_header属性，则根据__app_header 修改头部
            if (ld.isArray(opts.__app_header)) {
                head_array = opts.__app_header
            } else if (!head_array) {
                alert('只有当参数中有__app_header时才可省略！');
            }
            if (!current_viewId) {
                is_selfSwitch = false;
                opts.__direction = 'none';

            } else if (current_viewId !== to_viewid) {
                is_selfSwitch = false;           // 标记为 “非自跳转”

            } else {
                is_selfSwitch = true;            // 标记为"自跳转"
                opts.__direction = 'none';
            }

            transformView(to_viewid, head_array, opts);

            prev_Info.header = head_array;
            prev_header = current_header;         // 记录跳转页面前“header”
            current_header = head_array;
            if (!is_selfSwitch) {
                prev_Info.viewid = current_viewId;  // 记录跳转前页面 
                current_viewId = opts.__to_viewid;  // 修改 跳转页面为当前页面
            }
            // 检查 当前页面 是否 需要滚动（不需要滚动则不需要检查是否刷新）
            if (opts.__direction === 'none' &&
                SwiperObj.isCurrentViewScrollable()) {

                SwiperObj.isCurrentViewRefreshable();  // 检查 将要跳转的页面 是否 需要刷新
                SwiperObj.autoHiddenAddMore();         // 自动隐藏 ‘更多’
            }

            var tempfooter = ld('#app-footer>div[is_show="true"]').attr('id');
            if (!is_selfSwitch) {
                prev_Info.footerid = tempfooter ? tempfooter : false;
            }
            ViewObj.switchFooter(tempfooter, 'hidden');
            PicturePreviewObj.clearPicturePreview();   // 清空图片预览缓存数据
        },
        // 跳转页面公共接口
        switchView: function (to_viewid, siwtch_type, opts_obj) {
            // 检查参数to_viewid是否合法viewid
            var t_vid = to_viewid;//checkValid('viewid',getValidStr(to_viewid,'switchView'));
            if (!t_vid) {
                alert('1.html没有id=' + to_viewid + '的页面！\n' + '2.没有在commonjs中Viewobj对象的all_viewsId添加' + to_viewid);
                return;
            }
            toview_id = t_vid;
            var opts = ld.isPlainObject(opts_obj) ? opts_obj : {},
                s_type = siwtch_type,//getValidStr(siwtch_type,'switchView'),
                create_switch_fn = ViewObj['create-' + t_vid],
                switch_fn = ViewObj['switch' + t_vid + s_type],
                opts = ld.extend({
                    __to_viewid: t_vid,
                    __switch_type: s_type
                }, opts);

            // 默认 自动添加自定义属性，用__no_deftOpts:true，取消添加默认属性。
            if (!opts.__no_dftOpts) {
                // 将自定义参数，与默认参数合并（自定义属参数可覆盖默认参数）
                opts = ViewObj.getFianlOpts(opts);
            }
            if (onSwitchBefore(t_vid, s_type, opts) === false) return;
            if (!ld.isFunction(switch_fn)) {
                // 不存在对应页面的switch方法时，创建switch方法（该步骤只在第一次跳转时执行）    
                if (ld.isFunction(create_switch_fn)) {
                    create_switch_fn(t_vid, s_type, {});

                    // 报错
                } else {
                    alert('没有创建' + t_vid + '的create-' + t_vid + '方法,请在对应页面的js中‘view.create-’处定义\n');
                    throw new Error('出错位置！');
                }
            }
            // 暴露 “页面切换”的接口（需要延迟执行“页面切换”时调用）
            ViewObj.delayExecSwitch = function () {
                // 没有网络，给出提示
                if (s_type === 'back') {
                    // 返回时，不需要显示刷新按钮
                    NetworkObj.showNetworkTips('body_tip', 'hide',
                        {
                            footerid: opts.__footer_id,
                            is_switchview: true
                        });
                }
                // 设置开始读取数据
                is_datafetching = true;
                // 执行页面跳转
                ViewObj['switch' + t_vid + s_type](opts);
            };
            // 当 __confirm_switch:true 显示“确定退出吗？”弹出框
            if (opts.__confirm_switch === true) {
                logicHanderObj.popUpMaskToggle('tplCancel');
            } else {
                ViewObj.delayExecSwitch();
            }
        },
        // 切换底部接口（每次页面切换都需要调用这个方法）
        switchFooter: function (footer_id, sh_type) {
            var f_obj = ld('#' + footer_id);
            // 明细页面底部--编辑按钮，需要特殊控制
            if (footer_id === 'crm-detail-footer' && sh_type === 'display') {
                if (f_obj.attr('editable') === 'true' && ld('#divDetailLabel .curr').attr('choosename') === "detailView") {
                    f_obj.attr('is_show', 'true').removeClass('ui-hide');
                }
                // 其他页面底部
            } else {
                if (sh_type === 'display') {
                    // 主页底部标签
                    if (footer_id === 'cwnm-main-footer') {
                        if (ViewObj.getCurrentViewId().indexOf('main') > -1) {
                            f_obj.attr('is_show', 'true').removeClass('ui-hide');
                            machineHanderObj.showMainBtn();
                        }
                    } else {
                        f_obj.attr('is_show', 'true').removeClass('ui-hide');
                    }
                } else if (sh_type === 'hidden') {
                    f_obj.attr('is_show', 'false').addClass('ui-hide');
                    // 主页底部标签
                    if (footer_id === 'cwnm-main-footer') machineHanderObj.hideMainBtn();
                }
            }
        },
        // 切换页面之后执行的方法（异步数据读取结束之后）
        onSwitchAfter: function (options) {
            // 设置状态
            is_getdataend = true; // 数据获取结束
            if (transform_state !== 'transformend') return;
            is_datafetching = false; // 关闭正在获取
            is_getdataend = false;   // 关闭数据获取结束  
            transform_state = 'none'; // 设置切换状态

            var opts = ld.isPlainObject(options) ? options : {},
                translate = typeof opts.translate === 'number' ? opts.translate : 0,
                fn = opts['onSwitchAfter'],
                footer_id = opts.__footer_id;//checkValid('footerid',opts.__footer_id);

            onExitAfter(opts);
            // console.log(ViewObj.rootScope.item_num+'---'+current_viewId+'---'+opts.__switch_type);
            // 显示详情页关联信息
            // if (ViewObj.rootScope.item_num > 0 && current_viewId === 'cwn-crmdetail-view' && opts.__switch_type === 'init') {
            //     getDetailRelation(ViewObj.rootScope.item_num, ViewObj.rootScope.max_textlen);
            // }
            // 执行 传入的 onSwitchAfter 方法
            if ($.isFunction(fn)) {
                fn();
            }
            // 显示底部
            ViewObj.switchFooter(footer_id, 'display');
            var content_hight = SwiperObj.CONTENT_HEIGHT,
                temp_height = 40;
            // 当连续跳转,底部不相同时
            // 或者头部有分类时   需要重新设置 ，内容显示高度

            if (!ld('#lineheadstatus').is(':hidden')) {
                content_hight -= 48;
            }
            // 如果该view有底部
            if (footer_id && !ld('#' + footer_id).is(':hidden')) {

                // 显示内容高度要减去底部高度
                temp_height = ld('#' + footer_id).offsetHeight;
                temp_height = temp_height >= 40 ? temp_height : 40; // 设置底部默认值 48
                temp_height = current_viewId === 'work-release-view' ? 90 : temp_height;
                content_hight -= temp_height;
                SwiperObj.SWIPER_HOLDER.height(content_hight);
            }
            if (!is_selfSwitch) {
                prev_Info.footerid = footer_id; // 记录当前footerid
            }

            // 当选项对象中带有 origin时，滚动条返回到之前的位置
            // console.log(scoller_TopStack[current_viewId]+'#'+current_viewId);
            if (opts.__scroll_top === 'origin') {
                var h = scoller_TopStack[current_viewId];
                if (typeof h === 'number') {
                    translate = h;
                }
            }
            ld('.swiper-scrollbar.swiper-scrollbar-g').removeClass('ui-hide');
            // 调整滚动高度并设置滚动条位置
            SwiperObj.autoHeight(translate);
            ld('.swiper-scrollbar.swiper-scrollbar-g').animate({'opacity': 0}, 200);
            // 进入news work me crm 首页时 清空所有值
            if (current_viewId && current_viewId.indexOf('main') !== -1) {
                scoller_TopStack = {};
                viewreset_stack = {};
            }
            // 加载完数据后，自动隐藏更多
            if (SwiperObj.is_currentViewRefreshable) {
                SwiperObj.autoHiddenAddMore();
            }
            //部分手机特殊控制  
            if (ViewObj.getCurrentViewId() === 'crm-main-view') {
                ld(".crm-homelists li:active").css('background-color', '#fdfdfd');
            }
            if (ViewObj.getCurrentViewId() === 'crm-list-view') {
                ld(".crm-lists li:active").css('background-color', '#fdfdfd');
            }
            if (ViewObj.getCurrentViewId() === 'me-main-view') {
                ld(".me-homelists li:active").css('background-color', '#fdfdfd');
            }
        },
        // 动态创建view
        createView: function (options) {
            var new_viewid = options.viewid,
                tpl_html = '<div id="' + new_viewid + '" class="swiper-slide ui-hide"></div>';
            if (!new_viewid) {
                alert('createView必须传入 new_viewid参数');
            }
            all_viewsId.crm_work_news += (',' + new_viewid);

            if (!ld('#' + new_viewid).length) {
                if (options.refreshable) {
                    ld(tpl_html).insertAfter(ld('#list-refresh-holder'));
                } else {
                    ld(tpl_html).insertAfter(ld('#adjust-head-holder'));
                }
            } else {
                ld('#new_viewid').html('');
            }

            ViewObj['create-' + new_viewid] = function (to_viewid, switch_type, scope) {
                ViewObj['switch' + new_viewid + 'back'] = function (opts_obj) {
                    ViewObj.toViewCommon(new_viewid, scope.current_header, opts_obj);
                    if (ld.isFunction(options.backFun)) {
                        options.backFun(function () {
                            ViewObj.onSwitchAfter(opts_obj);
                        });
                    } else {
                        ViewObj.onSwitchAfter(opts_obj);
                    }
                };
                ViewObj['switch' + new_viewid + 'init'] = function (opts_obj) {
                    ViewObj.toViewCommon(new_viewid, options.app_header, opts_obj);
                    scope.prev_header = ViewObj.getInfo('prev_header');
                    scope.prev_viewid = ViewObj.getPrevInfo('viewid');
                    scope.prev_footerid = ViewObj.getPrevInfo('footerid');
                    scope.current_header = ViewObj.getInfo('current_header');
                    if (ld.isFunction(options.initFun)) {
                        options.initFun(opts_obj);
                    }
                };
                ViewObj[new_viewid + '-header-click'] = function (targetobj, clickOpts) {
                    var t_id = clickOpts.target_id,
                        _this = null;
                    if (t_id === 'head_left') {// 头部左边
                        if (ld.isFunction(options.headerLeftBt)) {
                            options.headerLeftBt();
                        }
                        ViewObj.switchView(scope.prev_viewid, 'back', {
                            __app_header: scope.prev_header,
                            __footer_id: scope.prev_footerid,
                            __scroll_top: 'origin'
                        });

                    } else if (t_id === 'head_rig') {// 头部右边
                        if (ld.isFunction(options.headerRightBt)) {
                            options.headerRightBt(function () {
                                ViewObj.onSwitchAfter(opts_obj);
                            });
                        }
                    }
                };
                ViewObj[new_viewid + '-body-click'] = function (targetobj, clickOpts) {
                    if (ld.isFunction(options.bodyClick)) {
                        options.bodyClick(targetobj);
                    }
                };
                ViewObj[new_viewid + '-footer-click'] = function (targetobj, clickOpts) {
                    if (ld.isFunction(options.footerClick)) {
                        options.footerClick(targetobj);
                    }
                };
            };
        }
    };
    //返回全局 ViewObj_beat对象
    return view;
})();
// 在跳转页面前，要在这里由基础参数构造一个完整的参数
ViewObj.getFianlOpts = function (options) {
    var opts = options,
        s_type = opts.__switch_type,
        view_id = opts.__to_viewid,
        view_name = opts.view_name,
        target_obj = opts.target_obj,
        default_obj = {},
        eventType = ['onSwitchBefore',
            'onSwitchAfter',
            'onExitBefore',
            'onExitAfter'];
    if (view_id.indexOf('main') > -1) {
        ViewObj.rootScope = {}; // 清空之前保存的临时数据
        default_obj.__footer_id = 'cwnm-main-footer';
        if (view_id.indexOf('work') > -1) { // 每次跳转到 work首页时需要、给头部右边添加一个属性
            default_obj.onSwitchAfter = function () {
                ld('#app_header>.head-rig>a').attr('tag', 'workAdd');
            };
            default_obj.onExitAfter = function () {
                //if(NetworkObj.isOnline()){
                ld('#workDataClassify').addClass('ui-hide');
                //}
            }
        }
    } else {
        switch (view_id) {
            case 'cwn-popuselect-view':
                switch (view_name) {
                    case 'drop_down_list':
                        if (target_obj && target_obj.length > 0) {
                            default_obj = getDropDownList(target_obj);
                        }
                        break;
                    case 'choose_module':
                        if (target_obj && target_obj.length > 0) {
                            default_obj = getChooseModule(target_obj);
                        }
                        break;
                    case 'submit_approve':
                        default_obj = getSubmitApprove();
                        break;
                    case 'users_list':
                        var user_searchObj = {};
                        user_searchObj.return_module = opts.return_module;
                        user_searchObj.searchtype = opts.searchtype;
                        user_searchObj.filterown = opts.filterown;
                        user_searchObj.scopetype = opts.scopetype;
                        user_searchObj.common = opts.common;
                        user_searchObj.isactive = opts.isactive;
                        user_searchObj.popup_type = opts.popup_type;
                        default_obj = getChooseUserList(user_searchObj);
                        break;
                    case 'nextApproval_user_list':
                        default_obj = getNextApprovalUserList();
                        break;
                    case 'nextApproval_step_list':
                        default_obj = getNextApprovalStepList(target_obj.attr('items'));
                        break;
                    case 'comment_execution_list':
                        var user_searchObj = {};
                        user_searchObj.return_module = opts.return_module;
                        user_searchObj.searchtype = opts.searchtype;
                        user_searchObj.filterown = opts.filterown;
                        user_searchObj.scopetype = opts.scopetype;
                        user_searchObj.common = opts.common;
                        user_searchObj.isactive = opts.isactive;
                        default_obj = getCommentExecutionList(user_searchObj, opts.list_name);
                        break;
                    case 'acct_cont_pro_relationlist':
                        default_obj = getAcctContProRelationList(opts.list_name, opts.w_r_modulename);
                        break;
                }
                break;
            case 'cwn-popuedit-view':
                switch (view_name) {
                    case 'me_updateinfo':
                        if (target_obj && target_obj.length > 0) {
                            default_obj = getMeUpdateInfo(opts.update_type);
                        }
                        break;
                }
                break;
            case 'cn-approval-view':
                if (s_type === 'init') {
                    if (opts.view_name === 'approval') {
                        default_obj.title_str = '审批';
                    } else {
                        default_obj.title_str = '反审批';
                    }
                }
                break;
            case 'cwn-crmdetail-view':
                if (category === 'crm') {
                    default_obj.__footer_id = 'crm-detail-footer';
                }
                break;
            case 'wn-replayforword-view':
                default_obj.__init_delay = 0;
                default_obj = {
                    onSwitchAfter: function () {
                        var inputs = ld('#wn-replayforword-view textarea');
                        autosize(inputs);//textarea根据内容自动调整大小
                        ld('#replycontent').focus();
                    }
                };
                break;
            case 'crm-createedit-view':
                if (module === 'Expense' && (view_name === 'create' || view_name === 'edit')) {
                    default_obj.__footer_id = 'crm-addexpense-footer';
                } else if (newmodule === 'Expense' && view_name === 'relationcreate') {
                    default_obj.__footer_id = 'crm-addexpense-footer';
                } else if (module === 'Approve' && view_name === 'edit') {
                    var a_module = ViewObj.rootScope.approvemodule;
                    if( a_module == 'SalesOrder' || a_module == 'Quotes' ||
                        a_module == 'ServiceContracts' || a_module == 'PurchaseOrder'){
                        default_obj.__footer_id = 'crm-addproduct-footer';
                    }
                    if( a_module == 'Expense'){
                        default_obj.__footer_id = 'crm-addexpense-footer';
                    }
                    if( a_module == 'AddJobBill' || a_module == 'MinusJobBill' ||
                        a_module == 'BusinessApply' || a_module == 'Commission'){
                        default_obj.__footer_id = 'crm-addoadetail-footer';
                    }
                }  else if ((module == 'SalesOrder' ||
                    module == 'Quotes' ||
                    module == 'ServiceContracts' ||
                    module == 'PurchaseOrder') && (view_name === 'create' || view_name === 'edit')) {
                    default_obj.__footer_id = 'crm-addproduct-footer';
                } else if ((newmodule == 'SalesOrder' ||
                    newmodule == 'Quotes' ||
                    newmodule == 'ServiceContracts' ||
                    newmodule == 'PurchaseOrder') && view_name === 'relationcreate') {
                    default_obj.__footer_id = 'crm-addproduct-footer';
                } else if ((module == 'AddJobBill' ||
                    module == 'MinusJobBill' ||
                    module == 'BusinessApply' ||
                    module == 'Commission') && (view_name === 'create' || view_name === 'edit')) {
                    default_obj.__footer_id = 'crm-addoadetail-footer';
                } else {
                    default_obj.__footer_id = '';
                }
                break;
            case 'cwn-sendrang-view':
                if (category === 'news' || category === 'work') {
                    default_obj.__footer_id = 'wn-choosenview-footer';
                }
                break;
            case 'work-release-view':
                default_obj = {
                    onSwitchAfter: function () {
                        var inputs = ld('#work-release-view textarea');
                        autosize(inputs);//textarea根据内容自动调整大小
                        logicHanderObj.getFocus(inputs.eq(0).attr('id'));//获取焦点   
                    },
                    onSwitchBefore: function () {
                        ld('body,#home-page').css({'backgroundColor': '#fff'});
                    },
                    onExitBefore: function () {
                        ld('body,#home-page').css({'backgroundColor': '#F5F8F9'});
                    },
                    onExitAfter: function () {
                        // 从发布页进入work首页时，清空缓存值
                        if (ViewObj.getCurrentViewId() === 'work-main-view') {
                            logicHanderObj.toClear(); // 工作返回清空值
                        }
                    }
                };
                break;
            case 'me-feedback-view':
                default_obj.onExitAfter = function () {
                    if (ViewObj.getCurrentViewId() === 'me-main-view') {
                        ld('#me-feedback-footer').css({'backgroundColor': '#bdbdbd'});
                    }
                };
                default_obj.onSwitchAfter = function () {
                    autosize(ld('#me-feedback-view textarea'));
                    logicHanderObj.getFocus('feedBackContent');//获取焦点  
                    if (ViewObj.getInfo('prev_viewid') === 'me-main-view') {
                        var full_text = '',
                            flag = false;
                        ld('#feedBackContent').on('paste', function () {
                            flag = true;
                        });
                        ld('#feedBackContent').on('input propertychange', function () {
                            if (ld(this).val().length <= 300) {
                                ld('#me-feedback-view i[tag=cur-cunt]').html(ld(this).val().length);
                                if (ld(this).val().length === 300) {
                                    full_text = ld('#me-feedback-view textarea').val();
                                }
                            } else {
                                full_text = ld('#me-feedback-view textarea').val().substr(0, 300);
                                ld('#me-feedback-view i[tag=cur-cunt]').html('300');
                                ld('#me-feedback-view textarea').val(full_text);
                            }
                            autosize(ld('#me-feedback-view textarea'));
                            if (empty(ld(this).val())) {
                                ld('#me-feedback-footer').css({'backgroundColor': '#bdbdbd'});
                            } else {
                                ld('#me-feedback-footer').css({'backgroundColor': '#55acef'});
                            }
                        });
                    }
                };
                break;
        }
    }
    callBackBind(eventType);
    // 构造最终的参数
    return ld.extend(true, default_obj, options);

    function callBackBind(eventTypeAr) {
        ld.each(eventTypeAr, function (index, value) {
            options[value] = (function (fun_name) {
                var result = origin = ld.isFunction(opts[fun_name]) ? opts[fun_name] : null,
                    def = null;
                if (ld.isFunction(default_obj[fun_name])) {
                    def = default_obj[fun_name];
                    result = function () {
                        if (ld.isFunction(def)) def();
                        if (ld.isFunction(origin)) origin();
                        def = null, origin = null;
                    };
                }
                return result;
            })(value);
        });
    };
    // 弹出下拉框选择列表
    function getDropDownList(_this) {
        return {
            __init_delay: 0,
            __refreshable: false,
            title_str: _this.attr('title_str'),
            select_mode: _this.attr('select_mode'),
            show_search: _this.attr('show_search') === 'true' ? true : false,
            choose_style: 'v',
            auto_back: true,
            multi_autotoggle: true,
            search_obj: {
                parent_obj: ld('#cwn-popuselect-view>.top-wrapper'),
                value_text: '',
                tip_text: '请输入' + _this.attr('title_str'),
                searchFun: function (searchstr, callback) {
                    var content_hoder = ld('#cwn-popuselect-view>.content-wrapper');
                    if (!searchstr) {
                        PopPromptBox.show('请输入搜索条件!');
                        content_hoder.find('li').show();

                    } else {
                        content_hoder.find('li').each(function () {
                            if (ld(this).text().indexOf(searchstr) > -1) {
                                ld(this).show();
                            } else {
                                ld(this).hide();
                            }
                        });
                        if (content_hoder.find('li:visible').length === 0) {
                            PopPromptBox.show('未找到选项!');
                            content_hoder.find('li').show();
                        }
                    }
                    callback();
                }
            },
            initFun: function (callback) {
                var origin_value = _this.html(),
                    select_mode = _this.attr('select_mode'),
                    items_str = _this.attr('items');

                var list_str = '<ul>',
                    itemsArray = items_str.split('|##|'),
                    _isother = [],
                    option = [],
                    content_hoder = ld('#cwn-popuselect-view>.content-wrapper');
                content_hoder.addClass(_this.attr('popu_select'));
                for (var i = 0; i < itemsArray.length - 1; i++) {

                    if (itemsArray[i].toString()) {

                        option = itemsArray[i].split('&&');

                        if (option[0].toString()) {
                            if (option[1] !== '其他') {
                                //option[0]为值 option[1]名称
                                if (empty(option[2])) {
                                    list_str += '<li class="text-ellipsis " tag="' +
                                        option[0] + '" item="popu_select">' + option[1] + '</li>';
                                }
                                else {
                                    list_str += '<li class="text-ellipsis " tag="' +
                                        option[0] + '" item="popu_select" rate="' + option[2] + '">' + option[1] + '</li>';
                                }
                            } else {
                                _isother[0] = option[0];
                                _isother[1] = option[1];
                            }
                        }
                    }
                }
                if (_isother.length > 0) {
                    list_str += '<li item="popu_select" tag="' + _isother[0] + '">' +
                        _isother[1] + '</li>';
                }
                list_str += '</ul>';
                content_hoder.html(list_str); //插入选项列表值
                if (select_mode == 'single') {//单选框
                    if (origin_value) {
                        content_hoder.find('li').each(function () {
                            if (ld(this).text() === origin_value) {
                                ld(this).attr('init_item', 'true');
                            }
                        });
                    }
                    //多选框
                } else {
                    content_hoder.find('li').addClass('lnr lnr-square');
                    if (origin_value) {
                        var _valarray = origin_value.split(',');
                        for (var i = 0; i < _valarray.length; i++) {
                            if (_valarray[i]) {
                                content_hoder.find('li').each(function () {
                                    if (ld(this).text() === _valarray[i]) {
                                        ld(this).removeClass('lnr-square').addClass('lnr lnr-checkmark-square');
                                    }
                                });
                            }
                        }
                    }
                }
                callback();
            },
            itemFun: function (target_item, related_obj) {
                if (!NetworkObj.isOnline()) {
                    NetworkObj.showNetworkTips('head_tip', 'show');
                    return;
                } else {
                    NetworkObj.showNetworkTips('all', 'hide');
                }
                var related_b = related_obj,
                    _this = target_item;
                related_b.html(_this.text());
                related_b.attr('tag', _this.attr('tag'));
                // 是货币类型 要执行关联转化操作
                if (related_b.attr('uitype') == '117') {
                    getCurrencyRateAmounts();
                    related_b.val(_this.attr('tag'));
                }
                else if (related_b.attr('name') == 'inventory_currency') {
                    currencyChoose();
                }
                else if (related_b.attr('name') == 'select_entitytypeid' || related_b.attr('name') == 'select_entitytype') {//选择源单类型
                    ld('#entitytypeid').val('');
                    ld('#entitytypeidname').html('');
                    ld("#entitytypeidname").attr({choose_module: _this.attr('rate'), flid_lable: _this.text()});
                }
                else if (_this.attr('rate') != '' && _this.attr('rate') != undefined) {
                    var e_module = module;
                    if(module == 'Approve'){
                        e_module = ViewObj.rootScope.approvemodule;
                    }
                    if (e_module === 'Expense' && ld('#conversion_rate').length === 1) {
                        ld('#conversion_rate').val(_this.attr('rate'));
                        ld('#conversion_rate').change();
                    }
                }
                else { // 查看联动 
                    // alert(related_b.attr('id')+'---'+_this.text());
                    pickListChoose(related_b.attr('id'), _this.text());
                    if (ViewObj.getPrevInfo('viewid') === 'crm-photo-view') {
                        ld('#photovalueid').html('');
                        ld('#photovalueName').html('请点击选择');
                    }
                }
            },
            headerRigBtFun: function (related_obj) {
                var choosen_str = '',
                    checkbox_choosen_str = '';
                ld('#cwn-popuselect-view>.content-wrapper li').each(function () {
                    if (ld(this).hasClass('lnr-checkmark-square')) {
                        if (related_obj.attr('select_mode') === 'multi') {
                            choosen_str += ld(this).html() + ',';
                            checkbox_choosen_str += ld(this).html() + ' |##| ';
                        }
                        else {
                            choosen_str += ld(this).html() + ',';
                        }
                    }
                });
                if (!choosen_str) {
                    PopPromptBox.show('未选择任何选项!');
                } else {
                    related_obj.html(choosen_str.substring(0, choosen_str.length - 1));
                    if (related_obj.attr('select_mode') === 'multi') {
                        related_obj.attr('chossen_items', checkbox_choosen_str.substring(0, checkbox_choosen_str.length - 6));
                    }
                }
            }
        }
    }

    // 选择相关模块选择列表
    function getChooseModule(_this) {
        searchcontentDetail = ''; //  全局变量赋值
        fieldStr = _this.attr('fild_id'); //  全局变量赋值
        popmodule = _this.attr('desc');       //  全局变量赋值
        fieldNameStr = _this.attr('flid_lable'); //  全局变量赋值
        moduleNameStr = _this.attr('choose_module');   // 全局变量赋值
        var parentstatus = _this.attr('parentstatus');
        ViewObj.rootScope.parentstatus = parentstatus;
        var options = {
            __refreshable: true,
            title_str: '选择' + fieldNameStr,
            select_mode: 'single',
            show_search: true,
            choose_style: '',
            auto_back: true,
            multi_autotoggle: false,
            search_obj: {
                parent_obj: ld('#cwn-popuselect-view>.top-wrapper'),
                value_text: '',
                tip_text: '请输入' + fieldNameStr,
                searchFun: function (searchstr, callback) {
                    if(moduleNameStr == 'Users' || moduleNameStr == 'ShareUsers' || moduleNameStr == 'UsersMore'){
                        var item_num = 0,
                        searchstrValue = searchstr.toLowerCase();
                        ld('#cwn-popuselect-view li').each(function (index, el) {
                            var _this = ld(this),
                                eachValue = _this.find('i').html().toLowerCase();
                            if (eachValue.indexOf(searchstrValue) > -1) {
                                item_num++;
                                if (item_num === 1) {
                                    ld('#cwn-popuselect-view .no_message_tip').remove();
                                }
                                _this.show();
                            } else {
                                _this.hide();
                            }
                        });
                        if (!item_num) {
                            var listhtml = logicHanderObj.NoinfoNotice('数据');
                            ld('#cwn-popuselect-view .no_message_tip').remove();
                            ld('#cwn-popuselect-view .content-wrapper').append(listhtml);
                        }
                        callback();
                    }
                    else{
                        searchcontentDetail = searchstr; // 全局变量赋值
                        SwiperObj.ListPageObj.setListPageIndex(1);
                        EventHanderObj.refreshAjax(function () { // 刷新
                            callback();
                        });
                    }
                }
            },
            initFun: function (callback) {
                //显示选择列表
                var urlstring = 'module=' + popmoduleName + '&action=Pop' + popmoduleName +
                    '&searchcontent=' + searchcontentDetail;
                if (moduleNameStr != 'Users') {
                    urlstring += '&page=1';
                }
                if (popmodule == 'photo' || popmodule == 'sign') {
                    urlstring += '&noprfiledata=true';
                }
                ViewObj.rootScope.productsstatus = 'no';
                if (moduleNameStr != 'Accounts' &&
                    GVObj.crmObj.parentid > 0 &&
                    parentstatus === 'yes') {
                    urlstring += '&parentid=' + GVObj.crmObj.parentid;
                    ViewObj.rootScope.productsstatus = 'yes';
                }
                var keywords = '';
                var keyids = '';
                if (module != moduleNameStr) {
                    if (moduleNameStr == 'Accounts' && module == 'Accounts') {
                        if (ld('#account_idname').html() != '' && ld('#account_idname').html() != '0') {
                            keywords = ld('#account_idname').html();
                        }
                    } else {
                        if (module == "SalesOrder" && moduleNameStr == 'SalesOrder') {

                        } else if (ld('#account_id') != "undefined" && ld('#account_id') != undefined) {
                            if (ld('#account_id').val() != '' && ld('#account_id').val() != 0 && ld('#account_id').val() != undefined)
                                keyids = ld('#account_id').val();
                        }
                    }
                }
                if (moduleNameStr == 'PurchaseOrder' || moduleNameStr == 'VendorContact') {
                    if (ld('#vendor_id').val() != undefined) {
                        if (ld('#vendor_id').val() != '' && ld('#vendor_id').val() != 0)
                            keyids = ld('#vendor_id').val();
                    }
                }
                if (moduleNameStr == 'Contacts') {
                    if (ld('#contact_idname') != undefined) {
                        if (ld('#contact_idname').html() != '' && ld('#contact_idname').html() != 0 && ld('#contact_idname').html() != undefined) {
                            keywords = ld('#contact_idname').html();
                        }
                    }
                    if (ld('#account_id') != undefined && ld('#account_id').val() != undefined)
                        keyids = ld('#account_id').val();
                }
                // alert(ViewObj.rootScope.mode+'---'+module + '---' +newmodule)
                if(ViewObj.rootScope.mode === 'relationcreate'){
                    urlstring += '&frommodule=' + newmodule;
                }
                else{
                    urlstring += '&frommodule=' + module;    
                }
                urlstring += '&keyids=' + keyids + '&keywords=' + keywords;
                if(moduleNameStr == 'ShareUsers'){
                    urlstring = 'module=Users&action=changeShareUser&method=getShareUser&scopetype=user&searchcontent=&searchtype=byscope&filterrecordid=' + recordID;
                    getShareUsersList(urlstring, function () {
                        callback();
                    })
                }
                else{
                    getChooseModuleList(urlstring, function () {
                        callback();
                    });
                }
            },
            itemFun: function (target_item, related_obj) {
                chooseModuleFun(target_item.attr('user_id'), target_item.attr('user_name'));
            },
            headerRigBtFun: function (related_obj) {

            }
        };

        var popmoduleName = moduleNameStr;
        //显示  
        if (fieldStr == 'salesorder_id'
            && (module == 'Expense' || newmodule == 'Expense' || module == 'Project' || newmodule == 'Project')) {//选择原单
            options.__app_header = ['<', '', 'v', '选择合同订单', '', ''];
            var categoryhtml = '<li name="合同订单" title="SalesOrder">合同订单</li>' +
                '<li name="服务合同" title="ServiceContracts">服务合同</li>';
            ld('#sub_menulists').html(categoryhtml);
            options.search_obj.tip_text = '请输入合同订单';
        }
        if (moduleNameStr == 'UsersMore' || moduleNameStr == 'ShareUsers') {
            popmoduleName = 'Users';
            options.select_mode = 'multi';
            options.headerRigBtFun = function (related_obj) {
                if(moduleNameStr == 'UsersMore'){
                    if(module == 'PublicAnnouncement'){
                        if (empty(choose_pa_usersidobj)) {
                            PopPromptBox.show('至少选择一个选项');
                            return false;
                        }
                        var recipientids = '';
                        ld.each(choose_pa_usersidobj, function (key, id) {
                            recipientids += choose_pa_usersidobj[key] + ',';
                        });
                        var recipientnames = '';
                        ld.each(choose_pa_usersnameobj, function (key, id) {
                            recipientnames += choose_pa_usersnameobj[key] + ',';
                        });
                        ld('#' + related_obj.attr('id').replace(/name$/, '')).val(recipientids.substring(0, recipientids.length - 1));
                        related_obj.html(recipientnames.substring(0, recipientnames.length - 1));
                        sessionStorage.setItem('storage_users_pa_id', JSON.stringify(choose_pa_usersidobj));
                        sessionStorage.setItem('storage_users_pa_name', JSON.stringify(choose_pa_usersnameobj));
                        return true;
                    }
                    if(module == 'BusinessApply'){
                        if (empty(choose_ba_usersidobj)) {
                            PopPromptBox.show('至少选择一个选项');
                            return false;
                        }
                        var peerpersonsids = '';
                        ld.each(choose_ba_usersidobj, function (key, id) {
                            peerpersonsids += choose_ba_usersidobj[key] + ',';
                        });
                        var peerpersonsnames = '';
                        ld.each(choose_ba_usersnameobj, function (key, id) {
                            peerpersonsnames += choose_ba_usersnameobj[key] + ',';
                        });
                        ld('#' + related_obj.attr('id').replace(/name$/, '')).val(peerpersonsids.substring(0, peerpersonsids.length - 1));
                        related_obj.html(peerpersonsnames.substring(0, peerpersonsnames.length - 1));
                        sessionStorage.setItem('storage_users_ba_id', JSON.stringify(choose_ba_usersidobj));
                        sessionStorage.setItem('storage_users_ba_name', JSON.stringify(choose_ba_usersnameobj));
                        return true;
                    }
                }
                else if(moduleNameStr == 'ShareUsers'){
                    // Tools.print_array(choose_shared_useridobj);
                    if (empty(choose_shared_useridobj)) {
                        PopPromptBox.show('至少选择一个选项');
                        return false;
                    }
                    if(module == 'NearbyAccounts'){
                        module = 'Accounts';
                    }
                    //删除数组中空值
                    for(var i = 0 ;i<choose_shared_useridobj.length;i++)
                    {
                        if(choose_shared_useridobj[i] == "" || typeof(choose_shared_useridobj[i]) == "undefined")
                        {
                            choose_shared_useridobj.splice(i,1);
                            i= i-1;
                        }
                    }
                    //保存共享人
                    var useridall = choose_shared_useridobj.join(',');
                    var urlstring = 'module=Users&action=changeShareUser&frommodule=' + module +
                                    '&method=setShareUser&recordall=' + recordID + '&useridall=' + useridall;
                    WordReportAjax(urlstring, function (rest) {
                        ld('#rellist_' + related_id).find('i').html(choose_shared_useridobj.length);
                        ViewObj.switchView('cwn-relationlist-view', 'init', {
                            'module': newmodule,
                            'label': newmodulename,
                            'is_related_module': relatedmodule,
                            'record': relatedrecord,
                            'relatedid': related_id
                        });
                    });
                }
            };
        }
        ViewObj.rootScope.title_str = options.title_str;
        return options;
    }

    // 获取提交审批人选择列表
    function getSubmitApprove() {
        return {
            __refreshable: false,
            title_str: '选择审批流程',//提交审批
            select_mode: 'single',
            show_search: false,
            choose_style: 'o',
            auto_back: false,
            right_str: '确定',
            initFun: function (callback) {
                var urlstring = 'module=Approve&action=SubmitApprove&fld_module=' +
                    module + '&record=' + recordID + '&check=false&save=false';
                WordReportAjax(urlstring, function (rest) {
                    var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                    if (restobj.code == -1) {
                        PopPromptBox.show('您没有适用的审批流程，请联系管理员检查并设置审批流程');
                        return false;
                    } else {
                        var approvehtml = '<ul>';
                        ld.each(restobj.result.list, function (key, list) {
                            approvehtml += '<li tag="' + list.approveid + '"' + 'item="popu_select">' + list.approvename + '</li>';
                        });
                        approvehtml += '</ul>';
                    }
                    ld('#cwn-popuselect-view>.content-wrapper').html(approvehtml);
                    callback();
                });
            },
            headerRigBtFun: function (target_item, related_obj) {
                var approvelistid = target_item.attr('tag'),
                    urlstring = '';
                //判断是否有下一个审批人
                urlstring = 'module=Approve&action=SubmitApprove' +
                            '&getnextstepinfo=' + approvelistid + '&approve_recordid=' + recordID;
                WordReportAjax(urlstring, function (rest) {
                    var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                    if (restobj.code == -1) {
                        PopPromptBox.show(restobj.msg);
                        return false;
                    }
                    else{
                        urlstring = 'module=Approve&action=SubmitApprove&fld_module=' + module +
                                    '&approvevalue=' + approvelistid + '&record=' + recordID + '&check=false&save=true';
                        WordReportAjax(urlstring, function (rest) {
                            ViewObj.rootScope.loadCrmdetail({__direction: 'right_out'});
                        });
                        return false;
                    }
                });
            }
        }
    }

    // 获取用户选择列表
    function getChooseUserList(user_searchObj) {
        return {
            __refreshable: false,
            title_str: '选择同事',
            select_mode: 'single',
            show_search: true,
            auto_back: false,
            search_obj: {
                parent_obj: ld('#cwn-popuselect-view>.top-wrapper'),
                value_text: '',
                tip_text: '请输入姓名',
                searchFun: function (searchstr, callback) {
                    var item_num = 0,
                        searchstrValue = searchstr.toLowerCase();
                    ld('#cwn-popuselect-view li').each(function (index, el) {
                        var _this = ld(this),
                            eachValue = _this.find('i').html().toLowerCase();
                        if (eachValue.indexOf(searchstrValue) > -1) {
                            item_num++;
                            if (item_num === 1) {
                                ld('#cwn-popuselect-view .no_message_tip').remove();
                            }
                            _this.show();
                        } else {
                            _this.hide();
                        }
                    });
                    if (!item_num) {
                        var listhtml = logicHanderObj.NoinfoNotice('数据');
                        ld('#cwn-popuselect-view .no_message_tip').remove();
                        ld('#cwn-popuselect-view .content-wrapper').append(listhtml);
                    }
                    callback();
                }
            },
            initFun: function (callback) {
                getUserList(user_searchObj, callback);//获取用户信息、搜索用户信息
            },
            itemFun: function (target_item, related_obj) {
                if (!NetworkObj.isOnline()) {
                    NetworkObj.showNetworkTips('head_tip', 'show');
                    return;
                } else {
                    NetworkObj.showNetworkTips('all', 'hide');
                }
                var username = target_item.find('i').html(),
                    chooseuserid = target_item.attr('tag').replace('user', ''),
                    urlstring = '';

                if(user_searchObj.popup_type==='publicallocate'){
                    //选中
                    target_item.find('.img-circle').find('i').removeClass('lnr-circle').addClass('lnr-circle-solid');
                    urlstring = 'module=Accounts&action=AllocateAccount&allocatetype=2&maxaccount=1&record=' + recordID + '&allocate_userid=' + chooseuserid;
                    WordReportAjax(urlstring, function (rest) {
                        if (rest == '') return false;
                        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                        if (restobj.code == 1) {
                            PopPromptBox.show({
                                main_text: '确定是否将【' + ViewObj.rootScope.entitynamevlaue + '】<br/> 分配给【' + username + '】？',
                                btn_type: 'yesno',
                                yes_fun: function () {
                                    urlstring = 'module=Accounts&action=AllocateAccount&allocatetype=2&idstring=' + recordID + '&allocate_userid=' + chooseuserid;
                                    WordReportAjax(urlstring, function (rest) {
                                        if (rest == '') return false;
                                        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                                        //分配成功
                                        if (restobj.code == 1) {
                                            var urlstring = 'module=Accounts';
                                            var urlstringcheck = urlstring + '&action=DetailView&CheckPermitted=yes&record=' + recordID + '&mode=detail&approvepage=no';
                                            WordReportAjax(urlstringcheck, function (rest) {
                                                if (empty(rest)) return false;
                                                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                                                if (restobj.code != -1) {
                                                    ViewObj.rootScope.loadCrmdetail = function (options) {
                                                        ViewObj.switchView('cwn-crmdetail-view', 'init', ld.extend({
                                                            'url_string': urlstring
                                                        }, options));
                                                    };
                                                    ViewObj.rootScope.loadCrmdetail();
                                                } else {
                                                    ViewObj.switchView('crm-list-view', 'init');
                                                    ld("#status").hide();
                                                    return;
                                                }
                                            });  
                                        }
                                        //分配失败
                                        else{
                                            PopPromptBox.show(restobj.msg);
                                            return false;
                                        }
                                    });
                                },
                                no_fun: function () {
                                    //取消选中
                                    target_item.find('.img-circle').find('i').removeClass('lnr-circle-solid').addClass('lnr-circle');
                                }
                            });
                        } else {
                            PopPromptBox.show(restobj.msg);
                            return false;
                        }
                    });
                }
                else{
                    //选中
                    target_item.find('.img-circle').find('i').removeClass('lnr-circle').addClass('lnr-circle-solid');
                    urlstring = 'module=Users&action=ChangeCreatorInfo&setype=save&from_module=' + module +
                        '&changetype=Allocate&mode=detail&select_id=' + recordID + '&caterorid=' + chooseuserid;
                    PopPromptBox.show({
                        main_text: '确定是否将【' + ViewObj.rootScope.entitynamevlaue + '】<br/> 分配给【' + username + '】？',
                        btn_type: 'yesno',
                        yes_fun: function () {
                            WordReportAjax(urlstring, function (rest) {
                                if (rest == '') return false;
                                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);     
                                //分配成功
                                if (restobj.code == 1) {
                                    var urlstring = 'module=' + module;
                                    var urlstringcheck = urlstring + '&action=DetailView&CheckPermitted=yes&record=' + recordID + '&mode=detail&approvepage=no';
                                    WordReportAjax(urlstringcheck, function (rest) {
                                        if (empty(rest)) return false;
                                        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                                        if (restobj.code != -1) {
                                            ViewObj.rootScope.loadCrmdetail = function (options) {
                                                ViewObj.switchView('cwn-crmdetail-view', 'init', ld.extend({
                                                    'url_string': urlstring
                                                }, options));
                                            };
                                            ViewObj.rootScope.loadCrmdetail();
                                        } else {
                                            ViewObj.switchView('crm-list-view', 'init');
                                            ld("#status").hide();
                                            return;
                                        }
                                    });                                    
                                }
                                //分配失败
                                else{
                                    PopPromptBox.show(restobj.msg);
                                    return false;
                                }
                            });
                        },
                        no_fun: function () {
                            //取消选中
                            target_item.find('.img-circle').find('i').removeClass('lnr-circle-solid').addClass('lnr-circle');
                        }
                    });
                }            },
            headerRigBtFun: function (related_obj) {
            }
        };
    }

    // 获取下一步审批人选择列表
    function getNextApprovalUserList() {
        return {
            __refreshable: false,
            title_str: '选择下一步审批人',
            select_mode: 'multi',
            multi_autotoggle: false,
            show_search: true,
            search_obj: {
                parent_obj: ld('#cwn-popuselect-view>.top-wrapper'),
                value_text: '',
                tip_text: '请输入姓名',
                searchFun: function (searchstr, callback) {
                    var item_num = 0,
                        searchstrValue = searchstr.toLowerCase();
                    ld('#cwn-popuselect-view li').each(function (index, el) {
                        var _this = ld(this),
                            eachValue = _this.find('i').html().toLowerCase();
                        if (eachValue.indexOf(searchstrValue) > -1) {
                            item_num++;
                            if (item_num === 1) {
                                ld('#cwn-popuselect-view .no_message_tip').remove();
                            }
                            _this.show();
                        } else {
                            _this.hide();
                        }
                    });
                    if (!item_num) {
                        var listhtml = logicHanderObj.NoinfoNotice('数据');
                        ld('#cwn-popuselect-view .no_message_tip').remove();
                        ld('#cwn-popuselect-view .content-wrapper').append(listhtml);
                    }
                    callback();
                }
            },
            initFun: function (callback) {
                ld('#ddlSearchDetail').html('');
                ld("#status").show();
                var content_hoder = ld('#cwn-popuselect-view>.content-wrapper');
                var urlstring = '&searchcontent=&module=Users&action=PopUsers&page=1';
                WordReportAjax(urlstring, function (rest) {
                    try {
                        if (rest == '') return false;
                        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                        var listhtml = '',
                            crm_lists = '';
                        if (empty(restobj.result.list)) {
                            listhtml = logicHanderObj.NoinfoNotice('数据');
                        } else {
                            var nowuserid = ld('#nextapproval').val(),
                                nowname = ld('#nextapprovalname').html();
                            approveuserid = nowuserid.split(',');
                            if(nowname !== "") approveusername = nowname.split(',');
                            ld.each(restobj.result.list, function (key, list) {
                                if(list.userimg != undefined){
                                    var classstate = 'lnr-square';
                                    ld.each(approveuserid, function (key, id) {
                                        if (id == list.curid) {
                                            classstate = 'lnr-checkmark-square';
                                        }
                                    });
                                    listhtml += '<li id="user' + list.curid + '" user_id="' + list.curid + '" user_name="' + list.lastname + '" userid="' + list.curid + '" item="popu_select">' +
                                                    '<div>' +
                                                        '<img src="http://' + loginurl + '/' + list.userimg + '" onload="logicHanderObj.loadimg(this)" >' +
                                                    '</div>' +
                                                    '<span class="center text-ellipsis">' +
                                                        '<i class="text-ellipsis">' + list.lastname + '</i>' +
                                                        list.description +
                                                    '</span>' +
                                                    '<span class="img-circle">' +
                                                        '<i class="appiconfont '+ classstate +'"></i>' +
                                                    '</span>' +
                                                '</li>';
                                }
                                else{
                                    crm_lists = 'crm-lists';
                                    var classstate = 'lnr-square';
                                    ld.each(approveuserid, function (key, id) {
                                        if (id == list.curid) {
                                            classstate = 'lnr-checkmark-square';
                                        }
                                    });
                                    listhtml += '<li userid="' + list.curid + '" class="' + classstate + '" item="popu_select">' + list.lastname + '</li>';
                                }
                            });
                            listhtml = '<ul class="crm-lists-user-more  ' + crm_lists + '">' + listhtml + '</ul>';
                            content_hoder.html(listhtml);
                        }
                        ld("#status").hide();
                        callback();
                    }
                    catch (e) {
                        logicHanderObj.errorNotice();
                    }
                });
            },
            itemFun: function (target_item, related_obj) {
                var _this = target_item;
                var tmp_id = _this.attr('userid'),
                    tmp_name = _this.html();
                if(_this.hasClass('lnr-square') || _this.hasClass('lnr-checkmark-square')){
                    if (_this.hasClass('lnr-square')) {
                        _this.removeClass('lnr-square').addClass('lnr-checkmark-square');
                        approveuserid.push(tmp_id);
                        approveusername.push(tmp_name);
                    } else {
                        _this.removeClass('lnr-checkmark-square').addClass('lnr-square');
                        approveuserid.splice(ld.inArray(tmp_id, approveuserid), 1);
                        approveusername.splice(ld.inArray(tmp_name, approveusername), 1);
                    }
                }
                else{
                    tmp_name = _this.find('.center').find('i').html();
                    if (_this.find('.img-circle').find('i').hasClass('lnr-square')) {
                        _this.find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                        approveuserid.push(tmp_id);
                        approveusername.push(tmp_name);
                    } else {
                        _this.find('.img-circle').find('i').removeClass('lnr-checkmark-square').addClass('lnr-square');
                        approveuserid.splice(ld.inArray(tmp_id, approveuserid), 1);
                        approveusername.splice(ld.inArray(tmp_name, approveusername), 1);
                    }
                }
            },
            headerRigBtFun: function (related_obj) {
                ld('#nextapproval').val(approveuserid);
                ld('#nextapprovalname').html(approveusername.join(','));
                return true;
            }
        }
    }

    // 获取下一审批步骤选择列表
    function getNextApprovalStepList(itmes_str) {
        return {
            __refreshable: false,
            title_str: '下一步审批步骤',
            select_mode: 'single',
            show_search: 'false',
            choose_style: 'v',
            auto_back: true,
            initFun: function (callback) {
                var list_str = '<ul>',
                    itemsArray = itmes_str.split('|##|'),
                    option = [],
                    content_hoder = ld('#cwn-popuselect-view>.content-wrapper');

                // content_hoder.addClass(_this.attr('popu_select'));   
                for (var i = 0; i < itemsArray.length - 1; i++) {
                    if (itemsArray[i].toString()) {
                        option = itemsArray[i].split('&&');
                        if (option[0].toString()) {
                            list_str += '<li class="text-ellipsis " tag="' +
                                option[0] + '" item="popu_select">' + option[1] + '</li>';
                        }
                    }
                }
                list_str += '</ul>';
                content_hoder.html(list_str); //插入选项列表值
                callback();
            },
            itemFun: function (target_item, related_obj) {
                var stepid = target_item.attr('tag');
                ld('#optionsstepid').attr('stepid', stepid).html(target_item.html());
                ld('#nextstep').val(stepid);
                //这里需要切换自己步骤的用户
                var urlstring = 'module=Approve&action=stepApproveUser' +
                    '&approveid=' + ViewObj.rootScope.approveid + '&stepid=' + stepid;
                WordReportAjax(urlstring, function (rest) {
                    if (empty(rest)) return false;
                    var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                    ld('#nextapproval').val(restobj.result.list.id);
                    ld('#nextapprovalname').html(restobj.result.list.name);
                });
            }
        }
    }

    // work 获取执行人，评论人选择列表
    function getCommentExecutionList(user_searchObj, list_name) {
        var optinsobj = {
            __refreshable: false,
            title_str: '选择',
            select_mode: 'single',
            show_search: true,
            choose_style: 'u',
            auto_back: true,
            multi_autotoggle: false,
            search_obj: {
                parent_obj: ld('#cwn-popuselect-view>.top-wrapper'),
                value_text: '',
                tip_text: '请输入',
                searchFun: function (searchstr, callback) {
                    var item_num = 0;
                    ld('#cwn-popuselect-view li').each(function (index, el) {
                        var _this = ld(this);
                        if (_this.find('i').html().indexOf(searchstr) > -1) {
                            item_num++;
                            if (item_num === 1) {
                                ld('#cwn-popuselect-view .no_message_tip').remove();
                            }
                            _this.show();
                        } else {
                            _this.hide();
                        }
                    });
                    if (!item_num) {
                        var listhtml = logicHanderObj.NoinfoNotice('数据')
                        ld('#cwn-popuselect-view .no_message_tip').remove();
                        ld('#cwn-popuselect-view .content-wrapper').append(listhtml);
                    }
                    callback();
                }
            },
            initFun: function (callback) {
                if (list_name === 'comment') {
                    searchtype = 'comment';
                } else if (list_name === 'execution') {
                    searchtype = 'execute';
                }
                UserPopupInit(user_searchObj, function () {
                    var liststr = '<ul class="crm-lists-user-more ">',
                        imgurl = '',
                        username = '',
                        userinfo = '',
                        id = '',
                        choosen = '';
                    ld('#ColleagueDiv li[userid]').each(function (index, el) {
                        imgurl = ld(this).find('img').attr('src');
                        username = ld(this).find('span.center').find('i').html();
                        userinfo = ld(this).find('span.center').html();
                        id = ld(this).attr('userid');
                        
                        if (list_name === 'comment' && username === ld('#commentDIV span').html() && GVObj.optperson == id) {
                            choosen = 'lnr-circle-solid';
                        } else if (list_name === 'execution' && username === ld('#executionDIV span').html() && GVObj.execution == id) {
                            choosen = 'lnr-circle-solid';
                        }
                        else {
                            choosen = 'lnr-circle';
                        }
                        liststr += '<li id="user' + id + '" userid="' + id + '" item="popu_select" >' +
                                        '<div>' +
                                            '<img src="' + imgurl + '" onload="logicHanderObj.loadimg(this)" >' +
                                        '</div>' +
                                        '<span class="center text-ellipsis">' +
                                            userinfo +
                                        '</span>' +
                                        '<span class="img-circle">' +
                                            '<i class="' + choosen + '"></i>' +
                                        '</span>' +
                                    '</li>';
                    });
                    liststr += '</ul>';
                    ld('#cwn-popuselect-view>div.content-wrapper').html(liststr);
                    callback();
                });
            }
        }
        if (list_name === 'comment') {
            optinsobj.title_str = '选择点评人';
            optinsobj.search_obj.tip_text = '搜索点评人';
            optinsobj.itemFun = function (target_item, related_obj) {
                GVObj.optperson = target_item.attr('userid');
                var name = target_item.find('i').html();
                ld('#commentDIV').html('<span class="text-ellipsis">' + name + '</span>');
                //记录点评人
                sessionStorage.setItem('storage_work_com_execid', GVObj.optperson);
                sessionStorage.setItem('storage_work_com_execname', name);
            };
        } else if (list_name === 'execution') {
            optinsobj.title_str = '选择执行人';
            optinsobj.search_obj.tip_text = '搜索执行人';
            optinsobj.itemFun = function (target_item, related_obj) {
                GVObj.execution = target_item.attr('userid');
                var name = target_item.find('i').html();
                ld('#executionDIV').html('<span class="text-ellipsis">' + name + '</span>');
                //记录执行人
                sessionStorage.setItem('storage_work_com_execid', GVObj.execution);
                sessionStorage.setItem('storage_work_com_execname', name);
            };
        }
        return optinsobj;
    }

    // work获取关联联系人，关联客户列表，关联产品列表
    function getAcctContProRelationList(w_r_module, w_r_modulename) {
        var optinsobj = {
            __refreshable: true,
            __footer_id: 'wn-choosenview-footer',
            title_str: '选择',
            select_mode: 'multi',
            show_search: true,
            choose_style: '',
            auto_back: false,
            multi_autotoggle: false,
            search_obj: {
                parent_obj: ld('#cwn-popuselect-view>.top-wrapper'),
                value_text: '',
                tip_text: '请输入',
                searchFun: function (searchstr, callback) {
                    ViewObj.rootScope.work_rel_search = searchstr;
                    var urlstring = 'module=' + w_r_module + '&action=Pop' + w_r_module + '&searchcontent=' + searchstr;
                    if (w_r_module == 'Accounts') {
                        urlstring += '&noprfiledata=true';
                    }
                    GVObj.workObj.liststatus = 'search';
                    workHandleObj.getRelationList(urlstring, function () {
                        if (w_r_module == 'Accounts') {
                            ld.each(t_choose_a_relationidobj, function (key, id) {
                                ld('#' + w_r_module + '_' + id).removeClass('lnr-square').addClass('lnr-checkmark-square');
                            });
                        } else if (w_r_module == 'Contacts') {
                            ld.each(t_choose_c_relationidobj, function (key, id) {
                                ld('#' + w_r_module + '_' + id).removeClass('lnr-square').addClass('lnr-checkmark-square');
                            });
                        } else if (w_r_module == 'Products') {
                            ld.each(t_choose_p_relationidobj, function (key, id) {
                                ld('#' + w_r_module + '_' + id).removeClass('lnr-square').addClass('lnr-checkmark-square');
                            });
                        }
                        callback();
                    });
                }
            },
            initFun: function (callback) {
                relationtype = w_r_module;
                ViewObj.rootScope.work_rel_search = '';
                var urlstring = 'module=' + w_r_module + '&action=Pop' + w_r_module + '&searchcontent=' + ViewObj.rootScope.work_rel_search;
                if (w_r_module == 'Accounts') {
                    urlstring += '&noprfiledata=true';
                }
                relationidkey = 'storage_work_rela_' + w_r_module + 'id';
                relationnamekey = 'storage_work_rela_' + w_r_module + 'name';
                GVObj.workObj.liststatus = '';
                ld("#status").show();
                workHandleObj.getRelationList(urlstring, function () {
                    ld("#status").hide();
                    callback();
                });
            },
            itemFun: function (target_item, related_obj) {
                var id = target_item.attr('dataid'),
                    name = target_item.attr('name');
                if (ld('#' + w_r_module + '_' + id).hasClass('lnr-square')) {
                    ld('#' + w_r_module + '_' + id).removeClass('lnr-square').addClass('lnr-checkmark-square');
                    if (w_r_module === 'Accounts') {
                        if (ld.inArray(id, t_choose_a_relationidobj) == -1) {//当前元素下标位置
                            t_choose_a_relationidobj[t_choose_a_relationidobj.length] = id;
                            t_choose_a_relationnameobj[t_choose_a_relationnameobj.length] = name;
                        }
                    }
                    else if (w_r_module === 'Contacts') {
                        if (ld.inArray(id, t_choose_c_relationidobj) == -1) {//当前元素下标位置
                            t_choose_c_relationidobj[t_choose_c_relationidobj.length] = id;
                            t_choose_c_relationnameobj[t_choose_c_relationnameobj.length] = name;
                        }
                    }
                    else if (w_r_module === 'Products') {
                        if (ld.inArray(id, t_choose_p_relationidobj) == -1) {//当前元素下标位置
                            t_choose_p_relationidobj[t_choose_p_relationidobj.length] = id;
                            t_choose_p_relationnameobj[t_choose_p_relationnameobj.length] = name;
                        }
                    }
                    ld('#chosenlist_' + w_r_module).append('<li id="relation' + w_r_module + '_' + id + '">' + name + '</li>');
                }
                else {
                    ld('#' + w_r_module + '_' + id).removeClass('lnr-checkmark-square').addClass('lnr-square');
                    if (w_r_module === 'Accounts') {
                        t_choose_a_relationidobj.splice(ld.inArray(id, t_choose_a_relationidobj), 1);//移除选择id
                        t_choose_a_relationnameobj.splice(ld.inArray(name, t_choose_a_relationnameobj), 1);
                    }
                    else if (w_r_module === 'Contacts') {
                        t_choose_c_relationidobj.splice(ld.inArray(id, t_choose_c_relationidobj), 1);//移除选择id
                        t_choose_c_relationnameobj.splice(ld.inArray(name, t_choose_c_relationnameobj), 1);
                    }
                    else if (w_r_module === 'Products') {
                        t_choose_p_relationidobj.splice(ld.inArray(id, t_choose_p_relationidobj), 1);//移除选择id
                        t_choose_p_relationnameobj.splice(ld.inArray(name, t_choose_p_relationnameobj), 1);
                    }
                    ld('#relation' + w_r_module + '_' + id).remove();//删除该条记录
                }
                //Tools.print_array(choose_relationidobj);
                //因为这里不需要重新获取choose_relationidobj，所以没有使用showselectedRelationdata()方法
                btnshowRelationname = '';
                if (w_r_module === 'Accounts') {
                    if (t_choose_a_relationidobj.length == 1) {
                        btnshowRelationname = t_choose_a_relationnameobj;
                    } else {
                        if (t_choose_a_relationidobj.length > 1) {
                            btnshowRelationname += t_choose_a_relationidobj.length + '个' + w_r_modulename;
                        }
                    }
                }
                else if (w_r_module === 'Contacts') {
                    if (t_choose_c_relationidobj.length == 1) {
                        btnshowRelationname = t_choose_c_relationnameobj;
                    } else {
                        if (t_choose_c_relationidobj.length > 1) {
                            btnshowRelationname += t_choose_c_relationidobj.length + '个' + w_r_modulename;
                        }
                    }
                }
                else if (w_r_module === 'Products') {
                    if (t_choose_p_relationidobj.length == 1) {
                        btnshowRelationname = t_choose_p_relationnameobj;
                    } else {
                        if (t_choose_p_relationidobj.length > 1) {
                            btnshowRelationname += t_choose_p_relationidobj.length + '个' + w_r_modulename;
                        }
                    }
                }
                ld('#wn-choosenview-footer>span').html('已选择：' + btnshowRelationname);
            },
            headerRigBtFun: function (related_obj) {
                //存入数据
                if (w_r_module === 'Accounts') {
                    if (empty(t_choose_a_relationidobj)) {
                        PopPromptBox.show('至少选择一个关联' + w_r_modulename);
                        return false;
                    }
                    sessionStorage.setItem(relationidkey, JSON.stringify(t_choose_a_relationidobj));
                    sessionStorage.setItem(relationnamekey, JSON.stringify(t_choose_a_relationnameobj));
                    if (!empty(t_choose_a_relationidobj)) {
                        ld('#sendLogAcctlist').removeClass('ui-hide');
                        ld('#sendLogAcctlistCount').html(btnshowRelationname);
                    } else {
                        ld('#sendLogAcctlist').addClass('ui-hide');
                        ld('#sendLogAcctlistCount').html('');
                    }
                }
                else if (w_r_module === 'Contacts') {
                    if (empty(t_choose_c_relationidobj)) {
                        PopPromptBox.show('至少选择一个关联' + w_r_modulename);
                        return false;
                    }
                    sessionStorage.setItem(relationidkey, JSON.stringify(t_choose_c_relationidobj));
                    sessionStorage.setItem(relationnamekey, JSON.stringify(t_choose_c_relationnameobj));
                    if (!empty(t_choose_c_relationidobj)) {
                        ld('#sendLogContlist').removeClass('ui-hide');
                        ld('#sendLogContlistCount').html(btnshowRelationname);
                    } else {
                        ld('#sendLogContlist').addClass('ui-hide');
                        ld('#sendLogContlistCount').html('');
                    }
                }
                else if (w_r_module === 'Products') {
                    if (empty(t_choose_p_relationidobj)) {
                        PopPromptBox.show('至少选择一个关联' + w_r_modulename);
                        return false;
                    }
                    sessionStorage.setItem(relationidkey, JSON.stringify(t_choose_p_relationidobj));
                    sessionStorage.setItem(relationnamekey, JSON.stringify(t_choose_p_relationnameobj));
                    if (!empty(t_choose_p_relationidobj)) {
                        ld('#sendLogProlist').removeClass('ui-hide');
                        ld('#sendLogProlistCount').html(btnshowRelationname);
                    } else {
                        ld('#sendLogProlist').addClass('ui-hide');
                        ld('#sendLogProlistCount').html('');
                    }
                }
            },
            headerLeftBtFun: function (related_obj) {
                if (w_r_module === 'Accounts') {
                    t_choose_a_relationidobj = JSON.parse(sessionStorage.getItem(relationidkey));//id
                    t_choose_a_relationnameobj = JSON.parse(sessionStorage.getItem(relationnamekey));//name
                    //存入数据
                    sessionStorage.setItem(relationidkey, JSON.stringify(t_choose_a_relationidobj));
                    sessionStorage.setItem(relationnamekey, JSON.stringify(t_choose_a_relationnameobj));
                }
                else if (w_r_module === 'Contacts') {
                    t_choose_c_relationidobj = JSON.parse(sessionStorage.getItem(relationidkey));//id
                    t_choose_c_relationnameobj = JSON.parse(sessionStorage.getItem(relationnamekey));//name
                    //存入数据
                    sessionStorage.setItem(relationidkey, JSON.stringify(t_choose_c_relationidobj));
                    sessionStorage.setItem(relationnamekey, JSON.stringify(t_choose_c_relationnameobj));
                }
                else if (w_r_module === 'Products') {
                    t_choose_p_relationidobj = JSON.parse(sessionStorage.getItem(relationidkey));//id
                    t_choose_p_relationnameobj = JSON.parse(sessionStorage.getItem(relationnamekey));//name
                    //存入数据
                    sessionStorage.setItem(relationidkey, JSON.stringify(t_choose_p_relationidobj));
                    sessionStorage.setItem(relationnamekey, JSON.stringify(t_choose_p_relationnameobj));
                }
            }
        };
        optinsobj.title_str = '关联' + w_r_modulename;
        optinsobj.search_obj.tip_text = '搜索' + w_r_modulename;
        optinsobj.footerFun = function (targetobj, clickOpts) {
            // 当btnshowCCname 中有值才可以点击
            if (w_r_module === 'Accounts') {
                if (!empty(t_choose_a_relationidobj)) {
                    ViewObj.switchView('cwn-lookup-view', 'init', {
                        view_name: 'acctcontpro_relationlist',
                        __app_header: ['<', '', '', '查看已选', '', ''],
                        'list_name': w_r_module
                    });
                }
            }
            else if (w_r_module === 'Contacts') {
                if (!empty(t_choose_c_relationidobj)) {
                    ViewObj.switchView('cwn-lookup-view', 'init', {
                        view_name: 'acctcontpro_relationlist',
                        __app_header: ['<', '', '', '查看已选', '', ''],
                        'list_name': w_r_module
                    });
                }
            }
            else if (w_r_module === 'Products') {
                if (!empty(t_choose_p_relationidobj)) {
                    ViewObj.switchView('cwn-lookup-view', 'init', {
                        view_name: 'acctcontpro_relationlist',
                        __app_header: ['<', '', '', '查看已选', '', ''],
                        'list_name': w_r_module
                    });
                }
            }
        }

        return optinsobj;
    }

    // me 修改基本信息
    function getMeUpdateInfo(update_type) {
        var options = {};
        // me修改密码
        if (update_type === 'update_password') {
            options = {
                __init_delay: 'none',
                title_str: '修改密码',
                auto_back: false,
                right_str: '确定',
                model: 'custom',
                initFun: function (callback) {
                    var tpl_htmlStr = '',
                        content_holder = ld('#cwn-popuedit-view');
                    tpl_htmlStr = '<div class="popuedit">' +
                        '<ul class="update-wrap">' +
                        '<li><label>新密码</label><br />' +
                        '<input type="password" id="new_password" name="new_password" /></li>' +
                        '<li><label>确认密码</label><br />' +
                        '<input id="confirm_pwd" name="confirm_pwd" type="password"/>' +
                        '</ul></div>';
                    content_holder.html(tpl_htmlStr);
                },
                sureFun: function (targetobj, related_obj) {
                    var new_psdStr = ld('#new_password').val(),
                        confirm_pwdStr = ld('#confirm_pwd').val(),
                        pwd_tipStr = '';
                    if (empty(new_psdStr) || empty(confirm_pwdStr)) {               //验证输入密码
                        pwd_tipStr = '密码不能为空';
                    } else if (new_psdStr !== confirm_pwdStr) {
                        pwd_tipStr = '两次输入密码不一致';
                    } else {                                                  //验证成功
                        var urlstring = 'module=Home&action=ListView&method=changeMePwd' +
                            '&new_password=' + new_psdStr + '&confirm_new_password=' + confirm_pwdStr;
                        WordReportAjax(urlstring, function (rest) {
                            if (empty(rest)) return false;
                            var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                            if (restobj.code == 1) {
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
                            } else if (restobj.code == -1) {
                                PopPromptBox.show(restobj.msg);
                            }
                        });
                    }
                    if (pwd_tipStr) {
                        PopPromptBox.show(pwd_tipStr);
                        return false;
                    }
                }
            };
            // me修改邮箱，手机，姓名等信息
        } else {
            var submitStr = '';
            options = {
                __init_delay: 'none',
                auto_back: true,
                right_str: '确定',
                model: 'default',
                regexp_str: /^.*$/
            }
            switch (update_type) {
                case 'update_lastname':
                    submitStr = 'last_name';
                    options.tip_str = '姓名';
                    options.title_str = '修改姓名';
                    options.alias_str = '姓名';
                    break;
                case 'update_email':
                    submitStr = 'email1';
                    options.tip_str = 'Email';
                    options.title_str = '修改Email';
                    options.alias_str = 'Email';
                    options.regexp_str = /(\S)+[@]{1}(\S)+[.]{1}(\w)+/;
                    break;
                case 'update_mobile':
                    submitStr = 'phone_mobile';
                    options.tip_str = '手机号码';
                    options.title_str = '修改手机';
                    options.alias_str = '手机号码';
                    options.regexp_str = /^1\d{10}$/;
                    break;
            }
            options.sureFun = function (input_str, related_obj) {
                var urlstring = 'module=Home&action=ListView&method=saveMe&' + submitStr + '=' + input_str;
                WordReportAjax(urlstring, function (rest) {
                    if (submitStr === 'last_name') {
                        ld('.me-user div[tag=edit_medetail] h3').html(input_str);//“我”首页名称更改
                    }
                    related_obj.html(input_str);//“我”明细更改
                });
            }
        }
        return options;
    }
};

// 定义跳转到cwn-popuselect-view(弹出选择页)的方法 及click处理定义
ViewObj['create-cwn-popuselect-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        //scope.prev_header = ViewObj.getInfo('prev_header');
        ViewObj.toViewCommon(to_viewid, ViewObj.getInfo('prev_header'), opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        var r_str = opts_obj.right_str ? opts_obj.right_str : '',
            title_str = opts_obj.title_str ? opts_obj.title_str : ViewObj.rootScope.title_str;
        title_str = title_str ? title_str : '';
        scope = opts_obj;
        ld('#cwn-popuselect-view').find('div').html('');
        if (!ld.isFunction(scope.initFun)) {
            alert('请传入初始化方法！');
            throw new Error('请传入初始化方法！');
        }
        if (scope.select_mode === 'single') {
            if (scope.choose_style === 'v') {
                scope.choosen_class = 'lnr-checkmark';
            } else if (scope.choose_style === 'o') {
                scope.choosen_class = 'lnr-circle-solid';
            } else if (scope.choose_style === 'u') {
                scope.choosen_class = 'lnr-circle-solid';
            } else {
                scope.choosen_class = '';
            }
            // 当存在 头部右边按钮，并且存在点击方法
            // 将点击方法，替换到，点击右边按钮时执行
            if (r_str && ld.isFunction(scope.itemFun)) {
                scope.headerRigBtFun = scope.itemFun;
                scope.itemFun = null;
            }
        }
        else if (scope.select_mode === 'multi' && !r_str) {
            r_str = '确定';
            scope.choosen_class = 'lnr-checkmark-square';
        }
        if (scope.show_search === true) {
            ListSearchBox.display(scope.search_obj);
        }
        var header_ar = ['<', '', '', title_str, '', r_str];
        scope.header_ar = ['<', '', '', title_str, '', r_str];

        ViewObj.toViewCommon(to_viewid, header_ar, opts_obj);
        scope.prev_header = ViewObj.getInfo('prev_header');
        scope.prev_viewid = ViewObj.getPrevInfo('viewid');
        scope.prev_footerid = ViewObj.getPrevInfo('footerid');

        scope.backFun = function () {
            ViewObj.switchView(scope.prev_viewid, 'back', {
                __scroll_top: 'origin',
                __footer_id: scope.prev_footerid,
                __app_header: scope.prev_header
            });
        };
        scope.initFun(function () {
            var items_holder = ld('#cwn-popuselect-view>.content-wrapper');
            items_holder.attr('class', 'content-wrapper ' + scope.view_name);
            if (scope.select_mode === 'single') {
                var init_item = items_holder.find('[init_item]');
                if (scope.choose_style === 'o') {
                    items_holder.find('li').addClass('lnr-circle');
                    init_item.removeClass('lnr-circle').addClass(scope.choosen_class);
                } else if (scope.choose_style === 'v') {
                    init_item.addClass(scope.choosen_class).removeAttr('init_item');
                }
            }
            scope.title_str = ld('#head_mid>span:visible').html();
            ViewObj.onSwitchAfter(scope);
        });
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 点击头部左边
        if (t_id === 'head_left') {
            if(module==='Singin'){
                ViewObj.switchView('crm-sign-view', 'back');
            }
            else{
                scope.backFun();
                if (ld.isFunction(scope.headerLeftBtFun)) {
                    scope.headerLeftBtFun();
                }
            }
            // 点击头部右边
        } else if (t_id === 'head_rig') {
            if (scope.choosen_class != '') {
                var choosen_items = ld('#cwn-popuselect-view>.content-wrapper').find('.' + scope.choosen_class);
                if (!scope.__refreshable && choosen_items.length === 0) {
                    PopPromptBox.show('至少选择一个选项');
                    return;
                }

                if (ld.isFunction(scope.headerRigBtFun)) {
                    if (scope.select_mode === 'single') {
                        var _this = choosen_items;
                        if (scope.headerRigBtFun(_this, scope.target_obj) === false) return;
                    } else {
                        if (scope.headerRigBtFun(scope.target_obj) === false) return;
                    }
                }
                scope.backFun();
            }
            else {
                GVObj.crmObj.quickcreateStatus = 'yes';
                ViewObj.switchView('crm-createedit-view', 'init', {
                    view_name: 'create'
                });
            }
        }
    };
    // 底部点击操作
    ViewObj[to_viewid + '-footer-click'] = function (targetobj, clickOpts) {
        if (ld.isFunction(scope.footerFun)) {
            scope.footerFun(targetobj, clickOpts);
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = null;
        if (targetobj.parents('.content-wrapper').length === 1) {
            _this = targetobj.parents('li');
            if (_this.length === 1 ||
                targetobj.attr('item') === 'popu_select') {
                _this = _this.length ? _this : targetobj;
                //ViewObj.rootScope.signpage='first'
                //alert(scope.select_mode);
                if (scope.select_mode === 'multi' && scope.multi_autotoggle) {
                    if (_this.hasClass('lnr-checkmark-square')) {
                        _this.removeClass('lnr-checkmark-square').addClass('lnr-square');
                    } else {
                        _this.removeClass('lnr-square').addClass('lnr-checkmark-square');
                    }
                }
                else if (scope.select_mode === 'single') {//||scope.select_mode==='sign_account'
                    var c = scope.choosen_class;
                    if (scope.choose_style === 'o') {
                        _this.parent().find('.' + c).removeClass(c).addClass('lnr-circle');
                        _this.addClass(c).removeClass('lnr-circle');
                    } else if (scope.choose_style === 'v') {
                        _this.parent().find('.' + c).removeClass(c);
                        _this.addClass(c);
                    } else if (scope.choose_style === 'u') {
                        _this.parent().find('.img-circle').find('i').removeClass(c).addClass('lnr-circle');
                        _this.find('.img-circle').find('i').removeClass('lnr-circle').addClass(c);
                    }
                    if (scope.auto_back) {
                        window.setTimeout(function () {
                            scope.backFun();
                        }, 500);
                    }
                }
                if (!scope.multi_autotoggle ||
                    scope.select_mode === 'single') {
                    if (ld.isFunction(scope.itemFun)) {
                        scope.itemFun(_this, scope.target_obj, targetobj);
                    }
                }
            }
        }
    };
};

// 定义cwn-popuedit-view弹出输入页面，（me修改个人信息，me反馈等）
ViewObj['create-cwn-popuedit-view'] = function (to_viewid, siwtch_type, scope) {
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ld('#cwn-popuedit-view').html('');
        scope = opts_obj;
        scope.prev_header = ViewObj.getPrevInfo('header');
        scope.prev_footerid = ViewObj.getPrevInfo('footerid');
        if (!ld.isFunction(scope.sureFun)) {
            alert('viewObj.switchView("cwn-popuedit-view","int",{\n' +
                '    sureFun :function(){}\n' +
                '}请传入sureFun方法！');
            throw new Error('请传入确定方法！');
        }
        scope.backFun = function () {
            ViewObj.switchView(ViewObj.getPrevInfo('viewid'), 'back', {
                __scroll_top: 'origin',
                __footer_id: scope.prev_footerid,
                __app_header: scope.prev_header
            });
        }
        var r_str = opts_obj.right_str ? opts_obj.right_str : '',
            vlue_str = opts_obj.vlue_str ? opts_obj.vlue_str : '',
            placeholder = opts_obj.placeholder_str ? opts_obj.placeholder_str : '请输入' + scope.tip_str,
            init_html = '';
        scope.alias_str = scope.alias_str ? scope.alias_str : '';
        scope.tip_str = scope.tip_str ? scope.tip_str : '';
        if (scope.target_obj) {
            vlue_str = ld.trim(scope.target_obj.text());
        }

        if (scope.model === 'default') {
            scope.regexp_str = scope.regexp_str ? scope.regexp_str : /^.*$/;
            r_str = r_str ? r_str : '确定';
            init_html = '<div class="writeTxt"> <textarea  placeholder="' +
                placeholder + '" >' + vlue_str + '</textarea></div>';
        }
        ViewObj.toViewCommon('cwn-popuedit-view', ['<', '', '', scope.title_str, '', r_str], opts_obj);
        if (scope.model === 'custom') {
            // if(!r_str){
            if (!ld.isFunction(scope.initFun)) {
                alert('ViewObj.switchView("cwn-popuedit-view","int",{\n' +
                    '    initFun :function(){}\n' +
                    '}请传入sureFun方法！');
                throw new Error('请传入初始化方法！');
            }
            scope.initFun(function () {
                ViewObj.onSwitchAfter(opts_obj);
            });
            return;
        }
        if (r_str) {
            ld('#cwn-popuedit-view').html(init_html);
            ViewObj.onSwitchAfter(opts_obj);
        }
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 头部左边
        if (t_id === 'head_left') {
            // 跳转到work搜索
            scope.backFun();
        } else if (t_id === 'head_rig') {
            if (scope.right_str) {
                if (scope.model === 'default') {
                    var input_str = ld.trim(ld('#cwn-popuedit-view textarea').eq(0).val()),
                        tip_str = '';
                    if (input_str === '') {
                        tip_str = scope.alias_str ? scope.alias_str + '不能为空' : '输入不能为空';
                        PopPromptBox.show(tip_str);
                        //验证 对应的正则表达式 是否通过
                    } else if (scope.regexp_str && !scope.regexp_str.test(input_str)) {
                        tip_str = scope.alias_str ? '请输入正确的' + scope.alias_str : '输入有误';
                        PopPromptBox.show(tip_str);
                    } else {
                        if (scope.sureFun(input_str, scope.target_obj) === false) return;
                        if (scope.auto_back) {
                            scope.backFun();
                        }
                    }
                } else if (scope.model === 'custom') {
                    if (ld.isFunction(scope.sureFun)) {
                        if (scope.sureFun(ld('#head_rig'), scope.target_obj) === false) return;
                        if (scope.auto_back) {
                            scope.backFun();
                        }
                    }
                }
            }
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        if (scope.model === 'custom' && !scope.right_str) {
            if (ld.isFunction(scope.sureFun)) {
                if (scope.sureFun(targetobj, scope.target_obj) === false) return;
                if (scope.auto_back) {
                    scope.backFun();
                }
            }
            // 请给cwn-popuedit-view,initFun方法里时，给取消按钮
            // 添加edit-cancle，实现点击自动返回
            if (ld('#cwn-popuedit-view .edit-cancle').length === 1) {
                var _this = parents('.edit-cancle');
                if (targetobj.attr('class') === 'edit-cancle' ||
                    _this.length === 1) {
                    scope.backFun();
                }
            }
        }
    };
};

// 定义跳转cwn-lookup-view(查看信息页)的方法  及click处理定义
ViewObj['create-cwn-lookup-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '发送范围', '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ld('#cwn-lookup-view>div').addClass('ui-hide');
        scope.prev_header = ViewObj.getPrevInfo('header');
        if (ld.isArray(opts_obj.__app_header)) {
            ViewObj.toViewCommon(to_viewid, [], opts_obj);
        } else {
            alert('switchView("cwn-lookup-view","init",{})必须传入__app_header属性！');
        }
        scope.prev_vid = ViewObj.getPrevInfo('viewid');
        scope.prev_footerid = ViewObj.getPrevInfo('footerid');
        scope.view_name = opts_obj.view_name;
        switch (opts_obj.view_name) {
            // 工作明细 查看发送范围
            case 'workdetail_rangeview':
                // 先显示页面在加载数据
                ld('#workdetail_rangeview').removeClass('ui-hide');
                var urlstring = 'module=Home&action=ListView&method=getReportUserList&workreportid=' + opts_obj.workreportid;
                ld('#status').show();
                ld('#workdetail_rangeview').html('');
                WordReportAjax(urlstring, function (rest) {
                    ld('#status').hide();
                    var dataObj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest),
                        strhtml = '<ul class="listimg listimg-noR">';
                    ld.each(dataObj.list, function (key, list) {
                        if (list.curid) {
                            var infohtml = '';
                            if (list.profilename != '' && list.userlevel) {
                                infohtml = list.profilename + '-' + list.userlevel;
                            }
                            else if (list.profilename != '') {
                                infohtml = list.profilename;
                            }
                            else if (list.userlevel != '') {
                                infohtml = list.userlevel;
                            }
                            strhtml += '<i class="lnr-chevron-right"></i><li curid=' + list.curid + '><div><img src="http://' + loginurl + '/' + list.userimage + '" onload="logicHanderObj.loadimg(this)"/></div>' +
                                '<span class="center text-ellipsis"><i>' + list.username + '</i>' + infohtml + '</span></li>';
                        }
                    });
                    strhtml += '</ul>';
                    ld('#workdetail_rangeview').html(strhtml);
                    ViewObj.onSwitchAfter(opts_obj);
                });
                break;
            // @,转发，查看已选范围
            case 'rang_choosenview':
                ld('#workdetail_rangeview').addClass('ui-hide');
                ld('#chooseUserList,#chosenSendrange_commGroup,#chosenSendrange_Group,' +
                    '#chosenSendrange_Colleague').removeClass('ui-hide');
                if (ld('#ColleagueDiv>div>i').hasClass('lnr-checkmark-square')) {
                    ld('#Sendrange_Colleaguetitle').removeClass('ui-hide');
                }
                else {
                    ld('#Sendrange_Colleaguetitle').addClass('ui-hide');
                }
                if (ld('#DepartmentDiv>div>i').hasClass('lnr-checkmark-square')) {
                    ld('#Sendrange_Grouptitle').removeClass('ui-hide');
                }
                else {
                    ld('#Sendrange_Grouptitle').addClass('ui-hide');
                }
                ViewObj.onSwitchAfter(opts_obj);
                break;
            // me页面，通讯录，个人信息
            case 'me_adressbook_userinfo':
                ld('#cwn-lookup-view').html('');
                var urlstring = 'module=Users&action=DetailView&adressbookuserid=' + opts_obj.adressbookuserids;
                WordReportAjax(urlstring, function (rest) {
                    if (rest == '') return false;
                    var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                    var html_str = '';
                    html_str =  '<div class="logo-ver info"><img src="' + opts_obj.imgsrc + '"/><p>' + opts_obj.last_name + '</p></div>' +
                                '<div class="userinfo-opt ui-hide"><span class="phone"></span><span class="care-no"></span><span class="coll-no"></span></div>' +
                                '<ul class="userinfo-lists">' +
                                    '<li><span class="left">角色</span><span class="right">' + opts_obj.profilename + '</span></li>' +
                                    '<li><span class="left">Email</span><span class="right">' + restobj.result.list.email + '</span></li>' +
                                    '<li><span class="left">手机</span><span class="right">' + opts_obj.mobilephone + '</span></li>' +
                                    '<li><span class="left">电话</span><span class="right">' + opts_obj.telephone + '</span></li>' +
                                '</ul>';
                    ld('#cwn-lookup-view').html(html_str);
                });
                break;
            // work选择关联客户、联系人、产品
            case 'acctcontpro_relationlist':
                ld('#cwn-lookup-view>div,#chosenlist>ul').addClass('ui-hide');//隐藏其他查看内容
                ld('#chosenlist,#chosenlist_' + opts_obj.list_name).removeClass('ui-hide');
                ViewObj.onSwitchAfter(opts_obj);
                break;
            case 'me_feedback_detail':
                ld('#cwn-lookup-view').html('');
                var feedbackid = opts_obj.feedback_id ? opts_obj.feedback_id : null;
                if (!feedbackid) return;
                var urlstring = 'module=FeedBack&action=DetailView&id=' + feedbackid;
                WordReportAjax(urlstring, function (rest) {
                    if (rest == '') return false;
                    var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                    var html_str = '', phone = restobj.result.list.phone;
                    if (phone == '') {
                        phone = '未填写'
                    }
                    html_str =  '<div class="fb-detail">' +
                                    '<p><i>状态</i>' + restobj.result.list.status + '</p>' +
                                    '<p><i>描述</i>' + restobj.result.list.content + '</p>' +
                                    '<p><i>联系方式</i>' + phone + '</p>' +
                                    '<p class="a"><i>提交时间</i>' + restobj.result.list.createdate + '</p>' +
                                '</div>';
                    ld('#cwn-lookup-view').html(html_str);
                    ViewObj.onSwitchAfter(opts_obj);
                });
                break;
        }
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 头部左边
        if (t_id === 'head_left') {
            ViewObj.switchView(scope.prev_vid, 'back', {
                __scroll_top: 'origin',
                __app_header: scope.prev_header,
                __footer_id: scope.prev_footerid
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        if (targetobj.parents('#workdetail_rangeview').length === 1) {
            if (targetobj.parents('li').length === 1) {
                _this = targetobj.parents('li');
            } else if (targetobj.get(0).tagName.toLowerCase() === 'li') {
                _this = targetobj;
            } else if (targetobj.get(0).tagName.toLowerCase() === 'i') {
                _this = targetobj.next();
            } else {
                return;
            }
            var curid = _this.attr('curid');//用户ID
            if(curid === userid){
                ViewObj.switchView('all-userinfo-view', 'init', {
                    view_name: 'onlymeinfo'
                });
            }
            else{
                ViewObj.switchView('wn-userinfo-view', 'init', {
                    'curid': _this.attr('curid'),
                    'curimg': _this.children().first().html(),
                    'curinfo':_this.children().find('i').html()//目前只读取用户名，暂不读取角色权限信息
                });
            }
        }
    };
};

// 定义跳转wn-userinfo-view(查看个人信息页面，同事)的方法  及click处理定义
ViewObj['create-wn-userinfo-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '个人信息', '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        scope.prev_header = ViewObj.getPrevInfo('header');
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '个人信息', '', ''], opts_obj);
        scope.prev_vid = ViewObj.getPrevInfo('viewid');
        scope.prev_footerid = ViewObj.getPrevInfo('footerid');
        scope.curid = opts_obj.curid;
        smallcategory = 'all';
        //个人信息
        var infohtml =  '<ul class="divUserinfo">' + 
                            '<li curid="'+ opts_obj.curid +'">' + 
                                '<div>' + opts_obj.curimg + '</div>' + 
                                '<span class="center text-ellipsis"><i>' +opts_obj.curinfo + '</i></span>' + 
                            '</li>' + 
                        '</ul>';
        ld("#wn-userinfo-view .userinfo").html(infohtml);
        ld("#wn-userinfo-view .userinfo").removeClass('ui-hide');
        //显示个人信息下方的导航信息
        ld('#arfa_tab').removeClass('ui-hide');
        //默认‘全部’、‘日志’下拉框隐藏
        ld("#worktype_tab").css('display','none');

        var urlstring = 'smallcategory=all&bigcategory=' + bigcategory +
            '&page=1&searchcontent=&method=getList' + '&viewuserid=' + opts_obj.curid;
        //获取日志、微博、任务等数据并展示在页面上
        workHandleObj.getWorkList(urlstring, function () {
            ViewObj.onSwitchAfter(opts_obj);
        });
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 头部左边
        if (t_id === 'head_left') {
            if(category == 'news'){
                if(ViewObj.rootScope.newspage == 'worklist'){
                    ViewObj.rootScope.workpage = 'wn-worklist-view';
                }
                else{
                    ViewObj.rootScope.workpage = 'news-third-view';    
                }
            }
            else{
                ViewObj.rootScope.workpage = 'work-main-view';    
            }
            // ViewObj.rootScope.workpage = 'work-main-view';//scope.prev_vid、
            ViewObj.switchView(ViewObj.rootScope.workpage, 'back', {
                __scroll_top: 'origin',
                // __app_header: scope.prev_header,
                // __footer_id: scope.prev_footerid
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        //点击全部，出现分类信息。点击另外三个选项跳转到对应页面
        if (targetobj.parents('#arfa_tab').length === 1) {
            if (ld(targetobj).hasClass('lnr-chevron-down')) {
                ld('#worktype_tab').slideToggle("slow");
                ld('#arfa_tab .lnr-chevron-down').toggleClass("spin");
            } else {
                var type = targetobj.attr('tag');
                var titlehtml = targetobj.text();
                ViewObj.switchView('wn-replayfileat-view', 'init', {
                    'curid': scope.curid,
                    'type': type,
                    'title': titlehtml
                });
            }
        } else if (targetobj.parents('#worktype_tab').length === 1) {//点击日志、微博、任务，更新列表
            smallcategory = targetobj.attr('tag');
            ld('#worktype_tab').slideToggle("slow");
            ld('#arfa_tab .lnr-chevron-down').toggleClass("spin");
            SwiperObj.ListPageObj.setListPageIndex(1,'wn-userinfo-view');
            EventHanderObj.refreshWorkList(function(){// 工作首页列表刷新
                ld('#arfa_tab .lnr-chevron-down').html(targetobj[0].innerHTML);
                SwiperObj.autoHeight(0).autoHiddenAddMore(); // 刷新后 自动隐藏“更多”
            });
        } else {
            //点击点赞、回复、转发或进入明细页
            // 调用 wn-worklist-view 中的内容点击方法，防止代码重复
            ViewObj.rootScope.workpage = 'wn-userinfo-view';
            OperationObj.triggerCilckEvent(targetobj, 'body', {view_id: 'wn-worklist-view'})
        }
    };
};

// 定义跳转wn-replayfileat-view(查看工作回复、工作文档、@我的页面)的方法  及click处理定义
ViewObj['create-wn-replayfileat-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', scope.title, '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', opts_obj.title, '', ''], opts_obj);
        ld('#file_tab,#atmine_tab').addClass('ui-hide');
        if (opts_obj.type === 'atworklist' || opts_obj.type === 'atreplylist') {
            ld('#atmine_tab').removeClass('ui-hide');
        } else if (opts_obj.type === 'document' || opts_obj.type === 'picture') {
            ld('#file_tab').removeClass('ui-hide');
        }
        ld('#atmine_tab').attr('curid',opts_obj.curid);

        var _id = '#wn-replayfileat-view .tabswitch a[tag="' + opts_obj.type + '"]';
        ld(_id).addClass('curr');
        ld(_id).siblings().removeClass('curr');

        scope.title = opts_obj.title;
        scope.type = opts_obj.type;
        scope.curid = opts_obj.curid;
        GVObj.newstype = opts_obj.type;
        scope.prev_vid = ViewObj.getPrevInfo('viewid');

        var urlstring = 'method=getWorkRemindsAppList&smallcategory=' +
                        '&bigcategory=' + opts_obj.type + '&page=1&searchcontent=&viewuserid=' + opts_obj.curid;

        if (opts_obj.type === 'replylist' || opts_obj.type === 'atreplylist') {//工作回复、@我的-@我的工作回复列表显示
            urlstring = 'module=Home&action=ListView&' + urlstring;
            newsObj.getNewsThirdList('myreply_list', urlstring, function () {
                ViewObj.onSwitchAfter(opts_obj);
            });
        } else if (opts_obj.type === 'document') {//工作文档-工作附件
            urlstring = '&doc_type=document&viewuserid=' + opts_obj.curid;
            workHandleObj.getDocumentList(opts_obj.type,urlstring, function () {
                ld("#status").hide();
                ViewObj.onSwitchAfter(opts_obj);
            });
        } else if (opts_obj.type === 'picture') {//工作文档-工作图片
            urlstring = '&doc_type=picture&viewuserid=' + opts_obj.curid;
            workHandleObj.getDocumentList(opts_obj.type,urlstring, function () {
                ld("#status").hide();
                ViewObj.onSwitchAfter(opts_obj);
            });
        } else if (opts_obj.type === 'atworklist') {//@我的-@我的工作
            workHandleObj.getWorkList(urlstring, function () {
                ld("#status").hide();
                ViewObj.onSwitchAfter(opts_obj);
            });
        }
        ld('#wn-replayfileat-view').attr('curid',opts_obj.curid);
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 头部左边 wn-userinfo-view scope.prev_vid
        if (t_id === 'head_left') {
            ViewObj.switchView(scope.prev_vid, 'back', {
                __scroll_top: 'origin'
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        if (targetobj.parent().attr('class') === 'tabswitch switch-two') {
            var type = targetobj.attr('tag');
            ViewObj.switchView('wn-replayfileat-view', 'init', {
                'curid': scope.curid,
                'type': type,
                'title': scope.title
            });
        } else {
            //工作回复、@我的-@我的回复页面的点击头像进入个人中心
            if(targetobj.parent('.a-user-pic').length === 1){
                var curid = targetobj.parent('.a-user-pic').attr('userid');//用户ID
                if(curid === userid){
                    ViewObj.switchView('all-userinfo-view', 'init', {
                        view_name: 'onlymeinfo'
                    });
                }
                else{
                    var curname = targetobj.parent('.a-user-pic').next().find('.a-user-intro').html();//用户名
                    curname=curname.split('：')[0];
                    ViewObj.switchView('wn-userinfo-view', 'init', {
                        'curid': curid,
                        'curimg': ld(targetobj)[0].outerHTML,
                        'curinfo': curname//目前只读取用户名，暂无角色权限信息
                    });
                }
            }else if ((scope.type === 'replylist' || scope.type === 'atreplylist' || scope.type === 'document') && ((targetobj.parents('.area-list').length === 1) || targetobj.attr('class') === 'area-list')) {//工作回复、@我的-@我的回复点击除头像外的地方进入明细页
                _this = targetobj.parents('.area-list').length === 1 ? targetobj.parents('.area-list') : targetobj;

                var title_str = _this.find('[reporttypestr]').attr('reporttypestr'),
                    workreportid = _this.find('[workreportid]').attr('workreportid');

                ViewObj.rootScope.loadWorkDetail = function (options) {
                    ViewObj.switchView('wn-workdetail-view', 'init', ld.extend({
                        'workreportid': workreportid,
                        __app_header: ['<', '', '', title_str, '-', '-'],
                        __footer_id: 'wn-workdetail-footer'
                    }, options));
                };
                ViewObj.rootScope.loadWorkDetail();
            } else if (scope.type === 'atworklist') {//@我的-@我的工作页面的点击操作
                //点击点赞、回复、转发或进入明细页
                // 调用 wn-worklist-view 中的内容点击方法，防止代码重复
                OperationObj.triggerCilckEvent(targetobj, 'body', {view_id: 'wn-worklist-view'})
            }
        }
    };
};

// 定义跳转到crm-detail-view(crm明细页)的方法 及click处理定义
ViewObj['create-cwn-crmdetail-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, scope.header, opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ld('#cwn-crmdetail-view').html('');
        var title_str = '';
        // crm中
        if (category === 'crm') {
            var urlstring = typeof opts_obj.url_string === 'string' ? opts_obj.url_string : '';
            if (module == 'Approve') {
                title_str = ViewObj.rootScope.approvemodulename;
            } else {
                title_str = modulename;
            }
            scope.header = ['<', '', '', title_str, '-', '-'];
            ld('.pullDown_title').removeClass('select');//隐藏数据分类下拉
            ViewObj.toViewCommon(to_viewid, scope.header, opts_obj);
            scope.view_name = opts_obj.view_name;
            ViewObj.rootScope.mode = 'detail'; // 全局变量赋值

            if (urlstring !== '') {
                urlstring += '&action=DetailView&CheckPermitted=yes&record=' + recordID + '&mode=detail';
                if (module == 'Approve') {
                    urlstring += '&approvepage=yes';
                } else {
                    urlstring += '&approvepage=no';
                }
            } else {
                alert('switchView("cwn-crmdetail-view","init",{"url_string":XXXX})\n' +
                    'url_string属性不能为空！');
                return;
            }
            ld("#status").show();
            getCRMDetailView(scope.view_name, urlstring, function () {
                ld("#status").hide();
                if (opts_obj.view_name != 'nearbyaccounts' && opts_obj.view_name != 'nearbyaccountssearch') {
                    // 控制右上角 是否显示审批还是，更多
                    if (module === 'Approve') {
                        if (approvepermit === 'yes' && cancelapprove === 'yes') {
                            scope.header.splice(4, 2, '...', '');
                        } else if (approvepermit === 'yes' && cancelapprove === 'no') {
                            scope.header.splice(4, 2, '', '审批');
                        } else if (approvepermit === 'no' && cancelapprove === 'yes') {
                            scope.header.splice(4, 2, '', '反审批');
                        } else {
                            scope.header.splice(4, 2, '...', '');
                        }

                    } else {
                        scope.header.splice(4, 2, '...', '');
                    }
                }
                ViewObj.setAppHeader(scope.header);
                ViewObj.onSwitchAfter(opts_obj);
                // 显示详情页关联信息
                if (ViewObj.rootScope.item_num > 0) {
                    getDetailRelation(ViewObj.rootScope.item_num, ViewObj.rootScope.max_textlen);
                }
                //客户-公海已分配
                if(ViewObj.rootScope.completedpermit === 'yes'){
                    ld('#divReachDetailView').removeClass('ui-hide');
                }
            });
            // news或者work中
        } else {
            var _this = opts_obj.target_obj,
                _recordID = '',
                _modulename = '',
                _approvepage = '';
            scope._status = opts_obj.__status;
            //消息-审批保存后进入明细
            if(category === 'news' && scope._status == 'approve_status'){
                title_str = ViewObj.rootScope.approvemodulename;
                _recordID = recordID;
                _modulename = ViewObj.rootScope.approvemodule;
                _approvepage = 'yes';
            }
            else{
                if (opts_obj.view_name === 'approve_list') {
                    title_str = ViewObj.rootScope.approvemodulename;
                    _recordID = _this.attr('record');
                    _modulename = ViewObj.rootScope.approvemodule;
                    _approvepage = 'yes';
                }
                else if (opts_obj.view_name === 'notice_list') {
                    title_str = _this.find('h5').html();
                    _recordID = _this.attr('record');
                    _modulename = 'PublicAnnouncement';
                    _approvepage = 'yes';
                }
                else {
                    title_str = _this.attr('titlename');
                    _recordID = _this.attr('detailid');
                    _modulename = _this.attr('module');
                    _approvepage = 'no';
                }
            }
            scope.approvepage = _approvepage;
            if (_approvepage === 'yes') {
                scope.header = ['<', '', '', title_str, '-', '-']; // 记录当前页面的头部
            } else {
                scope.header = ['<', '', '', title_str, '', '']; // 记录当前页面的头部
            }
            // 记录前一页信息（返回时需要）
            scope.prev_header = ViewObj.getPrevInfo('header');
            ViewObj.toViewCommon(to_viewid, scope.header, opts_obj);
            scope.prev_vid = ViewObj.getPrevInfo('viewid');
            scope.prev_footerid = ViewObj.getPrevInfo('footerid');
            var detailboxhtml = '<div id="divRelatedList" class="ui-hide"></div>' +
                '<div id="divDetailLabel" class="tabswitch ui-hide"></div>' +
                '<div id="divCoordination" class="ui-hide"></div>' +
                '<div id="detailbox" class="ui-hide"></div>' +
                '<div id="divApproveLog" class="ui-hide"></div>' +
                '<div id="divComment" class="ui-hide"></div>';
            ld('#cwn-crmdetail-view').html(detailboxhtml);
            ld('#detailbox').html('').removeClass('ui-hide');
            if (_modulename == 'PublicAnnouncement') {//公告明细不要显示切换
                ld('#divDetailLabel').addClass('ui-hide');
            }
            var urlstring = 'module=' + _modulename + '&action=DetailView&record=' + recordID + '&approvepage=' + _approvepage;
            if (_modulename == 'PublicAnnouncement') {
                urlstring += '&updatereminds=1';
            }
            getCRMDetailViewforWork(_modulename, urlstring, function () {
                // 控制右上角 是否显示审批还是，更多
                if (approvepermit === 'yes' && cancelapprove === 'yes') {
                    scope.header.splice(4, 2, '...', '');
                } else if (approvepermit === 'yes' && cancelapprove === 'no') {
                    scope.header.splice(4, 2, '', '审批');
                } else if (approvepermit === 'no' && cancelapprove === 'yes') {
                    scope.header.splice(4, 2, '', '反审批');
                } else {
                    scope.header.splice(4, 2, '', '');
                }
                ViewObj.setAppHeader(scope.header);
                ViewObj.onSwitchAfter(opts_obj);
                // 显示详情页关联信息
                if (ViewObj.rootScope.item_num > 0) {
                    getDetailRelation(ViewObj.rootScope.item_num, ViewObj.rootScope.max_textlen);
                }
                //客户-公海已分配
                if(ViewObj.rootScope.completedpermit === 'yes'){
                    ld('#divReachDetailViewforWork').removeClass('ui-hide');
                }
            });
        }
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 点击头部左边
        if (t_id === 'head_left') {
            if (category === 'crm') {
                if (scope.view_name === 'nearbyaccounts') {
                    ViewObj.switchView('crm-nearbyaccounts-view', 'back', {
                        __scroll_top: 'origin'
                    });
                }
                else if (scope.view_name === 'nearbyaccountssearch') {
                    ViewObj.switchView('crm-nearbyaccounts-search-view', 'back', {
                        __scroll_top: 'origin'
                    });
                }
                else {
                    ViewObj.switchView('crm-list-view', 'back', {
                        __scroll_top: 'origin'
                    });
                }
            } else {
                if(category === 'news' && scope._status == 'approve_status'){
                    ViewObj.switchView('news-third-view', 'back', {
                        __scroll_top: 'origin'
                    });
                }
                else{
                    ViewObj.switchView(scope.prev_vid, 'back', {
                        __scroll_top: 'origin',
                        __app_header: scope.prev_header,
                        __footer_id: scope.prev_footerid
                    });
                }
            }
            // 点击头部右边
        } else if (t_id === 'head_rig') {
            // 如果是审批 直接进入审批
            if (ld('#head_rig span').html() === '审批') {
                ViewObj.switchView('cn-approval-view', 'init', {
                    view_name: 'approval'
                });
                // 进入更多选项
            } else if (ld('#head_rig span').html() === '反审批') {
                ViewObj.switchView('cn-approval-view', 'init', {
                    view_name: 'cancel_approval'
                });
            } else if (targetobj.attr('class') === 'lnr-more') {
                if (module === "Approve" ||
                    scope.approvepage === 'yes') {
                    ld('#tplDetailOperation>.btnsub').addClass('ui-hide');
                    if (approvepermit == 'yes') {
                        ld('#tplDetailOperation>[tag=btn_submit]').removeClass('ui-hide');
                    }
                    if (cancelapprove == 'yes') { //是否有反审批按钮权限(yes:有)
                        ld('#tplDetailOperation>[tag=btn_cancelapprove]').removeClass('ui-hide');
                    }
                }
                logicHanderObj.popUpMaskToggle('tplDetailOperation');
            }
        }
    };
    // 底部点击操作
    ViewObj[to_viewid + '-footer-click'] = function (targetobj, clickOpts) {
        // 点击底部“编辑按钮”
        if (targetobj.attr('id') === 'crm-detail-footer') {
            ViewObj.rootScope.list_create = 'create';
            ViewObj.switchView('crm-createedit-view', 'init', {
                view_name: 'edit'
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = null;
        // 点击crm明细页面相关信息
        if (targetobj.parents('#divRelatedList').length === 1
            && targetobj.attr('class') != 'lnr-chevron-right re-arrow') {
            _this = targetobj.parents('div[is_related]');
            if (_this.length === 1 || targetobj.attr('is_related')) {
                _this = _this.length ? _this : targetobj;
                if (!_this.attr('moudle')) return;
                var re_module = _this.attr('is_related');
                if (re_module === 'NearbyAccounts') {
                    re_module = 'Accounts';
                }
                ViewObj.switchView('cwn-relationlist-view', 'init', {
                    'module': _this.attr('moudle'),
                    'label': _this.attr('label'),
                    'is_related_module': re_module,
                    'record': _this.attr('record'),
                    'relatedid': _this.attr('relatedid')
                });
            }
            // 点击crm明细页面切换按钮
        } else if (targetobj.parents('#divDetailLabel').length === 1) {
            _this = targetobj;
            var choosename = _this.attr('choosename'),
                urlstring = '';
            ld('#divDetailLabel>.curr').removeClass('curr');
            _this.addClass('curr');
            ld('#cwn-crmdetail-view>div').not('#divRelatedList,#divDetailLabel').addClass('ui-hide');
            ViewObj.switchFooter('crm-detail-footer', 'hidden');
            // 明细界面
            if (choosename == 'detailView') {
                ld('#detailbox').removeClass('ui-hide');
                ViewObj.switchFooter('crm-detail-footer', 'display');
                SwiperObj.autoHeight(0);
                // 审批历史
            } else if (choosename == 'divApprove') {
                ld('#divApproveLog').removeClass('ui-hide');
                urlstring = '';
                if (module != 'Approve') {
                    urlstring += '&modulename=' + module;
                } else {
                    urlstring += '&modulename=' + approvemodule;
                }
                urlstring += '&recordid=' + recordID + '&setype=Approvelog';
                commonHandleObj.getApproveLogInfo(urlstring, function () {
                    SwiperObj.autoHeight(0);
                });
                // 评论信息
            } else if (choosename == 'divComment') {
                ld('#divComment').removeClass('ui-hide');
                var urlstring = '&modulename=' + module + '&recordid=' + recordID + '&setype=ModComments';
                commonHandleObj.getCommentInfo(urlstring, function () {
                    SwiperObj.autoHeight(0);
                });
                // 工作协同
            } else if (choosename == 'coordination') {
                ld('#divCoordination').removeClass('ui-hide');
                var urlstring = '&modulename=' + module + '&roleid=' + recordID;
                commonHandleObj.getCoordinationInfo('detail', urlstring, function () {
                    SwiperObj.autoHeight(0);
                });
            }
            // 点击右上角更多操作
        } else if (targetobj.parents('#tplDetailOperation').length === 1) {
            OperationObj.triggerCilckEvent(ld('#layerMask'));
            var tag = targetobj.attr('tag');
            switch (tag) {
                // 分配 1  1  明细刷新、列表刷新
                case 'btn_distribution':
                    ViewObj.switchView('cwn-popuselect-view', 'init', {
                        view_name: 'users_list',
                        'return_module': module,//模块
                        'searchtype': 'bymodule',//类型 (bymodule:根据模块权限; byscope:根据授权范围; all:全部)
                        'filterown': 'no',//是否过滤自己(yes:过滤, no:不过滤)
                        'scopetype': 'user',//显示类型( group:只显示部门; user:只显示用户; groupuser:显示部门及用户)
                        'common': 0,//是否显示常用标签(0:不显示;1:常用标签下没有我的选项;2:常用标签下有我的选项)
                        'isactive': 'no',//是否显示禁用用户（yes:显示,no:不显示  默认no）
                        'popup_type':'Allocate'//分配
                    });
                    break;
                // 公海分配 1  1  明细刷新、列表刷新
                case 'btn_allocateaccount':
                    ViewObj.switchView('cwn-popuselect-view', 'init', {
                        view_name: 'users_list',
                        'return_module': module,//模块
                        'searchtype': 'bymodule',//类型 (bymodule:根据模块权限; byscope:根据授权范围; all:全部)
                        'filterown': 'no',//是否过滤自己(yes:过滤, no:不过滤)
                        'scopetype': 'user',//显示类型( group:只显示部门; user:只显示用户; groupuser:显示部门及用户)
                        'common': 0,//是否显示常用标签(0:不显示;1:常用标签下没有我的选项;2:常用标签下有我的选项)
                        'isactive': 'no',//是否显示禁用用户（yes:显示,no:不显示  默认no）
                        'popup_type':'publicallocate'//分配
                    });
                    break;
                // 领取 1 1
                case 'btn_receive':
                    var urlstring = 'module=' + module + '&action=AllocateAccount&record=' + recordID + '&maxaccount=1';
                    WordReportAjax(urlstring, function (rest) {
                        if (rest == '') return false;
                        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                        if (restobj.code == 1) {
                            PopPromptBox.show({
                                main_text: restobj.msg,
                                btn_type: 'yesno',
                                yes_fun: function () {
                                    var urlstr = 'module=' + module + '&action=AllocateAccount&record=' + recordID + '&updateAccount=yes&allocatetype=3';
                                    WordReportAjax(urlstr, function (rest) {
                                        SwiperObj.ListPageObj.setListPageIndex(1, 'crm-list-view');
                                        // 刷新crm列表
                                        EventHanderObj.refreshCrmList();
                                        ViewObj.rootScope.loadCrmdetail({__direction: 'right_out'});
                                    });
                                }
                            });
                        } else {
                            PopPromptBox.show(restobj.msg);
                            return false;
                        }
                    });
                    break;
                // 共享 1 1
                case 'btn_share':
                    var share_label = ld('#divRelatedList').find('[moudle=ShareUser]').attr('label');
                    if(share_label == '' || share_label == undefined || share_label == 'undefined'){
                        share_label = '共享';
                    }
                    ViewObj.switchView('cwn-relationlist-view', 'init', {
                        'module': 'ShareUser',
                        'label': share_label,
                        'is_related_module': ld('#divRelatedList').find('[moudle=ShareUser]').attr('is_related'),
                        'record': recordID,
                        'relatedid': ld('#divRelatedList').find('[moudle=ShareUser]').attr('relatedid')
                    });
                    break;
                // 推进 1 0
                case 'btn_advance':
                    ViewObj.switchView('cwn-popuselect-view', 'init', {
                        view_name: 'advance_list drop_down_list',
                        __refreshable: false,
                        title_str: '推进',
                        select_mode: 'single',
                        show_search: false,
                        choose_style: 'v',
                        auto_back: true,
                        multi_autotoggle: false,
                        initFun: function (callback) {
                            //显示选择列表
                            var urlstring = 'module=' + module + '&action=EditStatus&setype=opts';
                            WordReportAjax(urlstring, function (rest) {
                                if (rest == '') return false;
                                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                                var statushtml = '';
                                if (restobj.result.list == '') {
                                    statushtml += logicHanderObj.NoinfoNotice('数据');
                                } else {
                                    statushtml += '<ul>';
                                    ld.each(restobj.result.list, function (statuskey, statusvalue) {
                                        if (statusvalue != '') {
                                            statushtml += '<li item="popu_select">' + statusvalue + '</li>';
                                        }
                                    });
                                    statushtml += '</ul>';
                                }
                                ld('#cwn-popuselect-view>.content-wrapper').html(statushtml);
                                callback();
                            });
                        },
                        itemFun: function (target_item, related_obj) {
                            var statusname = target_item.html(),
                                urlstring = 'module=' + module + '&action=EditStatus' +
                                    '&setype=save&salesstage=' + statusname + '&record=' + recordID;
                            WordReportAjax(urlstring, function (rest) {
                                if (rest == '') return false;
                                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                                ld('#lastsales_stage_advance').html(ld('#sales_stage_advance').html());
                                ld('#sales_stage_advance').html(statusname);
                            });
                        }
                    });
                    break;
                // 提交审批 1 0
                case 'btn_submitapprove':
                    var urlstring = 'module=Approve&action=SubmitApprove&fld_module=' + module + '&record=' + recordID + '&check=true&save=false';
                    WordReportAjax(urlstring, function (rest) {
                        if (rest == '') return false;
                        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                        if (restobj.code == -1) {
                            PopPromptBox.show(restobj.msg);
                            ViewObj.rootScope.loadCrmdetail({__direction: 'right_out'});
                            return false;
                        }
                        else {
                            var urlstring = 'module=Approve&action=SubmitApprove&fld_module=' + module + '&record=' + recordID + '&check=false&save=false';
                            WordReportAjax(urlstring, function (rest) {
                                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                                if (restobj.code == -1) {
                                    PopPromptBox.show('您没有适用的审批流程，请联系管理员检查并设置审批流程');
                                    return false;
                                } else {
                                    ViewObj.switchView('cwn-popuselect-view', 'init', {
                                        view_name: 'submit_approve'
                                    });
                                }
                            });
                        }
                    });
                    break;
                // 审批 1 1
                case 'btn_submit':
                    ViewObj.switchView('cn-approval-view', 'init', {
                        view_name: 'approval'
                    });
                    break;
                // 反审批 1 1
                case 'btn_cancelapprove':
                    ViewObj.switchView('cn-approval-view', 'init', {
                        view_name: 'cancel_approval'
                    });
                    break;
                // 删除 1 1
                case 'btn_del':
                    PopPromptBox.show({
                        main_text: '确定要删除吗？',
                        btn_type: 'yesno',
                        yes_fun: function () {
                            var urlstring = 'module=' + module + '&action=Delete&record=' + recordID;
                            WordReportAjax(urlstring, function (rest) {
                                if (empty(rest)) return false;
                                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                                if (restobj.code == -1) {//如果失败弹出提示
                                    PopPromptBox.show(restobj.msg);
                                    return;
                                } else {
                                    // 在列表中 移除 已删除的 项
                                    ld('#listbox li[record="' + recordID + '"]').remove();
                                }
                            });
                            ViewObj.switchView('crm-list-view', 'back');
                        }
                    });
                    break;
                default:
            }
            // 点击评论按钮
        } else if (targetobj.attr('class') === 'savebtn' &&
            targetobj.parents('#divComment').length === 1 && ViewObj.rootScope.savestatus != 'yes') {

            ViewObj.rootScope.savestatus = 'yes';
            var commentsContent = ld('#commentsContent').val();
            if (commentsContent == '') {
                PopPromptBox.show('评论内容不能为空');
                ViewObj.rootScope.savestatus = 'no';
                return false;
            }
            var urlstring = 'module=ModComments&action=DetailViewAjax&Create=true&ajxaction=WIDGETADDCOMMENT' +
                            '&parentid=' + recordID + '&comment=' + commentsContent + '&modulename=' + module;
            WordReportAjax(urlstring, function (rest) {
                ld('#detailbox').addClass('ui-hide');
                ld('#divComment').removeClass('ui-hide');
                var urlstr = '&modulename=' + module + '&recordid=' + recordID + '&setype=ModComments';
                commonHandleObj.getCommentInfo(urlstr, function () {
                    ViewObj.rootScope.savestatus = 'no';
                    SwiperObj.autoHeight(-1);
                });
            });
            // 点击产品清单项
        } else if (targetobj.parents('#productbill').length === 1 || targetobj.parents('#productbillnew').length === 1) {
            var switchopts = {};
            if(targetobj.parents('#productbill').length === 1){
                _this = targetobj.parents('li[tag]').length === 1 ? targetobj.parents('li[tag]') : targetobj;
                switchopts.type = 'old';
                //switchopts.view_name = 'product';
                switchopts.module = _this.attr('module');
                switchopts.product_id = _this.attr('tag');
            }
            else if(targetobj.parents('#productbillnew').length === 1){
                _this = targetobj.parents('li[entryid]').length === 1 ? targetobj.parents('li[entryid]') : targetobj;
                switchopts.type = 'new';
                var entry_title = ld('#detailbox').find('h2:last').text(),
                    entry_title_info = '';
                if(_this.attr('module') == 'Quotes' || _this.attr('module') == 'SalesOrder' || _this.attr('module') == 'ServiceContracts'){
                    entry_title_info = ld('#detailbox').find('h2:last').find('.pricetype').text();
                    entry_title = entry_title.replace(entry_title_info,'');
                }
                switchopts.title = entry_title;
                switchopts.module = _this.attr('module');
                switchopts.entryid = _this.attr('entryid');
                switchopts.entrytype = _this.attr('entrytype');
            }
            switchopts.recordID = recordID;
            switchopts.sequence_no = _this.attr('sequence_no');
            ViewObj.switchView('cwn-crmdetailsub-view', 'init', switchopts);
        } else if (targetobj.attr('class') === 'lnr-chevron-right re-arrow') {
            SwiperObj.WorkRelation_swiper.slideNext();
        } else if (targetobj.attr('tag') === 'sign_address') {
            ViewObj.switchView('cwn-seeposition-view', 'init', {
                onSwitchAfter: function () {
                    //根据客户ID，获取客户地址
                    var urlstring = 'module=Users&action=getDetailBlock' +
                                    '&recordid=' + ViewObj.rootScope.account_id + '&setype=AccountsAddress';
                    WordReportAjax(urlstring, function (rest) {
                        if (empty(rest)) return false;
                        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                        var signaccountAddress = restobj.result.list.address;
                        if (signaccountAddress != '') {
                            var script = document.createElement("script");
                            script.type = "text/javascript";
                            script.src = "http://api.map.baidu.com/geocoder/v2/?ak=Hgvb6X18khZw223dBW1hFHuT&callback=getLocationformAddress&output=json&address=" + encodeURIComponent(signaccountAddress);
                            document.body.appendChild(script);
                        }
                    });
                }
            });
        } else if (targetobj.attr('class') === 'c-detail-h2' || targetobj.parent().attr('class') === 'c-detail-h2') {
            if(targetobj.parent().attr('class') === 'c-detail-h2') {
                targetobj = targetobj.parent();
            }
            targetobj.next().toggleClass('ui-hide');
            SwiperObj.autoHeight(-1);  //滚动条保持原位
            if (targetobj.children().attr('class') === 'lnr-chevron-up') {
                targetobj.children().attr('class', 'lnr-chevron-down');
            } else if (targetobj.children().attr('class') === 'lnr-chevron-down') {
                targetobj.children().attr('class', 'lnr-chevron-up');
            }
        } 
        //查看附件
        else if (targetobj.parent().parent().attr('class') == 'item-content'){
            _this = targetobj.parent().parent();
            var ext = '',
                item_id = _this.attr('att_id'),
                item_path = _this.find('.item-path').html(),
                item_title = _this.find('.item-title').html();

            var item_title_arr = item_title.split(".");
            ext = item_title_arr[item_title_arr.length-1];
            ext = ext.toLowerCase();
            if(ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'bmp' || ext == 'gif' || ext == 'tiff'){
                ViewObj.switchView('cwn-attview-view', 'init', {
                    ext: ext,
                    title_str: item_title,                
                    att_path: item_path+item_title
                });
            }
            else if(ext == 'txt' || ext == 'doc' || ext == 'docx' || ext == 'pdf' || ext == 'ppt' || ext == 'pptx' || 
                    ext == 'xls' || ext == 'xlsx' || ext == 'htm' || ext == 'html'){
                machineHanderObj.AttachmentPreview(item_id,item_path+item_title);
            }
            else{
                PopPromptBox.show('您点开的附件无法在手机上查看');
                return;
            }
        }
    };
};

// 定义跳转到crm-detailsub-view的方法 查看产品、费用报销单、编辑页 及click处理定义
ViewObj['create-cwn-crmdetailsub-view'] = function (to_viewid, siwtch_type, scope) {
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        var opts = opts_obj,
            _type = opts.type,
            title_str = '产品清单',
            urlstring = '';
        if(_type == 'old'){
            urlstring = 'module=Users&action=getDetailBlock&setype=ProductInfo&modulename=' + opts_obj.module +
                        '&recordid=' + opts.recordID + '&productid=' + opts.product_id + '&sequence_no=' + opts.sequence_no;
        }
        else if(_type == 'new'){
            title_str = opts.title;
            urlstring = 'module=Users&action=getDetailBlock&setype=entrydetail&modulename=' + opts_obj.module +
                        '&recordid=' + opts.recordID + '&entryid=' + opts.entryid + '&entrytype=' + opts.entrytype + '&sequence_no=' + opts.sequence_no;
        }
        ViewObj.toViewCommon(to_viewid, ['<', '', '', title_str, '', ''], opts_obj);
        scope.__footer_id = ViewObj.getPrevInfo('footerid');
        ld('#status').show();
        WordReportAjax(urlstring, function (rest) {
            ld('#status').hide();
            try {
                if (empty(rest)) return false;
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                var tplnode = '<ul class="c-ul c-detail-cell">';
                if(restobj.result.list){
                    ld.each(restobj.result.list, function (key, list) {
                        if (list.fieldname == 'imagename') {
                            var productImgHtml = '',
                                i = 0;
                            if (list.value) {
                                ld.each(list.value, function (keyoption, listoption) {
                                    productImgHtml += '<div  img-detail=""> <img  img_num="' + (++i) + '" src="http://' + loginurl + '/' + listoption.option + '" onload="logicHanderObj.loadimg(this)"/></div>';
                                });
                            }
                            if(_type == 'old'){
                                tplnode += '<li><i>' + list.fieldlabel + '</i><div class="view picture-rang picture-preview">' + productImgHtml + '</div></li>';
                            }
                            else if(_type == 'new'){
                                tplnode += '<li><i>' + list.label + '</i><div class="view picture-rang picture-preview">' + productImgHtml + '</div></li>';
                            }
                        }
                        else {
                            if(_type == 'old'){
                                tplnode += '<li><i>' + list.fieldlabel + '</i><span>' + list.value + '</span></li>';
                            }
                            else if(_type == 'new'){
                                if(list.text == ''){
                                    list.text = '未填写';
                                }
                                tplnode += '<li><i>' + list.label + '</i><span>' + list.text + '</span></li>';
                            }
                        }
                    }); 
                }
                tplnode += '</ul>';
                ld('#cwn-crmdetailsub-view').html(tplnode);
                ViewObj.onSwitchAfter(opts_obj);
            } catch (e) {
                logicHanderObj.errorNotice();
            }
        });
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 点击头部左边
        if (t_id === 'head_left') {
            ViewObj.switchView(ViewObj.getPrevInfo('viewid'), 'back', {
                __scroll_top: 'origin',
                __footer_id: scope.__footer_id,
            });
        }
    };
};

// 定义跳转到cwn-relationlist-view(相关列表页)的方法 及click处理定义
ViewObj['create-cwn-relationlist-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, scope.header, opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
        if(newmodule == 'ShareUser'){
            ld('#app_header #head_rig').find('.lnr-plus').attr('fild_id','shareuserid');
            ld('#app_header #head_rig').find('.lnr-plus').attr('desc','create');
            ld('#app_header #head_rig').find('.lnr-plus').attr('flid_lable',ld('#app_header #head_mid').find('span').html().replace('选择',''));
            ld('#app_header #head_rig').find('.lnr-plus').attr('choose_module','ShareUsers');
            ld('#app_header #head_rig').find('.lnr-plus').attr('parentstatus','no');
        }
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        var opts = opts_obj,
            newmodulerelated = opts.module,
            modulename = opts.label,
            related_module = opts.is_related_module,
            record = opts.record,
            relatedid = opts.relatedid,
            urlstring = '';
        scope.header = ['<', '', '', modulename, '', ''];

        ViewObj.toViewCommon(to_viewid, scope.header, opts_obj);

        if (newmodulerelated == 'ModTracker') {
            urlstring = 'module=Home&action=ListView&method=getFieldUpdateLog&static=ModTracker' +
                        '&rmodule=' + related_module + '&fieldtype=assigned_user_id&record=' + record;
            WordReportAjax(urlstring, function () {
            });
            return;
        } else {
            ld('#relatedlistbox').html('');
            newmodulename = modulename; //  全局变量赋值
            newmodule = newmodulerelated; // 全局变量赋值
            relatedrecord = record; // 全局变量赋值
            relatedmodule = related_module; // 全局变量赋值
            related_id = relatedid;
            if (relatedmodule === 'ServiceCharge') {
                relatedmodule = 'Accounts';
            }
            //字段公式
            var f_module = newmodule;
            if (newmodule == 'Approve') {
                f_module = ViewObj.rootScope.approvemodule;
            }
            if (ld.inArray(f_module, formulaArray) >= 0) {
                getJsScript('js/producttool/DateTime.js', function () {
                });
                getJsScript('js/producttool/toolField.js', function () {
                });
                getJsScript('js/producttool/mobileformula.js', function () {
                });
                getJsScript('js/producttool/TabDetailFields.js', function () {
                });
                getJsScript('js/producttool/TabDetailFieldFormula.js', function () {
                });
            }
            urlstring = 'module=' + newmodule + '&action=index&viewid=SmOwner_Search_All&page=1&searchcontent=';//默认是第一页
            getRelatedList(urlstring, function () {
                ViewObj.onSwitchAfter(opts_obj);
            });
        }
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 点击头部左边
        if (t_id === 'head_left') {
            ViewObj.switchView('cwn-crmdetail-view', 'back');
        }
        else if (t_id === 'head_rig') {// 头部右边
            //共享人進入選擇界面
            if(newmodule == 'ShareUser'){
                // 跳转到带刷新的弹出页面
                ViewObj.switchView('cwn-popuselect-view', 'init', {
                    view_name: 'choose_module',
                    target_obj: targetobj
                });
            }
            else{
                GVObj.crmObj.quickcreateStatus = 'no';
                ViewObj.rootScope.list_create = 'relationcreate';
                ViewObj.switchView('crm-createedit-view', 'init', {
                    view_name: 'relationcreate'
                });
            }
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        // 列点击表选项
        var _this = targetobj.parents('li[record]');
        if (_this.length === 1 ||
            targetobj[0].tagName.toLowerCase() === 'li') {
            _this = _this.length ? _this : targetobj;
            // 点击联系人列表 电话图标 拨打电话
            if (newmodule === 'Contacts' && _this.attr('tag') === 'call') {
                logicHanderObj.Telephone(_this.attr('phonemobile'));
            } else {
                var urlstring = 'module=' + newmodule + '&action=DetailView&CheckPermitted=yes&record=' + _this.attr('record') + '&mode=detail&approvepage=no';
                WordReportAjax(urlstring, function (rest) {
                    var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                    if (restobj.code != -1) {
                        // 点击列表项进入明细
                        ViewObj.switchView('cwn-relationdetail-view', 'init', {
                            __app_header: ['<', '', '', ViewObj.getInfo('current_header')[3], '', ''],
                            'record': _this.attr('record')
                        });
                    } else {
                        PopPromptBox.show(restobj.msg);
                        ld("#status").hide();
                        return;
                    }
                });
            }
        }
    };
};

// 定义跳转到cwn-relationdetail(相关明细页)的方法 及click处理定义
ViewObj['create-cwn-relationdetail-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', newmodulename, '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        var opts = ld.isPlainObject(opts_obj) ? opts_obj : {},
            urlstring = '';
        ld('#cwn-relationdetail-view').html('');
        ViewObj.toViewCommon(to_viewid, ViewObj.getPrevInfo('header'), opts_obj);
        ViewObj.rootScope.related_recordid = opts.record;
        urlstring = 'module=' + newmodule + '&action=DetailView&CheckPermitted=yes&record=' + ViewObj.rootScope.related_recordid + '&mode=detail&approvepage=no';
        ld("#status").show();
        getRelatedDetail(urlstring, function () {
            ld("#status").hide();
            ViewObj.onSwitchAfter(opts_obj);
            //客户-公海已分配
            if(ViewObj.rootScope.completedpermit === 'yes'){
                ld('#divReachDetailViewforRea').removeClass('ui-hide');
            }
        });
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 点击头部左边
        if (t_id === 'head_left') {
            ViewObj.switchView('cwn-relationlist-view', 'back', {
                __scroll_top: 'origin'
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        // 点击相关明细切换
        if (targetobj.parents('#divDetailLabelrelated').length === 1) {
            ld('#divDetailLabelrelated>.curr').removeClass('curr');
            targetobj.addClass('curr');
            var choosename = targetobj.attr('choosename'),
                urlstring = '';
            // ld('#divDetailLabelrelated>a').addClass('ui-hide');
            ld('#divCoordinationrelated,#detailboxrelated,#divApproveLogrelated,#divCommentrelated').addClass('ui-hide');
            switch (choosename) {
                // 明细界面
                case 'detailView':
                    ld('#detailboxrelated').removeClass('ui-hide');
                    SwiperObj.autoHeight(0);
                    break;
                // 审批历史
                case 'divApprove':
                    ld('#divApproveLogrelated').removeClass('ui-hide');
                    if (relatedmodule != 'Approve') {
                        urlstring += '&modulename=' + relatedmodule;
                    } else {
                        urlstring += '&modulename=' + approvemodule;
                    }
                    urlstring += '&recordid=' + ViewObj.rootScope.related_recordid + '&setype=Approvelog';
                    commonHandleObj.getApproveLogInfo(urlstring, function () {
                        SwiperObj.autoHeight(0);
                    });
                    break;
                // 评论信息
                case 'divComment':
                    ld('#divCommentrelated').removeClass('ui-hide');
                    urlstring = '&modulename=' + relatedmodule + '&recordid=' + ViewObj.rootScope.related_recordid + '&setype=ModComments&isrelated=yes';
                    commonHandleObj.getCommentInfo(urlstring, function () {
                        SwiperObj.autoHeight(0);
                    });
                    break;
                // 工作协同
                case 'coordination':
                    ld('#divCoordinationrelated').removeClass('ui-hide');
                    urlstring = '&modulename=' + relatedmodule + '&roleid=' + ViewObj.rootScope.related_recordid;
                    commonHandleObj.getCoordinationInfo('relatedDetail', urlstring, function () {
                        SwiperObj.autoHeight(0);
                    });
                    break;
            }
        } else if (targetobj.parents('#productbill').length === 1 || targetobj.parents('#productbillnew').length === 1) {
            var switchopts = {};
            if(targetobj.parents('#productbill').length === 1){
                _this = targetobj.parents('li[tag]').length === 1 ? targetobj.parents('li[tag]') : targetobj;
                switchopts.type = 'old';
                // switchopts.view_name = 'product';
                switchopts.product_id = _this.attr('tag');
            }
            else if(targetobj.parents('#productbillnew').length === 1){
                _this = targetobj.parents('li[entryid]').length === 1 ? targetobj.parents('li[entryid]') : targetobj;
                switchopts.type = 'new';
                var entry_title = ld('#detailboxrelated').find('h2:last').text(),
                    entry_title_info = '';
                if(newmodule == 'Quotes' || newmodule == 'SalesOrder' || newmodule == 'ServiceContracts'){
                    entry_title_info = ld('#detailboxrelated').find('h2:last').find('.pricetype').text();
                    entry_title = entry_title.replace(entry_title_info,'');
                }
                switchopts.title = entry_title;
                switchopts.entryid = _this.attr('entryid');
                switchopts.entrytype = _this.attr('entrytype');
            }
            switchopts.module = newmodule;
            switchopts.recordID = ViewObj.rootScope.related_recordid;
            switchopts.sequence_no = _this.attr('sequence_no');
            ViewObj.switchView('cwn-crmdetailsub-view', 'init', switchopts);
        } else if (targetobj.attr('class') === 'c-detail-h2' || targetobj.parent().attr('class') === 'c-detail-h2') {
            if(targetobj.parent().attr('class') === 'c-detail-h2') {
                targetobj = targetobj.parent();
            }
            targetobj.next().toggleClass('ui-hide');
            SwiperObj.autoHeight(-1);  //滚动条保持原位
            if (targetobj.children().attr('class') === 'lnr-chevron-up') {
                targetobj.children().attr('class', 'lnr-chevron-down');
            } else if (targetobj.children().attr('class') === 'lnr-chevron-down') {
                targetobj.children().attr('class', 'lnr-chevron-up');
            }
        }
        else if (targetobj.attr('class') === 'savebtn' &&
            targetobj.parents('#divCommentrelated').length === 1 && ViewObj.rootScope.savestatus != 'yes') {

            ViewObj.rootScope.savestatus = 'yes';
            var commentsContent = ld('#r_commentsContent').val();
            if (commentsContent == '') {
                PopPromptBox.show('评论内容不能为空');
                ViewObj.rootScope.savestatus = 'no';
                return false;
            }
            var urlstring = 'module=ModComments&action=DetailViewAjax&Create=true&ajxaction=WIDGETADDCOMMENT' +
                            '&parentid=' + ViewObj.rootScope.related_recordid + '&comment=' + commentsContent + '&modulename=' + newmodule;
            WordReportAjax(urlstring, function (rest) {
                ld('#detailboxrelated').addClass('ui-hide');
                ld('#divCommentrelated').removeClass('ui-hide');
                var urlstr = '&modulename=' + newmodule + '&recordid=' + ViewObj.rootScope.related_recordid + '&setype=ModComments';
                commonHandleObj.getCommentInfo(urlstr, function () {
                    ViewObj.rootScope.savestatus = 'no';
                    SwiperObj.autoHeight(-1);
                });
            });
            // 点击产品清单项
        }
        //查看附件
        else if (targetobj.parent().parent().attr('class') == 'item-content'){
            _this = targetobj.parent().parent();
            var ext = '',
                item_id = _this.attr('att_id'),
                item_path = _this.find('.item-path').html(),
                item_title = _this.find('.item-title').html();

            var item_title_arr = item_title.split(".");
            ext = item_title_arr[item_title_arr.length-1];
            ext = ext.toLowerCase();
            if(ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'bmp' || ext == 'gif' || ext == 'tiff'){
                ViewObj.switchView('cwn-attview-view', 'init', {
                    ext: ext,
                    title_str: item_title,                
                    att_path: item_path+item_title
                });
            }
            else if(ext == 'txt' || ext == 'doc' || ext == 'docx' || ext == 'pdf' || ext == 'ppt' || ext == 'pptx' || 
                    ext == 'xls' || ext == 'xlsx' || ext == 'htm' || ext == 'html'){
                machineHanderObj.AttachmentPreview(item_id,item_path+item_title);
            }
            else{
                PopPromptBox.show('您点开的附件无法在手机上查看');
                return;
            }
        }
    };
};

// 定义跳转到cwn-seeposition(查看定位页)的方法 及click处理定义
ViewObj['create-cwn-seeposition-view'] = function (to_viewid, siwtch_type, scope) {
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        scope.prev_header = ViewObj.getPrevInfo('header');
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '地图', '', ''], opts_obj)
        scope.prev_vid = ViewObj.getPrevInfo('viewid');
        scope.prev_footerid = ViewObj.getPrevInfo('footerid');
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {

        var t_id = clickOpts.target_id;
        // 点击头部左边
        if (t_id === 'head_left') {
            ViewObj.switchView(scope.prev_vid, 'back', {
                __scroll_top: 'origin',
                __footer_id: scope.prev_footerid,
                __app_header: scope.prev_header
            });
        }
    };
};

// 定义跳转到crm_news审批、反审批页的方法 及click处理定义
ViewObj['create-cn-approval-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', scope.title_str, '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        scope = opts_obj;
        ViewObj.toViewCommon(to_viewid, ['<', '', '', scope.title_str, '', '确定'], scope);
        // 增加无操作效果
        ld('#head_rig').find('span').addClass('nooperation');
        // 审批页面初始化
        if (scope.view_name === 'approval') {
            ld('#tplcancelApproved').hide();
            ld('#tplApprovalStep').show();
            ld('#approvalStepContent').html('');
            var urlstring = 'module=Approve&action=ApproveStep&fld_module=' + approvemodule + '&record=' + recordID + '&userid=' + userid;
            commonHandleObj.getApproveStep(urlstring, function () {
                // 刪除无操作效果
                ld('#head_rig').find('span').removeClass('nooperation');                
                ViewObj.onSwitchAfter(scope);
            });
            // 反审批页面初始化
        } else if (scope.view_name === 'cancel_approval') {
            ld('#tplApprovalStep').hide();
            ld('#tplcancelApproved').show();
            ld('#cancelApprovedCon').html('');
            var urlstring = 'module=Approve&action=getCancelApprove&fld_module=' + approvemodule +
                '&record=' + recordID + '&setype=approveinfo';
            WordReportAjax(urlstring, function (rest) {
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                if (restobj.code == 1) {
                    // 审批流程删除/禁用
                    if (restobj.result.list2.status == 0) {
                        PopPromptBox.show({
                            main_text: '当前审批流程已经被删除或者删除，是否使用新的审批流程重新流转？',
                            btn_type: 'yesno',
                            yes_fun: function () {
                                commonHandleObj.getCancelApprove(restobj.result);
                            },
                            no_fun: function () {
                                ViewObj.switchView('cwn-crmdetail-view', 'back');//返回明细界面
                            }
                        });
                        // 删除无操作效果
                        ld('#head_rig').find('span').removeClass('nooperation');
                    }
                    // 可正常使用
                    else{
                        commonHandleObj.getCancelApprove(restobj.result);
                    }
                }
                else{
                    //非管理员，审批流程被删除或者禁用，只能返回明细界面，无法进行反审批操作
                    PopPromptBox.show(restobj.msg);
                    ViewObj.switchView('cwn-crmdetail-view', 'back');//返回明细界面
                    return;
                }
                return;
            });
        }
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 点击头部左边
        if (t_id === 'head_left') {
            ViewObj.switchView('cwn-crmdetail-view', 'back');
        } else if (t_id === 'head_rig' && ViewObj.rootScope.savestatus != 'yes' && !ld('#head_rig').find('span').hasClass('nooperation')) {
            ViewObj.rootScope.savestatus = 'yes';
            // 审批保存
            if (scope.view_name === 'approval') {
                if (category == 'news' || module == 'Approve') {
                    fld_module = approvemodule;
                } else {
                    fld_module = module;
                }
                ViewObj.rootScope.stepid = ld('#stepid').val();
                ViewObj.rootScope.nextstep = ld('#nextstep').val();
                var approveRemarks = ld('#approveRemarks').val(),
                    nextuserid = ld('#nextapproval').val(),
                    urlstring = 'module=Approve&action=SaveApproveLog&approvestatus=' + GVObj.approveObj.approvestatus + '&record=' + recordID +
                                '&approveid=' + ViewObj.rootScope.approveid + '&stepid=' + ViewObj.rootScope.stepid +
                                '&fld_module=' + fld_module + '&description=' + approveRemarks;
                //通过并继续下一步
                if (GVObj.approveObj.approvestatus == 1) {
                    if(ld('#nextapproval').length == 1){
                        if(nextuserid == '' || nextuserid == null){
                            PopPromptBox.show('下一步骤的审批人为空，无法提交');
                            ViewObj.rootScope.savestatus = 'no';
                            return;
                        }
                    }
                    urlstring += '&nextstep=' + ViewObj.rootScope.nextstep + '&nextuserid=' + nextuserid;
                }
                //不通过，返回到上一步
                if (GVObj.approveObj.approvestatus == 5) {
                    urlstring += '&laststepid=' + ViewObj.rootScope.laststepid;
                }
                WordReportAjax(urlstring, function (rest) {
                    var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                    if (restobj.code == -1) {//如果失败弹出提示
                        PopPromptBox.show(restobj.msg);
                        ViewObj.rootScope.savestatus = 'no';
                        return;
                    }
                    ViewObj.rootScope.savestatus = 'no';
                    ld('#approveRemarks').val('');
                    // 保存结束后返回到 list列表页
                    if (category == 'news') {
                        // 调用 news-second-view 页面 ，进入“待审批” 点击事件
                        /*
                        OperationObj.triggerCilckEvent(ld('#news-second-view li[tag="Pendingapproval"]').eq(0),
                            'body', {view_id: 'news-second-view'});
                        */                        
                        OperationObj.triggerCilckEvent(ld('#newsapprove-list-view li[tag="'+ViewObj.rootScope.approvemodule+'"]').find('a').eq(0),
                            'body', {view_id: 'newsapprove-list-view'});                            
                    } else {
                        var urlstring = '';
                        if (module == 'Approve') {
                            // 调用 crm-main-view 页面 ，进入“审批中心” 点击事件
                            /*
                            OperationObj.triggerCilckEvent(ld('#crm-main-view li[module="Approve"]').eq(0),
                                'body', {view_id: 'crm-main-view'});
                            */   
                            ViewObj.switchView('crm-list-view', 'init');
                            /*                         
                            OperationObj.triggerCilckEvent(ld('#approve-list-view #approveContent li[module="'+ViewObj.rootScope.approvemodule+'"]').eq(0),
                                'body', {view_id: 'approve-list-view'});
                                */
                                
                        } else {
                            urlstring = 'module=' + module;
                            ViewObj.switchView('cwn-crmdetail-view', 'init', {
                                'url_string': urlstring,
                                __direction: 'right_out'
                            });
                        }
                    }
                    // 清空变量
                    ViewObj.rootScope.approveid = '';
                    GVObj.approveObj.approvestatus = '';
                    ViewObj.rootScope.stepid = '';
                    ViewObj.rootScope.nextstep = '';
                    ViewObj.rootScope.laststepid = '';
                });
                // 反审批保存
            } else if (scope.view_name === 'cancel_approval') {
                if (category == 'news' || module == 'Approve') {
                    fld_module = approvemodule;
                } else {
                    fld_module = module;
                }
                var urlstring = 'module=Approve&action=getCancelApprove&fld_module=' + fld_module + '&record=' + recordID +  
                                '&canceltype=' + GVObj.approveObj.approvestatus + '&setype=cancel';
                if (GVObj.approveObj.approvestatus == 1) {//使用当前流程重新流转
                    urlstring += '&approveid=' + ViewObj.rootScope.approveid;
                }
                if (GVObj.approveObj.approvestatus == 2) {//使用新的流程重新流转
                    urlstring += '&approveid=' + GVObj.approveObj.newapproveid;
                }
                WordReportAjax(urlstring, function (rest) {
                    ld("#status").hide();
                    var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                    if (restobj.code == -1) {//如果失败弹出提示
                        PopPromptBox.show(restobj.msg);
                        ViewObj.rootScope.savestatus = 'no';
                        return;
                    }
                    ViewObj.rootScope.savestatus = 'no';
                    // 保存结束后返回到 list列表页
                    if (category == 'news') {
                        // 调用 news-second-view 页面 ，进入“待审批” 点击事件
                        /*
                        OperationObj.triggerCilckEvent(
                            ld('#news-second-view li[tag="Pendingapproval"]').eq(0),'body', {view_id: 'news-second-view'});
                        */
                        OperationObj.triggerCilckEvent(ld('#newsapprove-list-view li[tag="'+ViewObj.rootScope.approvemodule+'"]').find('a').eq(0),
                            'body', {view_id: 'newsapprove-list-view'});
                    } else {
                        var urlstring = '';
                        if (module == 'Approve') {
                            // 调用 crm-main-view 页面 ，进入“审批中心” 点击事件
                            /*
                            OperationObj.triggerCilckEvent(
                                ld('#crm-main-view li[module="Approve"]').eq(0),'body', {view_id: 'crm-main-view'});
                            */
                            ViewObj.switchView('crm-list-view', 'init');
                            /*
                            OperationObj.triggerCilckEvent(ld('#approve-list-view li[module="'+ViewObj.rootScope.approvemodule+'"]').eq(0),
                                'body', {view_id: 'approve-list-view'});
                                */
                        } else {
                            urlstring = 'module=' + module;
                            ViewObj.switchView('cwn-crmdetail-view', 'init', {
                                'url_string': urlstring,
                                __direction: 'right_out'

                            });
                        }
                    }
                    // 清空变量
                    GVObj.approveObj.approvestatus = '';
                    ViewObj.rootScope.approveid = '';
                    GVObj.approveObj.newapproveid = '';
                });
            }
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = targetobj.parents('li');
        // 点击 选择项
        if (targetobj[0].tagName.toLowerCase() === 'textarea') {
            return;
        } else if (targetobj[0].tagName.toLowerCase() === 'li' ||
            _this.length === 1) {
            _this = _this.length ? _this : targetobj;

            if (_this.find('.lnr-circle').length === 1) {
                ld('#cn-approval-view .lnr-circle-solid').removeClass('lnr-circle-solid').addClass('lnr-circle');
                _this.find('.lnr-circle').removeClass('lnr-circle').addClass('lnr-circle-solid');
            }
            if (scope.view_name === 'cancel_approval') {
                if (_this.attr('cancelapprovetype') != undefined) {
                    GVObj.approveObj.approvestatus = _this.attr('cancelapprovetype');
                }
            }
            else {
                if (_this.attr('approvestatus') != undefined) {
                    GVObj.approveObj.approvestatus = _this.attr('approvestatus');
                }
            }
            if (scope.view_name === 'cancel_approval' &&
                _this.attr('cancelapprovetype') == '2') {
                if (ld('#newapprove').attr('items')) {
                    ld('#newapprove').removeClass('ui-hide');
                } else {
                    PopPromptBox.show('没有适用的新流程!');
                }
            } else {
                ld('#newapprove').addClass('ui-hide');
            }

            // 审批 点击下一步审批人、下一步审批步骤，反审批使用新流程
            var next_user = _this.find('i[tag="NextapprovalUser"]'),
                next_step = _this.find('#optionsstepid'),
                new_approve = _this.find('strong');

            //  审批 下一步审批人点击
            if (next_user.length === 1) {
                ViewObj.switchView('cwn-popuselect-view', 'init', {
                    view_name: 'nextApproval_user_list',
                    target_obj: next_user

                });
                //  审批 下一步审批步骤点击
            } else if (next_step.length === 1) {
                if (targetobj.attr('id') === 'optionsstepid') {
                    ViewObj.switchView('cwn-popuselect-view', 'init', {
                        view_name: 'nextApproval_step_list',
                        target_obj: next_step
                    });
                }
                // 反审批 打开新的审批流程
            } else if (new_approve.length === 1) {
                ld('#newapprove').removeClass('ui-hide');
                ViewObj.switchView('cwn-popuselect-view', 'init', {
                    view_name: 'nextApproval_step_list',
                    target_obj: _this,
                    title_str: '选择新流程',
                    itemFun: function (target_item, related_obj) {
                        GVObj.approveObj.newapproveid = target_item.attr('tag');
                        ld('#newapprove>strong').html(target_item.html());
                    }
                });
            }
        }
    };
};

// 定义跳转wn-worklist-view(工作协同列表页)的方法  及click处理定义
ViewObj['create-wn-worklist-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, scope.__app_header, opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
        ld('#app_header input').val(work_searchcontent);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        scope.__app_header = [];
        var urlstring = '',
            pubclearhtml = '';
        ld('#wn-worklist-view').html('');
        // 从news二级页面跳转过来时 特殊处理
        if (scope.view_name === 'news_work_list' ||
            category === 'news') {
            scope.__app_header = ['<', '', '', opts_obj.title_str, '', ''];
            urlstring = opts_obj.url_string;

            if (opts_obj.addsubtitle) { //  当有这个参数时（待处理：显示切换标签“日志/任务”）
                pubclearhtml = '<div class="tabswitch switch-two ui-hide" id="pending_node">' +
                    '<a class="curr" tag="workreport">日 志<i class="cirh-num ui-hide" tag="logn"></i></a>' +
                    '<a tag="cocmd">任 务<i class="cirh-num ui-hide" tag="cocmdn"></i></a></div>';
            }
            pubclearhtml += '<div class="pubclear pubDetialC"></div>';
            ld('#wn-worklist-view').prepend(pubclearhtml);
            ld('#pending_node').removeClass('ui-hide');
            // 默认处理
        } else {
            scope.__app_header = ['', '取消', '', '搜索', '', '搜索'];
            scope.searchstr = ld('#app_header input').val();
            urlstring = 'smallcategory=' + smallcategory + '&bigcategory=' + bigcategory +
                        '&page=1&searchcontent=' + work_searchcontent + '&method=getList';
            ld('#wn-worklist-view').html('<div class="pubDetialC"></div>');
        }
        ViewObj.toViewCommon(to_viewid, scope.__app_header, opts_obj);
        scope.prev_viewid = ViewObj.getInfo('prev_viewid');
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
            if (scope.prev_viewid === 'news-second-view') {
                ViewObj.switchView('news-second-view', 'init', {
                    view_name: 'work_remind',
                    __direction: 'right_out',
                    __view_reset: true
                });
            } else {
                ViewObj.switchView('work-main-view', 'back', {
                    __direction: 'right_out'
                });
            }
            // 头部右边
        } else if (t_id === 'head_rig') {
            if (ld('#app_header input').val() === scope.searchstr) return;
            // 引用 work-search-view 的 “搜索” 按钮
            OperationObj.triggerCilckEvent(null, 'header', {
                target_id: 'head_rig',
                view_id: 'work-search-view'
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = null,
            urlstring = '',
            title_str = '',
            content_holder = targetobj.parents('.area-list'),
            workreportid = content_holder.attr('workreportid'),
            title_str = content_holder.find('span[tag=work_subcategory]').html();
        if(targetobj.parent('.a-user-pic').length === 1){
            var curid = targetobj.parent('.a-user-pic').attr('userid');
            if(curid === userid){
                ViewObj.switchView('all-userinfo-view', 'init', {
                    view_name: 'onlymeinfo'
                });
            }
            else{
                // ViewObj.rootScope.workpage = 'wn-worklist-view';
                ViewObj.switchView('wn-userinfo-view', 'init', {
                    'curid': curid,
                    'curimg': ld(targetobj)[0].outerHTML,
                    'curinfo': targetobj.parent('.a-user-pic').next().children().first().html()//目前只读取用户名，暂无角色权限信息
                });
            }
            return;
        }
        // 点击 回复、点赞、 转发
        if (targetobj.parents('.areal_mid_bot').length === 1) {
            _this = targetobj.parents('a');
            if (_this.length === 1 || targetobj[0].tagName.toLowerCase() === 'a') {
                _this = _this.length ? _this : targetobj;
                GVObj.workrecord = workreportid;
                switch (_this.attr('tag')) {
                    // 点击 回复、点评
                    case 'reply':
                        var replytag = _this.find('span').attr('tag'),
                            replyCount = ld('.replyCount' + GVObj.workrecord).html(),
                            replystatus = '',
                            go_workdtail = false,
                            go_replay = false;
                        entitytypetag = _this.find('span').attr('entitytype'); // 全局变量赋值
                        // 任务 -> 弹出汇报、回复选择框
                        if (entitytypetag === 'cocmd' && replytag === 'yes') {
                            // machineHanderObj.hideMainBtn();
                            ViewObj.switchFooter('cwnm-main-footer', 'hidden');
                            logicHanderObj.popUpMaskToggle('tplOrderNode');
                            // 回复、点评
                        } else {
                            // 回复
                            if (replytag === 'no') {
                                // 1个回复以上 -> 进入明细
                                if (parseInt(replyCount)) {
                                    go_workdtail = true;
                                    // 0个回复 ->进入回复页
                                } else {
                                    title_str = '回复';
                                    replystatus = 'reply';
                                    go_replay = true;
                                }
                                // 点评
                            } else if (replytag === 'yes') {
                                // 已经点评过->进入明细
                                if (parseInt(replyCount)) {
                                    go_workdtail = true;
                                    // 没有点评过->进入点评页
                                } else {
                                    title_str = '点评' + title_str;
                                    replystatus = 'savecomment';
                                    go_replay = true;
                                }
                            }
                            // 进入work明细
                            if (go_workdtail) {
                                ViewObj.rootScope.loadWorkDetail = function (options) {
                                    ViewObj.switchView('wn-workdetail-view', 'init', ld.extend({
                                        'workreportid': workreportid,
                                        __app_header: ['<', '', '', title_str, '-', '-'],
                                        __footer_id: 'wn-workdetail-footer'
                                    }, options));
                                };
                                ViewObj.rootScope.loadWorkDetail();
                                // 进入回复
                            } else if (go_replay) {
                                ViewObj.switchView('wn-replayforword-view', 'init', {
                                    view_name: 'reply',
                                    'title_str': title_str,
                                    __footer_id: 'wn-at-footer',
                                    'replystatus': replystatus,
                                    __direction: 'left_in'
                                });
                            }
                        }
                        break;
                    // 点击 点赞
                    case 'praise':
                        urlstring = 'module=Home&action=ListView&method=savepraise&workreportid=' + GVObj.workrecord;
                        workHandleObj.listPraiseCount(_this);//列表点赞数量赋值
                        WordReportAjax(urlstring, function (rest) {
                        });
                        break;
                    // 点击 转发
                    case 'forward':
                        ViewObj.switchView('wn-replayforword-view', 'init', {
                            view_name: 'forword',
                            'title_str': '转发',
                            __footer_id: 'wn-forword-footer'
                        });
                        break;
                }
            }
            return;
        }// 点击签到地图
        else if (targetobj.hasClass('position_icon') || targetobj.parent().hasClass('position_icon')) {
            _this = targetobj.hasClass('position_icon') ? targetobj : targetobj.parent();
            ViewObj.switchView('cwn-seeposition-view', 'init', {
                onSwitchAfter: function () {
                    var longtitude = _this.attr('longtitude'),
                        latitude = _this.attr('latitude');
                    ld('#mapBox').css({'width': SwiperObj.PHONE_WIDTH, 'height': SwiperObj.PHONE_HEIGHT});
                    map = new BMap.Map("mapBox");
                    var point = new BMap.Point(longtitude, latitude);
                    map.centerAndZoom(point, 15);
                    var marker = new BMap.Marker(point);  // 创建标注
                    map.addOverlay(marker);               // 将标注添加到地图中
                }
            });
            return;
        }// news 待处理->头部分类
        else if (ld('#pending_node').length === 1) {
            if (targetobj[0].tagName.toLowerCase() === 'a' &&
                targetobj.attr('class') !== 'curr') {
                ld('#pending_node>a').removeClass('curr');
                targetobj.addClass('curr');
                GVObj.news_smallcategory = targetobj.attr('tag');
                //默认是第一页
                var urlstring = 'smallcategory=' + GVObj.news_smallcategory + '&bigcategory=' + GVObj.newstype +
                    '&page=1&searchcontent=' + work_searchcontent + '&method=getWorkRemindsAppList';
                workHandleObj.getWorkList(urlstring, function () {
                    SwiperObj.autoHeight(0).autoHiddenAddMore();
                });
            }
        }
        // 点击 进入明细
        if (targetobj.parents('.area-list').length === 1) {
            ViewObj.rootScope.loadWorkDetail = function (options) {
                ViewObj.switchView('wn-workdetail-view', 'init', ld.extend({
                    'workreportid': workreportid,
                    __app_header: ['<', '', '', title_str, '-', '-'],
                    __footer_id: 'wn-workdetail-footer'
                }, options));
            };
            ViewObj.rootScope.loadWorkDetail();
        }
    };
};

// 定义跳转wn-workdetail-view(工作明细页)的方法  及click处理定义
ViewObj['create-wn-workdetail-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, [], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, [], opts_obj);
        var prev_vid = ViewObj.getPrevInfo('viewid'),
            vid_list = 'work-main-view,wn-worklist-view,news-third-view,wn-userinfo-view,wn-replayfileat-view';
        if (vid_list.indexOf(prev_vid) > -1) {
            ViewObj.rootScope.prev_vid = prev_vid;
            scope.prev_vid = prev_vid;
        }
        scope.workreportid = opts_obj.workreportid;
        urlstring = 'workreportid=' + opts_obj.workreportid;
        workHandleObj.getWorkDetailView(urlstring, function () {
            ViewObj.onSwitchAfter(opts_obj);
        },scope.workreportid);
    }
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id,
            targetobj = ld('#' + t_id),
            _this = null;            
        // 头部左边
        if (t_id === 'head_left') {
            var prev_vid = ViewObj.getPrevInfo('viewid');
            console.log(prev_vid);
            if(prev_vid==='cwn-lookup-view'){
                // ViewObj.switchView('work-main-view', 'back', {
                //     __scroll_top: 'origin'
                // });
                if(category == 'news'){
                    ViewObj.switchView('wn-worklist-view', 'back', {
                        __scroll_top: 'origin'
                    });
                }
                else{
                    ViewObj.switchView('work-main-view', 'back', {
                        __scroll_top: 'origin'
                    });
                }
            }
            else{
                if(category == 'news'){
                    ViewObj.switchView(ViewObj.rootScope.prev_vid, 'back', {
                        __scroll_top: 'origin'
                    });
                }
                else{
                    ViewObj.switchView(ViewObj.rootScope.workpage, 'back', {
                        __scroll_top: 'origin'
                    });
                }
            }
            // if(prev_vid==='cwn-lookup-view'){
            //     if(category == 'news'){
            //         ViewObj.switchView('wn-worklist-view', 'back', {
            //             __scroll_top: 'origin'
            //         });
            //     }
            //     else{
            //         ViewObj.switchView('work-main-view', 'back', {
            //             __scroll_top: 'origin'
            //         });
            //     }
            // }
            // else{
            //     ViewObj.switchView(ViewObj.rootScope.workpage, 'back', {
            //         __scroll_top: 'origin'
            //     });
            // }
            
            // 头部右边
        } else if (t_id === 'head_rig' && targetobj.find('a').attr('class') === 'lnr-more') {
            logicHanderObj.popUpMaskToggle('tplMoreOperation');
        }
    };
    // 底部点击操作
    ViewObj[to_viewid + '-footer-click'] = function (targetobj, clickOpts) {
        var _this = targetobj.parents('li'),
            replystatus = '',
            title_str = '';
        if (_this.length === 1 ||
            targetobj[0].tagName.toLowerCase() === 'li') {
            _this = _this.length ? _this : targetobj;
            _this = _this.find('a');
            switch (_this.attr('tag')) {
                case 'reply':
                    if (_this.attr('replytype') === 'yes' &&
                        _this.attr('entitytype') === 'cocmd') {
                        // machineHanderObj.hideMainBtn();
                        ViewObj.switchFooter('cwnm-main-footer', 'hidden');
                        logicHanderObj.popUpMaskToggle('tplOrderNode');
                    } else {
                        title_str = '回复';
                        replystatus = 'reply';
                        if (_this.attr('entitytype') === 'workreport' &&
                            _this.attr('replytype') === 'yes') {
                            replystatus = 'savecomment';
                            title_str = '点评' + ld('#head_mid span:visible').html();
                        }
                        ViewObj.switchView('wn-replayforword-view', 'init', {
                            view_name: 'reply',
                            'title_str': title_str,
                            'replystatus': replystatus,
                            __footer_id: 'wn-at-footer'
                        });
                    }
                    break;
                case 'praise':
                    var urlstring = 'module=Home&action=ListView' + '&method=savepraise&workreportid=' + GVObj.workrecord;
                    var num = ld('#reply_atop_rig_count' + GVObj.workrecord).attr('count');
                    if (empty(num) || 1 > num) num = 0;
                    else num = parseInt(num);
                    if (isNaN(num)) num = 0;
                    var icon = _this.find('i');
                    if (icon.attr('class') == 'lnr-good') {//点赞
                        num += 1;
                        icon.attr('class', 'lnr-gooded');
                        //取消点赞
                    } else {
                        if (num) num -= 1;
                        icon.attr('class', 'lnr-good');
                    }
                    ld('#reply_atop_rig_count' + GVObj.workrecord).attr('count', num);
                    ld('#reply_atop_rig_count' + GVObj.workrecord).html('赞(' + num + ')');
                    WordReportAjax(urlstring, function (rest) {
                        var handobj = ld('.func>.areal_mb_center>[workreport=' + GVObj.workrecord + ']');
                        workHandleObj.listPraiseCount(handobj);//列表点赞数量赋值
                        if (ld('#reply_atop_rig_count' + GVObj.workrecord).attr('class') === 'curr') {
                            workHandleObj.getPraiseList(GVObj.workrecord, null);
                        }
                    });
                    break;
                case 'forward':
                    ViewObj.switchView('wn-replayforword-view', 'init', {
                        view_name: 'forword',
                        'title_str': '转发',
                        __footer_id: 'wn-forword-footer'
                    });
                    break;
            }
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        // 点击查看发送范围
        if (targetobj.attr('tag') === 'send_range') {
            ViewObj.switchView('cwn-lookup-view', 'init', {
                view_name: 'workdetail_rangeview',
                workreportid: scope.workreportid,
                __app_header: ['<', '', '', '发送范围', '', '']
            });
            //  work明细更多操作
        } else if (targetobj.parents('#tplMoreOperation').length === 1) {
            // 点击取消任务
            if (targetobj.attr('tag') === 'more-cocmdcancel') {
                logicHanderObj.popUpMaskToggle('tplMoreOperation');
                PopPromptBox.show({
                    main_text: '您确定取消该任务？',
                    btn_type: 'yesno',
                    yes_fun: function () {
                        var urlstring = 'module=Home&action=ListView';
                        urlstring += '&method=savereader&savetype=savecancel&workreportid=' + GVObj.workrecord + '';
                        WordReportAjax(urlstring, function (rest) {
                            ViewObj.rootScope.loadWorkDetail({__direction: 'right_out'});
                            ld('#work-main-view').find('.areal-top[workreportid="' + GVObj.workrecord + '"]')
                                .find('.a-user-bz').find('span:last').addClass('fontred').html('-已取消');
                        });
                    }
                });
                // 点击删除
            } else if (targetobj.attr('tag') === 'more-delete') {
                logicHanderObj.popUpMaskToggle('tplMoreOperation');
                var urlstring = 'module=Home&action=ListView&method=DeleteReport&workreportid=' + GVObj.workrecord;
                WordReportAjax(urlstring, function (rest) {
                    if (rest == '##error##') {
                        PopPromptBox.show('删除失败！');
                        return false;
                    }
                    ViewObj.switchView(ViewObj.rootScope.prev_vid, 'back', {
                        __scroll_top: 'origin',
                        onSwitchBefore: function () {
                            ld('#' + scope.prev_vid)
                                .find('.area-list[workreportid="' + GVObj.workrecord + '"]')
                                .addClass('ui-hide');
                        }
                    });
                });
            }
            // 点击 进入关联客户明细、联系人明细
        } else if (targetobj.attr('tag') === 'seeCrmBilldetail') {
            module = targetobj.attr('module');
            recordID = targetobj.attr('detailid');
            var urlstring = 'module=' + module + '&action=DetailView&CheckPermitted=yes&record=' + recordID;
            WordReportAjax(urlstring, function (rest) {
                if (empty(rest)) return false;
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                if (restobj.code != -1) {
                    ViewObj.switchView('cwn-crmdetail-view', 'init', {
                        target_obj: targetobj
                    });
                } else {
                    PopPromptBox.show(restobj.msg);//弹出层
                }
            });
            // 点击签到地图
        } else if (targetobj.hasClass('position_icon') ||
            targetobj.parent().hasClass('position_icon')) {
            OperationObj.triggerCilckEvent(targetobj, 'body', {view_id: 'wn-worklist-view'});
            // 点击 切换回复
        } else if (targetobj.attr('tag') === 'reply_area_top_left') {
            targetobj.parent().find('span').attr('class', '');
            targetobj.attr('class', 'curr');
            workHandleObj.getReplyList(GVObj.workrecord, null);
            // 点击 切换赞
        } else if (targetobj.attr('tag') === 'reply_area_top_rig') {
            targetobj.parent().find('span').attr('class', '');
            targetobj.attr('class', 'curr');
            workHandleObj.getPraiseList(GVObj.workrecord, null);
            // 点击 WORK明细页回复
        } else if (targetobj.attr('tag') === 'replytoreply') {
            var spans = targetobj.parent().find('strong').html();
            spans = '@' + spans.substr(0, spans.length) + ' ';
            ViewObj.switchView('wn-replayforword-view', 'init', {
                view_name: 'reply',
                'replycontent': spans,
                __footer_id: 'wn-at-footer'
            });
            //点击明细页面回复列表头像
        } else if(targetobj.parent('.cell-a').length === 1 || targetobj.parent('.a-user-pic').length === 1){
            var curid = targetobj.parent().attr('replyuserid');//用户ID
            if(curid === userid){
                ViewObj.switchView('all-userinfo-view', 'init', {
                    view_name: 'onlymeinfo'
                });
            }
            else{
                ViewObj.switchView('wn-userinfo-view', 'init', {
                    'curid': curid,
                    'curimg': ld(targetobj)[0].outerHTML,
                    'curinfo': targetobj.parent().next().find('strong').html()//目前只读取用户名，暂无角色权限信息
                });
            }
        }
    };
};

// 定义跳转wn-replayforword-view(回复、评论、任务)的方法  及click处理定义
ViewObj['create-wn-replayforword-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['', '取消', '', '回复', '', '发布'], opts_obj);
        logicHanderObj.getTxtautoH(ld('#replycontent').val(), 'replycontent'); // 根据调整输入框高度
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ld('.sendrangeimg').remove(); //删除发送范围为空提示
        var title_str = opts_obj.title_str ? opts_obj.title_str : '';
        scope.view_name = opts_obj.view_name;
        scope.replycontent = opts_obj.replycontent;
        scope.replystatus = opts_obj.replystatus;
        if (scope.view_name === 'at' && !title_str) {
            title_str = '回复'
        } else if (scope.view_name === 'forword' && !title_str) {
            title_str = '转发'
        }
        // 获取上一个页面的内容
        ViewObj.toViewCommon(to_viewid, ['', '取消', '', title_str, '', '发布'], opts_obj);
        scope.prev_header = ViewObj.getInfo('prev_header'); // 获取上一个页面的头部
        scope.prev_vid = ViewObj.getPrevInfo('viewid'); // 获取上一个页面的 viewid
        scope.prev_footerid = ViewObj.getPrevInfo('footerid');  // 获取上一个页面的 footerid

        var replayforwordStr = "<div class='writeTxt'>" +
            "<textarea id='replycontent' name='replycontent' autofocus='autofocus' placeholder='请填写内容'></textarea>" +
            "</div>";

        ld('#wn-replayforword-view').html(replayforwordStr);

        if (scope.replycontent !== '' ||
            scope.replycontent !== undefined) {
            ld('#replycontent').val(scope.replycontent);
        } else {
            ld('#replycontent').val('');
        }
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id,
            targetobj = ld('#' + t_id),
            _this = null,
            goback_options = {
                __scroll_top: 'origin',
                __footer_id: scope.prev_footerid,
                __app_header: scope.prev_header,
                __direction: 'right_out'
            };
        // 头部左边
        if (t_id === 'head_left') {
            goback_options.__confirm_switch = true;
            ViewObj.switchView(scope.prev_vid, 'back', goback_options);
            // 头部右边
        } else if (t_id === 'head_rig') {
            // 回复、点评确认
            if (scope.view_name === 'reply') {
                var atuser = ld('#sendLog_at_user').val();   //at用户
                var atgroup = ld('#sendLog_at_group').val(); //at部门
                var replycontent = ld('#replycontent').val();
                if (empty(replycontent)) {
                    PopPromptBox.show('您还没有填写内容！');
                    return false;
                }
                var urlstring = 'module=Home&action=ListView';
                urlstring += '&workreportid=' + GVObj.workrecord + '&userid=' + userid;
                if (scope.replystatus == 'savefinish' || scope.replystatus == 'savecomment') {
                    //默认普通回复reply，完成任务savefinish，点评日志savecomment
                    urlstring += '&method=savereader&reader_content=' + encodeURIComponent(replycontent) +
                        '&ccgroup=' + atgroup + '&ccuser=' + atuser +
                        '&savetype=' + scope.replystatus;
                } else {
                    urlstring += '&method=saveSendLog&savetype=4&backstatus=yes&replycontent=' +
                        encodeURIComponent(replycontent) +
                        '&atgroup=' + atgroup + '&atuser=' + atuser;
                    if (GVObj.workObj.parentid > 0) {
                        urlstring += '&parentid=' + GVObj.workObj.parentid;
                    }
                }
                WordReportAjax(urlstring, function (rest) {
                    GVObj.workObj.parentid = 0;//回复的回复清空
                    ld('#replycontent').val('');
                    var temp_str = '';
                    if (scope.replystatus == 'savefinish') {
                        temp_str = '-已完成';
                    } else if (scope.replystatus == 'savecomment') {
                        temp_str = '-已点评';
                    }
                    workHandleObj.listReplyCount(temp_str);//列表回复数量赋值
                    // 返回上一个页面(回复需要刷新明细页面)
                    if (scope.prev_vid === 'wn-workdetail-view') {
                        ViewObj.rootScope.loadWorkDetail({__direction: 'right_out'});
                    } else {
                        ViewObj.switchView(scope.prev_vid, 'back', goback_options);
                    }
                });
                // 转发确认
            } else if (scope.view_name === 'forword') {
                var forwardCon = ld('#replycontent').val();//转发内容
                var ccgroup = sessionStorage.getItem('storage_work_cc_groupid');//部门
                var ccuser = sessionStorage.getItem('storage_work_cc_userid');//同事
                if (empty(ccgroup) && empty(ccuser)) {
                    if (ld('.bot_operbtn .sendrangeimg').length == 0) {
                        ld('.bot_operbtn').append('<div class="sendrangeimg" style="bottom:2rem;"></div>');
                    }
                    return false;
                }
                if (empty(forwardCon)) {
                    PopPromptBox.show('您还没有填写内容');
                    return false;
                }
                sessionStorage.clear();//清除发送范围记录
                ld('#wn-forword-footer .send_scop_icon,#ccrangeDIV').html('<span class="text-ellipsis">发送范围</span>');
                var urlstring = 'module=Home&action=ListView&method=savereader&savetype=saveforward' +
                    '&reader_content=' + encodeURIComponent(forwardCon) + '&reader_score=' +
                    '&ccgroup=' + ccgroup + '&ccuser=' + ccuser + '&workreportid=' + GVObj.workrecord;
                WordReportAjax(urlstring, function (rest) {
                    workHandleObj.listReplyCount('');//列表回复数量赋值
                    // 返回上一个页面(转发需要刷新明细页面)
                    if (scope.prev_vid === 'wn-workdetail-view') {
                        ViewObj.rootScope.loadWorkDetail({__direction: 'right_out'});
                    } else {
                        ViewObj.switchView(scope.prev_vid, 'back', goback_options);
                    }
                });
            }
        }
    };
    // 底部点击操作
    ViewObj[to_viewid + '-footer-click'] = function (targetobj, clickOpts) {
        var v_name = '';
        if (scope.view_name === 'reply') {
            v_name = 'at-reply'
        } else if (scope.view_name === 'forword') {
            v_name = 'forword'
        }
        ViewObj.switchView('cwn-sendrang-view', 'init', {
            view_name: v_name,
            'return_module': 'Work',//模块
            'searchtype': 'all',//类型 (bymodule:根据模块权限; byscope:根据授权范围; all:全部)
            'filterown': 'yes',//是否过滤自己(yes:过滤, no:不过滤)
            'scopetype': 'groupuser',//显示类型( group:只显示部门; user:只显示用户; groupuser:显示部门及用户)
            'common': 1,//是否显示常用标签(0:不显示;1:常用标签下没有我的选项;2:常用标签下有我的选项)
            'isactive': 'no',//是否显示禁用用户（yes:显示,no:不显示  默认no）
        });
    };
};

// 定义跳转cwn-sendrang-view(@、发送范围 页面)的方法  及click处理定义
ViewObj['create-cwn-sendrang-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, [], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        if (!opts_obj.view_name) {
            alert('ViewObj.switchView(' + 'switch' + to_viewid + siwtch_type + ',"init",\n' +
                '{view_name : "XXX"}})请传入view_name参数,可选 at\forword\pisition!');
            return;
        }
        var title_Str = '';
        scope.view_name = opts_obj.view_name;

        if (opts_obj.view_name === 'at-release' || opts_obj.view_name === 'at-reply') {
            scope.rangeview_header = ['<', '', '', '@范围', '', ''];
            title_Str = '@范围';//回复at
        } else {
            scope.rangeview_header = ['<', '', '', '已选发送范围', '', ''];
            title_Str = '选择发送范围';//发布，转发
            ld('.sendrangeimg').remove(); //删除发送范围为空提示
        }
        // 记录返回信息
        scope.prev_header = ViewObj.getPrevInfo('header');
        ViewObj.toViewCommon(to_viewid, ['', '取消', '', title_Str, '', '确定'], opts_obj);
        scope.prev_vid = ViewObj.getPrevInfo('viewid');
        scope.prev_footerid = ViewObj.getPrevInfo('footerid');

        // 初始之前的值
        ld('#chosenSendrange_commGroup,#chosenSendrange_Colleague,#chosenSendrange_Group').html('');
        ld('#SearchDiv').addClass('ui-hide');
        ld('#usersearch').val('');
        ld('#wn-choosenview-footer>span').html('已选择：' + btnshowCCname);

        // 初始化选择记录
        /*
         choose_useridobj=[]; choose_usernameobj=[];
         choose_groupidobj=[]; choose_groupnameobj=[];
         */
        GVObj.workObj.liststatus = '';//非搜索

        //用户查找，填充条件
        var user_searchObj = {};
        user_searchObj.return_module = opts_obj.return_module;
        user_searchObj.searchtype = opts_obj.searchtype;
        user_searchObj.filterown = opts_obj.filterown;
        user_searchObj.scopetype = opts_obj.scopetype;
        user_searchObj.common = opts_obj.common;
        user_searchObj.isactive = opts_obj.isactive;
        scope.common = opts_obj.common;
        UserPopupInit(user_searchObj, function () {
            if (opts_obj.common === 1) {
                if (opts_obj.view_name != 'at-release' && opts_obj.view_name != 'at-reply' && opts_obj.view_name != 'forword') {
                    //先加载底部已选择数据，获取已选择内容
                    //已选择部门记录
                    var final_groupidobj = [];
                    final_groupidobj = sessionStorage.getItem('storage_work_cc_groupid').split(',');
                    var final_groupnameobj = [];
                    final_groupnameobj = sessionStorage.getItem('storage_work_cc_groupname').split(',');
                    if (final_groupidobj[0] === '') {
                        final_groupidobj = [];
                        final_groupnameobj = [];
                    }
                    //已选择同事记录
                    var final_useridobj = [];
                    final_useridobj = sessionStorage.getItem('storage_work_cc_userid').split(',');
                    var final_usernameobj = [];
                    final_usernameobj = sessionStorage.getItem('storage_work_cc_username').split(',');
                    if (final_useridobj[0] === '') {
                        final_useridobj = [];
                        final_usernameobj = [];
                    }
                    //重新赋值
                    choose_groupidobj = final_groupidobj;
                    choose_groupnameobj = final_groupnameobj;
                    choose_useridobj = final_useridobj;
                    choose_usernameobj = final_usernameobj;
                    showselectedCCorAt(final_groupidobj, final_groupnameobj, final_useridobj, final_usernameobj);
                    //清除选择记录
                    ld('#CommonDiv>div>i,#DepartmentDiv>div>i,#ColleagueDiv>div>i').attr('class', 'lnr-square');
                    ld('#chosenSendrange_commGroup,#chosenSendrange_Group,#chosenSendrange_Colleague').html('');
                    //再次加载，还原“发送范围”选中状态
                    if (!empty(final_groupidobj)) {
                        var grouphtml = '';
                        if (ld.inArray('all', final_groupidobj) != -1) {
                            ld('#chosenSendrange_commGroup').html('<li chooseid="all">所有</li>');
                        }
                        ld.each(final_groupidobj, function (key, id) {
                            // ld('#comgroup' + id + '>i,#group' + id + '>i').attr('class', 'lnr-checkmark-square');
                            ld('#comgroup' + id).find('.img-circle').find('i').attr('class', 'lnr-checkmark-square');
                            ld('#group' + id).find('.img-circle').find('i').attr('class', 'lnr-checkmark-square');

                            if (id != 'all') {
                                grouphtml += '<li chooseid="' + id + '" >' + final_groupnameobj[key] + '</li>';
                            }
                        });
                        ld('#chosenSendrange_Group').html(grouphtml);
                    }
                    if (!empty(final_useridobj)) {
                        var userhtml = '';
                        ld.each(final_useridobj, function (key, id) {
                            // ld('#user' + id + '>i').attr('class', 'lnr-checkmark-square')
                            ld('#user' + id).find('.img-circle').find('i').attr('class', 'lnr-checkmark-square');
                            userhtml += '<li id="chosencolleague_' + id + '" >' + final_usernameobj[key] + '</li>';
                        });
                        ld('#chosenSendrange_Colleague').html(userhtml);
                    }
                }
                else {
                    btnshowCCname = '';
                    choose_groupidobj = [];
                    choose_groupnameobj = [];
                    choose_useridobj = [];
                    choose_usernameobj = [];
                    ld('#wn-choosenview-footer>span').html('已选择：' + btnshowCCname);
                }
            }
            else if (opts_obj.common === 2) {
                switch (opts_obj.dashboard_type) {
                    case 'weeklystatistics':
                        d_cache_ws_lableStr = CacheObj.get('d_cache_ws_lable');
                        choose_db_useridobj = CacheObj.get('d_cache_ws_view');
                        choose_db_nameobj = CacheObj.get('d_cache_ws_name');
                        break;
                    case 'salesfunnel':
                        d_cache_ws_lableStr = CacheObj.get('d_cache_sf_lable');
                        choose_db_useridobj = CacheObj.get('d_cache_sf_view');
                        choose_db_nameobj = CacheObj.get('d_cache_sf_name');
                        break;
                    case 'contractamount':
                        d_cache_ws_lableStr = CacheObj.get('d_cache_ct_lable');
                        choose_db_useridobj = CacheObj.get('d_cache_ct_view');
                        choose_db_nameobj = CacheObj.get('d_cache_ct_name');
                        break;
                    case 'salessituation':
                        d_cache_ws_lableStr = CacheObj.get('d_cache_ss_lable');
                        choose_db_useridobj = CacheObj.get('d_cache_ss_view');
                        choose_db_nameobj = CacheObj.get('d_cache_ss_name');
                        break;
                    case 'returnamount':
                        d_cache_ws_lableStr = CacheObj.get('d_cache_ra_lable');
                        choose_db_useridobj = CacheObj.get('d_cache_ra_view');
                        choose_db_nameobj = CacheObj.get('d_cache_ra_name');
                        break;
                    case 'signednumber':
                        d_cache_ws_lableStr = CacheObj.get('d_cache_sn_lable');
                        choose_db_useridobj = CacheObj.get('d_cache_sn_view');
                        choose_db_nameobj = CacheObj.get('d_cache_sn_name');
                        break;
                    case 'signedamount':
                        d_cache_ws_lableStr = CacheObj.get('d_cache_sa_lable');
                        choose_db_useridobj = CacheObj.get('d_cache_sa_view');
                        choose_db_nameobj = CacheObj.get('d_cache_sa_name');
                        break;
                    case 'paymentamount':
                        d_cache_ws_lableStr = CacheObj.get('d_cache_pa_lable');
                        choose_db_useridobj = CacheObj.get('d_cache_pa_view');
                        choose_db_nameobj = CacheObj.get('d_cache_pa_name');
                        break;
                    case 'coststatistics':
                        d_cache_ws_lableStr = CacheObj.get('d_cache_ca_lable');
                        choose_db_useridobj = CacheObj.get('d_cache_ca_view');
                        choose_db_nameobj = CacheObj.get('d_cache_ca_name');
                        break;
                    case 'daylog':
                        d_cache_ws_lableStr = CacheObj.get('d_cache_dl_lable');
                        choose_db_useridobj = CacheObj.get('d_cache_dl_view');
                        choose_db_nameobj = CacheObj.get('d_cache_dl_name');
                        break;
                    case 'weeklog':
                        d_cache_ws_lableStr = CacheObj.get('d_cache_wl_lable');
                        choose_db_useridobj = CacheObj.get('d_cache_wl_view');
                        choose_db_nameobj = CacheObj.get('d_cache_wl_name');
                        break;
                    case 'monthlog':
                        d_cache_ws_lableStr = CacheObj.get('d_cache_ml_lable');
                        choose_db_useridobj = CacheObj.get('d_cache_ml_view');
                        choose_db_nameobj = CacheObj.get('d_cache_ml_name');
                        break;
                }
                if (choose_db_useridobj.length === 0) {
                    choose_db_useridobj = [];
                    choose_db_nameobj = [];
                    choose_db_useridobj[0] = 'me';
                    choose_db_nameobj[0] = '我的';
                }
                ld('#label_usergroup>.curr').removeClass('curr');
                ld('#SearchDiv,#CommonDiv,#ColleagueDiv,#DepartmentDiv').addClass('ui-hide');
                if (ld.inArray('all', choose_db_useridobj) > -1) {
                    if(ld('#comgroupall').find('.img-circle').find('i').hasClass('lnr-square')){
                        ld('#comgroupall').find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                    }
                    else{
                        ld('#comgroupall>i').attr('class', 'lnr-checkmark-square');
                    }
                    ld('#CommonDiv').removeClass('ui-hide');
                    ld('#label_usergroup a[tag=Common]').addClass('curr');
                }
                else if (choose_db_useridobj.length === 1 && ld.inArray('me', choose_db_useridobj) === 0) {
                    if(ld('#comgroupme').find('.img-circle').find('i').hasClass('lnr-square')){
                        ld('#comgroupme').find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                    }
                    else{
                        ld('#comgroupme>i').attr('class', 'lnr-checkmark-square');
                    }
                    ld('#CommonDiv').removeClass('ui-hide');
                    ld('#label_usergroup a[tag=Common]').addClass('curr');
                }
                else {
                    if (d_cache_ws_lableStr === 'Colleague') {
                        ld.each(choose_db_useridobj, function (key, id) {
                            if(ld('#ColleagueDiv li[userid=' + id + ']').find('.img-circle').find('i').hasClass('lnr-square')){
                                ld('#ColleagueDiv li[userid=' + id + ']').find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                            }
                            else{
                                ld('#ColleagueDiv div[userid=' + id + ']>i').attr('class', 'lnr-checkmark-square');    
                            }
                        });
                        ld('#usersearch').attr('placeholder', '搜索同事');
                        ld('#SearchDiv,#ColleagueDiv').removeClass('ui-hide');
                        ld('#label_usergroup a[tag=Colleague]').addClass('curr');
                    }
                    else if (d_cache_ws_lableStr === 'Department') {
                        ld.each(choose_db_useridobj, function (key, id) {
                            if(ld('#DepartmentDiv li[tag=' + id + ']').find('.img-circle').find('i').hasClass('lnr-square')){
                                ld('#DepartmentDiv li[tag=' + id + ']').find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                            }
                            else{
                                ld('#DepartmentDiv div[tag="' + id + '"]>i').attr('class', 'lnr-checkmark-square');
                            }
                        });
                        ld('#usersearch').attr('placeholder', '搜索部门');
                        ld('#SearchDiv,#DepartmentDiv').removeClass('ui-hide');
                        ld('#label_usergroup a[tag=Department]').addClass('curr');
                    }
                    else {
                        ld.each(choose_db_useridobj, function (key, id) {
                            if(ld('#CommonDiv li[tag=' + id + ']').find('.img-circle').find('i').hasClass('lnr-square')){
                                ld('#comgroupall').find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                            }
                            else{
                                ld('#CommonDiv div[tag="' + id + '"]>i').attr('class', 'lnr-checkmark-square');    
                            }
                            ld('#CommonDiv').removeClass('ui-hide');
                            ld('#label_usergroup a[tag=Common]').addClass('curr');
                        });
                    }
                }
            }
            ViewObj.onSwitchAfter(opts_obj);
        });
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id,
            targetobj = ld('#' + t_id),
            _this = null;
        // 点击头部左边、右边
        if (t_id === 'head_left') {
            // 返回到上一个页面
            ViewObj.switchView(scope.prev_vid, 'back', {
                __app_header: scope.prev_header,
                __footer_id: scope.prev_footerid
            });
            // 点击右边，进行确定处理
        } else if (t_id === 'head_rig') {
            switch (scope.view_name) {
                // at确定
                case 'at-reply':
                case 'at-release':
                    if (scope.view_name === 'at-reply') {
                        ViewObj.rootScope.focusID = 'replycontent';
                    }
                    if (writeAtcontent() === false) {//将at值填充到输入框中
                        return;
                    }
                    if (!empty(choose_useridobj)) {
                        ld('#sendLog_at_user').val(ld('#sendLog_at_user').val() + choose_useridobj + ',');
                    }
                    if (!empty(choose_groupidobj)) {
                        ld('#sendLog_at_group').val(ld('#sendLog_at_group').val() + choose_groupidobj + ',');
                    }
                    break;
                //发送范围、转发发送范围
                case 'sendrang-all':
                case 'forword':
                    if (!btnshowCCname) {
                        PopPromptBox.show('请选择发送范围');
                        return;
                    }
                    if (btnshowCCname == '') {
                        btnshowCCname = '发送范围';
                    }
                    ld('#wn-forword-footer .send_scop_icon,#ccrangeDIV').html('<span class="text-ellipsis">' + btnshowCCname + '</span>');
                    //Tools.print_array(choose_groupidobj);Tools.print_array(choose_groupnameobj);
                    //存入数据
                    sessionStorage.setItem('storage_work_cc_groupid', choose_groupidobj);
                    sessionStorage.setItem('storage_work_cc_groupname', choose_groupnameobj);
                    sessionStorage.setItem('storage_work_cc_userid', choose_useridobj);
                    sessionStorage.setItem('storage_work_cc_username', choose_usernameobj);
                    break;
                //仪表盘
                case 'dashboarddetail':
                    if (empty(choose_db_useridobj)) {
                        PopPromptBox.show('选择要查看的范围');
                        return;
                    }
                    if (ld.inArray('all', choose_db_useridobj) > -1) {
                        ld('#dsviewrange').html('全部');
                        choose_db_useridobj = [];
                        choose_db_useridobj[0] = 'all';
                    }
                    else {
                        //Tools.print_array(choose_db_nameobj);
                        var choose_nameStr = '';
                        ld.each(choose_db_nameobj, function (key, name) {
                            choose_nameStr += name + ',';
                        });
                        ld('#dsviewrange').html(choose_nameStr.substring(0, choose_nameStr.length - 1));
                    }
                    ViewObj.rootScope.db_lable = ld('#label_usergroup a.curr').attr('tag');//保存当前选择标签
                    break;
            }
            // 返回到上一个页面
            ViewObj.switchView(scope.prev_vid, 'back', {
                __app_header: scope.prev_header,
                __footer_id: scope.prev_footerid
            });
        }
    };
    // 底部点击操作
    ViewObj[to_viewid + '-footer-click'] = function (targetobj, clickOpts) {
        // 当btnshowCCname 中有值才可以点击
        if (btnshowCCname) {
            ViewObj.switchView('cwn-lookup-view', 'init', {
                view_name: 'rang_choosenview',
                __app_header: scope.rangeview_header
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = null;
        // 点击切换常用、选同事、选部门
        if (targetobj.parents('#label_usergroup').length === 1 &&
            targetobj[0].tagName.toLowerCase() === 'a') {
            _this = targetobj;
            taglabel = _this.attr('tag');
            ld('#label_usergroup>.curr').removeClass('curr');
            _this.addClass('curr');
            ld('#SearchDiv,#CommonDiv,#ColleagueDiv,#DepartmentDiv').addClass('ui-hide');
            if (taglabel == 'Common') {//常用
                ld('#CommonDiv').removeClass('ui-hide');
            } else if (taglabel == 'Colleague') {//同事
                ld('#usersearch').attr('placeholder', '搜索同事');
                ld('#SearchDiv,#ColleagueDiv').removeClass('ui-hide');
            } else if (taglabel == 'Department') {//部门
                ld('#usersearch').attr('placeholder', '搜索部门');
                ld('#SearchDiv,#DepartmentDiv').removeClass('ui-hide');
            }
            SwiperObj.autoHeight(0);
            if (scope.common === 2) {
                //初始化选择记录
                choose_db_useridobj = [];
                choose_db_nameobj = [];
                ld('#CommonDiv>div>i,#ColleagueDiv>div>i,#DepartmentDiv>div>i').removeClass('lnr-checkmark-square').addClass('lnr-square');
                ld('#CommonDiv').find('.img-circle').find('i').removeClass('lnr-checkmark-square').addClass('lnr-square');
                ld('#ColleagueDiv').find('.img-circle').find('i').removeClass('lnr-checkmark-square').addClass('lnr-square');
                ld('#DepartmentDiv').find('.img-circle').find('i').removeClass('lnr-checkmark-square').addClass('lnr-square');
            }
            // 点击常用选项、选同事选项、选部门选项
        } else if (targetobj.parents('.datainfo').length === 1 ||
            targetobj.parents('.classdatainfo').length === 1 ||
            (targetobj.attr('class') && targetobj.attr('class').indexOf('datainfo') > -1) || 
            (targetobj.attr('class') && targetobj.attr('class').indexOf('classdatainfo') > -1) ) {
            
            if(targetobj.parents('.classdatainfo').length === 1){
                _this = targetobj.parents('.classdatainfo');
            }
            else{
                _this = targetobj.parents('.datainfo');
            }
            _this = _this.length ? _this : targetobj;
            var parent_id = '';
            if(targetobj.parents('.classdatainfo').length === 1){
                parent_id = _this.parent().parent().attr('id');
            }
            else{
                parent_id = _this.parent().attr('id');
            }
            switch (parent_id) {
                // 点击常用选项
                case 'CommonDiv':
                    chooseGroupCC(scope.common, 'comgroup', _this.attr('comgroupid'), _this.find('span').attr('groupname'));
                    break;
                // 点击选同事选项
                case 'ColleagueDiv':
                    //alert(scope.common+'---'+_this.attr('userid')+'---'+_this.find('span').find('i').html());
                    if(targetobj.parents('.classdatainfo').length === 1){
                        chooseUserCC(scope.common, _this.attr('userid'), _this.find('span').find('i').html());
                    }
                    else{
                        chooseUserCC(scope.common, _this.attr('userid'), _this.find('span').html());
                    }
                    break;
                // 点击选部门选项
                case 'DepartmentDiv':
                    chooseGroupCC(scope.common, 'group', _this.attr('groupid'), _this.find('span').attr('groupname'));
                    break;
            }
            // 点击搜索按钮
        } else if (targetobj.parents('#usersearchDiv').length === 1 ||
            targetobj.attr('type') === 'button') {
            GVObj.workObj.liststatus = 'search';//搜索
            var send_category = ld('#label_usergroup a.curr').attr('tag'),
                lists = null,
                list_holder = null,
                item_num = 0;

            if (send_category === 'Colleague') {
                lists = ld('#ColleagueDiv li');
            } else if (send_category === 'Department') {
                lists = ld('#DepartmentDiv li');
            }
            list_holder = lists.eq(0).parent().parent();
            if (lists) {
                var searchstrValue = ld('#usersearch').val().toLowerCase();
                lists.each(function (index, el) {
                    var eachValue = ld(this).find('span.text-ellipsis').find('i.text-ellipsis').html().toLowerCase();
                    if (eachValue.indexOf(searchstrValue) > -1) {
                        item_num++
                        ld(this).show();
                        if (item_num === 1) {
                            list_holder.find('.no_message_tip').remove();
                        }
                    } else {
                        ld(this).hide();
                    }
                });
                if (!item_num) {
                    var listhtml = logicHanderObj.NoinfoNotice('数据');
                    list_holder.find('.no_message_tip').remove();
                    list_holder.append(listhtml);
                }
            }
        }
    };
};

// 定义跳转crm-main-view(crm首页)的方法  及click处理定义
ViewObj['create-crm-main-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, [], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        var viewModule = ''
        if (category_for === 'crm') {
            viewModule = "CRM";
        }
        else if (category_for === 'apply') {
            viewModule = "应用";
        }
        ViewObj.toViewCommon(to_viewid, ['', '', '', viewModule, '-', '-'], opts_obj);
        EventHanderObj.initCrmAndApplyMenuView(viewModule, function () {
            ViewObj.onSwitchAfter(opts_obj);
        });
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id,
            targetobj = ld('#' + t_id),
            _this = null;
        if (t_id === 'head_rig') {
            var showtype = 0,
                c_header = ViewObj.getInfo('current_header');
            if (targetobj.find('a').hasClass('lnr-grid')) {
                showtype = 1;
                c_header.splice(4, 1, '列表');
                ViewObj.setAppHeader(c_header);
                ld('#crmSudoku,#crmList').addClass('ui-hide');
                ld('#crmSudoku').removeClass('ui-hide');

            } else if (targetobj.find('a').hasClass('lnr-menu')) {
                showtype = 2;
                c_header.splice(4, 1, '方格');
                ViewObj.setAppHeader(c_header);
                ld('#crmSudoku,#crmList').addClass('ui-hide');
                ld('#crmList').removeClass('ui-hide');
            }
            SwiperObj.autoHeight(0);
            GVObj.main_header = c_header;
            commonHandleObj.saveModuleShowset(showtype, category_for, userid);//保存CRM菜单显示
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = null,  // 所点击的具体目标
            urlstring = '';
        // 判断点击是哪一个元素----start------
        _this = targetobj.parents('li');
        // 点击方格显示 模块
        if (!ld('#crmSudoku').is(':hidden') &&
            _this.length === 1 ||
            targetobj[0].tagName.toLowerCase() === 'li') {
            _this = _this.length ? _this : targetobj;
            // 点击crm首页列表显示 模块
        } else if (!ld('#crmList').is(':hidden') &&
            targetobj.parents('li').length === 1) {
            _this = targetobj.parents('li');
            // 点击其他地方 返回，不执行以下操作
        } else {
            return false;
        }
        // 判断点击是哪一个元素----end------
        module = _this.attr('module'); // 全局变量赋值
        modulename = _this.attr('modulename');// 全局变量赋值
        searchcontent = ''; // 全局变量赋值
        ld('#divTab,.lnr-cross-circle').addClass('ui-hide');
        if (phoneversion == 'ios') {
            iosObj.getDeviceInfo();
        } else if (phoneversion == 'android') {
            GVObj.deviceID = javatojs.getDeviceId();
        }
        // 点击签到模块
        if (module === 'Singin') {
            if (phoneversion == 'android') {
                if (!javatojs.isOpenGPS()) {
                    // 弹出 确定取消弹出框
                    PopPromptBox.show({
                        main_text: 'GPS卫星定位未开启，是否立即开启？',
                        btn_type: 'yesno',
                        yes_str: '立即开启',
                        no_str: '取消',
                        show_mianbt: false,
                        yesbt_position: 'left',
                        yes_fun: openGPS,
                        no_fun: singinFunction
                    });
                }
                else {
                    singinFunction();
                }
            }
            else {
                singinFunction();
            }
            // 点击拍照模块
        } else if (module === 'PhotoGraph') {
            GVObj.crmObj.liststatus = 0;
            // 按照init方式,跳转到拍照页
            ViewObj.switchView('crm-photo-view', 'init', {
                __footer_id: 'crm-photo-footer',
                __init_delay: 'none',
                onSwitchAfter: function () {
                    ld('#crm-photo-footer div')
                        .attr('active', 'false')
                        .css({'backgroundColor': '#aaa'});
                }
            });
        } else if (module === 'UploadLog') {//轨迹上传
            ViewObj.switchView('crm-uploadlog-view', 'init');
        } else if (module === 'Dashboard') {//仪表盘
            ViewObj.switchView('crm-dashboard-view', 'init');
        } else if (module === 'NearbyAccounts') {//附近客户
            ViewObj.switchView('crm-nearbyaccounts-view', 'init', {
                onSwitchAfter: function () {
                    loadLocationJScript();//加载地图
                },
                __init_delay: 'none'
            });
        } else if (module === 'Approve') {//审批中心
            ViewObj.switchView('approve-list-view', 'init');
        } else {//列表
            GVObj.crmObj.liststatus = 0;
            ViewObj.switchView('crm-list-view', 'init');
        }
    };
};

// 定义跳转approve-list-view(news审批提醒中模块列表)的方法及click处理定义
ViewObj['create-approve-list-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '审批中心', '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '审批中心', '', ''], opts_obj);
        ViewObj.rootScope.approvetype = 0;
        ld('#approve-category>.tabswitch>.curr').removeClass('curr');
        ld('#approve-category>.tabswitch>[approvestatus=' + ViewObj.rootScope.approvetype + ']').addClass('curr');
        var urlstring = 'module=Approve&action=ApproveListViewCount&approvestatus=0';
        WordReportAjax(urlstring, function (rest) {
            if (empty(rest)) return false;
            var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
            var listhtml = '<ul class="newstwo-lists">';
            if(restobj.result.list != '' && restobj.result.list != null){
                ld.each(restobj.result.list, function (index, list) {
                    listhtml += '<li tag="'+ list.module +'">'+
                                    '<a><span class="news_left_tit">'+ list.label +'</span><i class="lnr-chevron-right"></i>'+
                                    '<span class="news_num"><i class="approveno">'+ list.num +'</i></span></a>'+
                                '</li>';
                });    
            }            
            listhtml += '</ul>';
            ld('#approve-list-view #approveContent').html(listhtml);
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
            // 跳转到apply首页
            ViewObj.switchView('crm-main-view', 'init', {
                view_name: scope.back_viewname,
                __direction: 'right_out'
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        if (targetobj.parents('#approve-category').length === 1 && targetobj[0].tagName.toLowerCase() === 'a') {
            ld('#approve-list-view #approveContent').html('');
            _this = targetobj;
            ViewObj.rootScope.approvetype = _this.attr('approvestatus');
            ld('#approve-category>.tabswitch>.curr').removeClass('curr');
            ld('#approve-category>.tabswitch>[approvestatus=' + ViewObj.rootScope.approvetype + ']').addClass('curr');
            var urlstring = 'module=Approve&action=ApproveListViewCount&approvestatus='+ ViewObj.rootScope.approvetype;
            WordReportAjax(urlstring, function (rest) {
                if (empty(rest)) return false;
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                var listhtml = '<ul class="newstwo-lists">';
                if(restobj.result.list != '' && restobj.result.list != null){
                    ld.each(restobj.result.list, function (index, list) {
                        listhtml += '<li tag="'+ list.module +'">'+
                                        '<a><span class="news_left_tit">'+ list.label +'</span><i class="lnr-chevron-right"></i>'+
                                        '<span class="news_num"><i class="approveno">'+ list.num +'</i></span></a>'+
                                    '</li>';
                    });
                }
                listhtml += '</ul>';
                ld('#approve-list-view #approveContent').html(listhtml);
            });
        }else if(targetobj.parents('li').length === 1){
            _this = targetobj.parents('li');
            if(_this.attr('tag') != undefined){
                ViewObj.rootScope.approvemodule = _this.attr('tag');
            }
            if(_this.find('span:first-child').html() != undefined){
                ViewObj.rootScope.approvemodulename = _this.find('span:first-child').html();
            }
            ViewObj.switchView('crm-list-view', 'init');
        }
    };
};

// 定义跳转到crm-list-view(crm列表)的方法 及click处理定义
ViewObj['create-crm-list-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        if (module === 'Approve') {
            ld('#approvecategory').removeClass('ui-hide');
        }
        ViewObj.toViewCommon(to_viewid, scope.__app_header, opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
        if(!ViewObj.rootScope.listsearchstr){
            ViewObj.rootScope.listsearchstr = '搜索';
        }
        if(module != 'Approve'){
            // 搜索框显示
            ListSearchBox.display({
                parent_id: 'divSearch',
                tip_text: ViewObj.rootScope.listsearchstr,
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
        }
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        var opts = opts_obj,
            urlstring = typeof opts.url_string === 'string' ? opts.url_string : '',
            head_ar = [],
            pubclearhtml = '';
        // 外勤统计
        if (module === "SinginList") {
            ViewObj.toViewCommon(to_viewid, ['<', '', 'v', '我的签到', '', ''], opts_obj);
            GVObj.crmObj.liststatus = 1;
            scope.signuserid = opts_obj.signuserid ? opts_obj.signuserid : userid;
            signuserid = scope.signuserid;
            //隐藏crm列表
            pubclearhtml = '<div id="divTab" class="ui-hide"></div>' +
                '<div id="listbox" class="pubclear pubDetialC"></div>';
            ld('#crm-list-view').html(pubclearhtml);
            // 如果参数中有urlstring字符串，则忽略构造urlstring
            if (urlstring === '') {
                urlstring = 'module=Singin&action=index' +
                    '&signuserid=' + scope.signuserid + '&viewid=curmonth';
            }
            getSign(urlstring, function () {
                ViewObj.onSwitchAfter(opts_obj);
            });
            //  其他模块
        } else {
            pubclearhtml = '<div id="divSearch"></div>' +
                '<div id="divTab" class="ui-hide"></div>' +
                '<div id="approvecategory" class="ui-hide">' +
                '<div class="tabswitch switch-three">' +
                '<a class="curr" approvestatus="0">待审批</a>' +
                '<a approvestatus="1">已审批</a>' +
                '<a approvestatus="2">近30天</a>' +
                '</div>' +
                '</div>' +
                '<div id="listbox" class="pubclear pubDetialC"></div>';
            ld('#crm-list-view').html(pubclearhtml);
            if (opts.__app_header) {
                scope.__app_header = opts.__app_header;
            } else {
                // 审批模块 头部
                if (module === 'Approve') {//审批中心不需要查找条件
                    GVObj.approveObj.approvestatus = 0;
                    head_ar = ['<', '', '', ViewObj.rootScope.approvemodulename, '', ''];
                    // 其他模块头部
                } else {
                    head_ar = ['<', '', 'v', '我的' + modulename, '-', '-'];
                }
                scope.__app_header = head_ar;
            }
            ViewObj.toViewCommon(to_viewid, scope.__app_header, opts_obj);
            var category_key = '',
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
            }
            if (category_value == '') {
                category_value = 'SmOwner_Search_Me';
                ViewObj.rootScope.SearchScope = 'SmOwner_Search_Me'; // 全局变量赋值
            }
            // 如果选项对象中有urlstring字符串，则忽略构造urlstring
            if (urlstring === '') {
                if (module === 'Accounts'&&(ViewObj.rootScope.accountresult==''||ViewObj.rootScope.accountresult==undefined)) {
                    ViewObj.rootScope.accountresult = 'ALLACCOUNT';
                }
                urlstring = 'module=' + module + '&action=index' + '&page=1&viewid=' + category_value +
                    '&searchcontent=' + searchcontent;//默认是第一页
                ld("#status").show();
            }
            //字段公式
            var f_module = module;
            if (module == 'Approve') {
                f_module = ViewObj.rootScope.approvemodule;
            }
            if (ld.inArray(f_module, formulaArray) >= 0) {
                getJsScript('js/producttool/DateTime.js', function () {
                });
                getJsScript('js/producttool/toolField.js', function () {
                });
                getJsScript('js/producttool/mobileformula.js', function () {
                });
                getJsScript('js/producttool/TabDetailFields.js', function () {
                });
                getJsScript('js/producttool/TabDetailFieldFormula.js', function () {
                });
            }
            if (module == 'Approve') {
                urlstring = 'fromapprovemodule=' + ViewObj.rootScope.approvemodule + '&page=1';
            }
            getCRMList(urlstring, function () {
                ld("#status").hide();
                if (ViewObj.rootScope.createpermit === 'yes' || ViewObj.rootScope.quickcreate === 'yes') {
                    scope.__app_header.splice(4, 2, '+', '');
                    ViewObj.setAppHeader(scope.__app_header);
                }
                if (module != 'Approve') {
                    var category_html = ld('#pulldown_menulists li[name=' + category_value + ']').html();
                    //ld('#head_mid').find('span').html(category_html);
                    scope.__app_header.splice(3, 1, category_html);
                    ViewObj.setAppHeader(scope.__app_header);
                }
                ViewObj.onSwitchAfter(opts_obj);
            });
        }
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id,
            targetobj = ld('#' + t_id),
            _this = null;
        // 头部左边
        if (t_id === 'head_left') {
            ld('.list-addmore-label').html('');
            if(module === 'Approve'){
                ViewObj.switchView('approve-list-view', 'init', {
                    __app_header: "审批中心",
                    __direction: 'right_out'
                });
            }else{
                ViewObj.switchView('crm-main-view', 'back', {
                    __scroll_top: 'origin',
                    __app_header: GVObj.main_header
                });
            }
            // 头部右边
        } else if (t_id === 'head_rig' && targetobj.find('a').attr('class') != '') {
            // 关闭头部下拉分类
            if (ld('#head_mid span:visible.select').length === 1) {
                logicHanderObj.headerDataClassify();
            }
            GVObj.crmObj.quickcreateStatus = 'no';
            ViewObj.rootScope.list_create = 'create';
            //弹框，包括其他创建方式
            var qcbool = ViewObj.rootScope.quickcreate === 'yes' ? true : false,
                psbool = ViewObj.rootScope.publicstatus === 'yes' ? true : false,
                ctvalue = ViewObj.rootScope.createtype;//客户创建类别
            if(module === 'Accounts'){
                if(ctvalue === '0'){//全部
                    if (!qcbool && !psbool) {
                        ViewObj.rootScope.publicaccount = '0';
                        ViewObj.switchView('crm-createedit-view', 'init', {
                            view_name: 'create'
                        });
                    }
                    else{
                        var create_menu = ld('#tplCreatemenu');
                        if (create_menu.hasClass('ui-hide')) {
                            ld('#layerMask').show();
                            create_menu.removeClass('ui-hide');
                        } else {
                            create_menu.addClass('ui-hide');
                        }
                    }
                }
                else if(ctvalue === '3'){//公海已分配
                    var urlstring = 'module=Accounts&action=Check&type=distributionTop';
                    WordReportAjaxNew(urlstring,function(rest){
                        if(empty(rest)) return false;
                        var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
                        if(restobj.result.list.quantityceiling === 'yes'){
                            PopPromptBox.show('您拥有的公海客户数量已经达到上限，创建失败');
                            return false;
                        }
                        else{
                            ViewObj.rootScope.publicaccount = '2';
                            ViewObj.switchView('crm-createedit-view', 'init', {
                                view_name: 'create'
                            });
                        }
                    },{async:false});
                }
                else{
                    if(ctvalue==='0'||ctvalue==='1'){
                        ViewObj.rootScope.publicaccount = '0';
                    }
                    else if(ctvalue==='2'){
                        ViewObj.rootScope.publicaccount = '1';
                    }
                    else if(ctvalue==='3'){
                        ViewObj.rootScope.publicaccount = '2';
                    }
                    ViewObj.switchView('crm-createedit-view', 'init', {
                        view_name: 'create'
                    });
                }
            }
            else{
                if (module != 'Accounts' && module != 'Contacts' && !qcbool) {
                    ViewObj.switchView('crm-createedit-view', 'init', {
                        view_name: 'create'
                    });
                }
                else {
                    var create_menu = ld('#tplCreatemenu');
                    if (create_menu.hasClass('ui-hide')) {
                        ld('#layerMask').show();
                        create_menu.removeClass('ui-hide');
                    } else {
                        create_menu.addClass('ui-hide');
                    }
                }
            }
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = null,
            urlstring = '';
        //点击客户公海切换、外勤统计时间切换
        if (targetobj.parents('#divTab').length === 1 &&
            targetobj[0].tagName.toLowerCase() === 'a') {
            _this = targetobj;
            if (module === 'Accounts') {//点击客户公海切换
                ViewObj.setAppHeader(['<', '', 'v', '我的' + modulename, '-', '-']);
                ld('#divTab>.tabswitch>.curr').removeClass('curr');
                _this.addClass('curr');
                ld('#search_content').val(''); // 清空查找条件
                searchcontent = ''; // 全局变量赋值
                ViewObj.rootScope.accountresult = ld('#divTab>.tabswitch>.curr').attr('accountresult');
                if (ViewObj.rootScope.accountresult === 'ALLACCOUNT') {
                    category_key = 'category_Accounts_all';
                }
                else if (ViewObj.rootScope.accountresult === 'PUBLICALLOCATE') {
                    category_key = 'category_Accounts_public';
                }
                else if (ViewObj.rootScope.accountresult === 'NOALLOCATE') {
                    category_key = 'category_Accounts_no';
                }
                category_value = CacheObj.get(category_key);
                if (category_value == '') {
                    category_value = 'SmOwner_Search_Me';
                    ViewObj.rootScope.SearchScope = 'SmOwner_Search_Me'; // 全局变量赋值
                }
                urlstring = 'module=Accounts&action=index&page=1&viewid=' + category_value;//默认是第一页
                getCRMList(urlstring, function () {
                    SwiperObj.autoHeight(0); // 自动调整高度
                    SwiperObj.autoHiddenAddMore(); // 自动隐藏 ‘更多’
                    ld("#status").hide();
                    if (ViewObj.rootScope.createpermit === 'yes' || ViewObj.rootScope.quickcreate === 'yes') {
                        ViewObj.setAppHeader(['<', '', 'v', '我的' + modulename, '+', '']);
                    }
                    var category_html = ld('#pulldown_menulists li[name=' + category_value + ']').html();
                    ld('#head_mid').find('span').html(category_html);
                    ViewObj.onSwitchAfter(opts_obj);
                });
            } else if (module === 'SinginList') {//点击外勤统计时间切换
                var choosename = _this.attr('choosename');
                urlstring = 'module=Singin&action=index';
                urlstring += '&signuserid=' + scope.signuserid + '&viewid=' + choosename;
                getSign(urlstring, function () {
                    ld('#divTab>div>a').removeClass('on');
                    ld('#divTab>div>[choosename=' + choosename + ']').addClass('on');
                    SwiperObj.autoHeight(0); // 自动调整高度
                    SwiperObj.autoHiddenAddMore(); // 自动隐藏 ‘更多’
                });
            }
            // 点击审批中心切换
        } else if (targetobj.parents('#approvecategory').length === 1 &&
            targetobj[0].tagName.toLowerCase() === 'a') {
            _this = targetobj;
            ld('#crm-list-view .pubDetialC').html('');
            ViewObj.rootScope.approvetype = _this.attr('approvestatus');
            urlstring = 'fromapprovemodule=' + ViewObj.rootScope.approvemodule + '&page=1';
            getCRMList(urlstring, function () {
                SwiperObj.autoHeight(0); // 重新获取数据 高度置更新 并跳转顶部
                SwiperObj.autoHiddenAddMore(); // 自动隐藏 ‘更多’
            });
            // 点击列表项进入明细
        } else if (targetobj.parents('#listbox').length === 1) {
            if (targetobj.parents('li').length === 1) {
                _this = targetobj.parents('li');
            } else if (targetobj.get(0).tagName.toLowerCase() === 'li') {
                _this = targetobj;
            } else {
                return;
            }
            urlstring = '';
            recordID = _this.attr('record'); // 全局变量赋值
            if (recordID === undefined) return; // 若没有取到 recordID值，直接返回
            if (module == 'Approve') {
                //ld('#approvecategory').addClass('ui-hide');
                approvemodule = ViewObj.rootScope.approvemodule;
                urlstring = 'module=' + approvemodule;
            } else {
                urlstring = 'module=' + module;
                approvemodule = module;
            }

            var urlstringcheck = urlstring + '&action=DetailView&CheckPermitted=yes&record=' + recordID + '&mode=detail';
            if (module == 'Approve') {
                urlstringcheck += '&approvepage=yes';
            } else {
                urlstringcheck += '&approvepage=no';
            }
            WordReportAjax(urlstringcheck, function (rest) {
                if (empty(rest)) return false;
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                if (restobj.code != -1) {
                    ViewObj.rootScope.loadCrmdetail = function (options) {
                        ViewObj.switchView('cwn-crmdetail-view', 'init', ld.extend({
                            'url_string': urlstring
                        }, options));
                    };
                    ViewObj.rootScope.loadCrmdetail();
                } else {
                    PopPromptBox.show(restobj.msg);
                    ld("#status").hide();
                    return;
                }
            });
            // 创建弹出层选项点击
        } else if (targetobj.parents('#tplCreatemenu').length === 1) {
            // 执行返回操作
            OperationObj.triggerCilckEvent(ld('#layerMask'));
            // 根据创建类型创建
            var createtype = targetobj.attr('tag');
            switch (createtype) {
                case 'quickcreate': // 快速创建
                    if (module == 'Accounts') {
                        ViewObj.rootScope.publicaccount = 0; // 全局变量赋值
                    }
                    GVObj.crmObj.quickcreateStatus = 'yes';
                    break;
                case 'create': // 创建
                    break;
                case 'createordinary': // 创建普通客户
                    if (module == 'Accounts') {
                        ViewObj.rootScope.publicaccount = 0; // 全局变量赋值
                    }
                    break;
                case 'createnotallocated': // 创建公海未分配
                    if (module == 'Accounts') {
                        ViewObj.rootScope.publicaccount = 1; // 全局变量赋值
                    }
                    break;
                case 'createallocated': // 创建公海已分配
                    var checkvalue = 'no';
                    urlstring = 'module=Accounts&action=Check&type=distributionTop';
                    WordReportAjaxNew(urlstring,function(rest){
                        if(empty(rest)) return false;
                        var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
                        if(restobj.result.list.quantityceiling === 'yes'){
                            PopPromptBox.show('您拥有的公海客户数量已经达到上限，创建失败');
                            checkvalue = 'yes';
                        }
                    },{async:false});
                    if(checkvalue==='yes'){
                        return;        // 返回不继续执行
                    }
                    if (module == 'Accounts') {
                        ViewObj.rootScope.publicaccount = 2; // 全局变量赋值
                    }
                    break;
                case 'cardcreate': // 拍名片创建
                    machineHanderObj.getCardInfo(); // 调用拍名片功能
                    return;        // 返回不继续执行
                    break;
                case 'choosecardcreate': // 选名片创建，目前跟拍名片调同一个方法
                    machineHanderObj.getCardInfo(); // 调用拍名片功能
                    return;        // 返回不继续执行
                    break;
            }
            ViewObj.switchView('crm-createedit-view', 'init', {
                view_name: 'create'
            });
        }
    };
};

// 定义跳转到crm-createedit-view(crm 创建/编辑页)的方法 及click处理定义
ViewObj['create-crm-createedit-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        var opts = opts_obj,
            title_str = '';
        if (ld.isArray(opts.__app_header)) {
            ViewObj.toViewCommon(to_viewid, opts.__app_header, opts_obj);
        } else {
            if (ViewObj.rootScope.mode === 'create' || ViewObj.rootScope.mode === 'relationcreate') {
                title_str = '创建';
            } else if (ViewObj.rootScope.mode = 'edit') {
                title_str = '编辑';
            }
            ViewObj.toViewCommon(to_viewid, ['<', '', '', title_str + modulename, '', '保存'], opts_obj);
        }
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        var opts = ld.isPlainObject(opts_obj) ? opts_obj : {},
            urlstring = typeof opts.url_string === 'string' ? opts.url_string : '';
        scope.view_name = opts.view_name;
        imgid = '';//把图片ID清空
        if (module === 'PublicAnnouncement') {
            choose_pa_usersidobj = [];
            choose_pa_usersnameobj = [];//公告接收人
            sessionStorage.setItem('storage_users_pa_id', JSON.stringify(choose_pa_usersidobj));
            sessionStorage.setItem('storage_users_pa_name', JSON.stringify(choose_pa_usersnameobj));
        }
        if (module === 'BusinessApply') {
            choose_ba_usersidobj = [];
            choose_ba_usersnameobj = [];//出差申请单同行人
            sessionStorage.setItem('storage_users_ba_id', JSON.stringify(choose_ba_usersidobj));
            sessionStorage.setItem('storage_users_ba_name', JSON.stringify(choose_ba_usersnameobj));
        }
        // 初始化创建页、相关信息创建
        if (scope.view_name === 'create' || scope.view_name === 'relationcreate') {
            var createmoduleName = '';
            if (opts.view_name === 'relationcreate') {
                createmoduleName = newmodulename;
            }
            else {
                createmoduleName = modulename;
            }
            //签到这里，创建客户
            if (createmoduleName === '外勤签到') {
                createmoduleName = '客户';
            }
            ViewObj.toViewCommon(to_viewid, ['<', '', '', '创建' + createmoduleName, '', '保存'], opts_obj);
            ViewObj.rootScope.mode = scope.view_name; // 全局变量赋值
            GVObj.crmObj.parentid = '';
            var card = opts.card,
                cardinfo = opts.cardinfo;
            ld('#crm-createedit-view').html(''); // 清空内容
            //ld('#divTab').addClass('ui-hide');   // 隐藏切换按钮
            if (urlstring === '') {
                if (opts.view_name === 'relationcreate') {
                    urlstring = 'module=' + newmodule + '&action=CreateView&Create=true';
                    if (ViewObj.rootScope.account_id != '' && parseInt(ViewObj.rootScope.account_id) > 0) {
                        urlstring += '&account_id=' + ViewObj.rootScope.account_id;
                        GVObj.crmObj.parentid = ViewObj.rootScope.account_id;
                    }
                    if (ViewObj.rootScope.vendor_id != '' && parseInt(ViewObj.rootScope.vendor_id) > 0) {
                        urlstring += '&vendor_id=' + ViewObj.rootScope.vendor_id;
                        GVObj.crmObj.parentid = ViewObj.rootScope.vendor_id;
                    }
                    if (module === 'Contacts' || module === 'VendorContact') {
                        urlstring += '&contact_id=' + recordID;
                    }
                    urlstring += '&parent_module=' + module + '&parent_id=' + recordID;
                }
                else {
                    urlstring = 'module=' + module + '&action=CreateView&Create=true';
                }
                //签到这里，创建客户
                if (module === 'Singin') {
                    urlstring = 'module=Accounts&action=CreateView&Create=true';
                }
                if (GVObj.crmObj.quickcreateStatus == 'yes') {
                    urlstring += '&quickcreate=quick';
                }
                if (card == 'cardios' || card == 'cardandroid') {
                    urlstring = 'module=' + module + '&action=CreateView&cardversion=' + card +
                                '&cardcontent=' + cardinfo + '&camcard=' + ViewObj.rootScope.camcard;
                }
                urlstring += '&mode=create';
            }
            // 初始化编辑页
        } else if (scope.view_name === 'edit') {
            var d_modulename = modulename;
            if(module == 'Approve'){
                d_modulename = ViewObj.rootScope.approvemodulename;
            }
            ViewObj.toViewCommon(to_viewid, ['<', '', '', '编辑' + d_modulename, '', '保存'], opts_obj);
            ViewObj.rootScope.mode = 'edit';
            ld('#divTab').addClass('ui-hide');
            //隐藏并清空明细标签内容
            ld('#crm-createedit-view').html('');
            if (urlstring === '') {
                var d_module = module;
                if(module == 'Approve'){
                    d_module = ViewObj.rootScope.approvemodule;
                }
                urlstring = 'module=' + d_module + '&action=DetailView&mode=edit&record=' + recordID;
            }
        }
        //获取关联创建相关参数，如果存在并且是关联创建时增加该参数
        if(scope.view_name === 'relationcreate' && ViewObj.rootScope.relatedCreationInfo != undefined && ViewObj.rootScope.relatedCreationInfo!= ''){
            urlstring += '&relatedCreationInfo=' + ViewObj.rootScope.relatedCreationInfo;
        }
        logicHanderObj.clearFieldArray();//清空对应字段组合
        ld("#status").show();
        getCRMCreateEditView(ViewObj.rootScope.mode, scope.view_name, urlstring, function (restobj) {
            ld("#status").hide();
            if (ViewObj.rootScope.mode === 'create' || ViewObj.rootScope.mode === 'relationcreate') {
                rowcnt = 1; // 全局变量赋值
                productcount = 0; // 全局变量赋值
            }            
            if( (module == 'Contacts' || newmodule == 'Contacts' || 
                 module == 'VendorContact' || newmodule == 'VendorContact') && 
                (ViewObj.rootScope.mode === 'create' || ViewObj.rootScope.mode === 'relationcreate')){
                var CamCard_RelatedCreate = '';
                if(restobj.CamCard_RelatedCreate != '' && restobj.CamCard_RelatedCreate != undefined && restobj.CamCard_RelatedCreate != 'undefined'){
                    CamCard_RelatedCreate = restobj.CamCard_RelatedCreate;
                }
                scope.CamCard_RelatedCreate = CamCard_RelatedCreate;
            }
            ViewObj.onSwitchAfter(opts_obj);
        });
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 点击头部左边
        if (t_id === 'head_left') {
            //返回到相关信息列表
            if (scope.view_name === 'relationcreate') {
                ViewObj.switchView('cwn-relationlist-view', 'init', {
                    __confirm_switch: true,
                    __direction: 'right_out',
                    __view_reset: true,
                    'module': newmodule,
                    'label': newmodulename,
                    'is_related_module': relatedmodule,
                    'record': relatedrecord,
                    'relatedid': related_id
                });
            }
            else {
                if (scope.view_name === 'create') {
                    if (module === 'Singin') {
                        ViewObj.rootScope.signpage='first';
                        //ViewObj.switchView('cwn-popuselect-view', 'back');
                        ViewObj.switchView('crm-sign-view', 'back');
                    }
                    else {
                        ViewObj.switchView('crm-list-view', 'back', {
                            __scroll_top: 'origin',
                            __confirm_switch: true,
                            __direction: 'right_out'
                        });
                    }
                } else if (scope.view_name === 'edit') {
                    var d_module = module;
                    if(module == 'Approve'){
                        d_module = ViewObj.rootScope.approvemodule;
                    }
                    var urlstring = 'module=' + d_module;
                    var switchopts = {
                            'url_string': urlstring,
                            __footer_id: 'crm-detail-footer',
                            __confirm_switch: true,
                            __direction: 'right_out',
                            __view_reset: true,
                        };
                    if(category == 'news'){
                        switchopts.__status = 'approve_status';
                        ViewObj.switchView('cwn-crmdetail-view', 'init', switchopts);
                    }
                    else{
                        ViewObj.switchView('cwn-crmdetail-view', 'init', switchopts);
                    }
                }
            }
            // 点击头部右边
        } else if (t_id === 'head_rig' && ViewObj.rootScope.savestatus != 'yes') {
            ViewObj.rootScope.savestatus = 'yes';
            if (NetworkObj.checkNetwork()) {
                saveCrmCreateOrEdit(scope, ViewObj.rootScope.mode, function () {
                    ViewObj.rootScope.savestatus = 'no';
                });
            }
        }
    };
    // 底部点击操作
    ViewObj[to_viewid + '-footer-click'] = function (targetobj, clickOpts) {
        // 编辑页，底部"添加产品"按钮
        ViewObj.rootScope.productstatus = 'add';
        if (targetobj.attr('tag') === 'addProduct') {
            ViewObj.switchView('crm-createeditsub-view', 'init', {
                view_name: 'product'
            });
        } else if (targetobj.attr('tag') === 'addExpense') {
            ViewObj.switchView('crm-createeditsub-view', 'init', {
                view_name: 'expense'
            });
        } else if (targetobj.attr('tag') === 'addOadetail') {
            ViewObj.switchView('crm-createeditsub-view', 'init', {
                view_name: 'oadetail'
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = null;
        // 客户查重
        if (targetobj.attr('tag') === 'check_repeat') {
            ViewObj.switchView('crm-checkrepeat-view', 'init', {
                __init_delay: 'none'
            });
            // 产品清单 编辑/删除按钮
        } else if (targetobj.parents('#productUL').length === 1) {
            if (targetobj.attr('tag') === 'pedit') {
                ViewObj.rootScope.productstatus = 'edit';
                ViewObj.switchView('crm-createeditsub-view', 'init', {
                    view_name: 'product',
                    target_obj: targetobj.parent().parent()
                });
            }
            if (targetobj.attr('tag') === 'pdel') {
                ViewObj.rootScope.productstatus = 'del';
                var _this = targetobj.parent().parent(),
                    delproductrow = _this.attr('row'),
                    delmoneyStr = _this.find('span:last').html(),
                    rowvalue = _this.attr('row'),
                    quantityAll = ld('#productSubCount').html(),
                    quantityOnly = _this.find('span:last').attr('count');
                //20704: CRM>合同订单；创建合同订单，选择两个产品，删除其中一个，显示的总金额出错
                delmoneyStr = delmoneyStr.split((",")).join("");
                _this.remove();
                productcount -= 1; //全局变量赋值
                quantityAll = Number(quantityAll) - Number(quantityOnly);
                var productmoney = ld('#crm-addproduct-footer>ul>li>[tag=productmoney]').html();
                productmoney = productmoney.split((",")).join("");
                productmoney = eval(productmoney) - eval(delmoneyStr.replace('金额:', ''));
                //无产品时整单折扣
                if (productcount === 0) {
                    ld('#salesOrderetotal').addClass('ui-hide');
                }
                productmoney = logicHanderObj.fmoney(productmoney);
                ld('#productSubCount').html(Tools.Number.toDecimal(quantityAll, parseInt(ViewObj.rootScope.sys_49)));//数量小计
                if (ld('#productSubtotal').length === 1) {
                    ld('#productSubtotal').html(Tools.Number.toDecimal(productmoney, 2));//金额小计
                }
                reCalculation();//重新计算
            }            
        } else if (targetobj.parents('#expenselistUL').length === 1) {// 费用报销单 编辑/删除按钮            
            if (targetobj.attr('tag') === 'Eedit') {// 费用报销编辑按钮
                ViewObj.rootScope.productstatus = 'edit';
                ViewObj.switchView('crm-createeditsub-view', 'init', {
                    view_name: 'expense',
                    target_obj: targetobj.parent().parent()
                });                
            } else if (targetobj.attr('tag') === 'Edel') {// 费用报销删除按钮
                _this = targetobj.parent().parent();
                ViewObj.rootScope.productstatus = 'del';
                var delproductrow = _this.attr('row'),
                    delmoneyStr = _this.find('span:last').html();
                _this.addClass('ui-hide');
                //20704: CRM>合同订单；创建合同订单，选择两个产品，删除其中一个，显示的总金额出错
                delmoneyStr = delmoneyStr.split((",")).join("");
                var rowvalue = _this.attr('row');
                ld("#hidden_rowid_" + rowvalue).val('1');
                productcount--;
                var expensemoney = ld('#crm-addexpense-footer>ul>li>[tag=expensemoney]').html();
                expensemoney = expensemoney.split((",")).join("");
                expensemoney = eval(expensemoney) - eval(delmoneyStr.replace('金额:', '')); //  全局变量赋值
                expensemoney = logicHanderObj.fmoney(expensemoney);
                if (productcount == 0) {
                    expensemoney = 0;
                }
                ld('#crm-addexpense-footer>ul>li>[tag=expensemoney]').html(expensemoney);
            }            
        } else if (targetobj.parents('#oadetaillistUL').length === 1) {// OA表单 编辑/删除按钮
            if (targetobj.attr('tag') === 'Dedit') {// OA表单编辑按钮
                ViewObj.rootScope.productstatus = 'edit';
                ViewObj.switchView('crm-createeditsub-view', 'init', {
                    view_name: 'oadetail',
                    target_obj: targetobj.parent().parent()
                });
            } else if (targetobj.attr('tag') === 'Ddel') {// OA表单删除按钮
                _this = targetobj.parent().parent();
                ViewObj.rootScope.productstatus = 'del';
                var delproductrow = _this.attr('row'),
                    delmoneyStr = _this.find('span:last').html();
                _this.addClass('ui-hide');
                //20704: CRM>合同订单；创建合同订单，选择两个产品，删除其中一个，显示的总金额出错
                delmoneyStr = delmoneyStr.split((",")).join("");
                var rowvalue = _this.attr('row');
                ld("#hidden_rowid_" + rowvalue).val('1');
                productcount--;
                var addcostorday = ld('#crm-addoadetail-footer>ul>li>[tag=oadetailtotal]').html();
                addcostorday = addcostorday.split((",")).join("");
                if(module == 'AddJobBill' || module == 'MinusJobBill'){
                    addcostorday = eval(addcostorday) - eval(delmoneyStr.replace('时长(h):', '')); //  全局变量赋值
                } else if(module == 'BusinessApply'){
                    addcostorday = eval(addcostorday) - eval(delmoneyStr.replace('天数:', '')); //  全局变量赋值
                } else if(module == 'Commission'){
                    
                }
                if (productcount == 0) {
                    addcostorday = 0;
                }
                ld('#crm-addoadetail-footer>ul>li>[tag=oadetailtotal]').html(addcostorday);
            }
            //弹出选择页面 img-detail
        } else if (targetobj.attr('tag') === 'img-detail') {
            logicHanderObj.popUpMaskToggle('tplPhone');//显示拍照获取方式弹出层和遮罩层
            //选择币种
        } else if (targetobj.attr('id') === 'inventory_currency') {
            _this = targetobj;
            if (_this.length === 1) {
                ViewObj.switchView('cwn-popuselect-view', 'init', {
                    view_name: _this.attr('popu_select'),
                    target_obj: _this
                });
            }
            //选择整单折扣、调整
        } else if (targetobj.attr('id') === 'selectDiscount' || targetobj.attr('id') === 'adjustmentType') {
            ViewObj.switchView('cwn-popuselect-view', 'init', {
                view_name: targetobj.attr('popu_select'),
                target_obj: targetobj,
                itemFun: function (target_item, related_obj) {
                    related_obj.html(target_item.html());
                    related_obj.attr('tag', target_item.attr('tag'));
                    if(module == 'Commission' || newmodule == 'Commission'){
                        oaDetailCalcTotal();
                    }
                    else{
                        calcTotal();    
                    }
                }
            });
            //显示安卓选择文件获取方式弹出层和遮罩层
        } else if (targetobj.attr('id') === 'androidChooseAtt') {
            logicHanderObj.popUpMaskToggle('tplFileatt');
            //安卓删除附件
        } else if (targetobj.parents().parents().parents('#androidAttList').length === 1 && targetobj.attr('tag') == 'del') { 
            PopPromptBox.show({
                main_text: '您确定删除该附件吗？',
                btn_type: 'yesno',
                yes_str: '确定',
                no_str: '取消',
                yes_fun: function () {
                    var att_id = targetobj.parents().parents().attr('id');
                    ld('#'+att_id).remove();
                    var arr3 = [];
                    arr3 = ViewObj.rootScope.att_arr;
                    var arr4 = arr3.filter(function(item) {
                        item_array = item.split('&&&&');
                        return item_array[4] != att_id;
                    });
                    ViewObj.rootScope.att_arr = arr4;
                    var att_count = ViewObj.rootScope.att_count;
                    att_count--;
                    ViewObj.rootScope.att_count = att_count;
                }
            });
            //IOS删除附件
        } else if (targetobj.parents().parents().parents('#thelist').length === 1 && targetobj.attr('tag') == 'del') {
            PopPromptBox.show({
                main_text: '您确定删除该附件吗？',
                btn_type: 'yesno',
                yes_str: '确定',
                no_str: '取消',
                yes_fun: function () {
                    var att_id = targetobj.parents().parents().attr('id');
                    ld('#'+att_id).remove();
                    var arr3 = [];
                    arr3 = ViewObj.rootScope.att_arr;
                    var arr4 = arr3.filter(function(item) {
                        return item['id'] != att_id;
                    });
                    ViewObj.rootScope.att_arr = arr4;
                    var att_count = ViewObj.rootScope.att_count;
                    att_count--;
                    ViewObj.rootScope.att_count = att_count;
                }
            });
        } else {            
            var temp_li = targetobj.parents('li.arrow-right'),
                options = {};
            if (!temp_li.length && targetobj.attr('class')) {
                temp_li = targetobj.attr('class').indexOf('arrow-right') > -1 ? targetobj : null;
            }
            if (temp_li) {
                _this = temp_li.find('b[popu_select]').eq(0);
                if(module==='Singin'){
                    ViewObj.rootScope.signpage = 'second';
                }
                if (_this.length === 1) {
                    ViewObj.switchView('cwn-popuselect-view', 'init', {
                        view_name: _this.attr('popu_select'),
                        target_obj: _this
                    });
                }
            }
        }
    };
};

// 定义跳转到crm-checkrepeat-view(客户查重)的方法 及click处理定义
ViewObj['create-crm-checkrepeat-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '客户查重', '', '搜索'], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '客户查重', '', '搜索'], opts_obj);
        var tplnode = '<a class="lnr-chevron-right" href="javascript:void(0);" ></a>' +
            '<b class="text-ellipsis"  id="dup_search_field" name="dup_search_field" >查重字段</b>';
        ld('#divAccountField').html(tplnode);
        ld('#check_repeat_columnname').val(ld('#accountname').val());
        var accountnameArr = ld('#accountname').parent().find('i').html().split('>');
        if (ld('#accountname').val() != '') {
            ld('#dup_search_field').html(accountnameArr[2]);
        }
        ld('#crm-checkrepeat-content').html('').addClass('ui-hide');
        var urlstring = 'module=Accounts&action=duplicate_related_popu&type=get';
        WordReportAjax(urlstring, function (rest) {
            if (empty(rest)) return false;
            var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
            var _index = 0,
                _defaultVal = '',
                _defaultText = '',
                _listitems = '',
                _title_str = '查重字段',
                targetobj = ld('#dup_search_field');
            ld.each(restobj.result.list, function (key, options) {   //构建数组
                if (_index == 0) {
                    _defaultVal = key;
                    _defaultText = options;
                }
                _listitems += key + '&&' + options + '|##|';
                _index++;
            });
            if (ld('#accountname').val() != '') {
                _defaultVal = 'ld_account|accountname';
            }
            targetobj.attr({
                'tag': _defaultVal,
                'items': _listitems,
                'title_str': '查重字段',
                'desc': 'duplicate',
                'select_mode': 'single',
                'popu_select': 'drop_down_list',
                'show_search': 'true'
            });
            ViewObj.onSwitchAfter(opts_obj);
            if (ld('#accountname').val() != '') {
                commonHandleObj.accountDuplicate(_defaultVal, ld('#accountname').val());
            }
        });
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        if (t_id === 'head_left') {// 头部左边
            ViewObj.switchView('crm-createedit-view', 'back');//跳转到crm新增编辑页面
        } else if (t_id === 'head_rig') {// 头部右边
            var listhtml = '',
                dup_search_fieldTag = ld('#dup_search_field').attr('tag'),
                dup_search_field = ld('#dup_search_field').html(),
                check_repeat_columnname = ld('#check_repeat_columnname').val();
            if (dup_search_field === '查重字段') {
                PopPromptBox.show('请选择查重字段')
                return;
            }
            if (check_repeat_columnname === '' || check_repeat_columnname === null) {
                PopPromptBox.show('请输入查重关键字')
                return;
            }
            commonHandleObj.accountDuplicate(dup_search_fieldTag, check_repeat_columnname);
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        // 点击 选择查重字段
        if (targetobj.parents('#divAccountField').length === 1) {
            targetobj = targetobj.parents('#divAccountField').find('b');
            // 跳转到下拉选择页面
            ViewObj.switchView('cwn-popuselect-view', 'init', {
                view_name: 'drop_down_list',
                target_obj: targetobj
            });
        }
    };
};

//客户查重
commonHandleObj.accountDuplicate = function (dup_search_fieldTag, check_repeat_columnname) {
    var urlstring = 'module=Accounts&action=duplicate_related_popu&noprfiledata=true' +
        '&select_option_value=' + dup_search_fieldTag +
        '&search_content=' + check_repeat_columnname + '&type=getlist';
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        if (restobj.result.list != null) {
            var listhtml = '';
            ld.each(restobj.result.list, function (key, list) {
                listhtml += '<li record="' + list.accountid + '"><h5>' + list.accountname + '</h5>' +
                    '<p><span>' + list.smowner + '</span> | <span>' + list.rating + ' | ' + list.createdtime + '</span></p>' +
                    '</li>';
            });
            listhtml = '<ul class="crm-lists">' + listhtml + '</ul>';
        }
        else {
            listhtml = logicHanderObj.NoinfoNotice('数据');
        }
        ld('#crm-checkrepeat-content').html(listhtml).removeClass('ui-hide');
    });
}

//明细界面
function getCRMDetailViewforWork(modulename, urldata, callback) {
    // 销毁之前定义的 Swiper 对象
    if (SwiperObj.isDestroyable(SwiperObj.workRelation_swiper)) {
        try {
            SwiperObj.workRelation_swiper.destroy(true, true);
        } catch (e) {
        }
    }
    var urlstring = urldata + '&mode=detail';
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest),
            res = restobj.result,
            res_list2 = res.list2;

        editpermit = res_list2.editpermit;//是否有编辑权限(yes:有)
        distributionpermit = res_list2.distributionpermit;//是否有分配权限(yes:有)
        allocateaccountpermit = res_list2.allocateaccount;//是否有分配权限(yes:有)
        advancepermit = res_list2.advancepermit;//是否有推进权限(yes:有)
        delpermit = res_list2.delpermit;//是否有删除权限(yes:有)
        submitapprove = res_list2.submitapprove;//是否有提交审批按钮权限,yes:有
        approvepermit = res_list2.approvepermit;//是否有审批按钮权限,yes:有
        cancelapprove = res_list2.cancelapprove;//是否有反审批按钮权限，yes:有
        if(module == 'PublicAnnouncement'){
            editpermit = 'no';   
        }
        if (editpermit == 'yes') {
            ld('#crm-detail-footer').attr('editable', 'true');
        } else {
            ld('#crm-detail-footer').attr('editable', 'false');
        }
        //客户-公海已分配
        if (module === 'Accounts'){
            ViewObj.rootScope.completedpermit = res_list2.completedpermit;//是否显示达成图标
        }
        if (res.list3) {
            ViewObj.rootScope.entitynamevlaue = res.list3.A;//entityname值
        }
        is_related_module = modulename;
        //相关信息
        if (res.list1 != '') { //swiper-container-list
            var divRelatedListhtml = '<div class="relatedlistwrap ui-hide"><div class="swiper-container relation-crm"><div class="swiper-wrapper">',
                _item_num = 0,//相关信息，个数
                _max_textlen = 0;//根据 文字 字数 确定 每行显示几项
            //show_rel_list(this,关联模块module,关联模块,本单据module,本单据id,关联模块关联id)
            ld.each(res.list1, function (key, list) {
                divRelatedListhtml += '<div class="swiper-slide" id="rellist_' +
                    list.related_id + '" relamodule="' + list.label + '" moudle="' +
                    list.module + '" label="' + list.label + '" is_related="' +
                    is_related_module + '" record="' + res.list2.record + '" relatedid="' +
                    list.related_id + '"  ><i>' + list.nums +
                    '</i><span>' + list.label + '</span></div>';
                //获取最大文字个数
                var textlen = list.label.toString().length;
                _max_textlen = _max_textlen > textlen ? _max_textlen : textlen;
                _item_num++;
            });
            divRelatedListhtml += '</div></div></div>';
            ld('#divRelatedList').html(divRelatedListhtml).css({'height': '48px', 'overflow': 'hidden', 'backgroundColor': '#fff'}).removeClass('ui-hide');
            ViewObj.rootScope.item_num = _item_num;
            ViewObj.rootScope.max_textlen = _max_textlen;
        }
        else{
            ViewObj.rootScope.item_num = 0;
            ViewObj.rootScope.max_textlen = 0;
        }
        //明细界面标签
        var detailLabelhtml = '';
        if ((modulename == 'Accounts' || modulename == 'NearbyAccounts' || modulename == 'Contacts' || (modulename == 'Approve' && (approvemodule == 'Accounts' || approvemodule == 'Contacts'))) && res_list2.workreport === 'yes') {//客户、联系人 有工作协同
            detailLabelhtml += '<a choosename="coordination">工作协同</a>';
        }
        detailLabelhtml += '<a choosename="detailView" class="curr">详细资料</a>';
        ViewObj.rootScope.openapprove = res_list2.openapprove;//是否启用审批历史,yes:启用
        if (ViewObj.rootScope.openapprove == 'yes') {
            detailLabelhtml += '<a choosename="divApprove">审批历史</a>';
        }
        ViewObj.rootScope.opencomments = res_list2.opencomments;//是否启用评论,yes:启用
        if (ViewObj.rootScope.opencomments == 'yes') {
            detailLabelhtml += '<a choosename="divComment">评&nbsp;&nbsp;论&nbsp;</a>';
        }
        ld('#divDetailLabel').html(detailLabelhtml).removeClass('ui-hide').addClass(res.list2.detailLabelClass); //页签宽度

        var tplnode = '';
        //客户-公海已分配
        if (modulename === 'Accounts'){
            tplnode += '<div id="divReachDetailViewforWork" class="ui-hide" style="position:absolute;z-index:650;right:30%;padding-top: 7px;">' + 
                            '<img src="images/reach.png">' + 
                       '</div>';
        }
        ld.each(res.list, function (key, list) {
            if (empty(list)) return false;
            if (list.display_status === '0') {
                tplnode += '<h2 class="c-detail-h2">' + list.blocklabel + '<i class="lnr-chevron-up"></i></h2>';
                tplnode += '<ul class="c-ul c-detail-cell ui-hide">';
            }
            else {
                tplnode += '<h2 class="c-detail-h2">' + list.blocklabel + '<i class="lnr-chevron-down"></i></h2>';
                tplnode += '<ul class="c-ul c-detail-cell">';
            }
            ld.each(list.fieldinfo, function (key, fieldinfo) {
                if (!fieldinfo.text) {
                    fieldinfo.text = '';
                }
                //客户，联系人是电话类型字段的显示电话图标
                var phone = '';
                if (fieldinfo.phone == 'yes' && fieldinfo.text != '<b>未填写</b>') {
                    var phonemobile = Tools.escape2Html(fieldinfo.text);
                    if (phoneversion == 'ios') {
                        callhtml = 'href="tel:' + phonemobile + '"';
                    } else {
                        callhtml = "onclick=androidObj.callPhone('" + phonemobile + "');";
                    }
                    phone = '<a ' + callhtml + ' class="lnr-phone-handset">&nbsp;&nbsp;</a>';
                }
                //根据不同类型显示不同信息
                if (fieldinfo.uitype == '19') {//区域
                    tplnode += '<li class="heightauto"><i>' + fieldinfo.fieldlabel +'</i><div>' + fieldinfo.text + '</div>';

                } else if (fieldinfo.uitype == '69') {//照片
                    tplnode += '<li><i>' + fieldinfo.fieldlabel +'</i><div class="view picture-rang picture-preview">';
                    if (!fieldinfo.text) {
                        tplnode += '<div img-detail > <img img_num="1" src="images/defaultuser.png" onload="logicHanderObj.loadimg(this)"/> </div>';
                    } else {
                        ld.each(fieldinfo.options, function (imgkey, imgvalue) {
                            if (empty(list)) return false;
                            tplnode += '<div img-detail ><img img_num=' + (imgkey + 1) + ' src="http://' + loginurl + '/' + imgvalue.value + '" onload="logicHanderObj.loadimg(this)"/> </div>';
                            //'style = "background-image:url(http://'+loginurl+'/'+imgvalue.value+')"'
                        });
                    }
                    tplnode += '</div>';
                } else if (fieldinfo.uitype == '1108' || fieldinfo.uitype == '1109') {//附件
                    tplnode += '<li><i>' + fieldinfo.fieldlabel +'</i><span>';
                    if(fieldinfo.text != '<b>未填写</b>'){
                        tplnode +=  '<ul class="attUl">';
                        ld.each(fieldinfo.text, function (attkey, attvalue) {
                            var img = Tools.getAttImg(attvalue.name),
                                imgStr = 'images/' + img + '.png';
                            if(img == 'img'){
                                imgStr = 'http://' + loginurl + '/' + attvalue.path + attvalue.name;
                            }
                            tplnode +=  '<li>' + 
                                            '<div class="item-content" att_id="' + attvalue.id + '">' + 
                                                '<div class="media-list">' + 
                                                '    <img style="width:36px;height:36px;border-radius:.3rem;" src="' + imgStr + '">' + 
                                                '</div>' + 
                                                '<div class="item-inner">' + 
                                                '    <div class="item-title">' + attvalue.name + '</div>' + 
                                                '    <div class="item-path ui-hide">' + attvalue.path + '</div>' + 
                                                '    <div class="item-text">' + attvalue.size + '</div>' + 
                                                '</div>' + 
                                            '</div>' + 
                                        '</li>';
                        });
                        tplnode +=  '</ul>';
                    }
                    else{
                        tplnode += '尚无附件';
                    }
                    tplnode += '</span>';
                } else {
                    tplnode += '<li><i>' + fieldinfo.fieldlabel + '</i><span>' + Tools.escape2Html(fieldinfo.text) + phone + '</span>';
                }
                tplnode += '</li>';
            });
            tplnode += '</ul>';
        });
        if(!res.entry){
            //合同订单，报价单，服务合同,采购订单
            var res_pdct = res.listproduct;
            if (res_pdct && res_pdct.total.count > 0) {
                ViewObj.rootScope.sys_49 = restobj.result.list2.sys_49;
                ViewObj.rootScope.sys_93 = restobj.result.list2.sys_93;
                rowcnt = res_pdct.total.count; // 全局变量赋值
                productcount = rowcnt;   // 全局变量赋值
                var currency_name = res_pdct.currency_name,
                    producttotal = res_pdct.total.hdnGrandTotal;
                tplnode += '<h2 class="c-detail-h2">产品清单<b class="pricetype">' + currency_name + '</b></h2>' +
                    '<ul class="c-ul c-other-cell detail" id="productbill">';
                var productModule = module;
                ld.each(res_pdct.list, function (key, list) {
                    if (empty(list)) return false;
                    var taxpriceStr = Tools.Number.toDecimal(list.taxprice, parseInt(ViewObj.rootScope.sys_93));
                    var quantityStr = Tools.Number.toDecimal(list.quantity, parseInt(ViewObj.rootScope.sys_49));
                    if (module === 'Approve') {
                        productModule = approvemodule;
                    }
                    tplnode += '<li tag=' + list.productid + ' module=' + productModule + ' sequence_no=' + list.sequence_no + '><p><i class="text-ellipsis">' + list.productname + '</i></p><p><span>' + list.productshowfieldslabel + '</span></p></li>';
                });
                tplnode += '</ul>';
                //整单折扣信息
                var discount_type = res_pdct.total.discount_type,      //整单折扣类型
                    discount_percent = res_pdct.total.discount_percent,//折扣百分比
                    txtAdjustment = res_pdct.total.txtAdjustment,//调整价格
                    hdnDiscountAmount = res_pdct.total.hdnDiscountAmount,//直接降价
                    _viewDiscountVal = '',
                    _viewDiscountDetialVal = '',
                    _viewAdjustmentVal = '',
                    _viewAdjustmentDetialVal = '';
                if (discount_percent == null) {
                    discount_percent = '0.00';
                }
                if (txtAdjustment == null) {
                    txtAdjustment = '0.00';
                }
                if (hdnDiscountAmount == null) {
                    hdnDiscountAmount = '0.00';
                }
                if (txtAdjustment < 0) {
                    _viewAdjustmentVal = '减少';
                    _viewAdjustmentDetialVal = Math.abs(txtAdjustment);
                }
                else {
                    _viewAdjustmentVal = '增加';
                    _viewAdjustmentDetialVal = txtAdjustment;
                }
                if (discount_type == 0) {
                    _viewDiscountVal = '直接降价';
                    _viewDiscountDetialVal = hdnDiscountAmount;
                } else {
                    _viewDiscountVal = '百分比降价';
                    _viewDiscountDetialVal = discount_percent;
                }
                if (res.listproductfield != null) {
                    tplnode += '<ul class="c-ul c-other-total detail">';
                    tplnode += '<li><span>数量小计</span><span>' + Tools.Number.toDecimal(res_pdct.total.allquantity, parseInt(ViewObj.rootScope.sys_49)) + '</span></li>';
                    if (res_pdct.total.hdnSubTotal != undefined) {
                        tplnode += '<li><span>金额小计</span><span>' + Tools.Number.toDecimal(res_pdct.total.hdnSubTotal, 2) + '</span></li>';
                    }
                    ld.each(res.listproductfield, function (keylist, list) {
                        if (list.newline == 1) {
                            if (list.uitype == '35') {
                                tplnode += '<li><span>调整</span><b id="viewAdjustment">' + _viewAdjustmentVal +
                                    '</b><span id="viewAdjustmentDetial">' + Tools.Number.toDecimal(_viewAdjustmentDetialVal, 2) +
                                    '</span></li>';
                            }
                            if (list.uitype == '37') {
                                tplnode += '<li><span>整单折扣</span><b id="viewDiscount">' + _viewDiscountVal +
                                    '</b><span id="viewDiscountDetial">' + Tools.Number.toDecimal(_viewDiscountDetialVal, 2) +
                                    '</span></li>';
                            }
                        }
                    });
                    tplnode += '<li><span>总金额</span><span style="color: #ff8000 !important;">' + logicHanderObj.fmoney(producttotal) + '</span></li>';
                    tplnode += '</ul>';
                }
            }
            //费用清单
            if (res.listexpense && res.listexpense.count > 0) {
                ViewObj.rootScope.sys_49 = restobj.result.list2.sys_49;
                ViewObj.rootScope.sys_93 = restobj.result.list2.sys_93;
                var expensecount = res.listexpense.count,
                    expenseblocklabel = res.listexpense.blocklabel;
                tplnode += '<h2 class="c-detail-h2">' + expenseblocklabel + '</h2><ul class="c-ul c-other-cell detail">';
                ld.each(res.listexpense.list, function (key, list) {
                    if (empty(list)) return false;
                    var rmb_totalStr = Tools.Number.toDecimal(list.rmb_total, parseInt(2));
                    tplnode += '<li><p><i class="text-ellipsis">' + list.expenseuse + '</i></p><p>' + list.expensetype + '<span>' + rmb_totalStr + '</span></p></li>';
                });
                tplnode += '</ul>';
                tplnode += '<ul class="c-ul c-other-total detail">';
                tplnode += '<li><span>总金额</span><span style="color: #ff8000 !important;">'+ res.listexpense.total.total +'</span></li>';
                tplnode += '</ul>';
            }
        }
        else{
            var entry_blocklabel = res.entry.blocklabel,
                entry_listinfo = res.entry.list,
                entry_total = res.entry.p_total;
            tplnode += '<h2 class="c-detail-h2">' + entry_blocklabel;
            if(module == 'Quotes' || module == 'SalesOrder' || module == 'ServiceContracts'){
                tplnode += '<b class="pricetype">' + res.currency.current.currency_name + '</b>';
            }
            tplnode += '</h2>';
            tplnode += '<ul class="c-ul c-other-cell detailnew" id="productbillnew" >';
            ld.each(entry_listinfo, function (key, list) {
                if (empty(list)) return false;
                var entry_class = '';
                if(list.item4){
                    entry_class = 'entrytypeclass';
                }
                var productModule = module;
                if (module === 'Approve') {
                    productModule = approvemodule;
                }
                tplnode +=  '<li class="' + entry_class + '" entryid="' + list.entryid + '" entrytype="' + list.entrytype + '" module="' + productModule + '" sequence_no="' + list.sequence_no + '" >' + 
                                '<p><i class="text-ellipsis">' + list.item1 + '</i></p>';
                                if(list.item3){
                tplnode +=          '<p>' + list.item3 + '<span>' + list.item2 + '</span></p>';
                                }
                                else{
                tplnode +=          '<p><span>' + list.item2 + '</span></p>';
                                }
                                if(list.item4){
                tplnode +=          '<p><span>' + list.item4 + '</span></p>';    
                                }
                tplnode +=  '</li>';
            });
            tplnode += '</ul>';
            tplnode += '<ul class="c-ul c-other-total detail">';
            ld.each(entry_total, function (key, list) {
                tplnode +=  '<li><span>' + list.label + '</span><span>' + list.value +'</span></li>';
            });
            tplnode += '</ul>';
        }
        ld('#detailbox').html(tplnode);
        callback();
    });
}

//审批历史
commonHandleObj.getApproveLogInfo = function (urldata, callback) {
    var urlstring = 'module=Users&action=getDetailBlock' + urldata;
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var tplnode = '<div class="detailapprove">';
        if (restobj.result.list == '') {
            tplnode += '<div class="tip">没有内容</div>';
        }
        else {
            var num = restobj.result.list.length;
            ld.each(restobj.result.list, function (key, list) {
                tplnode += '<ul><li class="strong"> ' + num + '.' + list.STEPNAME + '</li>';
                tplnode += '<li>' + list.OPERATOR + ' | ' + list.OPERATE + ' | ' + list.CREATEDTIME + '</li>';
                tplnode += '<li>结果：' + list.APPROVERESULT + '</li>';
                if (list.DESCRIPTION != '' && list.DESCRIPTION != null) {
                    tplnode += '<li>备注：<span style="color: red;">' + list.DESCRIPTION + '</span></li>';
                }
                if (list.NEXTSTEPBYNAME != '' && list.NEXTSTEPBYNAME != null) {
                    tplnode += '<li>下一步处理人：' + list.NEXTSTEPBYNAME + '</li>';
                }
                tplnode += '</ul>';
                num--;
            });
        }
        tplnode += ' </div>';
        if (ld('#cwn-crmdetail-view').hasClass('ui-hide') == false) {
            ld('#divApproveLog').html(tplnode);
        }
        else {//公共的相关信息
            ld('#divApproveLogrelated').html(tplnode);
        }
        callback();
        ld("#status").css('display', 'none');
    });
}
//评论信息
commonHandleObj.getCommentInfo = function (urldata, callback) {
    var urlstring = 'module=Users&action=getDetailBlock' + urldata;
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var tplnode = '<div class="detailcomment">';
        if (category == 'crm' && 
           (ld('#cwn-crmdetail-view').hasClass('ui-hide') == false || ld('cwn-relationdetail-view').hasClass('ui-hide') == false)) {
            if (restobj.result.list2.createpermit == 'yes') {
                tplnode += '    <div class="writecomment">';
                if(ld('#cwn-crmdetail-view').hasClass('ui-hide') == false){
                    tplnode += '    <textarea id="commentsContent" name="commentsContent" placeholder="请填写评论内容" ></textarea>';    
                }
                else{
                    tplnode += '    <textarea id="r_commentsContent" name="r_commentsContent" placeholder="请填写评论内容" ></textarea>';    
                }
                tplnode += '       <div class="savebtn">评论</div>';
                tplnode += '    </div>';
            }
        }
        if (restobj.result.list2.viewpermit == 'yes') {
            tplnode += '    <p class="pubclear">评论记录</p>';
            tplnode += '    <ul>';
            if (restobj.result.list != undefined) {
                ld.each(restobj.result.list, function (key, list) {
                    tplnode += '<li><h3>' + list.last_name + '<i>' + list.createdtime + '</i></h3>' + list.commentcontent + '</li>';
                });
            }
            tplnode += '    </li>';
        }
        else {
            tplnode += '    <p class="pubclear tip">您没有查看权限</p>';
        }
        tplnode += '</div>';
        if (ld('#cwn-crmdetail-view').hasClass('ui-hide') == false) {
            ld('#divComment').html(tplnode);

        } else {//公共的相关信息
            ld('#divCommentrelated').html(tplnode);
        }
        callback();
        ld("#status").hide();
    });
}
//工作协同信息
commonHandleObj.getCoordinationInfo = function (detail, urldata, callback) {
    var urlstring = 'module=Home&action=ListView&method=getList' + urldata;
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var tplnode = ld('#tplCoordination').html();
        var listhtml = '';
        if (empty(restobj.report)) {
            listhtml = logicHanderObj.NoinfoNotice('数据');
        }
        var userimage, userimg, node, maxlength = 0;
        var signcls, accountlist, accountcls, contactlist, contactcls, productslist, productscls;
        var workimglist, workimgcls, workattlist, workattcls;
        SwiperObj.ListPageObj.setListPageIndex(restobj.summary.curpagenum, ViewObj.getInfo('to_viewid'));
        SwiperObj.ListPageObj.setHasNextPage(restobj.summary.havenextpage, ViewObj.getInfo('to_viewid'));
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
                    accountlist += '<a class="fontgery" href="javascript:void(0);">' +
                        accountobj.name + '</a>' + '、';
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
                    contactlist += '<a class="fontgery" href="javascript:void(0);"  >' +
                        contactsobj.name + '</a>' + '、';
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
                    productslist += productsobj.name + '、';
                    productsclscount++;
                })
                productslist = productslist.substr(0, productslist.length - 1);
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
                        workimglist += '<span img-detail="http://' + loginurl + '/' + imgpath +
                            '" style="display:none;"></span>';
                    });
                    workimglist += '<img src="' + tem_url + '" alt="" class=""><span>' +
                        img_index + '张</span></li>';
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
            //控制微博、日志、任务字段显示
            workreportlabel = '';
            var workfldarr = {'worksummary': 'summary', 'workexperience': 'experience'}
            switch (report.entitytype) {
                case 'weibo'://微博
                case 'cocmd'://任务
                    //转换表情路径
                    report.experience = report.experience.replace(new RegExp("themes/softed", "gm"), 'images');
                    workreportlabel = '<p class="font16 black">' + Tools.escape2Html(report.experience) + '</p>';
                    break;
                case 'workreport'://发日志
                    ld.each(workreport_field_obj['worktype_' + report.workreporttype],
                        function (fldname, fldlabel) {
                            if (workfldarr[fldname] != undefined) fldname = workfldarr[fldname];
                            fldlabelarr = fldlabel.split("&&&&&");
                            fldlabel = fldlabelarr[0];
                            //转换表情路径
                            report[fldname] = report[fldname].replace(new RegExp("themes/softed", "gm"), 'images');
                            workreportlabel += '<h3 class="font16">' + fldlabel + '</h3><p class="font16 black">' + Tools.escape2Html(report[fldname]) + '</p>';
                        }
                    );
                    break;
            }
            node = Tools.sprintf(tplnode,
                report.curid,
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
                productslist
            );
            node = strtr(node, 'name-img', userimg);//用户图片
            listhtml += node;
        });
        if (detail == 'relatedDetail') {
            ld('#divCoordinationrelated').html(listhtml);
        }
        else if (detail == 'detail') {
            ld('#divCoordination').html(listhtml);
        }
        callback();
    });
}

//相关信息列表
function getRelatedList(urldata, callback) {
    var urlstring = urldata + '&mode=list&recordid=' + relatedrecord +
        '&related_module=' + relatedmodule + '&related_id=' + related_id;
    WordReportAjax(urlstring, function (rest) {
        try {
            if (empty(rest)) return false;
            var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
            //获取关联创建相关参数
            if(restobj.result.relatedCreationInfo != undefined && restobj.result.relatedCreationInfo!= ''){
                ViewObj.rootScope.relatedCreationInfo = restobj.result.relatedCreationInfo;
            }
            var listhtml = '',
                list_class = 'crm-lists';
            if (newmodule == 'ContactRecords' || newmodule == 'VendorContactRecords') {
                list_class = 'crm-lists line3';
            }
            //计算多少行
            if (!empty(restobj.result.list1)) {
                if(restobj.result.list1[0].title){
                    var i = 1;
                    ld.each(restobj.result.list1[0].field, function (listfieldkey, listfieldinfo) {
                        i++;
                    });
                    list_class = 'crm-lists line'+i;
                }
            }
            if (newmodule == 'ShareUser') {
                list_class = 'listimg';
            } 
            listhtml = '<ul class="'+ list_class +'">';
            if (empty(restobj.result.list1)) {
                listhtml = logicHanderObj.NoinfoNotice(restobj.result.list2.moduletitle);
            }
            SwiperObj.ListPageObj.setListPageIndex(restobj.result.curpagenum, ViewObj.getInfo('to_viewid'));
            SwiperObj.ListPageObj.setHasNextPage(restobj.result.havenextpage, ViewObj.getInfo('to_viewid'));
            listhtml += getlistData(restobj.result.list1, newmodule);//输出列表
            listhtml += '</ul>';
            var content_holder = ld('#relatedlistbox');
            if (SwiperObj.is_addMore) { //加载  不清空原来内容
                content_holder.html(content_holder.html() + listhtml);
            } else { //刷新、搜索、换其他内容时都需要清空原来内容
                content_holder.html(listhtml);
            }
            if(newmodule != 'Attachment'){
                //判断相关信息是否有创建权限
                if (category === 'crm' && restobj.result.list2.createpermit === 'yes'
                    && module != 'Approve'
                    && newmodule != 'Products' && newmodule != 'Campaigns'
                    && newmodule != 'Accounts') {
                    
                    if (module === 'Products') {
                        if (newmodule === 'ShareUser') {
                            var current_header = ViewObj.getInfo('current_header');
                            current_header.splice(4, 2, '+', '');
                            ViewObj.setAppHeader(current_header);
                        }
                    }
                    else if (module === 'Campaigns') {
                        if (newmodule != 'Accounts' && newmodule != 'Contacts') {
                            var current_header = ViewObj.getInfo('current_header');
                            current_header.splice(4, 2, '+', '');
                            ViewObj.setAppHeader(current_header);
                        }
                    }
                    else if (module === 'Project') {
                        if (newmodule != 'HelpDesk') {
                            var current_header = ViewObj.getInfo('current_header');
                            current_header.splice(4, 2, '+', '');
                            ViewObj.setAppHeader(current_header);
                        }
                    }
                    else if(module === 'Potentials'){
                        if (newmodule != 'Contacts') {
                            var current_header = ViewObj.getInfo('current_header');
                            current_header.splice(4, 2, '+', '');
                            ViewObj.setAppHeader(current_header);
                        }
                    }
                    else {
                        var current_header = ViewObj.getInfo('current_header');
                        current_header.splice(4, 2, '+', '');
                        ViewObj.setAppHeader(current_header);
                    }
                }

                if(newmodule == 'ShareUser'){
                    ld('#app_header #head_rig').find('.lnr-plus').attr('fild_id','shareuserid');
                    ld('#app_header #head_rig').find('.lnr-plus').attr('desc','create');
                    ld('#app_header #head_rig').find('.lnr-plus').attr('flid_lable',ld('#app_header #head_mid').find('span').html());
                    ld('#app_header #head_rig').find('.lnr-plus').attr('choose_module','ShareUsers');
                    ld('#app_header #head_rig').find('.lnr-plus').attr('parentstatus','no');
                }
            }
            else{
                //Attachment
                var current_header = ViewObj.getInfo('current_header');
                current_header.splice(4, 2, '', '');
                ViewObj.setAppHeader(current_header);
            }
            callback();
        }
        catch (e) {
            logicHanderObj.errorNotice();
        }
    });
}

//输出列表数据
function getlistData(list1, getlistmodule) {
    var listhtml = '';
    if(list1 == '' || list1 == null) return listhtml;
    ld.each(list1, function (key, list) {
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
            if (!list.E) {
                list.E = '--';
            }
            if (!list.F) {
                list.F = '--';
            }
        }
        
        if (list.approvestatus == '' || list.approvestatus == null || list.approvestatus == undefined) {
            list.approvestatus = '';
        }
        else{
            list.approvestatus = list.approvestatus + '&nbsp;&nbsp;';
        }
        if(!list.title){
            // 客户、供应商
            // Accounts：A客户名称,B销售负责人,C客户状态,D创建时间;
            // Vendors：A供应商编号,B名称,C采购负责人,D创建时间;
            if (getlistmodule == 'Accounts' ||
                getlistmodule == 'Vendors' ||
                getlistmodule == 'ServiceCharge') {
                listhtml += '<li record="' + list.curid + '">' +
                    '<h5><span style="color:#ff8000 !important;">' + list.approvestatus + '</span>' + list.A + '</h5>' +
                    '<p><span>' + list.B + '</span> | <span>' + list.C + ' | ' + list.D + '</span></p>' +
                    '</li>';
                // 联系记录、供应商联系记录
                // ContactRecords: A主题,B销售负责人,C客户名称,D日期
                // VendorContactRecords：A主题,B采购负责人,C供应商名称,D创建时间
            } else if ( getlistmodule == 'ContactRecords' ||
                getlistmodule == 'VendorContactRecords') {
                listhtml += '<li record="' + list.curid + '">' +
                    '<h5><span style="color:#ff8000 !important;">' + list.approvestatus + '</span>' + list.A + '</h5>' +
                    '<p><span>' + list.C + '</span></p>' +
                    '<p><span>' + list.B + ' | ' + list.D + '</span></p>' +
                    '</li>';
                // 销售机会、市场活动、公告、产品
                // Campaigns:A销售机会名称、市场活动名称,B负责人,C创建时间
                // PublicAnnouncement: A标题,B日期,C内容;Products: A产品名称,B计量单位,C规格型号
            } else if ( getlistmodule == 'Potentials' ||
                getlistmodule == 'Campaigns' ||
                getlistmodule == 'PublicAnnouncement' ||
                getlistmodule == 'Products') {
                listhtml += '<li record="' + list.curid + '">' +
                    '<h5><span style="color:#ff8000 !important;">' + list.approvestatus + '</span>' + list.A + '</h5>' +
                    '<p><span>' + list.B + '</span> | <span>' + list.C + '</span></p>' +
                    '</li>';
            } else if (getlistmodule == 'Faq') {//常见问题
                //A编号,B问题类别,C常见问题,D问题内容
                listhtml += '<li record="' + list.curid + '">' +
                    '<h5><span style="color:#ff8000 !important;">' + list.approvestatus + '</span>' + list.A + '</h5>' +
                    '<p><span>' + list.B + '</span> | <span>' + list.C + ' | ' + list.D + '</span></p>' +
                    '</li>';
            } else if (getlistmodule == 'Contacts' || getlistmodule == 'VendorContact') {//联系人、供应商联系人
                var phoneshow = 'ui-hide',
                    relmobile = /^1\d{10}$/,
                    relhome = /^((\d{3})|((\d{3})-)|(\d{4})|((\d{4})-))?(\d{7,8})$/,
                    newphone_arr = new Array(),
                    newphone_str = '';
                if (list.D != '--') {
                    var number = new Array();
                    number = list.D.split(',');
                    //去除重复的号码
                    for (var j = 0; j < number.length; j++) {
                        var items = number[j];
                        if (relmobile.test(items) || relhome.test(items)) {
                            if (ld.inArray(items, newphone_arr) == -1) {
                                newphone_arr.push(items);
                                newphone_str += items + '&&';
                            }
                        }
                    }
                    if (newphone_arr.length > 0) {
                        phoneshow = '';
                    }
                }
                // Contacts：A联系人名称,B销售负责人,C客户名称,D电话
                // VendorContact：A姓名,B采购负责人,C供应商联系人,D电话
                listhtml += '<li record="' + list.curid + '" class="r-cell">' +
                    '<h5><span style="color:#ff8000 !important;">' + list.approvestatus + '</span>' + list.A + '</h5>' +
                    '<p><span>' + list.B + '</span> | <span>' + list.C + '</span><a phonemobile="' + newphone_str + '" class="lnr-phone-handset ' + phoneshow + '" tag="call">&nbsp;</a></p>' +
                    '</li>';
                // 合同订单、报价单、服务合同、采购订单、费用报销
                // A单据编号,B客户名称,C金额,D销售负责人,E签约时间/创建时间
                //项目/项目计划：A编号B客户C预算D项目负责人E状态
            } else if ( getlistmodule == 'SalesOrder' ||
                getlistmodule == 'Quotes' ||
                getlistmodule == 'ServiceContracts' ||
                getlistmodule == 'PurchaseOrder' ||
                getlistmodule == 'Expense' ||
                getlistmodule == 'Project' ||
                getlistmodule == 'ProjectTask') {

                listhtml += '<li record="' + list.curid + '">' +
                    '<h5><span style="color:#ff8000 !important;">' + list.approvestatus + '</span>' + list.A + ' | ' + list.B + '</h5>' +
                    '<p><span>' + list.C + '</span> | <span>' + list.D + ' | ' + list.E + '</span></p>' +
                    '</li>';
                // 客户服务单
            } else if (getlistmodule == 'HelpDesk') {
                if (!list.B || list.B == '-0001-11 00:00:00') list.B = '--';//实际处理时间
                // A服务单编号,B实际处理时间,C负责人,D客户名称,E状态
                listhtml += '<li record="' + list.curid + '">' +
                    '<h5><span style="color:#ff8000 !important;">' + list.approvestatus + '</span>' + list.A + ' | ' + list.D + '</h5>' +
                    '<p><span>' + list.C + '</span> | <span>' + list.E + ' | ' + list.B + '</span></p>' +
                    '</li>';
            } else if(getlistmodule == 'Attachment'){
                //var attArr = list.A.split('.');attArr[attArr.length-1]            
                listhtml += '<li record="' + list.curid + '" class="r-cell">' +
                    '<h5></span>' + list.A + '</h5>' +
                    '<p><span>' + list.B + '</span> | <span>' + list.C + '</span><a class="lnr-phone-handset" href="http://' + loginurl + '/' + list.D + list.A + '" download="' + list.A + '" tag="att">&nbsp;</a></p>' +
                    '</li>';
            } else if(getlistmodule == 'ShareUser'){
                listhtml += '<li>' +
                                '<div>' +
                                    '<img src="http://' + loginurl + '/' + list.userimg + '" onload="logicHanderObj.loadimg(this)" >' +
                                '</div>' +
                                '<span class="center text-ellipsis">' +
                                    '<i class="text-ellipsis">' + list.lastname + '</i>' +
                                    list.description +
                                '</span>' +
                            '</li>';
            }
        }
        else{
            var module_class = '';
            if (getlistmodule == 'Contacts' || getlistmodule == 'VendorContact') {
                module_class = 'r-cell';
                var phoneshow = 'ui-hide',
                    relmobile = /^1\d{10}$/,
                    relhome = /^((\d{3})|((\d{3})-)|(\d{4})|((\d{4})-))?(\d{7,8})$/,
                    newphone_arr = new Array(),
                    newphone_str = '';
                if (list.hidden != undefined && list.hidden != '--') {
                    var number = new Array();
                    number = list.hidden.split(',');
                    //去除重复的号码
                    for (var j = 0; j < number.length; j++) {
                        var items = number[j];
                        if (relmobile.test(items) || relhome.test(items)) {
                            if (ld.inArray(items, newphone_arr) == -1) {
                                newphone_arr.push(items);
                                newphone_str += items + '&&';
                            }
                        }
                    }
                    if (newphone_arr.length > 0) {
                        phoneshow = '';
                    }
                }
            }
            listhtml += '<li record="' + list.curid + '" class="' + module_class + '">';
                            if(list.approvestatus == ''){
            listhtml +=         '<h5>' + list.title + '</h5>';
                            }
                            else{
            listhtml +=         '<h5><span style="color:#ff8000 !important;">' + list.approvestatus + '</span>' + list.title + '</h5>';                
                            }
                            var phonerow = 0;
                            ld.each(list.field, function (keyfield, listfield) {
                                phonerow++;
                                var listfieldOne = listfield[0],
                                    listfieldTwo = listfield[1];
                                if(listfieldOne == undefined) listfieldOne = '';
                                if(listfieldTwo == undefined) listfieldTwo = '';
                                if(phonerow == 1 && (getlistmodule == 'Contacts' || getlistmodule == 'VendorContact')){
            listhtml +=             '<p><span>' + listfieldOne + '</span> | <span>' + listfieldTwo + '</span>' +  
                                    '<a phonemobile="' + newphone_str + '" class="lnr-phone-handset ' + phoneshow + '" tag="call">&nbsp;</a>' +
                                    '</p>';
                                }
                                else{
            listhtml +=             '<p><span>' + listfieldOne + '</span> | <span>' + listfieldTwo + '</span></p>';                                    
                                }
                            });
            listhtml += '</li>';
        }
    });
    return listhtml;
}

//获取相关信息单据明细
function getRelatedDetail(urlstring, callback) {
    ld('#cwn-relationdetail-view').html('');
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        if (restobj.code != -1) {
            ld('#divCoordinationrelated,#detailboxrelated,#divApproveLogrelated,#divCommentrelated').html('');//清空内容
        } else {
            PopPromptBox.show(restobj.msg);
            ld("#status").hide();
            return;
        }
        var relateddetailhtml = '<div id="divDetailLabelrelated" class="tabswitch ui-hide"></div>' +
            '<div id="divCoordinationrelated" class="ui-hide"></div>' +
            '<div id="detailboxrelated" class="ui-hide"></div>' +
            '<div id="divApproveLogrelated" class="ui-hide"></div>' +
            '<div id="divCommentrelated" class="ui-hide"></div>';
        ld('#cwn-relationdetail-view').html(relateddetailhtml);
        try {
            var res = restobj.result;
            var detailModule = res.list2.module;
            //客户-公海已分配
            if (detailModule === 'Accounts'){
                ViewObj.rootScope.completedpermit = res.list2.completedpermit;//是否显示达成图标
            }
            //明细界面标签
            var detailLabelhtml = '';
            if (detailModule == 'Accounts' || detailModule == 'Contacts') {//客户、联系人有工作协同
                detailLabelhtml += '<a choosename="coordination">工作协同</a>';
            }
            detailLabelhtml += '<a choosename="detailView" class="curr">详细资料</a>';
            ViewObj.rootScope.openapprove = res.list2.openapprove;//是否启用审批历史,yes:启用
            if (ViewObj.rootScope.openapprove == 'yes') {
                detailLabelhtml += '<a choosename="divApprove">审批历史</a>';
            }
            ViewObj.rootScope.opencomments = res.list2.opencomments;//是否启用评论,yes:启用
            if (ViewObj.rootScope.opencomments == 'yes') {
                detailLabelhtml += '<a choosename="divComment">评&nbsp;&nbsp;论&nbsp;</a>';
            }
            ld('#divDetailLabelrelated').html(detailLabelhtml);
            ld('#divDetailLabelrelated').addClass(res.list2.detailLabelClass);//页签宽度
            ld('#divDetailLabelrelated,#detailboxrelated').removeClass('ui-hide');//显示详细资料和评论标签
            var tplnode = '';
            //客户-公海已分配
            if (detailModule === 'Accounts'){
                tplnode += '<div id="divReachDetailViewforRea" class="ui-hide" style="position:absolute;z-index:650;right:30%;padding-top: 7px;">' + 
                                '<img src="images/reach.png">' + 
                           '</div>';
            }
            //客户和联系人关联字段
            if (res.list4 != undefined && res.list4 != null && res.list4 != '') {
                var accountAndcontactHtml = '';
                accountAndcontactHtml += '<h2 class="c-detail-h2">' + res.list4.blocklabel + '<i class="lnr-chevron-down"></i></h2>';
                accountAndcontactHtml += '<ul class="c-ul c-detail-cell">';
                ld.each(res.list4.fieldinfo, function (key, list) {
                    if (Tools.escape2Html(list.text) == '') {
                        var text = '<b>未填写</b>';
                    } else {
                        var text = Tools.escape2Html(list.text);
                    }
                    accountAndcontactHtml += '<li><i>' + list.fieldlabel + '</i><span>' + text + '</span></li>';
                });
                accountAndcontactHtml += '</ul>';
                if (res.list4.display_position == 0) {
                    tplnode += accountAndcontactHtml;
                }
            }
            ld.each(res.list, function (key, list) {
                if (empty(list)) return false;
                if (list.display_status === '0') {
                    tplnode += '<h2 class="c-detail-h2">' + list.blocklabel + '<i class="lnr-chevron-up"></i></h2>';
                    tplnode += '<ul class="c-ul c-detail-cell ui-hide">';
                }
                else {
                    tplnode += '<h2 class="c-detail-h2">' + list.blocklabel + '<i class="lnr-chevron-down"></i></h2>';
                    tplnode += '<ul class="c-ul c-detail-cell">';
                }
                ld.each(list.fieldinfo, function (key, fieldinfo) {
                    if (fieldinfo.text == "undefined" || fieldinfo.text == null || fieldinfo.text == '') fieldinfo.text = '';
                    //客户，联系人是电话类型字段的显示电话图标
                    var phone = '';
                    if (fieldinfo.phone == 'yes' && fieldinfo.text != '<b>未填写</b>') {
                        var phonemobile = Tools.escape2Html(fieldinfo.text);
                        if (phoneversion == 'ios') {
                            callhtml = 'href="tel:' + phonemobile + '"';
                        }
                        else {
                            callhtml = "onclick=androidObj.callPhone('" + phonemobile + "');";
                        }
                        phone = '<a ' + callhtml + ' class="lnr-phone-handset">&nbsp;&nbsp;</a>';
                    }
                    //根据不同类型显示不同信息
                    if (fieldinfo.uitype == '19') {//区域
                        tplnode += '<li class="heightauto"><i>' + fieldinfo.fieldlabel + '</i><div>' + fieldinfo.text + '</div>';
                    } else if (fieldinfo.uitype == '69') {//照片
                        tplnode += '<li><i>' + fieldinfo.fieldlabel +
                            '</i><div class="view picture-rang picture-preview">';
                        if (!fieldinfo.text) {
                            tplnode += '<div img-detail ><img img_num="1" src="images/defaultuser.png" onload="logicHanderObj.loadimg(this)"/> </div>';
                            //'style = "background-image:url(images/defaultuser.png)"
                        } else {
                            ld.each(fieldinfo.options, function (imgkey, imgvalue) {
                                if (empty(list)) return false;
                                tplnode += '<div img-detail ><img img_num=' + (imgkey + 1) + ' src="http://' + loginurl + '/' + imgvalue.value + '" onload="logicHanderObj.loadimg(this)"/> </div>';
                                //style = "background-image:url(http://'+loginurl+'/'+imgvalue.value+')"'
                            });
                        }
                        tplnode += '</div>';

                    } else if (fieldinfo.uitype == '83') {//产品税别
                        tplnode += '<li><i>' + fieldinfo.fieldlabel + '</i><span>';
                        if (res.tax_info != undefined) {
                            ld.each(res.tax_info, function (taxkey, taxinfo) {
                                tplnode += taxinfo.taxlabel + ' : ' + taxinfo.percentage + ';';
                            });
                        }
                        tplnode += '</span>';
                    } else if (fieldinfo.uitype == '1108' || fieldinfo.uitype == '1109') {//附件
                        tplnode += '<li><i>' + fieldinfo.fieldlabel +'</i><span>';
                        if(fieldinfo.text != '<b>未填写</b>'){
                            tplnode +=  '<ul class="attUl">';
                            ld.each(fieldinfo.text, function (attkey, attvalue) {
                                var img = Tools.getAttImg(attvalue.name);
                                tplnode +=  '<li>' + 
                                                '<div class="item-content" att_id="' + attvalue.id + '">' + 
                                                    '<div class="media-list">' + 
                                                    '    <img style="width:36px;height:36px;" src="images/' + img + '.png">' + 
                                                    '</div>' + 
                                                    '<div class="item-inner">' + 
                                                    '    <div class="item-title">' + attvalue.name + '</div>' + 
                                                    '    <div class="item-path ui-hide">' + attvalue.path + '</div>' + 
                                                    '    <div class="item-text">' + attvalue.size + '</div>' + 
                                                    '</div>' + 
                                                '</div>' + 
                                            '</li>';
                            });
                            tplnode +=  '</ul>';
                        }
                        else{
                            tplnode += '尚无附件';
                        }
                        tplnode += '</span>';
                    } else {
                        tplnode += '<li><i>' + fieldinfo.fieldlabel + '</i><span>' + Tools.escape2Html(fieldinfo.text) + phone + '</span>';
                    }
                    tplnode += '</li>';
                });
                tplnode += '</ul>';
            });
            //客户和联系人关联字段
            if (res.list4 != undefined && res.list4 != null && res.list4 != '') {
                if (res.list4.display_position == 1) {
                    tplnode += accountAndcontactHtml;
                }
            }
            if(!res.entry){
                //合同订单，报价单，服务合同,采购订单
                var res_pdct = res.listproduct;
                if (res_pdct && res_pdct.total.count > 0) {
                    ViewObj.rootScope.sys_49 = restobj.result.list2.sys_49;
                    ViewObj.rootScope.sys_93 = restobj.result.list2.sys_93;
                    rowcnt = res_pdct.total.count; // 全局变量赋值
                    productcount = rowcnt;   // 全局变量赋值
                    var currency_name = res_pdct.currency_name,
                        producttotal = res_pdct.total.hdnGrandTotal;
                    tplnode += '<h2 class="c-detail-h2">产品清单<b class="pricetype">' + currency_name + '</b></h2>' +
                        '<ul class="c-ul c-other-cell detail" id="productbill">';
                    var productModule = module;
                    ld.each(res_pdct.list, function (key, list) {
                        if (empty(list)) return false;
                        var taxpriceStr = Tools.Number.toDecimal(list.taxprice, parseInt(ViewObj.rootScope.sys_93));
                        var quantityStr = Tools.Number.toDecimal(list.quantity, parseInt(ViewObj.rootScope.sys_49));
                        if (module === 'Approve') {
                            productModule = approvemodule;
                        }
                        tplnode += '<li tag=' + list.productid + ' module=' + productModule + ' sequence_no=' + list.sequence_no + '><p><i class="text-ellipsis">' + list.productname + '</i></p><p><span>' + list.productshowfieldslabel + '</span></p></li>';
                    });
                    tplnode += '</ul>';
                    //整单折扣信息
                    var discount_type = res_pdct.total.discount_type,      //整单折扣类型
                        discount_percent = res_pdct.total.discount_percent,//折扣百分比
                        txtAdjustment = res_pdct.total.txtAdjustment,//调整价格
                        hdnDiscountAmount = res_pdct.total.hdnDiscountAmount,//直接降价
                        _viewDiscountVal = '',
                        _viewDiscountDetialVal = '',
                        _viewAdjustmentVal = '',
                        _viewAdjustmentDetialVal = '';
                    if (discount_percent == null) {
                        discount_percent = '0.00';
                    }
                    if (txtAdjustment == null) {
                        txtAdjustment = '0.00';
                    }
                    if (hdnDiscountAmount == null) {
                        hdnDiscountAmount = '0.00';
                    }
                    if (txtAdjustment < 0) {
                        _viewAdjustmentVal = '减少';
                        _viewAdjustmentDetialVal = Math.abs(txtAdjustment);
                    }
                    else {
                        _viewAdjustmentVal = '增加';
                        _viewAdjustmentDetialVal = txtAdjustment;
                    }
                    if (discount_type == 0) {
                        _viewDiscountVal = '直接降价';
                        _viewDiscountDetialVal = hdnDiscountAmount;
                    } else {
                        _viewDiscountVal = '百分比降价';
                        _viewDiscountDetialVal = discount_percent;
                    }
                    if (res.listproductfield != null) {
                        tplnode += '<ul class="c-ul c-other-total detail">';
                        tplnode += '<li><span>数量小计</span><span>' + Tools.Number.toDecimal(res_pdct.total.allquantity, parseInt(ViewObj.rootScope.sys_49)) + '</span></li>';
                        if (res_pdct.total.hdnSubTotal != undefined) {
                            tplnode += '<li><span>金额小计</span><span>' + Tools.Number.toDecimal(res_pdct.total.hdnSubTotal, 2) + '</span></li>';
                        }
                        ld.each(res.listproductfield, function (keylist, list) {
                            if (list.newline == 1) {
                                if (list.uitype == '35') {
                                    tplnode += '<li><span>调整</span><b id="viewAdjustment">' + _viewAdjustmentVal +
                                        '</b><span id="viewAdjustmentDetial">' + Tools.Number.toDecimal(_viewAdjustmentDetialVal, 2) +
                                        '</span></li>';
                                }
                                if (list.uitype == '37') {
                                    tplnode += '<li><span>整单折扣</span><b id="viewDiscount">' + _viewDiscountVal +
                                        '</b><span id="viewDiscountDetial">' + Tools.Number.toDecimal(_viewDiscountDetialVal, 2) +
                                        '</span></li>';
                                }
                            }
                        });
                        tplnode += '<li><span>总金额</span><span style="color: #ff8000 !important;">' + logicHanderObj.fmoney(producttotal) + '</span></li>';
                        tplnode += '</ul>';
                    }
                }
                //费用清单
                if (res.listexpense && res.listexpense.count > 0) {
                    ViewObj.rootScope.sys_49 = restobj.result.list2.sys_49;
                    ViewObj.rootScope.sys_93 = restobj.result.list2.sys_93;
                    var expensecount = res.listexpense.count,
                        expenseblocklabel = res.listexpense.blocklabel;
                    tplnode += '<h2 class="c-detail-h2">' + expenseblocklabel + '</h2><ul class="c-ul c-other-cell detail">';
                    ld.each(res.listexpense.list, function (key, list) {
                        if (empty(list)) return false;
                        var rmb_totalStr = Tools.Number.toDecimal(list.rmb_total, parseInt(2));
                        tplnode += '<li><p><i class="text-ellipsis">' + list.expenseuse + '</i></p><p>' + list.expensetype + '<span>' + rmb_totalStr + '</span></p></li>';
                    });
                    tplnode += '</ul>';
                    tplnode += '<ul class="c-ul c-other-total detail">';
                    tplnode += '<li><span>总金额</span><span style="color: #ff8000 !important;">'+ res.listexpense.total.total +'</span></li>';
                    tplnode += '</ul>';
                }
            }
            else{
                var entry_blocklabel = res.entry.blocklabel,
                    entry_listinfo = res.entry.list,
                    entry_total = res.entry.p_total;
                tplnode += '<h2 class="c-detail-h2">' + entry_blocklabel;
                if(newmodule == 'Quotes' || newmodule == 'SalesOrder' || newmodule == 'ServiceContracts'){
                    tplnode += '<b class="pricetype">' + res.currency.current.currency_name + '</b>';
                }
                tplnode += '</h2>';
                tplnode += '<ul class="c-ul c-other-cell detailnew" id="productbillnew" >';
                ld.each(entry_listinfo, function (key, list) {
                    if (empty(list)) return false;
                    var entry_class = '';
                    if(list.item4){
                        entry_class = 'entrytypeclass';
                    }
                    tplnode +=  '<li class="' + entry_class + '" entryid="' + list.entryid + '" entrytype="' + list.entrytype + '" sequence_no="' + list.sequence_no + '" >' + 
                                    '<p><i class="text-ellipsis">' + list.item1 + '</i></p>';
                                    if(list.item3){
                    tplnode +=          '<p>' + list.item3 + '<span>' + list.item2 + '</span></p>';
                                    }
                                    else{
                    tplnode +=          '<p><span>' + list.item2 + '</span></p>';
                                    }
                                    if(list.item4){
                    tplnode +=          '<p><span>' + list.item4 + '</span></p>';    
                                    }
                    tplnode +=  '</li>';
                });
                tplnode += '</ul>';
                tplnode += '<ul class="c-ul c-other-total detail">';
                ld.each(entry_total, function (key, list) {
                    tplnode +=  '<li><span>' + list.label + '</span><span>' + list.value +'</span></li>';
                });
                tplnode += '</ul>';
            }
            ld('#detailboxrelated').html(tplnode);
            callback();
        }
        catch (e) {
            logicHanderObj.errorNotice();
        }
    });
}

function UserPopupInit(user_searchObj, callback) {
    //用户查找，填充条件
    var return_module = user_searchObj.return_module,
        searchtype = user_searchObj.searchtype,
        filterown = user_searchObj.filterown,
        scopetype = user_searchObj.scopetype,
        common = user_searchObj.common,
        isactive = user_searchObj.isactive,
        group_useridStr = '';
    if (common === 2) {
        choose_db_useridobj = [];
        choose_db_nameobj = [];//清空仪表盘选择查看范围
    }
    //是否显示常用标签(0:不显示;1:常用标签下没有我的选项;2:常用标签下有我的选项)
    ld('#label_usergroup a').attr('class', '');
    if (common === 0) {
        ld('#label_usergroup a[tag=Common]').addClass('ui-hide');
        ld('#label_usergroup a[tag=Colleague]').addClass('curr');
        ld('#ColleagueDiv').removeClass('ui-hide');//显示同事
        ld('#CommonDiv,#DepartmentDiv').addClass('ui-hide');//隐藏常用标签、部门标签
    }
    else {
        ld('#label_usergroup a[tag=Common]').removeClass('ui-hide');
        ld('#label_usergroup a[tag=Common]').addClass('curr');
        ld('#CommonDiv').removeClass('ui-hide');//显示常用标签
        ld('#ColleagueDiv,#DepartmentDiv').addClass('ui-hide');//隐藏同事、部门标签
    }
    var urlstring = 'module=Home&action=ListView&method=getGroupUsers' +
        '&return_module=' + return_module + '&searchtype=' + searchtype + '&filterown=' + filterown +
        '&scopetype=' + scopetype + '&common=' + common + '&isactive=' + isactive + '&searchcontent=';
    ld("#status").show();
    ld('#CommonDiv,#ColleagueDiv,#DepartmentDiv').html('');//清空数据
    WordReportAjax(urlstring, function (rest) {
        ld("#status").hide();
        if (rest == '') return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);

        ViewObj.rootScope.otherGroup = restobj.DepartmentGroup;//上下级部门关系
        //加载“常用”
        if (common != 0) {
            var commhtml = '';
            if (restobj.AllColleague || restobj.MeDepartment) {
                if (common === 2) {
                    if (restobj.MeColleague) {
                        /*
                        commhtml += '<div id="comgroupme" comgroupid="me" class="datainfo ' +
                            '" tag="me"><span groupname="我的">我的</span><i class="lnr-square"></i></div>';
                        */
                        commhtml += '<li id="comgroupme" comgroupid="me" class="classdatainfo" tag="me">' +
                                        '<div>' +
                                            '<img src="images/defaultuser.png" onload="logicHanderObj.loadimg(this)" >' +
                                        '</div>' +
                                        '<span class="center text-ellipsis" groupname="我的">' +
                                        '<i class="text-ellipsis">我的</i>' +
                                        '</span>' +
                                        '<span class="img-circle">' +
                                            '<i class="lnr-square"></i>' +
                                        '</span>' +
                                    '</li>';
                    }
                }
                if (restobj.AllColleague) {
                    /*
                    commhtml += '<div id="comgroupall" comgroupid="all" class="datainfo ' +'" tag="all"><span groupname="' + restobj.AllColleague.tips + '">' + 
                                restobj.AllColleague.tips + '<i>( ' + restobj.AllColleague.count +' )</i></span><i class="lnr-square"></i></div>';
                    */
                    commhtml += '<li id="comgroupall" comgroupid="all" class="classdatainfo" tag="all">' +
                                    '<div>' +
                                        '<img src="images/defaultgroups.png" onload="logicHanderObj.loadimg(this)" >' +
                                    '</div>' +
                                    '<span class="center text-ellipsis" groupname="' + restobj.AllColleague.tips + '">' +
                                        '<i class="text-ellipsis">' + restobj.AllColleague.tips + '<b>(' + restobj.AllColleague.count + ')</b></i>' +
                                    '</span>' +
                                    '<span class="img-circle">' +
                                        '<i class="lnr-square"></i>' +
                                    '</span>' +
                                '</li>';
                }
                if (restobj.MeDepartment) {
                    ld.each(restobj.MeDepartment, function (id, obj) {
                        if (common === 2) {
                            group_useridStr = 'tag="' + obj['group_userid'] + '"';
                        }
                        /*
                        commhtml += '<div id="comgroup' + id + '" comgroupid="' + id + '" class="datainfo' + '" ' + group_useridStr + '><span groupname="' + obj.name + '">' +
                            obj.tips + '：' + obj.name + '<i>( ' + obj.count + ' )</i></span><i class="lnr-square"></i></div>';
                        */
                        commhtml += '<li id="comgroup' + id + '" comgroupid="' + id + '" class="classdatainfo" ' + group_useridStr + '>' +
                                        '<div>' +
                                            '<img src="images/defaultgroups.png" onload="logicHanderObj.loadimg(this)" >' +
                                        '</div>' +
                                        '<span class="center text-ellipsis" groupname="' + obj.name + '">' +
                                            '<i class="text-ellipsis">' + obj.tips + '：' + obj.name + '<b>(' + obj.count + ')</b></i>' +
                                        '</span>' +
                                        '<span class="img-circle">' +
                                            '<i class="lnr-square"></i>' +
                                        '</span>' +
                                    '</li>';
                    });
                }
            }
            ld('#CommonDiv').html('<ul class="crm-lists-user-more ">'+commhtml+'</ul>');
        }

        //加载“部门”
        var grouphtml = '';
        if (restobj.Department) {
            ld.each(restobj.Department, function (id, obj) {
                if (common === 2) {
                    group_useridStr = 'tag="' + obj['group_userid'] + '"';
                }
                /*
                grouphtml += '<div id="group' + id + '" groupid="' + id + '" class="datainfo' +
                    '" ' + group_useridStr + '><div><img src="images/defaultgroups.png"></div><span groupname="' +
                    obj['name'] + '">' + obj['name'] + '<i>( ' + obj.count + ' )</i></span><i class="lnr-square"></i></div>';
                */
                grouphtml += '<li id="group' + id + '" groupid="' + id + '" class="classdatainfo" ' + group_useridStr + '>' +
                                '<div>' +
                                    '<img src="images/defaultgroups.png" onload="logicHanderObj.loadimg(this)" >' +
                                '</div>' +
                                '<span class="center text-ellipsis" groupname="'+ obj['name'] +'">' +
                                    '<i class="text-ellipsis">' + obj['name'] + '<b>(' + obj.count + ')</b></i>' +
                                '</span>' +
                                '<span class="img-circle">' +
                                    '<i class="lnr-square"></i>' +
                                '</span>' +
                            '</li>';
            });
        }
        ld('#DepartmentDiv').html('<ul class="crm-lists-user-more ">'+grouphtml+'</ul>');

        //加载“同事”
        var userhtml = '';
        if (restobj.Colleague) {
            ld.each(restobj.Colleague, function (userkey, obj) {
                userhtml += '<li id="user' + obj.userid.value + '" userid="' + obj.userid.value + '" class="classdatainfo" >' +
                                '<div>' +
                                    '<img src="http://' + loginurl + '/' + obj.userimgpath.value + '" onload="logicHanderObj.loadimg(this)" >' +
                                '</div>' +
                                '<span class="center text-ellipsis">' +
                                    '<i class="text-ellipsis">' + obj.lastname.value + '</i>';
                                    if(obj.description){
                userhtml +=             obj.description.value;
                                    }
                                    else{
                                        if(obj.profilename){
                userhtml +=                 obj.profilename.value;                            
                                        }
                                        if(obj.userlevel){
                userhtml +=                 '-' + obj.userlevel.value;                            
                                        }
                                    }
                userhtml +=     '</span>' +
                                '<span class="img-circle">' +
                                    '<i class="lnr-square"></i>' +
                                '</span>' +
                            '</li>';
                /*
                userhtml += '<div id="user' + obj.userid.value + '" userid="' + obj.userid.value + '" class="datainfo ' +
                    '"><div><img src="http://' + loginurl + '/' + obj.userimgpath.value +
                    '" onload="logicHanderObj.loadimg(this)"></div><span>' + obj.lastname.value + '</span><i class="lnr-square"></i></div>';
                */
                
            });
        }
        ld('#ColleagueDiv').html('<ul class="crm-lists-user-more ">'+userhtml+'</ul>');
        //ld('#CommonDiv div[comgroupid],#ColleagueDiv div[userid],#DepartmentDiv div[groupid]').attr('class','datainfo squareimg');
        callback();
    });
}

//选择用户
function chooseUserCC(user_common, id, name) {
    //仪表盘选择
    if (user_common === 2) {
        if (choose_db_useridobj.length === 0) {
            choose_db_useridobj = [];
            choose_db_nameobj = [];
            choose_db_useridobj[0] = id;
            choose_db_nameobj[0] = name;
        }
        if (ld('#user' + id + ' i').hasClass('lnr-square')) {
            //ld('#user' + id + ' i').removeClass('lnr-square').addClass('lnr-checkmark-square');
            ld('#user' + id).find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
            if (ld.inArray(id, choose_db_useridobj) == -1) {//当前元素下标位置
                choose_db_useridobj[choose_db_useridobj.length] = id;
                choose_db_nameobj[choose_db_nameobj.length] = name;
            }
        } else {
            //ld('#user' + id + ' i').removeClass('lnr-checkmark-square').addClass('lnr-square');
            ld('#user' + id).find('.img-circle').find('i').removeClass('lnr-checkmark-square').addClass('lnr-square');  
            choose_db_useridobj.splice(ld.inArray(id, choose_db_useridobj), 1);
            choose_db_nameobj.splice(ld.inArray(name, choose_db_nameobj), 1);
        }
    }
    //工作标签选择
    else {
        //选择同事id
        if (empty(choose_useridobj)) {
            choose_useridobj[0] = id;
        }
        //选择同事名称
        if (empty(choose_usernameobj)) {
            choose_usernameobj[0] = name;
        }
        
        if (ld('#user' + id + ' i').hasClass('lnr-square')) {
            ld('#user' + id).find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
            if (ld.inArray(id, choose_useridobj) == -1) {//当前元素下标位置
                choose_useridobj[choose_useridobj.length] = id;
                choose_usernameobj[choose_usernameobj.length] = name;
            }
            ld('#chosenSendrange_Colleague').append('<li id="chosencolleague_' + id + '">' + name + '</li>');
        } else {
            ld('#user' + id).find('.img-circle').find('i').removeClass('lnr-checkmark-square').addClass('lnr-square');  
            choose_useridobj.splice(ld.inArray(id, choose_useridobj), 1);//移除选择id
            choose_usernameobj.splice(ld.inArray(name, choose_usernameobj), 1);
            ld('#' + 'chosencolleague_' + id).remove();//删除该条记录
        }
        
        //底部已选择数据显示
        showselectedCCorAt(choose_groupidobj, choose_groupnameobj, choose_useridobj, choose_usernameobj);
    }
}

//选择部门
function chooseGroupCC(user_common, idprefix, groupid, groupname) {
    //仪表盘选择
    if (user_common === 2) {
        var useridTag = ld('#' + idprefix + groupid).attr('tag');
        if (choose_db_useridobj.length === 0) {
            choose_db_useridobj = [];
            choose_db_nameobj = [];
            choose_db_useridobj[0] = useridTag;
            choose_db_nameobj[0] = groupname;
        }
        if(ld('#' + idprefix + groupid + '>i').hasClass('lnr-square') || ld('#' + idprefix + groupid + '>i').hasClass('lnr-checkmark-square')){
            if (ld('#' + idprefix + groupid).hasClass('lnr-square')) {
                ld('#comgroup' + groupid + '>i,#group' + groupid + '>i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                if (ld.inArray(useridTag, choose_db_useridobj) == -1) {//当前元素下标位置
                    choose_db_useridobj[choose_db_useridobj.length] = useridTag;
                    choose_db_nameobj[choose_db_nameobj.length] = groupname;
                }
            } else {
                ld('#comgroup' + groupid + '>i,#group' + groupid + '>i').removeClass('lnr-checkmark-square').addClass('lnr-square');
                choose_db_useridobj.splice(ld.inArray(useridTag, choose_db_useridobj), 1);
                choose_db_nameobj.splice(ld.inArray(groupname, choose_db_nameobj), 1);
            }
        }
        else{
            if (ld('#' + idprefix + groupid).find('.img-circle').find('i').hasClass('lnr-square')) {
                ld('#comgroup' + groupid).find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                ld('#group' + groupid).find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                if (ld.inArray(useridTag, choose_db_useridobj) == -1) {//当前元素下标位置
                    choose_db_useridobj[choose_db_useridobj.length] = useridTag;
                    choose_db_nameobj[choose_db_nameobj.length] = groupname;
                }
            } else {
                ld('#comgroup' + groupid).find('.img-circle').find('i').removeClass('lnr-checkmark-square').addClass('lnr-square');
                ld('#group' + groupid).find('.img-circle').find('i').removeClass('lnr-checkmark-square').addClass('lnr-square');
                choose_db_useridobj.splice(ld.inArray(useridTag, choose_db_useridobj), 1);
                choose_db_nameobj.splice(ld.inArray(groupname, choose_db_nameobj), 1);
            }
        }
    }
    //工作标签选择
    else {
        //选择部门id
        if (empty(choose_groupidobj)) {
            choose_groupidobj = [];
            choose_groupidobj[0] = groupid;
        }
        //选择部门名称
        if (empty(choose_groupnameobj)) {
            choose_groupnameobj = [];
            choose_groupnameobj[0] = groupname;
        }
        if(ld('#' + idprefix + groupid + '>i').hasClass('lnr-square') || ld('#' + idprefix + groupid + '>i').hasClass('lnr-checkmark-square')){
            if (ld('#' + idprefix + groupid + '>i').hasClass('lnr-square')) {
                ld('#comgroup' + groupid + '>i,#group' + groupid + '>i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                if (ld.inArray(groupid, choose_groupidobj) == -1) {//当前元素下标位置
                    choose_groupidobj[choose_groupidobj.length] = groupid;
                    choose_groupnameobj[choose_groupnameobj.length] = groupname;
                }
                if (groupid == 'all') {
                    ld('#chosenSendrange_commGroup').append('<li chooseid="' + groupid + '">' + groupname + '</li>');
                } else {
                    ld('#chosenSendrange_Group').append('<li chooseid="' + groupid + '">' + groupname + '</li>');
                    //选中子部门
                    ld.each(ViewObj.rootScope.otherGroup, function (keygroupid, childobj) {
                        //选中当前部门的下属部门
                        if (groupid == keygroupid) {
                            ld.each(childobj, function (key, valueid) {
                                ld('#comgroup' + valueid + '>i,#group' + valueid + '>i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                                valueid = valueid.toString();//转字符串类型
                                if (ld.inArray(valueid, choose_groupidobj) == -1) {
                                    choose_groupidobj[choose_groupidobj.length] = valueid;
                                    subgroupname = ld('#group' + valueid).find('span').attr('groupname');
                                    choose_groupnameobj[choose_groupnameobj.length] = subgroupname;
                                    ld('#chosenSendrange_Group').append('<li chooseid="' + valueid + '">' + subgroupname + '</li>');
                                }
                            });
                        }
                    });
                }
            } else {
                ld('#comgroup' + groupid + '>i,#group' + groupid + '>i').removeClass('lnr-checkmark-square').addClass('lnr-square');
                choose_groupidobj.splice(ld.inArray(groupid, choose_groupidobj), 1);//移除选择id
                choose_groupnameobj.splice(ld.inArray(groupname, choose_groupnameobj), 1);
                if (groupid == 'all') {
                    ld('#chosenSendrange_commGroup>[chooseid=' + groupid + ']').remove();
                } else {
                    ld('#chosenSendrange_Group>[chooseid=' + groupid + ']').remove();
                    //移除子部门
                    ld.each(ViewObj.rootScope.otherGroup, function (keygroupid, childobj) {
                        //取消选中部门的下属部门
                        if (groupid == keygroupid) {
                            ld.each(childobj, function (key, valueid) {
                                ld('#comgroup' + valueid + '>i,#group' + valueid + '>i').removeClass('lnr-checkmark-square').addClass('lnr-square');
                                valueid = valueid.toString();
                                groupname = ld('#group' + valueid).find('span').attr('groupname');
                                if (ld.inArray(valueid, choose_groupidobj) != -1) {
                                    choose_groupidobj.splice(ld.inArray(valueid, choose_groupidobj), 1);
                                    choose_groupnameobj.splice(ld.inArray(groupname, choose_groupnameobj), 1);
                                    ld('#chosenSendrange_Group>[chooseid=' + valueid + ']').remove();
                                }
                            });
                        }
                    });
                }
            }    
        }
        else{
            if (ld('#' + idprefix + groupid).find('.img-circle').find('i').hasClass('lnr-square')) {
                ld('#comgroup' + groupid).find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                ld('#group' + groupid).find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                if (ld.inArray(groupid, choose_groupidobj) == -1) {//当前元素下标位置
                    choose_groupidobj[choose_groupidobj.length] = groupid;
                    choose_groupnameobj[choose_groupnameobj.length] = groupname;
                }
                if (groupid == 'all') {
                    ld('#chosenSendrange_commGroup').append('<li chooseid="' + groupid + '">' + groupname + '</li>');
                } else {
                    ld('#chosenSendrange_Group').append('<li chooseid="' + groupid + '">' + groupname + '</li>');
                    //选中子部门
                    ld.each(ViewObj.rootScope.otherGroup, function (keygroupid, childobj) {
                        //选中当前部门的下属部门
                        if (groupid == keygroupid) {
                            ld.each(childobj, function (key, valueid) {
                                ld('#comgroup' + valueid).find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                                ld('#group' + valueid).find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                                valueid = valueid.toString();//转字符串类型
                                if (ld.inArray(valueid, choose_groupidobj) == -1) {
                                    choose_groupidobj[choose_groupidobj.length] = valueid;
                                    subgroupname = ld('#group' + valueid).find('span').attr('groupname');
                                    choose_groupnameobj[choose_groupnameobj.length] = subgroupname;
                                    ld('#chosenSendrange_Group').append('<li chooseid="' + valueid + '">' + subgroupname + '</li>');
                                }
                            });
                        }
                    });
                }
            } else {
                ld('#comgroup' + groupid).find('.img-circle').find('i').removeClass('lnr-checkmark-square').addClass('lnr-square');
                ld('#group' + groupid).find('.img-circle').find('i').removeClass('lnr-checkmark-square').addClass('lnr-square');
                choose_groupidobj.splice(ld.inArray(groupid, choose_groupidobj), 1);//移除选择id
                choose_groupnameobj.splice(ld.inArray(groupname, choose_groupnameobj), 1);
                if (groupid == 'all') {
                    ld('#chosenSendrange_commGroup>[chooseid=' + groupid + ']').remove();
                } else {
                    ld('#chosenSendrange_Group>[chooseid=' + groupid + ']').remove();
                    //移除子部门
                    ld.each(ViewObj.rootScope.otherGroup, function (keygroupid, childobj) {
                        //取消选中部门的下属部门
                        if (groupid == keygroupid) {
                            ld.each(childobj, function (key, valueid) {
                                ld('#comgroup' + valueid).find('.img-circle').find('i').removeClass('lnr-checkmark-square').addClass('lnr-square');
                                ld('#group' + valueid).find('.img-circle').find('i').removeClass('lnr-checkmark-square').addClass('lnr-square');
                                valueid = valueid.toString();
                                groupname = ld('#group' + valueid).find('span').attr('groupname');
                                if (ld.inArray(valueid, choose_groupidobj) != -1) {
                                    choose_groupidobj.splice(ld.inArray(valueid, choose_groupidobj), 1);
                                    choose_groupnameobj.splice(ld.inArray(groupname, choose_groupnameobj), 1);
                                    ld('#chosenSendrange_Group>[chooseid=' + valueid + ']').remove();
                                }
                            });
                        }
                    });
                }
            }
        }
        //底部已选择数据显示
        showselectedCCorAt(choose_groupidobj, choose_groupnameobj, choose_useridobj, choose_usernameobj);
    }
}

//底部已选择数据显示
function showselectedCCorAt(groupidobj, groupnameobj, useridobj, usernameobj) {
    //已选择部门记录
    var final_groupidobj = [];
    var final_groupnameobj = [];
    //已选择同事记录
    var final_useridobj = [];
    var final_usernameobj = [];
    final_groupidobj = groupidobj;
    final_groupnameobj = groupnameobj;
    final_useridobj = useridobj;
    final_usernameobj = usernameobj;
    //组合文字显示在底部
    if (final_groupidobj.length == 1) {
        btnshowCCname = final_groupnameobj;
    } else {
        if (ld.inArray('all', final_groupidobj) == -1) {//未选择“所有同事”
            btnshowCCname = '';
            if (final_groupidobj.length > 1) {
                btnshowCCname = final_groupidobj.length + '个部门';
            }
        } else {
            btnshowCCname = '所有、' + (final_groupidobj.length - 1) + '个部门';
        }
    }
    if (final_groupidobj.length >= 1 && final_useridobj.length != 0) {
        btnshowCCname += '、';
    }
    if (final_useridobj.length == 1) {
        btnshowCCname += final_usernameobj;
    } else {
        btnshowCCname += '';
        if (final_useridobj.length > 1) {
            btnshowCCname += final_useridobj.length + '个同事';
        }
    }
    ld('#wn-choosenview-footer>span').html('已选择：' + btnshowCCname);
}

//at已选择同事、部门写入到发布页面（去重）
function writeAtcontent() {
    //已选择部门记录
    var final_groupidobj = choose_groupidobj,
        final_groupnameobj = choose_groupnameobj;
    //已选择同事记录
    var final_useridobj = choose_useridobj,
        final_usernameobj = choose_usernameobj;
    if (empty(btnshowCCname)) {
        PopPromptBox.show('选择要@的范围');
        return false;
    }
    else {
        if (final_groupnameobj === '') {
            var spacer = '';
        } else {
            var spacer = ',';
        }
        var tempinfo = final_groupnameobj + spacer + final_usernameobj,//当前选择将要插入的@数据
            tempinfoArr = tempinfo.split(','),//当前要插入的@数组
            newstrname = '';
        if (!empty(ld('#' + ViewObj.rootScope.focusID).val())) {
            var infostr = ld('#' + ViewObj.rootScope.focusID).val();//原数据
            var infostrArr = infostr.replace(/\s/g, "").split('@');//原@数组
            if (infostrArr.length > 1) {
                ld.each(tempinfoArr, function (index, strname) {
                    if (strname && infostrArr.indexOf(strname) == -1) {
                        newstrname += '@' + strname + ' ';
                    }
                });
            } else {
                ld.each(tempinfoArr, function (index, strname) {
                    if (strname) {
                        newstrname += '@' + strname + ' ';
                    }
                });
            }
            ld('#' + ViewObj.rootScope.focusID).val(infostr + newstrname);//把数组组合成字符串,插入到发布页面
        } else {
            ld.each(tempinfoArr, function (index, strname) {
                if (strname) {
                    newstrname += '@' + strname + ' ';
                }
            });
            ld('#' + ViewObj.rootScope.focusID).val(newstrname);
        }
        //21857:工作>新建微博、日志、任务：@用户比较多时，内容显示不完整。初步用这种方式解决
        var focusIDValue = ld('#' + ViewObj.rootScope.focusID).val();
        var rowInt = parseInt(focusIDValue.length / 22) + 1;
        var rowHeight = '';
        if (parseInt(rowInt) <= 2) {
            rowHeight = 25;
        }
        else {
            rowHeight = rowInt * 20;
        }
        ld('#' + ViewObj.rootScope.focusID).css('height', parseInt(rowHeight));
    }
}

//删除数组指定元素
Array.prototype.ElementRemove = function (dx) {
    if (isNaN(dx) || dx > this.length) {
        return false;
    }
    this.splice(dx, 1);
};
/* 审批、反审批 start*/
//获取审批步骤
commonHandleObj.getApproveStep = function (urlstring, callback) {
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        ViewObj.rootScope.approveid = restobj.result.list1.approveid;//审批流程ID
        ViewObj.rootScope.stepid = restobj.result.list1.stepid;//审批流程—步骤ID
        ViewObj.rootScope.laststepid = restobj.result.list1.laststepid;//审批流程—上一步骤ID
        var tplnode = '',
            option_itmes = '';
        ld.each(restobj.result.list, function (key, list) {
            tplnode += '<li approvestatus="' + list.approvestatus + '">' + list.label;
            if (list.checked == 'checked') {
                GVObj.approveObj.approvestatus = list.approvestatus;
                tplnode += '<b class="r-icon lnr-circle-solid"></b>';
            } else {
                tplnode += '<b class="r-icon lnr-circle"></b>';
            }
            if (!empty(list.options)) {
                ld.each(list.options, function (key, options) {
                    if (options.selected) {
                        if (options.selected == 'yes') {
                            tplnode += '<input type="hidden" id="nextstep" name="nextstep" value="' +
                                options.stepid + '"><span class="text-ellipsis" id="optionsstepid" stepid="' +
                                options.stepid + '">' + options.stepname + '</span>';
                        }
                        option_itmes += options.stepid + '&&' + options.stepname + '|##|';
                    } else {
                        tplnode += '<input type="hidden" id="nextstep" name="nextstep" value="' +
                            options.stepid + '">';
                    }
                });
            }
            tplnode += '</li>';
            if (!empty(list.setnextuser)) {//是否有选择下一步审批人权限
                if(list.setnextuser.nextspecifyapproverid == 0){
                    tplnode += '<li class="arrow-right" ><i style="width:45%;" tag="NextapprovalUser" >下一步骤的审批人</i>';
                    tplnode += '<b class="text-ellipsis" id="nextapprovalname" style="width:48%;margin-right:1rem;">' +
                        list.setnextuser.nextsetpbyuser + '</b>';
                }
                tplnode += '<input type="hidden" value="' + list.setnextuser.nextsetpby +
                    '" name="recipient" id="nextapproval"></li>';
            }
        });
        tplnode += '<input type="hidden" id="stepid" name="stepid" value="' + ViewObj.rootScope.stepid + '">';
        ld('#approvalStepContent').html(tplnode);
        if (option_itmes) {
            ld('#optionsstepid').attr({items: option_itmes});
        }
        callback();
    });
};
//反审批方法
commonHandleObj.getCancelApprove = function (res) {
    ViewObj.rootScope.approveid = res.list2.approveid;//审批流程ID
    GVObj.approveObj.approvestatus = 0;
    // 加载反审批步骤
    var listCancelapprove = '';
    ld.each(res.list1, function (key, list) {
        if (list.canceltype == '0') {
            radio = 'lnr-circle-solid';
        } else {
            radio = 'lnr-circle';
        }
        listCancelapprove += '<li cancelapprovetype="' + list.canceltype + '">' + list.label + '<b class="r-icon ' + radio + '"></b></li>';
    });
    listCancelapprove += '<li id="newapprove" class="fontblue ui-hide">新流程：<strong></strong><i class="lnr-chevron-right"></i></li>';
    ld('#cancelApprovedCon').html(listCancelapprove);
    // 加载新的流程
    var list_items = '';
    if (!empty(res.list)) {
        ld.each(res.list, function (key, list) {
            if (key === 0) {
                GVObj.approveObj.newapproveid = list.approveid;
                ld('#newapprove>strong').html(list.approvename);
            }
            list_items += list.approveid + '&&' + list.approvename + '|##|';
        });
    } else {
        GVObj.approveObj.newapproveid = 0;
    }
    ld('#newapprove').attr('items', list_items);
    // 删除无操作效果
    ld('#head_rig').find('span').removeClass('nooperation');
};
/* 审批、反审批 end*/
//监视dom高度变化（在发布日志界面，输入内容高度变化时，增加减少高度）
(function ($, h, c) {
    var a = $([]), e = $.resize = $.extend($.resize, {}), i, k = "setTimeout", j = "resize", d = j + "-special-event", b = "delay", f = "throttleWindow";
    e[b] = 250;
    e[f] = true;
    $.event.special[j] = {
        setup: function () {
            if (!e[f] && this[k]) {
                return false
            }
            var l = $(this);
            a = a.add(l);
            $.data(this, d, {w: l.width(), h: l.height()});
            if (a.length === 1) {
                g()
            }
        }, teardown: function () {
            if (!e[f] && this[k]) {
                return false
            }
            var l = $(this);
            a = a.not(l);
            l.removeData(d);
            if (!a.length) {
                clearTimeout(i)
            }
        }, add: function (l) {
            if (!e[f] && this[k]) {
                return false
            }
            var n;

            function m(s, o, p) {
                var q = $(this), r = $.data(this, d);
                r.w = o !== c ? o : q.width();
                r.h = p !== c ? p : q.height();
                n.apply(this, arguments)
            }

            if ($.isFunction(l)) {
                n = l;
                return m
            } else {
                n = l.handler;
                l.handler = m
            }
        }
    };
    function g() {
        i = h[k](function () {
            a.each(function () {
                var n = $(this), m = n.width(), l = n.height(), o = $.data(this, d);
                if (m !== o.w || l !== o.h) {
                    n.trigger(j, [o.w = m, o.h = l])
                }
            });
            g()
        }, e[b])
    }
})(jQuery, this);
//获取列表
function getCRMList(urldata, callback) {
    var list_class = 'crm-lists';
    var urlstring = urldata + '&mode=list';
    if (ViewObj.rootScope.SearchScope != 'SmOwner_Search_Me') {
        ViewObj.rootScope.SearchScope = 'SmOwner_Search_All';
    }
    urlstring += '&SearchScope=' + ViewObj.rootScope.SearchScope;
    if (module == 'Accounts') {
        urlstring += '&pagepublicaccounttype=' + ViewObj.rootScope.accountresult;
    }
    if (module == 'ContactRecords' || module == 'VendorContactRecords' ||
        ViewObj.rootScope.approvemodule == 'ContactRecords' || ViewObj.rootScope.approvemodule == 'VendorContactRecords') {
        list_class = 'crm-lists line3';
    }
    if (module == 'Approve') {//审批中心
        ld('#header_crmList .head-rig').addClass('ui-hide');
        ld('#approvecategory').removeClass('ui-hide');
        ld('#approvecategory>.tabswitch>.curr').removeClass('curr');
        ld('#approvecategory>.tabswitch>[approvestatus=' + ViewObj.rootScope.approvetype + ']').addClass('curr');
        urlstring = 'module=Approve&action=ListView&' + urldata + '&approvestatus=' + ViewObj.rootScope.approvetype;
    }
    WordReportAjaxNew(urlstring, function (rest, callbackstatus) {        
        if (callbackstatus == 'success') {
            try {
                if (empty(rest)) return false;
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                //计算多少行
                if (!empty(restobj.result.list1)) {
                    if(restobj.result.list1[0].title){
                        var i = 1;
                        ld.each(restobj.result.list1[0].field, function (listfieldkey, listfieldinfo) {
                            i++;
                        });
                        list_class = 'crm-lists line'+i;
                    }
                }
                var listhtml = '<ul class="' + list_class + '">';
                if (module != 'Approve') {
                    ViewObj.rootScope.listsearchstr = restobj.result.str;
                    // 搜索框显示
                    ListSearchBox.display({
                        parent_id: 'divSearch',
                        tip_text: restobj.result.str,
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
                }
                if (empty(restobj.result.list1)) {
                    if (module != 'Approve') {
                        listhtml = logicHanderObj.NoinfoNotice(restobj.result.list2.moduletitle);
                    }
                    else{
                        listhtml = logicHanderObj.NoinfoNotice('数据');    
                    }                    
                }
                //头部数据分类
                if (module != 'Approve') {
                    var categoryhtml = '';
                    ld.each(restobj.result.list, function (key, list) {
                        //如果后期在分类后添加数字，直接在li里加入“<i>(88)</i>”
                        categoryhtml += '<li name="' + list.viewname + '" title="' + list.title + '">' + list.title + '</li>';
                    });
                    ld('#pulldown_menulists').html(categoryhtml);
                    createpermit = restobj.result.list2.createpermit;//是否有创建权限，yes:有
                    if (createpermit == 'yes') {
                        ld('#header_crmList>.head-rig').removeClass('ui-hide');
                    }
                    else {
                        ld('#header_crmList>.head-rig').addClass('ui-hide');
                    }
                }
                ld('#tplCreatemenu [tag=createordinary],#tplCreatemenu [tag=createnotallocated],#tplCreatemenu [tag=createallocated]').addClass('ui-hide');
                ld('#tplCreatemenu [tag=create]').removeClass('ui-hide');
                //声明创建权限变量
                if (module != 'Approve') {
                    ViewObj.rootScope.createpermit = restobj.result.list2.createpermit;
                    ViewObj.rootScope.quickcreate = restobj.result.list2.quickcreate;
                }
                //客户是否启用公海,先把页签隐藏
                if (module == 'Accounts') {
                    if (restobj.result.list2.publicstatus == 0) {//启用公海
                        ViewObj.rootScope.publicstatus = 'yes';
                        var tabhtml = '';
                        ld.each(restobj.result.listtab, function (key, list) {
                            if (list.accountresultStr == ViewObj.rootScope.accountresult) {
                                tabhtml += '<a class="curr" accountresult="' + list.accountresultStr + '">' + list.value + '</a>';
                            }
                            else {
                                tabhtml += '<a class="" accountresult="' + list.accountresultStr + '">' + list.value + '</a>';
                            }
                        });
                        if (restobj.result.listtab.length == 2) {
                            ld('#divTab').html('<div class="tabswitch switch-two">' + tabhtml + '</div>');
                        }
                        else {
                            ld('#divTab').html('<div class="tabswitch switch-three">' + tabhtml + '</div>');
                        }
                        ld('#divTab').removeClass('ui-hide');
                        var createtype = restobj.result.list2.createtype;
                        if (createtype == 0) {
                            ld('#tplCreatemenu>.btnsub').removeClass('ui-hide');
                        }
                        else if (createtype == 1) {
                            ld('#tplCreatemenu>[tag=createordinary]').removeClass('ui-hide');
                        }
                        else if (createtype == 2) {
                            ld('#tplCreatemenu>[tag=createnotallocated]').removeClass('ui-hide');
                        }
                        else if (createtype == 3) {
                            ld('#tplCreatemenu>[tag=createallocated]').removeClass('ui-hide');
                        }
                    }
                    else {//未启用公海
                        ViewObj.rootScope.publicstatus = 'no';
                        ld('#tplCreatemenu>[tag=createordinary]').removeClass('ui-hide');
                    }
                    ld('#tplCreatemenu>[tag=create]').addClass('ui-hide');
                    ViewObj.rootScope.createtype = restobj.result.list2.createtype;//客户创建类别
                }
                if (ViewObj.rootScope.quickcreate === 'yes') {
                    ld('#tplCreatemenu>[tag=quickcreate]').removeClass('ui-hide');
                }
                else {
                    ld('#tplCreatemenu>[tag=quickcreate]').addClass('ui-hide');
                }
                ViewObj.rootScope.camcard = -5;
                if ((module == 'Accounts' || module == 'Contacts' || module == 'Vendors' || module == 'VendorContact')
                    && restobj.result.list2.camcard != undefined) {
                    ViewObj.rootScope.camcard = restobj.result.list2.camcard;
                }
                if (ViewObj.rootScope.camcard > 0) {
                    ld('#tplCreatemenu>[tag=cardcreate]').removeClass('ui-hide');
                    ld('#tplCreatemenu>[tag=choosecardcreate]').addClass('ui-hide');
                }
                else {
                    ld('#tplCreatemenu>[tag=cardcreate]').addClass('ui-hide');
                    ld('#tplCreatemenu>[tag=choosecardcreate]').addClass('ui-hide');
                }
                SwiperObj.ListPageObj.setListPageIndex(restobj.result.curpagenum, ViewObj.getInfo('to_viewid'));
                SwiperObj.ListPageObj.setHasNextPage(restobj.result.havenextpage, ViewObj.getInfo('to_viewid'));
                if(module == 'Approve'){
                    listhtml += getlistData(restobj.result.list1, ViewObj.rootScope.approvemodule);//输出列表
                }
                else{
                    listhtml += getlistData(restobj.result.list1, module);//输出列表
                }

                listhtml += '</ul>';
                if (SwiperObj.is_addMore) {//如果是加载就 不清空原来的内容
                    ld('#crm-list-view .pubDetialC').html(ld('#crm-list-view .pubDetialC').html() + listhtml);
                } else {//搜索和 刷新都要清空原来的内容
                    ld('#crm-list-view .pubDetialC').html(listhtml);
                }
                callback();
            }
            catch (e) {  
                //logicHanderObj.errorNotice();
            }
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

//明细界面
function getCRMDetailView(view_name, urlstring, callback) {
    // 销毁之前定义的 Swiper 对象
    if (SwiperObj.isDestroyable(SwiperObj.WorkRelation_swiper)) {
        try {
            SwiperObj.WorkRelation_swiper.destroy(true, true);
        } catch (e) {
        }
    }
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest),
            res = restobj.result,
            res_list2 = res.list2,
            is_related_module = '';
        if (restobj.code != -1) {
            ld('#divCoordination,#detailbox,#divApproveLog,#divComment').html('');//清空内容
        } else {
            PopPromptBox.show(restobj.msg);
            ld('#crm-detail-footer').attr('editable', 'false').addClass('ui-hide');
            ld("#status").hide();
            return;
        }
        var detailboxhtml = '<div id="divRelatedList" class="ui-hide"></div>' +
            '<div id="divDetailLabel" class="tabswitch ui-hide"></div>' +
            '<div id="divCoordination" class="ui-hide"></div>' +
            '<div id="detailbox" class="ui-hide"></div>' +
            '<div id="divApproveLog" class="ui-hide"></div>' +
            '<div id="divComment" class="ui-hide"></div>';
        ld('#cwn-crmdetail-view').html(detailboxhtml);
        try {
            ld('#tplDetailOperation>.btnsub').addClass('ui-hide');
            //是否有编辑权限(yes:有)
            editpermit = res_list2.editpermit;
            if (editpermit == 'yes' && view_name != 'nearbyaccounts' && view_name != 'nearbyaccountssearch') {
                ld('#crm-detail-footer').attr('editable', 'true');
            } else {
                ld('#crm-detail-footer').attr('editable', 'false');
            }
            //是否有分配权限(yes:有)
            distributionpermit = res_list2.distributionpermit;
            if (distributionpermit == 'yes') {
                ld('#tplDetailOperation>[tag=btn_distribution]').removeClass('ui-hide');
            }
            //是否有公海分配权限(yes:有)
            allocateaccountpermit = res_list2.allocateaccount;
            if (allocateaccountpermit == 'yes') {
                ld('#tplDetailOperation>[tag=btn_allocateaccount]').removeClass('ui-hide');
            }
            //是否有领取权限(yes:有)
            receivepermit = res_list2.receivepermit;
            if (receivepermit == 'yes') {
                ld('#tplDetailOperation>[tag=btn_receive]').removeClass('ui-hide');
            }
            //是否有共享权限(yes:有)
            sharepermit = res_list2.sharepermit;
            if (sharepermit == 'yes') {
                ld('#tplDetailOperation>[tag=btn_share]').removeClass('ui-hide');
            }
            //是否有推进权限(yes:有)
            advancepermit = res_list2.advancepermit;
            if (advancepermit == 'yes') {
                ld('#tplDetailOperation>[tag=btn_advance]').removeClass('ui-hide');
            }
            //是否有提交审批按钮权限,yes:有
            submitapprove = res_list2.submitapprove;
            if (submitapprove == 'yes') {
                ld('#tplDetailOperation>[tag=btn_submitapprove]').removeClass('ui-hide');
            }
            //是否有审批按钮权限,yes:有
            approvepermit = res_list2.approvepermit;
            if (approvepermit == 'yes') {
                ld('#tplDetailOperation>[tag=btn_submit]').removeClass('ui-hide');
            }
            //是否有反审批按钮权限，yes:有
            cancelapprove = res_list2.cancelapprove;
            if (cancelapprove == 'yes') {
                ld('#tplDetailOperation>[tag=btn_cancelapprove]').removeClass('ui-hide');
            }
            //是否有删除权限(yes:有)
            delpermit = res_list2.delpermit;
            if (delpermit == 'yes') {
                ld('#tplDetailOperation>[tag=btn_del]').removeClass('ui-hide');
            }
            //客户-公海已分配
            if (module === 'Accounts'){
                ViewObj.rootScope.completedpermit = res_list2.completedpermit;//是否显示达成图标
            }
            if (res.list3) {
                ViewObj.rootScope.entitynamevlaue = res.list3.A;//entityname值
            }
            //如果是审批模块
            if (module == 'Approve') {
                is_related_module = res_list2.module;
            } else {
                is_related_module = module;
            }
            if (res_list2.morepermit == 'no') {//更多按钮是否有操作
                ld('#header_detail>.head-rig').html('');
            }
            //相关信息
            if (res.list1 != '' && res.list1 != null) {
                var divRelatedListhtml = '<div class="relatedlistwrap ui-hide"><div class="swiper-container relation-crm"><div class="swiper-wrapper">',
                    _item_num = 0,//相关信息，个数
                    _max_textlen = 0;//根据 文字 字数 确定 每行显示几项
                //show_rel_list(this,关联模块module,关联模块,本单据module,本单据id,关联模块关联id)
                ld.each(res.list1, function (key, list) {
                    divRelatedListhtml += '<div class="swiper-slide" id="rellist_' +
                        list.related_id + '" relamodule="' + list.label + '" moudle="' +
                        list.module + '" label="' + list.label + '" is_related="' +
                        is_related_module + '" record="' + res.list2.record + '" relatedid="' +
                        list.related_id + '"  ><i>' + list.nums +
                        '</i><span>' + list.label + '</span></div>';
                    //获取最大 文字长度
                    var textlen = list.label.toString().length;
                    _max_textlen = _max_textlen > textlen ? _max_textlen : textlen;
                    _item_num++;
                });
                divRelatedListhtml += '</div></div></div>';
                ld('#divRelatedList').html(divRelatedListhtml).css({'height': '48px', 'overflow': 'hidden', 'backgroundColor': '#fff'}).removeClass('ui-hide');
                ViewObj.rootScope.item_num = _item_num;
                ViewObj.rootScope.max_textlen = _max_textlen;
            }
            else{
                ViewObj.rootScope.item_num = 0;
                ViewObj.rootScope.max_textlen = 0;
            }
            //明细界面标签
            var detailLabelhtml = '';
            if ((module == 'Accounts' ||
                module == 'NearbyAccounts' ||
                module == 'Contacts' ||
                (module == 'Approve' && (approvemodule == 'Accounts' ||
                approvemodule == 'Contacts'))) &&
                res_list2.workreport === 'yes') {//客户、联系人 有工作协同
                detailLabelhtml += '<a choosename="coordination">工作协同</a>';
            }
            detailLabelhtml += '<a choosename="detailView" class="curr">详细资料</a>';
            ViewObj.rootScope.openapprove = res_list2.openapprove;//是否启用审批历史,yes:启用
            if (ViewObj.rootScope.openapprove == 'yes') {
                detailLabelhtml += '<a choosename="divApprove">审批历史</a>';
            }
            ViewObj.rootScope.opencomments = res_list2.opencomments;//是否启用评论,yes:启用
            if (ViewObj.rootScope.opencomments == 'yes') {
                detailLabelhtml += '<a choosename="divComment">评&nbsp;&nbsp;论&nbsp;</a>';
            }
            ld('#divDetailLabel').html(detailLabelhtml).removeClass('ui-hide').addClass(res.list2.detailLabelClass); //页签宽度
            ld('#detailbox').removeClass('ui-hide');//显示详细资料和评论标签
            var tplnode = '';
            //客户-公海已分配
            if (module === 'Accounts'){
                tplnode += '<div id="divReachDetailView" class="ui-hide" style="position:absolute;z-index:650;right:30%;padding-top: 7px;">' + 
                                '<img src="images/reach.png">' + 
                           '</div>';
            }
            //客户和联系人关联字段
            if (res.list4) {
                var accountAndcontactHtml = '<h2 class="c-detail-h2">' + res.list4.blocklabel + '<i class="lnr-chevron-down"></i></h2><ul class="c-ul c-detail-cell">',
                    text = '';
                ld.each(res.list4.fieldinfo, function (key, list) {
                    if (Tools.escape2Html(list.text) == '') {
                        text = '<b>未填写</b>';
                    } else {
                        text = Tools.escape2Html(list.text);
                    }
                    accountAndcontactHtml += '<li><i>' + list.fieldlabel +
                        '</i><span>' + text + '</span></li>';
                });
                accountAndcontactHtml += '</ul>';
                if (res.list4.display_position == 0) {
                    tplnode += accountAndcontactHtml;
                }
            }
            ld.each(res.list, function (key, list) {
                if (empty(list)) return false;
                if (list.display_status === '0') {
                    tplnode += '<h2 class="c-detail-h2">' + list.blocklabel + '<i class="lnr-chevron-up"></i></h2>';
                    tplnode += '<ul class="c-ul c-detail-cell ui-hide">';
                }
                else {
                    tplnode += '<h2 class="c-detail-h2">' + list.blocklabel + '<i class="lnr-chevron-down"></i></h2>';
                    tplnode += '<ul class="c-ul c-detail-cell">';
                }
                ld.each(list.fieldinfo, function (fieldkey, fieldinfo) {
                    //记录客户ID
                    if (module === 'Accounts' || module === 'NearbyAccounts' || module === 'ServiceCharge') {
                        ViewObj.rootScope.account_id = res_list2.record;
                    }
                    else if (fieldinfo.fieldname === 'account_id') {
                        ViewObj.rootScope.account_id = fieldinfo.hiddenvalue;
                    }
                    //记录供应商ID
                    if (module === 'Vendors') {
                        ViewObj.rootScope.vendor_id = res_list2.record;
                    }
                    else if (fieldinfo.fieldname === 'vendor_id') {
                        ViewObj.rootScope.vendor_id = fieldinfo.hiddenvalue;
                    }
                    if (!fieldinfo.text) {
                        fieldinfo.text = '';
                    }
                    //客户，联系人是电话类型字段的显示电话图标
                    var phone = '';
                    if (fieldinfo.phone == 'yes' && fieldinfo.text != '<b>未填写</b>') {
                        var phonemobile = Tools.escape2Html(fieldinfo.text);
                        var phonemobiletext = phonemobile;
                        if (fieldinfo.phonetext != undefined) {
                            phonemobiletext = Tools.escape2Html(fieldinfo.phonetext);
                        }
                        if (phoneversion == 'ios') {
                            callhtml = 'href="tel:' + phonemobiletext + '"';
                        } else {
                            callhtml = "onclick=androidObj.callPhone('" + phonemobiletext + "');";
                        }
                        phone = '<a ' + callhtml + ' class="lnr-phone-handset">&nbsp;&nbsp;</a>';
                    }
                    //根据不同类型显示不同信息
                    if (fieldinfo.uitype == '19') {//区域
                        if ((module == 'Accounts' || module == 'NearbyAccounts') && fieldinfo.fieldname == 'bill_street' && fieldinfo.text != '<b>未填写</b>') {
                            tplnode += '<li class="heightauto"><i>' + fieldinfo.fieldlabel + '</i>';
                            tplnode += '<div><i class="lnr-location" tag="sign_address"></i>' + Tools.escape2Html(fieldinfo.text) + '</div>';
                        }
                        else {
                            tplnode += '<li class="heightauto"><i>' + fieldinfo.fieldlabel + '</i><div>' + Tools.escape2Html(fieldinfo.text) + '</div>';
                        }
                    } else if (fieldinfo.uitype == '69') {//照片
                        tplnode += '<li><i>' + fieldinfo.fieldlabel +
                            '</i><div class="view picture-rang picture-preview">';
                        if (!fieldinfo.text) {
                            tplnode += '<div img-detail ><img img_num="1" src="images/defaultuser.png" onload="logicHanderObj.loadimg(this)"/> </div>';
                        } else {
                            ld.each(fieldinfo.options, function (imgkey, imgvalue) {
                                tplnode += '<div img-detail ><img img_num=' + (imgkey + 1) + ' src="http://' + loginurl + '/' + imgvalue.value + '" onload="logicHanderObj.loadimg(this)"/> </div>';
                            });
                        }
                        tplnode += '</div>';
                    }
                    else if (fieldinfo.uitype == '83') {//产品税别
                        tplnode += '<li><i>' + fieldinfo.fieldlabel + '</i><span>';
                        if (res.tax_info) {
                            ld.each(res.tax_info, function (taxkey, taxinfo) {
                                tplnode += taxinfo.taxlabel + ' : ' + taxinfo.percentage + ';';
                            });
                        } else {
                            tplnode += Tools.escape2Html(fieldinfo.text);
                        }
                        tplnode += '</span>';
                    }
                    else if (fieldinfo.uitype == '1108' || fieldinfo.uitype == '1109') {//附件
                        tplnode += '<li><i>' + fieldinfo.fieldlabel +'</i><span>';
                        if(fieldinfo.text != '<b>未填写</b>'){
                            tplnode +=  '<ul class="attUl">';
                            ld.each(fieldinfo.text, function (attkey, attvalue) {
                                var img = Tools.getAttImg(attvalue.name),
                                    imgStr = 'images/' + img + '.png';
                                if(img == 'img'){
                                    imgStr = 'http://' + loginurl + '/' + attvalue.path + attvalue.name;
                                }
                                tplnode +=  '<li>' + 
                                                '<div class="item-content" att_id="' + attvalue.id + '">' + 
                                                    '<div class="media-list">' + 
                                                    '    <img style="width:36px;height:36px;border-radius:.3rem;" src="' + imgStr + '">' + 
                                                    '</div>' + 
                                                    '<div class="item-inner">' + 
                                                    '    <div class="item-title">' + attvalue.name + '</div>' + 
                                                    '    <div class="item-path ui-hide">' + attvalue.path + '</div>' + 
                                                    '    <div class="item-text">' + attvalue.size + '</div>' + 
                                                    '</div>' + 
                                                '</div>' + 
                                            '</li>';
                            });
                            tplnode +=  '</ul>';
                        }
                        else{
                            tplnode += '尚无附件';
                        }
                        tplnode += '</span>';
                    }
                    else if (module === 'Potentials' &&
                        (fieldinfo.fieldname == 'sales_stage' || fieldinfo.fieldname == 'lastsales_stage')) {
                        tplnode += '<li><i>' + fieldinfo.fieldlabel +
                            '</i><span id="' + fieldinfo.fieldname + '_advance">' + Tools.escape2Html(fieldinfo.text) + '</span>';
                    }
                    else if (module === 'Accounts' && fieldinfo.fieldname == 'bill_street') {
                        tplnode += '<li><i>' + fieldinfo.fieldlabel + '</i><span>' + Tools.escape2Html(fieldinfo.text) + '</span>';
                    }
                    else {
                        tplnode += '<li><i>' + fieldinfo.fieldlabel + '</i><span>' + Tools.escape2Html(fieldinfo.text) + phone + '</span>';
                    }
                    tplnode += '</li>';
                });
                tplnode += '</ul>';
            });
            //客户和联系人关联字段
            if (res.list4) {
                if (res.list4.display_position == 1) {
                    tplnode += accountAndcontactHtml;
                }
            }
            if(!res.entry){
                //合同订单，报价单，服务合同,采购订单
                var res_pdct = res.listproduct;
                if (res_pdct && res_pdct.total.count > 0) {
                    ViewObj.rootScope.sys_49 = restobj.result.list2.sys_49;
                    ViewObj.rootScope.sys_93 = restobj.result.list2.sys_93;
                    rowcnt = res_pdct.total.count; // 全局变量赋值
                    productcount = rowcnt;   // 全局变量赋值
                    var currency_name = res_pdct.currency_name,
                        producttotal = res_pdct.total.hdnGrandTotal;
                    tplnode += '<h2 class="c-detail-h2">产品清单<b class="pricetype">' + currency_name + '</b></h2>' +
                        '<ul class="c-ul c-other-cell detail" id="productbill">';
                    var productModule = module;
                    ld.each(res_pdct.list, function (key, list) {
                        if (empty(list)) return false;
                        var taxpriceStr = Tools.Number.toDecimal(list.taxprice, parseInt(ViewObj.rootScope.sys_93));
                        var quantityStr = Tools.Number.toDecimal(list.quantity, parseInt(ViewObj.rootScope.sys_49));
                        if (module === 'Approve') {
                            productModule = approvemodule;
                        }
                        tplnode += '<li tag=' + list.productid + ' module=' + productModule + ' sequence_no=' + list.sequence_no + '><p><i class="text-ellipsis">' + list.productname + '</i></p><p><span>' + list.productshowfieldslabel + '</span></p></li>';
                    });
                    tplnode += '</ul>';
                    //整单折扣信息
                    var discount_type = res_pdct.total.discount_type,      //整单折扣类型
                        discount_percent = res_pdct.total.discount_percent,//折扣百分比
                        txtAdjustment = res_pdct.total.txtAdjustment,//调整价格
                        hdnDiscountAmount = res_pdct.total.hdnDiscountAmount,//直接降价
                        _viewDiscountVal = '',
                        _viewDiscountDetialVal = '',
                        _viewAdjustmentVal = '',
                        _viewAdjustmentDetialVal = '';
                    if (discount_percent == null) {
                        discount_percent = '0.00';
                    }
                    if (txtAdjustment == null) {
                        txtAdjustment = '0.00';
                    }
                    if (hdnDiscountAmount == null) {
                        hdnDiscountAmount = '0.00';
                    }
                    if (txtAdjustment < 0) {
                        _viewAdjustmentVal = '减少';
                        _viewAdjustmentDetialVal = Math.abs(txtAdjustment);
                    }
                    else {
                        _viewAdjustmentVal = '增加';
                        _viewAdjustmentDetialVal = txtAdjustment;
                    }
                    if (discount_type == 0) {
                        _viewDiscountVal = '直接降价';
                        _viewDiscountDetialVal = hdnDiscountAmount;
                    } else {
                        _viewDiscountVal = '百分比降价';
                        _viewDiscountDetialVal = discount_percent;
                    }
                    if (res.listproductfield != null) {
                        tplnode += '<ul class="c-ul c-other-total detail">';
                        tplnode += '<li><span>数量小计</span><span>' + Tools.Number.toDecimal(res_pdct.total.allquantity, parseInt(ViewObj.rootScope.sys_49)) + '</span></li>';
                        if (res_pdct.total.hdnSubTotal != undefined) {
                            tplnode += '<li><span>金额小计</span><span>' + Tools.Number.toDecimal(res_pdct.total.hdnSubTotal, 2) + '</span></li>';
                        }
                        ld.each(res.listproductfield, function (keylist, list) {
                            if (list.newline == 1) {
                                if (list.uitype == '35') {
                                    tplnode += '<li><span>调整</span><b id="viewAdjustment">' + _viewAdjustmentVal +
                                        '</b><span id="viewAdjustmentDetial">' + Tools.Number.toDecimal(_viewAdjustmentDetialVal, 2) +
                                        '</span></li>';
                                }
                                if (list.uitype == '37') {
                                    tplnode += '<li><span>整单折扣</span><b id="viewDiscount">' + _viewDiscountVal +
                                        '</b><span id="viewDiscountDetial">' + Tools.Number.toDecimal(_viewDiscountDetialVal, 2) +
                                        '</span></li>';
                                }
                            }
                        });
                        tplnode += '<li><span>总金额</span><span style="color: #ff8000 !important;">' + logicHanderObj.fmoney(producttotal) + '</span></li>';
                        tplnode += '</ul>';
                    }
                }
                //费用清单
                if (res.listexpense && res.listexpense.count > 0) {
                    ViewObj.rootScope.sys_49 = restobj.result.list2.sys_49;
                    ViewObj.rootScope.sys_93 = restobj.result.list2.sys_93;
                    var expensecount = res.listexpense.count,
                        expenseblocklabel = res.listexpense.blocklabel;
                    tplnode += '<h2 class="c-detail-h2">' + expenseblocklabel + '</h2><ul class="c-ul c-other-cell detail">';
                    ld.each(res.listexpense.list, function (key, list) {
                        if (empty(list)) return false;
                        var rmb_totalStr = Tools.Number.toDecimal(list.rmb_total, parseInt(2));
                        tplnode += '<li><p><i class="text-ellipsis">' + list.expenseuse + '</i></p><p>' + list.expensetype + '<span>' + rmb_totalStr + '</span></p></li>';
                    });
                    tplnode += '</ul>';
                    tplnode += '<ul class="c-ul c-other-total detail">';
                    tplnode += '<li><span>总金额</span><span style="color: #ff8000 !important;">'+ res.listexpense.total.total +'</span></li>';
                    tplnode += '</ul>';
                }
            }
            else{
                var entry_blocklabel = res.entry.blocklabel,
                    entry_listinfo = res.entry.list,
                    entry_total = res.entry.p_total,
                    d_module = module;
                tplnode += '<h2 class="c-detail-h2">' + entry_blocklabel;
                if(d_module == 'Approve'){
                    d_module = ViewObj.rootScope.approvemodule;
                }
                if(d_module == 'Quotes' || d_module == 'SalesOrder' || d_module == 'ServiceContracts'){
                    tplnode += '<b class="pricetype">' + res.currency.current.currency_name + '</b>';
                }
                tplnode += '</h2>';
                tplnode += '<ul class="c-ul c-other-cell detailnew" id="productbillnew" >';
                ld.each(entry_listinfo, function (key, list) {
                    if (empty(list)) return false;
                    var entry_class = '';
                    if(list.item4){
                        entry_class = 'entrytypeclass';
                    }
                    var productModule = module;
                    if (module === 'Approve') {
                        productModule = approvemodule;
                    }
                    tplnode +=  '<li class="' + entry_class + '" entryid="' + list.entryid + '" entrytype="' + list.entrytype + '" module="' + productModule + '" sequence_no="' + list.sequence_no + '" >' + 
                                    '<p><i class="text-ellipsis">' + list.item1 + '</i></p>';
                                    if(list.item3){
                    tplnode +=          '<p>' + list.item3 + '<span>' + list.item2 + '</span></p>';
                                    }
                                    else{
                    tplnode +=          '<p><span>' + list.item2 + '</span></p>';
                                    }
                                    if(list.item4){
                    tplnode +=          '<p><span>' + list.item4 + '</span></p>';    
                                    }
                    tplnode +=  '</li>';
                });
                tplnode += '</ul>';
                tplnode += '<ul class="c-ul c-other-total detail">';
                ld.each(entry_total, function (key, list) {
                    tplnode +=  '<li><span>' + list.label + '</span><span>' + list.value +'</span></li>';
                });
                tplnode += '</ul>';
            }
            ld('#detailbox').html(tplnode);
            callback();
        }
        catch (e) {
            logicHanderObj.errorNotice();
            ld('#crm-detail-footer').attr('editable', 'false').addClass('ui-hide');
        }
    });
}

//创建、编辑界面
function getCRMCreateEditView(mode, create_status, urlstring, callback) {
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        //判断是创建、编辑、关联创建
        var cemoduleName = '';
        if (create_status === 'relationcreate') {//关联创建
            cemoduleName = newmodule;
        }
        else {//创建、编辑
            cemoduleName = module;
        }
        if(cemoduleName == 'Approve'){
            cemoduleName = ViewObj.rootScope.approvemodule;
        }
        var tplnode = '<div>';
        ld.each(restobj.result.list, function (key, list) {
            if (empty(list)) return false;
            ViewObj.rootScope.moduletitle = restobj.result.module.moduletitle;
            tplnode += '<h2 class="c-detail-h2">' + list.blocklabel + '</h2>';
            tplnode += '<ul class="c-ul c-edit-cell">';
            ld.each(list.fieldinfo, function (key, fieldinfo) {
                if (fieldinfo.text == "undefined" || fieldinfo.text == null) fieldinfo.text = '';
                if (fieldinfo.hiddenvalue == undefined || fieldinfo.hiddenvalue == null) fieldinfo.hiddenvalue = '';
                //必录项加*,必录字段组合
                var isornotEmpty = fieldinfo.typeofdata;
                var typeArr = isornotEmpty.split("~");
                var starStr = '';
                if (typeArr[1] == "M") {
                    if(cemoduleName == 'Potentials' && fieldinfo.fieldname == 'sales_stage' && mode == 'edit'){
                        checkEmptyStr += fieldinfo.fieldname + ',' + fieldinfo.fieldlabel + ',val&&&&&';
                    }
                    else{
                        if (ld.inArray(fieldinfo.uitype, selectArray) >= 0) {
                            checkEmptyStr += fieldinfo.fieldname + ',' + fieldinfo.fieldlabel + ',html&&&&&';
                        }
                        else {
                            checkEmptyStr += fieldinfo.fieldname + ',' + fieldinfo.fieldlabel + ',val&&&&&';
                        }
                    }
                    if(cemoduleName == 'Potentials' && fieldinfo.fieldname == 'sales_stage' && mode == 'edit'){
                        starStr = '';
                    }
                    else{
                        starStr = '<strong>*</strong>';    
                    }                    
                }
                //不能重复组合
                if (fieldinfo.fieldonly == 1) {
                    if (ld.inArray(fieldinfo.uitype, selectArray) >= 0) {
                        fieldonlyStr += fieldinfo.fieldname + ',' + fieldinfo.fieldlabel + ',html&&&&&';
                    }
                    else {
                        fieldonlyStr += fieldinfo.fieldname + ',' + fieldinfo.fieldlabel + ',val&&&&&';
                    }
                }
                //uitype 71、72 为金额字段
                if (fieldinfo.uitype == '71' || fieldinfo.uitype == '72') {
                    priceFieldName[priceFieldNameNum] = fieldinfo.fieldname;
                    priceFieldNameNum++;
                }
                //uitype 13 为Email字段
                if (fieldinfo.uitype == '13') {
                    emailFieldNameArray[emailFieldNameArrayNum] = new Array();
                    emailFieldNameArray[emailFieldNameArrayNum]['fieldlabel'] = fieldinfo.fieldlabel;
                    emailFieldNameArray[emailFieldNameArrayNum]['fieldname'] = fieldinfo.fieldname;
                    emailFieldNameArrayNum++;
                }
                //把单据所有字段信息都列出来
                if (fieldinfo.uitype == '33') {//uitype 33 为多选框字段
                    billfieldStr += fieldinfo.fieldname + ',' + fieldinfo.fieldlabel + ',selectmore&&&&&';
                }
                else if (fieldinfo.uitype == '56') {//uitype 56 为复选框字段
                    billfieldStr += fieldinfo.fieldname + ',' + fieldinfo.fieldlabel + ',checkbox&&&&&';
                }
                else {
                    if(cemoduleName == 'Potentials' && fieldinfo.fieldname == 'sales_stage' && mode == 'edit'){
                        billfieldStr += fieldinfo.fieldname + ',' + fieldinfo.fieldlabel + ',val&&&&&';
                    }
                    else{
                        if (ld.inArray(fieldinfo.uitype, selectArray) >= 0) {
                            billfieldStr += fieldinfo.fieldname + ',' + fieldinfo.fieldlabel + ',html&&&&&';
                        }
                        else {
                            billfieldStr += fieldinfo.fieldname + ',' + fieldinfo.fieldlabel + ',val&&&&&';
                        }
                    }
                }

                if (mode === 'edit' && fieldinfo.displaytype == 2 && fieldinfo.uitype != 4 && fieldinfo.uitype != 15) {
                    tplnode += '<li class="ui-hide"><i>' + starStr + fieldinfo.fieldlabel + '</i>';
                }
                else {
                    if (ld.inArray(fieldinfo.uitype, chooseModuleArray) >= 0 || ld.inArray(fieldinfo.uitype, selectArray) >= 0) {//下拉、多选、模块选择
                        if (mode === 'edit' && fieldinfo.uitype == '53') {//负责人
                            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
                        }
                        else if (mode === 'edit' && fieldinfo.fieldname == 'sales_stage') {//销售阶段
                            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
                        }
                        else {
                            tplnode += '<li class="arrow-right"><i>' + starStr + fieldinfo.fieldlabel + '</i><span class="lnr-chevron-right"></span>';
                        }
                    }
                    else if (fieldinfo.uitype == '19' || fieldinfo.uitype == '21' || fieldinfo.uitype == '230' || 
                             fieldinfo.uitype == '1108' || fieldinfo.uitype == '1109') {//区域
                        tplnode += '<li class="heightauto"><i>' + starStr + fieldinfo.fieldlabel + '</i>';
                    }
                    else if (fieldinfo.uitype == '69') {//图片
                        tplnode += '<li class="imglichoose"><i>' + starStr + fieldinfo.fieldlabel + '</i>';
                    }
                    else {
                        tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
                    }
                }

                //根据不同类型显示不同信息
                var inputtext = '';
                if (mode === 'edit' && fieldinfo.uitype != '1108' && fieldinfo.uitype != '1109') {
                    inputtext = Tools.escape2Html(fieldinfo.text);
                    inputtext = Tools.delHtmlTag(inputtext);
                }
                else {
                    inputtext = fieldinfo.hiddenvalue;
                }
                if (fieldinfo.displaytype == '2') {//只可查看，不可编辑
                    var readonlyStr = 'readonly';
                    if (fieldinfo.uitype == '4' && fieldinfo.isallow == '1') {//编号
                        readonlyStr = '';
                    }                    
                    tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" type="text" value="' + inputtext + '" ' + readonlyStr + ' />';                    
                }
                else {
                    if (fieldinfo.uitype == '2' && fieldinfo.fieldname === 'accountname') {//客户查重功能
                        tplnode += '<a class="btn-opt" href="javascript:void(0);" tag="check_repeat">查重</a>';
                        tplnode += '<input style="width:32%;" id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" type="text" value="' + inputtext + '" />';
                    }
                    else if (fieldinfo.uitype == '83'&&restobj.result.tax_info!=undefined&&restobj.result.tax_info!='') {//产品税别
                        tplnode += getPorductTaxInfo(restobj.result.tax_info);
                    }
                    else if (fieldinfo.uitype == '11' || fieldinfo.uitype == '1101' || fieldinfo.uitype == '1102' || fieldinfo.uitype == '1103') {//电话
                        tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" type="tel" value="' + inputtext + '" />';
                    }
                    else if (fieldinfo.uitype == '7') {//数字
                        tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" type="number" value="' + inputtext + '" />';
                    }
                    else if (fieldinfo.uitype == '71' || fieldinfo.uitype == '72') {//金额
                        tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" type="number" value="' + Tools.Number.toDecimal(inputtext, 2) + '" />';
                    }
                    else if (fieldinfo.uitype == '19' || fieldinfo.uitype == '21' || fieldinfo.uitype == '230') {//区域
                        tplnode += '<textarea id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '">' + inputtext + '</textarea>';
                    }
                    else if (ld.inArray(fieldinfo.uitype, selectArray) >= 0) {//下拉框选择 单选、多选;货币选择、账户;复选框
                        var _selectmod = '',
                            listitems = '',
                            _selectedval = '',
                            _multi_selectedval = '',
                            _showsearch = 'true';
                        if (fieldinfo.uitype == '33') {  //多选框
                            _selectmod = 'multi';
                        } else {  //单选框
                            _selectmod = 'single';
                        }
                        if (fieldinfo.uitype == '56') {
                            listitems = '&&|##|是&&是|##|否&&否|##|';
                            _selectedval = fieldinfo.text;//保存默认值
                            _showsearch = 'false';
                        }
                        else{
                            if (fieldinfo.options != null) {
                                ld.each(fieldinfo.options, function (key, options) {//构建数据
                                    listitems += options.value + '&&' + options.text + '|##|';
                                    if (fieldinfo.uitype == '33') {//多选框
                                        _selectedval = fieldinfo.text;
                                        _selectedval = _selectedval.replace(" |##| ", ",");
                                        _multi_selectedval = fieldinfo.text;
                                    }
                                    else {
                                        if (options.value == fieldinfo.hiddenvalue) {
                                            _selectedval = options.text;//保存默认值
                                        }
                                    }
                                });
                                if (fieldinfo.options.length <= 8) _showsearch = 'false';
                            }
                        }
                        var ddltitle = fieldinfo.fieldlabel;
                        if (ddltitle.indexOf(' ') >= 0) {   //去掉字段名空格
                            ddltitle = ddltitle.split(' ')[0];
                        }
                        if (fieldinfo.uitype != '33') {
                            if (fieldinfo.uitype == '117') {//货币类型
                                var currency_idVal = 1;
                                if (mode === 'edit') {
                                    currency_idVal = fieldinfo.hiddenvalue;
                                }
                                else {
                                    _selectedval = '人民币';
                                }
                                tplnode += '<input id="hidden_currency_id" type="hidden" name="hidden_currency_id" value="' + currency_idVal + '">';
                                tplnode += '<b class="text-ellipsis" id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" popu_select="drop_down_list" ' +
                                    'title_str="' + ddltitle + '" show_search="' + _showsearch + '" select_mode="' + _selectmod + '" desc="' + mode + '" ' +
                                    'items="' + listitems + '" tag="' + currency_idVal + '" uitype="117">' + _selectedval + '</b>';
                            }
                            else if (fieldinfo.uitype == '251') {//账户
                                var bankaccountsetidVal = 1;
                                if (mode === 'edit') {
                                    bankaccountsetidVal = fieldinfo.hiddenvalue;
                                    _selectedval = fieldinfo.text;
                                }
                                tplnode += '<input id="hidden_bankaccountsetid" type="hidden" name="hidden_bankaccountsetid" value="' + fieldinfo.hiddenvalue + '">';
                                tplnode += '<b class="text-ellipsis" id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" popu_select="drop_down_list" ' +
                                    'title_str="' + ddltitle + '" show_search="' + _showsearch + '" select_mode="' + _selectmod + '" items="' + listitems + '" desc="' + mode + '" ' +
                                    'tag="' + bankaccountsetidVal + '" >' + _selectedval + '</b>';
                            }
                            else {
                                tplnode += '<b class="text-ellipsis" id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" popu_select="drop_down_list" ' +
                                    'title_str="' + ddltitle + '" show_search="' + _showsearch + '" select_mode="' + _selectmod + '" items="' + listitems + '" ' +
                                    'desc="' + mode + '" >' + _selectedval + '</b>';
                            }
                        }
                        else {
                            tplnode += '<b class="text-ellipsis" id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" type="text" ' +
                                'popu_select="drop_down_list" title_str="' + ddltitle + '" show_search="' + _showsearch + '" ' +
                                'select_mode="' + _selectmod + '" items="' + listitems + '" desc="' + mode + '" chossen_items="' + _multi_selectedval + '" >' + _selectedval + '</b>';
                        }
                    }
                    else if (ld.inArray(fieldinfo.uitype, chooseModuleArray) >= 0) {//模块选择
                        var parentstatus = 'yes',
                            chooseModule = '';
                        tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" type="hidden" value="' + fieldinfo.hiddenvalue + '" />';
                        if (fieldinfo.uitype == '53' || fieldinfo.uitype == '153') {//负责人、自定义选择用户
                            chooseModule = 'Users';
                        }
                        else if (fieldinfo.uitype == '242') {//公告接收人
                            chooseModule = 'UsersMore';
                            if (mode === 'edit') {
                                //接收人id、接收人name
                                var recipientids = fieldinfo.hiddenvalue;
                                var recipientnames = fieldinfo.text;
                                choose_pa_usersidobj = recipientids.split(",");
                                choose_pa_usersnameobj = recipientnames.split(",");
                                //Tools.print_array(choose_pa_usersidobj);
                                sessionStorage.setItem('storage_users_pa_id', JSON.stringify(choose_pa_usersidobj));
                                sessionStorage.setItem('storage_users_pa_name', JSON.stringify(choose_pa_usersnameobj));
                            }
                        }
                        else if (fieldinfo.uitype == '154') {//出差申请单同行人
                            chooseModule = 'UsersMore';
                            if (mode === 'edit') {
                                //同行人id、同行人name
                                var peerpersonsids = fieldinfo.hiddenvalue;
                                var peerpersonsnames = fieldinfo.text;
                                choose_ba_usersidobj = peerpersonsids.split(",");
                                choose_ba_usersnameobj = peerpersonsnames.split(",");
                                //Tools.print_array(choose_ba_usersidobj);
                                sessionStorage.setItem('storage_users_ba_id', JSON.stringify(choose_ba_usersidobj));
                                sessionStorage.setItem('storage_users_ba_name', JSON.stringify(choose_ba_usersnameobj));
                            }
                        }
                        else if (fieldinfo.uitype == '73' || fieldinfo.uitype == '51' || fieldinfo.uitype == '173') {//73:客户名称,51:上级单位
                            chooseModule = 'Accounts';
                            if (mode === 'edit') {
                                GVObj.crmObj.parentid = fieldinfo.hiddenvalue;
                            }
                        }
                        else if (fieldinfo.uitype == '57') {//联系人姓名
                            chooseModule = 'Contacts';
                        }
                        else if (fieldinfo.uitype == '80') {//合同订单
                            if (module == 'SalesOrder') {
                                parentstatus = 'no';
                            }
                            chooseModule = 'SalesOrder';
                        }
                        else if (fieldinfo.uitype == '240') {//服务单
                            chooseModule = 'HelpDesk';
                        }
                        else if (fieldinfo.uitype == '76') {//销售机会
                            chooseModule = 'Potentials';
                        }
                        else if (fieldinfo.uitype == '243') {//服务合同
                            chooseModule = 'ServiceContracts';
                        }
                        else if (fieldinfo.uitype == '59') {//产品名称
                            chooseModule = 'Products';
                        }
                        else if (fieldinfo.uitype == '58') {//市场活动
                            chooseModule = 'Campaigns';
                        }
                        else if (fieldinfo.uitype == '78') {//报价单
                            chooseModule = 'Quotes';
                        }
                        else if (fieldinfo.uitype == '79') {//常见问题
                            chooseModule = 'Faq';
                        }
                        else if (fieldinfo.uitype == '75' || fieldinfo.uitype == '81') {//供应商
                            chooseModule = 'Vendors';
                            if (mode === 'edit') {
                                GVObj.crmObj.parentid = fieldinfo.hiddenvalue;
                            }
                        }
                        else if (fieldinfo.uitype == '96') {//供应商联系人
                            chooseModule = 'VendorContact';
                        }
                        else if (fieldinfo.uitype == '202' || fieldinfo.uitype == '102' || fieldinfo.uitype == '200') {//选择源单，合同订单、采购订单
                            chooseModule = 'SalesOrder';
                        }
                        else if (fieldinfo.uitype == '10' || fieldinfo.uitype == '82') {//项目
                            chooseModule = 'Project';
                        }
                        else if (fieldinfo.uitype == '241') {//项目任务
                            chooseModule = 'ProjectTask';
                        }
                        tplnode += '<b class="text-ellipsis" popu_select="choose_module" fild_id="' + fieldinfo.fieldname + '" flid_lable="' + fieldinfo.fieldlabel + '" ' +
                            'choose_module="' + chooseModule + '" desc="' + mode + '" parentstatus="' + parentstatus + '" id="' + fieldinfo.fieldname + 'name" ' +
                            'name="' + fieldinfo.fieldname + 'name">' + fieldinfo.text + '</b>';
                    }
                    else if (fieldinfo.uitype == '86') {//日期+时间
                        tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" type="text" tag="date-control-datetime" readonly="true" value="" />';
                        DateContorlObj.addDateControlInfo('crm_datecontrol_field', fieldinfo.fieldname, 'datetime', fieldinfo.hiddenvalue);
                    }
                    else if (fieldinfo.uitype == '5' || fieldinfo.uitype == '23' || fieldinfo.uitype == '70') {//日期标签
                        tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" type="text" tag="date-control-date" readonly="true" value="" />';
                        DateContorlObj.addDateControlInfo('crm_datecontrol_field', fieldinfo.fieldname, 'date', fieldinfo.hiddenvalue);
                    }
                    else if (fieldinfo.uitype == '14') {//时间标签
                        tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" type="text" tag="date-control-time" readonly="true" value="" />';
                        DateContorlObj.addDateControlInfo('crm_datecontrol_field', fieldinfo.fieldname, 'time', fieldinfo.hiddenvalue);
                    }
                    else if (fieldinfo.uitype == '1108' || fieldinfo.uitype == '1109') {//附件
                        ViewObj.rootScope.att_maxcount = fieldinfo.att_maxcount;                 
                        if (phoneversion == 'android') {
                            var atts_Str = '';
                            tplnode += '<div id="androidUploader" class="androidatt-example">' + 
                                            '<!--用来存放文件信息-->' + 
                                            '<div id="androidAttList" class="androidatt-list">';
                                if(fieldinfo.text != '<b>未填写</b>' && fieldinfo.text != ''){
                                    ld.each(fieldinfo.text, function (attkey, attvalue) {
                                        atts_Str += attvalue.path+'&&&&'+attvalue.name+'&&&&'+attvalue.size+'&&&&'+attvalue.type+'&&&&'+attvalue.id+'####';
                                        var img = Tools.getAttImg(attvalue.name),
                                            imgStr = 'images/' + img + '.png';
                                        if(img == 'img'){
                                            imgStr = 'http://' + loginurl + '/' + attvalue.path + attvalue.name;
                                        }
                                        tplnode += '<div id="' + attvalue.id + '" class="item-content">' +
                                                        '<div class="media-list">' + 
                                                        '    <img style="width:36px;height:36px;border-radius:.3rem;" src="' + imgStr + '">' + 
                                                        '</div>' + 
                                                        '<div class="item-inner">' + 
                                                        '    <div class="item-title">' + attvalue.name + '</div>' + 
                                                        '    <div class="item-text">' + attvalue.size + '</div>' + 
                                                        '</div>' + 
                                                        '<div class="media-list-right">' + 
                                                        '    <img tag="del" style="width:24px;height:24px;" src="images/del.png">' + 
                                                        '</div>' + 
                                                    '</div>';
                                    });
                                    var android_atts_arr = atts_Str.split("####");//字符串转变成数组，将每个附件分开
                                    android_atts_arr.pop();
                                    ViewObj.rootScope.att_count = android_atts_arr.length;
                                    ViewObj.rootScope.att_arr = android_atts_arr;
                                } 
                                else{
                                    ViewObj.rootScope.att_count = 0;
                                    ViewObj.rootScope.att_arr = [];
                                }
                                tplnode +=  '</div>' + 
                                            '<div class="attbtns">' + 
                                                '<div id="androidChooseAtt">选择文件</div>' + 
                                            '</div>' + 
                                        '</div>';
                                
                        }
                        else{
                            tplnode += '<div id="uploader" class="wu-example">' + 
                                            '<!--用来存放文件信息-->' + 
                                            '<div id="thelist" class="uploader-list">';
                            if(fieldinfo.text != '<b>未填写</b>' && fieldinfo.text != ''){
                                ld.each(fieldinfo.text, function (attkey, attvalue) {
                                    var img = Tools.getAttImg(attvalue.name),
                                        imgStr = 'images/' + img + '.png';
                                    if(img == 'img'){
                                        imgStr = 'http://' + loginurl + '/' + attvalue.path + attvalue.name;
                                    }
                                    tplnode += '<div id="' + attvalue.id + '" class="item-content">' +
                                                    '<div class="media-list">' + 
                                                    '    <img style="width:36px;height:36px;border-radius:.3rem;" src="' + imgStr + '">' + 
                                                    '</div>' + 
                                                    '<div class="item-inner">' + 
                                                    '    <div class="item-title">' + attvalue.name + '</div>' + 
                                                    '    <div class="item-text">' + attvalue.size + '</div>' + 
                                                    '</div>' + 
                                                    '<div class="media-list-right">' + 
                                                    '    <img tag="del" style="width:24px;height:24px;" src="images/del.png">' + 
                                                    '</div>' + 
                                                '</div>';
                                });
                                ViewObj.rootScope.att_count = fieldinfo.hiddenvalue.length;
                                ViewObj.rootScope.att_arr = fieldinfo.hiddenvalue;
                            }
                            else{
                                ViewObj.rootScope.att_count = 0;
                                ViewObj.rootScope.att_arr = [];
                            }
                            tplnode +=      '</div>' + 
                                            '<div class="btns">' + 
                                                '<div id="picker">选择文件</div>' + 
                                            '</div>' + 
                                       '</div>';
                            //初始化Web Uploader
                            setTimeout(function() {
                                var timestamp = Date.parse(new Date());
                                getJsScript('js/webuploader/uploader.js?version=1.'+timestamp, function () {});
                            }, 500);
                        }
                    }
                    else if (fieldinfo.uitype == '69') {//照片
                        ViewObj.rootScope.att_maxcount = fieldinfo.att_maxcount;   
                        tplnode += '<div id="imagemodule" show-deletebt="true" class="edit picture-rang picture-preview" >';
                        if (mode === 'edit' && fieldinfo.text != '') {
                            ld.each(fieldinfo.options, function (productkey, productvalue) {
                                imgid += productvalue.text + ',';
                                tplnode += '<div img-detail ><img img_num="' + (productkey + 1) + '" src="http://' + loginurl + '/' + productvalue.value + '" onload="logicHanderObj.loadimg(this)"/></div>';
                            });
                        }
                        tplnode += '<div tag="img-addbt" style="background-image:url(images/add_photo.png)"></div></div>';
                    }
                    else {
                        tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" type="text" value="' + inputtext + '" />';
                    }
                    if (cemoduleName == 'Accounts' || cemoduleName == 'Vendors'){
                        if(fieldinfo.fieldname == 'bill_country' && fieldinfo.hiddenvalue != ''){
                            ViewObj.rootScope.defaultcountry = fieldinfo.hiddenvalue;
                            pickListChoose('bill_country', fieldinfo.hiddenvalue);
                        }
                        if(fieldinfo.fieldname == 'bill_state' && fieldinfo.hiddenvalue != ''){
                            ViewObj.rootScope.defaultstate = fieldinfo.hiddenvalue;
                            pickListChoose('bill_state', fieldinfo.hiddenvalue);
                        }
                        if(fieldinfo.fieldname == 'bill_city' && fieldinfo.hiddenvalue != ''){
                            ViewObj.rootScope.defaultcity = fieldinfo.hiddenvalue;
                            pickListChoose('bill_city', fieldinfo.hiddenvalue);
                        }
                    }
                }
                tplnode += '</li>';
            });
            tplnode += '</ul>';
        });
        tplnode += '</div>';
        
        //合同订单、报价单、服务合同、采购订单
        ViewObj.rootScope.trade = '';
        if (cemoduleName == 'SalesOrder' || cemoduleName == 'Quotes' ||
            cemoduleName == 'ServiceContracts' || cemoduleName == 'PurchaseOrder') {
            ViewObj.rootScope.trade = restobj.result.module.trade;
            tplnode += '<div id="divChooseProduct"></div>';
            tplnode += '<div class="bottomFixed"></div>';
        }
        //费用报销
        if (cemoduleName == 'Expense') {
            tplnode += '<div id="divExpensedetail" class="ui-hide"></div>';
            tplnode += '<div class="bottomFixed"></div>';
        }
        //OA表单：加班单、请假单、出差申请单、佣金单
        if (cemoduleName == 'AddJobBill' || cemoduleName == 'MinusJobBill' ||
            cemoduleName == 'BusinessApply' || cemoduleName == 'Commission') {
            tplnode += '<div id="divOadetail" class="ui-hide"></div>';
            tplnode += '<div class="bottomFixed"></div>';
        }
        ld('#crm-createedit-view').html(tplnode);
        // 绑定时间控件
        DateContorlObj.bingDateContrl('crm_datecontrol_field');
        //合同订单、报价单、服务合同、采购订单等小计、整单折扣、调整等html串
        if (cemoduleName == 'SalesOrder' || cemoduleName == 'Quotes' ||
            cemoduleName == 'ServiceContracts' || cemoduleName == 'PurchaseOrder') {
            if (mode != 'edit') {
                ld('#productSubCount').html(0);//数量小计
                if (ld('#productSubtotal').length === 1) {
                    ld('#productSubtotal').html(0);//金额小计
                }
                ld('#crm-addproduct-footer>ul>li>[tag=productmoney]').html('0');
            }
            arrProductObj = restobj.result.listproductfield;
            noArrProductObj = restobj.result.nopresenceproductfield;
            arrCurrencyObj = restobj.result.currency;
            arrFormulaFieldObj = restobj.result.listformulafield;
            ViewObj.rootScope.sys_49 = restobj.result.list2.sys_49;
            ViewObj.rootScope.sys_93 = restobj.result.list2.sys_93;
            var salesOrderedit = getTotalHtml(arrProductObj);
            ld('#divChooseProduct').append(salesOrderedit);
            if (mode != 'edit') {
                ld('#salesOrderetotal').addClass('ui-hide');
            }
            //判断不含税单价是否隐藏。no是不隐藏，yes是隐藏
            ViewObj.rootScope.hiddenlistprice = 'no';
            ld.each(noArrProductObj, function (key, fieldinfo) {
                if(fieldinfo.columnname === 'listprice'){
                    ViewObj.rootScope.hiddenlistprice = 'yes';
                }
            });
        }
        //费用报销
        if (cemoduleName == 'Expense') {
            if (mode != 'edit') {
                ld('#crm-addexpense-footer>ul>li>span').html('0');
            }
            arrExpenseObj = restobj.result.listexpensefield;
            arrFormulaFieldObj = restobj.result.listformulafield;
            ViewObj.rootScope.sys_49 = restobj.result.list2.sys_49;
            ViewObj.rootScope.sys_93 = restobj.result.list2.sys_93;
        }
        //OA表单：加班单、请假单、出差申请单、佣金单
        if (cemoduleName == 'AddJobBill' || cemoduleName == 'MinusJobBill' ||
            cemoduleName == 'BusinessApply' || cemoduleName == 'Commission') {
            if (mode != 'edit') {
                ld('#crm-addoadetail-footer>ul>li>span').html('0');
            }
            if (cemoduleName == 'Commission'){
                var totalHtml = '<ul class="c-ul c-other-total" id="oadetailtotalUL">' + 
                                    '<li><span>调整</span>' +
                                        '<b class="text-ellipsis" id="adjustmentType" name="adjustmentType" tag="+" desc="create" ' +
                                        'items="+&&增加|##|-&&减少|##|" select_mode="single" ' +
                                        'show_search="false" title_str="调整" popu_select="drop_down_list" >增加</b><i class="lnr-chevron-right"></i>' +
                                        '<input id="adjustment" name="adjustment" type="number"  tag="adjustment" value="0.00" onblur="oaDetailCalcTotal()" />' +
                                    '</li>' + 
                                '</ul>';
                ld('#divOadetail').append(totalHtml);
            }
            arrOaDetailObj = restobj.result.entry;
            arrFormulaFieldObj = restobj.result.entry.listformulafield;
            ViewObj.rootScope.sys_49 = restobj.result.list2.sys_49;
            ViewObj.rootScope.sys_93 = restobj.result.list2.sys_93;
        }
        if (mode === 'edit') {
            //合同订单、报价单、服务合同、采购订单等
            var res_pdct = restobj.result.listproduct;
            if (res_pdct && res_pdct.total.count > 0) {
                rowcnt = res_pdct.total.count;
                productcount = rowcnt;
                var producttotal = eval(res_pdct.total.hdnGrandTotal);
                var addproducthtml = '';
                addproducthtml += '<h2 class="c-detail-h2" contraction="no">产品清单';
                addproducthtml += '<input id="prev_inventory_currency" name="prev_inventory_currency" type="hidden" value="' + res_pdct.currency_id + '" />';
                var currencyStr = '', currencyFirstStr = '';
                ld.each(restobj.result.currency, function (key, list) {
                    if (res_pdct.currency_id == list.value) {
                        currencyFirstStr = list.text;
                    }
                    currencyStr += list.value + '&&' + list.text + '|##|';
                });
                addproducthtml += '<i class="lnr-chevron-right"></i>'
                addproducthtml += '<b class="text-ellipsis" id="inventory_currency" tag="currencyChoose"  name="inventory_currency" popu_select="drop_down_list" title_str="币种" show_search="false" select_mode="single" items="' + currencyStr + '" desc="create" >' + currencyFirstStr + '</b>';
                addproducthtml += '</h2>';
                addproducthtml += '<ul id="productUL" class="c-ul c-other-cell">';
                ld.each(res_pdct.list, function (key, list) {
                    var prow = eval(eval(key) + 1);
                    var quantityStr = Tools.Number.toDecimal(list.quantity, parseInt(ViewObj.rootScope.sys_49));
                    var taxpriceStr = Tools.Number.toDecimal(list.taxprice, parseInt(ViewObj.rootScope.sys_93));
                    var taxamountStr = Tools.Number.toDecimal(list.tax_amount, 2);
                    addproducthtml += '<li row="' + prow + '" productid="product' + list.productid + '_' + prow + '">';
                    addproducthtml += '<input id="hidden_rowid_' + prow + '" name="hidden_rowid_' + prow + '" type="hidden" value="0">';
                    addproducthtml += '<p><i class="text-ellipsis">' + list.productname + '</i><span>' + taxpriceStr + 'x' + quantityStr + '</span></p>';
                    addproducthtml += '<p><a tag="pedit">编辑</a> <a tag="pdel">删除</a><span tag="money" count="' + quantityStr + '">价税合计:' + taxamountStr + '</span></p>';
                    ld.each(noArrProductObj, function (nokey, nolist) {
                        addproducthtml += '<input id="' + nolist.columnname + prow + '" name="' + nolist.columnname + prow + '" type="hidden" value="' + nolist.defaultvalue + '" />';
                    });
                    ld.each(list, function (key, detial) {
                        if (key == 'productid') {
                            addproducthtml += '<input id="hdnProductId' + prow + '" name="hdnProductId' + prow + '" type="hidden" value="' + detial + '" />';
                        }
                        else {
                            addproducthtml += '<input id="' + key + prow + '" name="' + key + prow + '" type="hidden" value="' + detial + '" />';
                        }
                    });
                    addproducthtml += '</li>';
                });
                addproducthtml += '</ul>';
                ld('#divChooseProduct').prepend(addproducthtml);
                //数量、金额小计
                ld('#productSubCount').html(Tools.Number.toDecimal(res_pdct.total.allquantity, parseInt(ViewObj.rootScope.sys_49)));
                if (ld('#productSubtotal').length === 1) {
                    ld('#productSubtotal').html(Tools.Number.toDecimal(res_pdct.total.hdnSubTotal, 2));
                }
                //调整、整单折扣赋值
                var discount_type = res_pdct.total.discount_type,      //整单折扣类型
                    discount_percent = res_pdct.total.discount_percent,//折扣百分比
                    txtAdjustment = res_pdct.total.txtAdjustment,//调整价格
                    hdnDiscountAmount = res_pdct.total.hdnDiscountAmount,//直接降价
                    _viewDiscountVal = '',
                    _viewDiscountDetialVal = '',
                    _viewAdjustmentVal = '',
                    _viewAdjustmentDetialVal = '';
                if (discount_percent == null) {
                    discount_percent = '0.00';
                }
                if (txtAdjustment == null) {
                    txtAdjustment = '0.00';
                }
                if (hdnDiscountAmount == null) {
                    hdnDiscountAmount = '0.00';
                }
                //调整
                if (ld('#adjustment') != undefined) {
                    if (txtAdjustment < 0) {
                        ld('#adjustmentType').attr('tag', '-'); //调整 选中 减少
                        ld('#adjustmentType').html('减少');
                        ld('#adjustment').val(Tools.Number.toDecimal(Math.abs(txtAdjustment), 2));
                    }
                    else {
                        ld('#adjustmentType').attr('tag', '+');//调整 选中 增加
                        ld('#adjustmentType').html('增加');
                        ld('#adjustment').val(Tools.Number.toDecimal(txtAdjustment, 2));
                    }
                }
                //整单折扣
                if (ld('#sub_discount_amount') != undefined) {
                    if (discount_type == 0) {
                        ld('#selectDiscount').attr('tag', '-');//整单折扣  直接降价
                        ld('#selectDiscount').html('直接降价');
                        ld('#sub_discount_amount').val(Tools.Number.toDecimal(hdnDiscountAmount, 2));
                    } else {
                        ld('#selectDiscount').attr('tag', '%');//整单折扣  百分比降价
                        ld('#selectDiscount').html('百分比降价');
                        ld('#sub_discount_amount').val(Tools.Number.toDecimal(discount_percent, 2));
                        _viewDiscountDetialVal = discount_percent;
                    }
                }
                ld('#crm-addproduct-footer>ul>li>[tag=productmoney]').html(producttotal);
                //赋值字段公式
                var fieldinfojson = arrFormulaFieldObj;
                fieldformulaobj = new fieldFormula(fieldinfojson, ViewObj.rootScope.sys_49, ViewObj.rootScope.sys_93);
                fieldformulaobj.setAllRowEvent(res_pdct.count);
            }
            //费用报销等
            var res_expense = restobj.result.listexpense;
            if (res_expense && res_expense.count > 0) {
                var expensehtml = '', htmlhidden = '';
                rowcnt = res_expense.count;
                productcount = rowcnt;
                var expenseblocklabel = res_expense.blocklabel;
                var producttotal = eval(res_expense.total.total);
                expensehtml += '<h2 class="c-detail-h2">' + expenseblocklabel + '</h2>';
                expensehtml += '<ul id="expenselistUL" class="c-ul c-other-cell">';
                ld.each(res_expense.list, function (key, list) {
                    var prow = eval(key + 1);
                    var rmb_totalStr = Tools.Number.toDecimal(list.rmb_total, parseInt(2));
                    expensehtml += '<li row="' + prow + '">';
                    expensehtml += '<input id="hidden_rowid_' + prow + '" name="hidden_rowid_' + prow + '" type="hidden" value="0">';
                    expensehtml += '<p class="text-ellipsis">' + list.expenseuse + '</p>';
                    expensehtml += '<p><a tag="Eedit">编辑</a> <a tag="Edel">删除</a><span tag="money">金额:' + rmb_totalStr + '</span></p>';
                    ld.each(list, function (key, value) {
                        expensehtml += '<input id="' + key + prow + '" name="' + key + prow + '" type="hidden" value="' + value + '" />';
                    });
                    expensehtml += '</li>';
                });
                expensehtml += '</ul>';
                ld('#divExpensedetail').prepend(expensehtml);
                ld('#divExpensedetail').removeClass('ui-hide');
                ld('#crm-addexpense-footer>ul>li>[tag=expensemoney]').html(producttotal);                
            }
            //OA表单等
            if(cemoduleName == 'AddJobBill' || cemoduleName == 'MinusJobBill' || cemoduleName == 'BusinessApply' || cemoduleName == 'Commission'){
                var res_oadetail = restobj.result.entry;
                    optionList = '';
                if(res_oadetail.listfield) {
                    ld.each(res_oadetail.listfield, function (key, list) {
                        if(list.columnname == 'entitytype'){
                            optionList = list.option;
                        }
                    });
                }
                if (res_oadetail.list) {
                    var oadetailhtml = '', htmlhidden = '',costordayStr = '',listulliClass = 'detailline3';
                    if(cemoduleName == 'AddJobBill'){
                        listulliClass = ''
                    }
                    rowcnt = res_oadetail.list.length;
                    productcount = rowcnt;
                    var oadetailblocklabel = res_oadetail.blocklabel;
                    var producttotal = res_oadetail.p_total[0].value;
                    if(cemoduleName == 'Commission'){
                        ld('#adjustment').val(Tools.Number.toDecimal(res_oadetail.p_total[0].value, 2));
                        producttotal = res_oadetail.p_total[1].value;
                    }
                    oadetailhtml += '<h2 class="c-detail-h2">' + oadetailblocklabel + '</h2>';
                    oadetailhtml += '<ul id="oadetaillistUL" class="c-ul c-other-cell ' + listulliClass + '">';
                    ld.each(res_oadetail.list, function (key, list) {
                        var prow = eval(key + 1),
                            descriptionStr = '';
                        if(cemoduleName == 'AddJobBill'){
                            descriptionStr = list.starttime.value + ' ~ ' + list.starttime.value;//'原因:'+list.description.value;
                            costordayStr = '时长(h):' + Tools.Number.toDecimal(list.costtime.value, parseInt(1));                            
                        } else if(cemoduleName == 'MinusJobBill'){
                            descriptionStr = list.starttime.value + ' ~ ' + list.starttime.value;//'假别:'+list.minusjobtype.value;
                            costordayStr = '假别:' + list.minusjobtype.value + '<br/>';
                            costordayStr += '时长(h):' + Tools.Number.toDecimal(list.costtime.value, parseInt(1));
                        } else if(cemoduleName == 'BusinessApply'){
                            descriptionStr = list.starttime.value + ' ~ ' + list.starttime.value;//'交通工具:'+list.traffictype.value;
                            costordayStr = '交通工具:' + list.traffictype.value + '<br/>';
                            costordayStr += '天数:' + Tools.Number.toDecimal(list.days.value, parseInt(1));
                        } else if(cemoduleName == 'Commission'){
                            descriptionStr = list.entitytype.value + ':' + list.entitytypeid.value;
                            costordayStr = '合同金额:' + Tools.Number.toDecimal(list.source_total.value, parseInt(2)) + '<br/>';
                            costordayStr += '佣金:' + Tools.Number.toDecimal(list.amount.value, parseInt(2));
                        }
                        oadetailhtml += '<li row="' + prow + '">';
                        oadetailhtml += '<input id="hidden_rowid_' + prow + '" name="hidden_rowid_' + prow + '" type="hidden" value="0">';
                        oadetailhtml += '<p class="text-ellipsis">' + descriptionStr + '</p>';
                        oadetailhtml += '<p><a tag="Dedit">编辑</a> <a tag="Ddel">删除</a><span tag="costorday">' + costordayStr + '</span></p>';
                        ld.each(list, function (key, value) {
                            if(key == 'detailid'){
                                oadetailhtml += '<input id="' + key + prow + '" name="' + key + prow + '" type="hidden" value="' + value + '" />';
                            }
                            else if(key == 'entitytype'){
                                var entitytype_tabid = '';
                                ld.each(optionList, function(optionkey ,optionvalue){
                                    if(value.hiddenvalue == optionvalue.name){
                                        entitytype_tabid = optionvalue.value;
                                    }
                                });
                                oadetailhtml += '<input id="entitytype_tabid' + prow + '" name="entitytype_tabid' + prow + '" type="hidden" value="' + entitytype_tabid + '" />';
                                oadetailhtml += '<input id="entitytype_tabname' + prow + '" name="entitytype_tabname' + prow + '" type="hidden" value="' + value.hiddenvalue + '" />';
                            }
                            else if(key == 'entitytypeid'){
                                oadetailhtml += '<input id="entitytypeid' + prow + '" name="entitytypeid' + prow + '" type="hidden" value="' + value.hiddenvalue + '" />';
                                oadetailhtml += '<input id="entitytype_name' + prow + '" name="entitytype_name' + prow + '" type="hidden" value="' + value.value + '" />';
                            }
                            else{
                                oadetailhtml += '<input id="' + key + prow + '" name="' + key + prow + '" type="hidden" value="' + value.value + '" />';    
                            }
                        });
                        oadetailhtml += '</li>';
                    });
                    oadetailhtml += '</ul>';
                    ld('#divOadetail').prepend(oadetailhtml);
                    ld('#divOadetail').removeClass('ui-hide');
                    ld('#crm-addoadetail-footer>ul>li>[tag=oadetailtotal]').html(producttotal);                    
                }  
            }            
        }
        autosize(ld('#crm-createedit-view textarea'));//textarea根据内容自动调整大小
        callback(restobj.result);
        ld('#crm-createedit-view').width(SwiperObj.PHONE_WIDTH);
        // var ceshiStr = 'storage/2017/July/week1/&&&&工作安排.txt&&&&780kb&&&&text/plain####';
        //     ceshiStr+= 'storage/2017/July/week1/&&&&灵当CRM详细需求-微信端-OA表单.docx&&&&780kb&&&&application/octet-stream####';
        // setFileAttachmentInfoAndroid(ceshiStr);
    });
}

function setFileAttachmentInfoAndroid(fileinfo){
    var android_atts_str = '';
    var android_atts_arr = fileinfo.split("####");//字符串转变成数组，将每个附件分开
    android_atts_arr.pop();
    
    var att_count = ViewObj.rootScope.att_count;
    for(var i=0;i<android_atts_arr.length;i++){
        att_count++;  
        if(att_count>ViewObj.rootScope.att_maxcount){
            PopPromptBox.show('添加的附件数量不允许超出'+ ViewObj.rootScope.att_maxcount +'个');
            return;
        }  
    }
    ViewObj.rootScope.att_count = att_count;

    for(var i=0;i<android_atts_arr.length;i++){
        var _android_att_str = android_atts_arr[i];
        var _android_att_arr = _android_att_str.split("&&&&");
        var timestamp = Date.parse(new Date()); 
        var timestamp_str = timestamp+'_'+i;
        _android_att_arr.push(timestamp_str);
        _android_att_str = _android_att_arr.join("&&&&");
        android_atts_arr[i] = _android_att_str;
    }
    var arr2 = [];
    if(ViewObj.rootScope.att_arr != undefined){
        arr2 = ViewObj.rootScope.att_arr;
    }
    for(var i=0;i<android_atts_arr.length;i++){
        arr2.push(android_atts_arr[i]);
    }
    ViewObj.rootScope.att_arr = arr2;
    for(var i=0;i<android_atts_arr.length;i++){
        var android_att_str = android_atts_arr[i];
        android_att_arr = android_att_str.split("&&&&");
        
        var img = Tools.getAttImg(android_att_arr[1]),
            imgStr = 'images/' + img + '.png';
        if(img == 'img'){
            imgStr = 'http://' + loginurl + '/' + android_att_arr[0] + android_att_arr[1];
        }
        android_atts_str += '<div id="' + android_att_arr[4] + '" class="item-content">' +
                                '<div class="media-list">' + 
                                '    <img style="width:36px;height:36px;border-radius:.3rem;" src="' + imgStr + '">' + 
                                '</div>' + 
                                '<div class="item-inner">' + 
                                '    <div class="item-title">' + android_att_arr[1] + '</div>' + 
                                '    <div class="item-text">' + android_att_arr[2] + '</div>' + 
                                '</div>' + 
                                '<div class="media-list-right">' + 
                                '    <img tag="del" style="width:24px;height:24px;" src="images/del.png">' + 
                                '</div>' + 
                            '</div>';
    }
    ld('#androidAttList').html(ld('#androidAttList').html() + android_atts_str);
}

//弹出下拉框列表 //----
function getPopDropDownList(origin_value, select_mode, items_str) {
    var list_str = '<ul>',
        itemsArray = items_str.split('|##|'),
        _isother = [],
        option = '',
        content_hoder = ld('#cwn-popuselect-view>.content-wrapper');
    for (var i = 0; i < itemsArray.length - 1; i++) {
        if (!itemsArray[i].toString()) {
            option = itemsArray[i].split('&&');
            if (!option[0].toString()) {
                if (option[1] !== '其他') {
                    //option[0]为值 option[1]名称
                    list_str += '<li class="text-ellipsis " tag="' +
                        option[0] + '" item="popu_select">' + option[1] + '</li>';

                } else {
                    _isother[0] = option[0];
                    _isother[1] = option[1];
                }
            }
        }
    }
    if (_isother.length > 0) {
        list_str += '<li tag="' + _isother[0] + '">' + _isother[1] + '</li>';
    }
    list_str += '</ul>';
    content_hoder.html(list_str); //插入选项列表值
    if (select_mode == 'single') {//单选框
        if (origin_value) {
            content_hoder.find('li').each(function () {
                if (ld(this).text() === _selectedval) {
                    ld(this).addClass('singeselectcheck');
                }
            });
        }
        //多选框
    } else {
        content_hoder.find('li').addClass('lnr lnr-square');
        if (origin_value) {
            var _valarray = origin_value.split(',');
            for (var i = 0; i < _valarray.length; i++) {
                if (_valarray[i]) {
                    content_hoder.find('li').each(function () {
                        if (ld(this).text() === _valarray[i]) {
                            ld(this).addClass('lnr lnr-checkmark-square');
                        }
                    });
                }
            }
        }
    }
}

//选择列表赋值
function getChooseModuleList(urlstring, callback) {
    WordReportAjax(urlstring, function (rest) {
        if (rest == '') return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var content_hoder = ld('#cwn-popuselect-view>.content-wrapper');
        ld('#cwn-popuselect-view input[tag=search-text]').attr('placeholder', restobj.result.str);
        SwiperObj.ListPageObj.setListPageIndex(restobj.result.curpagenum, ViewObj.getInfo('to_viewid'));
        SwiperObj.ListPageObj.setHasNextPage(restobj.result.havenextpage, ViewObj.getInfo('to_viewid'));

        var listhtml = '',
            crm_lists = '',
            user_class = 'listimg',
            res_list = restobj.result.list,
            res_list2 = restobj.result.list2;
        if (res_list && res_list.length) {
            ld.each(res_list, function (key, list) {
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
                    if (!list.E) {
                        list.E = '--';
                    }
                    if (!list.F) {
                        list.F = '--';
                    }
                    if (moduleNameStr == 'Users') {
                        if(list.userimg != undefined){
                            listhtml += '<li id="user' + list.curid + '" user_id="' + list.curid + '" user_name="' + list.lastname + '" userid="' + list.curid + '" item="popu_select">' +
                                            '<div>' +
                                                '<img src="http://' + loginurl + '/' + list.userimg + '" onload="logicHanderObj.loadimg(this)" >' +
                                            '</div>' +
                                            '<span class="center text-ellipsis">' +
                                                '<i class="text-ellipsis">' + list.lastname + '</i>' +
                                                list.description +
                                            '</span>' +
                                            '<span class="img-circle">' +
                                                '<i class="lnr-circle"></i>' +
                                            '</span>' +
                                        '</li>';
                        }
                        else{
                            user_class = 'crm-lists-user';
                            listhtml += '<li item="popu_select"  user_id="' + list.curid + '" user_name="' + list.lastname + '" id="user' + list.curid + 
                                        '" userid="' + list.curid + '">' + list.lastname + '</li>';
                        }
                    } else if (moduleNameStr == 'UsersMore' || moduleNameStr == 'Users') {
                        if(list.userimg != undefined){
                            listhtml += '<li id="user' + list.curid + '" user_id="' + list.curid + '" user_name="' + list.lastname + '" userid="' + list.curid + '" item="popu_select">' +
                                            '<div>' +
                                                '<img src="http://' + loginurl + '/' + list.userimg + '" onload="logicHanderObj.loadimg(this)" >' +
                                            '</div>' +
                                            '<span class="center text-ellipsis">' +
                                                '<i class="text-ellipsis">' + list.lastname + '</i>' +
                                                list.description +
                                            '</span>' +
                                            '<span class="img-circle">' +
                                                '<i class="lnr-square"></i>' +
                                            '</span>' +
                                        '</li>';
                        }
                        else{
                            crm_lists = 'crm-lists';
                            listhtml += '<li id="user' + list.curid + '" user_id="' + list.curid + '" user_name="' + list.lastname + 
                                        '" userid="' + list.curid + '" class="lnr-square" item="popu_select">' + list.lastname + '</li>';    
                        }

                    } else if (moduleNameStr == 'Accounts') {
                        //Accounts：A客户名称,B销售负责人,C客户状态,D创建时间
                        listhtml += '<li item="popu_select" user_id="' + list.curid + '" user_name="' + list.A + '"  id="module' + list.curid + '" userid="' + list.curid + '"><h5>' +
                            list.A + '</h5><p><span>' + list.B + '</span> | <span>' + list.C + ' | ' + list.D + '</span></p></li>';
                    } else if (moduleNameStr == 'ContactRecords'
                        || moduleNameStr == 'VendorContactRecords') {
                        //ContactRecords: A主题,B销售负责人,C客户名称,D日期
                        //VendorContactRecords：A主题,B采购负责人,C供应商名称,D创建时间
                        listhtml += '<li item="popu_select" user_id="' + list.curid + '" user_name="' + list.A + '"  id="module' + list.curid + '" userid="' + list.curid + '">' +
                            '<h5>' + list.A + '</h5>' +
                            '<p><span>' + list.C + '</span></p>' +
                            '<p><span>' + list.B + ' | ' + list.D + '</span></p></li>';
                    } else if (moduleNameStr == 'Vendors') {
                        //Vendors：A供应商编号,B名称,C采购负责人,D创建时间
                        listhtml += '<li item="popu_select"  id="module' + list.curid + '" user_id="' + list.curid + '" user_name="' + list.B + '" userid="' + list.curid + '"><h5>' +
                            list.A + '</h5><p><span>' + list.B + '</span> | <span>' + list.C + ' | ' + list.D +
                            '</span></p></li>';
                    }
                    else if (moduleNameStr == 'Contacts' || moduleNameStr == 'Campaigns' ||
                        moduleNameStr == 'VendorContact' ||
                        moduleNameStr == 'Potentials' ||
                        moduleNameStr == 'Products') {
                        //Contacts：A联系人名称,B销售负责人,C客户名称;VendorContact:A姓名,B采购负责人,C供应商联系人
                        //Potentials：A销售机会名称,B负责人,C创建时间;Products：A产品名称,B计量单位,C规格型号
                        //Campaigns:A销售机会名称、市场活动名称,B负责人,C创建时间
                        listhtml += '<li item="popu_select"  id="module' + list.curid + '" user_id="' + list.curid + '" user_name="' + list.A + '" userid="' + list.curid + '"><h5>' +
                            list.A + '</h5><p><span>' + list.B + '</span> | <span>' + list.C + '</span></p></li>';
                    } else if (moduleNameStr == 'HelpDesk') {
                        if (!list.B || list.B == '-0001-11 00:00:00') list.B = '--';//实际处理时间
                        //A服务单编号,B实际处理时间,C负责人,D客户名称,E状态
                        listhtml += '<li item="popu_select"  id="module' + list.curid + '" user_id="' + list.curid + '" user_name="' + list.A + '" userid="' + list.curid +
                            '"><h5>' + list.A + ' | ' + list.D + '</h5><p><span>' + list.C + '</span> | <span>' +
                            list.E + ' | ' + list.B + '</span></p></li>';
                    } else if (moduleNameStr == 'SalesOrder' ||
                        moduleNameStr == 'Quotes' ||
                        moduleNameStr == 'ServiceContracts' ||
                        moduleNameStr == 'PurchaseOrder' ||
                        moduleNameStr == 'Expense' ||
                        moduleNameStr == 'Project' ||
                        moduleNameStr == 'ProjectTask') {//合同订单、报价单、服务合同、采购订单、费用报销、项目、项目任务
                        //A单据名称,B客户名称,C金额,D销售负责人,E签约时间、创建时间
                        listhtml += '<li item="popu_select"  id="module' + list.curid + '" user_id="' + list.curid + '" user_name="' + list.A + '" userid="' + list.curid + '"><h5>' +
                            list.A + ' | ' + list.B + '</h5><p><span>' + list.C + '</span> | <span>' + list.D +
                            ' | ' + list.E + '</span></p></li>';
                    } else {
                        listhtml += '<li item="popu_select"  id="module' + list.curid + '" user_id="' + list.curid + '" user_name="' + list.A + '" userid="' + list.curid + '"><h5>' +
                            list.A + '</h5><p><span>' + list.B + '</span> | <span>' + list.C + '</span></p></li>';
                    }
                }
                else{
                    var module_class = '';
                    if (moduleNameStr == 'Contacts' || moduleNameStr == 'VendorContact') {
                        module_class = 'r-cell';
                        var phoneshow = 'ui-hide',
                            relmobile = /^1\d{10}$/,
                            relhome = /^((\d{3})|((\d{3})-)|(\d{4})|((\d{4})-))?(\d{7,8})$/,
                            newphone_arr = new Array(),
                            newphone_str = '';
                        if (list.hidden != '--' && list.hidden != '' && list.hidden != null) {
                            var number = new Array();
                            number = list.hidden.split(',');
                            //去除重复的号码
                            for (var j = 0; j < number.length; j++) {
                                var items = number[j];
                                if (relmobile.test(items) || relhome.test(items)) {
                                    if (ld.inArray(items, newphone_arr) == -1) {
                                        newphone_arr.push(items);
                                        newphone_str += items + '&&';
                                    }
                                }
                            }
                            if (newphone_arr.length > 0) {
                                phoneshow = '';
                            }
                        }
                    }
                    listhtml += '<li class="r-cell" item="popu_select" user_id="' + list.curid + '" user_name="' + list.title + '"  id="module' + list.curid + '" userid="' + list.curid + '">' + 
                                    '<h5>' + list.title + '</h5>';
                                    var phonerow = 0;
                                    ld.each(list.field, function (keyfield, listfield) {
                                        phonerow++;
                                        var listfieldOne = listfield[0],
                                            listfieldTwo = listfield[1];
                                        if(listfieldOne == undefined) listfieldOne = '';
                                        if(listfieldTwo == undefined) listfieldTwo = '';
                                        if(phonerow == 1 && (moduleNameStr == 'Contacts' || moduleNameStr == 'VendorContact')){
                    listhtml +=             '<p><span>' + listfieldOne + '</span> | <span>' + listfieldTwo + '</span>' +  
                                            '<a phonemobile="' + newphone_str + '" class="lnr-phone-handset ' + phoneshow + '" tag="call">&nbsp;</a>' +
                                            '</p>';
                                        }
                                        else{
                    listhtml +=             '<p><span>' + listfieldOne + '</span> | <span>' + listfieldTwo + '</span></p>';                                    
                                        }
                                    });
                    listhtml += '</li>';
                }
            });
            if (moduleNameStr == 'UsersMore') {
                listhtml = '<ul class="crm-lists-user-more ' + crm_lists + '">' + listhtml + '</ul>';
            } else if (moduleNameStr == 'Users') {
                listhtml = '<ul class="'+ user_class +'">' + listhtml + '</ul>';
            } else {
                //计算多少行
                if (!empty(restobj.result.list)) {
                    if(restobj.result.list[0].title){
                        var i = 1;
                        ld.each(restobj.result.list[0].field, function (listfieldkey, listfieldinfo) {
                            i++;
                        });
                        list_class = 'crm-lists line'+i;
                        listhtml = '<ul class="crm-lists ' + list_class + '">' + listhtml + '</ul>';
                    }
                    else{
                        if (moduleNameStr == 'ContactRecords' || moduleNameStr == 'VendorContactRecords') {
                            listhtml = '<ul class="crm-lists line3">' + listhtml + '</ul>';
                        }
                        else{
                            listhtml = '<ul class="crm-lists">' + listhtml + '</ul>';
                        }
                    }
                }
                else{
                    listhtml = '<ul class="crm-lists">' + listhtml + '</ul>';
                }
            }
        } else {
            if (moduleNameStr == 'Users' || moduleNameStr == 'UsersMore'){
                listhtml = logicHanderObj.NoinfoNotice('数据');
            }
            else{
                listhtml = logicHanderObj.NoinfoNotice(restobj.result.list2.moduletitle);
            }
            ld('#list-addmore-holder').addClass('ui-hide');
        }
        
        if (module === 'Singin' && res_list2.quickcreate === 'yes' && ViewObj.rootScope.signpage === 'first') {
            var header_ar = ViewObj.getInfo('current_header')
            header_ar.splice(4, 2, '+', '');
            ViewObj.setAppHeader(header_ar);
        }
        if (SwiperObj.is_addMore) {//加载在面添加内容
            content_hoder.html(content_hoder.html() + listhtml);
        } else {//刷新搜索等都需清空原来内容
            content_hoder.html(listhtml);
        }
        
        if (moduleNameStr == 'UsersMore') {//多选用户
            if(module == 'PublicAnnouncement'){
                //已选择接收人记录
                var final_choose_pa_usersidobj = JSON.parse(sessionStorage.getItem('storage_users_pa_id'));
                ld.each(final_choose_pa_usersidobj, function (key, id) {
                    if(ld('#user' + final_choose_pa_usersidobj[key]).hasClass('lnr-square')){
                        ld('#user' + final_choose_pa_usersidobj[key]).removeClass('lnr-square').addClass('lnr-checkmark-square');
                    }
                    else{
                        ld('#user' + final_choose_pa_usersidobj[key]).find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');    
                    }
                });
            }
            if(module == 'BusinessApply'){
                //已选择同行人记录
                var final_choose_ba_usersidobj = JSON.parse(sessionStorage.getItem('storage_users_ba_id'));
                ld.each(final_choose_ba_usersidobj, function (key, id) {
                    if(ld('#user' + final_choose_ba_usersidobj[key]).hasClass('lnr-square')){
                        ld('#user' + final_choose_ba_usersidobj[key]).removeClass('lnr-square').addClass('lnr-checkmark-square');
                    }
                    else{
                        ld('#user' + final_choose_ba_usersidobj[key]).find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');    
                    }
                });
            }
        }
        if (moduleNameStr == 'Users') {//选择负责人
            var assigneduserid = '';
            if(module == 'ServiceContracts' || newmodule == 'ServiceContracts'){
                assigneduserid = ld('#ServiceContractsassigned_user_id').val();
            }
            else{
                assigneduserid = ld('#assigned_user_id').val();
            }
            if(assigneduserid <= 0){
                assigneduserid = userid;
            }
            if(ld('#user'+ assigneduserid).find('.img-circle').find('i').hasClass('lnr-circle')){
                ld('#user'+ assigneduserid).parent().find('.img-circle').find('i').removeClass('lnr-circle-solid').addClass('lnr-circle');
                ld('#user'+ assigneduserid).find('.img-circle').find('i').removeClass('lnr-circle').addClass('lnr-circle-solid');
            }
        }
        callback();
    });
}

//选择共享人
function getShareUsersList(urlstring, callback){
    WordReportAjax(urlstring, function (rest) {
        if (rest == '') return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var content_hoder = ld('#cwn-popuselect-view>.content-wrapper');
        
        var listhtml = '',
            shared_userids = '',
            shared_usernames = '',
            cancelshare = restobj.cancelshare,
            res_list = restobj.Colleague;
        if (res_list && res_list.length) {
            ld.each(res_list, function (key, list) {
                var sharedclass = 'lnr-square';
                if(list.select.value == 'yes'){
                    sharedclass = 'lnr-checkmark-square';
                    if(cancelshare == 'no'){
                        sharedclass = 'lnr-checkmark-square no_checkbox';
                    }
                    shared_userids += list.userid.value + ',';
                    shared_usernames += list.lastname.value + ',';
                }
                listhtml += '<li id="user' + list.userid.value + '" user_id="' + list.userid.value + '" user_name="' + list.lastname.value + '" userid="' + list.userid.value + '" item="popu_select">' +
                                '<div>' +
                                    '<img src="http://' + loginurl + '/' + list.userimgpath.value + '" onload="logicHanderObj.loadimg(this)" >' +
                                '</div>' +
                                '<span class="center text-ellipsis">' +
                                    '<i class="text-ellipsis">' + list.lastname.value + '</i>' +
                                    list.description.value +
                                '</span>' +
                                '<span class="img-circle">' +
                                    '<i class="'+ sharedclass +'"></i>' +
                                '</span>' +
                            '</li>';
            });
            listhtml = '<ul class="crm-lists-user-more">' + listhtml + '</ul>';
        } else {
            listhtml = logicHanderObj.NoinfoNotice('');
            ld('#list-addmore-holder').addClass('ui-hide');
        }
        content_hoder.html(listhtml);
        shared_userids = shared_userids.substring(0, shared_userids.length - 1);
        shared_usernames = shared_usernames.substring(0, shared_usernames.length - 1);
        choose_shared_useridobj = shared_userids.split(",");
        choose_shared_usernameobj = shared_usernames.split(",");
        callback();
    });
}

function getDetailRelation(_item_num, _max_textlen) {
    ld('#cwn-crmdetail-view>#divRelatedList>.relatedlistwrap').removeClass('ui-hide');
    ld('#divRelatedList .relation-crm').css('margin', '0px');
    ld('.swiper-container.relation-crm').css({'width': SwiperObj.PHONE_WIDTH + 'px'});
    //获取最终的 每页显示个数
    var item_num = (function (item_num, max_len, realted_id) {
        //每一个： 1，最小值 2,最大值 3,对应的项值
        var text_range = [[1, 5, 4], [6, 7, 3], [8, 10, 2]];
        var final_num = 1;
        for (var i = 0, len = text_range.length; i < len; i++) {
            var curr_range = text_range[i];
            if (curr_range[0] <= max_len && max_len <= curr_range[1]) {
                final_num = curr_range[2];
                break;
            }
        }
        if (item_num > final_num) {//大于final_num个时，相关表单，添加向右的箭头
            ld('#' + realted_id + ' .relatedlistwrap').append('<div class="lnr-chevron-right re-arrow" ></div>');
            ld('#' + realted_id + ' .swiper-container').css({'width': (SwiperObj.PHONE_WIDTH - 20) + 'px'});
        }
        return final_num;
    })(_item_num, _max_textlen, 'divRelatedList');

    SwiperObj.WorkRelation_swiper = new Swiper('.swiper-container.relation-crm', {
        loop: false,
        slidesPerView: item_num
    });
    ld('.swiper-container.relation-crm').css({'height': '48px', 'overflow': 'hidden'});
    ld('#divRelatedList .relation-crm').css('margin', '0px');
}

//选择
function chooseModuleFun(id, name) {
    // alert(id+'---'+name+'---moduleNameStr:'+moduleNameStr+'---module:'+module);
    var idstr = '';
    if (moduleNameStr == 'Users' || moduleNameStr == 'UsersMore' || moduleNameStr == 'ShareUsers') {
        idstr = 'user';
    } else {
        idstr = 'module';
    }
    if (module == 'PublicAnnouncement' && moduleNameStr == 'UsersMore') {
        //选择接收人id
        if (empty(choose_pa_usersidobj)) {
            choose_pa_usersidobj = [];
            choose_pa_usersidobj[0] = id;
        }
        //选择接收人名称
        if (empty(choose_pa_usersnameobj)) {
            choose_pa_usersnameobj = [];
            choose_pa_usersnameobj[0] = name;
        }
        if(ld('#' + idstr + id).hasClass('lnr-square') || ld('#' + idstr + id).hasClass('lnr-checkmark-square')){
            if (ld('#' + idstr + id).hasClass('lnr-square')) {
                ld('#' + idstr + id).removeClass('lnr-square').addClass('lnr-checkmark-square');
                if (ld.inArray(id, choose_pa_usersidobj) == -1) {//当前元素下标位置
                    choose_pa_usersidobj[choose_pa_usersidobj.length] = id;
                    choose_pa_usersnameobj[choose_pa_usersnameobj.length] = name;
                }
            } else {
                ld('#' + idstr + id).removeClass('lnr-checkmark-square').addClass('lnr-square');
                choose_pa_usersidobj.splice(ld.inArray(id, choose_pa_usersidobj), 1);//移除选择id
                choose_pa_usersnameobj.splice(ld.inArray(name, choose_pa_usersnameobj), 1);
            }
        }
        else{
            if (ld('#' + idstr + id).find('.img-circle').find('i').hasClass('lnr-square')) {
                ld('#' + idstr + id).find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                if (ld.inArray(id, choose_pa_usersidobj) == -1) {//当前元素下标位置
                    choose_pa_usersidobj[choose_pa_usersidobj.length] = id;
                    choose_pa_usersnameobj[choose_pa_usersnameobj.length] = name;
                }
            } else {
                ld('#' + idstr + id).find('.img-circle').find('i').removeClass('lnr-checkmark-square').addClass('lnr-square');
                choose_pa_usersidobj.splice(ld.inArray(id, choose_pa_usersidobj), 1);//移除选择id
                choose_pa_usersnameobj.splice(ld.inArray(name, choose_pa_usersnameobj), 1);
            }
        }
    } else if (module == 'BusinessApply' && moduleNameStr == 'UsersMore') {
        //选择同行人id
        if (empty(choose_ba_usersidobj)) {
            choose_ba_usersidobj = [];
            choose_ba_usersidobj[0] = id;
        }
        //选择同行人名称
        if (empty(choose_ba_usersnameobj)) {
            choose_ba_usersnameobj = [];
            choose_ba_usersnameobj[0] = name;
        }
        if (ld('#' + idstr + id).find('.img-circle').find('i').hasClass('lnr-square')) {
            ld('#' + idstr + id).find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
            if (ld.inArray(id, choose_ba_usersidobj) == -1) {//当前元素下标位置
                choose_ba_usersidobj[choose_ba_usersidobj.length] = id;
                choose_ba_usersnameobj[choose_ba_usersnameobj.length] = name;
            }
        } else {
            ld('#' + idstr + id).find('.img-circle').find('i').removeClass('lnr-checkmark-square').addClass('lnr-square');
            choose_ba_usersidobj.splice(ld.inArray(id, choose_ba_usersidobj), 1);//移除选择id
            choose_ba_usersnameobj.splice(ld.inArray(name, choose_ba_usersnameobj), 1);
        }
    } else if (module == 'Contacts' && moduleNameStr == 'Accounts') {
        var urlstring = 'module=Users&action=getDetailBlock&recordid=' + id + '&setype=getAccountToContactInfo';
        WordReportAjax(urlstring, function (rest) {
            if (rest == '') return false;
            var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
            if (ld('#mailingcountry').length === 1) {
                ld('#mailingcountry').val(restobj.result.list.bill_country);
            }
            if (ld('#mailingstate').length === 1) {
                ld('#mailingstate').val(restobj.result.list.bill_state);
            }
            if (ld('#mailingcity').length === 1) {
                ld('#mailingcity').val(restobj.result.list.bill_city);
            }
            if (ld('#mailingzip').length === 1) {
                ld('#mailingzip').val(restobj.result.list.bill_code);
            }
            if (ld('#mailingstreet').length === 1) {
                ld('#mailingstreet').val(restobj.result.list.bill_street);
            }
            if (ld('#account_id').length === 1) {
                ld('#account_id').val(restobj.result.list.accountid);
            }
            if (ld('#account_idname').length === 1) {
                ld('#account_idname').html(restobj.result.list.accountname);
            }
        });
    } else {
        if (module == 'PhotoGraph') {
            ld('#photovalueid').html(id);
            ld('#photovalueName').html(name);
        } else if (module == 'Singin') {
            if(ld("#account_idname").length>0){
                ld('#account_id').val(id);
                ld('#account_idname').html(name);
            }
            else{
                ld('#accountid').html(id);
                ld('#accountName').html(name);
                getAccountsAddressforSinginDistance(id);//根据客户ID获取客户地址并计算距离
            }
        } else {
            if(moduleNameStr == 'ShareUsers'){
                if(!ld('#' + idstr + id).find('.img-circle').find('i').hasClass('no_checkbox')){
                    if(ld('#' + idstr + id).find('.img-circle').find('i').hasClass('lnr-square')){
                        ld('#' + idstr + id).find('.img-circle').find('i').removeClass('lnr-square').addClass('lnr-checkmark-square');
                        if (ld.inArray(id, choose_shared_useridobj) == -1) {//当前元素下标位置
                            choose_shared_useridobj[choose_shared_useridobj.length] = id;
                            choose_shared_usernameobj[choose_shared_usernameobj.length] = name;
                        }
                    }
                    else{
                        ld('#' + idstr + id).find('.img-circle').find('i').removeClass('lnr-checkmark-square').addClass('lnr-square');
                        choose_shared_useridobj.splice(ld.inArray(id, choose_shared_useridobj), 1);//移除选择id
                        choose_shared_usernameobj.splice(ld.inArray(name, choose_shared_usernameobj), 1); 
                    }
                }
            }
            else{
                if(moduleNameStr == 'Products'){
                    var list_create = ViewObj.rootScope.list_create,
                        return_module = '';
                    if (list_create === 'relationcreate') {
                        return_module = newmodule;
                    }
                    else if (list_create === 'create') {
                        return_module = module;
                    }
                    if(return_module == 'Approve'){
                        return_module = ViewObj.rootScope.approvemodule;
                    }
                    var productid = id;
                    var urlstring = 'module=Products&action=ProductInfo&return_module=' + return_module +
                                    '&productid=' + productid + '&currencyid=' + currencyid +
                                    '&wareid=&row_id=&frommodule='+return_module;
                    if(ViewObj.rootScope.productsstatus == 'yes'){
                        urlstring += '&accvenid=' + GVObj.crmObj.parentid;
                    }
                    ViewObj.rootScope.operability = 'no';
                    WordReportAjax(urlstring, function (rest) {
                        if (rest == '') return false;
                        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                        ld.each(restobj.result.list, function (key, value) {
                            if (document.getElementById(key) != undefined) {
                                if (key === 'imagename') {
                                    var popimagesStr = '';
                                    if (value != null) {
                                        ld.each(value, function (imagekey, imagevalue) {
                                            popimagesStr += '<div img-detail ><img  img_num=' + (imagekey + 1) + ' src="http://' + loginurl + '/' + imagevalue.option + '" onload="logicHanderObj.loadimg(this)"/></div>';
                                        });
                                    }
                                    ld('#' + key).html(popimagesStr).addClass('view picture-rang picture-preview');
                                }
                                else if (key === 'vendor_id') {
                                }
                                else {
                                    // console.log('key:'+key+'---'+decodeURIComponent(value));
                                    if(value == null){
                                        value = '';
                                    }
                                    ld('#' + key).val(decodeURIComponent(value));
                                }
                            }
                        });
                        //fieldformulaobj.cur_input_focus_obj=document.getElementById("listprice");
                        fieldformulaobj.CountRowFormulaColumn('');// 传参类型
                        ViewObj.rootScope.operability = 'yes';
                    });
                }
                else if(moduleNameStr == 'Users'){

                }
                else{
                    // module:Users;action:getChooseModuleInfo;curmodule:当前模块;selectmodule:选择模块;id:选择单据id
                    var c_module = module;
                    if(module == 'Approve'){
                        c_module = ViewObj.rootScope.approvemodule;
                    }
                    var urlstring = 'module=Users&action=getChooseModuleInfo&curmodule=' + c_module + '&selectmodule=' + moduleNameStr + '&mode=' + ViewObj.rootScope.mode + '&id=' + id;
                    WordReportAjax(urlstring, function (rest) {
                        if (rest == '') return false;
                        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                        if (ld('#account_id').length === 1 && restobj.result.accountid > 0) {
                            GVObj.crmObj.parentid = restobj.result.accountid;
                            ld('#account_id').val(restobj.result.accountid);
                            ld('#account_idname').html(restobj.result.accountname);
                        }
                        if (ld('#account_id').length === 1 && ld('#contact_id').length === 1 && restobj.result.contactid > 0) {
                            ld('#contact_id').val(restobj.result.contactid);
                            ld('#contact_idname').html(restobj.result.lastname);
                        }

                        if (ld('#vendor_id').length === 1 && restobj.result.vendorid > 0) {
                            GVObj.crmObj.parentid = restobj.result.vendorid;
                            ld('#vendor_id').val(restobj.result.vendorid);
                            ld('#vendor_idname').html(restobj.result.vendorname);
                        }
                        if (ld('#vendor_id').length === 1 && ld('#contact_id').length === 1 && restobj.result.vendorcontactsid > 0) {
                            ld('#contact_id').val(restobj.result.vendorcontactsid);
                            ld('#contact_idname').html(restobj.result.vendorcontacts);
                        } 

                        if (module == 'SalesOrder' && (ViewObj.rootScope.mode == 'create' || ViewObj.rootScope.mode === 'relationcreate') &&
                            ld('#assigned_user_id').length === 1 && restobj.result.smownerid > 0) {
                            ld('#assigned_user_id').val(restobj.result.smownerid);
                            ld('#assigned_user_idname').html(restobj.result.smowner);
                        }
                        if (module == 'ServiceContracts' && (ViewObj.rootScope.mode == 'create' || ViewObj.rootScope.mode === 'relationcreate') &&
                            ld('#ServiceContractsassigned_user_id').length === 1 && restobj.result.smownerid > 0) {
                            ld('#ServiceContractsassigned_user_id').val(restobj.result.smownerid);
                            ld('#ServiceContractsassigned_user_idname').html(restobj.result.smowner);
                        }
                        if (module == 'PurchaseOrder' && (ViewObj.rootScope.mode == 'create' || ViewObj.rootScope.mode === 'relationcreate') &&
                            ld('#assigned_user_id').length === 1 && restobj.result.vsmownerid > 0) {
                            ld('#assigned_user_id').val(restobj.result.vsmownerid);
                            ld('#assigned_user_idname').html(restobj.result.vsmowner);
                        }

                        if (moduleNameStr == 'Accounts' || moduleNameStr == 'Vendors') {
                            GVObj.crmObj.parentid = id;
                        }
                        else if (moduleNameStr == 'VendorContact') {
                            GVObj.crmObj.parentid = restobj.result.vendorid;
                        }

                        if (module == 'HelpDesk' && moduleNameStr == 'Faq') {
                            var descriptionStr = ld('#description').val();
                                solutionStr = ld('#solution').val();
                            if(descriptionStr != ''){
                                descriptionStr += '\n' + restobj.result.base.question;
                            }
                            else{
                                descriptionStr = restobj.result.base.question;
                            }
                            if(solutionStr != ''){
                                solutionStr += '\n' + restobj.result.base.answer;
                            }
                            else{
                                solutionStr = restobj.result.base.answer;
                            }
                            ld('#description').val(descriptionStr);
                            ld('#solution').val(solutionStr);
                        }
                    });

                    if (module == 'PurchaseOrder' && moduleNameStr == 'SalesOrder'){
                        //alert('采购订单选择合同订单加载产品');
                    }

                    //先选择产品再选择客户
                    //修改币种后不含税单价和含税单价修改后最近价格（未税）和最近价格（含税）也需要修改
                    if (moduleNameStr == 'Accounts' && 
                        (module == 'Quotes' || module == 'SalesOrder' || module == 'ServiceContracts' || module == 'PurchaseOrder')){
                        changeCurrencyMoneyFormAccounts(id);
                    }

                    // 佣金单，选择源单
                    if (module == 'Commission' && (moduleNameStr == 'SalesOrder' || moduleNameStr == 'ServiceContracts')){
                        var urlstring = 'module=Users&action=getRelatedData&frommodule=Commission&recordid=' + id;
                        WordReportAjax(urlstring, function (rest) {
                            if (rest == '') return false;
                            var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                            var list = restobj.result.related_list[0];
                            var detail = list.detail;
                            for (var i = 0; i < detail.length; i++) {
                                ld('#'+detail[i]['value']['input_name']).val(detail[i]['value']['value']);
                            }
                        });
                    }
                } 
                if(moduleNameStr == 'Users'){
                    if(ld('#user'+ id).find('.img-circle').find('i').hasClass('lnr-circle')){
                        ld('#user'+ id).parent().find('.img-circle').find('i').removeClass('lnr-circle-solid').addClass('lnr-circle');
                        ld('#user'+ id).find('.img-circle').find('i').removeClass('lnr-circle').addClass('lnr-circle-solid');
                    }
                }
                ld('#' + fieldStr).val(id);
                ld('#' + fieldStr + 'name').html(name);
            }
        }
    }
}

//根据客户ID获取客户地址并计算距离
function getAccountsAddressforSinginDistance(id){
    //根据客户ID，获取客户地址
    var urlstring = 'module=Users&action=getDetailBlock&recordid=' + id + '&setype=AccountsAddress';
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var signaccountAddress = restobj.result.list.address;
        if (signaccountAddress != '') {
            var script = document.createElement("script");
            script.type = "text/javascript";
            script.src = "http://api.map.baidu.com/geocoder/v2/?ak=Hgvb6X18khZw223dBW1hFHuT&callback=getLocationAccounts&output=json&address=" + encodeURIComponent(signaccountAddress);
            document.body.appendChild(script);
        }
        else {
            ld('#crm-sign-view .sign_info .sign_info_left').html('误差（米）：无法计算');
            ld('.positionAccountXY').html('');
        }
    });
}

//签到，选择客户获取客户经纬度
var getLocationAccounts = function (data) {
    if (data.result != undefined) {
        var point = ld('.positionAddressXY').html();
        var pointarr = point.split(",");

        var accountlng = data.result.location.lng,
            accountlat = data.result.location.lat,
            signlng = pointarr[0],
            signlat = pointarr[1];
        ld('.positionAccountXY').html(accountlng + ',' + accountlat);
        var signdistance = Tools.getGreatCircleDistance(signlng, signlat, accountlng, accountlat);
        if (Tools.Number.toInt(signdistance) > 500) {
            signdistance = Tools.Number.toInt(signdistance) - Tools.Number.toInt(500);
        }
        ld('#crm-sign-view .sign_info .sign_info_left').html('误差（米）：' + Tools.Number.toInt(signdistance));
    }
    else {
        ld('.positionAccountXY').html('');
    }
}

//创建、编辑保存
function saveCrmCreateOrEdit(status, mode, callback) {
    var create_status = status.view_name;
    if (!logicHanderObj.Check.Empty()) {//判断是否为空
        ViewObj.rootScope.savestatus = 'no';
        return;
    }
    if (!logicHanderObj.Check.Fieldonly(mode)) {//判断不能重复
        ViewObj.rootScope.savestatus = 'no';
        return;
    }
    if (!logicHanderObj.Check.EmailField()) {//判断Email格式是否正确
        ViewObj.rootScope.savestatus = 'no';
        return;
    }
    GVObj.crmObj.parentid = '';
    var fieldnametypeArr = billfieldStr.split('&&&&&'),
        fieldvalue = '', // 页面中的值
        i = 0;
    for (i = 0; i < fieldnametypeArr.length - 1; i++) {
        fieldnameArr = fieldnametypeArr[i].split(',');
        //对币种、账户字段，取tag属性值
        if (fieldnameArr[0].indexOf('currency_id') >= 0 ||
            fieldnameArr[0].indexOf('bankaccountsetid') >= 0) {
            fieldvalue += '&' + fieldnameArr[0] + '=' + ld('#' + fieldnameArr[0]).attr('tag');
        } else {
            if (fieldnameArr[2] == 'val') {
                fieldvalue += '&' + fieldnameArr[0] + '=' + ld('#' + fieldnameArr[0]).val();
            } else if (fieldnameArr[2] == 'html') {
                fieldvalue += '&' + fieldnameArr[0] + '=' + ld('#' + fieldnameArr[0]).html();
            }
            else if (fieldnameArr[2] == 'selectmore') {
                fieldvalue += '&' + fieldnameArr[0] + '=' + ld('#' + fieldnameArr[0]).attr('chossen_items');
            }
            else if (fieldnameArr[2] == 'checkbox') {
                var checkvalue = ld('#' + fieldnameArr[0]).html();
                if(checkvalue=='是'){
                    checkvalue = 1;
                }
                else{
                    checkvalue = 0;
                }
                fieldvalue += '&' + fieldnameArr[0] + '=' + checkvalue;
            }
        }
    }
    var mode_module = '',
        old_mode_module = '';
    if (create_status === 'relationcreate') {
        mode_module = newmodule;
    }
    else {
        mode_module = module;
    }
    //审批中心，编辑保存
    if(mode_module == 'Approve'){
        mode_module = ViewObj.rootScope.approvemodule;
    }
    if (mode_module === 'Singin') {
        old_mode_module = 'Singin';
        mode_module = 'Accounts';
    }
    else {
        old_mode_module = mode_module;
    }
    //联系人：birthday应小于当前日期
    if ((mode_module === 'Contacts' && ld('#birthday').length === 1) ||
        (mode_module === 'VendorContact' && ld('#birthday').length === 1)) {
        var birthday_date = DateContorlObj.getDateValue('birthday');
        if (!empty(birthday_date)) {
            birthday_date = birthday_date.replace(/-/g, "/");
            birthday_date = new Date(birthday_date);
            var curent_date = Tools.CurentTime.dateEn();
            curent_date = curent_date.replace(/-/g, "/");
            curent_date = new Date(curent_date);
            if (Date.parse(birthday_date) >= Date.parse(curent_date)) {
                PopPromptBox.show(ld('#birthday').parent().find('i').text() + '应小于当前日期');
                ViewObj.rootScope.savestatus = 'no';
                return;
            }
        }
    }
    //客户服务单：servicetype包含“上门”时，判断hopetime、hopetime_end、hope_address不可为空
    if (mode_module === 'HelpDesk' && ld('#servicetype').length === 1 && ld('#servicetype').html().indexOf('上门') > -1) {
        if (!logicHanderObj.Check.SpecialEmpty('hopetime')) {
            ViewObj.rootScope.savestatus = 'no';
            return;
        }
        if (!logicHanderObj.Check.SpecialEmpty('hopetime_end')) {
            ViewObj.rootScope.savestatus = 'no';
            return;
        }
        if (!logicHanderObj.Check.SpecialEmpty('hope_address')) {
            ViewObj.rootScope.savestatus = 'no';
            return;
        }
    }
    //客户服务单：hopetime_end必须晚于hopetime
    if (mode_module === 'HelpDesk' && ld('#hopetime').length === 1 && ld('#hopetime_end').length === 1) {
        if (!logicHanderObj.Check.DateField('hopetime', 'hopetime_end')) {
            ViewObj.rootScope.savestatus = 'no';
            return;
        }
    }
    //公告：enddate必须晚于startdate
    if (mode_module === 'PublicAnnouncement' && ld('#startdate').length === 1 && ld('#enddate').length === 1) {
        if (!logicHanderObj.Check.DateField('startdate', 'enddate')) {
            ViewObj.rootScope.savestatus = 'no';
            return;
        }
    }
    //市场活动：closingdate必须晚于startdate
    if (mode_module === 'Campaigns' && ld('#startdate').length === 1 && ld('#closingdate').length === 1) {
        if (!logicHanderObj.Check.DateField('startdate', 'closingdate')) {
            ViewObj.rootScope.savestatus = 'no';
            return;
        }
    }
    //项目：targetenddate须晚于startdate
    if (mode_module === 'Project' && ld('#startdate').length === 1 && ld('#targetenddate').length === 1) {
        if (!logicHanderObj.Check.DateField('startdate', 'targetenddate')) {
            ViewObj.rootScope.savestatus = 'no';
            return;
        }
    }
    //项目：actualenddate必须晚于startdate
    if (mode_module === 'Project' && ld('#startdate').length === 1 && ld('#actualenddate').length === 1) {
        if (!logicHanderObj.Check.DateField('startdate', 'actualenddate')) {
            ViewObj.rootScope.savestatus = 'no';
            return;
        }
    }
    //项目任务：enddate必须晚于startdate
    if (mode_module === 'ProjectTask' && ld('#startdate').length === 1 && ld('#enddate').length === 1) {
        if (!logicHanderObj.Check.DateField('startdate', 'enddate')) {
            ViewObj.rootScope.savestatus = 'no';
            return;
        }
    }
    //项目任务：actualenddate必须晚于startdate
    if (mode_module === 'ProjectTask' && ld('#startdate').length === 1 && ld('#actualenddate').length === 1) {
        if (!logicHanderObj.Check.DateField('startdate', 'actualenddate')) {
            ViewObj.rootScope.savestatus = 'no';
            return;
        }
    }
    var urlstring = 'module=' + mode_module + '&action=Save&userid=' + userid + fieldvalue;
    if (mode === 'create') {
        urlstring += '&createview=create_view';
        if (GVObj.crmObj.quickcreateStatus == 'yes') {
            urlstring += '&mode=quick&quickcreate_publicaccount=yes';
        } else {
            urlstring += '&mode=create';
        }
        if (mode_module == 'Accounts') {
            urlstring += '&publicaccount=' + ViewObj.rootScope.publicaccount;
        }
        if (mode_module == 'Contacts' || mode_module == 'VendorContact') {
            urlstring += '&CamCard_RelatedCreate=' + status.CamCard_RelatedCreate;
        }
    }
    else if (mode === 'edit') {
        urlstring += '&mode=edit&record=' + recordID;
    }
    //产品字段
    if (mode_module == 'SalesOrder' ||
        mode_module == 'Quotes' ||
        mode_module == 'ServiceContracts' ||
        mode_module == 'PurchaseOrder') {
        if (productcount <= 0) {
            PopPromptBox.show('您还没有添加产品');
            ViewObj.rootScope.savestatus = 'no';
            return;
        }
        var currency_id = ld('#prev_inventory_currency').val(),
            productfiledStr = '',
            productSubtotal = 0,//价税合计 小计
            ptotal = logicHanderObj.rmoney(ld('#crm-addproduct-footer span[tag=productmoney]').html()),//合计
            pdiscount_amount = ld('#sub_discount_amount').val(),//整单折扣
            padjustment = ld('#adjustment').val(),//调整金额
            pcount = 0,//产品数
            selectDiscount = ld('#selectDiscount').attr('tag'),
            adjustmentType = ld('#adjustmentType').attr('tag');
        if (ld('#productSubtotal').length === 1) {
            productSubtotal = logicHanderObj.rmoney(ld('#productSubtotal').html());
        }
        for (var i = 1; i <= rowcnt; i++) {
            if (document.getElementById('hdnProductId' + i) != undefined) {
                productfiledStr += '&hidden_rowid_' + i + '=' + ld('#hidden_rowid_' + i).val() +
                    '&hdnProductId' + i + '=' + ld('#hdnProductId' + i).val();
                ld.each(arrProductObj, function (key, list) {
                    if (list.newline == null || list.newline == '0') {
                        productfiledStr += '&' + list.columnname + i + '=' + ld('#' + list.columnname + i).val();
                    }
                });
            }
        }
        urlstring += productfiledStr + '&rowcnt=' + rowcnt + '&adjustmentType=' +
            adjustmentType + '&allSingledDiscount=' + selectDiscount +
            '&inventory_currency=' + currency_id + '&subtotal=' + productSubtotal + '&total=' + ptotal +
            '&discount_amount=' + pdiscount_amount + '&adjustment=' + padjustment;
    }
    //费用报销
    if (mode_module == 'Expense') {
        var expensefiledStr = '',
            expensemoney = ld('#crm-addexpense-footer>ul>li>[tag=expensemoney]').html(),//获取费用报销总金额
            expensemoney = expensemoney.split((",")).join("");
        if (productcount <= 0) {
            PopPromptBox.show('您还没有添加费用清单');
            ViewObj.rootScope.savestatus = 'no';
            return;
        }
        for (var i = 1; i <= rowcnt; i++) {
            if (ld('#expenselistUL>[row=' + i + ']').length > 0) {
                expensefiledStr += '&hidden_rowid_' + i + '=' + ld('#hidden_rowid_' + i).val();
                if (mode === 'edit') {
                    expensefiledStr += '&expensedetailid' + i + '=' + ld('#expensedetailid' + i).val();
                }
                ld.each(arrExpenseObj, function (key, list) {
                    if (list.newline == '1') {
                        return;
                    }
                    expensefiledStr += '&' + list.fieldname + i + '=' + ld('#' + list.fieldname + i).val();
                })
            }
        }
        urlstring += expensefiledStr + '&rowcnt=' + rowcnt + '&total=' + expensemoney + '&currency_id=1';
    }
    //OA表单字段
    if (mode_module == 'AddJobBill' ||
        mode_module == 'MinusJobBill' ||
        mode_module == 'BusinessApply' ||
        mode_module == 'Commission') {
        if (productcount <= 0) {
            PopPromptBox.show('您还没有添加明细');
            ViewObj.rootScope.savestatus = 'no';
            return;
        }
        var oadetailfiledStr = '',
            padjustment = '',//调整金额
            adjustmentType = '',//调整
            oadetailcostorday = ld('#crm-addoadetail-footer>ul>li>[tag=oadetailtotal]').html(),//获取费用报销总金额
            oadetailcostorday = oadetailcostorday.split((",")).join("");
        if (mode_module == 'Commission'){
            padjustment = ld('#adjustment').val();//调整金额
            adjustmentType = ld('#adjustmentType').attr('tag');//调整
        }
        for (var i = 1; i <= rowcnt; i++) {
            if (ld('#oadetaillistUL>[row=' + i + ']').length > 0) {
                oadetailfiledStr += '&hidden_rowid_' + i + '=' + ld('#hidden_rowid_' + i).val();
                if (mode === 'edit') {
                    oadetailfiledStr += '&lineitem_id' + i + '=' + ld('#lineitem_id' + i).val();
                }
                ld.each(arrOaDetailObj.listfield, function (key, list) {
                    oadetailfiledStr += '&' + list.columnname + i + '=' + ld('#' + list.columnname + i).val();
                })
            }
        }
        urlstring += oadetailfiledStr + '&rowcnt=' + rowcnt + '&total=' + oadetailcostorday;
        if (mode_module == 'Commission'){
            urlstring += '&adjustmentType=' + adjustmentType + '&noamount=' + padjustment;
        }
    }
    //图片功能
    if (imgid != '') {
        urlstring += '&attachmentsid=' + imgid;
    }
    //产品税别
    if (tax_cur.length >= 1) {
        ld.each(tax_cur, function (key, taxname) {
            if (ld('#' + taxname + '_check').is(":checked") == true) {
                var taxValue = ld('#' + taxname).val();
                urlstring += '&' + taxname + '_check=1&' + taxname + '=' + taxValue;
            }
        });
    }
    // 附件功能
    if(ViewObj.rootScope.att_arr != undefined){
        var atts_arr = ViewObj.rootScope.att_arr;
        if(phoneversion == 'android'){
            for(var i=0;i<atts_arr.length;i++){
                var att_str = atts_arr[i];
                var att_arr = att_str.split('&&&&');
                var j = i+1;
                urlstring += '&file_name_'+j+'='+encodeURIComponent(att_arr[1]) + '&file_path_'+j+'='+att_arr[0] + 
                             '&file_size_'+j+'='+att_arr[2] + '&file_type_'+j+'='+att_arr[3];
            }
            urlstring += '&file_num='+atts_arr.length + '&phoneversion=android';
        }
        else{
            for(var i=0;i<atts_arr.length;i++){
                var j = i+1;
                urlstring += '&file_name_'+j+'='+encodeURIComponent(atts_arr[i]['name']) + '&file_path_'+j+'='+atts_arr[i]['path'] + 
                             '&file_size_'+j+'='+atts_arr[i]['size'] + '&file_type_'+j+'='+atts_arr[i]['type'];
                
            }
            urlstring += '&file_num='+atts_arr.length + '&phoneversion=ios' ;
        }
    }
    // ViewObj.rootScope.savestatus = 'no';
    // console.log(urlstring);
    // return;
    ld("#status").show();
    WordReportAjax(urlstring, function (rest) {
        ld('#status').hide();
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        imgid = ''; // 全局变量赋值
        // 如果失败弹出提示
        if (restobj.code == -1) {
            PopPromptBox.show(restobj.msg);
            ld('#poplayerMask').hide();
            ViewObj.rootScope.savestatus = 'no';
            return;
            // 跳转到明细页
        } else {
            //返回到相关信息列表
            if (create_status === 'relationcreate') {
                //明细界面关联数量增加
                if ((module === 'Accounts' && ld('#account_id').val() == recordID) ||
                    (module === 'Contacts' && ld('#contact_id').val() == recordID) ||
                    (module === 'SalesOrder' && ld('#salesorder_id').val() == recordID) ||
                    (module === 'Potentials' && ld('#potential_id').val() == recordID) ||
                    (module === 'Quotes' && ld('#quote_id').val() == recordID) ||
                    (module === 'ServiceContracts' && ld('#servicecontractsid').val() == recordID) ||
                    (module === 'ServiceCharge' && ld('#account_id').val() == recordID) ||
                    (module === 'HelpDesk' && ld('#troubleticketid').val() == recordID) ||
                    (module === 'Campaigns' && ld('#campaignid').val() == recordID) ||
                    (module === 'Project' && ld('#projectid').val() == recordID) ||
                    (module === 'ProjectTask' && ld('#projecttaskid').val() == recordID) ||
                    (module === 'Vendors' && ld('#vendor_id').val() == recordID) ||
                    (module === 'VendorContact' && ld('#contact_id').val() == recordID) ||
                    (module === 'PurchaseOrder' && ld('#projecttaskid').val() == recordID)) {

                    if(newmodule == 'SalesOrder' && restobj.result.sys_130 == '1'){
                        // ld('#rellist_' + related_id).parent().find('div[moudle="ServiceContracts"]');
                        // alert(ld('#rellist_' + related_id).parent().find('div[moudle="ServiceContracts"]').find('span').text());
                        var rellistid = ld('#rellist_' + related_id).parent().find('div[moudle="ServiceContracts"]').attr('id');
                        var num_service = ld('#' + rellistid).find('i').html();
                        if (empty(num_service) || 1 > num_service) num_service = 0;
                        else num_service = parseInt(num_service);
                        num_service += 1;
                        ld('#' + rellistid).find('i').html(num_service);
                    }
                    var num = ld('#rellist_' + related_id).find('i').html();
                    if (empty(num) || 1 > num) num = 0;
                    else num = parseInt(num);
                    num += 1;
                    ld('#rellist_' + related_id).find('i').html(num);
                }
                ViewObj.switchView('cwn-relationlist-view', 'init', {
                    'module': newmodule,
                    'label': newmodulename,
                    'is_related_module': relatedmodule,
                    'record': relatedrecord,
                    'relatedid': related_id
                });
            }
            else {
                if (old_mode_module === 'Singin') {
                    ViewObj.switchView('crm-sign-view', 'back');
                    ld('#accountid').html(restobj.result.recordID);
                    ld('#accountName').html(ld('#accountname').val());
                    getAccountsAddressforSinginDistance(restobj.result.recordID);//根据客户ID获取客户地址并计算距离 
                }
                else {
                    if(mode!='edit'){
                        recordID = restobj.result.recordID; // 全局变量赋值
                    }
                    if(category == 'news' || category_for == 'apply'){
                        var urlstring = 'module=' + mode_module;
                        ViewObj.switchView('cwn-crmdetail-view', 'init', {
                            'url_string': urlstring,
                            __direction: 'right_out',
                            __status:'approve_status'
                        });
                    }
                    else{
                        if(ld('#assigned_user_id').val() != userid){
                            ViewObj.switchView('crm-list-view', 'init');
                        }
                        else{
                            var urlstring = 'module=' + module;
                            ViewObj.switchView('cwn-crmdetail-view', 'init', {
                                'url_string': urlstring,
                                __direction: 'right_out',
                                onSwitchAfter: function () {
                                    //将crm-list-view ,当前页设置为第一页
                                    SwiperObj.ListPageObj.setListPageIndex(1, 'crm-list-view');
                                    EventHanderObj.refreshCrmList(function () { // 刷新crm列表
                                        ViewObj.setScrollTop('crm-list-view', 0); // 设置crm-list-view滚动到顶端
                                    });
                                }
                            });
                        }  
                    }
                }
            }
        }
        callback();
    });
}

//获取用户信息、搜索用户信息
function getUserList(user_searchObj, callback) {
    //用户查找，填充条件
    var return_module = user_searchObj.return_module,
        searchtype = user_searchObj.searchtype,
        filterown = user_searchObj.filterown,
        scopetype = user_searchObj.scopetype,
        common = user_searchObj.common,
        isactive = user_searchObj.isactive;
    var urlstring = 'module=Home&action=ListView&method=getGroupUsers' +
        '&return_module=' + return_module + '&searchtype=' + searchtype + '&filterown=' + filterown +
        '&scopetype=' + scopetype + '&common=' + common + '&isactive=' + isactive + '&searchcontent=';
    if(user_searchObj.popup_type==='publicallocate'){
        urlstring += '&ishighseaallocate=yes';
    }
    else{
        urlstring += '&popup_type='+user_searchObj.popup_type;
    }
    WordReportAjax(urlstring, function (rest) {
        if (rest == '') return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var userhtml = '';
        if (restobj.Colleague == '') {
            userhtml = logicHanderObj.NoinfoNotice('数据');
        } else {
            userhtml += '<ul class="listimg">';
            ld.each(restobj.Colleague, function (userkey, userobj) {
                if (!userobj.lastname.value) userobj.lastname.value = '--';
                if(userobj.userlevel == undefined){
                    userhtml += '<li tag="user' + userobj.userid.value + '" item="popu_select"><div><img src="http://' + loginurl + '/' + userobj.userimgpath.value + '" onload="logicHanderObj.loadimg(this)"/></div>';
                    userhtml += '<span class="center text-ellipsis"><i class="text-ellipsis">' + userobj.lastname.value + '</i>' + userobj.description.value + '</span>';
                    userhtml += '<span class="img-circle"><i class="lnr-circle"></i></span></li>';
                }
                else{
                    if (!userobj.userlevel.value) {
                        userobj.userlevel.value = '';
                    } else {
                        userobj.userlevel.value = ' - ' + userobj.userlevel.value;
                    }
                    userhtml += '<li tag="user' + userobj.userid.value + '" item="popu_select"><div><img src="http://' + loginurl + '/' + userobj.userimgpath.value + '" onload="logicHanderObj.loadimg(this)"/></div>';
                    userhtml += '<span class="center text-ellipsis"><i class="text-ellipsis">' + userobj.lastname.value + '</i>' + userobj.profilename.value + userobj.userlevel.value + '</span>';
                    userhtml += '<span class="img-circle"><i class="lnr-circle"></i></span></li>';
                }
            });
            userhtml += '</ul>';
        }
        ld('#cwn-popuselect-view>.content-wrapper ').html(userhtml);
        callback();
    });
}

//联动
function pickListChoose(sourceField, sourceValue) {
    var frommoduleName = '';
    if (ViewObj.rootScope.list_create === 'relationcreate') {
        frommoduleName = newmodule;
    }
    else if (ViewObj.rootScope.list_create === 'create') {
        frommoduleName = module;
    }
    else{
        if(module==='Singin'){
            frommoduleName = 'Accounts';
        }
    }
    var urlstring = 'module=Users&action=getSourceTargetValue&sourcefield=' + sourceField +
        '&sourcevalue=' + sourceValue + '&frommodule=' + frommoduleName;
    WordReportAjax(urlstring, function (rest) {
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        //有关联操作才会继续执行
        var _key = '',
            listitems = '';
        if (restobj.code == 1) {
            if (restobj.result.list != null) {
                ld.each(restobj.result.list, function (key, list) {
                    _key = key;
                    if (list != null) {
                        ld.each(list, function (fieldkey, fieldvalue) {
                            listitems += fieldkey + '&&' + fieldvalue + '|##|';
                        });
                        ld('#' + _key).attr('items', listitems);
                    }
                    else {
                        ld('#' + _key).attr('items', '--无--&&--无--|##|');
                    }

                    ld('#' + key).html('').attr('tag', '');
                });
            }
            else {
                ld('#' + _key).attr('items', '--无--&&--无--|##|');
            }
        }
        if(ViewObj.rootScope.defaultstate != '' && sourceField == 'bill_state'){
            ld('#bill_state').attr('tag',sourceValue);
            ld('#bill_state').html(sourceValue);
        }
        if(ViewObj.rootScope.defaultcity != '' && sourceField == 'bill_city'){
            ld('#bill_city').attr('tag',sourceValue);
            ld('#bill_city').html(sourceValue);
        }
    });
}

//保存菜单显示设置
commonHandleObj.saveModuleShowset = function (showtype, labeltype, userid) {
    var urlstring = 'module=Home&action=ListView&method=savemoduleshowset' +
        '&showtype=' + showtype + '&type=' + labeltype;
    WordReportAjax(urlstring, function (rest) {
    });
}
//明细界面点击地图
var getLocationformAddress = function (data) {
    if (data.result != undefined) {
        ld('#mapBox').css({'width': SwiperObj.PHONE_WIDTH, 'height': SwiperObj.PHONE_HEIGHT});
        map = new BMap.Map("mapBox");
        var point = new BMap.Point(data.result.location.lng, data.result.location.lat);
        map.centerAndZoom(point, 15);
        var marker = new BMap.Marker(point);  // 创建标注
        map.addOverlay(marker);               // 将标注添加到地图中
    }
    else {
        PopPromptBox.show('获取地图失败，无法定位');
        return;
    }
}

//消息三级页面信息获取及展示
newsObj.getNewsThirdList = function (viewname, urlstring, callback) {
    if ('' === urlstring) return;
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);

        if(viewname==='myreply_list' || viewname==='mypraise_list'){
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
        }
        var listhtml = '';
        var userimage = '';
        var currentpage = '';
        var havenextpage = '';
        switch (viewname) {
            case 'myreply_list':   // 工作提醒 --> 我发出工作的回复、@我的回复
                if (empty(restobj.list)) {
                    listhtml = logicHanderObj.NoinfoNotice('数据');
                }
                ld.each(restobj.list, function (key, list) {//列表循环
                    if (empty(list)) return false;
                    userimage = 'images/defaultuser.png';
                    if (!empty(list.userimage)) {
                        userimage = 'http://' + loginurl + '/' + list.userimage;
                    }
                    //转换表情路径
                    list.replycontent = Tools.escape2Html(list.replycontent.replace(new RegExp("themes/softed", "gm"), 'images'));
                    list.reportcontent = Tools.escape2Html(list.reportcontent.replace(new RegExp("themes/softed", "gm"), 'images'));
                    userimg = '<img src="' + userimage + '" alt="" class="name-img" onload="logicHanderObj.loadimg(this)"/>';
                    listhtml += '<div class="area-list">';
                    listhtml += '    <div class="areal-top" tag="list" workreportid="' + list.reportid + '" reporttypestr="' + list.reporttypeStr + '">';
                    listhtml += '        <div class="areal-user">';
                    listhtml += '            <div class="a-user-pic" userid="' + list.replyuserid + '">' + userimg + '</div>';
                    listhtml += '            <div class="a-user-rgt" style="width:81%;">';
                    listhtml += '                <div class="a-user-intro">' + list.replyusername + '：' + list.replycontent + '</div>';
                    listhtml += '                <div class="clear"></div>';
                    listhtml += '                <div class="optcontent">' + list.reportcontent + '</div>';
                    listhtml += '                <div class="a_other_time">' + list.createdtime + '<span></span></div>';
                    listhtml += '            </div>';
                    listhtml += '        </div>';
                    listhtml += '    </div>';
                    listhtml += '</div>';
                });
                break;
            case 'mypraise_list': //  工作提醒 --> 我收到的赞
                if (empty(restobj.list)) {
                    listhtml = logicHanderObj.NoinfoNotice('赞');
                }
                ld.each(restobj.list, function (key, list) {//列表循环
                    if (empty(list)) return false;
                    userimage = 'images/defaultuser.png';
                    if (!empty(list.userimage)) {
                        userimage = 'http://' + loginurl + '/' + list.userimage;
                    }
                    userimg = '<img src="' + userimage + '" alt="" class="name-img" onload="logicHanderObj.loadimg(this)">';
                    //转换表情路径
                    list.content = Tools.escape2Html(list.content.replace(new RegExp("themes/softed", "gm"), 'images'));
                    nameaftertxt = '赞了我的工作';
                    listhtml += '<div class="area-list">';
                    listhtml += '    <div class="areal-top" tag="list" workreportid="' + list.curid + '" reporttypestr="' + list.reporttypeStr + '">';
                    listhtml += '        <div class="areal-user">';
                    listhtml += '            <div class="a-user-pic" userid="' + list.praiseuserid + '">' + userimg + '</div>';
                    listhtml += '            <div class="a-user-rgt" style="width:81%;">';
                    listhtml += '                <div class="a-user-intro">' + list.praiseusername + '：' + nameaftertxt + '</div>';
                    listhtml += '                <div class="clear"></div>';
                    listhtml += '                <div class="optcontent">' + list.content + '</div>';
                    listhtml += '                <div class="a_other_time">' + list.createdtime + '<span></span></div>';
                    listhtml += '            </div>';
                    listhtml += '        </div>';
                    listhtml += '    </div>';
                    listhtml += '</div>';
                });
                break;
            case 'message_list': // 消息提醒，列表界面
                if (empty(restobj.list)) {
                    listhtml = logicHanderObj.NoinfoNotice('消息');
                }
                userimage = 'images/defaultuser.png';
                if (!empty(restobj.userinfo.image)) {
                    userimage = 'http://' + loginurl + '/' + restobj.userinfo.image;
                }
                var userimgStr = '<img class="name-img" alt="" src="' + userimage + '" onload="logicHanderObj.loadimg(this)">';
                //列表循环
                ld.each(restobj.list, function (key, list) {
                    if (!list.reltablabel) list.reltablabel = '';
                    if (!list.relatetolabel) list.relatetolabel = '';
                    if (!list.content) list.content = '';
                    listhtml += '<div class="area-list">';
                    listhtml += '    <div class="areal-top" tag="list" workreportid="' + list.curid + '">';
                    listhtml += '        <div class="areal-user">';
                    listhtml += '            <div class="a-user-pic">' + userimgStr + '</div>';
                    listhtml += '            <div class="a-user-rgt">';
                    listhtml += '                <div class="a-user-intro">' + restobj.userinfo.lastname + '</div>';
                    listhtml += '                <div class="clear"></div>';
                    listhtml += '                <div class="a_user_time">' + list.remindtime + '</div>';
                    listhtml += '            </div>';
                    listhtml += '        </div>';
                    listhtml += '    </div>';
                    listhtml += '    <div class="areal_mid_con">';
                    listhtml += '         <div class="areal_notice">';
                    listhtml += '             <p>' + list.reltablabel + '<span class="fontBlue">' + list.relatetolabel + '</span></p>';
                    listhtml += '             <p>' + list.content + '</p>';
                    listhtml += '         </div>';
                    listhtml += '    </div>';
                    listhtml += '</div>';
                });
                break;
            case 'approve_list': // 审批提醒，列表界面
                if (empty(restobj.result.list1)) {
                    listhtml = logicHanderObj.NoinfoNotice('审批');
                }else{
                    //字段公式
                    if (ld.inArray(ViewObj.rootScope.approvemodule, formulaArray) >= 0) {
                        getJsScript('js/producttool/DateTime.js', function () {
                        });
                        getJsScript('js/producttool/toolField.js', function () {
                        });
                        getJsScript('js/producttool/mobileformula.js', function () {
                        });
                        getJsScript('js/producttool/TabDetailFields.js', function () {
                        });
                        getJsScript('js/producttool/TabDetailFieldFormula.js', function () {
                        });
                    }
                    var list_class = 'crm-lists';
                    if (ViewObj.rootScope.approvemodule == 'ContactRecords' || ViewObj.rootScope.approvemodule == 'VendorContactRecords') {
                        list_class = 'crm-lists line3';
                    } 
                    //计算多少行
                    if (!empty(restobj.result.list1)) {
                        if(restobj.result.list1[0].title){
                            var i = 1;
                            ld.each(restobj.result.list1[0].field, function (listfieldkey, listfieldinfo) {
                                i++;
                            });
                            list_class = 'crm-lists line'+i;
                        }
                    }    
                    listhtml = '<ul class="'+ list_class +'">';
                    listhtml += getlistData(restobj.result.list1, ViewObj.rootScope.approvemodule);//输出列表
                    listhtml += '</ul>';
                }
                break;
            case 'notice_list': // 公告提醒，列表界面
                if (empty(restobj.list)) {
                    listhtml = logicHanderObj.NoinfoNotice('公告');
                } else {
                    listhtml = '<ul class="crm-lists">';
                    ld.each(restobj.list, function (key, list) {
                        listhtml += '<li record="' + list.curid + '">';
                        listhtml += '   <h5>' + list.subject + '</h5>';
                        listhtml += '   <p>';
                        listhtml += '       <span>' + list.createdtime + '</span> | <span>' + list.lastname + '</span>';
                        listhtml += '   </p>';
                        listhtml += '</li>';
                    });
                    listhtml += '</ul>';
                }
                break;
        }
        var _id = '#' + ViewObj.getCurrentViewId() + ' .pubDetialC';
        var content_holder = ld(_id);
        if (SwiperObj.is_addMore) {//如果是刷新就 不清空原来的内容
            content_holder.html(content_holder.html() + listhtml);
        } else {//搜索和 刷新都要清空原来的内容
            content_holder.html(listhtml);
        }
        if (viewname === 'approve_list') {
            currentpage = restobj.result.curpagenum;
            havenextpage = restobj.result.havenextpage;
        } else {
            currentpage = restobj.summary.curpagenum;
            havenextpage = restobj.summary.havenextpage;
        }
        SwiperObj.ListPageObj.setListPageIndex(currentpage, ViewObj.getInfo('to_viewid'));
        SwiperObj.ListPageObj.setHasNextPage(havenextpage, ViewObj.getInfo('to_viewid'));
        callback();
    });
};

// 定义跳转all-userinfo-view(me资料，设置页)的方法  及click处理定义
ViewObj['create-all-userinfo-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', scope.title_str, '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        var c_vname = opts_obj.view_name,
            initFun = null,
            title_str = '';
        scope.c_vname = c_vname;
        ld('#all-userinfo-view').html('');
        if (c_vname === 'crmset') {
            title_str = '模块设置';
            initFun = getMeCrmsetData;
        }
        else if (c_vname === 'remindsset') {
            title_str = '提醒设置';
            initFun = getMeRemindsetData;
        }
        else if (c_vname === 'edit_medetail'||c_vname === 'onlymeinfo') {
            title_str = '我的资料';
            initFun = getMeDetailData;
        }
        scope.title_str = title_str;
        scope.view_name = opts_obj.view_name;
        scope.prev_header= ViewObj.getPrevInfo('header');
        ViewObj.toViewCommon(to_viewid, ['<', '', '', title_str, '', ''], opts_obj);
        scope.prev_footerid= ViewObj.getPrevInfo('footerid');
        initFun(function () {
            ViewObj.onSwitchAfter(opts_obj);
        });
        scope.prev_vid = ViewObj.getPrevInfo('viewid');
    }
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 头部左边
        if (t_id === 'head_left') {
            ViewObj.switchView(scope.prev_vid, 'back', {
                __scroll_top: 'origin',
                __app_header: scope.prev_header,
                __footer_id: scope.prev_footerid
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = null;
        // 点击模块设置，消息提醒设置，模块开启/关闭
        if (targetobj[0].tagName.toLowerCase() === 'span' && 'open@@close'.indexOf(targetobj.attr('class')) > -1) {
            var tg = targetobj.attr('class'),
                moudleset = targetobj.parent().attr('moudleset'),
                openstatus = '';
            if (tg === 'open') {
                targetobj.attr('class', 'close');
            }
            else if (tg === 'close') {
                targetobj.attr('class', 'open');
            }
            if (scope.view_name === 'remindsset') {
                openstatus = tg === 'open' ? 'close' : 'open';
                meHandleObj.saveRemindSet(targetobj.parent().attr('remindset'), openstatus, userid);//保存提醒设置
            }
            else if (scope.view_name === 'crmset') {
                meHandleObj.saveModuleSet(moudleset, userid);//保存CRM设置
                MeCRMHomeLoaded();//设置再次进入CRM需要刷新
            }
            // 点击详细资料页
        } else if (targetobj.parents('ul.userinfo-lists').length === 1) {
            _this = targetobj.parents('li');
            if (_this.length === 1 ||
                targetobj[0].tagName.toLowerCase() === 'li') {
                _this = _this.length ? _this : targetobj;
                if (!_this.attr('tag')) {
                    return;
                }
                if (_this.attr('tag') === 'update_image') {
                    logicHanderObj.popUpMaskToggle('tplPhone');//显示拍照获取方式弹出层和遮罩层
                    return;
                }
                ViewObj.switchView('cwn-popuedit-view', 'init', {
                    view_name: 'me_updateinfo',
                    update_type: _this.attr('tag'),
                    target_obj: _this.find('span:last')
                });
            }
        }
    };
};
function getMeDetailData(callback) {
    var urlstring = 'module=Home&action=ListView&method=getMeInfo&type=view';
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var report = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var imagenameStr = '', listhtml = '';
        userimage = 'images/defaultuser.png';
        if (!empty(report.userinfo.imagename)) {
            userimage = 'http://' + loginurl + '/' + report.userinfo.imagename;
        }
        imagenameStr = '<img class="name-img" src="' + userimage + '" onload="logicHanderObj.loadimg(this)">';
        ld('#image_new_home').html('<img tag="userimage" src="' + userimage + '" onload="logicHanderObj.loadimg(this)">');
        listhtml += '<ul class="userinfo-lists">' +
            '   <li tag="update_image">' +
            '          <span class="left">头像</span>' +
            '          <i class="lnr-chevron-right"></i>' +
            '          <span class="right nomargin text-ellipsis picture-preview" id="image_new">' + imagenameStr + '</span>' +
            '    </li>' +
            '    <li tag="update_password">' +
            '           <span class="left">密码</span>' +
            '           <i class="lnr-chevron-right"></i>' +
            '           <span class="right nomargin text-ellipsis">立即修改</span>' +
            '    </li>' +
            '</ul>';
        listhtml += '<ul class="userinfo-lists ">' +
            '    <li>' +
            '           <span class="left">账号</span>' +
            '           <i class="lnr-chevron-right visi-hide"></i>' +
            '           <span class="right nomargin text-ellipsis">' + report.userinfo.user_name + '</span>' +
            '    </li>' +
            '   <li tag="update_lastname">' +
            '           <span class="left">姓名</span>' +
            '           <i class="lnr-chevron-right"></i>' +
            '           <span class="right nomargin text-ellipsis" id="lastname_new">' + report.userinfo.last_name + '</span>' +
            '    </li>' +
            '    <li>' +
            '           <span class="left">角色</span>' +
            '           <i class="lnr-chevron-right visi-hide"></i>' +
            '           <span class="right nomargin text-ellipsis">' + report.userinfo.profilename + '</span>' +
            '    </li>' +
            '    <li tag="update_email">' +
            '           <span class="left">Email</span>' +
            '           <i class="lnr-chevron-right"></i>' +
            '           <span class="right nomargin text-ellipsis" id="email_new">' + report.userinfo.email1 + '</span>' +
            '    </li>' +
            '    <li tag="update_mobile">' +
            '           <span class="left">手机</span>' +
            '           <i class="lnr-chevron-right"></i>' +
            '           <span class="right nomargin text-ellipsis" id="phone_new">' + report.userinfo.phone_mobile + '</span>' +
            '    </li>' +
            '</ul>' +
            '<ul class="userinfo-lists text">' +
            '   <li>' +
            '            <span class="left text-ellipsis">允许查看全景资料</span>' +
            '            <span class="right">' + report.userinfo.accountallview + '</span>' +
            '   </li>' +
            '   <li>' +
            '            <span class="left text-ellipsis">允许查看其他用户单据</span>' +
            '            <span class="right">' + report.userinfo.viewothers + '</span>' +
            '    </li>' +
            '    <li>' +
            '            <span class="left text-ellipsis">允许编辑其他用户单据</span>' +
            '            <span class="right">' + report.userinfo.editothers + '</span>' +
            '    </li>' +
            '    <li>' +
            '            <span class="left text-ellipsis">允许删除其他用户单据</span>' +
            '            <span class="right">' + report.userinfo.delothers + '</span>' +
            '    </li>' +
            '    <li>' +
            '            <span class="left text-ellipsis">允许查询自己创建的单据</span>' +
            '            <span class="right">' + report.userinfo.viewselfbills + '</span>' +
            '    </li>' +
            '    <li>' +
            '            <span class="left text-ellipsis">允许编辑其他用户单据的手机号码字段</span>' +
            '            <span class="right">' + report.userinfo.edit_other_mobile + '</span>' +
            '    </li>';
        '    <li>';
        '            <span class="left text-ellipsis">手机号码显示样式根据系统参数控制</span>' +
        '            <span class="right">' + report.userinfo.is_mobile_style + '</span>' +
        '    </li>' +
        '</ul>';
        ld('#all-userinfo-view').html(listhtml);
        callback();
    });
}
function getMeCrmsetData(callback) {
    var urlstring = 'module=Home&action=ListView&method=getMeModules';
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var listmodule = '',
            listmodulename = '',
            openstatus = '',
            listhtml = '';
        listhtml = '<div class="crm-home crmset" class="ui-hide">';
        var listhtml_dashboard = '',
            listhtml_accounts = '',
            listhtml_sales = '',
            listhtml_service = '',
            listhtml_project = '',
            listhtml_finacial = '',
            listhtml_purchase = '',
            listhtml_stock = '',
            listhtml_other = '';
        ld.each(restobj.result.list, function (key, list) {
            listmodule = list.module; listmodulename = list.title; openstatus = 'close';
            if (list.display == 'yes') {
                openstatus = 'open';
            }
            if (list.parenttab == 'Dashboard') {
                listhtml_dashboard += '<li moudleset="' + listmodule + '"><a href="javascript:void(0);"><img src="images/crm_' + listmodule + '.png"></a><span class="listmodulenamelab">' + listmodulename + '</span><span class="' + openstatus + '"></span></li>';
            } else if (list.parenttab == 'Accounts') {
                listhtml_accounts += '<li moudleset="' + listmodule + '"><a href="javascript:void(0);"><img src="images/crm_' + listmodule + '.png"></a><span class="listmodulenamelab">' + listmodulename + '</span><span class="' + openstatus + '"></span></li>';
            } else if (list.parenttab == 'Sales') {
                listhtml_sales += '<li moudleset="' + listmodule + '"><a href="javascript:void(0);"><img src="images/crm_' + listmodule + '.png"></a><span class="listmodulenamelab">' + listmodulename + '</span><span class="' + openstatus + '"></span></li>';
            } else if (list.parenttab == 'Service') {
                listhtml_service += '<li moudleset="' + listmodule + '"><a href="javascript:void(0);"><img src="images/crm_' + listmodule + '.png"></a><span class="listmodulenamelab">' + listmodulename + '</span><span class="' + openstatus + '"></span></li>';
            } else if (list.parenttab == 'Project') {
                listhtml_project += '<li moudleset="' + listmodule + '"><a href="javascript:void(0);"><img src="images/crm_' + listmodule + '.png"></a><span class="listmodulenamelab">' + listmodulename + '</span><span class="' + openstatus + '"></span></li>';
            } else if (list.parenttab == 'Finacial') {
                listhtml_finacial += '<li moudleset="' + listmodule + '"><a href="javascript:void(0);"><img src="images/crm_' + listmodule + '.png"></a><span class="listmodulenamelab">' + listmodulename + '</span><span class="' + openstatus + '"></span></li>';
            } else if (list.parenttab == 'Purchase') {
                listhtml_purchase += '<li moudleset="' + listmodule + '"><a href="javascript:void(0);"><img src="images/crm_' + listmodule + '.png"></a><span class="listmodulenamelab">' + listmodulename + '</span><span class="' + openstatus + '"></span></li>';
            } else if (list.parenttab == 'Stock') {
                listhtml_stock += '<li moudleset="' + listmodule + '"><a href="javascript:void(0);"><img src="images/crm_' + listmodule + '.png"></a><span class="listmodulenamelab">' + listmodulename + '</span><span class="' + openstatus + '"></span></li>';
            } else if (list.parenttab == 'Other') {
                listhtml_other += '<li moudleset="' + listmodule + '"><a href="javascript:void(0);"><img src="images/crm_' + listmodule + '.png"></a><span class="listmodulenamelab">' + listmodulename + '</span><span class="' + openstatus + '"></span></li>';
            }
        });
        if (listhtml_dashboard != '') {
            listhtml += '<ul class="set-lists">' + listhtml_dashboard + '</ul>';
        }
        if (listhtml_accounts != '') {
            listhtml += '<ul class="set-lists">' + listhtml_accounts + '</ul>';
        }
        if (listhtml_sales != '') {
            listhtml += '<ul class="set-lists">' + listhtml_sales + '</ul>';
        }
        if (listhtml_service != '') {
            listhtml += '<ul class="set-lists">' + listhtml_service + '</ul>';
        }
        if (listhtml_project != '') {
            listhtml += '<ul class="set-lists">' + listhtml_project + '</ul>';
        }
        if (listhtml_finacial != '') {
            listhtml += '<ul class="set-lists">' + listhtml_finacial + '</ul>';
        }
        if (listhtml_purchase != '') {
            listhtml += '<ul class="set-lists">' + listhtml_purchase + '</ul>';
        }
        if (listhtml_stock != '') {
            listhtml += '<ul class="set-lists">' + listhtml_stock + '</ul>';
        }
        if (listhtml_other != '') {
            listhtml += '<ul class="set-lists">' + listhtml_other + '</ul>';
        }
        listhtml += '</div>';
        ld('#all-userinfo-view').html(listhtml);
        callback();
    });
}
function getMeRemindsetData(callback) {
    var urlstring = 'module=Home&action=ListView&method=getRemindSet';
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var workreminds = restobj.list.push_work_reminds;
        var newsreminds = restobj.list.push_news_reminds;
        var workremindsstatus = 'close', newsremindsstatus = 'close';
        if (workreminds == 1) {
            workremindsstatus = 'open';
        }
        if (newsreminds == 1) {
            newsremindsstatus = 'open';
        }
        var listhtml = '<div class="crmset"><ul class="set-lists">';
        listhtml += '<li remindset="PushWork"><span class="listmodulenamelab">推送工作提醒</span><span class="' + workremindsstatus + '"></span></li>';
        listhtml += '<li remindset="PushMessage"><span class="listmodulenamelab">推送消息提醒</span><span class="' + newsremindsstatus + '"></span></li>';
        listhtml += '</ul></div>';
        ld('#all-userinfo-view').html(listhtml);
        callback();
    });
}

// 定义跳转cwn-attview-view(附件查看)的方法  及click处理定义
ViewObj['create-cwn-attview-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', scope.title, '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        scope.curr_viewid = ViewObj.getCurrentViewId();
        scope.title = opts_obj.title_str;
        scope.__footer_id = ViewObj.getPrevInfo('footerid');
        var ext = opts_obj.ext,
            att_path_name = 'http://' + loginurl + '/' + opts_obj.att_path;
        if(ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'bmp' || ext == 'gif' || ext == 'tiff' ){
            var att_str = '<img src="' + att_path_name + '" onload="logicHanderObj.loadimg(this)" >';
            ld('#cwn-attview-view').html(att_str);
        }
        ViewObj.toViewCommon(to_viewid, ['<', '', '', scope.title, '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    }
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 头部左边
        if (t_id === 'head_left') {
            ViewObj.switchView(scope.curr_viewid, 'back', {
                __scroll_top: 'origin',
                __footer_id: scope.__footer_id,
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {        
    };
};
// 定义跳转到crm-createeditsub-view的方法 编辑产品，编辑费用报销单页， 及click处理定义
ViewObj['create-crm-createeditsub-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', scope.title_str, '', '确定'], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        var title_str = '',
            _this = null;
        scope.view_name = opts_obj.view_name;
        ViewObj.rootScope.operability = 'yes';
        if (scope.view_name === 'product') {
            if (ViewObj.rootScope.trade == 'finance' && productcount == 1) {
                PopPromptBox.show('金融行业只能添加一个产品')
                return false;
            }
            getProductInfo();
            title_str = '产品明细';
            if (ViewObj.rootScope.productstatus === 'edit') {
                _this = opts_obj.target_obj;
                editproductid = _this.attr('productid');
                editproductrow = _this.attr('row');
                ld('#hdnProductId').val(ld('#hdnProductId' + editproductrow).val());
                ld.each(arrProductObj, function (key, list) {
                    if (list.newline == 0) {
                        if (list.columnname == 'productname') {
                            ld('#productnamename').html(ld('#' + list.columnname + editproductrow).val());
                        }
                        else {
                            var uitypeInt = parseInt(list.uitype);
                            if (uitypeInt == 60 || uitypeInt == 56) {
                                var valueStr = ld('#' + list.columnname + editproductrow).val();
                                if(uitypeInt == 56){
                                    if(valueStr == '1'){
                                        valueStr = '是';
                                    }
                                    else{
                                        valueStr = '否';
                                    } 
                                }
                                ld('#'+ list.columnname +'_p').html(valueStr);
                            }
                            var columnnameStr = ld('#' + list.columnname + editproductrow).val();
                            if (10 <= uitypeInt && uitypeInt <= 50) {
                                if (uitypeInt == 10) {
                                    columnnameStr = Tools.Number.toDecimal(columnnameStr, parseInt(ViewObj.rootScope.sys_49));
                                }
                                else if (uitypeInt == 15) {
                                    if(list.columnname==='usageunit'){
                                        columnnameStr = columnnameStr;
                                    }
                                    else{
                                        var numTypeArr = list.typedata.split(",");
                                        if (numTypeArr[1] == 0) {
                                            columnnameStr = Tools.Number.toInt(columnnameStr);
                                        }
                                        else {
                                            columnnameStr = Tools.Number.toDecimal(columnnameStr, parseInt(numTypeArr[1]));
                                        }
                                    }                                    
                                }
                                else if (uitypeInt == 20) {
                                    var numTypeArr = list.typedata.split(",");
                                    if (numTypeArr[1] == 0) {
                                        columnnameStr = Tools.Number.toInt(columnnameStr);
                                    }
                                    else {
                                        columnnameStr = Tools.Number.toDecimal(columnnameStr, parseInt(numTypeArr[1]));
                                    }
                                }
                                else if (uitypeInt == 24) {
                                    columnnameStr = Tools.Number.toInt(columnnameStr);
                                }                                
                                else {
                                    columnnameStr = Tools.Number.toDecimal(columnnameStr, 2);
                                }
                            }
                            else if (uitypeInt == 163 || uitypeInt == 730 || uitypeInt == 731 || uitypeInt == 810 || uitypeInt == 811) {
                                columnnameStr = Tools.Number.toDecimal(columnnameStr, parseInt(ViewObj.rootScope.sys_93));
                            }
                            ld('#crm-createeditsub-view #' + list.columnname).val(columnnameStr);
                        }
                    }
                });
            }            
            var fieldinfojson = arrFormulaFieldObj;
            fieldformulaobj = new fieldFormula(fieldinfojson, ViewObj.rootScope.sys_49, ViewObj.rootScope.sys_93);
            fieldformulaobj.setEvent('');
        }
        else if (scope.view_name === 'expense') {
            getaddExpenseInfo();//获取费用清单信息            
            title_str = '费用报销单明細';
            if (ViewObj.rootScope.productstatus === 'edit') {
                _this = opts_obj.target_obj;
                editproductrow = _this.attr('row');
                ld.each(arrExpenseObj, function (key, list) {
                    var valueStr = ld('#' + list.fieldname + editproductrow).val();
                    if (list.type === 'Amount' || list.type === 'RMB_Amount') {//金额、人民币金额
                        valueStr = Tools.Number.toDecimal(valueStr, parseInt(2));
                    }
                    else if (list.type === 'Number' || list.type === 'Rate') {//数量;Rate: 汇率
                        valueStr = Tools.Number.toDecimal(valueStr, parseInt(ViewObj.rootScope.sys_49));
                    }
                    else if (list.type === 'Num') {//数字
                        var typeofdataNum = list.typeofdata;
                        var typeofdataNumArr = typeofdataNum.split('~');
                        var numFloat = typeofdataNumArr[2].split(',')[1];
                        valueStr = Tools.Number.toDecimal(valueStr, parseInt(numFloat));
                    }
                    else if (list.type === 'Price') {//单价
                        valueStr = Tools.Number.toDecimal(valueStr, parseInt(ViewObj.rootScope.sys_93));
                    }
                    else if (list.type === 'SelectCurrency') {
                        var currencyValue = '';
                        var currencyArr = ld('#' + list.fieldname).attr('items').split('|##|');
                        for (var i = 0; i < currencyArr.length - 1; i++) {
                            currencyFieldArr = currencyArr[i].split('&&');
                            if (currencyFieldArr[0] === valueStr) {
                                currencyValue = currencyFieldArr[1];
                            }
                        }
                        ld('#' + list.fieldname).html(currencyValue);
                        ld('#' + list.fieldname).attr('tag', valueStr);
                    } 
                    else if (list.type === 'SelectSource') {
                        if(list.fieldname === 'entitytypeid'){
                            var currencyValue = '',
                                entitytype_tabid = ld('#entitytype_tabid' + editproductrow).val(),
                                entitytypeid = ld('#entitytypeid' + editproductrow).val(),
                                entitytype_tabname = ld('#entitytype_tabname' + editproductrow).val(),
                                entitytype_name = ld('#entitytype_name' + editproductrow).val();
                            var currencyArr = ld('#select_entitytypeid').attr('items').split('|##|');
                            for (var i = 0; i < currencyArr.length - 1; i++) {
                                currencyFieldArr = currencyArr[i].split('&&');
                                if (currencyFieldArr[0] === entitytype_tabid) {
                                    currencyValue = currencyFieldArr[1];
                                }
                            }
                            ld('#select_entitytypeid').html(currencyValue);
                            ld('#select_entitytypeid').attr('tag', entitytype_tabid);
                            ld('#entitytypeid').val(entitytypeid);
                            ld('#entitytypeidname').html(entitytype_name);
                            ld('#entitytypeidname').attr('choose_module', entitytype_tabname);
                            ld('#entitytypeidname').attr('flid_lable', currencyValue);
                        }
                    }
                    
                    if (list.type === 'Select' || list.type === 'CheckBox') {
                        if(list.type === 'CheckBox'){
                            if(valueStr == '1'){
                                valueStr = '是';
                            }
                            else{
                                valueStr = '否';
                            }
                        }
                        ld('#' + list.fieldname).html(valueStr);
                    } 
                    else {
                        ld('#' + list.fieldname).val(valueStr);
                    }
                });
            }
            var fieldinfojson = arrFormulaFieldObj;
            fieldformulaobj = new tabDetailFieldFormula(fieldinfojson, ViewObj.rootScope.sys_49, ViewObj.rootScope.sys_93);
            fieldformulaobj.setEvent('');
        }
        else if (scope.view_name === 'oadetail') {
            getaddOadetailInfo();//获取OA明細界面信息
            title_str = '分录明细';
            if (ViewObj.rootScope.productstatus === 'edit') {
                _this = opts_obj.target_obj;
                editproductrow = _this.attr('row');
                ld.each(arrOaDetailObj.listfield, function (key, list) {
                    var valueStr = ld('#' + list.columnname + editproductrow).val();
                    if (list.fieldtype_orign_mc === 'Amount') {//金额
                        valueStr = Tools.Number.toDecimal(valueStr, parseInt(2));
                    }
                    else if (list.fieldtype_orign_mc === 'Number') {//数量
                        valueStr = Tools.Number.toDecimal(valueStr, parseInt(ViewObj.rootScope.sys_49));
                    }
                    else if (list.fieldtype_orign_mc === 'Num') {//数字
                        var typeofdataNum = list.typedata;
                        var typeofdataNumArr = typeofdataNum.split('~');
                        var numFloat = typeofdataNumArr[2].split(',')[1];
                        valueStr = Tools.Number.toDecimal(valueStr, parseInt(numFloat));
                    }
                    else if (list.fieldtype_orign_mc === 'Price') {//单价
                        valueStr = Tools.Number.toDecimal(valueStr, parseInt(ViewObj.rootScope.sys_93));
                    }
                    else if (list.fieldtype_orign_mc === 'SelectCurrency') {
                        var currencyValue = '';
                        var currencyArr = ld('#' + list.columnname).attr('items').split('|##|');
                        for (var i = 0; i < currencyArr.length - 1; i++) {
                            currencyFieldArr = currencyArr[i].split('&&');
                            if (currencyFieldArr[0] === valueStr) {
                                currencyValue = currencyFieldArr[1];
                            }
                        }
                        ld('#' + list.columnname).html(currencyValue);
                        ld('#' + list.columnname).attr('tag', valueStr);
                    } 
                    else if (list.fieldtype_orign_mc === 'entitytype') {
                        var currencyValue = '',
                            entitytype_tabid = ld('#entitytype_tabid' + editproductrow).val(),
                            entitytypeid = ld('#entitytypeid' + editproductrow).val(),
                            entitytype_tabname = ld('#entitytype_tabname' + editproductrow).val(),
                            entitytype_name = ld('#entitytype_name' + editproductrow).val();
                        var currencyArr = ld('#select_entitytype').attr('items').split('|##|');
                        for (var i = 0; i < currencyArr.length - 1; i++) {
                            currencyFieldArr = currencyArr[i].split('&&');
                            if (currencyFieldArr[0] === entitytype_tabid) {
                                currencyValue = currencyFieldArr[1];
                            }
                        }
                        ld('#select_entitytype').html(currencyValue);
                        ld('#select_entitytype').attr('tag', entitytype_tabid);
                        ld('#entitytypeid').val(entitytypeid);
                        ld('#entitytypeidname').html(entitytype_name);
                        ld('#entitytypeidname').attr('choose_module', entitytype_tabname);
                        ld('#entitytypeidname').attr('flid_lable', currencyValue);
                    }
                    else if (list.fieldtype_orign_mc === 'SelectSource') {
                        var currencyValue = '',
                            entitytype_tabid = ld('#entitytype_tabid' + editproductrow).val(),
                            entitytypeid = ld('#entitytypeid' + editproductrow).val(),
                            entitytype_tabname = ld('#entitytype_tabname' + editproductrow).val(),
                            entitytype_name = ld('#entitytype_name' + editproductrow).val();
                        var currencyArr = ld('#select_entitytype').attr('items').split('|##|');
                        for (var i = 0; i < currencyArr.length - 1; i++) {
                            currencyFieldArr = currencyArr[i].split('&&');
                            if (currencyFieldArr[0] === entitytype_tabid) {
                                currencyValue = currencyFieldArr[1];
                            }
                        }
                        ld('#select_entitytype').html(currencyValue);
                        ld('#select_entitytype').attr('tag', entitytype_tabid);
                        ld('#entitytypeid').val(entitytypeid);
                        ld('#entitytypeidname').html(entitytype_name);
                        ld('#entitytypeidname').attr('choose_module', entitytype_tabname);
                        ld('#entitytypeidname').attr('flid_lable', currencyValue);
                    }
                    
                    if (list.fieldtype_orign_mc === 'Select' || list.fieldtype_orign_mc === 'CheckBox') {
                        if(list.fieldtype_orign_mc === 'CheckBox'){
                            if(valueStr == '1'){
                                valueStr = '是';
                            }
                            else{
                                valueStr = '否';
                            }
                        }
                        ld('#' + list.columnname).html(valueStr);
                    } 
                    else {
                        ld('#' + list.columnname).val(valueStr);
                    }
                });
            }
            //赋值字段公式
            var fieldinfojson = arrFormulaFieldObj;
            fieldformulaobj = new tabDetailFieldFormula(fieldinfojson, ViewObj.rootScope.sys_49, ViewObj.rootScope.sys_93);
            fieldformulaobj.setEvent('');
        }
        scope.title_str = title_str;
        scope.prev_header = ViewObj.getPrevInfo('header');
        ViewObj.toViewCommon(to_viewid, ['<', '', '', title_str, '', '确定'], opts_obj);
        scope.prev_footerid = ViewObj.getPrevInfo('footerid');
        scope.prev_viewid = ViewObj.getPrevInfo('viewid');
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id,
            flag = false;
        // 点击头部左边
        if (t_id === 'head_left') {
            ViewObj.switchView(scope.prev_viewid, 'back', {
                __scroll_top: 'origin',
                __app_header: scope.prev_header,
                __footer_id: scope.prev_footerid
            });
        } else if (t_id === 'head_rig' && ViewObj.rootScope.operability == 'yes') {
            if (scope.view_name === 'product') {
                flag = saveEditsubProduct();
            } else if (scope.view_name === 'expense') {
                flag = saveEditsubExpense();
            } else if (scope.view_name === 'oadetail') {
                flag = saveEditsubOadetail();
            }
            if (flag === false) return;
            ViewObj.switchView(scope.prev_viewid, 'back', {
                __scroll_top: 'origin',
                __app_header: scope.prev_header,
                __footer_id: scope.prev_footerid
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        OperationObj.triggerCilckEvent(targetobj, 'body', { view_id: 'crm-createedit-view' });
    }
};
//产品信息读取
function getProductInfo() {
    var producthtml = '<div>';
    //不显示，并且有字段公式的自定义字段
    if (noArrProductObj) {
        ld.each(noArrProductObj, function (key, list) {
            producthtml += '<input id="' + list.columnname + '" type="hidden" value="0.00" name="' +
                list.columnname + '">';
        });
    }
    producthtml += '<ul class="c-ul c-edit-cell">';
    //显示字段
    ld.each(arrProductObj, function (key, list) {
        if (list.newline) {
            list.fieldlabel = list.fieldlabel ? list.fieldlabel : '';
            list.defaultvalu = list.defaultvalu ? list.defaultvalu : '';
            //必录项加*
            var typeArr = '', numTypeArr = '',
                starStr = '';
            if (list.typedata != '' && list.typedata != null) {
                typeArr = list.typedata.split("~");
                if (typeArr[1] == "M") {
                    //产品把所有必录字段信息都列出来
                    if (list.columnname == 'productname') {
                        fieldcheckEmptyStr += 'productnamename,' + list.fieldlabel + ',html&&&&&';
                    }
                    else {
                        if (list.uitype == 56) {
                            fieldcheckEmptyStr += list.columnname + ',' + list.fieldlabel + ',html&&&&&';
                        }
                        else{
                            fieldcheckEmptyStr += list.columnname + ',' + list.fieldlabel + ',val&&&&&';
                        }
                    }
                    starStr = '<strong>*</strong>';
                }
            }
            if (list.newline == 0) {
                if (list.uitype == 70 && list.columnname!='procreatedtime') {
                    producthtml += '<li class=arrow-right><i>' + starStr + list.fieldlabel + '</i><span class="lnr-chevron-right"></span>';
                }
                else if (list.uitype == 60 || list.uitype == 56) {
                    producthtml += '<li class=arrow-right><i>' + starStr + list.fieldlabel + '</i><span class="lnr-chevron-right"></span>';
                }
                else if (list.uitype == 2 || list.uitype == 3) {
                    producthtml += '<li class="heightauto"><i>' + starStr + list.fieldlabel + '</i>';
                }
                else if (list.uitype == 69) {//图片
                    producthtml += '<li class="imglichoose"><i>' + starStr + list.fieldlabel + '</i>';
                }
                else {
                    producthtml += '<li><i>' + starStr + list.fieldlabel + '</i>';
                }
                if (typeArr[0] == "N" || typeArr[0] == "NN") {
                    if (list.defaultvalue == '') list.defaultvalue = '0.00';
                }
                if (list.edit_permission == 2) {
                    if (parseInt(list.uitype) == 69) {//图片
                        producthtml += '<div id="' + list.columnname + '" name="' + list.columnname + '" ></div>';
                    }
                    else {
                        producthtml += '<input id="' + list.columnname + '" name="' + list.columnname + '"' +
                            'type="text" value="' + list.defaultvalue + '" readonly="true" />';
                    }
                }
                else {
                    var uitypeInt = parseInt(list.uitype);
                    var edit_permissionInt = parseInt(list.edit_permission);
                    if (uitypeInt == 70) {//产品名称
                        producthtml += '<input id="hdnProductId" name="hdnProductId" ' +
                            'type="hidden" value="" /><b class="text-ellipsis"' +
                            'popu_select="choose_module" fild_id="' + list.columnname +
                            '" flid_lable="' + list.fieldlabel + '" choose_module="Products"' +
                            ' desc="products" parentstatus="yes" id="' + list.columnname +
                            'name" name="' + list.columnname + 'name"></b>';
                    }
                    else if (uitypeInt < 9) {//文本：1:文本，2:文本域，3:产品描述
                        if (uitypeInt == 2 || uitypeInt == 3) {
                            if (list.defaultvalue == null) {
                                list.defaultvalue = '';
                            }
                            if (edit_permissionInt == 0) {
                                producthtml += '<textarea id="' + list.columnname + '" name="' + list.columnname + '">' + list.defaultvalue + '</textarea>';
                            } else {
                                producthtml += '<textarea id="' + list.columnname + '" name="' + list.columnname + '" readonly>' + list.defaultvalue + '</textarea>';
                            }
                        } else {
                            if (edit_permissionInt == 0) {
                                producthtml += '<input id="' + list.columnname + '" name="' + list.columnname + '" type="text" value="' + list.defaultvalue + '" />';
                            } else {
                                producthtml += '<input id="' + list.columnname + '" name="' + list.columnname + '" type="text" value="' + list.defaultvalue + '" readonly/>';
                            }
                        }
                    }
                    else if(uitypeInt==60 || uitypeInt == 56){//下拉框、多选框
                        var listitems = '&&|##|是&&是|##|否&&否|##|';
                        var _selectedval = list.defaultvalue;//保存默认值
                        var _showsearch = 'false';
                        if(_selectedval == '是' || _selectedval == '1'){
                            _selectedval = '是';
                        }
                        else{
                            _selectedval = '否';
                        }
                        producthtml += '<b class="text-ellipsis" id="' + list.columnname + '" name="' + list.columnname +
                                        '" popu_select="drop_down_list" title_str="' + list.fieldlabel + '" show_search="' + _showsearch +
                                        '" select_mode="single" items="' + listitems + '" desc="products" >' + _selectedval + '</b>';
                    }
                    else if(uitypeInt==60 || uitypeInt == 56){//下拉框、多选框
                        var listitems = '';
                        var _selectedval = '';
                        var _showsearch = 'true';
                        if (list.options) {
                            ld.each(list.options, function (key, options) {   //构建数组
                                listitems += options.value + '&&' + options.text + '|##|';                                
                            });
                            if (list.options.length <= 8) _showsearch = 'false';
                        }
                        producthtml += '<b class="text-ellipsis" id="' + list.columnname + '_p" name="' + list.columnname +
                                        '_p" popu_select="drop_down_list" title_str="' + list.fieldlabel + '" show_search="' + _showsearch +
                                        '" select_mode="single" items="' + listitems + '" desc="products" >' + _selectedval + '</b>';
                    }
                    else if (10 <= uitypeInt && uitypeInt <= 50) {//10-15数量、15-20数字、20-25整数、25-50金额
                        //整数:24、数字:20、数量:10、单价:163、金额:50
                        var defaultvalueStr = '';
                        if (uitypeInt == 24) {
                            defaultvalueStr = Tools.Number.toInt(list.defaultvalue);
                        }
                        else if (uitypeInt == 15 || uitypeInt == 20) {
                            numTypeArr = list.typedata.split(",");
                            if (numTypeArr[1] == 0) {
                                defaultvalueStr = Tools.Number.toInt(list.defaultvalue);
                            }
                            else {
                                defaultvalueStr = Tools.Number.toDecimal(list.defaultvalue, parseInt(numTypeArr[1]));
                            }
                        }
                        else if (uitypeInt == 10) {
                            defaultvalueStr = Tools.Number.toDecimal(list.defaultvalue, parseInt(ViewObj.rootScope.sys_49));
                        }
                        else {
                            defaultvalueStr = Tools.Number.toDecimal(list.defaultvalue, 2);
                        }
                        if (edit_permissionInt === 0) {
                            producthtml += '<input id="' + list.columnname + '" name="' +
                                list.columnname + '" type="number" value="' + defaultvalueStr + '" />';
                        }
                        else {
                            producthtml += '<input id="' + list.columnname + '" name="' +
                                list.columnname + '" type="number" value="' + defaultvalueStr + '" readonly />';
                        }
                    }
                    else if (uitypeInt == 163 || uitypeInt == 730 || uitypeInt == 731 || uitypeInt == 810 || uitypeInt == 811) {//单价字段
                        var defaultvalueStr = Tools.Number.toDecimal(list.defaultvalue, parseInt(ViewObj.rootScope.sys_93));
                        if (edit_permissionInt == 0) {
                            producthtml += '<input id="' + list.columnname + '" name="' + list.columnname + '" type="number" value="' + defaultvalueStr + '" />';
                        }
                        else {
                            producthtml += '<input id="' + list.columnname + '" name="' + list.columnname + '" type="number" value="' + defaultvalueStr + '" readonly />';
                        }
                    }
                    else if (50 < uitypeInt && uitypeInt < 55) {//日期
                        if (uitypeInt == 51) {//yyyy-mm-dd
                            producthtml += '<input id="' + list.columnname + '" name="' + list.columnname + '" type="text" tag="date-control-date" readonly="true" />';
                            DateContorlObj.addDateControlInfo('productbox_date_field', list.columnname, 'date', list.defaultvalue);
                        }
                        if (uitypeInt == 52) {//yyyy-mm-dd hh:mm:ss日期+时间
                            producthtml += '<input id="' + list.columnname + '" name="' + list.columnname + '" type="text" tag="date-control-datetime" readonly="true" />';
                            DateContorlObj.addDateControlInfo('productbox_date_field', list.columnname, 'datetime', list.defaultvalue);
                        }
                        if (uitypeInt == 53 || uitypeInt == 54) {//53,hh:mm;54,hh:mm:ss
                            producthtml += '<input id="' + list.columnname + '" name="' + list.columnname + '" type="text" tag="date-control-time" readonly="true" />';
                            DateContorlObj.addDateControlInfo('productbox_date_field', list.columnname, 'time', list.defaultvalue);
                        }
                    }
                }
                producthtml += '</li>';
            }
        }
    });
    producthtml += '</ul></div>';
    ld('#crm-createeditsub-view').html(producthtml);
    DateContorlObj.bingDateContrl('productbox_date_field');
}
//获取费用清单信息
function getaddExpenseInfo() {
    var tplnode = '<div><ul class="c-ul c-edit-cell">';
    ld.each(arrExpenseObj, function (key, fieldinfo) {
        var starStr = '';
        if (fieldinfo.typeofdata != '' && fieldinfo.typeofdata != null) {
            //必录项加*
            var typeArr = fieldinfo.typeofdata.split("~");
            if (typeArr[1] == "M") {
                if(fieldinfo.type == 'Select' || fieldinfo.type == 'SelectCurrency' || 
                    fieldinfo.type == 'SelectSource' || fieldinfo.type === 'CheckBox'){
                    if(fieldinfo.fieldname == 'entitytypeid'){
                        fieldcheckEmptyStr += 'select_entitytypeid,源单类型,html&&&&&';
                        fieldcheckEmptyStr += 'entitytypeidname,' + fieldinfo.fieldlabel + ',html&&&&&';
                    }
                    else{
                        fieldcheckEmptyStr += fieldinfo.fieldname + ',' + fieldinfo.fieldlabel + ',html&&&&&';
                    }
                }
                else{
                    fieldcheckEmptyStr += fieldinfo.fieldname + ',' + fieldinfo.fieldlabel + ',val&&&&&';                        
                }
                starStr = '<strong>*</strong>';
            }
        }
        if (fieldinfo.newline == '1') {
            return;
        }
        var readonlyStr = '';
        if (fieldinfo.edit_permission === '1') {
            readonlyStr = 'readonly=true';
        }
        if (fieldinfo.type === 'Text') {//Text：文本
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" ' + readonlyStr + ' type="text" value="' + fieldinfo.hiddenvalue + '" />';
        }
        else if (fieldinfo.type === 'Number' || fieldinfo.type === 'Rate') {//Number: 数量;Rate: 汇率
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" ' + readonlyStr + ' type="number" value="' + Tools.Number.toDecimal(fieldinfo.hiddenvalue, parseInt(ViewObj.rootScope.sys_49)) + '" />';
        }
        else if (fieldinfo.type === 'Price') {//Pirce: 单价 
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" ' + readonlyStr + ' type="number" value="' + Tools.Number.toDecimal(fieldinfo.hiddenvalue, parseInt(ViewObj.rootScope.sys_93)) + '" />';
        }
        else if (fieldinfo.type === 'Num') {//Num: 数字
            var defaultvalueStr = '',
                numTypeArr = fieldinfo.typeofdata.split(",");
            if (numTypeArr[1] == 0) {
                defaultvalueStr = Tools.Number.toInt(fieldinfo.hiddenvalue);
            }
            else {
                defaultvalueStr = Tools.Number.toDecimal(fieldinfo.hiddenvalue, parseInt(numTypeArr[1]));
            }
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" ' + readonlyStr + ' type="number" value="' + defaultvalueStr + '" />';
        }
        else if (fieldinfo.type === 'Amount') {//Amount: 金额
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" ' + readonlyStr + ' type="number" value="' + Tools.Number.toDecimal(fieldinfo.hiddenvalue, 2) + '" />';
        }
        else if (fieldinfo.type === 'RMB_Amount') {//RMB_Amount：人民币金额
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" ' + readonlyStr + ' type="number" value="" />';
        }
        else if (fieldinfo.type === 'Int') {//Int:  整形
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" ' + readonlyStr + ' type="number" value="' + Tools.Number.toInt(fieldinfo.hiddenvalue) + '" />';
        }
        else if (fieldinfo.type === 'Select' || fieldinfo.type === 'SelectCurrency' || 
                 fieldinfo.type === 'SelectSource' || fieldinfo.type === 'CheckBox') {//Select：下拉框、SelectCurrency：币种
            if (fieldinfo.type === 'SelectSource') {
                tplnode += '<li class="arrow-right"><i>' + starStr + '源单类型</i><span class="lnr-chevron-right"></span>';
            }
            else{
                tplnode += '<li class="arrow-right"><i>' + starStr + fieldinfo.fieldlabel + '</i><span class="lnr-chevron-right"></span>';   
            }
            var listitems = '';
            var _selectedval = '';
            var _showsearch = 'true';
            if (fieldinfo.options != null && fieldinfo.options != '') {
                ld.each(fieldinfo.options, function (key, options) {   //构建数组
                    if (fieldinfo.type === 'SelectCurrency') {
                        listitems += options.value + '&&' + options.text + '&&' + options.rate + '|##|';
                    }
                    else if (fieldinfo.type === 'SelectSource') {
                        listitems += options.value + '&&' + options.text + '&&' + options.name + '|##|';
                    }
                    else {
                        listitems += options.value + '&&' + options.text + '|##|';
                    }
                    if (options.value == fieldinfo.hiddenvalue) {
                        _selectedval = options.text;
                    }
                });
                if (fieldinfo.options.length <= 8) _showsearch = 'false';
            }
            else{
                if(fieldinfo.type === 'CheckBox'){
                    listitems = '&&|##|是&&是|##|否&&否|##|';
                    _selectedval = fieldinfo.hiddenvalue;//保存默认值
                    if(_selectedval == '是' || _selectedval == '1'){
                        _selectedval = '是';
                    }
                    else{
                        _selectedval = '否';
                    }
                    _showsearch = 'false';
                }   
            }

            var ddltitle = fieldinfo.fieldlabel;
            if (ddltitle.indexOf(' ') >= 0) {   //去掉字段名空格
                ddltitle = ddltitle.split(' ')[0];
            }
            if (fieldinfo.type === 'SelectCurrency') {
                //tplnode += '<input id="'+fieldinfo.fieldname+'" name="'+fieldinfo.fieldname+'" type="hidden" value="">';
                tplnode += '<b class="text-ellipsis" id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname +
                    '" popu_select="drop_down_list" title_str="' + ddltitle + '" show_search="' + _showsearch +
                    '" select_mode="single" items="' + listitems + '" desc="products" tag="1">' + _selectedval + '</b>';
            }
            else if (fieldinfo.type === 'SelectSource') {
                tplnode += '<b class="text-ellipsis" id="select_' + fieldinfo.fieldname + '" name="select_' + fieldinfo.fieldname +
                    '" popu_select="drop_down_list" title_str="' + ddltitle + '" show_search="' + _showsearch +
                    '" select_mode="single" items="' + listitems + '" desc="products" tag="'+ fieldinfo.hiddenvalue +'">' + _selectedval + '</b>';
            }
            else {
                tplnode += '<b class="text-ellipsis" id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname +
                    '" popu_select="drop_down_list" title_str="' + ddltitle + '" show_search="' + _showsearch +
                    '" select_mode="single" items="' + listitems + '" desc="products" >' + _selectedval + '</b>';
            }
            if (fieldinfo.type === 'SelectSource') {
                var _choose_module = '',
                    _flid_lable = '';
                ld.each(fieldinfo.options, function (key, options) {//构建数据
                    if (options.value == fieldinfo.hiddenvalue) {
                        _choose_module = options.name;
                        _flid_lable = options.text;
                    }
                });
                tplnode += '<li class="arrow-right"><i>' + starStr + fieldinfo.fieldlabel+'</i><span class="lnr-chevron-right"></span>';
                tplnode += '<input id="entitytypeid" type="hidden" value="" name="entitytypeid">' +
                    '<b class="text-ellipsis" id="entitytypeidname" name="entitytypeidname" ' +
                    'parentstatus="yes" popu_select="choose_module" fild_id="entitytypeid" ' +
                    'choose_module="' + _choose_module + '" flid_lable="' + _flid_lable + '" ></b>';
            }
        }
        else if (fieldinfo.type === 'Date_Ymd') {
            //Date_Ymd:日期
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" type="text"  tag="date-control-date" readonly="true" />';
            DateContorlObj.addDateControlInfo('productbox_date_field', fieldinfo.fieldname, 'date', fieldinfo.hiddenvalue);
        }
        else if (fieldinfo.type === 'Date_YmdHms') {
            //Date_YmdHms:日期时间HH:mm:ss
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" type="text"  tag="date-control-datetime" readonly="true" />';
            DateContorlObj.addDateControlInfo('productbox_date_field', fieldinfo.fieldname, 'datetime', fieldinfo.hiddenvalue);
        }
        else if (fieldinfo.type === 'Date_Hm' || fieldinfo.type === 'Date_Hms') {
            //Date_Ymd:日期,Date_YmdHms:日期时间HH:mm:ss,Date_Hm:时间HH:mm,Date_Hms:时间 HH:mm:ss
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '" type="text"  tag="date-control-time" readonly="true" />';
            DateContorlObj.addDateControlInfo('productbox_date_field', fieldinfo.fieldname, 'time', fieldinfo.hiddenvalue);
        }
        else if (fieldinfo.type === 'TextArea') {//TextArea:文本区域
            tplnode += '<li class="heightauto"><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<textarea id="' + fieldinfo.fieldname + '" name="' + fieldinfo.fieldname + '">' + fieldinfo.hiddenvalue + '</textarea>';
        }
        else if (fieldinfo.type === 'Span') {//Span:查看
            return;
        }
        tplnode += '</li>';
    });
    tplnode += '</ul>';
    tplnode += '<div class="bottomFixed"></div>';
    tplnode += '</div>';
    ld('#crm-createeditsub-view').html(tplnode);
    DateContorlObj.bingDateContrl('productbox_date_field');
}
//获取OA明細界面信息
function getaddOadetailInfo() {
    var tplnode = '<div><ul class="c-ul c-edit-cell">';
    ld.each(arrOaDetailObj.listfield, function (key, fieldinfo) {
        var starStr = '';
        //必录项加*
        if (fieldinfo.fieldtype == "M") {
            if(fieldinfo.fieldtype_orign_mc == 'Select' || fieldinfo.fieldtype_orign_mc == 'SelectCurrency' || 
               fieldinfo.fieldtype_orign_mc == 'SelectSource' || fieldinfo.fieldtype_orign_mc == 'CheckBox'){
                fieldcheckEmptyStr += fieldinfo.columnname + ',' + fieldinfo.fieldlabel + ',html&&&&&';
            }
            else{
                fieldcheckEmptyStr += fieldinfo.columnname + ',' + fieldinfo.fieldlabel + ',val&&&&&';                        
            }
            starStr = '<strong>*</strong>';
        }
        var readonlyStr = '';
        if (fieldinfo.edit_permission === '1') {
            readonlyStr = 'readonly=true';
        }
        if (fieldinfo.fieldtype_orign_mc === 'Text') {//Text：文本
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.columnname + '" name="' + fieldinfo.columnname + '" ' + readonlyStr + ' type="text" value="' + fieldinfo.defaultvalue + '" />';
        }
        else if (fieldinfo.fieldtype_orign_mc === 'Number') {//Number: 数量 
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.columnname + '" name="' + fieldinfo.columnname + '" ' + readonlyStr + ' type="number" value="' + Tools.Number.toDecimal(fieldinfo.defaultvalue, parseInt(ViewObj.rootScope.sys_49)) + '" />';
        }
        else if (fieldinfo.fieldtype_orign_mc === 'Price') {//Pirce: 单价 
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.columnname + '" name="' + fieldinfo.columnname + '" ' + readonlyStr + ' type="number" value="' + Tools.Number.toDecimal(fieldinfo.defaultvalue, parseInt(ViewObj.rootScope.sys_93)) + '" />';
        }
        else if (fieldinfo.fieldtype_orign_mc === 'Num') {//Num: 数字
            var defaultvalueStr = '',
                numTypeArr = fieldinfo.typedata.split(",");
            if (numTypeArr[1] == 0) {
                defaultvalueStr = Tools.Number.toInt(fieldinfo.defaultvalue);
            }
            else {
                defaultvalueStr = Tools.Number.toDecimal(fieldinfo.defaultvalue, parseInt(numTypeArr[1]));
            }
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.columnname + '" name="' + fieldinfo.columnname + '" ' + readonlyStr + ' type="number" value="' + defaultvalueStr + '" />';
        }
        else if (fieldinfo.fieldtype_orign_mc === 'Amount' || fieldinfo.fieldtype_orign_mc === 'RMB_Amount') {//Amount: 金额、RMB_Amount：人民币金额
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.columnname + '" name="' + fieldinfo.columnname + '" ' + readonlyStr + ' type="number" value="' + Tools.Number.toDecimal(fieldinfo.defaultvalue, 2) + '" />';
        }
        else if (fieldinfo.fieldtype_orign_mc === 'Int') {//Int:  整形
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.columnname + '" name="' + fieldinfo.columnname + '" ' + readonlyStr + ' type="number" value="' + Tools.Number.toInt(fieldinfo.defaultvalue) + '" />';
        }
        else if (fieldinfo.fieldtype_orign_mc === 'Select' || fieldinfo.fieldtype_orign_mc === 'SelectCurrency' || 
            fieldinfo.fieldtype_orign_mc === 'entitytype' || fieldinfo.fieldtype_orign_mc === 'CheckBox') 
        {//Select：下拉框、SelectCurrency：币种            
            tplnode += '<li class="arrow-right"><i>' + starStr + fieldinfo.fieldlabel + '</i><span class="lnr-chevron-right"></span>'; 
            var listitems = '';
            var _selectedval = '';
            var _showsearch = 'true';
            if (fieldinfo.option) {
                ld.each(fieldinfo.option, function (key, options) {   //构建数组
                    if (fieldinfo.fieldtype_orign_mc === 'SelectCurrency') {
                        listitems += options.value + '&&' + options.text + '&&' + options.rate + '|##|';
                    }
                    else if (fieldinfo.fieldtype_orign_mc === 'entitytype') {
                        listitems += options.value + '&&' + options.text + '&&' + options.name + '|##|';
                    }
                    else {
                        listitems += options.value + '&&' + options.text + '|##|';
                    }
                    if (options.value == fieldinfo.defaulthiddenvalue) {
                        _selectedval = options.text;
                    }
                });
                if (fieldinfo.option.length <= 8) _showsearch = 'false';
            }
            else{
                if(fieldinfo.fieldtype_orign_mc === 'CheckBox'){
                    listitems = '&&|##|是&&是|##|否&&否|##|';
                    _selectedval = fieldinfo.defaultvalue;//保存默认值
                    _showsearch = 'false';
                }    
            }
            
            var ddltitle = fieldinfo.fieldlabel;
            if (ddltitle.indexOf(' ') >= 0) {   //去掉字段名空格
                ddltitle = ddltitle.split(' ')[0];
            }
            if (fieldinfo.fieldtype_orign_mc === 'SelectCurrency') {
                tplnode += '<b class="text-ellipsis" id="' + fieldinfo.columnname + '" name="' + fieldinfo.columnname +
                    '" popu_select="drop_down_list" title_str="' + ddltitle + '" show_search="' + _showsearch +
                    '" select_mode="single" items="' + listitems + '" desc="products" tag="1">' + _selectedval + '</b>';
            }
            else if (fieldinfo.fieldtype_orign_mc === 'entitytype') {
                tplnode += '<b class="text-ellipsis" id="select_' + fieldinfo.columnname + '" name="select_' + fieldinfo.columnname +
                    '" popu_select="drop_down_list" title_str="' + ddltitle + '" show_search="' + _showsearch +
                    '" select_mode="single" items="' + listitems + '" desc="products" tag="'+ fieldinfo.defaulthiddenvalue +'">' + _selectedval + '</b>';
            }
            else {
                tplnode += '<b class="text-ellipsis" id="' + fieldinfo.columnname + '" name="' + fieldinfo.columnname +
                    '" popu_select="drop_down_list" title_str="' + ddltitle + '" show_search="' + _showsearch +
                    '" select_mode="single" items="' + listitems + '" desc="products" >' + _selectedval + '</b>';
            }
        }
        else if (fieldinfo.fieldtype_orign_mc === 'SelectSource') {
            tplnode += '<li class="arrow-right"><i>' + starStr + fieldinfo.fieldlabel + '</i><span class="lnr-chevron-right"></span>'; 
            var _choose_module = '',
                _flid_lable = '';
            ld.each(arrOaDetailObj.listfield, function (filedkey, fieldinfos) {
                if(fieldinfos.columnname == 'entitytype'){
                    ld.each(fieldinfos.option, function (entitykey, entityoptions) {//构建数据
                        if (entityoptions.value == fieldinfos.defaulthiddenvalue) {
                            _choose_module = entityoptions.name;
                            _flid_lable = entityoptions.text;
                        }
                    });
                }
            });
            tplnode += '<input id="entitytypeid" type="hidden" value="" name="entitytypeid">' +
                '<b class="text-ellipsis" id="entitytypeidname" name="entitytypeidname" ' +
                'parentstatus="yes" popu_select="choose_module" fild_id="entitytypeid" ' +
                'choose_module="' + _choose_module + '" flid_lable="' + _flid_lable + '" ></b>';
        }
        else if (fieldinfo.fieldtype_orign_mc === 'Date_Ymd') {
            //Date_Ymd:日期
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.columnname + '" name="' + fieldinfo.columnname + '" type="text"  tag="date-control-date" readonly="true" />';
            DateContorlObj.addDateControlInfo('productbox_date_field', fieldinfo.columnname, 'date', fieldinfo.defaultvalue);
        }
        else if (fieldinfo.fieldtype_orign_mc === 'Date_YmdHms') {
            //Date_YmdHms:日期时间HH:mm:ss
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.columnname + '" name="' + fieldinfo.columnname + '" type="text"  tag="date-control-datetime" readonly="true" />';
            DateContorlObj.addDateControlInfo('productbox_date_field', fieldinfo.columnname, 'datetime', fieldinfo.defaultvalue);
        }
        else if (fieldinfo.fieldtype_orign_mc === 'Date_Hm' || fieldinfo.type === 'Date_Hms') {
            //Date_Ymd:日期,Date_YmdHms:日期时间HH:mm:ss,Date_Hm:时间HH:mm,Date_Hms:时间 HH:mm:ss
            tplnode += '<li><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<input id="' + fieldinfo.columnname + '" name="' + fieldinfo.columnname + '" type="text"  tag="date-control-time" readonly="true" />';
            DateContorlObj.addDateControlInfo('productbox_date_field', fieldinfo.columnname, 'time', fieldinfo.defaultvalue);
        }
        else if (fieldinfo.fieldtype_orign_mc === 'TextArea') {//TextArea:文本区域
            tplnode += '<li class="heightauto"><i>' + starStr + fieldinfo.fieldlabel + '</i>';
            tplnode += '<textarea id="' + fieldinfo.columnname + '" name="' + fieldinfo.columnname + '">' + fieldinfo.defaultvalue + '</textarea>';
        }
        else if (fieldinfo.fieldtype_orign_mc === 'Span') {//Span:查看
            return;
        }
        tplnode += '</li>';
    });
    tplnode += '</ul>';
    tplnode += '<div class="bottomFixed"></div>';
    tplnode += '</div>';
    ld('#crm-createeditsub-view').html(tplnode);
    DateContorlObj.bingDateContrl('productbox_date_field');
}
//选择后确定产品
function saveEditsubProduct() {
    if (!logicHanderObj.Check.DetailEmpty()) return false; //判断是否为空,tax_amount,taxprice
    //服务合同：enddate必须晚于startdate
    if (ld('#servicecontracts_start_date').length === 1 && ld('#servicecontracts_end_date').length === 1) {
        if (!logicHanderObj.Check.DateField('servicecontracts_start_date', 'servicecontracts_end_date')) {
            return false;
        }
    }
    var hdnProductId = ld('#hdnProductId').val(),
        productname = ld('#productnamename').html(),
        taxprice = ld('#taxprice').val(),
        quantity = ld('#quantity').val(),
        money = ld('#tax_amount').val(),
        addproducthtml = '';
    if (taxprice == '') {
        taxprice = 0;
    }
    if (money == '') {
        money = 0;
    }
    var quantityStr = Tools.Number.toDecimal(quantity, parseInt(ViewObj.rootScope.sys_49));
    var taxpriceStr = Tools.Number.toDecimal(taxprice, parseInt(ViewObj.rootScope.sys_93));
    var moneyStr = Tools.Number.toDecimal(money, 2);
    if (productcount == 0) {
        rowcnt = 1; //全局变量赋值
        addproducthtml += '<h2 class="c-detail-h2" contraction="no">产品清单' +
            '<input id="prev_inventory_currency" name="prev_inventory_currency" type="hidden" value="1" />';
        var currencyStr = '',
            currencyFirstStr = '';
        ld.each(arrCurrencyObj, function (key, list) {
            if (currencyFirstStr === '') {
                currencyFirstStr = list.text;
            }
            currencyStr += list.value + '&&' + list.text + '|##|';
        });
        addproducthtml += '<i class="lnr-chevron-right"></i>'
        addproducthtml += '<b class="text-ellipsis" id="inventory_currency" tag="currencyChoose" name="inventory_currency" popu_select="drop_down_list" title_str="币种" show_search="false" select_mode="single" items="' + currencyStr + '" desc="create" >' + currencyFirstStr + '</b>';
        addproducthtml += '</h2>';
        addproducthtml += '<ul id="productUL" class="c-ul c-other-cell">' +
            '<li row="' + rowcnt + '" productid="product' + hdnProductId + '_' + rowcnt + '">' +
            '<input id="hidden_rowid_' + rowcnt + '" name="hidden_rowid_' + rowcnt + '" type="hidden" value="0">' +
            '<p><i class="text-ellipsis">' + productname + '</i><span>' + taxpriceStr + 'x' + quantityStr + '</span></p>' +
            '<p><a tag="pedit">编辑</a> <a tag="pdel">删除</a><span tag="money" count="' + quantity + '">价税合计:' + moneyStr + '</span></p>' +
            '</li></ul>';
        ld('#divChooseProduct').find('h2,#productUL').remove();//移除原有的产品清单 头标签
        ld('#divChooseProduct').prepend(addproducthtml);// 编辑、创建页 插入产品列表
        ld('#salesOrderetotal').removeClass('ui-hide');//显示整单折扣
    }
    else {
        if (ViewObj.rootScope.productstatus == 'add') {
            rowcnt++;
            addproducthtml += '<li row="' + rowcnt + '" productid="product' + hdnProductId + '_' + rowcnt + '">' +
                '<input id="hidden_rowid_' + rowcnt + '" name="hidden_rowid_' + rowcnt + '" type="hidden" value="0">' +
                '<p><i class="text-ellipsis">' + productname + '</i><span>' + taxpriceStr + 'x' + quantityStr + '</span></p>' +
                '<p><a tag="pedit">编辑</a> <a tag="pdel">删除</a><span tag="money" count="' + quantity + '">价税合计:' + moneyStr + '</span></p>' +
                '</li>';
            ld('#productUL').append(addproducthtml);
        }
        else if (ViewObj.rootScope.productstatus == 'edit') {
            ld('#productUL>[row=' + editproductrow + ']').html('');
            ld('#productUL>[row=' + editproductrow + ']').attr('productid', 'product' + hdnProductId + '_' + rowcnt);
            addproducthtml += '<input id="hidden_rowid_' + editproductrow + '" name="hidden_rowid_' + editproductrow + '" type="hidden" value="0">' +
                '<p><i class="text-ellipsis">' + productname + '</i><span>' + taxpriceStr + 'x' + quantityStr + '</span></p>' +
                '<p><a tag="pedit">编辑</a><a tag="pdel">删除</a><span tag="money" count="' + quantity + '">价税合计:' + moneyStr + '</span></p>';
            ld('#productUL>[row=' + editproductrow + ']').html(addproducthtml);
        }
    }
    var addproducthtmlhidden = '';
    if (ViewObj.rootScope.productstatus == 'edit') {
        addproducthtmlhidden += '<input id="hdnProductId' + editproductrow + '" name="hdnProductId' + editproductrow + '" type="hidden" value="' + hdnProductId + '" />';
    } else {
        addproducthtmlhidden += '<input id="hdnProductId' + rowcnt + '" name="hdnProductId' + rowcnt + '" type="hidden" value="' + hdnProductId + '" />';
    }
    ld.each(arrProductObj, function (key, list) {
        if (list.newline == 0) {
            var columnnameStr = '';
            if (list.columnname == 'productname') {
                columnnameStr = ld('#productnamename').html();
            }
            else if(list.uitype == 60){
                columnnameStr = ld('#' + list.columnname + '_p').html();                
            }
            else if(list.uitype == 56){
                columnnameStr = ld('#' + list.columnname).html();    
                if(columnnameStr=='是'){
                    columnnameStr = 1;
                }
                else{
                    columnnameStr = 0;
                }            
            }
            else {
                columnnameStr = ld('#' + list.columnname).val();
            }
            if (ViewObj.rootScope.productstatus == 'edit') {
                addproducthtmlhidden += '<input id="' + list.columnname + editproductrow + '" name="' +
                    list.columnname + editproductrow + '" type="hidden" value="' + columnnameStr + '" />';
            } else {
                addproducthtmlhidden += '<input id="' + list.columnname + rowcnt + '" name="' +
                    list.columnname + rowcnt + '" type="hidden" value="' + columnnameStr + '" />';
            }
        }
    });
    if (noArrProductObj) {
        ld.each(noArrProductObj, function (key, list) {   
            var columnnameStr = '';
            if (list.columnname == 'productname') {
                columnnameStr = ld('#productnamename').html();
            }
            else {
                columnnameStr = ld('#' + list.columnname).val();
            }
            if (ViewObj.rootScope.productstatus == 'edit') {
                addproducthtmlhidden += '<input id="' + list.columnname + editproductrow + '" name="' +
                    list.columnname + editproductrow + '" type="hidden" value="' + columnnameStr + '" />';
            } else {
                addproducthtmlhidden += '<input id="' + list.columnname + rowcnt + '" name="' +
                    list.columnname + rowcnt + '" type="hidden" value="' + columnnameStr + '" />';
            }            
        });
    }
    ld('#productUL>[productid=product' + hdnProductId + '_' + rowcnt + ']').append(addproducthtmlhidden);
    if (ViewObj.rootScope.productstatus == 'add') {
        productcount++;
    }
    //循环读取金额并相加
    var addproductamount = 0, quantityAll = 0;
    ld("span[tag=money]").each(function () {
        addproductamount += eval(ld(this).html().replace('金额:', ''));
        quantityAll += Number(ld(this).attr('count'));
    });
    addproductamount = logicHanderObj.fmoney(addproductamount);
    ld('#productSubCount').html(Tools.Number.toDecimal(quantityAll, parseInt(ViewObj.rootScope.sys_49)));//数量小计
    if (ld('#productSubtotal').length === 1) {
        ld('#productSubtotal').html(Tools.Number.toDecimal(addproductamount, 2));//金额小计
    }
    var prev_inventory_currency = ld('#prev_inventory_currency').val();
    if (prev_inventory_currency != 1) {
        currencyChooseAgain(ld('#hdnProductId').val(), rowcnt);//币种选择后，再添加产品
    }
    else {
        reCalculation();
    }
}
//选择后确定费用信息
function saveEditsubExpense() {
    if (!logicHanderObj.Check.DetailEmpty()) return false; //判断是否为空
    //费用报销：enddate必须晚于startdate
    if (ld('#startdate').length === 1 && ld('#enddate').length === 1) {
        if (!logicHanderObj.Check.DateField('startdate', 'enddate')) {
            return false;
        }
    }
    var expenseusename = ld('#expenseuse').val(),
        money = ld('#rmb_total').val(),
        addhtml = '',
        hiddenrowcnt = '';
    if (money == '') {
        money = 0;
    }
    var moneyStr = Tools.Number.toDecimal(money, parseInt(2));
    if (ld('#expenselistUL').length <= 0) {
        rowcnt = 1;
        hiddenrowcnt = rowcnt;
        addhtml += '<h2 class="c-detail-h2" contraction="no">' + ViewObj.rootScope.moduletitle + '明细</h2>' +
            '<ul id="expenselistUL" class="c-ul c-other-cell"><li row="' + rowcnt + '">' +
            '<input id="hidden_rowid_' + rowcnt + '" name="hidden_rowid_' + rowcnt + '" type="hidden" value="0">' +
            '<p class="text-ellipsis">' + expenseusename + '</p><p><a tag="Eedit">编辑</a> <a tag="Edel">删除</a>' +
            '<span tag="money">金额:' + moneyStr + '</span></p></li></ul>';
        ld('#divExpensedetail').prepend(addhtml);
    } else {
        if (ViewObj.rootScope.productstatus == 'edit') {
            hiddenrowcnt = editproductrow;
            addhtml += '<input id="hidden_rowid_' + editproductrow + '" name="hidden_rowid_' +
                editproductrow + '" type="hidden" value="0"><p class="text-ellipsis">' + expenseusename +
                '</p><p><a tag="Eedit">编辑</a> <a tag="Edel">删除</a>' +
                '<span tag="money">金额:' + moneyStr + '</span></p>';
            var expensedetailidValue = ld('#expensedetailid' + editproductrow).val();
            addhtml += '<input id="expensedetailid' + editproductrow + '" name="expensedetailid' +
                editproductrow + '" type="hidden" value="' + expensedetailidValue + '" />';
            ld('#expenselistUL>[row=' + editproductrow + ']').html(addhtml);

        } else {
            rowcnt++;
            addhtml += '<li row="' + rowcnt + '"><input id="hidden_rowid_' + rowcnt + '" name="hidden_rowid_' +
                rowcnt + '" type="hidden" value="0"><p class="text-ellipsis">' + expenseusename + '</p>' +
                '<p><a tag="Eedit">编辑</a> <a tag="Edel">删除</a><span tag="money">金额:' +
                moneyStr + '</span></p>';
            addhtml += '<input id="expensedetailid' + rowcnt + '" name="expensedetailid' +
                rowcnt + '" type="hidden" value="" /></li>';
            ld('#expenselistUL').append(addhtml);
            hiddenrowcnt = rowcnt;
        }
    }
    //费用清单隐藏域    
    var htmlhidden = '',
        hiddenvalue = '';
    ld.each(arrExpenseObj, function (key, list) {
        if (list.newline == '1') {
            return;
        }
        if (list.type == 'Select') {
            hiddenvalue = ld('#' + list.fieldname).html();
        } else if (list.type == 'SelectCurrency') {
            hiddenvalue = ld('#' + list.fieldname).attr('tag');
        } else if (list.type == 'CheckBox') {
            hiddenvalue = ld('#' + list.fieldname).html();
            if(hiddenvalue=='是'){
                hiddenvalue = 1;
            }
            else{
                hiddenvalue = 0;
            }
        } else {
            hiddenvalue = ld('#' + list.fieldname).val();
        }
        htmlhidden += '<input id="' + list.fieldname + hiddenrowcnt + '" name="' + list.fieldname + hiddenrowcnt +
            '" type="hidden" value="' + hiddenvalue + '" />';
        if (list.type == 'SelectSource' && list.fieldname == 'entitytypeid') {
            hiddenvalue = ld('#entitytypeidname').html();
            htmlhidden += '<input id="entitytype_name' + hiddenrowcnt + '" name="entitytype_name' + hiddenrowcnt +
                '" type="hidden" value="' + hiddenvalue + '" />';

            htmlhidden += '<input id="entitytype_tabid' + hiddenrowcnt + '" name="entitytype_tabid' + hiddenrowcnt +
                '" type="hidden" value="' + ld('#select_entitytypeid').attr('tag') + '" />';
            htmlhidden += '<input id="entitytype_tabname' + hiddenrowcnt + '" name="entitytype_tabname' + hiddenrowcnt +
                '" type="hidden" value="' + ld('#entitytypeidname').attr('choose_module') + '" />';
        }
    });
    ld('#expenselistUL>[row=' + hiddenrowcnt + ']').append(htmlhidden);
    if (ViewObj.rootScope.productstatus == 'add') {
        productcount++;
    }
    //循环读取金额并相加
    var addproductamount = 0;
    var i = 1;
    ld("span[tag=money]").each(function () {
        if (document.getElementById('hidden_rowid_' + i) != undefined && document.getElementById('hidden_rowid_' + i).value == 0) {
            addproductamount += eval(ld(this).html().replace('金额:', ''));
        }
        i++;
    });
    addproductamount = Tools.Number.toDecimal(addproductamount, 2);
    ld('#divExpensedetail').removeClass('ui-hide');
    ld('#crm-addexpense-footer>ul>li>[tag=expensemoney]').html(addproductamount);//总金额    
}
//选择后确定OA表单信息
function saveEditsubOadetail() {
    if (!logicHanderObj.Check.DetailEmpty()) return false; //判断是否为空
    //enddate必须晚于startdate
    if (ld('#starttime').length === 1 && ld('#endtime').length === 1) {
        if (!logicHanderObj.Check.DateField('starttime', 'endtime')) {
            return false;
        }
    }
    var o_module = module,
        description = '',
        costorday = '',
        amount = '',
        costordayStr = '',
        addhtml = '',
        hiddenrowcnt = '',
        listulliClass = 'detailline3';

    if(module == 'Approve'){
        o_module = ViewObj.rootScope.approvemodule;
    }
    if(o_module == 'AddJobBill'){
        description = ld('#starttime').val() + ' ~ ' + ld('#endtime').val();//'原因:'+ld('#description').val();
        costorday = ld('#costtime').val();
        listulliClass = '';
    } else if(o_module == 'MinusJobBill'){
        description = ld('#starttime').val() + ' ~ ' + ld('#endtime').val();//'假别:'+ld('#minusjobtype').html();
        costorday = ld('#costtime').val();
    } else if(o_module == 'BusinessApply'){
        description = ld('#starttime').val() + ' ~ ' + ld('#endtime').val();//'交通工具:'+ld('#traffictype').html();
        costorday = ld('#days').val();
    } else if(o_module == 'Commission'){
        description = ld('#select_entitytype').html()+':'+ld('#entitytypeidname').html();
        costorday = ld('#source_total').val();
        amount = ld('#amount').val();
        if (amount == '') {
            amount = 0;
        }
    }
    if (costorday == '') {
        costorday = 0;
    }
    if(o_module == 'AddJobBill'){
        costordayStr = '时长(h):' + Tools.Number.toDecimal(costorday, parseInt(1));
    } else if(o_module == 'MinusJobBill'){
        costordayStr = '假别:'+ld('#minusjobtype').html() + '<br/>时长(h):' + Tools.Number.toDecimal(costorday, parseInt(1));
    } else if(o_module == 'BusinessApply'){
        costordayStr = '交通工具:'+ld('#traffictype').html() + '<br/>天数:' + Tools.Number.toDecimal(costorday, parseInt(1));
    } else if(o_module == 'Commission'){
        costordayStr = '合同金额:' + Tools.Number.toDecimal(costorday, parseInt(2)) + '<br/>佣金:' + Tools.Number.toDecimal(amount, parseInt(2));
    }
    if (ld('#oadetaillistUL').length <= 0) {
        rowcnt = 1;
        hiddenrowcnt = rowcnt;
        addhtml +=  '<h2 class="c-detail-h2" contraction="no">' + ViewObj.rootScope.moduletitle + '明细</h2>' +
                    '<ul id="oadetaillistUL" class="c-ul c-other-cell ' + listulliClass + '">' + 
                        '<li row="' + rowcnt + '">' +
                            '<input id="hidden_rowid_' + rowcnt + '" name="hidden_rowid_' + rowcnt + '" type="hidden" value="0">' +
                            '<p class="text-ellipsis">' + description + '</p>' + 
                            '<p><a tag="Dedit">编辑</a> <a tag="Ddel">删除</a><span tag="costorday">' + costordayStr + '</span></p>' + 
                        '</li>' + 
                    '</ul>';
        ld('#divOadetail').prepend(addhtml);
    } else {
        if (ViewObj.rootScope.productstatus == 'edit') {
            hiddenrowcnt = editproductrow;
            addhtml +=  '<input id="hidden_rowid_' + editproductrow + '" name="hidden_rowid_' + editproductrow + '" type="hidden" value="0">' + 
                        '<p class="text-ellipsis">' + description + '</p>' + 
                        '<p><a tag="Dedit">编辑</a> <a tag="Ddel">删除</a><span tag="costorday">' + costordayStr + '</span></p>';
            var expensedetailidValue = ld('#lineitem_id' + editproductrow).val();
            addhtml += '<input id="lineitem_id' + editproductrow + '" name="lineitem_id' + editproductrow + '" type="hidden" value="' + expensedetailidValue + '" />';
            ld('#oadetaillistUL>[row=' + editproductrow + ']').html(addhtml);

        } else {
            rowcnt++;
            addhtml +=  '<li row="' + rowcnt + '"><input id="hidden_rowid_' + rowcnt + '" name="hidden_rowid_' +rowcnt + '" type="hidden" value="0">' + 
                        '<p class="text-ellipsis">' + description + '</p>' + 
                        '<p><a tag="Dedit">编辑</a> <a tag="Ddel">删除</a><span tag="costorday">' + costordayStr + '</span></p>';
            addhtml += '<input id="lineitem_id' + rowcnt + '" name="lineitem_id' + rowcnt + '" type="hidden" value="" /></li>';
            ld('#oadetaillistUL').append(addhtml);
            hiddenrowcnt = rowcnt;
        }
    }
    //OA表单隐藏域    
    var htmlhidden = '',
        hiddenvalue = '';
    ld.each(arrOaDetailObj.listfield, function (key, list) {
        if (list.fieldtype_orign_mc == 'Select') {
            hiddenvalue = ld('#' + list.columnname).html();
        } else if (list.fieldtype_orign_mc == 'entitytype') {
            hiddenvalue = ld('#' + list.columnname).attr('tag');
        } else if (list.fieldtype_orign_mc == 'SelectCurrency') {
            hiddenvalue = ld('#' + list.columnname).attr('tag');
        } else if (list.fieldtype_orign_mc == 'CheckBox') {
            hiddenvalue = ld('#' + list.columnname).html();
            if(hiddenvalue=='是'){
                hiddenvalue = 1;
            }
            else{
                hiddenvalue = 0;
            }
        } else {
            hiddenvalue = ld('#' + list.columnname).val();
        }
        if(list.columnname != 'entitytype'){
            htmlhidden += '<input id="' + list.columnname + hiddenrowcnt + '" name="' + list.columnname + hiddenrowcnt +'" type="hidden" value="' + hiddenvalue + '" />';    
        }
        if (list.fieldtype_orign_mc == 'SelectSource' && list.columnname == 'entitytypeid') {
            hiddenvalue = ld('#entitytypeidname').html();
            htmlhidden += '<input id="entitytype_name' + hiddenrowcnt + '" name="entitytype_name' + hiddenrowcnt + '" type="hidden" value="' + hiddenvalue + '" />';
            if(module == 'Commission'){
                htmlhidden += '<input id="entitytype_tabid' + hiddenrowcnt + '" name="entitytype_tabid' + hiddenrowcnt + '" type="hidden" value="' + ld('#select_entitytype').attr('tag') + '" />';
                htmlhidden += '<input id="entitytype_tabname' + hiddenrowcnt + '" name="entitytype_tabname' + hiddenrowcnt + '" type="hidden" value="' + ld('#entitytypeidname').attr('choose_module') + '" />';
            }
            else{
                htmlhidden += '<input id="entitytype_tabid' + hiddenrowcnt + '" name="entitytype_tabid' + hiddenrowcnt + '" type="hidden" value="' + ld('#select_entitytypeid').attr('tag') + '" />';
                htmlhidden += '<input id="entitytype_tabname' + hiddenrowcnt + '" name="entitytype_tabname' + hiddenrowcnt + '" type="hidden" value="' + ld('#entitytypeidname').attr('choose_module') + '" />';   
            }
        }
    });
    ld('#oadetaillistUL>[row=' + hiddenrowcnt + ']').append(htmlhidden);
    if (ViewObj.rootScope.productstatus == 'add') {
        productcount++;
    }
    oaDetailCalcTotal();//OA表单、计算合计
}
//OA表单、计算合计
function oaDetailCalcTotal() {
    //循环读取并相加
    var o_module = module,
        addcostorday = 0;
    if(module == 'Approve'){
        o_module = ViewObj.rootScope.approvemodule;
    }
    var i = 1;
    ld("span[tag=costorday]").each(function () {
        if (document.getElementById('hidden_rowid_' + i) != undefined && document.getElementById('hidden_rowid_' + i).value == 0) {
            if(o_module == 'AddJobBill'){
                addcostorday += eval(ld(this).html().replace('时长(h):', ''));
            } else if(o_module == 'MinusJobBill'){
                var addcostordayStr = ld(this).html();
                var addcostordayArr = addcostordayStr.split('时长(h):');
                addcostorday += eval(addcostordayArr[1]);                
            } else if(o_module == 'BusinessApply'){
                var addcostordayStr = ld(this).html();
                var addcostordayArr = addcostordayStr.split('天数:');
                addcostorday += eval(addcostordayArr[1]); 
            } else if(o_module == 'Commission'){
                var addcostordayStr = ld(this).html();
                var addcostordayArr = addcostordayStr.split('佣金:');
                addcostorday += eval(addcostordayArr[1]);
            }
        }
        i++;
    });
    // addcostorday = Tools.Number.toDecimal(addcostorday, 2);
    if(o_module == 'Commission'){
        var adjustmentType = ld('#adjustmentType').attr('tag');//获取调整类型,adjustmentType
        if (ld('#adjustment').length > 0) {
            adjustment = ld('#adjustment').val();
            if (adjustment > 0) {
                if (adjustmentType == '+') {
                    addcostorday = eval(addcostorday) + eval(adjustment);
                } else {
                    addcostorday = eval(addcostorday) - eval(adjustment);
                }
            } else {
                ld('#adjustment').val(0);
            }
        }
    }
    addcostorday = Tools.Number.toDecimal(addcostorday, 1);
    ld('#divOadetail').removeClass('ui-hide');
    ld('#crm-addoadetail-footer>ul>li>[tag=oadetailtotal]').html(addcostorday);//总金额 
}
//币种选择
function currencyChoose() {
    var choosecurrencyid = ld('#inventory_currency').attr('tag');
    var prev_cur = ld('#prev_inventory_currency').val();
    ld('#prev_inventory_currency').val(choosecurrencyid);
    var products_list = "";
    for (var i = 1; i <= rowcnt; i++) {
        var productid = ld("#hdnProductId" + i).val();
        if (i != 1) {
            products_list = products_list + "::";
        }
        products_list = products_list + productid;
    }

    var urlstring = 'module=Products&action=InventoryPriceAjax';
    urlstring += '&currencyid=' + choosecurrencyid + '&productsList=' + products_list+'&frommodule='+module;
    WordReportAjax(urlstring, function (rest) {
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var price_values = restobj.result.price_values;
        var costprice = restobj.result.costprice;
        updatePriceValues(price_values, costprice);
        changeCurrencyMoney(choosecurrencyid,prev_cur,1);
    });
}
//币种选择后，再添加产品
function currencyChooseAgain(products_list, rows) {
    var choosecurrencyid = ld('#inventory_currency').attr('tag');
    var prev_cur = ld('#prev_inventory_currency').val();
    var urlstring = 'module=Products&action=InventoryPriceAjax';
    urlstring += '&currencyid=' + choosecurrencyid + '&productsList=' + products_list+'&frommodule='+module;
    WordReportAjax(urlstring, function (rest) {
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var price_values = restobj.result.price_values;
        var costprice = restobj.result.costprice;
        updatePriceValuesAgain(price_values, costprice, rows);
        changeCurrencyMoney(choosecurrencyid,prev_cur,rows);
    });
}
function updatePriceValues(pricesList, costlist) {
    if (pricesList == null || pricesList == '') return;
    var prices_list = pricesList.split("::");
    var cost_list = costlist.split("::");
    var products_list = "";
    for (var i = 1; i <= prices_list.length; i++) {
        var j = i - 1;
        if(ViewObj.rootScope.hiddenlistprice=='yes'){
            ld("#taxprice" + i).val(prices_list[j]);//taxprice:含税单价;listprice:不含税单价
        }
        ld("#listprice" + i).val(prices_list[j]);//taxprice:含税单价;listprice:不含税单价
        ld("#productcost" + i).val(cost_list[j]);
        fieldformulaobj.CountRowFormulaColumn(i);
        var taxpricenew = ld("#taxprice" + i).val();
        var quantitynew = ld("#quantity" + i).val();
        ld('#productUL>[row=' + i + ']').find('span:first').html(taxpricenew + 'x' + Tools.Number.toDecimal(quantitynew, parseInt(ViewObj.rootScope.sys_49)));
        var totalPrice = eval(taxpricenew) * eval(quantitynew);
        ld('#productUL>[row=' + i + ']').find('span:last').html('金额:' + Tools.Number.toDecimal(totalPrice, parseInt(ViewObj.rootScope.sys_49)));
    }
    reCalculation();//重新计算  
}
//币种选择后，再添加产品
function updatePriceValuesAgain(pricesList, costlist, rows) {
    if (pricesList == null || pricesList == '') return;
    if(ViewObj.rootScope.hiddenlistprice=='yes'){
        ld("#taxprice" + rows).val(pricesList);//taxprice:含税单价;listprice:不含税单价    
    }
    ld("#listprice" + rows).val(pricesList);//taxprice:含税单价;listprice:不含税单价
    ld("#productcost" + rows).val(costlist);
    fieldformulaobj.CountRowFormulaColumn(rows);
    var taxpricenew = ld("#taxprice" + rows).val();
    var quantitynew = ld("#quantity" + rows).val();
    ld('#productUL>[row=' + rows + ']').find('span:first').html(taxpricenew + 'x' + Tools.Number.toDecimal(quantitynew, parseInt(ViewObj.rootScope.sys_49)));
    var totalPrice = eval(taxpricenew) * eval(quantitynew);
    ld('#productUL>[row=' + rows + ']').find('span:last').html('金额:' + Tools.Number.toDecimal(totalPrice, parseInt(ViewObj.rootScope.sys_49)));
    reCalculation();//重新计算  
}
//修改币种后不含税单价和含税单价修改后最近价格（未税）和最近价格（含税）也需要修改
function changeCurrencyMoney(currency_id,before_currency_id,rows){
    var urlstring = 'module=Users&action=ChangeRateAmount&getCurrencyRate=yes&return_module=' + module + 
                    '&select_currency_id=' + currency_id+'&before_currency_id='+before_currency_id;
    WordReportAjax(urlstring, function (rest) {
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var beforecurrency_rate = restobj.result.before_currency_rate;
        var now_currency_rate = restobj.result.select_currency_rate;
        if(document.getElementById('productcost'+rows)!=undefined)
        {
            var productcost=parseFloat(ld('#productcost'+rows).val());

            if(parseInt(beforecurrency_rate,10) == 1){
                productcost = productcost*now_currency_rate;    
            }
            else{
                productcost = parseFloat(productcost/beforecurrency_rate)*now_currency_rate;    
            }
            ld('#productcost'+rows).val(Tools.Number.toDecimal(productcost, 2));
        }
        if(document.getElementById('lastlistprice'+rows)!=undefined)
        {
            var lastlistprice=parseFloat(document.getElementById('lastlistprice'+rows).value);

            if(parseInt(beforecurrency_rate,10) == 1){
                lastlistprice = lastlistprice*now_currency_rate;
            }
            else{
                lastlistprice = parseFloat(lastlistprice/beforecurrency_rate)*now_currency_rate;
            }
            ld('#lastlistprice'+rows).val(Tools.Number.toDecimal(lastlistprice, 2));
        }
        if(document.getElementById('lasttaxprice'+rows)!=undefined)
        {
            var lasttaxprice=parseFloat(document.getElementById('lasttaxprice'+rows).value);

            if(parseInt(beforecurrency_rate,10) == 1){
                lasttaxprice = lasttaxprice*now_currency_rate;
            }
            else{
                lasttaxprice = parseFloat(lasttaxprice/beforecurrency_rate)*now_currency_rate;
            }
            ld('#lasttaxprice'+rows).val(Tools.Number.toDecimal(lasttaxprice, 2));
        }
    });
}
//先选择产品再选择客户
//修改币种后不含税单价和含税单价修改后最近价格（未税）和最近价格（含税）也需要修改
function changeCurrencyMoneyFormAccounts(accountid){
    var productids = '';
    ld("#productUL>li").each(function () {
        var row = ld(this).attr('row');
        productids += ld('#hdnProductId'+row).val() + ',';
    });
    if(productids.length<=0){
        return false;
    }
    productids = productids.substr(0, productids.length - 1);
    var prev_inventory_currency = ld('#prev_inventory_currency').val();
    var urlstring = 'module=Accounts&action=getAccountLastPrice&accountid=' + accountid + '&frommodule=' + module + 
                    '&productids=' + productids+'&currency_id='+prev_inventory_currency;
    WordReportAjax(urlstring, function (rest) {
        if (rest == '') return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);        
        ld.each(restobj.result, function (key, list) {
            var keyStr = 'product' + key + '_';
            ld("#productUL>li").each(function () {
                var productid = ld(this).attr('productid');
                if(productid.indexOf(keyStr)>-1){
                    var rows = ld(this).attr('row');
                    ld('#lasttaxprice'+rows).val(list.lasttaxprice);
                    ld('#lastlistprice'+rows).val(list.lastlistprice);
                }                
            });
        });
    });
}
//重新计算
function reCalculation() {
    //循环读取金额并相加
    var addproductamount = 0;
    var addproductcount = 0;
    ld("span[tag=money]").each(function () {
        addproductamount += eval(ld(this).html().replace('金额:', ''));
        addproductcount++;
    });
    if (ld('#productSubtotal').length === 1) {
        ld('#productSubtotal').html(Tools.Number.toDecimal(addproductamount, 2));//金额小计
    }
    var selectDiscount = ld('#selectDiscount').attr('tag');//获取整单折扣类型,selectDiscount
    var discount_amount = ld('#sub_discount_amount').val();//获取整单折扣值
    var adjustmentType = ld('#adjustmentType').attr('tag');//获取调整类型,adjustmentType
    if (discount_amount > 0) {
        if (selectDiscount == '-') {
            addproductamount -= discount_amount;
        } else if (selectDiscount == '%') {
            addproductamount = addproductamount * ((100 - discount_amount) / 100);
        }
    } else {
        ld('#sub_discount_amount').val(0);
    }
    if (ld('#adjustment').length > 0) {
        adjustment = ld('#adjustment').val();
        if (adjustment > 0) {
            if (adjustmentType == '+') {
                addproductamount = eval(addproductamount) + eval(adjustment);
            } else {
                addproductamount = eval(addproductamount) - eval(adjustment);
            }
        } else {
            ld('#adjustment').val(0);
        }
    }
    addproductamount = logicHanderObj.fmoney(addproductamount);
    ld('#crm-addproduct-footer>ul>li>[tag=productmoney]').html(addproductamount);
}
/*
 * edit:chj
 * date:2014/12/17
 * 编辑、新增页面，切换币种，更改银行账户和当前页的所有金额字段
 */
function getCurrencyRateAmounts() {
    var select_currency_id = ld('#currency_id').attr('tag');//选择后的币种ID
    var before_currency_id = ld('#hidden_currency_id').val();   //选择前的币种ID
    var urlstring = 'module=Users&action=ChangeRateAmount&select_currency_id=' + select_currency_id;
    urlstring += '&before_currency_id=' + before_currency_id + '&getCurrencyRate=yes';
    ld('#hidden_currency_id').val(select_currency_id);
    WordReportAjax(urlstring, function (rest) {
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var before_currency_rate = restobj.result.before_currency_rate;
        var select_currency_rate = restobj.result.select_currency_rate;
        for (var i = 0; i < priceFieldNameNum; i++) {
            var amount = ld('#' + priceFieldName[i]).val().replace(',', '');
            if (parseInt(before_currency_rate, 10) == 1)
                amount = amount * select_currency_rate;
            else {
                amount = parseFloat(amount / before_currency_rate) * select_currency_rate;
            }
            amount = Tools.Number.toDecimal(amount, 2);
            ld('#' + priceFieldName[i]).val(amount);
        }
        //费用
        if (module == 'Expense') {
            var i = 1;
            var addproductamount = 0;
            ld("#expenselistUL>li>[tag=money]").each(function () {
                if (document.getElementById('hidden_rowid_' + i) != undefined && document.getElementById('hidden_rowid_' + i).value == 0) {
                    addproductamount += eval(ld('#expenselistUL>[row=' + i + ']>[tag=money]').html().replace('金额:', ''));
                    if (parseInt(before_currency_id, 10) == 1) {
                        addproductamount = addproductamount * select_currency_rate;
                    } else {
                        addproductamount = parseFloat(addproductamount / before_currency_rate) * select_currency_rate;
                    }
                    addproductamount = Tools.Number.toDecimal(addproductamount, 2);
                    ld('#money' + i).val(addproductamount);
                    ld('#expenselistUL>[row=' + i + ']>[tag=money]').html('金额:' + eval(addproductamount));
                }
                i++;
            });
            var expensemoney = ld('#crm-addexpense-footer>ul>li>[tag=expensemoney]').html();
            if (parseInt(before_currency_id, 10) == 1) {
                expensemoney = expensemoney * select_currency_rate;
            } else {
                expensemoney = parseFloat(expensemoney / before_currency_rate) * select_currency_rate;
            }
            expensemoney = Tools.Number.toDecimal(expensemoney, 2);
            ld('#crm-addexpense-footer>ul>li>[tag=expensemoney]').html(expensemoney);
        }
        if (restobj.result.bank_info != '') {
            if (ld('#bankaccountsetid') != undefined) {
                ld('#bankaccountsetid').attr('items', restobj.result.bank_info);
                var bank_info = restobj.result.bank_info.split('|##|');
                var bank_name = bank_info[0].split('&&');
                ld('#hidden_bankaccountsetid').val(bank_name[0]);
                ld('#bankaccountsetid').html(bank_name[1]);
                ld('#bankaccountsetid').attr('tag', bank_name[0]);
            }
        }
        else {
            ld('#bankaccountsetid').attr('items', '');
            ld('#hidden_bankaccountsetid').val('');
            ld('#bankaccountsetid').html('');
            ld('#bankaccountsetid').attr('tag', '');
        }
    });
}
//鼠标定位到尾部begin
ld.fn.setCursorPosition = function (position) {
    if (this.lengh == 0) return this;
    return ld(this).setSelection(position, position);
}
ld.fn.setSelection = function (selectionStart, selectionEnd) {
    if (this.lengh == 0) return this;
    input = this[0];

    if (input.createTextRange) {
        var range = input.createTextRange();
        range.collapse(true);
        range.moveEnd('character', selectionEnd);
        range.moveStart('character', selectionStart);
        range.select();
    } else if (input.setSelectionRange) {
        input.focus();
        input.setSelectionRange(selectionStart, selectionEnd);
    }
    return this;
}
ld.fn.focusEnd = function () {
    this.setCursorPosition(this.val().length);
}
//鼠标定位到尾部end
//其他计算合计
function calcTotal() {
    var discount_amount = 0;
    var adjustmentType;
    var adjustment;
    var selectDiscount;
    //获取产品合计
    var addproductamount = 0;
    ld("span[tag=money]").each(function () {
        addproductamount += eval(ld(this).html().replace('金额:', ''));
    });
    selectDiscount = ld('#selectDiscount').attr('tag');//获取整单折扣类型
    discount_amount = ld('#sub_discount_amount').val();//获取整单折扣值
    adjustmentType = ld('#adjustmentType').attr('tag');//获取调整类型
    if (discount_amount > 0) {
        if (selectDiscount == '-') {
            addproductamount -= discount_amount;
        } else if (selectDiscount == '%') {
            addproductamount = addproductamount * ((100 - discount_amount) / 100);
        }
    } else {
        ld('#sub_discount_amount').val(0);
    }
    if (ld('#adjustment').length > 0) {
        adjustment = ld('#adjustment').val();
        if (adjustment > 0) {
            if (adjustmentType == '+') {
                addproductamount = eval(addproductamount) + eval(adjustment);
            } else {
                addproductamount = eval(addproductamount) - eval(adjustment);
            }
        } else {
            ld('#adjustment').val(0);
        }
    }
    addproductamount = Tools.Number.toDecimal(addproductamount, 2);
    ld('#crm-addproduct-footer>ul>li>[tag=productmoney]').html(addproductamount);
}
//获取整单折扣和调整的HTML 合同订单等
function getTotalHtml(arrProductObj) {
    var totalHtml = '<ul class="c-ul c-other-total" id="salesOrderetotal">';
    totalHtml += '<li><span>数量小计</span><span id="productSubCount"></span></li>';
    //totalHtml += '<li><span>金额小计</span><span id="productSubtotal"></span></li>';
    ld.each(arrProductObj, function (key, list) {
        if (list.newline == 2) {
            if (list.columnname == 'subtotal') {
                totalHtml += '<li><span>金额小计</span><span id="productSubtotal"></span></li>';
            }
        }
        if (list.newline == 1) {
            if (list.uitype == '37') {
                totalHtml +=
                    '<li><span>整单折扣</span>' +
                    '<b class="text-ellipsis" id="selectDiscount" name="selectDiscount" tag="-" desc="create" ' +
                    'items="-&&直接降价|##|%&&百分比降价|##|" select_mode="single" ' +
                    'show_search="false" title_str="整单折扣" popu_select="drop_down_list" >直接降价</b><i class="lnr-chevron-right"></i>' +
                    '<input id="sub_discount_amount" name="sub_discount_amount" type="number"  tag="sub_discount_amount" value="0.00" onblur="calcTotal()" />' +
                    '</li>';
            }
            if (list.uitype == '35') {
                totalHtml +=
                    '<li><span>调整</span>' +
                    '<b class="text-ellipsis" id="adjustmentType" name="adjustmentType" tag="+" desc="create" ' +
                    'items="+&&增加|##|-&&减少|##|" select_mode="single" ' +
                    'show_search="false" title_str="调整" popu_select="drop_down_list" >增加</b><i class="lnr-chevron-right"></i>' +
                    '<input id="adjustment" name="adjustment" type="number"  tag="adjustment" value="0.00" onblur="calcTotal()" />' +
                    '</li>';
            }
        }
    });
    totalHtml += '</ul>';
    return totalHtml;
}
function getPorductTaxInfo(tax_info) {
    var tplnode = '';
    if (tax_info.length >= 1) {
        ld.each(tax_info, function (key, taxinfo) {
            var tax_checked = "";
            var tax_visibility = "hidden";
            if (taxinfo.check_value == 1) {
                tax_checked = 'checked';
                tax_visibility = "visible"
            }
            tplnode += '<li style="position:relative;">' + taxinfo.taxlabel +
                '<input type="checkbox" id="' + taxinfo.taxname + '_check" ' +
                tax_checked + ' style="float:none;margin-left: 1rem;position:absolute;' +
                'left:28%;top:25%;" onclick="logicHanderObj.fnshowHide(this,\'' + taxinfo.taxname + '\')">' + '<input id="' +
                taxinfo.taxname + '" class="detailedViewTextBox" type="text"  style="visibility:' +
                tax_visibility + ';width:50%; " value="' + taxinfo.percentage + '" name="' +
                taxinfo.taxname + '" fieldonly="0">' + '</li>';

            tax_cur[key] = taxinfo.taxname;
        });
    }
    tplnode = tplnode.substring(0, tplnode.length - 6);//去掉末尾的 </li> 五个字符
    return tplnode;
}
