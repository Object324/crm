function TemplateprintList(){
   var that=this;
   this.ue = '';
}
//刷新
TemplateprintList.refresh = function(){
	var tabid = ld('#TemplateModule').val();
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=TemplateprintList&parenttab=Settings&printtab='+tabid+'&directmode=ajax';
	ldAjax(surl,"",function(data){
		if(data.code==1){
		  ld(" [name=templateprintlist]").html(data.result.content);
          DelProgressObjs();
        
        }
	})
}

//选择模块
TemplateprintList.templatePrintSel = function(){
	TemplateprintList.refresh();
}
//创建
TemplateprintList.create = function(printid,type=''){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=createtemplatePrint&printtabid='+ld('#TemplateModule').val()+'&mode=create';
	if(printid > 0){
		surl += '&printId='+printid;
	}
	if(!empty(type)){
		surl += '&type='+type;
	}
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,TemplateprintList.save,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
			// 设置内容最大高度
			crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
			//crmPopupobj.show(data.result.content);
			TemplateprintList.ue = UE.getEditor('CKTemplatePrint');
			TemplateprintList.ue.ready(function() {
			      var id=ld('#CKTemplatePrint').children("div:first-child").attr("id");
                   ld('#'+id).css('z-index','99999');
				crmPopupobj.center();
			},2);
			ld("#divPrint a").click(function(){
				var tag = ld(this).attr('tag');
				var tagArr = tag.split('_');
				var tagId = tagArr[1];
				for(var i=1;i<=12;i++){
					ld("#divPrint"+i).hide();
					ld("#divPrint"+i+"_1").hide();
				}
				ld("#divPrint"+tagId).show();
				ld("#divPrint"+tagId+"_1").show();
				if(tagId == 4){
					ld("#divPrint5").show();
					ld("#divPrint5_1").show();
				}
			});
			//edit: zkt BUG0063693 打印模板---新增/编辑----变量信息中，可选模块应该固定显示当前模块
			if((ld("#" + crmPopupobj.divid + " [name=TemplateprintList_moduleSel]").length)>0)
				ld("#" + crmPopupobj.divid + " [name=TemplateprintList_moduleSel]").trigger("onchange");
            //edit: xll BUG0062035 打印模板定制“信息变量”下拉框没有搜索功能
            var selectobj = ld("#" + crmPopupobj.divid + " [fieldtype=selecttype]");
            ld.each(selectobj, function(){
                var tmpobj = ld("#" + crmPopupobj.divid + " [name=" + this.getAttribute('name') + "]");
                if(tmpobj.length>0&&tmpobj!=undefined){
                    var cls_resetComboxHtmlobj=new cls_resetComboxHtml(tmpobj.attr("name"));
                    cls_resetComboxHtmlobj.setPopupObj(crmPopupobj);
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(tmpobj,120);
                }
            })
			if(data.result.templatetype && !empty(data.result.templatetype)){// 模板类型
				crmPopupobj.originalfilename = data.result.originalfilename;
				crmPopupobj.downloadpath = data.result.downloadpath;
				crmPopupobj.templatetype = data.result.templatetype;
				crmPopupobj.filejsondata = [];
				crmPopupobj.filejsondata['templatefile'] = data.result.filejsondata?data.result.filejsondata:[];
				TemplateprintList.WebUploadEvent();
			}
		}
	})
}
//保存
TemplateprintList.save = function(){
	if(trim(document.forms['TemplatePrintform'].templatename.value)=="")
    {
        //模板名称不能为空！
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['TEMPLATENAMECANOTEMPTY']);
        document.forms['TemplatePrintform'].templatename.focus();
        return false;
    }
	var templateprintname=encodeURIComponent(document.forms['TemplatePrintform'].templatename.value);
	var printtabid=document.forms['TemplatePrintform'].printtabid.value;
    var url='index.php?module=Settings&action=SettingsAjax&file=TemplatePrintSave&isDuplicate=true&printtabid='+printtabid+"&templatename="+templateprintname;
	if(document.forms['TemplatePrintform'].printid!=undefined)
	{
		url=url+"&printid="+document.forms['TemplatePrintform'].printid.value;
	}

	var popupobj = CrmPopup.getPopupObj('last');
	var templatetype = '';
	if(popupobj.templatetype && !empty(popupobj.templatetype)){// Word/Excel模板判断是否有上传模板文件
		if(empty(popupobj.filejsondata['templatefile'])){
			MessagePopup.TipOne_warning(arrJsPopLabel['UploadTemplateCannotEmpty']);
			return false;
		}
		templatetype= popupobj.templatetype;// 模板类型
	}

	ldAjax(url,"",function(data){
		if(data.code == 1){
			var data_form = new FormData(ld(".ajax_form")[0]);
			//ls 2022-08-09  打印模板定制，增加参数“是否审批通过后才允许打印
			if (data_form.get('approvedallowprint') == 'on'){
				data_form.set('approvedallowprint','yes');
			}else{
				data_form.set('approvedallowprint','no');
			}
			var urlsting = 'index.php?module=Settings&action=SettingsAjax&file=TemplatePrintSave';
			urlsting += "&templatetype="+templatetype;// 模板类型

			ld('#rptContentLoading').show();
			ld.ajax({
				type: 'POST',
				dataType: 'json',
				processData: false, // 告诉jquery不要处理数据
				contentType: false, // 告诉jquery不要设置contentType
				data: data_form,
				url: urlsting,
				success: function(json, textStatus, xhr) {
					popupobj.CancelEvent();
					ld('#rptContentLoading').hide();
					TemplateprintList.refresh();
				},
				error: function(xhr, textStatus, errorThrown) {
					//alert(2);
				}
			  })
		}else{
			 RemindsMsg("","LdPopWidth400px",'',"yes","yes",data.msg);
		}
        DelProgressObjs();
		return false;
	})
}
TemplateprintList.copy=function(printid){
    var popupobj=CrmPopup.getPopupObj('last');
    popupobj.CancelEvent();
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=createtemplatePrint&printtabid='+ld('#TemplateModule').val()+'&mode=create';
	if(printid > 0){
		surl += '&printId='+printid+"&CopyTemplate=true";
	}
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth1100px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,TemplateprintList.save,"","LdPopWidth1100px",'Settings',"",data.result.oktext,"",data.result.canceltext);  
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
			//crmPopupobj.show(data.result.content);
			TemplateprintList.ue = UE.getEditor('CKTemplatePrint');
			TemplateprintList.ue.ready(function() {
			      var id=ld('#CKTemplatePrint').children("div:first-child").attr("id");
                   ld('#'+id).css('z-index','99999');
				crmPopupobj.center();
			},2);
			ld("#divPrint a").click(function(){
				var tag = ld(this).attr('tag');
				var tagArr = tag.split('_');
				var tagId = tagArr[1];
				for(var i=1;i<=12;i++){
					ld("#divPrint"+i).hide();
					ld("#divPrint"+i+"_1").hide();
				}
				ld("#divPrint"+tagId).show();
				ld("#divPrint"+tagId+"_1").show();
				if(tagId == 4){
					ld("#divPrint5").show();
					ld("#divPrint5_1").show();
				}
			});
		}
	})
}
//查看
TemplateprintList.view = function(printid){
	var surl = "index.php?module=Settings&action=SettingsAjax&file=TemplatePrintDetail&parenttab=Settings&printId="+printid;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","1100",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjax(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,TemplateprintList.cancelTemplateprint,"","1100",'Settings',"",data.result.oktext,"",data.result.canceltext);  
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
			crmPopupobj.setScrollDivMaxHeight();
			crmPopupobj.center();

			if(data.result.templatetype && !empty(data.result.templatetype)){// 模板类型
				crmPopupobj.originalfilename = data.result.originalfilename;
				crmPopupobj.downloadpath = data.result.downloadpath;
				crmPopupobj.templatetype = data.result.templatetype;
				crmPopupobj.filejsondata = [];
				crmPopupobj.filejsondata['templatefile'] = data.result.filejsondata?data.result.filejsondata:[];
				TemplateprintList.WebUploadEvent('detail');
			}
		}
        DelProgressObjs();
	})
}
//编辑
TemplateprintList.edit = function(printid){
    var popupobj=CrmPopup.getPopupObj('last');
    if(popupobj!=undefined)
        popupobj.CancelEvent();
	TemplateprintList.create(printid);
}
//取消确认
TemplateprintList.cancelTemplateprint = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	popupobj.CancelEvent();
}
/*
删除模板

*/
TemplateprintList.deletetemplateprint = function(obj,printid)
{
    var printtabid=document.getElementById("TemplateModule").value;
	var surl = "index.php?module=Settings&action=SettingsAjax&file=TemplatePrintDelete&printtab="+printtabid+"&printid="+printid+"&Systemdefault=1";
	ldAjax(surl,"",function(data){
		if(data.code == 1){
			//确认要删除该打印模板吗？
			RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['CONFIRMWANTDELETEPRINTTEMPLATE']);
			ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
				var surl = "index.php?module=Settings&action=SettingsAjax&file=TemplatePrintDelete&printtab="+printtabid+"&printid="+printid;
				ldAjax(surl,"",function(data){
					if(data.code == 1){
						TemplateprintList.refresh();
					}
                    DelProgressObjs();
				})
			})
		}else{
			//该模板为系统预置，不允许删除！
            RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['SYSTEMTEMPLATECANOTDELETE']);
		}
        DelProgressObjs();
	})
}
/*
edit:can
date:20130814
reason:新增和编辑模板中选择模块事件
*/
TemplateprintList.moduleSel=function(obj)
{
	var popupobj=CrmPopup.getPopupObj("last");
	var printtabid = ld("#"+popupobj.divid+" [name=printtabid]").val();
	var urlstring = '&tabid='+printtabid+'&printtabid='+obj.value;
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=TemplatePrintField'+urlstring;
	ldAjax(surl,"",function(data){
		if(data.code == 1){
			ld("#"+popupobj.divid+" [name=tabField]").html(data.result.fieldsel);
		}
        //edit: xll BUG0062035 打印模板定制“信息变量”下拉框没有搜索功能
        var selectobj = ld("#" + popupobj.divid + " [name=SelectField]");
        if(selectobj.length>0&&selectobj!=undefined){
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj.attr("name"));
            cls_resetComboxHtmlobj.setPopupObj(popupobj);
            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj,120);
        }
        DelProgressObjs();
	})
}

