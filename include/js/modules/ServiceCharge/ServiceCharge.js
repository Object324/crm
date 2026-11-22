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
	 		    puyoungJS_DialogBox.block();
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
	 		    puyoungJS_DialogBox.block();
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
			 puyoungJS_DialogBox.block();
				//var result = response.responseText;
                var results=response.responseText.split('###SUCCESS###');
                if(results[1] == 1)
                {
                    $("status").style.display="none";
                    alert(arrJsPopLabel['Group_name']+arrJsPopLabel['CANOTREPEATED']);
                    return false;
                }
                puyoungJS_DialogBox.unblock();
            	var newbox=document.getElementById('groupedit');
                newbox.style.display="none";
                document.getElementById('hiddengroupid').value = results[1];
                puyoungJS_DialogBox.block();
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
			 puyoungJS_DialogBox.block();
				//var result = response.responseText;
                var results=response.responseText.split('###SUCCESS###');
                if(results[1] == 1)
                {
                    alert(arrJsPopLabel['Group_name']+arrJsPopLabel['CANOTREPEATED']);
                    return false;
                }
                puyoungJS_DialogBox.unblock();
            	var newbox=document.getElementById('groupedit');
                newbox.style.display="none";
                puyoungJS_DialogBox.block();
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
			 puyoungJS_DialogBox.block();
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
                    puyoungJS_DialogBox.block();
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
  
    
}


/**
Liver 2016-12-07 平均分配
**/
function averageDistribution(obj,module,popup_type){    
    //获取要变更的ID
    var selectlen = 1;
	var select_id = '';//选择的单据id
	var savefilter = '';//选择的单据个数
    var mode = 'list';//类型：列表(list)详情页(detail)
	var excludedRecords = '';
	var oem_crm = ld('#oem_crm').val();
    if(ld('input[name=selected_id]').length > 0){//列表

        select_id = document.getElementById('allselectedboxes').value;
		if('all' == select_id){
			//获取全选数量
			selectlen = document.getElementById('numOfRows').value;
            excludedRecords = document.getElementById('excludedRecords').value;
			if(parseInt(selectlen) > parseInt(getMaxMassOperationLimit())) {
				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',selectlen,getMaxMassOperationLimit(),'');
				if(confirm(confirm_str)) {
				} else {
					return false;
				}
			}
			savefilter += '&selectlen='+selectlen;
		}else {
			var x = select_id.split(';');
			var count = x.length;
			if(0 == ld('input[name=selected_id]:checked').length){
                RemindsMsg("","LdPopWidth400px","","yes","yes","");
				return false;
			}
			if(count - 1 > getMaxMassOperationLimit()) {
				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count - 1,getMaxMassOperationLimit(),'');
				if(confirm(confirm_str)) {
				} else {
					return false;
				}
			}

            selectlen = count - 1;
		}
	}
    else if(document.DetailView == undefined){
        RemindsMsg("","LdPopWidth400px","","yes","","");
        return false;
    }else{//详情页
		select_id = document.DetailView.record.value;
        mode = 'detail';
	}
	savefilter += '&select_id='+select_id;
  

	//自定义弹出层页面html，绑定事件
    //alert(popup_url);
	var scopepopupobj;
    var popup_caption_value;
    var popup_url = '';

    var popupinfo = getAllocateSharePopupInfo(popup_type, module);
    popup_caption_value = popupinfo.poptitle;
    popup_url = popupinfo.popup_url;

	var popup_header =  '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><a class="rfloat" href="javascript:;" style="margin-right: 15px;margin-top:-4px;"  onclick="getLinksUrl(\'Accounts\',\'Allocate\',\'averageDistribution\');" >'+arrJsPopLabel['ONLINEHELP']+'</a><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER']+'\'><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		scopepopupobj =  new ScopePopupObj(module);
        scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		if(oem_crm == 'no'){
			scopepopupobj.popup_header = popup_header;
		}
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
		   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
           cls_ScopePopup.prop.popup_module = module;//模块
		   cls_ScopePopup.prop.popup_value = '';
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                    //没有选择任何用户，则给出提示
                    var array_user=cls_ScopePopup.return_obj.return_id.split(",").length;//选取用户的个数
                    if(empty(cls_ScopePopup.return_obj.return_id) || array_user<2){
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTTWOUSER'];
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

                        return false;
                    }else{
                        var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                        //edit:can 2021-03-05 44743: （本地8.3.7）单据平均分配；客户模块，选择客户单据后进行平均分配，先选择一个成员，出现“请至少选择两个成员！”提示后，再加个成员点确定没反应
                       ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click');//解绑防止多次点击。
                        // var array_user=selected_user.split(",");
                        ld('#rptContentLoading').show();
                        // @edit:liushuai,2021-03-10,reason:【ID1001390】批量平均分配增加显示进度条（服务收费管理需单独处理）
                        var intervalrow = 8; //默认 8 数据量太大  请求次数过多  会导致执行起来过久
                        if (selectlen > 100){
                            intervalrow = Math.ceil(selectlen / 10); //向上取整
                        }
                        //duan 2022-2-28 设置批量操作上限20，如果一次性选中的记录条数大于系统设置的批量操作最大条数10倍以上，会导致进度条未生效
                        if(intervalrow >20){
                            intervalrow = 20;
                        }
                        startAverageDistribution(module, popup_type, mode, select_id, selected_user, selectlen, excludedRecords, 0, intervalrow);

                    }
                });
            }
		});
	});
}


