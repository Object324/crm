/*********************************************************************************
*{*ÐÞ¸Ä±àÂë¸ñÊ½:Í³Ò»±àÂë£ºUTF-8*}*
* The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 ********************************************************************************/
function toggleSelectDocumentRecords(module,state,relCheckName,parentEleId) {

	toggleSelect_ListView(state,relCheckName,parentEleId);
	if(state == true) {
		$('selectedboxes_'+parentEleId).value = 'all';
		$('selectAllRec_'+parentEleId).style.display = 'none';
		$('deSelectAllRec_'+parentEleId).style.display = 'inline';
	} else {
		$('selectedboxes_'+parentEleId).value = '';
		$('excludedRecords_'+parentEleId).value = '';
		$('currentPageRec_'+parentEleId).checked = false;
		$('selectAllRec_'+parentEleId).style.display = 'inline';
		$('deSelectAllRec_'+parentEleId).style.display = 'none';
		$('linkForSelectAll_'+parentEleId).hide();
	}
}

//Added after 504 for renaming a folder
function UpdateAjaxSave(label,fid,fldname,fileOrFolder)
{
        fldVal=$('txtbox_'+label).value;
	if(fldVal.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
        {
				var confirm_str = arrJsPopLabel['FOLDERNAMECANOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
        }
        if(fldVal.replace(/^\s+/g, '').replace(/\s+$/g, '').length>=21)
        {
                var confirm_str = arrJsPopLabel['FOLDERNAMETOOLONG'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
        }
	if(fldVal.match(/['"\\%+?]/))
        {
                var confirm_str = arrJsPopLabel['SPECIALCHARCTERNOTALLOWED'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
        }
        if(fileOrFolder == 'file')
                var url='action=DocumentsAjax&mode=ajax&file=Save&module=Documents&fileid='+fid+'&fldVal='+fldVal+'&fldname='+fldname+'&act=ajaxEdit';
        else
	{
                var foldername = encodeURIComponent(fldVal);
				foldername = foldername.replace(/^\s+/g, '').replace(/\s+$/g, '');
                foldername = foldername.replace(/&/gi,'*amp*');		
                var url='action=DocumentsAjax&mode=ajax&file=SaveFolder&module=Documents&record='+fid+'&foldername='+fldVal+'&savemode=Save';
	}
	if(fldname == 'status')
        {
                fldVal = $('txtbox_'+label).options[$('txtbox_'+label).options.selectedIndex].text;
                gtempselectedIndex = $('txtbox_'+label).options.selectedIndex;
        }
	$('status').style.display="block";
        new Ajax.Request(
                        'index.php',
                        {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: url,
                        onComplete: function(response) {
                        		var item = response.responseText;
					$('status').style.display="none";
					if(item.indexOf("Failure") > -1 )
		                        {
                		                $("lblError").innerHTML="<table cellpadding=0 cellspacing=0 border=0 width=100%><tr><td class=small bgcolor=red><font color=white size=2><b>"+arrJsPopLabel['UNABLEUPDATETRYAGAIN']+"</b></font></td></tr></table>";
		                                setTimeout(hidelblError,3000);
                		        }
					else if(item.indexOf('DUPLICATE_FOLDERNAME') > -1)
					{
						var confirm_str = arrJsPopLabel['FOLDERNAMEALREADYEXISTS'];
						RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					}
                                        else
					{
						$('dtlview_'+label).innerHTML = fldVal;
                                        	eval("hndCancel('dtlview_"+label+"','editarea_"+label+"','"+label+"')");
						if(fldname == 'status')
                        	                        $('txtbox_'+label).selectedIndex = gtempselectedIndex;
						else
                        	                        $('txtbox_'+label).value = fldVal;
						eval(item);

					}
					
                                }
                        }
                );

}

function closeFolderCreate()
{
        $('folder_id').value = '';
        $('folder_name').value = '';
        $('folder_desc').value='';
        fninvshnew('orgLay')
}

function AddFolder()
{
    var fldobj = getObj('folder_name');
    var descobj = getObj('folder_desc');
    var modeobj = getObj('fldrsave_mode');
    var saveobj = getObj('fldrsave_mode');
    var fldrname = fldobj.value;
	var fldrdesc = descobj.value;
        if(fldrname.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
        {
				var confirm_str = arrJsPopLabel['FOLDERNAMECANOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
        }
        if(fldrname.replace(/^\s+/g, '').replace(/\s+$/g, '').length>=21)
        {
                var confirm_str = arrJsPopLabel['FOLDERNAMETOOLONG'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
        }
        if(fldrdesc.replace(/^\s+/g, '').replace(/\s+$/g, '').length>=51)
        {
                var confirm_str = arrJsPopLabel['FOLDERDESCRIPTIONTOOLONG'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
        }
	if(fldrname.match(/['"\\%+]/) || fldrdesc.match(/['"\\%+]/))
        {
                var confirm_str = arrJsPopLabel['SPECIALCHARCTERNOTALLOWED'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
        }	
	if(fldrname.match(/[?]+$/) || fldrname.match(/[?]+/))
	{
		var confirm_str = arrJsPopLabel['SPECIALCHARCTERNOTALLOWED'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
                fninvshnew('orgLay');
                var foldername = encodeURIComponent(fldrname);
                var folderdesc = encodeURIComponent(fldrdesc);
		foldername = foldername.replace(/^\s+/g, '').replace(/\s+$/g, '');
                foldername = foldername.replace(/&/gi,'*amp*');
                folderdesc = folderdesc.replace(/^\s+/g, '').replace(/\s+$/g, '');
                folderdesc = folderdesc.replace(/&/gi,'*amp*');
                fldobj.value = '';
                descobj.value = '';
                var mode = modeobj.value;
                if(mode == 'save')
                {
                    url ='&savemode=Save&foldername='+foldername+'&folderdesc='+folderdesc;
                }
                saveobj.value = 'save';
		$('status').style.display = 'block';
                new Ajax.Request(
                                'index.php',
                                {queue: {position: 'end', scope: 'command'},
                                method: 'post',
                                postBody: 'action=DocumentsAjax&mode=ajax&file=SaveFolder&module=Documents'+url,
                                onComplete: function(response) {
					var item = response.responseText;
					$('status').style.display = 'none';
					if(item.indexOf('Failure') > -1)
					{
						$('lblError').innerHTML = "<table cellpadding=0 cellspacing=0 border=0 width=100%><tr><td class=small bgcolor=red><font color=white size=2><b>"+arrJsPopLabel['ADDFOLDERPLEASETRYAGAIN']+"</b></font></td></tr></table>";
						setTimeOutFn();	
					}
					else if(item.indexOf('DUPLICATE_FOLDERNAME') > -1)
					{
						var confirm_str = arrJsPopLabel['FOLDERNAMEALREADYEXISTS'];
						RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					}
					else
					{
                        var confirm_str = arrJsPopLabel['SUCCESSFULOPERATION'];
						RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
						$("ListViewContents").innerHTML = item;
						setContentHeight('Documents');//¼ÆËãÄÚÈÝ¸ß¶È
					}
                                }
                        }
                );
}


function DeleteFolderCheck(folderId)
{
        gtempfolderId = folderId;
        new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: "module=Documents&action=DocumentsAjax&mode=ajax&file=DeleteFolder&deletechk=true&folderid="+folderId,
                        onComplete: function(response) {
                        var item = response.responseText;
                       	if(item.indexOf("NOT_PERMITTED") > -1) {
							var confirm_str = arrJsPopLabel['NOTALLOWEDPERFORMOPERATION'];
							RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
							return false;
						}
						else if(item.indexOf("FAILURE") > -1)
                        {
								var confirm_str = arrJsPopLabel['ONLYEMPTYFOLDERSCANDELETE'];
								RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        }
						else {
								var confirm_str = arrJsPopLabel['SUREWANTDELETETHISFOLDER'];
								RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
								ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
									DeleteFolder(gtempfolderId);   
									fninvsh('emptyfolder');   	
								});
								return false;
                            }
                        }
                }
        );
}

function DeleteFolder(folderId)
{
	$('status').style.display = "block";
        new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: "module=Documents&action=DocumentsAjax&mode=ajax&file=DeleteFolder&folderid="+folderId,
                        onComplete: function(response) {
                                        var item = response.responseText;
										$('status').style.display = "none";
                                        if(item.indexOf("FAILURE") > -1)
                                        {
											var confirm_str = arrJsPopLabel['ERRORDELETINGFOLDER'];
											RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                        }else
                                        {
											$('ListViewContents').innerHTML = item;
                                            fnvshobj(this,'emptyfolder');
                                        }
		               }
                }
        );
}

function MoveFile(id,foldername)
{
	fninvshnew('movefolderlist');
   
    
	var searchurl= $('search_url').value;
	var viewid =getviewId();
	var idstring = '';
	var select_options = '';
	var excludedRecords = '';
	var obj = document.getElementsByName('folderidVal');
	var folderid='0';
	var numOfRows=0;
	var activation='false';

     List_CheckBox_Ids.getIds('Documents');
     
     select_options=List_CheckBox_Ids.ids;
	
	var count = List_CheckBox_Ids.num_rows;
 
	idstring = select_options;
		if(count<=0)
        {
			var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
	

	if(idstring != '') {
		if(parseInt(count) > parseInt(getMaxMassOperationLimit())) {
			var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count,getMaxMassOperationLimit(),'');
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
				//确认移动
				CanMoveFile(viewid,searchurl,excludedRecords,folderid,activation,foldername,id,idstring);
			});
			return false;
		} else {
			//确认移动
			CanMoveFile(viewid,searchurl,excludedRecords,folderid,activation,foldername,id,idstring);
		}
		return false;
			
	} else {
		var confirm_str = arrJsPopLabel['PLEASESELECTLEASTONEFILE'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
}
//确认移动
function CanMoveFile(viewid,searchurl,excludedRecords,folderid,activation,foldername,id,idstring){
	
	var confirm_str = arrJsPopLabel['SUREWANTMOVEFILETO']+" "+ foldername+" "+ arrJsPopLabel['FOLDER'];
	RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
	//确认移动
	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		var url = "&viewname="+viewid+searchurl+"&excludedRecords="+excludedRecords+"&folderidstring="+folderid+"&selectallmode="+activation;
		$('status').style.display = "block";
		new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody: 'action=DocumentsAjax&file=MoveFile&from_folderid=0&module=Documents&folderid='+id+'&idlist='+idstring+url,
				onComplete: function(response) {
					var item = response.responseText;
					$('status').style.display = "none";
					if(item.indexOf("NOT_PERMITTED") > -1 ) {
						$("lblError").innerHTML="<table cellpadding=0 cellspacing=0 border=0 width=100%><tr><td class=small bgcolor=red><font color=white size=2><b>"+arrJsPopLabel['NOTALLOWEDPERFORMOPERATION']+"</b></font></td></tr></table>";
						setTimeout(hidelblError,3000);
					}
					else{
						getObj('ListViewContents').innerHTML = item;
						setContentHeight('Documents');//¼ÆËãÄÚÈÝ¸ß¶È
					}
						
				}

			}
		);
	});
}


/*
function dldCntIncrease(fileid)
{
	EmptyProgressObjs();

	ldAjaxsyncNoProgress('index.php?action=DocumentsAjax&mode=ajax&file=SaveFile&module=Documents&file_id='+fileid+'&act=updateDldCnt','',function(){

		DelProgressObjs();
	});
}
*/


function checkFileIntegrityDetailView(noteid)
{
	$('vtbusy_integrity_info').style.display='';
	new Ajax.Request(
            'index.php',
            {queue: {position: 'end', scope: 'command'},
             method: 'post',
             postBody: 'module=Documents&action=DocumentsAjax&mode=ajax&file=SaveFile&act=checkFileIntegrityDetailView&noteid='+noteid,
             onComplete: function(response) {
             	var item = response.responseText;
				if(item.indexOf('file_available') > -1)
				{
							$('vtbusy_integrity_info').style.display='none';
							$('integrity_result').innerHTML='&nbsp;&nbsp;&nbsp;<font style=color:green>'+arrJsPopLabel['FILESCANDOWNLOAD']+'</font>';
							$('integrity_result').style.display='';
							setTimeout(hideresult,4000);
				}
				else if(item.indexOf('file_not_available') > -1)
				{
							$('vtbusy_integrity_info').style.display='none';
							$('integrity_result').innerHTML='&nbsp;&nbsp;&nbsp;<font style=color:red>'+arrJsPopLabel['DOCUMENTCANOTDOWNLOAD']+'</font>';
							$('integrity_result').style.display='';	
							setTimeout(hideresult,6000);	
				}
				else if(item.indexOf('lost_integrity') > -1)
				{
							$('vtbusy_integrity_info').style.display='none';
							$('integrity_result').innerHTML='&nbsp;&nbsp;&nbsp;<font style=color:red>'+arrJsPopLabel['DOCUMENTNOTAVAILABLE']+'</font>';
							$('integrity_result').style.display='';	
							setTimeout(hideresult,6000);	
				}
                else if(item.indexOf('other_integrity') > -1)
				{
							$('vtbusy_integrity_info').style.display='none';
							$('integrity_result').innerHTML='&nbsp;&nbsp;&nbsp;<font style=color:red>'+arrJsPopLabel['ANNEXEXTERNALTYPE']+'</font>';
							$('integrity_result').style.display='';	
							setTimeout(hideresult,6000);	
				}
			}
		}
	);
}

function hideresult()
{
	$('integrity_result').style.display = 'none';
}

function add_data_to_relatedlist(entity_id,recordid) {



        opener.document.location.href="index.php?module={RETURN_MODULE}&action=updateRelations&smodule={SMODULE}&destination_module=Products&entityid="+entity_id+"&parentid="+recordid;
}
/**
 * ÖªÊ¶¹ÜÀíÌí¼ÓÅúÁ¿Ìá½»°´Å¥
 * @reason 0014766: ÖªÊ¶¹ÜÀí>ÁÐ±í£ºÃ»ÓÐÏÔÊ¾¡¾ÅúÁ¿Ìá½»¡¿°´Å¥
 * @author Tujt 2015-05-11
 */
var approve_subbtn_val = '';
function approve_documentsubmit(module){
	if(ld('div.documentModuleFolderView input[type=checkbox]:checked').length == 0){
		var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
	}
	var selectid = 0;var selectlen = 0;
	ld('div.documentModuleFolderView input[type=checkbox]:checked').each(function(index, el) {
		if(ld(this).attr('name').indexOf('selectall') > -1){
			return true;
		}
		selectid += ld(this).attr('id')+',';
		selectlen ++;
	});
	var urlstring = 'module=Approve&action=ApproveAjax&file=SubmitApprove&save=false&fld_module='+module;
	RequestAjax(urlstring,function(rest){//»ñÈ¡µ±Ç°Ä£¿éµÄÉóÅúÁ÷³Ì
		if(rest == ''){
			DelProgressObjs();
			return false;
		}
		if(rest.indexOf('###NO###') > -1){//Ã»ÓÐ¿ÉÓÃµÄÉóÅúÁ÷³Ì
			var confirm_str = arrJsPopLabel['NOPROCESSPLEASESETPROCESS'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			DelProgressObjs();
			return false;
		}
		var results = rest.split("###SUCCESS###");
		var approveobj = document.getElementById('SubmitApprove');
		sethtml(approveobj,results[1]);
		fnvshobj('','SubmitApprove');
        ld('#SubmitApprove').css('top','30%');
		//»ñÈ¡±£´æ°´Å¥£¬ÖØÐÂ°ó¶¨µã»÷ÊÂ¼þ
		var appinput = approveobj.getElementsByTagName('input');
		var applen = appinput.length;var submitobj;var cancelobj;
		for(var i=0; i<applen; i++){
			if('D_pbtnok' == appinput[i].className){
				submitobj = appinput[i];//±£´æ°´Å¥¶ÔÏó
			}else if('D_pbtncancel' == appinput[i].className){
				cancelobj = appinput[i];//È¡Ïû°´Å¥¶ÔÏó
			}
		}
		if(submitobj){
			var issubmit = 1;
			//ÅúÁ¿ÉóÅúºó£¬±£´æ°´Å¥»á±»ÐÞ¸ÄÎªÏÂÔØÎÄ±¾£¬ÔÙ´Î°ó¶¨°´Å¥Ê±£¬ÐèÒª°ÑÎÄ±¾ÖØÐÂÐÞ¸ÄÎª±£´æ
			if(approve_subbtn_val != '') submitobj.value = approve_subbtn_val;
			submitobj.onclick = function(){//¸ø±£´æ°´Å¥°ó¶¨µã»÷ÊÂ¼þ
				if(issubmit != 1) return false;issubmit = 2;//·ÀÖ¹ÖØ¸´µã»÷
				var approvevalue = ld('#SubmitApprove form[name=frmsubmitapprove]').find('[name=approvevalue]').val();
				var urlstring = 'module=Approve&action=ApproveAjax&file=SubmitApprove';
				urlstring += '&fld_module='+module+'&approvevalue='+approvevalue;
				urlstring += '&selectid='+selectid+'&batchsubmit=1&save=true&selectlen='+selectlen;
				RequestAjax(urlstring,function(rest){//ÅúÁ¿Ìá½»±£´æ
					if(rest == ''){
						DelProgressObjs();
						return false;
					}
					var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
					var submitlog = '<div style="width:97%;max-height:400px;overflow-y:auto;margin-top:10px;margin-bottom:10px;line-height:22px;padding-left:10px;">';
					submitlog += restobj.log.value;//ÅúÁ¿Ìá½»Ê§°ÜÈÕÖ¾
					submitlog += '</div>';
					sethtml(document.getElementById('subappcontent'),submitlog);
					approve_subbtn_val = submitobj.value;
					var inputs = submitobj.parentNode.getElementsByTagName('input');
                    inputs[1].value = restobj.download.value;
                    submitobj.style.display = 'none';//Òþ²ØÌá½»°´Å¥
                    cancelobj.className="D_pbtnok";
					cancelobj.onclick = function(){//È¡Ïû°´Å¥
						fninvshnew('SubmitApprove');puyoungJS_DialogBox.unblock();
						//getListViewEntries_js(module,'start='+restobj.start.value);//Ë¢ÐÂÒ³Ãæ
						ld('div.documentModuleFolderView input[type=checkbox]').prop('checked',false);
						ld('div.documentModuleFolderView input[type=checkbox]').parent().parent().parent().find('tr.lvtColDataSelected').attr('class','lvtColData');
					}
					DelProgressObjs();
				});
			}
		}
		DelProgressObjs();
	});
}
