//dongmao
function sum_commission(fldname){

	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var totaluser_qty = 0;	//实际到达人数
	var newuser_qty = 0;	//新人人数
	var car_amount = 0;	//车辆补贴
	var newuser_amount = 0;	//新人补贴
	var user_amount = 0;	//人员补贴
	var total = 0;	//总佣金
	var user_fee = CrmPopup.findHtmlobj(divid,"user_fee").val();	//人员补贴
	var newuser_fee = CrmPopup.findHtmlobj(divid,"newuser_fee").val();	//新人补贴
	if(user_fee == '')user_fee = 0;
	if(newuser_fee == '')newuser_fee = 0;
	if(fldname == 'totaluser_qty'){
		if(CrmPopup.findHtmlobj(divid,"totaluser_qty").val() != undefined){
			totaluser_qty = CrmPopup.findHtmlobj(divid,"totaluser_qty").val();
			if(totaluser_qty == '')totaluser_qty = 0;
		}
		user_amount = eval(totaluser_qty) * eval(user_fee);
		CrmPopup.findHtmlobj(divid,"user_amount").val(user_amount.toFixed(2));
	}

	if(fldname == 'user_amount'){
		if(CrmPopup.findHtmlobj(divid,"user_amount").val() != undefined){
			user_amount = CrmPopup.findHtmlobj(divid,"user_amount").val();
			if(user_amount == '')user_amount = 0;
		}
		totaluser_qty = eval(user_amount) / eval(user_fee);
		CrmPopup.findHtmlobj(divid,"totaluser_qty").val(totaluser_qty.toFixed(2));
	}
	
	if(fldname == 'newuser_qty'){
		if(CrmPopup.findHtmlobj(divid,"newuser_qty").val() != undefined){
			newuser_qty = CrmPopup.findHtmlobj(divid,"newuser_qty").val();
			if(newuser_qty == '')newuser_qty = 0;
		}
		newuser_amount = eval(newuser_qty) * eval(newuser_fee);
		CrmPopup.findHtmlobj(divid,"newuser_amount").val(newuser_amount.toFixed(2));
	}

	if(fldname == 'newuser_amount'){
		if(CrmPopup.findHtmlobj(divid,"newuser_amount").val() != undefined){
			newuser_amount = CrmPopup.findHtmlobj(divid,"newuser_amount").val();
			if(newuser_amount == '')newuser_amount = 0;
		}
		newuser_qty = eval(newuser_amount) / eval(newuser_fee);
		CrmPopup.findHtmlobj(divid,"newuser_qty").val(newuser_qty.toFixed(2));
	}

	if(CrmPopup.findHtmlobj(divid,"newuser_amount").val() != undefined){
		newuser_amount = CrmPopup.findHtmlobj(divid,"newuser_amount").val();
		if(newuser_amount == '')newuser_amount = 0;
	}
	if(CrmPopup.findHtmlobj(divid,"user_amount").val() != undefined){
		user_amount = CrmPopup.findHtmlobj(divid,"user_amount").val();
		if(user_amount == '')user_amount = 0;
	}
	if(CrmPopup.findHtmlobj(divid,"car_amount").val() != undefined){
		car_amount = CrmPopup.findHtmlobj(divid,"car_amount").val();
		if(car_amount == '')car_amount = 0;
	}
	
	total = eval(user_amount) + eval(newuser_amount) + eval(car_amount);
	CrmPopup.findHtmlobj(divid,"total").val(total.toFixed(2));
	CrmPopup.findHtmlobj(divid,"span_total").html(total.toFixed(2));

}