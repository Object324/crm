function ButtonsCustomization(){
    var that = this;
    this.surl = 'index.php?module=Users&action=UsersAjax&file=ButtonsCustomization&ajax=true';
    // this.selectedmodule = '';// 所选模块
    this.selected_tabid = 0;// 所选模块id
    this.popupobj = {}; // 列表弹出层对象
    this.editpopupobj = {}; // 新增编辑弹出层对象
    this.pop_selected_tabid = 0;// 新增编辑时所选模块id
    this.btnid = 0;// 编辑时btnid

    this.listdata_arr = [];

    this.setPopupobj = function(obj){
        this.popupobj = obj;
    }
    // 切换模块
    this.changeModule = function(obj){
        this.selected_tabid = ld(obj).val();
        this.refreshList();
    }
    // 刷新列表
    this.refreshList = function(){
        var surl = this.surl;
        var param = {'selected_tabid': this.selected_tabid,'mode': 'list'};
        ldAjaxNoProgress(surl,param,function (data){
            if(data.code == 1){
                ld("#"+that.popupobj.divid).find('[name=listcontent]').html(data.result.content);
                that.setListEvent();
                that.listdata_arr = data.result.listdata_arr;
            }else{

            }
        })
    }
    // 列表界面绑定事件
    this.setListEvent = function(){
        var Popupobj = ld("#"+this.popupobj.divid);
        // 切换模块
        Popupobj.find("#optionmodule").off('change').on('change', function (event) {
            that.changeModule(this);
        });
        // 新增
        Popupobj.find("[name=createbtn]").off('click').on('click', function (event) {
            that.initPopup(this);
        });
        // 编辑
        Popupobj.find("[name=editbtn]").off('click').on('click', function (event) {
            that.initPopup(this);
        });
        // 删除
        Popupobj.find("[name=deletebtn]").off('click').on('click', function (event) {
            that.delete(this);
        });
        // 启用
        Popupobj.find("[name=changeactive]").off('click').on('click', function (event) {
            that.changeActive(this);
        });
    }
    // 新增编辑弹出层
    this.initPopup = function (obj){
        var btnid = this.btnid = ld(obj).data('btnid');
        var mode = 'create';
        var tabid;
        if(btnid > 0){// 编辑
            tabid = this.pop_selected_tabid = ld(obj).data('tabid');
            mode = 'edit';
        }else{
            tabid = this.selected_tabid;
        }
        var crmPopupobj=CrmPopup.load("","","",'LdPopWidth800px','Settings',"","","","");
        crmPopupobj.prevshow();
        var surl = this.surl;
        var param = {'btnid': btnid,'selected_tabid': tabid,'mode': mode};
        
        ldAjaxNoProgress(surl,param,function (data){
            if(data.code == 1){
                crmPopupobj.setParams(data.result.title, that.save, "", "LdPopWidth800px", 'Settings', "", data.result.oktext, "", data.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj, data.result.content);
                if(mode == 'create'){
                    // 下拉框样式
                    var selectobj_field = ld("#"+popupobj.divid).find("select[name=selectmodule]");
                    var cls_resetComboxHtmlobj = new cls_resetComboxHtml(selectobj_field.attr('name'));
                    cls_resetComboxHtmlobj.setPopupObj(popupobj);
                    var selectwidth = Tools.getParentobjByChild(selectobj_field, 'td').width();
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj_field, selectwidth + 20);
                    // 按钮默认开启
                    ld("#"+crmPopupobj.divid).find('[name=is_active]').prop('checked',true);
                    ld("#"+crmPopupobj.divid).find('[name=btnposition]').prop('checked',true);
                    // 默认类型为工作流
                    var buttoninfo_arr = {'type': 'workflow'};
                    crmPopupobj.buttoninfo_arr = buttoninfo_arr;
                    that.pop_selected_tabid = ld("#"+crmPopupobj.divid).find('[name=selectmodule]').val();
                }else{
                    crmPopupobj.buttoninfo_arr = data.result.buttoninfo_arr;
                }
                // 用户字段多选框
                ld("#"+crmPopupobj.divid).find("[name=selectuserfields]").select2({closeOnSelect: true,dropdownParent:ld("#"+crmPopupobj.divid)});
                ld("#"+crmPopupobj.divid+" .select2").css('width',"100%");
                // 显示条件

                crmPopupobj.showvalues = data.result.showvalues;
                crmPopupobj.datetimestr = data.result.datetimestr;//基本查询
                crmPopupobj.viewnamelabel = data.result.viewnamelabel;
                crmPopupobj.modulelabel = data.result.modulelabel;

                var advanceFilterObj = new cls_advanceFilter();
                var params = {};
                that.advanceFilterObj = advanceFilterObj;
                params.columnOptionHtml = data.result.columns_block;
                params.fLabels = data.result.flabels;
                params.datetimestr = data.result.datetimestr;
                params.advfilterhtml = data.result.foption;
                params.fieldsinfo = data.result.fieldinfo;
                params.criteria_groups_arr = data.result.criteria_groups;
                params.module = 'Settings';
                // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
                params.advanceFields = data.result.advanceFields;
                advanceFilterObj.showAdvanceFilter(crmPopupobj,params);

                WorkflowCustomization.createbing();
                WorkflowCustomization.setSort();// 设置拖动
                that.editpopupobj = crmPopupobj;
                that.setPopupEvent();
            }else{

            }

        })
    }
    // 新增编辑弹出层绑定事件
    this.setPopupEvent = function(){
        var Popupobj = ld("#"+that.editpopupobj.divid);
        // 选择模块
        Popupobj.find("select[name=selectmodule]").off('change').on('change', function (event) {
            that.selectModule(this);
        });
    }
    // 选择模块
    this.selectModule = function(obj){
        var pop_selected_tabid = this.pop_selected_tabid = ld(obj).val();
        var Popupobj = ld("#"+that.editpopupobj.divid);
        Popupobj.find("[name=tabid]").val(pop_selected_tabid);
        Popupobj.find("[name=table_workflow_actions]").find(".dragtrrow").remove();
        var scrolltop = ld("#" + that.editpopupobj.divid + "_scroll").scrollTop();
        // 清空用户字段
        Popupobj.find("[name=selectuserfields]").val('');
        var effectivemethod = Popupobj.find("[name=effectivemethod]").val();
        var surl = this.surl;
        var param = {'selected_tabid': pop_selected_tabid,'mode': 'selectmodule','custombuttonadv': 'yes','effectivemethod': effectivemethod};
        ldAjaxNoProgress(surl,param,function (data){
            if(data.code == 1){
                // 重置模块的用户字段下拉框
                Popupobj.find("[name=selectuserfields]").html('');
                var optionhtml = '';
                ld.each(data.result.userfields_arr, function(fieldid, label) {
                    optionhtml += `<option value="` + fieldid + `">` + label + `</option>`;
                });
                Popupobj.find("[name=selectuserfields]").html(optionhtml);
                // 重置显示条件

                that.advanceFilterObj.changeAdvanceCondition('');

                // that.editpopupobj.highersearchobj = new HigherSearchGroup("adv_filter_div");
                // that.editpopupobj.highersearchobj.columns_block = data.result.columns_block;//查询字段
                // that.editpopupobj.highersearchobj.foption = data.result.foption;//查询条件下拉框的html
                // that.editpopupobj.highersearchobj.criteria_groups = data.result.criteria_groups;//高级查询
                // Popupobj.find("[name=adv_filter_div]").html(data.result.content);
                // Popupobj.find("[name=advft_criteria]").val('');
                // Popupobj.find("[name=advft_criteria_groups]").val('');
                // that.editpopupobj.highersearchobj.addNewConditionGroup();
                ld("#" + that.editpopupobj.divid + "_scroll").scrollTop(scrolltop);
            }else{

            }
        })
    }
    // 保存弹出层
    this.save = function(){
        if (that.advanceFilterObj.checkAdvancedFilter() == false) {// 检查高级条件
            return false;
        }
        var Popupobj = ld("#"+that.editpopupobj.divid);
        var is_active = Popupobj.find('[name=is_active]').prop('checked')?'yes':'no';
        var label_zh = Popupobj.find('[name=button_label_zh]').val();
        var label_en = Popupobj.find('[name=button_label_en]').val();
        if(empty(label_zh)){
            MessagePopup.TipOne_warning(arrJsPopLabel['CHINESEBLOCKNAMENOTEMPTY']);
            return false;
        }else if(empty(label_en)){
            MessagePopup.TipOne_warning(arrJsPopLabel['ENGLISHBLOCKNAMENOTEMPTY']);
            return false;
        }
        var description = Popupobj.find('[name=description]').val();
        // 获取选中的按钮位置
        var btnposition_obj = Popupobj.find('[name=btnposition]');
        var btnposition_arr = [];
        var btnposition_str = '';
        ld.each(btnposition_obj, function () {
            if(ld(this).prop('checked')){
                btnposition_arr.push(ld(this).data('name'));
            }
        });
        if(!empty(btnposition_arr)){
            btnposition_str = btnposition_arr.join(',');
        }
        var profileid_str = Popupobj.find('#role_name_tr').find("[name=user_role]").val();//获取角色权限id
        var userid_str = Popupobj.find('#username_tr').find("[name=userid]").val();//获取选中用户的id
        // 获取选中的用户字段字段id
        var userfieldid_arr = Popupobj.find("[name=selectuserfields]").val();
        console.log('userfieldid_arr: ', userfieldid_arr);
        var userfieldid_str = userfieldid_arr.join(',');
        // 显示条件
        var advft_criteria = that.advanceFilterObj.advft_criteria;
        var advft_criteria_groups = that.advanceFilterObj.advft_criteria_groups;

        var effectivemethod = Popupobj.find("[name=effectivemethod]").val();
        // 保存数据库的参数
        var params_arr = {
            'is_active': is_active,
            'label_zh': label_zh,
            'label_en': label_en,
            'description': description,
            'btnposition': btnposition_str,
            'profileid': profileid_str,
            'userid': userid_str,
            'userfieldid': userfieldid_str,
            'effectivemethod': effectivemethod,
            'advft_criteria': advft_criteria,
            'advft_criteria_groups': advft_criteria_groups,
            'type': that.editpopupobj.buttoninfo_arr['type'],
        };
        if(params_arr['type'] == 'workflow'){
            params_arr['related_id'] = ld("#"+that.editpopupobj.divid).find("[name=workflow_id]").val();
            // 请添加工作流操作！
            var trobjs = Popupobj.find("[name=table_workflow_actions] > tbody ").children("tr");
            var trobjs_firstadd = Popupobj.find("[name=table_workflow_actions] > tbody ").children("tr").eq(0).attr('workflow_actionid');//230413 wyt BUG0058823  kfbcrm 工作流程定制---新建时不添加工作流操作---保存时没有提示

            if (trobjs_firstadd == undefined || ld(trobjs).length == 0) {
                RemindsMsg("", "LdPopWidth400px", '', "yes", "", arrJsPopLabel['Pleaseaddworkflowoperation']);
                return false;
            }
            var workflowaction_arr = [];
            ld.each(trobjs, function () {
                if (ld(this).attr('workflow_actionid') > 0)
                    workflowaction_arr.push(ld(this).attr('workflow_actionid'));
            })
            var workflowaction_str = workflowaction_arr.join(",");
            params_arr['workflowactionids'] = workflowaction_str;
        }

        var surl = that.surl;
        var param = {
            'btnid': that.btnid,
            'selected_tabid': that.pop_selected_tabid,
            'mode': 'save',
        };
        
        param['params_arr'] = params_arr;
        console.log('param: ', param);

        ldAjaxNoProgress(surl,param,function (data){
            if(data.code == 1){
                that.editpopupobj.CancelEvent();
                that.refreshList();
            }
        })
    }
    // 自定义按钮点击事件
    this.buttonClick = function(position, module, record, btnid=""){
        var surl = this.surl;
        var param = {'btn_module': module,'mode': 'buttonclick','record': record,'btnid': btnid};
        ldAjax(surl,param,function (data){
            if(data.code == 1){
                // 刷新界面
                if (position == 'detail') {
                    var detailviewpopupobj = CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
                    var tmparra = [detailviewpopupobj.record];
                    var tmpdata = {};

                    var tmpobj = new AfterUpdatePrevPopupObjContent(module, data.result, tmparra);
                    tmpobj.eachrefreshDetailViewByModules([module]);
                    tmpobj.update();
                }
                else {
                    var tmparra = new Array();
                    var tmpobj = new AfterUpdatePrevPopupObjContent(module, "", tmparra);
                    var refreshlistmodules = new Array(module);
                    tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                }
                MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULOPERATION']);
                workflowCallApiPop(data.result);// 工作流API弹窗
                DelProgressObjs();
            }else{
                MessagePopup.TipOne_warning(data.msg);
            }
        });
    }
    // 删除自定义按钮
    this.delete = function(obj){
        var btnid = ld(obj).data('btnid');
        var targetobj = that.listdata_arr.find(item => item.btnid == btnid);
        
        if (targetobj) {
            var tabid = targetobj.tabid;
            var type = targetobj.type;
            var related_id = targetobj.related_id;
        }
        MessagePopup.TipTwo_warning(arrJsPopLabel['SUREWANTDELETE']);
        var popupobj = CrmPopup.getPopupObj('last');
        ld('#'+popupobj.divid).find('#'+popupobj.divid+'_btnok').unbind('click').on('click', function (event) {
            var surl = that.surl;
            var param = {'btnid': btnid,'selected_tabid': tabid,'mode': 'delete','type': type,'related_id': related_id};
            ldAjax(surl,param,function (data){
                if(data.code == 1){
                    that.refreshList();
                    DelProgressObjs();
                }else{

                }
            })
        })
    }
    // 启用/不启用 自定义按钮
    this.changeActive = function(obj){
        var btnid = ld(obj).data('btnid');
        var is_active = ld(obj).prop('checked')?'yes':'no';
        var targetobj = that.listdata_arr.find(item => item.btnid == btnid);
        
        if (targetobj) {
            var tabid = targetobj.tabid;
            var type = targetobj.type;
            var related_id = targetobj.related_id;
        }
        var surl = that.surl;
        var param = {'btnid': btnid,'selected_tabid': tabid,'mode': 'changeactive','is_active': is_active,'type': type,'related_id': related_id};
        ldAjaxNoProgress(surl,param,function (data){
            if(data.code == 1){
                
            }else{

            }
        })
    }
    
}












