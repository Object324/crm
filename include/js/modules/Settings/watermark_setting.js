function watermark_setting(){
	var that=this;
	this.ue = '';
 }
 //编辑  edit：yby 2022.12.15
 watermark_setting.edit = function(){
	 var surl = 'index.php?module=Settings&action=SettingsAjax&file=Editwatermark_setting';
	 var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","",""); //加载弹窗
	 crmPopupobj.prevshow();
	 ldAjaxNoProgress(surl,"",function(data){
		 //data是对象，code是data的属性
		 if(data.code==1){ 
			 crmPopupobj.setParams(data.result.title,watermark_setting.save,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");  //弹窗的内容
			 crmPopupobj.show(data.result.content);//弹窗的内容
			 // 设置内容最大高度
			 crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
			 watermark_setting.watermark_content_select(); //调用水印内容说明的方法
		 }
	 })
 }
 //水印的内容  edit：yby 2022.12.15
 watermark_setting.watermark_content_select=function(obj){
	var popupobj=CrmPopup.getPopupObj("last");
	var watermark_content = ld(obj).val();
	var watermark_content_hint = ld(obj).find('option:selected').attr('hint');
	if(empty(obj)){
		watermark_content = ld("#"+popupobj.divid+" #watermark_content_select").val();
		watermark_content_hint = ld("#"+popupobj.divid+" #watermark_content_select").find('option:selected').attr('hint');
	}
	ld("#"+popupobj.divid+" #watermark_content_input").css('display','none');

	ld("#"+popupobj.divid+" #watermark_remark").text('('+watermark_content_hint+')');

	if(watermark_content=='custom_content'){
		ld("#"+popupobj.divid+" #watermark_content_input").css('display',''); 
	} 	
 }
 
 //保存水印内容  edit：yby 2022.12.15
 watermark_setting.save = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var presence = ld("#"+popupobj.divid+" [name=open_watermark_setting]").prop("checked");
	if (presence)
		presence = 'yes';
	else
		presence = 'no';

	var watermark_display = ld("#"+popupobj.divid+" #watermark_content_select").val();
	var custom_content = ld("#"+popupobj.divid+" #watermark_content_input").val();
	var url = 'index.php?module=Settings&action=SettingsAjax&file=watermark_setting_save&presence='+ presence+"&watermark_display="+watermark_display+"&custom_content="+encodeURIComponent (custom_content);
	if(ld.trim(custom_content)=='' && watermark_display =='custom_content' && presence=='yes'){
		var custom_watermark_notempty = arrJsPopLabel['CUSTOMWATERMARKNOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","",custom_watermark_notempty);
		return false;
	}
	
	//ldAjax 点击的时候有进程需要加载
	ldAjax(url,'',function(data){
	popupobj.CancelEvent();//点击保存后退出弹窗
		// ljj 20240131 BUG20240130-68 kfbcrm-水印设置-修改水印显示内容后界面不会自动刷新
		ld('[id^=mask_div]').remove();
		if (!empty(data.result.watermark_txt)){
			getJsScript('include/js/shuiyin.js', function () {
				watermark({"watermark_txt": data.result.watermark_txt});
			});
		}
		//刷新列表
		var surl = "index.php?module=Settings&action=watermark_setting&parenttab=Settings&ReportHeader=dheader";
		// ldAjaxNoProgress 点击后不用加载
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				ld(' [name=SettingRightContent]').html(data.result.content);//加载 name=SettingRightContent 右边的整个内容
			}
		})
		DelProgressObjs();
	});
	
 }
 
 
 
 