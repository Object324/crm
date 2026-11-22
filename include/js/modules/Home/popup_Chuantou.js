//穿透弹窗类
function popup_Chuantou(popupobj,boardstuffid,penetrateModule,scopemodule){
    this.popupobj = popupobj;
    this.boardstuffid = boardstuffid;
    this.penetrateModule = penetrateModule;//穿透数据是哪个模块的
    this.scopemodule = scopemodule;//数据范围依赖哪个模块
    this.divid = popupobj.divid;
    this.selecteduserid = '';
    this.search_date_custom_value = '';
    this.approve_value = '';
    this.scopeType = 'SmOwner_Search_All';
    this.advance_demand = '[]';
    this.advance_demand_groups = '[]';
    this.currentpage = 1;
    this.searchType = 1;
    this.surl = 'index.php?module=Home&action=HomeAjax&file=GetPenetrateModuleList&function_name=getListView';
    this.params_data = '';
    /** 子图类型 */
    this.ChildChartType = '';
    //列表字段排序功能
    this.sortColumnName = '';//排序字段
    this.sortType = 'DEFAULT';//排序类型

    var that = this,
        PopupJqObj = ld('#'+popupobj.divid);
    this.init = function(scopeType,selectuserid,search_date_custom_value,approve_value){
        that.scopeType = ld('#HomeSmOwnerSearchScope').val();	//查看范围类型
        if(scopeType=='SmOwner_Search_All'){
            that.scopeType = 'SmOwner_Search_All';
        }else{
            that.scopeType = 'smowner_search_senior';
            that.selecteduserid = selectuserid;
        }
        that.search_date_custom_value = search_date_custom_value;//时间条件
        that.approve_value = approve_value;//审批条件
    }
    this.setEvent = function(){
        var divobj = ld('#'+that.popupobj.divid);
        //数据范围 下拉框值改变事件
        divobj.find('#ChuantouSmOwnerSearchScope').unbind('change').bind('change',function(){
            that.SmOwnerSearchScopeChuantou(this);
        });
        divobj.find('#icon_range').unbind('click').bind('click',function(){
            that.SmOwnerSearchScopeChuantouHigh(that.scopemodule);
        });
        //基本查找 字段选择事件
        divobj.find('#bas_searchfield').unbind('change').bind('change',function(){
            that.getBasicFieldSearchHistory(this);
            that.setBasicFieldStorage(this);
        });
        //清除搜索框的内容
        divobj.find('#clearsearch').unbind('click').bind('click',function(){
            that.clearBasicSearch(this);
        });
        //搜索小图标点击事件
        divobj.find('#callsearch').unbind('click').bind('click',function(){
            that.callsearch('Basic');
        });
        //搜索文字输入框点击事件
        divobj.find('#search_text').unbind('click').bind('click',function(){
            that.getBasicFieldSearchHistory(this);
        });
        //搜索文件输入框 键盘事件
        divobj.find('#search_text').unbind('keyup').bind('keyup',function(event){
            var e = event || window.event;
            if(e.keyCode == 13){
                that.callsearch('Basic');
            }
        });
        //高级查找条件按钮事件
        divobj.find("#categoryAdvsear").unbind('click').bind('click',function (){
            //that.fun_other_conditions(this,that.advance_demand,that.advance_demand_groups);
            that.fun_other_conditions(this);
        });
        //导出按钮事件
        divobj.find("#categoryExport").unbind('click').bind('click',function (){
            that.Export_chuantou();
        });
        //上一页的点击事件
        divobj.find("#prevpage").unbind('click').bind('click',function (){
            var prevpage_num = that.currentpage-1;
            if(prevpage_num<=0){
                return false ;
            }
            that.currentpage = prevpage_num;
            that.callsearch(that.searchType);
        });
        //下一个的点击事件
        divobj.find("#nextpage").unbind('click').bind('click',function (){
            var prevpage_num = that.currentpage+1;
            if(prevpage_num>that.maxpagenum){
                return false ;
            }
            that.currentpage = prevpage_num;
            that.callsearch(that.searchType);
        });
        //页码下拉的点击事件
        divobj.find("li[name=pagenum_list]").unbind('click').bind('click',function (){
            var linum = ld(this).data('linum');
            if(linum>0 && linum<=that.maxpagenum){
                that.currentpage = linum;
                that.callsearch(that.searchType);
            }else{
                return false;
            }
        });
        //模块标签切换的事件
        divobj.find("li[name=modulelist_li]").unbind('click').bind('click',function (){
            var modulename = ld(this).data('modulename');

            that.penetrateModule = modulename;
            that.scopemodule = modulename;
            that.changeModuleSearch();
        });

        //字段排序
        divobj.find('[sort=yes]').off('click').on('click',function (){
            that.sortColumnName = ld(this).data('columnname');
            that.sortType = ld(this).data('type');
            that.callsearch(that.searchType);
        })

    }
    this.basicUrl = ''
    this.changeModuleSearch = function(){
        if(that.basicUrl === '') {
            that.basicUrl = that.surl;
        }
        var surl = that.basicUrl;
        that.currentpage = 1;
        surl += "&selectuserid="+that.selecteduserid;
        surl +="&scopeType="+that.scopeType;
        surl +="&penetrateModule="+that.penetrateModule;
        surl +="&scopemodule="+that.scopemodule;
        surl+="&start="+that.currentpage;//分页参数

        that.surl = surl;
        ldAjax(surl,that.params_data,function (data){
            if (data.code == 1) {
                var fullscreen_obj = ld("#" + that.divid + "_fullscreen");
                var switchtotype = fullscreen_obj.attr('switchtotype');

                CrmPopup.setPopupobjHtmlContent_scroll_jquery(that.popupobj, data.result.content);
                that.maxpagenum=data.result.maxpagenum;
                //wym BUG0075984 首页-销售排行榜-签约数量，点击导出没有数据。
                that.export_data=data.result.export_data;

                var popupheight = ld("#" + that.divid).height();
                var winwidth = ld(window).height();
                if(popupheight < winwidth){
                    ld("#" + that.divid + "_fullscreen").attr('switchtotype','recovery');
                }
                else{
                    ld("#" + that.divid + "_fullscreen").attr('switchtotype','fullscreen');
                }
                that.popupobj.switchFullscreen();
                //设置弹框内可以用来放列表数据的table父级的div的高度
                //that.setChuanTouTableHeight();

                var listresizeobj=new List_ResizeTable(that.popupobj);
                that.popupobj.listresizeobj=listresizeobj;
                listresizeobj.setPopupResizeTable_Init(that.penetrateModule);

                that.setEvent();//设置事件
            }
            ld('#rptContentLoading').hide();
        });
    }
    //设置弹框内可以用来放列表数据的table父级的div的高度
    this.setChuanTouTableHeight = function (){
        //LayoutBlocklistTable //页签切换的高度 最后加10像素是为了将横向的滚动条露出来
        var windowHeight = CrmPopup.getClientHeight();
        if(ld('#'+that.popupobj.divid+' .main_grid_top').length>0){
            windowHeight -= ld('#'+that.popupobj.divid+' .main_grid_top').outerHeight(true);
        }
        if(ld('#'+that.popupobj.divid+'_head').length>0){
            windowHeight -= ld('#'+that.popupobj.divid+'_head').outerHeight(true);
        }
        if(ld('#'+that.popupobj.divid+' #resize_header_table_divid').length>0){
            windowHeight -= ld('#'+that.popupobj.divid+' #resize_header_table_divid').outerHeight(true);
        }
        if(ld('#'+that.popupobj.divid+' #LayoutBlocklistTable').length>0){
            windowHeight -= ld('#'+that.popupobj.divid+' #LayoutBlocklistTable').outerHeight(true);
        }
        PopupJqObj.find('#resize_content_table_divid').css('height', windowHeight + 'px').css('max-height', windowHeight + 'px');
    }
    //数据范围下拉框值改变的方法
    this.SmOwnerSearchScopeChuantou = function(obj){
        var SearchScope = PopupJqObj.find('#ChuantouSmOwnerSearchScope').val();
        that.scopeType = SearchScope;
        that.currentpage = 1;
        var scopemodule=that.scopemodule;//数据范围依赖模块
        if(SearchScope=='smowner_search_senior'||ld(obj).attr("tag")=="icon"){
            that.SmOwnerSearchScopeChuantouHigh(scopemodule);
        }else{
            that.selecteduserid = SearchScope;
            that.callsearch(that.searchType);//调用搜索
        }
    }
    this.SmOwnerSearchScopeChuantouHigh = function(scopemodule){
        var scopepopupobj;
        var selectuserid = that.selecteduserid;
        var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_inputtype=checkbox&popup_selecttype=user&popup_scopetype=private&popup_type=listselecthigher';
        popup_url += '&popup_module='+scopemodule;
        getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
            var methodObj = {'popup_check_inactiveuser':'yes'};
            scopepopupobj =  new ScopePopupObj(methodObj);
            scopepopupobj.popup_caption_value = arrJsPopLabel['VIEWRANGESENIOR'];//标题title
            getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
                cls_ScopePopup.prop.popup_url = popup_url;//popup_url
                cls_ScopePopup.prop.popup_module = scopemodule;//模块
                cls_ScopePopup.prop.chuantoumodule = 'Home'; //wym 231115 BUG0075530 首页-数据简报穿透-取消勾选“显示离职成员” 与首页保持一致 关联需求:XUQIU1002054
                cls_ScopePopup.prop.popup_value = selectuserid;
                var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
                //重写确认按钮事件
                scopepopupobj.setEventBtnOk=function(){
                    ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                        //没有选择任何用户，则给出提示
                        if(empty(cls_ScopePopup.return_obj.return_id)){
                            var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                            return false;
                        }else{
                            var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                            that.selecteduserid = selected_user;
                            if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                            {
                                //通讯录(pc端企业微信)
                                cls_wxOpenDataobj.bindAllOpenData();

                            }
                            //wym 231115 BUG0075528 首页-数据简报穿透-取消勾选“显示离职成员” 与首页保持一致 关联需求:XUQIU1002054
                            if(ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser')){
                                var displayinactiv=ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser').prop('checked');
                                var tmpurlsting = 'index.php?module=Users&action=UsersAjax&file=viewInactiveusers&frommodule=Home&value='+displayinactiv+'&refresh=chuantou';
                                ldAjaxNoProgresssync(tmpurlsting,'',function(data){
                                    var scopeDivObj = PopupJqObj.find("#showselectsearchscope_chuantou");
                                    scopeDivObj.after(data.result.homecontent);
                                    scopeDivObj.remove();
                                    var newScopeDivObj = PopupJqObj.find("#showselectsearchscope_chuantou");
                                    newScopeDivObj.find('#ChuantouSmOwnerSearchScope').unbind('change').bind('change',function () {
                                        that.SmOwnerSearchScopeChuantou(this);
                                    });
                                    newScopeDivObj.find('#icon_range').unbind('click').bind('click',function(){
                                        that.SmOwnerSearchScopeChuantouHigh(that.scopemodule);
                                    });
                                    //Tools.getParentobjByChild(ld('#showselectsearchscope_chuantou'),'div').html(data.result.homecontent);
                                })
                            }
                            ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                            that.scopeType = 'smowner_search_senior';
                            PopupJqObj.find('#ChuantouSmOwnerSearchScope').val(that.scopeType);
                            PopupJqObj.find("#SmOwnerSearchScopeSenior").html('高级');
                            that.currentpage = 1;
                            that.callsearch(that.searchType);//调用搜索
                        }
                    });
                }
            });
        });
    }
    //获取基本查找历史记录的方法
    this.getBasicFieldSearchHistory = function (obj){
        var url = 'index.php?module='+that.penetrateModule+'&action='+that.penetrateModule+'Ajax&file=SearchHistory&mode=showhistory&newbasicsearch=yes';
        url += '&searchtype=BasicSearch';
        if(that.penetrateModule == 'Approve'){
            url += '&searchmodule='+that.penetrateModule;
        }
        if(that.penetrateModule == 'RecycleBin'){
            return false;
        }
        that.currentpage = 1;
        ldAjax(url,"",function(data){
            DelProgressObjs();
            if(data.code == 1){
                var searchvalue_arr = data.result.searchvalue_arr;
                var clearlabel = data.result.clearlabel;
                var html = '';
                ld.each(searchvalue_arr,function(i,item){
                    html += '<li name="search_text_'+i+'">'+
                        '<a class="overflow-space" optionvalue="'+item.searchvalue.search_field+'" searchtext="'+item.searchvalue.search_text+'" title="'+item.label+'">'+item.label+'</a>'+
                        '</li>';
                });
                html += '<li name="clear_BasicSearch" searchtype="BasicSearch" onmouseover="cmb_limouseover(event,\'BasicSearch\',\'\')"><a class="overflow-space blueFont">'+clearlabel+'</a></li>';
                ld('#'+that.popupobj.divid).find('#basicSearchNewDiv').find('#basicSearchList').html(html);
                ld('#'+that.popupobj.divid).find('[name^=\'search_text_\']').unbind('click').bind('click',function(){
                    that.selectThisHistoryLine(this);
                });
                ld('#'+that.popupobj.divid).find('[name=\'clear_BasicSearch\']').unbind('click').bind('click',function(){
                    that.clearhistory(this);
                });
                ld('body').unbind('click').bind('click',function(){
                    ld('#'+that.popupobj.divid).find('#basicSearchNewDiv').find('#basicSearchList').html('');
                });
            }else{
                ld('#'+that.popupobj.divid).find('#basicSearchNewDiv').find('#basicSearchList').html('');
            }
        });
    }
    //xll 20221214 保存最近一次的基本搜索框字段选项，将其设为基本搜索框的默认值
    this.setBasicFieldStorage = function (obj){
        var storage_value = ld(obj).val();
        var url = 'index.php?module='+that.penetrateModule+'&action='+that.penetrateModule+'Ajax&file=fieldstorage&storage_value='+storage_value;
        ldAjaxNoProgress(url,"",function(data){
        });
    }
    //wym 20231019 BUG0074006
    this.clearhistory= function (obj){
        var searchtype = ld(obj).attr('searchtype');
        var url = 'index.php?module='+that.penetrateModule+'&action='+that.penetrateModule+'Ajax&file=SearchHistory&mode=clearhistory';
        url += '&searchtype='+searchtype;
        ldAjaxNoProgress(url,"",function(data){
        });
    }
    //清除 zxm 20221212
    this.clearBasicSearch = function (obj){
        ld('#'+that.popupobj.divid).find('#basicSearchNewDiv').find('[name=search_text]').val('');
        // wym BUG0074002 kfbcrm-首页-数据简报-穿透弹出层中，基本查找输入框内点击“×”后，“×”就会消失
        //ld('#'+that.popupobj.divid).find('#ListViewBtnAndSeach').find('.ld-icon-clearsearch').css('visibility','hidden');
        ld('#'+that.popupobj.divid).find('#basicSearchNewDiv').find('[name=search_text]').focus();
    }
    this.callsearch = function(searchType){
        var surl=that.surl;
        surl += "&selectuserid="+that.selecteduserid;
        surl+="&scopeType="+that.scopeType
        surl +='&issearch=yes';
        surl+="&searchType="+searchType;
        surl+="&start="+that.currentpage;//分页参数
        //列表字段排序功能
        surl+='&sortColumnName='+that.sortColumnName;
        surl+='&sortType='+that.sortType;

        that.searchType = searchType;
        var advanceParams = '';
        if(searchType=='Basic'){
            //基本查找  需要传查询字段名  传关键字
            var searchField = ld('#'+that.popupobj.divid).find('#bas_searchfield').val();
            var searchText = ld('#'+that.popupobj.divid).find('#search_text').val();
            surl+="&searchField="+searchField;
            surl+="&searchText="+searchText;
            if (that.type == 'workBriefReportChuantou'){
                advanceParams+="&advance_demand="+that.advance_demand;
                advanceParams+="&advance_demand_groups="+that.advance_demand_groups;
            }
        }
        if(searchType=='advance'){
            advanceParams+="&advance_demand="+that.advance_demand;
            advanceParams+="&advance_demand_groups="+that.advance_demand_groups;
        }
        if(that.ChildChartType !== ''){
            surl += that.getChildChartUrlParam();
        }
        //that.surl = surl;
        ldAjax(surl,advanceParams + that.params_data,function (data){
            if (data.code == 1) {
                if(that.ChildChartType === ''){
                    // ld('#'+that.popupobj.divid).find('#chuantou_listview_tbody').html(data.result.content);//將表体内容更改
                    ld('#'+that.popupobj.divid).find('#chuantou_listview_content').html(data.result.content);//將表体内容更改
                    ld('#'+that.popupobj.divid).find('.PageDiv0').html(data.result.pagehtml);
                    that.maxpagenum=data.result.maxpagenum;
                    //wym XUQIU1001820 导出需要保存当前sql结果
                    that.export_data=data.result.export_data;
                    that.setChuanTouTableHeight();
                    that.popupobj.listresizeobj.setPopupResizeTable_Init(that.penetrateModule);
                    that.setEvent();//设置事件
                }
                else {
                    that.newChartObj.setChildChartData(data.result.ChildChartData);
                    that.setChildChart();
                }
            }
            ld('#rptContentLoading').hide();
        });
    }
    this.HighersearchPopup = function() {
        var Popupobj = new ListHigherSearchPopup.load("", that.callSearch, "", "LdPopWidth800px", that.penetrateModule, "", "", "", "");
        Popupobj.show();
        //显示搜索历史
        Popupobj.searchtype = 'advance';
        popupobj.searchmode = 'showhistory';
        show_history(Popupobj);
        //wym 230505 列表界面高级查找添加搜索功能
        var columnIndex = advft_column_index_count;
        for(i=0;i<=columnIndex;i++){
            var selectname = 'fcol'+i;
            if(ld("#"+Popupobj.divid + ' #'+selectname).length>0){
                var selObj = ld("#"+Popupobj.divid + ' #'+selectname);
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectname);
                cls_resetComboxHtmlobj.setPopupObj(popupobj);
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selObj,180);
            }
        }
    }
    this.selectThisHistoryLine = function(obj){
        var searchtext = ld(obj).find('a').attr('searchtext');
        var optionvalue = ld(obj).find('a').attr('optionvalue');
        ld('#'+that.popupobj.divid).find('#basicSearchNewDiv').find('[name=search_text]').val('').focus().val(searchtext);
        ld('#'+that.popupobj.divid).find('#basicSearchNewDiv').find('#bas_searchfield').val(optionvalue);
        ld('#'+that.popupobj.divid).find('#basicSearchNewDiv').find('#basicSearchList').html('');
        that.currentpage = 1;
        //搜索
       that.callsearch('Basic');
    }
    //zxm 20230609 调用高级查找组件
    this.fun_other_conditions = function(curobj){
        var title = ld(curobj).text();
        that.computemodule = that.penetrateModule;//模块
        getJsScript('include/js/modules/Home/SetOtherConditions.js', function () {
            var SetOtherConditionsObj = new SetOtherConditions();
            SetOtherConditionsObj.SetDirDataObj(that);
            SetOtherConditionsObj.setpoptitle(title);
            SetOtherConditionsObj.addTaskAfterOkfun(that.get_advancedemand);
            SetOtherConditionsObj.fun_other_conditions();
        });
    }
    //获取 高级查找组件的值并调用搜索
    this.get_advancedemand = function()
    {
        that.currentpage = 1;
        that.callsearch('advance');//执行查找
    }
	//wym XUQIU1001820 CRM首页，数据简报，点击数据穿透后，在弹出的界面增加“导出”选项。
    this.Export_chuantou = function () {
        var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth500px", that.penetrateModule, "", 'none', "", "");
        crmPopupobj.prevshow();
        var surl='index.php?module='+that.penetrateModule+'&action='+that.penetrateModule+'Ajax&file=Exportchuantou&export_style=firstcolheader';
        surl+='&getprogress=yes';
        var data= that.export_data;
        data['title'] = that.title;
        data['boardid'] = that.boardid;
        ldAjax(surl,data,function(data){
            if(data.code==1){
                crmPopupobj.setParams(data.result.title, "", "", "LdPopWidth500px", that.penetrateModule, "", "", "", "");
                crmPopupobj.show(data.result.content);
                that.listcount = data.result.listcount;
                that.detailcount =  data.result.detailcount;
                if (that.detailcount > 2000 && that.detailcount < 5000) {
                    that.eachexportcount = 100;
                } else if (that.detailcount >= 5000) {
                    that.eachexportcount = 200;
                } else {
                    that.eachexportcount = that.export_data.exportnum_onestep;
                }
                //第二次导出，将结束行作为下一次的起始行，结束行加每次导出行数作为下一次的结束行。
                that.Export_downloads(crmPopupobj,data.result.endexportrow , parseInt(data.result.endexportrow, 10) + parseInt(that.eachexportcount, 10));
            }
        });
    }
    this.Export_downloads = function (crmPopupobj, startexportrow, endexportrow) {
        var surl ='index.php?module='+that.penetrateModule+'&action='+that.penetrateModule+'Ajax&file=Exportchuantou&export_style=firstcolheader&export_chuantou=yes';
        surl += "&startexportrow=" + startexportrow + "&endexportrow=" + endexportrow+ "&listcount=" + that.listcount+ "&detailcount=" + that.detailcount;
        var data= that.export_data;
        data['title'] = that.title;
        data['boardid'] = that.boardid;
        var width = parseInt(startexportrow / that.listcount * 100);
        if (width >= 100) {
            width = 100;
        }
        ld("#dvExportprogress").css("width", width + "%");
        if (parseInt(startexportrow, 10) >= parseInt(that.listcount, 10)) {
            that.exportresulthtml();
            return false;
        }
        var is_close = true;
        if(ld("#" + crmPopupobj.divid).length <= 0){
            is_close = false;
        }
        if (is_close === true){
            ldAjax(surl,data,function(data){
                //先走后台判断是否已经导出完毕,没有导出完返回code=1继续导出,导出完返回code=2跳转到下载的url
                if (data.code == 1) {
                    ld("#dvctimedescription").html(data.result.timedescription);
                    that.Export_downloads(crmPopupobj, data.result.endexportrow, parseInt(data.result.endexportrow, 10) + parseInt(that.eachexportcount, 10));
                } else if (data.code == 2) {
                    window.location.href = 'index.php?module=uploads&frommodule='+that.penetrateModule+'&action=downloadxls&exportformat=exportxls&export_chuantou=yes&title='+that.title;
                    ld("#dvExportprogress").css("width", "100%");
                    //that.startwritefile();
                    that.exportresulthtml();
                    ld('#rptContentLoading').hide();
                }
            });
        }else {

        }

    }

    /**
     * 设置查看范围
     * @param {string} scopeType 查看范围类型
     * @param {string} selectUser 用户id字符串，逗号(,)分割
     */
    this.setScope = function (scopeType,selectUser) {
        that.scopeType = scopeType;
        PopupJqObj.find('#ChuantouSmOwnerSearchScope').val(scopeType);
        that.selecteduserid = selectUser;
    }

    that.exportresulthtml = function () {
        var popupobj = CrmPopup.getPopupObj("last");
        popupobj.CancelEvent();
        // wx_downloadurl = 'index.php?module=uploads&frommodule='+that.penetrateModule+'&action=downloadxls&exportformat=exportxls&export_chuantou=yes&title='+that.title;
        var surl = 'index.php?module=' + that.penetrateModule + "&action=" + that.penetrateModule + "Ajax&file=ExportResult&export_type=chuantou";
        surl += "&title=" + that.title;
        var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth500px", that.penetrateModule, "", 'none', "", "");
        crmPopupobj.prevshow();
        ldAjax(surl,'',function (data) {
            DelProgressObjs();
            if (data.code == 1) {
                crmPopupobj.setParams(data.result.title, "", "", "LdPopWidth500px", that.penetrateModule, "", "", "", "");
                crmPopupobj.show(data.result.content);
            }
        });
    }
    
    this.ChildChartInit = function (Params) {
        that.ChildChartType = 'Default';
        that.surl = Params.surl;
        that.params_data = Params.params_data;
        /** 获取子图echarts Option的方法 */
        that.getChildChartOption = Params.getChildChartOption;
        that.newChartObj = Params.newChartObj;
        that.scopeType = Params.scopeType;
        that.selecteduserid = Params.selectuserid;
        that.search_date_custom_value = Params.search_date_custom_value
    }

    this.ChildChartSetEvent = function () {
        //界面样式调整

        //切换子图类型 按部门/按用户
        var ChildTypeObj = that.ChildTypeObj = PopupJqObj.find('#SelChildChartType');
        that.ChildChartType = ChildTypeObj.val();
        ChildTypeObj.unbind('change').bind('change',that.ChildChartTypeChange);

        //查看范围下拉框
        var homeScopeObj = ld('#home_index').find('#HomeSmOwnerSearchScope'),
            scopeOption = homeScopeObj.html(),
            scopeObj = PopupJqObj.find('#ChuantouSmOwnerSearchScope');
        scopeObj.html(scopeOption);
        scopeObj.find('option[value="'+homeScopeObj.val()+'"]').prop('selected',true);
        PopupJqObj.find('#showselectsearchscope_chuantou').css('margin-top','2px');
        //设置查看范围下拉款可搜索
        var width = scopeObj.outerWidth(),
            ComboxHtmlObj = new cls_resetComboxHtml(scopeObj.attr("name"));
        ComboxHtmlObj.setPopupObj(that.popupobj);
        ComboxHtmlObj.setSearchComboxWidthByhtml(scopeObj,width);
        scopeObj.unbind('change').bind('change',function () {
            that.SmOwnerSearchScopeChuantou(this);
        });
        PopupJqObj.find('#icon_range').unbind('click').bind('click',function(){
            that.SmOwnerSearchScopeChuantouHigh(that.scopemodule);
        });

        //时间控件初始化
        var BtnAndSeachObj = PopupJqObj.find('#ListViewBtnAndSeach').find('.ld-flex-start'),
            timeObj = ld(ld('#home_index').find('.home_laydate_div').get(0).cloneNode(true)),
            timeSelector = '#'+that.divid + ' .home_laydate_time';
        timeObj.css('margin-top','12px');
        //去除lay-key属性，以重新生成对象，避免单例影响
        timeObj.find('.home_laydate_time').removeAttr('lay-key');
        BtnAndSeachObj.append(timeObj);
        // 日期加载
        laydate.render({
            elem: timeSelector,
            theme: 'type-ym',
            trigger: 'click',
            btns: [],
            type: 'date',
            newType: 'date',
            range: true,
            fromType: 'ChildChart',
            change: function (value, date, edate) {
                PopupJqObj.find('.home_laydate_time').val(arrJsPopLabel['custom']);//选择日期时赋值custom
                PopupJqObj.find('.laydate_time_hiddenvalue').val(value);
                value = value.split(' - ');
                var begin_date=value[0];
                var end_date=value[1];
                value=begin_date+'~'+end_date;
                that.search_date_custom_value = value;
                ld(".layui-laydate").remove();//关掉弹出层
            },
            //时间变化重新请求
            timeChange: that.ChildChartTimeChange,
        });

        //echarts初始化
        var myChartJqObj = PopupJqObj.find('#myChart'),
            ChartHeight = PopupJqObj.get(0).clientHeight - 51 - 42;
        myChartJqObj.css('height',ChartHeight+'px');
        that.ChildChart = echarts.init(myChartJqObj.get(0),echartTheme);
    }
    
    this.setChildChart = function () {
        var option = that.getChildChartOption();
        that.ChildChart.setOption(option);

        //edit: xll 2024/03/07 BUG20240305-51 穿透界面图形监控尺寸变化
        var myChartDom = that.ChildChart.getDom(),
            observer = new ResizeObserver(function (entries,observer) {
                that.ChildChart.resize();
            });
        observer.observe(myChartDom);
    }
    
    this.ChildChartTypeChange = function () {
        that.ChildChartType = that.ChildTypeObj.val();
        that.callsearch(that.searchType);
    }
    
    this.ChildChartScopeChange = function () {

    }
    
    this.ChildChartTimeChange = function () {
        var dateType = PopupJqObj.find('#ListViewBtnAndSeach').find('.laydate_time_value').attr('data-value');
        if(dateType !== 'custom'){
            that.search_date_custom_value = dateType;
        }
        that.callsearch(that.searchType);
    }

    this.getChildChartUrlParam = function () {
        return '&search_date_custom_value=' + that.search_date_custom_value + '&ChildChartType=' + that.ChildChartType;
    }

}