//选择模块字段事件
var fieldSel = function(obj)
{
	var popupobj=CrmPopup.getPopupObj("last");
	ld("#"+popupobj.divid+" [name=selField]").val("[var."+obj.value+"]");
}

//打印模板中插入模板
TemplateprintList.InsertTemplate = function(obj)
{
	var popupobj=CrmPopup.getPopupObj("last");
    if(trim(ld("#"+popupobj.divid+" [name=selField]").val())==""){
		//请选择字段！
		var confirm_str = arrJsPopLabel['PLEASESELECTFIELD'];   
		MessagePopup.TipOne_warning(confirm_str);
		return false;
    }
	var selField = ld("#"+popupobj.divid+" [name=selField]").val();
	TemplateprintList.ue.ready(function() {
		TemplateprintList.ue.focus();
		TemplateprintList.ue.execCommand('inserthtml',selField);
	//	TemplateprintList.ue.setContent(selField,true);
	},2);
}

// 复制通配符/占位符
TemplateprintList.CopyPlaceholder = function(obj)
{
	var popupobj=CrmPopup.getPopupObj("last");
    if(trim(ld("#"+popupobj.divid+" [name=selField]").val())==""){
		//请选择字段！
		var confirm_str = arrJsPopLabel['PLEASESELECTFIELD'];   
		MessagePopup.TipOne_warning(confirm_str);
		return false;
    }
	var selField = ld("#"+popupobj.divid+" [name=selField]").val();
	var copy_content = document.createElement("input");
	copy_content.setAttribute("value", selField);
	document.body.appendChild(copy_content);// 将input添加到body
	copy_content.select();// 选中input的文本内容
	document.execCommand("copy");// 执行复制
	document.body.removeChild(copy_content);// 删除input标签
	MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYCOPIED'])
}

