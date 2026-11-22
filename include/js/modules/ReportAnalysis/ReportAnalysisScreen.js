function ReportAnalysisScreen() {
    ReportAnalysis.call(this);
    var that = this;
    this.reportlist = {};//报表数据存到对象中  点击报表的时候需要获取报表的按钮
    this.listtype = 'screen';//视图类型 分屏视图
    this.divid = 'reportanalysis_screen';
    this.frompage='fromdetail';
    this.curReportModule = '';
    this.curReportId = 0;
    this.reportlistbody = ld('#'+that.divid).find('[tag=reportList_'+that.listtype+']');
    this.tbody_recentview = ld('#'+that.divid).find('[tag=LastReview]');
    this.init = function(){
        that.setEvent();
    }
    that.setScroll = function(){

    }
    //设置时间
    this.setEvent = function(){
        window.onresize = function(e) {
            var event = window.event || e;
            that.reportTypeNav();
        }
        that.setSize();

        //分屏视图的展开收起按钮的点击事件
        ld("#reportanalysis_screen #listviewtreeopen").unbind('click').bind('click',function(){
            that.setTreeExpandData();
        });
    }
    //设置宽度
    this.setSize = function(){
        //设置左侧报表菜单的高度
        ld('#'+that.divid+' #reportanalysis_tablecontent').css('height',(ld(window).height()-160)+'px');
        //设置右侧报表显示区域报表头的宽度
        var left = parseInt(ld('#pageleft .nav-menu').css('width'))+340;
        // 判断 报表名称列是否显示
        var display =ld("#reportanalysis_screen #structuretree").css("display");
        if(display=='none'){
            left = left-320;
        }
        //var menustatus = localStorage.getItem('ldcrm_ding_status');

        ld('#'+that.divid+' .screen-detail-header').css('width',(ld(window).width()- left - 10)+'px');
        //设置右侧报表显示区域报表体的宽度高度
        ld('#'+that.divid+' #reportanalysis_reportcontent').css('width',(ld(window).width()- left - 10)+'px').css('height',(ld(window).height()-130)+'px');
    }
    //分屏视图左侧收起隐藏
    this.setTreeExpandData = function (){
        var effectDiv = ld("#reportanalysis_screen #structuretree");//树结构td区块
        var tdExpandObj = ld("#reportanalysis_screen #listviewtreeopen");//展开收起图标td
        var expand = effectDiv.css("display")=='none'?'no':'yes';
        tdExpandObj.attr("data-tip",expand=='no'?arrJsPopLabel['EXPANSION']:arrJsPopLabel['COLLAPSE']);//展开 EXPANSION 收起COLLAPSE
        if(expand == 'yes'){
            effectDiv.css('display','none');
            tdExpandObj.removeClass('closetree').addClass('opentree');
        }else{
            effectDiv.css('display','');
            tdExpandObj.removeClass('opentree').addClass('closetree');
        }
        //重新请求报表数据
        ld('#'+that.divid).find('tr[module='+that.curReportModule+'][data-id='+that.curReportId+']').find('.report-name-link').trigger('click');
        that.setSize();
    }
    //获取最近浏览的那一行列头
    that.getRecentViewHeader = function(){
        return '<tr class="lvtColData" data-status="open" tag="RecentView" data-parent="0" >\n' +
            '      <td>\n' +
            '          <div class="report-name" name="RecentView" onclick="ReportAnalysisObj.showRecentReport(this,\'RecentView\');">\n' +
            '              <div class="report-open">&nbsp;</div>\n' +
            '              <div tag="folder-img">\n' +
            '                  <img class="marL8 marR8" src="'+that.folderimg+'">'+arrJsPopLabel['RECENTBROWSING']+'\n' +
            '              </div>\n' +
            '          </div>\n' +
            '      </td>\n' +
            '  </tr>'
    }
    //没点击报表的时候的空态显示
    that.emptyHtml = function(){
        var height = ld(window).height()-130;
        return '<div style="position: relative;height:'+height+'px"><div class="warningTableContent" style="z-index:600;padding-top:30px;text-align: center;"><div class="wtc_img" style="margin: 0 auto"><img style="width: 50%;height: 50%;" src="themes/softed/images/icon-nofile.png"></div><div class="wtc_content">'+arrJsPopLabel['SCREENVIEWTIP']+'</div></div></div>';
    }
    //分屏视图的时候--编辑按钮的html
    that.getReportEditHtml = function(item){
        var editHtmlArr = {
            OftenUseReport: function (item) {
                return '';
            },
            Customreport: function (item) {
                return '<div class="ld-button" data-id="' + item.report_id + '" onclick="ReportAnalysisObj.editTemplateReport(' + item.report_id + ')">'+ arrJsPopLabel['EDIT']+'<b name="Create" class="ListView_ButtonNum"></b></div>';
            },
            Comprehensivereport: function (item) {
                return '';
            },
            CustomEcharts: function (item) {
                return '<a target="_blank" frompage="fromdetail" class="ld-button textFloatDisplay" data-id="' + item.report_id + '" onclick="ReportAnalysisObj.creat_new_chart(this,\'' + item.type + '\')">'+ arrJsPopLabel['EDIT']+'</a>';
            },
            CustomTables: function (item) {
                return '<a target="_blank" class="ld-button textFloatDisplay" data-id="' + item.report_id + '" onclick="ReportAnalysisObj.creat_new_table(this,\'' + item.type + '\')">'+ arrJsPopLabel['EDIT']+'</a>';
            },
            ReportAnalysis:function(item){
                //文件夹的编辑按钮
                return '<a class="ld-button textFloatDisplay" href="javascript:;" onclick="ReportAnalysisObj.createNewDir(' + item.report_id + ',' + item.parent_id + ',this)">'+ arrJsPopLabel['EDIT']+'</a>';
            }
        }
        return editHtmlArr[item.modulename](item);
    }
    //按钮列
    that.getButtonHtml = function(btnname,item){
        //编辑、分配、新建、排序、删除,取消显示
        var btnArr = {
            edit:function(item){
                return that.getReportEditHtml(item);
            },
            allocate:function(item){
                return '<a class="ld-button textFloatDisplay" href="javascript:;" onclick="ScopePopup_Details.getInstance().allocateTemplate(this,' + item.parent_id + ',' + item.report_id + ',\'' + item.allocatetypeids + '\',' + item.approveallocatetype + ',\'ReportAnalysis\',\''+item.modulename+'\');">'+ arrJsPopLabel['DISTRIBUT']+'</a>';
            },
            sort:function(item){
                return '<a class="ld-button textFloatDisplay" href="javascript:;" onclick="ReportAnalysisObj.sortReport(' + item.report_id + ')">'+arrJsPopLabel['SORT']+'</a>';
            },
            delete:function(item){
                //常用报表/综合报表(系统预设)没有这个删除按钮  文件夹下有报表的也没有删除按钮 最近浏览文件夹也没有删除按钮
                if(item.modulename=='ReportAnalysis'){
                    //文件夹
                    return '<a class="ld-button textFloatDisplay" href="javascript:;" onclick="ReportAnalysisObj.deleteDir(' + item.report_id + ',this,' + item.parent_id + ')">'+arrJsPopLabel['DELETE']+'</a>';
                }else{
                    //报表
                    return '<a class="ld-button textFloatDisplay" href="javascript:;" onclick="ReportAnalysisObj.deleteReport(' + item.report_id + ',this,\'' + item.modulename + '\')">'+arrJsPopLabel['DELETE']+'</a>';
                }
            },
            cancel:function(item){
                //只有最近浏览文件夹里面的有
                return '<a class="ld-button textFloatDisplay" href="javascript:;" onclick="ReportAnalysisObj.canceldisplayReport(' + item.report_id + ',this,\'' + item.modulename + '\')">'+arrJsPopLabel['CANCELDISPLAY']+'</a>';
            },
            move:function(item){
                return '<a class="ld-button textFloatDisplay" href="javascript:;" onclick="ReportAnalysisObj.moveDir(' + item.report_id + ',\'' + item.report_name + '\',' + item.parent_id + ',\''+item.modulename+'\')">'+arrJsPopLabel['MOVE']+'</a>';
            },
            print:function(item){
                //打印--只有SQL统计表和自定义统计表有
                return '<a class="ld-button textFloatDisplay" href="javascript:;" id="printTableDetail">'+arrJsPopLabel['PRINT']+'</a>';
            },
            export:function(item){
                //导出--只有SQL统计表和自定义统计表有
                return '<a class="ld-button textFloatDisplay" href="javascript:;" id="exportTableDetail">'+arrJsPopLabel['ExportExcel']+'</a>';
            }
        }
        return btnArr[btnname](item);
    }

    //报表名称的html--根据模块名称获取
    that.getReportNameHtml = function(item){
        var indent = that.setIndent(item.level);
        var reportNameHtmlArr = {
            OftenUseReport:function(item){
                return '<td style="'+indent+';max-width:320px;" onclick="ReportAnalysisObj.showUseReport(' + item.report_id + ',\'' + item.reportlabel + '\',\''+ item.report_name + '\')"><a class="report-name-link textFloatDisplay" data-tip="'+ item.report_name + '" data-direction="top" data-type="position" href="javascript:;">'+ '<b class="icon-table marR5 marT-2"></b>' + item.report_name + '</a></td>';
            },
            Customreport:function(item){
                //报表库的 打开新页签
                return '<td style="'+indent+';max-width:320px;" onclick="ReportAnalysisObj.showCustomreport(' + item.report_id + ',\'' + item.type + '\',\'' + item.report_template + '\',\'' + item.report_name + '\',\'' + item.databaselinktype + '\')"><a class="report-name-link textFloatDisplay" data-tip="'+ item.report_name + '" data-direction="top" data-type="position" href="javascript:;">'+ '<b class="icon-table marR5 marT-2"></b>' + item.report_name + '</a></td>';
            },
            Comprehensivereport:function(){
                //综合报表的
                return '<td style="'+indent+';max-width:320px;" onclick="ReportAnalysisObj.showComprehensivereport(' + item.report_id + ',\''+ item.report_name + '\')"><a class="report-name-link textFloatDisplay" data-tip="'+ item.report_name + '" data-direction="top" data-type="position" href="javascript:;">'+ '<b class="icon-table marR5 marT-2"></b>' + item.report_name + '</a></td>'
            },
            CustomEcharts:function() {
                return '<td style="'+indent+';max-width:320px;" onclick="ReportAnalysisObj.showEchartDetail(' + item.report_id + ',\'' + item.type + '\',\''+ item.report_name + '\',\''+item.btnarr+'\')"><a class="report-name-link textFloatDisplay" data-tip="'+ item.report_name + '" data-direction="top" data-type="position" href="javascript:;">' + '<b class="icon-chart marR5 marT-2"></b>' + item.report_name + '</a></td>';
            },
            CustomTables:function(){
                return '<td style="'+indent+';max-width:320px;" onclick="ReportAnalysisObj.showTableDetail(' + item.report_id + ',\'' + item.type + '\',\''+ item.report_name + '\')"><a class="report-name-link textFloatDisplay" data-tip="'+ item.report_name + '" data-direction="top" data-type="position" href="javascript:;">' + '<b class="icon-table marR5 marT-2"></b>' + item.report_name + '</a></td>';
            },

        }
        return reportNameHtmlArr[item.modulename](item);
    }
    //分屏视图  文件夹行的html
    this.renderDir = function(index,item,parent_id){
        //开关
        var data_status = "close";
        var data_class = "report-close";
        var imgname = "icon-folder-close.png";
        //wyt 221213 BUG0059350 报表分析--刷新--最近浏览的下一个文件夹的图标也是打开状态的 但其实它首次进来不是打开的
        var LastReviewRecord=parseInt(ld('#LastReviewRecord').val());
        if(index==0&&parent_id==0&&LastReviewRecord==0){
            data_status = "open";
            data_class = "report-open";
            imgname = "icon-folder.png";
        }
        //缩进
        var indent = that.setIndent(item.level);

        //item
        var html = '';
        html = '<tr class="lvtColData" data-status="'+data_status+'" tag="sequence_' + item.parent_id + '" recent-view="no" module="'+item.modulename+'" data-parent="' + item.parent_id + '" data-id="' + item.report_id + '" data-sequence="' + (parseInt(index) + 1) + '">\n' +
            '<td style="'+indent+';max-width:320px;"><div class="report-name" onclick="ReportAnalysisObj.showReportChild(this,'+item.report_id+');"><div class="'+data_class+'">&nbsp;</div><div tag="folder-img">'+'<img class="marL8 marR8" src="themes/softed/images/icon-folder-close.png"></div><div tag="reportname">'+item.report_name+'</div></div></td>\n' +
            '</tr>';
        return html;
    }
    //分屏视图  报表行的html
    this.renderReport = function(index,item,datalength){

        var linkhtml = that.getReportNameHtml(item);//详情的跳转链接
        var html = '<tr tag="sequence_' + item.parent_id + '" class="lvtColData" module="'+item.modulename+'" recent-view="'+item.recentview+'" data-parent="' + item.parent_id + '" data-id="' + item.report_id + '" data-sequence="' + (parseInt(index) + 1) + '">\n' +
           linkhtml+
            '</tr>';
        var key = item.modulename+'_'+item.report_id;
        that.reportlist[key] = item;//报表的数据  键是报表所属模块加上报表id
        return html;
    }
    this.getDetailBtnHtml = function(modulename,report_id){
        var html='';
        var item = that.reportlist[modulename+'_'+report_id];
        if(item&&item.btnarr!='') {
            var btnarr = [];
            if(typeof item.btnarr == 'string'){
                btnarr = item.btnarr.split(',');
            }else{
                btnarr = item.btnarr.list;
            }
            ld.each(btnarr, function (i, btnname) {
                html += that.getButtonHtml(btnname, item);
            });
        }
        return html;
    }
    //取消显示报表
    this.canceldisplayReport = function(report_id,obj,modulename){
        var url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=ListView&function_name=CancelDisplayReport';
        var params = '&reportid='+report_id+'&modulename='+modulename;
        ldAjaxNoProgress(url,params,function(res){
            if(res.code==1){
                that.getRecentView(function(){
                    //回调处理 当前报表取消显示之后，限制最近浏览的最新一个
                    that.showRecentViewFirst();
                });
            }
        });
    }
    //删除报表
    this.deleteReport = function(report_id,obj,modulename){
        RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['CONFIRMWANTDELETEREPORTS']);
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function() {
            var url = "index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=DeleteReport";
            var param = "&report_id=" + report_id+"&modulename=" + modulename;
            ldAjaxNoProgress(url,param,function(res){
                MessagePopup.TipOne_success(res.msg);
                if(res.code==1){
                    var msgObj = CrmPopup.global_listPopupObj.pop();
                    //删除该行tr
                    ld('#'+that.divid).find('tr[module='+modulename+'][data-id='+report_id+']').remove();
                    //显示最新一个最近浏览的报表
                    that.showRecentViewFirst();
                    ld('#'+msgObj.divid).find('#'+msgObj.divid+'_btnok').unbind('click').bind('click',function () {
                        CrmPopup.global_listPopupObj.push(msgObj)
                        msgObj.CancelEvent()
                    })
                }
            });
        });
    }
    //取消显示或者删除的时候 显示最近浏览的第一个
    this.showRecentViewFirst = function(){
        ld('#'+that.divid).find('#reportanalysis_reportcontent').empty();
        var second_line = that.tbody_recentview.find('td:eq(1)').find('.report-name-link');//最近浏览数据的第一条
        if(second_line.length>0){
            second_line.trigger('click');
        }else{
            ld('#'+that.divid).find('#reportanalysis_reportcontent').html(that.emptyHtml());//空态
            ld('#'+that.divid).find('#screen_reportname').text('');//空态
            ld('#'+that.divid).find('[tag=reportanalysis_detail_btnlist]').html('');//空态
        }
    }
    this.showEchartDetail = function(report_id,report_type,report_name){
        ld('#screen_reportname').text(report_name);
        var btnhtml = that.getDetailBtnHtml('CustomEcharts',report_id)
        ld('[tag=reportanalysis_detail_btnlist]').html(btnhtml);
        var file = report_type=='sqlchart'?'SqlEchartsDetailView':'SelfDefinedReport';
        var url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file='+file+'&function_name=getChart&report_id=' + report_id;
        ldAjax(url,'',function (data) {
            if (data.code == 1) {
                ld('#reportanalysis_reportcontent').html(data.result.content);
                ld('#rptContentLoading').hide();
            }
            //edit: xll 2023/10/19 BUG0074218 在报表详情显示后再更新报表列表界面
            that.RecordLastViewRecord(report_id,'CustomEcharts');
        });
    }

    this.showTableDetail = function(report_id,report_type,report_name){
        ld('#screen_reportname').text(report_name);
        var btnhtml = that.getDetailBtnHtml('CustomTables',report_id)
        ld('[tag=reportanalysis_detail_btnlist]').html(btnhtml);
        var  Popupobj = new CrmPopup();
        Popupobj.divid="reportanalysis_reportcontent";
        Popupobj.module='CustomTables';

        var file = report_type=='sql'?'SqlTableDetailView':'CustomTablesDetailView';
        var url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file='+file+'&function_name=index&report_id=' + report_id;
        ldAjax(url,'',function (data) {
            if (data.code == 1) {
                Popupobj.permit_createview = data.result.permit_create;//编辑、新增权限
                Popupobj.permit_editview = data.result.permit_edit;//编辑权限
                ld('#reportanalysis_reportcontent').html(data.result.content);
                if(report_type=='sql'){
                    getScriptBackWithURL('include/js/modules/CustomTables/CustomTablesSqlDetail.js',function() {
                        var CustomTablesSqlDetailObj = new CustomTablesSqlDetail();
                        CustomTablesSqlDetailObj.setPopupobj(Popupobj);
                        CustomTablesSqlDetailObj.setDivid(Popupobj.divid);
                        CustomTablesSqlDetailObj.setReportId(report_id);
                        CustomTablesSqlDetailObj.init();
                    });
                }else{
                    getScriptBackWithURL('include/js/modules/CustomTables/CustomTablesDetail.js',function() {
                        var CustomTablesDetailObj = new CustomTablesDetail();
                        CustomTablesDetailObj.setPopupobj(Popupobj);
                        CustomTablesDetailObj.setDivid(Popupobj.divid);
                        CustomTablesDetailObj.setReportId(report_id);
                        CustomTablesDetailObj.init();
                    });
                }
                ld('#rptContentLoading').hide();
                //zxm 20240710 分屏模式的时候自定义统计表有冻结列的时候 th和td的层级太高(9999),点击编辑按钮,这个div的表格会覆盖在编辑弹窗之上
                ld('#'+Popupobj.divid).find('#thResizable').css('z-index',1)
            }
            that.RecordLastViewRecord(report_id,'CustomTables');
        });

    }
    //分屏视图--常用报表的显示
    this.showUseReport = function(report_id,reportlabel,report_name){
        ld('#screen_reportname').text(report_name);
        var btnhtml = that.getDetailBtnHtml('OftenUseReport',report_id)
        ld('[tag=reportanalysis_detail_btnlist]').html(btnhtml);
        var tempurl = "index.php?module=ReportAnalysis&file=OftenUseReport&action=ReportAnalysisAjax&isshowModuleListTree=yes&report_name="+reportlabel+"&refreshUseReport="+ report_id +"&refreshleftmenuclick=yes&frommodule=ReportAnalysis&listtype=screen";
        ldAjax(tempurl,'',function (data) {
            ld('#reportanalysis_reportcontent').html(data.result.content);
            ld('#rptContentLoading').hide();
            //edit: xll 2023/10/19 BUG0074218 在报表详情显示后再更新报表列表界面
            that.RecordLastViewRecord(report_id,'OftenUseReport');
        });
    }
    //分屏视图 俄罗斯报表的显示
    this.showCustomreport = function(report_id,type,report_template,report_name,databaselinktype){
        ld('#screen_reportname').text(report_name);
        var btnhtml = that.getDetailBtnHtml('Customreport',report_id)
        ld('[tag=reportanalysis_detail_btnlist]').html(btnhtml);
        if(type=='url'){
            //链接
            var html='<iframe src="'+report_template+'" frameborder="0" width="100%" height="100%">'
        }else{
            var default_report = '1';
            if(databaselinktype === 'templatelink') {
                default_report = '0';
            }
            var tmpherf='CustomReport/JsReport/index.php?crm_report_key='+report_template+'&default_report='+default_report+'&report_name='+encodeURIComponent(report_name)+'&fromlinkmodule=yes';
            tmpherf= cls_encryptyurl.Puyoung_Encryptyurl(tmpherf,'');
            var html='<iframe src="'+tmpherf+'" frameborder="0" width="100%" height="100%">'
        }
        ld('#reportanalysis_reportcontent').html(html);
        that.RecordLastViewRecord(report_id,'Customreport');
    }
    //分屏视图 综合报表  显示
    this.showComprehensivereport = function(report_id,report_name){
        var tempurl = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=ComprehensivereportAll&listtype=screen&report_id='+report_id;
        tempurl= cls_encryptyurl.Puyoung_Encryptyurl(tempurl,'');
        var btnhtml = that.getDetailBtnHtml('Comprehensivereport',report_id)
        ld('[tag=reportanalysis_detail_btnlist]').html(btnhtml);
        ldAjax(tempurl,'',function (data) {
            ld('#screen_reportname').text(report_name);
            ld('#reportanalysis_reportcontent').html(data.result.content);
            var curtypename = data.result.curtypename;
            ld('#Comprehensivereport_list').children().hide();
            ld('#Comprehensivereport_list').find('#change_table_div_'+curtypename).show();
            ld('#rptContentLoading').hide();
            //edit: xll 2023/10/19 BUG0074218 在报表详情显示后再更新报表列表界面
            that.RecordLastViewRecord(report_id,'Comprehensivereport');
        });
    }
    this.updateFolderList = function (list) {
        if(!(list instanceof Array))
            list = [list]
        ld.each(list,function (index,item) {
            that.updateReportHtmlInfo(item);
        })
    }
    //更新报表显示信息 比如报表名称 按钮等
    this.updateReportHtmlInfo = function(item){
        //需要更新左侧报表名称  右侧头的报表名称和按钮
        var modulename = item.modulename;
        var report_id = item.report_id;
        var popupJqObj = ld('#'+that.divid);
        if(item.show=='no'){
            popupJqObj.find('tr[module='+modulename+'][data-id='+report_id+']').remove();
            return ;
        }
        popupJqObj.find('tr[module='+modulename+'][data-id='+report_id+']').find('.report-name-link').html('<b class="icon-table marR5 marT-2"></b>'+item.report_name);
        popupJqObj.find('#screen_reportname').text(item.report_name);
        //更新按钮
        var btnhtml = '';
        if(item.btnarr!='') {
            var btnarr = item.btnarr.split(',');
            ld.each(btnarr, function (i, btnname) {
                btnhtml += that.getButtonHtml(btnname, item);
            });
        }
        popupJqObj.find('[tag=reportanalysis_detail_btnlist]').html(btnhtml);
    }
}
ReportAnalysisScreen.prototype = Object.create(ReportAnalysis.prototype);
ReportAnalysisScreen.prototype.constructor = ReportAnalysisScreen;