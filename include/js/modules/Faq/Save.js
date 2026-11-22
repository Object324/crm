var popupobj=CrmPopup.getPopupObj("last");
popupobj.after_validate=function()
{
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
	/** 赛克
	* edit: chj
	* date:2020/9/9
	* reason: 判责单更新创建新的判责内容，需要在一个界面内操作,创建判责单后，返回当前工单编辑页面，并刷新当前页面
	*/
	if(version_account != undefined && version_account == 'saic'){
		popupobj.after_save=function(){
			var popupobj=CrmPopup.getPopupObj("last");
			var accountid = popupobj.record;
			var surl = 'index.php?module=Accounts&action=AccountsAjax&file=saic_api&getFaqInfo=yes&accountid='+accountid;
			//alert(surl);
			ldAjax(surl,"",function(data){
				if(data.code == 1){
					var divid = popupobj.divid;
					if('detailviewpage' == popupobj.type){
						DetailViewRelation.showpage_moduledetail(popupobj);
					}else{
						CrmPopup.findHtmlobj(divid,'faq_id').val(data.result.id);
						CrmPopup.findHtmlobj(divid,'faq_id_name').val(data.result.faq_no);
						CrmPopup.findHtmlobj(divid,'cf_3013').val(data.result.userid);
						CrmPopup.findHtmlobj(divid,'span_cf_3013').html(data.result.last_name);
						CrmPopup.findHtmlobj(divid,'cf_3015').val(data.result.modifiedtime);
						CrmPopup.findHtmlobj(divid,'cf_3017').val(data.result.question);
						CrmPopup.findHtmlobj(divid,'cf_3019').val(data.result.answer);
						CrmPopup.findHtmlobj(divid,'cf_3021').val(data.result.cf_2794);
						CrmPopup.findHtmlobj(divid,'cf_3023').val(data.result.cf_3023);	// 投诉是否合理
						CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_cf_3023').val(data.result.cf_3023);
						CrmPopup.findHtmlobj(divid,'cf_3028').val(data.result.cf_2797);
						CrmPopup.findHtmlobj(divid,'cf_2798').val(data.result.cf_2798);
						CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_cf_2798').val(data.result.cf_2798);
						CrmPopup.findHtmlobj(divid,'cf_3032').val(data.result.cf_2799);
						CrmPopup.findHtmlobj(divid,'cf_2801').val(data.result.cf_2801);
						CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_cf_2801').val(data.result.cf_2801);
						CrmPopup.findHtmlobj(divid,'cf_2802').val(data.result.cf_2802);
						CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_cf_2802').val(data.result.cf_2802);
						CrmPopup.findHtmlobj(divid,'cf_2803').val(data.result.cf_2803);
						CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_cf_2803').val(data.result.cf_2803);
						CrmPopup.findHtmlobj(divid,'cf_3042').val(data.result.cf_3042);
						CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_cf_3042').val(data.result.cf_3042);
						CrmPopup.findHtmlobj(divid,'cf_3045').val(data.result.cf_3045);
						CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_cf_3045').val(data.result.cf_3045);
						//多选框   责任方
						if(data.result.cf_2796 != ''){
							var cf_2796_array = new Array();
							var cf_2796_array = data.result.cf_2796.split(" |##| ");
							ld.each(cf_2796_array,function(index,value){
								ld("#cf_2796 option").each(function() {
									if(ld(this).val() == value){
										ld(this).attr("selected","selected");
									}
								})
							});
							ld("#cf_2796").select2({closeOnSelect: false});
						}
						//多选框   补偿方案
						if(data.result.cf_2800 != ''){
							var cf_2800_array = new Array();
							var cf_2800_array = data.result.cf_2800.split(" |##| ");
							ld.each(cf_2796_array,function(index,value){
								ld("#cf_2800 option").each(function() {
									if(ld(this).val() == value){
										ld(this).attr("selected","selected");
									}
								})
							});
							ld("#cf_2800").select2({closeOnSelect: false});
						}
					}
				}
				DelProgressObjs();
			});
		}
	}
	return true;
}