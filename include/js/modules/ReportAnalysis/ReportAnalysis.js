//列表页JS
function ReportAnalysis(){
    var that = this;
    this.pagemode='';
    this.listtype='list';//视图类型:列表视图,分屏视图 默认列表视图
    this.divid='reportanalysis_list';
    this.frompage='fromlist';
    this.folderimg='themes/softed/images/icon-folder.png?a='+Math.random();
    this.curReportModule = '';
    this.curReportId = 0;
    this.reportlistbody = ld('#'+that.divid).find('[tag=reportList_'+that.listtype+']');
    this.tbody_recentview = ld('#'+that.divid).find('[tag=LastReview]');
    this.init = function(){
        that.setEvent();
        this.reportlistbody.empty();
        this.tbody_recentview.find('tr[recent-view=yes]').remove();
    }

    this.setEvent = function(){
        window.onresize = function(e) {
            var event = window.event || e;
            that.reportTypeNav();
        }
        ld('#'+that.divid+' #reportanalysis_tablecontent').css('height',(ld(window).height()-160)+'px');
    }
    //设置文件夹前面的缩进空格
    that.setIndent = function(level){
        var indent = 'padding-left:'+(level*15)+'px';
        return indent;
    }
    //没搜到数据的提示
    that.getNoRecordsHtml = function(msg){
        return '<table class="listEntries marB20" border="0" cellspacing="1" cellpadding="0" width="100%">' +
            '<tr>' +
            '<td style="background-color:#fff;height: 0px;padding: 0;" colspan="7" align="center">' +
            '<div class="warningTableContent" style="z-index:600;margin: 10px auto;">' +
            '<div class="wtc_img">' +
            '<img src="themes/icon2023/ld-no-records.png?'+global_js_version+'">' +
            '</div>' +
            '<div class="wtc_content">'+msg+'</div>' +
            '<div class="wtc_btn"></div>' +
            '<div></div>' +
            '</div>' +
            '</td>' +
            '</tr>' +
            '</table>';
    }
    //获取最近浏览的那一行列头
    that.getRecentViewHeader = function(){
        return '<tr class="lvtColData" data-status="open" tag="RecentView" data-parent="0" >\n' +
            '      <td  class="locking-left shadow-left">\n' +
            '          <div class="report-name" name="RecentView" onclick="ReportAnalysisObj.showRecentReport(this,\'RecentView\');">\n' +
            '              <div class="report-open">&nbsp;</div>\n' +
            '              <div tag="folder-img">\n' +
            '                  <img class="marL8 marR8" src="'+that.folderimg+'">'+arrJsPopLabel['RECENTBROWSING']+'\n' +
            '              </div>\n' +
            '          </div>\n' +
            '      </td>\n' +
            '      <td></td>\n' +
            '      <td>'+arrJsPopLabel['FOLDER']+'</td>\n' +
            '      <td><span title="">'+arrJsPopLabel['RecentBrowsingReport']+'</span></td>\n' +
            '      <td></td>\n' +
            '      <td></td>\n' +
            '      <td class="locking-right shadow-right"><div style="display: flex;justify-content: flex-start;"></div>\n' +
            '      </td>\n' +
            '  </tr>';
    }
    //报表名称的html--根据模块名称获取
    that.getReportNameHtml = function(item){
        var reportNameHtmlArr = {
            OftenUseReport:function(item){
                var tempurl = "index.php?pageto_module=ReportAnalysis&pageto_action=OftenUseReport";
                var addurl =encodeURIComponent("&report_name="+ item.reportlabel +"&refreshUseReport="+ item.report_id +"&refreshleftmenuclick=yes&frommodule=ReportAnalysis");
                tempurl = tempurl+'&page_addurl='+addurl;
                return '<a class="report-name-link" target="_blank" onclick="ReportAnalysisObj.RecordLastViewRecord(' + item.report_id + ',\'' + item.modulename + '\')" href="'+tempurl+'">'+ '<b class="icon-table marR5 marT-2"></b>' + item.report_name + '</a>';
            },

            Customreport:function(item){
                if(item.type=='url'){
                    return '<a class="report-name-link" target="_blank" title="' + item.report_name + '"  onclick="ReportAnalysisObj.RecordLastViewRecord(' + item.report_id + ',\'' + item.modulename + '\')" href="' + item.report_template + '">' + '<b class="icon-table marR5 marT-2"></b>' + item.report_name + '</a>';
                }
                else {
                    //报表库的 打开新页签
                    //edit: xll 2024/03/06 BUG20240209-01 报表分析--模板报表--使用模板参数配置不生效
                    var default_report = '1';
                    if (item.databaselinktype === 'templatelink') {
                        default_report = '0';
                    }
                    var tmpherf = 'index.php?crm_report_key=' + item.report_template + '&default_report=' + default_report + '&report_name=' + encodeURIComponent(item.report_name);
                    //zkt 20231010 XUQIU1001341 SQL注入
                    tmpherf = cls_encryptyurl.Puyoung_Encryptyurl(tmpherf, '');
                    return '<a class="report-name-link" target="_blank" title="' + item.report_name + '"  onclick="ReportAnalysisObj.RecordLastViewRecord(' + item.report_id + ',\'' + item.modulename + '\')" href="CustomReport/JsReport/' + tmpherf + '">' + '<b class="icon-table marR5 marT-2"></b>' + item.report_name + '</a>';
                }
            },
            Comprehensivereport:function(item){
                var tmpherf = 'index.php?pageto_module=ReportAnalysis&pageto_action=Comprehensivereport' ;
                //zkt 20231010 XUQIU1001341 SQL注入
                tmpherf= cls_encryptyurl.Puyoung_Encryptyurl(tmpherf,'');
                //综合报表的
                return '<a class="report-name-link" target="_blank" onclick="ReportAnalysisObj.RecordLastViewRecord(' + item.report_id + ',\'' + item.modulename + '\')" href="'+tmpherf+'">'+ '<b class="icon-table marR5 marT-2"></b>' + item.report_name + '</a>'
            },
            CustomEcharts:function(item) {
                return '<a class="report-name-link" href="javascript:;" onclick="ReportAnalysisObj.showEchartDetail(' + item.report_id + ',\'' + item.type + '\')">' + '<b class="icon-chart marR5 marT-2"></b>' + item.report_name + '</a>';
            },
            CustomTables:function(item){
                return '<a class="report-name-link" href="javascript:;" onclick="ReportAnalysisObj.showTableDetail(' + item.report_id + ',\'' + item.type + '\')">' + '<b class="icon-table marR5 marT-2"></b>' + item.report_name + '</a>';
            },
        }
        return reportNameHtmlArr[item.modulename](item);
    }
    //列表视图的时候--编辑按钮的html
    that.getReportEditHtml = function(item){
        var tooltip_attr = 'data-tip="'+arrJsPopLabel['EDIT']+'" data-direction="top" data-type="position"';
        var editHtmlArr = {
            OftenUseReport: function (item) {
                return '';
            },
            Customreport: function (item) {
                return  '<i target="_blank" '+tooltip_attr+' class="ld-button-list-item ld-fonticon ld-fonticon-edit textFloatDisplay" data-id="' + item.report_id + '" onclick="ReportAnalysisObj.editTemplateReport(' + item.report_id + ')"></i>';
            },
            Comprehensivereport: function (item) {
                return '';
            },
            CustomEcharts: function (item) {
                return '<i target="_blank" '+tooltip_attr+' class="ld-button-list-item ld-fonticon ld-fonticon-edit textFloatDisplay" data-id="' + item.report_id + '" onclick="ReportAnalysisObj.creat_new_chart(this,\'' + item.type + '\')"></i>';
            },
            CustomTables: function (item) {
                return '<i target="_blank" '+tooltip_attr+' class="ld-button-list-item ld-fonticon ld-fonticon-edit textFloatDisplay" data-id="' + item.report_id + '" onclick="ReportAnalysisObj.creat_new_table(this,\'' + item.type + '\')"></i>';
            },
            ReportAnalysis:function(item){
                //文件夹的编辑按钮
                return '<i '+tooltip_attr+' class="ld-button-list-item ld-fonticon ld-fonticon-edit textFloatDisplay" href="javascript:;" onclick="ReportAnalysisObj.createNewDir(' + item.report_id + ',' + item.parent_id + ',this)"></i>';
            }
        }
        return editHtmlArr[item.modulename](item);
    }

    that.getButtonHtml = function(btnname,item){
        //编辑、分配、新建、排序、删除,取消显示
        var btnArr = {
            edit:function(item){
                return that.getReportEditHtml(item);
            },
            allocate:function(item){
                var tooltip_attr = 'data-tip="'+arrJsPopLabel['DISTRIBUT']+'" data-direction="top" data-type="position"';
                return '<i class="ld-button-list-item ld-fonticon ld-fonticon-allocate textFloatDisplay" '+tooltip_attr+' href="javascript:;" onclick="ScopePopup_Details.getInstance().allocateTemplate(this,' + item.parent_id + ',' + item.report_id + ',\'' + item.allocatetypeids + '\',' + item.approveallocatetype + ',\'ReportAnalysis\',\''+item.modulename+'\');"></i>';
            },
            create:function(item){
                var tooltip_attr = 'data-tip="'+arrJsPopLabel['CREATE']+'" data-direction="top" data-type="position"';
                return '<i data-showtag="create-droplist" class="creat-new-table2 ld-button-list-item ld-fonticon ld-fonticon-addfolder textFloatDisplay" '+tooltip_attr+' href="javascript:;"></i>';
            },
            create_more:function(item){
                return '<ol tag="create-droplist" class="D_more_menua report-type-select2 reportanalysis-more-shadow" style="height: 262px;">\n' +
                    '<li onclick="ReportAnalysisObj.createNewDir(0,' + item.report_id + ')",this>\n' +
                    '      <a title="' + arrJsPopLabel['FOLDER'] + '" style="padding:0 5px;margin:0;text-align: center;">' + arrJsPopLabel['FOLDER'] + '</a>\n' +
                    '</li>' +
                    '<li onclick="ReportAnalysisObj.createTemplateReport(' + item.report_id + ')">\n' +
                    '      <a title="' + arrJsPopLabel['TEMPLATE'] + arrJsPopLabel['Table']+'" style="padding:0 5px;margin:0;text-align: center;">' + arrJsPopLabel['TEMPLATE'] + arrJsPopLabel['Table']+'</a>\n' +
                    '</li>' +
                    '<li data-parentid="' + item.report_id + '" onclick="ReportAnalysisObj.creat_new_table(this,\'selectfield\')">\n' +
                    '     <a title="' + arrJsPopLabel['MODULE'] + arrJsPopLabel['Table']+'" style="padding:0 5px;margin:0;text-align: center;">' + arrJsPopLabel['MODULE'] + arrJsPopLabel['Table']+'</a>\n' +
                    '</li>\n' +
                    '<li data-parentid="' + item.report_id + '" onclick="ReportAnalysisObj.creat_new_table(this,\'sql\')">\n' +
                    '     <a title="SQL'+ arrJsPopLabel['Table']+'" style="padding:0 5px;margin:0;text-align: center;">SQL'+ arrJsPopLabel['Table']+'</a>\n' +
                    '</li>\n' +
                    '<li onclick="">\n' +
                    '     <a title="'+ arrJsPopLabel['statisticalGraphics']+'" style="padding:0 5px;margin:0;text-align: center;" onclick="ReportAnalysisObj.creat_new_chart(this,\'selectfield\')">'+ arrJsPopLabel['statisticalGraphics']+'</a>\n' +
                    '</li>'+
                    '<li onclick="">\n' +
                    '     <a title="SQL'+ arrJsPopLabel['statisticalGraphics']+'" style="padding:0 5px;margin:0;text-align: center;" onclick="ReportAnalysisObj.creat_new_chart(this,\'sqlchart\')">SQL'+ arrJsPopLabel['statisticalGraphics']+'</a>\n' +
                    '</li>'+
                    '</ol>';
            },
            sort:function(item){
                var tooltip_attr = 'data-tip="'+arrJsPopLabel['SORT']+'" data-direction="top" data-type="position"';
                return '<i class="ld-button-list-item ld-fonticon ld-fonticon-sort textFloatDisplay" '+tooltip_attr+' href="javascript:;" onclick="ReportAnalysisObj.sortReport(' + item.report_id + ')"></i>';
            },
            sort_more:function(item){
                //更多里面的排序
                return '<li class="reportanalysis-more-li" href="javascript:;" onclick="ReportAnalysisObj.sortReport(' + item.report_id + ')">\n' +
                            '<a class="reportanalysis-btn-more" style="padding:0 5px;margin:0;text-align: center;">' + arrJsPopLabel['SORT'] + '</a>\n' +
                        '</li>';
            },
            delete:function(item){
                var tooltip_attr = 'data-tip="'+arrJsPopLabel['DELETE']+'" data-direction="top" data-type="position"';
                //常用报表/综合报表(系统预设)没有这个删除按钮  文件夹下有报表的也没有删除按钮 最近浏览文件夹也没有删除按钮
                if(item.modulename=='ReportAnalysis'){
                    //文件夹
                    return '<i class="ld-button-list-item ld-fonticon ld-fonticon-del textFloatDisplay" '+tooltip_attr+' href="javascript:;" onclick="ReportAnalysisObj.deleteDir(' + item.report_id + ',this,' + item.parent_id + ')"></i>';
                }else{
                    //报表
                    return '<i class="ld-button-list-item ld-fonticon ld-fonticon-del textFloatDisplay" '+tooltip_attr+' href="javascript:;" onclick="ReportAnalysisObj.deleteReport(' + item.report_id + ',this,\'' + item.modulename + '\')"></i>';
                }
            },
            delete_more:function(item){
                //常用报表/综合报表(系统预设)没有这个删除按钮  文件夹下有报表的也没有删除按钮 最近浏览文件夹也没有删除按钮
                if(item.modulename=='ReportAnalysis'){
                    //文件夹
                    return '<li class="reportanalysis-more-li" href="javascript:;" onclick="ReportAnalysisObj.deleteDir(' + item.report_id + ',this,' + item.parent_id + ')">\n' +
                        '<a class="reportanalysis-btn-more" style="padding:0 5px;margin:0;text-align: center;">' + arrJsPopLabel['DELETE'] + '</a>\n' +
                        '</li>';
                }
                else{
                    //报表
                    return '<li href="javascript:;" onclick="ReportAnalysisObj.deleteReport(' + item.report_id + ',this,\'' + item.modulename + '\')">\n' +
                        '<a class="ld-button-list-item reportanalysis-btn-more ld-button-list-item-delete-more" style="padding:0 5px;margin:0;text-align: center;">' + arrJsPopLabel['DELETE'] + '</a>\n' +
                        '</li>';
                }
            },
            cancel:function(item){
                 var tooltip_attr = 'data-tip="'+arrJsPopLabel['CANCELDISPLAY']+'" data-direction="top" data-type="position"';
                //只有最近浏览文件夹里面的有
                return '<i class="ld-button-list-item ld-fonticon ld-fonticon-canceldisplay textFloatDisplay" '+tooltip_attr+' href="javascript:;" onclick="ReportAnalysisObj.canceldisplayReport(' + item.report_id + ',this,\'' + item.modulename + '\')"></i>';
            },
            cancel_more:function(item){
                return '<li class="reportanalysis-more-li" href="javascript:;" onclick="ReportAnalysisObj.canceldisplayReport(' + item.report_id + ',this,\'' + item.modulename + '\')">\n' +
                    '<a class="reportanalysis-btn-more ld-button-list-item-cancel-more" style="padding:0 5px;margin:0;text-align: center;">' + arrJsPopLabel['CANCELDISPLAY'] + '</a>\n' +
                    '</li>';
            },
            move:function(item){
                 var tooltip_attr = 'data-tip="'+arrJsPopLabel['MOVE']+'" data-direction="top" data-type="position"';
                return '<i class="ld-button-list-item ld-fonticon ld-fonticon-move textFloatDisplay" '+tooltip_attr+' href="javascript:;" onclick="ReportAnalysisObj.moveDir(' + item.report_id + ',\'' + item.report_name + '\',' + item.parent_id + ',\''+item.modulename+'\')"></i>';
            },
            move_more:function(item){
                return '<li class="reportanalysis-more-li" href="javascript:;" onclick="ReportAnalysisObj.moveDir(' + item.report_id + ',\'' + item.report_name + '\',' + item.parent_id + ',\''+item.modulename+'\')">\n' +
                    '<a class="reportanalysis-btn-more" style="padding:0 5px;margin:0;text-align: center;">' + arrJsPopLabel['MOVE'] + '</a>\n' +
                    '</li>';
            },
            print:function(item){
                //打印--只有SQL统计表和自定义统计表有--列表视图暂时不放
                return '';
            },
            export:function(item){
                //导出--只有SQL统计表和自定义统计表有--列表视图暂时不放
                return '';
            },
            more:function(item){
                var more_html= '<i data-showtag="more-droplist" class="creat-new-table2 ld-button-list-item ld-fonticon ld-fonticon-more textFloatDisplay" href="javascript:;"></i>';
                return more_html;
            },
            more_drop:function (item){
                if(item.btnarr&&item.btnarr['more']){
                    var morelist = item.btnarr['more'];//前三个按钮不可能会到更多里面  不需要考虑判断

                    var height = (morelist.length*42)+10;
                    var more_html= '<ol tag="more-droplist" class="reportanalysis-more-shadow report-type-select2" style="height:'+height+'px">\n' ;
                    ld.each(morelist,function(i,morebtnname){
                        more_html+=that.getButtonHtml(morebtnname+'_more',item);
                    });
                    more_html+='</ol>';
                    return more_html;
                }
                return '';
            }
        }
        return btnArr[btnname](item);
    }

    //模糊搜索报表 回车搜索
    that.searchSubmit = function(event){
        var e = event || window.event;
        if(e.keyCode == 13){// Enter 回车键
            that.getSearchList();
        }
    }
    // 搜索
    this.getSearchList = function(){
        var keyWords = ld('#'+that.divid).find("[name=keyWords]").val();
        var tbody = that.reportlistbody;
        var tbody_recentview = that.tbody_recentview;
        if(empty(keyWords)){
            tbody_recentview.show();
            that.getReportList(0,'init');return;
        }
        var url = "index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=ListView";
        var param = 'is_ajax=yes&function_name=getReportList&type=search&keyWords='+keyWords;
        tbody.empty();
        ld('tr[recent-view=yes]').remove();
        ldAjaxNoProgress(url,param,function(res){
            var data = res.result.list;
            var dataLength = data.length;
            tbody_recentview.hide();
            if(dataLength==0){
                //数据条数为0 没搜出来相关报表
                tbody.html(that.getNoRecordsHtml(res.msg));
            }
            var html = '';
            ld.each(data,function(index,item) {
                html = that.renderReport(index,item,dataLength);
                tbody.append(html);
                tooltip('.textFloatDisplay', {transition: true, time: 200});
            });
            that.refreshClassNameAfterShow();
            that.reportTypeNav();
            ld('#rptContentLoading').hide();
        });
    }
    // 最近浏览
    this.getRecentView = function(callback){
        var LastReviewRecord=parseInt(ld('#LastReviewRecord').val());
        var tbody_recentview = that.tbody_recentview;
        if(LastReviewRecord>0){
            var url = "index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=ListView";
            var param = "is_ajax=yes&function_name=getReportList&type=init&parent_id=-1";
            ldAjaxNoProgress(url, param, function (res) {
                var data = res.result.list;
                var html = that.getRecentViewHeader();
                var dataLength = data.length;
                ld.each(data, function (index, item) {
                    html += that.renderReport(index,item,dataLength);
                });
                tbody_recentview.html(html);
                tooltip('.textFloatDisplay', {transition: true, time: 200});
                that.refreshClassNameAfterShow();
                //当前行显示选中态--列表视图不需要
                if(that.listtype=='screen'){
                    ld('#'+that.divid+' [tag=LastReview]').find('tr').removeClass('lvtColDataHover').addClass('lvtColData');
                    if(that.curReportModule){
                        ld('#'+that.divid+' [tag=LastReview]').find('tr[module='+that.curReportModule+'][data-id='+that.curReportId+']').addClass('lvtColDataHover').removeClass('lvtColData');
                    }
                }
                callback();
            });
        }
    }
    // 获取子文件夹和子报表
    //根据parent_id 与type获取报表列表
    this.getReportList =function(parent_id,type){
        ld('#rptContentLoading').show();
        var url = "index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=ListView";
        var keyWords = ld('#'+that.divid).find("[name=keyWords]").val();
        var tbody_recentview=that.tbody_recentview;
        var tbody = that.reportlistbody;
        tbody.empty();
        var param = "is_ajax=yes&function_name=getReportList&parent_id="+parent_id+'&type='+type+'&keyWords='+keyWords+'&listtype='+that.listtype;
        ldAjaxNoProgress(url,param,function(res){
            var data = res.result.list;
            var dataLength = data.length;
            tbody_recentview.show();
            var html = '';
            ld.each(data,function(index,item) {
                if(item.isfolder == 'yes'){
                    var LastReviewRecord=parseInt(ld('#LastReviewRecord').val());
                    html = that.renderDir(index,item,parent_id);
                    tbody.append(html);
                    if(index==0){
                        if(LastReviewRecord==0){
                            //默认展开第一个
                            that.getReportChildData(item.report_id,tbody.find('tr:first-child'),'after');
                        }
                        else{
                            ld('#'+that.divid).find('tr[recent-view=yes]').remove();
                            //默认展开最近浏览文件夹
                            var parenttr = tbody_recentview.find('tr:first-child');
                            ld(parenttr).attr('data-status','open');
                            ld(parenttr).find('.report-close').removeClass('report-close').addClass('report-open');
                            ld(parenttr).find('div[tag=folder-img] img').attr('src',that.folderimg);
                            that.getReportChildData(-1,tbody_recentview.find('tr:first-child'),'after');
                        }
                    }
                }
                else{
                    html = that.renderReport(index,item,dataLength);
                    tbody.append(html);
                    tooltip('.textFloatDisplay', {transition: true, time: 200});
                }
            });
            that.refreshClassNameAfterShow();
            that.reportTypeNav();
            ld('#rptContentLoading').hide();
        });
    }

    //wyt 221213 BUG0059145 报表分析，搜索报表输入框，输入关键字后，后面增加删除图标按钮
    //显示清除按钮
    this.viewClearText = function(){
        var search_text = ld('#'+that.divid).find("[name=keyWords]").val();
        //显示清除按钮
        if(!empty(search_text)){
            ld('.create-entity-toolbar .ld-icon-clearsearch').css('display','');
        }
        else{
            ld('.create-entity-toolbar .ld-icon-clearsearch').css('display','none');
        }
    }
    //清除搜索框内容
    this.clearText = function(){
        //显示清除按钮
        ld('#'+that.divid).find("[name=keyWords]").val('');
        ld('#'+that.divid).find("[name=keyWords]").focus();
        ld('.create-entity-toolbar .ld-icon-clearsearch').css('display','none');
        that.getReportList(0,'search');
    }

    //点击展开
    this.getReportChild = function(parent_id,obj){
        //var parenttr = ld(obj).parents('tr');
        var parenttr =  Tools.getParentobjByChild(ld(obj),'tr');
        var status = parenttr.attr('data-status');
        var report_id = parenttr.attr('data-id');
        if(status=='close') {
            parenttr.attr('data-status','open');
            ld(obj).find('.report-close').removeClass('report-close').addClass('report-open');
            ld(parenttr).find('div[tag=folder-img] img').attr('src',that.folderimg);
            that.getReportChildData(parent_id,parenttr,'after');
        }
        else{
            //获得子文件夹 将子文件夹也关闭
            var childrenTrs = parenttr.parent().find('[tag="sequence_'+report_id+'"][data-status="open"]');
            ld.each(childrenTrs,function(index,childtr){
                var pid = ld(childtr).attr('data-id');
                that.getReportChild(pid,ld(childtr).find('.report-name'));
            });
            parenttr.attr('data-status','close');
            ld(obj).find('.report-open').removeClass('report-open').addClass('report-close');
            ld(parenttr).find('div[tag=folder-img] img').attr('src','themes/softed/images/icon-folder-close.png');
            ld('tr[data-parent='+parent_id+'][recent-view=no]').remove();
        }
    }
    //文件夹
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
            '<td class="locking-left shadow-left" style="'+indent+'"><div class="report-name" onclick="ReportAnalysisObj.showReportChild(this,'+item.report_id+');"><div class="'+data_class+'">&nbsp;</div><div tag="folder-img">'+'<img class="marL8 marR8" src="themes/softed/images/'+imgname+'"></div><div tag="reportname">'+item.report_name+'</div></div></td>\n' +
            '<td>'+item.last_name+'</td>\n' +
            '<td>'+item.type_name+'</td>\n' +
            '<td><span tag="description" class="textFloatDisplay" data-tip=\"'+ item.description +'\" data-direction=\"top\" ' +
            'data-type=\"position\">'+item.description+'</span></td>\n' +
            '<td>'+item.createdtime+'</td>\n' +
            '<td><span tag="allocates" class="textFloatDisplay" data-tip=\"'+ item.allocates +'\" data-direction=\"top\" ' +
            'data-type=\"position\">' + item.allocates + '</span>' +that.getButtonHtml('create_more',item) + that.getButtonHtml('more_drop',item)+
            '</td>' +
            '<td  class="locking-right shadow-right"><div tag="btns" class="ld-button-list">';
        ld.each(item.btnarr['list'],function(i,btnname){
            html += that.getButtonHtml(btnname,item);
        })
        html +='</div>' +
            '</td></tr>';
        return html;
    }
    //报表
    this.renderReport = function(index,item,datalength){
        var indent = that.setIndent(item.level);
        var btnhtml = '';
        ld.each(item.btnarr['list'],function(i,btnname){
            btnhtml += that.getButtonHtml(btnname,item);
        });
        var linkhtml = that.getReportNameHtml(item);//详情的跳转链接
        var html = '<tr tag="sequence_' + item.parent_id + '" class="lvtColData" module="'+item.modulename+'" recent-view="'+item.recentview+'" data-parent="' + item.parent_id + '" data-id="' + item.report_id + '" data-sequence="' + (parseInt(index) + 1) + '">\n' +
            '<td class="locking-left shadow-left" style="'+indent+'">'+linkhtml+'</td>\n' +
            '<td>' + item.last_name + '</td>\n' +
            '<td><span class="textFloatDisplay" data-tip=\"'+item.modulelabel +'&nbsp;'+ item.type_name +'\" data-direction=\"top\" ' +
            'data-type=\"position\">'+item.modulelabel +'&nbsp;'+item.type_name+'</span></td>\n' +
            '<td><span class="textFloatDisplay description" data-tip=\"'+ item.description +'\" data-direction=\"top\" ' +
            'data-type=\"position\">' + item.description + '</span></td>\n' +
            '<td>' + item.createdtime + '</td>\n' +
            '<td><span tag="allocates" class="textFloatDisplay" data-tip=\"'+ item.allocates +'\" data-direction=\"top\" ' +
            'data-type=\"position\">' + item.allocates + '</span>' + that.getButtonHtml('create_more',item) + that.getButtonHtml('more_drop',item)+
            '</td>' +
            '<td class="locking-right shadow-right"><div tag="btns" class="ld-button-list">' + btnhtml +
            '</div>' +
            '</td>\n' +
            '</tr>';
        return html;
    }
    //zxm 20220926 新建报表-- 类型下拉选择  更多--下拉
    this.reportTypeNav = function(){
        ld(".creat-new-table2").hover(function (){
            var trobj = Tools.getParentobjByChild(ld(this),'tr');
            var showtag = ld(this).data('showtag');
            var top = ld(this).offset().top ;
            var left = ld(this).offset().left - 90;

            var window_height = ld(window).height();
            var bottom = window_height-top;
            var dropdown_listobj = trobj.find('[tag='+showtag+']');
            dropdown_listobj.css('left',left+'px');
            if(bottom>260){
                top = top + 16 ;
                dropdown_listobj.css('top',top+'px');
            }
            else{
                dropdown_listobj.css('bottom',bottom+'px');
            }
            dropdown_listobj.css('visibility','visible');
        },function (){
            var trobj = Tools.getParentobjByChild(ld(this),'tr');
            var showtag = ld(this).data('showtag');
            var dropdown_listobj = trobj.find('[tag='+showtag+']');
            dropdown_listobj.css('visibility','hidden');
        });
        ld(".report-type-select2").hover(function (){
            ld(this).css('visibility','visible');
        },function (){
            ld(this).css('visibility','hidden');
        });
    }
    //删除文件夹--直接将改行tr删掉
    this.deleteDir = function(report_id,obj){
        RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['CONFIRMWANTDELETEFOLDER']);
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function() {
            var url = "index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=DeleteDir";
            var param = "&report_id=" + report_id;
            ldAjaxNoProgress(url,param,function(res){
                if(res.code==1){
                    MessagePopup.TipOne_success(res.result.res);
                    Tools.getParentobjByChild(ld(obj),'tr').remove();
                }
                else{
                    MessagePopup.TipOne_warning(res.result.res);
                }
            });
        });
    }
    //删除报表--直接将该行tr删掉
    this.deleteReport = function(report_id,obj,modulename){
        RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['CONFIRMWANTDELETEREPORTS']);
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function() {
            var url = "index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=DeleteReport";
            var param = "&report_id=" + report_id+"&modulename=" + modulename;
            ldAjaxNoProgress(url,param,function(res){
                MessagePopup.TipOne_success(res.msg);
                if(res.code==1){
                    Tools.getParentobjByChild(ld(obj),'tr').remove();
                }
            });
        });
    }

    //获取某文件夹下的报表
    this.getReportChildData = function(parent_id,obj,fun) {
        var url = "index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=ListView";
        var param = "is_ajax=yes&function_name=getReportList&type=init&parent_id=" + parent_id;
        ldAjaxNoProgress(url, param, function (res) {
            var data = res.result.list;
            var html = '';
            var dataLength = data.length;
            ld.each(data, function (index, item) {
                if(item.isfolder == 'yes'){
                    //子文件夹  没有新建报表按钮
                    html += that.renderDir(index,item,parent_id);
                }
                else {
                    html += that.renderReport(index,item,dataLength);
                }
            });
            if(fun=="after"){
                obj.after(html);
            }
            else{
                obj.append(html);
            }
            tooltip('.textFloatDisplay', {transition: true, time: 200});
            that.reportTypeNav();
            that.refreshClassNameAfterShow();
            if(parent_id==-1&&that.listtype=='screen'){
                //最近浏览  打开第一个报表
                var second_line = that.tbody_recentview.find('td:eq(1)').find('.report-name-link');
                second_line.trigger('click');
            }
        });
    }
    //新建报表
    this.creat_new_table = function(obj,report_type){
        var report_id = ld(obj).attr('data-id');
        if(empty(report_id))
            report_id = 0;
        var frompage = 'fromlist';
        frompage = ld(obj).attr('frompage');
        var  parent_id = ld(obj).attr('data-parentid');
        if(report_type=='sql') {
            getJsScript('include/js/modules/CustomTables/CustomTablesSqlCreate.js', function () {
                var NewCreateObj = new CustomTablesSqlCreate();
                NewCreateObj.createTableSql(report_id,frompage,parent_id);
            });
        }
        else{
            getJsScript('include/js/modules/CustomTables/CustomTablesCreate.js', function () {
                CustomTablesCreate.createTable(report_id,frompage,parent_id);
            });
        }
    }
    //新建图表 编辑图表
    this.creat_new_chart = function(obj,report_type) {
        var report_id = ld(obj).attr('data-id');
        if(empty(report_id))
            report_id = 0;
        var frompage = that.frompage;
        frompage = ld(obj).attr('frompage');
        var parent_id = ld(obj).attr('data-parentid');
        if(report_type=='sqlchart'){
            //sql图表
            getJsScript('include/js/modules/CustomEcharts/SqlChartCreate.js', function () {
                var NewCreateObj = new SqlChartCreate();
                NewCreateObj.createChart(report_id,frompage,parent_id);
            });
        }
        else{
            getJsScript('include/js/modules/CustomEcharts/ChartCreate.js', function () {
                var NewCreateObj = new ChartCreate();
                NewCreateObj.createChart(report_id,frompage,parent_id);
            });
        }
    }
    //点击文件夹 事件
    this.showReportChild = function(obj,report_id){
        that.getReportChild(report_id,obj);
    }
    //新建分类
    this.createNewDir = function(analysisfolder_id,parent_id,obj) {
        var url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=EditDir&mode=edit&analysisfolder_id='+analysisfolder_id+'&parent_id='+parent_id;
        ldAjaxNoProgress(url,{},function(res){
            var module = 'ReportAnalysis';
            var Popupobj = CrmPopup.load( res.result.title, that.submitDirInfo, "", "LdPopWidth600px", module, "", res.result.oktext, "", res.result.cancel);
            Popupobj.createScrollDiv();//创建滚动条
            Popupobj.prevshow();
            Popupobj.center();
            Popupobj.setParams(res.result.title, that.submitDirInfo, '', "LdPopWidth600px", module, obj, res.result.oktext, "", res.result.cancel);
            Popupobj.show(res.result.content);
        });
    }
    //新建文件夹提交的ajax请求--编辑文件夹改变文件夹行的名称和描述--创建文件夹在最近浏览的最后追加一行文件夹tr
    this.submitDirInfo = function(obj){
        var popupobj = CrmPopup.getPopupObj('last');
        var divid = popupobj.divid;
        var analysisfolder_id = ld('#'+divid+' #analysisfolder_id').val();
        var folderlabel_zh = ld('#'+divid+' #folderlabel_zh').val();
        var folderlabel_en = ld('#'+divid+' #folderlabel_en').val();
        var description = ld('#'+divid+' #description').val();
        var parent_id = ld('#'+divid+' #parent_id').val();

        if(folderlabel_zh==''||folderlabel_zh==undefined){
            ld('#folderlabel_zh').css('border-color','red');
            ld('#folderlabel_zh').addClass('input-warning');
            ld('#folderlabel_zh').focus();
            return;
        }
        else{
            ld('#folderlabel_zh').css('border-color','#ced4da');
        }
        if(folderlabel_en==''||folderlabel_en==undefined){
            ld('#folderlabel_en').css('border-color','red');
            ld('#folderlabel_en').addClass('input-warning');
            ld('#folderlabel_en').focus();
            return;
        }
        else{
            ld('#folderlabel_en').css('border-color','#ced4da');
        }
        var params = 'parent_id='+parent_id+'&folderlabel_zh='+folderlabel_zh+'&folderlabel_en='+folderlabel_en+'&description='+description+'&analysisfolder_id='+analysisfolder_id+'&mode=save';
        var url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=EditDir';
        ldAjaxNoProgress(url,params,function(res){
            popupobj.CancelEvent();
            if(res.result.savetype=='edit'){
                var trobj = Tools.getParentobjByChild(ld(obj),'tr');
                trobj.find('[tag=reportname]').text(folderlabel_zh);
                trobj.find('[tag=description]').text(description);
            }
            if(res.result.savetype=='create'){
                var parentid = parent_id;
                var trhtml = that.renderDir(99,res.result.folderinfo,parentid);
                that.reportlistbody.prepend(trhtml);
            }
            that.refreshClassNameAfterShow();
        });
    }
    //新建模板报表--报表库报表、include\js\modules\Customreport\Customreport.js
    this.createTemplateReport = function(parent_id){
        var url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=CreateReport&analysisfolder_id='+parent_id+'&folder_id=0&ajax=true&frommodule=ReportAnalysis';
        ldAjaxNoProgress(url,{},function(res){
            var module = 'ReportAnalysis';
            var Popupobj = CrmPopup.load( res.result.title, that.saveTemplateReport, "", "LdPopWidth600px", module, "", res.result.oktext, "", res.result.cancel);
            Popupobj.prevshow();
            Popupobj.center();
            Popupobj.setParams(res.result.title, that.saveTemplateReport, '', "LdPopWidth600px", module, [Popupobj,''], res.result.oktext, "", res.result.cancel);
            Popupobj.show(res.result.content);
            // 设置内容最大高度
            Popupobj.setPopBodyMaxHeight(".divPopOverflow");
            ScopePopup_Details.getInstance().allocateTemplate('',-5,-5,'','','createCustomreport');
            that.templateReportBind(Popupobj);//建立报表绑定事件
        });
    }
    //编辑模板报表--报表库报表、include\js\modules\Customreport\Customreport.js
    this.editTemplateReport = function(report_id){
        var url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=EditReport&report_id='+report_id+'&ajax=true&frommodule=ReportAnalysis';
        ldAjaxNoProgress(url,{},function(res){
            var module = 'ReportAnalysis';
            var Popupobj = CrmPopup.load( res.result.title, that.saveEditTemplateReport, "", "LdPopWidth600px", module, "", res.result.oktext, "", res.result.cancel);
            Popupobj.createScrollDiv();//创建滚动条
            Popupobj.prevshow();
            Popupobj.center();
            Popupobj.setParams(res.result.title, that.saveEditTemplateReport, '', "LdPopWidth600px", module, [Popupobj], res.result.oktext, "", res.result.cancel);
            Popupobj.show(res.result.content);
            Popupobj.setPopBodyMaxHeight(".divPopOverflow");
            that.templateReportBind(Popupobj);//建立报表绑定事件
        });
    }
    this.saveEditTemplateReport = function(Popupobj){
        var popobj = ld('#'+Popupobj.divid);
        var report_id = popobj.find('#report_id').val();
        var report_name = popobj.find('#edit_report_name').val();
        var report_describe = popobj.find('#edit_report_describe').val();
        var select_folder = popobj.find('#edit_select_folder').val();
        var edit_folder_id = popobj.find('#edit_folder_id').val();
        var setlinkmodule = popobj.find('#setlinkmodule').is(':checked');
        setlinkmodule = setlinkmodule==true?'on':'';
        var edit_report_url = '';
        var frommodule = popobj.find('#frommodule').val();//报表类型
        if(frommodule=='ReportAnalysis'){
            var analysisfolder_id = popobj.find('#analysisfolder_id').val();//报表类型
            if(analysisfolder_id == ''){
                var confirm_str = popobj.find('#analysisfolder_id').attr("tag") + arrJsPopLabel['CANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
            }
        }
        //报表名称
        if(report_name == ''){
            var confirm_str = popobj.find('#edit_report_name').attr("tag") + arrJsPopLabel['CANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            popobj.find('#edit_report_name').focus();
            return false;
        }
        if(popobj.find('#edit_report_url') != undefined && popobj.find('#edit_report_url').val() != undefined){
            edit_report_url = encodeURIComponent(popobj.find('#edit_report_url').val());
            if(edit_report_url == ''){
                var confirm_str = popobj.find('#edit_report_url').attr("tag") + arrJsPopLabel['CANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                popobj.find('#edit_report_url').focus();
                return false;
            }
        }
        if(popobj.find('#reportserveraddress') != undefined && popobj.find('#reportserveraddress').val() != undefined){
            edit_report_url = encodeURIComponent(popobj.find('#reportserveraddress').val());
            if(edit_report_url == ''){
                var confirm_str = popobj.find('#reportserveraddress').attr("tag") + arrJsPopLabel['CANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                popobj.find('#reportserveraddress').focus();
                return false;
            }
        }
        var reportfile = '';
        if(popobj.find('#reportfile') != undefined && popobj.find('#reportfile').val() != undefined){
            reportfile = encodeURIComponent(popobj.find('#reportfile').val());
            if(reportfile == ''){
                var confirm_str = popobj.find('#reportfile').attr("tag") + arrJsPopLabel['CANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                popobj.find('#reportfile').focus();
                return false;
            }
        }

        var databaselinktype= '';
        if(popobj.find("#databaselinktype").val()!=undefined) {
            databaselinktype = popobj.find("#databaselinktype").val();
        }
        var url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=EditReport&report_id='+report_id+'&report_name='+encodeURIComponent(report_name)+'&report_describe='+encodeURIComponent(report_describe)+'&select_folder='+select_folder+'&edit_report_url='+edit_report_url+'&ajax=true&report_save=yes';
        url+="&databaselinktype="+databaselinktype+'&setlinkmodule='+setlinkmodule+'&reportfile='+reportfile+'&analysisfolder_id='+analysisfolder_id+'&frommodule='+frommodule;
        ld('#rptContentLoading').show();
        ldAjax_File(url,{},function(json) {
            ld('#rptContentLoading').hide();
            that.updateReportHtmlInfo(json.result.reportinfo);//更新报表信息 报表名称等
            Popupobj.CancelEvent();
        });
    }
    this.saveTemplateReport = function(Popupobj,choice){
        var popobj = ld('#'+Popupobj.divid);
        var report_name = popobj.find('#report_name').val();//报表名称
        var report_type = popobj.find('#report_type').val();//报表类型

        ScopePopup_Details.getInstance().saveAction_before();
        var folder_id = popobj.find('#folder_id').val();//文件夹id
        //报表名称
        if(report_name == ''){
            var confirm_str = popobj.find('#report_name').attr("tag") + arrJsPopLabel['CANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            popobj.find('#report_name').focus();
            return false;
        }
        //报表名称长度
        if(report_name.length >= 100){
            var confirm_str = popobj.find('#report_name').attr("tag") + arrJsPopLabel['CANNOTEXCEED'] + '100'+arrJsPopLabel['AWORD'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            popobj.find('#report_name').focus();
            return false;
        }
        //报表类型
        if(report_type == ''){
            var confirm_str = popobj.find('#report_type').attr("tag") + arrJsPopLabel['CANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
        //如果报表类型为链接地址，则判断判断地址是否为空
        if(report_type == 'url'){
            var report_url = popobj.find('#report_url').val();
            if(report_url == ''){
                var confirm_str = popobj.find('#report_url').attr("tag")+arrJsPopLabel['CANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                popobj.find('#report_url').focus();
                return false;
            }
        }
        //如果报表类型为帆软报表，则判断判断报表文件、报表服务器地址是否为空
        if(report_type == 'finereport'){
            var reportfile = popobj.find('#reportfile').val();
            var reportserveraddress = popobj.find('#reportserveraddress').val();
            if(reportfile == ''){
                var confirm_str = popobj.find('#reportfile').attr("tag")+arrJsPopLabel['CANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                popobj.find('#reportfile').focus();
                return false;
            }
            if(reportserveraddress == ''){
                var confirm_str = popobj.find('#reportserveraddress').attr("tag")+arrJsPopLabel['CANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                popobj.find('#reportserveraddress').focus();
                return false;
            }
        }
        if(!ScopePopup_Details.getInstance().validate(null)) {
            return false;
        }

        var data = new FormData(popobj.find(".ajax_form")[0]);
        var surl = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=CreateReport&report_save=report_save&choice=' + choice;

        var frommodule = popobj.find('#frommodule').val();//报表类型
        surl += '&frommodule='+frommodule;
        if(frommodule=='ReportAnalysis'){
            var analysisfolder_id = popobj.find('#analysisfolder_id').val();//报表类型
            if(analysisfolder_id == ''){
                var confirm_str = popobj.find('#analysisfolder_id').attr("tag") + arrJsPopLabel['CANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
            }
        }
        ld('#rptContentLoading').show();
        ldAjax_File(surl,data,function(json){
            ld('#rptContentLoading').hide();
            if(json.code == 1){
                Popupobj.CancelEvent();
                //获取所属文件夹是否是开启的
                var parentDisplay = ld('#'+that.divid).find('tr[module=ReportAnalysis][data-id='+analysisfolder_id+']').css('display');
                if(parentDisplay!='none'){
                    that.getReportList(0,'init');
                }

            }
            else if (json.code == -2) {
                //提示框样式
                json.msg += arrJsPopLabel['CREATREPORTTEXT1']
                    + '<div class="ld-msgDlg-bottom-Boxtext linefeed" style="font-size:13px;padding-left: 0px; color: rgb(153,153,153);line-height: 16px"> '
                    + arrJsPopLabel['CREATREPORTTEXT2']
                    + '</div>';
                RemindsMsg("", "LdPopWidth400px", "", arrJsPopLabel['CONTINUE'], arrJsPopLabel['SAVE'], json.msg);
                var tempopupobj = CrmPopup.getPopupObj('last');
                //当数据库或者文件夹内已有报表源文件名称时，根据不同的选择传入不同的参数
                ld('#' + tempopupobj.divid + "_btnok").on('click', function () {
                    that.saveTemplateReport(Popupobj,'CONTINUE');
                });
                ld('#' + tempopupobj.divid + "_btncancel").on('click', function () {
                    that.saveTemplateReport(Popupobj,'SAVE');
                });
            }
            else {
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", json.msg);
            }
        });
    }
    this.templateReportBind = function(Popupobj){
        ld('#'+Popupobj.divid).find("#report_type").unbind("change").bind("change",function(){
            var popobj = ld('#'+Popupobj.divid);
            //报表类型
            if(ld(this).val()=='template') {
                popobj.find("#tr_DataBaseLink").css("display","");
                popobj.find("#tr_templatereport").css("display","");
                popobj.find("#tr_Reportfile").css("display","none");
                popobj.find("#tr_Reportserveraddress").css("display","none");
            }
            else if(ld(this).val()=='finereport') {
                popobj.find("#tr_DataBaseLink").css("display","none");
                popobj.find("#tr_templatereport").css("display","none");
                popobj.find("#tr_Reportfile").css("display","");
                popobj.find("#tr_Reportserveraddress").css("display","");
            }
            else {
                popobj.find("#tr_templatereport").css("display","");
                popobj.find("#tr_DataBaseLink").css("display","none");
                popobj.find("#tr_Reportfile").css("display","none");
                popobj.find("#tr_Reportserveraddress").css("display","none");
            }
        })
        //模板类型
        ld('#'+Popupobj.divid).find('#report_type').on('change',function(){
            var popobj = ld('#'+Popupobj.divid);
            var report_type = popobj.find('#report_type').val();
            if(report_type == 'template'){
                popobj.find('#template_div').show();
                popobj.find('#url_div').hide();
            }
            else if(report_type == 'url'){
                popobj.find('#template_div').hide();
                popobj.find('#url_div').show();
                popobj.find('#report_url').focus();
            }
        });
    }
    //文件夹排序 dir 文件夹排序 report报表文件排序
    this.sortReport = function(parent_id){
        var url = 'module=ReportAnalysis&action=ReportAnalysisAjax&file=ListView&function_name=sortReport&ajax=true&parent_id='+parent_id;
        ldAjax('index.php?',url,function (data) {
            if (data.code == 1){
                DelProgressObjs();
                var popupobj = CrmPopup.load(data.result.title,'','','LdPopWidth400px','ReportAnalysis','',data.result.oktext,'',data.result.canceltext);
                popupobj.show(data.result.content);
                getJsScript('include/js/DragTransfer.js',function(){
                    var tableobj = ld('#'+popupobj.divid).find("select#select_folder").parents("table");
                    var RightObj = tableobj.find("select#select_folder");
                    var Drag_Transfer = new DragTransfer();
                    var translabel = {
                        available: '',
                        selected: '',
                        placeholder: arrJsPopLabel['PleaseEnterColumnSearchFor'],
                    };
                    Drag_Transfer.SetTranslabel(translabel);
                    Drag_Transfer.SetDragTransfer(tableobj,"",RightObj,'reset','320');
                    tableobj.find('.ld-selectAll').empty();//BUG20240924-52
                });
                that.report_sort_btn(parent_id);
            }
        });
    }
    //文件夹排序提交的ajax请求
    this.report_sort_btn = function(parent_id){
        var popupobj = CrmPopup.getPopupObj('last');
        var divobj = ld('#'+popupobj.divid);
        ld('#'+popupobj.divid+'_btnok').unbind('click').bind('click',function(){
            var selectedFieldStr = "";
            if(ld('#select_folder')!=undefined){
                var selectedColumnsObj=divobj.find('#select_folder');
                for (var i=0;i<selectedColumnsObj.get(0).options.length;i++){
                    selectedFieldStr += selectedColumnsObj.get(0).options[i].value + ";";
                }
            }
            if(selectedFieldStr != ''){
                var url = 'module=ReportAnalysis&action=ReportAnalysisAjax&file=ListView&function_name=saveSortFolder&folderid_str='+encodeURIComponent(selectedFieldStr)+'&ajax=true';
                ldAjax('index.php?',url,function (data) {
                    if (data.code == 1){
                        popupobj.CancelEvent();
                        var trobj = ld('#'+that.divid).find('tr[module=ReportAnalysis][data-id='+parent_id+']');
                        trobj.find('.report-name').trigger('click');
                        DelProgressObjs();
                    }
                })
            }
        });
    }
    this.showEchartDetail = function(report_id,report_type){
        var tmpwidth = ld(window).width();//全屏宽度
        var module = 'CustomEcharts';
        var Popupobj = CrmPopup.load("", "", "", tmpwidth, module, "", "", "", "");
        Popupobj.report_id = report_id;
        Popupobj.isShowDetail = 'yes';
        Popupobj.report_type = report_type;
        Popupobj.createScrollDiv();//创建滚动条
        Popupobj.prevshow();
        var file = report_type=='sqlchart'?'SqlEchartsDetailView':'SelfDefinedReport';
        var url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file='+file+'&function_name=getChart&report_id=' + report_id;
        //自定义统计表打开详情弹框不要底部按钮
        Popupobj.createBottomHtml = function(){
            this.popupbottomhtml = '';
        }
        ldAjax(url,'',function (data) {
            if (data.code == 1) {
                Popupobj.permit_createview = data.result.permit_create;//编辑、新增权限
                Popupobj.permit_editview = data.result.permit_edit;//编辑权限
                Popupobj.setParams(data.result.title, '', '', tmpwidth, module, "", arrJsPopLabel['SAVE'], "", arrJsPopLabel['LBL_CLOSE']);
                CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj, data.result.content);
                Popupobj.center();
                CrmPopup.fullScreen(ld("#" + Popupobj.divid), Popupobj);
            }
            //edit: xll 2023/10/19 BUG0074218 在报表详情显示后再更新报表列表界面
            that.RecordLastViewRecord(report_id,'CustomEcharts');
        });
    }

    this.showTableDetail = function(report_id,report_type){
        if(report_type=='sql'){
            getJsScript('include/js/modules/CustomTables/CustomTablesSqlDetail.js',function() {
                CustomTablesSqlDetail.showTableDetail(report_id);
            });
        }
        else{
            getJsScript('include/js/modules/CustomTables/CustomTablesDetail.js',function() {
                CustomTablesDetail.showTableDetail(report_id);
            });
        }
        that.RecordLastViewRecord(report_id,'CustomTables');
    }

    //统计图移动分类
    this.moveDir = function(report_id,report_name,parent_id,modulename) {
        var module = 'ReportAnalysis';
        var Popupobj = CrmPopup.load( arrJsPopLabel['MOVE']+arrJsPopLabel['FOLDER'], that.submitMoveDir, "", "LdPopWidth600px", module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
        Popupobj.createScrollDiv();//创建滚动条
        Popupobj.prevshow();
        Popupobj.center();
        var url = "index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=ListView";
        var param = "is_ajax=yes&function_name=getAllFolder&analysisfolder_id="+parent_id;
        ldAjaxNoProgress(url,param,function(res) {
            var options = res.result.options;
            var confirm_str = '<div class="ld-public-content-small" id="moveDirContent">\n' +
                '    <div class="ld-form-item-div">\n' +
                '        <div class="ld-form-item-label">'+arrJsPopLabel['ReportName']+'</div>\n' +
                '        <div class="ld-form-item-content">' +
                '           <input id="report_id" type="hidden" value="'+report_id+'" name="report_id">\n' +
                '           <input id="modulename" type="hidden" name="modulename" readonly value="'+modulename+'">\n' +
                '           <input id="report_name" class="ld-input-inner" name="report_name" readonly value="'+report_name+'">\n' +
                '        </div>\n' +
                '    </div>\n' +
                '    <div class="ld-form-item-div">\n' +
                '        <div class="ld-form-item-label">'+arrJsPopLabel['SELECTFOLDERS']+'</div>\n' +
                '        <div class="ld-form-item-content">' +
                '           <select id="analysisfolder_id" class="ld-select-inner">'+options+'</select>' +
                '        </div>\n' +
                '    </div>\n' +
                '</div>';
            Popupobj.setParams(arrJsPopLabel['MOVE']+arrJsPopLabel['FOLDER'], that.submitMoveDir, '', "LdPopWidth600px", module, "", arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
            Popupobj.show(confirm_str);
            ld('#'+Popupobj.divid).find('#parent_id').select2({width:'100%',closeOnSelect: true});
        });
    }
    //统计图移动分类ajax请求
    this.submitMoveDir = function(){
        var popupobj = CrmPopup.getPopupObj('last');
        var report_name = ld('#'+popupobj.divid+' #report_name').val();
        var report_id = ld('#'+popupobj.divid+' #report_id').val();
        var analysisfolder_id = ld('#'+popupobj.divid+' #analysisfolder_id').val();
        var modulename = ld('#'+popupobj.divid+' #modulename').val();
        var params = '&is_ajax=yes&step=0&analysisfolder_id='+analysisfolder_id+'&report_name='+report_name+'&report_id='+report_id+'&modulename='+modulename;
        var url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=ListView&function_name=moveDir';
        ldAjaxNoProgress(url,params,function(res){
            var popupobj = CrmPopup.getPopupObj('last');
            ld("#" + popupobj.divid).remove();
            ld('#'+popupobj.divid+'_olayernodeid').remove();
            that.getReportList(0,'init');
        });
    }
    //wyt 221129 XUQIU1000911 报表分析，增加“最近浏览”文件夹
    //点击报表，最近浏览报表顺序更新
    this.RecordLastViewRecord = function(reportid,modulename,type){
        var url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=ListView&function_name=LastViewRecord';
        var params = '&reportid='+reportid+'&modulename='+modulename;
        that.curReportModule = modulename;
        that.curReportId = reportid;
        //当前行显示选中态
        ld('#'+that.divid+' [tag=reportList_screen]').find('tr').removeClass('lvtColDataHover').addClass('lvtColData');
        ld('#'+that.divid+' [tag=reportList_screen]').find('tr[module='+that.curReportModule+'][data-id='+that.curReportId+']').addClass('lvtColDataHover').removeClass('lvtColData');
        ldAjaxNoProgress(url,params,function(res) {
            if (res.code == 1) {
                var tbody_recentview=that.tbody_recentview;
                if(tbody_recentview.length>0) {
                    var LastReviewRecord = parseInt(ld('#LastReviewRecord').val());
                    if (LastReviewRecord == 0) {
                        ld('#LastReview').show();
                    }
                    ld('#LastReviewRecord').val(LastReviewRecord + 1);
                    that.getRecentView(function(){});
                }
            }
        }
    )}
    //点击最近浏览文件夹
    this.showRecentReport = function(obj,res){
        //var parenttr = ld(obj).parents('tr');
        var parenttr =  Tools.getParentobjByChild(ld(obj),'tr');
        var status = ld(parenttr).attr('data-status');
        if(status=='close') {
            ld(parenttr).attr('data-status','open');
            ld(obj).find('.report-close').removeClass('report-close').addClass('report-open');
            ld(obj).find('div[tag=folder-img] img').attr('src',that.folderimg);
            that.getReportChildData('-1',parenttr,'after');
        }
        else{
            ld(parenttr).attr('data-status','close');
            ld(obj).find('.report-open').removeClass('report-open').addClass('report-close');
            ld(obj).find('div[tag=folder-img] img').attr('src','themes/softed/images/icon-folder-close.png');
            ld('tr[recent-view=yes]').remove();
            that.refreshClassNameAfterShow();
        }
    }
    //取消显示报表
    this.canceldisplayReport = function(report_id,obj,modulename){
        var url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=ListView&function_name=CancelDisplayReport';
        var params = '&reportid='+report_id+'&modulename='+modulename;
        ldAjaxNoProgress(url,params,function(res){
            if(res.code==1){
                ld('tr[data-id='+report_id+'][module='+modulename+']').remove();
                var LastReviewRecord=parseInt(ld('#LastReviewRecord').val());
                if(LastReviewRecord==1){
                    ld("#LastReview").css('display', 'none');
                }
                ld('#LastReviewRecord').val(LastReviewRecord-1);
            }
        });
    }
    this.updateReportList = function (list) {
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
        var icon_class="icon-table";
        if(modulename=='CustomEcharts'){
            icon_class="icon-chart";
        }
        var popupJqObj = ld('#'+that.divid),
            trJqObj = popupJqObj.find('tr[module='+modulename+'][data-id='+report_id+']');
        if(item.show=='no'){
            trJqObj.remove();
            return ;
        }
        trJqObj.find('.report-name-link').html('<b class="'+icon_class+' marR5 marT-2"></b>'+item.report_name);
        trJqObj.find('[tag=description]').text(item.description);
        trJqObj.find('[tag=allocates]').text(item.allocates);
        //更新按钮
        var btnhtml = '';
        ld.each(item.btnarr['list'],function(i,btnname){
            btnhtml += that.getButtonHtml(btnname,item);
        });
        trJqObj.find('[tag=btns]').html(btnhtml);
        // 文件夹查看范围批量修改
        if(modulename === 'ReportAnalysis') {
            let nextTrObj = trJqObj.next(),
                folderId = trJqObj.data('id');
            while(1) {
                if(nextTrObj.length === 0 || nextTrObj.data('parent') !== folderId)
                    break;
                nextTrObj.find('[tag=allocates]').text(item.allocates);
                nextTrObj = nextTrObj.next();
            }
        }
    }

    //@edit:zhaosk @date:2024/08/12 @reason:BUG20240808-54 报表分析模块加入隔行换色
    //在DOM元素生成后隔行换色
    this.refreshClassNameAfterShow=function(){
        if(that.listtype=='list'){
            var reportlistbody = ld('#'+that.divid).find('[tag=reportList_'+that.listtype+']');
            var lastReviewbody = ld('#'+that.divid).find('[tag=LastReview]');
            var i=0;
            var lastReviewLineObj=ld(lastReviewbody).find('tr');
            var reportListLineObj=ld(reportlistbody).find('tr');
            ld.each(lastReviewLineObj,function(index,item){
                if(i%2===1){
                    ld(item).removeClass('lvtColData').addClass('lvtColDataBj');
                }
                else{
                    ld(item).removeClass('lvtColDataBj').addClass('lvtColData');
                }
                i++;
            })
            ld.each(reportListLineObj,function(index,item){
                if(i%2===1){
                    ld(item).removeClass('lvtColData').addClass('lvtColDataBj');
                }
                else{
                    ld(item).removeClass('lvtColDataBj').addClass('lvtColData');
                }
                i++;
            })
        }
    }
}


ReportAnalysis.setMutationObserver = function(){
    //监听右侧内容宽度变化
    let MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
    let main_content_obj = ld('section.main-content').get(0);
    let observer = new MutationObserver((mutationList) => {
        setTimeout(function(){
            ReportAnalysis.reportanalysis_setListtype(reportanalysis_listtype);
        },300);
    })
    observer.observe(main_content_obj, { attributes: true, attributeFilter: ['style'], attributeOldValue: true })
}
//设置视图类型
ReportAnalysis.reportanalysis_setListtype =function(listtype){
    if(listtype=='screen'){
        ReportAnalysisObj = new ReportAnalysisScreen();
    }
    else{
        ReportAnalysisObj = new ReportAnalysisList();
    }
    ReportAnalysisObj.init();
    ReportAnalysisObj.getReportList(0,'init');
    //保存当前视图类型
    var url = "index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=ListView";
    var param = "is_ajax=yes&function_name=setShowType&save_type=ReportAnalysis_listtype&save_value=" + listtype;
    ldAjaxNoProgress(url, param, function (res) {
        ld('.customtable').hide();
        ld('#reportanalysis_'+listtype).show();
        ld('#reportanalysis_'+listtype+' #reportanalysis_tablecontent').scrollLeft(0);
        ld('#ld_reportanalysis_search_'+listtype).focus();
        ReportAnalysisObj.setScroll();
    });
}
ReportAnalysis.refreshReportName = function (report_id,report_name) {
    //需要判断下当前是分屏模式还是列表模式
    var listtype = reportanalysis_listtype;
    var lastTrList = ld('#reportanalysis_'+listtype+' [tag=LastReview]').find('tr'),trList = ld('#reportanalysis_'+listtype+' [tag=reportList_list]').find('tr'),
        lastLinkObj = lastTrList.filter('[data-id='+report_id+']').find('.report-name-link'),linkObj = trList.filter('[data-id='+report_id+']').find('.report-name-link');
    if(lastLinkObj.length > 0){
        lastLinkObj.html(lastLinkObj.children().get(0).outerHTML + report_name);
    }
    if(linkObj.length > 0){
        linkObj.html(linkObj.children().get(0).outerHTML + report_name);
    }
    if(listtype=='screen'){
        ld('#screen_reportname').text(report_name);
    }
}

//edit: xll 2024/02/23 标签间的通信，用于左侧菜单打开新页签（报表设为链接模块）
ReportAnalysis.getChannel = function () {
    // 创建一个广播通道并进行监听
    var channel = new BroadcastChannel('openNewTab_ReportAnalysis');
    var ReportAnalysisObj = new ReportAnalysis();
    ReportAnalysisObj.init();
    // 监听消息事件
    channel.onmessage = function(event) {
        var message = event.data,
            module = message.module,
            report_id = message.report_id,
            report_type = message.report_type;
        if(typeof ReportAnalysis.channelCallBack[module] === "function"){
            ReportAnalysis.channelCallBack[module](report_id,report_type);
        }
    };
    //发送ready，即channel监听已创建
    channel.postMessage('ready');
    ReportAnalysisObj.channel = channel
}
ReportAnalysis.getChannel();
ReportAnalysis.channelCallBack = {
    CustomEcharts : function (report_id,report_type) {
        var ReportAnalysisObj = new ReportAnalysis();
        ReportAnalysisObj.init();
        ReportAnalysisObj.showEchartDetail(report_id,report_type);
    },
    CustomTables : function (report_id,report_type) {
        var ReportAnalysisObj = new ReportAnalysis();
        ReportAnalysisObj.init();
        if(!empty(report_type)){
            ReportAnalysisObj.init();
            ReportAnalysisObj.showTableDetail(report_id,report_type);
        }else{
            //老的链接 不带report_type 需要去查询一下
            var url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=CustomTablesListView&function_name=getReportType&report_id='+report_id;

            //zkt 20231013 XUQIU1001341 SQL注入
            ldAjaxNoProgress(url,'',function (data) {
                getJsScript('include/js/modules/ReportAnalysis/ReportAnalysis.js', function () {
                    ReportAnalysisObj.init();
                    ReportAnalysisObj.showTableDetail(report_id,data.result.report_type);
                });
            });
        }
    }
}

AjaxJSPage("ReportAnalysisScreen_js", 'include/js/modules/ReportAnalysis/ReportAnalysisScreen.js');
AjaxJSPage("ReportAnalysisList_js", 'include/js/modules/ReportAnalysis/ReportAnalysisList.js');