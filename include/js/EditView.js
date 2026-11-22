/*
{*修改编码格式:统一编码：UTF-8*}
*/
function rel_check_object(sel_id, module) {
    var selected;
    var select_global = new Array();
    var cookie_val = get_cookie(module + "_all");
    if (cookie_val == null)
        selected = sel_id.value + ";";
    else
        selected = trim(cookie_val);
    select_global = selected.split(";");
    var box_value = sel_id.checked;
    var id = sel_id.value;
    var duplicate = select_global.indexOf(id);
    var size = select_global.length - 1;
    var result = "";
    var currentModule = document.getElementById("RLreturn_module").value;

    var excluded = document.getElementById(currentModule + '_' + module + '_excludedRecords').value;
    if (box_value == true) {
        if(ld(sel_id).hasClass('checkbox-item')){
            ld(sel_id).addClass('tb-checkbox-selected');
            ld(sel_id).parent().parent().removeClass('lvtColData').removeClass('lvtColDataBj').addClass('lvtColDataSelected');
        }
        if (document.getElementById(currentModule + '_' + module + '_selectallActivate').value == 'true') {
            document.getElementById(currentModule + '_' + module + '_excludedRecords').value = excluded.replace(excluded.match(id + ";"), '');
        } else {
            if (duplicate == "-1") {
                select_global[size] = id;
            }

            size = select_global.length - 1;
            var i = 0;
            for (i = 0; i <= size; i++) {
                if (trim(select_global[i]) != '')
                    result = select_global[i] + ";" + result;
            }
        }
        rel_default_togglestate(module);
    } else {
        if(ld(sel_id).hasClass('checkbox-item'))
        {
            ld(sel_id).removeClass('tb-checkbox-selected');
            ld(sel_id).parent().parent().removeClass('lvtColDataSelected').addClass('lvtColData');
        }
        if (document.getElementById(currentModule + '_' + module + '_selectallActivate').value == 'true') {
            document.getElementById(currentModule + '_' + module + '_excludedRecords').value = id + ";" + excluded;
        }
        if (duplicate != "-1")

            select_global.splice(duplicate, 1)

        size = select_global.length - 1;
        var i = 0;
        for (i = size; i >= 0; i--) {
            if (trim(select_global[i]) != '')
                result = select_global[i] + ";" + result;
        }
        // getObj(module + "_selectall").checked = false;

    }
    set_cookie(module + "_all", result);
}

function rel_check_object_parent_td(obj){
    var parent_td=ld(obj).find("input")[0];
    var click_event = window.event;
    if(click_event.target!=parent_td){
        ld(parent_td).click();
    }
}
function rel_default_togglestate(module) {
    var all_state = true;
    var currentModule = $('return_module').value;
    if (currentModule == 'Campaigns') {
        var groupElements = document.getElementsByName(currentModule + '_' + module + "_selected_id");
    } else {
        var groupElements = document.getElementsByName(module + "_selected_id");
    }
    if (typeof (groupElements) == 'undefined') return;

    for (var i = 0; i < groupElements.length; i++) {
        var state = groupElements[i].checked;
        if (state == false) {
            all_state = false;
            break;
        }
    }
    if (getObj(module + "_selectall")) {
        getObj(module + "_selectall").checked = all_state;
    }
}

function rel_toggleSelect(state, relCheckName, module) {
    var popupobj = CrmPopup.getPopupObj('last');
    //edit:can 2020-10-09 42827: （https://61mis.com/kfbtest/ [^]）市场活动单据查看详情界面，相关信息->客户界面，全选客户时，把市场活动单据列表界面的单据也全选了
    ld('#' + popupobj.divid + ' [name=' + relCheckName + ']').prop('checked', state);
    if (state) {
        ld('#' + popupobj.divid + ' [name=' + module + '_selectall]').addClass('tb-checkbox-selected');
        ld('#' + popupobj.divid + ' [name=' + relCheckName + ']').addClass('tb-checkbox-selected');
        ld('#' + popupobj.divid + ' [name=' + relCheckName + ']').parent().parent().removeClass('lvtColData').removeClass('lvtColDataBj').addClass('lvtColDataSelected');
    } else {
        ld('#' + popupobj.divid + ' [name=' + module + '_selectall]').removeClass('tb-checkbox-selected');
        ld('#' + popupobj.divid + ' [name=' + relCheckName + ']').removeClass('tb-checkbox-selected');
        ld('#' + popupobj.divid + ' [name=' + relCheckName + ']').parent().parent().removeClass('lvtColDataSelected').addClass('lvtColData');
    }
}

function toggleAssignType(currType) {
    if (currType == "U") {
        getObj("assign_user").style.display = "block"
        getObj("assign_team").style.display = "none"
        if (getObj("set_reminder") != null) {
            getObj("set_reminder").disabled = false;
        }
        if (getObj("pop_reminds") != null) {
            getObj("pop_reminds").disabled = false;
        }
    } else {
        getObj("assign_user").style.display = "none"
        getObj("assign_team").style.display = "block"
        if (getObj("set_reminder") != null) {
            getObj("set_reminder").disabled = true;
        }
        if (getObj("pop_reminds") != null) {
            getObj("pop_reminds").disabled = true;
        }
        if (document.getElementById('reminderOptions') != undefined) {
            document.getElementById('reminderOptions').style.display = "none";
            document.getElementById('reminderOptions2').style.display = "none";
        }
    }
}

function selectVendorContact(check, type, frmName) {
    var record = document.getElementsByName("record")[0].value;
    if (document.getElementById('vendor_id') != undefined && trim(document.getElementById('vendor_id').value) != "") {
        window.open("index.php?module=VendorContact&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&recordid=" + record + "&vendorid=" + trim(document.getElementById('vendor_id').value), "", "width=840,height=602,resizable=1,scrollbars=1");
    } else

        window.open("index.php?module=VendorContact&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&recordid=" + record, "", "width=840,height=602,resizable=1,scrollbars=1");
}

function selectContact(check, type, frmName, related) {
    getJsScript('include/js/DetailButtons.js', function () {
        selectContacts(check, type, frmName, related);
    })
}

//to get Select Potential Popup
function selectPotential(mod) {
    // To support both B2B and B2C model
    var record_id = '';
    var parent_module = '';
    /**
     * 快速创建，form的name值是QcEditView，而不是EditView
     * @reason 0012667: 快速创建>>联系记录，点击“销售机会”字段的选择按钮，结果报.js错误
     * @author Tujt 2014-11-21
     */
    var editform;
    if (typeof (document.EditView) != 'undefined')
        editform = document.EditView;
    else if (typeof (document.QcEditView) != 'undefined')
        editform = document.QcEditView;
    var acc_element = editform.account_id;
    var cnt_element = editform.contact_id;
    if (acc_element != null) {
        record_id = acc_element.value;
        parent_module = 'Accounts';
    } else if (cnt_element != null) {
        record_id = cnt_element.value;
        parent_module = 'Contacts';
    }
    if (record_id != '')
        window.open("index.php?module=Potentials&action=Popup&html=Popup_picker&popuptype=specific_potential_account_address&form=EditView&accountid=" + record_id + "&parent_module=" + parent_module + "&frommodule=" + mod, "test", "width=840,height=602,resizable=1,scrollbars=1");
    else
        window.open("index.php?module=Potentials&action=Popup&html=Popup_picker&popuptype=specific_potential_account_address&form=EditView&frommodule=" + mod, "test", "width=840,height=602,resizable=1,scrollbars=1");
}

//to select Quote Popup
function selectQuote(mod) {
    // To support both B2B and B2C model
    var record_id = '';
    var parent_module = '';
    var acc_element = document.EditView.account_id;
    var cnt_element = document.EditView.contact_id;
    if (acc_element != null) {
        record_id = acc_element.value;
        parent_module = 'Accounts';
    } else if (cnt_element != null) {
        record_id = cnt_element.value;
        parent_module = 'Contacts';
    }
    var surl = "module=Quotes&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&popup=yes&accountid=" + record_id + "&parent_module=" + parent_module + "&frommodule=" + mod;
    CrmPopupWindow(mod, surl, 'Quotes');
}

function selectPurchaseOrder(mod) {
    /**
     * edit:chj
     * date:2014-2-24
     *reason:收款单和付款单改进(v5.3)
     **/
    var idstring = '';
    var listval = '';
    if (document.getElementById('selectlistval') != undefined && trim(document.getElementById('selectlistval').value) != "") {
        listval = document.getElementById('selectlistval').value;
    }
    if (mod == 'SendCashBill') {
        /*var tableName = document.getElementById('SendPaymentList');
	    var prev = tableName.rows.length;
        var count = eval(prev);
        var iCount = 1;
        if(count > 4)
        {
            for(iCount=1;iCount<=count-4;iCount++)
            {
                if(iCount == 1)
                    idstring =  document.getElementById('curSendCashBill'+iCount).value;
                else
                    idstring =  idstring + ',' + document.getElementById('curSendCashBill'+iCount).value;
            }
            idstring = idstring + '|' + document.getElementById('otherselect').value;
            idstring = idstring + ',' + document.getElementById('nosendpayment').value;
            idstring = idstring + ',' + document.getElementById('totalhaveplaymentamount').value;
            idstring = idstring + ',' + document.getElementById('totalplayment').value;
        }*/
        var action = 'SendCashBillPopup&ReportHeader=dheader&idstring=' + idstring;
    } else if (mod == 'PurchaseInvoice') {
        var vendor_id = 0;
        var rowcnt = 0;
        if (document.getElementById('rowcnt') != undefined) {
            rowcnt = document.getElementById('rowcnt').value;
        }
        if (document.EditView.vendor_id != undefined) {
            vendor_id = document.EditView.vendor_id.value;
        }
        if (vendor_id != '' && vendor_id > 0)
            window.open("index.php?module=PurchaseOrder&action=PurchaseInvoicePopup&ReportHeader=dheader&html=Popup_picker&popuptype=specific&form=EditView&select=enable&rowcnt=" + rowcnt + "&idstring=" + idstring + "&listval=" + listval + "&vendor_id=" + vendor_id + "&parent_module=" + mod + "&frommodule=" + mod, "test", "width=840,height=602,resizable=1,scrollbars=1");
        else {
            window.open("index.php?module=PurchaseOrder&action=PurchaseInvoicePopup&ReportHeader=dheader&html=Popup_picker&popuptype=specific&form=EditView&select=enable&rowcnt=" + rowcnt + "&idstring=" + idstring + "&listval=" + listval + "&frommodule=" + mod, "test", "width=840,height=602,resizable=1,scrollbars=1");
        }
        return false;
    } else {
        var action = 'Popup';
    }
    if (mod == 'SendPayment') {
        //25911: 供应商明细界面：关联创建付款计划，选择采购订单时带出了其他供应商的单据
        window.open("index.php?module=PurchaseOrder&action=" + action + "&html=Popup_picker&popuptype=specific&form=EditView&listval=" + listval + "&frommodule=" + mod, "test", "width=840,height=602,resizable=1,scrollbars=1");

    } else {
        if (document.getElementById('vendor_id') != undefined && trim(document.getElementById('vendor_id').value) != "") {
            window.open("index.php?module=PurchaseOrder&action=" + action + "&html=Popup_picker&popuptype=specific&form=EditView&select=enable&listval=" + listval + "&frommodule=" + mod + "&vendorid=" + document.getElementById('vendor_id').value, "test", "width=840,height=602,resizable=1,scrollbars=1");
        } else {
            if (mod == 'Stock') {
                var surl = "module=PurchaseOrder&action=" + action + "&html=Popup_picker&popuptype=specific&form=EditView&select=enable&listval=" + listval + "&frommodule=" + mod + "&popup=yes&page_popup=yes";
                CrmPopupWindow(mod, surl, 'PurchaseOrder');
            } else {
                window.open("index.php?module=PurchaseOrder&action=" + action + "&html=Popup_picker&popuptype=specific&form=EditView&select=enable&listval=" + listval + "&frommodule=" + mod, "test", "width=840,height=602,resizable=1,scrollbars=1");
            }

        }
    }


}

/*
edit:can
date:20140221
reason:选择原单(合同订单)
*/

function selectSourceSalesOrder(mod) {
    var record_id = '';
    var parent_module = '';
    var acc_element = document.EditView.account_id;
    var cnt_element = document.EditView.contact_id;
    var module = document.EditView.module.value;
    var accountid;
    var vendorid;
    if (acc_element != null) {
        record_id = acc_element.value;
        parent_module = 'Accounts';
    } else if (cnt_element != null) {
        record_id = cnt_element.value;
        parent_module = 'Contacts';
    }
    if (record_id != '')
        window.open("index.php?module=SalesOrder&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&select=enable&relmod_id=" + record_id + "&parent_module=" + parent_module + "&frommodule=" + mod, "test", "width=840,height=602,resizable=1,scrollbars=1");
    else
        window.open("index.php?module=SalesOrder&action=Popup&html=Popup_picker&popuptype=specific&select=enable&form=EditView&frommodule=" + mod, "test", "width=840,height=602,resizable=1,scrollbars=1");
}

function delimage(id) {
    new Ajax.Request(
        'index.php',
        {
            queue: {
                position: 'end',
                scope: 'command'
            },
            method: 'post',
            postBody: 'module=Contacts&action=ContactsAjax&file=DelImage&recordid=' + id,
            onComplete: function (response) {
                if (response.responseText.indexOf("SUCCESS") > -1)
                    $("replaceimage").innerHTML = arrJsPopLabel['PICTUREHASBEENDELETED'];
                else {
                    var confirm_str = arrJsPopLabel['ERROROCCURREDWHILEEDIT'];
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                }
            }
        }
    );
}

function delUserImage(id) {
    new Ajax.Request(
        'index.php',
        {
            queue: {
                position: 'end',
                scope: 'command'
            },
            method: 'post',
            postBody: 'module=Users&action=UsersAjax&file=Save&deleteImage=true&recordid=' + id,
            onComplete: function (response) {
                if (response.responseText.indexOf("SUCCESS") > -1)
                    $("replaceimage").innerHTML = arrJsPopLabel['PICTUREHASBEENDELETED'];
                else {
                    var confirm_str = arrJsPopLabel['ERROROCCURREDWHILEEDIT'];
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                }
            }
        }
    );
}


function formValidate() {
    return doformValidation('');
}

/*
判断提现取现单批量编辑账号不能一样
andrew
20140422
*/
function checkeditf(module) {
    if (module == 'PutCash' || module == 'CashDeposit') {
        var value = document.getElementById('251');
        var outaccount = value.options[value.selectedIndex].value;
        var csd = document.getElementById('252');
        var inaccount = csd.options[csd.selectedIndex].value;
        if (outaccount == inaccount) {
            var confirm_str = arrJsPopLabel['taaacnbtttsa'];
            RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str);
            return false;
        } else {
            return true;
        }
    } else {
        return true;
    }
}

//閸ф绱潏鎴濃偓鑲╂畱妤犲矁鐦?
function massEditFormValidate() {
    return doformValidation('mass_edit');
}

