/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
var CKTemplatePrint;
/*
edit:Can
date:20130814
reason:选择打印模板
*/
function templatePrintSel(obj,BLOCKIDSETTING,FIELDIDSETTING)
{
    var tabid=obj.value;
    window.location="index.php?module=Settings&action=TemplateprintList&parenttab=Settings&printtab="+tabid+"&blockidsetting="+BLOCKIDSETTING+"&fieldidsetting="+FIELDIDSETTING;
    
}

/*
edit:andrew
date:20140928
reason:选择服务绩效参数 
*/
function templateServerSel(obj,BLOCKIDSETTING,FIELDIDSETTING)
{
    var tabid=obj.value;
    window.location="index.php?module=Settings&action=Serviceperformance&parenttab=Settings&selectserverttab="+tabid+"&blockidsetting="+BLOCKIDSETTING+"&fieldidsetting="+FIELDIDSETTING;
}
/*
edit:andrew
date:20140929
reason:选择城市
*/
var isserviepermance=false;
function getBillCityDepency(obj,BLOCKIDSETTING,FIELDIDSETTING)
{
    if(picklist==false)
    return ;
   
    var bill_state = document.getElementById('bill_state').value;
    var bill_country = document.getElementById('bill_country').value;
    var tabid=obj.value;
    window.location="index.php?module=Settings&action=Serviceperformance&parenttab=Settings&selectserverttab=2&selecttype=selected&billcityid="+tabid+'&bill_state='+bill_state+'&bill_country='+bill_country+"&blockidsetting="+BLOCKIDSETTING+"&fieldidsetting="+FIELDIDSETTING;
}
/**
 *@andrw: 
 *@date:20140825
 *@reason:服务绩效参数显示编辑
 *type:1.显示编辑框，2.隐藏编辑框
 *roleid：显示或隐藏的编辑框
 */
function vtlib_showeditinput_Server(type,roleid,countasrict)
{

    if(type == 1)
    {
      document.getElementById('editarea_'+roleid).style.display = 'block';
      document.getElementById('seetxtbox_'+roleid).style.display = 'none';
    }
    else
    {
     //   document.getElementById('txtbox_'+roleid).value = countasrict;
      document.getElementById('editarea_'+roleid).style.display = 'none';
      document.getElementById('seetxtbox_'+roleid).style.display = 'block';

    }
}

/**
 *@andrw: 
 *@date:20140825
 *@reason:服务绩效参数上限编辑保存
 */
function vtlib_saveServercount(countasrict,roleid)
{
    var count = document.getElementById('txtbox_'+roleid).value;
    var selectserverttab = document.getElementById('selectserverttab').value;
   // var type="^[0-9]\d*(\.\d+)?$";
    //var re = new RegExp(type);

    if(count==''){
        document.getElementById('txtbox_'+roleid).value = countasrict;   
        var confirm_str = arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return; 
    }
    else if(count < 0){
        document.getElementById('txtbox_'+roleid).value = countasrict;   
         var confirm_str = arrJsPopLabel['Must_number_greater_than_0'];
         RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return; 
    }
    else if(isNaN(count))
    {
         document.getElementById('txtbox_'+roleid).value = countasrict;   
         var confirm_str = arrJsPopLabel['Must_number_greater_than_0'];
         RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }else{
         $("status").style.display="inline";
        var data = "module=Settings&action=SettingsAjax&file=SaveServiceperformance&count=" +count + "&roleid="+roleid+"&ajax=true&seltab="+selectserverttab;
        new Ajax.Request(
		  'index.php',
            {queue: {position: 'end', scope: 'command'},
        	   method: 'post',
                postBody: data,
                onComplete: function(response) {
                    if(response.responseText.indexOf('SUCCESS')>-1){
                        document.getElementById('editarea_'+roleid).style.display = 'none';
                        document.getElementById('seetxtbox_'+roleid).style.display = 'block';
                        document.getElementById('txtbox_'+roleid).value = count;
                        document.getElementById('seetxtbox_'+roleid).innerHTML = commafy(count);
                        //alert(arrJsPopLabel['SUCCESSFULLYSAVED']);
                       $('status').hide();
                    }else if(response.responseText.indexOf('USEDEN')>-1)
                    {
                        var confirm_str = arrJsPopLabel['Savefailed'];
                        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
                        $('status').hide();
                    }
                }
		  }
	   );
    }

}
//千分位格式
function commafy(num) {   
//1.先去除空格,判断是否空值和非数   
num = num + "";   
num = num.replace(/[ ]/g, ""); //去除空格  
    if (num == "") {   
    return;   
    }   
    if (isNaN(num)){  
    return;   
    }   
    //2.针对是否有小数点，分情况处理   
    var index = num.indexOf(".");   
    if (index==-1) {//无小数点   
      var reg = /(-?\d+)(\d{3})/;   
        while (reg.test(num)) {   
        num = num.replace(reg, "$1,$2");   
        }   
    } else {   
        var intPart = num.substring(0, index);   
        var pointPart = num.substring(index + 1, num.length);   
        var reg = /(-?\d+)(\d{3})/;   
        while (reg.test(intPart)) {   
        intPart = intPart.replace(reg, "$1,$2");   
        }   
       num = intPart +"."+ pointPart;   
    }   
return num;   
}
//适用人员全选js  2014 0107
function select_all(checkel,groupname){
    var checkel=$(checkel);
    var thechecked=checkel.checked;
    var allcheckvals=$$('.StepUserClass');
    for(var i=0;i<allcheckvals.length;i++){
    var el=allcheckvals[i];
    var groupnameattr=el.getAttribute("groupname");
    if(groupnameattr==groupname)
    {
       el.checked=thechecked; 
    } 
  }
}
//保存模板打印适用人员 20140108
function SaveTemplatePrintAllocate(obj)
{
    var form=document.forms['frmTemplatePrint'];
    for(var i=0;i<form.elements.length;i++)
    {
         if(form.elements[i].name=='owners[]'&&form.elements[i].checked==true)
         {
            form.submit();
            return true;
         }
    }
    //form.submit();
    //请至少选择一个用户！
    var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];   
    RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
    return false;
}


/*
edit:can
date:20130814
reason:新增和编辑模板中选择模块事件
*/
function moduleSel(obj)
{
	var urlstring = '&tabid='+document.TemplatePrintform.printtabid.value+'&printtabid='+obj.value;
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'module=Settings&action=TemplatePrintField'+urlstring,
			onComplete: function(response) {
			 
				if(response.responseText.indexOf("SUCCESS")>-1){
				  var results=response.responseText.split("##SUCCESS##");
				  document.getElementById("tabField").innerHTML=results[1];
				}else
                {
                    var confirm_str = alert_arr.ERROR_WHILE_EDITING;
                     RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
                }
					
			}
		}
	);
}
/*
edit:can
date:20130815
reason:打印模板新增和编辑界面字段选择
*/
function fieldSel(obj)
{
    document.getElementById("selField").value="[var."+obj.value+"]";
    
}
/*
edit:can
date:20130815
reason:打印模板中插入模板
*/

function InsertTemplates(obj)
{
    if(trim(document.getElementById("selField").value )=="")
    {
        //请选择字段！
        var confirm_str = arrJsPopLabel['PLEASESELECTFIELD'];   
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return false;
    }

    /*
    * editor:gyq_05
    * reason:适配审批通知提醒
    * date  :2016 2 25
    * */
    var txtvalue=document.forms['frmsendInfoContent'].SelectField.options[document.forms['frmsendInfoContent'].SelectField.selectedIndex].text;

    if(txtvalue.length > 0){
        document.getElementById('CKcontent').value += document.getElementById("selField").value;
        ld('#CKcontent').focus();
    } else{

        var txtvalue=document.forms['TemplatePrintform'].SelectField.options[document.forms['TemplatePrintform'].SelectField.selectedIndex].text;

        var body = UE.getEditor('CKTemplatePrint').getContent();
        var value = UE.getEditor('CKTemplatePrint').focus();
    }





    //document.getElementsByTagName("iframe")[0].contentWindow.document.body.innerHTML('CKTemplatePrint',document.getElementById("selField").value);
    //bodyEditor.innerHTML('CKTemplatePrint',document.getElementById("selField").value);
    /*
    if ( CKTemplatePrint.mode == 'wysiwyg' )
    {	
		CKTemplatePrint.insertText( document.getElementById("selField").value );
	}
    */
}

