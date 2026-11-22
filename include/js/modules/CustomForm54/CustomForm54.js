function CustomForm54(){
	var that = this;
    this.local_get = '';

	this.receiveCertificate = function(obj,module,popup_type,mode,record) {
        //获取要变更的ID
        var select_id = '';//选择的单据id
        var savefilter = '';//选择的单据个数
        var excludedRecords = '';
        var urlstring = 'index.php?module=' + module + '&action=' + module + 'Ajax&file=ReceiveCertificate&setype=check';
        select_id = document.getElementById('allselectedboxes').value;
        if ('all' == select_id) {
        //获取全选数量
            var selectlen = document.getElementById('numOfRows').value;
            savefilter += '&selectlen=' + selectlen;
        }else {
            var x = select_id.split(';');
            var count = x.length;
            savefilter += '&selectlen=' + (count-1);
        }
        urlstring += '&select_ids=' + select_id + savefilter;
        ld('#rptContentLoading').show();
        ldAjax(urlstring,{},function(data){
            if(data.code == 1){
                if (mode == 'list') {//列表

                    if ('all' == select_id) {
                        
                        excludedRecords = document.getElementById('excludedRecords').value;
                        if (parseInt(selectlen) > parseInt(getMaxMassOperationLimit())) {
                            var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', selectlen, getMaxMassOperationLimit(), '');
                            RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);

                            //确定事件
                            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                                that.receiveCertificates(popup_type, module, mode, select_id, excludedRecords, savefilter,0,selectlen, []);
                            });
                        }
                        else {
                            var confirm_str = '<span style="display: block;">'+that.getTwoVarJsPop('HaveSelectedWhetherReceive', selectlen,'','')+'</span>';
                            confirm_str += '<span style="color: #999;">('+data.result.confirm_msg+')</span>';
                            // MessagePopup.TipTwo_warning(confirm_str);
                            default_successRemindsMsg(confirm_str,'','','LdPopWidth600px','yes','yes');
                            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                                that.receiveCertificates(popup_type, module, mode, select_id, excludedRecords, savefilter,0,selectlen, []);
                            });
                        }

                    } else {

                        if (0 == ld('input[name=selected_id]:checked').length) {
                            MessagePopup.TipOne_warning();
                            return false;
                        }
                        if (count - 1 > getMaxMassOperationLimit()) {
                            var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', count - 1, getMaxMassOperationLimit(), '');
                            //创建提示弹出层
                            RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);
                            //确定事件
                            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                                that.receiveCertificates(popup_type, module, mode, select_id, excludedRecords, savefilter,0,count-1, []);
                            });
                        } else {
                            var confirm_str = '<span style="display: block;">'+that.getTwoVarJsPop('HaveSelectedWhetherReceive', count - 1,'','')+'</span>';
                            confirm_str += '<span style="color: #999;">('+data.result.confirm_msg+')</span>';
                            // MessagePopup.TipTwo_warning(confirm_str);
                            default_successRemindsMsg(confirm_str,'','','LdPopWidth600px','yes','yes');
                            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                                that.receiveCertificates(popup_type, module, mode, select_id, excludedRecords, savefilter,0,count-1, []);
                            });
                        }
                    }
                    that.local_get = data.result.local_get;
                }
                // else if (mode=='detail') {//详情页
                //     //zxm 20221227 详情页分配 单据id直接使用传过来的值
                //     that.receiveCertificates(popup_type, module, mode, record, excludedRecords, savefilter);
                // }
                ld('#rptContentLoading').hide();
            }else if(data.code == -1){
                MessagePopup.TipOne_warning(data.msg);
            }
        });
    }

    this.receiveCertificates = function(popup_type, module, mode, select_id, excludedRecords, savefilter, startrow, maxrows, resultdata) {
        var popupobj=CrmPopup.getPopupObj('last');
        var viewid = getviewId();
        var intervalrow = 1;

        var urlstring = 'index.php?module=' + module + '&action=' + module + 'Ajax&file=ReceiveCertificate&setype=get';
        
        urlstring += '&localget='+this.local_get;//xxy 2023-11-28 区分领取到对应crm和只领取
        urlstring += '&changetype=' + popup_type + '&mode=' + mode + savefilter;
        urlstring += '&select_ids=' + select_id + '&excludedRecords=' + excludedRecords + '&viewname=' + viewid;
        urlstring += "&startrow=" + startrow + "&endrow=" + (startrow + intervalrow);
        var param = {'resultdata':resultdata};

        ldAjaxNoProgress(urlstring,param,function(data){
            if(data.code == 1){
                ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtncancel').click();
                // var restobj = eval('(' + data.responseText + ')') ? eval('(' + data.responseText + ')') : JSON.parse(data.responseText);
                // if (mode == 'detail') {
                //     workflowCallApiPop(restobj);//工作流API弹窗
                // }
                var account_total = data.result.account_total;
                if (mode == 'list') {
                    var tmppopupobjobj;

                    if (startrow == 0) {
                        tmppopupobjobj = ProgressPopup.load(data.result.title, "", "", 500, module, "", "", "", "");
                        tmppopupobjobj.show=function(){
                            var htmlcontent="<div class='import_process'><div class='progressbar batchProgress'></div>";
                            htmlcontent+="<div class='import_info'>共选择了<span class='num totalnum'></span>条记录，<span class='spanvalidata' style='display:none'>客户单据共<span class='num validatanum'></span>条，</span> 正在领取第<span class='num curnum'></span>条客户单据及其相关证书，请稍后……</div></div>";
                            this.cssWidth=750;
                            this.parentfun_show(htmlcontent);
                            ld("#"+this.divid).css("zIndex",10000);
                        }
                        tmppopupobjobj.show();

                    }
                    else {
                        tmppopupobjobj = CrmPopup.getPopupObj('last');

                    }
                    maxrows = parseInt(maxrows);
                    var percent = parseInt(((startrow + intervalrow) / account_total * 100));
                    //var width=parseInt((500*(startrow+intervalrow)/maxrows));

                    tmppopupobjobj.setPercentWidth(percent);
                    tmppopupobjobj.setTotalNum(maxrows);
                    tmppopupobjobj.setCurNum(startrow);
                    // if (maxrows != restobj.selectrows) {
                        tmppopupobjobj.setValidataNum(account_total);
                    // }
                    if (parseInt(startrow + intervalrow) < parseInt(account_total)) {
                        var result_data = data.result.result_data;
                        // console.log(result_data)
                        that.receiveCertificates(popup_type, module, mode, select_id, excludedRecords, savefilter, startrow + 1,maxrows, result_data);
                        return false;
                    }
                    else {
                        tmppopupobjobj.CancelEvent();
                    }
                }

                // if (mode == 'detail') {
                //     //ls 2022-02-23 0050023: 系统设置》参数》提醒参数“客户服务单分配时是否发送短信或邮件通知客户服务单联系人” ；分配服务单单据TT10，没收到短信或邮件提醒(单据详情页分配时)
                //     //客户服务单分配时是否发送短信或邮件通知客户首要联系人
                //     if (module == 'HelpDesk') {
                //         CreateSendForm(module, select_id);
                //     }

                //     var detailviewpopupobj = CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
                //     var tmparra = [detailviewpopupobj.record];
                //     var tmpdata = {};

                //     var tmpobj = new AfterUpdatePrevPopupObjContent(module, restobj, tmparra);
                //     tmpobj.eachrefreshDetailViewByModules([module]);
                //     tmpobj.update();
                //     return false;
                // }
                // if (ld('input[name=selected_id]').length == 0) {//Liver 2016/09/07 去掉&&module!='Documents'，原因是bug0024278: 知识管理明细：更多中点击-更改创建人，确定后，界面显示了更改创建人的提示消息
                //     puyoungJS_DialogBox.block();

                //     if (module == 'HelpDesk') {
                //         var help_url = window.location.href;
                //         help_url = help_url.replace('&sendtype=yes', '');
                //         if (help_url.indexOf('&sendtype=yes') < 0 && popup_type == 'Allocate') {
                //             help_url += '&sendtype=yes';
                //         }
                //         window.location.href = help_url;
                //         return false;
                //     }
                //     puyoungJS_DialogBox.unblock();
                //     fninvshnew('selectpopup_1');
                //     if (parseInt(restobj.errorcount) > 0) {
                //         audioRemindsMsg("", "", module, "", "", restobj.log.value);
                //         return false;
                //     }
                //     changeUser.saveretjson = restobj;

                //     changeUser.afterOperation(popup_type, selected_user, cls_ScopePopup.return_obj.return_name, module);
                //     if (popup_type == 'Allocate') {

                //         var prevpopupobj = CrmPopup.getPopupObj("last");
                //         prevpopupobj.smownercolumnname_value = cls_ScopePopup.return_obj.return_name;
                //         PageRecordPopup.setDetailViewTitle(prevpopupobj.divid);
                //     }
                //     //window.location.reload();
                //     return false;
                // }
                getJsScript('include/js/ldcrm.base.js', function () {
                    //zkt 20230914 BUG0071724 kfbtest-产品管理-勾选一个产品，点击分配，选择成员，点击确认，此时提示信息更改负责人成功，但点击取消按钮则显示未分配，应去掉第二个弹出层的取消按钮
                    resultRemindsMsg(data.result.title, "LdPopWidth600px", "", "yes", "", data.result.content_html);

                    ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                        fninvshnew('mass_advancer');
                        puyoungJS_DialogBox.unblock();

                        if (ld('input[name=selected_id]').length > 0) {
                            if ($('basicsearchcolumns') != undefined)
                                $('basicsearchcolumns').innerHTML = '';
                            if ($('allselectedboxes') != undefined)
                                $('allselectedboxes').value = '';
                            if ($('excludedRecords') != undefined)
                                $('excludedRecords').value = '';
                            var tmparra = new Array();
                            var tmpobj = new AfterUpdatePrevPopupObjContent(module, "", tmparra);
                            //服务单保存后刷新服务单的历史记录(查看界面)
                            var refreshlistmodules = new Array(module);
                            tmpobj.eachrefreshlistbyModules(refreshlistmodules);

                            //window.location.reload();
                            if (document.getElementById("SmOwnerSearchScope") != undefined)
                                searchScope = encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
                            var viewid = getviewId();
                        } else {
                            var tmparra = new Array();
                            var tmpobj = new AfterUpdatePrevPopupObjContent(module, "", tmparra);
                            //服务单保存后刷新服务单的历史记录(查看界面)
                            var refreshlistmodules = new Array(module);
                            tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                            // window.location.reload();
                        }
                    });
                    return false;

                });
            }else if(data.code == -1){
                MessagePopup.TipOne_warning(data.msg);
            }
        });
    }

    this.getTwoVarJsPop = function(labelbol,t0,t1){
        var jspopinfo=arrJsPopLabel[labelbol];
        var res=jspopinfo.split('{Var}');
        jspopinfo=res[0]+t0+res[1]+t1;
        if(res.length>2)
        {
            jspopinfo+=res[2];
        }
        return jspopinfo;
    }
}