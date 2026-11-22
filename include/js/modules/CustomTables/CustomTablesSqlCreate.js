if(ld==undefined){
    var ld = $;
}
function CustomTablesSqlCreate(){
    this.popupobj = "";
    this.divid = "";
    this.report_id = 0;
    var that = this;
    this.pagerows=0;//总页数
    this.pagestart=1;//页码 第一页
    this.maxpagecount=0;//最大的页码
    this.report_type='sql';
    this.chartInfo='';
    this.reportDetailBodyObj;//表体 对象
    this.reportDetailHeaderObj;//表体 对象
    this.pageto_module = 'ReportAnalysis';
    this.init = function(mode){

        //表体 对象
        that.reportDetailBodyObj = ld('#'+that.divid).find('[tag=reportDetailBody]');
        that.reportDetailHeaderObj = ld('#'+that.divid).find('[tag=reportDetailHeader]');
        //设置事件
        that.setEvent(mode);
        that.mode = mode;
        that.renderSqlReportTable();
    }
    this.setPopupobj = function(popupobj){
        that.popupobj = popupobj;
    }
    this.setDivid = function(divid){
        that.divid = divid;
    }
    this.setReportId = function(report_id){
        that.report_id = report_id;
    }
    //新建SQL报表
    this.createTableSql = function(report_id,frompage,parent_id ){
        var tmpwidth = ld(window).width();//全屏宽度
        var module = 'CustomTables';
        var Popupobj = CrmPopup.load('',  that.saveReportInfo,"", tmpwidth, module, "", arrJsPopLabel['SAVE'], "", arrJsPopLabel['CANCEL']);
        Popupobj.prevshow();
        that.pagemode='create_edit';
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlTableEditView&function_name=index&report_id="+report_id+"&report_type="+that.report_type+"&frommodule="+that.frommodule;
        if(parent_id!=undefined){
            url += '&parent_id='+parent_id;
        }
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxNoProgress(url,'',function (data) {
            Popupobj.permit_print = data.result.permit_print;//打印权限
            Popupobj.permit_export = data.result.permit_export;//导出权限
            Popupobj.permit_create = data.result.permit_create;//编辑、新增权限
            Popupobj.setHeadTitle(data.result.title);
            CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj,data.result.content);
            var mode = "create";
            if(report_id>0){
                mode  = "edit";
            }
            ld('#'+Popupobj.divid+' #report_name').focus();//打开新增编辑页面 光标定在报表名称处
            that.setPopupobj(Popupobj);
            that.setDivid(Popupobj.divid);
            that.setReportId(report_id);
            that.init(mode);
            that.frompage = frompage;
            Popupobj.setEvent();
            CrmPopup.fullScreen(ld("#" + Popupobj.divid), Popupobj);
            ld('#'+Popupobj.divid).find('#analysisfolder_id').select2({width:'100%',closeOnSelect: true});
        });
    }
    //设置事件
    this.setEvent = function(mode){
        var that=this;
        //标签切换事件
        ld('#'+that.divid).find('.change_tab').unbind('click').bind('click',function(){
            that.changeTab(ld(this));
        });
        //zxm 20220822 sql编辑事件 editsql
        ld('#'+that.divid).find('[tag=editsql]').unbind('click').bind('click',function(event){
            //阻止事件冒泡
            event.stopPropagation();
            var sqlvalue = ld('#'+that.divid).find('#sqlstr').text();

            var tmpwidth = "LdPopWidth800px";
            var module = 'CustomTables';
            var Popupobj = CrmPopup.load( arrJsPopLabel['EDIT']+"SQL", that.sqlparse, "", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
            Popupobj.createScrollDiv();//创建滚动条
            Popupobj.prevshow();
            var tmpheight = Popupobj.getPopContentHeight() - 135;//全屏宽度
            var html = '<table width="100%" border="0" cellspacing="0" cellpadding="0" align="left" id="editsql_box" class="">' +
                '      <tbody>';
            html += '<tr><td class="ld-form-item-content" style="padding:0;">' +
                // '     <textarea class="ld-textarea-inner" style="overflow: auto; overflow-wrap: break-word; resize: horizontal; height: '+tmpheight+'px;" id="sqlstr_temp">'+sqlvalue+'</textarea>' +
                '     <div id="sqlstr_temp" class="ace_editor" style="min-height:470px"><textarea class="ace_text-input">'+sqlvalue+'</textarea></div>' +
                '      </td></tr><tr><td class="ld-form-item-content" style="padding: 14px 0 0 0;">' +
                '      <span style="line-height:20px;height:20px;display:block">' +
                '     1.'+arrJsPopLabel['SQLtablecreatetip1']+'</span>' +
                '      <span style="line-height:20px;height:20px;display:block">2.'+arrJsPopLabel['SQLtablecreatetip2']+'</span>' +
                '      <span style="line-height:20px;height:20px;display:block">3.'+arrJsPopLabel['SQLtablecreatetip4']+'</span>' +
                '      <span style="line-height:20px;height:20px;display:block">4.'+arrJsPopLabel['SQLtablecreatetip3']+'</span>' +

                '</td>' +
                '</tr></tbody></table>';
            Popupobj.setParams( arrJsPopLabel['EDIT']+"SQL", that.sqlparse, '', tmpwidth, module, "", arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
            Popupobj.show(html);
            //代码样式
            that.sqlEditor = AceInitSqlEditor("sqlstr_temp");

            ld('#'+Popupobj.divid + ' .dvpopupsroll').css('padding', '20px 24px');
            // 需要去掉的给高度
            Popupobj.reduceBodyHeight = 0;
            // 设置内容最大高度
            Popupobj.setPopBodyMaxHeight(".dvpopupsroll");

            Popupobj.center();
        });
        that.setSqlColumnsEvent();

        //新变量 newvariable
        ld('#'+that.divid).find('[tag=newvariable]').unbind('click').bind('click',function(event){
            //阻止事件冒泡
            event.stopPropagation();
            that.editVariable(this);
        });
        that.setVariableEvent();//变量事件

        //多选条件的样式 select2
        ld('#'+that.divid).find('.sqlvar-detail-selectmulti ').select2({width:'100%',closeOnSelect: true});
        //每页条数 改变事件
        ld('#'+that.divid).find('#limitrecord').unbind('change').bind('change',function(){
            that.reportDetailBodyObj.empty();
            ld("#"+that.divid+" [name=pagenum]").val(1);
            that.renderSqlReportTable();
        });
        //页码改变事件
        ld('#'+that.divid).find('#changePageCount').unbind('change').bind('change',function() {
            that.changePageCount();
        });

        ld('#'+that.divid).find('#changePageCount').unbind('keyup').bind('keyup',function(e) {
            var e = event || window.event;
            if(e.keyCode == 13) {// Enter 回车键
                that.changePageCount();
            }
        });
    }
    //变量事件
    this.setVariableEvent = function(){
        //编辑变量
        ld('#'+that.divid).find('[tag=variableedit]').unbind('click').bind('click',function(){
            that.editVariable(this);
        });
        //变量排序事件
        ld('#'+that.divid).find('[tag=variableup]').unbind('click').bind('click',function(){
            that.variableup(this);
        });
        ld('#'+that.divid).find('[tag=variabledown]').unbind('click').bind('click',function(){
            that.variabledown(this);
        });
        //变量删除事件
        ld('#'+that.divid).find('[tag=variabledelete]').unbind('click').bind('click',function(){
            that.variabledelete(this);
        });
    }
    //字段事件
    this.setSqlColumnsEvent = function(){
        //字段编辑事件 editSqlColumns
        ld('#'+that.divid).find('[tag=editSqlColumns]').unbind('click').bind('click',function(){
            that.editSqlColumns(this);
        });
        //字段选中事件   fieldlists_check
        ld('#'+that.divid).find('[tag=fieldlists_check]').unbind('change').bind('change',function(){
            that.fieldlists_check_change(this);
        });
    }
    //tab切换事件
    this.changeTab = function(obj){
        var report_name = ld('#'+that.divid+' #report_name').val();
        var report_id = ld('#'+that.divid+' #report_id').val();
        var fortab = ld(obj).attr('for');
        if(fortab=="tableSet"&&report_name==''){
            CustomTablesObj.connotempty('报表名称',ld('#'+that.divid).find('#report_name'));
            return;
        }
        //判断是否选择文件夹
        var parent_id = ld('#'+that.divid).find('#parent_id').val();
        if(parent_id==''){
            alert(arrJsPopLabel['SelectFolder']);
            return false;
        }
        //tab显示隐藏
        ld(obj).siblings().removeClass('ld-ui-tabs-active');
        ld(obj).addClass('ld-ui-tabs-active');
        ld('#'+that.divid).find('.tab-contents').hide();
        ld('#'+that.divid).find('#'+fortab).show();
        that.saveReportInfo("no");
    }
    this.changePageCount=function()
    {
        //BUG0065024 zxm20230420 报表分析，点击自定义报表，SQL报表，当输入要跳转页数，大于总页数时，会跳转到一个空值界面（应该跳转到最后一页）
        var pagenum = ld("#"+that.divid+" [name='pagenum']").val();//第几页
        if(pagenum>=that.totalpages){
            ld("#"+that.divid+" [name='pagenum']").val(that.totalpages);
        }
        //分页
        that.reportDetailBodyObj.empty();
        that.renderSqlReportTable();
    }
    //XUQIU1000530	统计表 自定义统计表-支持SQL语句  SQL运行
    this.renderSqlReportTable = function(){
        ld('#rptContentLoading').show();
        var divid = that.divid;
        var report_id = ld('#'+divid).find('#report_id').val();
        var chartInfoForm = ld('#'+divid).find('#chartInfoForm').serialize();//页面上所有的字段值
        var params = '&report_id='+report_id;
        params += '&'+chartInfoForm;
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlTableDetailView&function_name=getSqlDetailData";
        if(typeof frommobile!='undefined' && frommobile=='yes'){
            params += '&frommobile='+frommobile;
        }
        var pagenum = 1;
        var limitrecord = ld("#"+divid+ " [name=limitrecord]").val();//每页限制条数
        pagenum = ld("#"+divid+" [name='pagenum']").val();//第几页
        that.maxpagecount = Math.ceil(that.pagerows/limitrecord) ;
        url+="&limitrecord="+limitrecord;
        if(that.pagerows>0&&parseInt(pagenum)>that.maxpagecount)
        {
            ld('#rptContentLoading').hide();
            return ;
        }
        url+="&pagenum="+pagenum;
        url+='&totalrows='+that.pagerows;
        url+='&pagemode='+that.mode;
        ldAjaxNoProgress(url,params,function(ajaxdata){
            if(ajaxdata.code==1){
                var content = ajaxdata.result.content;
                that.reportDetailBodyObj.empty().html(content);
                that.setPageStyle(ajaxdata.result,pagenum);//分页样式
                var columnsArr = ajaxdata.result.columnsArr;
                CustomTablesSqlColumnsObj.init(that.mode,that);//初始化字段表格
                CustomTablesSqlColumnsObj.setSorSqltable();
                that.th_width = CustomTablesSqlColumnsObj.renderHeader(columnsArr);
                that.setScroll(that.th_width,215);//设置滚动条
                //表头拖动
                ld('#' + that.divid + " #thResizable").resizableColumns('thResizable', that.report_id,that);
                //列固定
                freezecolumnsObj.init('thResizable');//冻结列类初始化
                var width = freezecolumnsObj.freezeThColumnBeforeAll('set-sticky');
                freezecolumnsObj.freezeTdColumnBeforeAll('set-sticky',width);
                ld('#'+that.divid).find('.customtable-droplist').css('z-index','9999')
            }else{
                that.setScroll(0,130);
            }
            ld('#rptContentLoading').hide();
        });
    }
    //设置分页样式
    this.setPageStyle = function(data,pagenum){
        that.pagerows=data.pagerows;//总条数
        that.totalpages=data.totalpages;//总页数
        ld("#"+that.divid+' [name=totaldescription]').html(data.totaldescription);
        ld("#"+that.divid+' #pageoftotalpages').html(pagenum + '/' + data.totalpages);
        that.pagestart++;
        if(pagenum<=1){
            ld('#'+that.divid+' #goleft').removeClass('icon-prevpage').addClass('no-icon-prevpage').attr('title','').unbind('click');
        }else{
            ld('#'+that.divid+' #goleft')
                .removeClass('no-icon-prevpage')
                .addClass('icon-prevpage')
                .attr('title','上一页')
                .unbind('click')
                .bind('click',function(){
                    ld("#"+that.divid+' #changePageCount').val(pagenum-1);
                    that.changePageCount();
                });
        }
        if(pagenum>=data.totalpages){
            ld('#'+that.divid+' #goright').removeClass('icon-nextpage').addClass('no-icon-nextpage').attr('title','').unbind('click');
        }else{
            ld('#'+that.divid+' #goright')
                .removeClass('no-icon-nextpage')
                .addClass('icon-nextpage')
                .attr('title','下一页')
                .unbind('click')
                .bind('click',function(){
                    ld("#"+that.divid+' #changePageCount').val(parseInt(pagenum)+1);
                    that.changePageCount();
                });
        }
    }

    this.sqlparse = function(){
        ld('#rptContentLoading').show();
        var popobj = CrmPopup.getPopupObj("last");
        //var sqlstr_origin =  ld('#'+popobj.divid).find('#sqlstr_temp').val();
        var sqlstr_origin =  that.sqlEditor.getValue();
        
        //zxm 丁程宣的edge浏览器会阻断sql传输  base64加密去掉
        var sqlstr=cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(sqlstr_origin,false,[]);
        sqlstr = encodeURIComponent(sqlstr);
        var report_id = ld('#'+that.divid).find('#report_id').val();
        var report_name = ld('#'+that.divid).find('#report_name').val();
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlTableEditView";
       
        var param = "is_ajax=yes&function_name=parserSql&report_id="+report_id+"&sqlstr="+sqlstr+"&report_name="+report_name;
        ldAjaxNoProgress(url,param,function(res) {
            if(res.code==1){
                var html = '';
                var columnsarr = res.result.columnsarr;
                ld.each(columnsarr,function(index,column){
                    var checked = '';
                    if(column.visibile=='yes'){
                        checked = 'checked';
                    }
                    html += ' <li style="display: flex;justify-content: space-between;border-bottom: #fff;">'+
                    '<span class="user" tag="fieldline'+index+'">'+
                    '<label>'+
                    '<input '+checked+' class="second_switch" type="checkbox" columnid="'+column.id+'" name="fieldlists[]" tag="fieldlists_check">'+column.columns+''+
                    '<span>['+column.tdheader_label+']</span>'+
                    '</label>'+
                    '</span><span><a class="Anu3_a">'+
                    '<i class="ld-fonticon ld-fonticon-edit" tag="editSqlColumns" columnid="'+column.id+'"></i>'+
                    '</a>'+
                    '</span>'+
                    '</li>';
                });
                popobj.CancelEvent();
                ld('#'+that.divid).find('[tag=fieldlists]').html(html);
                ld('#'+that.divid).find('#sqlstr').text(sqlstr_origin);
                //事件
                that.setSqlColumnsEvent();//字段编辑事件
                that.renderSqlReportTable();
            }else{
                RemindsMsg("","LdPopWidth400px","","yes","yes",res.msg);
            }
            ld('#rptContentLoading').hide();
        });
    };
    //XUQIU1000530	统计表 自定义统计表-支持SQL语句  SQL运行 字段编辑事件
    this.editSqlColumns = function(editObj){
        var columnid = ld(editObj).attr('columnid');
        var report_id = that.report_id;
        var tmpwidth = "600px";
        var module = 'CustomTables';
        var Popupobj = CrmPopup.load('', that.saveSqlColumns, "", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
        Popupobj.createScrollDiv();//创建滚动条
        Popupobj.prevshow();
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlTableEditView&function_name=editSqlColumns&columnid="+columnid+"&report_id="+report_id;
        ldAjaxNoProgress(url,'',function(ajaxdata){
            var content = ajaxdata.result.content;
            var title = ajaxdata.result.title;
            Popupobj.setParams(title, that.saveSqlColumns, '', tmpwidth, module, "", arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
            Popupobj.show(content);
            //设为超链接 change事件 isset_linkurl
            ld('#'+Popupobj.divid).find('[tag=isset_linkurl]').unbind('change').bind('change',function(){
                var isset_linkurl = ld(this).prop('checked');
                if(isset_linkurl){
                    ld('#'+Popupobj.divid).find('[tag=linktype_td]').show();
                    ld('#'+Popupobj.divid).find('[tag=primarykey_field_td]').show();
                }else{
                    ld('#'+Popupobj.divid).find('[tag=linktype_td]').hide();
                    ld('#'+Popupobj.divid).find('[tag=primarykey_field_td]').hide();
                }
            });
        });
    };
    //XUQIU1000530	统计表 自定义统计表-支持SQL语句 字段选中与取消选中事件
    this.fieldlists_check_change = function(editObj){
        var thispopobj =  CrmPopup.getPopupObj("last");
        var report_id = ld('#'+thispopobj.divid).find('#report_id').val();
        var columnid = ld(editObj).attr('columnid');

        var prop = ld(editObj).prop('checked');
        var visibile = '';
        if(prop){
            visibile = 'yes';
        }else{
            visibile = 'no';
        }
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlTableEditView&function_name=updateVisibile&columnid="+columnid+"&visibile="+visibile;
        ldAjaxNoProgress(url,{},function(ajaxdata){
            that.renderSqlReportTable();
        });
    }
    //XUQIU1000530	统计表 自定义统计表-支持SQL语句  SQL运行 字段编辑保存
    this.saveSqlColumns = function(editObj){
        var thispopobj =  CrmPopup.getPopupObj("last");
        var param = '';
        var report_id = ld('#'+thispopobj.divid).find('#report_id').val();
        var columnid = ld('#'+thispopobj.divid).find('#columnid').val();
        var tdheader_label = ld('#'+thispopobj.divid).find('#tdheader_label').val();
        var fieldtype = ld('#'+thispopobj.divid).find('#fieldtype').val();
        var isset_linkurl = ld('#'+thispopobj.divid).find('#isset_linkurl').prop('checked');
        param += 'columnid='+columnid+'&tdheader_label='+tdheader_label+'&fieldtype='+fieldtype+'&isset_linkurl='+isset_linkurl;
        if(isset_linkurl){
            param += '&isset_linkurl=yes';
        }else{
            param += '&isset_linkurl=no';
        }
        var linktype = ld('#'+thispopobj.divid).find('#linktype').val();
        var primarykey_field = ld('#'+thispopobj.divid).find('#primarykey_field').val();
        param += '&linktype='+linktype;
        param += '&primarykey_field='+primarykey_field;
        param += '&report_id='+report_id;
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlTableEditView&function_name=saveSqlColumns";
        ldAjaxNoProgress(url,param,function(ajaxdata){
            popupobj.CancelEvent();
            ld('#'+that.divid).find('[tag=fieldline'+columnid+'] span').text('['+ajaxdata.result.tdheader_label+']');
            that.renderSqlReportTable();
        });
    };
    //XUQIU1000530	统计表 自定义统计表-支持SQL语句  SQL运行 变量新增 或 编辑
    this.editVariable = function(obj){
        var report_id = that.report_id;
        var filterid = ld(obj).attr('filterid');
        var tmpwidth = "800px";
        var module = 'CustomTables';
        var Popupobj = CrmPopup.load('', that.saveVariable, "", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
        Popupobj.createScrollDiv();//创建滚动条
        Popupobj.prevshow();
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlTableEditView&function_name=editVariable&filterid="+filterid+"&report_id="+report_id;
        ldAjaxNoProgress(url,'',function(ajaxdata){
            var content = ajaxdata.result.content;
            var title = ajaxdata.result.title;
            Popupobj.setParams(title, that.saveVariable, '', tmpwidth, module, "", arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
            Popupobj.show(content);

            ld('#'+Popupobj.divid).find('[tag=var_type]').unbind('change').bind('change',function(){
                that.var_type_change(Popupobj.divid);
            });
            ld('#'+Popupobj.divid).find('[tag=select_source]').unbind('change').bind('change',function(){
                that.select_source_change(Popupobj.divid);
            });
            ld('#'+Popupobj.divid).find('[tag=modulename]').unbind('change').bind('change',function(){
                var var_type = ld('#'+Popupobj.divid).find('[tag=var_type]').val();
                if(var_type=='select'||var_type=='multiselect'){
                    that.modulename_change(Popupobj.divid);
                }
            });
            //$('#test option:selected').val();
            ld('#'+Popupobj.divid).find('#fieldname').unbind('change').bind('change',function(){
                that.fieldname_change(Popupobj.divid);
            });
            ld('#'+Popupobj.divid).find('#department_allselect_checkbox').unbind('change').bind('change',function(){
                that.department_allselect_checkbox_change(Popupobj.divid);
            });
            ld('#'+Popupobj.divid).find('#default_value_selectdate').unbind('change').bind('change',function(){
                that.default_value_selectdate_change(Popupobj.divid);
            });
            ld('#'+Popupobj.divid).find('#selectvalues').unbind('change').bind('change',function(){
                that.selectvalues_change(Popupobj.divid,filterid);
            });
            if(filterid>0){
                ld('#'+Popupobj.divid).find('#default_multivalue_select').select2({width:'100%',closeOnSelect: true});
            }
            that.selectvalues_change(Popupobj.divid,filterid);
            ld('#'+Popupobj.divid).find('#var_type').select2({width:'100%',closeOnSelect: true});
            ld('#'+Popupobj.divid).find('#select_source').select2({width:'100%',closeOnSelect: true});
        });
    }
    //XUQIU1000530	统计表 自定义统计表-支持SQL语句  保存变量信息
    this.saveVariable = function(){
        var thispopobj =  CrmPopup.getPopupObj("last");
        var params = ld('#'+thispopobj.divid).find('#editVariable').serialize();
        //验证必填项
        var verification1 = CustomTablesObj.connotempty('变量名称',ld('#'+thispopobj.divid).find('#var_name'));
        if(!verification1){
            return;
        }
        var verification2 = CustomTablesObj.connotempty('显示名称',ld('#'+thispopobj.divid).find('#display_name'));
        if(!verification2){
            return;
        }
        var verification3 = CustomTablesObj.connotempty('变量类型',ld('#'+thispopobj.divid).find('#var_type'));
        if(!verification3){
            return;
        }
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlTableEditView&function_name=saveVariable&"+params;
        ldAjaxNoProgress(url,'',function(ajaxdata){
            if(ajaxdata.code!=1){
                RemindsMsg("","LdPopWidth400px","","yes","yes",ajaxdata.msg);return;
            }else{
                thispopobj.CancelEvent();
                var sqlFilterArr = ajaxdata.result.sqlFilterArr;
                var sqlFilterArrCount = sqlFilterArr.length;
                var html = '';
                ld.each(sqlFilterArr,function(index,item){
                    html += '<li tag="filterlineTr" filterid="'+item.id+'" rowindex="'+(parseInt(index)+1)+'" style="display: flex;justify-content: space-between;border-bottom: #fff;">' +
                        '                                        <span class="user" >' +
                        '                                            <label>' +
                        '                                                '+item.var_name+'' +
                        '                                                 <span>['+item.display_name+']</span>' +
                        '                                            </label>' +
                        '                                            </span>' +
                        '<span>';
                    var display = "";
                    if(index<=0){
                        display = 'display:none;'
                    }
                    html += '<a class="icon-category category-sup marR8" style="cursor: pointer;'+display+'" title="'+arrJsPopLabel['MOVEUP']+'" tag="variableup"></a>';
                    var display2 = "";
                    if(index+1>=sqlFilterArrCount){
                        display2 = 'display:none;'
                    }
                    html += '<a class="icon-category category-sdown marR8" style="cursor: pointer;'+display2+'" title="'+arrJsPopLabel['MOVEDOWN']+'" tag="variabledown"></a>';
                    html += '                                            <a class="icon-homeimg icon-sdel2 marR8" style="cursor: pointer;" title="'+arrJsPopLabel['DELETE']+'" tag="variabledelete"></a>' +
                        '                                        <a class="Anu3_a"><i class="ld-fonticon ld-fonticon-edit" filterid="'+item.id+'" tag="variableedit"></i></a></span>' +
                        '                                        </li>';
                });
                ld('#'+that.divid).find('[tag=filterlineTr]').remove();
                ld('#'+that.divid).find('[tag=filterListHeader]').after(html);
                that.setVariableEvent();//变量编辑 删除 上移动下移动事件设置
                that.renderSqlReportTable();
            }
        });
    }

    //变量上移
    this.variableup = function(obj){
        var liobj = Tools.getParentobjByChild(ld(obj),'li');
        var prev_liobj = liobj.prev();
        var prev_html = prev_liobj[0];
        prev_liobj.remove();
        liobj.after(prev_html);
        that.setVariableEvent();//变量编辑 删除 上移动下移动事件设置
        that.resetSqlVarSequence();
    }
    //变量下移动
    this.variabledown = function(obj){
        var liobj = Tools.getParentobjByChild(ld(obj),'li');
        var prev_liobj = liobj.next();
        var prev_html = prev_liobj[0];
        prev_liobj.remove();
        liobj.before(prev_html);
        that.setVariableEvent();//变量编辑 删除 上移动下移动事件设置
        that.resetSqlVarSequence();
    }
    //变量删除事件
    this.variabledelete = function(obj){
        RemindsMsg( "确定删除变量吗？", "LdPopWidth400px", "", "yes", "yes", "确定删除变量吗");
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
            ld('#rptContentLoading').show();
            var liobj = Tools.getParentobjByChild(ld(obj), 'li');
            var filterid = ld(liobj).attr('filterid');
            var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlTableEditView&function_name=variableDelete&filterid=" + filterid;
            ldAjaxNoProgress(url, '', function (ajaxdata) {
                liobj.remove();
                that.resetSqlVarSequence();
                ld('#rptContentLoading').hide();
            });
        });
    }
    this.resetSqlVarSequence=function(){
        var liobjs=ld('#'+that.divid).find("li[tag='filterlineTr']");
        var filterid_str = '';
        var sequence_str = '';
        var trlength = liobjs.length;
        ld.each(liobjs,function(tmpindex,trobj){
            var rowindex=parseInt(tmpindex)+1;
            ld(trobj).attr("rowindex",rowindex);
            sequence_str += rowindex + ',';
            var filterid = ld(trobj).attr('filterid');
            filterid_str += filterid + ',';
            ld(trobj).find('[tag=variableup]').show();
            ld(trobj).find('[tag=variabledown]').show();
            if(rowindex<=1){
                ld(trobj).find('[tag=variableup]').hide();
                ld(trobj).find('[tag=variabledown]').show();
            }
            if(rowindex >= trlength){
                ld(trobj).find('[tag=variableup]').show();
                ld(trobj).find('[tag=variabledown]').hide();
            }
        });
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlTableEditView&function_name=resetSqlVarSequence&report_id="+that.report_id;
        url+='&filterid_str='+filterid_str+'&sequence_str='+sequence_str;
        ldAjaxNoProgress(url,'',function(ajaxdata){

        });

    }
    //XUQIU1000530	统计表 自定义统计表-支持SQL语句 变量类型切换事件
    this.var_type_change = function(divid){
        var var_type = ld('#'+divid).find('[tag=var_type]').val();
        if(var_type=='date'){
            ld('#'+divid).find('[tag=datevalue_tr]').css('display','flex');
            ld('#'+divid).find('[tag=datetimevalue_tr]').hide();
        }else if(var_type=='datetime'){
            ld('#'+divid).find('[tag=datevalue_tr]').hide();
            ld('#'+divid).find('[tag=datetimevalue_tr]').css('display','flex');
        }else{
            ld('#'+divid).find('[tag=datevalue_tr]').hide();
            ld('#'+divid).find('[tag=datetimevalue_tr]').hide();
        }
        //下拉框字段来源
        if(var_type=='select'||var_type=='multiselect'){
            ld('#'+divid).find('[tag=select_source_tr]').css('display','flex');
            ld('#'+divid).find('[tag=modulename_tr]').css('display','flex');
            ld('#'+divid).find('[tag=fieldname_tr]').css('display','flex');
            ld('#'+divid).find('[tag=selectvalues_tr]').css('display','flex');
        }else{
            ld('#'+divid).find('[tag=select_source_tr]').css('display','none');
            ld('#'+divid).find('[tag=modulename_tr]').css('display','none');
            ld('#'+divid).find('[tag=fieldname_tr]').css('display','none');
            ld('#'+divid).find('[tag=selectvalues_tr]').css('display','none');
        }
        //默认值  显示隐藏
        if(var_type=='selectuser'||var_type=='multiuser'){
            ld('#'+divid).find('[tag=default_value_tr]').hide();
            ld('#'+divid).find('[tag=default_value_select_tr]').hide();
            ld('#'+divid).find('[tag=default_value_multiselect_tr]').hide();
            ld('#'+divid).find('[tag=default_value_selectdate_tr]').hide();
            ld('#'+divid).find('[tag=modulename_tr]').css('display','flex');
            ld('#'+divid).find('[tag=default_value_approvestatus_tr]').hide();
            ld('#'+divid).find('[tag=default_value_checkbox_tr]').hide();
        }
        else if(var_type=='date'||var_type=='datetime'){
            ld('#'+divid).find('[tag=default_value_tr]').hide();
            ld('#'+divid).find('[tag=default_value_select_tr]').hide();
            ld('#'+divid).find('[tag=default_value_multiselect_tr]').hide();
            ld('#'+divid).find('[tag=default_value_selectdate_tr]').css('display','flex');
            ld('#'+divid).find('[tag=default_value_approvestatus_tr]').hide();
            ld('#'+divid).find('[tag=default_value_checkbox_tr]').hide();
        }
        else if(var_type=='multiselect'){
            ld('#'+divid).find('[tag=default_value_tr]').hide();
            ld('#'+divid).find('[tag=default_value_select_tr]').hide();
            ld('#'+divid).find('[tag=default_value_multiselect_tr]').css('display','flex');
            ld('#'+divid).find('[tag=default_value_selectdate_tr]').hide();
            ld('#'+divid).find('#default_multivalue_select').select2({width:'100%',closeOnSelect: true});
            ld('#'+divid).find('[tag=default_value_approvestatus_tr]').hide();
            ld('#'+divid).find('[tag=default_value_checkbox_tr]').hide();
        }else if(var_type=='select'){
            ld('#'+divid).find('[tag=default_value_tr]').hide();
            ld('#'+divid).find('[tag=default_value_select_tr]').css('display','flex');
            ld('#'+divid).find('[tag=default_value_multiselect_tr]').hide();
            ld('#'+divid).find('[tag=default_value_selectdate_tr]').hide();
            ld('#'+divid).find('[tag=default_value_approvestatus_tr]').hide();
            ld('#'+divid).find('[tag=default_value_checkbox_tr]').hide();
        }else if(var_type=='string'||var_type=='number'){
            if(var_type=='number'){
                ld('#'+divid).find('[tag=default_value_tr]').css('display','flex');
            }else{
                ld('#'+divid).find('[tag=default_value_tr]').hide();
            }

            ld('#'+divid).find('[tag=default_value_select_tr]').hide();
            ld('#'+divid).find('[tag=default_value_multiselect_tr]').hide();
            ld('#'+divid).find('[tag=default_value_selectdate_tr]').hide();
            ld('#'+divid).find('[tag=default_value_approvestatus_tr]').hide();
            ld('#'+divid).find('[tag=default_value_checkbox_tr]').hide();
        }else if(var_type=='checkbox'){
            ld('#'+divid).find('[tag=default_value_checkbox_tr]').css('display','flex');
            ld('#'+divid).find('[tag=default_value_tr]').hide();
            ld('#'+divid).find('[tag=default_value_select_tr]').hide();
            ld('#'+divid).find('[tag=default_value_multiselect_tr]').hide();
            ld('#'+divid).find('[tag=default_value_selectdate_tr]').hide();
            ld('#'+divid).find('[tag=default_value_approvestatus_tr]').hide();
        }else if(var_type=='approvestatus'){
            //审批组件
            ld('#'+divid).find('[tag=default_value_approvestatus_tr]').css('display','flex');

            ld('#'+divid).find('[tag=default_value_tr]').hide();
            ld('#'+divid).find('[tag=default_value_select_tr]').hide();
            ld('#'+divid).find('[tag=default_value_multiselect_tr]').hide();
            ld('#'+divid).find('[tag=default_value_selectdate_tr]').hide();
            ld('#'+divid).find('[tag=default_value_checkbox_tr]').hide();
        }else if(var_type=='department'){
            // 部门组件
            ld('#'+divid).find('[tag=department_allselect_tr]').css('display','flex');

            ld('#'+divid).find('[tag=default_value_approvestatus_tr]').hide();
            ld('#'+divid).find('[tag=default_value_tr]').hide();
            ld('#'+divid).find('[tag=default_value_select_tr]').hide();
            ld('#'+divid).find('[tag=default_value_multiselect_tr]').hide();
            ld('#'+divid).find('[tag=default_value_selectdate_tr]').hide();
            ld('#'+divid).find('[tag=default_value_checkbox_tr]').hide();
        }else if(var_type=='curroperator'){
            //当前操作员
            ld('#'+divid).find('[tag=department_allselect_tr]').hide();
            ld('#'+divid).find('[tag=default_value_approvestatus_tr]').hide();
            ld('#'+divid).find('[tag=default_value_tr]').hide();
            ld('#'+divid).find('[tag=default_value_select_tr]').hide();
            ld('#'+divid).find('[tag=default_value_multiselect_tr]').hide();
            ld('#'+divid).find('[tag=default_value_selectdate_tr]').hide();
            ld('#'+divid).find('[tag=default_value_checkbox_tr]').hide();
        }
        if(var_type=='select'||var_type=='multiselect'){
            that.select_source_change(divid);
        }
        if(var_type=='date'||var_type=='datetime'){
            that.default_value_selectdate_change(divid);
        }
        if(var_type=='department'){
            //-- 展示全部组织架构信息： 切换事件
            that.department_allselect_checkbox_change(divid);
        }
    }
    //XUQIU1000530	统计表 自定义统计表-支持SQL语句  下拉框值来源	切换事件
    this.select_source_change = function(divid){
        var select_source = ld('#'+divid).find('[tag=select_source]').val();
        if(select_source=='picklist'){
            ld('#'+divid).find('[tag=modulename_tr]').css('display','flex');
            ld('#'+divid).find('[tag=fieldname_tr]').css('display','flex');
            that.modulename_change(divid);
        }else{
            ld('#'+divid).find('[tag=modulename_tr]').hide();
            ld('#'+divid).find('[tag=fieldname_tr]').hide();
            ld('#'+divid).find('#selectvalues').val("");
            ld('#'+divid).find('#default_multivalue_select').html("").val("");
            ld('#'+divid).find('#default_value_select').html("").val("");
            ld('#'+divid).find('#selectvalues').unbind('change').bind('change',function(){
                that.selectvalues_change(divid,0);
            })
        }
    }
    //XUQIU1000530	统计表 自定义统计表-支持SQL语句  模块名称切换事件
    this.modulename_change = function(divid){
        var modulename = ld('#'+divid).find('[tag=modulename]').val();
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlTableEditView&function_name=getPickListsByModule&modulename="+modulename;
        ldAjaxNoProgress(url,'',function(ajaxdata){
            var html = '';
            var picklists = ajaxdata.result.picklists;
            ld.each(picklists,function(index,item){
                html += '<option pickvalues="'+item.picklist_str+'" value="'+item.columnname+'">'+item.label+'</option>';
            });
            ld('#'+divid).find('#fieldname').html(html);
            that.fieldname_change(divid);
        });
    }
    //XUQIU1000530	统计表 自定义统计表-支持SQL语句  字段名称切换事件
    this.fieldname_change = function(divid){
        var pickvalues = ld('#'+divid).find('#fieldname option:selected').attr('pickvalues');
        ld('#'+divid).find('#selectvalues').val(pickvalues);
        var pickvalues_arr = pickvalues.split(',');
        var html = '';
        ld.each(pickvalues_arr,function(index,item){
            html += '<option value="'+item+'">'+item+'</option>';
        });

        ld('#'+divid).find('#default_value_select').html(html);//默认值
        ld('#'+divid).find('#default_multivalue_select').html(html);//默认值
        ld('#'+divid).find('#modulename').select2({width:'100%',closeOnSelect: true});
        ld('#'+divid).find('#fieldname').select2({width:'100%',closeOnSelect: true});
        ld('#'+divid).find('#default_multivalue_select').select2({width:'100%',closeOnSelect: true});
    };
    this.selectvalues_change = function(divid,filterid){
        ld('#'+divid).find('#modulename').select2({width:'100%',closeOnSelect: true});
        ld('#'+divid).find('#fieldname').select2({width:'100%',closeOnSelect: true});
        if(filterid<=0){
            var selectvalues = ld('#'+divid).find('#selectvalues').val();
            var pickvalues_arr = selectvalues.split(',');
            var html = '';
            ld.each(pickvalues_arr,function(index,item){
                html += '<option value="'+item+'">'+item+'</option>';
            });
            ld('#'+divid).find('#default_value_select').html(html);//默认值
            ld('#'+divid).find('#default_multivalue_select').html(html);//默认值
            ld('#'+divid).find('#default_value_select').select2({width:'100%',closeOnSelect: true});
            ld('#'+divid).find('#default_multivalue_select').select2({width:'100%',closeOnSelect: true});
        }
    }
    this.default_value_selectdate_change = function(divid){
        var default_value_selectdate = ld('#'+divid).find('#default_value_selectdate').val();
        var var_type = ld('#'+divid).find('#var_type').val();
        if(var_type=='date'){
            ld('#'+divid).find('[tag=datevalue_tr]').css('display','flex');
            ld('#'+divid).find('[tag=datetimevalue_tr]').hide();
        }
        if(var_type=='datetime'){
            ld('#'+divid).find('[tag=datevalue_tr]').hide();
            ld('#'+divid).find('[tag=datetimevalue_tr]').css('display','flex');
        }
        if(default_value_selectdate!='selfdefined'){
            ld('#'+divid).find('#datevalue').attr('disabled',true);
            ld('#'+divid).find('#datetimevalue').attr('disabled',true);
            var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlTableEditView&function_name=getDefaultDateValue&default_value_selectdate="+default_value_selectdate+"&var_type="+var_type;
            ldAjaxNoProgress(url,'',function(ajaxdata){
                ld('#'+divid).find('#datevalue').val(ajaxdata.result.value_date);
                ld('#'+divid).find('#datetimevalue').val(ajaxdata.result.value);
            });
        }else{
            ld('#'+divid).find('#datevalue').removeAttr('disabled');
            ld('#'+divid).find('#datetimevalue').removeAttr('disabled');
        }
    }
    this.department_allselect_checkbox_change = function(divid){
        var department_allselect = ld('#'+divid).find('#department_allselect_checkbox').prop('checked');
        if(department_allselect==false){
            ld('#'+divid).find('[tag=modulename_tr]').css('display','flex');
        }else{
            ld('#'+divid).find('[tag=modulename_tr]').hide();
        }
    }
    this.saveReportInfo = function(isfinish){
        ld('#rptContentLoading').show();
        var report_type = ld('#'+that.divid).find('#report_type').val();//报表类型 selectfield-字典报表 sql-SQL
        var params = ld('#'+that.divid+' #chartInfoForm').serialize();
        //报表名称不能为空
        var report_name = ld('#'+that.divid +" #report_name").val();
        if((report_name==''||report_name==undefined)){//字典报表 保存的时候报表名称必填
            ld('#rptContentLoading').hide();
            CustomTablesObj.connotempty('报表名称',ld('#'+that.divid).find('#report_name'));
            return;
        }
        //创建链接模块
        var linkmodulecheck = ld('#'+that.divid +" #linkmodulecheck").prop('checked');
        if(linkmodulecheck){
            params += '&linkmodulecheck=yes';
        }else{
            params += '&linkmodulecheck=no';
        }
        //是否放看板显示
        var show_athome = ld('#'+that.divid +" #show_athome").prop('checked');
        if(show_athome){
            params += '&show_athome=yes';
        }else{
            params += '&show_athome=no';
        }
        params += '&is_ajax=yes&isfinish='+isfinish+'&report_type='+report_type;
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlTableEditView&function_name=saveReportInfo";
        ldAjaxNoProgress(url,params,function(res){
            ld('#rptContentLoading').hide();
            if(res.code==1){
                var report_id = res.result.report_info.report_id;
                ld('#'+that.divid +" #report_id").val(report_id);
                ld('#'+that.divid +" #report_type").attr('disabled',true);

                that.report_id = report_id;
                if(isfinish=='no') {
                    that.renderSqlReportTable();
                //wyt 220817 XUQIU1000504 自定义统计图表或报表的查看界面增加快捷编辑按钮
                }else if( that.frompage == "fromdetail"){
                    var popupobj = CrmPopup.getPopupObj('lastprev');
                    that.popupobj.CancelEvent();
                    //edit: xll 2024/02/01 BUG20240111-78 刷新详情页弹窗的报表名称
                    if(popupobj.headtitle !== report_name){
                        popupobj.headtitle = report_name;
                        ld('#'+popupobj.divid).find('#'+popupobj.divid+'_head').find('.E_ptita').text(report_name);
                        ReportAnalysis.refreshReportName(report_id,report_name);
                    }
                    var CustomTablesSqlDetailObj = new CustomTablesSqlDetail();
                    CustomTablesSqlDetailObj.setPopupobj(popupobj);
                    CustomTablesSqlDetailObj.setDivid(popupobj.divid);
                    CustomTablesSqlDetailObj.setReportId(report_id);
                    CustomTablesSqlDetailObj.init();
                }else if(isfinish=='init'){
                    that.init('edit');
                }else{
                    var popupobj = CrmPopup.getPopupObj('last');
                    popupobj.CancelEvent();
                    ReportAnalysisObj.getReportList(0, 'init');
                }
            }else{
                if(isfinish=='no') {
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['SaveFailed2']);
                }else{
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", res.msg);
                }
            }
        });
    }
    //滚动条
    this.setScroll = function(th_width,top_height){
        var windowWidth = CrmPopup.getClientWidth();
        var windowHeight = CrmPopup.getClientHeight();
        var divid = that.divid;
        var offset = ld("#"+divid+" #div_thResizableContent").offset();
        var right_width = offset==undefined||offset.left==undefined?0:offset.left;
        top_height = offset==undefined||offset.top==undefined?0:offset.top;//元素距离顶端的高度
        var height=windowHeight-top_height;
        if(typeof frommobile!="undefined" && frommobile=='yes'){
            ld("#"+divid+" #div_thResizableContent").css('width',(windowWidth-right_width)+'px');//宽度
        }else{
            ld("#"+divid+" #div_thResizableContent").css('width',(windowWidth-right_width-44)+'px').css('margin-left','20px').css('margin-right','20px');//宽度
            height = height-87;
        }
        if(th_width<=0){
            ld("#"+divid+" #thResizable").css('width',(windowWidth-right_width-57)+'px');
        }else{
            ld("#"+divid+" #thResizable").css('width',(parseInt(th_width)+17)+'px');
        }
        ld("#"+divid+" #div_thResizableContent").css('height',height+'px');//宽度
        ld("#"+divid+" #sqlfieldListDiv").css('height',((parseInt(height)+100)/2)+'px');
        ld("#"+divid+" #sqlVariableDiv").css('height',((parseInt(height)+100)/2)+'px');
        ld("#"+divid+" #fieldListDiv").css('height',(parseInt(height)+100)+'px');
    }
}
