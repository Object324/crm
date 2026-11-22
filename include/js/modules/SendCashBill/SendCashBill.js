//批量审批
function masscheckSendCashBill(alert_str, module, gstart, viewid, idlist, searchscope, confirm_status) {
    //var url = 'module=SendCashBill&type=check&action=SendCashBillAjax&file=BankConfirm&idlist='+idlist;
    //RequestAjax(url,function(rest){
    //if(rest.indexOf('#####:success') > -1){

    if (confirm_status) {
        confirm_masscheckSendCashBill(alert_str, module, gstart, viewid, idlist, searchscope, confirm_status);
    } else {//确定要进行审核吗？
        RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", alert_str);
        //确定按钮
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
            confirm_masscheckSendCashBill(alert_str, module, gstart, viewid, idlist, searchscope, confirm_status);
        });
    }

    //}else{//您选择的记录有已审核的单据，不能进行批量审核！
    //alert(arrJsPopLabel['yhbsrcdnbb']);
    //}
    //});
    return false;
}

//审核付款单
function confirm_masscheckSendCashBill(alert_str, module, gstart, viewid, idlist, searchscope, confirm_status) {
    url = 'module=SendCashBill&action=SendCashBillAjax&file=BankConfirm&type=checklist&return_module=' + module;
    url += '&' + gstart + '&viewname=' + viewid + '&idlist=' + idlist + '&SearchScope=' + searchscope;
    RequestAjax(url, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var divobj = createElementDivs('massApproveCashBill');
        ld(divobj).css('max-height', '350px');
        ld('#massApproveCashBillcontent').css('max-height', '250px');
        ld('#massApproveCashBillcontent').css('overflow-y', 'auto');
        var submitlog = '<div style="width:97%;margin-top:10px;margin-bottom:10px;line-height:22px;padding-left:10px;">';
        submitlog += restobj.log.value;//批量提交失败日志
        submitlog += '</div>';
        ld(divobj).find('div.D_pop_tit .D_ptita').html(restobj.title.value);
        ld('#massApproveCashBillcontent').html(submitlog);
        fnvshobj('', 'massApproveCashBill');
        ld(divobj).find('div.D_pbtn .D_pbtnok').unbind('click').on('click', function () {
            fninvshnew('massApproveCashBill');
            puyoungJS_DialogBox.unblock();
            getId('allselectedboxes').value = '';
            getListViewEntries_js(module, 'start=' + restobj.start.value);//刷新页面
        });
		DelProgressObjs();
    });
}

/*
edit:Can
date:20130606
reason:无付款计划金额
*/
function NoSendPayment(obj) {
    var ret = true;
    var popupobj = CrmPopup.getPopupObj("last");
    if (obj == 'select')
        obj = ld('#' + popupobj.divid + ' [name="nosendpayment"]').get(0);
    var otherselect = ld('#' + popupobj.divid + ' [name="otherselect"]').get(0).value;    //调整 增加 减少
    if (isNaN(obj.value) && trim(obj.value) != "") {
        //其它款项金额非法！
        var confirm_str = arrJsPopLabel['INVALIDADJUSTMENTAMOUNT'];
        RemindsMsg("", "LdPopWidth400px", "", "yes", "", confirm_str);
        obj.focus();

        if (!document.all) {
            obj.select();
            window.setTimeout(function () {
                obj.focus();
                obj.select();
            }, 0);
        }

        ret = false;
    }
    obj.value = trim(obj.value);
    if (obj.value == "") {
        obj.value = 0;
    }
    var curvalue = 0;
    var paymenttab = ld('#' + popupobj.divid + ' table[name="proTab"]').get(0);
    var rowcount = paymenttab.rows.length;//总行数
    var trobjs=ld(paymenttab).find("tr[detaildeleted=no]");
    
    //for (var i = 1; i < rowcount - 3; i++) {
        /*if(document.getElementById("chkPayment"+i).checked)
        {*/
      //  if (ld('#' + popupobj.divid + ' [name="deleterow' + i + '"]').get(0).value == 0) {
        ld.each(trobjs,function(){
            
            var amount = ld(this).find(' [name="amount"]').get(0);
            curvalue = curvalue + parseFloat(amount.value);
        })
            
        //}

        //}
    //}
     var rowcount=ld(paymenttab).find("tr").length;
    var totalpaymenttr = paymenttab.rows[rowcount - 1];
    var totalpaymenttd = totalpaymenttr.cells[1];
    if (otherselect == 1)
        var total = curvalue + parseFloat(obj.value);
    else
        var total = curvalue - parseFloat(obj.value);
    var typeofdata_decimal = gettypeofdata_decimal(popupobj,'total','main');
    totalpaymenttd.innerHTML = parseFloat(total).toFixed(typeofdata_decimal);
    ld('#' + popupobj.divid + ' [name="totalplayment"]').get(0).value = parseFloat(total).toFixed(typeofdata_decimal);
    return ret;
}