function doformValidation(edit_type) {
    var act_time;
    var popupobj = CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    var pagetype = popupobj.pagetype;

    if (doformValidation.imagecheck() == false) {
        return false;
    }

    if (popupobj.module == 'Contacts' && gValidationCall != 'tabchange') {
        if (edit_type == '') {
            if (getObj('existing_portal') != null
                && ((getObj('existing_portal').value == 0 && getObj('portal').checked &&
                        (getObj('email') == null || trim(getObj('email').value) == '')) ||
                    (getObj('existing_portal').value == 1 && getObj('portal').checked &&
                        getObj('email') != null && trim(getObj('email').value) == ''))) {
                var confirm_str = arrJsPopLabel['PLEASEENTERVALIDEMAIL'];
                audioRemindsMsg("", "", popupobj.module, "yes", "yes", confirm_str);
                return false;
            }
        } else {
            if (getObj('portal') != null && getObj('portal').checked && getObj('portal_mass_edit_check').checked && (getObj('email') == null || trim(getObj('email').value) == '' || getObj('email_mass_edit_check').checked == false)) {
                var confirm_str = arrJsPopLabel['PLEASEENTERVALIDEMAIL'];
                audioRemindsMsg("", "", popupobj.module, "yes", "yes", confirm_str);
                return false;
            }
            if ((getObj('email') != null && trim(getObj('email').value) == '' && getObj('email_mass_edit_check').checked) && !(getObj('portal').checked == false && getObj('portal_mass_edit_check').checked)) {
                var confirm_str = arrJsPopLabel['SAVEEMPTYEMAILCANPROHIBITACCESS'];
                audioRemindsMsg("", "", popupobj.module, "yes", "yes", confirm_str);
                return false;
            }
        }
    }

    if ((popupobj.module == 'CashDeposit' || popupobj.module == 'PutCash')) {
        /**
         * 提现单编辑界面，点击快速创建提现单，将两个账户设置为不一样，关闭后，
         * 提现单编辑页面将跳过账户判断直接保存，因为这个时候界面上有了两个name值
         * 现在精确判断form表单下的name值，保证判断的精确性
         * @reason 0013946: 快速创建-存现单、提现单：当转出账户和转入账号一样保存时，没有进行判断
         * @author Tujt 2015-03-10
         */

        if (CrmPopup.isExistsObj(popupobj.divid, 'outaccount') && CrmPopup.isExistsObj(popupobj.divid, 'inaccount')) {
            if (CrmPopup.findHtmlobj(popupobj.divid, 'outaccount').find("option:selected").val() == CrmPopup.findHtmlobj(popupobj.divid, 'inaccount').find("option:selected").val()) {
                var confirm_str = arrJsPopLabel['taaacnbtttsa'];
                audioRemindsMsg("", "", popupobj.module, "yes", "yes", confirm_str);
                return false;
            }
        }
    }

    if (popupobj.module == 'Attachment' && gValidationCall != 'tabchange') {
        if (edit_type == '') {
            if (getObj('file_name') != undefined && trim(getObj('file_name').value) == '') {
                //上传附件为空，请上传附件！
                var confirm_str = arrJsPopLabel['PLEASEUPLOADATT'];
                audioRemindsMsg("", "", popupobj.module, "", "", confirm_str);
                return false;
            }
        }
    }

    //用户注册，账号不能用纯数字
    /*if(popupobj.module == 'Users'){
		if(getObj('user_name')!=undefined && getObj('mode') != undefined){
			var user_name = getObj('user_name').value;
			if(!isNaN(user_name) && getObj('mode').value != 'edit'){
				alert(arrJsPopLabel['usernamecannotbepurenumbers']);
				return false;
			}
		}
	}*/

    /*202 收款单 销售发票 佣金单  费用报销 源单合同订单必录时， 判断是否为空*/
    if (document.getElementById('salesordertypeofdata') != undefined && document.getElementById('salesordertypeofdata').value == 'M') {
        if (popupobj.module == 'Expense') {
            if (document.EditView.salesorder_name != undefined && document.EditView.salesorder_name.value == '') {
                var confirm_str = arrJsPopLabel['SOURCEMODULE'] + arrJsPopLabel['CANOTEMPTY'];
                audioRemindsMsg("", "", "", "", "", confirm_str);
                return false;
            }
        } else if (popupobj.module == 'SendCashBill' || popupobj.module == 'Stock') {
            if (document.getElementById('purchaseorder_id') != undefined && document.getElementById('purchaseorder_id').value == '') {
                var confirm_str = arrJsPopLabel['PURCHASEORDER'] + arrJsPopLabel['CANOTEMPTY'];
                audioRemindsMsg("", "", "", "", "", confirm_str);
                return false;
            }
        } else {
            if (document.getElementById('salesorder_id') != undefined && document.getElementById('salesorder_id').value == '') {
                if (popupobj.module == 'PurchaseOrder')
                    var confirm_str = arrJsPopLabel['SALESORDER'] + arrJsPopLabel['CANOTEMPTY'];
                else {
                    var confirm_str = arrJsPopLabel['SOURCEMODULE'] + arrJsPopLabel['CANOTEMPTY'];
                }
                audioRemindsMsg("", "", "", "", "", confirm_str);
                return false;
            }
        }

    }

    if (popupobj.module == 'SalesOrder') {
        if (edit_type == 'mass_edit') {
            if (getObj('enable_recurring_mass_edit_check') != null
                && getObj('enable_recurring_mass_edit_check').checked
                && getObj('enable_recurring') != null) {
                if (getObj('enable_recurring').checked && (getObj('recurring_frequency') == null
                    || trim(getObj('recurring_frequency').value) == '--None--' || getObj('recurring_frequency_mass_edit_check').checked == false)) {
                    //不需要修改
                    //alert(alert_arr.RECURRING_FREQUENCY_NOT_PROVIDED);
                    return false;
                }
                if (getObj('enable_recurring').checked == false && getObj('recurring_frequency_mass_edit_check').checked
                    && getObj('recurring_frequency') != null && trim(getObj('recurring_frequency').value) != '--None--') {
                    //不需要修改
                    //alert(alert_arr.RECURRING_FREQNECY_NOT_ENABLED);
                    return false;
                }
            }
        } else if (getObj('enable_recurring') != null && getObj('enable_recurring').checked) {
            if (getObj('recurring_frequency') == null || getObj('recurring_frequency').value == '--None--') {
                //不需要修改
                //alert(alert_arr.RECURRING_FREQUENCY_NOT_PROVIDED);
                return false;
            }
            var start_period = getObj('start_period');
            var end_period = getObj('end_period');
            if (trim(start_period.value) == '' || trim(end_period.value) == '') {
                var confirm_str = arrJsPopLabel['DTARTTIMEENDTIMECANOTEMPTY'];
                audioRemindsMsg("", "", "", "", "", confirm_str);
                return false;
            }
        }
    }

    if (popupobj.fields != undefined) {

        for (var i = 0; i < popupobj.fields.length; i++) {

            var curr_fieldname = popupobj.fields[i].fieldname;
            var curr_fieldinfo = popupobj.fields[i];
            var curr_fieldvalue = '';
            //if(popupobj.fields[i].allowedit == 'no'){
            //	continue;
            //}
            var fieldlabel = htmldecode(popupobj.fields[i].fieldlabel);

            if (edit_type == 'mass_edit') {
                if (curr_fieldname != 'salutationtype')
                    var obj = getObj(curr_fieldname + "_mass_edit_check");
                if (obj == null || obj.checked == false) continue;
            }
            if ((popupobj.module == 'PaymentPlan' || popupobj.module == 'SendPayment') && curr_fieldname == 'entitytypeid') {
                curr_fieldname = 'salesorder_id';
            }
            //duan 20230306 详情页点击小编辑时，不应该判断displaytype为2的字段，例如签到、工单管理的解决方案等
            if(popupobj.fields[i].displaytype == 2) continue;
            
            if (popupobj.fields[i].uitype == 202) {

                var type = popupobj.fields[i].typeofdata.split("~");
                if (type[1] == "M") {
                    if (popupobj.module == 'PaymentPlan' || popupobj.module == 'SendPayment') {

                        if (pagetype == 'detailview_modulepage' && popupobj.module == 'PaymentPlan') {
                            //edit:can 20200-10-09 42798: (61mis.com/kfbcrm)财务管理-收款计划-详情；在收款计划单据详情界面进行编辑字段操作，源单是有效的，选择源单字段提示“选择源单不能为空”。
                            if (!emptyCheck('entitytypeid_name', fieldlabel, CrmPopup.findHtmlobj(divid, 'entitytypeid_name').attr("type")))
                                return false;
                        } else //if (!emptyCheck('salesorder_name',fieldlabel,CrmPopup.findHtmlobj(divid,'salesorder_name').attr("type")))
                        {
                            //chj 2022/7/18 收款计划，新建已审批，修改单据的预计到款日，保存，提示选择源单不能为空，选择源单已选择。详情见附件。收款单编号：CP-20220706-345 ，可用这个单据测试。
                            /*if (popupobj.fields[i].allowedit == 'yes') {
                                // @edit:dong @date:2020/09/23 @reason: bug 0042709 selectlistval_label 改为selectlistval_name
                                if (!emptyCheck('salesorder_id', fieldlabel, CrmPopup.findHtmlobj(divid, 'salesorder_id').attr("type")))
                                    return false;
                            } else {
                                if (!emptyCheck('salesorder_id', fieldlabel, CrmPopup.findHtmlobj(divid, 'salesorder_id').attr("type")))
                                    return false;
                            }*/
                            //BUG0074822 lius 20231102 收款计划（GP2949）编辑单据保存时，一直提示“选择源单不能为空！”--源单有值
                            if (!emptyCheck('entitytypeid', fieldlabel, CrmPopup.findHtmlobj(divid, 'entitytypeid').attr("type")))
                                return false;
                        }

                        // @edit:dong @date:2020/09/23 @reason: bug0042735 详细页面小编辑 提示源单为空
                    } else if (pagetype == 'detailview_modulepage') {

                        if (!emptyCheck('selectlistval', fieldlabel, 'text'))
                            return false;
                    } else {
                        if (popupobj.fields[i].allowedit == 'yes') {
                            // @edit:dong @date:2020/09/23 @reason: bug 0042709 selectlistval_label 改为selectlistval_name
                            if (!emptyCheck('selectlistval_label', fieldlabel, CrmPopup.findHtmlobj(divid, 'selectlistval_label').attr("type")))
                                return false;
                        } else {
                            if (!emptyCheck('selectlistval', fieldlabel, CrmPopup.findHtmlobj(divid, 'selectlistval').attr("type")))
                                return false;
                        }
                    }
                }
            }
            if (CrmPopup.isExistsObj(divid, curr_fieldname) && popupobj.fields[i].typeofdata) {

                var type = popupobj.fields[i].typeofdata.split("~");

                if (type[1] == "M") {
                    if(CrmPopup.findHtmlobj(divid, curr_fieldname).length>0){
                        var tmpcurr_fieldnameobj = CrmPopup.findHtmlobj(divid, curr_fieldname);
                        if(tmpcurr_fieldnameobj.length>1) {
                            var  tmpcurrObjs = tmpcurr_fieldnameobj;
                            ld.each(tmpcurrObjs,function (){
                                if(ld(this).attr('fieldname') != undefined && ld(this).attr('fieldname') == curr_fieldname){
                                    tmpcurr_fieldnameobj = ld(this);
                                    return false;
                                }
                            })
                        }
                        if (tmpcurr_fieldnameobj.prop('tagName') != undefined || tmpcurr_fieldnameobj.attr("type") != undefined) {
                            if (!emptyCheck(curr_fieldname, fieldlabel, tmpcurr_fieldnameobj.attr("type")))
                                return false;
                        }
                    }


                }
                switch (type[0]) {
                    case "P"://正整数
                        var fldobj = CrmPopup.findHtmlobj(divid, curr_fieldname);

                        var r = /^\+?[1-9][0-9]*$/;//正整数
                        curr_fieldvalue = fldobj.val();
                        if(curr_fieldinfo.havesensitivevalue != undefined && curr_fieldinfo.havesensitivevalue == 'yes'){
                            curr_fieldvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(curr_fieldinfo.sensitiveencryptvalue,true,curr_fieldinfo);
                        }
                        if (isNaN(curr_fieldvalue)) {
                            var confirm_str = fieldlabel + arrJsPopLabel['SHOULDPOSITIVEINTEGER'];
                            audioRemindsMsg("", "", "", "", "", confirm_str);
                            return false;
                        }
                        if (!r.test(curr_fieldvalue)) {
                            var confirm_str = fieldlabel + arrJsPopLabel['SHOULDPOSITIVEINTEGER'];
                            audioRemindsMsg("", "", "", "", "", confirm_str);
                            return false;
                        }
                        break;
                    case "O"  :
                        break;
                    case "V"  :
                        //by andy qq 改进 临时会话
                        if (curr_fieldname == 'qq') {
                            if (CrmPopup.findHtmlobj(divid, curr_fieldname).val() != '') {
                                curr_fieldvalue = CrmPopup.getHtmlobjval(divid, curr_fieldname);
                                if(curr_fieldinfo.havesensitivevalue != undefined && curr_fieldinfo.havesensitivevalue == 'yes'){
                                    curr_fieldvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(curr_fieldinfo.sensitiveencryptvalue,true,curr_fieldinfo);
                                }
                                if (!isQQ(curr_fieldvalue)) {
                                    var confirm_str = fieldlabel + arrJsPopLabel['FORMATERROR'];
                                    audioRemindsMsg("", "", "", "", "", confirm_str);
                                    return false;
                                }
                            }
                        }
                        break;
                    case "C"  :
                        break;
                    case "DT" :
                        if (CrmPopup.getHtmlobjval(divid, curr_fieldname) != undefined && CrmPopup.getHtmlobjval(divid, curr_fieldname).replace(/^\s+/g, '').replace(/\s+$/g, '').length != 0) {
                            if (type[1] == "M")
                                if (!emptyCheck(curr_fieldname, fieldlabel, type[2]))
                                    return false
                            if (type[0] == 'DT') {

                                if (!dateTimesecValidate(curr_fieldname, fieldlabel, type[0]))
                                    return false;
                            }
                            if (type[2] == "DT") {//BY LD KEVIN type[2]="DT" 自定义字段添加日期时间控件
                                if (!dateTimesecValidate(curr_fieldname, fieldlabel, type[2]))
                                    return false;
                            } else if (typeof (type[3]) == "undefined" && type[2] != "DT") {
                                var currdatechk = "OTH"
                            } else {
                                var currdatechk = type[3]
                            }
                            //edit:kevin date:2013-05-30 reason:4028 type[2]!='time_start' 时间typeofdata:DT~M~time_start
                            if (type[0] != "DT" && type[2] != "DT" && type[2] != 'time_start') {
                                if (!dateTimeValidate(curr_fieldname, type[2], fieldlabel, currdatechk))
                                    return false;
                            }
                            if (type[4] && type[2] != "DT") {
                                if (!dateTimeComparison(curr_fieldname, type[2], fieldlabel, type[5], type[6], type[4]))
                                    return false

                            }
                        }
                        break;
                    case "D"  :

                        if (CrmPopup.getHtmlobjval(divid, curr_fieldname).replace(/^\s+/g, '').replace(/\s+$/g, '').length != 0) {
                            if (typeof (type[2]) == "undefined") var currdatechk = "OTH"
                            else var currdatechk = type[2];


                            if (!dateValidate(curr_fieldname, fieldlabel, currdatechk))
                                return false;

                            if (type[3]) {
                                if (popupobj.module == 'SalesOrder' && curr_fieldname == 'end_period'
                                    && (getObj('enable_recurring') == null || getObj('enable_recurring').checked == false)) {
                                    continue;
                                }

                                if (!dateComparison(curr_fieldname, fieldlabel, type[4], type[5], type[3]))
                                    return false
                            }
                        }
                        break;
                    case "T"  :
                        if (CrmPopup.getHtmlobjval(divid, curr_fieldname).replace(/^\s+/g, '').replace(/\s+$/g, '').length != 0) {
                            if (typeof (type[2]) == "undefined") var currtimechk = "OTH";
                            else var currtimechk = type[2];
                            if (!timeValidate(curr_fieldname, fieldlabel, currtimechk))
                                return false;
                            if (type[3]) {
                                if (!timeComparison(curr_fieldname, fieldlabel, type[4], type[5], type[3]))
                                    return false;
                            }
                        }
                        break;
                    case "I"  :
                        curr_fieldvalue = CrmPopup.getHtmlobjval(divid, curr_fieldname);
                        if(curr_fieldinfo.havesensitivevalue != undefined && curr_fieldinfo.havesensitivevalue == 'yes'){
                            curr_fieldvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(curr_fieldinfo.sensitiveencryptvalue,true,curr_fieldinfo);
                        }
                        if (curr_fieldvalue != undefined && curr_fieldvalue != "" && CrmPopup.getHtmlobjval(divid, curr_fieldname).replace(/^\s+/g, '').replace(/\s+$/g, '').length != 0) {
                            if (curr_fieldvalue.length != 0) {
                                if (!intValidate(curr_fieldname, '', fieldlabel))
                                    return false
                                if (type[2]) {
                                    if (!numConstComp(curr_fieldname, fieldlabel, type[2], type[3]))
                                        return false
                                }
                            }
                        }
                        break;
                    case "N"  :
                    case "NN" :
                        curr_fieldvalue = CrmPopup.getHtmlobjval(divid, curr_fieldname);
                        if(curr_fieldinfo.havesensitivevalue != undefined && curr_fieldinfo.havesensitivevalue == 'yes'){
                            curr_fieldvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(curr_fieldinfo.sensitiveencryptvalue,true,curr_fieldinfo);
                        }
                        if (curr_fieldvalue.replace(/^\s+/g, '').replace(/\s+$/g, '').length != 0) {
                            if (curr_fieldvalue.length != 0) {
                                if (typeof (type[2]) == "undefined") var numformat = "any";
                                else var numformat = type[2];
                                if (type[0] == "NN") {
                                    if (!numValidate(curr_fieldname, fieldlabel, numformat, true))
                                        return false;
                                } else if (!numValidate(curr_fieldname, fieldlabel, numformat))
                                    return false;
                                if (type[3]) {
                                    if (!numConstComp(curr_fieldname, fieldlabel, type[3], type[4]))
                                        return false;
                                }
                            }
                        }
                        break;
                    case "E"  :
                        curr_fieldvalue = CrmPopup.getHtmlobjval(divid, curr_fieldname);
                        if(curr_fieldinfo.havesensitivevalue != undefined && curr_fieldinfo.havesensitivevalue == 'yes'){
                            curr_fieldvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(curr_fieldinfo.sensitiveencryptvalue,true,curr_fieldinfo);
                        }
                        if (curr_fieldvalue.replace(/^\s+/g, '').replace(/\s+$/g, '').length != 0) {
                            if (curr_fieldvalue.length != 0) {
                                var etype = "EMAIL";
                                if (!patternValidate(curr_fieldname, fieldlabel, etype))
                                    return false;
                            }
                        }
                        break;
                }
                curr_fieldvalue = CrmPopup.getHtmlobjval(divid, curr_fieldname);
                if(curr_fieldinfo.havesensitivevalue != undefined && curr_fieldinfo.havesensitivevalue == 'yes'){
                    curr_fieldvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(curr_fieldinfo.sensitiveencryptvalue,true,curr_fieldinfo);
                }
                //start Birth day date validation
                if ((curr_fieldname == "birthday" || curr_fieldname == "birthday_mapping") && curr_fieldvalue.replace(/^\s+/g, '').replace(/\s+$/g, '').length != 0) {
                    var now = new Date()
                    var currtimechk = "OTH"
                    var datelabel = fieldlabel;

                    var datevalue = CrmPopup.getHtmlobjval(divid, curr_fieldname).replace(/^\s+/g, '').replace(/\s+$/g, '')
                    if (!dateValidate(curr_fieldname, fieldlabel, currdatechk)) {
                        try {
                            CrmPopup.findHtmlobj(divid, curr_fieldname).focus();
                        } catch (error) {
                        }
                        return false
                    } else {
                        datearr = splitDateVal(datevalue);
                        dd = datearr[0]
                        mm = datearr[1]
                        yyyy = datearr[2]
                        var datecheck = new Date()
                        datecheck.setYear(yyyy)
                        datecheck.setMonth(mm - 1)
                        datecheck.setDate(dd)
                        if (!compareDate(datecheck, datelabel, now, arrJsPopLabel['CURRENTDATE'], "L")) {
                            try {
                                CrmPopup.findHtmlobj(divid, curr_fieldname).focus();
                            } catch (error) {
                            }
                            return false
                        }
                    }
                }
                //End Birth day
            }

        }
    }
    if (popupobj.validatasaverule != undefined && popupobj.validatasaverule != '') {
        var validatasaveobj = new validatasave(popupobj.validatasaverule, 'php');
        if (!validatasaveobj.mainphpvalidata()) {
            return false;
        }
    }
    var validatasaveobj = new validatasave(popupobj.validatasave, 'js');
    if (!validatasaveobj.mainjsvalidata()) {

        return false;
    }


    //克莱门特：要求完成时间大于等于实际上门日期，否则不能保存；要求完成时间和实际上门日期小于等于制单日期（创建日期），否则不能保存；
    if (popupobj.module == 'OutboundOrder' && document.getElementById('version_account') != undefined && document.getElementById('version_account').value == 'climaveneta') {
        var popupobj = CrmPopup.getPopupObj("last");
        var divid = popupobj.divid;
        var realtime = CrmPopup.findHtmlobj(divid, 'realtime').val();
        var finishtime = CrmPopup.findHtmlobj(divid, 'finishtime').val();
        if (!empty(realtime) && !empty(finishtime)) {
            if (realtime > finishtime) {
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", '完成时间小于实际上门日期，保存失败！');
                return false;
            }
        }
        var nowdate = getNow();
        if (!empty(realtime) || !empty(finishtime)) {
            if (realtime > nowdate) {
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", '实际上门日期不能大于当前日期，保存失败！');
                return false;
            }
            if (finishtime > nowdate) {
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", '完成时间不能大于当前日期，保存失败！');
                return false;
            }
        }
    }
    //克莱门特：服务合同：维保日期设置不得早于开始日期，否则不让保存。
    if (popupobj.module == 'ServiceContracts' && document.getElementById('version_account') != undefined && document.getElementById('version_account').value == 'climaveneta') {
        var popupobj = CrmPopup.getPopupObj("last");
        var divid = popupobj.divid;
        var maintenance_startdate = CrmPopup.findHtmlobj(divid, 'maintenance_startdate').val();
        var maintenance_enddate = CrmPopup.findHtmlobj(divid, 'maintenance_enddate').val();
        if (!empty(maintenance_startdate) && !empty(maintenance_enddate)) {
            if (maintenance_enddate < maintenance_startdate) {
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", '维保期限设置不得早于维保开始日期！');
                return false;
            }
        }
        //合同类型不是维保合同，无法保存
        if (CrmPopup.findHtmlobj(divid, 'cf_2326').val() != undefined && CrmPopup.findHtmlobj(divid, 'cf_2326').val() != '维保合同') {
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", '合同类型非维保合同，保存失败！');
            return false;
        }
        var cf_2326 = CrmPopup.findHtmlobj(divid, 'cf_2326').val();

    }

    if (popupobj.module == 'Reminds' || popupobj.module == 'ContactRecords' || popupobj.module == 'Calendar') {
        if (popupobj.module == 'Reminds' || document.getElementById('pop_reminds') != undefined && document.getElementById('pop_reminds').checked) {
            if (popupobj.module == 'Reminds') {
                act_time = getObj('date_time').value;

            } else {
                act_time = getObj('date_only').value;
                getObj('date_time').value = act_time;
            }
            cur_time = new Date();
            cur_time.setMinutes(cur_time.getMinutes() - 10);
            now_mon = cur_time.getMonth() + 1;
            cur_time = cur_time.getFullYear() + '-' + getDigital(now_mon) + '-' + getDigital(cur_time.getDate()) + ' ' + getDigital(cur_time.getHours()) + ':' + getDigital(cur_time.getMinutes());
            if (act_time < cur_time) {
                var confirm_str = arrJsPopLabel['REMINDENTIMESHOULDGREATERCURRENTTIME'];
                audioRemindsMsg("", "", "", "", "", confirm_str);
                return false;
            }
        }
        //Edit:can reason:9873: 手动新建提醒后，弹出的提醒查看界面，相关模块字段没有显示数据
        if (popupobj.module == 'Reminds') {
            if (getObj('related_to_type') != undefined && getObj('reltab') != undefined)
                getObj('reltab').value = getObj('related_to_type').options[getObj('related_to_type').options.selectedIndex].value;
        }
        if (popupobj.module == 'ContactRecords') {
            cur_time = new Date();
            cur_time.setMinutes(cur_time.getMinutes() - 10);
            now_mon = cur_time.getMonth() + 1;
            cur_time = cur_time.getFullYear() + '-' + getDigital(now_mon) + '-' + getDigital(cur_time.getDate()) + ' ' + getDigital(cur_time.getHours()) + ':' + getDigital(cur_time.getMinutes());
            if (document.getElementById('set_remind') != undefined && document.getElementById('set_remind').checked) {
                act_time = getObj('email_date_only').value;
                getObj('email_remind').value = act_time;
            }
            if (document.getElementById('pop_reminds') != undefined && document.getElementById('pop_reminds').checked) {
                act_time = getObj('date_only').value;
                getObj('date_time').value = act_time;
            }
            if (act_time != undefined && act_time < cur_time) {
                var confirm_str = arrJsPopLabel['REMINDENTIMESHOULDGREATERCURRENTTIME'];
                audioRemindsMsg("", "", "", "", "", confirm_str);
                return false;
            }
            if ((document.getElementById('set_remind') != undefined && document.getElementById('set_remind').checked) ||
                (document.getElementById('pop_reminds') != undefined && document.getElementById('pop_reminds').checked)) {
                textValue = getObj('contents').value;
                if (trim(textValue) == '' || trim(textValue) == '<br>') {
                    var confirm_str = arrJsPopLabel['REMINDERSCANOTEMPTY'];
                    audioRemindsMsg("", "", "", "", "", confirm_str);
                    return false;
                }
            }
        }

        if (popupobj.module == 'Calendar') {
            var startdate = "";
            var enddate = "";
            if (CrmPopup.isExistsObj(popupobj.divid, 'date_start')) {
                startdate = CrmPopup.findHtmlobj(popupobj.divid, 'date_start').val();
            }
            if (CrmPopup.isExistsObj(popupobj.divid, 'due_date')) {
                enddate = CrmPopup.findHtmlobj(popupobj.divid, 'due_date').val();
            }
            if (!empty(startdate) && !empty(enddate) && startdate > enddate) {
                var confirm_str = arrJsPopLabel['THESTARTTIME'];
                audioRemindsMsg("", "", "", "", "", confirm_str);
                return false;
            }
        }
    }
    if (popupobj.module == 'CashBill') {
        //editor:gyq_161 reason:收款单   2019/11/26 14:39
        var popupobj = CrmPopup.getPopupObj("last");
        if (ld('#' + popupobj.divid + ' [name="nopaymentplan"]').length > 0) {
            var nopaymentplan = ld('#' + popupobj.divid + ' [name="nopaymentplan"]').get(0).value;
            nopaymentplan = parseFloat(nopaymentplan.split(",").join(""));
            //调整金额只可以录入正数
            var temp = /^(0|[1-9]{1}\d{0,})(\.(\d{1}\d{0,}))?$/.test(nopaymentplan);
            if (!temp) {
                var confirm_str = arrJsPopLabel['INVALIDADJUSTMENTAMOUNT'];
                audioRemindsMsg("", "", "", "", "", confirm_str);
                return false;
            }
        }
    }
    if (popupobj.module == 'SendCashBill') {
        if (document.getElementById("nosendpayment") != undefined) {
            var nosendpayment = document.getElementById("nosendpayment").value;
            nosendpayment = parseFloat(nosendpayment.split(",").join(""));
            //调整金额只可以录入正数
            var temp = /^(0|[1-9]{1}\d{0,})(\.(\d{1}\d{0,}))?$/.test(nosendpayment);
            if (!temp) {
                var confirm_str = arrJsPopLabel['INVALIDADJUSTMENTAMOUNT'];
                audioRemindsMsg("", "", "", "", "", confirm_str);
                return false;
            }
        }
    }

    // 删除收款单合计不能为空或0的判断 By luyx 2020-06-29
    /*
    if(popupobj.module=='CashBill')
    {
        if(CrmPopup.findHtmlobj(popupobj.divid,'cashbill_total').val() == 0||CrmPopup.findHtmlobj(popupobj.divid,'cashbill_total').val()==""){
			audioRemindsMsg("","LdPopWidth400px","","","",arrJsPopLabel['TOTALOTHER']+arrJsPopLabel['CANNOTEMPTYORZERO']);
            return false;
		}

    }
    */

    if (popupobj.module == 'Commission') {
        if (document.getElementById("setnoamount") != undefined) {
            var setnoamount = document.getElementById("setnoamount").value;
            setnoamount = parseFloat(setnoamount.split(",").join(""));
            //调整金额只可以录入正数
            var temp = /^(0|[1-9]{1}\d{0,})(\.(\d{1}\d{0,}))?$/.test(setnoamount);
            if (!temp) {
                var confirm_str = arrJsPopLabel['INVALIDADJUSTMENTAMOUNT'];
                audioRemindsMsg("", "", "", "", "", confirm_str);
                return false;
            }
        }
    }
    if (popupobj.module == 'Contacts') {
        if (getObj('imagename')) {
            if (getObj('imagename').value != '') {
                var image_arr = new Array();
                image_arr = (getObj('imagename').value).split(".");
                var image_arr_last_index = image_arr.length - 1;
                if (image_arr_last_index < 0) {
                    var confirm_str = arrJsPopLabel['AVAILABLEFILETYS'];
                    audioRemindsMsg("", "", "", "", "", confirm_str);
                    return false;
                }
                var image_ext = image_arr[image_arr_last_index].toLowerCase();
                if (image_ext == "jpeg" || image_ext == "png" || image_ext == "jpg" || image_ext == "gif" || image_ext == "bmp" || image_ext == "ico") {
                    return true;
                } else {
                    var confirm_str = arrJsPopLabel['AVAILABLEFILETYS'];
                    audioRemindsMsg("", "", "", "", "", confirm_str);
                    return false;
                }
            }
        }
    }

    for (var j = 0; j < popupobj.fields.length; j++) {
        var curr_fieldname = popupobj.fields[j].fieldname;
        var fieldlabel = popupobj.fields[j].fieldlabel;
        var fieldinfo = popupobj.fields[j];

        if (CrmPopup.isExistsObj(divid, curr_fieldname)) {
            var currobjvalue = CrmPopup.getHtmlobjval(divid, curr_fieldname);
            if(fieldinfo != undefined && fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
                currobjvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(fieldinfo.sensitiveencryptvalue,true,fieldinfo);
            }
            if (curr_fieldname == "date_start" || curr_fieldname == "task_date_start") {
                var datelabel = fieldlabel;
                var datefield = curr_fieldname;
                var startdatevalue = currobjvalue.replace(/^\s+/g, '').replace(/\s+$/g, '')
            }
            if (curr_fieldname == "time_start" || curr_fieldname == "task_time_start") {
                var timelabel = fieldlabel;
                var timefield = curr_fieldname;
                var timeval = currobjvalue.replace(/^\s+/g, '').replace(/\s+$/g, '')
            }
            if (curr_fieldname == "eventstatus" || curr_fieldname == "taskstatus") {
                var statusvalue = currobjvalue.replace(/^\s+/g, '').replace(/\s+$/g, '')
                var statuslabel = popupobj.fields[j++].fieldlabel;

            }
        }
    }

    //0019731: 项目>费率设定>新增界面：新增单据时，如果起始时间晚于截止时间，应该给出提示
    if (popupobj.module == 'Rate') {
        if (document.getElementById('jscal_field_startdate') != undefined && document.getElementById('jscal_field_enddate') != undefined) {
            if (document.getElementById('jscal_field_startdate').value > document.getElementById('jscal_field_enddate').value) {
                var confirm_str = arrJsPopLabel['THISDATENOEDNDATE'];
                audioRemindsMsg("", "", "", "", "", confirm_str);
                return false;
            }
        }
    }
    if (statusvalue == "Planned") {
        var dateelements = splitDateVal(startdatevalue)
        var hourval = parseInt(timeval.substring(0, timeval.indexOf(":")))
        var minval = parseInt(timeval.substring(timeval.indexOf(":") + 1, timeval.length))
        dd = dateelements[0]
        mm = dateelements[1]
        yyyy = dateelements[2]

        var chkdate = new Date()
        chkdate.setYear(yyyy)
        chkdate.setMonth(mm - 1)
        chkdate.setDate(dd)
        chkdate.setMinutes(minval)
        chkdate.setHours(hourval)
        if (!comparestartdate(chkdate)) return false;
    }//end


    if (popupobj.module == 'Expense' && typeof PiaozoneObj != "undefined" && PiaozoneObj.isauthorize=='yes') {//ld('#' + popupobj.divid + ' #pz_block').length > 0  没有授权或者授权到期，就不用作判断了
        var pz_invoicetotal = ld('#' + popupobj.divid + ' #pz_invoicetotal').val();//发票合计值
        if (Object.keys(PiaozoneObj.invoicedata).length <= 0) {
            MessagePopup.TipOne_warning(arrJsPopLabel['InvoiceDetailsCannotEmpty']);
            return false;
        }
        if (ld('#' + popupobj.divid + ' [name="total"]').length > 0) {
            var total = ld('#' + popupobj.divid + ' [name="total"]').val();//分录合计值
            total = JsNumbertoFixed(total,2);
        }else{
            var rowobjs = popupobj.getTrObjsByDelType("no");
            var total  = 0;
            ld.each(rowobjs, function () {
                var tr_total = parseFloat(ld(this).find("#rmb_total").val());
                total += tr_total;
            });
            //console.log(total);
            total = JsNumbertoFixed(total,2); //parseFloat(total).toFixed(2);
        }

        if (parseFloat(total)>parseFloat(pz_invoicetotal)) {
            MessagePopup.TipOne_warning('合计不能超出发票合计');
            return false;
        }


    }

    return true;
}

