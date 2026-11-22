function showSelectUser(ipt){
	var module = '';
	if(document.getElementById('module') != undefined){
		module = document.getElementById('module').value;
	}
    var obj = {'field':'senioruserid','view':'private','type':'searchscope','module':module};
    ViewUserPopup(obj,function(userobj){
        ipt.value = userobj.username.value;        
    });        
}

function get_search_senior(ipt){
    var viewName = encodeURIComponent(ipt.options[ipt.options.selectedIndex].value);
    if('smowner_search_senior' == viewName){//高级
		var module = '';
		if(document.getElementById('module') != undefined){
			module = document.getElementById('module').value;
		}
		var scopepopupobj;//自定义弹出层页面html，绑定事件
		var popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题
		//var module = 'PublicAnnouncement';
		getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
			scopepopupobj =  new ScopePopupObj(module);
			scopepopupobj.popup_caption_value = popup_caption_value;//标题title
			getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
			   cls_ScopePopup.prop.popup_module = module;//模块
			   cls_ScopePopup.prop.popup_value = '';
                module = 'OftenUseReport';
			   cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user'
			   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('.D_pbtn .D_pbtnok').unbind('click').on('click',function(){
						if(empty(cls_ScopePopup.return_obj.return_id)){
                            var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
							return false;
						}else{
							ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
							if(document.getElementById('selectuserid') != undefined){
								document.getElementById('selectuserid').value=cls_ScopePopup.return_obj.return_id;
							}
							
						}
					});
				}
			});
		});
	}else if('SmOwner_Search_Group' == viewName){	//按部门
		var module = '';
		if(document.getElementById('module') != undefined){
			module = document.getElementById('module').value;
		}
		var scopepopupobj;//自定义弹出层页面html，绑定事件
		var popup_caption_value = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];//标题
		//var module = 'PublicAnnouncement';
		getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
			scopepopupobj =  new ScopePopupObj(module);
			scopepopupobj.popup_caption_value = popup_caption_value;//标题title
			scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];//查询框默认值
			scopepopupobj.popup_header = '<p style="margin-top:10px;">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'&nbsp;&nbsp;<input type="text" class="seniorinput"  id=\'popup_locationdiv\' value=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP']+'\'></p>';
			getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
			   cls_ScopePopup.prop.popup_module = module;//模块
			   cls_ScopePopup.prop.popup_value = '';
                module = 'OftenUseReport';
			   cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewgroupinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=group';
			   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('.D_pbtn .D_pbtnok').unbind('click').on('click',function(){
						if(empty(cls_ScopePopup.return_obj.return_id)){
                            var confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
							return false;
						}else{
							ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
							if(document.getElementById('selectuserid') != undefined){
								document.getElementById('selectuserid').value=cls_ScopePopup.return_obj.return_id;
							}
							
						}
					});
				}
			});
		});
	}
}
function changedaytime(obj,type,day1,day2){
    //document.getElementById('startmonth').value=day1;  
    //document.getElementById('endmonth').value=day2;
    document.getElementById('startmonth').value=day1+' '+'-'+' '+day2;
	setReportTime(document.getElementById('startmonth').value);
    ld('#startmonth').daterangepicker(null, function(start, end, label) {
        
      });
      
    /**
    *@author:andy
    *@data:
    *@reason:优化
    *@version:|
    */
	ld('#OftenUseReport_search_date a').each(function(){
		if(ld(this).attr('id') == type){
			ld(this).attr('class','onselected_A changeday');
		}else{
			ld(this).attr('class','changeday');
		}
	});
   
	/*var p=obj.parentNode.children;
    //alert(p.length)
    for(var i=0;i<p.length;i++)
    {
        if(p[i] != obj){
            if(p[i].nodeName == 'A')
                p[i].className='changeday';
        }
    }
	if(ld('#daterangepicker_search') != undefined){
		ld('#daterangepicker_search').attr('class','changeday')
	}
    obj.className='onselected_A changeday';*/
   
}

function fnDropDownUsers(obj,Lay,topY){
	var tagName = document.getElementById(Lay);
	var leftSide = findPopX(obj);
	var topSide = findPopY(obj);
   
    //topSide=obj.offsetHeight+20;
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
        //tagName.style.top= topSide+ 11 + topY+'px';
        tagName.style.width=obj.clientWidth+'px';
        }
        else
		tagName.style.top= topSide + 28 +'px';
		tagName.style.display = 'block';
}


