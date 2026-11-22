/*
{*修改编码格式:统一编码：UTF-8*}
*/
document.write("<script type='text/javascript' src='include/js/Inventory.js'></"+"script>");
document.write("<script type='text/javascript' src='include/js/Mail.js'></"+"script>");

document.write("<script type='text/javascript' src='modules/Accounts/Accounts.js'></"+"script>");
/**
edit:can
reason: //服务收费管理明细界面分配
**/
 function servicCharge_allocation(obj,id)
 {
     $("status").style.display="inline";
    //alert("module="+module+"&action=GroupEdit&returnModule="+module+"&mode=ajax&type="+type+"&idstring="+idstring+"&groupid="+groupid+"");
    //alert(groupid);
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module=ServiceCharge&action=GroupEdit&returnModule=ServiceCharge&mode=ajax&type=Dis"+"&idstring="+id+"&return_action=DetailView",
			onComplete: function(response) {	 
	 		    lingdangJS_DialogBox.block();
                $("status").style.display="none";
				//var result = response.responseText;
                var results=response.responseText.split('###SUCCESS###');
               	$("smowneredit_form_div").update(results[1]);
	           	fnvshobj(obj, 'smowneredit');                             
			}
		}
    );
 }

/**
 * edit:chj
 * reason:客户分配 、移动分组、编辑、删除分组
 * description: 服务收费管理(CRMV5.6)
 * date:2014-8-15
 *type:dis:分配，move：移动分组
 * */
function setServiceChargeGroup(module,type)
{ 
    var idstring = '';
    var groupid = document.getElementById('hiddengroupid').value;
    $('groupedit_div').innerHTML = '';
    if(document.getElementById('isadmin') != undefined && document.getElementById('isadmin').value == 0)
    {
        alert(arrJsPopLabel['SORRYYOUARENOTTHEADMINISTRATOR']);
        return false;
    }
    var viewname=document.getElementById('viewname').value;
    if(type == 'Dis' || type == 'Move')
    {
        var select_options = document.getElementById('allselectedboxes').value;
        
    	var numOfRows = document.getElementById('numOfRows').value;
    	var excludedRecords = $('excludedRecords').value;
    	var x = select_options.split(';');
		var count = x.length;
        if(count > 1||select_options=='all') {
			idstring = select_options;
        }
        else
        {
            alert(arrJsPopLabel['PLEASESELECTONEENTITY']);
			return false;
        }
        //if(select_options=='all') {
    }
    if(type == 'Edit' || type == 'Del')
    {
        if(document.getElementById('hiddengroupid').value == '')
        {
            alert(arrJsPopLabel['PLEASESELECTYOUGROUPNAME']);
			return false;
        }
    }
    $("status").style.display="inline";
    //alert("module="+module+"&action=GroupEdit&returnModule="+module+"&mode=ajax&type="+type+"&idstring="+idstring+"&groupid="+groupid+"");
    //alert(groupid);
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module="+module+"&ReportHeader=dheader&action=GroupEdit&returnModule="+module+"&mode=ajax&&viewname="+viewname+"&type="+type+"&idstring="+idstring+"&groupid="+groupid+"",
			onComplete: function(response) {	 
	 		    lingdangJS_DialogBox.block();
                $("status").style.display="none";
				//var result = response.responseText;
                var results=response.responseText.split('###SUCCESS###');
                $('groupedit_div').innerHTML=results[1];
                fnvshobj(this, 'groupedit');                                
			}
		}
    );
    
}
/**
 * edit:chj
 * reason:分组创建保存
 * description: 服务收费管理(CRMV5.6)
 * date:2014-8-15
 * */
