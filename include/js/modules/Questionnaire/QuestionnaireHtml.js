
//关联选择单据（单选）
function showrelatedlist(topicid,selectmodule){
    var value = '';
    var Keyids = getRelatedKeyids(selectmodule);
    value = ld('#SelectBill_'+topicid).get(0).value;
    $.ajax({
        url: '../../modules/Questionnaire/InterfaceRelatedList.php?languege='+languege,
        data: 'topicid='+topicid+'&value='+value+'&Keyids='+Keyids,
        type: 'POST',
        dataType: 'json',
        timeout: 5000,
        success: function (data) {
            if(data.code == 1){
                var popupobj= CrmPopup.load(data.result.title,'','',"600",data.result.module,"",data.result.oktext,'',data.result.canceltext);
                popupobj.show(data.result.content);
                ld('#'+popupobj.divid).css('width','98%');
                ld('#'+popupobj.divid).css('max-width','600px');
                popupobj.center();
            }
        }
    })
}

//弹出框列表选中变色
function setPopTrColor(sel_id){
    document.getElementById(sel_id).className = "lvtColDataHover";
}
function setPopTrColorOut(sel_id,type){
    if(type == 'On'){
        document.getElementById(sel_id).className = "lvtColDataBj";
    }else{
        document.getElementById(sel_id).className = "lvtColData";
    }
}

function search_relatedlist(topicid,selectmodule){
    var value = '';
    value = ld('#cheack_repeat_columnname').get(0).value;
    var Keyids = getRelatedKeyids(selectmodule);
    $.ajax({
        url: '../../modules/Questionnaire/InterfaceRelatedList.php?languege='+languege,
        data: 'topicid='+topicid+'&value='+value+'&Keyids='+Keyids,
        type: 'POST',
        dataType: 'json',
        timeout: 5000,
        success: function (data) {
            if(data.code == 1){
                popupobj.show(data.result.content);
            }
        }
    })
}

function cleanall(){
    document.getElementById("cheack_repeat_columnname").value="";
}
//选择单据
function choose_related(crmid,rowindex,topicid){
    document.getElementById("SelectBillId_"+topicid).value=crmid;
    document.getElementById("SelectBill_"+topicid).value=ld('#poprow_'+rowindex).find(":first-child").get(0).innerText;
    var popupobj=CrmPopup.getPopupObj('last');
    popupobj.CancelEvent();
}

function clearinput(topicid){
    document.getElementById("SelectBillId_"+topicid).value='';
    document.getElementById("SelectBill_"+topicid).value='';
}

function getRelatedKeyids(selectmodule){
    Keyids = '';
    var SelectBillIdobj = ld('#mainFieldsIphone').find('input[name*=SelectBillId_]');
    if(SelectBillIdobj.length > 0){
        for(let i = 0;i<SelectBillIdobj.length;i++){
            var module = SelectBillIdobj.get(i).getAttribute('referencemodule');
            if(selectmodule!=module && SelectBillIdobj.get(i).value != ''){

                if(selectmodule=='ProjectTask'){
                    if(module == 'Project')
                        Keyids = SelectBillIdobj.get(i).value;
                    else if(module == 'Accounts')
                        Keyids = SelectBillIdobj.get(i).value;
                }else if (selectmodule == 'PurchaseOrder' || selectmodule == 'VendorContact') {
                    if (module == 'Vendors') {
                        Keyids = SelectBillIdobj.get(i).value;
                    }
                }else if (selectmodule == 'Contacts') {
                    if (module == 'Accounts') {
                        Keyids = SelectBillIdobj.get(i).value;
                    }
                }else{
                    //chj : 0015517: 施明程：合同订单选择上级合同时，不应该限制只能选择选定客户的合同
                    if(module=="SalesOrder"&&selectmodule =='SalesOrder'){

                    }else if(module == 'Accounts'){
                        Keyids = SelectBillIdobj.get(i).value;
                    }
                }
            }
        }
    }
    return Keyids;
}