function getSelected(txtid){
    cbobj=document.getElementsByName('cb_select_user');
    txtidobj=document.getElementById(txtid);
    txtobj=document.getElementById('search_text');
    if(cbobj!=undefined&&txtobj!=undefined&&txtidobj!=undefined){
        txtobj_str='';
        txtidobj_str='';
        for(i=0;i<cbobj.length;i++){
            if(cbobj[i].checked){
                sp_obj=document.getElementById('sp_user_'+i);
                txt_obj=document.getElementById('search_text_'+i);
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

calendarParentid="searchAcc";
/*
edit:chj
date:2014-9-24
reason:0011632: 自定义报表、常用报表、综合报表、库存台账中，增加基本查找和高级查找增加"ENter"键查询
*/
function OftenUseReportSearchSubmit(event,obj,searchtype)
{
    var e = event || window.event;
    if(e.keyCode == 13)// Enter 回车键
    {
        callOftenUseReportSearch(obj,searchtype);
    }
}
/*
edit:chj
date:2015/5/13
reason:应收账款汇总表
*/
function callReportSearch(obj){
	var url='module=OftenUseReport&action=ListView';
	//区域
	if(ld('#address') != undefined && ld('#address').val() != ''){
		url +='&address='+ld('#address').val();
	}
	//核算项目名称
	if(ld('#OrgFName') != undefined && ld('#OrgFName').val() != ''){
		url +='&orgfname='+ld('#OrgFName').val();
	}
	//业务人员
	if(ld('#FName') != undefined && ld('#FName').val() != ''){
		url +='&fname='+ld('#FName').val();
	}
	//开始日期
	if(ld('#startdate') != undefined && ld('#startdate').val() != ''){
		url +='&startdate='+ld('#startdate').val();
	}
	//结束日期
	if(ld('#enddate') != undefined && ld('#enddate').val() != ''){
		url +='&enddate='+ld('#enddate').val();
	}
	var useReportid=document.forms['basicSearch'].UseReport.value;
	url +='&UseReport='+useReportid;
	url+='&ajax=true&searchtype=BasicSearch';
    document.getElementById('status').style.display="inline";
    //alert(url);
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
					document.getElementById('status').style.display="none";
					var results=response.responseText.split("###SUCCESS###");
					document.getElementById('UseReportList').innerHTML=results[1];
					document.getElementById("BasicSearchreput").disabled=false;
				}
			}
	  )
}
function setReportOrderListView(reportid,fieldname,ordertype)
{
    usereportorderobj=new usereportorder();
    usereportorderobj.reportid=reportid;
    usereportorderobj.fieldname=fieldname;
    if(ordertype=="")
        ordertype='asc';
    usereportorderobj.ordertype=ordertype;
    document.getElementById("BasicSearchreput").click();
   
}
function usereportorder()
{
    
}
 usereportorder.prototype={"reportid":0,'fieldname':'','ordertype':''};
var usereportorderobj=null;
function callTrackReport(obj,searchtype)
{
     document.getElementById("BasicSearchreput").disabled=true;
    var url='module=OftenUseReport&action=ListView';
    var useReportid=0;
    
   
       // var receiverid=document.forms['basicSearch'].receiverid.value;
       var receiverid='';
       var SmOwnerSearchScope='';
       if(document.getElementById('selectuserid')!=null){
                receiverid=document.getElementById('selectuserid').value;
            }
            if(document.getElementById('SmOwnerSearchScope')!=null){
                SmOwnerSearchScope=document.getElementById('SmOwnerSearchScope').value;
            }
           receiverid=SmOwnerSearchScope;
        useReportid=document.forms['basicSearch'].UseReport.value;
        url+='&datefindcolumn=createdtime&startmonth='+document.getElementById('track_date').value+'&endmonth='+document.getElementById('track_date').value;
        url+='&receiverid='+receiverid+"&UseReport="+useReportid;
      
        url+='&ajax=true&searchtype=BasicSearch&reportheader=reportheader';
       
         document.getElementById('status').style.display="inline";
    
     ld.ajax(
             {
                  type: "post",
                  url: "index.php",
                  data:url,
                  async:false,
                  dataType: "json",
                  success: function (data) {
                            document.getElementById("BasicSearchreput").disabled=false; 
                            document.getElementById('status').style.display="none";
                          
                            var pointobj=eval('('+ data +')')?eval('('+ data +')'):JSON.parse(data);
                            // var map_obj=new Lingdang_Map('lingdang_map');
                            if(pointobj!=null&&pointobj!='null'&&pointobj!='undefined'&&pointobj.length>0)
                                {
                                    
                                    map_obj.show_map(pointobj[0].lng,pointobj[0].lat);
                                    map_obj.setTrackReport(pointobj);   
                                }
                                else if(map_obj!=undefined)
                                {
                                    map_obj.clearOverlay();
                                }
                                                    
                  },
                                                
             }
     )
       
    
}
/*
edit:can
date:20131202
reason:立即查找
*/
function callOftenUseReportSearch(obj,searchtype,r_type,r_para)
{
    document.getElementById("BasicSearchreput").disabled=true;
    var url='module=OftenUseReport&action=ListView';
    var useReportid=0;
    
    if(searchtype=='BasicSearch')
    {
       // var receiverid=document.forms['basicSearch'].receiverid.value;
       var receiverid='';
       var SmOwnerSearchScope='';
            if(document.getElementById('selectuserid')!=null){
                receiverid=document.getElementById('selectuserid').value;
            }
            if(document.getElementById('SmOwnerSearchScope')!=null){
                SmOwnerSearchScope=document.getElementById('SmOwnerSearchScope').value;
            }
            //alert(document.getElementById('SmOwnerSearchScope').value);

			if (document.forms['basicSearch'].startmonth != undefined) {
				var thequerytime = document.forms['basicSearch'].startmonth.value;//双时间录入框改为单时间段录入框
				var strs = new Array(); //定义一数组
				strs = thequerytime.split(" - "); //字符分割
				var startmonth = trim(strs[0]);
				var endmonth = trim(strs[1]);
			}

        
        var datefindcolumn=document.forms['basicSearch'].datefindcolumn.value;
        var otherfindcolumn=document.forms['basicSearch'].otherfindcolumn.value;
        if(document.forms['basicSearch'].basicotherfinds!=undefined&&document.forms['basicSearch'].basicotherfinds.value!=undefined&&document.forms['basicSearch'].basicotherfinds.value!=""){
            var basicotherfindz=document.forms['basicSearch'].basicotherfindz.value;
            var basicotherfinds=document.forms['basicSearch'].basicotherfinds.value;
            url+='&basicotherfinds='+basicotherfinds+'&basicotherfindz='+basicotherfindz;
        }
        if(document.forms['basicSearch'].basicotherfind2!=undefined&&document.forms['basicSearch'].basicotherfind2.value!=undefined&&document.forms['basicSearch'].basicotherfind2.value!=""){
            var basicotherfind2=document.forms['basicSearch'].basicotherfind2.value;
            url+='&basicotherfind2='+basicotherfind2;
        }
        if(document.forms['basicSearch'].basicotherfind3!=undefined&&document.forms['basicSearch'].basicotherfind3.value!=undefined&&document.forms['basicSearch'].basicotherfind3.value!=""){
            var basicotherfind3=document.forms['basicSearch'].basicotherfind3.value;
            url+='&basicotherfind3='+basicotherfind3;
        }
        if(document.forms['basicSearch'].basicotherfind4!=undefined&&document.forms['basicSearch'].basicotherfind4.value!=undefined&&document.forms['basicSearch'].basicotherfind4.value!=""){
            var basicotherfind4=document.forms['basicSearch'].basicotherfind4.value;
            url+='&basicotherfind4='+basicotherfind4;
        }
		//排行维度
		if(document.forms['basicSearch'].salesranking_value != undefined && document.forms['basicSearch'].salesranking_value.value != ""){
			var salesranking_value=document.forms['basicSearch'].salesranking_value.value;
            url+='&salesranking_value='+salesranking_value;
		}

          //var r=document.getElementById("basicotherfindsapp2").checked; 

    
        if(document.forms['basicSearch'].basicotherfindsapp2!=undefined&&document.forms['basicSearch'].basicotherfindsapp2.value!=undefined){
            var basicotherfindsapp2=document.getElementById("basicotherfindsapp2").checked;
            url+='&basicotherfindsapp2='+basicotherfindsapp2;
        }
        if(document.forms['basicSearch'].basicotherfindsbill!=undefined&&document.forms['basicSearch'].basicotherfindsbill.value!=undefined&&document.forms['basicSearch'].basicotherfindsbill.value!=""){
            var basicotherfindsbill=document.forms['basicSearch'].basicotherfindsbill.value;
            url+='&basicotherfindsbill='+basicotherfindsbill;
        }
        if(document.forms['basicSearch'].basicotherfind5!=undefined&&document.forms['basicSearch'].basicotherfind5.value!=undefined&&document.forms['basicSearch'].basicotherfind5.value!=""){
            var basicotherfind5=document.forms['basicSearch'].basicotherfind5.value;
            url+='&basicotherfind5='+basicotherfind5;
        }
        if(document.forms['basicSearch'].basicotherfind6!=undefined&&document.forms['basicSearch'].basicotherfind6.value!=undefined&&document.forms['basicSearch'].basicotherfind6.value!=""){
            var basicotherfind6=document.forms['basicSearch'].basicotherfind6.value;
            url+='&basicotherfind6='+basicotherfind6;
        }
		if(ld('#basicotherfindsapp') != undefined && document.forms['basicSearch'].basicotherfindsapp != undefined){
			var basicotherfindsapp=document.forms['basicSearch'].basicotherfindsapp.checked;
            url+='&basicotherfindsapp='+basicotherfindsapp;
		}
		if(ld('#check_approve_status') != undefined){
			if(ld("#check_approve_status").prop("checked") == true){
				url+='&check_approve_status=yes';
			}else{
				url+='&check_approve_status=no';
			}
		}
        if(startmonth > endmonth)
        {
            var confirm_str = arrJsPopLabel['STARTDATECANOTGREATERENDDATE'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            document.getElementById("BasicSearchreput").disabled=false;
            return false;
        }

        useReportid=document.forms['basicSearch'].UseReport.value;
        url+='&datefindcolumn='+datefindcolumn+'&startmonth='+startmonth+'&endmonth='+endmonth;
        url+='&receiverid='+receiverid+"&UseReport="+useReportid+"&SmOwnerSearchScope="+SmOwnerSearchScope;
        
        if(document.forms['basicSearch'].basicotherfind!=undefined&&document.forms['basicSearch'].basicotherfind.value!="")
        {
            url+='&otherfindcolumn='+otherfindcolumn+'&basicotherfind='+encodeURIComponent(document.forms['basicSearch'].basicotherfind.value);
        }
        url+='&ajax=true&searchtype=BasicSearch';
        if(usereportorderobj!=null)
        {
           url+='&sorder='+usereportorderobj.fieldname+"&ordertype="+usereportorderobj.ordertype;
        }
         document.getElementById('status').style.display="inline";
        if(obj != null &&  obj.id=="recalculated_distance"){
            //签到报表距离重新计算
			url+="&recalculated_distance=yes";
		}
        //editor:gyq_86 reason:库存报表 2018/11/23 11:37
        var productid = ld('#productid_current').val();
        if(productid > 0){
            url+="&productid_current="+productid;
            url+="&productids="+ld('#productids').val();
            url+="&productids_name="+ld('#productids_name').val();
            url+="&productids_current="+ld('#productids_current').val();
        }
        if(r_type==='page'){
            url+='&'+r_para;
        }
	   //alert(url);
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
                        //$("status").style.display='none';
                        document.getElementById('status').style.display="none";
                        var results=response.responseText.split("###SUCCESS###");
                        // document.write(results[1]);exit();
                        //$("UseReportList").innerHTML=results[1];
                        //alert(results);
                        document.getElementById('UseReportList').innerHTML=results[1];
                        document.getElementById("BasicSearchreput").disabled=false;
                        //editor:gyq_86 reason:库存报表 2018/11/23 11:53
                        var productids = ld('#productids').val();
                        if(productids){
                            var names = ld('#productids_name').val();
                            var current = ld('#productids_current').val();
                            var names_arr = names.split(',');
                            ld('input[name="basicotherfind5"]').val(names_arr[current]);
						}
}
                }
          )
    }
    
    //return false;
}
function changeSalesRank(){
	if(ld("#salesranking_value") != undefined){
		var salesranking_value = ld("#salesranking_value").find("option:selected").attr("tag");
		ld('#checkbox_label').html(salesranking_value);
	}
}
function changeCheckLabel(){
	if(ld("#basicotherfindsbill") != undefined){
		var basicotherfindsbill = ld("#basicotherfindsbill").find("option:selected").attr("tag");
		ld('#checkbox_label').html(basicotherfindsbill);
	}
}
/**
*@author:andy
*@data:20141010
*@reason:常用报表更改样式，引入新日历插件、新的jquery控件后，带产品的的报表 转高级、基本查找 的
* show(divid) 函数指向错误，跑到prototype.js中的show方法，致使报错，所以新增此函数
*@version:|
*/
function showdiv(divid) {
    if(getObj(divid))
	{
		var id = document.getElementById(divid);
      //alert(divId);
		id.style.display = 'block';
	}

}
function DoOnchange(){
        var basicotherfinds = document.getElementById("basicotherfinds").value;
        //alert(basicotherfinds);
        var url="module=OftenUseReport&action=ListView&types=selectchange&selectid="+basicotherfinds;
        var objsel=document.getElementById("basicotherfindz");      
        objsel.options.length=0;
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
                        //$("status").style.display='none';
                        document.getElementById('status').style.display="none";
                        var results=response.responseText.split("###SUCCESS###");
                       var s = eval(results[1]);
                      for(var i=0;i<s.length;i++){
                        objsel.options[i]=new Option(s[i],s[i]);
                        }
                        //$("UseReportList").innerHTML=results[1];
                         
                    }
                }
          )
}
function updateRelFieldOptions(sel, opSelName) {
    var selObj = document.getElementById(opSelName);
    if(selObj==undefined)
    {
        return false;
    }
    var fieldtype = null ;

    var currOption = selObj.options[selObj.selectedIndex];
    /*
    andrew
    20140629
    0009550: IE8浏览器：常用报表-合同订单跟踪表，进入该表界面网页左下角报错
    */
    if(sel.selectedIndex==-1){
        var currField = '';
    }else{
        var currField = sel.options[sel.selectedIndex];
    }
    //alert(currField);

    if(currField.value != null && currField.value.length != 0)
    {
        	fieldtype = trimfValues(currField.value);
        	ops = rel_fields[fieldtype];
        
        	var off = 0;
        	if(ops != null)
        	{
        		var nMaxVal = selObj.length;
        		for(nLoop = 0; nLoop < nMaxVal; nLoop++)
        		{
        			selObj.remove(0);
        		}
        		selObj.options[0] = new Option (alert_arr.LBL_NONE, '');
        		if (currField.value == '') {
        			selObj.options[0].selected = true;
        		}
        		off = 1;
        		for (var i = 0; i < ops.length; i++)
        		{
        			var field_array = ops[i].split("::");
        			var label = field_array[1];
        			var field = field_array[0];
        			if (label == null) continue;
                   
        			var option = new Option (label, label);
        			selObj.options[i + off] = option;
        			if (currOption != null && currOption.value == option.value)
        			{
        				option.selected = true;
        			}
        		}
        	}
    }
    else
    {
	var nMaxVal = selObj.length;
	for(nLoop = 0; nLoop < nMaxVal; nLoop++)
	{
		selObj.remove(0);
	}
	selObj.options[0] = new Option ('None', '');
	if (currField.value == '') {
		selObj.options[0].selected = true;
	}
    }

}

