function AccountSet(){
   var that=this;
}
//刷新
AccountSet.refresh = function(){
	var surl = "index.php?module=Settings&action=AccountSet&parenttab=Settings";
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			ld(' [name=SettingRightContent]').html(data.result.content);
		}
	})
}

//系统设置 - 接口设置 - 企业微信客户联系设置
AccountSet.save=function(){
	//序时簿“新建”功能下拉按钮选项 不能为空提示
	var form=document.forms['EditView'];
	var newdropdownoptionValue = ld('#m_newdropdownoption').select2('data');
	var strnewvalue='';
    
    ld.each(newdropdownoptionValue,function(index,info){
        if(info.text!='')
        {
            strnewvalue=info.text;
        }
    })
  
   
   
	if(form.status!=undefined && form.status.checked){
		form.isset.value=0;
		var  atleastonechoose=false;
         if(strnewvalue==''||strnewvalue==undefined){
            confirm_str = arrJsPopLabel['NEWBUTTONDROPDOWNOPTIONS']+arrJsPopLabel['CANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }

		ld("[accounttype=chkcomplete]").each(function () {
			if(ld(this).is(":checked"))
			{
				atleastonechoose=true;
				return false;
			}
		});
      
		ld("[accounttype=chknormal]").each(function () {
			if(ld(this).is(":checked"))
			{
				atleastonechoose=true;
				return false;
			}
		});
		if(!atleastonechoose)    
		{
			confirm_str = arrJsPopLabel['ATLEASTONECONDITIONSENABLED'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
		var daysbol=true;
		var expre=/^[0-9]*[1-9][0-9]*$/;
		var chk_index=1;

		ld.each(recoverymodules,function(index,tmpmodule){
			if(ld(" [name="+tmpmodule+"_completechk]").prop("checked"))
			{
				if(ld(" [name=changerule_complete_"+tmpmodule+"]").val()=='no')
				{
					//单次回收
					var textvalue=ld(" [name="+tmpmodule+"_single_completedays]").val();
				}
				else
				{
					//循环回收
					//ContactRecords_completedays
					var textvalue=ld(" [name="+tmpmodule+"_completedays]").val();
				}
				
				 if((!/^\d+$/.test(textvalue)||textvalue<1))
				{
					daysbol=false;
					return false;
				}
			}
       
			if(ld(" [name="+tmpmodule+"_normalchk]").prop("checked"))
			{
				if(ld(" [name=changerule_normal_"+tmpmodule+"]").val()=='no')
				{
					//单次回收
					//Potentials_single_normaldays
					var textvalue=ld(" [name="+tmpmodule+"_single_normaldays]").val();
				}
				else
				{
					//循环回收
					
					
					var textvalue=ld(" [name="+tmpmodule+"_normaldays]").val();
				}
				if((!/^\d+$/.test(textvalue)||textvalue<1))
				{
					daysbol=false;
					return false;
				}
			}
		 })
		if(!daysbol)
        {
            confirm_str = arrJsPopLabel['DAYSMUSTGREATERQUZERO'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
		if(form.count!=undefined && form.count.value !=''&&form.astricttype[1].checked!=true){
			if(!(expre.test(trim(form.count.value)))){
				RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['NUMONLYINT']);
				form.count.focus();
				return false;
			}
		}
		else if(form.astricttype[1].checked!=true){
			RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['NUMONLYINT']);
			form.count.focus();
			return false;
		}
        var confirm_str = arrJsPopLabel['CUSTPARAMETERSAVEDSUCCESS'];
        var popupobj=new Object();
        popupobj.divid="SettingRightContent";
        popupobj.type='';
        CrmPopup.global_listPopupObj.push(popupobj);
        
        var tmpbol=checkAdvancedFilter();
    	if(!tmpbol)
    	{
    	   CrmPopup.global_listPopupObj.pop();
    	   	return false;
    	}
     	document.forms['EditView'].account_set_advft_criteria.value=document.getElementById('advft_criteria').value;
         document.forms['EditView'].account_set_advft_criteria_groups.value=document.getElementById('advft_criteria_groups').value;
    
    }else{
        form.isset.value=1;
    }
	

	var data = new FormData(ld(".ajax_form")[0]);
	var surl = "";
	ld('#rptContentLoading').show();
	ld.ajax({
        type: 'POST',
        dataType: 'json',
        processData: false, // 告诉jquery不要处理数据
        contentType: false, // 告诉jquery不要设置contentType
        data: data,
        url: 'index.php?module=Settings&action=SettingsAjax&file=SaveAccountSet&parenttab=Settings',
        success: function(data) {
			ld('#rptContentLoading').hide();
                var confirm_str=arrJsPopLabel['SUCCESSFULLYSAVED'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        },
        error: function(xhr, textStatus, errorThrown) {
			//alert(2);
		}
      })
	return false;
}