//导入excel文件到打印模板中
TemplateprintList.ImportTemplate = function(obj){
	fnvshobj('','InportExcelDiv');
    ld('#InportExcelDiv div.D_pbtn .D_pbtnok').unbind('click');//每次点击导入打印模板按钮时解除掉按钮（确定按钮）上面的所有绑定事件；
	ld('#InportExcelDiv div.D_pbtn .D_pbtnok').on('click',function(){
		if(!empty(ld('#upload_file_name').html())){
			var urlstring = 'module=Settings&action=SettingsAjax&file=UploadExcel';
			urlstring += '&file_path='+ld('#upload_file_name').attr('path')+'';
			urlstring += '&file_name='+ld('#upload_file_name').attr('file')+'';
			urlstring += '&ajax=true&setype=excel';
			RequestAjax(urlstring,function(rest){
				if('' == rest) return false;
				//ue.execCommand('insertHtml',rest);
				ue.setContent(rest);
				DelProgressObjs();
				ld('#InportExcelDiv div.D_pbtn .D_pbtncancel').click();
			});
		}
        else{
    	    var confirm_str = arrJsPopLabel['PLEASESELECTAFILE'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        }
	});
	ld('#InportExcelDiv div.E_pop_tit .E_ptitc').on('click',function(){
		ld('#InportExcelDiv div.D_pbtn .D_pbtncancel').click();
        return false;
	});
	ld('#InportExcelDiv div.D_pbtn .D_pbtncancel').on('click',function(){
		fninvshnew('InportExcelDiv');puyoungJS_DialogBox.unblock();
		// unsetUnloadExcel();
	});
}

// 下载预置模板
TemplateprintList.DownloadDefaultTemplate = function(obj)
{
	var filepath = ld(obj).attr('filepath');
	filepath = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(filepath,true,"");
	
	if(empty(filepath)){
		MessagePopup.TipOne_warning(arrJsPopLabel['PresetTemplateDeleted']);
	}else{
		var alink = document.createElement('a');
		alink.style.display = 'none'
		alink.href = filepath;
		var originalfilename = ld(obj).attr('originalfilename');
		alink.download = !empty(originalfilename)?originalfilename:'';
		document.body.appendChild(alink)
		alink.click();
		URL.revokeObjectURL(alink.href) // 释放URL 对象
		document.body.removeChild(alink)
	}
}
// 初始化上传附件
TemplateprintList.WebUploadEvent = function (type='') {
	//获取htmlobj
	var popupobj = CrmPopup.getPopupObj("last");
	popupobj.SettingsType = 'Templateprint';

	var fileuploader = CrmPopup.findHtmlobj(popupobj.divid, 'UploadFile');
	ld('#' + popupobj.divid).find(' [name=UploadFile]').html('');//把初始化加载的内容删除
	var uploadFile = new WebUploadFile();

	// var globalWebUploadType = uploadFile.uploadType();
	// globalWebUploadType = uploadFile.getScript(globalWebUploadType);
	// console.log('globalWebUploadType: ', globalWebUploadType);

	var templatetype = popupobj.templatetype;// 根据模板类型限制文件上传格式
	var allowedfiletype = '';
	if(templatetype == 'Excel'){
		allowedfiletype = 'xls,xlsx';
	}else if(templatetype == 'Word'){
		allowedfiletype = 'docx';
	}
	// getJsScript('include/js/webuploader.js', function () {
		ld('#' + popupobj.divid).find('[name=UploadFile]').powerWebUpload({ 
			fileTypeDuplicate:'yes',	//附件类型判断
			fileNameDuplicate:'yes',	//同名附件判断
			mode:'',	//当前单据 create or edit
			module:'',	//当前模块
			jsonData: popupobj.filejsondata['templatefile'],	//edit data,编辑界面显示已上传的附件
			record:'',	//单据单据id
			admin:'',//是否是管理员
			uitype:'',
			inputFileName:'templatefile',	//选择附件后赋值标签的name
			fileNumLimit:'',
			special_ins: '',
			uploderFileType: allowedfiletype,// 限制上传类型
		});

	
		ld('#' + popupobj.divid).find('.webuploader-pick').css('height','auto')
		ld('#' + popupobj.divid).find('.webuploader-pick').html('<input type="button" name="uploadTemplateBtn" class="ld-button" value="'+arrJsPopLabel['UploadPrintTemplate']+'"/>');
		if(!empty(popupobj.filejsondata['templatefile'])){
			ld('#' + popupobj.divid).find('.webuploader-pick').parent().hide();
			// 下载
			var downloadhtml = `<span class="webuploadDownloadbtn" tag="" style="padding-left:5px">
								<a filepath="`+popupobj.downloadpath+`" onclick="TemplateprintList.DownloadDefaultTemplate(this)" originalfilename="`+popupobj.originalfilename+`"><span>`+arrJsPopLabel['DOWNLOAD']+`</span></a></span>`;
			setTimeout(() => {
				if(type == 'detail')// 详情隐藏删除按钮
					ld('#' + popupobj.divid).find('.uploader-list').find('.webuploadDelbtn').hide();
				else
					TemplateprintList.deleteFileBtnEvent();
				if(ld('#' + popupobj.divid).find('.webuploadDownloadbtn').length < 1){
					ld('#' + popupobj.divid).find('.webuploadPrebtn').after(downloadhtml);
				}
			}, 200);
		}
	// });

}
// 上传成功后事件
TemplateprintList.uploadSuccessEvent = function () {
	var popupobj = CrmPopup.getPopupObj("last");
	ld('#' + popupobj.divid).find('[name=UploadFile]').find(' .webuploader-container').hide(); 

	var fileuploader = ld('#' + popupobj.divid).find('.UploadhiddenInput');
	var tmp_fieldname = 'templatefile';
	var k = ld('#' + popupobj.divid).find('.UploadhiddenInput').find('[name=templatefile-file_num]').val();
	if (fileuploader.find("[name=" + tmp_fieldname + "-" + "file_name_" + k + "]") != undefined && fileuploader.find("[name=" + tmp_fieldname + "-" + "file_name_" + k + "]").length > 0 && fileuploader.find("[name=" + tmp_fieldname + "-" + "file_name_" + k + "]").val() != undefined) {
		var filearr = {};

		filearr['newfile_name'] = fileuploader.find("[name=" + tmp_fieldname + "-" + "newfile_name_" + k + "]").val();
		filearr['file_name'] = fileuploader.find("[name=" + tmp_fieldname + "-" + "file_name_" + k + "]").val();
		filearr['file_type'] = fileuploader.find("[name=" + tmp_fieldname + "-" + "file_type_" + k + "]").val();
		filearr['file_size'] = fileuploader.find("[name=" + tmp_fieldname + "-" + "file_size_" + k + "]").val();
		filearr['file_path'] = fileuploader.find("[name=" + tmp_fieldname + "-" + "file_path_" + k + "]").val();

		filearr['cloud_path'] = fileuploader.find("[name=" + tmp_fieldname + "-" + "cloud_path" + k + "]").val();
		filearr['storage_location'] = fileuploader.find("[name=" + tmp_fieldname + "-" + "storage_location" + k + "]").val();
		filearr['upload_from'] = fileuploader.find("[name=" + tmp_fieldname + "-" + "upload_from" + k + "]").val();
		if (popupobj.filejsondata == undefined || k == 1) {
			popupobj.filejsondata = [];
			popupobj.filejsondata['templatefile'] = [];
		}
		popupobj.filejsondata['templatefile'] = filearr;

	}
	
	TemplateprintList.deleteFileBtnEvent();

}

TemplateprintList.deleteFileBtnEvent = function () {
	var popupobj = CrmPopup.getPopupObj("last");

	ld('#' + popupobj.divid).find('.uploader-list').find('.webuploadDelbtn').on('click',function () {// 删除附件点击事件
		popupobj.filejsondata['templatefile'] = [];

		ld('#' + popupobj.divid).find('.webuploader-pick').css('height','auto')
		ld('#' + popupobj.divid).find('.webuploader-pick').html('<input type="button" name="uploadTemplateBtn" class="ld-button" value="上传打印模板"/>');
		ld('#' + popupobj.divid).find('[name=UploadFile]').find(' .webuploader-container').show();
		ld('#' + popupobj.divid).find('.webuploader-pick').parent().find('div').css('width',ld('#' + popupobj.divid).find('.webuploader-pick').css('width'))
		ld('#' + popupobj.divid).find('.webuploader-pick').parent().find('div').css('height',ld('#' + popupobj.divid).find('.webuploader-pick').css('height'))
    })
}