function InsertHTML(value)
{
    //alert(value);
    //bodyEditor.html(document.getElementById("selField").value);
    /*
	if ( CKTemplatePrint.mode == 'wysiwyg' )
	{
		
		CKTemplatePrint.insertHtml( value );
	}
    else
    {
        //错误！
        alert(arrJsPopLabel['ERROR']);   
    }
    */
}
/*
删除模板

*/
function deletetemplateprint(obj,printid,BLOCKIDSETTING,FIELDIDSETTING)
{
    var printtabid=document.getElementById("TemplateModule").value;
    lingdangJS_DialogBox.block();
    
 
   new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module=Settings&action=TemplatePrintDelete&printtab="+printtabid+"&printid="+printid+"&Systemdefault=1&blockidsetting="+BLOCKIDSETTING+"&fieldidsetting="+FIELDIDSETTING ,
			onComplete: function(response) {
				if(response.responseText.indexOf("SUCCESS")>0)
                {
                     //确认要删除该打印模板吗？
                     RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['CONFIRMWANTDELETEPRINTTEMPLATE']);
                     ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                        window.location="index.php?module=Settings&action=TemplatePrintDelete&printtab="+printtabid+"&printid="+printid+"&blockidsetting="+BLOCKIDSETTING+"&fieldidsetting="+FIELDIDSETTING;
                     })    
                     lingdangJS_DialogBox.unblock();               
                }
				else
                {
                  //该模板为系统预置，不允许删除！
                  RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['SYSTEMTEMPLATECANOTDELETE']);
                  lingdangJS_DialogBox.unblock();
                }
					
			}
		}
		);
    
}
/*
edit:can
date;20130815
reason:打印模板保存
*/
function TemplatePrintSave(obj)
{
    
    if(trim(document.forms['TemplatePrintform'].templatename.value)=="")
    {
        //模板名称不能为空！
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['TEMPLATENAMECANOTEMPTY']);
        document.forms['TemplatePrintform'].templatename.focus();
        return false;
    }
    //lingdangJS_DialogBox.block();
     var templateprintname=encodeURIComponent(document.forms['TemplatePrintform'].templatename.value);
     var printtabid=document.forms['TemplatePrintform'].printtabid.value;
     var url='module=Settings&action=TemplatePrintSave&isDuplicate=true&printtabid='+printtabid+"&templatename="+templateprintname;
     if(document.forms['TemplatePrintform'].printid!=undefined)
     {
        url=url+"&printid="+document.forms['TemplatePrintform'].printid.value;
     }
    	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:url ,
			onComplete: function(response) {
				if(response.responseText.indexOf("SUCCESS")>-1)
                {
                    document.forms['TemplatePrintform'].submit();
                }
				else
                {  
                     //模板名称重复！
                     RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['TEMPLATENAMEREPEAT']);
                     lingdangJS_DialogBox.unblock();
                }
					
			}
		}
		);

}
function setTemplateDefault(obj)
{
    if(obj.checked)
    {
        obj.value=1
    }
    else
    {
        obj.value=0;
    }
}
var httpreq=null;
var NodeButton;
function RoleUser(obj,RoleID)
{
     httpreq=createXMLHTTP();
     NodeButton=obj;
     var urlparam='modules/Settings/RoleUser.php?roleid='+RoleID+'&parenttab=Settings&mode=Role2User';
     httpreq.open("POST",urlparam,true);
     httpreq.onreadystatechange=RoleAjax;
     httpreq.setRequestHeader("If-Modified-Since","0");
     httpreq.send(null);
     return false;
   
}
function RoleAjax()
{
      if(httpreq.readyState==4)
          {
              if(httpreq.status==0||httpreq.status==200)
              {
                RemindsMsg("","LdPopWidth400px",'',"yes","yes",httpreq.responseText);
                document.getElementById("Role2UserDiv").innerHTML= httpreq.responseText; 
                fnvshobj(NodeButton, "Role2User");    
              }
          }
}
/*
edit:can
date:20131205
reason:产品工具自定义字段属性修改
*/
function ProductToolEditField(obj,divid,id)
{

   if(ld('#cfList tr').hasClass('selectedbj')){
        ld('#cfList tr').removeClass('selectedbj');
    }
    //设置当前字段所在为黄色
    ld('input[name=producttoolfield'+id+']').parent().parent().addClass('selectedbj');
    $("status").style.display="inline";
	var tabid;
	if(document.getElementById('hiddentabid') != undefined){
		tabid = document.getElementById('hiddentabid').value;
	}

	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:"module=Settings&action=ProductToolEditField&id="+id+"&tabid="+tabid,
			onComplete: function(response) {
				$("status").style.display="none";
				results = response.responseText.split('&#&#&#');
				$("dvProductToolEditField").innerHTML=results[1];
				fnvshobj(obj, divid); 
                
			}
		}
	);
}
/*
edit:chj
date:2016-02-15
reason:显示自定义字段的排序界面
*/
function ShowFieldSort(obj,divid,sType){
	var tabid = ld("#selectmodule").val();
    $("status").style.display="inline";
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module=Settings&action=ProductToolSetupField&tabid="+tabid+"&type="+sType,
			onComplete: function(response) {
				$("status").style.display="none";
				var results = response.responseText.split('&#&#&#');
                $("sortview_form_div").update(results[1]);
				fnvshobj(obj, divid);
			}
		}
	);
}
/*
edit:chj
date:2016-02-15
reason:保存自定义字段的排序
*/
function saveFieldSort(obj,divid,tabid,stype){
	$("status").style.display="inline";
	var selectedFieldStr = "";
	if(document.getElementById('selectedColumns2')!=undefined){
		selectedColumnsObj=document.getElementById('selectedColumns2');
		for (i=0;i<selectedColumnsObj.options.length;i++){
			//获取模块所有自定义字段的排序顺序
			if(stype == 'Sort'){
				selectedFieldStr += selectedColumnsObj.options[i].value + ";";
			}else{
				//获取取消隐藏的所有自定义字段
				if(selectedColumnsObj.options[i].selected){
					selectedFieldStr += selectedColumnsObj.options[i].value + ";";
				}
			}
		}
	}
	//更新、保存自定义字段顺序
	if(selectedFieldStr != ''){
		new Ajax.Request(
			'index.php',
			{queue: {position: 'end', scope: 'command'},
					method: 'post',
					postBody:"module=Settings&action=SettingsAjax&file=ProductToolField&submode=UpdateField"+stype+"&tabid="+tabid+"&parenttab=Settings&ajax=true&selectedFieldStr="+selectedFieldStr,
					onComplete: function(response) {
						$("status").style.display="none";
						var strs= response.responseText.split('###SUCCESS###');
						document.getElementById("cfList").innerHTML=strs[1];
						fninvshnew(divid);
				  
					}
			}
		);
	}else{//0026798: 控制面板-单据分录定制：点击【显示隐藏字段】，弹出层中直接点击保存，结果弹出层没有关闭
	   $("status").style.display="none";
	   fninvshnew(divid);
	}
}
/*
edit:chj
date:2015/6/3
reason:更改产品工具自定义字段显示顺序
*/
function UpdateFieldSequence(obj,producttoolfieldid,tabid,sequence,optype){
	$("status").style.display="inline";
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:"module=Settings&action=SettingsAjax&file=ProductToolField&submode=UpdateFieldSequence&producttoolfieldid="+producttoolfieldid+"&tabid="+tabid+"&type="+optype+"&sequence="+sequence+"&parenttab=Settings&ajax=true",
				onComplete: function(response) {
					$("status").style.display="none";
					var strs= response.responseText.split('###SUCCESS###');
					document.getElementById("cfList").innerHTML=strs[1];
					fninvshnew('dvProductToolEditField');
			  
				}
		}
	);
}
/*
edit:chj
date:2015/6/3
reason:设置自定义字段用户权限
*/
var setproducttoolfielduser_idx = 0;
function setProductToolFieldUser(producttoolfieldid,module){
    if(ld('#cfList tr').hasClass('selectedbj')){
        ld('#cfList tr').removeClass('selectedbj');
    }
    //设置当前字段所在为黄色
    ld('input[name=producttoolfield'+producttoolfieldid+']').parent().parent().addClass('selectedbj');
	var tabid;
	var scopepopupobj;//自定义弹出层页面html，绑定事件
    var popup_caption_value = arrJsPopLabel['LBL_FIELDS_ACCESS'];//标题
	//重写header
	//var popup_header_html = '&nbsp;&nbsp;<span class="E_red_txt">'+arrJsPopLabel['NOTESELECTTHEUSERDOESNOTHAVETHEFIELDVIEWANDEDITPERMISSIONS']+'</span><br /><p style="margin-top:10px;">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'&nbsp;&nbsp;<input type="text" class="seniorinput" style="height:20px;" id=\'popup_locationdiv\' value=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER']+'\'><input class="seniorcheckbox" type="checkbox" id=\'viewuser_nogroupuser\'>'+arrJsPopLabel['SHOWNOGROUPUSER']+'</p>';
	var popup_header_html = '<p style="margin-top:10px;">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'&nbsp;&nbsp;<input type="text" class="seniorinput" style="height:20px;" id=\'popup_locationdiv\' value=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER']+'\'><input class="seniorcheckbox" type="checkbox" id=\'viewuser_nogroupuser\'>'+arrJsPopLabel['SHOWNOGROUPUSER']+'</p>';
    //重写查询框的下拉div
	var popup_searchTextDiv_html = '<div id=\'popup_search_div\' style=\'padding-left:59px;display: block;position: absolute;top: 99px;\'><div class=\'view-search\' ></div></div>';
	if(document.getElementById('hiddentabid') != undefined){
		tabid = document.getElementById('hiddentabid').value;
	}
	var selectuseridall = ld('#hidden_pro_profile_value').val();
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		scopepopupobj =  new ScopePopupObj(module);
        scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		scopepopupobj.popup_header = popup_header_html;
        scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认显示内容
		scopepopupobj.popup_searchTextDiv = popup_searchTextDiv_html;
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
           cls_ScopePopup.prop.popup_module = module;//模块
           cls_ScopePopup.prop.popup_value = selectuseridall;
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('.D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                  
                    ld('.D_pbtn .D_pbtncancel').click();
                    var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
					ld('#hidden_pro_profile_value').val(selected_user);
					 /*var urlstring = 'module=Settings&action=SettingsAjax&file=ProductToolField&frommodule='+module+'&producttoolfieldid='+producttoolfieldid+'&submode=setProductProfile&ajax=true&tabid='+tabid;
					if(!empty(selected_user)){
						urlstring +='&useridall='+selected_user;
					}
					RequestAjax(urlstring,function(response){
						if(empty(response)) return false;
						var strs= response.split('###SUCCESS###');
						document.getElementById("cfList").innerHTML=strs[1];
						fninvshnew('viewuserpopup');lingdangJS_DialogBox.unblock();
                        //设置当前字段所在为黄色
				        ld('input[name=producttoolfield'+producttoolfieldid+']').parent().parent().addClass('selectedbj');
                    
					});*/
					return false;
                });
            }
		});
	});
}
function deleteRole(obj,url)
{
    lingdangJS_DialogBox.block();//遮罩层  
    $("status").style.display="inline";
	url = url+"&DelRole=DelRole";
	//alert(url);
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
					$("status").style.display="none";
					var results=response.responseText.split('&#&#&#');
					if($("delprofile")!=undefined)
					{
						$("delprofile").innerHTML=results[1];
						fnvshobj(obj, 'delprofile');
					}
				}
		}
	);	
}

