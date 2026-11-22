/*
 *{*修改编码格式:统一编码：UTF-8*}
edit:can
date:20130411
reason:弹出框界面连接测试
*/
function SqlConnect(obj,url)
{
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:url,
			onComplete: function(response) {
                   var splitpop=response.responseText.split("&&&&&&&&&&&&//B/");
				   if(empty(splitpop) || splitpop == ''){
                        var confirm_str = "连接失败";
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        document.forms['KIS'].Database_entity.focus();
				   }
                   var pop1=splitpop[1];
                  
                   var splitpop1=pop1.split(":##:");
                   if(splitpop1[1] == 'SUCCESS'){
                        var confirm_str = "连接成功";
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        document.forms['KIS'].Database_entity.focus();
                        if(document.getElementById('btn_submit') != undefined){
                            document.getElementById('btn_submit').setAttribute("class", "D_pbtnok"); 
                            document.getElementById("btn_submit").disabled=false;
                        }
                        
                   }else if(splitpop1[1] == 'ERROR'){
                        var confirm_str = "连接失败";
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        document.forms['KIS'].Database_entity.focus();
                        if(document.getElementById('btn_submit') != undefined){
                            document.getElementById('btn_submit').setAttribute("class", "D_pbtncancel"); 
                            document.getElementById("btn_submit").disabled=true;
                        }
                   }else{
                        $("Demo_List").update(splitpop1[1]);
                   }
                   return false;
                   /*if(splitpop1[0]=="success")
                   {
                       $("Demo_List").update(splitpop1[1]);
                   }
                   else if(splitpop1[0]=="error")
                   {
                    $("Demo_List").update("");
                        alert(splitpop1[1]);
                   }*/
			}
		}
		);
        
}
function ServerCon(obj,facetype)
{
    var Database_entity;//数据库实体
    var sa=document.forms['KIS'].KISsa.value;//登录名
    var pwd=document.forms['KIS'].KISpwd.value;//密码
    var hostname=document.forms['KIS'].KIShostname.value;
    if(document.forms['KIS'].Database_entity != undefined){
        Database_entity=document.forms['KIS'].Database_entity.value;
    }
    var SETTING_MODE;
    if(document.getElementById('setting_mode') != undefined){
        SETTING_MODE = document.getElementById('setting_mode').value;//账套名称选择类型
    }
	
    if(SETTING_MODE== 1){
        if(facetype == 'Tyy'){
            var databasename="UFTSystem";
        }else if(facetype == 'Tyu'){
            var databasename="UFSystem";
        }else{
            var databasename="master";
        }
    }else{
        databasename = Database_entity;
    }
	if(document.getElementById('connectmode') != undefined){
        var connect_mode = document.getElementById('connectmode').value;
    }
	if(connect_mode == 'SQLSRV'){
		if(hostname==undefined||hostname=="")
		{
            var confirm_str = "服务器不能为空！";
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			document.forms['KIS'].KIShostname.focus();
			return;
		}
	}
    if(sa==undefined ||sa=="")
    {
        var confirm_str = "登录名不能为空！";
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        document.forms['KIS'].KISsa.focus();
        return ;
    }
    if(SETTING_MODE == 2){
        if(Database_entity==undefined || Database_entity==""){
            var confirm_str = "数据库实体不能为空！";
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);           
            return ;
        }
    }
    url="module=Settings&action=SettingsAjax&file=SqlconResult&sa="+sa+"&pwd="+pwd+"&hostname="+hostname+"&databasename="+databasename+"&facetype="+facetype+"&test_link="+SETTING_MODE+'&connect_mode='+connect_mode;
    //alert(url);
    SqlConnect(obj,url);
}
/*
edit:can
reason:k3弹出框界面
date:20130411
*/
function KThreePopup(obj)
{   
    var url="module=Settings&action=KThreePopup";  
    var sa=document.forms['index'].sa.value;
    var pwd=document.forms['index'].pwd.value;
    var hostName=document.forms['index'].hostname.value;
    var databasename=document.forms['index'].databasename.value;
    var setting_mode=document.getElementById('setting_mode').value;
    url=url+"&sa="+sa+"&pwd="+pwd+"&hostname="+hostName+"&databasename="+databasename+"&facetype=KThree"+"&setting_mode="+setting_mode;
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:url,
			onComplete: function(response) {
			             var popups=response.responseText.split('&&&&&&&&&&&&//B/');
                        var popup=popups[1];
                     
			         //$("KIS_form_div").update(popup);
                     document.getElementById('KIS_form_div').innerHTML = popup;
					 fnvshobj(obj, "KISHeader");
			}
		}
		); 
        
}
/*
edit:Chj
date:20150410
reason:产商下拉框更改事件
*/
function changesoft(obj){
    if(obj.value == '金蝶'){
        ld('#jindie').show();
        ld('#yongy').hide();
        ld('#dingjie').hide();
		ld('#order_style').show();
		ld('#quantity_style').show();
        var setting_mode = document.getElementById('setting_mode');
        setting_mode.removeAttribute('disabled');
        setting_mode.value='1';
        document.getElementById('btnBrowser').value=arrJsPopLabel['SELECT'];
        document.getElementById('setting_mode_id').innerHTML = arrJsPopLabel['ZHANGTAOCHOOSE'];
    }else if(obj.value == '用友'){
        ld('#jindie').hide();
        ld('#yongy').show();
        ld('#dingjie').hide();
		ld('#order_style').show();
		ld('#quantity_style').show();
        var setting_mode = document.getElementById('setting_mode');
        setting_mode.removeAttribute('disabled');
        setting_mode.value='1';
        document.getElementById('btnBrowser').value=arrJsPopLabel['SELECT'];
        document.getElementById('setting_mode_id').innerHTML = arrJsPopLabel['ZHANGTAOCHOOSE'];
    }else{        
        ld('#jindie').hide();
        ld('#yongy').hide();
        ld('#dingjie').show();
		ld('#order_style').show();
		ld('#quantity_style').hide();
        var setting_mode = document.getElementById('setting_mode');
        setting_mode.value='2';
        setting_mode.setAttribute('disabled','disabled');
        document.getElementById('btnBrowser').value=arrJsPopLabel['Configure'];
        document.getElementById('setting_mode_id').innerHTML = arrJsPopLabel['SELECTDATABASE'];
    }
    var soft_version =document.getElementById('soft_version');
    var soft_version_val= soft_version.options[soft_version.selectedIndex].value;
    if(obj.value == '鼎捷'){
        //document.getElementById("using_order_read").style.display="table-row";
        document.getElementById("using_ticket_read").style.display="table-row";
    }else{
        //document.getElementById("using_order_read").style.display="none";
        document.getElementById("using_ticket_read").style.display="none";
    }
    if((obj.value == '金蝶' && soft_version_val == 1)||obj.value == '鼎捷'){
        document.getElementById("using_order_read").style.display="table-row";
    }else{
        document.getElementById("using_order_read").style.display="none";
    }
    
    if(obj.value == '金蝶' && soft_version_val == 1){
        //document.getElementById("using_order_read").style.display="table-row";
        document.getElementById("using_quote_read").style.display="table-row";
        document.getElementById("SHOWDATAINTERFACESTEP7").style.display="block";
        document.getElementById("DATAINTERFACESTEP7").style.display="none";
    }else{
        //document.getElementById("using_order_read").style.display="none";
        document.getElementById("using_quote_read").style.display="none";
        document.getElementById("DATAINTERFACESTEP7").style.display="block";
         document.getElementById("SHOWDATAINTERFACESTEP7").style.display="none";
    }
}
//切换账套数据库
function setbtnBrowser(obj){
    if(obj.value == 2){//当选择设置方式为“配置连接”时，更改按钮名称为“设置”
        document.getElementById('btnBrowser').value=arrJsPopLabel['Configure'];
        document.getElementById('setting_mode_id').innerHTML = arrJsPopLabel['SELECTDATABASE'];
    }else{
        document.getElementById('btnBrowser').value=arrJsPopLabel['SELECT'];
        document.getElementById('setting_mode_id').innerHTML = arrJsPopLabel['ZHANGTAOCHOOSE'];
    }
    //清空文本框中的连接信息
    if(document.getElementById('data_name') != undefined){
        document.getElementById('data_name').value='';
    }
}
/*
edit:Can
date:20130415
reason:版本下拉框更改事件
*/
function changesel(obj,setting_mode_val)
{
   var demo_name = '';
   if(document.getElementById('demo_name') != undefined && document.getElementById('demo_name').value != ''){
	demo_name = document.getElementById('demo_name').value;
   }
   document.getElementById("KISHeader").style.display="none";
   document.getElementById("KIS_form_div").innerHTML="";
   document.getElementById("td_demo_name").innerHTML='<div style="float:left;margin-right:5px;">'+
   '<select onchange="setbtnBrowser(this)" name="setting_mode" id= "setting_mode" class="btn-radius-system">'+
   '<option value="1" >'+arrJsPopLabel['SELECTZHAOTAO']+'</option>'+
   '<option value="2" >'+arrJsPopLabel['SELECTDATABASE']+'</option>'+
   '</select></div>'+ 
   '<div style="float:left;margin-right:5px;"><input type="text" id="data_name" value="'+demo_name+'"  readonly="true" class="txtBox btn-radius-system gwidth100"></div>'+
   '<div style="float:left;"><input type="button" value="'+arrJsPopLabel['SELECT']+'" id="btnBrowser" class="Anu3_a" style=""></div>';
   var btnBrowser=document.getElementById("btnBrowser");
   var soft_factory =document.getElementById('soft_factory');
   var soft_factory_val= soft_factory.options[soft_factory.selectedIndex].value;
    
    
   if(soft_factory_val == '金蝶' && obj.options[obj.selectedIndex].value ==1){
        //document.getElementById("using_order_read").style.display="table-row";
        document.getElementById("using_quote_read").style.display="table-row";
        document.getElementById("SHOWDATAINTERFACESTEP7").style.display="block";
        document.getElementById("DATAINTERFACESTEP7").style.display="none";
   }else{
        //document.getElementById("using_order_read").style.display="none";
        document.getElementById("using_quote_read").style.display="none";
        document.getElementById("DATAINTERFACESTEP7").style.display="block";
        document.getElementById("SHOWDATAINTERFACESTEP7").style.display="none";
   }
   if((soft_factory_val == '金蝶' && obj.options[obj.selectedIndex].value ==1)||soft_factory_val=='鼎捷'){
        document.getElementById("using_order_read").style.display="table-row";
   }else{
        document.getElementById("using_order_read").style.display="none";
   }
   if(soft_factory_val == '鼎捷'){
        document.getElementById("using_ticket_read").style.display="table-row";
        var setting_mode = document.getElementById('setting_mode');
        setting_mode.value='2';
        setting_mode.setAttribute('disabled','disabled');
        document.getElementById('btnBrowser').value=arrJsPopLabel['Configure'];
   }else{
        if(setting_mode_val != undefined){
            document.getElementById("setting_mode").value= setting_mode_val;
        }
        document.getElementById("using_ticket_read").style.display="none";
        var setting_mode = document.getElementById('setting_mode');
        setting_mode.removeAttribute("disabled");
        document.getElementById('btnBrowser').value=arrJsPopLabel['SELECT'];
   }
   if(document.getElementById('setting_mode').value ==2){
        document.getElementById('btnBrowser').value=arrJsPopLabel['Configure'];
        document.getElementById('data_name').value = document.forms['index'].databasename.value;
    }else{
        document.getElementById('btnBrowser').value=arrJsPopLabel['SELECT'];
    }
	btnBrowser.onclick=function()
	{
		KThreePopup(this);
	}
}
/*
edit:can
date:20130415
reason:点击帐套列表的超链接
*/
function returnEdit(obj)
{
    var tdparent=obj.parentNode;
    var trparent=tdparent.parentNode;
    document.forms['index'].sa.value=document.forms['KIS'].KISsa.value;
    document.forms['index'].pwd.value=document.forms['KIS'].KISpwd.value;
    //数据库实体
    if(document.forms['KIS'].Database_entity != undefined){
        document.forms['index'].databasename.value=document.forms['KIS'].Database_entity.value;
        document.forms['index'].data_name.value = document.forms['KIS'].Database_entity.value;
    }else{
        document.forms['index'].databasename.value=trparent.cells[1].innerHTML;
		document.forms['index'].data_name.value = obj.innerHTML;
    }
    document.forms['index'].hostname.value=document.forms['KIS'].KIShostname.value;
    document.forms['index'].demo_name.value=obj.innerHTML;
    
    if(document.getElementById("sp_demo_name") != undefined){
        if(document.all){
            document.getElementById("sp_demo_name").innerText=obj.innerHTML;
        }else {
            document.getElementById("sp_demo_name").textContent=obj.innerHTML;
        }
    }
    //连接方式
    if(document.forms['KIS'].connectmode != undefined){
        document.forms['index'].connect_mode.value = document.forms['KIS'].connectmode.value;
    }
    //隐藏弹出框
    fninvshnew('KISHeader');
    //$("KIS_form_div").update("");
    
}
var filefacetype=undefined;
function fileChange(obj)
{
    var filename=obj.value;
    var splitname=filename.split(".");
    if(splitname[splitname.length-1].toLowerCase()!="ais")
    {
        //var msg = '请选择格式为ais的文件！';
        //alert(msg);
        //return false;
    }
     filefacetype=obj.getAttribute('facetype');
     if (window.navigator.userAgent.indexOf("MSIE") >= 1) 
     {   
            obj.select();   
            filename= document.selection.createRange().text;   
       }   
        else if (window.navigator.userAgent.indexOf("Firefox") >= 1) 
        {   
            if (obj.files) 
            {   
              //  filename=obj.files.item(0).getAsDataURL();   
           }   
           else 
           {
             //filename= obj.value; 
           }
            
        }   
        //alert(filename);
        
   //url="module=Settings&action=SqlconResult&sa=morningstar&pwd=ypbwkfyjhyhgzj&hostname="+filename+"&databasename="+obj.value+"&facetype="+facetype;
    //SqlConnect(obj,url);
}
var prevTr=undefined;
function settdColor(obj,event)
{
    var e=event||window.event;
    if(e.stopPropagation)//事件冒泡
    {
        e.stopPropagation();
    }
    else 
    {
        e.cancelBubble=true;
    }
    while(obj.tagName!="TR")
    {
        obj=obj.parentNode;
    }
    if(prevTr!=undefined)
    {
        prevTr.style.backgroundColor="#FFFFFF";
    }
    obj.style.backgroundColor="#FFFFCC";
    prevTr=obj;
}

function chkbox(obj)
{
    if(obj.value=="1")
    {
        obj.value="0"
    }
    else 
    {
        obj.value="1";
    }
}

function ConnectMode(obj){
    if(document.getElementById('connectmode') != undefined){
        var connect_mode = document.getElementById('connectmode').value;
        if(connect_mode == 'SQLSRV'||connect_mode == 'DIRODBC'){
            document.getElementById('database_entity').innerHTML = arrJsPopLabel['DATABASEENTITY'];
            document.getElementById('select_database').style.display = '';
        }else{
            document.getElementById('database_entity').innerHTML = arrJsPopLabel['DATASOURCEODBC'];
            document.getElementById('select_database').style.display='none';
        }  
    }
}