doformValidation.imagecheck = function () {//Liver fieldinfoobjs != undefined && fieldinfoobjs != null 不能去掉，去掉保存销售机会等报错
    if (typeof (fieldinfoobjs) != 'undefined' && fieldinfoobjs != undefined && fieldinfoobjs != null && fieldinfoobjs.fields != '' && fieldinfoobjs.fields != undefined) {


        for (i = 0; i < fieldinfoobjs.fields.length; i++) {
            if (fieldinfoobjs.fields[i].uitype == 69 && fieldinfoobjs.fields[i].typeofdata.indexOf("M") > 0) {
                //24151: 图片类型的字段，设为必填项后，不上传图片，点击保存，还是可以保存成功。
                if (parseInt(ld('#files_list').children('div').length) < 2) {
                    var confirm_str = fieldinfoobjs.fields[i].fieldlabel + arrJsPopLabel['CANOTEMPTY'];
                    audioRemindsMsg("", "", "", "", "", confirm_str);
                    return false;
                }
            }
        }
    }
    return true;
}
var httpreq = null;
var isDuplicate = true;
var httpsyscode = null;

//Function added for Mass select in Popup - Philip
/**
 * edit:chj
 * reason: 批量编辑  提交按钮事件
 */
function massEditSubmit() {

    //todo:重写该方法
    //edit:can 2020-09-0942626: （http://xiaoshou360.com/XS/zhigu?[^]）（上海志谷建筑装饰工程有限公司客户问题）合同管理菜单>材料采购单模块列表界面>查询单据编号为“PO160”>勾选该单
    var popupobj = CrmPopup.getPopupObj('last');

    var filterstr = '';
    var assigntype = '';
	//230726 wym XUQIU1000102 筛选掉更多币种隐藏域中的checkbox 所以加了not筛选器 
    ld('form[name=EditView] input[type=checkbox]:checked:not([data-mass-edit-type="cur_display"])').each(function () {
        var namestr = ld(this).attr('name');
        var namearr = namestr.split('_mass_edit_check');
        var fldname = namearr[0];
        if(ld('form[name=EditView] input[name=' + fldname + ']') != undefined) {
			//230726 wym XUQIU1000102 该两种字段会含有更多币种 隐藏域中的值也需要传值保存
            if(fldname=='unit_price'||fldname=='procostprice'){
                if(ld("form[name=EditView] #"+fldname+"_currency_class input[type=checkbox]:checked")) {
                    var check_Arr = ld("form[name=EditView] #"+fldname+"_currency_class input[type=checkbox]:checked");
                    check_Arr.each(function (){
                        var fldname_check = ld(this).attr('name');
                        var fldvalue_check = ld(this).val();
                        filterstr += '&' + fldname_check + '=' + encodeURIComponent(fldvalue_check);

                        var fldname_check_arr = fldname_check.split('_check');
                        var currency_id = fldname_check_arr[0].substr(-1);
                        var fldname_cur = fldname+"_curname"+currency_id ;
                        var fldvalue_cur = ld('#' + fldname_cur).val();
                        filterstr += '&' + fldname_cur + '=' + encodeURIComponent(fldvalue_cur);
                    })
                }
            }
            else if(fldname == 'is_admin'){//2024-3-15 xxy BUG20240314-25 成员管理->批量编辑，勾选“是否管理员”设为否时没有生效
               ld('form[name=EditView] [name=' + fldname + ']').attr('value',ld('form[name=EditView] [name=' + fldname + ']').prop('checked')?'on':'off');
            }
            //ls 2022-02-17 0050010: （需补丁）客户》选择单据》批量编辑，备注信息区块的“富文本框”字段，在批量编辑时不是富文本框格式，然后调用文档模板是代码(获取富文本框的值不能再使用标签选择器)
            var fldvalue = ld('form[name=EditView] [name=' + fldname + ']').val();
            if (fldvalue == undefined) {
                var fldvalue = ld('#' + fldname).val();
            }
        } else {
            var fldvalue = ld('#' + fldname).val();
        }
        filterstr += '&' + namestr + '=' + encodeURIComponent(fldvalue);
    });

    //异常处理
    if (filterstr == '' || ld("#idstring").val() == '') {

        CrmPopup.getPopupObj("last").CancelEvent();


        return false;
    }
    var listpopupobj = CrmPopup.getPopupObj('lastprev');

    //获取批量编辑 - 选中的单据ID
    // var idstring = ld("#idstring").val();
    if (ld('input[name=assigntype]') != undefined) {
        assigntype = ld('input[name=assigntype]').val();
    }
    // $("status").style.display="block";

    /*var urlstring = 'module='+popupobj.module+'&action='+popupobj.module+'Ajax&file=MassEditSave'+filterstr+'&massedit_module='+popupobj.module
		+'&assigntype='+assigntype+'&massedit_recordids='+idstring+"&ajaxaction=MassEditSave";
	// urlstring+="&mass_edit_totalrows="+document.getElementById("mass_edit_totalrows").value;*/

    // @edit:liushuai,2021-03-04,reason:【ID1001390】批量编辑增加显示进度条
    // @edit:liushuai,2021-04-21,0045572: 批量编辑，超过一页的数据后就会多出一个失败案例，且在列表中找不到（列表中单据会少一个）(不知何时最后一个分号又被去掉了)
    // var selectlen = idstring.split(';').length;//-1 因为最后多一个分号；  //多选和全选是一样的格式，全选没有像批量提交批量分配那样参数为all

    var select_options = document.getElementById('allselectedboxes').value;

    var numOfRows = document.getElementById('numOfRows').value;
    var excludedRecords = $('excludedRecords').value;
    if (select_options == 'all') {
        var idstring = select_options;
        var skiprecords = excludedRecords.split(";");
        var count = skiprecords.length;

        if (count > 1) {
            count = numOfRows - count + 1;
        } else {
            count = numOfRows;
        }
    } else {
        var x = select_options.split(';');
        var count = x.length - 1;
        var idstring = select_options;
    }

    var selectlen = count;
    var intervalrow = 8; //默认 8 数据量太大  请求次数过多  会导致执行起来过久
    if (selectlen > 100) {
        intervalrow = Math.ceil(selectlen / 10); //向上取整
    }
    //duan 2022-2-28 设置批量操作上限20，如果一次性选中的记录条数大于系统设置的批量操作最大条数10倍以上，会导致进度条未生效
    if (intervalrow > 20) {
        intervalrow = 20;
    }

    startMassEditSubmit(popupobj.module, selectlen, filterstr, assigntype, idstring, 0, intervalrow);
}

function startMassEditSubmit(module, selectlen, filterstr, assigntype, idstring, startrow, intervalrow) {
    var endrow = startrow + intervalrow;
    if (endrow > selectlen) {  //最后一个请求
        endrow = selectlen;
    }
    var urlstring = 'module=' + module + '&action=' + module + 'Ajax&file=MassEditSave&massedit_module=' + module
        + '&assigntype=' + assigntype + '&massedit_recordids=' + idstring + "&ajaxaction=MassEditSave&excludedRecords=" + $('excludedRecords').value;
    // urlstring+="&mass_edit_totalrows="+document.getElementById("mass_edit_totalrows").value;

    urlstring += "&selectlen=" + selectlen + "&startrow=" + startrow + "&endrow=" + endrow;

    //zkt 模块树结构显示增加条件，获取树结构点击条件
    if (ld("#isshowModuleListTree") != undefined && ld("#isshowModuleListTree").val() == 'yes') {
        urlstring += '&isshowModuleListTree=yes';
    }

    ldAjaxHtmlNoProgress("index.php?" + urlstring, filterstr, function (rest) {//批量提交保存
        ld('#rptContentLoading').hide();
        if (rest == '') {
            DelProgressObjs();
            return false;
        }
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);

        var tmppopupobjobj;
        if (startrow == 0) {
            tmppopupobjobj = ProgressPopup.load(restobj.title.value, "", "", 500, module, "", "", "", "");
            tmppopupobjobj.show();
        } else {
            tmppopupobjobj = CrmPopup.getPopupObj('last');
        }
        var maxrows = parseInt(restobj.maxrows);
        var percent = parseInt(((startrow + intervalrow) / maxrows * 100));

        tmppopupobjobj.setPercentWidth(percent);
        tmppopupobjobj.setTotalNum(restobj.selectrows);
        tmppopupobjobj.setCurNum(startrow);
        if (maxrows != restobj.selectrows) {
            tmppopupobjobj.setValidataNum(maxrows);
        }

        if (parseInt(startrow + intervalrow) < parseInt(restobj.maxrows)) {
            startMassEditSubmit(module, selectlen, filterstr, assigntype, idstring, startrow + intervalrow, intervalrow)
            return false;
        } else {
            tmppopupobjobj.CancelEvent();
        }

        CrmPopup.getPopupObj("last").CancelEvent();
        // $("status").style.display="none";
        createElementDiv('massedit_div');//创建DIV
        ld('#massedit_divtitlename').html(restobj.title.value);


        sethtml(document.getElementById('massedit_divcontent'), restobj.log.value);
        ld('#massedit_div .E_pbtn .E_pbtncancel').css('display', 'none');
        fnvshobj(this, 'massedit_div');
        ////edit:can 2020-11-16 43280: （61mis.com/kfbcrm）客户管理-客户-分配/共享/批量编辑；在客户单据列表，选择单据进行分配/共享/批量编辑操作，弹出操作成功弹窗；在该弹窗点击单据编号，进入详情，详情界面显示在了操作成功弹窗后面；
        ld("#layer").css("z-Index", CrmPopup.zIndex);
        CrmPopup.zIndex++;
        ld('#massedit_div').css("z-Index", CrmPopup.zIndex);
        CrmPopup.zIndex++;
        ld('#massedit_div .E_pbtn .E_pbtnok').unbind('click').on('click', function () {
            fninvshnew('massedit_div');
            puyoungJS_DialogBox.unblock();
            if (document.getElementById('allselectedboxes') != undefined) {
                document.getElementById('allselectedboxes').value = '';
            }
            if (document.getElementById('selectedboxes') != undefined) {
                document.getElementById('selectedboxes').value = '';

            }
            //ls 2022-02-16 0049524: 销售机会》勾选2个单据批量编辑成功后，成功弹窗中点击单据编号穿透到单据详情， 这时点击任意相关信息模块，再返回弹窗点击确认后，列表会显示对应相关信息的模块
            var popupobj = CrmPopup.getPopupObj('last');
            getListViewEntries_js(popupobj.module, 'start=' + restobj.start.value);//刷新页面

        });
        DelProgressObjs();
    });
}