function generateReport(obj) {

	if(!checkAdvancedFilter()) return false;
	
	lingdangJS_DialogBox.block();
	var usereportid=document.forms['basicSearch'].UseReport.value;
	var advft_criteria =document.getElementById('advft_criteria').value;// $('advft_criteria').value;
	var advft_criteria_groups =document.getElementById('advft_criteria_groups').value;// $('advft_criteria_groups').value;
    var url="";
    if(usereportorderobj!=null)
    {
       // url+='&sorder='+usereportorderobj.fieldname+"&ordertype="+usereportorderobj.ordertype;
    }
	var thequerytime=document.forms['basicSearch'].startmonth.value;//双时间录入框改为单时间段录入框
	var strs= new Array(); //定义一数组
	strs=thequerytime.split(" - "); //字符分割
	var startmonth=trim(strs[0]);
	var endmonth=trim(strs[1]);
	if(startmonth > endmonth)
	{
        var confirm_str = arrJsPopLabel['STARTDATECANOTGREATERENDDATE'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		document.getElementById("BasicSearchreput").disabled=false;
		return false;
	}
	var datefindcolumn=document.forms['basicSearch'].datefindcolumn.value;
	url+='&datefindcolumn='+datefindcolumn+'&startmonth='+startmonth+'&endmonth='+endmonth;
	if(document.getElementById('hidden_userreportname') != undefined){
		url += '&hidden_userreportname='+document.getElementById('hidden_userreportname').value;
	}
	
	new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'action=ListView&ajax=true&module=OftenUseReport&ajax=true&UseReport='+usereportid+'&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+"&searchtype=advSearch"+url,
                        onComplete: function(response) {
						 
                            var results=response.responseText.split("###SUCCESS###");
                            document.getElementById('UseReportList').innerHTML=results[1];
                            //$("UseReportList").innerHTML=results[1];
							lingdangJS_DialogBox.unblock();
                        }
                }
        );
}