// @edit:liushuai,2021-03-10,reason:【ID1001390】批量平均分配增加显示进度条（服务收费管理需单独处理）
function startAverageDistribution(module, popup_type, mode, select_id, selected_user, selectlen, excludedRecords, startrow, intervalrow)
{
    var endrow = startrow+intervalrow;
    if (endrow > selectlen){
        endrow = selectlen;
    }
    var urlstring = 'module=Users&action=UsersAjax&file=ChangeCreatorInfo&setype=save';
    urlstring += '&from_module='+module+'&changetype='+popup_type+'&mode='+mode;
    urlstring += '&select_id='+select_id+'&caterorid='+selected_user+'&excludedRecords='+excludedRecords;

    urlstring+="&startrow="+startrow+"&endrow="+endrow;
    ldAjax('index.php?',urlstring, function (data) {
        DelProgressObjs();
        ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
        var tmpmsg = data.msg;
        var restobj = data.result;
        if(empty(restobj)) return false;
        if(data.code == -1){
            if(tmpmsg.indexOf('###REACHMAXCUSTOMER###')>-1){
                var confirm_str = arrJsPopLabel['REACHMAXCUSTOMERJS'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
            }
        }
        else if(data.code == 1) {
            if(mode=='list')
            {
                var tmppopupobjobj;

                if(startrow==0)
                {
                    tmppopupobjobj=ProgressPopup.load(restobj.progresstitle,"","",500,module,"","","","");
                    tmppopupobjobj.show();

                }
                else{
                    tmppopupobjobj=CrmPopup.getPopupObj('last');

                }
                var maxrows=parseInt(restobj.maxrows);
                var percent=parseInt(((startrow+intervalrow)/maxrows*100));
                //var width=parseInt((500*(startrow+intervalrow)/maxrows));

                tmppopupobjobj.setPercentWidth(percent);
                tmppopupobjobj.setTotalNum(restobj.selectrows);
                tmppopupobjobj.setCurNum(startrow);
                if(maxrows!=restobj.selectrows)
                {
                    tmppopupobjobj.setValidataNum(maxrows);
                }
                if(parseInt(startrow+intervalrow)<parseInt(restobj.maxrows))
                {
                    startAverageDistribution(module, popup_type, mode, select_id, selected_user, selectlen, excludedRecords, startrow + intervalrow, intervalrow);
                    return false;
                }
                else{
                    tmppopupobjobj.CancelEvent();
                }
            }
            if(ld('input[name=selected_id]').length == 0){//Liver 2016/09/07 去掉&&module!='Documents'，原因是bug0024278: 知识管理明细：更多中点击-更改创建人，确定后，界面显示了更改创建人的提示消息
                puyoungJS_DialogBox.block();

                if(module == 'HelpDesk'){
                    var help_url = window.location.href;
                    help_url = help_url.replace('&sendtype=yes','');
                    if(help_url.indexOf('&sendtype=yes')<0 && popup_type=='Allocate'){
                        help_url += '&sendtype=yes';
                    }
                    window.location.href=help_url;
                    return false;
                }
                puyoungJS_DialogBox.unblock();
                fninvshnew('selectpopup_1');
                changeUser.afterOperation(popup_type,selected_user,cls_ScopePopup.return_obj.return_name,module);
                //window.location.reload();
                return false;
            }
            getJsScript('include/js/ldcrm.base.js',function(){
                resultRemindsMsg(restobj.title.value,"LdPopWidth600px","","yes","",restobj.log.value);
                var popupobj=CrmPopup.getPopupObj('last');
                if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                {
                    //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenData();
                }


                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    fninvshnew('mass_advancer');puyoungJS_DialogBox.unblock();
                    if(ld('input[name=selected_id]').length > 0){
                        $('basicsearchcolumns').innerHTML = '';
                        $('allselectedboxes').value='';
                        $('excludedRecords').value='';
                        getListViewEntries_js(module,restobj.start.value);//刷新页面
                        //window.location.reload();
                        if(document.getElementById("SmOwnerSearchScope")!=undefined)
                            searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
                        var viewid = getviewId();

                    }else{
                        window.location.reload();
                    }
                });
                return false;
            });
        }
        else{
            return false;
        }
    });
}