function isQQ(qq) {
    var filter = /^\s*[.0-9]{5,20}\s*$/;
    if (!filter.test(qq)) {
        return false;
    } else {
        return true;
    }
}

function AjaxDuplicateValidate(a, b, c) {
    getJsScript('include/js/ldcrm.edit.js', function () {
        AjaxDuplicateValidates(a, b, c);
    });
}

// Setting cookies
function set_cookie(name, value, exp_y, exp_m, exp_d, path, domain, secure) {
    var cookie_string = name + "=" + escape(value);

    if (exp_y) //delete_cookie(name)
    {
        var expires = new Date(exp_y, exp_m, exp_d);
        cookie_string += "; expires=" + expires.toGMTString();
    }

    if (path) cookie_string += "; path=" + escape(path);
    if (domain) cookie_string += "; domain=" + escape(domain);
    if (secure) cookie_string += "; secure";

    document.cookie = cookie_string;
}

// Retrieving cookies
function get_cookie(cookie_name) {
    var results = document.cookie.match(cookie_name + '=(.*?)(;|$)');
    if (results) return (unescape(results[1]));
    else return null;
}

// Delete cookies
function delete_cookie(cookie_name) {
    var cookie_date = new Date();  // current date & time
    cookie_date.setTime(cookie_date.getTime() - 1);
    document.cookie = cookie_name += "=; expires=" + cookie_date.toGMTString();
}

/*
edit:can
date;20130822
reason:打印模板导出为DOC
*/
function ConvertToDOC(obj, module, recordid) {
    var popupobj = CrmPopup.getPopupObj("last");

    var printid = ld("#" + popupobj.divid + " [name=print_select]").val();
    if (printid == 0) {
        //请选择打印模板！
        var confirm_str = arrJsPopLabel['PLEASESELECTPRINTTEMPLATES'];
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
        return false;
    }


    var alink = document.createElement('a');
    alink.style.display = 'none'
    alink.href = 'index.php?module=Settings&action=TemplatePrintHtml&CreateDOC=true&tabname=' + module + '&printid=' + printid + '&record=' + recordid;
    alink.download = '';
    document.body.appendChild(alink)
    alink.click();
    URL.revokeObjectURL(alink.href) // 释放URL 对象
    document.body.removeChild(alink)

    //document.location.href='index.php?module=Settings&action=TemplatePrintHtml&CreateDOC=true&tabname='+module+'&printid='+printid+'&record='+recordid;
}

/*
edit:can
date;20130822
reason:打印模板导出为PDF
*/
function ConvertToPDF(obj, module, recordid) {
    var popupobj = CrmPopup.getPopupObj("last");

    var printid = ld("#" + popupobj.divid + " [name=print_select]").val();
    if (printid == 0) {
        //请选择打印模板！
        var confirm_str = arrJsPopLabel['PLEASESELECTPRINTTEMPLATES'];
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
        return false;
    }
    //alert(2);
    var alink = document.createElement('a');
    alink.style.display = 'none'
    alink.href = 'index.php?module=Settings&action=TemplatePrintHtml&CreatePDF=true&tabname=' + module + '&printid=' + printid + '&record=' + recordid;
    alink.download = '';
    document.body.appendChild(alink)
    alink.click();
    URL.revokeObjectURL(alink.href) // 释放URL 对象
    document.body.removeChild(alink)

    // document.location.href='index.php?module=Settings&action=TemplatePrintHtml&CreatePDF=true&tabname='+module+'&printid='+printid+'&record='+recordid;
}

function changepass() {
    getJsScript('include/js/ldcrm.edit.js', function () {
        changepasss();
    });
}

/*
edit:can
date:20140304
reason:7317:联系记录新增界面：项目、项目任务字段：若选择有客户，则只能选择当前用户有权限看到的该客户的项目信息。
*/
function selectRelatedTo(fldtype, fldname, mod, id) {
    var popupobj = CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    fldtype = CrmPopup.findHtmlobj(popupobj.divid, fldtype).val()
    if ((fldtype == 'SalesOrder' || fldtype == 'ServiceContracts') && mod == 'Project') {
        //zkt 20231206 BUG0076808  升级到最新版，项目立项模块，选择销售合同。原单不显示，相关信息带出不显示，（三个客户升级同时都有该问题，）请提供对应问题补丁
        showrelatedlist(mod, fldtype, "select",'', fldname);
        return;
    } else if (document.EditView.account_id != undefined && trim(document.EditView.account_id.value) != "") {
        var surl = "module=" + fldtype + "&action=Popup&html=Popup_picker&form=vtlibPopupView&fieldname=" + fldname + "&frommodule=" + mod + "&forfield=" + fldname + "&srcmodule=" + mod + "&forrecord=" + id + "&accountid=" + document.EditView.account_id.value + "&popup=yes&page_popup=yes";
    } else {
        var surl = "module=" + fldtype + "&action=Popup&html=Popup_picker&form=vtlibPopupView&fieldname=" + fldname + "&frommodule=" + mod + "&srcmodule=" + mod + "&forrecord=" + id + "&popup=yes&page_popup=yes";
    }
    surl += "&popuptype=related_to";
    CrmPopupWindow(mod, surl, fldtype);

}

/*
*新增操作 by andy
*服务单新增服务合同字段，弹出窗
*date:20140227
*/
function SelectServicecontracts(mod) {
    // To support both B2B and B2C model
    var record_id = '';
    var parent_module = '';
    var acc_element = document.EditView.account_id;
    var module = document.EditView.module.value;
    var accountid;
    if (acc_element != null) {
        record_id = acc_element.value;
        parent_module = 'ProjectTask';
    }

    if (record_id != '') {
        window.open("index.php?module=ServiceContracts&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&accountid=" + record_id + "&parent_module=" + parent_module + "&fromModule=1", "test", "width=840,height=602,resizable=1,scrollbars=1");
    } else {
        window.open("index.php?module=ServiceContracts&action=Popup&html=Popup_picker&popuptype=specific&form=EditView", "test", "width=840,height=602,resizable=1,scrollbars=1");
    }

}

/*
*新增操作 by andys
*销售退款单选择退货单，弹出窗
*date:20140120
*/
function selectsalesback(mod) {
    // To support both B2B and B2C model
    var record_id = '';
    var parent_module = '';
    var acc_element = document.EditView.account_id;
    var cnt_element = document.EditView.contact_id;
    var module = document.EditView.module.value;
    var accountid;
    if (acc_element != null) {
        record_id = acc_element.value;
        parent_module = 'Accounts';
    } else if (cnt_element != null) {
        record_id = cnt_element.value;
        parent_module = 'Contacts';
    }
    window.open("index.php?module=SalesBack&action=Popup&html=Popup_picker&popuptype=specific&form=EditView", "test", "width=840,height=602,resizable=1,scrollbars=1");
}

function checkReturn(id, value, url) {
    //	0028721: 合同订单-查看明细界面-关联创建-办理退货问题
    var popupobj = CrmPopup.getPopupObj('last');
    ldAjaxHtmlNoProgress('index.php','module=SalesBack&action=SalesBackAjax&file=SalesBackOperation&ajaxmode=check&salesorder_id=' + id,function(ajaxhtml){
        var result = ajaxhtml.split('###SUCCESS###');
        var var_result = result[1];

        if (var_result == 'allow') {
            //window.location.href=url;
            //window.open(url);
            //alert(url);
            //ls 20220927 Xuqiu1000213 服务回访单、销售退货单、采购退货单、销售退款单、采购退款单增加“新建”功能(目前合同订单相关创建销售退货单checkReturn只针对源单为合同订单时)
            related_add_url(url, 'SalesOrder', 'SalesBack', id);
        } else if (var_result == 'no_outboundorder') {
            //该{$SalesOrder.SalesOrder}还未出库，不允许办理退货！
            var confirm_str = arrJsPopLabel['ORDEROUTNOALLOWRETURN'];
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
            return;
        } else if (var_result == 'nocheck_outboundorder') {
            //该合同订单还未出库，不允许办理退货！
            var confirm_str = arrJsPopLabel['OUTBOUNDCOUNTEQUALZERO'];
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
            return;
        } else {
            //该合同订单已全部退货，不允许办理退货。
            var confirm_str = arrJsPopLabel['ORDERFULLYOUTNOALLOWRETURN'];
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
            return;
        }
    });


}

function checknum(id, url) {
    new Ajax.Request(
        'index.php',
        {
            queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: 'module=SalesBack&action=SalesBackOperation&ajaxmode=cashbackcheck&salesback_id=' + id,
            onComplete: function (response) {
                var result = response.responseText.split('###SUCCESS###');
                var var_result = result[1];
                if (var_result != 1) {
                    window.open(url);
                } else {
                    //该退货单已全部退款，不允许办理退款。
                    var confirm_str = arrJsPopLabel['SINGLEFULLREFUNDNOTALLOWERREFUNDS'];
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                    return;
                }
            }
        }
    );

}


/*
*edit:diony
*date:20140702
*reason:采购订单选择办理退货，弹出窗
*/
function checkPurchaseReturn(id, value, url) {
    if (value == 33) {
        //该采购订单还未入库，不允许办理退货
        var confirm_str = arrJsPopLabel['PURCHASEORDEROUTNOALLOWRETURN'];
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
        return;
    } else {
        new Ajax.Request(
            'index.php',
            {
                queue: {position: 'end', scope: 'command'},
                method: 'post',
                postBody: 'module=PurchaseBack&file=PurchaseBackOperation&action=PurchaseBackAjax&ajaxmode=check&purchaseorder_id=' + id,
                onComplete: function (response) {
                    //var result=response.responseText.split('###SUCCESS###');
                    if (response.responseText.indexOf('###SUCCESS###') > -1) {
                        //ls 20220927 Xuqiu1000213 服务回访单、销售退货单、采购退货单、销售退款单、采购退款单增加“新建”功能（采购退货单源单为采购订单时保留原有逻辑不变）
                        // var tmpurl = '&purchaseorder_id='+id+'&frommodule=PurchaseOrder&fromid='+id+'&relatedcreate=yes';
                        var tmpurl = '&frommodule=PurchaseOrder&fromid=' + id + '&relatedcreate=yes';
                        var objparams = new CreatePagePopup.params();
                        objparams.params['refreshpage'] = 'no';
                        objparams.params['relatedcreate'] = 'yes';
                        CreatePagePopup.showpage('PurchaseBack', tmpurl, objparams);

                    } else {
                        if (response.responseText.indexOf('no_stock') > -1) {
                            var confirm_str = arrJsPopLabel['PURCHASEORDEROUTNOALLOWRETURN'];
                            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                        } else if (response.responseText.indexOf('nocheck_stock') > -1) {
                            var confirm_str = arrJsPopLabel['THISDOCUMENTHASBEENSHIPPEDTOZERO'];
                            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                        } else {
                            //èˉ￥é??è′-è?￠????·2?…¨é?¨é€€è′§???????…?è????????é€€è′§?€?
                            var confirm_str = arrJsPopLabel['PURCHASEORDERFULLYOUTNOALLOWRETURN'];
                            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                        }
                        return;
                    }
                }
            }
        );

        return false;
    }
}

/*
*edit:diony
*date:20140715
*reason:采购退货单选择办理退货，弹出窗
*/
function checkPurchaseCashReturn(id, url) {
    new Ajax.Request(
        'index.php',
        {
            queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: 'module=PurchaseBack&action=PurchaseBackOperation&ajaxmode=cashbackcheck&purchaseback_id=' + id,
            onComplete: function (response) {
                if (response.responseText.indexOf('###SUCCESS###') > -1) {
                    window.open(url, "test", "width=840,height=602,resizable=1,scrollbars=1");
                } else {
                    //该退货单已全部退款，不允许办理退款。
                    var confirm_str = arrJsPopLabel['SINGLEFULLREFUNDNOTALLOWERREFUNDS'];
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                    return;
                }
            }
        }
    );
}

/*
*edit:xiaoshun
*date:20160505
*reason:客户服务单、项目任务唯一创建回访单
*/
function checkCreatedServiceReturn(id, url, fmodule) {
    new Ajax.Request(
        'index.php',
        {
            queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: 'module=ServiceReturn&action=ServiceReturnOperation&ajaxmode=check&record=' + id + '&fmodule=' + fmodule,
            onComplete: function (response) {
                if (response.responseText.indexOf('###EXIST###') > -1) {
                    var confirm_str = arrJsPopLabel['HAVECREATEDSERVICERETURN'];
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                    return;
                } else {
                    if (fmodule == 'HelpDesk') {
                        window.open('index.php?module=ServiceReturn&action=EditView&return_module=ServiceReturn&return_action=DetailView&parent_id=' + id + '&parent_module=HelpDesk&EditView=yes' + url);
                        return;
                    }
                    if (fmodule == 'ProjectTask') {
                        window.open('index.php?module=ServiceReturn&action=EditView&return_module=ServiceReturn&return_action=DetailView&parent_id=' + id + '&parent_module=ProjectTask&EditView=yes' + url);
                        return;
                    }

                }
            }
        }
    );
}

/******************************************
 * DetailView RelatedList                 *
 * 详细信息页面，相关信息左右结构js事件   *
 * Add:Tujt Date:20140331                 *
 ******************************************/
var relajax = '';
var isbalance = 1;//相关信息是否处于加载中
function show_rel_list(a, b, c, d) {
    show_rel_lists(a, b, c, d);
}

function show_workreport(a, b, c, d) {
    show_workreports(a, b, c, d);
}

function setRelListWorkReportAjax(a, b) {
    setRelListWorkReportAjaxs(a, b);
}

function setRelListAjax(a, b, c) {
    setRelListAjaxs(a, b, c)
}

function SetRelatedlist(a, b, c, d) {
    SetRelatedlists(a, b, c, d);
}

function QuickSetaction(a, b, c, d) {
    QuickSetactions(a, b, c, d);
}

/**
 * 显示模块详细信息界面，同时隐藏相关信息界面
 * @author Tujt 20140331

 function show_detail(){
    CrmPopup.delPopupobjByType('relatedpagelist');
	document.getElementById('DetailContent').style.display = '';
	document.getElementById('RelatedContent').style.display = 'none';

    ld("#detailrelatedinfo_ul").find("li").each(function(){
        ld(this).find("a").removeClass("On");
    })
    ld("#detailrelatedinfo_ul").find("li:first").find("a").addClass("On");
} */
/**
 * 显示已经加载过的相关信息界面，隐藏模块详细信息界面
 * @param
 * @returns
 * @author Tujt 2014-04-04
 */
function show_related() {
    if (document.getElementById('RelatedContent').style.display == 'none') {
        var currobj = document.getElementById('currrelid');
        if (currobj.value > 0) {
            document.getElementById('DetailContent').style.display = 'none';
            document.getElementById('RelatedContent').style.display = '';
            return;
        }
    }
}

/**
 * 相关信息，排序事件
 * @param orderby ajax 提交条件
 * @returns 调用初始化相关信息方法 setRelListAjax
 * @author Tujt 20140331
 *///20210910添加相关信息点击事件至DetailViewTab.js
/*function related_left_block(orderby,relatedid){
	setRelListAjax(orderby,relatedid);
}*/
/**
 * 相关信息，切换试图事件
 * @param relatedid 相关信息ID
 * @param viewid 视图ID
 * @returns 调用setRelListAjax
 * @author Tujt 20140331
 */
function showRelatedCustomView(relatedid, viewid) {
    if (document.DetailView) {
        var header = document.DetailView.module.value;
        var record = document.DetailView.record.value;
    } else if (document.EditView) {
        var header = document.EditView.module.value;
        var record = document.EditView.record.value;
    } else {
        return;
    }
    var urldata = "&header=" + header + "&record=" + record + "&viewid=" + viewid;
    urldata += "&relatedid=" + relatedid + "&currpage=1&related_left_type=1";
    urldata += '&switchview=' + viewid;
    setRelListAjax(urldata, relatedid);
}

/**
 * 刷新
 * @param relatedid 相关信息ID
 * @returns 调用setRelListAjax
 * @author Tujt 20140331
 */
function resetRelated(relatedid) {
    return false;
    if (document.DetailView) {
        var header = document.DetailView.module.value;
        var record = document.DetailView.record.value;
    } else if (document.EditView) {
        var header = document.EditView.module.value;
        var record = document.EditView.record.value;
    } else {
        return;
    }
    var pagenum = 1;
    if (document.form.pagenum != undefined) {//获取当前分页页数
        pagenum = document.form.pagenum.value;
    }
    var urldata = "&header=" + header + "&record=" + record;
    urldata += "&relatedid=" + relatedid + "&start=" + pagenum + "&related_left_type=1";

    setRelListAjax(urldata, relatedid, header);
    //刷新相关信息条目数
    set_rel_count(record);
    set_rel_createbtn(record);
}

/**
 * 分页事件
 * @param
 * @returns
 * @author Tujt 20140401
 */
function related_left_load(urldata, tpl, mod) {
    setRelListAjax(urldata, tpl);
}

/**
 * @edit:chj
 * @date:2014-
 * @reason:显示服务单信息
 * @description:
 */
function showServiceContractsDetail(recordid, module, popupobj) {

    //var popupobj=CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    ldAjaxHtmlNoProgress('index.php?','module=' + module + '&action=' + module + 'Ajax&file=ShowServiceContractsDetail&accountid=' + recordid,function (ajaxhtml) {
        if (ajaxhtml != '') {
            var results = trim(ajaxhtml).split('###SUCCESS###');
            if (results[1] != 1) {

                //$("showServiceContactsInfo").innerHTML = results[1];
                //$("showServiceContactsInfo").style.display="block";
                ld("#" + popupobj.divid + " [name=HelpDeskHistorytr]").css("display", "");
                ld("#" + popupobj.divid + " [name=HelpDeskHistory]").parent().css("display", "");
                ld("#" + popupobj.divid + " [name=showServiceContactsInfo]").css("display", "");	//parent().parent().   加了之后，客户和客户服务单明细不显示服务信息了
                CrmPopup.findHtmlobj(divid, 'showServiceContactsInfo').html(results[1]);
                tooltip(ld("#" + popupobj.divid).find('.tip-items-list'), {transition: true, time: 200});

            }
        }
    });
}

/**
 * @edit:chj
 * @date:2014-9-19
 * @reason:客户服务单、项目任务 获取客户和联系人相关字段信息 ,新增联系记录单据andy
 * @description:
 */
