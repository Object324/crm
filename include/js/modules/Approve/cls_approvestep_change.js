/*
* edit:duan
* reason:审批步骤变化事件
* date:20240920
*
* */
function cls_approvestep_change(popupobj,approve_fieldname_arr)
{
    //布局规则
    var that=this;
    that.popupobj=popupobj;
    this.main_approve_fieldname_arr=[];
    this.entry_approve_fieldname_arr=[];
    this.wait_line = 0;
    this.ajax_status = 'off';
    this.fieldchangetype = '';

    if(approve_fieldname_arr['main_fieldname']!=undefined){
        this.main_approve_fieldname_arr=approve_fieldname_arr['main_fieldname'];
    }
    if(approve_fieldname_arr['entry_fieldname']!=undefined){
        this.entry_approve_fieldname_arr=approve_fieldname_arr['entry_fieldname'];
    }
    this.user_fieldname_arr = [];

    that.values=[];
    
    this.set_approve_fieldname_arr = function (approve_fieldname_arr) {
        if(approve_fieldname_arr['main_fieldname']!=undefined){
            this.main_approve_fieldname_arr=approve_fieldname_arr['main_fieldname'];
        }
        if(approve_fieldname_arr['entry_fieldname']!=undefined){
            this.entry_approve_fieldname_arr=approve_fieldname_arr['entry_fieldname'];
        }
    }

    this.set_user_fieldname_arr = function (user_fieldname_arr) {
        if(empty(user_fieldname_arr))user_fieldname_arr = [];
        this.user_fieldname_arr = user_fieldname_arr;
    }

    //判断分录变化的触发字段
    this.checkentryfieldchange = function (obj,fieldname) {
        if(this.entry_approve_fieldname_arr.includes(fieldname)){
            this.fieldchangetype = 'entry';
            this.common_event();
        }
    }
    //判断分录变化的触发字段
    this.nocheckentryfieldchange = function () {
        if(this.entry_approve_fieldname_arr.length >0){
            this.fieldchangetype = 'entry';
            this.common_event();
        }
    }
    //判断表头变化的触发字段
    this.checkfieldchange = function (obj,fieldname) {
        if(this.main_approve_fieldname_arr.includes(fieldname)){
            this.fieldchangetype = 'main';
            this.common_event();
        }else if(this.user_fieldname_arr.includes(fieldname)){
            this.fieldchangetype = 'user';
            this.common_event();
        }
    }

    this.checkfieldexist = function (fieldname) {
        if(this.main_approve_fieldname_arr.includes(fieldname)){
            return 'yes';
        }else{
            return 'no';
        }
    }

    this.common_event = function () {
        if(this.ajax_status == 'on'){
            this.wait_line++;
        }else{
            this.ajax_status = 'on';
            setTimeout(function () {
                if(that.popupobj.pagetype == CreatePagePopup.pagetype){
                    //新增编辑界面，更新审批流程
                    that.getNewApproveInfo();
                }else{
                    //审批弹出界面，填写审批必填字段，更新审批步骤，审批人
                    that.getNewApproveStep();
                }
            },200);
        }
    }

    //新增编辑界面获取新的审批流程信息
    this.getNewApproveInfo = function () {
        this.wait_line = 0;
        this.ajax_status = 'on';
        var url = "index.php?module=Approve&action=ApproveAjax&file=getNewApproveInfo"
        var requestvalues = getPageValueByCrmPopupFieldsNew(this.popupobj);
        var param = {
            "requestvalues": (requestvalues['requestvalue']),
            "sensitiverequestfield": (requestvalues['sensitiverequestfield']),
            "frommodule": this.popupobj.module,
            "record": this.popupobj.record,
            "requestvalue_arr": requestvalues['requestvalue_arr']
        };
        var cur_approveinfo = {};
        var popupobj = this.popupobj;
        var popupdivid = popupobj.divid;
        cur_approveinfo['approveid'] = ld('#'+popupdivid + ' #approvevalue').val();
        param['cur_approveinfo'] = cur_approveinfo;

        var i = 0;
        var tmpurl = '';

        var detaildata_arr = getPageValueByCrmPopupAllProductDetail(popupobj);
        if(!empty(detaildata_arr)){
            param['detaildata_arr'] = detaildata_arr;
        }

        ldAjaxNoProgressWithError(url,param,function (data) {
            if(data.code == 1){
                var approve_arr = data.result.approve_arr;
                that.popupobj.approve_arr = approve_arr;

                if(approve_arr.length >0){
                    ld('#'+popupdivid + ' #popup_submit_head').show();
                    ld('#'+popupdivid + ' #popup_submit_content').show();
                    ld('#'+popupdivid + '_btnsavesubmit').show();
                }else{
                    ld('#'+popupdivid + ' #popup_submit_head').hide();
                    ld('#'+popupdivid + ' #popup_submit_content').hide();
                    ld('#'+popupdivid + '_btnsavesubmit').hide();
                }
                ld('#'+popupdivid + ' #popup_submit_content').html(data.result.approve_html);
                that.popupobj.center();
                that.popupobj.changeapproveEvent();
            }
            that.ajax_status = 'off';
            if(that.wait_line > 0){
                that.getNewApproveInfo();
            }
        },function (error_data) {
            if(error_data.code == 'ajax_error'){
                that.ajax_status = 'off';
                if(that.wait_line > 0){
                    that.getNewApproveInfo();
                }
            }
        })
    }
    //判断审批步骤根据界面上的字段条件变化
    this.getNewApproveStep = function () {
        this.wait_line = 0;
        this.ajax_status = 'on';
        var url = 'index.php?module=Approve&action=ApproveAjax&file=ApproveStep';
        var requestvalues = getPageValueByCrmPopupFieldsNew(this.popupobj);
        var param = {
            "requestvalues": (requestvalues['requestvalue']),
            "sensitiverequestfield": (requestvalues['sensitiverequestfield']),
            "fld_module": this.popupobj.module,
            "record": this.popupobj.record,
            "returnmodule": this.popupobj.module,
            "changestep":'yes',
            "requestvalue_arr": requestvalues['requestvalue_arr']
        };
        var cur_approveinfo = {};
        var popupobj = this.popupobj;
        var popupdivid = popupobj.divid;
        cur_approveinfo['stepid'] = ld('#'+popupdivid + ' [name=nextstep_0]').val();
        cur_approveinfo['approvestatus'] = ld('#'+popupdivid + ' [name=approvestatus]:checked').val();
        param['cur_approveinfo'] = cur_approveinfo;
        //除了通过并继续下一步和审批结束,其他情况不需要动态判断下一步审批
        if(cur_approveinfo['approvestatus']!= 1 && cur_approveinfo['approvestatus']!= 2){
            return '';
        }
        ldAjaxNoProgressWithError(url,param,function (data) {
            if(data.code == 1){
                var approveresult = data.result.approveresult;
                var nextsteps_arr = data.result.nextsteps_arr;
                var ended = data.result.ended;
                if(ended == 0){
                    if(cur_approveinfo['approvestatus'] == 1){
                        ld('#'+popupdivid + ' [name=procecess_table_2]').show();
                    }
                }else{
                    ld('#'+popupdivid + ' [name=procecess_table_2]').hide();
                    //修改条件后,有新的可流转的步骤,不直接跳到结束流程
                    if(cur_approveinfo['approvestatus'] == 2 && approveresult == 1){
                        ld('#'+popupdivid + ' #approvestatus2').prop('checked',false);
                        ld('#'+popupdivid + ' #approvestatus1').prop('checked',true);
                        cur_approveinfo['approvestatus'] = 1;
                    }
                }
                var nextstepid = 0;
                if(nextsteps_arr.length >0){
                    ld('#'+popupdivid + ' [name=procecess_head_1]').show();
                    ld('#'+popupdivid + ' [name=procecess_table_2]').find('td').css('padding-top','');
                    if(cur_approveinfo['approvestatus'] == 1){
                        ld('#'+popupdivid + ' [name=procecess_table_1]').show();
                    }
                    nextstepid = nextsteps_arr[0]['stepid'];

                    //如果请求前后的审批步骤相同,则不需要做处理
                    if(nextstepid != cur_approveinfo['stepid']){
                        var nextstepobj = ld('#'+popupdivid + ' [name=nextstep_0]');
                        nextstepobj.val(nextstepid);
                        ld('#'+popupdivid + ' [name=nextstepname_0]').val(nextsteps_arr[0]['stepname']);
                        //根据返回值更新审批人和相关参数
                        that.setNewApproveUser(data.result);
                        that.set_user_fieldname_arr(data.result.user_fieldname_arr);
                    }else{
                        if(that.fieldchangetype == 'user'){
                            that.setNewApproveUser(data.result);
                        }
                    }
                }else{
                    ld('#'+popupdivid + ' [name=procecess_table_2]').find('td').css('padding-top','0px');
                    ld('#'+popupdivid + ' [name=procecess_head_1]').hide();
                    ld('#'+popupdivid + ' [name=procecess_table_1]').hide();
                    //修改条件后,没有可流转的步骤,直接跳到结束流程
                    if(cur_approveinfo['approvestatus'] == 1 && approveresult == 2){
                        ld('#'+popupdivid + ' #approvestatus1').prop('checked',false);
                        ld('#'+popupdivid + ' #approvestatus2').prop('checked',true);
                    }
                }
                popupobj.center();
            }
            that.ajax_status = 'off';
            if(that.wait_line > 0){
                that.getNewApproveStep();
            }
        },function (error_data) {
            if(error_data.code == 'ajax_error'){
                that.ajax_status = 'off';
                if(that.wait_line > 0){
                    that.getNewApproveStep();
                }
            }
        })
    }

    this.setNewApproveUser = function(result){
        var divid = this.popupobj.divid;
        var popupobj = this.popupobj;
        var nextsetpbyuser=result['nextsetpbyuser'];
        var specifyapproverid=result['specifyapproverid'];
        var nextsetpby = result['nextsetpby'];
        var countersigner =  result['countersigner'];
        ld('#'+divid+' #userid_0').val(nextsetpby);
        var userids=nextsetpby.split(',');

        ld('#'+divid+' #userid_name_0').val(nextsetpbyuser);
        ld('#'+divid+' #userid_name_0').html(nextsetpbyuser);

        //edit:zkt 【审批，审批人添加框样式优化】--切换审批步骤
        var tmpuseridtonames = result['nextstepidtoname'];
        var ulhtml = '';
        var stepindex = 0;
        if(tmpuseridtonames != ''){

            ld.each(tmpuseridtonames,function (tmpid,tmpname) {
                ulhtml += "<li class='ld-input-inner-div-item' itemid='approver_"+stepindex+"_"+tmpid+"' title='"+tmpname+"'><span class='item-name'>"+tmpname+"</span>";
                if(parseInt(specifyapproverid)!=1){//修改本步骤的审批（1：否）
                    ulhtml += '<span class="remove-h" onclick="ApproveSelectApproverDiv_remove_oneuser(this,\'userid_'+stepindex+'\',\'userid_name_'+stepindex+'\')">×</span>';
                }
                ulhtml += '</li>';
            })

            var approverdivobj =ld('#before_approve_selectdiv_'+stepindex).find('div[name=approvers_div_'+stepindex+']');
            if(ld(approverdivobj).find('ul').length>0){
                ld(approverdivobj).find('ul').html(ulhtml);
                if(ld(approverdivobj).find('ul').next().length>0){
                    if(parseInt(specifyapproverid)==1){
                        ld(approverdivobj).find('ul').next().css('display','none');
                    }
                    else{
                        ld(approverdivobj).find('ul').next().css('display','');
                    }
                }
            }
        }else{
            var approverdivobj =ld('#before_approve_selectdiv_'+stepindex).find('div[name=approvers_div_'+stepindex+']');
            if(ld(approverdivobj).find('ul').length>0){
                ld(approverdivobj).find('ul').html(ulhtml);
                if(ld(approverdivobj).find('ul').next().length>0){
                    if(parseInt(specifyapproverid)==1){
                        ld(approverdivobj).find('ul').next().css('display','none');
                    }
                    else{
                        ld(approverdivobj).find('ul').next().css('display','');
                    }
                }
            }
        }
        ld("#"+popupobj.divid+" [tag=label_countersigner]").css('display','none');
        ld("#"+popupobj.divid+" [tag=label_approver]").css('display','none');
        if(countersigner=='yes'){
            ld("#"+popupobj.divid+" [tag=label_countersigner]").css('display','');
        }
        else{
            ld("#"+popupobj.divid+" [tag=label_approver]").css('display','');
        }
        if(parseInt(specifyapproverid)==1){//修改本步骤的审批（1：否）
            ld("#"+popupobj.divid+" #before_approve_select").css("display",'none');
        }
        else{
            // ld("#username_approver").css("display",'');
            ld("#"+popupobj.divid+" #before_approve_select").css("display",'');
        }
    }
}