/*
edit:andy
date:20140310
reason:立即查找(用户使用分析表),
*/
function UserAnalySisSearch(obj,searchtype)
{
    var url='module=Settings&action=userloginanalysis';
    var useReportid=0;
    if(searchtype=='BasicSearch')
    {   
        var startmonth=document.getElementById('startmonth').value;
        var endmonth=document.getElementById('endmonth').value;
        var cversion=encodeURIComponent(document.getElementById('cversion').value);
        var city=encodeURIComponent(document.getElementById('city').value);
        var phone=document.getElementById('phone').value;
        url+='&startmonth='+startmonth+'&endmonth='+endmonth+'&cversion='+cversion+'&city='+city+'&phone='+phone;
        url+='&ajax=true&searchtype=BasicSearch';
        //$("status").style.display="inline";
        document.getElementById('status').style.display = 'inline';
        
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
                        document.getElementById('status').style.display = 'none';
                        var results=response.responseText.split("###SUCCESS###");
                        //$("UseReportList").innerHTML=results[1];
                        document.getElementById('UseReportList').innerHTML=results[1];
                         
                    }
                }
          )
    }
    
    //return false;
}

/**
 *@andrw: 
 *@date:20140826
 *@reason:公海客户上限类型显示隐藏
 *type:1.显示用户，2.显示角色
 */
function changeastricttype(type,count){

    if(type == 1)
    {
        document.getElementById('select_user_ASTRICTTYPE').disabled = false;
        document.getElementById('select_role_ASTRICTTYPE').style.display = 'none';
    }
    else
    {
        document.getElementById('select_role_ASTRICTTYPE').style.display = 'block'; 
        document.getElementById('select_user_ASTRICTTYPE').disabled = true;
        //document.getElementById('select_user_ASTRICTTYPE').value = count;
    }
}
/**
 *@andrw: 
 *@date:20140825
 *@reason:公海客户上限显示编辑
 *type:1.显示编辑框，2.隐藏编辑框
 *roleid：显示或隐藏的编辑框
 */
function vtlib_showeditinput_account(type,roleid,countasrict)
{
    if(type == 1)
    {
      document.getElementById('editarea_'+roleid).style.display = 'block';
      document.getElementById('seetxtbox_'+roleid).style.display = 'none';
    }
    else
    {
      document.getElementById('editarea_'+roleid).style.display = 'none';
      document.getElementById('seetxtbox_'+roleid).style.display = 'block';
      document.getElementById('txtbox_'+roleid).value = countasrict;
    }
}

/**
 *@andrw: 
 *@date:20140825
 *@reason:模公海客户上限编辑保存
 */
function vtlib_savecount(countasrict,roleid)
{
    var count = document.getElementById('txtbox_'+roleid).value;
    var type="^[0-9]*[1-9][0-9]*$";
    var re = new RegExp(type);
    if(count==''){
        document.getElementById('txtbox_'+roleid).value = countasrict;   
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['CANOTEMPTY']);
        return; 
    }
    else if(count.match(re)==null)
    {
         document.getElementById('txtbox_'+roleid).value = countasrict;   
         RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['Limitthenumbermustbeapositiveinteger']);
        return;
    }else{
        var data = "module=Settings&action=SettingsAjax&file=SaveAcctountAstrictRole&count=" +count + "&roleid="+roleid+"&ajax=true";
        new Ajax.Request(
		  'index.php',
            {queue: {position: 'end', scope: 'command'},
        	   method: 'post',
                postBody: data,
                onComplete: function(response) {
				    $('status').hide();
                    if(response.responseText.indexOf('SUCCESS')>-1){
                        document.getElementById('editarea_'+roleid).style.display = 'none';
                        document.getElementById('seetxtbox_'+roleid).style.display = 'block';
                        document.getElementById('txtbox_'+roleid).value = count;
                        document.getElementById('seetxtbox_'+roleid).innerHTML = count;      

                        RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['SUCCESSFULLYSAVED']);
                    }else if(response.responseText.indexOf('USEDEN')>-1)
                    {
                        RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['Savefailed']);
                    }
                }
		  }
	   );
    }

}
/**
 *@andy: 
 *@date:20140819
 *@reason:模块中英文名称保存
 *@version:v5.61
 */
 var prevtrobj=undefined;