function getAccountsContactsInfo(accountid, contactid, module, popupobj) {
//	if(document.EditView != undefined)
//		var frommodule = document.EditView.module.value;
//	else if(document.DetailView != undefined)
//		var frommodule = document.DetailView.module.value;
//	else
//		var frommodule = module;
    var frommodule = popupobj.module;
    if (popupobj.type == DetailViewPage.type) {
        var mode = 'DetailView';
    } else {
        var mode = 'EditView';
    }

    //alert('module=Users&action=UsersAjax&file=getAccountsContactsInfo&mode='+mode+'&accountid='+accountid+'&contactid='+contactid+'&frommodule='+frommodule);
    new Ajax.Request(
        'index.php',
        {
            queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: 'module=Users&action=UsersAjax&file=getAccountsContactsInfo&mode=' + mode + '&accountid=' + accountid + '&contactid=' + contactid + '&frommodule=' + frommodule,
            onComplete: function (response) {
                if (response.responseText != '') {
                    var results = trim(response.responseText).split('###SUCCESS###');
                    if (response.responseText.indexOf("###ERROR###") > -1) {
                    } else {
                        if (results[1] != '') {
                            //$("showAccountsContactsInfo").innerHTML = results[1];
                            //$("showAccountsContactsInfo").style.display="block";
                            //	$("showAccountsContactsInfoTr").style.display="";
                            ld("#" + popupobj.divid + " [name=showAccountsContactsInfo]").html(results[1]);
                            ld("#" + popupobj.divid + " [name=showAccountsContactsInfo]").css("display", "block");
                            ld("#" + popupobj.divid + " [name=showAccountsContactsInfoTr]").css("display", "block");
                            IsFrameElement();
                            /**
                             * 销售机会中，关联的客户联系人字段中有name值，会把销售机会模块的name值冲掉
                             * @reason 0012340 新建销售机会备注字段的内容不显示
                             * @author Tujt 2014-11-10
                             */
                            var inputs = ld("#" + popupobj.divid + " [name=showAccountsContactsInfo]").get(0).getElementsByTagName('input');
                            var inputlen = inputs.length;
                            for (var i = 0; i < inputlen; i++) {
                                inputs[i].name = 'AccountsContacts_' + inputs[i].name;
                            }
                            var inputs = ld("#" + popupobj.divid + " [name=showAccountsContactsInfo]").get(0).getElementsByTagName('textarea');
                            var inputlen = inputs.length;
                            for (var i = 0; i < inputlen; i++) {
                                inputs[i].name = 'AccountsContacts_' + inputs[i].name;
                            }
                        }
                    }

                }
            }
        }
    );
}

/**
 *@edit: andy
 *@date: 2014122
 *@reason:收款单增加源单信息区块,二次选择源单，更新源单信息区块
 *@version: v5.9
 */
//editor:gyq_161 reason:收款单增加源单信息区块,二次选择源单，更新源单信息区块   2019/11/25 14:45
function getRelatedOrderInformations(frommodule, sourcemodule) {
    var popupobj = CrmPopup.getlastPopupObjByPageType(CreatePagePopup.pagetype);
    var trobjs = popupobj.getTrObjsByDelType("no");
    var realy_table_data_rows = ld(trobjs).length;
    /* var parentwindow=window;
	if(window.opener!=undefined&&parentwindow.document.getElementById('proTab')==undefined){
		parentwindow=window.opener;
	}
    var rows=parentwindow.document.getElementById('proTab').rows.length;*/

    var idstring = new Array();
    ld.each(trobjs, function () {
        var i = ld(this).attr("rowindex");

        idstring[i] = ld(this).find(" #entitytypeid").val();
    })


    RequestAjax('module=' + module + '&action=' + module + 'Ajax&file=getRelatedOrderInformations&idstring=' + idstring.join(',') + '&sourcemodule=' + sourcemodule,
        function (rest) {
            if (rest.indexOf('###gotpl###') > -1) {
                var strs = rest.split('###gotpl###');
                //editor:gyq_161不确定 reason:带分录模块弹出层   2019/11/25 16:36
                ld('#relatedorder_div').html(strs[1]);
                DelProgressObjs();
                //$("relatedorder_div").innerHTML=;
            }

        });
}

/**
 *@edit:andy
 *@date:
 *@reason:相关信息新增单据弹出层js
 *@version:
 */
function CreateNewBill(obj, Module, relModule, record) {
    // $("status").style.display="inline";
    //alert('module='+relModule+'&action='+relModule+'Ajax&file=EditView&ajax=true')
    new Ajax.Request(
        'index.php',
        {
            queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: 'module=' + relModule + '&action=' + relModule + 'Ajax&file=CreateNewBill&ajax=true',
            onComplete: function (response) {
                if (response.responseText.indexOf('SUCCESS') > -1) {
                    var results = response.responseText.split('###SUCCESS###');
                    // $("status").style.display="none";
                    $('CreateNewBill_form_div').innerHTML = results[1];
                    fnvshobj(obj, 'CreateNewBill');
                }
            }
        }
    );

}

function SelectSource(module, obj, list) {
    SelectSources(module, obj, list);
}

//function setBalanceOfAccount(a,b,c,d,e,f){setBalanceOfAccounts(a,b,c,d,e,f);}
function rel_balance_list(a, b, c, d) {
    rel_balance_lists(a, b, c, d);
}

function set_rel_count(record) {
    return false;
    /*if(document.DetailView){
		var header = document.DetailView.module.value;
		var record = document.DetailView.record.value;

         if(document.DetailView.module.length!=undefined&&document.DetailView.module.length>0)
        {
            //常见问题
            	var header = document.DetailView.module[0].value;

		      //var record = document.DetailView.record[0].value;

        }
	}else if(document.EditView){
		var header = document.EditView.module.value;
		var record = document.EditView.record.value;
	}else{
		return;
	}


	if(header != '' && record > 0){
		var urldata = 'module=Users&action=UsersAjax&file=setRelatedModList';
		urldata += '&header='+header+'&record='+record+'&related_left_type=3';
		urldata += '&SearchScope=SmOwner_Search_All';
		RequestAjax(urldata,function(rest){
			if(rest != ''){
				var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
				for(relid in restobj){
                    //editor:gyq_20181116 0035454: （http://111.30.26.19:8020/crm [^]）客户模块>单据明细界面>点击签到：签到中是有签到数据的，但是没有在左边签到哪里显示出一共有多少条签到的提醒。（公司账套没有问题）
                    if(document.getElementById('rel-coount-'+relid)) {//js判断元素是否存在
                        if (document.getElementById('rel-coount-' + relid) && restobj[relid] > 0) {
                            document.getElementById('rel-coount-' + relid).innerHTML = '<span class="Num category_count">[' + restobj[relid] + ']</span>';
                        } else {
                            if (document.getElementById('rel-coount-' + relid).innerHTML != '') {
                                document.getElementById('rel-coount-' + relid).innerHTML = '';
                            }
                        }
                    }
				}
			}
		});
	}*/
}

function set_rel_createbtn(record) {
    /*if(document.DetailView){
		var header = document.DetailView.module.value;
		var record = document.DetailView.record.value;
        if(document.DetailView.module.length!=undefined&&document.DetailView.module.length>0)
        {
            //常见问题
            	var header = document.DetailView.module[0].value;

		     // var record = document.DetailView.record[0].value;

        }

	}else if(document.EditView){
		var header = document.EditView.module.value;
		var record = document.EditView.record.value;
	}else{
		return;
	}


	if(header != '' && record > 0){
		var urldata = 'module=Users&action=UsersAjax&file=setRelatedModList';
		urldata += '&header='+header+'&record='+record+'&related_left_type=4';
		urldata += '&SearchScope=SmOwner_Search_All';
		RequestAjax(urldata,function(rest){
			if(rest != ''){
				var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
				for(relid in restobj){
					if(document.getElementById('rel-createbtn-'+relid) && restobj[relid] != '' && restobj[relid] != null){
						document.getElementById('rel-createbtn-'+relid).innerHTML = restobj[relid];
					}
				}
			}
		});
	}*/
}

/*公告选择用户 by andy*/
function select_recipient() {
    var scopepopupobj;//自定义弹出层页面html，绑定事件
    var popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题
    var useridstr = document.forms['EditView'].recipient.value;
    var module = 'PublicAnnouncement';
    getJsScript('include/js/ScopePopup/ScopePopupObj.js', function () {
        var methodObj = {'popup_check_inactiveuser': 'yes'};
        scopepopupobj = new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = popup_caption_value;//标题title
        getJsScript('include/js/ScopePopup/ScopePopup.js', function () {
            cls_ScopePopup.prop.popup_module = module;//模块
            cls_ScopePopup.prop.popup_value = useridstr;
            cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=&popup_module=' + module + '&popup_inputtype=checkbox&popup_selecttype=user'
            var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
            //重写确认按钮事件
            scopepopupobj.setEventBtnOk = function () {
                ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtnok').unbind('click').on('click', function () {
                    if (empty(cls_ScopePopup.return_obj.return_id)) {
                        RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", arrJsPopLabel['PLEASESELECTLESTONEUSER']);
                        return false;
                    } else {
                        var popupobj=CrmPopup.getPopupObj('lastprev');
                        ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtncancel').click();
                        if (ld("[name='recipient_name']").length > 0) {
                            ld('#'+popupobj.divid+" [name=recipient_name]").html(cls_ScopePopup.return_obj.return_name);
                            ld("[name='recipient']").val(cls_ScopePopup.return_obj.return_id);
                        }
                    }
                });
            }
        });
    });
}

function ChangeBankAccount(cur_id, module) {

    if (cur_id >= 1) {
        new Ajax.Request(
            'index.php',
            {
                queue: {position: 'end', scope: 'command'},
                method: 'post',
                postBody: 'module=Users&action=UsersAjax&file=ChangeRateAmount&ajax=true&return_module=' + module + '&currency_id=' + currency_id + '&ChangeBank=true',
                onComplete: function (response) {
                    if (response.responseText.indexOf('###SUCCESS###') > -1) {
                        //默认币种类型
                        if (document.EditView.currency_id != undefined) {
                            document.EditView.currency_id.value = cur_id;
                            document.getElementById('hidden_currency_id').value = cur_id;
                        }
                        var results = response.responseText.split('###SUCCESS###');
                        //提现单和存现单 有转出和转入2个账户  select命名不一致
                        if (document.EditView.bankaccountsetid != undefined) {
                            var selectValue = document.EditView.bankaccountsetid;	//银行账户

                            UpdateBankAccount(selectValue, results[1]);
                            var cls_resetComboxHtmlobj = new cls_resetComboxHtml('bankaccountsetid');

                            cls_resetComboxHtmlobj.setComboxObjHtml();

                        }
                    }
                }
            }
        );
    }
}

function getCurrencyRateAmount(obj, module, cur_id, formname) {

    getCurrencyRateAmounts(obj, module, cur_id, formname);
}

/*提醒选择接收人 by andy*/
function select_reciever(obj) {
    var scopepopupobj;//自定义弹出层页面html，绑定事件
    var popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题

    //wyt 221110 XUQIU1000658 主题：关联选择单据（单选）字段弹出层中增加【快速创建】操作按钮(快速创建提醒未精确的找到对应表单)
    var prevpopobj = CrmPopup.getPopupObj('last');
    var from = ld('#' + prevpopobj.divid + ' form[name=EditView]');
    var useridstr = from.find('[name=recieverid]').val();
    var module = 'Reminds';
    getJsScript('include/js/ScopePopup/ScopePopupObj.js', function () {
        var methodObj = {'popup_check_inactiveuser': 'yes'};
        scopepopupobj = new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = popup_caption_value;//标题title
        getJsScript('include/js/ScopePopup/ScopePopup.js', function () {
            cls_ScopePopup.prop.popup_module = module;//模块
            cls_ScopePopup.prop.popup_value = useridstr;
            //ls 20221123 BUG0059072 消息提醒： 新建消息提醒 选择提醒人时 部门经理权限设置好了 但是看不到部门下其他成员只能看到自己的，管理员账号是正常的
            cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=&popup_module=' + module + '&popup_inputtype=checkbox&popup_selecttype=user&checkprivilege=no'
            var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
            //重写确认按钮事件
            scopepopupobj.setEventBtnOk = function () {
                ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtnok').unbind('click').on('click', function () {
                    if (empty(cls_ScopePopup.return_obj.return_id)) {
                        RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", arrJsPopLabel['PLEASESELECTLESTONEUSER']);
                        return false;
                    } else {
                        ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtncancel').click();
                        if (ld("[name='txt_select_user']").length > 0) {
                            ld("[name='txt_select_user']").val(cls_ScopePopup.return_obj.return_name);
                            ld("[name='recieverid']").val(cls_ScopePopup.return_obj.return_id);
                        }
                    }
                });
            }
        });
    });
}

function UpdateBankAccount(selectValue, bankaccountinfo) {
    //删除下拉框原先所有值
    selectValue.length = 0;
    //添加币种对应的银行账户
    var banklen = bankaccountinfo.split('#,#');

    if (banklen.length >= 1 && bankaccountinfo != "") {
        for (var i = 0; i < banklen.length; i++) {
            var bankinfo = banklen[i].split('&');
            var option = new Option(bankinfo[1], bankinfo[0]);
            selectValue.options.add(option);
        }
    } else {
        var option = new Option('', '');
        selectValue.options.add(option);
    }

}

function productsDetailsChecks(obj) {
    if (obj.checked == true) {
        obj.value = 1;
    } else {
        obj.value = 0;
    }
}

//editor:gyq_161 reason:重新格式化源单分录的列头   2019/11/26 17:04
function changeProtabHeader(module, sourcemodule) {

    if (module == 'CashBill' || module == "SendCashBill") {
        var popupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
        var type = 'edit';
        if(popupobj.createdtype == 'create' || popupobj.createdtype == 'quickcreate'){
            type = 'create';
        }
        //zkt 20231213 BUG0077029kfbcrm-收款单（开启分录冻结列）-新建-选择源单-分录字段错位，实际收款金额显示“NaN”
        ld('#rptContentLoading').show();
        var urlstring = "index.php?module=" + module + "&action=" + module + "Ajax" + "&file=EditView" + "&sourcemodule_changetype=" + sourcemodule + "&changeheader=true"+'&frompagetype='+type;
        ldAjaxNoProgress(urlstring,'',function (data) {
            ld('#rptContentLoading').hide();
            if (data.code == 1) {
                var popupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);

                if (module == 'CashBill') {
                    ld("#" + popupobj.divid + " [name=cashbillsource]").html(data.result.detailtablehtml);
                } else if (module == 'SendCashBill') {
                    ld("#" + popupobj.divid + " [name=sendcashbillsource]").html(data.result.detailtablehtml);
                }
                popupobj.ResetgetDetailTableObj();
                //zkt 20220919 BUG0056687如下截图日收款统计表模块（原收款单模块），保存后，很多字段信息值为空，可在系统随意测试。
                //布局规则重设的fields信息会被editview清空
                data.result.fields = popupobj.fields;
                popupobj.beforeshowInitValue(data);

                if (popupobj.hasOwnProperty('detailfieldmodule') && popupobj.detailfieldmodule !== undefined && popupobj.detailfieldmodule.indexOf('detailhtml') > -1) {
                    popupobj.detailpicklist = [];
                    popupobj.detailpicklistColors = [];
                }
                if (popupobj.detailfields != undefined && popupobj.detailfields.length > 0) {

                    popupobj.SortDetailTableRow();//拖动行

                    var trobjs = popupobj.getTrObjsByDelType("no");
                    var rowcnt = ld(trobjs).length;
                    for (var tmpi = 1; tmpi <= rowcnt; tmpi++) {
                        popupobj.SetDetailFieldControl(tmpi);
                    }

                    popupobj.detailfieldcolumninfo = [];
                    ld.each(popupobj.detailfields, function (tmpindex, tmpfieldinfo) {
                        popupobj.detailfieldcolumninfo[tmpfieldinfo.columnname] = tmpfieldinfo;
                    })
                }
                popupobj.setDetailAttachmentEvent();
                popupobj.aftershowInitValue(data);
                //zkt 20230419 BUG0065051 v8.4.9.7升级前版本v8.4.9.1收款单在创建好保存后，然后打开编辑时选择源单发票填开后产品管理不会带出来，必须点清空或新增一行后再次选择源单才会跳出来，升级后这个问题还是存在（GR935）
                if(popupobj.detailfields != undefined && popupobj.detailfields.length > 0 && popupobj.detailfieldmodule == 'Products'){
                    var rowobjs = popupobj.getTrObjsByDelType('no');
                    ld.each(rowobjs, function () {
                        popupobj.selectproductobj.setDataBind(ld(this))
                    })
                }

                //切换源单，带出客户的预收信息
                if (module == "CashBill") {
                    if (ld("#" + popupobj.divid).find(' [name=account_id]').length > 0) {//选择原单带出客户
                        //预收款信息
                        if (ld("#" + popupobj.divid + " [name=bankaccountsetid]").length > 0)
                            var bankaccountsetid = ld("#" + popupobj.divid + " [name=bankaccountsetid]").val();
                        else
                            var bankaccountsetid = 0;
                        //edit:can 2020-08-31 收款单关联预收单做核销的时，无需控制“银行账户”一致，控制币种一致即可
                        if (ld("#" + popupobj.divid + " [name=currency_id]").length > 0)
                            var currency_id = ld("#" + popupobj.divid + " [name=currency_id]").val();
                        else
                            var currency_id = 0;

                        var accountid = ld("#" + popupobj.divid + " [name=account_id]").val();
                        if (popupobj.cashbilltype != undefined)
                            var cashtype = popupobj.cashbilltype;//收款类型(cashbill:收款单,debuction:预收单)
                        else
                            var cashtype = '';
                        getChooseRelateLists.getInstance(popupobj).setCurrencyId(currency_id);
                        getChooseRelateLists.getInstance(popupobj).getChooseAccountRelateList(bankaccountsetid, accountid, cashtype);

                    }
                }


            }
        });
    }

}

/**
 * @edit:cxl
 * @date:2015-4-20
 * @reason:实现选择源单后面的橡皮擦功能
 * @description:
 *module:当前模块
 */
