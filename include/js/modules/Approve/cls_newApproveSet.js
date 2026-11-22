function cls_newApproveSet()
{
    //审批流程
    var that=this;
    this.tabid=ld("#pick_module").val();
    this.approvepopuphtml='';
    this.showpopupobj=undefined;
    this.module='';
    this.approvestepflowobj=undefined;
    this.approveid=0;
    this.showpopupobjtype='approveinfo';//显示信息类型（approveinfo:审批流程信息，approvestep：审批步骤流程
    this.approvedatainfo_arr=[];
    this.label_arr=[];
    this.editprofile = 'yes';//duan 20240801 判断当前模块是否可以编辑

    this.showapproveinfo=function()
    {
        var param={tabid:that.tabid}
        if(this.approvepopuphtml=='')
        {
            //wym 231225 BUG0077760 审批流程定制--弹窗修改为全屏弹窗
            this.popupobj=CrmPopup.load("","","",parseInt(CrmPopup.getClientWidth()),this.tabid,"","","","");
            this.popupobj.prevshow();
            var approveid=that.approveid;
        }
        else{
            if(that.approvedatainfo_arr.advancesearch!=undefined)
            {
                //如果条件查询不为空
                param['advancesearch']=that.approvedatainfo_arr.advancesearch;
                param['groupcondition']=that.approvedatainfo_arr.groupcondition;
            }
            var approveid=0;
        }

        ldAjax("index.php?module=Settings&action=SettingsAjax&file=newApproveSetShow&approveid="
            +approveid,param,function(ajaxdata){
            DelProgressObjs();
            if(that.approvepopuphtml=='')
                that.approvedatainfo_arr=ajaxdata.result.approvedatainfo;
            that.popuptitle=ajaxdata.result.title;
            that.label_arr=ajaxdata.result.label;
            that.ajaxdata=ajaxdata;
            datetimestr=ajaxdata.result.datetimestr;
            that.module=ajaxdata.result.module;
            that.popupobj.module = that.module;
            that.popupobj.fields = ajaxdata.result.fields;
            that.editprofile = ajaxdata.result.editprofile;

            that.showapprovehtml();

            var advancefilterobj = new cls_advanceFilter();
            that.advanceFilterobj = advancefilterobj;
            var params = {};
            params.columnOptionHtml = ajaxdata.result.columns_block;
            params.fLabels = ajaxdata.result.fLabels;
            params.datetimestr = ajaxdata.result.datetimestr;
            params.advfilterhtml = ajaxdata.result.foption;
            params.fieldsinfo = ajaxdata.result.fieldinfo;
            params.criteria_groups_arr = ajaxdata.result.criteria_groups_arr;
            params.module = that.module;
            params.fullscreen = 'yes';
            params.proportion = 2;
            // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
            params.advanceFields = ajaxdata.result.advanceFields;
            advancefilterobj.showAdvanceFilter(that.popupobj,params);

            /*
            edit:weiyannan
            date:2023-11-14
            reason:XUQIU1002049 系统穿梭框界面样式统一 后台设置--系统定制--审批流程定制--新建/编辑--设置已批准的单据允许编辑的字段--仅部分字段
            */
            var tem_Popupobj = CrmPopup.getPopupObj("last")
            getJsScript('include/js/DragTransfer.js', function () {
                var tableobj = ld('#' + tem_Popupobj.divid).find(" .dragtransfertable");
                var LeftObj = tableobj.find(" .commonMultipleSelect:first");
                var RightObj = tableobj.find(" .commonMultipleSelect:last");
                var Drag_Transfer = new DragTransfer();
                Drag_Transfer.SetDragTransfer(tableobj, LeftObj, RightObj, 'reset', '400');
            });
        })
    }
    this.setApproveId=function(approveid){
        this.approveid=approveid;
    }
    this.showapprovehtml=function() {
        this.popupobj.advanceSearchDivid = this.popupobj.divid;
        this.popupobj.setHeadTitle(this.popuptitle);

        var tablehtml = "<div class='E_pop_tit E_pop_tit_third'>";
        tablehtml += '<strong class="E_ptita" style="color:#333333;" >' + this.popuptitle + '</strong>';
        tablehtml += '<div class="flowstep" style="margin-left: 60px;">1</div><span style="float: left;line-height: 64px;margin: 0 10px;font-size: 16px;">' + this.label_arr.configbasicinfo + '</span><div style="width: 60px; border-bottom: 0.6mm dashed #3B7CFF;float: left;margin: 32px 18px 0 10px;"></div>';
        tablehtml += '<div class="flowstep" tag="secondstep" style="background-color: #999">2</div><span tag="secondstep" style="float: left;line-height: 64px;margin: 0 10px;font-size: 16px;">' + this.label_arr.configureprocess + '</span>';
        tablehtml += '<div class="E_pop_tit_Second_Right">';
        tablehtml += '<input type=\'button\' class=\'ld-button rfloat marR20\' name=\'startStepflow\' value="' + this.label_arr.next + '">';
        tablehtml += '    <div class="ld-fonticon ld-fonticon-close tip-items-pop" value="' + arrJsPopLabel['LBL_CLOSE'] + '" id="' + this.popupobj.divid + '_imgclosenew"></div>';
        tablehtml += '</div>';
        if (this.approveid > 0) {
            tablehtml += '<input type=\'button\' class=\'ld-button\' style=\'float: right;margin-top: 16px;margin-right: 12px;\' onclick="forceApproveRetStart(' + this.tabid + ',' + this.approveid + ');" name=\'submitapprove\' value="' + this.label_arr.forcedrejection + '">';
        }
        tablehtml += '</div>';
        tablehtml += '<table class="ld-public-content-paddingright" style="width:100%;table-layout: fixed;">';
        tablehtml += "<tbody>";
        tablehtml += " <tr><td style=\"width: 200px\"></td><td style=\"width: calc(100% - 200px)\"></td><td style=\"width: 200px\"></td><td style=\"width: calc(100% - 200px)\"></td></tr>";
        tablehtml += "<tr>";
        tablehtml += "<th class='ld-from-headblock' colspan='4'><div class=\"ld-from-headblock-title\">" + this.label_arr.basicinformation + "</div></th>";
        tablehtml += "</tr>";
        tablehtml += "<tr class='ld-form-item'>";
        tablehtml += "<td class='ld-form-item-label' ><font  color='red'>*</font>" + this.label_arr.name + "</td>";
        tablehtml += '<td class=\'ld-form-item-content\' ><input id="name" name="name" type="text" class="ld-input-inner" value="' + this.approvedatainfo_arr.name + '"> </td>';
        tablehtml += "<td class='ld-form-item-label' >" + this.label_arr.presence + "</td>";
        var onclickevent = "";
        if (this.approvedatainfo_arr.status == 0)
            tablehtml += '<td class=\'ld-form-item-content\' ><input ' + onclickevent + ' class="second_switch" name="status" type="checkbox" checked> </td>';
        else
            tablehtml += '<td class=\'ld-form-item-content\' ><input ' + onclickevent + ' class="second_switch" name="status" type="checkbox" > </td>';

        tablehtml += "</tr>";
        tablehtml += '<tr>';
        tablehtml += "<td class='ld-form-item-label'>" + this.label_arr.remark + "</td>";
        tablehtml += '<td class=\'ld-form-item-content\' colspan=3><textarea  class="ld-textarea-inner" style="height: 60px;" name="description">' + this.approvedatainfo_arr.description + '</textarea></td>';
        tablehtml += '</tr></tbody></table>';

        //高级配置
        tablehtml += '<table class="ld-public-content-paddingright" style="width:100%;margin: auto;"><tbody>';
        tablehtml += " <tr><td style=\"width: 300px\"></td><td style=\"width: calc(100% - 300px)\"></td><td style=\"width: 300px\"></td><td style=\"width: calc(100% - 300px)\"></td></tr>";
        tablehtml += "<tr><th class='ld-from-headblock' colspan='4'><div class=\"ld-from-headblock-title\">" + this.label_arr.HighConfig + "</div></th></tr>";
        //新建时默认流程/提交审批时默认流程
        tablehtml += '<tr class=\'ld-form-item\'>';
        tablehtml += "<td class='ld-form-item-label'>" + this.label_arr.default_on_new + "</td>";
        if (this.approvedatainfo_arr.default_on_new == 'yes')
            tablehtml += '<td class=\'ld-form-item-content\'><input class="second_switch" name="default_on_new" type="checkbox" checked> </td>';
        else
            tablehtml += '<td class=\'ld-form-item-content\'><input class="second_switch" name="default_on_new" type="checkbox" > </td>';

        tablehtml += "<td class='ld-form-item-label'>" + this.label_arr.default_on_submit + "</td>";
        if (this.approvedatainfo_arr.default_on_submit == 'yes')
            tablehtml += '<td class="ld-form-item-content"><input class="second_switch" name="default_on_submit" type="checkbox" checked> </td>';
        else
            tablehtml += '<td class="ld-form-item-content"><input class="second_switch" name="default_on_submit" type="checkbox" > </td>';
        tablehtml += '</tr>';

        //提交审批时是否显示审批意见/提交审批意见是否必填
        tablehtml += '<tr class=\'ld-form-item\'>';
        tablehtml += "<td class='ld-form-item-label'>" + this.label_arr.submitshowremark + "</td>";
        if (this.approvedatainfo_arr.showsubmitremark == 'yes')
            tablehtml += '<td class="ld-form-item-content"><input class="second_switch" name="showsubmitremark" type="checkbox" checked> </td>';
        else
            tablehtml += '<td class="ld-form-item-content"><input class="second_switch" name="showsubmitremark" type="checkbox" > </td>';
        tablehtml += "<td class='ld-form-item-label' tag='td_submitremarkrequire'>" + this.label_arr.approveremarkrequired + "</td>";
        tablehtml += '<td class="ld-form-item-content" tag="td_submitremarkrequire"><input class="second_switch" name="submitremarkrequire" type="checkbox" > </td>';
        tablehtml += '</tr>';

        //提交审批时是否加急/是否启用催审功能
        tablehtml += '<tr class=\'ld-form-item\'>';
        tablehtml += "<td class='ld-form-item-label'>" + this.label_arr.ShowUrgentWhenSubmit + "</td>";
        if (this.approvedatainfo_arr.showurgent == 'yes')
            tablehtml += '<td class="ld-form-item-content"><input class="second_switch" name="showurgent" type="checkbox" checked> </td>';
        else
            tablehtml += '<td class="ld-form-item-content"><input class="second_switch" name="showurgent" type="checkbox" > </td>';
        tablehtml += "<td class='ld-form-item-label'>" + this.label_arr.expeditingfunction + "</td>";
        if (this.approvedatainfo_arr.enableexpediting == 'yes')
            tablehtml += '<td class="ld-form-item-content"><input class="second_switch" name="enableexpediting" type="checkbox" checked> </td>';
        else
            tablehtml += '<td class="ld-form-item-content"><input class="second_switch" name="enableexpediting" type="checkbox" > </td>';
        tablehtml += '</tr>';

        //审批结束是否编辑/是否允许反审批
        tablehtml += '<tr class=\'ld-form-item\' ' + (this.editprofile == 'no' ? 'style="display:none;"' : '') + ' >';
        tablehtml += "<td style='border: none;' class='ld-form-item-label'>" + this.label_arr.finishedallowedit + "</td>";
        if (this.approvedatainfo_arr.finishedallowedit == 'yes')
            tablehtml += '<td style="border: none;" class="ld-form-item-content"><input class="second_switch" name="finishedallowedit" type="checkbox" checked> </td>';
        else
            tablehtml += '<td style="border: none;" class="ld-form-item-content"><input class="second_switch" name="finishedallowedit" type="checkbox" > </td>';
        tablehtml += "<td style='border: none;' tag='td_editresetapprove' class='ld-form-item-label'>" + this.label_arr.editdocumentresettheapproval + "</td>";
        if (this.approvedatainfo_arr.editresetapprove == 'no')
            tablehtml += '<td style="border: none;" tag=\'td_editresetapprove\' class="ld-form-item-content"><input class="second_switch" name="editresetapprove" type="checkbox" > </td>';
        else
            tablehtml += '<td style="border: none;" tag=\'td_editresetapprove\' class="ld-form-item-content"><input class="second_switch" name="editresetapprove" type="checkbox" checked> </td>';
        tablehtml += '</tr>';

        //审批结束是否编辑/是否允许反审批
        tablehtml += '<tr class=\'ld-form-item\'>';
        tablehtml += "<td style='border: none;' class='ld-form-item-label'>" + this.label_arr.allowcancel + "</td>";
        if (this.approvedatainfo_arr.allowantiapproval == '1')
            tablehtml += '<td style="border: none;" class="ld-form-item-content"><input class="second_switch" name="allowantiapproval" type="checkbox" checked> </td>';
        else
            tablehtml += '<td style="border: none;" class="ld-form-item-content"><input class="second_switch" name="allowantiapproval" type="checkbox" > </td>';
        tablehtml += '</tr>';

        //设置已批准的单据允许编辑的字段
        tablehtml += '<tr tag="tr_FinishedApproveAllowEditFieldSet">' +
            '<th colspan="4" class="f1 ld-from-headblock"><div class="ld-from-headblock-title">' + this.label_arr.FinishedApproveAllowEditFieldSet + '</div></th>';
        tablehtml += '</tr>';
        tablehtml += '<tr tag="tr_FinishedApproveAllowEditFieldSet">';
        tablehtml += '<td class="select-input" style="padding-left: 80px;" colspan="4">';
        if (this.approvedatainfo_arr.fininsedselectfieldtype == 'all')
            tablehtml += '<input type="radio" name="fininsedselectfieldtype" value="all" checked=""><label class="padR10">' + this.label_arr.AllFields + '</label>';
        else
            tablehtml += '<input type="radio" name="fininsedselectfieldtype" value="all" ><label class="padR10">' + this.label_arr.AllFields + '</label>';
        if (this.approvedatainfo_arr.fininsedselectfieldtype == 'part')
            tablehtml += '<input type="radio" name="fininsedselectfieldtype" checked value="part"><label class="padR10">' + this.label_arr.PartialFields + '</label>';
        else
            tablehtml += '<input type="radio" name="fininsedselectfieldtype"   value="part"><label class="padR10">' + this.label_arr.PartialFields + '</label>';
        tablehtml += '</td>'
        tablehtml += '</tr>';
        tablehtml += '<tr name="tr_FinishedApproveAllowEditFieldSet">';
        tablehtml += '<td colspan="4">';
        tablehtml += '<table class="lasttdbordernon dragtransfertable" cellspacing="0" cellpadding="0" border="0" style="width: auto;margin: 10px auto;" >';
        tablehtml += '<tr><td class="padTB10" width="355">';
        tablehtml += '<b>' + this.label_arr.optionfield + '</b><br>';
        //wyt 221215 BUG0059774 审批流程定制，新建审批流，设置审批结束允许编辑部分字段，点击可选字段搜索框时，“请输入要查找的字段”提示信息没有自动隐藏
        tablehtml += '<input class="detailedViewTextBox" style="width:345px;margin-top: 5px;" type="text" onkeyup="cls_input_select.getInstance(\'field\')._onkeyup(this,\'AssmablyList\',event)"  placeholder="' + this.label_arr.entersearchfieldlabel + '" name="allmember"><br>';
        //可以编辑字段-》选择字段
        tablehtml += '<select style="height: 180px;width:345px;margin-top: 10px;" class="commonMultipleSelect" name="AssmablyList" id="AssmablyList" ondblclick="addColumnCustomviewModule(\'AssmablyList\',\'selectedAssmablyColumns\')" multiple="">';
        ld.each(this.approvedatainfo_arr.finishedalloweditallfields, function (tmpvalue, tmplabel) {
            var isfind = 'no';
            ld.each(that.approvedatainfo_arr.finishedalloweditchoosefield, function (chooseindex, chooseinfo) {
                if (chooseinfo.value == tmpvalue) {
                    isfind = 'yes';
                    return false;
                }
            })
            if (isfind == 'yes')
                return true;
            tablehtml += '<option value="' + tmpvalue + '">' + tmplabel + '</option>';
        })
        tablehtml += ' </select>';
        tablehtml += '</td>';
        tablehtml += '<td width="45">';
        tablehtml += '<a class="icon-newhomearr icon-mright" href="javascript:;" onclick="copySelectedOptionsCustomviewModule(\'AssmablyList\',\'selectedAssmablyColumns\');" title="' + this.label_arr.moveright + '"></a><br>';
        tablehtml += '<a class="icon-newhomearr icon-mleft" style="margin-top:15px;" href="javascript:;" onclick="copySelectedOptionsCustomviewModule(\'selectedAssmablyColumns\',\'AssmablyList\');" title="' + this.label_arr.moveleft + '"></a>';
        tablehtml += '</td>';
        tablehtml += '<td class="padTB10" width="355">';
        tablehtml += '<b>' + this.label_arr.Selected_Fields + '</b><br><br><br>';
        tablehtml += '<select size="11" style="height: 180px;width:345px;margin-top: 10px;" class="commonMultipleSelect" name="selectedAssmablyColumns" id="selectedAssmablyColumns" ondblclick="addColumnCustomviewModule(\'selectedAssmablyColumns\',\'AssmablyList\')" multiple="">';
        //审批结束允许编辑的字段已选择字段
        ld.each(this.approvedatainfo_arr.finishedalloweditchoosefield, function (tmpindex, tmpinfo) {
            tablehtml += '<option value="' + tmpinfo.value + '" >' + tmpinfo.label + '</option>';
        })
        tablehtml += '</select>';
        tablehtml += '</td>';
        tablehtml += '<td width="45">';
        tablehtml += '<a class="icon-newhomearr icon-mup" href="javascript:;" onclick="ProductDetailmoveUp();" title="' + this.label_arr.moveup + '"></a><br>';
        tablehtml += '<a class="icon-newhomearr icon-mdown" style="margin-top:15px;" href="javascript:;" onclick="ProductDetailmoveDown();" title="' + this.label_arr.movedown + '"></a>';
        tablehtml += '</td>'
        tablehtml += '</tr>';
        tablehtml += '</table>';
        tablehtml += '</td></tr>';

        //设置可编辑字段的适用范围
        tablehtml += '<tr tag="tr_FinishedApproveAllowEditFieldSet">';
        tablehtml += '<td class="ld-form-item-label" style="border: none;">' + this.label_arr.SetAllowEidtFieldScope + '</td>';
        tablehtml += '<td class="ld-form-item-content" style="border: none;" colspan="3" class="select-input">';
        //设置可编辑字段的适用范围
        if (this.approvedatainfo_arr.finishedfield_allocatetype == 'all')
            tablehtml += '<label class="padR10"><input type="radio"  style="margin-right: 10px"  name="finishededittype" value="all" checked="checked">' + this.label_arr.alluser + '</label>';
        else
            tablehtml += '<label class="padR10"><input type="radio" style="margin-right: 10px" name="finishededittype" value="all" >' + this.label_arr.alluser + '</label>';
        if (this.approvedatainfo_arr.finishedfield_allocatetype == 'group')
            tablehtml += ' <label class="padR10"><input type="radio" style="margin-right: 10px" name="finishededittype" checked value="group">' + this.label_arr.bydept + '</label>';
        else
            tablehtml += '<label class="padR10"><input type="radio" style="margin-right: 10px" name="finishededittype"  value="group">' + this.label_arr.bydept + '</label>';
        if (this.approvedatainfo_arr.finishedfield_allocatetype == 'user')
            tablehtml += ' <label class="padR10"><input type="radio" style="margin-right: 10px" name="finishededittype" checked value="user">' + this.label_arr.byuser + '</label>';
        else
            tablehtml += ' <label class="padR10"><input type="radio" style="margin-right: 10px" name="finishededittype"  value="user">' + this.label_arr.byuser + '</label>';
        if (this.approvedatainfo_arr.finishedfield_allocatetype == 'role')
            tablehtml += '<label class="padR10"><input type="radio" style="margin-right: 10px" name="finishededittype" checked value="role">' + this.label_arr.byrole + '</label>';
        else
            tablehtml += '<label class="padR10"><input type="radio" style="margin-right: 10px" name="finishededittype" value="role">' + this.label_arr.byrole + '</label>';
        tablehtml += '<label class="padR10"><input type="hidden" id="selectfinishededitid" name="selectfinishededitid"  value="' + this.approvedatainfo_arr.finishedfield_allocateid + '">';
        tablehtml += ' <label class="padR10"><input type="hidden" id="selectfinishededittype" name="selectfinishededittype" value="' + this.approvedatainfo_arr.finishedfield_allocatetype + '"></td>';
        tablehtml += ' </tr>';

        //适用提交人范围
        tablehtml += '<tr><th class="ld-from-headblock" colspan="4"><div class="ld-from-headblock-title">' + this.label_arr.ApplicatesubmitScope + '</div></th></tr>';
        tablehtml += '<tr>';
        tablehtml += '<td class="ld-form-item-label" style="border: none;">' + this.label_arr.applicablescope + '</td>';
        tablehtml += '<td class="ld-form-item-content" style="border: none;" colspan="3" id="allocate_divcontent" class="select-input">';
        var selectallocatetype = this.approvedatainfo_arr.approveallocatetype;
        var approvelocateid = this.approvedatainfo_arr.approveallocateid;
        if (this.approvedatainfo_arr.approveallocatetype == '0')
            tablehtml += '<label class="padR10"><input type="radio" style="margin-right: 10px" name="radiotype" value="0"  checked>' + this.label_arr.alluser + ' </label>';
        else
            tablehtml += ' <label class="padR10"><input type="radio" style="margin-right: 10px" name="radiotype" value="0"  >' + this.label_arr.alluser + ' </label>';
        if (this.approvedatainfo_arr.approveallocatetype == '1')
            tablehtml += '<label class="padR10"><input type="radio" style="margin-right: 10px" name="radiotype" value="1" checked>' + this.label_arr.bydept + '</label>';
        else
            tablehtml += '<label class="padR10"><input type="radio" style="margin-right: 10px" name="radiotype" value="1" >' + this.label_arr.bydept + '</label>';
        if (this.approvedatainfo_arr.approveallocatetype == '2')
            tablehtml += '<label class="padR10"><input type="radio" style="margin-right: 10px" name="radiotype" value="2" checked>' + this.label_arr.byuser + '</label>';
        else
            tablehtml += '<label class="padR10"><input type="radio" style="margin-right: 10px" name="radiotype" value="2" >' + this.label_arr.byuser + '</label>';
        if (this.approvedatainfo_arr.approveallocatetype == '3')
            tablehtml += '<label class="padR10"><input type="radio" style="margin-right: 10px" name="radiotype" value="3" checked>' + this.label_arr.byrole + '</label>';//wym BUG0077670 审批流定制 编辑 按角色 选择适用提交人范围的审批流程 点击按角色文字没有反应
        else
            tablehtml += '<label class="padR10"><input type="radio" style="margin-right: 10px" name="radiotype" value="3" >' + this.label_arr.byrole + '</label>';
        tablehtml += '<input type="hidden" id="selectallocateid" name="selectallocateid"  value="' + approvelocateid + '">' +
            '<input type="hidden" id="selectallocatetype" name="selectallocatetype"  value="' + selectallocatetype + '">';
        tablehtml += '</td>';
        tablehtml += '</tr>';
        //tablehtml+='<tr><th  class="newtablethtitle" colspan="4">'+this.label_arr.applicablescope+'</th></tr>';
        tablehtml += "</tbody>";
        tablehtml += '</table>';

        if (that.approvepopuphtml == '')
            CrmPopup.setPopupobjHtmlContent_scroll_jquery(that.popupobj, that.ajaxdata.result.content);
        else
            ld("#" + newApproveSetObj.popupobj.divid + "_scroll").html(that.ajaxdata.result.content);
        ld("#" + that.popupobj.divid + " [name=dvtable]").html(tablehtml);
        that.setApproveEvent();
        that.setfishedallowedit();
        that.setsubmitremarkrequired();
        ld("#" + that.popupobj.divid + " [name=pop_adv_filter_div]").css("max-height", 'none')
        //duan 在高级查询条件的列头中加入标题
        var titlecontent = '<th class="ld-from-headblock" colspan="4" ><div class="ld-from-headblock-title">' + this.label_arr.applicablescope + '</div></th>';
        var tableobj = ld("#" + that.popupobj.divid + " [name=pop_adv_filter_div]").children('table');
        ld(tableobj).removeClass('settingPopTable');
        ld(titlecontent).prependTo(tableobj.find('tr'));
        if (tableobj.find('tr th').length > 1) {//wym 240112 XUQIU1001873 把高级查找的标题和按钮放在同一行
            tableobj.find('tr th.ld-from-headblock').html('<div class="ld-from-headblock-title">' + arrJsPopLabel['APPLICABLESCOPE'] + '<input type="button" class="ld-button ld-button-primary" value="' + arrJsPopLabel['NEWCOMBINATION'] + '" onclick="New_addNewConditionGroup(\'pop_adv_filter_div\');" style="float: right;margin-top:-6px"></div>');
            tableobj.find('tr th').eq(1).remove();
        }
        ld(tableobj).prependTo(tableobj.parent().parent());
        ld("#" + that.popupobj.divid + " [name=pop_adv_filter_div]").css('width', (CrmPopup.getClientWidth() * 0.8 - 130) + 'px');
        ld("#" + that.popupobj.divid + " [name=pop_adv_filter_div]").css('margin-left', '80px');
        //duan 隐藏原有头部，并设置新的头部点击事件
        ld('#' + this.popupobj.divid + '_head').hide();
        ld('#' + this.popupobj.divid + '_scroll').css('max-height', CrmPopup.getClientHeight() + 'px');
        //wym 231225 BUG0077760 审批流程定制--弹窗修改为全屏弹窗
        ld('#' + this.popupobj.divid + '_scroll').css('height', CrmPopup.getClientHeight() + 'px');
        ld("#" + that.popupobj.divid + "_imgclosenew").unbind('click').bind('click', function () {
            that.popupobj.CancelEvent();
        })
        that.popupobj.center();
    }

    this.setApproveEvent = function () {
        ld("#" + that.popupobj.divid + " [name=status]").unbind("click").bind("click", function () {
            //是否启用
            if (that.approveused == 'yes') {
                MessagePopup.TipOne_warning(arrJsPopLabel['PROCESSUSEDCANOTMODIFIED']);
                ld(this).prop("checked",!ld(this).prop("checked"));
            }else{
                that.approvedatainfo_arr.status=1;
                if(ld(this).prop("checked")){
                    that.approvedatainfo_arr.status=0;
                }
            }
        })
        ld("#"+this.popupobj.divid+" [name=default_on_submit]").unbind("click").bind("click",function(){
            that.approvedatainfo_arr.default_on_submit='no';
            if(ld(this).prop("checked"))
            {
                that.approvedatainfo_arr.default_on_submit='yes';
            }
        })
        ld("#"+this.popupobj.divid+" [name=default_on_new]").unbind("click").bind("click",function(){
            //是否新建时默认流程
            that.approvedatainfo_arr.default_on_new='no';
            if(ld(this).prop("checked"))
            {
                that.approvedatainfo_arr.default_on_new='yes';
            }
        })
        //是否显示审批意见
        ld("#"+that.popupobj.divid+" [name=showsubmitremark]").unbind("click").bind("click",function(){
            if(ld(this).prop("checked"))
            {
                that.approvedatainfo_arr.showsubmitremark='yes';
            }
            else
                that.approvedatainfo_arr.showsubmitremark='no';
            that.setsubmitremarkrequired();
        })
        ld("#"+that.popupobj.divid+" [name=submitremarkrequire]").unbind("click").bind("click",function(){
            //审批意见是否必填
            if(ld(this).prop("checked"))
            {
                that.approvedatainfo_arr.submitremarkrequire='yes';
            }
            else
                that.approvedatainfo_arr.submitremarkrequire='no';
        })
        ld("#"+that.popupobj.divid+" [name=showurgent]").unbind("click").bind("click",function(){

            that.approvedatainfo_arr.showurgent='no';
            if(ld(this).prop("checked"))
            {
                //提交审批时是否显示加急选项
                that.approvedatainfo_arr.showurgent='yes';
            }
        })
        ld("#"+that.popupobj.divid+" [name=enableexpediting]").unbind("click").bind("click",function(){
            that.approvedatainfo_arr.enableexpediting='no';
            if(ld(this).prop("checked"))
            {//是否启用催审功能
                that.approvedatainfo_arr.enableexpediting='yes';
            }
        })
        ld("#"+that.popupobj.divid+" [name=allowantiapproval]").unbind("click").bind("click",function(){
            that.approvedatainfo_arr.allowantiapproval='0';
            if(ld(this).prop("checked")) {
                that.approvedatainfo_arr.allowantiapproval='1';
            }
        })
        ld("#"+that.popupobj.divid+" [name=finishedallowedit]").unbind("click").bind("click",function(){
            that.approvedatainfo_arr.fininsedselectfieldtype='all';
            //审批结束是否允许编辑单据
            if(ld(this).prop("checked"))
                that.approvedatainfo_arr.finishedallowedit='yes';
            else
                that.approvedatainfo_arr.finishedallowedit='no';
            that.setfishedallowedit();
        })
        ld("#"+this.popupobj.divid+" [name=fininsedselectfieldtype]").unbind("click").bind("click",function(){
            that.approvedatainfo_arr.fininsedselectfieldtype=ld(this).val();
            that.setfishedallowedit();
        })
        ld("#"+this.popupobj.divid+" [name=editresetapprove]").unbind("click").bind("click",function(){
            that.approvedatainfo_arr.editresetapprove='no';
            if(ld(this).prop("checked")) {
                that.approvedatainfo_arr.editresetapprove='yes';
            }
        })
        var module=that.module;
        ld("#"+this.popupobj.divid+" [name=finishededittype]").unbind("click").bind("click",function(){
            //设置已批准可编辑字段的适用范围
            that.approvedatainfo_arr.finishedfield_allocatetype=ld(this).val();
            that.setchooseScopePopup(ld(this),ld(this).val());
        })
        ld("#"+this.popupobj.divid+" [name=radiotype]").unbind("click").bind("click",function(){
            //设置审批流程适用范围
            that.approvedatainfo_arr.approveallocatetype=ld(this).val();
            if(ld(this).val()==1)
                var selectvalue='group';
            else if(ld(this).val()==2)
                var selectvalue='user'
            else if(ld(this).val()==3)
                var selectvalue='role'
            that.setchooseScopePopup(ld(this),selectvalue);
        })
        ld("#"+this.popupobj.divid+" [name=startStepflow]").unbind("click").bind("click",function(){
            //审批流程界面下一步
            that.approvepopuphtml=ld("#"+that.popupobj.divid).html();
            var approvename=ld("#"+that.popupobj.divid+" [name='name']").val();
            //判断流程名称不能为空
            if (approvename.replace(/^\s+/g, '').replace(/\s+$/g, '').length == 0) {
                var confirm_str = arrJsPopLabel['PROCESSNAMECANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                ld('form input[name=name]').focus();
                return false;
            }
            that.approvedatainfo_arr.name = approvename;

            that.approvedatainfo_arr.description=ld("#"+that.popupobj.divid+" [name='description']").val();
            if(that.approvedatainfo_arr.finishedallowedit=='yes')
            {
                if(that.approvedatainfo_arr.fininsedselectfieldtype=='part')
                {
                    that.approvedatainfo_arr.finishedalloweditchoosefield=[];
                    ld.each(ld("#"+that.popupobj.divid+" [name=selectedAssmablyColumns]").find("option"),function(tmpindex,tmpinfo){
                        that.approvedatainfo_arr.finishedalloweditchoosefield.push({'value':ld(tmpinfo).val(),'label':ld(tmpinfo).text()});
                    })
                }
            }

            that.approvedatainfo_arr.description=ld("#"+that.popupobj.divid+" [name='description']").val();

            if(!that.advanceFilterobj.checkAdvancedFilter()) return false;
            var popupobj=CrmPopup.getPopupObj('last');
            that.approvedatainfo_arr.advancesearch = '';
            that.approvedatainfo_arr.groupcondition = '';
            if(popupobj.advft_criteria!=undefined) {
                that.approvedatainfo_arr.advancesearch = popupobj.advft_criteria;
                that.approvedatainfo_arr.groupcondition = popupobj.advft_criteria_groups;
            }
            getJsScript('include/js/modules/Approve/cls_ApproveStepFlow.js',function(){
                if(that.approvestepflowobj==undefined) {
                    that.approvestepflowobj=new cls_ApproveStepFlow();
                }
                that.approvestepflowobj.show();
                that.approvestepflowobj.approveused = that.approveused;
                that.approvestepflowobj.editprofile = that.editprofile;
            })
        })
        //点击数字2 进入下一步
        ld('#'+that.popupobj.divid+" [tag=secondstep]").off('click').on('click',function () {
            ld('#'+that.popupobj.divid+" [name=startStepflow]").click();
        });
    }

    this.setchooseScopePopup=function(jqueryobj,selectvalue){
        var module=that.module;
        var popup_user_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user&checkprivilege=no';
        var popup_groups_url ='module=Users&action=UsersAjax&file=viewuserinfo&view=private&fld_module='+module+'&selecttype=group&popup_inputtype=checkbox&popup_selecttype=group';
        var popup_role_url ='module=Users&action=UsersAjax&file=viewprofileinfo&view=private&fld_module='+module+'&popup_selecttype=profile&popup_inputtype=checkbox';
        if(selectvalue=='user'||selectvalue=='group'||selectvalue=='role')
        {
            getJsScript('include/js/ScopePopup/ScopePopupObj.js',function()
            {
                scopepopupobj =  new ScopePopupObj(module);
                scopepopupobj.popup_caption_value = arrJsPopLabel['APPLICABLESCOPE'];//标题title
                scopepopupobj.popup_header =  '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'></div><div id="selectUserCheck"><input type="checkbox" id=\'viewuser_disableuser\'><label for="viewuser_disableuser">'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
                scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认显示内容

                getJsScript('include/js/ScopePopup/ScopePopup.js',function()
                {
                    cls_ScopePopup.popup_selecttype = ld(jqueryobj).val();
                    cls_ScopePopup.prop.popup_module = module;//模块
                    if(ld(jqueryobj).attr("name")=="finishededittype")
                        cls_ScopePopup.prop.popup_value = ld("#"+that.popupobj.divid+" [name=selectfinishededitid]").val();
                    else
                        cls_ScopePopup.prop.popup_value = ld("#"+that.popupobj.divid+" [name=selectallocateid]").val();
                    if(selectvalue=='user')
                    {
                        cls_ScopePopup.prop.popup_url = popup_user_url;
                        scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox"><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
                    }
                    else if(selectvalue=='group')
                    {
                        scopepopupobj.popup_searchvalue=arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];
                        cls_ScopePopup.prop.popup_url = popup_groups_url;
                        scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox"><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
                    }
                    else
                    {
                        cls_ScopePopup.prop.popup_url = popup_role_url;
                        scopepopupobj.popup_searchvalue=arrJsPopLabel['pleaseenterprofile'];
                        scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'></div>';
                    }
                    var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
                    var parentsetEventBtnCancel=scopepopupobj.setEventBtnCancel;

                    //重写确认按钮事件
                    scopepopupobj.setEventBtnOk=function(){
                        ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                            //ls 2022-02-07 0049886: 系统设置》审批流程定制》合同订单，新增审批流，设置可编辑字段的适用范围时，弹窗中直接点击确认，没有提醒“至少选择一个部门/成员”
                            var selected_groupid = cls_ScopePopup.return_obj.return_id;//选中的部门id

                            if(empty(selected_groupid)){
                                if(selectvalue == 'group'){
                                    confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
                                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                    return false;
                                }else{
                                    confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                    return false;
                                }
                            }

                            ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                            var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                            if(ld(jqueryobj).attr("name")=="finishededittype")
                            {
                                ld('#'+that.popupobj.divid+" [name=selectfinishededitid]").val(selected_user);
                                ld('#'+that.popupobj.divid+" [name=selectfinishededittype]").val(selectvalue);
                                that.approvedatainfo_arr.finishedfield_allocateid=selected_user;//
                            }
                            else{
                                ld('#'+that.popupobj.divid+" [name=selectallocateid]").val(selected_user);
                                ld('#'+that.popupobj.divid+" [name=selectallocatetype]").val(ld("#"+that.popupobj.divid+" [name=radiotype]:checked").val());
                                that.approvedatainfo_arr.approveallocateid=selected_user;
                                that.approvedatainfo_arr.approveallocatetype=ld('#'+that.popupobj.divid+" [name=selectallocatetype]").val();

                            }
                            return false;
                        });
                    }
                });
            });
        }
    }
    this.setfishedallowedit=function()
    {
        //允许编辑字段
        ld("#"+that.popupobj.divid+" [tag=tr_FinishedApproveAllowEditFieldSet]").css('display','none');
        ld("#"+that.popupobj.divid+" [name=tr_FinishedApproveAllowEditFieldSet]").css('display','none');
        ld("#"+this.popupobj.divid+" [tag=td_editresetapprove]").css('display','none');
        if(that.approvedatainfo_arr.finishedallowedit=='yes')
        {
            ld("#"+this.popupobj.divid+" [tag=td_editresetapprove]").css('display','');
            ld("#"+that.popupobj.divid+" [tag=tr_FinishedApproveAllowEditFieldSet]").css('display','');
            if(that.approvedatainfo_arr.fininsedselectfieldtype=='part')
            {
                ld("#"+that.popupobj.divid+" [name=tr_FinishedApproveAllowEditFieldSet]").css('display','');
            }
        }
    }
    this.setsubmitremarkrequired=function()
    {
        ld("#"+this.popupobj.divid+" td[tag=td_submitremarkrequire]").css("display",'none');
        if(this.approvedatainfo_arr.showsubmitremark=='yes')
        {
            ld("#"+this.popupobj.divid+" td[tag=td_submitremarkrequire]").css("display",'');
            if(this.approvedatainfo_arr.submitremarkrequire =='yes')
            {
                ld("#"+this.popupobj.divid+"  [name=submitremarkrequire]").prop("checked",true)
            }
        }
        else{
            this.approvedatainfo_arr.submitremarkrequire='no';

            ld("#"+this.popupobj.divid+"  [name=submitremarkrequire]").prop("checked",false)
        }
    }
}
var newApproveSetObj;
cls_newApproveSet.getObj=function()
{
    //if(newApproveSetObj==undefined)
    newApproveSetObj= new cls_newApproveSet();
    return newApproveSetObj;
}
var datetimestr;