/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/		
		


//document.write("<script type='text/javascript' src='include/js/Mail.js'></"+"script>");
function toggleDisplay(id){
		
if(this.document.getElementById( id).style.display=='none'){
	this.document.getElementById( id).style.display='inline'
	this.document.getElementById(id+"link").style.display='none';
					
}else{
	this.document.getElementById(  id).style.display='none'
	this.document.getElementById(id+"link").style.display='none';
	}
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

function add_data_to_relatedlist_incal(id,name)
{
	var idval = window.opener.document.EditView.contactidlist.value;
	var nameval = window.opener.document.EditView.contactlist.value;
	if(idval != '')
	{
		if(idval.indexOf(id) != -1)
                {
                        window.opener.document.EditView.contactidlist.value = idval;
                        window.opener.document.EditView.contactlist.value = nameval;
                }
                else
                {
                        window.opener.document.EditView.contactidlist.value = idval+';'+id;
			if(name != '')
                	{
				// this has been modified to provide delete option for Contacts in Calendar
				//this function is defined in script.js ------- Jeri
				window.opener.addOption(id,name);
                	}

                }
	}
	else
	{
		window.opener.document.EditView.contactidlist.value = id;
		if(name != '')
		{
			window.opener.addOption(id,name);
		}
		//end
	}
}

function add_data_to_relatedlist(entity_id,recordid) {
    //38755: (51mis.com/kfbcrm)客户>客户管理>全部（含所有公海）：单据明细界面，左侧相关点击“市场活动”字段，点击“选择”按钮，弹出层任意点击“市场活动名称”，提示报错。
       var detailviewpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
      
       var popupobj=CrmPopup.getPopupObj('lastprev');
      // alert("module="+detailviewpopupobj.module+"&action="+detailviewpopupobj.module+"Ajax&file=updateRelations&destination_module=Accounts&idlist="+entity_id+"&parentid="+recordid);
	new Ajax.Request(
	'index.php',
    	{
    		queue: {
    			position: 'end',
    			scope: 'command'
    		},
    		method: 'post',
    		postBody:"module="+detailviewpopupobj.module+"&action="+detailviewpopupobj.module+"Ajax&file=updateRelations&destination_module="+popupobj.module+"&idlist="+entity_id+"&parentid="+recordid,
    		onComplete: function(response) {
    			var popupobj=CrmPopup.getPopupObj('lastprev');
             
    			var divid = popupobj.divid;
    			var related_id =popupobj.relateid; CrmPopup.findHtmlobj(divid,'hidden_related_id_Contacts').val();
    			var viewid = CrmPopup.findHtmlobj(divid,'viewname_Contacts').val();
             
    			cancelCrmPopup();
               //38825: （51mis.com/kfbcrm）客户管理>联系人>选择编号为“CON547”进入明细界面>选择“市场活动”界面：弹出层点击蓝色“市场活动名称”字段没有反应。
                var urldata = "&header="+detailviewpopupobj.module+"&record="+detailviewpopupobj.record;
            	urldata += "&relatedid="+related_id+"&currpage=1&related_left_type=1";
            	//urldata += '&switchview='+viewid;
             
            	//setRelListAjax(urldata,related_id);
                
    		//	showRelatedCustomView(related_id,viewid);
    			//popupobj.relatelistsizeobj.setRelatedResizeTable_Init('Contacts');
    		//	set_rel_count();
                        var lastpopupobj=CrmPopup.getPopupObj('last');
                        var tmparra=new Array();
                          tmparra.push(popupobj.record);
                          
                        var tmpobj= new AfterUpdatePrevPopupObjContent(lastpopupobj.module,getEmptyValueInfo(),tmparra);
                        tmparra=[lastpopupobj.module];
                        tmpobj.eachrefreshlistbyModules(tmparra);
                        delete tmpobj;
    		}
    	}
	);
}
function set_return_specific(product_id, product_name) {
        //Used for DetailView, Removed 'EditView' formname hardcoding
        var fldName = getOpenerObj("contacts_name");
        var fldId = getOpenerObj("contact_id");
        fldName.value = product_name;
        fldId.value = product_id;
}
//only for Todo
function set_return_toDospecific(product_id, product_name) {
        var fldName = getOpenerObj("task_contact_name");
        var fldId = getOpenerObj("task_contact_id");
        fldName.value = product_name;
        fldId.value = product_id;
}

function submitform(id){
		document.massdelete.entityid.value=id;
		document.massdelete.submit();
}	

function searchMapLocation(addressType)
{
        var mapParameter = '';
        if (addressType == 'Main')
        {
		if(fieldname.indexOf('mailingstreet') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingstreet')]))	
				mapParameter = document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingstreet')]).innerHTML+' ';
		}
		if(fieldname.indexOf('mailingcity') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingcity')]))
				mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingcity')]).innerHTML+' ';
		}
		if(fieldname.indexOf('mailingstate') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingstate')]))
	                        mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingstate')]).innerHTML+' ';
		}
		if(fieldname.indexOf('mailingcountry') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingcountry')]))
				mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingcountry')]).innerHTML+' ';
		}
		if(fieldname.indexOf('mailingzip') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingzip')]))
				mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingzip')]).innerHTML;
		}
        }
        else if (addressType == 'Other')
        {
		if(fieldname.indexOf('otherstreet') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('otherstreet')]))
				mapParameter = document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('otherstreet')]).innerHTML+' ';
		}
		if(fieldname.indexOf('othercity') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('othercity')]))
				mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('othercity')]).innerHTML+' ';
		}
		if(fieldname.indexOf('otherstate') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('otherstate')]))
	                        mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('otherstate')]).innerHTML+' ';
		}
                if(fieldname.indexOf('othercountry') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('othercountry')]))
				mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('othercountry')]).innerHTML+' ';
		}
                if(fieldname.indexOf('otherzip') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('otherzip')]))
                        	mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('otherzip')]).innerHTML;
		}
        }
	mapParameter = removeHTMLFormatting(mapParameter);
	window.open('http://maps.google.com/maps?q='+mapParameter,'goolemap','height=450,width=700,resizable=no,titlebar,location,top=200,left=250');
}
/**detailview_email_contact_show
更新操作
edit:cdw
date:20131120
reason:联系人详细界面群发邮件功能改进
**/
function detailview_email_contact_show()
{
	var allids=document.forms['DetailView'].record.value;
    // $("status").style.display="inline";
	var url = "module=Contacts&action=sendEmailField&parenttab=Parent Accounts&ReportHeader=dbheader&allids="+allids;
	ldAjaxHtmlNoProgress('index.php',url,function (response) {
		var tmparr = [];
		tmparr.push('Contacts');
		var popupobj = CrmPopup.load(arrJsPopLabel['PLEASESELECTEMAIL'], chosebox_select_btn_email, "", "LdPopWidth500px", 'Contacts', '', arrJsPopLabel['SAVE'], tmparr, arrJsPopLabel['CANCEL']);
		var results = response.split('&#&#&#');
		popupobj.show(results[1]);
	});
}
/**
更新操作
edit:cdw
date:20131120
reason:联系人详细界面群发短信功能改进
***/
function detailview_MassSMS_contact_show()
{
	var allids=document.forms['DetailView'].record.value;
	var url = "module=Contacts&action=sendSMSField&parenttab=Parent Accounts&ReportHeader=dbheader&allids="+allids;
	ldAjaxHtml('index.php',url,function (response) {
		DelProgressObjs();
		var tmparr = [];
		tmparr.push('Contacts');
		var popupobj = CrmPopup.load(arrJsPopLabel['PLEASESELECTEMAIL'], chosebox_select_btn, "", "LdPopWidth500px", 'Contacts', '', arrJsPopLabel['SAVE'], tmparr, arrJsPopLabel['CANCEL']);
		var results = response.split('&#&#&#');
		popupobj.show(results[1]);
	});

}



