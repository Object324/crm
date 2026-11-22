//系统设置 - 模板设置 - 文档模板定制
function Createdocumenttemplate(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=Createdocumenttemplate';
	var popupobj=CrmPopup.getPopupObj("last");
	// 0043581: （https://61mis.com/kfbcrm [^]）客户问题（邹钰明），系统设置->模板设置->文档模板定制：新增/编辑界面，【内容】字段富文本框中【鼠标右击】，弹出的菜单栏被遮挡了，无法使用（需要补丁）
	//由于无法给设置编辑器的z-index设大一些，所以临时降低新增弹窗的z-index
	var tmp_zIndex = CrmPopup.zIndex;
	CrmPopup.zIndex = 1100;
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,savedocumenttemplate,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.show(data.result.content);
			// 设置内容最大高度
			crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
			var tmpokeditor= UE.getEditor('documentbody');//实例化编辑器
			tmpokeditor.ready(function() {
				var id=ld('#documentbody').children("div:first-child").attr("id");
				ld('#'+id).css('z-index','99999');
				crmPopupobj.center();
			},2);
			// CrmPopup.zIndex = tmp_zIndex;
			// ld("#edui_fixedlayer").css('z-index',CrmPopup.zIndex++);
		}
        else if(data.code==-1){
            crmPopupobj.CancelEvent();
            //zkt 20220512 51731【亿海蓝】点击系统设置-文档模板定制。点击新增一直转圈。
            var modulelabel = '';
            if(document.getElementById('documentsmodulelabel')!=undefined){
                modulelabel = document.getElementById('documentsmodulelabel').value;
            }
            
            var confirm_str = modulelabel+data.msg;
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
	})
}
//系统设置 - 模板设置 - 文档模板定制 - 编辑
function editdocumenttemplate(templateid){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=editeDocumentstemplate&templateid='+templateid;
	var popupobj=CrmPopup.getPopupObj("last");
	CrmPopup.zIndex = 1100;
	var tmp_zIndex = CrmPopup.zIndex;
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,savedocumenttemplate,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);  
			crmPopupobj.show(data.result.content);
			var tmpokeditor= UE.getEditor('documentbody',{'zIndex':2000});//实例化编辑器
			CrmPopup.zIndex = tmp_zIndex;
			// 设置内容最大高度
			crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
		}
	})
}
function closedocumenttemplate(){
	var popupobj=CrmPopup.getPopupObj("last");
	popupobj.CancelEvent();
}
//系统设置 - 模板设置 - 文档模板定制 - 详情
function detaildocumenttemplate(templateid){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=detailviewemailtemplate&templateid='+templateid;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,closedocumenttemplate,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);  
			crmPopupobj.show(data.result.content);
		}
	})
}
//系统设置 - 模板设置 - 文档模板定制 - 保存
function savedocumenttemplate(){

	var surl = 'index.php?module=Settings&action=SettingsAjax&file=savedocumenttemplate';
	var popupobj=CrmPopup.getPopupObj("last");
	var templatename = ld("#"+popupobj.divid+" [name=templatename]").val();
	if(empty(templatename)){
        var confirm_str = arrJsPopLabel['TEMPLATENAMECANOTEMPTY'];
        // RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		MessagePopup.TipOne_warning(confirm_str);
        return false;
    }
	var templateid = ld("#"+popupobj.divid+" [name=templateid]").val();	//知识模板id
	var _description = ld("#"+popupobj.divid+" [name=description]").val();
	var check_url = surl + "&templateid="+templateid+"&templatename="+templatename+"&SaveCheck=yes";
	//alert(check_url);
	ldAjaxNoProgress(check_url,"",function(data){
		if(data.code==1){
			var documentbody =  ld("#"+popupobj.divid+" [name=documentbody]").val();
			ld.post("index.php",{module : 'Settings' ,action:"SettingsAjax",file:"savedocumenttemplate",'templatename':templatename,'templateid':templateid,'description':_description,'body':documentbody},function(response) {
				popupobj.CancelEvent();
				var confirm_str = arrJsPopLabel['SUCCESSFULLYSAVED'];
				// RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				MessagePopup.TipOne_success(confirm_str)
				 //确定按钮
				ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
					var surl = 'index.php?module=Settings&action=showDocTemplateindex&ReportHeader=dheader';
					ldAjaxNoProgress(surl,"",function(data){
						if(data.code==1){
							ld(' [name=SettingRightContent]').html(data.result.content);
						}
					})
				});
			});
		}else{
			// RemindsMsg("","LdPopWidth400px","","yes","yes",data.result.log);
			MessagePopup.TipOne_warning(data.result.log)
            return false;
		}
	})
}

//系统设置 - 模板设置 - 文档模板定制 - 删除
function deletedocumenttemplate(templateid){
	var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    //确定按钮
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		var surl = 'index.php?module=Documents&action=DocumentsAjax&file=deleteemailtemplate&templateid='+templateid;
		ldAjax(surl,"",function(data){
			if(data.code==1){
				var surl = 'index.php?module=Settings&action=showDocTemplateindex&ReportHeader=dheader';
				ldAjaxNoProgress(surl,"",function(data){
					if(data.code==1){
						ld(' [name=SettingRightContent]').html(data.result.content);
					}
				})
			}
            DelProgressObjs();
		})
    });
}