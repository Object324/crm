function BusinessInformation(){
    var that=this;
    var pagetype = '';
    this.tableobj = '';
    this.fieldTypetoLabel = {
        "text" : "文本",
        "picklist" : "下拉框",
        "phone" : "电话",
        "date" : "日期",
        "datetime" : "日期时间",
        "email" : "Email",
        "url" : "网址",
        "textarea" : "文本区域",
        "longtextarea" : "整行文本区域",
        "mobile" : "手机",
        "moduleno" : "单据编号",
        "number" : "数字",
        "currency" : "货币",
    }
    this.iscreatingmodule = 'no';// 是否正在创建工商模块

    that.setPopupobj = function(obj){
        that.popupobj = obj;
    }
    //切换页签对应的事件
    that.BusinessPageChangeSetEvent = function (pagetype,ajaxdata){
        that.pagetype = pagetype;
        var popupobj = that.popupobj;
        //设置表格高度
        var businessinformationlistheaderheight = 0;
        if(ld("#businessinformationlistheader").length>0){
            businessinformationlistheaderheight = ld("#businessinformationlistheader").outerHeight()+5;//5 margin-bottom
        }
        var showpagecontentheaderheight = 0;
        if(ld("#showpagecontentheader").length>0){
            showpagecontentheaderheight = ld("#showpagecontentheader").outerHeight();
        }
        var showpagecontentbottomheight = 0;
        if(ld("#showpagecontentbottom").length>0){
            showpagecontentbottomheight = ld("#showpagecontentbottom").outerHeight();
        }
        ld("#"+popupobj.divid).find("#showpagecontentbody").height(parseInt(ld(".main_grid_box").outerHeight())-businessinformationlistheaderheight-showpagecontentheaderheight-showpagecontentbottomheight);
        if(pagetype == 'functionsetting'){
            that.tableobj = ld('#'+that.popupobj.divid).find('#business_information');
            var selectobj=ld("#"+popupobj.divid).find("select#businessqueryfield");
            for(var i=0;i<selectobj.length;i++){
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj.eq(i).attr("name"));
                cls_resetComboxHtmlobj.setPopupObj(popupobj);
                var selectwidth = Tools.getParentobjByChild(selectobj.eq(i),'td').width();
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj.eq(i),selectwidth+10);
            }
        }
        else if(pagetype == 'backfillingmaprule'){
            var selecttypeobj=ld("#"+popupobj.divid).find("#backfillingmapmodule");
            if(selecttypeobj.length>0&&selecttypeobj!=undefined){
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selecttypeobj.attr("name"));
                cls_resetComboxHtmlobj.setPopupObj(popupobj);
                var selectwidth = Tools.getParentobjByChild(selecttypeobj,'td').width();
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selecttypeobj,selectwidth+10);
            }
        }
        else if(pagetype == 'businessdataanalysis'){
            var businessdataanalysis_chartsobj = ld("#businessdataanalysis_charts");
            var optiondata_arr = ajaxdata.result;
            if(optiondata_arr.xlinedata.length>0){
                var option = {
                    title: {
                        text: optiondata_arr.optiontitle
                    },
                    tooltip: {
                        trigger: 'axis'
                    },
                    legend: {
                        data: optiondata_arr.charlinedata
                    },
                    grid: {
                        left: '3%',
                        right: '4%',
                        bottom: '3%',
                        containLabel: true
                    },
                    toolbox: {
                        feature: {
                            saveAsImage: {}
                        }
                    },
                    xAxis: {
                        type: 'category',
                        boundaryGap: false,
                        data: optiondata_arr.xlinedata
                    },
                    yAxis: {
                        type: 'value'
                    },
                    series: [
                        {
                            name: optiondata_arr.charlinedata[0],
                            type: 'line',
                            data: optiondata_arr.ylinedata0
                        },
                        {
                            name: optiondata_arr.charlinedata[1],
                            type: 'line',
                            data: optiondata_arr.ylinedata1
                        }
                    ]
                };
                var charobj = echarts.init(businessdataanalysis_chartsobj.get(0));
                charobj.setOption(option);
            }
        }
        if(ajaxdata.result && ajaxdata.result.business_insterfacekey_deploy_value != undefined){
            var business_insterfacekey_deploy_value = ajaxdata.result.business_insterfacekey_deploy_value;
            if(business_insterfacekey_deploy_value == 0){
                ld(that.ld_navbarobj.LayoutObj).find('li[data-navbarid="businesslog"]').css('display','none');
                ld(that.ld_navbarobj.LayoutObj).find('li[data-navbarid="businessdataanalysis"]').css('display','none');
            }
        }

        if(pagetype != 'businessdataanalysis'){
            var businesstableobj = ld('.main_grid_box').find("#showpagecontentbody");
            if(businesstableobj.length > 0){
                businesstableobj.scroll(function (){
                    if(businesstableobj.scrollTop() > 0){
                        if(businesstableobj.find('tr').length>0){
                            businesstableobj.find('tr').eq(0).addClass('ld-setting-tabtop-shadow');
                        }
                    }else{
                        if(businesstableobj.find('tr').length>0){
                            businesstableobj.find('tr').eq(0).removeClass('ld-setting-tabtop-shadow');
                        }
                    }
                });
            }
        }
    }
    //切换工商查询方式，onchange隐藏或显示勾选
    that.BusinessSearchChange = function(obj){
        var search_type = ld(obj).val();
        var urlstring = 'module=Settings&action=SettingsAjax&file=BusinessQuerySettings';
        urlstring += '&mode=changebusinessqueryinterfacemethod';
        urlstring += '&business_search_method='+search_type;
        ldAjaxNoProgress('index.php?',urlstring,function(ajaxdata){
            if(ajaxdata.code == 2){
                that.editBusiness_insterfacekey();
                return false;
            }
            var StuffNavBarList = [];
            var selectheaderarr = that.headerarr;
            if(search_type == 0){
                selectheaderarr = that.nobusinessheaderarr;
            }
            var isselected = 'yes';
            var headerindex = 0;
            var selectpage = that.ld_navbarobj.CurNavBarEvent.NavBarItem.id;
            ld.each(selectheaderarr,function (index,headerid){
                var isselected = 'no';
                if(selectpage = headerid){
                    isselected = 'yes';
                }
                StuffNavBarList[headerindex] = { label:arrJsPopLabel[headerid], selected: isselected, id:headerid};
                headerindex++;
            })
            that.ld_navbarobj.SetNavBar(that.ld_navbarobj.LayoutObj,StuffNavBarList,that.ld_navbarobj.Options);
            if(search_type=="1"){
                ld('#businessqueryinterfacemethod option[value = "1"]').attr('selected', 'selected');
                ld('#businessqueryinterfacemethod option[value = "0"]').removeAttr('selected');
                ld('#business_insterfacekey_tr').hide();
                ld('#business_usage_period_tr').show();
                ld(that.ld_navbarobj.LayoutObj).find('li[data-navbarid="businesslog"]').css('display','');
                ld(that.ld_navbarobj.LayoutObj).find('li[data-navbarid="businessdataanalysis"]').css('display','');
            }
            else{
                ld('#businessqueryinterfacemethod option[value = "1"]').removeAttr('selected');
                ld('#businessqueryinterfacemethod option[value = "0"]').attr('selected', 'selected');
                ld('#business_insterfacekey_tr').show();
                ld('#business_usage_period_tr').hide();
                ld(that.ld_navbarobj.LayoutObj).find('li[data-navbarid="businesslog"]').css('display','none');
                ld(that.ld_navbarobj.LayoutObj).find('li[data-navbarid="businessdataanalysis"]').css('display','none');
            }
        })
    }

    that.editBusiness_insterfacekey = function(){
        //产生弹窗
        var popupobj = that.popupobj;
        var Popupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
        Popupobj.prevshow();
        var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=BusinessQuerySettings&mode=getbusiness_insterfacekeypop';
        ldAjax(urlstring,{},function (ajaxdata) {
            if (ajaxdata.code == 1) {
                Popupobj.setParams(ajaxdata.result.title, that.SaveBusiness_insterfacekey, "", "LdPopWidth800px", 'Settings', "", ajaxdata.result.oktext, "", ajaxdata.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj, ajaxdata.result.content);
                Popupobj.havesensitivevalue = ajaxdata.result.havesensitivevalue;
                Popupobj.sensitiveencryptvalue = ajaxdata.result.sensitiveencryptvalue;
                Popupobj.business_insterfacekey_encryptkey = ajaxdata.result.business_insterfacekey_encryptkey;
                ld("#"+Popupobj.divid+" #business_insterfacekey").unbind("change").bind("change",function(event){
                    //zkt 20240428 BUG20240428-34 自购天眼查接口无法使用
                    Popupobj.havesensitivevalue = 'no';
                    Popupobj.sensitiveencryptvalue = '';
                })
            }
        })
    }

    //保存设置的key值
    that.SaveBusiness_insterfacekey = function()
    {
        var popupobj = CrmPopup.getPopupObj('last');
        var urlstring = "module=Settings&action=SettingsAjax&file=BusinessQuerySettings&mode=savebusiness_insterfacekey";
        var business_insterfacekey_value = ld('#'+popupobj.divid+' [name=business_insterfacekey').val();
        var havesensitivevalue = popupobj.havesensitivevalue;
        var business_insterfacekey_encryptkey = popupobj.business_insterfacekey_encryptkey;
        var sensitiveencryptvalue = popupobj.sensitiveencryptvalue;
        if(havesensitivevalue == 'yes'){
            business_insterfacekey_value = ld_js_secret(sensitiveencryptvalue,business_insterfacekey_encryptkey,true);
        }
        else{
            sensitiveencryptvalue = ld_js_secret(business_insterfacekey_value,business_insterfacekey_encryptkey,false);
        }
        if(business_insterfacekey_value !=undefined && business_insterfacekey_value==''){
            //选择自购查询时，key必填
            var confilrm_str = arrJsPopLabel['TIANYANCHABUSINESSINTERFACEKEYNOTNULL'];//天眼查接口不能为空
            RemindsMsg("","LdPopWidth400px","","yes","",confilrm_str);
            return false;
        }
        //加密
        var secretbusiness_insterfacekey_value = encodeURIComponent(sensitiveencryptvalue);
        urlstring += "&business_insterfacekey_value="+secretbusiness_insterfacekey_value;
        ldAjaxNoProgress('index.php',urlstring,function(ajaxdata){
            if(ajaxdata.code == 1){
                popupobj.CancelEvent();
                ld('#businessqueryinterfacemethod option[value = "1"]').removeAttr('selected');
                ld('#businessqueryinterfacemethod option[value = "0"]').attr('selected', 'selected');
                ld('#business_insterfacekey_tr').show();
                ld('#business_usage_period_tr').hide();
                ld('#business_insterfacekey_span').text(ajaxdata.result.newinterfacekey);
                ld(that.ld_navbarobj.LayoutObj).find('li[data-navbarid="businesslog"]').css('display','none');
                ld(that.ld_navbarobj.LayoutObj).find('li[data-navbarid="businessdataanalysis"]').css('display','none');
            }
            else if(ajaxdata.code==-1){
                RemindsMsg("","LdPopWidth400px","","yes","",ajaxdata.msg);
                return false;
            }
        })
    }
    //保存设置的工商模糊查询开始查询数量
    that.SaveBusiness_fuzzyquery_num = function(obj)
    {
        var fuzzyquerytosearchnum = ld(obj).val();
        var urlstring = "module=Settings&action=SettingsAjax&file=BusinessQuerySettings&mode=savebusiness_fuzzyquery_count";
        urlstring += "&fuzzyquerytosearchnum="+fuzzyquerytosearchnum;
        ldAjaxNoProgress('index.php',urlstring,function(ajaxdata){
            if(ajaxdata.code == 1){
            }
        })
    }

    //更多按钮-工商查询设置-点击【设置例外条件】对应事件
    that.BusinessExpection = function (obj)
    {
        var parenttrobj = Tools.getParentobjByChild(ld(obj),'tr');
        var frommodule = ld(parenttrobj).data('module');
        var Popupobj=CrmPopup.load("","","","LdPopWidth800px",'',"","","","");
        Popupobj.prevshow();
        Popupobj.advanceSearchDivid=Popupobj.divid;
        var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=BusinessQueryAdvancePop&frommodule=' + frommodule;
        ldAjax(urlstring,{},function (ajaxdata) {
            if (ajaxdata.code == 1) {
                Popupobj.setParams(ajaxdata.result.title, that.save_business_advancedemand, "", "LdPopWidth800px", frommodule, "", ajaxdata.result.oktext, "", ajaxdata.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj, ajaxdata.result.content);

                var advancefilterobj = new cls_advanceFilter();
                var params = {};
                that.advanceFilterObj = advancefilterobj;
                params.columnOptionHtml = ajaxdata.result.columns_block;
                params.fLabels = ajaxdata.result.fLabels;
                params.datetimestr = ajaxdata.result.datetimestr;
                params.advfilterhtml = ajaxdata.result.advfilterhtml;
                params.fieldsinfo = ajaxdata.result.fieldinfo;
                params.criteria_groups_arr = ajaxdata.result.criteria_groups_arr;
                params.module = frommodule;
                params.source = ajaxdata.result.source;
                // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
                params.advanceFields = ajaxdata.result.advanceFields;
                advancefilterobj.showAdvanceFilter(Popupobj,params);

                DelProgressObjs();
            }
        })
    }

    //工商模糊查询规则设置-点击【设置模糊查询规则】对应事件
    that.BusinessFuzzyControl = function (obj)
    {
        var parenttrobj = Tools.getParentobjByChild(ld(obj),'tr');
        var frommodule = ld(parenttrobj).data('module');
        var Popupobj=CrmPopup.load("","","","LdPopWidth600px",'',"","","","");
        Popupobj.prevshow();
        Popupobj.module = frommodule;
        var mode = 'getfuzzycontrol';
        var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=BusinessQuerySettings'+'&mode='+mode+'&frommodule=' + frommodule;
        ldAjax(urlstring,{},function (ajaxdata) {
            if (ajaxdata.code == 1) {
                Popupobj.setParams(ajaxdata.result.title, that.save_business_fuzzycontrol, "", "LdPopWidth600px", frommodule, "", arrJsPopLabel['SAVE'], "", arrJsPopLabel['CANCEL']);
                Popupobj.show( ajaxdata.result.content);
            }
        })
    }
    that.save_business_fuzzycontrol = function(){
        var popupobj=CrmPopup.getPopupObj('last');
        var obj = ld('#'+popupobj.divid+" input[type='checkbox']");
        var changevalue = '{';
        for (var i = 0; i < obj.length; i++) {
            changevalue += '"'+obj.eq(i).prop('id') + '":' + (obj.eq(i).is(':checked') ? '"yes"' : '"no"');
            changevalue+=i<obj.length-1?',':'}';
        }
        var urlstring = 'module=Settings&action=SettingsAjax&file=BusinessQuerySettings&setmodule='+popupobj.module;
        urlstring += '&mode=setinformationvalue';
        urlstring += '&settype=fuzzyquerycontrol';
        urlstring += '&changevalue='+changevalue;
        ldAjaxNoProgress('index.php?',urlstring,function(ajaxdata) {
            if(ajaxdata.code == 1) {
                popupobj.CancelEvent();
            }
        })
    }
    //更新设置的例外条件值
    that.save_business_advancedemand=function(){
        var popupobj=CrmPopup.getPopupObj('last');
        if(!that.advanceFilterObj.checkAdvancedFilter()) return false;
        var advft_criteria = that.advanceFilterObj.advft_criteria;
        var advft_criteria_groups = that.advanceFilterObj.advft_criteria_groups;
        var frommodule = popupobj.module;
        popupobj.CancelEvent();
        var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=BusinessQuerySettings&mode=saveadvancedemand&setmodule=' + frommodule;
        urlstring += '&advancesearch=' + advft_criteria;
        urlstring += '&groupcondition=' + advft_criteria_groups;
        ldAjax(urlstring,{},function (ajaxdata) {
            if (ajaxdata.code == 1) {

            }
        })
    }

    that.BusinessInformationset=function(obj,module,type)
    {
        //勾选状态
        if(ld(obj).is(':checked')){
            var changevalue = 'yes';
        }else{
            var changevalue = 'no';
        }
        var parenttrobj = Tools.getParentobjByChild(ld(obj),'tr');
        var urlstring = 'module=Settings&action=SettingsAjax&file=BusinessQuerySettings&setmodule='+module;
        urlstring += '&mode=setinformationvalue';
        urlstring += '&settype='+type;
        urlstring += '&changevalue='+changevalue;
        ldAjaxNoProgress('index.php?',urlstring,function(ajaxdata){
            if(type=='nobusinessnosave'){
                if(changevalue == 'yes'){
                    //没有勾选没有工商信息不允许保存（新建/编辑）时，设置例外规则及不允许导入 可以进行选择
                    ld(parenttrobj).find(" [name=nobusiness_notimport]").attr('disabled',false);
                    ld(parenttrobj).find(" [name=business_expection]").css('display','inline');
                }
                else{
                    if(ld(parenttrobj).find(" [name=nobusiness_notimport]").prop('checked')==true){
                        ld(parenttrobj).find(" [name=nobusiness_notimport]").prop('checked',false);
                    }
                    //没有勾选没有工商信息不允许保存（新建/编辑）时，设置例外规则及不允许导入不能选择
                    ld(parenttrobj).find(" [name=nobusiness_notimport]").attr('disabled',"disabled");
                    ld(parenttrobj).find(" [name=business_expection]").css('display','none');
                }
            }
            else if(type=='enablebusiness'){
                if(changevalue == 'yes'){
                    ld(parenttrobj).find(" [name=nobusiness_notsave]").attr('disabled',false);
                    ld(parenttrobj).find(" [name=nobusiness_notimport]").attr('disabled',false);
                    ld(parenttrobj).find(" [name=enablefuzzyquery]").attr('disabled',false);
                    ld(parenttrobj).find(" [name=enablebatchbackfill]").attr('disabled',false);
                }
                else{
                    ld(parenttrobj).find(" [name=nobusiness_notsave]").prop('checked',false).attr('disabled',"disabled");
                    ld(parenttrobj).find(" [name=nobusiness_notimport]").prop('checked',false).attr('disabled',"disabled");
                    ld(parenttrobj).find(" [name=enablefuzzyquery]").prop('checked',false).attr('disabled',"disabled");
                    ld(parenttrobj).find(" [name=enablebatchbackfill]").prop('checked',false).attr('disabled',"disabled");
                    
                    ld(parenttrobj).find(" [name=business_expection]").css('display','none');
                }
            }
            else if(type=='enablefuzzyquery'){
                ld(parenttrobj).find("#business_fuzzycontrol").css('display',changevalue == 'yes'?'inline':'none');
            }
        })
    }

    //映射规则对应模块切换
    that.BackfillingmoduleChange = function(obj){
        var urlstring = 'module=Settings&action=SettingsAjax&file=BusinessInformation&ajax=true';
        var selectpage = that.ld_navbarobj.CurNavBarEvent.NavBarItem.id;
        urlstring += '&selectpage='+selectpage;
        var selectmodule = ld(obj).val();
        urlstring += '&selectmodule='+selectmodule;
        ldAjax('index.php?',urlstring,function(ajaxdata){
            var vtlib_businessinformation_listobj = ld("#vtlib_businessinformation_list");
            vtlib_businessinformation_listobj.html(ajaxdata.result.content);
            that.BusinessPageChangeSetEvent(selectpage,ajaxdata);
            DelProgressObjs();
        })
    }
    //编辑映射规则
    that.EditBackfillingfield = function(obj,module,tianyanchaname){
        var urlstring = 'module=Settings&action=SettingsAjax&file=BackFillTianYanContentSettings&mode=edittianyanchaname';
        urlstring += '&frommodule='+module;
        urlstring += '&tianyanchaname='+tianyanchaname;
        var Popupobj=CrmPopup.load("","","","LdPopWidth900px",module,"","","","");
        Popupobj.prevshow();
        ldAjaxNoProgress('index.php?',urlstring,function(ajaxdata){
            if(ajaxdata.code == 1) {
                Popupobj.setParams(ajaxdata.result.title, that.SaveBackfillingfield, "", 'LdPopWidth900px', module, "", ajaxdata.result.oktext, "", ajaxdata.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll(Popupobj, ajaxdata.result.content);
                var backfillfields_arr = ajaxdata.result.backfillfields;
                for (var i = 0; i < backfillfields_arr.length; i++) {
                    //将选择模块select下拉框设置为不显示，并在其后插入输入下拉框div
                    var selectobj = ld("#" + Popupobj.divid).find(" select[name=" + i + "]");
                    if (selectobj.length > 0 && selectobj != undefined) {
                        var cls_resetComboxHtmlobj = new cls_resetComboxHtml(selectobj.attr("name"));
                        cls_resetComboxHtmlobj.setPopupObj(Popupobj);
                        var selectwidth = Tools.getParentobjByChild(selectobj,'td').width();
                        cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj, selectwidth+10);
                    }
                }
                Popupobj.fieldcount = ajaxdata.result.fieldcount;
                Popupobj.module = module;
                Popupobj.tianyanchaname = tianyanchaname;
            }
            else{
                return false;
            }
        });

    }
    //保存映射规则
    that.SaveBackfillingfield = function(){
        var popupobj=CrmPopup.getPopupObj("last");
        var module = popupobj.module;
        //获取映射字段选中内容
        var selectoptions = new Array();
        var tianyanchaname = popupobj.tianyanchaname;
        var selectoption = ld("#"+popupobj.divid+" [name=0]").val();
        var tranlabel = ld("#"+popupobj.divid+" [name=0] option:selected").text();
        var optionvalue = selectoption.split(':');
        //天眼查回传内容不为日期，不能映射为日期格式
        //zkt 20230717 XUQIU1001418  需要允许回填日期字段
        if(account_version != 'zhongsi'){
            if(!empty(optionvalue[2])&& (optionvalue[2]=='date'||optionvalue[2]=='datetime')){
                if(tianyanchaname != undefined && tianyanchaname != 'estiblishTime'){
                    var fieldlabel = ld("#"+popupobj.divid+" [name=isfieldname_0]").attr('tag');
                    var tipcontent = fieldlabel+arrJsPopLabel['CANNOTFIELDTODATE'];
                    RemindsMsg("","LdPopWidth400px","","yes","",tipcontent);
                    return false;
                }
            }
        }
        selectoptions.push(tianyanchaname+':'+selectoption);
        var tmpurl = '';
        if(selectoptions != undefined && !empty(selectoption)){
            tmpurl = '&selectoptions='+JSON.stringify(selectoptions);
        }
        var urlstring = "index.php?module=Settings&action=SettingsAjax&file=BackFillTianYanContentSettings&mode=savetianyanchaname&frommodule="+module;
        urlstring += "&tianyanchaname="+tianyanchaname;
        ldAjaxNoProgress(urlstring,tmpurl,function(ajaxdata){
            if(ajaxdata.code == 1){
                popupobj.CancelEvent();
                popupobj=CrmPopup.getPopupObj("last");
                var parenttrobj = ld("#"+popupobj.divid+" [name="+tianyanchaname+"]");
                var tdtranlabelobj = ld(parenttrobj).find(" td[name=tranlabel]");
                var tdtypeobj = ld(parenttrobj).find(" td[name=trantype]");
                var trantype = '';
                trantype = that.fieldTypetoLabel[optionvalue[2]];
                if(empty(trantype))
                    trantype = optionvalue[2];
                ld(tdtranlabelobj).html(tranlabel);
                ld(tdtypeobj).html(trantype);
            }
            else if(ajaxdata.code == -1){
                RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['Savefailed']);
                return false;
            }
        })
    }
    //搜索黑名单关键字
    that.SearchBlacklistkeywords = function (event){
        var e = event || window.event;
        if(e.keyCode == 13){
            that.getbalcklistbypage(1);
        }
    }
    that.getbalcklistbypage = function(pagenum){
        var searchText = ld("#blacksearchkeywords").val();//搜索框信息
        var urlstring = 'module=Settings&action=SettingsAjax&file=BusinessInformation&ajax=true';
        var selectpage = that.ld_navbarobj.CurNavBarEvent.NavBarItem.id;
        urlstring += '&selectpage='+selectpage;
        urlstring += '&searchwords='+encodeURIComponent(searchText);
        urlstring += '&pagenum='+pagenum;
        ldAjax('index.php?',urlstring,function(ajaxdata){
            var vtlib_businessinformation_listobj = ld("#vtlib_businessinformation_list");
            vtlib_businessinformation_listobj.html(ajaxdata.result.content);
            that.BusinessPageChangeSetEvent(selectpage,ajaxdata);
            DelProgressObjs();
        })
    }
    //新增/编辑黑名单关键字
    that.EditBlackKeywords = function(keywordid){
        var urlstring = "module=Settings&action=SettingsAjax&file=BlackListKeyWordSettings&mode=editblackkeywords";
        urlstring += "&keywordid="+keywordid;
        var Popupobj=CrmPopup.load("","","","LdPopWidth800px","Settings","","","","");
        Popupobj.prevshow();
        ldAjaxNoProgress('index.php?',urlstring,function(ajaxdata){
            if(ajaxdata.code == 1) {
                Popupobj.setParams(ajaxdata.result.title,that.SaveBlackKeywords, "", 'LdPopWidth800px', "Settings", "", ajaxdata.result.oktext, "", ajaxdata.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll(Popupobj, ajaxdata.result.content);
                Popupobj.keywordid = keywordid;
            }
        })
    }
    that.SaveBlackKeywords = function(){
        var urlstring = "module=Settings&action=SettingsAjax&file=BlackListKeyWordSettings&mode=saveblackkeywords";
        var popupobj = CrmPopup.getPopupObj('last');
        urlstring += "&keywordid="+popupobj.keywordid;
        var keywordobj = ld("#"+popupobj.divid).find("#blackkeywords");
        var keywordtext = ld(keywordobj).val();
        if(empty(keywordtext)){
            RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['KEYWORDSCANNOTBEEMPTY']);
            return false;
        }
        urlstring += "&keywordtext="+keywordtext;
        ldAjaxNoProgress('index.php?',urlstring,function(ajaxdata){
            if(ajaxdata.code == 1) {
                popupobj.CancelEvent();
                that.getbalcklistbypage(1);
            }
            else if(ajaxdata.code == -1) {
                RemindsMsg("","LdPopWidth400px","","yes","",ajaxdata.msg);
                return false;
            }
        })
    }
    //删除黑名单关键字
    that.DeleteBlackKeywords = function(keywordid){
        //删除
        var alert_str = arrJsPopLabel['SUREWANTDELETE'];
        RemindsMsg("", "LdPopWidth400px", "LinkModuleCustom", "yes", "yes", alert_str);
        //确定按钮
        var tmpid = ld(this).attr('tag');
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function() {
            var urlstring = "module=Settings&action=SettingsAjax&file=BlackListKeyWordSettings&mode=deleteblackkeywords";
            urlstring += "&keywordid="+keywordid;
            ldAjaxNoProgress('index.php?',urlstring,function(ajaxdata){
                if(ajaxdata.code == 1) {
                    var pagenum = 1;
                    if(that.listviewpaginationobj != undefined){
                        pagenum = that.listviewpaginationobj.currentpage;
                    }
                    that.getbalcklistbypage(pagenum);
                }
            });
        });
    }
    that.SearchBusinesslogList = function (obj){
        var startdate = ld("#businesslogstartdate").val();
        var enddate = ld("#businesslogenddate").val();
        var startdate_date = new Date(startdate);
        var enddate_date = new Date(enddate);
        if(startdate_date>enddate_date){
            var alert_str = arrJsPopLabel['STARTDATECANOTGREATERENDDATE'];
            RemindsMsg("", "LdPopWidth400px", "LinkModuleCustom", "yes", "yes", alert_str);
            return false;
        }
        var urlstring = 'module=Settings&action=SettingsAjax&file=BusinessInformation&ajax=true';
        var selectpage = that.ld_navbarobj.CurNavBarEvent.NavBarItem.id;
        urlstring += '&selectpage='+selectpage;
        urlstring += '&startdate='+startdate;
        urlstring += '&enddate='+enddate;
        ldAjax('index.php?',urlstring,function(ajaxdata){
            var vtlib_businessinformation_listobj = ld("#vtlib_businessinformation_list");
            vtlib_businessinformation_listobj.html(ajaxdata.result.content);
            that.BusinessPageChangeSetEvent(selectpage,ajaxdata);
            DelProgressObjs();
        })
    }
    that.getBusinesslogDetail = function(searchdate){
        var urlstring = "module=Settings&action=SettingsAjax&file=BusinessLogandAnalysis&mode=showbusinesslogdetail";
        urlstring += "&searchdate="+searchdate;
        var selectpage = that.ld_navbarobj.CurNavBarEvent.NavBarItem.id;
        urlstring += '&selectpage='+selectpage;
        var Popupobj=CrmPopup.load("","","","LdPopWidth800px","Settings","","","","");
        Popupobj.isShowFullscreen='yes';
        Popupobj.Fullscreencallback = function (switchtotype){
            var fullscreen_obj = ld("#" + Popupobj.divid + "_fullscreen");
            var windowHeight = CrmPopup.getClientHeight();
            //弹窗标题固定为64px
            var minusheight=64;
            //查询分类/搜索框/查找按钮
            if(CrmPopup.isExistsObj(Popupobj.divid,'resize_popupsearch_div')){
                minusheight+=CrmPopup.findHtmlobj(Popupobj.divid,'resize_popupsearch_div').height();
            }
            //确定按钮/分页信息
            var tableobj=CrmPopup.findHtmlobj(Popupobj.divid,'ListViewContents').find("table.small");
            var trobj =ld(tableobj).children('tbody').children('tr:not(:has(#hdScrolllistentries_yy))');//排除掉包含列表的tr
            if (trobj.length > 0) {
                trobj.each(function() {
                    minusheight += ld(this).height();
                });
            }

            if(switchtotype=="fullscreen"){//全屏
                var headerheight = CrmPopup.findHtmlobj(Popupobj.divid,'resize_header_table_divid').height();
                CrmPopup.findHtmlobj(Popupobj.divid,'hdScrolllistentries_yy').css('height',windowHeight-minusheight);
                CrmPopup.findHtmlobj(Popupobj.divid,'resize_content_table_divid').css("height",windowHeight-minusheight-headerheight);
                if(CrmPopup.isExistsObj(Popupobj.divid,'ListViewContents')){
                    CrmPopup.findHtmlobj(Popupobj.divid,'ListViewContents').css("max-height",windowHeight-minusheight);
                }
                if(ld('#'+Popupobj.divid+' #producttable').length>0){//群发短信-客户管理-搜索后页面
                    ld('#'+Popupobj.divid+' #producttable').parent().css("height",windowHeight-minusheight);
                }
            }else{//缩小
                var preheight = parseInt(fullscreen_obj.attr('small-height'));
                if(preheight === null || preheight === undefined ){
                    preheight= windowHeight*0.8 ;
                }
                CrmPopup.findHtmlobj(Popupobj.divid,'hdScrolllistentries_yy').css('height',preheight-minusheight);
                if(CrmPopup.isExistsObj(Popupobj.divid,'resize_content_table_divid')){
                    CrmPopup.findHtmlobj(Popupobj.divid,'resize_content_table_divid').css("height",400);
                }
            }
            Popupobj.center();
        }
        Popupobj.prevshow();
        ldAjaxNoProgress('index.php?',urlstring,function(ajaxdata){
            if(ajaxdata.code == 1) {
                Popupobj.setParams(ajaxdata.result.title,"", "", 'LdPopWidth800px', "Settings", "", "", "", "");
                CrmPopup.setPopupobjHtmlContent_scroll(Popupobj, ajaxdata.result.content);
                //zkt 20240821 BUG20240821-06 后台设置->工商日志查询->点击“查看详细信息”，查询方式选择全部下面三个选项中的任意一个选项，查找不出记录。（且将查询方式切换为全部后，依旧查找不出记录）
                Popupobj.searchdate = searchdate;
                //默认全屏
                Popupobj.switchFullscreen();
                ld('#'+Popupobj.divid+' #resize_header_tableid').css('width',ld('#'+Popupobj.divid+' #resize_header_table_divid').get(0).offsetWidth);
                ld('#'+Popupobj.divid+' #resize_content_tableid').css('width',ld('#'+Popupobj.divid+' #resize_header_table_divid').get(0).offsetWidth);
                Popupobj.center();
            }
        })
    }
    that.SearchBusinesslogDetail = function(){
        var popupobj = CrmPopup.getPopupObj('last');
        var urlstring = "module=Settings&action=SettingsAjax&file=BusinessLogandAnalysis&mode=showbusinesslogdetail";
        urlstring += "&searchdate="+popupobj.searchdate;
        var selectedoperator = ld("#"+popupobj.divid+" #businessoperator").val();
        var selectedoperationtype = ld("#"+popupobj.divid+" #businesssearchtype").val();
        urlstring += "&selectedoperator="+selectedoperator;
        urlstring += "&selectedoperationtype="+selectedoperationtype;
        ldAjaxNoProgress('index.php?',urlstring,function(ajaxdata){
            if(ajaxdata.code == 1) {
                ld("#"+popupobj.divid+"_scroll").html(ajaxdata.result.content);
                var fullscreen_obj = ld("#" + popupobj.divid + "_fullscreen")
                var switchtotype = fullscreen_obj.attr('switchtotype');
                if(switchtotype!='fullscreen'){
                    popupobj.Fullscreencallback('fullscreen');
                }
            }
        })
    }
    
    //搜索
    that.SearchBusinessdataanalysis = function(){
        var urlstring = "module=Settings&action=SettingsAjax&file=BusinessInformation&ajax=true";
        var selectpage = that.ld_navbarobj.CurNavBarEvent.NavBarItem.id;
        urlstring += '&selectpage='+selectpage;
        var popupobj = that.popupobj;
        urlstring += "&startdate="+ld("#"+popupobj.divid+" #dataanalysisstartdate").val();
        urlstring += "&enddate="+ld("#"+popupobj.divid+" #dataanalysisenddate").val();
        var selectedoperator = ld("#"+popupobj.divid+" #dataanalysisoperator").val();
        var selectedoperationtype = ld("#"+popupobj.divid+" #dataanalysissearchtype").val();
        urlstring += "&selectedoperator="+selectedoperator;
        urlstring += "&selectedoperationtype="+selectedoperationtype;
        ldAjaxNoProgress('index.php?',urlstring,function(ajaxdata){
            if(ajaxdata.code == 1) {
                var vtlib_businessinformation_listobj = ld("#vtlib_businessinformation_list");
                vtlib_businessinformation_listobj.html(ajaxdata.result.content);
                that.BusinessPageChangeSetEvent(selectpage,ajaxdata);
                DelProgressObjs();
            }
        })
    }

    /* 功能设置-列表增删工商模块 */
    //绑定事件
    this.setBindEvent = function(trobj,module,tabid){

        trobj.find('#businessqueryfield').attr('name','businessqueryfield_'+tabid);
        trobj.attr('data-tabid',tabid);
        trobj.attr('data-module',module);
        trobj.find('#enablebusiness').unbind('click').on('click', function (event) {
            that.BusinessInformationset(this,module,'enablebusiness');
        })
        trobj.find('#nobusiness_notsave').unbind('click').on('click', function (event) {
            that.BusinessInformationset(this,module,'nobusinessnosave');
        })
        trobj.find('#nobusiness_notimport').unbind('click').on('click', function (event) {
            that.BusinessInformationset(this,module,'nobusinessnoimport');
        })
        trobj.find('#enablefuzzyquery').unbind('click').on('click', function (event) {
            that.BusinessInformationset(this,module,'enablefuzzyquery');
        })
        trobj.find('#enablebatchbackfill').unbind('click').on('click', function (event) {
            that.BusinessInformationset(this,module,'enablebatchbackfill');
        })
        trobj.find('#businessqueryfield').unbind('change').on('change', function (event) {
            that.changeBusinessQueryField(this);
        })
        trobj.find('[tag=delete]').unbind('click').on('click', function (event) {
            that.deleteBusinessModule(this);
        })
    }
    //新增工商查询模块
    this.createBusinessModule = function(){
        // 防止点击太快请求还没结束导致新增出错
        if(this.iscreatingmodule == 'yes'){
            return;
        }
        this.iscreatingmodule = 'yes';
        var popupobj = CrmPopup.getPopupObj('last');
        var tableobj = this.tableobj;
        var urlstring = 'module=Settings&action=SettingsAjax&file=BusinessQuerySettings&mode=createbusinessmodule';
        // urlstring += "&tabid="+tabid;
        var trhtml = "";
        var rowsnum = Number(tableobj.find('tr:last').find('td:first').text());//序号
        var tabindex = Number(tableobj.find('tr:last').attr("tabindex"))+1;
        ldAjaxNoProgress('index.php?',urlstring,function(data){
            if(data.code==1){
                var newmodule_arr = data.result.newmodule_arr;//新增行模块
                var field_arr = data.result.field_arr;//模块中字段
                var modulelist = data.result.modulelist;//所有可选模块
                var id = newmodule_arr['id'];
                var tabid = newmodule_arr['tabid'];
                var module = newmodule_arr['module'];
                var modulelabel = newmodule_arr['modulelabel'];

                if(tabindex % 2 == 0){
                    trhtml = '<tr id="setting_'+tabindex+'" data-id="'+id+'" data-tabid="'+tabid+'" data-module="'+module+'" tabindex="'+tabindex+'" class="lvtColData" onmouseout="listOnMouseOut(ld(this),\'on\');" onmouseover="listOnMouseOver(ld(this));">';
                }else{
                    trhtml = '<tr id="setting_'+tabindex+'" data-id="'+id+'" data-tabid="'+tabid+'" data-module="'+module+'" tabindex="'+tabindex+'" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),\'On\');" onmouseover="listOnMouseOver(ld(this));">';
                }

                trhtml += '<td>'+(rowsnum+1)+'</td>';
                trhtml += '<td class="ld-form-item-content"><select id="selectbusinessmodule" name="selectbusinessmodule_'+tabindex+'" class="ld-select-inner" style="height: 30px;" onchange="BusinessInformationobj.changeBusinessModule(this)">';
                ld.each(modulelist, function(tabid, moduleinfo) {
                    if(moduleinfo.modulename == module)
                        trhtml += '<option value="'+tabid+'" data-module="'+moduleinfo.modulename+'" selected="">'+moduleinfo.modulelabel+'</option>';
                    else
                        trhtml += '<option value="'+tabid+'" data-module="'+moduleinfo.modulename+'">'+moduleinfo.modulelabel+'</option>';
                });
                trhtml += '</select></td>';
                trhtml += '<td class="ld-form-item-content locking-left"><select id="businessqueryfield" name="businessqueryfield_'+tabid+'" class="ld-select-inner" style="height: 30px;">'
                ld.each(field_arr, function(fieldid, fieldinfo) {
                    trhtml += '<option value="'+fieldid+'" '+fieldinfo.selected+'>'+fieldinfo.fieldlabel+'</option>';
                });
                trhtml += '</select></td>';
                trhtml += '<td><input type="checkbox" id="enablebusiness" class="second_switch" checked=""/></td>';
                trhtml += '<td>'
                            +'<input type="checkbox" id="nobusiness_notsave" name="nobusiness_notsave" class="second_switch"/>'
                            +'<a href="javascript:;" style="display:none;margin-left:5px;" id="business_expection" name="business_expection" onclick="BusinessInformationobj.BusinessExpection(this)">'+arrJsPopLabel['SETEXCEPTION']+'</a>'
                            +'</td>';
                trhtml += '<td><input type="checkbox" id="nobusiness_notimport" name="nobusiness_notimport" class="second_switch" disabled/></td>';
                trhtml += '<td><input type="checkbox" id="enablefuzzyquery" class="second_switch"/></td>';
                trhtml += '<td class="locking-rightleft"><input type="checkbox" id="enablebatchbackfill" class="second_switch"/></td>';
                trhtml += '<td class="locking-right"><a class="Anu3_a redFont" href="javascript:void(0);" tag="delete">'+arrJsPopLabel['DELETE']+'</a></td>';
                
                trhtml += '</tr>';
                tableobj.find('tbody').append(trhtml);
                var selectobj_module = ld("#"+popupobj.divid).find("select[name=selectbusinessmodule_"+tabindex+"]");
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj_module.attr('name'));
                cls_resetComboxHtmlobj.setPopupObj(popupobj);
                var selectwidth = Tools.getParentobjByChild(selectobj_module,'td').width();
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj_module,selectwidth+10);
                var selectobj_field = ld("#"+popupobj.divid).find("select[name=businessqueryfield_"+tabid+"]");

                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj_field.attr('name'));
                cls_resetComboxHtmlobj.setPopupObj(popupobj);
                var selectwidth = Tools.getParentobjByChild(selectobj_field,'td').width();
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj_field,selectwidth+10);
                var trobj = tableobj.find('tr#setting_'+tabindex);
                that.setBindEvent(trobj,module,tabid);
                that.reloadAvailableModules();
                ld("#"+popupobj.divid).find("#addrow").focus();
                that.iscreatingmodule = 'no';
            }
        })
    }
    //新增模块后修改模块
    this.changeBusinessModule = function(obj){
        var popupobj = CrmPopup.getPopupObj('last');
        // var tableobj = ld('#'+popupobj.divid).find('#business_information');
        var tabid = ld(obj).val();
        // var module = ld(obj).attr('data-module');
        var trobj = ld(obj).parents('tr:first')
        var id = trobj.attr('data-id');
        var selecthtml = '';
        var urlstring = 'module=Settings&action=SettingsAjax&file=BusinessQuerySettings&mode=changebusinessmodule';
        urlstring += "&tabid="+tabid+"&id="+id;
        ldAjaxNoProgress('index.php?',urlstring,function(data){
            if(data.code==1){
                var selectobj_field = trobj.find('#businessqueryfield');
                var selectobj_field_td = trobj.find('#businessqueryfield').parent('td');
                selectobj_field_td.html('');
                var field_arr = data.result.field_arr;//模块中字段
                var new_module = data.result.module;
                selecthtml += '<select id="businessqueryfield" name="businessqueryfield_'+tabid+'" class="ld-select-inner" style="height: 30px;" onchange="">'
                ld.each(field_arr, function(fieldid, fieldinfo) {
                    selecthtml += '<option value="'+fieldid+'" '+fieldinfo.selected+'>'+fieldinfo.fieldlabel+'</option>';
                });
                selecthtml += '</select>';
                selectobj_field_td.html(selecthtml);
                that.setBindEvent(trobj,new_module,tabid);
                // var selectobj_field = ld("#"+popupobj.divid).find("select[name=businessqueryfield_"+tabid+"]");
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(trobj.find('#businessqueryfield').attr('name'));
                cls_resetComboxHtmlobj.setPopupObj(popupobj);
                var selectwidth = Tools.getParentobjByChild(trobj.find('#businessqueryfield'),'td').width();
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(trobj.find('#businessqueryfield'),selectwidth+10);
                // that.selectedmodule_arr.push({'tabid':tabid,'module':new_module});
                that.reloadAvailableModules();
            }
        })
    }
    //更改工商查询字段
    this.changeBusinessQueryField = function(obj){
        var popupobj = CrmPopup.getPopupObj('last');
        // var tableobj = ld('#'+popupobj.divid).find('#business_information');
        var fieldid = ld(obj).val();
        var trobj = ld(obj).parents('tr:first')
        var tabid = trobj.attr('data-tabid');

        var urlstring = 'module=Settings&action=SettingsAjax&file=BusinessQuerySettings&mode=changebusinessqueryfield';
        urlstring += "&tabid="+tabid+"&fieldid="+fieldid;
        ldAjaxNoProgress('index.php?',urlstring,function(data){
            if(data.code==1){

            }
        })
    }
    //新增或切换模块时更新其他模块下拉框内容，防止选重复模块
    this.reloadAvailableModules = function(){
        var popupobj = CrmPopup.getPopupObj('last');
        var tableobj = this.tableobj;
        var selectobj_module = tableobj.find('select[name^=selectbusinessmodule_]');
        var selectobj_arr = {};
        selectobj_module.each(function() {
            selectobj_arr[ld(this).attr('name')] = (ld(this).val());
        });
        
        var urlstring = 'module=Settings&action=SettingsAjax&file=BusinessQuerySettings&mode=reloadavailablemodules';
        ldAjaxNoProgress('index.php?',urlstring,function(data){
            if(data.code==1){
                var modulelist = data.result.modulelist;
                selectobj_module.each(function() {
                    var optionhtml = '';
                    var targetobj = ld(this);
                    var tmp_optionhtml = '<option value="'+ld(this).val()+'" data-module="'+ld(this).attr('data-module')+'" selected="">'+ld(this).find('option:selected').text()+'</option>';
                    targetobj.html('');
                    optionhtml += tmp_optionhtml;
                    ld.each(modulelist, function(tabid, moduleinfo) {
                        optionhtml += '<option value="'+tabid+'" data-module="'+moduleinfo.modulename+'">'+moduleinfo.modulelabel+'</option>';
                    });
                    targetobj.html(optionhtml);
                    var cls_resetComboxHtmlobj=new cls_resetComboxHtml(targetobj.attr('name'));
                    cls_resetComboxHtmlobj.setPopupObj(popupobj);
                    var selectwidth = Tools.getParentobjByChild(targetobj,'td').width();
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(targetobj,selectwidth+10);
                })
            }
        })
    }
    //删除工商查询模块
    this.deleteBusinessModule = function(obj){
        var tableobj = this.tableobj;
        MessagePopup.TipTwo_warning(arrJsPopLabel['ConfirmToDelBusinessModule']);
        var popupobj = CrmPopup.getPopupObj('last');
        ld("#" + popupobj.divid + " input[tagclick='msgConfirm']").unbind("click").bind("click", function () {
            var trobj = ld(obj).parents('tr:first');
            var tabid = trobj.attr('data-tabid');
            trobj.remove();
            var urlstring = 'module=Settings&action=SettingsAjax&file=BusinessQuerySettings&mode=deletebusinessmodule';
            urlstring += "&tabid="+tabid;
            ldAjaxNoProgress('index.php?',urlstring,function(data){
                if(data.code==1){
                    that.reloadAvailableModules();
                    MessagePopup.TipZero_success(data.result.msg);
                    that.resetlvtColData(tableobj);
                }
            })
        });
    }
    //重新加载隔行换色
    this.resetlvtColData = function(tableobj){
        trobj = tableobj.find("tr");
        trobj.attr('onmouseover','');
        trobj.attr('onmouseout','');
        trobj.removeClass('lvtColData');
        trobj.removeClass('lvtColDataBj');
        trobj.removeClass('lvtColDataHover');
        ld.each(trobj,function(index,tmpobj){
            if(index>0){
                if(index%2==0){
                    ld(tmpobj).addClass('lvtColDataBj');
                    ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                    ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"On")');
                    ld(tmpobj).find('td:first').html(index);
                    // ld(tmpobj.childNodes[2]).html(index);
                }else{
                    ld(tmpobj).addClass('lvtColData');
                    ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                    ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
                    ld(tmpobj).find('td:first').html(index);
                    // ld(tmpobj.childNodes[2]).html(index);
                }
            }
        });
    }
}