function vtlib_showeditinput(event,type,modulename_zh,modulename_en)
{
    var e=event||window.event;
    var editobj=e.srcElement||e.target;//当前点击的编辑/取消按钮对象
    var nowtr=editobj.parentNode||editobj.parentElement;//当前编辑行父级(td)对象
    nowtr=nowtr.parentNode||nowtr.parentElement;//获取当前点击的编辑/取消按钮所在行(tr)
   
    
    var tddivobj=undefined;//td下 div
    var tdspnobj=undefined;//td下span
    var tdcell=undefined;//表格的单元格
   
    if(type == 1)//点击"编辑"按钮
    {
       //2:关闭/启用和编辑列
       //3:只修改中英文列的值，28808: 控制面板>模块管理：OA表单的模块，编辑后保存或者取消，备注列不显示“OA表单”
       for(var i=0;i<3;i++)//获取当前对象的单元格数 nowtr.cells.length -1为去掉操作列一个td,操作当前行下其余单元格下的div 和 span
       {
         /**
          *@edit:andy 
          *@date:20140828
          *@reason:每行增加序列号，JS报错
          *@version:v5.6
          */
         if(i==0)
            continue;
         tdcell=nowtr.cells[i];//单元格td对象
         
         tddivobj_input= tdcell.getElementsByTagName('input');//输入框input对象
         tdspnobj_span= tdcell.getElementsByTagName('span');//原显示span对象
		 if(tddivobj_input[0] != undefined){
			tddivobj_input[0].value=tdspnobj_span[0].innerHTML;//取消不改变原值
		 }
                // alert(tdspnobj_span[0].innerHTML);
         tddivobj= tdcell.getElementsByTagName('div');//单元格td对象下的div对象数组
		if(tddivobj[0] != undefined){
			tddivobj[0].style.display='block';//这里默认第一个对象样式改变
		}
		
         tdspnobj= tdcell.getElementsByTagName('span');//单元格td对象下的span对象数组
		 if(tdspnobj[0] != undefined){
			tdspnobj[0].style.display='none';//这里默认第一个对象样式改变
		 }
       }
     
        if(prevtrobj != undefined && nowtr != prevtrobj)
        {
             for(var i=0;i<3;i++)
               {
                 if(i==0)
                    continue;
                 tdcell=prevtrobj.cells[i];
                 tddivobj= tdcell.getElementsByTagName('div');
                 tddivobj[0].style.display='none';
                 tdspnobj= tdcell.getElementsByTagName('span');
                 tdspnobj[0].style.display='block';
               }
        }
     
         prevtrobj=nowtr;
         
        
    }
    else//点击保存按钮
    {
        
        //prevtrobj会在上次编辑但未保存的操作行定义
        if(prevtrobj!=undefined)
        {
          
             for(var i=0;i<prevtrobj.cells.length-1;i++)//获取上次操作对象的单元格数 -2为去掉操作列两个td,操作当前行下其余单元格下的div 和 span
               {
                 if(i==0)
                    continue;
                 tdcell=prevtrobj.cells[i];//获取上次操作行的单元格td对象
                 tddivobj= tdcell.getElementsByTagName('div');//单元格td对象下的div对象数组
                 
                 tddivobj_input= tdcell.getElementsByTagName('input');//输入框input对象
                 tdspnobj_span= tdcell.getElementsByTagName('span');//原显示span对象
                 tddivobj_input[0].value=tdspnobj_span[0].innerHTML;//取消不改变原值
                 tddivobj[0].style.display='none';
                 tdspnobj= tdcell.getElementsByTagName('span');//单元格td对象下的span对象数组
                 tdspnobj[0].style.display='block';
                 //更新成修改后的值
                 if(modulename_zh != '' && modulename_en != ''){
                    var tag = tdspnobj[0].getAttribute('tag');
                    if(tag == 'zh'){
                        tdspnobj[0].innerHTML = modulename_zh;
                    }else if(tag == 'en'){
                        tdspnobj[0].innerHTML = modulename_en;
                    }
                 }
                 
               }
        }
        prevtrobj=undefined;//取消事件则 prevtrobj 对象 = undefined
    }
    
}
/**
 *@andy: 
 *@date:20140819
 *@reason:模块中英文名称保存
 *@version:v5.61
 */
function vtlib_savemodulename(event,modulename_zh_id,modulenename_en_id,actionmodle,BLOCKIDSETTING,FIELDIDSETTING)
{
    
    var modulenename_zh=document.getElementById(modulename_zh_id).value;
    var modulenename_en=document.getElementById(modulenename_en_id).value;
    if(modulenename_zh == '' || modulenename_en == '')
    {
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['MODULENAMECANNOTBEEMPTY']);
        return false;
    }
    $('status').show();
    
    var data = "module=Settings&action=SettingsAjax&file=ModuleManager&actionmodle=" +actionmodle + "&modulenename_zh="+encodeURIComponent(modulenename_zh)+"&modulenename_en="+encodeURIComponent(modulenename_en)+"&ajax=true&blockidsetting="+BLOCKIDSETTING+"&fieldidsetting="+FIELDIDSETTING;
    new Ajax.Request(
		'index.php',
        {queue: {position: 'end', scope: 'command'},
        	method: 'post',
            postBody: data,
            onComplete: function(response) {
				$('status').hide();
				// Reload the page to apply the effect of module setting
                if(response.responseText.indexOf('SUCCESS')>-1){
                    //调用取消按钮事件并且赋值
                    vtlib_showeditinput(event,2,modulenename_zh,modulenename_en);
                } 
				else if(response.responseText.indexOf('USEDZH')>-1)
                {
                    RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['MODULECHINESENAMEALREADYEXISTS']);
                }
                else if(response.responseText.indexOf('USEDEN')>-1)
                {
                    RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['MODULEENGLISHNAMEALREADYEXISTS']);
                }
            }
		}
	);
}

/**
 *@edit:andy 
 *@date:20140909
 *@reason:左右选择项改进
 *@version:
 */
 if (document.all)

	var browser_ie=true

else if (document.layers)

	var browser_nn4=true

else if (document.layers || (!document.all && document.getElementById))

	var browser_nn6=true
function copySelectedOptionsSettingModule(source, destination) {

    //var srcObj = $(source);
	//var destObj = $(destination);
    var srcObj = document.getElementById(source);//$(source);
	var destObj = document.getElementById(destination);//$(destination);
	if(typeof(srcObj) == 'undefined' || typeof(destObj) == 'undefined') return;
    for(i=0;i<destObj.length;i++){
        destObj.options[i].selected=false;
    }
    for (i=0;i<srcObj.length;i++) {
		if (srcObj.options[i].selected==true) {
			var rowFound=false;
			var existingObj=null;
			for (j=0;j<destObj.length;j++) {
				if (destObj.options[j].value==srcObj.options[i].value) {
                    srcObj.options.remove(i);//无论默认有无，都去掉该备选项 ,               
					rowFound=true
					existingObj=destObj.options[j]
					break
				}
			}
			if (rowFound!=true) {
				var newColObj=document.createElement("OPTION")
				newColObj.value=srcObj.options[i].value
                if (browser_ie) 
                    newColObj.innerText=srcObj.options[i].innerText
				else if (browser_nn4 || browser_nn6) 
                    newColObj.text=srcObj.options[i].text
				destObj.appendChild(newColObj)//右键
				srcObj.options[i].selected=false
                srcObj.options.remove(i);
                i=-1;
				newColObj.selected=true
				rowFound=false
			} else {
				if(existingObj != null) 
                    existingObj.selected=true
			}
		}
	}
}


/**
 *@edit:andy 
 *@date:
 *@reason:左右结构点击事件
 *@version:
 */
function addColumn(source, destination) 
{
    var availListObj=getObj(source)
    var selectedColumnsObj=getObj(destination)


    for (i=0;i<availListObj.length;i++) 
    {
        if (availListObj.options[i].selected==true) 
        {            	
        	var rowFound=false;
        	var existingObj=null;
            for (j=0;j<selectedColumnsObj.length;j++) 
            {
                if (selectedColumnsObj.options[j].value==availListObj.options[i].value) 
                {
                    rowFound=true
                    existingObj=selectedColumnsObj.options[j]
                    break
                }
            }
            if (rowFound!=true) 
            {
                var newColObj=document.createElement("OPTION")
                newColObj.value=availListObj.options[i].value
                if (browser_ie) newColObj.innerText=availListObj.options[i].innerText
                else if (browser_nn4 || browser_nn6) newColObj.text=availListObj.options[i].text
                selectedColumnsObj.appendChild(newColObj)
                availListObj.options[i].selected=false
                newColObj.selected=true
                availListObj.remove(i);//20140902，diony，右移时删除左边信息
                rowFound=false
            } 
            else 
            {
                if(existingObj != null) existingObj.selected=true
            }
        }
    }
}
function updateMenu(obj){
	var tag = ld(obj).attr('tag');
  RemindsMsg("","LdPopWidth400px",'',"yes","yes",tag);
}
/**
 *@edit:chj 
 *@date:2015/3/31
 *@reason:权限管理、部门 设置成员事件
 *@version:V6.0 角色权限改进
 */
