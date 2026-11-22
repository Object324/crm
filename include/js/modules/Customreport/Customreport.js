/*********************************************************************************
**{*修改编码格式:统一编码：UTF-8*} 
* The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.   
*
 ********************************************************************************/
ld(function () {
	Fun_report = {};
	Fun_report.Folder = function(){
		ld("#report-add-folder").on('click',function(){
			fnvshobj(this,'folder_text');//文件夹显示
		});
		ld("#report-hide-folder,#report-href-folder").on('click',function(){
			fninvshnew('folder_text');//文件夹隐藏
		});
		ld('#report-save-folder').on('click',function(){
			var folder_name = ld('#folder_name').val();
			if(folder_name == ''){
				var confirm_str = arrJsPopLabel['FOLDERNAMECANNOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				ld('#folder_name').focus();
				return false;
                //20160408Liver bug21439【定制报表】：新建文件夹，文件夹名输入50个字保存，弹出层提示“文件夹名太长，请重试！”，字数限制为50
			}else if(folder_name.length > 50){
				var confirm_str = arrJsPopLabel['FOLDERNAMETOOLONG'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				ld('#folder_name').focus();
				return false;
			}else{
				var url = 'module=Customreport&action=CustomreportAjax&file=ReportFolder&type=addFolder&folder_name='+encodeURIComponent(folder_name)+'&ajax=true';
				//弹出框提醒
				RequestAjax(url,function(rest){
					if(rest == 'error'){
						var confirm_str = arrJsPopLabel['FOLDERNAMEALREADYEXISTS'];
						RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
						DelProgressObjs();
						ld('#folder_name').focus();
						return false;
					}else{
						fninvshnew('folder_text');
						DelProgressObjs();
						location.reload();
					}
				});
			}
		});
		ld('#report-sort-folder').on('click',function(){
			var url = 'module=Customreport&action=CustomreportAjax&file=SortFolder&ajax=true';
			RequestAjax(url,function(rest){
				ld('#folder_sortview_content_div').html(rest);
				fnvshobj(this,'folder_sortview');
				report_sort_btn();
				DelProgressObjs();
			});
		});
        //显示隐藏的文件夹
		ld('#report-show-folder').on('click',function(){
			var url = 'module=Customreport&action=CustomreportAjax&file=showFolder&ajax=true';
			RequestAjax(url,function(rest){
				ld('#show_foldert_content_div').html(rest);
				fnvshobj(this,'show_folder');
				report_show_btn();
				DelProgressObjs();
			});
		});
	}
	Fun_report.run = function () {
		this.Folder();//添加、排序文件夹
	};
	Fun_report.run();
});
//文件夹排序事件绑定
var report_sort_btn = function(){
	ld('#report-hide-sortfolder,#report-href-sortfolder').on('click',function(){
		fninvshnew('folder_sortview');//文件夹排序隐藏
	});
	ld('#report-save-sortfolder').on('click',function(){
		var selectedFieldStr = "";
		if(ld('#select_folder')!=undefined){
			var selectedColumnsObj=document.getElementById('select_folder');
			for (i=0;i<selectedColumnsObj.options.length;i++){
				selectedFieldStr += selectedColumnsObj.options[i].value + ";";
			}
		}
		if(selectedFieldStr != ''){
			var url = 'module=Customreport&action=CustomreportAjax&file=ReportFolder&type=sortFolder&folderid_str='+encodeURIComponent(selectedFieldStr)+'&ajax=true';
			RequestAjax(url,function(rest){
				fninvshnew('folder_sortview');
				RefreshList('');
				DelProgressObjs();
			});
		}
	});
}

//显示隐藏文件夹操作
var report_show_btn = function(){ 
   	ld('#report-hide-showfolder,#report-href-showfolder').on('click',function(){
		fninvshnew('show_folder');//窗口关闭
	});
	ld('#report-save-showfolder').on('click',function(){
		var selected_showFolder = [];
		if(ld('#select_folder')!=undefined){
			
             ld('#select_folder option:selected').each(function(){
                 selected_showFolder.push(ld(this).val()); 
             });
		}
		if(selected_showFolder != ''){
			var url = 'module=Customreport&action=CustomreportAjax&file=ReportFolder&type=showFolder&folderid_showFolder='+encodeURIComponent(selected_showFolder)+'&ajax=true';
			RequestAjax(url,function(rest){
				fninvshnew('show_folder');
				RefreshList('');
				DelProgressObjs();
			});
		}
	});
}
function fun_report_floder(){
	fun_report_floder.cur_obj=null;
}

fun_report_floder.getInstance=function(folder_id){
    if(fun_report_floder.cur_obj==null){
        fun_report_floder.cur_obj=new fun_report_floder();
    }
	fun_report_floder.folder_id = folder_id;
    return fun_report_floder.cur_obj;
}

//建立报表
//editor:gyq_14 reason:分配功能统一
fun_report_floder.prototype.createReport = function(){
	var url = 'module=Customreport&action=CustomreportAjax&file=CreateReport&folder_id='+fun_report_floder.folder_id+'&ajax=true';
	RequestAjax(url,function(rest){
		ld('#createreport_content_div').html(rest);

		getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
			ScopePopup_Details.getInstance().allocateTemplate('',-5,-5,'','','createCustomreport');
			fnvshobj(this,'createreport_div');
			reportBind();//建立报表绑定事件
		});
		DelProgressObjs();
	});
}

