
function getSelected(txtid){
    cbobj=document.getElementsByName('cb_select_user');
    txtidobj=document.getElementById(txtid);
    txtobj=document.getElementById('txt_select_user');
    if(cbobj!=undefined&&txtobj!=undefined&&txtidobj!=undefined){
        txtobj_str='';
        txtidobj_str='';
        for(i=0;i<cbobj.length;i++){
            if(cbobj[i].checked){
                sp_obj=document.getElementById('sp_user_'+i);
                txt_obj=document.getElementById('txt_user_'+i);
                txtobj_str=txtobj_str+sp_obj.innerHTML+',';
                txtidobj_str=txtidobj_str+txt_obj.value+',';
            }
        }
        txtobj_str=txtobj_str.substr(0,txtobj_str.lastIndexOf(','));
        txtidobj_str=txtidobj_str.substr(0,txtidobj_str.lastIndexOf(','));
        txtobj.value=txtobj_str;
        txtidobj.value=txtidobj_str;
    }
}
function fnDropDownUsers(obj,Lay,topY){
	var tagName = document.getElementById(Lay);
	var leftSide = findPopX(obj);
	var topSide = findPopY(obj);
	var maxW = tagName.style.width;
	var widthM = maxW.substring(0,maxW.length-2);
	var getVal = eval(leftSide) + eval(widthM);
	if(getVal  > document.body.clientWidth ){
		leftSide = eval(leftSide) - eval(widthM);
		tagName.style.left = leftSide + 34 + 'px';
	}
	else
		tagName.style.left= leftSide + 'px';
        if(topY!=undefined){
        tagName.style.top= topSide + topY+'px';
        tagName.style.width=obj.clientWidth+'px';
        }
        else
		tagName.style.top= topSide + 28 +'px';
		tagName.style.display = 'block';
}
function set_return(product_id, product_name) {
	if(document.getElementById('from_link').value != '') {
        window.opener.document.QcEditView.parent_name.value = product_name;
        window.opener.document.QcEditView.parent_id.value = product_id;
	} else {
        window.opener.document.EditView.parent_name.value = product_name;
        window.opener.document.EditView.parent_id.value = product_id;
	}
}
function set_return_specific(product_id, product_name) {
        
        //getOpenerObj used for DetailView 
	if(document.getElementById('from_link').value != '')
	{
		var fldName = window.opener.document.QcEditView.accounts_name;
		var fldId = window.opener.document.QcEditView.account_id;
	}else
	{	
		var fldName = window.opener.document.EditView.accounts_name;
		var fldId = window.opener.document.EditView.account_id;
	}
        fldName.value = product_name;
        fldId.value = product_id;
}
function add_data_to_relatedlist(entity_id,recordid) {

        opener.document.location.href="index.php?module=Emails&action=updateRelations&destination_module=Accounts&entityid="+entity_id+"&parentid="+recordid;
}
function set_return_formname_specific(formname,product_id, product_name) {
        window.opener.document.EditView1.accounts_name.value = product_name;
        window.opener.document.EditView1.account_id.value = product_id;
}


//added by rdhital/Raju for emails
function submitform(id){
		document.massdelete.entityid.value=id;
		document.massdelete.submit();
}	

function findPopX(obj)
{
  var curleft = 0;
        if (document.getElementById || document.all) {
                while (obj.offsetParent && obj.offsetParent.id!="qcform") { curleft += obj.offsetLeft; obj = obj.offsetParent;}
        }        
        else if (document.layers) { curleft += obj.x; }
        return curleft;
}

function findPopY(obj)
{
  var curtop = 0;
        if (document.getElementById || document.all) {
                while (obj.offsetParent && obj.offsetParent.id!="qcform") { curtop += obj.offsetTop; obj = obj.offsetParent;}
        }        
        else if (document.layers) { curtop += obj.Y; }
        return curtop;
}
/*function findPosX(obj) {
   
        var curleft = 0;
        if (document.getElementById || document.all) {
                while (obj.offsetParent) { curleft += obj.offsetLeft; obj = obj.offsetParent;}
        }
        
        else if (document.layers) { curleft += obj.x; }
        //alert(curleft);
        return curleft;
}


function findPosY(obj) {
        var curtop = 0;
        if (document.getElementById || document.all) {
                while (obj.offsetParent) { curtop += obj.offsetTop; obj = obj.offsetParent; }
        }
        else if (document.layers) {curtop += obj.y;}
        return curtop;
}
*/
ScrollEffect = function(){ };
ScrollEffect.lengthcount=202;
ScrollEffect.closelimit=0;
ScrollEffect.limit=0;


function just(){
        ig=getObj("company");
        if(ScrollEffect.lengthcount > ScrollEffect.closelimit ){closet();return;}
        ig.style.display="block";
        ig.style.height=ScrollEffect.lengthcount+'px';
        ScrollEffect.lengthcount=ScrollEffect.lengthcount+10;
        if(ScrollEffect.lengthcount < ScrollEffect.limit){setTimeout("just()",25);}
        else{ getObj("innerLayer").style.display="block";return;}
}