function clickOnBlurMember(obj){
	if(obj.value == '')
	{
		obj.value = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];
		obj.style.color='#999';
	}
}
/**
 *@edit:chj 
 *@date:2015/3/31
 *@reason:权限管理、部门 设置成员事件
 *@version:V6.0 角色权限改进
 */
function clickOnFoucusMember(obj){
	var membermessage = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];
	if(obj.value == membermessage)
	{
		obj.value="";
		obj.style.color='#000';
	}
}
/**
 *@edit:cyb
 *@date:2016-02-24
 *@reason:【控制面板】-【员工轨迹组】新增或者编辑事件
**/
function CreateTracks(trackpostion_id,operatetype)
{   
    lingdangJS_DialogBox.block();//遮罩层  
    $("status").style.display="inline";
	url = 'module=Settings&action=EditTracks&trackpostion_id='+trackpostion_id+'&operatetype='+operatetype;	
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
					$("status").style.display="none";
					var results=response.responseText.split('&#&#&#');
					if($("EditTrackProfile")!=undefined)
					{
						$("EditTrackProfile").innerHTML=results[1];
						fnvshobj(obj, 'EditTrackProfile');
					}                   
				}
		}
	);	
}
/**
 *@edit:cyb
 *@date:2016-02-25
 *@reason:保存员工轨迹定位组信息；
 **/
function SaveTrackPostion(trackpostion_id)
{
    var operatetype=document.getElementById('operatetype').value;
    var trackpostion=document.getElementById('trackpostion').value;       
    var starttime=document.getElementById('starttime').value;    
    var stoptime=document.getElementById('stoptime').value;
    var workcalender_id=document.getElementById('workcalenderid').value;   
    var blockidsetting =document.getElementById('blockidsetting').value;
    var fieldidsetting =document.getElementById('fieldidsetting').value;
    if(trim(trackpostion)=='') 
    {
       var confirm_str = arrJsPopLabel['TRACKGROUPNAME']+arrJsPopLabel['CANOTEMPTY'];
       RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
       var currObj = getObj("trackpostion");
       currObj.focus();
       return false;
    } 
    if(trim(starttime)=='') 
    {
       var confirm_str = arrJsPopLabel['STARTDATE']+arrJsPopLabel['CANOTEMPTY'];
       RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
       return false;
    }
    if(trim(stoptime)=='') 
    {
       var confirm_str = arrJsPopLabel['ENDDATE']+arrJsPopLabel['CANOTEMPTY'];
       RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
       return false;
    }  
    if(trim(stoptime)<=trim(starttime)) //结束日期不得小于开始日期
    {
       var confirm_str = arrJsPopLabel['ENDTIME']+arrJsPopLabel['GREATETHAN']+arrJsPopLabel['BEGINTIME'];
       RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
       return false;
    }     
	url = 'module=Settings&action=SaveTracks&trackpostion_id='+trackpostion_id+'&operatetype='+operatetype;	
    url+='&trackpostion='+trackpostion+'&starttime='+starttime+'&stoptime='+stoptime+'&workcalender_id='+workcalender_id;
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {				   
					if(trim(response.responseText)=='Duplicate')
					{                    
                       var confirm_str = arrJsPopLabel['POSITIONINGGROUPNAMECANNOTBEREPEATED'];
                       RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
                       var currObj = getObj("trackpostion");
                       //document.getElementById('trackpostion_name').value=="";                       
                       currObj.focus();                                          
                       return false;					  
                    }                        
         window.location="index.php?module=Settings&action=listtracks&blockidsetting="+blockidsetting+"&fieldidsetting="+fieldidsetting;
                    }
          }     
     );
       
 }
 /**
  *@edit:cyb
  *@date:2016-02-26
  *@reason:显示工作日历管理弹出层界面；
 **/
 function ShowWorkingSpace(start){  
    
    ld('#EditTrackProfile').hide();
    lingdangJS_DialogBox.block();//遮罩层  
    $("status").style.display="inline";
	url = 'module=Settings&action=ShowWorkingSpace&start='+start;	
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
					$("status").style.display="none";
					var results=response.responseText.split('&#&#&#');
					if($("listworkcalender")!=undefined)
					{
						$("listworkcalender").innerHTML=results[1];
						fnvshobj(obj, 'listworkcalender');
					}                   
				}
		}
	);	
    
 }