function SaveGroup(module,type,id)
{
    var groupname = document.getElementById('zhgroupname').value;
    if(!groupname)
    {
        alert(arrJsPopLabel['Group_name']+arrJsPopLabel['CANOTEMPTY']);
        return false;
    }
    if(groupname.length > 20)
    {
        alert(arrJsPopLabel['Group_name']+arrJsPopLabel['GROUPLENGTH']);
        return false;
    }
    var en_groupname = document.getElementById('engroupname').value;
    if(!en_groupname)
    {
        alert(arrJsPopLabel['GroupEnname']+arrJsPopLabel['CANOTEMPTY']);
        return false;
    }
    if(en_groupname.length > 20)
    {
        alert(arrJsPopLabel['GroupEnname']+arrJsPopLabel['GROUPLENGTH']);
        return false;
    }
    $("status").style.display="inline";
    //alert("module="+module+"&action=GroupEdit&returnModule="+module+"&mode=ajax&groupid="+id+"&type="+type+"&engroupname="+en_groupname+"&zhgroupname="+groupname);
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
            async: 'false',
			postBody:"module="+module+"&action=GroupEdit&returnModule="+module+"&mode=ajax&groupid="+id+"&type="+type+"&engroupname="+en_groupname+"&zhgroupname="+groupname,
			onComplete: function(response) {	 
			 lingdangJS_DialogBox.block();
				//var result = response.responseText;
                var results=response.responseText.split('###SUCCESS###');
                if(results[1] == 1)
                {
                    $("status").style.display="none";
                    alert(arrJsPopLabel['Group_name']+arrJsPopLabel['CANOTREPEATED']);
                    return false;
                }
                lingdangJS_DialogBox.unblock();
            	var newbox=document.getElementById('groupedit');
                newbox.style.display="none";
                document.getElementById('hiddengroupid').value = results[1];
                lingdangJS_DialogBox.block();
                refReshServiceCharge(module,results[1]);
                $("status").style.display="none";
                //document.location.href='index.php?module='+module+'&action=index&parenttab=Parent Accounts';                     
			}
		}
    );
}

/**
 * edit:chj
 * reason:分组编辑
 * description: 服务收费管理(CRMV5.6)
 * date:2014-8-15
 * */
function EditGroup(module,type,id)
{
    $("status").style.display="inline";
    var selectgroupud = document.getElementById('servicegroup').value;
    //alert("module="+module+"&action=GroupEdit&returnModule="+module+"&mode=ajax&type="+type+"&groupid="+id+"&selectgroupid="+selectgroupud);
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
            async: 'false',
			postBody:"module="+module+"&action=GroupEdit&returnModule="+module+"&mode=ajax&type="+type+"&groupid="+id+"&selectgroupid="+selectgroupud,
			onComplete: function(response) {	 
			 lingdangJS_DialogBox.block();
				//var result = response.responseText;
                var results=response.responseText.split('###SUCCESS###');
                if(results[1] == 1)
                {
                    alert(arrJsPopLabel['Group_name']+arrJsPopLabel['CANOTREPEATED']);
                    return false;
                }
                lingdangJS_DialogBox.unblock();
            	var newbox=document.getElementById('groupedit');
                newbox.style.display="none";
                lingdangJS_DialogBox.block();
                refReshServiceCharge(module,selectgroupud);
                $("status").style.display="none";
                //document.location.href='index.php?module='+module+'&action=index&parenttab=Parent Accounts';                     
			}
		}
    );
}
/**
 * edit:chj
 * reason:服务收费  设置分组的操作权限
 * description: 服务收费管理(CRMV5.6)
 * date:2014-8-15
 * */
function setGroupDisplay(is_edit)
{
    if(is_edit == 0)    //没有编辑、删除权限
    {
        document.getElementById('ServiceCharge_group2').style.display='none';
        document.getElementById('ServiceCharge_group3').style.display='none';   
    }
    else
    {
        document.getElementById('ServiceCharge_group2').style.display='block';
        document.getElementById('ServiceCharge_group3').style.display='block'; 
    }
}
/**
 * edit:chj
 * reason:服务收费  选择分组，根据该分组进行序时簿查询
 * description: 服务收费管理(CRMV5.6)
 * date:2014-8-15
 * */