function setSendCashBillTotal() {

}

/*
edit:chj
date:2014-4-22
reason:调整回款计划总金额(v5.3)
*/
function selSendPayment(obj) {
    var ret = true;
    var curvalue = 0;
    var popupobj = CrmPopup.getPopupObj("last");
    var nopaymentplan = ld('#' + popupobj.divid + ' [name="nosendpayment"]').get(0);
    var paymenttab = ld('#' + popupobj.divid + ' table[name="proTab"]').get(0);
    
    var trobjs=ld(paymenttab).find("tr[detaildeleted=no]");
    
   // for (var i = 1; i < rowcount - 3; i++) {
       // if (ld('#' + popupobj.divid + ' [name="deleterow' + i + '"]').get(0).value == 0) {
        ld.each(trobjs,function(){
            curvalue = curvalue + parseFloat(ld(this).find(' [name="amount"]').val());
            
        })
            
       // }
   // }
    var rowcount=ld(paymenttab).find("tr").length;
    var totalpaymenttr = paymenttab.rows[rowcount - 1];
    var totalpaymenttd = totalpaymenttr.cells[1];
    if (obj == 1)
        var total = curvalue + parseFloat(nopaymentplan);
    else
        var total = curvalue - parseFloat(nopaymentplan);
    var typeofdata_decimal = gettypeofdata_decimal(popupobj,'total','main');
    totalpaymenttd.innerHTML = parseFloat(total).toFixed(typeofdata_decimal);
    ld('#' + popupobj.divid + ' [name="totalplayment"]').get(0).value = parseFloat(total).toFixed(typeofdata_decimal);
    return ret;
}

function calSendTotal() {
    var ret = true;
    var curvalue = 0;
    let prevpopupobj =CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);//编辑或者新增界面
    let paymenttab = ld('#' + prevpopupobj.divid + ' table[name="proTab"]').first();
    let nopaymentplan = paymenttab.find('[name="nosendpayment"]').first().val();
    let otherselect = paymenttab.find('[name="otherselect"]').first().val();
   var trobjs=ld(paymenttab).find("tr[detaildeleted=no]");
    ld.each(trobjs,function(){
            var amount=ld(this).find(' [name="amount"]').val();
            if(amount=='')
            {
                amount=0;
            }
            curvalue = curvalue + parseFloat(amount);
            
    })
    if(paymenttab.find('[name="subtotal_amount"]').size() > 0){
      //  paymenttab.find('[name="subtotal_amount"]').first().html(parseFloat(curvalue).toFixed(gettypeofdata_decimal(popupobj,'amount','main'))) ;
	}
     var rowcount=ld(paymenttab).find("tr").length;
    //求回款计划的总金额
    let paymenttr = paymenttab.find('tr').eq(rowcount-1);
    let paymenttd = paymenttr.find('td').eq(1);
    //paymenttd.html(curvalue.toFixed(2));
    let totalpaymenttr = paymenttab.find('tr').eq(rowcount-1);
    let totalpaymenttd = totalpaymenttr.find('td').eq(1);
    //if (otherselect == 1)
//        var total = curvalue + parseFloat(nopaymentplan);
//    else
//        var total = curvalue - parseFloat(nopaymentplan);
   
    var typeofdata_decimal = gettypeofdata_decimal(popupobj,'total','main');
    if (ld('#' + prevpopupobj.divid ).find('[name="sum_total"]').size() > 0) {
        ld('#' + prevpopupobj.divid ).find('[name="sum_total"]').first().html(parseFloat(curvalue).toFixed(typeofdata_decimal));
    }
    if (ld('#' + prevpopupobj.divid ).find('[name="span_total"]').size() > 0) {
        ld('#' + prevpopupobj.divid ).find('[name="span_total"]').first().html(parseFloat(curvalue).toFixed(typeofdata_decimal));
    }
   
    if (ld('#' + prevpopupobj.divid ).find('[name="total"]').size() > 0) {
        ld('#' + prevpopupobj.divid ).find('[name="total"]').first().val(parseFloat(curvalue).toFixed(typeofdata_decimal));
    }
    if (curvalue > 0) {
        ld('#' + prevpopupobj.divid ).find('[name="sum_total"]').first().show();
        ld('#' + prevpopupobj.divid ).find('[name="span_total"]').first().show();
        ld('#' + prevpopupobj.divid ).find('[name="total"]').first().hide();
    } else {
        ld('#' + prevpopupobj.divid ).find('[name="sum_total"]').first().hide();
        ld('#' + prevpopupobj.divid ).find('[name="span_total"]').first().hide();
        ld('#' + prevpopupobj.divid ).find('[name="total"]').first().show();
    }
    //totalpaymenttd.innerHTML=parseFloat(total).toFixed(2);
    return ret;
}