/**
 *@edit:cyb
 *@date:2016-02-26
 *@reason:弹出层分页刷新事件
**/
function getPopEntries_js(start){
    ShowWorkingSpace(start);
}
/**
*edit:cyb
*date:2016-05-25
*reason: bug:21563:控制面板>轨迹定位组：新增轨迹定位组>工作日历管理>新增工作日历，翻页组件 无效
**/
function getWorkingSpace_js(start){
    ShowWorkingSpace(start);
}
/**
 *@edit:cyb
 *@date:2016-02-26
 *@reason:显示工作日历管理编辑或新增界面
 **/
 function  EditWorkingSpace(id,operatetype,start_spec_year,start_hol_year,pop_portion,selected_date){
    ld('#listworkcalender').hide();
    lingdangJS_DialogBox.block();//遮罩层  
    $("status").style.display="inline";
    //attr_selectdate=ld('#attr_selectdate').val();
    attr_selectdate=selected_date;
	url = 'module=Settings&action=EditWorkingSpace&workcalender_id='+id+'&operatetype='+operatetype+'&start_spec_year='+start_spec_year+'&start_hol_year='+start_hol_year+'&pop_portion='+pop_portion;   
	url+='&attr_selectdate='+attr_selectdate;
    new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {				    
					$("status").style.display="none";
					var results=response.responseText.split('&#&#&#');
                    if(trim(pop_portion)!=''&&trim(pop_portion)=='all_poptable'){//刷新整个弹出层                   
                        if($("EditWorkingSpace")!=undefined)
    					{
    						$("EditWorkingSpace").innerHTML=results[1];
    						fnvshobj(obj, 'EditWorkingSpace');
                            var spec_year=ld('#specialworkingday .mar_lr5').text(); 
                            var hol_year=ld('#holiday_valcation .mar_lr5').text();     
                            ld('#special_'+spec_year).attr("style", "display:block;");  
                            ld('#hol_'+hol_year).attr("style", "display:block;");
    					}                         
                    }else{
                        if($("workingday")!=undefined)//刷新日期
    					{
    						$("workingday").innerHTML=results[1]; 
                            var spec_year=ld('#specialworkingday .mar_lr5').text(); 
                            var hol_year=ld('#holiday_valcation .mar_lr5').text();     
                            ld('#special_'+spec_year).attr("style", "display:block;");  
                            ld('#hol_'+hol_year).attr("style", "display:block;");   					
    					} 
                    }
                    					                 
				}
		}
	);	
 }
 /**
 *@edit:cyb 
 *@date:2016-03-01
 *@reason:工作日历管理编辑保存界面工作日刷新事件
 **/
 function getWorkingdayEntries_js(type,pop_portion)
 {
     if(pop_portion=='pop_special'){
        var spec_year=ld('#specialworkingday .mar_lr5').text(); 
        if(type=='pre'){
             spec_year=parseInt(spec_year)-1;
        }else{
            spec_year=parseInt(spec_year)+1; 
            
        }
        ld('#specialworkingday .mar_lr5').text(spec_year);  
        ld('#specialworkingday .holidaydate').attr("style", "display:none;");
        ld('#special_'+spec_year).attr("style", "display:block;"); 
     }else{
        var hol_year=ld('#holiday_valcation .mar_lr5').text();
        if(type=='pre'){
             hol_year=parseInt(hol_year)-1;
        }else{
            hol_year=parseInt(hol_year)+1;   
        }
        ld('#holiday_valcation .mar_lr5').text(hol_year);  
        ld('#holiday_valcation .holidaydate').attr("style", "display:none;");
        ld('#hol_'+hol_year).attr("style", "display:block;");
     }
 }
 /**
 *@edit:cyb
 *@date:2016-03-01
 *@reason:工作日历管理保存事件 
 **/
 function SaveWorkingSpace(id,operatetype)
 {    
    var workcalender_name=document.getElementById('workcalender_name').value; //日历名称  
    if(trim(workcalender_name)=='') 
    {
        var confirm_str = arrJsPopLabel['CALENDERNAME']+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        var currObj = getObj("workcalender_name");
        currObj.focus(); 
        return false;
    }
    var defworkday=document.getElementsByName('defworkday');    
    var strarr=new Array();
    for(var i=0;i<defworkday.length;i++){
        if(defworkday[i].checked == true)
        {
            strarr[i]=1;
        }
        else{
            strarr[i]=0;
        }       
    }
    var strdefworkday=strarr.join(',');//获取复选框选中星期 
    var special=ld("#specialworkingday  span ").text();
    var holiday=ld("#holiday_valcation  span").text();
    var def_workingday=ld("#def_workingday ").val();
   	var url = 'module=Settings&action=SaveWorkingSpace&workcalender_id='+id+'&operatetype='+operatetype;	
    url+= '&workcalender_name='+workcalender_name+'&defworkday='+strdefworkday;
    url+='&special='+special+'&holiday='+holiday+'&def_workingday='+def_workingday;
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {			
				if(trim(response.responseText)=='Duplicate')
				{                    
                   var confirm_str = arrJsPopLabel['WORKCALENDERCANNOTBEREPEATED'];
                   RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
                   var currObj = getObj("workcalender_name");                   
                   currObj.focus();                                     
                   return false;					  
                }
                fninvshnew('EditWorkingSpace');//保存完之后关闭当前弹出层                  
                ShowWorkingSpace(1); //显示工作日历列表
                changeSelectWorkingCalender();//动态改变新增或者编辑轨迹定位组弹出层工作日历下拉框取值 ；      
           }
        }     
     );   
 }
 /**
  *@edit:cyb
  *@date:2016-03-02
  *@reason:工作日历管理界面”添加“按钮事件
 **/
 function AddWorkingday(id,operatetype,languageType,workingdaytype){
    ld('#EditWorkingSpace').hide();
    lingdangJS_DialogBox.block();//遮罩层  
    $("status").style.display="inline";
    var	url = 'module=Settings&action=SettingsAjax&file=AddWorkingday&workcalender_id='+id+'&workingdaytype='+workingdaytype+'&operatetype='+operatetype;	
    
    //alert(url);
    if(languageType=='zh') {
        var dNMin=['日','一', '二', '三', '四', '五', '六'];
        var mNam=['一月','二月','三月','四月','五月','六月','七月','八月','九月','十月','十一月','十二月'];
        var preMonth='上月';
        var nextMonth='下月';
        
    }  
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
					$("status").style.display="none";
					var results=response.responseText.split('&#&#&#');
					if($("addWorkingday")!=undefined)
					{
						$("addWorkingday").innerHTML=results[1];
                        ld('#calenderview').multiDatesPicker({
                            	altField: '#altField', //设置保存选中日期值ID；
                                dayNamesMin: dNMin, //设置一周每天的格式;
                                dateFormat: 'yy-mm-dd', //设置日期格式； 
                                firstDay: 1 , //设置星期一为第一天
                                monthNames:mNam, // 设置月份显示格式;
                                prevText :preMonth,
                                nextText :nextMonth
                        });
						fnvshobj(obj, 'addWorkingday');                        
					}                   
				}
		}
	);   
 }
  /**
  *@edit:cyb
  *@date:2016-03-03
  *@reason:添加特殊工作日保存事件
 **/
 function SaveWorkingday(id,workingdaytype,operatetype)
 {
    var selected_date=ld('#altField').val();
    var remark = ld('#remark').val();
    if(empty(remark)){//备注不能为空
        var confirm_str = document.getElementById('remark').title+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        var currObj = getObj("remark");                   
            currObj.focus(); 
        return false;
    }
    if(trim(selected_date).length<1){//至少选择一个日期
        var confirm_str = arrJsPopLabel['PLEASESELECTADATEATLEAST'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return false;
    }
    var special=ld("#specialworkingday  span ").text();
    var holiday=ld("#holiday_valcation  span").text();
    var spec_year=ld('#specialworkingday .mar_lr5').html();
    var hol_year=ld('#holiday_valcation .mar_lr5').html(); 
    var url = 'module=Settings&action=SaveWorkingday&workcalender_id='+id+'&workingdaytype='+workingdaytype;	
    url+= '&selected_date='+selected_date+'&remark='+remark+'&operatetype='+operatetype;
    url+='&special='+special+'&holiday='+holiday;
    //alert(url);
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {			
			   	results=response.responseText.split('##&&');
                fninvshnew('addWorkingday');
                showPopDiv('EditWorkingSpace');//显示编辑工作日历弹出层
                //ld('#attr_selectdate').val(results[1]);
                var selected_date=results[1];
                EditWorkingSpace(id,operatetype,spec_year,hol_year,'switch',selected_date); 
                
           }
        }     
     );
 }
