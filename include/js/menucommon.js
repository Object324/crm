
var hoverMenuName = '';//记录导航区块名称

function menucommon(){

}
menucommon.childmenuclickbefore = function(relid,event){
    var tmps = {};


    ld.each(LeftMenu_functionobj.parenttabinfo,function(tmpname,tmplabel){
        var tmp_childlist = LeftMenu_functionobj.childtablist[tmpname];
        var isfind = 'no';
        ld.each(tmp_childlist,function (index,childdata) {
            if(childdata.id == relid){
                tmps = childdata;
                isfind = 'yes';
                return false;
            }
        });
        if(isfind == 'yes'){
            return false;
        }
    });

    menucommon.childmenuclick(tmps,event);
}
//菜单点击事件
menucommon.childmenuclick=function(obj,event){
    if(obj['module']){

    }else{
        obj['relid'] = obj['id'];
        obj['module']=obj['tablabel'];
        obj['type']=obj['tab_tablename'];
        obj['label']=obj['modulename'];
        if(obj['type']=='ld_linkmodulecustom'){
            if(obj['isopeninblank'] == ''){
                obj['isopeninblank'] = 'no';
            }
            obj['specialcheck'] = obj['checkphp']+"::"+obj['isopeninblank']+"::"+obj['linkcivid'];
            if(obj['module']=='CustomEcharts' || obj['module']== 'CustomTables'){

            }
            else if(obj['entitytype'] != undefined && obj['entitytype'] =='category' ){
                // @edit:dong @date:2020/12/02 @reason: bug数据分类自定义链接模块 右键打开页面错误
                obj['newUrl'] =  obj['linkurl'].substring(obj['linkurl'].indexOf('&start',obj['linkurl']));
            }else{
                if(obj['linkurl'].indexOf('CustomReport/JsReport/index.php?')>=0){
                    obj['linkurl'] = cls_encryptyurl.Puyoung_Encryptyurlhavephp(obj['linkurl'],'');
                }
            }
        }
    }


    //initDingFunction();//锁定事件
    var module=obj['module'];
    //duan 20240909 常用模块、审批数量、消息提醒比较占用时间，延迟到列表之后执行
    if(module != 'Home' && module != 'Cache' && module != 'RecycleBin' && obj['relid'] && parseInt(obj['relid']) > 0){
        var tablename = obj['type'];
        if (tablename == 'ld_linkmodulecustom' ){
            if (obj['entitytype'] == 'category'){
                tablename += '_'+obj['entitytype'];
            }else {
                module = '';
            }
        }
        menucommon.saveCommonFunctions(parseInt(obj['relid']),module,obj['tabid'],tablename);
    }

    if(obj['relid'] && ld('.parenttabrel-item[relid='+obj['relid']+']').length > 0){
        LeftMenu_functionobj.selectedparenttab = ld('.parenttabrel-item[relid='+obj['relid']+']').attr('parenttab');
        LeftMenu_functionobj.selectedparenttabrel = obj['relid'];
    }


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

        if(event!=undefined)
        {
            var ahrefobj=event.srcElement||event.target;

            if(ld(ahrefobj).attr("href") == undefined || ld(ahrefobj).attr("href") == ''){
                if(obj['tablabel']=='CustomEcharts' || obj['tablabel']== 'CustomTables'){
                    ld(ahrefobj).attr("href",obj['linkurl']);
                }
                else if(obj['entitytype'] != undefined && obj['entitytype'] =='category' ){
                    // @edit:dong @date:2020/12/02 @reason: bug数据分类自定义链接模块 右键打开页面错误
                    var newUrl =  obj['linkurl'].substring(obj['linkurl'].indexOf('&start',obj['linkurl']));
                    ld(ahrefobj).attr("href",'index.php?pageto_module='+obj['tablabel']+'&pageto_action=index&page_addurl='+encodeURIComponent(newUrl));
                }else{
                    if(obj['linkurl'].indexOf('CustomReport/JsReport/index.php?')>=0){
                        obj['linkurl'] = cls_encryptyurl.Puyoung_Encryptyurlhavephp(obj['linkurl'],'');
                    }
                    ld(ahrefobj).attr("href",obj['linkurl']);
                }
            }


            //zxm 20221103 报表分析 常用报表的链接模块 打开新页签 //20221130 常用报表的模块变成ReportAnalysis
            if(ld(ahrefobj).attr("href") != undefined&&(ld(ahrefobj).attr("href").indexOf("pageto_module=ReportAnalysis&pageto_action=newindex")>=0||
                ld(ahrefobj).attr("href").indexOf("pageto_module=ReportAnalysis&pageto_action=OftenUseReport")>=0))
            {
                obj.module = 'ReportAnalysis';
                OpenNewWebTab(ld(ahrefobj).attr("href"));
                //return false;
            }
            if(window.location.href!=undefined && window.location.href.toLocaleLowerCase().indexOf("https")>=0&&ld(ahrefobj).attr("href") != undefined&&ld(ahrefobj).attr("href").toLocaleLowerCase().indexOf("http:")>=0)
            {
                //edit:can 2020-10-20 42944: （https://61mis.com/kfbtest [^]）客户问题（普阳会计），首页->政务服务网，链接模块定制中的链接模块打不开，界面显示空白（需要补丁）
                OpenNewWebTab(ld(ahrefobj).attr("href"));
                //return false;
            }

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
        if(obj.file == 'listroles'){
            obj.classObjName = 'cls_RolesProfile';
            obj.classObjFunction = 'init';
        }
        menucommon.settingmenuclick(obj);
        return false;
    }
    // ls 2021-10-26 【ID1001109】增加“小程序商城设置”
    if(obj.module=="ShopSettings" || obj.module=="CardSettings"){
        if(obj.file==''||obj.file==undefined){
            obj.file='index';
        }
        menucommon.settingmenuclick(obj);
        return false;
    }
    if(obj.module=='listroles'){
        obj.module = 'Settings';
        obj.file = 'listroles';
        obj.classObjName = 'cls_RolesProfile';
        obj.classObjFunction = 'init';
        menucommon.settingmenuclick(obj);
        return false;
    }
    if(obj.module=='LoginPolicy'){
        obj.module='Settings';
        obj.file='loginpolicy';
        menucommon.settingmenuclick(obj);
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
    if(obj.type == 'ld_linkmodulecustom'&&ld(ahrefobj).attr("href")!=undefined&&ld(ahrefobj).attr("href").indexOf("pageto_module=OftenUseReport&pageto_action=newindex&page_addurl=")<0){

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
        // 帮助
        ld(" .detail_crumbs").find('.ld-fonticon').remove();

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

        //刷新消息提醒数量
        getRemindsCount();
        //刷新审批数量
        menucommon.getApproveCount();

        //搜客宝 hzx 20240424
        if(module=='ldsoukebao' || module=='ldsoukebaomap' || crmorprmtype == 'prm'){
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

menucommon.settingmenuclick=function(obj){
    var newUrl = "index.php";//修改从项目名后开始
    var module = obj.module;
    var file = obj.file;
    var label = obj.label;
    if (module == 'Users' && (file == 'index' || file == 'listview')) {
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
        // CrmPopup.global_listPopupObj=[];
        ld(" .detail_path li").html(label);
        // 帮助
        if(data.result.helpUrl && data.result.helpUrl.HelpUrl && data.result.helpUrl.HelpUrl!=""){
            ld(" .detail_crumbs").find('.ld-fonticon').remove();
            var helpHtml="<i title="+arrJsPopLabel['ONLINEHELP']+" class=\"ld-fonticon ld-fonticon-help\" onclick=\"OpenNewWebTab('"+data.result.helpUrl.HelpUrl+"','_blank')\"></i>";
            ld(" .detail_crumbs").append(helpHtml);
        }
        else{
            ld(" .detail_crumbs").find('.ld-fonticon').remove();
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

        // 初始化js类对象
        var classObjName = obj.classObjName;
        if(!empty(classObjName)){
            var classObj = new window[classObjName]();
            if(typeof classObj[obj.classObjFunction] === 'function'){
                var classObjFunction = obj.classObjFunction;
                classObj[classObjFunction](data.result);
            }
        }
        
        DelProgressObjs();
    });
}

menucommon.getApproveCount = function () {
    /* 异步获取审批中心数量 tujt 2014-08-29*/
    ldAjaxHtmlNoProgress('index.php','module=Approve&action=ApproveAjax&file=getApproveCount&ajax=true',function (response) {
        var rest = response.responseText;
        rest = trim(rest);
        if(rest > 0){
            document.getElementById('headerapprovecount').innerHTML = '('+trim(rest)+')';
        }
    });
}

//增加常用模块
menucommon.saveCommonFunctions=function(relid,module,tabid,tablename){
    var url = 'index.php?module=Users&action=UsersAjax&file=commonMenu&mode=save&relid='+relid+'&clickmodule='+module+'&tabname='+tablename+'&tabid='+tabid;
    ldAjaxHtmlNoProgressobj(url,'',function (data) {

    });
}

var _flag = 'yes';
//document.write('<scri'+'pt src="include/js/picklist.js" type="text/javascript"></s'+'cript>');
//清除缓存，有提示
function clearcaches(){
    if(_flag == 'yes'){
        _flag = 'no';
        getJsScript("include/js/Sys_Cache.js",function(){
            Sys_Cache.showPopup();

        });
        return false;

    }
}
//清除缓存，无提示
function clearcachesNoMsg(){
    if(_flag == 'yes'){
        _flag = 'no';
        new Ajax.Request('index.php',{
            queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: 'module=Cache&file=index&ajax=true&action=CacheAjax',
            onComplete: function(response) {
                if(response.responseText.indexOf('SUCCESS')>0){
                    ld('#rptContentLoading').hide();
                    puyoungJS_DialogBox.block();
                    puyoungJS_DialogBox.unblock();
                    _flag = 'yes';
                    return;
                }
            }
        });
    }
}


//加载内容中点击事件
function initContentLeftMenuClick(){
    initRightContentHeight();//加载右侧内容中菜单和详细内容高度

    //左侧区块点击事件
    ld(".statistic-analysis-sidebar .analysis-accordion-content .analysis-accordion-header").click(function(){
        var clickFlag = ld(this).parent().find('div.analysis-accordion').is(":hidden");
        ld(this).parent().parent().find('div.analysis-accordion').each(function(){
            ld(this).parent().find('div.analysis-accordion').hide();
        });
        ld('.statistic-analysis-sidebar .analysis-accordion-content .analysis-accordion-header').each(function(){
            ld(this).removeClass('selected');
        });
        if(clickFlag){
            ld(this).addClass('selected');
            ld(this).parent().find('div.analysis-accordion').show();
        }
        else{
            ld(this).removeClass('selected');
            ld(this).parent().find('div.analysis-accordion').hide();
        }
        //左侧菜单滚动条重置大小
        //ld(".statistic-analysis-sidebar").getNiceScroll().resize();
    });
    //左侧内容点击事件
    ld(".statistic-analysis-sidebar .analysis-accordion-content .analysis-accordion > ul > li > a").click(function(){
        ld('.statistic-analysis-sidebar .analysis-accordion > ul > li').each(function(){
            ld(this).removeClass('active');
        });
        ld(this).parent().addClass('active');
    });
}

//加载右侧内容中菜单和详细内容高度
/*function initRightContentHeight(){
    ld('.statistic-analysis-content .statistic-analysis-sidebar').css('height', parseInt(ld(window).height()) - parseInt(topheight) - parseInt(con_mt_height)+'px');
    ld('.main_grid .main_grid_box').css('height', parseInt(ld(window).height()) - parseInt(topheight) - parseInt(con_mt_height) - parseInt(main_grid_top) +'px');//46863
    ld('.main_grid .ld-operationlog-list-content').css('height', parseInt(ld(window).height()) - parseInt(topheight) - parseInt(con_mt_height) - parseInt(main_grid_top) -150 +'px');//46863
    ld('.main_grid_reportanalysis .main_grid_box').css('height', parseInt(ld(window).height()) - parseInt(topheight) - parseInt(con_mt_height) - parseInt(main_grid_top) +'px');//zxm 20221103 报表分析 打开新页面的常用报表 高度设置
    if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined"){
       //通讯录(pc端企业微信)
       cls_wxOpenDataobj.bindAllOpenData();
    }
}*/

//右侧宽度
function rightContentWidth(){
    ld('#'+ListView_Page.fullwidth_divid).css('width',getRightWidth());
    ld('#'+ListView_Page.content_tableid).css("width",getRightWidth());
    ld('#'+ListView_Page.header_table_divid).css("width",getRightWidth());
    ld('#'+ListView_Page.content_table_divid).css("width",getRightWidth());
    ld('#'+ListView_Page.header_tableid).css("width",getRightWidth());

    var popupobj=CrmPopup.getPopupObj('first');
    //常用报表界面没有listresizeobj对象
    if(popupobj!=undefined&&popupobj.listresizeobj!=undefined){
        popupobj.listresizeobj.setReiszeTable_Init(popupobj.module,'ajax');
    }
}
function getRightWidth(){

    return parseInt(CrmPopup.getClientWidth()) - parseInt(getLeftMenuWidth()) - 20;
}

function GetHttpRequest(){
    if ( window.XMLHttpRequest ) // Gecko

        return new XMLHttpRequest();

    else if ( window.ActiveXObject ) // IE

        return new ActiveXObject("MsXml2.XmlHttp");
}

function RemoveAllJsFileText(){
    var fileid='';
    while(global_js_sync_id.length>0){
        fileid=global_js_sync_id[global_js_sync_id.length-1];
        ld("#"+fileid).remove();
        global_js_sync_id.pop();
    }
}
function AjaxJSPage(sId, url){


    if(dynamicJsScript[sId]==1){

        return false;//不要重复加载js文件
        ld("#"+sId).remove()
    }
    dynamicJsScript[sId]=1;
    var oXmlHttp = GetHttpRequest() ;
    global_js_sync_id.push(sId);
    oXmlHttp.onreadystatechange = function(){
        if ( oXmlHttp.readyState == 4 ){
            if ( oXmlHttp.status == 200 || oXmlHttp.status == 304 ){
                //eval.call(window, oXmlHttp.responseText);
                IncludeJS( sId, url, oXmlHttp.responseText );
            }
            else{}
        }
    }
    oXmlHttp.open('GET', global_js_url+url+"?v="+Math.random()+global_js_version, false);
    oXmlHttp.send();
}

function IncludeJS(sId, fileUrl, source){
    if ( ( source != null ) && ( !document.getElementById( sId ) ) ){
        var oHead = document.getElementsByTagName('HEAD').item(0);
        var oScript = document.createElement( "script" );
        oScript.language = "javascript";
        oScript.type = "text/javascript";
        // oScript.src=global_js_url+fileUrl;
        oScript.id = sId;
        // oScript.defer = true;
        oScript.text = source;
        oHead.appendChild( oScript );
    }
}

//计算宽度
function setWidthForAll(){
    var div_width =CrmPopup.getClientWidth()-getLeftMenuWidth()-16;
    //首页组件
    ld('.widget-content .salekit-list .salekit-item').css('width', parseInt((div_width-28)/SalesKitCount)+'px');
    ld('#MainMatrix > div[tag=1]').css('width', div_width+'px');
    if(CrmPopup.getClientWidth() <= 414){
        ld('#MainMatrix > div[tag=2]').css('width', div_width+'px');
    }
    else{
        ld('#MainMatrix > div[tag=2]').css('width', (div_width/2-13)+'px');
    }
    //列表
    rightContentWidth();
}

//抽屉设置事件
function initDrawer(){
    ld('<div class="first-modal" autocomplete="off"></div>').appendTo("body");
    //关闭抽屉
    ld(".first-modal").click(function(){
        ld(".first-modal").remove();
        ld(".first-drawer-wrapper").remove();
    });
    var htmlStr =   '<div class="first-drawer-wrapper">' +
        '<div class="first-drawer-container">' +
        '<div class="first-drawer-header">' +
        '<span class="first-drawer-title"></span>' +
        '<span class="first-drawer-titlenum"></span>' +
        '<div class="first-drawer-headerbtn">' +
        '<button type="button"><i class="ld-fonticon ld-fonticon-close"></i></button>' +
        '</div>' +
        '</div>' +
        '<div class="first-drawer-body">' +
        '<div class="first-drawer-body-content"></div>' +
        '<div class="first-drawer-body-footer"></div>' +
        '</div>' +
        '</div>' +
        '</div>';
    if(ld(".first-drawer-wrapper").length < 1)
        ld(htmlStr).appendTo("body");
    //关闭抽屉
    ld(".first-drawer-headerbtn").click(function(){
        ld(".first-modal").remove();
        ld(".first-drawer-wrapper").remove();
        ld(document).unbind();
    });
}

//抽屉-审批
function initDrawerApprovepage(tabtype){
    ld('.first-drawer-title').html(arrJsPopLabel['APPROVAL']);
    var approveStr =    '<div class="demo-block demo-zh-CN demo-menu drawer-approve-page">' +
        '<div class="source">' +
        '<div>' +
        '<ul role="menubar" class="el-menu-demo el-menu--horizontal el-menu">' +
        '<li role="menuitem" class="el-menu-item" style="" tag="0">' + arrJsPopLabel['Pending'] +'</li>' +
        '<li role="menuitem" class="el-menu-item" style="" tag="1">' + arrJsPopLabel['Processed'] +'</li>' +
        '<li role="menuitem" class="el-menu-item" style="" tag="3">' + arrJsPopLabel['isubmitted'] +'</li>' +
        '<li role="menuitem" class="el-menu-item" style="" tag="4">' + arrJsPopLabel['ApproveRejected'] +'</li>' +
        '</ul>' +
        '</div>' +
        '</div>' +
        '</div>';
    if(ld(".drawer-approve-page").length < 1)
        ld('.first-drawer-body-content').append(approveStr);
    ld('.first-drawer-body-content ul.el-menu li.el-menu-item[tag='+tabtype+']').addClass('is-active');
    ld(".drawer-approve-page li").unbind('click').click(function(){
        ld('.drawer-approve-page li').each(function(){
            ld(this).removeClass('is-active');
        });
        ld(this).addClass('is-active');
        initDrawerApprovepageClick(ld(this).attr('tag'));
    });

    ld(".drawer-approve-page li").css('width',(100)/ld(".drawer-approve-page li").length+'%');
}
function initDrawerApprovepageClick(tabtype){
    ld('[name="approve_href"]').first().attr('data-tabtype', tabtype);
    var moduleStr = '<div class="weui-grids weui-grids-drawer"></div>';
    var surl = "index.php?";
    loadStr('first-drawer-body-content', 'weui-grids-drawer');
    ldAjaxNoProgress(surl,"module=Users&action=UsersAjax&file=getApproveCount&tabtype="+tabtype,function(data){
        if(data.code==1){
            var approve_html = '';

            if(data.result.approvenum >= 1){
                var arpprove_array =  eval("("+data.result.arpproveinfo+")")?eval("("+data.result.arpproveinfo+")"):json.parse(data.result.arpproveinfo);
                approve_html = '<div class="weui-grids weui-grids-drawer">';
                ld.each(arpprove_array,function(_key,approveobj){
                    approve_html += '<a href="javascript:" class="weui-grid" role="button" onclick="ApproveHrefListView(\''+approveobj['module']+'\',\''+tabtype+'\', false)">' +
                        '<div class="weui-grid-bg">' +
                        '<div class="weui-grid__icon">' + approveobj['num'] + '</div>' +
                        '<p class="weui-grid__label">'+approveobj['modulelabel']+'</p>' +
                        '</div>' +
                        '</a>';
                });
                approve_html += '</div>';
                var titleStr = '（'+data.result.approvenum+'）';
                ld('.first-drawer-titlenum').html(titleStr);
            }
            else{
                approve_html = '<div class="weui-grids-drawer nodata">' + arrJsPopLabel['NOINFO'] + '</div>';
                //zkt 20220616 BUG0052873（http://crm.airmaster.com.cn/crm/）首页待审批提示是1个审批。但是右上角的审批是11个，实际上就是11个。
                ld('.first-drawer-titlenum').html('');
            }
            //duan 20240914 点击待审批时，更新列表审批数量
            if(tabtype == 0){
                if(data.result.approvenum >= 1){
                    ld('#headerapprovecount').html('('+data.result.approvenum+')');
                }else{
                    ld('#headerapprovecount').html('');
                }
            }
            // setTimeout(() => {
            ld('.weui-grids-drawer').remove();
            ld('.first-drawer-body-content').append(approve_html);
            // }, 2000);
            // //点击抽屉其他位置，关闭抽屉
            // ld(document).click(function(e){
            //     var target = ld(e.target);
            //     if(target.closest(".first-drawer-wrapper").length == 0){
            //         ld(".first-drawer-wrapper").remove();
            //         ld(document).unbind();
            //     }
            // });
        }
        //异地登录
        if(data.code==DataCode.logincontrol){
            Tools.Relogin();
        }
    });
}

//加载效果
function loadStr(operationClass, loadclass){
    var load_html = '<div class="el-loading-mask ' + loadclass + '">' +
        '<div class="el-loading-spinner">' +
        '<svg viewBox="25 25 50 50" class="circular"><circle cx="50" cy="50" r="20" fill="none" class="path"></circle></svg>' +
        '</div>' +
        '</div>';
    ld('.'+operationClass).append(load_html);
}
function quickCreateSearch(){
    var search_str = ld('#quickcreate .quickcreate-search-area input#query_string').val();
    if(ld.trim(search_str) == ''){
        ld.each(ld('#quickcreate [name=quickcreate_list] p'),function (){
            if(ld(this).find('span').length>0){
                ld(this).html(ld(this).data('fieldtable'));
            }
        });
    }else{
        ld.each(ld('#quickcreate [name=quickcreate_list] p'),function (){
            if(ld(this).find('span').length>0){
                ld(this).html(ld(this).data('fieldtable'));
            }
        });
        var tmpfirstScrollTo = 'no';
        if(ld('#quickcreate [name=quickcreate_list] p[data-fieldtable*=\'' + search_str + '\']').length>0) {
            ld.each(ld('#quickcreate [name=quickcreate_list] p[data-fieldtable*=' + search_str + ']'), function (index, liobj) {
                var field_label = ld(this).html();
                var span_html = '<span class="ld-Highlight">' + search_str + '</span>';
                var reg = new RegExp(search_str, "g");
                var new_field_label = field_label.replace(reg, span_html);
                // ljj 20240416 BUG20240416-09 快速创建弹出层中，搜索模块名称后，没有自动定位到模块名称处
                if (tmpfirstScrollTo == 'no'){
                    var scrolltop=ld('#quickcreate [name=quickcreate_list]').scrollTop();
                    var position = ld(this).offset();
                    var top = position.top + scrolltop - 190;
                    ld('#quickcreate [name=quickcreate_list]').animate({scrollTop:top}, 100);
                    tmpfirstScrollTo = 'yes';
                }
                ld(this).html(new_field_label);
            });
        }
    }
}
function quickCreateSearch_Key(e){
    if(e.keyCode == 13){
        quickCreateSearch();
    }
}
function quickCreateSearchPop_Key(e,type){
    if(e.keyCode == 13){
        quickCreateSearchPop(type);
    }
}
function quickCreateSearchPop(type){
    var popupobj=CrmPopup.getPopupObj("last");
    var tmp_contentid = '';
    if(type=='search'){
        tmp_contentid = 'UnifiedSearch_moduleform';
    }else if(type=='quickcreate'){
        tmp_contentid = 'UnifiedQuickcreate_moduleform';
    }

    var divobj = ld('#'+popupobj.divid);
    var search_str = ld('#'+popupobj.divid+' .page-topsec-area input#query_string').val();
    search_str = ld.trim(search_str);
    var searchResultTipobj = divobj.find('#searchResultTip');
    var UnifiedSearch_divobj = divobj.find('[name=UnifiedSearch_div]');
    var nocontentobj =  divobj.find('#nocontent');
    var UnifiedSearch_moduledivobj = divobj.find('#UnifiedSearch_modulediv');
    var search_onlyin_all_divobj = divobj.find('#search_onlyin_all_div');

    var nocontent = true;
    if (empty(search_str)){
        searchResultTipobj.css('display','none');
        UnifiedSearch_divobj.css('display','');
        search_onlyin_all_divobj.css('display','');
        nocontent = false;
    }else {
        search_onlyin_all_divobj.css('display','none');
        searchResultTipobj.css('display','');
        searchResultTipobj.html('<span>'+arrJsPopLabel['Include']+'"'+search_str+'"'+arrJsPopLabel['SEARCHTITLE']+'</span>');
        ld.each(UnifiedSearch_divobj,function () {
            var spanobj = ld(this).find('[tag=UnifiedSearch_span]');
            var text = spanobj.data('fieldtable');
            if (text.indexOf(search_str) > -1){
                ld(this).css('display','');
                nocontent = false;
            }else {
                ld(this).css('display','none');
            }
        })
    }
    if (nocontent){
        UnifiedSearch_moduledivobj.css('display','none');
        nocontentobj.css('display','');
    }else {
        UnifiedSearch_moduledivobj.css('display','grid');
        nocontentobj.css('display','none');
    }
}


// ljj 20231207 XUQIU1002271 系统PC端头部处可设置
function headerSetting(module,record){
    this.module=module;
    this.record=record;
    this.divid='';
    var that=this;

    this.getHeaderSetting= function (){
        var url = "index.php?module="+that.module+"&action="+that.module+"Ajax&file=HeaderSettings&option=gethtml&record="+that.record;
        var popupobj=CrmPopup.load("","","","LdPopWidth600px",'Home',"","","","");
        popupobj.prevshow();
        ldAjaxNoProgress(url,'',function(data){
            if(data.code == 1){
                popupobj.setParams(data.result.title,that.saveHeaderSetting,"","LdPopWidth450px","Home","",data.result.oktext,"",data.result.canceltext,"");
                popupobj.show(data.result.content);
                that.divid=popupobj.divid;

                // 选择无法选中的select并置灰色
                ld("#"+that.divid).find('select[disabled=""]').each(function (index,element){
                    ld(element).addClass('cursorNotAllowed');
                });
                // var qucikfindsetting=ld("#"+that.divid).find('[name=quickfindsetting]');
                // var quickcreatesetting=ld("#"+that.divid).find('[name=quickcreatesetting]');
                // var approvalremindsetting=ld("#"+that.divid).find('[name=approvalremindsetting]');
                // var userinfosetting=ld("#"+that.divid).find('[name=userinfosetting]');
                // if(qucikfindsetting.length>0&&qucikfindsetting!=undefined) {
                //     var qucikfindsettingobj=new cls_resetComboxHtml(qucikfindsetting.attr("name"));
                //     qucikfindsettingobj.setPopupObj(popupobj);
                //     qucikfindsettingobj.setSearchComboxWidthByhtml(qucikfindsetting, qucikfindsetting.css('width'));
                // }
                // if(quickcreatesetting.length>0&&quickcreatesetting!=undefined) {
                //     var quickcreatesettingobj=new cls_resetComboxHtml(quickcreatesetting.attr("name"));
                //     quickcreatesettingobj.setPopupObj(popupobj);
                //     quickcreatesettingobj.setSearchComboxWidthByhtml(quickcreatesetting, quickcreatesetting.css('width'));
                // }
                // if(approvalremindsetting.length>0&&approvalremindsetting!=undefined) {
                //     var approvalremindsettingobj=new cls_resetComboxHtml(approvalremindsetting.attr("name"));
                //     approvalremindsettingobj.setPopupObj(popupobj);
                //     approvalremindsettingobj.setSearchComboxWidthByhtml(approvalremindsetting, approvalremindsetting.css('width'));
                // }
                // if(userinfosetting.length>0&&userinfosetting!=undefined) {
                //     var userinfosettingobj=new cls_resetComboxHtml(userinfosetting.attr("name"));
                //     userinfosettingobj.setPopupObj(popupobj);
                //     userinfosettingobj.setSearchComboxWidthByhtml(userinfosetting, userinfosetting.css('width'));
                // }
            }
        });
    }
    this.saveHeaderSetting=function (){
        var qucikfindsetting_value=ld("#"+that.divid).find('[name=quickfindsetting]').val();
        var quickcreatesetting_value=ld("#"+that.divid).find('[name=quickcreatesetting]').val();
        var approvalremindsetting_value=ld("#"+that.divid).find('[name=approvalremindsetting]').val();
        var userinfosetting_value=ld("#"+that.divid).find('[name=userinfosetting]').val();
        var helpmanualsetting_value=ld("#"+that.divid).find('[name=helpmanualsetting]').val();
        // 获取参数生效范围
        var quickfindsetting_scope_value=ld("#"+that.divid).find('[name=quickfindsetting_scope]').val();
        var quickcreatesetting_scope_value=ld("#"+that.divid).find('[name=quickcreatesetting_scope]').val();
        var approvalremindsetting_scope_value=ld("#"+that.divid).find('[name=approvalremindsetting_scope]').val();
        var helpsetting_scope_value=ld("#"+that.divid).find('[name=helpsetting_scope]').val();
        var userinfosetting_scope_value=ld("#"+that.divid).find('[name=userinfosetting_scope]').val();
        var url = "index.php?module="+that.module+"&action="+that.module+"Ajax&file=HeaderSettings&option=save&record="+that.record;
        url += '&qucikfindsetting='+qucikfindsetting_value;
        url += '&quickcreatesetting='+quickcreatesetting_value;
        url += '&approvalremindsetting='+approvalremindsetting_value;
        url += '&userinfosetting='+userinfosetting_value;
        url += '&helpmanualsetting='+helpmanualsetting_value;
        // 新增参数生效范围
        url += '&quickfindsetting_scope='+quickfindsetting_scope_value;
        url += '&quickcreatesetting_scope='+quickcreatesetting_scope_value;
        url += '&approvalremindsetting_scope='+approvalremindsetting_scope_value;
        url += '&helpsetting_scope='+helpsetting_scope_value;
        url += '&userinfosetting_scope='+userinfosetting_scope_value;
        ldAjaxNoProgress(url,'',function(data){
            if(data.code == 1){
                MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYMODIFIED']);
                setTimeout(function () {
                    window.location.reload();
                },500);
            }
        });

    }

}


//zsk 2024/3/20 BUG20240318-55 查询分类和查看范围的搜索框增加输入内容一键清除功能
function clearBasicSearchScope(obj){
    event.preventDefault();
    event.stopPropagation();
    ld(obj).siblings('input').val('');
    ld(obj).css('visibility','hidden');
    ld(obj).siblings('input').focus();
    if (ld(obj).attr('module') !== undefined) {
        //BUG20240703-54 清空搜索框后刷新右侧分类列表
        ld('#showCustomlist_new #showCustomlist_search').trigger('keyup'); // 触发 keyup 事件
    }
}
function searchScopeSetShowOrHideClearIcon(obj){
    var search_text =ld(obj).val();
    //显示清除按钮\
    if(!empty(search_text)){
        ld(obj).siblings('b').css('visibility','visible');
        //隐藏排序按钮
        obj1=ld(obj).closest('.ld-form-item-content');
        obj1=ld(obj1).siblings('div[class="ld-form-item-head"]');
        ld(obj1).find('.second_switch').css('visibility','hidden');
    }else{
        ld(obj).siblings('b').css('visibility','hidden');
        //显示排序按钮
        obj1=ld(obj).closest('.ld-form-item-content');
        obj1=ld(obj1).siblings('div[class="ld-form-item-head"]');
        ld(obj1).find('.second_switch').css('visibility','visible');
    }
}


// 固定列和表头整体高度
function lockingHeaderColumn(containerObj, options){
    var containerObj = ld(containerObj);
    var containerTableObj = containerObj.find('table');
    if (containerObj.length > 0) {
        var divWidth = containerObj.width();
        var tableWidth = containerTableObj.width();
        containerObj.css('height', options.height+'px');

        var positionLeftWidthArr = [];
        if (containerTableObj.length > 0) {
            var cur_left = 0;
            containerTableObj.find("thead tr th").each(function(key, thobj) {
                var cur_width = ld(thobj).outerWidth();
                var tmparr = {'width':cur_width,'left':cur_left};
                positionLeftWidthArr.push(tmparr);
                cur_left = cur_left+parseInt(cur_width);
            });
        }

        containerObj.scroll(function (){
            if(containerObj.scrollTop() > 0){
                if(containerTableObj.find('thead tr th').length>0){
                    containerTableObj.find('thead tr th').addClass('shadow-bottom');
                }
            }
            else{
                if(containerTableObj.find('thead tr th').length>0) {
                    containerTableObj.find('thead tr th').removeClass('shadow-bottom');
                }
            }

            let lockIndex = 0;
            containerTableObj.find('thead th').each(function(i,thobj) {
                if (ld(this).hasClass('locking-left')) {
                    lockIndex = i+1;
                }
            });

            var scrollLeft = containerObj.scrollLeft();
            if (scrollLeft > 0) {
                containerTableObj.find('tbody td.locking-left, thead th.locking-left').each(function() {
                    ld(this).addClass('shadow-left');
                });
                containerTableObj.find('thead th').each(function(key, obj) {
                    if(key<lockIndex){
                        setTableThTdCssSticky(obj, '3', positionLeftWidthArr[key].left);
                    }
                });
                containerTableObj.find('tbody tr').each(function(keytr, objtr) {
                    ld(objtr).find('td').each(function(keytd, objtd) {
                        if(keytd<lockIndex){
                            setTableThTdCssSticky(objtd, '2', positionLeftWidthArr[keytd].left);
                        }
                    });
                });
            }
            else {
                containerTableObj.find('tbody td.locking-left, thead th.locking-left').each(function() {
                    ld(this).removeClass('shadow-left');
                });
            }
            if (scrollLeft + divWidth < tableWidth) {
                containerTableObj.find('tbody td.locking-right, thead th.locking-right').each(function() {
                    ld(this).addClass('shadow-right');
                });
            }
            else {
                containerTableObj.find('tbody td.locking-right, thead th.locking-right').each(function() {
                    ld(this).removeClass('shadow-right');
                });
            }
        });

        if (containerTableObj.length > 0) {
            let thWidthCount = 0;
            containerTableObj.find("thead tr th").each(function() {
                let thWidth = '', thWidthArr = [];
                if(ld(this).attr("width")){
                    thWidth = ld(this).attr("width");
                    thWidthArr = thWidth.split('px');
                    thWidth = parseInt(thWidthArr[0]);
                }
                else{
                    thWidth = parseInt(ld(this).outerWidth());
                }
                thWidthCount += thWidth;
            });
            let lastChild2Width = options.width-thWidthCount+parseInt(options.thwidth);
            if(lastChild2Width < parseInt(options.thwidth)){
                lastChild2Width = parseInt(options.thwidth);
            }
            else{
                var scrollWidth = containerObj.width() - containerObj[0].clientWidth;
                lastChild2Width -= scrollWidth;
            }
            containerTableObj.find("thead tr th.locking-rightleft").css("width", lastChild2Width+"px");
        }

        if(options.width >= tableWidth){
            containerObj.css('overflow-x', 'hidden');
        }
        else{
            containerObj.css('overflow-x', 'auto');   
        }
    }
}
function setTableThTdCssSticky (tdobj, zindex, left){
    ld(tdobj).css('position', 'sticky').css('z-index', zindex).css('left', left+ 'px');
}