function change_table(id,is_edit,rowid,cnt,viewid)
{
    for(var i=0;i<cnt;i++){
            //document.getElementById('change_table_here'+i).style.color = '#0070BA';
            document.getElementById('change_table_here'+i).style.color = '';
    }
   // document.getElementById('change_table_here'+rowid).style.color='red';
    //setGroupDisplay(is_edit);
    document.getElementById('hiddengroupid').value = id;
	$("status").style.display="inline";
    if(viewid=='')
        viewid=document.getElementById("viewname").value;
    if(document.getElementById("SmOwnerSearchScope")!=null)
        var searchScope= encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    else
        searchScope='';
    document.getElementById("viewname").value=viewid;
    var viewName = encodeURIComponent(viewid);
   
    //alert(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    //alert("module=ServiceCharge&action=ServiceChargeAjax&file=ListView&ajax=true&start=1&viewname="+viewName+"&parenttab=Parent Accounts&SearchScope="+searchScope+"&accounttype="+customtype+"&groupid="+id+"&groupedit="+is_edit);
    new Ajax.Request(
       	'index.php',
        {queue: {position: 'end', scope: 'command'},
           	method: 'post',
            postBody:"module=ServiceCharge&action=ServiceChargeAjax&file=ListView&ajax=true&start=1&viewname="+viewName+"&parenttab=Service&SearchScope="+searchScope+"&groupid="+id+"&groupedit="+is_edit,
            onComplete: function(response) {
            $("status").style.display="none";
            result = response.responseText.split('&#&#&#');
            $("ListViewContents").innerHTML= result[2];
            $("servicechargeleft").innerHTML=result[3];
           
			$('basicsearchcolumns_real').innerHTML = $('basicsearchcolumns').innerHTML           
			$('basicsearchcolumns').innerHTML = '';
			//document.basicSearch.search_text.value = '';
            }
        }
	);
}

/**
 * edit:chj
 * reason:服务收费  分许排序 分组名称向上移动
 * description:服务收费管理(CRMV5.6) 
 * date:2014-8-15
 * */
function moveSelectUp()
{
    var elem =document.getElementById('selectedSourceColumns');
    if(elem.options.selectedIndex>=0)
    {
        for (var i=1;i<elem.options.length;i++)
        {
            if(elem.options[i].selected == true)
            {
    			//swap with one up
    			var first = elem.options[i-1];
    			var second = elem.options[i];
    			var temp = new Array();

				temp.value = first.value;
				temp.innerHTML = first.innerHTML;

				first.value = second.value;
				first.innerHTML = second.innerHTML;

				second.value = temp.value;
				second.innerHTML = temp.innerHTML;

				first.selected = true;
				second.selected = false;
            }
        }
    }
}

/**
 * edit:chj
 * reason:服务收费  分许排序 分组名称向下移动
 * description: 服务收费管理(CRMV5.6)
 * date:2014-8-15
 * */
function moveSelectDown()
{
    var elem =document.getElementById('selectedSourceColumns');
    if(elem.options.selectedIndex>=0)
    {
        for (var i=elem.options.length-2;i>=0;i--)
        {
            if(elem.options[i].selected == true)
            {
                //swap with one down
                var first = elem.options[i+1];
                var second = elem.options[i];
                var temp = new Array();

				temp.value = first.value;
				temp.innerHTML = first.innerHTML;

				first.value = second.value;
				first.innerHTML = second.innerHTML;

				second.value = temp.value;
				second.innerHTML = temp.innerHTML;

				first.selected = true;
				second.selected = false;
            }
        }
    }
}
function SubmitGroup(from,module)
{
    var isGroupName;
    var ColStr = new Array();
    var elem =document.getElementById('selectedSourceColumns');
    var cnt = elem.options.length;
    for (var i=0; i<cnt; i++)
    {
        ColStr[i]= elem.options[i].value;
    }
    isGroupName =  ColStr.join(';');
    //document.getElementById('selectgroupname').value = ColStr.join(';');
    //alert("module="+module+"&action=GroupEdit&returnModule="+module+"&mode=ajax&type=Soft&selectgroupname="+isGroupName);
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module="+module+"&action=GroupEdit&returnModule="+module+"&mode=ajax&type=Soft&selectgroupname="+isGroupName,
			onComplete: function(response) {	 
			 lingdangJS_DialogBox.block();
                document.location.href='index.php?module='+module+'&action=index';
			}
		}
    );
}