/**
 *@edit:cyb
 *@date:2016-03-03
 *@reason:删除特殊工作日
**/
function DeleteWorkingday(date,falsh_portion)
{
    if(!confirm(arrJsPopLabel['SUREWANTDELETE']))
    {
      return false;
    }    
    if(falsh_portion=='special')//特殊工作日
    {
       ld('#specialworkingdays_'+date).remove(); 
    }
    else{  //节假日
       ld('#holiday_valcation_'+date).remove();  
    }
}
/**
 *@edit:cyb
 *@date:2016-03-03
 *@reason:删除工作日历
**/
function DeleteWorkingcalender(id,start){
    if(!confirm(arrJsPopLabel['SUREWANTDELETE']))
    {
      return false;
    }     
    ld('#workcalender_'+id).remove();   
    ld('#listworkcalender .listEntries tr').each(function(index,el){//刷新工作日历列表
        if(index!=0)
        {
            ld(el).find('td').eq(0).html(index);
        }        
     }  
    )  
    if(ld('#listworkcalender .listEntries tr').length==1){
        start=start-1;
    } 
    var url='module=Settings&action=DeleteWorkingcalender&workcalender_id='+id;
    new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {		
				  ShowWorkingSpace(start); //显示工作日历列表  
                  changeSelectWorkingCalender();//动态改变新增或者编辑轨迹定位组弹出层工作日历下拉框取值 ； 
              }
          }     
     );
}
/**
*@edit:cyb
*@date:2016-03-03
*@reason:删除员工轨迹定位组
*/
function DeleteTrackPostion(id)
{    
    if(!confirm(arrJsPopLabel['SUREWANTDELETE']))
    {
      return false;
    }
    var blockidsetting =document.getElementById('blockidsetting').value;
    var fieldidsetting =document.getElementById('fieldidsetting').value;      
    //ld('#'+rowid).remove(); 
    var url='module=Settings&action=DeleteTrackPostion&trackpostion_id='+id;
    new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
				    
				window.location="index.php?module=Settings&action=listtracks&blockidsetting="+blockidsetting+"&fieldidsetting="+fieldidsetting;
                    }
          }     
     ); 
}
/**
*@edit:cyb
*@date:2016-03-03
*@reason:分配员工轨迹定位组；
**/
function AllocateTrackGroup(trackpostion_id,selected_userid)
{   
	var scopepopupobj;
    var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_module=Users&popup_inputtype=checkbox&popup_selecttype=user';
    getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		var methodObj = {'popup_check_inactiveuser':'no'};
		scopepopupobj =  new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = arrJsPopLabel['DISTRIBUT'];//标题title
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
		   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
           cls_ScopePopup.prop.popup_module = module;//模块
		   cls_ScopePopup.prop.popup_value = selected_userid;
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                    //没有选择任何用户，则给出提示
                    if(empty(cls_ScopePopup.return_obj.return_id)){
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
                        return false;
                    }else{
                        var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                        var urlstring = 'module=Settings&action=SettingsAjax&file=AllocateTrackGroup&selecteduserid='+selected_user+'&trackpostion_id='+trackpostion_id;
						new Ajax.Request("index.php",
						{
							queue:{
								position:"end",
								scope:"command"
							},
							method:"post",
							postBody:urlstring,
							onComplete:function (response) {
								window.location.reload();return false;
							}
						}); 
                    }
                });
            }
		});
	});
}
var trackpostion={id:0};
var setuserid = function(obj,userobj){   
    if(obj!='cancel')//点击确定按钮时，获取到选中的用户，执行保存操作；
    {
        /* eidtor:gyq_14 date:20160718 */
     selecteduserid=obj.value;//获取分配时选择到的用户；
     var blockidsetting =document.getElementById('blockidsetting').value;
     var fieldidsetting =document.getElementById('fieldidsetting').value;     
     var url='module=Settings&action=AllocateTrackGroup&selecteduserid='+selecteduserid+'&trackpostion_id='+trackpostion.id;   
     new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {				  
				window.location="index.php?module=Settings&action=listtracks&blockidsetting="+blockidsetting+"&fieldidsetting="+fieldidsetting;
                    }
          }     
     );       
   }     
}
/**
 *edit:cyb
 *date:2016-05-19
 *reason:其他设置中帮我吧接口下点击编辑之后，保存时，密钥等校验；
**/
function checkbangwo8info(){
    var vendorid=document.getElementById('vendorid').value;
    var authcode=document.getElementById('authcode').value;
  	var presence = document.getElementById('presence').value;
  
	if(presence == 0){
		if(empty(vendorid)){
			var confirm_str = document.getElementById('vendorid').title+arrJsPopLabel['CANOTEMPTY'];
      RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
			document.getElementById('vendorid').focus();    	 
			return false;
		}
		if(empty(authcode)){
			var confirm_str = document.getElementById('authcode').title+arrJsPopLabel['CANOTEMPTY'];
      RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
			document.getElementById('authcode').focus();
			return false;
		}
	}

  var is_customer = document.getElementById('is_customer').value;
  var supportname = document.getElementById('supportname').value;
  var supportpwd = document.getElementById('supportpwd').value;
  if(is_customer == 0){
    if(empty(supportname)){
      var confirm_str = document.getElementById('supportname').title+arrJsPopLabel['CANOTEMPTY'];
      RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
      document.getElementById('supportname').focus();       
      return false;
    }
    if(empty(supportpwd)){
      var confirm_str = document.getElementById('supportpwd').title+arrJsPopLabel['CANOTEMPTY'];
      RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
      document.getElementById('supportpwd').focus();
      return false;
    }
  }
  var columnlist = new Array();
  var k = 0;
	for(var i=0; i<=100;i++){
		if(ld('#fcol'+i).val() != undefined && ld('#fcol'+i).val() != ''){
			columnlist[k] = new Array();
			columnlist[k].push(ld('#fcol'+i).val());
			columnlist[k].push(ld('#fop'+i).val());
			columnlist[k].push(ld('#fval'+i).val());
			columnlist[k].push(ld('#fcon'+i).val());
			k++;
		}
	}
	var url='module=Settings&action=SettingsAjax&file=bangwo8interface&presence='+presence+'&vendorid='+vendorid+'&authcode='+authcode+'&editinterface=editinterface&supportname='+supportname+"&supportpwd="+supportpwd+"&is_customer="+is_customer+"&columnlist="+JSON.stringify(columnlist);
	//alert(url);
	//return false;
	new Ajax.Request(
		'index.php',
		 {queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
					var results=trim(response.responseText);
					if(results.indexOf("ISNULL")>0 && presence != 1){//判断密钥或者vendorid是否正确；
					  var confirm_str = arrJsPopLabel['KEYORVENDORIDISERRORPLEASEENTERAGAIN'];
						RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
					  return false;
					}else if(results.indexOf("NOURL")>0 && presence != 1){//判断帮我吧url是否可以访问
					  var confirm_str = arrJsPopLabel['crmserver'];
						RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
					  return false;
					}else if(results.indexOf("INCORRECT")>0 && presence != 1){//帮我吧客服账号或者密码错误！
						var confirm_str = arrJsPopLabel['bangwobauserpwd'];
						RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
						return false;
					}
					else{
					  var blockidsetting = ld('#blockidsetting').val();
					  var fieldidsetting = ld('#fieldidsetting').val();
					  window.location="index.php?module=Settings&action=bangwo8interface&parenttab=Settings&blockidsetting="+blockidsetting+"&fieldidsetting="+fieldidsetting;
					}
				}
		  }     
	);
   
}
function setBwText(){
	if(document.getElementById("presence").checked){
    ld('#presence').val(0);
    ld('#vendorid').attr("disabled",false);
    ld('#authcode').attr("disabled",false);
    ld('#tr_vendorid').show();
    ld('#tr_authcode').show();
	}else{
    ld('#presence').val(1);
    ld('#vendorid').attr("disabled",true);
    ld('#authcode').attr("disabled",true);
    ld('#tr_vendorid').hide();
    ld('#tr_authcode').hide();
	}
}
/**
 *edit:cyb
 *date:2016-05-20
 *reason:设置帮我吧客服账号信息
 **/
/* gyq_14 */
function settingsBangwo8info(obj,bangwo8supportnameid){
	 lingdangJS_DialogBox.block();//遮罩层  
	 $("status").style.display="inline";
	 var url='module=Settings&action=settingsBangwo8info&bangwo8supportnameid='+bangwo8supportnameid;   
	 new Ajax.Request(
		'index.php',
		 {queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
					$("status").style.display="none";
					var results=response.responseText.split('&#&#&#');
					if($("settingsBangwo8info")!=undefined)
					{
						$("settingsBangwo8info").innerHTML=results[1];

                        getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){

                            ScopePopup_Details.getInstance().allocateTemplate('',-5,bangwo8supportnameid,'','','settingsBangwo8info');
                        });
                        fnvshobj(obj, 'settingsBangwo8info');

						
						getJsScript('include/js/Bangwo.js',function(){
							new bangwo();
						});
					}
				}
		  }     
	 ); 
}
/**
 *edit:cyb
 *date:2016-05-20
 *reason:帮我吧设置按钮弹出层中，保存事件处理；
**/
/* gyq_14XX  Has been deleted   function SaveBangwo8info(bangwo8supportnameid,supportname){*/

/**
    *edit:cyb
    *date:2016-05-18
    *reason:调用帮我吧接口，根据crm客户信息修改帮我吧系统公司信息
**/
function Setbangwo8info(operate){
     var url='module=Settings&action=Setbangwo8interface&parenttab=Settings&operate='+operate;    
	// alert(url);return false;
     $("status").style.display="inline";
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
					var results=trim(response.responseText);
					if(results.indexOf("NOURL")>0){//判断帮我吧url是否可以访问
					  var confirm_str = arrJsPopLabel['crmserver'];
            RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
					  return false;
					}else{
						$("status").style.display="none";
						var confirm_str = arrJsPopLabel['CRMSYSTEMSYNCHRONIZED'];//CRM系统的客户和联系人成功同步到帮我吧系统
            RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
						return false;
					}
                     
                }
            }
        )
}
/**
*reason:0021564: 控制面板>轨迹定位组：新增轨迹定位组>工作日历管理>新增工作日历，返回至“新增轨迹定位组”弹出层，点击“工作日历”下拉框，没有该工作日历
*edit:cyb
*date:2016-07-20
*/
function changeSelectWorkingCalender(){
     var trackpostion_id=document.getElementById('trackpostion_id').value;
     var url='module=Settings&action=SettingsAjax&file=changeSelectWorkingCalender&trackpostion_id='+trackpostion_id;    
     $("status").style.display="inline";
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
                     $("status").style.display="none";
					 var results=response.responseText.split('&#&#&#');
                     ld("#workcalenderid").html(results[1]);
                     return false;
                }
            }
        )
}
//显示隐藏的弹出层
function showPopDiv(id){
    ld('#'+id+'').show();
    lingdangJS_DialogBox.block();//遮罩层 
 }
 
//税率设定编辑
function editTaxConfig(taxid,type){
    if(type == 1){    //编辑
        ld('span[tag=showspan]').show();
        ld('div[tag=hiddendiv]').hide();
        ld('#span_tax_'+taxid).hide();
        ld('#div_tax_'+taxid).show();
        ld('#span_rate_'+taxid).hide();
        ld('#div_rate_'+taxid).show();
    }else{  //取消
        ld('span[tag=showspan]').show();
        ld('div[tag=hiddendiv]').hide();
        //取消时将input value值还原
        ld('#div_tax_'+taxid+' input').attr('value',ld('#span_tax_'+taxid).text());
        ld('#div_rate_'+taxid+' input').attr('value',parseFloat(ld('#span_rate_'+taxid).text()).toFixed(3));
    }
}

//税率设定保存
function saveTaxConfig(taxid,taxname){
    var tax = ld('#div_tax_'+taxid+' input').val();
    var taxrate = ld('#div_rate_'+taxid+' input').val();
    var url='module=Settings&action=SettingsAjax&file=TaxConfig&ajax=true&savetax=yes&taxid='+taxid+'&tax='+tax+'&taxname='+taxname+'&taxrate='+taxrate;
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
				 $("TaxConfigContents").update(response.responseText);
                 return false;
            }
        }
    )
}