function clearModuleProduct(obj, module, productfield) {
    var popupobj = CrmPopup.getPopupObj('last');
    //工单管理选择源单时，设置分录对象为产品信息
    if (module == 'WorkSheet') {
        //清空配件信息
        deleteAllPartinfo(obj);
        popupobj.js_detailtablename = 'newproTab';
    }
    var tableobj = popupobj.getDetailTableObj();
    if (ld("#" + popupobj.divid + " [name=relaredordertable]").length > 0)//document.getElementById('relaredordertable') != undefined)//从整个触发事件的网页中获得源单信息的divid并且清除里面的内容
    {
        ld("#" + popupobj.divid + " [name=relaredordertable]").html('');//document.getElementById('relaredordertable').innerHTML='';
    }
    var selectlistvalid = ld("#" + popupobj.divid + " [name=relaredordertable]").val();//document.getElementById('selectlistval').value ;

    if (ld("#" + popupobj.divid + " [name=proTab]").length > 0) {//document.getElementById('proTab') != undefined){
        var tableName = ld("#" + popupobj.divid + " [name=proTab]").get(0);// document.getElementById('proTab');
        var prev = tableName.rows.length;//获取table行数

        if (prev >= 3)//任意一个table为空时至少有三行；||(module=='CashBill'||module=='SendCashBill')收付款单预收，无源单时只有2行
        {
            if (module == 'CashBill' || module == 'SendCashBill') {
                //changeProtabHeader(module,ld('#selectsource').val());//当选择原单改变时，重新选择猎头
                changeProtabHeader(module, ld("#" + popupobj.divid + " [name=selectsource]").first().val());//当选择原单改变时，重新选择猎头
            }
            if ((module == 'CashBill') || (module == 'Commission') || (module == 'Expense'))//这些元素对应的tableid是SendPaymentList
            {
                var tableobj = popupobj.getDetailTableObj();//ld("#"+popupobj.divid+" [name="+popupobj.js_detailtablename+"]");
                if (module == 'Commission' && account_version == 'langjie') {
                    ld.each(ld(tableobj).find("tr[detaildeleted=no]"), function () {
                        var tmprowindex = ld(this).attr('rowindex');
                        deleteRow(tmprowindex);
                    })
                } else {
                    for (var i = 1; i <= prev - 4; i++)//删除table的行
                    {


                        deleteRowPayment(i);

                    }
                    caltotal();
                }
                //
            } else if (module == 'SendCashBill')//删除table的行
            {
                for (var i = 1; i <= prev - 4; i++) {
                    deleteRowSendPayment(i);

                }
                calSendTotal();

                //setProductDivWidth(popupobj) ;
            } else  // 这些元素对应的tableid是proTab：Stock，OutboundOrder,PurchaseOrder，PurchaseInvoice，ServiceContracts,Invoice
            {
                //清空源单的ID值
                var selectlistval = '';
                if (ld("#" + popupobj.divid + " [name=selectlistval]").length > 0) {//document.getElementById('selectlistval') != undefined){
                    //	document.getElementById('selectlistval').value = '';
                    ld("#" + popupobj.divid + " [name=selectlistval]").val('');
                }
                var trlength = popupobj.getTrObjsByDelType('no').length;
                //zkt XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据 --- 分录变化时数据操作 -分录删除前
                Detaildatachange_byrowindexoperation(popupobj,'before','deleteall');
                for (var i = 1; i <= trlength; i++) {
                    ld(tableobj).find("[rowindex=" + i + "]").remove();
                }
              
                 popupobj.detaildatavalue_arr=[];
                 //popupobj.detaildatavalue_arr.push(popupobj.selectproductobj.getDetailDataValues());
                //edit:can 2020-10-22 42917: （https://61mis.com/kfbtest [^]）单据新建界面，选择源单单据后，切换源单类型点击【确定】，没有清空关联源单的分录明细信息（出库单模块测试）
                fun_selectproduct.clear_opertion = 'yes';
                fun_selectproduct.addproductrow();
                popupobj.fieldformulaobj.CountsubTotal();
              
                var parentwindow = window;
                setModuleEntityName();
                popupobj.selectproductobj.AfterchooseSourceHide();////选择源单后隐藏按钮（严格控制选择源单）
                //parentwindow.fieldformulaobj.CountFormulaColumn();//小计（包括计算合计,整单折扣)
                if (popupobj.module == 'TimeSheet') {
                    setTimeSheet();
                }
                ShowSequence(popupobj);
                Detaildatachange_byrowindexoperation(popupobj,'after','deleteall');
            }
        }
        if (ld("#" + popupobj.divid + " [name=selectlistval_label]").val() != undefined) {
            ld("#" + popupobj.divid + " [name=selectlistval_label]").val("");
            ld("#"+popupobj.divid+" [name=selectsourcename]").val(ld(obj).val());
        }
        if (module == 'SalesOrder') {
            ld("#" + popupobj.divid + " [name=quote_id]").val("");
        } else if (module == 'ServiceContracts') {
            ld("#" + popupobj.divid + " [name=salesorder_id_name]").val('');

            ld("#" + popupobj.divid + " [name=salesorder_id]").val('');


        } else {
            //BUG0078425 name也要一起清除掉
            ld("#" + popupobj.divid + " [name=salesorder_id_name]").val("");
            ld("#" + popupobj.divid + " [name=salesorder_id]").val("");
            ld("#" + popupobj.divid + " [name=selectlistval]").val("");
        }

    }
    if (module == 'PaymentPlan') {
        //edit:can 20210205 44622: （本地8.3.7）财务管理-收款计划/付款计划-编辑；编辑收/付款计划单机，清除选择源单时，点击没有任何反应
        ld("#" + popupobj.divid + ' [name=salesorder_id]').val('');
        ld("#" + popupobj.divid + ' [name=entitytypeid]').val('');
        ld("#" + popupobj.divid + " [name=salesorder_name]").val('');
    } else if (module == 'SendPayment') {
        //edit:can 20210205 44622: （本地8.3.7）财务管理-收款计划/付款计划-编辑；编辑收/付款计划单机，清除选择源单时，点击没有任何反应
        ld("#" + popupobj.divid + ' [name=salesorder_id]').val('');
        ld("#" + popupobj.divid + ' [name=entitytypeid]').val('');
        ld("#" + popupobj.divid + " [name=salesorder_name]").val('');
    }
   
    clearModuleProduct.other_clear();
    if (ld.trim(selectlistvalid) != '') {

        var ids = selectlistvalid.split(",");
        if (ids.length > 0) {
            var record = ids[ids.length - 1];
            //38212: 引用字段（包括：ld_related_field 表中手动添加的），源字段清空时，已用字段也需要清空的需求
            clear_relatedfielddatas(ld("#" + popupobj.divid + " [name=selectsource]").val(), record, "selectlistval", "selectlistval", module, 'popupselectfield');
        }
    }

}

clearModuleProduct.other_clear = function () {

}

/**
 * 共享
 * @author Tujt 2015-06-02
 */
function SetModuleShare(module, record, used_portion, relatedid) {
    getJsScript('include/js/Share.js', function () {
        Share.getInstance().getPopup(module, record)
    });
    /*if(typeof cls_wxGetSessionobj!=undefined&&typeof cls_wxGetSessionobj!="undefined")
    {
        cls_wxGetSessionobj.openEnterpriseChat();
    }*/

}

function showShareUserEdit(jqueryobj) {
    getJsScript('include/js/Share.js', function () {
        Share.getInstance().showEditBtn(jqueryobj);

    });

}

function HideShareUseEdit(jqueryobj) {
    getJsScript('include/js/Share.js', function () {
        Share.getInstance().hideEditBtn(jqueryobj);

    });

}

/**
 * 详情页按钮事件
 * @author Tujt 2015-06-03
 */
function detailbutton_click(obj, module, setype, record) {
    getJsScript('include/js/DetailButtons.js', function () {
        detailbuttons_click(obj, module, setype, record);
    });
}

/**
 * 获取服务单历史记录
 * @author cme 2015-12-09
 */
function getAccountByHelpDeskHistory(account_id, url_string, popupobj) {
    var start;
    if (popupobj == undefined || popupobj == 'undefined') {
        /**
         * @edit:ls
         * @date:2020-7-9
         * @reason:0041915: （https://61mis.com/kfbtest [^]）客户服务单新建/编辑界面，客户服务单历史记录区块，点击“下一页”箭头点不动
         * @description:该页面的传参没有popupobj参数：getAccountByHelpDeskHistory('page','&start=2');，需要判断获取
         */
        var popupobj = CrmPopup.getPopupObj("last");
    }
    if (!empty(popupobj.popupdivid)) {
        popupobj.divid = popupobj.popupdivid;
    }
    var divid = popupobj.divid;
    var parentwindow = window;

    // if(document.opener != undefined){
//        parentwindow = window.opener;
//    }
    if (CrmPopup.isExistsObj(divid, "HelpDeskHistorytr")) {
        //BUG0070970 liushuai 20230811 （http://crm.airmaster.com.cn/crm）8482版本，财务人员无法在“售后立项通知单HelpDesk”内看到历史售后服务记录
        if (account_id == '' || account_id == 0 || typeof account_id == 'undefined') {
            if (parentwindow.document.getElementById('accountid') != undefined) {
                account_id = parentwindow.document.getElementById('accountid').value;
            }else{
                CrmPopup.findHtmlobj(divid, "HelpDeskHistorytr").css("display", "none");
                CrmPopup.findHtmlobj(divid, "HelpDeskHistory").css("display", "none");

                return false;
            }

        } else {
            CrmPopup.findHtmlobj(divid, "HelpDeskHistorytr").css("display", "");
            ld("#" + popupobj.divid + " [name=HelpDeskHistory]").parent().css("display", "");
        }
    }
    if (account_id == 'page') {
        account_id = document.getElementById('accountid').value;
    }
    var urlstring = 'module=HelpDesk&action=HelpDeskAjax&file=AccountHelpDeskLog&acount_id=' + account_id;
    if (url_string != '') {
        urlstring += url_string;
    }
    new Ajax.Request(
        'index.php',
        {
            queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: urlstring,
            onComplete: function (response) {
                var rest = response.responseText;
                if (trim(rest) != '') {
                    CrmPopup.findHtmlobj(divid, "HelpDeskHistory").html(rest);
                    CrmPopup.findHtmlobj(divid, "HelpDeskHistory").css("display", "");
                    ld("#" + popupobj.divid + " [name=showServiceContactsInfo]").parent().parent().css("display", "");
                    tooltip(ld("#" + popupobj.divid).find('.tip-items-list'), {transition: true, time: 200});
                }
            }
        });
}

/**
 * 获取评论列表信息
 * @param String modulename 模块名
 * @returns Integer recordid ID
 * @author Tujt 2014-08-05
 */
function showModCommentsHtml(modulename,recordid,popupobj){
	var urlstring = 'module=Users&action=UsersAjax&file=getDetailBlock&'+
						'modulename='+modulename+'&recordid='+recordid+'';
    if(ld("#commentMode").length>0){
        urlstring += '&commentmode='+ld("#commentMode").data('commentmode');
    }

	if(document.getElementById('modcommentdiv')){
		//getJsScript('modules/ModTracker/ModTrackerCommon.js',function(){
		//	getJsScript('include/js/modules/ModComments/ModCommentsCommon.js',function(){
			//	ModCommentsCommon.modulename = modulename;

        ldAjaxHtml('index.php?',urlstring+'&setype=ModComments',function (rest) {
            if(trim(rest) != ''){
                //document.getElementById('modcommentdiv').innerHTML = rest;
                //duan 20220808 获取原始divid
                if(!empty(popupobj.popupdivid)){
                    popupobj.divid=popupobj.popupdivid;
                }
                ld("#"+popupobj.divid+" #contentwrap_"+recordid).html(rest);

                ld("#"+popupobj.divid+" #contentwrap_"+recordid).find('textarea').not('.proName_note').autosize();
                getJsScript('include/js/modules/ModComments/ModComments.js',function(){
                    if(ld("#"+popupobj.divid+" #commentMode").length>0&&ld("#"+popupobj.divid+" #commentMode").data('commentmode')=='advanced'){
                        CommentWinPopup(popupobj,"ModCommentUsersDiv");
                    }
                    setModcommentEvent();
                })
                //zkt 20230516 XUQIU1001414 单据查看详情界面，若有评论信息时，评论模块应该默认展开（戚涛）
                if(popupobj.modcommentdisplayright == 'yes' &&ld("#"+popupobj.divid+" #contentwrap_"+recordid).children(' :not(#modcomment_nocomment_'+recordid+') ').length>0){
                    if(ld('#'+popupobj.divid+" #modcommentblock_Expanddiv").data('status')!='yes'){
                        ld('#'+popupobj.divid+" #modcommentblock_Expanddiv").click();
                        // if(localStorage.getItem(modulename+'_right_modcommentshow') && localStorage.getItem(modulename+'_right_modcommentshow') != ''){
                        //     localStorage.setItem(modulename+'_right_modcommentshow','yes');
                        // }
                    }
                }
                //ljj 20240401 XUQIU1001924 PC端+移动端：模块单据详情界面：评论内容增加图片、附件 加载图片
                var prevshow_img=ld('#'+popupobj.divid + ' #contentwrap_'+recordid).find('img[name=prevshow_img]');
                ld.each(prevshow_img,function (index,obj) {
                    previewImage(ld(obj).get(0));
                })

                DelProgressObjs();
                if (typeof cls_wxOpenDataobj != undefined && typeof cls_wxOpenDataobj != "undefined") {
                    //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
                }
            } else {
                //没有评论权限
                DelProgressObjs();
            }
        });
    }
    if (1 == popupobj.approvemod) {//审批
        // $('status').style.display = 'block';
        ldAjaxHtmlNoProgress('index.php',urlstring + '&setype=Approvelog',function (ajaxhtml) {
            // $('status').style.display = 'none';
            var rest = ajaxhtml;
            if (trim(rest) != '') {
                //duan 20220808 获取原始divid
                if (!empty(popupobj.popupdivid)) {
                    popupobj.divid = popupobj.popupdivid;
                }
                ld("#" + popupobj.divid + " [name=approveStaus]").html(rest);
                ld("#" + popupobj.divid + " [name=approvelogtr]").css('display', '');
                getJsScript('include/js/modules/Approve/Approve.js', function () {
                });
                if (typeof cls_wxOpenDataobj != undefined && typeof cls_wxOpenDataobj != "undefined") {
                    //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
                }

            }
        });
    }
    /*if('Accounts' == modulename && 0 == accountset){//客户公海操作日志
				});
		//	});
		//});
	}
	if(1 == popupobj.approvemod){//审批
                    if(!empty(popupobj)){
                        var tmpwidth = (ld("#"+popupobj.divid).get(0).clientWidth*0.28)>400?400:ld("#"+popupobj.divid).get(0).clientWidth*0.28;
                        ld("#"+popupobj.divid+" #modcommentdiv").css('width',tmpwidth+'px');
                        ld("#"+popupobj.divid+" #modcommentblock_parenttd").css('width',tmpwidth+'px');
                    }
				});
		//	});
		//});
	}
	if(1 == popupobj.approvemod){//审批
		// $('status').style.display = 'block';
		new Ajax.Request(
			'index.php',
			{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: urlstring+'&setype=Recordsofoperation',
			onComplete: function(response) {
				// $('status').style.display = 'none';
				var rest = response.responseText;
                if(trim(rest) != '')
                {
                    document.getElementById('publicaccountlog').innerHTML = rest;
				    document.getElementById('publicaccountlogtr').style.display = '';
                      if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                        {
                                        //通讯录(pc端企业微信)
                                cls_wxOpenDataobj.bindAllOpenData();
                        }
                }

			}
		});
	}*/
}

/**
 * 发送邮件
 * @author Tujt 2015-06-05
 */
//function detailview_email_contact_show(){
//getJsScript('include/js/Mail.js',function(){
//detailview_email_contact_show();
//});
//}

/**
 * 显示字段日志
 * @author Tujt 2015-06-08
 */
// editor:gyqX160803 Bug:0023859 Exp:显示日志新增参数 module
function showFieldHistory(record, module) {
    getJsScript('include/js/modules/ModTracker/ModTracker.js', function () {
        ModTrackerShowHistory(record, module);
    });
}

/**
 * 显示负责人日志
 * @author andrew 2015-08-31
 */
function showAssignedUserHistory(record, module) {
    getJsScript('include/js/modules/ModTracker/ModTracker.js', function () {
        ModTrackerShowAssignedUserHistory(record, module);
    });
}

function hndMouseOver_show(uitype, fieldLabel) {
    if (document.getElementById('dtlview_' + uitype + '_show') != undefined) {
        document.getElementById('dtlview_' + uitype + '_show').style.display = 'block';
    }
}

function hndMouseOver_showno(uitype, fieldLabel) {
    if (document.getElementById('dtlview_' + uitype + '_show')) {
        document.getElementById('dtlview_' + uitype + '_show').style.display = 'none';
    }
}

/**
 * 快捷链接
 * @author Tujt 2015-06-18
 */
function ActionUserd_click(obj, module, type, record) {
    var tag = ld(obj).attr('tag');
    switch (type) {
        case 'MassSMS'://发短信
            if ('Accounts' == module || 'ServiceCharge' == module) {
                detailview_SMS_account_show('SMS', 'Accounts');
            } else if ('Contacts' == module) {
                detailview_MassSMS_contact_show();
            }
            break;
        case 'Emails'://发邮件
            if ('Accounts' == module || 'ServiceCharge' == module) {
                detailview_email_account_show('Accounts');
            } else if ('Contacts' == module) {
                detailview_email_contact_show()
            } else if ('Vendors' == module) {
                fnvshobj(obj, 'sendmail_cont');
                sendmail('Vendors', record);
            }
            break;
        case 'OutboundOrder'://创建出库单
            if ('SalesOrder' == module) {//合同订单


                checkProductNum('OutboundOrder', record, 2, tag, "&frommodule=SalesOrder");//tag:account_id
            }
            break;
        case 'PaymentPlan'://创建回款计划
            if ('SalesOrder' == module) {//这个有问题啊，以后再来改
                ChangePaymentPlan(obj, record);
            }
            break;
        case 'SalesBack'://销售退货单
            if ('SalesOrder' == module) {
                var tagarr = tag.split('-');
                checkReturn(record, tagarr[0], 'index.php?module=SalesBack&action=EditView&return_action=DetailView&Create=true&convertmode=sotosalesback&salesorder_id=' + record + '&account_id=' + tagarr[1])
            }
            break;
        case 'PurchaseBack'://采购退货单
            if ('PurchaseOrder' == module) {
                var tagarr = tag.split(',');
                checkPurchaseReturn(record, tagarr[0], 'index.php?module=PurchaseBack&action=EditView&return_action=DetailView&Create=true&purchaseorder_id=' + record + '&vendor_id=' + tagarr[1] + "&frommodule=PurchaseOrder");
            }
            break;
        case 'ServiceReturn'://回访单
            checkCreatedServiceReturn(record, tag, module);
            break;
    }
}

/**
 * @author Tujt 2015-06-18
 */
function chosebox_select_btn(module) {
    getJsScript('include/js/ListView.js', function () {
        chosebox_select_btn(module);
    });
}

//function chosebox_select_btn_email(module){
////	getJsScript('include/js/ListView.js',function(){
//		chosebox_select_btn_email(module);
//	//});
//}
function approve_selectuser() {
    getJsScript('include/js/modules/Approve/Approve.js', function () {
        approve_selectuser();
    });
}

function approve_selectgroup() {
    getJsScript('include/js/modules/Approve/Approve.js', function () {
        approve_selectgroup();
    });
}
/**
 *并发步骤选择审批人
 *edit:can 2020-12-08
 */
function concurrentstepapprove_selectuser(rowindex) {
    getJsScript('include/js/modules/Approve/Approve.js', function () {
        concurrentstepapprove_selectuser(rowindex);
    });
}

function concurrentstepapprove_cancel_selectuser(rowindex) {
    /* editor:gyq_14 */

    getJsScript('include/js/modules/Approve/Approve.js', function () {
        concurrentstepapprove_cancel_selectuser(rowindex);
    });


}

/*
*edit: chj
*date: 2020/9/27
*reason: 加签JS
*/

function approve_augmentsinger_selectuser() {
    getJsScript('include/js/modules/Approve/Approve.js', function () {
        approve_augmentsinger_selectuser();
    });
}