//报表排序
fun_report_floder.prototype.sortReport = function(){
	fnvshobj(this,'report_sortview_'+fun_report_floder.folder_id);
	reportSortBind(fun_report_floder.folder_id);//报表排序绑定事件
}

//显示隐藏的报表
fun_report_floder.prototype.showReport = function(){  
        var url = 'module=Customreport&action=CustomreportAjax&file=showReport&folder_id='+fun_report_floder.folder_id+'&ajax=true';
        RequestAjax(url,function(rest){
            ld('#show_report_content_div').html(rest);
            fnvshobj(this,'show_report');
            reportShowBind(fun_report_floder.folder_id,url);
			DelProgressObjs();
        });
}

//隐藏文件夹
//Liver 2016/09/08
fun_report_floder.prototype.hideFolder = function(){
    var url = 'module=Customreport&action=CustomreportAjax&file=ReportFolder&type=hideFolder&folder_id='+fun_report_floder.folder_id+'&ajax=true';
    reporthideFolderBind(fun_report_floder.folder_id,url);//隐藏文件夹绑定事件
}

//重命名文件夹
fun_report_floder.prototype.renameFolder = function(){
	fnvshobj(this,'rename_folder_text_'+fun_report_floder.folder_id);
	renameFolderBind(fun_report_floder.folder_id);//重命名文件夹绑定事件
}

