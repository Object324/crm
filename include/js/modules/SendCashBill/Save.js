var popupobj=CrmPopup.getPopupObj("last");
popupobj.before_validate=function()
{
    //editor:gyq_161 reason:付款单保存判断付款计划信息   2019/11/26 14:16
    var popupobj=CrmPopup.getPopupObj("last");
    var paymenttab = ld('#'+popupobj.divid+' table[name="proTab"]').get(0);
    var rowcount=paymenttab.rows.length;//总行数
    var nowtr;
    var acutalamount=0;//已收（实收)金额
    var amount=0;//计划金额
    var ret=true;
    var trobjs=ld(paymenttab).find("tr[detaildeleted=no]");
    
    //for(var i=1;i<rowcount-3;i++)
   // {
    ld.each(trobjs,function(){
         if(trim(ld(this).find(' [name="amount"]').get(0).value)=="")
        {
            ld(this).find(' [name="amount"]').val(0);
        }
        if(isNaN(ld(this).find(' [name="amount"]').val()))
        {
            //无效的本次收款！
            var confirm_str = arrJsPopLabel['INVALIDPAYMENT'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            ld(this).find(' [name="amount"]').focus();
            ret=false;
        }
    })
       
    //}
    
    //zkt注释 20220811 暂时不知道做什么用的
    /*if(trim(ld('#'+popupobj.divid+' [name="nosendpayment"]').get(0).value)=="")
    {
        ld('#'+popupobj.divid+' [name="nosendpayment"]').get(0).value=0;
    }*/
    if(!formValidate())
    {
        return false;
    }
    return ret;
}