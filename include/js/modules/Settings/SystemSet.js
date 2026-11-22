function SystemSet(){
   var that=this;
}
//刷新
SystemSet.refresh = function(){
	var surl = 'index.php?module=Settings&action=SystemSet&parenttab=Settings&ReportHeader=dheader';
	ldAjax(surl,"",function(data){
		if(data.code==1){
			ld(' [name=SettingRightContent]').html(data.result.content);
		}
        DelProgressObjs();
	})
}

//切换页签
SystemSet.showSystem_parameters = function(obj,type)
{
	//20240617 gwq BUG20240613-21 在系统参数设置中，从系统参数模块切换成业务参数模块时，切换前后滚动条的位置是一样的，而不是在切换参数模块后滚动条复位到最上面
	ld('#system_div').scrollTop(0);
	ld("input[name='postroot']").val(type);
	ld('#system_div .rootinfo').eq(type-1).css('display','block').siblings().css('display','none');
	// ld("#one_li li").eq(type-1).find('a').addClass('On').parent().siblings().find('a').removeClass('On');
	ld(obj).find('a').addClass('On').parent().siblings().find('a').removeClass('On');
}

//保存
SystemSet.save = function(obj){
	var digit="0123456789";
	var alpha="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
	var deploy_48_hidden = document.getElementById('deploy_48_hidden');
	if(deploy_48_hidden != undefined && document.getElementById("48") != undefined  && deploy_48_hidden.value != document.getElementById("48").value){
		 var confirm_str = arrJsPopLabel['theparametertriggerpoint'];
		 RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		 document.getElementById('deploy_48_hidden_type').value = 1;
	 }else{
		 var confirm_str = arrJsPopLabel['CONFIRMMODIFYIT'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
	 }
	
	//点击确认
	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		 //验证输入页码数是否正确
		 var pagenum_one=document.getElementById("pagenum_one");
		 var pagenum_two=document.getElementById("pagenum_two");
		 var salesorderpreremind=document.getElementById("salesorderpreremind");
		 var ServiceContractsPreremind=document.getElementById("ServiceContractsPreremind");
		 var paymentplanemind_day=document.getElementById("paymentplanemind_day");
		 var sendpaymentemind_day=document.getElementById("sendpaymentemind_day");
		 var p=/^[1-9]\d*$/;
		 var pd=/^[0-9]\d*$/;

		 if( pagenum_one != undefined && !p.test(pagenum_one.value)){
			var confirm_str = arrJsPopLabel['INVALIDNUMBERRECORDS'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		 }
		 if(pagenum_two != undefined && !p.test(pagenum_two.value)){
			var confirm_str = arrJsPopLabel['INVALIDLISTNUMBER'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		 }
		 if(salesorderpreremind != undefined && !pd.test(salesorderpreremind.value) && salesorderpreremind.value!=''){
			var confirm_str = arrJsPopLabel['INVALIDREMINDERDAYS'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		 }
		 if(ServiceContractsPreremind !=undefined && !pd.test(ServiceContractsPreremind.value) && ServiceContractsPreremind.value !=''){
			var confirm_str = arrJsPopLabel['INVALIDREMINDERDAYS'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		 }
		 if(paymentplanemind_day !=undefined && !pd.test(paymentplanemind_day.value) && paymentplanemind_day.value !=''){
			var confirm_str = arrJsPopLabel['INVALIDREMINDERDAYS'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		 }
		 if(sendpaymentemind_day !=undefined && !pd.test(sendpaymentemind_day.value) && sendpaymentemind_day.value !=''){
			var confirm_str = arrJsPopLabel['INVALIDREMINDERDAYS'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		 }
		 if(document.getElementById("105")!=undefined&&document.getElementById("105").value!="")
		 {
			var strs=document.getElementById("105").value.split("");
			for( var i=0 ;i<strs.length;i++)
			{
				var ch=strs[i];
			
				 if(digit.indexOf(ch)<0
				&&alpha.indexOf(ch)<0)
				{
					var confirm_str = 'Api接口授权码有非法字符！';
					RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					return false;
				}
			}
		 }
		 if(document.getElementById("106")!=undefined&&document.getElementById("106").value!="")
		 {
			var strs=document.getElementById("106").value.split("");
			for( var i=0 ;i<strs.length;i++)
			{
				var ch=strs[i];
				 if(digit.indexOf(ch)<0
				&&alpha.indexOf(ch)<0)
				{
					var confirm_str = 'Api接口key有非法字符！';
					RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					return false;
				}
			}
		 }
		 var surl = 'index.php?module=Settings&action=SettingsAjax&file=SystemSet&parenttab=Settings&post=yes';
		 var max_deploytype = ld('#max_deploytype').val();
		 var allsystemcount = ld('#allsystemcount').val();
		 for(var i = 1; i <= allsystemcount; i++){
			if(ld('#'+i).val() != undefined){
				var tmpvalue = ld('#'+i).val();
				//@edit:zkt @date:2024/12/17 @reason:XUQIU20241104-08 【安全性优化】文件安全、数据暴露风险漏洞：CRMAPI 接口重新设计，KEY数据库中加密
				//空值不进行加密
				if(tmpvalue != '' && (i == 105 || i == 106)){
					//设置 API 接口授权码（只能输入字母和数字）、设置 API 接口 KEY（只能输入字母和数字） 加密值并保存数据库
					tmpvalue = encodeURIComponent(cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperationandandkey(tmpvalue,false,i));
				}
				surl += '&'+ i +'='+tmpvalue;
			}
		 }
		 surl += '&deploy_48_hidden_type='+ld('#deploy_48_hidden_type').val();
		 ldAjax(surl,"",function(ajaxdata){
			if(ajaxdata.code == 1){
				var confirm_str = arrJsPopLabel['SUCCESSFULLYSAVED'];
				// RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				MessagePopup.TipOne_success(confirm_str);
                DelProgressObjs();
				return false;
			}
		 })
	});
}
SystemSet.showSelectProductsSet = function(){
	var sev_val = ld('#70').val();
	if(sev_val == '0'){
		ld('#71').parent().parent().css('display','');
	}else{
		ld('#71').parent().parent().css('display','none');
		var nextobj = ld('#71').parent().parent().nextAll();//BUG0069920 xxy 2023-7-26 后台设置-系统参数设置-业务参数-参数前序号不连续
		nextobj.attr('onmouseover','');
		nextobj.attr('onmouseout','');
		nextobj.removeClass('lvtColData');
		nextobj.removeClass('lvtColDataBj');
		nextobj.removeClass('lvtColDataHover');
		ld.each(nextobj,function(index,itemobj){
			ld(itemobj).find("td:first").text(ld(itemobj).find("td:first").text()-1);//后续序号都减一
			if(index%2==0){ //重新添加隔行换色
				ld(itemobj).addClass('lvtColDataBj');
				ld(itemobj).attr('onmouseover','listOnMouseOver(ld(this))');
				ld(itemobj).attr('onmouseout','listOnMouseOut(ld(this),"On")');
			}else{
				ld(itemobj).addClass('lvtColData');
				ld(itemobj).attr('onmouseover','listOnMouseOver(ld(this))');
				ld(itemobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
			}
		})
	}
}
SystemSet.showSelectPaymentPlanSet = function(){ 
	var sev_val_show = ld('#53').val();
	if(sev_val_show == '1'){
		ld('#40').parent().parent().css('display','none');
	}else{
		 ld('#40').parent().parent().css('display','');
	}
}
//若审批参数“合同订单是否启用审批流程”为否，则不显示下拉选项“审批通过创建”
SystemSet.showApproveCreate = function(){
	var approval = ld('#3').val();
	if(approval=='1'){
		ld("#125 option[value='2']").hide();
	}else{
		ld("#125 option[value='2']").show();
	}
}
 /*
* editor:gyq_05
* reason:新增参数设置页取消按钮,保存或取消后仍返回到审批流程设置界面
* date  :2016 3 4
* */
SystemSet.setSystemParamsCancel = function(obj){

	var hrefmark =  ld('#showSystem_parameters2 input[name="comefromapprove"]').val();
	if(hrefmark == 1){
		location.href='index.php?module=Settings&action=MultiApproveList&parenttab=Settings&blockidsetting=3&fieldidsetting=47';
	}else{
		location.href='index.php?module=Settings&action=index&parenttab=Settings';
	}
}
 var root = ld("input[name='postroot']").val();
ld("#one_li li").eq(root-1).find('a').addClass('On').parent().siblings().find('a').removeClass('On');
SystemSet.showSelectProductsSet();
SystemSet.showSelectPaymentPlanSet();
SystemSet.showApproveCreate();
ld("#3").on("change",function(){
	SystemSet.showApproveCreate();
});
inputAddSubNumberBox.getInstance().init(ld('#lengthdecimaldigitdiv_49'),0,8,1,'limit_both_systemset');
inputAddSubNumberBox.getInstance().init(ld('#lengthdecimaldigitdiv_93'),0,8,1,'limit_both_systemset');
inputAddSubNumberBox.getInstance().init(ld('#lengthdecimaldigitdiv_122'),1,8,1,'limit_both_systemset');
inputAddSubNumberBox.getInstance().init(ld('#lengthdecimaldigitdiv_351'),0,8,1,'limit_both_systemset');