//删除文件夹
fun_report_floder.prototype.deleteFolder = function(){
	//获取文件夹下是否存在报表
	var report_folder_num = ld('#report-folder-num-'+fun_report_floder.folder_id).val();
	if(report_folder_num >= 1){
		var confirm_str = arrJsPopLabel['THEFOLDERLISTEXISTSNOTALLOWEDTODELETE'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}else{
		if(confirm(arrJsPopLabel['CONFIRMWANTDELETEFOLDER']+'?')){
			var url = 'module=Customreport&action=CustomreportAjax&file=ReportFolder&type=deleteFolder&folder_id='+fun_report_floder.folder_id+'&ajax=true';
			RequestAjax(url,function(rest){
				if(rest == 'error'){
					var confirm_str = arrJsPopLabel['ERRORDELETINGFOLDER'];
					DelProgressObjs();
					RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					return false;
				}else{
					if(ld('#report-list-div-'+fun_report_floder.folder_id) != undefined){
						ld('#report-list-div-'+fun_report_floder.folder_id).remove();
					}
					DelProgressObjs();
				}
			});
		}
	}
}
//重命名文件夹 - 绑定事件
var renameFolderBind = function(folder_id){
	//取消、关闭
	ld('#rename-report-hide-folder,#rename-report-href-folder').on('click',function(){
		fninvshnew('rename_folder_text_'+folder_id);
	});
	//保存
	ld('#rename-report-save-folder-'+folder_id).on('click',function(){
		if(ld('#folder_name_'+folder_id) != undefined){
			var folder_name = ld('#folder_name_'+folder_id).val();
			if(folder_name == ''){
				var confirm_str = arrJsPopLabel['FOLDERNAMECANNOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				ld('#folder_name_'+folder_id).focus();
				return false;
			}
            /**
            *Liver 2016/05/09 0022193: 报表>定制报表：点击【重命名文件夹】时，录入字数超过50时，没有提示消息的问题
            */
            if(folder_name.length>50){
				var confirm_str = arrJsPopLabel['FOLDERNAMETOOLONG'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				ld('#folder_name_').focus();
				return false;
            }
			var url = 'module=Customreport&action=CustomreportAjax&file=ReportFolder&type=renameFolder&folder_id='+folder_id+'&folder_name='+encodeURIComponent(folder_name)+'&ajax=true';
			RequestAjax(url,function(rest){
				if(rest == 'error'){
					var confirm_str = arrJsPopLabel['FOLDERNAMEALREADYEXISTS'];
					DelProgressObjs();
					RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					ld('#folder_name').focus();
					return false;
				}else{
					fninvshnew('rename_folder_text_'+folder_id);
					RefreshList(folder_id);
					DelProgressObjs();
				}
			});	
		}
	});
	
}
//隐藏报表文件夹
var reporthideFolderBind = function(folder_id,url){
    RequestAjax(url,function(rest){
        if(rest == 'error'){
        	var confirm_str = '隐藏失败';
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
        RefreshList(folder_id);
		DelProgressObjs();
    });
}
//报表排序 - 绑定事件
var reportSortBind = function(folder_id){
	//取消、关闭
	ld('#report-hide-sort,#report-href-sort').on('click',function(){
		fninvshnew('report_sortview_'+folder_id);
	});
	//保存
	ld('#report-save-sort-'+folder_id).on('click',function(){
		var selectedReportStr = "";
		if(ld('select_report_'+folder_id)!=undefined){
			var selectedColumnsObj=document.getElementById('select_report_'+folder_id);
			for (i=0;i<selectedColumnsObj.options.length;i++){
				selectedReportStr += selectedColumnsObj.options[i].value + ";";
			}
		}
		if(selectedReportStr != ''){
			var url = 'module=Customreport&action=CustomreportAjax&file=ReportFolder&type=sortReport&reportid_str='+encodeURIComponent(selectedReportStr)+'&ajax=true';
			RequestAjax(url,function(rest){
				fninvshnew('report_sortview_'+folder_id);
				RefreshList(folder_id);
				DelProgressObjs();
			});
		}
	});
}


//显示隐藏的报表 - 绑定事件
var reportShowBind = function(folder_id,url){
	//取消、关闭
	ld('#report-href-showReport,#report-hide-showReport').on('click',function(){
		fninvshnew('show_report');
	}); 
	//保存
	ld('#report-save-showReport').on('click',function(){
        var selectedReportStr = [];      
        if(ld('#select_Report')!=undefined){
            
            ld('#select_Report option:selected').each(function(){
                selectedReportStr.push(ld(this).val()); 
            });
        }
		if(selectedReportStr != ''){
			var url = 'module=Customreport&action=CustomreportAjax&file=ReportFolder&type=showReport&reportid_str='+encodeURIComponent(selectedReportStr)+'&ajax=true';
			RequestAjax(url,function(rest){
				fninvshnew('show_report');
				RefreshList(folder_id);
				DelProgressObjs();
			});
		}else{
			var confirm_str = '请选择需要显示的报表！';
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
		}
	});
}


//建立报表 - 绑定事件
var reportBind = function(){
	//取消、关闭
	ld('#report-save-hide-btn,#report-save-href-btn').on('click',function(){
		fninvshnew('createreport_div');
		return false;
	});
   
    ld("#report_type").unbind("change").bind("change",function(){
        //报表类型
        if(ld(this).val()=='template')
        {
            ld("#tr_DataBaseLink").css("display","");
            ld("#tr_templatereport").css("display","");
            ld("#tr_Reportfile").css("display","none");
            ld("#tr_Reportserveraddress").css("display","none");
        }
        else if(ld(this).val()=='finereport')
        {
            ld("#tr_DataBaseLink").css("display","none");
            ld("#tr_templatereport").css("display","none");
            ld("#tr_Reportfile").css("display","");
            ld("#tr_Reportserveraddress").css("display","");
        }
        else
        {
            ld("#tr_templatereport").css("display","");
            ld("#tr_DataBaseLink").css("display","none");
            ld("#tr_Reportfile").css("display","none");
            ld("#tr_Reportserveraddress").css("display","none");
        }
    })
	//模板类型
	ld('#report_type').on('change',function(){
		var report_type = ld('#report_type').val();
		if(report_type == 'template'){
			ld('#template_div').show();
			ld('#url_div').hide();
		}else if(report_type == 'url'){
			ld('#template_div').hide();
			ld('#url_div').show();
			ld('#report_url').focus();
		}
	});
	//保存
    // editor:gyq_14
	ld('#report-save-btn').on('click',function(){
		repodrtsave();
	});

	var repodrtsave = function (choice){
		var report_name = ld('#report_name').val();//报表名称
		var report_type = ld('#report_type').val();//报表类型

		//var radioUser = ld('input:radio[name="radioUser"]:checked').val(); //适用范围
		var radioUser = ld('#allocate_divconten input[name="radiotype"]:checked ').val();
		ScopePopup_Details.getInstance().saveAction_before();
		var folder_id = ld('#folder_id').val();//文件夹id 
		//报表名称
		if(report_name == ''){
			var confirm_str = ld('#report_name').attr("tag") + arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			ld('#report_name').focus();
			return false;
		}
		//报表名称长度
		if(report_name.length >= 100){
			var confirm_str = ld('#report_name').attr("tag") + arrJsPopLabel['CANNOTEXCEED'] + '100'+arrJsPopLabel['AWORD'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			ld('#report_name').focus();
			return false;
		}
		//报表类型
		if(report_type == ''){
			var confirm_str = ld('#report_type').attr("tag") + arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
		//如果报表类型为链接地址，则判断判断地址是否为空
		if(report_type == 'url'){
			var report_url = ld('#report_url').val();
			if(report_url == ''){
				var confirm_str = ld('#report_url').attr("tag")+arrJsPopLabel['CANOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				ld('#report_url').focus();
				return false;
			}
		}
		//如果报表类型为帆软报表，则判断判断报表文件、报表服务器地址是否为空
		if(report_type == 'finereport'){
			var reportfile = ld('#reportfile').val();
			var reportserveraddress = ld('#reportserveraddress').val();
			if(reportfile == ''){
				var confirm_str = ld('#reportfile').attr("tag")+arrJsPopLabel['CANOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				ld('#reportfile').focus();
				return false;
			}
			if(reportserveraddress == ''){
				var confirm_str = ld('#reportserveraddress').attr("tag")+arrJsPopLabel['CANOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				ld('#reportserveraddress').focus();
				return false;
			}
		}
		if(!ScopePopup_Details.getInstance().validate(null)) {
			return false;
		}

		var data = new FormData(ld(".ajax_form")[0]);
		var surl = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=CreateReport&report_save=report_save&choice=' + choice;

		var frommodule = ld('#frommodule').val();//报表类型
		surl += '&frommodule='+frommodule;
		if(frommodule=='ReportAnalysis'){
			var analysisfolder_id = ld('#analysisfolder_id').val();//报表类型
			if(analysisfolder_id == ''){
				var confirm_str = ld('#analysisfolder_id').attr("tag") + arrJsPopLabel['CANOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			}
		}
		ld('#rptContentLoading').show();
		ld.ajax({
			type: 'POST',
			dataType: 'json',
			processData: false, // 告诉jquery不要处理数据
			contentType: false, // 告诉jquery不要设置contentType
			data: data,
			url: surl,
			success: function(json, textStatus, xhr) {
				ld('#rptContentLoading').hide();
				if(json.code == 1){
					fninvshnew('createreport_div');
					if(frommodule=='ReportAnalysis'){
						ReportAnalysisObj.getReportList(0,'init');
					}else {
						RefreshList(folder_id);
					}
				} else if (json.code == -2) {
//提示框样式
					json.msg += arrJsPopLabel['CREATREPORTTEXT1']
						+ '<div class="ld-msgDlg-bottom-Boxtext linefeed" style="font-size:13px;padding-left: 0px; color: rgb(153,153,153);line-height: 16px"> '
						+ arrJsPopLabel['CREATREPORTTEXT2']
						+ '</div>';
					RemindsMsg("", "LdPopWidth400px", "", arrJsPopLabel['CONTINUE'], arrJsPopLabel['SAVE'], json.msg);
					var tempopupobj = CrmPopup.getPopupObj('last');
//当数据库或者文件夹内已有报表源文件名称时，根据不同的选择传入不同的参数
					ld('#' + tempopupobj.divid + "_btnok").on('click', function () {
						repodrtsave('CONTINUE');
					});
					ld('#' + tempopupobj.divid + "_btncancel").on('click', function () {
						repodrtsave('SAVE');
					});
				} else {
					RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", json.msg);
					//fninvshnew('createreport_div');
				}

			},
			error: function(xhr, textStatus, errorThrown) {
				//alert(2);
			}
		})
		return false;
	}
}
//删除报表提示
var deleteReport = function(report_id,report_type,folder_id){
	var is_deletereport = 0;
	if(report_type == 'template'){
		var confirm_str = arrJsPopLabel['THEREISAREPORTTEMPLATETHEREPORT'];
	}else{
		var confirm_str = arrJsPopLabel['THEREISAREPORTTEMPLATETHEREPORT'];
	}
	RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
	//点击确认
	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		confirm_deleteReport(report_id,report_type,folder_id);//删除报表
	});
}

//确认后，删除报表
function confirm_deleteReport(report_id,report_type,folder_id){
	var url = 'module=Customreport&action=CustomreportAjax&file=ReportFolder&type=deleteReport&report_id='+report_id+'&ajax=true';
	RequestAjax(url,function(rest){
		if(rest == 'error'){
			var confirm_str = arrJsPopLabel['ERRORDELETEINGSTATEMENTS'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			DelProgressObjs();
			return false;
		}
		RefreshList(folder_id);
		DelProgressObjs();
	});
}

//隐藏报表
var hideReport = function(report_id,report_type,folder_id){
    var url = 'module=Customreport&action=CustomreportAjax&file=ReportFolder&type=hideReport&report_id='+report_id+'&ajax=true';
    RequestAjax(url,function(rest){
        if(rest == 'error'){
            var confirm_str = arrJsPopLabel['隐藏失败'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			DelProgressObjs();
            return false;
        }
        RefreshList(folder_id);
		DelProgressObjs();
    });
}


//编辑报表
var editReport = function(report_id){
	var url = 'module=Customreport&action=CustomreportAjax&file=EditReport&report_id='+report_id+'&ajax=true';
	RequestAjax(url,function(rest){
		ld('#editreport_content_div').html(rest);
		fnvshobj(this,'editreport_div');
		reportEditBind();//编辑报表绑定事件
		DelProgressObjs();
	});
}
//编辑报表 - 绑定事件
var reportEditBind = function(){
	var pageto_module = getSearchString('pageto_module',location.href);
	ld('#report-edit-hide-btn,#report-edit-href-btn').on('click',function(){
		fninvshnew('editreport_div');
	});
	ld('#report-edit-save-btn').on('click',function(){
		var report_id = ld('#report_id').val();
		var report_name = ld('#edit_report_name').val();
		var report_describe = ld('#edit_report_describe').val();
		var select_folder = ld('#edit_select_folder').val();
		var edit_folder_id = ld('#edit_folder_id').val();
		var setlinkmodule = ld('#setlinkmodule').is(':checked');
		setlinkmodule = setlinkmodule==true?'on':'';
		var edit_report_url = '';
		var frommodule = ld('#frommodule').val();//报表类型
		if(frommodule=='ReportAnalysis'){
			var analysisfolder_id = ld('#analysisfolder_id').val();//报表类型
			if(analysisfolder_id == ''){
				var confirm_str = ld('#analysisfolder_id').attr("tag") + arrJsPopLabel['CANOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			}
		}
		//报表名称
		if(report_name == ''){
			var confirm_str = ld('#edit_report_name').attr("tag") + arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			ld('#edit_report_name').focus();
			return false;
		}
		if(ld('#edit_report_url') != undefined && ld('#edit_report_url').val() != undefined){
			edit_report_url = encodeURIComponent(ld('#edit_report_url').val());
			if(edit_report_url == ''){
				var confirm_str = ld('#edit_report_url').attr("tag") + arrJsPopLabel['CANOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				ld('#edit_report_url').focus();
				return false;
			}
		}
        if(ld('#reportserveraddress') != undefined && ld('#reportserveraddress').val() != undefined){
			edit_report_url = encodeURIComponent(ld('#reportserveraddress').val());
			if(edit_report_url == ''){
				var confirm_str = ld('#reportserveraddress').attr("tag") + arrJsPopLabel['CANOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				ld('#reportserveraddress').focus();
				return false;
			}
		}
        var reportfile = '';
        if(ld('#reportfile') != undefined && ld('#reportfile').val() != undefined){
			reportfile = encodeURIComponent(ld('#reportfile').val());
			if(reportfile == ''){
				var confirm_str = ld('#reportfile').attr("tag") + arrJsPopLabel['CANOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				ld('#reportfile').focus();
				return false;
			}
		}
        
        var databaselinktype= '';
        if(ld("#databaselinktype").val()!=undefined)
        {
            databaselinktype = ld("#databaselinktype").val();
        }
		var url = 'module='+pageto_module+'&action='+pageto_module+'Ajax&file=EditReport&report_id='+report_id+'&report_name='+encodeURIComponent(report_name)+'&report_describe='+encodeURIComponent(report_describe)+'&select_folder='+select_folder+'&edit_report_url='+edit_report_url+'&ajax=true&report_save=yes';
        url+="&databaselinktype="+databaselinktype+'&setlinkmodule='+setlinkmodule+'&reportfile='+reportfile+'&analysisfolder_id='+analysisfolder_id+'&frommodule='+frommodule;
		RequestAjax(url,function(rest){
			fninvshnew('editreport_div');
			var hidden_report_id = ld('#hidden_select_folder').val();
			if(frommodule=='ReportAnalysis'||pageto_module=='ReportAnalysis'){
				ReportAnalysisObj.getReportList(0,'init');
			}else{
				if(report_id != hidden_report_id){
					RefreshList('');
				}else{
					RefreshList(edit_folder_id);
					RefreshList(select_folder);
				}
			}
			DelProgressObjs();
		});
	});
}
/* editor:gyq_14 date:20160718 */
var ReportAllocateUser = function(report_id,allocatetype,folder_id){
	ReportAllocateUser.cur_radiovalue=allocatetype;
	var url = 'module=Customreport&action=CustomreportAjax&file=AllocateReport&report_id='+report_id+'&ajax=true';
	RequestAjax(url,function(rest){
		reportAllocateBind(report_id,rest,allocatetype,folder_id);//报表分配事件绑定
		DelProgressObjs();
	});
}

var reportAllocateBind = function(report_id,allocateids,allocatetype,folder_id){

	getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){

		ScopePopup_Details.getInstance().allocateTemplate(this,'Settings',report_id,allocateids,allocatetype,'Customreport',folder_id);
	});
}
//分配：选择所有用户
ReportAllocateUser.setalluser=function(stype){
	ReportAllocateUser.report_stype = stype;
	ReportAllocateUser.cur_radiovalue=0; 
	ld("#"+stype+"_selectuser").val('-1');
}
//分配：选择部门
ReportAllocateUser.report_showgroups = function(stype){
	obj_init_type="yes";
	ReportAllocateUser.report_stype = stype;
	var obj=new Object();
    obj.value="GROUPS";
	if(ReportAllocateUser.cur_radiovalue==1)
        selectScope(obj,"Settings",ld("#"+stype+"_selectuser").val());
    else{
		selectScope(obj,"Settings","");
		ld("#"+stype+"_selectuser").val('');
	}
	selectUserCallBack.callback=ReportAllocateUser.setgroupid;
}
//分配：选择用户
ReportAllocateUser.report_showusers = function(stype){
	obj_init_type="yes";
	ReportAllocateUser.report_stype = stype;
	var obj=new Object();
    obj.value="USERS";
	if(ReportAllocateUser.cur_radiovalue==2)
        selectScope(obj,"Settings",ld("#"+stype+"_selectuser").val());
    else{
		selectScope(obj,"Settings","");
		ld("#"+stype+"_selectuser").val('');
	}
	selectUserCallBack.callback=ReportAllocateUser.setuserid;
}
//分配：选择用户确认事件
ReportAllocateUser.setuserid = function(obj,userobj){    
	if(obj!='cancel'){
		ld("#"+ReportAllocateUser.report_stype+"_selectuser").val(obj.userid.value);
		ReportAllocateUser.cur_radiovalue=2;
	}
}
//分配：选择部门确认事件
ReportAllocateUser.setgroupid=function(obj,groupobj){
	if(obj!='cancel'){
		ld("#"+ReportAllocateUser.report_stype+"_selectuser").val(obj.groupid.value);
		ReportAllocateUser.cur_radiovalue=1;
	}   
}
//Ajax更新列表
var RefreshList = function(folder_id){
	var url = 'module=Customreport&action=CustomreportAjax&file=ListView&ajax=true';
	if(folder_id != ''){
		url += '&folder_id='+folder_id;
	}
	RequestAjax(url,function(rest){
		if(folder_id != ''){
			ld('#report-list-div-'+folder_id).html(rest);
		}else{
			ld('#report-list').html(rest);
		}
		DelProgressObjs();
	});
}

var report_href_link = function(report_id){
	if(report_id > 0){
		if(ld("#href_link_"+report_id) != undefined){
			var link_url = ld("#href_link_"+report_id).attr("tag");
            if(link_url.indexOf("http://")<0&&link_url.indexOf("https://")<0)
		          	window.open ('http://' + link_url,'target') 
             else
                    window.open ( link_url,'target') 
			//window.location.href=link_url;
		}
	}
}
//zkt 【禹王：自定义报表增加对“帆软”开发的报表的访问解析支持】
var report_href_fanruan = function(report_id){
    if(account_version != 'yuwang'){
        return ;
    }
	if(report_id > 0){
	   if(ld("#href_link_"+report_id) != undefined){
            var link_url = ld("#href_link_"+report_id).attr("tag");
		}
        else{
            return ;
        }
        var url='index.php?module=Users&action=UsersAjax&file=FineRecordgettoken&ajax=true&reportid='+report_id;
    	ldAjaxNoProgress(url,'',function(data){
               if(data.code == 1)
               {
                    window.open ( link_url+data.result.token,'target');
                    DelProgressObjs();
               }
               else if(data.code == -1)
               {
                    RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
    				return false;
               }
		})
    }
		
}

function ExportReport(obj)
{
    var Start_Date1=document.getElementById('begin_createdate').value;
    var End_Date1=document.getElementById('begin_end_date').value;
    
    var url='module=Customreport&action=CustomreportAjax&file=ExportIndirtprojectReports&ajax=true&Export=true&Start_Date1='+Start_Date1+"&End_Date1="+End_Date1+"&type="+obj;
    	new Ajax.Request
	(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:url,
				onComplete: function(response) 
				{
                    if(!empty(response.responseText)){
                         window.location='index.php?module=Customreport&action=ExportIndirtprojectReport&frommodule='+response.responseText;
                    }
				}
			}
	  )
}

//生成金蝶凭证
function generateVoucher(obj,startdate,enddate){
	var tr_length = ld("#ProjectSummaryReportList tr").length;
	if(tr_length <= 1){
		var confirm_str = arrJsPopLabel['nodata'];//没有数据
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	var subjectcode = ld('#subjectcode').val();
	var url = 'module=Customreport&action=CustomreportAjax&file=VoucherPop&startdate='+startdate+'&enddate='+enddate+'&subjectcode='+subjectcode;
	RequestAjax(url,function(response){
		if(response == 'ERRORDB'){//金蝶数据库连接失败
			var confirm_str = arrJsPopLabel['KINGDEEDATEBASECONNECTIONFAILED'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			DelProgressObjs();
			return false;
		}else if(response == 'ERRORCODE'){//科目代码在金蝶中不存在！
			var confirm_str = arrJsPopLabel['SUBECTCODEDOESNOTEXISTSINKINGDEE'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			DelProgressObjs();
			return false;
		}else{
			document.getElementById('voucherdiv').innerHTML = response;
			fnvshobj(obj, "voucherheader");	
			DelProgressObjs();
		}
	});
}

//保存金蝶凭证
function SaveVoucher(obj,mode){
	var single_userid,voucherdate,startdate,enddate,mer_type;
	//业务日期
	if(ld('#voucherdate') != undefined && ld('#voucherdate').val() == ''){
		var tag = ld('#voucherdate').attr('tag');
		var confirm_str = tag+arrJsPopLabel['CANOTEMPTY']+'！';
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}else{
		voucherdate = ld('#voucherdate').val();
	}
	//制单人
	if(ld('#single_userid') != undefined && ld('#single_userid').val() == ''){
		var tag = ld('#single_userid').attr('tag');
		var confirm_str = tag+arrJsPopLabel['CANOTEMPTY']+'！';
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}else{
		single_userid = ld('#single_userid').val();
	}
	//开始日期
	startdate = ld('#startdate').val();
	//结束日期
	enddate = ld('#enddate').val();
	//MER  DIRECT or INDIRECT
	mer_type = ld('#mer_type').val();
	var url = 'module=Customreport&action=CustomreportAjax&file=SaveVoucher&startdate='+startdate+'&enddate='+enddate;
	url += '&voucherdate='+voucherdate+'&single_userid='+single_userid+'&mer_type='+mer_type+'&mode='+mode;
	//alert(url);
	//return false;
	RequestAjax(url,function(response){
		fninvshnew('voucherheader');
		var result = response.split('&&&&&&&&&&&&//B/');
		if(result[0] == 'ERROR'){
			document.getElementById('voucherconfigdiv').innerHTML = result[1];
			fnvshobj(obj, "voucherconfig");	
		}else{
			if(mode == 'update'){
				fninvshnew('voucherconfig');
			}
		}
		DelProgressObjs();
	});
}

//取消
function CancelVoucher(obj){
	fninvshnew('voucherconfig');
	fnvshobj(obj, "voucherheader");
}