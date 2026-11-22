var popupobj=CrmPopup.getPopupObj("last");
popupobj.before_validate=function()
{
    //editor:gyq_161 reason:收款单保存判断回款计划信息   2019/11/26 14:16
    var popupobj=CrmPopup.getPopupObj("last");
    var trobjs = popupobj.getTrObjsByDelType("no");
     
    var nowtr;
    var acutalamount=0;//已收（实收)金额
    var amount=0;//计划金额
    var ret=true;

       ld.each(trobjs,function(){
                var i=ld(this).attr("rowindex");
        
              var amountobj=ld(this).find('[name="amount"]');
                if(trim(amountobj.val())=="")
                {
                   
                    amountobj.val(0);
                }
        
               
                if(isNaN(amountobj.val()))
                {
                    //无效的本次收款！
                    var confirm_str = arrJsPopLabel['INVALIDCOLLECTION'];
                    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                   
                    amountobj.get(0).focus();
        
                    ret=false;
                }
        })
       
       // 检查判断抵扣金额要小于等于可抵扣金额或者是否允许修改客户名称和账户
        var tmpbo=getChooseRelateLists.getInstance(popupobj).verfifybalanceamount();
       
       if(!tmpbo){
        return false;
    }
    if(!formValidate())
    {
        return false;
    }
    return ret;
}