function deleteRowSendPayment(i) {
    rowCnt--;
    var popupobj = CrmPopup.getPopupObj("last");
    var paymenttab = ld('#' + popupobj.divid + ' table[name="proTab"]').get(0);
    ld('#' + popupobj.divid + ' [name="row' + i + '"]').get(0).style.display = 'none';
    ld(paymenttab).find("tr[rowindex="+i+"]").remove();
    ShowSequence(popupobj);
    
    var trobjs=ld(paymenttab).find("tr[detaildeleted=no]");
    var rowcount = ld(trobjs).length;
    var dis_row = rowcount;
    
   
    //没有明细行
    if (dis_row == 0) {
        if (ld('#' + popupobj.divid + ' [name="sum_total"]').size() > 0) {
            ld('#' + popupobj.divid + ' [name="sum_total"]').get(0).style.display = 'none';
        }
        if (ld('#' + popupobj.divid + ' [name="span_total"]').size() > 0) {
            ld('#' + popupobj.divid + ' [name="span_total"]').get(0).style.display = 'none';
        }
        if (ld('#' + popupobj.divid + ' [name="total"]').size() > 0) {
            ld('#' + popupobj.divid + ' [name="total"]').get(0).style.display = '';
        }
    } else {
        if (ld('#' + popupobj.divid + ' [name="sum_total"]').size() > 0) {
            ld('#' + popupobj.divid + ' [name="sum_total"]').get(0).style.display = '';
        }
        if (ld('#' + popupobj.divid + ' [name="span_total"]').size() > 0) {
            ld('#' + popupobj.divid + ' [name="span_total"]').get(0).style.display = '';
        }
        if (ld('#' + popupobj.divid + ' [name="total"]').size() > 0) {
            ld('#' + popupobj.divid + ' [name="total"]').get(0).style.display = 'none';
        }
    }
    //选择源单字段增加保存到数据库功能
    //updateCashbillSourceNo();
    
}