/*
更新操作
edit:can
date:20131128
reason:常用报表高级查询保存(V3.1)
*/
function saveReportAdvFilter(reportid) {

	if(!checkAdvancedFilter()) return false;
	
	lingdangJS_DialogBox.block();
	
	var advft_criteria =document.getElementById('advft_criteria').value;// $('advft_criteria').value;
	var advft_criteria_groups =document.getElementById('advft_criteria_groups').value;// $('advft_criteria_groups').value;
    //alert(advft_criteria)
    //return false;
    //alert('action=ListView&ajax=true&module=OftenUseReport&submode=saveCriteria&UseReport='+reportid+'&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+"&searchtype=advSearch")
	new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'action=ListView&ajax=true&module=OftenUseReport&submode=saveCriteria&UseReport='+reportid+'&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+"&searchtype=advSearch",
                        onComplete: function(response) {
						   var results=response.responseText.split("###SUCCESS###");
                            document.getElementById('UseReportList').innerHTML=results[1];;//$("UseReportList").innerHTML=results[1];
							lingdangJS_DialogBox.unblock();
                        }
                }
        );
}
function UseReportPrint(obj)
{
    var receiverid='';
    if(document.getElementById('selectuserid')!=null){
       receiverid=document.getElementById('selectuserid').value;
    }
    var SmOwnerSearchScope='';
    if(document.getElementById('SmOwnerSearchScope')!=null){
        SmOwnerSearchScope=document.getElementById('SmOwnerSearchScope').value;
    }
    var searchtype=document.getElementById('printsearchType').value;//$('printsearchType').value;
    var usereportid=document.forms['basicSearch'].UseReport.value;
    var url='index.php?module=OftenUseReport&action=OftenUseReportAjax&file=ListView&ajax=true&Print=true&UseReport='+usereportid+'&SmOwnerSearchScope='+SmOwnerSearchScope;
   //alert(searchtype);
    if(searchtype=="advSearch")
    {
   	    var advft_criteria =document.getElementById('advft_criteria').value;// $('advft_criteria').value;
        var advft_criteria_groups =document.getElementById('advft_criteria_groups').value;// $('advft_criteria_groups').value;
        url+='&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+"&searchtype=advSearch";
    }
    else if(searchtype=="BasicSearch")
    {
        //var receiverid=document.forms['basicSearch'].receiverid.value;
        var thequerytime=document.forms['basicSearch'].startmonth.value;//双时间录入框改为单时间段录入框
        //alert(thequerytime)
        var strs= new Array(); //定义一数组
        strs=thequerytime.split(" - "); //字符分割
        //alert(trim(strs[0]))
        //alert(trim(strs[1]))
        var startmonth=trim(strs[0]);
        var endmonth=trim(strs[1]);
       // var startmonth=document.forms['basicSearch'].startmonth.value;
       // var endmonth=document.forms['basicSearch'].endmonth.value;
        var datefindcolumn=document.forms['basicSearch'].datefindcolumn.value;
        var otherfindcolumn=document.forms['basicSearch'].otherfindcolumn.value;
        //useReportid=document.forms['BasicSearch'].UseReport.value;
        url+='&datefindcolumn='+datefindcolumn+'&startmonth='+startmonth+'&endmonth='+endmonth;
        url+='&receiverid='+receiverid;
        if(document.forms['basicSearch'].basicotherfinds!=undefined&&document.forms['basicSearch'].basicotherfinds.value!=undefined&&document.forms['basicSearch'].basicotherfinds.value!=""){
            var basicotherfindz=document.forms['basicSearch'].basicotherfindz.value;
            var basicotherfinds=document.forms['basicSearch'].basicotherfinds.value;
            url+='&basicotherfinds='+basicotherfinds+'&basicotherfindz='+basicotherfindz;
        }
        if(document.forms['basicSearch'].basicotherfind2!=undefined&&document.forms['basicSearch'].basicotherfind2.value!=undefined&&document.forms['basicSearch'].basicotherfind2.value!=""){
            var basicotherfind2=document.forms['basicSearch'].basicotherfind2.value;
            url+='&basicotherfind2='+basicotherfind2;
        }
        if(document.forms['basicSearch'].basicotherfind3!=undefined&&document.forms['basicSearch'].basicotherfind3.value!=undefined&&document.forms['basicSearch'].basicotherfind3.value!=""){
            var basicotherfind3=document.forms['basicSearch'].basicotherfind3.value;
            url+='&basicotherfind3='+basicotherfind3;
        }
        if(document.forms['basicSearch'].basicotherfind4!=undefined&&document.forms['basicSearch'].basicotherfind4.value!=undefined&&document.forms['basicSearch'].basicotherfind4.value!=""){
            var basicotherfind4=document.forms['basicSearch'].basicotherfind4.value;
            url+='&basicotherfind4='+basicotherfind4;
        }
           
          //var r=document.getElementById("basicotherfindsapp2").checked; 

    
        if(document.forms['basicSearch'].basicotherfindsapp2!=undefined&&document.forms['basicSearch'].basicotherfindsapp2.value!=undefined){
            var basicotherfindsapp2=document.getElementById("basicotherfindsapp2").checked;
            url+='&basicotherfindsapp2='+basicotherfindsapp2;
        }
        if(document.forms['basicSearch'].basicotherfindsbill!=undefined&&document.forms['basicSearch'].basicotherfindsbill.value!=undefined&&document.forms['basicSearch'].basicotherfindsbill.value!=""){
            var basicotherfindsbill=document.forms['basicSearch'].basicotherfindsbill.value;
            url+='&basicotherfindsbill='+basicotherfindsbill;
        }
        if(document.forms['basicSearch'].basicotherfind5!=undefined&&document.forms['basicSearch'].basicotherfind5.value!=undefined&&document.forms['basicSearch'].basicotherfind5.value!=""){
            var basicotherfind5=document.forms['basicSearch'].basicotherfind5.value;
            url+='&basicotherfind5='+basicotherfind5;
        }
        if(document.forms['basicSearch'].basicotherfind6!=undefined&&document.forms['basicSearch'].basicotherfind6.value!=undefined&&document.forms['basicSearch'].basicotherfind6.value!=""){
            var basicotherfind6=document.forms['basicSearch'].basicotherfind6.value;
            url+='&basicotherfind6='+basicotherfind6;
        }
        if(document.forms['basicSearch'].basicotherfind!=undefined&&document.forms['basicSearch'].basicotherfind.value!="")
        {
            url+='&otherfindcolumn='+otherfindcolumn+'&basicotherfind='+encodeURIComponent(document.forms['basicSearch'].basicotherfind.value);
        }
        url+='&searchtype=BasicSearch';
    }
	//排行维度
	if(document.forms['basicSearch'].salesranking_value != undefined && document.forms['basicSearch'].salesranking_value.value != ""){
		var salesranking_value=document.forms['basicSearch'].salesranking_value.value;
		url+='&salesranking_value='+salesranking_value;
	}
	if(ld('#check_approve_status') != undefined){
		if(ld("#check_approve_status").prop("checked") == true){
			url+='&check_approve_status=yes';
		}else{
			url+='&check_approve_status=no';
		}
	}
    //alert(url);
     window.open(url);
}