//查看联系人上下级关系
var getContactHierarchy = function(contactid){
	var scopepopupobj;//自定义弹出层页面html，绑定事件
	var popup_account_url = 'module=Users&action=UsersAjax&file=viewcontactinfo&popup_scopetype=private&popup_module=Contacts&contactid='+contactid+'&popup_selecttype=user';
	var popup_searchTextDiv_html = '<div id=\'popup_search_div\' style=\'padding-left:59px;display: block;position: absolute;top: 104px;\'><div class=\'view-search\' ></div></div>';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		scopepopupobj =  new ScopePopupObj('Contacts');
        scopepopupobj.popup_caption_value = arrJsPopLabel['Viewupperandlowerrelations'];//标题title
		scopepopupobj.popup_searchTextDiv = popup_searchTextDiv_html;
		scopepopupobj.popup_header = '';
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
           cls_ScopePopup.prop.popup_module = 'Contacts';//模块
		   cls_ScopePopup.prop.popup_url = popup_account_url;
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		   // ld('#'+cls_ScopePopup.popup_divid).attr('class','D_pop_box LdPopWidth500px ui-popup');
		   // ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').hide();
		   // ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').val(arrJsPopLabel['LBL_CLOSE']);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
					return false;
                });
            }
		});
	});
}

// @edit:dong @date:2020/08/04 @reason: 移动到listview.js
/*
var location_lat = 0;
var location_lng = 0;
function getLocationAddress(fldname,mode){
	
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	//默认省份
	var bill_state = '';
	var bill_city = '';
	if(mode == 'edit'){
		bill_state = CrmPopup.findHtmlobj(divid,'bill_state').val();
		bill_city = CrmPopup.findHtmlobj(divid,'bill_city').val();
	}else if(mode == 'detail'){
		bill_state =trim(ld('#dtlview_bill_state font').html());
		bill_city = trim(ld('#dtlview_bill_city font').html());
	}
	//定位地址
	var address  = '';
	if(!empty(fldname) && CrmPopup.findHtmlobj(divid,fldname).val() != undefined){
		address = CrmPopup.findHtmlobj(divid,fldname).val();
	}
	if(empty(address) && (!empty(bill_state) || !empty(bill_city))){
		address = bill_state + bill_city;
	}
	//详情页
	if(mode == 'detail' && document.getElementById('dtlview_locationaddress') != undefined && document.getElementById('dtlview_locationaddress').innerHTML != ''){
		address = document.getElementById('dtlview_locationaddress').innerHTML;
	}
	if(empty(address))return '';
	var module_mod = '';
	if(mode == 'detail' || mode == 'edit'){
		var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint=yes";	//单
	}else{
		var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint_list=yes";	//多、列表
		module_mod = 'select';
	}
	new Ajax.Request
	(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:urlajax,
				onComplete: function(response) 
				{
					var results = trim(response.responseText);    
					var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
					if(restobj != ''){
						 ld('#'+divid + ' .f-item').css('display', 'block');
						if(empty(module_mod)){
							location_lat = restobj['entries']['lat'];
							location_lng = restobj['entries']['lng'];
							//创建script标签
							var script = document.createElement("script");
							//设置标签的type属性
							script.type = "text/javascript";
							//设置标签的链接地址
							script.src = "https://map.qq.com/api/js?v=2.exp&callback=initMap&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X";
							//添加标签到dom
							document.body.appendChild(script);
						}else{
							var info = '';
							for(var i in restobj['entries']){
								if(restobj['entries'][i]['address'] != undefined){
									info += '<li state="'+restobj['entries'][i]['state']+'" city="'+restobj['entries'][i]['city']+'" district="'+restobj['entries'][i]['district']+'" address="'+restobj['entries'][i]['address']+'" point="'+restobj['entries'][i]['point']+'" country="'+restobj['entries'][i]['country']+'">';
									info += '<span>'+restobj['entries'][i]['address']+'</span>';
									info += '</li>';

								}
							}

							CrmPopup.findHtmlobj(divid,'search_location_address').html(info);
							CrmPopup.findHtmlobj(divid,'search_location_address').show();

			              ld('#'+divid).unbind('click').on('click',function(){
			                CrmPopup.findHtmlobj(divid,'search_location_address').hide();
			              })
							
							ld('#search_location_address').find('li').each(function() {
								ld(this).click(function() {
									var district = ld(this).attr('district');
									var state = ld(this).attr('state');
									var city = ld(this).attr('city');
									var address = ld(this).attr('address');
									var point = ld(this).attr('point');
									var country = ld(this).attr('country'); 
									var point_arr = point.split(',');
									location_lat = point_arr[0];
									location_lng = point_arr[1];
									//city = trim(city.replace('市',''));
									if(CrmPopup.findHtmlobj(divid,'mailingstreet').val() != undefined && CrmPopup.findHtmlobj(divid,'mailingstreet').val() != ''){
										RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['doyouuselocationaddress']);
										ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
											CrmPopup.findHtmlobj(divid,'locationaddress').val(address);
											scriptMap(address,district,city,state,country)
										});
										ld('input[class="D_pbtncancel"]').unbind('click').on('click',function(){
					                      CrmPopup.findHtmlobj(divid,'search_location_address').hide();
					                    });
									}else{
										CrmPopup.findHtmlobj(divid,'locationaddress').val(address);
										scriptMap(address,district,city,state,country)
									}
								})
							})

						}
					}else{
						//var info = '<li><span>'+arrJsPopLabel['thelocationaddress']+'</span></li>';
						//CrmPopup.findHtmlobj(divid,'search_location_address').html(info);
						//CrmPopup.findHtmlobj(divid,'search_location_address').show();
						ld('#'+divid + ' .f-item').css('display', 'none');
					}
					
				}
			}
	  )
}
//加载地图
function scriptMap(address,district,city,state,country){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	CrmPopup.findHtmlobj(divid,'bill_street').val(address);
	if(CrmPopup.findHtmlobj(divid,'mailingstreet').val() != undefined){
		CrmPopup.findHtmlobj(divid,'mailingstreet').val(address);
	}
	if(CrmPopup.findHtmlobj(divid,'bill_city').val() != undefined){
		CrmPopup.findHtmlobj(divid,'bill_city').val(city);
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_city').html(city);
	}
	
	if(CrmPopup.findHtmlobj(divid,'bill_state').val() != undefined){
		CrmPopup.findHtmlobj(divid,'bill_state').val(state);
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_state').html(state);
	}
	if(CrmPopup.findHtmlobj(divid,'bill_area').val() != undefined){
		CrmPopup.findHtmlobj(divid,'bill_area').val(district);
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_area').html(district);
	}
	if(CrmPopup.findHtmlobj(divid,'bill_country').val() != undefined){
		CrmPopup.findHtmlobj(divid,'bill_country').val(country);
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_country').html(country);
	}
	CrmPopup.findHtmlobj(divid,'search_location_address').hide();
	//创建script标签
	var script = document.createElement("script");
	//设置标签的type属性
	script.type = "text/javascript";
	//设置标签的链接地址
	script.src = "https://map.qq.com/api/js?v=2.exp&callback=initMap&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X";
	//添加标签到dom
	document.body.appendChild(script);
}
//加载地图api后的回调函数
function initMap(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var center = new qq.maps.LatLng(location_lat,location_lng);
	//定义map变量 调用 qq.maps.Map() 构造函数   获取地图显示容器
	ld("#"+divid+" [name=location_map_td]").show();
	 var map = new qq.maps.Map(ld("#"+divid+" [name=container]")[0], {
		center: center,      // 地图的中心地理坐标。
		zoom:15,                                                 // 地图的中心地理坐标。
		disableDefaultUI: true
	});
	//创建标记
	var anchor = new qq.maps.Point(6, 6),
	size = new qq.maps.Size(23, 38),
	origin = new qq.maps.Point(0, 0),
	icon = new qq.maps.MarkerImage('themes/images/location.png', size, origin, anchor);
	var marker = new qq.maps.Marker({
		icon: icon,
		position: center,
		map: map
	});
}

function enlarge_map(address){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	if(empty(address)){
		address = CrmPopup.findHtmlobj(divid,'locationaddress').val();
	}
	var record = CrmPopup.findHtmlobj(divid,'record').val();
	var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint=yes&record="+popupobj.record+"&frommodule="+popupobj.module;	//单
	new Ajax.Request
	(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:urlajax,
				onComplete: function(response) 
				{
					var results = trim(response.responseText);
					var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
					if(restobj != ''){
						location_lat = restobj['entries']['lat'];
						location_lng = restobj['entries']['lng'];
						var table_html = '<div name="big_container" id="big_container" style="height:500px;"></div>';
						resultRemindsMsg(arrJsPopLabel['ACCOUNTSMAP'],"LdPopWidth800px","","yes","",table_html);
						//创建script标签
						var script = document.createElement("script");
						//设置标签的type属性
						script.type = "text/javascript";
						//设置标签的链接地址
						script.src = "https://map.qq.com/api/js?v=2.exp&callback=Big_initMap&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X";
						//添加标签到dom
						document.body.appendChild(script);
					}
				}
			}
	  )
}
//
function Big_initMap(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var center = new qq.maps.LatLng(location_lat,location_lng);
	//定义map变量 调用 qq.maps.Map() 构造函数   获取地图显示容器
	var map = new qq.maps.Map(ld("#"+divid+" [name=big_container]")[0], {
		center: center,      // 地图的中心地理坐标。
		zoom:15,                                           // 地图的中心地理坐标。
		disableDefaultUI: true
	});
	//创建标记
	var anchor = new qq.maps.Point(6, 6),
	size = new qq.maps.Size(23, 38),
	origin = new qq.maps.Point(0, 0),
	icon = new qq.maps.MarkerImage('themes/images/location.png', size, origin, anchor);
	var marker = new qq.maps.Marker({
		icon: icon,
		position: center,
		map: map
	});
}
*/
