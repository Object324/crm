function SeniorAllocateShare(module,mode,viewtype='list'){
    var that=this;
    this.module = module;
    this.mode = mode;// 分配，平均分配，共享
    this.viewtype = viewtype;// 界面，listview,detailview
    this.recordid = '';// 单条单据id
    this.popupobj = '';
    this.selected_ids = '';// 所选单据id
    this.rows_num = 0;// 所选单据数量
    this.cls_ScopePopup = new Object();
    this.excluded_records = '';
    // this.selected_user = '';// 所选用户
    this.getPopup = function(recordid=''){
        this.recordid = recordid;
        var rows_num = 0;
        if(empty(recordid)){
            List_CheckBox_Ids.getIds(module);
            this.selected_ids = List_CheckBox_Ids.ids;// 列表界面所选单据id
            this.rows_num = parseInt(List_CheckBox_Ids.num_rows);// 单据数量
            if(this.rows_num == 1){
                this.recordid = this.selected_ids;
            }
        }else{
            this.selected_ids = recordid;
            this.rows_num = 1;
        }
        rows_num = this.rows_num;

        if(rows_num >parseInt(getMaxMassOperationLimit())){
            var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',rows_num,getMaxMassOperationLimit(),'');
            //创建提示弹出层
            RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);
            //确定事件
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                that.setHtml();
            });
        }else{
            this.setHtml();
        }
    }
    // 弹出层页面内容
    this.setHtml = function (){
        var mode = this.mode;
        var module = this.module;
        var recordid = this.recordid;

        var Popupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
        Popupobj.prevshow();
        var urlstring = 'module=Users&action=UsersAjax&file=SeniorAllocateShare&mode='+mode+'&frommodule='+module;

        var selected_ids = this.selected_ids;// 列表界面所选单据id
        var rows_num = this.rows_num;// 单据数量
        this.excluded_records = ld('#excludedRecords').val();

        if(!empty(recordid)){
            urlstring += '&recordid='+recordid;
        }
        // 判断至少选择一条单据
        if(empty(recordid) && rows_num < 1){
            var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
            MessagePopup.TipOne_warning(confirm_str);
            return false;
        }
        ldAjaxNoProgress('index.php?',urlstring,function (data) {
            if (data.code == 1) {
                Popupobj.setParams(data.result.title, that.confirmEvent, "", "LdPopWidth600px", module, "", data.result.oktext, "", data.result.canceltext);

                var labelarr = data.result.label_arr;
                var otherlabel = data.result.otherlabel;
                var table_html = '<div class="ld-pop-container-second">';

                if(mode == "seniorShare") {// 选择多条单据时，需要选共享类型
                    // 共享设置
                    table_html += `<div class="pad10">
                                        <div class="ld-pop-contnet-title-items">
                                            <div class="ld-pop-contnet-title-item">`+otherlabel.headblock.sharesettings+`</div>
                                        </div>
                                   </div>`
                    table_html +='<div style="padding:6px 10px 10px 10px;">'
                                    +'<div class="select-input"><label style="padding-left:0;">' + arrJsPopLabel['TYPE']+'：</label>'
                                        +'<input type="radio" name="share_type" id="share_type_add" value="add" checked="checked"/><label for="share_type_add" class="padR10">'+arrJsPopLabel['SUPERADDTION']+'</label>'
                    if(data.result.share_type_onlyadd != 'yes'){
                        table_html +='<input type="radio" name="share_type" id="share_type_cover" value="cover"/><label for="share_type_cover" class="padR10">'+arrJsPopLabel['REPLACE']+'</label>'
                                    +'<input type="radio" name="share_type" id="share_type_cancel" value="cancel_share"/><label for="share_type_cancel" class="padR10">'+arrJsPopLabel['CANCELSHARE']+'</label>';
                    }
                    //弹框右上角友情帮助Tips
                    if(document.getElementById('oem_crm') != undefined){
                        var oem_crm = document.getElementById('oem_crm').value;
                        if(oem_crm == 'no'){
                            table_html += '<a class="rfloat" href="javascript:;" style="margin-right: 15px;margin-top: -4px;" onclick="getLinksUrl(\'\',\'Share\',\'module_list_share\');">'+arrJsPopLabel['ONLINEHELP']+'</a>';
                        }
                    }
                    table_html += '</div>';
                    table_html += '<div class="select-input padT16"><label style="padding-left:0;">'+arrJsPopLabel['EXPLAIN']+'：</label><label id="share_type_remind">'+arrJsPopLabel['SHARETYPEADD']+'</label></div>'
                    table_html += '</div>';

                    Popupobj.selected_user = data.result.selected_user;
                }else{
                    // 负责人设置
                    table_html += `<div class="pad10">
                                        <div class="ld-pop-contnet-title-items">
                                            <div class="ld-pop-contnet-title-item">`+otherlabel.headblock.smownersettings+`</div>
                                        </div>
                                   </div>`
                }
                
                // 选人
                table_html += `<table class="ld-public-content-small" style="padding: 6px 10px 20px 10px;" border="0" cellpadding="0" cellspacing="0" width="100%">`
                                +`<tr>`
                                    +`<td class="ld-form-item-label" id="selectusers_label">`;
                if(mode == "seniorShare")
                    table_html +=arrJsPopLabel['AddSharers'];
                else
                    table_html +=labelarr.selectusers;
                table_html +=`</td>`
                            +`<td class="ld-form-item-content">`
                                +`<div style="display:flex;">`
                                    +`<div class="ld-input-inner-div ld-input-inner-add" id="selectusers" name="selectusers" style="overflow: hidden;text-overflow: ellipsis;vertical-align:middle;display:inline-block;margin:0" value="">`+data.result.userfullnames+`</div>`
                                    +`<a class="ld-text-clear" id="clearusers" href="javascript:;" title="`+arrJsPopLabel['CLEAR']+`" >+</a>`
                                    +`<a class="icon-range" href="javascript:void(0);" name="selectusers" data-tip="`+arrJsPopLabel['PLEASESELECTPERSONNEL']+`" onmouseenter="tooltip.bind(this)"></a>`
                                +`</div>`
                            +`</div></td></tr>`;
                // 将原销售负责人
                if(!empty(labelarr.shareoldsmowner.label)){
                    table_html +=`<tr><td class="ld-form-item-label">`+labelarr.shareoldsmowner.label+`</td>`
                                +`<td class="ld-form-item-content">`
                                +`<div class="select-input">`
                                    // +`<select id="shareoldsmowner" name="shareoldsmowner" class="ld-select-inner" style="">`
                    var tmp_checked = '';
                    ld.each(labelarr.shareoldsmowner.option, function(index, option) {
                        // table_html += '<option value="'+option.value+'" '+option.selected+'>'+option.label+'</option>';
                        if(option.value == labelarr.shareoldsmowner.optionvalue){
                            tmp_checked = 'checked';
                        }else{
                            tmp_checked = '';
                        }
                        table_html += '<input type="radio" name="shareoldsmowner" id="shareoldsmowner_'+option.value+'" value="'+option.value+'" '+tmp_checked+'/>'+
                                        '<label for="shareoldsmowner_'+option.value+'" class="padR10">'+option.label+'</label>';
                    });
                    table_html +=`</div>`
                    table_html +=`</td></tr>`;
                }

                // // 同时分配，共享相关信息
                // table_html +=`<tr><td class="ld-form-item-label" id="sharerelatedinfo">`+labelarr.sharerelatedinfo.label+`</td>`
                //             +`<td class="ld-form-item-content">`
                //                 +`<input id="enablerelatedinfo" `+labelarr.sharerelatedinfo.checked+` type="checkbox" class="second_switch">`
                //             +`</td></tr>`;

                // var displaystyle = '';
                // if(labelarr.sharerelatedinfo.checked == ''){
                //     displaystyle = 'style="display:none;"'
                // }
                // // 全部或部分模块
                // table_html +=`<tr name="relmodulescope_tr" `+displaystyle+`><td class="ld-form-item-label"> </td>`
                //             +`<td class="ld-form-item-content">`
                //                 +`<div class="select-input">`
                //                     +'<input type="radio" name="relmodule_scope" id="allrelatedinfo" value="all" checked="" /><label for="allrelatedinfo" class="padR10">'+arrJsPopLabel['ALL']+'</label>'
                //                     +'<input type="radio" name="relmodule_scope" id="partrelatedinfo" value="part" '+labelarr.relmodulescope.part.checked+' /><label for="partrelatedinfo" class="padR10">'+arrJsPopLabel['Part']+'</label>'
                //                 +`</div>`
                //             +`</td></tr>`;
                // // 模块多选框
                // var multiselectmodule_displaystyle = '';
                // if(empty(labelarr.relmodulescope.part.checked) || labelarr.sharerelatedinfo.checked == ''){
                //     multiselectmodule_displaystyle = 'style="display:none;"';
                // }
                // table_html +=`<tr name="relmodulescope_tr" id="multiselectmodule" `+multiselectmodule_displaystyle+`><td class="ld-form-item-label"> </td>`
                //             +`<td class="ld-form-item-content">`
                //             +`<select id="selectrelatedmodule" name="selectrelatedmodule" class="ld-select-inner" style="" multiple="">`
                // ld.each(data.result.modulelist, function(tmpi, moduleinfo) {
                //     table_html += '<option value="'+moduleinfo.tabid+'" '+moduleinfo.selected+'>'+moduleinfo.label+'</option>';
                // });
                // table_html +=`</select></td></tr>`;

                table_html += '</table>';

                // 同时分配以下相关信息
                table_html += `<div class="pad10">
                                    <div class="ld-pop-contnet-title-items">
                                        <div class="ld-pop-contnet-title-item" id="headblock_chooserelinfo">`+otherlabel.headblock.chooserelinfo+`</div>
                                    </div>
                               </div>`

                // 数据范围
                if(!empty(labelarr.datascopeforelinfo)){
                    table_html += `<table class="ld-public-content-small pad10" border="0" cellpadding="0" cellspacing="0" width="100%">`
                    table_html +=`<tr name="datascope_tr">`
                                    +`<td class="ld-form-item-label" id="datascope_label">`+labelarr.datascopeforelinfo.label+`</td>`
                                    +`<td class="ld-form-item-content">`
                                        +`<select id="datascope" name="datascope" class="ld-select-inner" style="">`
                    ld.each(labelarr.datascopeforelinfo.option, function(index, option) {
                        table_html += '<option value="'+option.value+'" '+option.selected+'>'+option.label+'</option>';
                    });
                    table_html +=`</select>`
                                +`</td></tr></table>`;
                }

                // 穿梭框div
                table_html += '<table><div id="ModuleTransferDiv" style=""></div></table>';

                
                table_html +=`</div>`;

                CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj, table_html);
                // 模块穿梭框
                var leftfields_arr = data.result.dragtransfer_modulelist['available'];
                var rightfields_arr = data.result.dragtransfer_modulelist['selected'];
                if(rightfields_arr.length > 0)
                    leftfields_arr = leftfields_arr.filter(leftitem => !rightfields_arr.some(rightitem => rightitem.value == leftitem.value));// 在左侧数组中去掉右侧已选字段
                var tableobj = ld('#'+Popupobj.divid).find("div#ModuleTransferDiv");// 加载穿梭框
                var LeftObj = leftfields_arr;
                var RightObj = rightfields_arr;
                var Drag_Transfer = new DragTransfer();
                var translabel = {
                    available: arrJsPopLabel['OptionModules'],
                    selected: arrJsPopLabel['Selectedmodule'],
                    placeholder: arrJsPopLabel['PleaseEnterModuleSearchFor'],
                };
                Drag_Transfer.SetTranslabel(translabel);
                Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'set','210');
                Popupobj.center();

                that.popupobj = Popupobj;
                that.setBindEvent();// 绑定事件
            }
        })
    }
    // 绑定事件
    this.setBindEvent = function (){
        var popupobj = this.popupobj;
        var targetobj = ld("#"+popupobj.divid);

        // targetobj.find("#selectrelatedmodule").select2({closeOnSelect: true,dropdownParent:targetobj});
        // targetobj.find(".select2").css('width',"100%");

        // targetobj.find("#enablerelatedinfo").unbind('click').on('click', function (event) {
        //     that.enableRelatedInfo(this);
        // });
        
        // targetobj.find('input[name="relmodule_scope"]').unbind('click').on('click',function(){
        //     that.changeRelModuleScope(this);
        // });
        targetobj.find("[name=selectusers]").unbind('click').on('click', function (event) {
            that.selectUsers(this);
        });
        targetobj.find("#clearusers").unbind('click').on('click', function (event) {
            that.clearUsers();
        });
        that.changeRelInfoScope(targetobj.find('select#datascope'));
        targetobj.find('select#datascope').unbind('change').on('change',function(){
            that.changeRelInfoScope(this);
        });
        if(this.mode == "seniorShare"){
            getJsScript('include/js/Share.js', function () {// 切换共享类型
                Share.getInstance().sharetypeEvent(targetobj)
                if(!empty(that.recordid)){// 兼容以前选一条单据(或详情界面)共享默认是"替换"
                    targetobj.find('input[name="share_type"]#share_type_cover').click();
                }
            });
        }
    }
    // 确定事件
    this.confirmEvent = function (){
        var mode = that.mode;
        var module = that.module;
        var viewtype = that.viewtype;
        var selected_ids = that.selected_ids;
        var rRowNum = that.rows_num;
        var excluded_records = that.excluded_records;

        var popupobj = that.popupobj;
        var selected_user = popupobj.selected_user;
        var selected_username = popupobj.selected_username;// 姓名的字符串


        if(empty(selected_user)){
            MessagePopup.TipOne_warning(arrJsPopLabel['PLEASESELECTLESTONEUSER']);
            return false;
        }
        // 获取页面设置的参数
        var join_url = '';
        var datascope = '';
        if(mode == "seniorShare"){
            var share_type = ld("#"+popupobj.divid).find('input[name="share_type"]:checked').val();
            datascope = 'all';
        }else{
            var shareoldsmowner = ld("#"+popupobj.divid).find('input[name="shareoldsmowner"]:checked').val();
            join_url += '&shareoldsmowner='+shareoldsmowner;
            datascope = ld("#"+popupobj.divid).find('#datascope').val();
        }

        join_url += '&reldata_scope='+datascope;// 数据范围
        join_url += '&enablerelatedinfo='+(datascope=='none'?'no':'yes');// 数据范围中选择不分配相关信息则等同于以前的未启用
        // 所选模块
        var relmodule_scope = 'part';
        join_url += '&relmodule_scope='+relmodule_scope;
        var selectedtabid_str = '';
        if(relmodule_scope == 'part' && datascope !='none'){
            var Drag_Transfer = new DragTransfer();
            Drag_Transfer.tableObj = ld('#'+popupobj.divid).find("div#ModuleTransferDiv");
            var selectedtabid_arr = Drag_Transfer.getData('right');// 获取已选值的value
            // if(empty(selectedtabid_arr)){// 请至少选择一个相关信息模块
            //     MessagePopup.TipOne_warning(arrJsPopLabel['PleaseSelectOneRelatedModule']);
            //     return false;
            // }
            // var selectedtabid_arr = [];
            // ld.each(selectrelatedmodule,function(index,info){
            //     var selectedtabid = info.id;
            //     selectedtabid_arr.push(selectedtabid);
            // })
            selectedtabid_str = selectedtabid_arr.join(',');
        }
        join_url += '&selectedtabid_str='+selectedtabid_str;
        // console.log('join_url: ', join_url);
        popupobj.CancelEvent();
        if(mode == "seniorShare"){
            viewtype = viewtype+'view';
            var intervalrow = 8;
            if (rRowNum > 100){
                intervalrow = Math.ceil(rRowNum / 10); //向上取整
            }
            //duan 2022-2-28 设置批量操作上限20，如果一次性选中的记录条数大于系统设置的批量操作最大条数10倍以上，会导致进度条未生效
            if(intervalrow >20){
                intervalrow = 20;
            }
            if(rRowNum>0){
                ld('#rptContentLoading').show();
                getJsScript('include/js/Share.js', function () {
                    Share.getInstance().startBatchShare(module,selected_ids,share_type,excluded_records,selected_user,viewtype, rRowNum, 0, intervalrow, join_url);
                });
            }
        }
        else if(mode == "seniorAllocate"){
            startChangeCreator(selected_user,selected_username,'Allocate', module, viewtype, selected_ids, excluded_records,0, join_url);
        }
        else if(mode == "seniorAverageAllocate"){
            ld('#rptContentLoading').show();
            // @edit:liushuai,2021-03-02,reason:【ID1001390】批量平均分配增加显示进度条
            var selected_user_arr=selected_user.split(",");
            var intervalrow=selected_user_arr.length;
            var executeTimeCount=parseInt(rRowNum/intervalrow);
            //edit:can 20210425 45560: （https://61mis.com/kfbcrm [^] ）平均分配时不平均
            if(executeTimeCount>20){
                intervalrow=selected_user_arr.length*2;
            }
            if(executeTimeCount>30){
                intervalrow=selected_user_arr.length*3;
            }
            if(executeTimeCount>30){
                intervalrow=selected_user_arr.length*4;
            }
            if(executeTimeCount>50){
                intervalrow=selected_user_arr.length*5;
            }
            if(executeTimeCount>60){
                intervalrow=selected_user_arr.length*6;
            }
            if(executeTimeCount>70){
                intervalrow=selected_user_arr.length*7;
            }
            if(intervalrow<8){
                intervalrow=selected_user_arr.length*2;
            }
            
            startAverageDistribution(module, 'averageDistribution', viewtype, selected_ids, selected_user, rRowNum, excluded_records, 0, intervalrow, join_url);
        }
        else if(mode == "seniorHigndistribution"){// 公海分配
            if(viewtype == 'detail'){
                AllocatetaccountDetails(selected_ids,2,selected_user,selected_username,join_url);
            }else{
                massAllocate_Load(selected_ids,2,selected_user,selected_username, join_url);
            }
        }
        else if(mode == "seniorAverageHigndistribution"){// 公海平均分配
            massHighAllocate_Load(selected_ids, 2, selected_user, selected_username, rRowNum, join_url);
        }

    }
    // 同时分配，共享相关信息触发事件
    this.enableRelatedInfo = function (obj){
        var popupobj = this.popupobj;
        var checkstatus = ld(obj).prop("checked");
        if(checkstatus){
            if(ld("#"+popupobj.divid).find('#partrelatedinfo').prop('checked') == true){
                ld("#"+popupobj.divid).find("[name=relmodulescope_tr]").show();
            }else{
                ld("#"+popupobj.divid).find("[name=relmodulescope_tr]:first").show();
            }
            ld("#"+popupobj.divid).find("[name=datascope_tr]").show();
        }else{
            ld("#"+popupobj.divid).find("[name=relmodulescope_tr]").hide();
            ld("#"+popupobj.divid).find("[name=datascope_tr]").hide();
        }
    }
    // 切换相关信息模块范围
    this.changeRelModuleScope = function (obj){
        var popupobj = this.popupobj;
        var select_value = ld(obj).val();
        if(select_value == 'part'){
            ld("#"+popupobj.divid).find('#multiselectmodule').show();
        }else{
            ld("#"+popupobj.divid).find('#multiselectmodule').hide();
        }
    }
    // 切换相关信息数据范围
    this.changeRelInfoScope = function (obj){
        var popupobj = this.popupobj;
        var select_value = ld(obj).val();
        if(select_value == 'none'){
            ld("#"+popupobj.divid).find('#ModuleTransferDiv').hide();
        }else{
            ld("#"+popupobj.divid).find('#ModuleTransferDiv').show();
        }
        popupobj.center();
    }
    // 选择用户
    this.clearUsers = function (){
        var popupobj = this.popupobj;
        ld("#"+popupobj.divid).find("#selectusers").html('');
        ld("#"+popupobj.divid).find("#selectusers").val('');
        popupobj.selected_user = '';
        popupobj.selected_username = '';
    }
    // 选择用户
    this.selectUsers = function (obj){
        var popupobj = this.popupobj;
        var mode = this.mode;
        var module = this.module;
        var rRowNum = this.rows_num;

        var poptitle = '';// 标题
        var popup_url = '';
    
        var popupinfo = getAllocateSharePopupInfo(mode, module);
        poptitle = popupinfo.poptitle;
        popup_url = popupinfo.popup_url;
        
        var scopepopupobj;
        getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
            var methodObj = {'popup_check_inactiveuser':'yes','popup_check_nogroupuser':'no','rRowNum':rRowNum};
            scopepopupobj =  new ScopePopupObj(methodObj);
            scopepopupobj.popup_caption_value = poptitle;//标题
            getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
                // 获取选择用户信息
                cls_ScopePopup.prop.popup_module = module;//模块
                cls_ScopePopup.prop.popup_value = popupobj.selected_user;// 已选用户
                cls_ScopePopup.prop.popup_url = popup_url;
                var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);

                that.cls_ScopePopup = cls_ScopePopup;
                // 确认按钮事件
                scopepopupobj.setEventBtnOk=function(){
                    that.selectUsersEvent();
                };
            });
        });
        
    }
    // 选择用户确认事件
    this.selectUsersEvent = function (obj){
        var popupobj = this.popupobj;
        var cls_ScopePopup = this.cls_ScopePopup;
        var rRowNum = this.rows_num;
        ld('#'+cls_ScopePopup.popup_divid).find(' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
            //选中的用户
            var selected_user = popupobj.selected_user = cls_ScopePopup.return_obj.return_id;
            var userfullnames = popupobj.selected_username = cls_ScopePopup.return_obj.return_name;
            if(rRowNum>1 && selected_user<=0){
                RemindsMsg('',"LdPopWidth400px","","yes","yes",arrJsPopLabel['PLEASESELECTLESTONEUSER']);
                return false;
            }

            ld("#"+popupobj.divid).find("#selectusers").html(userfullnames);
            ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();

        });
    }

}




SeniorAllocateShare.curobj = '';
SeniorAllocateShare.getInstance=function(module,mode){
	if(!empty(SeniorAllocateShare.curobj)){
	}else{
		SeniorAllocateShare.curobj=new SeniorAllocateShare(module,mode);
	}
    return SeniorAllocateShare.curobj;
}