function UseReportColumnSet(usereportid,obj,divid)
{
    document.getElementById('status').style.display="inline";//$("status").style.display="inline";
    new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'action=UseReportSetColumn&module=OftenUseReport&UseReport='+usereportid+"&ReportHeader=DHeader",
                        onComplete: function(response) {
                       	document.getElementById('status').style.display="none";//$("status").style.display="none";
                           // lingdangJS_DialogBox.block();//遮罩层  
						   var results=response.responseText.split("###SUCCESS###");
                            document.getElementById('columnset_form_div').innerHTML=results[1];//$("columnset_form_div").innerHTML=results[1];
							 fnvshobj(obj, divid); 
                        }
                }
        );
}


function ReportmoveUp()
{
var elem = document.getElementById('selectedAssmablyColumns');
		if(elem.options.selectedIndex>=0){
			for (var i=1;i<elem.options.length;i++){
				if(elem.options[i].selected == true){
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
function ReportmoveDown()
{
var elem = document.getElementById('selectedAssmablyColumns');
		if(elem.options.selectedIndex>=0){
			for (var i=elem.options.length-2;i>=0;i--){
				if(elem.options[i].selected == true){
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
/*
edit:can
date:20131202
reason:显示列设置保存
*/
function SaveColumnSet(obj)
{
	document.getElementById('status').style.display="inline";
    var selobj=document.getElementById('selectedAssmablyColumns');
   	if(!positiveInteger(document.forms['frmColumnSet'].PageWidthPercent.value))
    {
        //页面宽度百分比只能输入正整数！
        var confirm_str = arrJsPopLabel['PERCENTAGEONLYPOSITIVEINGEGER'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    if(document.forms['frmColumnSet'].PageWidthPercent.value>300)
    {
        //页面宽度百分比最大值为300！
        var confirm_str = arrJsPopLabel['PERCENTAGEPAGEWIDTHIS300'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    if(selobj.options.length<2)
    {
        //至少设置显示3列！
        var confirm_str = arrJsPopLabel['SETDISPLAYLEASTTHREE'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    for (var i=0;i<selobj.options.length;i++)
    {
        document.getElementById('selectedAssmablyColumnsString').value+=selobj.options[i].value+",";
        
    }
    var searchtype=document.getElementById('printsearchType').value;//$('printsearchType').value;
    var usereportid=document.forms['basicSearch'].UseReport.value;
  

    var receiverid=document.forms['basicSearch'].receiverid.value;
    //var startmonth=document.forms['basicSearch'].startmonth.value;
    //var endmonth=document.forms['basicSearch'].endmonth.value;
    var thequerytime=document.forms['basicSearch'].startmonth.value;//双时间录入框改为单时间段录入框
    //alert(thequerytime)
    var strs= new Array(); //定义一数组
    strs=thequerytime.split(" - "); //字符分割
    //alert(trim(strs[0]))
    //alert(trim(strs[1]))
    var startmonth=trim(strs[0]);
    var endmonth=trim(strs[1]);
        
    var datefindcolumn=document.forms['basicSearch'].datefindcolumn.value;
    if(document.forms['basicSearch'].otherfindcolumn!=undefined)
        var otherfindcolumn=document.forms['basicSearch'].otherfindcolumn.value;
    useReportid=document.forms['basicSearch'].UseReport.value;
    document.forms['frmColumnSet'].coldatefindcolumn.value=datefindcolumn;
    document.forms['frmColumnSet'].startdate.value=startmonth;
    document.forms['frmColumnSet'].enddate.value=endmonth;
    document.forms['frmColumnSet'].smownerids.value=receiverid;
        
    if(document.forms['basicSearch'].basicotherfind!=undefined&&document.forms['basicSearch'].basicotherfind.value!="")
        {
           document.forms['frmColumnSet'].colotherfindcolumn.value=otherfindcolumn;
           document.forms['frmColumnSet'].colbasicotherfind.value=basicotherfind;
           
        }
     
    document.forms['frmColumnSet'].searchtype.value=searchtype;
    document.forms['frmColumnSet'].UseReportId.value=usereportid;
    //document.forms['frmColumnSet'].submit();
    lingdangJS_DialogBox.block();
   var selectedAssmablyColumnsString=document.getElementById('selectedAssmablyColumnsString').value;
   if(searchtype=='advSearch')
   {
       var advft_criteria =document.getElementById('advft_criteria').value;// $('advft_criteria').value;
        var advft_criteria_groups =document.getElementById('advft_criteria_groups').value;// $('advft_criteria_groups').value;
    	new Ajax.Request(
                    'index.php',
                    {queue: {position: 'end', scope: 'command'},
                            method: 'post',
                            postBody: 'action=ListView&ajax=true&module=OftenUseReport&submode=SaveColumnSet&UseReport='+usereportid+'&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+"&searchtype=advSearch&selectedAssmablyColumnsString="+selectedAssmablyColumnsString+'&pagewidth='+document.forms['frmColumnSet'].PageWidthPercent.value+"&ReportHeader=DHeader",
                            onComplete: function(response) {
    						   var results=response.responseText.split("###SUCCESS###");
							    document.getElementById('status').style.display="none";
                                document.getElementById('UseReportList').innerHTML=results[1];;//$("UseReportList").innerHTML=results[1];
    							fninvshnew('UseReportSet');
                            }
                    }
            );
   }
   else
   {
      var url='module=OftenUseReport&action=ListView';
      url+='&datefindcolumn='+datefindcolumn+'&startmonth='+startmonth+'&endmonth='+endmonth;
        url+='&receiverid='+receiverid+"&UseReport="+useReportid;
        if(document.forms['basicSearch'].basicotherfind!=undefined&&document.forms['basicSearch'].basicotherfind.value!="")
        {
            url+='&otherfindcolumn='+otherfindcolumn+'&basicotherfind='+encodeURIComponent(document.forms['basicSearch'].basicotherfind.value);
        }
        url+='&ajax=true&searchtype=BasicSearch&submode=SaveColumnSet&selectedAssmablyColumnsString='+selectedAssmablyColumnsString+'&pagewidth='+document.forms['frmColumnSet'].PageWidthPercent.value+"&ReportHeader=DHeader";
        
        
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
                        document.getElementById('status').style.display="none";//$("status").style.display='none';
                        var results=response.responseText.split("###SUCCESS###");
						document.getElementById('status').style.display="none";
                        document.getElementById('UseReportList').innerHTML=results[1];//$("UseReportList").innerHTML=results[1];
                       	fninvshnew('UseReportSet');
                         
                    }
                }
          )
   }
   
}

function EditUseReportColumn(usereportid,obj,divid)
{
     document.getElementById('status').style.display="inline";//$("status").style.display="inline";
    new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'action=EditUseReportColumn&module=OftenUseReport&UseReport='+usereportid,
                        onComplete: function(response) {
                       	document.getElementById('status').style.display="none";//$("status").style.display="none";
                            //lingdangJS_DialogBox.block();//遮罩层  
						   var results=response.responseText.split("###SUCCESS###");
                            document.getElementById('Edit_Column_div').innerHTML=results[1];//$("Edit_Column_div").innerHTML=results[1];
							 fnvshobj(obj, divid); 
                        }
                }
        );
}
/***
**签到报表（签到距离重新计算）17796: 常用报表->签到报表->添加重新计算按钮
***/
function recalculated_distance(obj,useReportid)
{
  
    callOftenUseReportSearch(obj,'BasicSearch');
}
function Exproteoftenusereport(useReportid)
{      
           var usereportid=document.forms['basicSearch'].UseReport.value;
    var url='index.php?module=OftenUseReport&action=ListView&ajax=true&Export=true&UseReport='+usereportid;
        var datefindcolumn=document.getElementsByName('datefindcolumn')[0].value;
        var otherfindcolumn=document.getElementsByName('otherfindcolumn')[0].value;
        //var startmonth=document.getElementsByName('startmonth')[0].value;
        //var endmonth=document.getElementsByName('endmonth')[0].value;
        var thequerytime=document.forms['basicSearch'].startmonth.value;//双时间录入框改为单时间段录入框
        //alert(thequerytime)
        var strs= new Array(); //定义一数组
        strs=thequerytime.split(" - "); //字符分割
        //alert(trim(strs[0]))
        //alert(trim(strs[1]))
        var startmonth=trim(strs[0]);
        var endmonth=trim(strs[1]);
        var receiverid='';
        if(document.getElementById('selectuserid')!=null){
               receiverid=document.getElementById('selectuserid').value;
            }
            var SmOwnerSearchScope='';
            if(document.getElementById('SmOwnerSearchScope')!=null){
                SmOwnerSearchScope=document.getElementById('SmOwnerSearchScope').value;
            }
         //var receiverid=document.forms['basicSearch'].receiverid.value;
            url+='&receiverid='+receiverid+'&SmOwnerSearchScope='+SmOwnerSearchScope;
    var searchtype=document.getElementById('printsearchType').value;//$('printsearchType').value;

    //alert(SmOwnerSearchScope);
    if(searchtype=="advSearch")
    {
   	    var advft_criteria =document.getElementById('advft_criteria').value;// $('advft_criteria').value;
        var advft_criteria_groups =document.getElementById('advft_criteria_groups').value;// $('advft_criteria_groups').value;
        url+='&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+"&searchtype=advSearch";
    }
    else if(searchtype=="basicSearch"||searchtype=="BasicSearch")
    {
        if(document.forms['basicSearch'].basicotherfindsapp2!=undefined&&document.forms['basicSearch'].basicotherfindsapp2.value!=undefined){
          
            var basicotherfindsapp2=document.getElementById("basicotherfindsapp2").checked;
            url+='&basicotherfindsapp2='+basicotherfindsapp2;
        }
        if(document.forms['basicSearch'].basicotherfinds!=undefined&&document.forms['basicSearch'].basicotherfinds.value!=undefined&&document.forms['basicSearch'].basicotherfinds.value!=""){
            var basicotherfindz=document.forms['basicSearch'].basicotherfindz.value;
            var basicotherfinds=document.forms['basicSearch'].basicotherfinds.value;
            url+='&basicotherfinds='+basicotherfinds+'&basicotherfindz='+basicotherfindz;
        }
        if(document.forms['basicSearch'].basicotherfindsbill!=undefined&&document.forms['basicSearch'].basicotherfindsbill.value!=undefined&&document.forms['basicSearch'].basicotherfindsbill.value!=""){
            var basicotherfindsbill=document.forms['basicSearch'].basicotherfindsbill.value;

            url+='&basicotherfindsbill='+basicotherfindsbill;
        }
        if(document.forms['basicSearch'].basicotherfind2!=undefined&&document.forms['basicSearch'].basicotherfind2.value!=undefined&&document.forms['basicSearch'].basicotherfind2.value!=""){
            var basicotherfind2=document.forms['basicSearch'].basicotherfind2.value;
            url+='&basicotherfind2='+basicotherfind2;
        }
        if(document.forms['basicSearch'].basicotherfind3!=undefined&&document.forms['basicSearch'].basicotherfind3.value!=undefined&&document.forms['basicSearch'].basicotherfind3.value!=""){
            var basicotherfind3=document.forms['basicSearch'].basicotherfind3.value;
            url+='&basicotherfind3='+basicotherfind3;
        }
        if(document.forms['basicSearch'].basicotherfind4!=undefined&&document.forms['basicSearch'].basicotherfind4.value!=undefined&&document.forms['basicSearch'].basicotherfind4.value!=""){
            var basicotherfind4=document.forms['basicSearch'].basicotherfind4.value;
            url+='&basicotherfind4='+basicotherfind4;
        }
        if(document.forms['basicSearch'].basicotherfind5!=undefined&&document.forms['basicSearch'].basicotherfind5.value!=undefined&&document.forms['basicSearch'].basicotherfind5.value!=""){
            var basicotherfind5=document.forms['basicSearch'].basicotherfind5.value;
            url+='&basicotherfind5='+basicotherfind5;
        }
        if(document.forms['basicSearch'].basicotherfind6!=undefined&&document.forms['basicSearch'].basicotherfind6.value!=undefined&&document.forms['basicSearch'].basicotherfind6.value!=""){
            var basicotherfind5=document.forms['basicSearch'].basicotherfind6.value;
            url+='&basicotherfind6='+basicotherfind6;
        }
        if(document.forms['basicSearch'].basicotherfindsapp!=undefined&&document.forms['basicSearch'].basicotherfindsapp.value!=undefined&&document.forms['basicSearch'].basicotherfindsapp.value!=""){
            var basicotherfindsapp=document.forms['basicSearch'].basicotherfindsapp.value;
            url+='&basicotherfindsapp='+basicotherfindsapp;
        }
        url+='&datefindcolumn='+datefindcolumn+'&startmonth='+startmonth+'&endmonth='+endmonth;
        url+="&UseReport="+useReportid;
        if(document.getElementsByName('basicotherfind')[0]){
        if(document.getElementsByName('basicotherfind')[0].value!=undefined&&document.getElementsByName('basicotherfind')[0].value!="")
        {
            url+='&otherfindcolumn='+otherfindcolumn+'&basicotherfind='+encodeURIComponent(document.getElementsByName('basicotherfind')[0].value);
        }
        }
        url+='&ajax=true&searchtype=BasicSearch';
        
    }
    //排行维度
	if(document.forms['basicSearch'].salesranking_value != undefined && document.forms['basicSearch'].salesranking_value.value != ""){
		var salesranking_value=document.forms['basicSearch'].salesranking_value.value;
		url+='&salesranking_value='+salesranking_value;
	}
	if(ld('#check_approve_status') != undefined){
		if(ld("#check_approve_status").prop("checked") == true){
			url+='&check_approve_status=yes';
		}else{
			url+='&check_approve_status=no';
		}
	} 
        //alert(url);
   //  location.href="index.php?module=OftenUseReport&action=ExportOftenUseReport&usereportid="+useReportid;
   location.href=url;
}

function SaveUseReportColumn(obj)
{
    
    var tab=document.getElementById('editColumnTable');
    var tabrows=tab.rows.length;
    var txt="";
    var txtc="";
    for(var i=1;i<tabrows;i++)
    {
         if(trim(document.getElementById('txt'+i).value)==''||trim(document.getElementById('txtc'+i).value)=='')
         {
            //显示名称不能为空！
            var confirm_str = arrJsPopLabel['DISPLAYNAMECANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            document.getElementById('txt'+i).focus();
            document.getElementById('txtc'+i).focus();
            return false;
         }
         else
         {
           
                txt+=('&txt'+i)+'='+encodeURIComponent(document.getElementById('txt'+i).value);
                txt+=('&txtc'+i)+'='+encodeURIComponent(document.getElementById('txtc'+i).value);          
         }
    }
    var searchtype=document.getElementById('printsearchType').value;//$('printsearchType').value;
    var usereportid=document.forms['basicSearch'].UseReport.value;
  
   /*var advft_criteria = $('advft_criteria').value;
   var advft_criteria_groups = $('advft_criteria_groups').value;
   document.forms['frmeditcolumn'].editUseReportadv.value=advft_criteria;
   document.forms['frmeditcolumn'].editUseReportadv_group.value=advft_criteria_groups;
    */

    var receiverid=document.forms['basicSearch'].receiverid.value;
    //var startmonth=document.forms['basicSearch'].startmonth.value;
    //var endmonth=document.forms['basicSearch'].endmonth.value;
    var thequerytime=document.forms['basicSearch'].startmonth.value;//双时间录入框改为单时间段录入框
    //alert(thequerytime)
    var strs= new Array(); //定义一数组
    strs=thequerytime.split(" - "); //字符分割
    //alert(trim(strs[0]))
    //alert(trim(strs[1]))
    var startmonth=trim(strs[0]);
    var endmonth=trim(strs[1]);
    
    var datefindcolumn=document.forms['basicSearch'].datefindcolumn.value;
    if(document.forms['basicSearch'].otherfindcolumn!=undefined)
        var otherfindcolumn=document.forms['basicSearch'].otherfindcolumn.value;
    useReportid=document.forms['basicSearch'].UseReport.value;
   
   lingdangJS_DialogBox.block();
   var columnid=document.forms['frmeditcolumn'].columnid.value;
   if(searchtype=='advSearch')
   {
        var advft_criteria = document.getElementById('advft_criteria').value;//$('advft_criteria').value;
       var advft_criteria_groups =document.getElementById('advft_criteria_groups').value;// $('advft_criteria_groups').value;
    	new Ajax.Request(
                    'index.php',
                    {queue: {position: 'end', scope: 'command'},
                            method: 'post',
                            postBody: 'action=ListView&ajax=true&module=OftenUseReport&submode=editColumnName&UseReport='+usereportid+'&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+"&searchtype=advSearch"+txt+'&columnid='+columnid,
                            onComplete: function(response) {
    						   var results=response.responseText.split("###SUCCESS###");
                                document.getElementById('UseReportList').innerHTML=results[1];;//$("UseReportList").innerHTML=results[1];
    							fninvshnew('EditUseReportColum');
                            }
                    }
            );
   }
   else
   {
      var url='module=OftenUseReport&action=ListView';
      url+='&datefindcolumn='+datefindcolumn+'&startmonth='+startmonth+'&endmonth='+endmonth;
        url+='&receiverid='+receiverid+"&UseReport="+useReportid;
        if(document.forms['basicSearch'].basicotherfind!=undefined&&document.forms['basicSearch'].basicotherfind.value!="")
        {
            url+='&otherfindcolumn='+otherfindcolumn+'&basicotherfind='+encodeURIComponent(document.forms['basicSearch'].basicotherfind.value);
        }
        url+='&ajax=true&searchtype=BasicSearch&submode=editColumnName'+txt+'&editenColumnName'+txtc+'&columnid='+columnid;
        
        
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
                        document.getElementById('status').style.display="none";//$("status").style.display='none';
                        var results=response.responseText.split("###SUCCESS###");
                      
                        document.getElementById('UseReportList').innerHTML=results[1];//$("UseReportList").innerHTML=results[1];
                       	fninvshnew('EditUseReportColum');
                         
                    }
                }
          )
   }

        
}



 function positiveInteger(num)
    {
        if (num=="")
        {            
                return false;
        }
            
        if (!(/(^[1-9]\d*$)/.test(num)))
        {
                return false;
        }
           
        return true;
    }
//adny   0012185: 建议优化合同订单跟踪表中显示列设置字段的显示方式 
function copySelectedOptionsOftenUserReport(source, destination) {

    var srcObj =document.getElementById(source);// $(source);
	var destObj =document.getElementById(destination);// $(destination);
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


function addListener(element, e, fn) {
    if (element.addEventListener) {
        element.addEventListener(e, fn, false);
    } else {
        element.attachEvent("on" + e, fn);
    }
}
function BodyClick(obj,lay){
    addListener(document, "click",
    function(evt) {
        var evt = window.event ? window.event: evt,
        target = evt.srcElement || evt.target;
        
        if (target == obj||target.id == lay||target.parentNode==undefined) {
            document.getElementById(lay).style.display = "";
            document.getElementById(lay).style.zIndex=1; 
            return;
        } else {
            while (target.nodeName.toLowerCase()) {
                target = target.parentNode;
                if(target==undefined)
                {
                    //document.getElementById(lay).style.display="";
                    return ;
                }
                if (target== obj||target.id == lay) {
                    document.getElementById(lay).style.display = "";
                    return;
                }
                if (target.nodeName.toLowerCase() == "body") {
                    document.getElementById(lay).style.display = "none";
                    return;
                }
            }
        }
    });
}

function ViewReportPopup(potentialid,obj){
    	$("status").style.display="inline";
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'action=popupreport&module=OftenUseReport&ReportHeader=DHeader&potentialid='+potentialid,
			onComplete: function(response) {
    			$("status").style.display="none";
    			$("DivPopupReport").style.display ='none';
                $("DivPopupReport").style.zIndex='9999';
    			$("DivPopupReport").innerHTML=response.responseText;
                fnvshobj(obj,'DivPopupReport');
			}
		}
		);
}

//TimeSheet个人月汇总表 
function CallTimeSheet(obj,searchtype)
{
    
    var begin_createdate = document.forms['basicSearch'].begin_createdate.value;//开始时间   
    var end_createdate = document.forms['basicSearch'].end_createdate.value;//结束时间
    if(begin_createdate.length>0&&end_createdate.length>0)
    {
        if(begin_createdate>end_createdate) 
        {
            //请正确输入时间范围！
            var confirm_str = arrJsPopLabel['THESTARTTIME'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false; 
        }
        
    }
    //开始日期为空警告
    if(begin_createdate.length == 0)
        {
            var confirm_str = arrJsPopLabel['STARTDATE']+arrJsPopLabel['CANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
    //结束时间不能为空
    if(end_createdate.length == 0)
        {
            var confirm_str = arrJsPopLabel['ENDDATE']+arrJsPopLabel['CANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
    var url='module=OftenUseReport&action=ListView';
    url += '&begin_createdate='+begin_createdate;
    url += '&end_createdate='+end_createdate;
    var userid = document.forms['basicSearch'].SmOwnerSearchScope.value;
    url += '&userid='+userid;
    var UseReport = document.forms['basicSearch'].UseReport.value;
    url += '&UseReport='+UseReport;
    url += '&ajax=true';
    new Ajax.Request(
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
                document.getElementById('status').style.display="none";
                var results=response.responseText.split("###SUCCESS###");
                document.getElementById('AjaxTimeSheetTable').innerHTML=results[1];
            }
        }
    )
   
}

function signimg_preview(signid){
	//1、生成黑色底色
       /* if(document.getElementById("workimgbgDiv") != undefined){
			
            document.getElementById("workimgbgDiv").style.height = '100%';
			show("workimgbgDiv");
		}else{*/
			 if(document.getElementById("workimgbgDiv") != undefined){
				var my = document.getElementById("workimgbgDiv");
				if (my != null)
					my.parentNode.removeChild(my);
			 }
			var bgObj = document.createElement("div");
			bgObj.setAttribute('id','workimgbgDiv');
			bgObj.style.position="fixed";
			bgObj.style.top="0";
			bgObj.style.background="#000000";
			bgObj.style.color="#FFF";
			//bgObj.style.filter="progid:DXImageTransform.Microsoft.Alpha(style=3,opacity=25,finishOpacity=75";
			//bgObj.style.opacity="0.3";
			bgObj.style.left="0";
			bgObj.style.width='100%';
			bgObj.style.height='100%';
			bgObj.style.zIndex = "10000";
			document.body.appendChild(bgObj);
			//
			var imgbg = '<div style="height: inherit;"><div class="imgbg-header"><span class="panel-visible-h" style="display: block;">×</span></div>';//顶层
			imgbg += '<div class="imgbg-content">';
			imgbg += '<div class="imgbg-left"><a href="javascript:;">‹</a></div>';
			imgbg += '<div class="imgbg-right"><a href="javascript:;">›</a></div>';
			imgbg += '<div class="imgbg-view"></div>';
			imgbg += '</div></div>';
			ld(bgObj).html(imgbg);
		//}
		var img = '<div><img src="'+ld('#signimage_'+signid+' span:first').find("img").attr('src')+'"></div>';
		ld('#workimgbgDiv .imgbg-content div:eq(2)').html(img);
		var imgobj = ld('#signimage_'+signid+' span:first').find("img");//记录当前点击的图片对象
		var achmentid =  ld('#signimage_'+signid+' span:first').attr('achmentid');//获取当前图片对应的ID
		var idx = 0;var imglen = ld('#signimage_'+signid+' span').length;
		//关闭图片显示浮层
		ld('#workimgbgDiv div.imgbg-header span.panel-visible-h').on('click',function(){
			ld('#workimgbgDiv').css('display','none');
		});
       
		if(imglen < 2){//不到两个图片
			ld('#workimgbgDiv .imgbg-content div:eq(0)').addClass('ui-visibhide');
			ld('#workimgbgDiv .imgbg-content div:eq(1)').addClass('ui-visibhide');
			return false;
		}else{//显示左右标签
			ld('#workimgbgDiv .imgbg-content div:eq(0)').removeClass('ui-visibhide');
			ld('#workimgbgDiv .imgbg-content div:eq(1)').removeClass('ui-visibhide');
		}
		//循环所有图片，判断当前图片的位置
		ld(this).parent().parent().find('span').each(function(){
			if(achmentid == ld(this).attr('achmentid')){//找到当前点击的ID值
				return false;//结束本次循环
			}
			idx ++;
		});
       if(idx==0)
       {
           //017756: 首页>工作协同>发微博、发日志、发任务：上传多个图片，查看图片，不会判断最后一张和第一张。可以一直翻下一页。       
         ld('#workimgbgDiv .imgbg-content .imgbg-left').addClass('ui-visibhide');
       }
       else if(idx==imglen-1)
       {
        //017756: 首页>工作协同>发微博、发日志、发任务：上传多个图片，查看图片，不会判断最后一张和第一张。可以一直翻下一页。
        ld('#workimgbgDiv .imgbg-content .imgbg-right').addClass('ui-visibhide');
       }
		//左标签
		ld('#workimgbgDiv .imgbg-content div:eq(0)').find('a').on('click',function(){
		  
			if(idx == 0){//就是最左边的图片，则自动切换到最后一张图片
				idx = imglen - 1;
                ld('#workimgbgDiv .imgbg-content .imgbg-left').addClass('ui-visibhide');
			}else{//切换到左边的图片
				idx --;
                if(idx==0)
                {
                   //017756: 首页>工作协同>发微博、发日志、发任务：上传多个图片，查看图片，不会判断最后一张和第一张。可以一直翻下一页。
                    ld('#workimgbgDiv .imgbg-content .imgbg-left').addClass('ui-visibhide');
                }
                ld('#workimgbgDiv .imgbg-content .imgbg-right').removeClass('ui-visibhide');
			}
			imgobj = ld(imgobj).parent().parent().find('span:eq('+idx+')');
			var imgsrc = ld(imgobj).find('img').attr('src');
			ld('#workimgbgDiv .imgbg-content div:eq(2) img').attr('src',imgsrc);
			return false;
		});
		//右标签
		ld('#workimgbgDiv .imgbg-content div:eq(1)').find('a').on('click',function(){
			if(idx == imglen - 1){//就是最右边的图片，则自动切换到第一张图片
				idx = 0;
                
			}else{//切换到右边的图片
				idx ++;
                if(idx==imglen-1)
                {
                    //idx = 0;
                    ld('#workimgbgDiv .imgbg-content .imgbg-right').addClass('ui-visibhide');
                }
                ld('#workimgbgDiv .imgbg-content .imgbg-left').removeClass('ui-visibhide');
			}
			imgobj = ld(imgobj).parent().parent().find('span:eq('+idx+')');
			var imgsrc = ld(imgobj).find('img').attr('src');
			ld('#workimgbgDiv .imgbg-content div:eq(2) img').attr('src',imgsrc);
			return false;
		});
}
function sign_recalculate(obj,signid){
    document.getElementById('status').style.display="inline";
    ld.post("index.php",{module:"OftenUseReport" ,file:"RecalculateDistance",signid:signid,'ajax':'true','action':"OftenUseReportAjax"},function(response) {
        document.getElementById('status').style.display="none";
        ld(obj).parent().parent().children().each(function(){
            var td_tag = ld(this).attr('tag');
            if(td_tag==='distance'){
                if(response.indexOf('###DISTANCE###')>-1){
                    var results=response.split("###DISTANCE###");
                    ld(this).text(results[1]);
                }else{
                    ld(this).text('无法计算');
                }
            }else if(td_tag==='bill_street'){
                //editor:gyq_20181023	0035431: 报表-常用报表-签到统计表，点击重新计算的时候应该根据客户最新的地址跟签到地址显示误差
                if(response.indexOf('###ADDRESS###')>-1){
                    var results=response.split("###ADDRESS###");
                    ld(this).text(results[1]);
                }else{
                    ld(this).text('-');
                }
            }
        })
    });
}