/*
edit:Can
date:20130606
reason:本次付款金额改变
*/
function curSendCashBill(obj) {
    var ret = true;
    
   
    var popupobj = CrmPopup.getPopupObj("last");
    if (obj != undefined) {
         var rowobj=ld(obj).parent();
        while(ld(rowobj).prop("tagName")!="TR")
        {
            rowobj=ld(rowobj).parent();
        }
        var rowindex=ld(rowobj).attr("rowindex");
        
        obj.value = trim(obj.value);

        if (isNaN(obj.value) && obj.value != "") {
            //金额非法！
            //alert(arrJsPopLabel['AMOUNTILLEGAL']);
            //obj.focus();
            if (!document.all) {
                obj.select();
                window.setTimeout(function () {
                    obj.focus();
                    obj.select();
                }, 0);
            }

            ret = false;
        }
        if (obj.value == "") {
            obj.value = 0;
        }
    }
    else {
        obj = ld('#' + popupobj.divid + ' [detailcolumnname="amount"]').get(0);
    }
    if (obj == undefined)//有可能没有付款单
    {
        return;
    }
    var chkName = "amount";//
   
    var paymenttab = ld('#' + popupobj.divid + ' table[name="proTab"]').get(0);
    
    var tabtr = ld(rowobj).get(0);
    var curvalue = 0;
 
    var nowtr;
    var nowtd;
    var trobjs=ld(paymenttab).find("tr[detaildeleted=no]");
    
    //for (var i = 1; i < rowcount - 3; i++) {
    ld.each(trobjs,function(){
       // if (ld('#' + popupobj.divid + ' [name="deleterow' + i + '"]').get(0).value == 0) {
            curvalue = curvalue + parseFloat(ld(this).find(' [name="amount"]').get(0).value);
        //}
    });
   // }

    //BUG0056909 在付款编辑时，单据分录的左下角出现了付款金额数字
    //求付款计划的总金额
    /*var rowcount=ld(paymenttab).find("tr").length;
    
    var paymenttr = paymenttab.rows[rowcount-1];
    var paymenttd = paymenttr.cells[1];
    paymenttd.innerHTML = curvalue.toFixed(2);*/
    if(ld('#' + popupobj.divid + ' [name="totalhaveplaymentamount"]').size() > 0){
        ld('#' + popupobj.divid + ' [name="totalhaveplaymentamount"]').get(0).value = curvalue.toFixed(gettypeofdata_decimal(popupobj,'amount','detail'));
    }
    //求无付款计划和有付款计划的总金额
    /*var totalpaymenttr = paymenttab.rows[rowcount-1];//小计行
    var totalpaymenttd = totalpaymenttr.cells[1];*/
    var total = parseFloat(parseFloat(curvalue).toFixed(gettypeofdata_decimal(popupobj,'total','main')));
    if(ld('#' + popupobj.divid + ' [name="nosendpayment"]').size() > 0){
        total += parseFloat(ld('#' + popupobj.divid + ' [name="nosendpayment"]').get(0).value);
    }
    total = parseFloat(parseFloat(total).toFixed(gettypeofdata_decimal(popupobj,'total','main')));
    if(ld('#' + popupobj.divid + ' [name="totalplayment"]').size() > 0){
        ld('#' + popupobj.divid + ' [name="totalplayment"]').get(0).value = total;
    }

    if (ld('#' + popupobj.divid + ' [name="sum_total"]').size() > 0) {
        ld('#' + popupobj.divid + ' [name="sum_total"]').get(0).innerHTML = total;
    }
    if (ld('#' + popupobj.divid + ' [name="span_total"]').size() > 0) {
        ld('#' + popupobj.divid + ' [name="span_total"]').get(0).innerHTML = total;
    }
    if (ld('#' + popupobj.divid + ' [name="total"]').size() > 0) {
        ld('#' + popupobj.divid + ' [name="total"]').get(0).value = total;
    }
     var  param=[];
     //console.log(popupobj.mainfieldformulaobj);
    if(popupobj.mainfieldformulaobj!=undefined)
    {
        param['data']={'formulafieldname':popupobj.mainfieldformulaobj.maincolumninfo['total'].fieldname};
    
        popupobj.mainfieldformulaobj.startComputer(param);
    }
    return ret;
}

/*
edit:can
date:20130710
reason:付款单上采购订单清除后清除相应的付款计划列表

*/
function ClearSendPaymentList(module) {
    var popupobj = CrmPopup.getPopupObj("last");
    var tabpay = ld('#' + popupobj.divid + ' table[name="proTab"]').get(0);
    if (tabpay != undefined) {
        for (var i = 1; i < tabpay.rows.length - 3; i++) {
            tabpay.deleteRow(i);
        }
        tabpay.rows[tabpay.rows.length - 3].cells[1].innerHTML = 0.00;
        tabpay.rows[tabpay.rows.length - 1].cells[1].innerHTML = ld('#' + popupobj.divid + ' [name="nosendpayment"]').get(0).value;
    }
    return false;
}



//V6.5:财务和库存单据选择源单  使用橡皮擦，清除供应商或者清除源单之后，分录中的产品信息应该清空，源单信息区块内容也应该清空。
clearVendors.other_clear = function () {
    clearModuleProduct(this, 'SendCashBill', '');
}

//币种切换调用事件，修改分录值 zkt 20220920
function BillChangCurrencychangeDetail(popupobj,sourcemodule,selectcurrency_rate,beforecurrency_rate){
    var sourcemodule_arr = popupobj.sourcemodule_arr;
    var withdetail = '';
    ld.each(sourcemodule_arr,function(index,sourcemoduleinfo){
        if(sourcemoduleinfo['entitytype'] == sourcemodule){
            withdetail = sourcemoduleinfo['withdetail'];
        }
    })
    var trobjs = popupobj.getTrObjsByDelType("no");
    if(withdetail == 'no'||withdetail == 'yes'){
		ld(trobjs).each(function () {
		   var tmpfieldname = 'amount';
           if(ld(this).find(' [name='+tmpfieldname+']').length>0){
                var tagMoney = ld(this).find(' [name='+tmpfieldname+']');
				var curCashBill = parseFloat(tagMoney.val());
				if(parseInt(beforecurrency_rate,10) == 1)
					curCashBill = curCashBill*selectcurrency_rate;
				else
					curCashBill = parseFloat(curCashBill/beforecurrency_rate)*selectcurrency_rate;
				curCashBill = curCashBill.toFixed(gettypeofdata_decimal(popupobj,tmpfieldname,'detail'));
                tagMoney.val(curCashBill);
                tagMoney.change();
				i++;
           }
		});
	}
        
}
