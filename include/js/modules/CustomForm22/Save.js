/**
 * 朗捷 报关单复制 清空某些字段
 * @returns {boolean}
 */
function setDetailNull(){
    var popupobj=CrmPopup.getPopupObj("last"),
        rowcnt = ld('#'+popupobj.divid+' [name="rowcnt"]').get(0).value,
        declare_type = ld("#"+popupobj.divid +" [name=declare_type]").val();
    if(declare_type == undefined){
        return false;
    }else{
        ld("#"+popupobj.divid +" [name=pack_type]").val('');
        ld("#"+popupobj.divid +" [name=cmb_span_optiontext_pack_type]").val('');
        ld("#"+popupobj.divid +" [name=piece]").val('');
        ld("#"+popupobj.divid +" [name=gross_weight]").val('');
        ld("#"+popupobj.divid +" [name=net_weight]").val('');
        ld("#"+popupobj.divid +" [name=cf_2818]").val('');
        ld("#"+popupobj.divid +" [name=cmb_span_optiontext_cf_2818]").val('');
        ld("#"+popupobj.divid +" [name=freight]").val('');
        ld("#"+popupobj.divid +" [name=subscribe]").val('');

        ld("#"+popupobj.divid +" [name=cf_3034]").val(''); //委托报关单号
        ld("#"+popupobj.divid +" [name=apply_no]").val('');//正式报关单单号
        ld("#"+popupobj.divid +" span[name=span_apply_no]").html(''); //正式报关单单号
        ld("#"+popupobj.divid +" [name=contract_no]").val(''); //合同协议号
        ld("#"+popupobj.divid +" [name=cabin_no]").val(''); //提运单号
        ld("#"+popupobj.divid +" [name=invoice_no]").val(''); //发票号


        for (var i=1;i<eval(rowcnt)+1;i++){
            ld("#"+popupobj.divid +" [name=sf191"+i+"]").val('');
            ld("#"+popupobj.divid +" [name=sf137"+i+"]").val('');
            ld("#"+popupobj.divid +" [name=sf138"+i+"]").val('');
            ld("#"+popupobj.divid +" [name=sf139"+i+"]").val('');
            ld("#"+popupobj.divid +" [name=sf141"+i+"]").val('');
            ld("#"+popupobj.divid +" [name=sf140"+i+"]").val('');
            ld("#"+popupobj.divid +" [name=sf194"+i+"]").val('');
            ld("#"+popupobj.divid +" [name=span_sf194"+i+"]").html('');
            ld("#"+popupobj.divid +" [name=sf193"+i+"]").val('');
            ld("#"+popupobj.divid +" [name=sf192"+i+"]").val('');
            ld("#"+popupobj.divid +" [name=sf143"+i+"]").val('');
            ld("#"+popupobj.divid +" [name=sf144"+i+"]").val('');
            ld("#"+popupobj.divid +" [name=sf145"+i+"]").val('');
            ld("#"+popupobj.divid +" [name=sf146"+i+"]").val('');
            ld("#"+popupobj.divid +" [name=sf147"+i+"]").val('');
            ld("#"+popupobj.divid +" [name=sf153"+i+"]").val('');
            ld("#"+popupobj.divid +" [name=sf154"+i+"]").val('');
        }

        // 小计
        ld("#"+popupobj.divid +" [name=subtotal_sf140]").html('');
        ld("#"+popupobj.divid +" [name=subtotal_sf194]").html('');
        ld("#"+popupobj.divid +" [name=subtotal_sf193]").html('');
        ld("#"+popupobj.divid +" [name=subtotal_sf154]").html('');
        ld("#"+popupobj.divid +" [name=sum_total]").html('');
        ld("#"+popupobj.divid +" [name=total]").val('');
    }


}

/**
 * 朗捷 报关单隐藏字段后 忽略隐藏字段的验证
 * @param columnname 字段名
 * @param i 所在行号
 * @returns {boolean}
 */
function ignoreVerifyTabDetailField(columnname,i) {
    var popupobj=CrmPopup.getPopupObj("last"),
    declare_type = ld("#"+popupobj.divid+" [name=declare_type]").val();
    if(declare_type =='出口' && columnname =='sf146'+i){
        return true;
    }else if(declare_type =='进口' && columnname =='sf145'+i){
        return true;
    }
    return false;
}