//设定产品明细的div宽度
function setProductDivWidth(popupobj) {
    if (popupobj.pagetype == 'detailview_modulepage') {
        getJsScript('include/js/AdvanceStage.js', function () {
            AdvanceStage.reset_pupupobj_divid(popupobj);
        })
    }

    var scrollwidth;
    var divWidth;
    var tableWidth;
    //var popupobj=CrmPopup.getPopupObj('last');
    //var mode=setProductDivWidth.pageMode;

    if (popupobj.pagetype == 'detailview') {
        //	0022103: 销售发票单据查看界面：页面设置中设置模块不显示，明细界面查看时，产品信息栏显示了白色区块

        scrollwidth = parseInt(ld("#" + popupobj.divid).css("width"));


    } else {
        //页面有滚动条 - 215  ,没有滚动条 - 197
        var tmpwidth = parseInt(ld("#" + popupobj.divid).css("width"));
        var maxheight = parseInt(ld("#" + popupobj.divid + "_scroll").css("max-height"));
        var scrollDom=ld("#" + popupobj.divid ).find(" .DivCTable").get(0)
       
        //必须这样，否则小光的电脑有问题
        if (Math.abs(ld("#" + popupobj.divid).get(0).clientWidth - ld("#" + popupobj.divid).get(0).offsetWidth) > 10) {
            scrollwidth = parseInt(tmpwidth - 21);
           
        } else {
            scrollwidth = parseInt(tmpwidth);
            
        }

    }
  
    var BrowserInfo = getBrowserInfo();
    if(scrollDom!=undefined)
     if (scrollDom.clientHeight === scrollDom.scrollHeight) {
          
            //没有滚动条
         
        }
        else{
           //有滚动条
           //获取滚动条的宽度:scrollDom.offsetWidth-scrollDom.clientWidth
        
            scrollwidth -= scrollDom.offsetWidth-scrollDom.clientWidth;
        }
   
     
    var modcommentwidth = 0;

    if (ld("#" + popupobj.divid + " #modcommentblock_icon").length > 0) {
        var modcommenttdexpendobj = ld("#" + popupobj.divid + " #modcommentblock_Expanddiv");
        var icon_status = modcommenttdexpendobj.data('status');
        var modcommenttdobj = Tools.getParentobjByChild(ld("#" + popupobj.divid + " #modcommentblock_icon"), 'td');
        if (ld(modcommenttdobj).css('display') != 'none') {
            modcommentwidth = icon_status == 'yes'? 375 : 40 ;
        }
    }
    if (ld('#'+popupobj.divid +' #modcommentblock_paddingtd').length > 0){
        // modcommentwidth += ld('#'+popupobj.divid +' #modcommentblock_paddingtd').width();
    }
    //zkt 宽度计算，做减法
    var edit_leftObj = ld("#" + popupobj.divid + " .edit-left");//wym XUQIU1002285 新增编辑左侧增加定位栏,分录宽度需要调整
    var display_status =edit_leftObj.css('display');
    var new_divWidth = 0;
    if(edit_leftObj.length>0){
        new_divWidth =edit_leftObj.get(0).offsetWidth;
    }
  	// 2023-12-29 diony 新增编辑界面左右间隔80px
    if(popupobj.pagetype==CreatePagePopup.pagetype){
        scrollwidth = scrollwidth-new_divWidth-160;
    }
    else{
        scrollwidth = scrollwidth-new_divWidth;
    }
    //工单重设分录宽度
    if (popupobj.module == 'WorkSheet') {
        divWidth = Math.floor((scrollwidth - modcommentwidth) / 3.78);
        divWidth = divWidth - 5;
        if (ld("#" + popupobj.divid + " [name=productDiv]").length > 0) {
            ld("#" + popupobj.divid + " [name=productDiv]").css('width', divWidth + 'mm');
            var tableobj = ld("#" + popupobj.divid + " [name=proTab]");
            tableobj.attr("tablewidth", ld("#" + popupobj.divid + " [name=table_width]").val());
            if (ld("#" + popupobj.divid + " [name=table_width]").length > 0) {
                tableWidth = ld("#" + popupobj.divid + " [name=table_width]").val();
                if (eval(tableWidth) < eval(divWidth)) {
                    tableobj.get(0).style.width = divWidth + 'mm';
                    tableobj.attr("tablewidth", divWidth);

                }
            }
        }

        if (ld("#" + popupobj.divid + " [name=newproductDiv]").length > 0) {
            ld("#" + popupobj.divid + " [name=newproductDiv]").css('width', divWidth + 'mm');
            var tableobj = ld("#" + popupobj.divid + " [name=newproTab]");
            var tmp_width = tableobj.width();//px
            tableobj.attr("tablewidth", ld("#" + popupobj.divid + " [name=table_width]").val());//冻结列的时候比宽度需要这个值
            tmp_width = Math.floor((tmp_width) / 3.78);//mm px=>mm
            if (tmp_width < divWidth) {//table宽度小于弹窗宽度时,取弹框宽度
                tableobj.get(0).style.width = divWidth + 'mm';
                tableobj.attr("tablewidth", divWidth);
            }
        }
		//工单管理 配件信息冻结列 zxm20231007
        setTimeout(function() {
            getJsScript('include/js/freezeEntriesColumns.js', function () {
                var freezeEntriesColumnsobj1 = new FreezeEntriesColumns(popupobj,'proTab');
                freezeEntriesColumnsobj1.freezeTheadAndBody();

                var freezeEntriesColumnsobj2 = new FreezeEntriesColumns(popupobj,'newproTab');
                freezeEntriesColumnsobj2.freezeTheadAndBody();
            });
        },1000);
        return false;
    }

    var productDivObj = ld("#" + popupobj.divid + " [name=productDiv]");
    var proTabTotalObj = ld("#" + popupobj.divid + " #proTabTotal");
    
   
    if (productDivObj.length > 0) {//首付款单没有
        
 
        divWidth = Math.floor((scrollwidth - modcommentwidth) / 3.78);
        if(divWidth*3.78<(scrollwidth - modcommentwidth) )
                divWidth+=1; 
        divWidth-=5;
        
        productDivObj.css('width',divWidth+'mm');
        //费用报销单,发票信息
        if (ld("#" + popupobj.divid + " #div_pz_block").length > 0) {
            ld('#div_pz_block').css('width', divWidth + 'mm');
        }
        if (proTabTotalObj.length > 0) {
            //proTabTotalObj.get(0).style.width = (scrollwidth - modcommentwidth-18.9) + 'px';//18.9：5*3.78保证width和divwidth一致
            proTabTotalObj.css('width',(scrollwidth - modcommentwidth-5*3.78)+'px');
             ld("#"+popupobj.divid+" .DivCNotice").not(' div[id^=detail_coment_div_]').not("[istag='yes']").css('width',proTabTotalObj.get(0).style.width)//xxy 2023-6-12 BUG0067554 在出库单入库单等几个特殊模块时，标签区域宽度被公用的class重写，但不需要重写，需要排除
        }

        //edit:can 20210203 	（http://39.99.235.13/crm [^] ）（苏州优乐蜂环保科技有限公司）8.3.7版本分录的布局规则不生效了

        //8.3.6版本中：合同管理-处置类合同（由合同订单模块修改），合同类别选择为‘处置类’之后，下方的分录中会出现‘甲付乙单价’等字段（上方的网址是8.3.6版本的登录地址）
        ld("#" + popupobj.divid + " [name=proTab]").attr("tablewidth", ld("#" + popupobj.divid + " [name=table_width]").val());
        if (ld("#" + popupobj.divid + " [name=table_width]").length > 0) {
            tableWidth = ld("#" + popupobj.divid + " [name=table_width]").val();

            if (eval(tableWidth) < eval(divWidth)) {

                ld("#" + popupobj.divid + " [name=proTab]").get(0).style.width = divWidth + 'mm';
                ld("#" + popupobj.divid + " [name=proTab]").attr("tablewidth", divWidth);

            }
        }

        if (popupobj.pagetype != 'detailview_modulepage') {
            var totalheight = ld("#" + popupobj.divid).get(0).clientHeight;//总高度
            var approveheight = 0;
            if (ld('#' + popupobj.divid + ' [name=frmsubmitapprove]').length > 0 && typeof ld('#' + popupobj.divid + ' [name=frmsubmitapprove]').get(0) != 'undefined') {
                approveheight = ld('#' + popupobj.divid + ' [name=frmsubmitapprove]').get(0).clientHeight;//审批表单高度
            }
            var otherheight = 42;//其他高度,分录下面默认存在其他行
            var productDivHeight = totalheight - approveheight - otherheight * 3;
            if (productDivHeight < 300) {
                productDivHeight = 300;//最小高度
            }
            ld("#" + popupobj.divid + " [name=productDiv]").css({'max-height': productDivHeight});
        }
        productDivObj.css('overflow','auto');
    }
    // ld("#div_pagerecord").css("width",divWidth+"mm");;
    //alert(ld("#div_pagerecord").css("width",divWidth+"mm"));
    //XUQIU1000651	zxm 20220909
    // 系统设置->单据分录定制，增加“设置冻结前几列”参数
   
    setTimeout(function() {
        getJsScript('include/js/freezeEntriesColumns.js', function () {
            var freezeEntriesColumnsobj = new FreezeEntriesColumns(popupobj,'proTab');
            freezeEntriesColumnsobj.freezeTheadAndBody();
        });
        // getJsScript('include/js/freezecolumns.js', function () {
        //     freezecolumnsObj.init('proTab');//冻结列类初始化
        //     freezecolumnsObj.freezeThColumn('set-sticky');
        // });
    },1000);

}

setProductDivWidth.pageMode = 'EditView';

//选择适用范围
function showProfileUsers(module, inputid) {
    var scopepopupobj;//自定义弹出层页面html，绑定事件
    var popup_selecttype = 'user';
    var popup_selectvalue = '';//默认选中值
    //再次选择，或者编辑
    if (ld('#selectType') != undefined && ld('#selectType').val() != '') {
        popup_selecttype = ld('#selectType').val();
    }
    if (ld('#selectValue') != undefined) {
        popup_selectvalue = ld('#selectValue').val();
    }
    var popup_user_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module=' + module + '&popup_inputtype=checkbox&popup_selecttype=user';
    var popup_profile_url = 'module=Users&action=UsersAjax&file=viewprofileinfo&popup_scopetype=private&popup_module=' + module + '&popup_inputtype=checkbox&popup_selecttype=profile';
    var popup_searchTextDiv_html = '<div id=\'popup_search_div\' style=\'padding-left:59px;display: block;position: absolute;top: 104px;\'><div class=\'view-search\' ></div></div>';
    getJsScript('include/js/ScopePopup/ScopePopupObj.js', function () {
        scopepopupobj = new ScopePopupObj(module);
        scopepopupobj.popup_caption_value = arrJsPopLabel['APPLICABLESCOPE'];//标题title
        scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认值
        scopepopupobj.popup_searchTextDiv = popup_searchTextDiv_html;
        scopepopupobj.popup_header = '<div class="select-input">' +
            '<input id="selectprofileuser1" type="radio" value="profile" name="selectprofileuser"><label class="padL0" for="selectprofileuser1">按角色设置</label>' +
            '<input id="selectprofileuser2" type="radio" value="user" checked="" name="selectprofileuser"><label class="padL0" for="selectprofileuser2">按用户设置</label>' +
            '<label class="padL0">' + arrJsPopLabel['LBL_SEARCHCHOOSE'] + '</label>' +
            '<input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\'' + arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'] + '\'>' +
            '<input type="checkbox" id=\'viewuser_nogroupuser\'>' +
            '<label id="viewuser_nogroupuser_span" for=\'viewuser_nogroupuser\>' + arrJsPopLabel['SHOWNOGROUPUSER'] + '</label></div>';
        getJsScript('include/js/ScopePopup/ScopePopup.js', function () {
            cls_ScopePopup.prop.popup_module = module;//模块
            cls_ScopePopup.prop.popup_value = popup_selectvalue;
            if (popup_selecttype == 'user') {
                cls_ScopePopup.prop.popup_url = popup_user_url;
            } else {
                cls_ScopePopup.prop.popup_url = popup_profile_url;
            }

            cls_ScopePopup.popup_more_selecttype = popup_selecttype;
            var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
            scopepopupobj.setEventLoad = function () {
                ld('input[name="selectprofileuser"]').unbind('click').on('click', function () {
                    if (ld(' input[name="selectprofileuser"]:checked ').val() == 'user') {
                        scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认值
                        ld('#popup_locationdiv').val(arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER']);
                        cls_ScopePopups.viewTree(popup_user_url);
                        popup_selecttype = 'user';
                    } else {
                        scopepopupobj.popup_searchvalue = arrJsPopLabel['pleaseenterprofile'];//查询框默认值
                        ld('#popup_locationdiv').val(arrJsPopLabel['pleaseenterprofile']);
                        cls_ScopePopups.viewTree(popup_profile_url);
                        popup_selecttype = 'profile';
                    }
                });
                showProfileUsers.setRadioBind(popup_selecttype);
            }
            //0026474: 快速创建-费率设定：适用范围字段后点击【+】，弹出层显示出错（参考截图）
            document.getElementById(cls_ScopePopup.popup_divid).style.zIndex = "10300";
            //重写确认按钮事件
            scopepopupobj.setEventBtnOk = function () {
                ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtnok').unbind('click').on('click', function () {
                    //没有选择任何用户，则给出提示
                    if (empty(cls_ScopePopup.return_obj.return_id)) {
                        if (popup_selecttype == 'user') {
                            var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                        } else {
                            var confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
                        }
                        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                    } else {
                        ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtncancel').click();
                        var selected_groupid = cls_ScopePopup.return_obj.return_id;//选中的部门id
                        var selected_groupname = cls_ScopePopup.return_obj.return_name;//选中的部门名称
                        var selected_type = cls_ScopePopup.return_obj.return_type;

                        if (ld('#' + inputid) != undefined) {
                            ld('#' + inputid).val(selected_groupname);
                        }
                        if (ld('#selectType') != undefined) {
                            ld('#selectType').val(selected_type);
                        }
                        if (ld('#selectValue') != undefined) {
                            ld('#selectValue').val(selected_groupid);
                        }
                    }
                    return false;
                });
            }
        });
    });
}

showProfileUsers.setRadioBind = function (popup_selecttype) {
    if (popup_selecttype == 'user') {
        ld('input[name="selectprofileuser"]').eq(1).attr("checked", "checked");
        ld('#selectUserCheck').css('display', 'block');
        ld('#viewuser_nogroupuser').show();
        ld('#viewuser_nogroupuser_span').show();
    } else {
        ld('input[name="selectprofileuser"]').eq(0).attr("checked", "checked");
        ld('#selectUserCheck').css('display', 'none');
        ld('#viewuser_nogroupuser').hide();
        ld('#viewuser_nogroupuser_span').hide();
    }
}

/* editor:gyq_13 reason:批量创建日程 date:2016.6.23*/
function createTemplateCalendars(orignhref) {
    getJsScript('include/js/modules/Calendar/TemplateCalendar/TemplateCalendar.js', function () {

        TemplateCalendar.getInstance().createCalendars(orignhref)
    });
}

//客户-》知识管理相关信息需要用到
function DownLoadDocumentss(fileid,record = 0) {
    //edit: xll 2024/07/31 BUG20240719-61 先下载，后发送ajax，否则无法处理请求
    window.location = 'index.php?module=uploads&action=downloadfile&return_module=Documents&fileid=' + fileid + '&entityid=' + fileid;

    if(record === 0)
        record = fileid;
    dldCntIncrease(record);

    // 刷新列表界面以更新下载次数
    var popupobj = CrmPopup.getPopupObj('last');
    var tmpobj = new AfterUpdatePrevPopupObjContent(popupobj.module, '', [record]);
    tmpobj.eachrefreshlistbyModules([popupobj.module]);
}

//附件设置：设置、查看允许上传的文件样式
//wyt 220706_XUQIU1000243_附件字段设置允许上传的文件格式新增模块控制
function setAttachFileType(stype, module_name) {
    var url = 'index.php?module=Users&action=UsersAjax&file=getAttachmentFileType&stype=' + stype + '&module_name=' + module_name;
    ldAjaxHtml(url,'',function (rest) {
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var submitlog = '<div id="attach_file_type_divcontent" class="pop_remind_content">';
        if (stype == 'set') {
            var popupobj = CrmPopup.load(restobj.title,'','','LdPopWidth600px',module_name,'',arrJsPopLabel['SAVE'],'',arrJsPopLabel['CANCEL']);
            submitlog += '<div class="ld-pop-container">';
            submitlog += '<textarea id="filetype_content" placeholder="'+arrJsPopLabel['PLEASEFILLFORMAT']+'" class="ld-textarea-inner" style="height:100px;">' + restobj.content + '</textarea>';//批量提交失败日志
        } else {
            var popupobj = CrmPopup.load(restobj.title,'','','LdPopWidth600px',module_name,'',arrJsPopLabel['LBL_CLOSE'],'','');
            submitlog += '<div class="ld-pop-container" style="word-break: break-all;word-wrap: break-word;line-height: 20px;">';
            submitlog += '<span>' + restobj.content + '</span>';//批量提交失败日志
        }
        submitlog += '</div></div>';
        popupobj.show(submitlog);
        DelProgressObjs();

        if (stype == 'set') {	//设置
            ld('#'+popupobj.divid+'_btnok').unbind('click').bind('click', function () {
                var filetype_content =  ld('#'+popupobj.divid+' #filetype_content').val();
                if (empty(filetype_content)) {
                    popupobj.CancelEvent();
                    var confirm_str = arrJsPopLabel['fileformat'] + arrJsPopLabel['CANOTEMPTY'] + '！';
                    MessagePopup.TipOne_warning(confirm_str); //BUG0071584 xxy 2023-8-24 附件字段“设置允许上传的文件格式”都删除保存后，弹出的“文件格式不能为空”弹窗中需要点击两次“确定”按钮才能关闭弹窗
                }else {
                    var okurl = 'index.php?module=Users&action=UsersAjax&file=getAttachmentFileType&save=yes&fileformat=' + filetype_content + '&module_name=' + module_name;
                    ldAjaxHtml(okurl,'',function (res){
                        popupobj.CancelEvent();
                        if (res.indexOf('success') >= 0) {
                            var confirm_str = arrJsPopLabel['Configure'] + arrJsPopLabel['SUCCESS'] + '！';
                            // RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                            MessagePopup.TipOne_success(confirm_str);
                        } else {
                            var confirm_str = arrJsPopLabel['Configure'] + arrJsPopLabel['LOSE'] + '！';
                            // RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                            MessagePopup.TipOne_warning(confirm_str);
                        }
                        DelProgressObjs();
                    })
                }
            });
        } else {	//查看
            ld('#'+popupobj.divid+'_btnok').unbind('click').bind('click', function () {
                popupobj.CancelEvent();
            });
        }
    });
}

//没有产品模块权限，请联系管理员
function noVtlibProducts() {
    var divobj = createElementDivs('loginreminder');
    var title = arrJsPopLabel['WARMPROMPT'];
    var div_text = '<div class="qui_dialog_body ww_dialog_body" style="background-color: #fff;">'
        + '<div class="msgDlg_left">'
        + '<div class="ww_commonImg ww_commonImg_Alert msgDlg_left_icon"></div>'
        + '</div>'
        + '<div class="msgDlg_right">'
        + '<div class="msgDlg_right_text" style="font-size:13px;padding-left: 4px;">' + arrJsPopLabel['noproductpermissions'] + '<br>' + arrJsPopLabel['setproductpermissions']
        + '</div>'
        + '</div>'
        + '</div>';
    ld(divobj).find('.D_pop_tit .D_ptita').html(title);
    ld('#loginremindercontent').html(div_text);
    ld(divobj).css('max-height', '500px');
    ld(divobj).css('width', '400px');
    ld(divobj).css('background', '#FDFDFD');
    ld('#loginremindercontent').css('max-height', '400px');
    ld('#loginremindercontent').css('border', 'none');
    ld(divobj).find('div.D_pbtn .D_pbtncancel').remove();
    ld(divobj).find('div.D_pbtn').addClass('ww_dialog_foot');
    ld(divobj).find('div.D_pop_tit a').attr("onclick", "fninvshnew('loginreminder');");
    ld(divobj).find('div.E_pbtn .E_pbtnok').attr("onclick", "fninvshnew('loginreminder');");
    fnvshobj(this, 'loginreminder');
}

function OpenRichTextTemplate(obj, ke) {
    var popupobj = CrmPopup.getPopupObj("last");
    var module = popupobj.module;
    //为了避免冲突，小编辑的富文本框需要加后缀于编辑界面区分
    if(popupobj.pagetype == 'approvepopup' || popupobj.pagetype == 'advancepopup'){
        popupobj.cheditorfieldname = obj+'_new';
    }else{
        popupobj.cheditorfieldname = obj;
    }
    popupobj.textareaobj = CrmPopup.findHtmlobj(popupobj.divid, obj);
    var Popupobj = CrmPopup.load("", "", "", "LdPopWidth650px", module, "", "", "", "");
    Popupobj.prevshow();
    var surl = 'index.php?module=' + module + '&action=' + module + 'Ajax&file=lookupRichText&popup=yes';
    ld.ajax({
        url: surl,
        type: 'POST',
        data: {"namename": "uname", "namenameage": 18},
        dataType: 'json',
        async: true,//
        timeout: 10000,
        success: function (data) {
            if (data.code == 1) {
                // $("status").style.display="none";
                Popupobj.createScrollDiv();//创建滚动条
                Popupobj.setParams(data.result.title, SaveDataRecord.save, "", "LdPopWidth950px", module, "", data.result.oktext, "", data.result.canceltext);
                Popupobj.show(data.result.content);
                return Popupobj;
            } else {
                ld("#" + Popupobj.divid).remove();
                Popupobj.crmpopuplayerobj.unblock();
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", data.msg);
            }
        },
        error: function (data) {
        }
    });
}

