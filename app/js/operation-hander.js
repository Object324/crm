//全局事件处理对象
var OperationObj=(function(){
    var TIME_INTERVAL = 500, // 两次点击间隔时间毫秒数
        start_time = 0,
        end_time = 0;
    // 全局点击操作
    var clickOpreation=(function(){
        ld('body').on('click',function(event){
            // 两次点击间隔时间必须大于指定毫秒数
            end_time = (new Date()).valueOf() ;
            if( (end_time - start_time) < TIME_INTERVAL ){
                start_time = end_time;
                return;
            }
            start_time = end_time;
            // 正在切换页面时，点击无效
            if(ViewObj.getInfo('transform_state') === 'transforming') return;

            var e=event || window.event,
                t = e.target|| e.srcElement,
                targetobj = ld(t),
                click_component = '',
                options={},
                flag = true;
            if(targetobj.parents('#app_header').length===1){
                click_component='header';
                options.target_id = '';
                if(targetobj.parents('#head_left').length===1){
                    if(ld('#head_left').attr('tag') !== 'none') options.target_id='head_left';
                }else if(targetobj.parents('#head_rig').length===1){
                    if(ld('#head_rig').attr('tag') !== 'none') options.target_id='head_rig';
                    if(!ld('#poplayerMask').is(':hidden')){
                        OperationObj.triggerCilckEvent(ld('#poplayerMask'));           
                    }
                }else if(targetobj.parents('#head_mid').length===1){
                    if(ld('#head_mid').attr('tag') !== 'none') options.target_id='head_mid';
                    // 头部下拉分类
                    if( ld('#head_mid').find('span:visible').attr('classify')==='true'){
                        logicHanderObj.headerDataClassify();
                    }
                }                
            }else if(targetobj.parents('#app-footer').length===1){
                click_component='footer';
            }else {
                if(ld('#head_mid').attr('tag') !== 'none')  click_component='body';
                flag = execOtherComponentClickEvent(targetobj);
            } 
            if(flag !== false){
                execOpreation(targetobj,click_component,options);
            }
        });
    })();

    function execOpreation(targetobj,click_component,options,istrigger){
        
        var t_viewid='';
        if(options.view_id){
            t_viewid=options.view_id;
        }else{
            t_viewid=ViewObj.getCurrentViewId();
        }
        var postfix='-'+click_component+'-click',
            createFun = ViewObj['create-'+t_viewid],
            operationFun = ViewObj[t_viewid+postfix],
            create_socpe = ld.isPlainObject(options.scope) ? options.scope : {};

        if($.isFunction(operationFun)){
             operationFun(targetobj,options);
             
        }else if(istrigger){
            if(ld.isFunction(createFun)){
                createFun(t_viewid,'',create_socpe);

            // 报错 
            }else{
                alert('没有创建'+t_viewid+'的create-'+t_viewid+
                      '方法,请在对应页面的js中‘view.create-’处定义\n');
                throw new Error('出错位置！');                
            }
            // 判断是否存在对应页面的switch方法
            try{
                ViewObj[t_viewid+postfix](targetobj,options);
            }catch(e){
                alert( 'OperationObj.triggerCilckEvent 时'+t_viewid+postfix+'方法有错误！\n'+
                       '或者没有定义相应的方法.\n'+'出错信息:'+e);
                throw new Error('出错位置！');
            }
        }    
    }
    function execOtherComponentClickEvent(targetobj,options,istrigger){
        var _this = null,
            view_id = ViewObj.getCurrentViewId(),
            _this_id = targetobj.attr('id'),
            _this_class = targetobj.attr('class'),
            _this_tag = targetobj.attr('tag');
        _this_id = _this_id ? _this_id : '';
        _this_class = _this_class ? _this_class : '';
        _this_tag = _this_tag ? _this_tag : '';
        // 点击遮罩层，或者 取消 按钮
        if( _this_id === 'layerMask' ||
           targetobj.parents('.orderdiv').length === 1){
            
            if(!ld('#pop-prompt-box').is(':hidden')) return;

            var flag = false;
            // 点击 打电话，发短信图标
            if( targetobj.parent().hasClass('msg') ||
                targetobj.parent().hasClass('talk') ){

                flag = true;
            }  
            // 点击取消按钮
            if(_this_tag === 'btnc_cancel'){
                if( !ld('#pop-prompt-box').length || 
                    ld('#pop-prompt-box').is(':hidden') ){
                   
                    flag = true;
                }
            // 确认，返回页面
            }else if(_this_tag === 'ok'){
                flag = true;
            // 点击遮罩层
            }else if(_this_id === 'layerMask'){
                flag = true;
            // 点击 “回复/汇报结果”
            }else{
                var title_str = '';
                var replystatus = '';
                switch(targetobj.attr('tag')){
                    case 'btnsub_cocmd_reply' :
                        title_str = '回复';
                        replystatus = 'reply';
                        break;
                    case 'btnsub_cocmd_result' :
                        title_str = '汇报结果';
                        replystatus = 'savefinish';
                        break;
                }
                if(title_str){
                    flag = true;
                    ViewObj.switchView('wn-replayforword-view','init',{
                        view_name : 'reply',
                        'replystatus' : replystatus,
                        'title_str' : title_str,
                        __footer_id : 'wn-at-footer'
                    }); 
                }
            }
            if(flag){
                // 在me crm work news 首页是需要显示main底部标签
                var cvid=ViewObj.getCurrentViewId();
                if( cvid.indexOf('main')>-1 ){
                     ViewObj.switchFooter('cwnm-main-footer','display');
                }

                ld('#layerMask').hide();
                ld('.orderdiv').addClass('ui-hide');
                // 执行返回页面操作
                if(_this_tag === 'ok'){
                    ViewObj.delayExecSwitch();
                    return false;
                }else if(_this_tag === 'btnc_cancel'){
                    return false;
                }
            }  
        // 点击 下拉分类 遮罩层
        }else if(_this_id === 'poplayerMask' ){
            if( ld('#poplayerMask:visible').length &&
                ld('#status:visible').length === 0){
                logicHanderObj.headerDataClassify();
            }
        // 点击 下拉分类，选项
        }else if(targetobj.parents('#pulldown_menu').length === 1){
            EventHanderObj.pulldownMenuClick(targetobj,options);      
        // work首页数据分类
        }else if(targetobj.parents('#workDataClassify').length === 1) {
            _this = targetobj.parents('.swiper-slide');            
            if( _this.length ===1 || 
                _this_class === 'swiper-slide'){
                _this = _this.length ? _this : targetobj;
                var target=_this.find('a');
                smallcategory = target.attr('tag');
                ld('#workDataClassify .swiper-slide a').removeClass('fontblue');
                target.addClass('fontblue');
                SwiperObj.ListPageObj.setListPageIndex(1,'work-main-view');
                EventHanderObj.refreshWorkList(function(){// 工作首页列表刷新
                    SwiperObj.autoHeight(0).autoHiddenAddMore(); // 刷新后 自动隐藏“更多”
                });    
            }
        // work发布弹出
        }else if(targetobj.parents('.pop-workadd').length === 1){            
            EventHanderObj.workPopAddtion(targetobj,options);
        // 打电话图标点击底部显示弹出框
        }else if(_this_tag === 'call'){
            logicHanderObj.Telephone(targetobj.attr('phonemobile')); 
            return false;
        // 点击刷新 
        }else if(targetobj.parents('#linecontentstatus').length === 1){
            ViewObj.delayExecSwitch();
            if(!NetworkObj.isOnline() ){
                NetworkObj.showNetworkTips('pop');
            } 
            return false;
        }        
    }
    var operation={};
    // 页面点击事件的全局方法
    operation.triggerCilckEvent=function(){
         var targetobj = arguments[0],
             click_type= '',
             click_component = '',
             options = {},
             other_options = {};
        // 第二个参数是 “对象”或者“undefined” 时，调用 other 事件处理
        // 第二个参数是 "header,body,footer"时，调用 normal事件处理
        if( ld.isPlainObject(arguments[1]) || 
            !arguments[1] ){

            click_type = 'other';
            other_options = ld.isPlainObject(arguments[1]) ? arguments[1] : {};

        }else if(typeof arguments[1] === 'string'){
            click_type = 'normal';
            click_component = arguments[1];
            options = ld.isPlainObject(arguments[2]) ? arguments[2] : {};
        } 

        if(click_type === 'normal'){
            execOpreation(targetobj,click_component,options,true);
        }else if(click_type === 'other'){
            execOtherComponentClickEvent(targetobj,other_options,true);
        }
    };
    return operation;
})();