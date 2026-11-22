/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
/**
 * *{*修改编码格式:统一编码：UTF-8*}
 * 更新操作
 * edit:diony
 * date:2013-11-15
 * reason:数据备份
 */

function validate(obj){
	obj.handbackup_path.value = trim(obj.handbackup_path.value);
	obj.backuppath_2.value = trim(obj.backuppath_2.value);

    if(obj.handbackup_path.value == ""){
        //备份文件路径不能为空！
		var confirm_str = arrJsPopLabel['BACKUPFILEPATHCANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		obj.handbackup_path.focus();
        return false;
    }
	if(obj.backuppath_2.value == ""){
        var confirm_str = arrJsPopLabel['BACKUPFILEPATHCANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		obj.backuppath_2.focus();
        return false;
	}
	//obj.handbackup_path.value = obj.handbackup_path.value.replace(/\s/g,'');//去除空格
	obj.handbackup_path.value = obj.handbackup_path.value.replace(/\\/g,'/');//替换反斜杠
	//obj.backuppath_2.value = obj.backuppath_2.value.replace(/\s/g,'');//去除空格
	obj.backuppath_2.value = obj.backuppath_2.value.replace(/\\/g,'/');//替换反斜杠
	var re = /[a-zA-Z]{1}:{1}\/[^\/].+(\/$)?/;
	var os = document.getElementById('os').value;
	if(os == 'window'){
		if(!re.test(obj.handbackup_path.value)){
			var confirm_str = arrJsPopLabel['BACKUPFILENOTINFORMAT'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			obj.handbackup_path.focus();
			return false;
		}
		if(!re.test(obj.backuppath_2.value)){
			var confirm_str = arrJsPopLabel['BACKUPFILENOTINFORMAT'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			obj.backuppath_2.focus();
			return false;
		}
	}else if(os == 'linux'){
		if(obj.handbackup_path.value[0] != '/'){
			arrJsPopLabel(arr['NOTTHECORRECTFILEPATH']);
			obj.handbackup_path.focus();
			return false;
		}
		//if(obj.backuppath_2.value[0] != '/'){
			//arrJsPopLabel(arr['NOTTHECORRECTFILEPATH']);
			//obj.backuppath_2.focus();
			//return false;
		//}
	}
    return true;
}

function isBackupUsing (check){
	//if(document.Backup.backuppath_2)
		//document.Backup.backuppath_2.readOnly = (document.Backup.backuppath_2.readOnly)?false:true;
	var selectobj = document.getElementById('aotobackuptab').getElementsByTagName('select');
	var selectlen = selectobj.length;
	if(selectlen > 0){
		if(!check){
			for(var i=0; i<selectlen; i++){
				selectobj[i].disabled = true;
			}
		}else{
			for(var i=0; i<selectlen; i++){
				selectobj[i].disabled = false;
			}
		}
	}
}

function autovalidate(obj){
    if(obj.autobackup_path.value==""){
        //备份文件路径不能为空！
		var confirm_str = arrJsPopLabel['BACKUPFILEPATHCANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
    if(obj.autobackup_day.value==""){
        //备份周期不能为空！
        var confirm_str = arrJsPopLabel['BACKUPCYCLECANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }    
    return true;
}


//下载备份文件列表
function showdownloadfilelist(urldata){
    var isinit = 0;
    var url = 'module=Settings&action=SettingsAjax&file=BackupSettings';
	url += '&filelist=yes&'+urldata;
	ldAjax('index.php?',url,function (data) {
		if (data.code == 1){
			var list = '';
			list += '<div class="ld-pop-container">';
			if (!empty(data.result.entries)){
				list += '' +
					'<div class="PageDiv0" style="margin:5px 0;">' +
					'<div class="ld-flex-start">\n' +
					'    \t<div class="ld-pagenum-div">' + data.result.navigation[0] + '</div>' +
					'' + data.result.navigation[1] + '</div>' +
					'</div>' +
					'';
			}
			var idx = 0;
			list += '<div class="ld-table-container ld-table-container-lines">';
			list += '<table class="" border="0" cellpadding="0" cellspacing="0" width="100%"><thead>';
			list += '<tr>';
			ld.each(data.result.header,function(key,head){
				if(key=='filename'){var keywidth='width="35%"'}
				list += '<th '+keywidth+'><div><span style=\'cursor: pointer;\' fld=\''+key+'\'>'+head+'</span>'+'</div>';
				list += '</th>';idx ++;
			});
			list += '</tr></thead><tbody>';
			if(!empty(data.result.entries)){
				ld.each(data.result.entries,function(fldid,entity){
					list += '<tr>';
					ld.each(data.result.header,function(fld,head){
						list += '<td><div align=\'left\'>'+entity[fld]+'</div>'+'</td>';
					});
					list += '</tr>';
				});
			}else{
				list += '<tr>';
				list += '<td colspan="'+idx+'" align="center">'+data.result.lbl_none+'</td>';
				list += '</tr>';
			}

			list += '</tbody></table></div></div>';
			if(ld('#FileListDiv').length == 1){
				if(0 == isinit) isinit = 1;
			}
			var popupobj = CrmPopup.getPopupObj('last');
			if (popupobj == undefined){
				popupobj = CrmPopup.load(data.result.title,'','','LdPopWidth800px','Setting','','','','');
			}
			popupobj.show(list);

			// 需要去掉的给高度
			popupobj.reduceBodyHeight = 75;
			// 设置内容最大高度
			popupobj.setPopBodyMaxHeight(".ld-table-container");

			DelProgressObjs();
		}
	})

}

//下载备份文件
function downloadfile(backupid){
	var url = "module=Settings&action=SettingsAjax&file=BackupSettings&download=yes&ajax=yes&backupid="+backupid;
	ldAjax("index.php",url,function (data){
		if (data.code == -1){
			MessagePopup.TipOne_warning(arrJsPopLabel['THEFILEHASDELETED']);
		}else {
			var a = document.createElement('a');
			a.href = "storage/backup/"+data.result.name;
			ld("body").append(a);
			a.click();
			ld(a).remove();
		}
		DelProgressObjs();
	})
}

//删除备份文件
function deletefile(backupid){
	MessagePopup.TipTwo_warning(arrJsPopLabel['SURETODELETEBACKUPFILE']);
	var popupobj = CrmPopup.getPopupObj('last');
	ld('#'+popupobj.divid).find('[tagclick=msgConfirm]').bind('click',function () {
		var url = "index.php?module=Settings&action=SettingsAjax&file=BackupSettings&deletefile=yes&ajax=yes&backupid="+backupid;
		ldAjax(url,'',function (data) {
			showdownloadfilelist();
			DelProgressObjs();
		})
	})
}

function loadRelatedListBlock(urldata,target) {
	var start = target.attr('start');
	var urldata = 'start='+start;
	showdownloadfilelist(urldata);
}

function ldSelectPageNum(obj,start,num){
	var urldata = 'start='+start;
	showdownloadfilelist(urldata);
}