//税率设定启用、停用切换
function toggleTaxConfig(taxname,status){
    var url='module=Settings&action=SettingsAjax&file=TaxConfig&ajax=true&changestatus=yes&taxname='+taxname+'&deleted='+status;
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
				 $("TaxConfigContents").update(response.responseText);
                 return false;
            }
        }
    )
}

function CloseDivSendInformContent(idname,divold){



    divold = 'approvestep';

    var divold=document.getElementById(divold);
    divold.style.display="inline";
    //29270: 控制面板>审批流程管理：审批通知，点击审批通知的“设置提醒内容”弹出框的【取消】按钮，结果：没有显示审批步骤弹出层，而是显示了遮罩层
    //fninvshnew(idname);
    fninvshnew(divold);
 

}
function SaveSendInfoContent(obj)
{
    var textRecipient=ld("#CKcontent").val();
    if(textRecipient==''){
        //内容模板为空！
        var confirm_str = arrJsPopLabel['CONTENTTEMPLATEEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return false;
    }
    
	//系统参数审批步骤页


		ld('#div_approveRemindsContent').parent().next().find('textarea').val(textRecipient);

		ld("divSendInform_content_div").innerHTML='';
		ld('#div_approveRemindsContent').removeAttr("id");
            document.forms['frmsendInfoContent'].module.value='Settings';
	//	CloseDivSendInformContent('divSendInform_content','approvestep');
	
    var popupobj=CrmPopup.getPopupObj("last");
    popupobj.CancelEvent();
     var divold=document.getElementById("approvestep");
    divold.style.display="inline";

}
SaveSendInfoContent.funname='SaveSendInfoContent';

//页面设置：编辑属性
var fun_editField = function(fieldid,uitype,frommodule){
	if(!empty(fieldid) && !empty(uitype)){
		ld.ajax('index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList_EditField&fieldid='+fieldid+'&uitype='+uitype+'&frommodule='+frommodule)
		.done(function(response){
			$('layoutlist_editfield_div').innerHTML=response;
			fnvshobj(this, 'layoutlist_editfield');
            if(uitype==33)
            {
               
                ld("#defaultvalue_"+fieldid).select2({closeOnSelect: false});
                
            }
		})
	}
	//fnvshobj(this,'editfield_{$value.fieldselect}');isuitypedisp({$value.fieldselect},{$value.uitype});
}
//页面设置：新增区块
var fun_createblock = function(frommodule){
	ld.ajax('index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList_CreateBlock&frommodule='+frommodule)
	.done(function(response){
		$('layoutlist_createblock_div').innerHTML=response;
		fnvshobj(this, 'layoutlist_createblock');
	})
}


//菜单定制
function CustomScope(){
	
}
CustomScope.setAllUser = function(){
	ld('#customscope_type').val('all');
	ld('#customscope_ids').val('');
}

//选用户
CustomScope.setScopeUser = function(ids){
	var module = 'Home';
	var popup_caption_value = arrJsPopLabel['SELECT']+arrJsPopLabel['LBL_USERS']; 
    var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		var methodObj = {'popup_check_inactiveuser':'yes'};
		scopepopupobj =  new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
		   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
           cls_ScopePopup.prop.popup_module = module;//模块
		   cls_ScopePopup.prop.popup_value = ids;
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                    //没有选择任何用户，则给出提示
                    if(empty(cls_ScopePopup.return_obj.return_id)){
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
                        return false;
                    }else{
                        var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
						ld('#customscope_type').val('user');
						ld('#customscope_ids').val(selected_user);
						ld('.D_pbtn .D_pbtncancel').click();
                    }
                });
            }
			scopepopupobj.setEventBtnCancel=function(){
				 //关闭事件
				ld('#'+cls_ScopePopup.popup_divid+' .D_pop_tit .D_ptitc').unbind('click').on('click',function(){
					ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
					return false;
				});
				//取消事件
				ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').unbind('click').on('click',function(){
					ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').trigger('closediv');
				});
				ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').unbind('closediv').on('closediv',function(){
					var customscope_type = ld('#customscope_type').val();
					ld('#view_scope').find('input[name="radioUser"]').each(function(i){
					
						if(customscope_type==ld(this).val()){
							ld(this).prop('checked',true);
						}
						
					});
					fninvshnew(cls_ScopePopup.popup_divid);
					if(ld('#'+cls_ScopePopup.popup_divid).length > 0){
						//删除div
						var divobj = ld('#'+cls_ScopePopup.popup_divid).get(0);
						divobj.parentNode.removeChild(divobj);
					}
				});
				return true;
			}
		});
	});
}

//选部门
CustomScope.setScopeGroup = function(ids){
	var module = 'Home';
	var popup_caption_value = arrJsPopLabel['SELECT']+arrJsPopLabel['USERGROUPLIST']; 
    var popup_url = 'module=Users&action=UsersAjax&file=viewgroupinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=group';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		var methodObj = {'popup_check_inactiveuser':'yes'};
		scopepopupobj =  new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];//查询框默认值
		scopepopupobj.popup_header = '<p style="margin-top:10px;">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'&nbsp;&nbsp;<input type="text" class="seniorinput"  id=\'popup_locationdiv\' value=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP']+'\'></p>';
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
		   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
           cls_ScopePopup.prop.popup_module = module;//模块
		   cls_ScopePopup.prop.popup_value = ids;
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                    if(empty(cls_ScopePopup.return_obj.return_id)){
                        var confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
                        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
                        return false;
                    }else{
                        var selected_user = cls_ScopePopup.return_obj.return_id;//选中的部门
						ld('#customscope_type').val('group');
						ld('#customscope_ids').val(selected_user);
						ld('.D_pbtn .D_pbtncancel').click();
                    }
                });
            }
			scopepopupobj.setEventBtnCancel=function(){
				 //关闭事件
				ld('#'+cls_ScopePopup.popup_divid+' .D_pop_tit .D_ptitc').unbind('click').on('click',function(){
					ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
					return false;
				});
				//取消事件
				ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').unbind('click').on('click',function(){
					ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').trigger('closediv');
				});
				ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').unbind('closediv').on('closediv',function(){
					var customscope_type = ld('#customscope_type').val();
					ld('#view_scope').find('input[name="radioUser"]').each(function(i){
					
						if(customscope_type==ld(this).val()){
							ld(this).prop('checked',true);
						}
						
					});
					fninvshnew(cls_ScopePopup.popup_divid);
					if(ld('#'+cls_ScopePopup.popup_divid).length > 0){
						//删除div
						var divobj = ld('#'+cls_ScopePopup.popup_divid).get(0);
						divobj.parentNode.removeChild(divobj);
					}
				});
				return true;
			}
		});
	});
}

//选择角色
function selectPopupProfile(div_hidden_id,div_title){
	if(ld('#'+div_hidden_id) != undefined){
		var ids = ld('#'+div_hidden_id).val();
		var module = 'Users';
		var popup_caption_value = arrJsPopLabel['SELECT']+div_title; 
		var popup_url = 'module=Users&action=UsersAjax&file=viewprofileinfo&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=profile';
		getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
			var methodObj = {'popup_check_inactiveuser':'no'};
			scopepopupobj =  new ScopePopupObj(methodObj);
			scopepopupobj.popup_caption_value = popup_caption_value;//标题title
			scopepopupobj.popup_searchvalue = arrJsPopLabel['pleaseenterprofile'];//查询框默认值
			scopepopupobj.popup_header = '<p style="margin-top:10px;">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'&nbsp;&nbsp;<input type="text" class="seniorinput"  id=\'popup_locationdiv\' value=\''+arrJsPopLabel['pleaseenterprofile']+'\'></p>';
			getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
			   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
			   cls_ScopePopup.prop.popup_module = module;//模块
			   cls_ScopePopup.prop.popup_value = ids;
			   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
						//没有选择任何用户，则给出提示
						if(empty(cls_ScopePopup.return_obj.return_id)){
							var confirm_str = arrJsPopLabel['Pleaseselectatleaprofile'];
              RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
              return false;
						}else{
							var selected_profile_id = cls_ScopePopup.return_obj.return_id;//选中的用户
							var selected_profile_name = cls_ScopePopup.return_obj.return_name;
							ld('#user_role').val(selected_profile_id);
							ld('#role_name').val(selected_profile_name);
							ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
						}
					});
				}
			});
		});
	}
}