function closet(){
        ig=getObj("company");
        getObj("innerLayer").style.display="none";
        ScrollEffect.lengthcount=ScrollEffect.lengthcount-10;
        ig.style.height=ScrollEffect.lengthcount+'px';
        if(ScrollEffect.lengthcount<20){ig.style.display="none";return;}
        else{setTimeout("closet()", 25);}
}


function fnDown(obj){
        var tagName = document.getElementById(obj);
        document.EditView.description.value = document.getElementById('summary').innerHTML;
        document.EditView.employees.value = getObj('emp').value;
        document.EditView.website.value = getObj('site').value;
        document.EditView.phone.value = getObj('Phone').value;
        document.EditView.fax.value = getObj('Fax').value;
        document.EditView.bill_street.value = getObj('address').value;
        if(tagName.style.display == 'none')
                tagName.style.display = 'block';
        else
                tagName.style.display = 'none';
}

function set_return_todo(product_id, product_name) {
        window.opener.document.createTodo.task_parent_name.value = product_name;
        window.opener.document.createTodo.task_parent_id.value = product_id;
}

//Changing account address info - ENDS
/*
edit:limengxing
date:20140212
reason:温馨提醒改进(V5.3)
other:提醒状态修改为已读
*/
function setRemindReaden(remindid)
{
        new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
		    postBody: 'module=Reminds&ReportHeader=DHeader&types=update_state&action=SetRemindReaden&remindsid='+remindid,
            onComplete: function(response) {           
                     ActivityReminderCallbackProcessg(response.responseText);
                    /* var remindcount = ld('#headerremindscount').html();
                     remindcount = remindcount.substring(remindcount.indexOf("(")+1,remindcount.indexOf(")"))
                     remindcount = remindcount - 1;
                     ld('#headerremindscount').html('('+remindcount+')');*/
                     getRemindsCount();
                }
		}
		);
}
function getRemindsCount()
{
      new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
		    postBody: 'module=Reminds&ReportHeader=DHeader&action=getRemindsCount',
            onComplete: function(response) {  
                if(response.responseText!=''&&parseInt(response.responseText)>0){
					if(ld('#reminds_popup_expansion .remind-notread-count') != undefined){
						ld('#reminds_popup_expansion .remind-notread-count').html(response.responseText);
					}
                    ld('#headerremindscount').html('('+response.responseText+')');
                }else{
                    if(ld('#reminds_popup_expansion .remind-notread-count') != undefined){
						ld('#reminds_popup_expansion .remind-notread-count').hide();
					}
					ld('#headerremindscount').html('');
				}
                    
                     //ActivityReminderCallbackProcessg(response.responseText);
                    /* var remindcount = ld('#headerremindscount').html();
                     remindcount = remindcount.substring(remindcount.indexOf("(")+1,remindcount.indexOf(")"))
                     remindcount = remindcount - 1;
                     ld('#headerremindscount').html('('+remindcount+')');*/
                     
                }
		}
		);
}

/*
edit:limengxing
date:20140212
reason:温馨提醒改进(V5.3)
other:更新该提醒的“提醒时间”
*/
function updateRemindtime(remindtime)
{        
         document.getElementById("selectviewremind").style.display="none";
        if(document.getElementById("popremindids")!=undefined&&document.getElementById("popremindids").value)
        {
            var ids=document.getElementById("popremindids").value;
            new Ajax.Request(
    		'index.php',
    		{
    			queue: {
    				position: 'end',
    				scope: 'command'
    			},
    			method: 'post',
    		    postBody: 'module=Reminds&ReportHeader=DHeader&action=SetRemindReaden&remindtime='+remindtime+'&remindsid='+ids,
                onComplete: function(response) {
                         ActivityReminderCallbackProcessg(response.responseText);
                         var remindcount = ld('#headerremindscount').html();
                         remindcount = remindcount.substring(remindcount.indexOf("(")+1,remindcount.indexOf(")"))
                         remindcount = remindcount - 1;
						 if(empty(remindcount)){
							if(ld('#reminds_popup_expansion .remind-notread-count') != undefined){
								ld('#reminds_popup_expansion .remind-notread-count').hide();
							}
						 }else{
							if(ld('#reminds_popup_expansion .remind-notread-count') != undefined){
								ld('#reminds_popup_expansion .remind-notread-count').html(remindcount);
							}
						 }
                         ld('#headerremindscount').html('('+remindcount+')');                       
                    }
    		}
    		);
        }
}

/*
edit:limengxing
date:20140212
reason:温馨提醒改进(V5.3)
other:更新该提醒的“上一篇下一篇”
*/
function Remindpages(pages,ids,pagenum)
{
        new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
		    postBody: 'module=Reminds&ReportHeader=DHeader&action=SetRemindReaden&pages='+pages+'&remindsid='+ids+'&pagenum='+pagenum,
            onComplete: function(response) {
                     ActivityReminderCallbackProcessg(response.responseText);
                }
		}
		);
}
/*
edit:limengxing
date:20140213
reason:温馨提醒改进
other:推迟弹出框
*/
function RemindDelayDropDown(event,obj,Lay){

    var tagName = document.getElementById(Lay);
        if(typeof tagName == 'undefined') {
        return false;
    }

  
    tagName.style.display = 'block';
    return false;
}