function submitRichText(templateid, module) {

    new Ajax.Request
    (
        'index.php',
        {
            queue: {
                position: 'end',
                scope: 'command'
            },
            method: 'post',
            //zkt 20230626 BUG0068678 案件来源模块，点击新建，选择原告富文本框点击调用文档模板，选择模板，无法进行调用 
            postBody: "module=" + module +"&action=" + module + "Ajax&file=RichTextContent&ReportHeader=DHeader&id=" + templateid,
            onComplete: function (response) {
                var popupobj = CrmPopup.getPopupObj("lastprev");

                if (response.responseText.indexOf('###SUCCESS###') > -1) {
                    var result = response.responseText.split("###SUCCESS###");
                    var ret = result[1];

                    popupobj.textareaobj.val(ret);
                    popupobj.oCKeditors[popupobj.cheditorfieldname].setContent(ret);

                }
                cancelCrmPopup();
            }
        }
    )
}


//editor:gyq_123 reason:显示服务小程序录入的沟通信息  2019/6/18 14:14 ID1000512
function get_communicate_detail(r_record, r_module, r_urlstring) {
    var urlstring = 'index.php?module=HelpDesk&action=HelpDeskAjax&file=communicate&record=' + r_record + '&frommodule=' + r_module;
    if (r_urlstring != '' && r_urlstring != undefined) {
        urlstring += r_urlstring;//携带当前页码
    }
    if (document.getElementById('communicate_div')) {
        ldAjax(urlstring, {}, function (rest) {
            document.getElementById('communicate_div').innerHTML = rest.result.content;//显示模板内容
            var popupobj = CrmPopup.getPopupObj('last');//获取当前的输出框对象
            ld("#" + popupobj.divid + " [name=communicatelist]").append(rest.result.tablecontent);//在当前的输出框对象上显示本页的内容
            DelProgressObjs();
        });
    }
    ;
}


//点击留言内容后方的【回复】按钮
function reply_message(obj) {

    var tdobj = Tools.getParentobjByChild(ld(obj), 'td');
    var reply_id = ld(tdobj).attr('id');
    var record = ld(tdobj).attr('record');
    var url = 'index.php?module=HelpDesk&action=HelpDeskAjax&file=Reply';
    url += '&mode=reply_ready';
    url += '&reply_id=' + reply_id;
    url += '&record=' + record;
    //实例化【回复】弹出层对象
    var Popupobj = CrmPopup.load("", "", "", "LdPopWidth650px", module, "", "", "", "");
    ldAjax(url, '', function (data) {
        if (data.code == 1) {
            //接收PHP返回的【回复】弹出层的参数并设置好弹出层属性
            var title = data.result.reply_content + ':' + data.result.title;
            var oktext = data.result.oktext;
            var canceltext = data.result.canceltext;
            var content_html = data.result.content_html;
            Popupobj.id = reply_id;
            Popupobj.record = record;
            Popupobj.setParams(title, reply_confirm, "", "LdPopWidth650px", module, "", oktext, "", canceltext);
            //接收PHP返回的【回复】弹出层的内容并进行展示
            Popupobj.show(content_html);
        }
    });
}

function reply_confirm() {
    //获取【回复】弹出层中文本框的内容
    var popupobj = CrmPopup.getPopupObj("last");
    var pid = popupobj.id;
    var record = popupobj.record;
    var reply_content = ld('#' + popupobj.divid + ' textarea[id=textarea]').val();
    //判断回复内容是否为空
    if (reply_content == "" || reply_content == null || reply_content == undefined) {
        alert("请输入回复内容");
        return -1;
    } else {
        //url携带回复内容和回复对象角色发给php
        var url = 'index.php?module=HelpDesk&action=HelpDeskAjax&file=Reply';
        url += '&mode=reply_finish';
        url += '&role_type=crmuser';
        url += '&reply_content=' + reply_content;
        url += '&pid=' + pid;
        url += '&record=' + record;
        ldAjax(url, '', function (data) {
            if (data.code == 1) {
                //接收来自文本框的评论内容和回复内容，并在评论区进行展示
                var r_record = data.result.r_record;
                var r_module = data.result.r_module;
                var r_urlstring = data.result.r_urlstring;
                get_communicate_detail(r_record, r_module, r_urlstring);
                popupobj.CancelEvent();//关闭弹出层
                DelProgressObjs();
            }
        });
    }
}


//editor:gyq_127 reason:服务小程序增加评价  2019/6/26 11:49 ID1000419
function get_evaluate_detail(r_record, r_module) {
    var urlstring = 'module=HelpDesk&action=HelpDeskAjax&file=index_evaluate&second_action=get_detail&record=' + r_record;
    if (document.getElementById('evaluate_div')) {
        RequestAjax(urlstring, function (rest) {
            if (trim(rest) != '') {
                document.getElementById('evaluate_div').innerHTML = rest;
                DelProgressObjs();
            }
        });
    }
}

//获取typeofdata值
function gettypeofdata_decimal(popupobj, columnanme, type) {
    var typeofdata_decimal = 2;
    if (empty(popupobj)) {
        popupobj = CrmPopup.getPopupObj("last");
    }
    var tmptypeofdata = '';
    if (type == 'main' && popupobj.fields != undefined) {
        ld.each(popupobj.fields, function (tmpindex, tmpfieldinfo) {
            if (tmpfieldinfo.columnname == 'total') {
                tmptypeofdata = tmpfieldinfo.typeofdata;
            }
        });
    } else if (type == 'detail' && popupobj.detailfields != undefined) {
        ld.each(popupobj.detailfields, function (tmpindex, tmpdetailfieldinfo) {
            if (tmpdetailfieldinfo.columnname == 'total') {
                tmptypeofdata = tmpdetailfieldinfo.typeofdata;
            }
        });
    }
    if(!empty(tmptypeofdata)){
        var tmptypeofdatas = tmptypeofdata.split(',');
        if (tmptypeofdatas.length > 1 && tmptypeofdatas[1] != '') {
            typeofdata_decimal = tmptypeofdata.split(',')[1];
        }
    }
    return typeofdata_decimal;
}
//wym XUQIU1001764 多选关联字段清除输入框所有值
function clear_multiinput(input_id,input_name) {
    var popupobj = CrmPopup.getPopupObj('last');
    ld('#' + popupobj.divid+" [name='"+input_id+"']").val('');
    ld('#' + popupobj.divid+" [name='"+input_name+"']").val('');
    ld('#' + popupobj.divid+" [name='"+input_name+"']").attr('title','');
    //zkt 20241024 BUG20240828-14 选择【工作量评估】后自动通过sql查询带出【评估结果】数据，删除【工作量评估】字段，【评估结果】字段没有被清空
    ld("#" + popupobj.divid+" [name='"+input_id+"']").change();
}
function insertAt(obj, index, newItem) {
    index = parseInt(index);
    // 获取所有的键（已排序）
    var keys = Object.keys(obj).map(key => parseInt(key)).sort((a, b) => a - b);

    // 从最后一个键开始，向后移动每一个项
    for (var i = keys.length - 1; i >= 0; i--) {
        var key = keys[i];
        if (key >= index) {
            obj[key + 1] = obj[key]; // 向后移动一位
        }
    }
    // 插入新项
    obj[index] = newItem;

    return obj;
}
function removeAt(obj, index) {
    index = parseInt(index);
    // 获取所有的键（已排序）
    var keys = Object.keys(obj).map(key => parseInt(key)).sort((a, b) => a - b);
    // 如果不存在该键，直接返回
    if (!keys.includes(index)) {
        //return obj;
    }
    else{
        // 删除指定键
        delete obj[index];
    }
    // 从指定键开始，向前移动每一个项
    for (var i = index; i < keys[keys.length - 1]; i++) {
        if (obj.hasOwnProperty(i + 1)) {
            obj[i] = obj[i + 1]; // 向前移动一位
        }
    }
    if(index<=keys[keys.length - 1]){
        // 删除原来最后一个键
        delete obj[keys[keys.length - 1]];
    }


    return obj;
}
//zkt 
//分录行rowindex变化
/**
 * popupobj：对应的弹窗对象
 * status: 记录分录行rowindex变化状态 
 * operation: 对分录行的操作 add,delete,exchange,deleteall
 * operationrowindex : 被操作行对应rowindex
 * torowindex: 目标行对应rowindex
 */
function Detaildatachange_byrowindexoperation(popupobj,status,operation,operationrowindex,torowindex)
{
    var status_arr = ['before','after'];
    var operation_arr = ['add','delete','exchange','deleteall','cearlrow'];
    if(status_arr.indexOf(status)<0){
        return ;
    }
    if(operation_arr.indexOf(operation)<0){
        return ;
    }
    
    //新增行操作
    if(status == 'before' && operation == 'add')
    {
        if(empty(torowindex)){
            torowindex = operationrowindex+1;
        }
        //处理 
        if(popupobj!=undefined && popupobj != '' && popupobj.pagetype != undefined && popupobj.pagetype == 'create_edit_modulepage')
        {
            
            if(popupobj.detailfilejsondata == undefined ){
                popupobj.detailfilejsondata =[]; 
            }
            var tmpdetailjsondata_arr = popupobj.detailfilejsondata;
            if(tmpdetailjsondata_arr[torowindex] == undefined){
                tmpdetailjsondata_arr[torowindex] = [];
            }
            else{
                insertAt(tmpdetailjsondata_arr,torowindex,[]);
            }
            
        }
    }
    
    //删除行操作
    if(status == 'before' && operation == 'delete')
    {
        if(empty(torowindex)){
            torowindex = operationrowindex;
        }
        //处理 
        if(popupobj!=undefined && popupobj != '' && popupobj.pagetype != undefined && popupobj.pagetype == 'create_edit_modulepage')
        {
            
            if(popupobj.detailfilejsondata == undefined ){
                popupobj.detailfilejsondata =[]; 
            }
            var tmpdetailjsondata_arr = popupobj.detailfilejsondata;
            removeAt(tmpdetailjsondata_arr,torowindex);
        }
    }
    
    //清空按钮,删除所有行操作
    if(status == 'before' && operation == 'deleteall')
    {
        //处理 
        if(popupobj!=undefined && popupobj != '' && popupobj.pagetype != undefined && popupobj.pagetype == 'create_edit_modulepage')
        {
            if(popupobj.detailfilejsondata != undefined ){
                popupobj.detailfilejsondata =[]; 
            }
        }
    }
    
    //拖动行操作
    if(status == 'before' && operation == 'exchange')
    {
        //处理 
        if(popupobj!=undefined && popupobj != '' && popupobj.pagetype != undefined && popupobj.pagetype == 'create_edit_modulepage')
        {
            if(!empty(operationrowindex)&&!empty(torowindex)){
                if(popupobj.detailfilejsondata != undefined){
                    if(popupobj.detailfilejsondata[operationrowindex] == undefined){
                        popupobj.detailfilejsondata[operationrowindex] = [];
                    }
                    if(popupobj.detailfilejsondata[torowindex] == undefined){
                        popupobj.detailfilejsondata[torowindex] = [];
                    }
                        
                    var tempdata = popupobj.detailfilejsondata[operationrowindex];
                    popupobj.detailfilejsondata[operationrowindex] = popupobj.detailfilejsondata[torowindex];
                    popupobj.detailfilejsondata[torowindex] = tempdata;
                }
            }
        }
    }
    
    //清除行操作(目前只有产品)
    if(status == 'before' && operation == 'cearlrow')
    {
        //处理 
        if(popupobj!=undefined && popupobj != '' && popupobj.pagetype != undefined && popupobj.pagetype == 'create_edit_modulepage')
        {
            if(popupobj.detailfilejsondata == undefined ){
                popupobj.detailfilejsondata =[]; 
            }
            if(popupobj.detailfilejsondata[operationrowindex] != undefined){
                popupobj.detailfilejsondata[operationrowindex] = [];
            }
        }
    }
}
//zkt 分录添加或删除附件时修改detailfilejsondata
/**
 * popupobj：对应的弹窗对象 -- 应为新增编辑界面弹窗
 * item: 附件对象
 * options: 附件的属性-包括fieldname
 * filename : 上传文件信息filename
 * file : 上传文件信息
 * flag: create：上传,edit：加载
 */
function addDetailfiledata(popupobj,item,options,file,flag,filename,newfile_name){
    if(popupobj!=undefined && popupobj != '' && popupobj.pagetype != undefined && popupobj.pagetype == 'create_edit_modulepage'&&options.isdetails != undefined && options.isdetails == 'yes'){
        if(empty(filename)){
            filename = file.name.replace(/\'/g,"");
			filename = filename.replace(/\"/g,"");
			filename = filename.replace(/ /g,"_");
        }
        if(empty(newfile_name)){
            newfile_name=file.newfile_name;
          	 newfile_name = newfile_name.replace(/\"/g,"");
			newfile_name = newfile_name.replace(/ /g,"_");
        }
        // item:附件字段对应div; opts.detail:是否为分录字段
        //获取分录所在 rowindex
        var trobj = Tools.getParentobjByChild(ld(item), 'tr');
        var tmprowindex = ld(trobj).attr('rowindex');
        
        var tmpcolumnname = options.inputFileName;//设置默认值
        for (var tmpi = 0; tmpi < popupobj.detailfields.length; tmpi++) {
            if (popupobj.detailfields[tmpi].fieldname == options.inputFileName){
                tmpcolumnname =popupobj.detailfields[tmpi].columnname ;
                break;
            }
        }
        //数组数据 处理
        if(popupobj.detailfilejsondata != undefined ){
            if(popupobj.detailfilejsondata[tmprowindex] == undefined){
                popupobj.detailfilejsondata[tmprowindex] = [];
            }
            if(popupobj.detailfilejsondata[tmprowindex][tmpcolumnname] == undefined){
                popupobj.detailfilejsondata[tmprowindex][tmpcolumnname] = [];
            }
            
            var tmpjsondata = popupobj.detailfilejsondata[tmprowindex][tmpcolumnname];//处理前数据
            var tmpupload_from = (file.upload_from!=undefined)?file.upload_from:'';
            var imagefromtype = (file.imagefromtype!=undefined)?file.imagefromtype:'';
            var tmpadddata = {
                                'filerowindex':file.filerowindex,
                                'fieldname':options.inputFileName,
                                'pre_button':options.pre_button,
                                'file_name':filename,
                                'file_size':file.size,
                                'file_type':file.type,
                                'file_path':file.path,
                                'newfile_name':newfile_name,
                                'cloud_path':decodeURIComponent(file.cloud_path),
                                'fileid':file.fileid,
                                'storage_location':file.storage_location,
                                'imagefromtype':imagefromtype,
                                'upload_from':tmpupload_from,
                                'isEncrypt':file.isEncrypt
                                };
            //增加
            if(flag == 'create'){
                tmpjsondata.push(tmpadddata);
            }
            else{
                if(tmpjsondata.length>0){
                    for(var tmpi=0 ;tmpi<tmpjsondata.length;tmpi++){
                        if(tmpjsondata[tmpi]['fileid']==tmpadddata['fileid']){
                            tmpjsondata[tmpi] = tmpadddata;
                            return false;
                        }
                    }
                }
                else{
                    tmpjsondata.push(tmpadddata);
                }
                
            }
        }
    }
}
//zkt 分录删除附件时修改detailfilejsondata
/**
 * popupobj：对应的弹窗对象 -- 应为新增编辑界面弹窗
 * item: 附件对象
 * options: 附件的属性-包括fieldname
 * filerowindex:
 */
function delateDetailfiledata(popupobj,item,options,filerowindex){
    if(popupobj!=undefined && popupobj != '' && popupobj.pagetype != undefined && popupobj.pagetype == 'create_edit_modulepage'&&options.isdetails != undefined && options.isdetails == 'yes'){
        // item:附件字段对应div; opts.detail:是否为分录字段
        //获取分录所在 rowindex
        var trobj = Tools.getParentobjByChild(ld(item), 'tr');
        var tmprowindex = ld(trobj).attr('rowindex');
        var tmpcolumnname = options.inputFileName;
        for (var tmpi = 0; tmpi < popupobj.detailfields.length; tmpi++) {
            if (popupobj.detailfields[tmpi].fieldname == options.inputFileName){
                tmpcolumnname =popupobj.detailfields[tmpi].columnname ;
                break;
            }
        }
        //数组数据 处理
        if(popupobj.detailfilejsondata != undefined && popupobj.detailfilejsondata[tmprowindex] != undefined &&  popupobj.detailfilejsondata[tmprowindex][tmpcolumnname] != undefined){
            var tmpjsondata = popupobj.detailfilejsondata[tmprowindex][tmpcolumnname];//处理前数据
            if(tmpjsondata.length>0){
                var tmpindex = -1; //要被删除的数据index
                for(var tmpi = 0 ; tmpi<tmpjsondata.length ; tmpi++){
                    if(tmpjsondata[tmpi]['filerowindex'] == filerowindex){
                        tmpindex = tmpi;
                        break;
                    }
                }
                if(tmpindex>=0){
                    tmpjsondata.splice(tmpindex, 1);//删除数组的一个值
                }
            }
        }
    }
}
/*
* edit:zkt
* datetime:20240624
* 获取分录 分录行 数据信息columnname:columnnamevalue
* */
function getDetailRowValuesarr(popupobj,rowobj)
{
    var detailrequestrowvalues = {};
    var rowid = ld(rowobj).attr("rowindex");
    var rowvalueinfo = [];
    if(!empty(rowid)&&popupobj.detailfieldmodule != undefined &&popupobj.detailfieldmodule == 'Products'){
        rowvalueinfo = popupobj.detaildatavalue_arr[rowid-1];
    }
    if(popupobj.detailfields!=undefined && popupobj.detailfields.length>0){
        ld.each(popupobj.detailfields,function(tmpindex,tmpfieldinfo){
            if (typeof tmpfieldinfo.columnname == 'undefined') {
                return true;
            }
            var tmpcolumnname = tmpfieldinfo.columnname;
            var tmpfieldvalue = '';
            if(!empty(rowvalueinfo)&&popupobj.detailfieldmodule != undefined &&popupobj.detailfieldmodule == 'Products'){
                var tmpvalue = rowvalueinfo[tmpcolumnname];
                if(tmpfieldinfo.uitype==60 && tmpcolumnname=='wareid')
                {
                    tmpfieldvalue = rowvalueinfo[tmpcolumnname+"_rawvalue"];

                }
                else if(tmpfieldinfo.uitype == 56){
                    tmpfieldvalue = (tmpvalue==true||tmpvalue==1)?1:0;
                }
                else if (tmpfieldinfo.uitype == 63) {
                    tmpfieldvalue = tmpvalue;
                }
                else{
                    tmpfieldvalue = tmpvalue;
                }
                if(tmpfieldinfo.columnname == 'entitytypeid'){
                    if (tmpfieldvalue === '0') {
                        tmpfieldvalue = '';
                    }
                }
                //zkt 20241129 增加传参产品id
                if(tmpfieldinfo.columnname == 'productname' && rowvalueinfo['productid'] != undefined){
                    detailrequestrowvalues['productid'] = rowvalueinfo['productid'];
                }

            }
            else{
                var tmpobj = ld(rowobj).find(" #" + tmpcolumnname );
                if (tmpfieldinfo.fieldtype == 'SelectComBox') {
                    //多选框
                    if(tmpobj.attr("multiple")!=undefined) {
                        var strtmp = getMultiPickListSelectValueByObj(tmpobj);
                    }else{
                        var strtmp = tmpobj.val();
                    }
                    tmpfieldvalue = strtmp;
                }
                else if (tmpfieldinfo.fieldtype == 'CheckBox'&&(tmpfieldinfo.edit_permission != undefined && tmpfieldinfo.edit_permission != 1)) {
                    if (ld(tmpobj).prop("checked")) {
                        tmpfieldvalue = "1";
                    } else {
                        tmpfieldvalue = "0";
                    }
                }
                else{
                    tmpfieldvalue = ld(tmpobj).val();
                }
            }
            if(tmpfieldvalue == undefined){
                tmpfieldvalue = '';
            }
            detailrequestrowvalues[tmpfieldinfo.columnname] = encodeURIComponent(tmpfieldvalue);
        })
    }
    return detailrequestrowvalues;
}