/**
 * edit:chj
 * reason:更改客户的服务收费人
 * description: 服务收费管理(CRMV5.6)
 * date:2014-8-15
 * */
function UpdateServiceUser(from,module)
{
    $("status").style.display="inline";
    var userinfo = document.getElementById('selusername').value;
    var serviceuserid = document.getElementById('assigned_user_id').value;
    if(document.getElementById('return_action_detail')!=undefined&&document.getElementById('return_action_detail').value=='DetailView')
    {
       //服务收费管理明细界面分配
        new Ajax.Request(
    		'index.php',
    		{
    			queue: {
    				position: 'end',
    				scope: 'command'
    			},
    			method: 'post',
                async: 'false',
    			postBody:"module="+module+"&action=GroupEdit&returnModule="+module+"&mode=ajax&type=Dis&assigned_user_id="+serviceuserid+"&selusername="+userinfo,
    			onComplete: function(response) {	 
                   window.location='index.php?module=ServiceCharge&action=DetailView&record='+userinfo;
    			}
    		}
        );
    }
    else
    {
         document.forms['Saveresults'].submit();
        /*var serviceid = document.getElementById('hiddengroupid').value;       
        new Ajax.Request(
    		'index.php',
    		{
    			queue: {
    				position: 'end',
    				scope: 'command'
    			},
    			method: 'post',
                async: 'false',
    			postBody:"module="+module+"&action=GroupEdit&returnModule="+module+"&mode=ajax&type=Dis&serviceuserid="+serviceuserid+"&userinfo="+userinfo,
    			onComplete: function(response) {	 
                    lingdangJS_DialogBox.block();
                    refReshServiceCharge(module,serviceid);
                    $("status").style.display="none";
                    //document.location.href='index.php?module='+module+'&action=index&parenttab=Parent Accounts&selectgroupid='+serviceuserid;                     
    			}
    		}
        );*/
        
    }
  
    
}
/**
 * edit:chj
 * reason:客户分配分组
 * description: 服务收费管理(CRMV5.6)
 * date:2014-8-15
 * */
function UpdateServiceGroup(from,module)
{
    document.forms['Saveresults'].submit();
    /*
    $("status").style.display="inline";
    var servicegroup = document.getElementById('servicegroup').value;
    var userinfo = document.getElementById('selusername').value;
    //alert("module="+module+"&action=GroupEdit&returnModule="+module+"&mode=ajax&type=Move&servicegroup="+servicegroup+"&userinfo="+userinfo);
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
            async: 'false',
			postBody:"module="+module+"&action=GroupEdit&returnModule="+module+"&mode=ajax&type=Move&servicegroup="+servicegroup+"&userinfo="+userinfo,
			onComplete: function(response) {	 
                document.getElementById('hiddengroupid').value = servicegroup;
                refReshServiceCharge(module,servicegroup);
                $("status").style.display="none";
                //document.location.href='index.php?module='+module+'&action=index&parenttab=Parent Accounts&selectgroupid='+servicegroup;                     
			}
		}
    );*/
    
}

function refReshServiceCharge(module,groupid)
{
 
    new Ajax.Request(
       	'index.php',
        {queue: {position: 'end', scope: 'command'},
               	method: 'post',
                async: 'false',
                postBody:"module="+module+"&action="+module+"Ajax&file=ListView&ajax=true&start=1&query=true&parenttab=Parent Accounts&groupid="+groupid,
                onComplete: function(response) {
                    result = response.responseText.split('&#&#&#');
                    if(trim(response.responseText)=="")
                    {
                         $("ListViewContents").innerHTML="";
                         return ;
                    }
                    if(result[2]!="undefined")
                    {
                        $("ListViewContents").innerHTML= result[2];
                         $("servicechargeleft").innerHTML=result[3];
                    }
                    else
                    {
                        $("ListViewContents").innerHTML=arrJsPopLabel['DATAERROR'];
                    }
                }
        }
	);
 
    fninvshnew('groupedit'); lingdangJS_DialogBox.unblock();    
}