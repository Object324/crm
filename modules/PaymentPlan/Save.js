 var popupobj=CrmPopup.getPopupObj("last");
popupobj.after_duplicate=function()
{
    
    var popupobj=CrmPopup.getPopupObj("last");
    
     var tex=CrmPopup.getHtmlobjval(popupobj.divid,"paymentstatus")
  
      if(trim(tex).indexOf('已收')!=-1)
      {

         if(confirm(arrJsPopLabel['ifthestatehasebeenselectedaspartofthe'])==false)
         {
            lingdangJS_DialogBox.unblock();
            return false;
         }
      }
	//回款计划类型为计划回款日期时，如果计划回款日期为空，则不能保存
	var plandate = CrmPopup.findHtmlobj(popupobj.divid,"plandate").val();
	if(empty(plandate)){
		var fieldlabel = CrmPopup.findHtmlobj(popupobj.divid,"plandate").attr('fieldlabel');
		var paymenttype = CrmPopup.findHtmlobj(popupobj.divid,"paymenttype").val();
		if(paymenttype == '计划回款日期'){
			var confirm_str = fieldlabel+arrJsPopLabel['CANOTEMPTY'];
    		RemindsMsg("","LdPopWidth400px","","","",confirm_str);
			return false;
		}
	}
     return true;
}
popupobj.showafter=function()
{
	var popupobj=CrmPopup.getPopupObj("last");
	var divid = popupobj.divid;
	if(CrmPopup.getHtmlobjval(divid,"selectsource") != undefined){
		var selectsource=CrmPopup.getHtmlobjval(divid,"selectsource");
		if(selectsource == 'Invoice'){
			if(CrmPopup.isExistsObj(divid,'cmb_a_paymenttype'))
			{
				CrmPopup.findHtmlobj(divid,'cmb_a_paymenttype').removeAttr("onclick");
				CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_paymenttype').html('计划回款日期');
				CrmPopup.findHtmlobj(divid,'cmb_a_paymenttype').find('div').hide();
			}
		}
	}
	
}