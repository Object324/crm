AjaxJSPage('ChartCreate','include/js/modules/CustomEcharts/ChartCreate.js');
/**
 * @class  SqlChartCreate
 * @author  xll
 * @date  2023/11/1 - 初始版本
 * - SQL统计图 新建编辑类
 * @description  处理SQL统计图新建编辑的业务
 */
function SqlChartCreate() {
    ChartCreate.call(this);
    var that = this;
    this.report_type = 'sqlchart';
    this.AjaxFileName = 'SqlEchartsEditView';

    /**
     * 编辑SQL统计图需要执行的事件（添加已选字段卡片、绑定字段拖动）
     */
    this.ExcuteEditEvnet = function () {
        //添加已选字段卡片
        var TaskOption = {
            Module : 'SqlField',
        };
        that.ChartSetHtmlObj.ExecuteTaskByTaskType('AddFieldsCard',TaskOption);
        //绑定字段拖动事件
        this.ChangeChartTypeEvent();
    }

    /**
     * 获取字段的模块（主要用于SQL统计图使用）
     * @param {object} FieldInfo 字段信息对象
     */
    this.getFieldModule = function (FieldInfo) {
        return 'SqlField';
    }

    /**
     * 根据字段信息对象获取字段DOM对象的Jquery对象
     * @param FieldInfo 字段信息对象
     * @return {object} 字段DOM对象的Jquery对象
     */
    this.getFieldItemObj = function (FieldInfo) {
        var fieldid = FieldInfo.columns;
        var DragBlockObj = ld('#'+that.Popupobj.divid+' #Block_SqlField');
        var ModuleFieldConObj = DragBlockObj.children('.ModuleFieldCon[block_id=SqlField]');
        var ItemObj = ModuleFieldConObj.children('.Field[fieldid='+fieldid+']');
        return ItemObj;
    }

    /**
     * 扩充Dom对象事件方法集合
     */
    this.SetObjEvent_Fun = Object.assign(this.SetObjEvent_Fun,{
        /**
         * - SQL编辑点击事件,出现弹窗进行编辑
         */
        EditSql_click : function (JqueryObj) {
            that.EventObj = JqueryObj;
            //阻止事件冒泡
            event.stopPropagation();
            var sqlvalue = that.ChartSetInfo.sqlstr_origin !== '' && that.ChartSetInfo.sqlstr_origin !== undefined ? that.ChartSetInfo.sqlstr_origin : '';
            var tmpheight = ld(window).height() - 200;//全屏宽度
            var tmpwidth = "1000px";
            var module = 'CustomEcharts';
            var Popupobj = CrmPopup.load( arrJsPopLabel['EDIT']+"SQL", that.CompleteSQL, "", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
            Popupobj.createScrollDiv();//创建滚动条
            Popupobj.prevshow();
            var html = '<table width="1000px" border="0" cellspacing="0" cellpadding="0" align="left" id="editsql_box" class="">' +
                '       <tbody>' +
                '       <tr>' +
                '           <td class="ld-form-item-content">' +
                // '               <textarea class="ld-textarea-inner" style="overflow:auto;overflow-wrap:break-word;resize:horizontal;height:'+tmpheight+'px;"' +
                // '                         id="sqlstr_temp">'+
                //                     sqlvalue +
                //                '</textarea>' +
                '     <div id="sqlstr_temp" class="ace_editor" style="min-height:470px"><textarea class="ace_text-input">'+sqlvalue+'</textarea></div>' +
                '           </td>' +
                '       </tr>' +
                '       <tr>' +
                '           <td class="ld-form-item-content">' +
                '               <span style="line-height:20px;height:20px;display:block">'+'1.SQL中不允许select *，请写出查询的具体字段；'+'</span>' +
                '               <span style="line-height:20px;height:20px;display:block">'+'2.为保证运算正确，请先在数据库工具中将SQL调试正确；'+'</span>' +
                '           </td>' +
                '       </tr>' +
                '       </tbody>' +
                '       </table>';
            Popupobj.setParams( arrJsPopLabel['EDIT']+"SQL", that.CompleteSQL, '', tmpwidth, module, "", arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
            Popupobj.show(html);
            //代码样式
            that.sqlEditor = AceInitSqlEditor("sqlstr_temp");
        },
        /**
         * - SQL字段编辑点击事件,出现弹窗进行编辑
         */
        EditSqlColumns_click : function (JqueryObj) {
            //阻止事件冒泡
            that.EventObj = JqueryObj;
            event.stopPropagation();
            var columnid = ld(JqueryObj).parent().attr('fieldid');
            var report_id = that.ChartSetInfo.report_id;
            var tmpwidth = "600px";
            var module = 'CustomEcharts';
            var editPopupobj = CrmPopup.load('', that.saveSqlColumns, "", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
            editPopupobj.createScrollDiv();//创建滚动条
            editPopupobj.prevshow();
            editPopupobj.fieldid = columnid;
            var url = that.getAjaxUrl();
            var params = "&function_name=editSqlColumns&columnid="+columnid+"&report_id="+report_id;
            ldAjax(url,params,function(ajaxdata){
                var content = ajaxdata.result.content;
                var title = ajaxdata.result.title;
                editPopupobj.setParams(title, that.saveSqlColumns, '', tmpwidth, module, '', arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
                editPopupobj.show(content);
                DelProgressObjs();
                that.ChartPreview();
            });
        },
        /**
         * - “新变量”点击事件,出现弹窗进行编辑
         */
        NewVariable_click : function (JqueryObj) {
            //阻止事件冒泡
            event.stopPropagation();
            that.EventObj = JqueryObj;
            var report_id = that.ChartSetInfo.report_id;
            var filterid = ld(JqueryObj).attr('fieldid');
            var tmpwidth = "800px";
            var module = 'CustomEcharts';
            var editPopupobj = CrmPopup.load('', that.saveVariable, "", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
            editPopupobj.createScrollDiv();//创建滚动条
            editPopupobj.prevshow();
            var url = that.getAjaxUrl();
            var params = "&function_name=editVariable&filterid="+filterid+"&report_id="+report_id;
            ldAjaxNoProgress(url,params,function(ajaxdata){
                var content = ajaxdata.result.content;
                var title = ajaxdata.result.title;
                editPopupobj.setParams(title, that.saveVariable, '', tmpwidth, module, "", arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
                editPopupobj.show(content);
                var JqPopupobj = ld('#'+editPopupobj.divid);
                that.SetObjEvent_Fun.EditVariable_callback(editPopupobj,JqPopupobj);
            });
        },
        /**
         * 变量新增编辑ajax请求回调事件
         * @param editPopupobj 编辑的弹窗对象
         * @param JqPopupobj 编辑的弹窗Jquery对象
         */
        EditVariable_callback : function (editPopupobj,JqPopupobj) {
            var filterid = ld(that.EventObj).attr('fieldid');
            var EventList = [
                //变量类型切换事件
                { selector : '#var_type', fun : 'var_type_change' , type : 'change'},
                //下拉框字段列表值来源
                { selector : '#select_source', fun : 'select_source_change' , type : 'change'},
                //下拉框字段值来源模块
                { selector : '[tag=modulename]', fun : 'modulename_change' , type : 'change'},
                //下拉框字段值来源字段
                { selector : '#fieldname', fun : 'fieldname_change' , type : 'change'},
                //下拉框字段列表值
                { selector : '#selectvalues', fun : 'selectvalues_change' , type : 'change'},
                //日期字段默认值
                { selector : '#default_value_selectdate', fun : 'default_value_selectdate_change' , type : 'change'},
            ];
            ld.each(EventList,function (index,Info) {
                JqPopupobj.find(Info.selector).unbind(Info.type).bind(Info.type,function(){
                    that.EditvariableFun[Info.fun](editPopupobj,JqPopupobj);
                });
            })
            if(filterid>0){
                //多选框字段默认值
                JqPopupobj.find('#default_multivalue_select').select2({width:'100%',closeOnSelect: true});
            }
            that.EditvariableFun.selectvalues_change(editPopupobj,JqPopupobj);
            JqPopupobj.find('#var_type').select2({width:'100%',closeOnSelect: true});
            JqPopupobj.find('#select_source').select2({width:'100%',closeOnSelect: true});
        },
        /**
         * - 编辑变量点击事件
         */
        EditVariable_click : function (JqueryObj) {
            var FieldObj = JqueryObj.parent();
            that.SetObjEvent_Fun.NewVariable_click(FieldObj);
        },
        /**
         * - 编辑删除点击事件
         */
        DelVariable_click : function (JqueryObj) {
            var DelCom = arrJsPopLabel['DelVariableComfirm'];
            RemindsMsg( DelCom, "LdPopWidth400px", "", "yes", "yes", DelCom);
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                ld('#rptContentLoading').show();
                var FieldObj = ld(JqueryObj).parent();
                var filterid = ld(FieldObj).attr('fieldid');
                var url = that.getAjaxUrl();
                var params = "&function_name=variableDelete&filterid=" + filterid;
                ldAjaxNoProgress(url, params, function (ajaxdata) {
                    FieldObj.remove();
                    that.SortVariable();
                    ld('#rptContentLoading').hide();
                });
            });
        },
    });

    /** SQL统计图在选择号图表类型后需要进行保存操作以获取report_id */
    this.AfterSelChartType = function () {
        that.SaveAjaxFun('SelChartType');
    }
    /** 编辑SQL完成事件 */
    this.CompleteSQL = function () {
        var popobj = CrmPopup.getPopupObj("last");
        // var sqlstr_origin = that.ChartSetInfo.sqlstr_origin = ld('#'+popobj.divid).find('#sqlstr_temp').val();
        // var sqlstr = Base64.encode(sqlstr_origin);
        var sqlstr_origin =  that.sqlEditor.getValue();
        var sqlstr = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(sqlstr_origin,false,[]);
        sqlstr = encodeURIComponent(sqlstr);
        var report_id = that.ChartSetInfo.report_id;
        var report_name = that.ChartSetInfo.report_name;
        var url = that.getAjaxUrl();
        var param = "is_ajax=yes&function_name=parserSql&report_id="+report_id+"&sqlstr="+sqlstr+"&report_name="+report_name;
        ldAjax(url,param,function(res) {
            if(res.code === 1){
                that.ShowField(res.result.columnsarr);
            }else{
                RemindsMsg("","LdPopWidth400px","","yes","yes",res.msg);
            }
            popobj.CancelEvent();
            DelProgressObjs();
        });
    }

    /** 编辑SQL字段保存 */
    this.saveSqlColumns = function () {
        var editPopupobj =  CrmPopup.getPopupObj("last");
        var report_id = that.ChartSetInfo.report_id;
        var columnid = editPopupobj.fieldid;
        var column_label = ld('#'+editPopupobj.divid).find('#column_label').val();
        var fieldtype = ld('#'+editPopupobj.divid).find('#fieldtype').val();

        var param = '&function_name=saveSqlColumns' +
            '&columnid='+columnid+'&column_label='+column_label+'&fieldtype='+fieldtype +
            '&report_id='+report_id;
        var url = that.getAjaxUrl();
        ldAjaxNoProgress(url,param,function(ajaxdata){
            ld(that.EventObj).siblings('.FieldLabel').find('.FieldDisplayName').text(' [ '+ajaxdata.result.column_label+' ] ');
            editPopupobj.CancelEvent();
        });
    }

    /** 编辑变量保存 */
    this.saveVariable = function () {
        var editPopupobj =  CrmPopup.getPopupObj("last");
        var JqPopobj = ld('#'+editPopupobj.divid);
        //验证必填项
        var verification = true;
        var verificationArr = [
            { label : '变量名称', ObjId : 'var_name', },
            { label : '显示名称', ObjId : 'display_name', },
            { label : '变量名称', ObjId : 'var_type', },
        ];
        ld.each(verificationArr,function (index,Info) {
            verification = verification && that.connotempty(Info.label,JqPopobj.find('#'+Info.ObjId));
            return verification;
        })
        if(!verification)
            return false;
        var url = that.getAjaxUrl();
        var params = '&function_name=saveVariable&';
        params += '&' + JqPopobj.find('#editVariable').serialize();
        ldAjaxNoProgress(url,params,function(ajaxdata){
            if(ajaxdata.code != 1){
                RemindsMsg("","LdPopWidth400px","","yes","yes",ajaxdata.msg);
            }else{
                //var show_athome_set = ajaxdata.result.show_athome_set;
                that.ShowField(ajaxdata.result.sqlFilterArr);
                editPopupobj.CancelEvent();
            }
        });
    }

    /** 编辑变量保存时，判断必填项的方法 */
    this.connotempty = function(tips,inputobj){
        var value = ld(inputobj).val();
        if(value === '' || value === undefined){
            RemindsMsg("","LdPopWidth400px","","yes","yes",tips+arrJsPopLabel['CANOTEMPTY']);
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                ld(inputobj).focus();
            });
            ld('input[class="E_pbtncancel"]').unbind('click').on('click', function () {
                ld(inputobj).focus();
            });
            return false;
        }
        return true;
    }

    /** 变量排序 */
    this.SortVariable = function () {
        var VarList = ld('#'+that.divid+' #Block_Variable .ModuleFieldCon .Field');
        var filterid_str = '';
        var sequence_str = '';
        ld.each(VarList,function(index,VarObj){
            var rowindex = parseInt(index) + 1;
            ld(VarObj).attr("rowindex",rowindex);
            sequence_str += rowindex + ',';
            var fieldid = ld(VarObj).attr('fieldid');
            filterid_str += fieldid + ',';
        });
        var url = that.getAjaxUrl();
        var params = "&function_name=resetSqlVarSequence&report_id="+that.ChartSetInfo.report_id +
            '&filterid_str='+filterid_str+'&sequence_str='+sequence_str;
        ldAjaxNoProgress(url,params,function(ajaxdata){
            that.ChartPreview();
        });
    }

    /** 变量编辑的弹窗界面事件集合(变量类型改变、等) */
    this.EditvariableFun = {
        /** 变量类型改变 */
        var_type_change : function (editPopupobj,JqPopup) {
            //字段信息行全部隐藏
            var editFormObj = JqPopup.find('#editVariable');
            editFormObj.find(' [fieldinfoitem]').hide();
            var var_type = JqPopup.find('[tag=var_type]').val();
            var tagArr = this.var_type_tagArr[var_type];
            ld.each(tagArr,function (index,tagId) {
                editFormObj.find('[tag='+tagId+']').css('display','flex');
                if(that.EditvariableFun.var_type_Fun[var_type])
                    that.EditvariableFun.var_type_Fun[var_type](editPopupobj,JqPopup);
            });
        },
        /** 变量类型对应的需要显示的设置行 */
        var_type_tagArr : {
            date : ['datevalue_tr','default_value_selectdate_tr'],
            datetime : ['datetimevalue_tr','default_value_selectdate_tr'],
            select : ['select_source_tr','modulename_tr','fieldname_tr','selectvalues_tr','default_value_select_tr'],
            multiselect : ['select_source_tr','modulename_tr','fieldname_tr','selectvalues_tr','default_value_multiselect_tr'],
            selectuser : ['modulename_tr'],
            multiuser : ['modulename_tr'],
            string : [],
            number : ['default_value_tr'],
            checkbox : [],
            approvestatus : ['default_value_approvestatus_tr'],
        },
        /** 变量类型需要执行的特殊方法 */
        var_type_Fun : {
            multiselect : function (editPopupobj,JqPopup) {
                JqPopup.find('#default_multivalue_select').select2({width:'100%',closeOnSelect: true});
                that.EditvariableFun.select_source_change(editPopupobj,JqPopup);
            },
            select : function (editPopupobj,JqPopup) {
                that.EditvariableFun.select_source_change(editPopupobj,JqPopup);
            },
            date : function (editPopupobj,JqPopup) {
                that.EditvariableFun.default_value_selectdate_change(editPopupobj,JqPopup);
            },
            datetime : function (editPopupobj,JqPopup) {
                that.EditvariableFun.default_value_selectdate_change(editPopupobj,JqPopup);
            },
        },
        select_source_change : function (editPopupobj,JqPopup) {
            var select_source = JqPopup.find('[tag=select_source]').val();
            if(select_source=='picklist'){
                JqPopup.find('[tag=modulename_tr]').css('display','flex');
                JqPopup.find('[tag=fieldname_tr]').css('display','flex');
                that.EditvariableFun.modulename_change(editPopupobj,JqPopup);
            }else{
                JqPopup.find('[tag=modulename_tr]').hide();
                JqPopup.find('[tag=fieldname_tr]').hide();
                JqPopup.find('#selectvalues').val("");
                JqPopup.find('#default_multivalue_select').html("").val("");
                JqPopup.find('#default_value_select').html("").val("");
                JqPopup.find('#selectvalues').unbind('change').bind('change',function(){
                    that.EditvariableFun.selectvalues_change(editPopupobj,JqPopup);
                })
            }
        },
        modulename_change : function (editPopupobj,JqPopup) {
            var modulename = JqPopup.find('[tag=modulename]').val();
            var url = that.getAjaxUrl();
            var params = "&function_name=getPickListsByModule&modulename="+modulename;
            ldAjaxNoProgress(url,params,function(ajaxdata){
                var html = '';
                var picklists = ajaxdata.result.picklists;
                ld.each(picklists,function(index,item){
                    html += '<option pickvalues="'+item.picklist_str+'" value="'+item.columnname+'">'+item.label+'</option>';
                });
                JqPopup.find('#fieldname').html(html);
                that.EditvariableFun.fieldname_change(editPopupobj,JqPopup);
            });
        },
        fieldname_change : function (editPopupobj,JqPopup) {
            var pickvalues = JqPopup.find('#fieldname option:selected').attr('pickvalues');
            JqPopup.find('#selectvalues').val(pickvalues);
            var pickvalues_arr = pickvalues.split(',');
            var html = '';
            ld.each(pickvalues_arr,function(index,item){
                html += '<option value="'+item+'">'+item+'</option>';
            });

            JqPopup.find('#default_value_select').html(html);//默认值
            JqPopup.find('#default_multivalue_select').html(html);//默认值
            JqPopup.find('#modulename').select2({width:'100%',closeOnSelect: true});
            JqPopup.find('#fieldname').select2({width:'100%',closeOnSelect: true});
            JqPopup.find('#default_multivalue_select').select2({width:'100%',closeOnSelect: true});
        },
        default_value_selectdate_change : function (editPopupobj,JqPopup) {
            var default_value_selectdate = JqPopup.find('#default_value_selectdate').val();
            var var_type = JqPopup.find('#var_type').val();
            if(var_type=='date'){
                JqPopup.find('[tag=datevalue_tr]').css('display','flex');
                JqPopup.find('[tag=datetimevalue_tr]').hide();
            }
            if(var_type=='datetime'){
                JqPopup.find('[tag=datevalue_tr]').hide();
                JqPopup.find('[tag=datetimevalue_tr]').css('display','flex');
            }
            if(default_value_selectdate!='selfdefined'){
                JqPopup.find('#datevalue').attr('disabled',true);
                JqPopup.find('#datetimevalue').attr('disabled',true);
                var url = that.getAjaxUrl();
                var params = "&function_name=getDefaultDateValue&default_value_selectdate="+default_value_selectdate+"&var_type="+var_type;
                ldAjaxNoProgress(url,params,function(ajaxdata){
                    JqPopup.find('#datevalue').val(ajaxdata.result.value_date);
                    JqPopup.find('#datetimevalue').val(ajaxdata.result.value);
                });
            }else{
                JqPopup.find('#datevalue').removeAttr('disabled');
                JqPopup.find('#datetimevalue').removeAttr('disabled');
            }
        },
        selectvalues_change : function (editPopupobj,JqPopup) {
            var filterid = ld(that.EventObj).attr('fieldid');
            JqPopup.find('#modulename').select2({width:'100%',closeOnSelect: true});
            JqPopup.find('#fieldname').select2({width:'100%',closeOnSelect: true});
            //if(filterid<=0){
                var selectvalues = JqPopup.find('#selectvalues').val();
                var pickvalues_arr = selectvalues.split(',');
                var html = '';
                ld.each(pickvalues_arr,function(index,item){
                    html += '<option value="'+item+'">'+item+'</option>';
                });
                JqPopup.find('#default_value_select').html(html);//默认值
                JqPopup.find('#default_multivalue_select').html(html);//默认值
                JqPopup.find('#default_value_select').select2({width:'100%',closeOnSelect: true});
                JqPopup.find('#default_multivalue_select').select2({width:'100%',closeOnSelect: true});
            //}
        },
    }

    /** 在指定区块下方展示对应的字段列表 */
    this.ShowField = function (FieldList) {
        var BlockId = ld(that.EventObj).parent().attr('block_id');
        if(BlockId === undefined) {
            BlockId = ld(that.EventObj).parents('.ModuleFieldBlock').attr('id');
            BlockId = BlockId.split('_')[1];
        }
        that.ChartSetArr.FieldList[BlockId] = FieldList;
        var FieldListHtml = that.ChartSetHtmlObj.getFieldBlockCon(FieldList,BlockId);
        var BlockConObj = ld('#'+that.divid+' #Block_'+BlockId+' .ModuleFieldCon');
        BlockConObj.html(FieldListHtml);
        that.BindFieldEvent[BlockId](BlockConObj);
        that.ChartPreview();
    }

    /** 不同区块的字段需要绑定的事件 */
    this.BindFieldEvent = {
        SqlField : function (BlockConObj) {
            if(!BlockConObj)
                BlockConObj = ld('#'+that.divid+' #Block_SqlField .ModuleFieldCon');
            //字段编辑事件 editSqlColumns
            BlockConObj.find('.Field .EditFieldIcon').unbind('click').bind('click',function(){
                that.SetObjEvent_Fun.EditSqlColumns_click(ld(this));
            });
            that.BindFieldDragEvent(BlockConObj.get(0));
        },
        Variable : function (BlockConObj) {
            //编辑变量
            BlockConObj.find('.Field .EditFieldIcon').unbind('click').bind('click',function(){
                that.SetObjEvent_Fun.EditVariable_click(ld(this));
            });
            //变量删除事件
            BlockConObj.find('.Field .DelFieldIcon').unbind('click').bind('click',function(){
                that.SetObjEvent_Fun.DelVariable_click(ld(this));
            });
            //字段拖动排序
            var dragobj = BlockConObj.get(0);
            Sortable.create(dragobj, {
                draggable: '.Field',
                handle: '.drag-handle',
                animation: 150,
                sort: true,
                onEnd: function (evt) {
                    that.SortVariable();
                }
            });
        },
    }

    /** SQL统计图中，统计维度和统计字段绑定拖动事件的数组 */
    this.getFieldDragEventArr = function () {
        return {
            XAxisField : {
                Selector : ' #XAxis',
                GroupName : 'SqlField',
                DragPermit : function () {
                    return true;
                },
                Keep : 'Keep',
                DataObj : that.ChartSetInfo.AxisFields.XAxis,
            },
            YAxisField : {
                Selector : ' #YAxis',
                GroupName : 'SqlField',
                DragPermit : function () {
                    return true;
                },
                AfterAdd : function (TargetObj) {
                    that.AddFieldEmpty(TargetObj);
                    //edit: xll 2024/02/19 BUG20240119-62 显示名称与字段中显示名称保持一致
                    //显示名称添加change事件
                    var fieldid = that.DragFieldInfo.id,fieldtype = that.DragFieldInfo.fieldtype;
                    TargetObj.find('#DisplayName').bind('change',function () {
                        var newVal = ld(this).val(),
                            param = '&function_name=saveSqlColumns' +
                                '&columnid='+fieldid+'&column_label='+newVal+'&fieldtype='+fieldtype +
                                '&report_id='+that.ChartSetInfo.report_id;
                        ldAjaxNoProgress(that.getAjaxUrl(),param,function(ajaxdata){
                            var FieldObj = ld("#"+that.divid).find("#Block_SqlField").find(`.Field[fieldid=${fieldid}]`);
                            FieldObj.find('.FieldDisplayName').text(` [ ${newVal} ] `);
                        });
                    });
                },
                Keep : 'KeepLast',
                DataObj : that.ChartSetInfo.AxisFields.YAxis,
            }
        }
    }

    /** SQL统计图中，获取拖动时的拖动字段信息对象 */
    this.getDragFieldInfo = function (SortableEvent) {
        delete that.DragFieldInfo;
        that.DragFieldInfo = {};
        var ItemObj = ld(SortableEvent.item);
        var fieldid = ItemObj.attr('fieldid');
        var fieldindex = parseInt(ItemObj.attr('fieldindex'));
        that.DragFieldInfo = that.ChartSetArr.FieldList.SqlField[fieldindex];
        that.DragFieldInfo.fieldindex = fieldindex;
    }

    /**
     * 字段拖动后，存入所需的字段信息
     * @param DataObj 拖动后字段信息存储的键名指针
     */
    this.getDragDataObj = function (DataObj) {
        var fieldindex = that.DragFieldInfo.fieldindex;
        DataObj.id = that.DragFieldInfo.id;
        DataObj.DisplayName = that.DragFieldInfo.column_label;
    }

    /** SQL统计图中，图表类型对象(折线图、柱状图等对象) 需要转化成对应类型的SQL图表对象 */
    this.getChartTypeObjFun = function () {
        var ChartType = that.ChartSetInfo.chart_type;
        if(ChartType=='simple_sunburst'){
            ChartType = 'multiple_sunburst';
        }
        var ChartTypeObj = that.getChartTypeObj[ChartType]();
        var SqlChartObj = new Chart_Sql();
        that.ChartTypeObj = SqlChartObj.getInstance(ChartTypeObj);
        return that.ChartTypeObj;
    }

    /** SQL统计图的界面生成对象 */
    this.getChartSetHtmlObj = function () {
        return new SqlChartSetHtml();
    }

    /** SQL统计图选择类型后需要进行保存获取report_id */
    this.SaveAjaxCallBackFun.SelChartType = function (data) {
        if(data.code == 1) {
            var chart_info = data.result.chart_info;
            that.ChartSetInfo.report_id = chart_info.report_id;
        }
    }

    /** SQL统计图返回值中，包含echarts图表配置项等信息的键值为chart_info.chartSet */
    this.getChartInfo = function (data) {
        return data.result.chart_info.chartSet;
    }

    /** 绑定各区块字段事件（编辑、拖动等事件） */
    this.ChangeChartTypeEvent = function () {
        var LeftBlockList = that.ChartTypeObj.LeftBlockList;
        ld.each(LeftBlockList,function (BlockId,BlockInfo) {
            var FieldConObj = ld('#'+that.divid+' #Block_'+BlockId+' .ModuleFieldCon');
            if(FieldConObj.find(' .Field').length > 0) {
                that.BindFieldEvent[BlockId](FieldConObj);
            }
        });
    }

    /** 新建、编辑SQL统计图的Ajax请求参数 */
    this.getCreateUrlParams = function (report_id) {
        return '&function_name=index&report_id='+report_id+'&frommodule='+that.pageto_module+"&report_type="+that.report_type;
    }

    /** 加载SQL统计图所需要的js、css补充资源 */
    this.LoadOtherResources = function () {
        AjaxJSPage('Chart_Sql','include/js/modules/CustomEcharts/Chart_Sql.js');
        AjaxJSPage('SqlChartSetHtml','include/js/modules/CustomEcharts/SqlChartSetHtml.js');
    }

}
SqlChartCreate.prototype = Object.create(ChartCreate.prototype);
SqlChartCreate.prototype.constructor = SqlChartCreate;