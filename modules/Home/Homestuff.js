/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 *******************************************************************************/

/**
 * this function is used to show hide the columns in the add widget div based on the option selected
 * @param string typeName - the selected option
 */
function chooseType(typeName){
	$('vtbusy_info').style.display="inline";
	$('stufftype_id').value=typeName;

	var typeLabel = typeName;
	if(alert_arr[typeName] != null && alert_arr[typeName] != "" && alert_arr[typeName] != 'undefined'){
		typeLabel = alert_arr[typeName];
	}
    if(typeLabel == 'defaultwidget'){
		$('divHeader').innerHTML="<b>"+alert_arr.LBL_SELECT+"</b>";
		$('vtbusy_info').style.display="inline";
		new Ajax.Request(
			'index.php',
			{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:'module=Home&action=HomeAjax&file=HomestuffAjax&home=homewidget',
			onComplete: function(response){
				var responseVal=response.responseText;
				$('home').innerHTML=response.responseText;
				show('addWidgetsDiv');
				placeAtCenter($('addWidgetsDiv'));
				$('homewidget').style.display="block";
				$('moduleNameRow').style.display="none";
				$('moduleFilterRow').style.display="none";
				$('modulePrimeRow').style.display="none";
				$('rssRow').style.display="none";
				$('showrow').style.display="none";
				$('dashTypeRow').style.display="none";
				$('dashNameRow').style.display="none";
				$('StuffTitleId').style.display="none";
				$('vtbusy_info').style.display="none";
				$('reportNameRow').style.display="none";
				$('reportTypeRow').style.display="none";
			}
			}
		);
	}else{
			$('divHeader').innerHTML="<b>"+alert_arr.LBL_ADD+typeLabel+"</b>";
	}
	if(typeName=='Module'){
		$('moduleNameRow').style.display="block";
		$('moduleFilterRow').style.display="block";
		$('modulePrimeRow').style.display="block";
		$('showrow').style.display="block";
		$('rssRow').style.display="none";
		$('dashNameRow').style.display="none";
		$('dashTypeRow').style.display="none";
		$('StuffTitleId').style.display="block";
		$('homewidget').style.display="none";
		$('reportNameRow').style.display="none";
		$('reportTypeRow').style.display="none";
		//$('homeURLField').style.display = "none";
	}else if(typeName=='DashBoard'){
		$('moduleNameRow').style.display="none";
		$('moduleFilterRow').style.display="none";
		$('modulePrimeRow').style.display="none";
		$('rssRow').style.display="none";
		$('showrow').style.display="none";
		$('dashNameRow').style.display="block";
		$('dashTypeRow').style.display="block";
		$('StuffTitleId').style.display="block";
		$('reportNameRow').style.display="none";
        $('reportTypeRow').style.display="none";
		$('homewidget').style.display="none";
		//$('homeURLField').style.display = "none";
		new Ajax.Request(
			'index.php',
			{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:'module=Home&action=HomeAjax&file=HomestuffAjax&dash=dashboard',
				onComplete: function(response){
					var responseVal=response.responseText;
					$('selDashName').innerHTML=response.responseText;
					show('addWidgetsDiv');
					placeAtCenter($('addWidgetsDiv'));
					$('vtbusy_info').style.display="none";
				}
			}
		);
	}else if(typeName=='RSS'){
		$('moduleNameRow').style.display="none";
		$('moduleFilterRow').style.display="none";
		$('modulePrimeRow').style.display="none";
		$('showrow').style.display="block";
		$('rssRow').style.display="block";
		$('dashNameRow').style.display="none";
		$('dashTypeRow').style.display="none";
		$('StuffTitleId').style.display="block";
		$('homewidget').style.display="none";
		$('vtbusy_info').style.display="none";
		$('reportNameRow').style.display="none";
		$('reportTypeRow').style.display="none";
		//$('homeURLField').style.display = "none";
	}else if(typeName=='Default'){
		$('moduleNameRow').style.display="none";
		$('moduleFilterRow').style.display="none";
		$('modulePrimeRow').style.display="none";
		$('showrow').style.display="none";
		$('rssRow').style.display="none";
		$('dashNameRow').style.display="none";
		$('dashTypeRow').style.display="none";
		$('StuffTitleId').style.display="none";
		$('homewidget').style.display="none";
		$('url_id').style.display = "none";
		$('reportNameRow').style.display="none";
		$('reportTypeRow').style.display="none";
	}else if(typeName == 'Notebook'){
		$('moduleNameRow').style.display="none";
		$('moduleFilterRow').style.display="none";
		$('modulePrimeRow').style.display="none";
		$('showrow').style.display="none";
		$('rssRow').style.display="none";
		$('dashNameRow').style.display="none";
		$('dashTypeRow').style.display="none";
		$('StuffTitleId').style.display="block";
		$('vtbusy_info').style.display="none";
		$('homewidget').style.display="none";
		$('reportNameRow').style.display="none";
		$('reportTypeRow').style.display="none";
		//$('homeURLField').style.display = "none";
	}
	else if(typeName == 'ReportCharts'){
		$('moduleNameRow').style.display="none";
		$('moduleFilterRow').style.display="none";
		$('modulePrimeRow').style.display="none";
		$('rssRow').style.display="none";
		$('showrow').style.display="none";
		$('StuffTitleId').style.display="block";
		$('reportNameRow').style.display="block";
		$('reportTypeRow').style.display="block";
		$('vtbusy_info').style.display="none";
        $('dashNameRow').style.display="none";
		$('dashTypeRow').style.display="none";
		$('homewidget').style.display="none";
		new Ajax.Request(
                    'index.php',
                    {queue: {position: 'end', scope: 'command'},
                            method: 'post',
                            postBody: 'module=Home&action=HomeAjax&file=HomeReportChart&ajax=true',
                            onComplete: function(response) {
                                        $('selReportName').innerHTML=response.responseText;
					show('addWidgetsDiv');
					placeAtCenter($('addWidgetsDiv'));
					$('vtbusy_info').style.display="none";
                        }
                    }
                 );
	}
	/*else if(typeName == 'URL'){
		$('moduleNameRow').style.display="none";
		$('moduleFilterRow').style.display="none";
		$('modulePrimeRow').style.display="none";
		$('showrow').style.display="none";
		$('rssRow').style.display="none";
		$('dashNameRow').style.display="none";
		$('dashTypeRow').style.display="none";
		$('StuffTitleId').style.display="block";
		$('vtbusy_info').style.display="none";
		//$('homeURLField').style.display = "block";
	}*/
}

/**
 * this function is used to set the filter list when the module name is changed
 * @param string modName - the modula name for which you want the filter list
 */
function setFilter(modName){
	var modval=modName.value;
	document.getElementById('savebtn').disabled = true;
	if(modval!=""){
		new Ajax.Request(
       		'index.php',
			{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:'module=Home&action=HomeAjax&file=HomestuffAjax&modname='+modval,
				onComplete: function(response){
					var responseVal=response.responseText;
					$('selModFilter_id').innerHTML=response.responseText;
					setPrimaryFld(document.getElementById('selFilterid'));
					show('addWidgetsDiv');
					placeAtCenter($('addWidgetsDiv'));
				}
			}
		);
	}
}

/**
 * this function is used to set the field list when the module name is changed
 * @param string modName - the modula name for which you want the field list
 */
function setPrimaryFld(Primeval){
	primecvid=Primeval.value;
	var fldmodule = $('selmodule_id').options[$('selmodule_id').selectedIndex].value;
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
		method: 'post',
		postBody:'module=Home&action=HomeAjax&file=HomestuffAjax&primecvid='+primecvid+'&fieldmodname='+fldmodule,
		onComplete: function(response){
			var responseVal=response.responseText;
			$('selModPrime_id').innerHTML=response.responseText;
			$('selPrimeFldid').selectedIndex = 0;
			$('vtbusy_info').style.display="none";
			document.getElementById('savebtn').disabled = false;
		}
	}
	);
}

/**
 * this function displays the div for selecting the number of rows in a widget
 * @param string sid - the id of the widget for which the div is being displayed
 */
function showEditrow(sid){
	$('editRowmodrss_'+sid).className="show_tab";
}

/**
 * this function is used to hide the div for selecting the number of rows in a widget
 * @param string editRow - the id of the div
 */
function cancelEntries(editRow){
	$(editRow).className="hide_tab";
}

/**
 * this function is used to save the maximum entries that a widget can display
 * @param string selMaxName - the widget name
 */
function saveEntries(selMaxName){
	sidarr=selMaxName.split("_");
	sid=sidarr[1];
	$('refresh_'+sid).innerHTML=$('vtbusy_homeinfo').innerHTML;
	cancelEntries('editRowmodrss_'+sid)
	showmax=$(selMaxName).value;
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:'module=Home&action=HomeAjax&file=HomestuffAjax&showmaxval='+showmax+'&sid='+sid,
			onComplete: function(response){
				var responseVal=response.responseText;
				eval(response.responseText);
				$('refresh_'+sid).innerHTML='';
			}
		}
	);
}

/**
 * this function is used to save the dashboard values
 */
function saveEditDash(dashRowId){
	$('refresh_'+dashRowId).innerHTML=$('vtbusy_homeinfo').innerHTML;
	cancelEntries('editRowmodrss_'+dashRowId);
	var dashVal='';
	var iter=0;
	for(iter=0;iter<3;iter++){
		if($('dashradio_'+[iter]).checked)
			dashVal=$('dashradio_'+[iter]).value;
	}
	did=dashRowId;
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:'module=Home&action=HomeAjax&file=HomestuffAjax&dashVal='+dashVal+'&did='+did,
			onComplete: function(response){
				var responseVal=response.responseText;
				eval(response.responseText);
				$('refresh_'+did).innerHTML='';
			}
		}
	);
}

/**
 * this function is used to delete widgets form the home page
 * @param string sid - the stuffid of the widget
 */
function DelStuff(sid){
	if(confirm(arrJsPopLabel['SUREWANTDELETE'])){
		new Ajax.Request(
			'index.php',
			{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:'module=Home&action=HomeAjax&file=HomestuffAjax&homestuffid='+sid,
				onComplete: function(response){
					var responseVal=response.responseText;
					if(response.responseText.indexOf('SUCCESS') > -1){
						var delchild = $('stuff_'+sid);
						odeletedChild = $('MainMatrix').removeChild(delchild);
						$('seqSettings').innerHTML= '<table cellpadding="10" cellspacing="0" border="0" width="100%" class="vtResultPop small"><tr><td align="center">Widget deleted sucessfully.</td></tr></table>';
						$('seqSettings').style.display = 'block';
						$('seqSettings').style.display = 'none';
						placeAtCenter($('seqSettings'));
						Effect.Appear('seqSettings');
						setTimeout(hideSeqSettings,3000);
					}else{
						alert(alert_arr.ERROR_DELETING_TRY_AGAIN)
					}
				}
			}
		);
	}
}

/**
 * this function loads the newly added div to the home page
 * @param string stuffid - the id of the newly created div
 * @param string stufftype - the stuff type for the new div (for e.g. rss)
 */
function loadAddedDiv(stuffid,stufftype){
	gstuffId = stuffid;
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:'module=Home&action=HomeAjax&file=NewBlock&stuffid='+stuffid+'&stufftype='+stufftype,
			onComplete: function(response){
				var responseVal=response.responseText;
				$('MainMatrix').style.display= 'none';
				$('MainMatrix').innerHTML = response.responseText + $('MainMatrix').innerHTML;
				positionDivInAccord('stuff_'+gstuffId,'',stufftype);
				initHomePage();
				loadStuff(stuffid,stufftype);
				$('MainMatrix').style.display='block';
			}
		}
	);
}
//刷新调用事件
function initWidgets(){
	loadAllWidgets(Vt_homePageWidgetInfoList);
}

/**
 * this function is used to reload a widgets' content based on its id and type
 * @param string stuffid - the widget id
 * @param string stufftype - the type of the widget
 */
function loadStuff(stuffid,stufftype){
    if(stuffid=='21'||stuffid=='2'||stuffid=='1'||stuffid=='4'||stuffid=='5'||stuffid=='9' ||stuffid=='24'){
        if($('a_'+stuffid) !=undefined)
        $('a_'+stuffid).style.display='none';
    }
	$('refresh_'+stuffid).innerHTML=$('vtbusy_homeinfo').innerHTML;
    var selectuid = 0;
	if(ld('#selectuserid') != undefined){
		selectuid = ld('#selectuserid').val();
	}
	var search_date = ld('.home-header-filter-select .header_value').attr('data-value');
	var search_date_custom_value = ld('#search_date_custom').val();	//自定义查询时间
	var approve_value = ld('.home-header-approve-select .approve_header_value').attr('approve-value');
     var url='module=Home&action=HomeAjax&file=HomeBlock&homestuffid='+stuffid+'&blockstufftype='+stufftype+'&selectuid='+selectuid+'&search_date='+search_date+'&date_custom='+search_date_custom_value+"&approve_value="+approve_value;
    if(loadStuff.param!="")
    {
       
        url+="&"+loadStuff.param;
    }
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
            //asynchronous:false,
		    postBody:url,
		    onComplete: function(response){
				var responseVal=response.responseText;
				$('stuffcont_'+stuffid).innerHTML=response.responseText;
                $('refresh_'+stuffid).innerHTML='';
				if(stufftype=="Default"&&typeof($('a_'+stuffid)) != 'undefined'){
					if($('more_'+stuffid)!=undefined && $('more_'+stuffid).value != ''){
						$('a_'+stuffid).style.display = 'block';
                        var url;                       
						 url = "index.php?module="+$('more_'+stuffid).value+"&action=index&selectuid="+selectuid;
						if($('search_qry_'+stuffid)!=''){
							url += $('search_qry_'+stuffid).value;
						}
						$('a_'+stuffid).href = url;
					}else{
						$('a_'+stuffid).style.display = 'none';
					}
				}
				var data_value = ld('.home-header-filter-select .header_value').html();
				if(search_date == 'custom'){
					data_value = search_date_custom_value;
				}
				if(!empty(data_value)){
					//ld('#stuff_'+stuffid+' .widget-tab-time').html(data_value);
				}
				var home_scope_username = ld('.home_header_top .home-header-top-date #scope_username').html();
				if(!empty(home_scope_username)){
					//ld('#stuff_'+stuffid+' .widget-tab-post').html(home_scope_username);
				}
				//视图标签的事件绑定
				home_menu_stuff_bind(stuffid);
                loadStuff.param="";
		    }
		}
	);
}
loadStuff.param="";

//视图标签的事件绑定
var home_menu_stuff_bind =function(stuffid){
	//标签切换
	ld('#stuffcont_'+stuffid+' .widget-content .tab span').each(function(){
		ld(this).unbind("click").on('click',function(){
			var menu_type = ld(this).attr('data-type');
			ld('#stuffcont_'+stuffid+' .widget-content .tab span').each(function(){
				ld(this).attr('class','tab-item');
			})
			ld(this).attr('class','tab-item cur');
			ld('#stuffcont_'+stuffid+' .widget-content .deal-list .deal-total').each(function(){
				var tag = ld(this).attr('tag');
				if(tag == menu_type){
					ld(this).show();
				}else{
					ld(this).hide();
				}
			});
			ld('#stuffcont_'+stuffid+' .widget-content .deal-list .deal-item').each(function(){
				var tag = ld(this).attr('tag');
				if(tag == menu_type){
					ld(this).show();
				}else{
					ld(this).hide();
				}
			});
			
		})
		
	})
	ld('#stuff_'+stuffid+' .E_stripe .changeday').each(function(){
		//周月统计切换
		ld(this).unbind("click").on('click',function(){
			var _tag = ld(this).attr('tag');
            
            loadStuff.param="homeweekmonthtype="+_tag;
            loadStuff(36,"saleskit");
            
            
			ld('#stuff_'+stuffid+' .E_stripe .changeday').each(function(){
				if( ld(this).attr('tag') == _tag)
					ld(this).attr('class','changeday changeday-ground onselected_A');
				else{
					ld(this).attr('class','changeday changeday-ground');
				}
			})
			/*if(_tag != undefined){
				ld('#stuffcont_'+stuffid+' .datalist li').each(function(){
					var label_type = ld(this).attr('label-type');
					if(label_type == _tag){
						ld(this).css('display','block');
					}else{
						ld(this).css('display','none');
					}
						
				})
			}*/
		})
		
	});
}

function loadAllWidgets(widgetInfoList){
	for(var index =widgetInfoList.length-1 ; index>=0;--index) {
		var widgetId = widgetInfoList[index].widgetId;
		var widgetType = widgetInfoList[index].widgetType;
        loadStuff(widgetId,widgetType);
	}
}

/**
 * this function validates the form for creating a new widget
 */
function frmValidate(){
	if($('stufftype_id').value=="defaultwidget"){
		var namelist = new Array();
		$('vtbusy_info').style.display="block";
		var elem = document.getElementsByName("names")
        for(var i = 0; i < elem.length; i++){
            if(elem[i].checked) {
				namelist[i] = elem[i].value;
            }
		}

		var values = JSON.stringify(namelist);
		new Ajax.Request(
			'index.php',
			{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: 'action=HomeAjax&module=Home&file=HomeWidgetsSave&values='+encodeURIComponent(values),
			onComplete: function(response) {
				$('addWidgetsDiv').style.display="none";
				$('vtbusy_info').style.display="none";
				window.location.reload();
			}
		}
	);
	}else{
		if(trim($('stufftitle_id').value)==""){
			alert(alert_arr.LBL_ENTER_WINDOW_TITLE);
			$('stufftitle_id').focus();
			return false;
		}
		if($('stufftype_id').value=="RSS"){
			if($('txtRss_id').value==""){
				alert(alert_arr.LBL_ENTER_RSS_URL);
				$('txtRss_id').focus();
				return false;
			}
		}
		/*if($('stufftype_id').value=="URL"){
			if($('url_id').value==""){
				alert("Please enter URL");
				$('url_id').focus();
				return false;
			}
		}*/
		if($('stufftype_id').value=="Module"){
			var selLen;
			var fieldval=new Array();
			var cnt=0;
			selVal=document.Homestuff.PrimeFld;
			for(k=0;k<selVal.options.length;k++){
				if(selVal.options[k].selected){
					fieldval[cnt]=selVal.options[k].value;
					cnt= cnt+1;
				}
			}
			if(cnt>2){
				alert(alert_arr.LBL_SELECT_ONLY_FIELDS);
				selVal.focus();
				return false;
			}else{
				document.Homestuff.fldname.value=fieldval;
			}
		}
		var stufftype=$('stufftype_id').value;
		var stufftitle=$('stufftitle_id').value;
		$('stufftitle_id').value = '';
		var selFiltername='';
		var fldname='';
		var selmodule='';
		var maxentries='';
		var txtRss='';
		var seldashbd='';
		var seldashtype='';
		var seldeftype='';
    	var selreport='';
    	var selreportcharttype='';
		//var txtURL = '';

		if(stufftype=="Module"){
			selFiltername =document.Homestuff.selFiltername[document.Homestuff.selFiltername.selectedIndex].value;
			fldname = fieldval;
			selmodule =$('selmodule_id').value;
			maxentries =$('maxentryid').value;
		}else if(stufftype=="RSS"){
			txtRss=$('txtRss_id').value;
			maxentries =$('maxentryid').value;
		}/*else if(stufftype=="URL"){
			txtURL=$('url_id').value;
		}*/else if(stufftype=="DashBoard"){
			seldashbd=$('seldashbd_id').value;
			seldashtype=$('seldashtype_id').value;
		}else if(stufftype=="Default"){
			seldeftype=document.Homestuff.seldeftype[document.Homestuff.seldeftype.selectedIndex].value;
		}
    else if(stufftype=="ReportCharts"){
    	selreport = $('selreportchart_id').value;
        selreportcharttype = $('selreportcharttype_id').value;
    }

	var url="stufftype="+stufftype+"&stufftitle="+stufftitle+"&selmodule="+selmodule+"&maxentries="+maxentries+"&selFiltername="+selFiltername+"&fldname="+encodeURIComponent(fldname)+"&txtRss="+txtRss+"&seldashbd="+seldashbd+"&seldashtype="+seldashtype+"&seldeftype="+seldeftype+"&selreport="+selreport+"&selreportcharttype="+selreportcharttype;//+'&txtURL='+txtURL;
		var stuffarr=new Array();
		$('vtbusy_info').style.display="inline";

		new Ajax.Request(
			'index.php',
			{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:'module=Home&action=HomeAjax&file=Homestuff&'+url,
				onComplete: function(response){
					var responseVal=response.responseText;
					if(!response.responseText){
						alert(alert_arr.LBL_ADD_HOME_WIDGET);
						$('vtbusy_info').style.display="none";
						$('stufftitle_id').value='';
						$('txtRss_id').value='';
						return false;
					}else{
						hide('addWidgetsDiv');
						$('vtbusy_info').style.display="none";
						$('stufftitle_id').value='';
						$('txtRss_id').value='';
						eval(response.responseText);
					}
				}
			}
		);
	}
}

/**
 * this function is used to hide the default widgets
 * @param string sid - the id of the widget
 */
function HideDefault(sid){
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:'module=Home&action=HomeAjax&file=HomestuffAjax&stuffid='+sid+"&act=hide",
	        onComplete: function(response){
				var responseVal=response.responseText;
				if(response.responseText.indexOf('SUCCESS') > -1){
					var delchild = $('stuff_'+sid);
					odeletedChild = $('MainMatrix').removeChild(delchild);
					$('seqSettings').innerHTML= '<table cellpadding="10" cellspacing="0" border="0" width="100%" class="vtResultPop small"><tr><td align="center">'+alert_arr.LBL_WIDGET_HIDDEN+'.'+alert_arr.LBL_RESTORE_FROM_PREFERENCES+'.</td></tr></table>';
					$('seqSettings').style.display = 'block';
					$('seqSettings').style.display = 'none';
					placeAtCenter($('seqSettings'));
					Effect.Appear('seqSettings');
					setTimeout(hideSeqSettings,5000);
				}else{
					alert(alert_arr.ERR_HIDING + '.'+ alert_arr.MSG_TRY_AGAIN + '.');
				}
	        }
		}
	);
}


/**
 * this function removes the widget dropdown window
 */
function fnRemoveWindow(){
	var tagName = document.getElementById('addWidgetDropDown').style.display= 'none';
}

/**
 * this function displays the widget dropdown window
 */
function fnShowWindow(){
	var tagName = document.getElementById('addWidgetDropDown').style.display= 'block';
}

/**
 * this function is used to postion the widgets on home on page resize
 * @param string targetDiv - the id of the target widget
 * @param string stufftitle - the title of the target widget
 * @param string stufftype - the type of the target widget
 */
function positionDivInAccord(targetDiv,stufftitle,stufftype){
	var layout=$('homeLayout').value;
	var widgetWidth;
	var dashWidth;

	switch(layout){
		case '2':
			widgetWidth = 49;
			dashWidth = 98.6;
			break;
		case '3':
			widgetWidth = 32;
			dashWidth = 64;
			break;
		case '4':
			widgetWidth = 24;
			dashWidth = 48.6;
			break;
		default:
			widgetWidth = 24;
			dashWidth = 48.6;
			break;
	}
	var mainX = parseInt(document.getElementById("MainMatrix").style.width);
	if(stufftitle != vtdashboard_defaultDashbaordWidgetTitle && stufftype != "DashBoard" && stufftype != "ReportCharts"){
		var dx = mainX *  widgetWidth/ 100;
	}else{
	   /*
       *AUTHOR:BY LD KEVIN
       *DATE:20130131
       *DESCRIPTION:淇敼bug3217
       *var dx = mainX * dashWidth / 100;
       */
	   var dx;
	   if(stufftype == "Default")
       dx= mainX * dashWidth / 100 - 1.5;	
        else
        dx = mainX * dashWidth / 100;
        
	}
	if(targetDiv == 'stuff_35' || 'stuff_36' == targetDiv)
		dx = 99.5;
	else
		dx = 99;
	document.getElementById(targetDiv).style.width=dx + "%";
}

/**
 * this function hides the seqSettings div
 */
function hideSeqSettings(){
	Effect.Fade('seqSettings');
}

/**
 * this function fetches the homepage dashboard
 * @param string stuffid - the id of the dashboard widget
 */
function fetch_homeDB(stuffid){
	$('refresh_'+stuffid).innerHTML=$('vtbusy_homeinfo').innerHTML;
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: 'module=Dashboard&action=DashboardAjax&file=HomepageDB',
			onComplete: function(response){
				$('stuffcont_'+stuffid).style.display = 'none';
				$('stuffcont_'+stuffid).innerHTML=response.responseText;
				$('refresh_'+stuffid).innerHTML='';
				Effect.Appear('stuffcont_'+stuffid);
			}
		}
	);
}

/**
 * this function initializes the homepage
 */
initHomePage = function(isadmin){
   
	Sortable.create(
		"MainMatrix",
		{
			constraint:false,tag:'div',overlap:'Horizontal',handle:'headerrow',
			onUpdate:function(){
				matrixarr = Sortable.serialize('MainMatrix').split("&");
				matrixseqarr=new Array();
				seqarr=new Array();
				for(x=0;x<matrixarr.length;x++){
					matrixseqarr[x]=matrixarr[x].split("=")[1];
				}
                    BlockSorting(matrixseqarr);
			}
		}
	);
}

/**
 * this function is used to save the sorting order of elements when they are moved around on the home page
 * @param array matrixseqarr - the array containing the sequence of the widgets
 */
function BlockSorting(matrixseqarr){
	var sequence = matrixseqarr.join("_");
	new Ajax.Request('index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:'module=Home&action=HomeAjax&file=HomestuffAjax&matrixsequence='+sequence,
			onComplete: function(response){
				$('seqSettings').innerHTML=response.responseText;
				$('seqSettings').style.display = 'block';
				$('seqSettings').style.display = 'none';
				placeAtCenter($('seqSettings'));
				Effect.Appear('seqSettings');
				setTimeout(hideSeqSettings,3000);
			}
		}
	);
}


/**
 * this function checks if the current browser is IE or not
 */
function isIE(){
	return navigator.userAgent.indexOf("MSIE") !=-1;
}



/**
 * this function adds a notebook widget to the homepage
 */
function addNotebookWidget(){
	new Ajax.Request('index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:'module=Home&action=HomeAjax&file=HomestuffAjax&matrixsequence='+sequence,
			onComplete: function(response){
				$('seqSettings').innerHTML=response.responseText;
				$('seqSettings').style.display = 'block';
				$('seqSettings').style.display = 'none';
				placeAtCenter($('seqSettings'));
				Effect.Appear('seqSettings');
				setTimeout(hideSeqSettings,3000);
			}
		}
	);
	loadAddedDiv(stuffid,stufftype);
}


/**
 * this function takes a widget id and adds scrolling property to it
 */
function addScrollBar(id){
	$('stuff_'+id).style['overflowX'] = "scroll";
	$('stuff_'+id).style['overflowY'] = "scroll";
}

/**
 * this function will display the node passed to it in the center of the screen
 */
function showOptions(obj,id){
	//document.getElementById(id).style.display='block';
    //lingdangJS_DialogBox.block();
     //Drag.init(document.getElementById("changeLayoutDivId"), document.getElementById("changeLayoutDiv"));
    //placeAtCenter(id);
    fnvshobj(obj,id);
    //setLayoutDiv(obj,id);
}

function setLayoutDiv(obj,Lay)
{
    /*var centerPixel = getViewPortCenter();
	document.getElementById(id).style.position = "absolute";
	var point = getDimension(id);


	var topvalue = (centerPixel.y - point.y/2) ;
	var rightvalue = (centerPixel.x - point.x/2);

	//to ensure that values will not be negative
	if(topvalue<0) topvalue = 0;
	if(rightvalue < 0) rightvalue = 0;
    document.getElementById(id).style.top = topvalue - 100 + "px";
	document.getElementById(id).style.right =rightvalue + 150 + "px";
	document.getElementById(id).style.left = '';
	document.getElementById(id).style.bottom = '';*/
    var tagName = document.getElementById(Lay);
	var leftSide = findPosX(obj);
	var topSide = findPosY(obj);
	var maxW = tagName.style.width;
	var widthM = maxW.substring(0,maxW.length-2);
	var IE = document.all?true:false;
	if(IE)
	{
		if($("repposition1"))
		{
			if(topSide > 1200)
			{
				topSide = topSide-250;
			}
		}
	}

	var getVal = eval(leftSide) + eval(widthM);
	if(getVal  > document.body.clientWidth ){
		leftSide = eval(leftSide) - eval(widthM);
		tagName.style.left = leftSide + 34 + 'px';
	}
	else
		tagName.style.left= leftSide + 'px';
    	tagName.style.top= topSide + 'px';
    	tagName.style.display = 'block';
    	tagName.style.visibility = "visible";
}
/**
 * this function will hide the node passed to it
 */
function hideOptions(id){
	//Effect.Fade(id);
    document.getElementById(id).style.display='none';
}

function setScope(obj)
{
  
    if('smowner_search_senior' == obj){//高级
		SmOwnerSearchSeniorHome('Home',obj);return false;
	}
    document.getElementById('hiddenscope').value = obj;
    UnifiedScope.submit();

}

/**
 * 查看范围高级功能
 * @project PROT180 角色权限改进
 * @author Tujt 2015-03-25
 */
function SmOwnerSearchSeniorHome(module,searchview){
	/* editor:gyq_14  date:20160715*/
	getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
		ScopePopup_Details.getInstance().SmOwnerSearchSenior(module,searchview,'home');
	});
	/*if(0 == ld('#searchseniorview').length){
		var divObj = document.createElement("div");
		divObj.setAttribute('id','searchseniorview');
		divObj.style.display = "none";
		document.body.appendChild(divObj);
		divObj.innerHTML = '<input type="hidden" id="senioruserid" name="senioruserid"><input type="hidden" name="senioruserid_name" id="senioruserid_name">';
	}
    //alert(selectuid);
	var obj = {'field':'senioruserid','view':'private','module':module,'type':'searchscope'};
    if(selectuid!= undefined && selectuid != ''){
        obj['value'] = selectuid;
    }
	ViewUserPopup(obj,function(userobj){
		document.getElementById('selectuid').value= userobj.userid.value;
		document.getElementById('hiddenscope').value = searchview;
		UnifiedScope.submit();
	});*/
}

/**
 * this function will be used to save the layout option
 */
function saveLayout(){
	$('status').show();
	hideOptions('changeLayoutDiv');
	var sel = $('layoutSelect');
	var layout = sel.options[sel.selectedIndex].value;
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:'module=Home&action=HomeAjax&file=HomestuffAjax&layout='+layout,
			onComplete: function(response){
				var responseVal=response.responseText;
				window.location.href = window.location.href;
			}
		}
	);
}
function saveEditReportCharts(dashRowId){
	$('refresh_'+dashRowId).innerHTML=$('vtbusy_homeinfo').innerHTML;
	cancelEntries('editRowmodrss_'+dashRowId);
	var reportVal='';
	var iter=0;
	for(iter=0;iter<3;iter++){
		if($('reportradio_'+iter).checked){
			reportVal=$('reportradio_'+iter).value;
		}
	}
	stuffid=dashRowId;
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:'module=Home&action=HomeAjax&file=HomestuffAjax&reportVal='+reportVal+'&stuffid='+stuffid,
			onComplete: function(response){
				var responseVal=response.responseText;
				eval(response.responseText);
				$('refresh_'+stuffid).innerHTML='';
			}
		}
	);
}
function PotentialsSalesState_list(module,url)
{
     var bgDiv = document.getElementById("bgDiv");
    if (bgDiv != null)
        bgDiv.parentNode.removeChild(bgDiv);
    var msgDiv = document.getElementById("msgDiv");
    if (msgDiv != null)
        msgDiv.parentNode.removeChild(msgDiv);
        
    var selObj = document.getElementById('SmOwnerSearchScope');
    var currOption = selObj.options[selObj.selectedIndex];
    var SearchScope=currOption.value;
  

    var cur_this=this;
   showPotentialsStageList.callback_fun=function()
    {
       
      
      //  if(start==1){
        
             //  fnvshobj(cur_this,'showPotentials');    
        //}
    };
    
     url='module=Home&action=HomeAjax&file=showPotentials&SearchScope='+SearchScope+'&ajax=true&selectuid='+selectuid+"&"+url;
    
    var listview_page=new ListView_Page("Home",url,"showPotentials");
    listview_page.callback_fun=showPotentialsStageList.callback_fun;
    listview_page.page();
}
//销售漏斗显示阶段数据
function showPotentialsStageList(sales_stage){
   
    var bgDiv = document.getElementById("bgDiv");
    if (bgDiv != null)
        bgDiv.parentNode.removeChild(bgDiv);
    var msgDiv = document.getElementById("msgDiv");
    if (msgDiv != null)
        msgDiv.parentNode.removeChild(msgDiv);
    selectuid = ld('#selectuserid').val();
	var search_date = ld('.home-header-filter-select .header_value').attr('data-value');
	var search_date_custom_value = ld('#search_date_custom').val();	//自定义查询时间
	var start = arguments[1]?arguments[1]:1;
    var cur_this=this;
    showPotentialsStageList.callback_fun=function()
    {
       
     
        if(start==1){
        
               
           //     fnvshobj(cur_this,'showPotentials');    
        }
    };
    var url='module=Home&action=HomeAjax&file=showPotentials&start='+start+'&sales_stage='+sales_stage+'&SearchScope=smowner_search_senior&ajax=true&selectuid='+selectuid+'&search_date='+search_date+'&date_custom='+search_date_custom_value;
    
    var listview_page=new ListView_Page("Home",url,"showPotentials");
    listview_page.callback_fun=showPotentialsStageList.callback_fun;
    listview_page.type="showPotentials";
    listview_page.jsonpage();
  
}

//分页跳转
function getPotentialsListViewEntries_js(sales_stage,start)
{
    showPotentialsStageList(sales_stage,start);
}

//销售漏斗列表删除功能
function DeskTopPotentialsdelete(DeleteID,Module){
    if(window.confirm(arrJsPopLabel['SUREWANTDELETE'])){
            var start=document.getElementById('START').value;
            var sales_stage=document.getElementById('sales_stage').value;

                new Ajax.Request(
        		'index.php',
        		{queue: {position: 'end', scope: 'command'},
        			method: 'post',
        			postBody:'module=Home&action=HomeAjax&file=showPotentials&type=deleted&DeleteID='+DeleteID+'&ajax=true',
        			onComplete: function(response){
   			              //fninvshnew('showPotentials');   
                        showPotentialsStageList(sales_stage,start);
                        loadStuff(19,'Default');
                    }
        		}
        	);
    }
}
var Header_Top_Load = function(){
	//隐藏查询下拉选项
	ld('#home_index').on('click',function(e){
		var _display = ld('.home-header-filter-select .select-box').css('display');
		if(_display != 'none'){
			ld('.home-header-filter-select .select-box').hide();	
		}
		
	})
	//首页：时间
	ld('.home-header-filter-select .header_value').on('click',function(e){
		e.stopPropagation();
		var data_value =  ld(this).attr('data-value');
		var _display = ld('.home-header-filter-select .select-box').css('display');
		if(_display == 'none'){
			ld('.home-header-filter-select .select-box').show();
		}else{
			ld('.home-header-filter-select .select-box').hide();
		}
		ld('.home-header-filter-select .select-box .select-list li').each(function(){
			if(ld(this).attr('data-value') == data_value){
				ld(this).addClass("selected");
			}else{
				ld(this).removeClass();
			}
		})
		if(data_value != 'custom'){
			ld('.home-header-filter-select .select-box .select-list li[tag=custom_set]').hide();
			ld('#search_date_custom').val();
		}
		ld('.home-header-filter-select .select-box .select-list li').on('click',function(){
			var select_data_value =  ld(this).attr('data-value');
			var select_li_value = trim(ld(this).html());
			if(select_data_value == 'custom_start' || select_data_value == 'custom_end')return;
			ld('.home-header-filter-select .select-box .select-list li').each(function(){
				ld(this).removeClass();
			})
			//自定义时间
			if(select_data_value == 'custom' || 'custom_btn' == select_data_value){
				if(select_data_value == 'custom'){	//选择自定义时间
					ld('.home-header-filter-select .select-box .select-list li[tag=custom_set]').show();
					ld('.home-header-filter-select .select-box .select-list li[data-value=custom]').addClass("selected");
					return false;
				}else{	//确认
					var begin_date = ld('.home-header-filter-select .select-box .select-list input[id=begin_date]').val();
					var end_date = ld('.home-header-filter-select .select-box .select-list input[id=end_date]').val();
					var custom_label = ld('.home-header-filter-select .select-box .select-list li[data-value=custom]').html();
					if(empty(end_date) || empty(begin_date)){
						alert(custom_label+arrJsPopLabel['CANOTEMPTY']);
						return false;
					}
					var date = begin_date +'~'+end_date;
					select_li_value = custom_label;
					select_data_value = 'custom';
					ld('#search_date_custom').val(date);
				}
			}else{
				ld('.home-header-filter-select .select-box .select-list li[tag=custom_set]').hide();
				ld('#search_date_custom').val();
			}
			ld('.home-header-filter-select .header_value').html(select_li_value);
			ld('.home-header-filter-select .header_value').attr('data-value',select_data_value);
			ld('.home-header-filter-select .select-box').hide();
			initWidgets();
		})
	})
	//首页：审批状态
	ld('.home-header-approve-select .approve_header_value').on('click',function(e){
		e.stopPropagation();
		var approve_value =  ld(this).attr('approve-value');
		var _display = ld('.home-header-approve-select .select-box').css('display');
		if(_display == 'none'){
			ld('.home-header-approve-select .select-box').show();
		}else{
			ld('.home-header-approve-select .select-box').hide();
		}
		ld('.home-header-approve-select .select-box .select-list li').each(function(){
			if(ld(this).attr('approve-value') == approve_value){
				ld(this).addClass("selected");
			}else{
				ld(this).removeClass();
			}
		})
		ld('.home-header-approve-select .select-box .select-list li').on('click',function(){
			var select_approve_value =  ld(this).attr('approve-value');
			var select_li_value = trim(ld(this).html());
			ld('.home-header-approve-select .select-box .select-list li').each(function(){
				ld(this).removeClass();
			})
			ld('.home-header-approve-select .approve_header_value').html(select_li_value);
			ld('.home-header-approve-select .approve_header_value').attr('approve-value',select_approve_value);
			ld('.home-header-approve-select .select-box').hide();
			initWidgets();
		})
	});
	//首页：查看范围
	ld('.home_header_top .home-header-top-scope').on('click',function(){
		var scopepopupobj;
		var selectuserid = '';
		if(ld('#selectuserid') != undefined){
			selectuserid = ld('#selectuserid').val();
		}
		var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_module=Home&popup_inputtype=checkbox&popup_selecttype=user&popup_scopetype=private';
		getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
			var methodObj = {'popup_check_inactiveuser':'yes'};
			scopepopupobj =  new ScopePopupObj(methodObj);
			scopepopupobj.popup_caption_value = arrJsPopLabel['VIEWRANGESENIOR'];//标题title
			getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
			   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
			   cls_ScopePopup.prop.popup_module = 'Home';//模块
			   cls_ScopePopup.prop.popup_value = selectuserid;
			   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
						//没有选择任何用户，则给出提示
						if(empty(cls_ScopePopup.return_obj.return_id)){
							var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
							RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
							return false;
						}else{
							var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
							var user_arr = selected_user.split(',');
							//alert("module=Home&action=HomeAjax&file=HomestuffSetting&getHomeStuffUserName=yes&selected_user="+selected_user);
							if(ld('#selectuserid') != undefined){
								new Ajax.Request(
									'index.php',
									{queue: {position: 'end', scope: 'command'},
											method: 'post',
											postBody:"module=Home&action=HomeAjax&file=HomestuffSetting&getHomeStuffUserName=yes&selected_user="+selected_user,
											onComplete: function(response) {
												var responseVal=trim(response.responseText);
												var restobj = eval('('+ responseVal +')')?eval('('+ responseVal +')'):JSON.parse(responseVal);
												ld('.home_header_top .home-header-top-date #scope_username').html(restobj['username']+restobj['usernum']);
												//ld('.home_header_top .home-header-top-date #scope_usernum').html();
												ld('#selectuserid').val(selected_user);
												ld('.D_pbtn .D_pbtncancel').click();
												initWidgets();
											}
									}
								);
							}
						}
					});
				}
			});
		});
	})
	//首页 设置
	ld('.home_header_top .home-header-top-setting-span').on('click',function(){
		var selectedStuffStr = '';
		var surl = 'module=Home&action=HomeAjax&file=HomestuffSetting';
		new Ajax.Request(
			'index.php',
			{queue: {position: 'end', scope: 'command'},
				method: 'post',
				//asynchronous:false,
				postBody:surl,
				onComplete: function(response){
					var responseVal=response.responseText;
					var divobj = createElementDivs('homestuffsetting');//创建DIV
					ld(divobj).find('.D_pop_tit .D_ptita').html(arrJsPopLabel['homepagedisplaysettings']);
					ld(divobj).find('.pop_remind_content').html(responseVal);
					fnvshobj(this,'homestuffsetting');
					//确认事件
					ld('#homestuffsetting .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
						if(document.getElementById('selectedColumns2')!=undefined){
							selectedColumnsObj=document.getElementById('selectedColumns2');
							for (i=0;i<selectedColumnsObj.options.length;i++){
								selectedStuffStr += selectedColumnsObj.options[i].value + ";";
							}
						}
						if(selectedStuffStr != ''){
							new Ajax.Request(
								'index.php',
								{queue: {position: 'end', scope: 'command'},
										method: 'post',
										postBody:"module=Home&action=HomeAjax&file=HomestuffSetting&stype=save&selectedStuffStr="+selectedStuffStr,
										onComplete: function(response) {
											window.location.href = 'index.php?module=Home&action=index';
											
										}
								}
							);
						}else{
							//请至少选择一个组件！
						   alert(arrJsPopLabel['pleaseselectatleast']);
						   return false;
						}
						
					});
				}
			}
		);
	})
}

//首页：销售简报
var setSalesTragetUrl = function(module){
	var search_date = ld('.home-header-filter-select .header_value').attr('data-value');
	var search_date_custom_value = ld('#search_date_custom').val();	//自定义查询时间
	var selectuserid = ld('#selectuserid').val();	//查看范围
	var approve_value = ld('.home-header-approve-select .approve_header_value').attr('approve-value');
	ld.ajax("index.php?module=Home&action=HomeAjax&file=setModuleSearchForHome&search_date="+encodeURIComponent(search_date)+"&search_date_custom_value="+encodeURIComponent(search_date_custom_value)+"&searchmodule="+module+"&selectuserid="+selectuserid+'&approve_value='+approve_value)
	.done(function(){
		if(module == 'Potentials_lastsales_stage')module = 'Potentials';
		url = 'index.php?module='+module+'&action=ListView&query_session=1';
		// window.location.href=url;
		window.open(url);
		//redirect(url);
	})
}

//首页：周月统计
var setSalesKitTragetUrl = function(labeltype,thistype){
	var weeklabel = '';
	ld("a[weekname=weeklabel]").each(function(){
		if(ld(this).attr('class') == 'changeday changeday-ground onselected_A'){
			weeklabel = ld(this).attr('tag');
		}
		  
	});
	if(!empty(labeltype) && !empty(weeklabel)){
		var selectuserid = ld('#selectuserid').val();
		//alert(labeltype);
		//alert("index.php?module=Home&action=HomeAjax&file=setModuleSearchForHome&weeklabel="+encodeURIComponent(weeklabel)+"&selectuserid="+selectuserid+"&labeltype="+labeltype+"&thistype="+thistype);
		ld.ajax("index.php?module=Home&action=HomeAjax&file=setModuleSearchForHome&weeklabel="+encodeURIComponent(weeklabel)+"&selectuserid="+selectuserid+"&labeltype="+labeltype+"&thistype="+thistype)
		.done(function(){
			//alert(labeltype);
			if(labeltype == 'account_num'){
				url = 'index.php?module=Accounts&action=ListView&query_session=1';
				window.open(url); 
			}else if(labeltype == 'contactrecord_num'){
				url = 'index.php?module=ContactRecords&action=ListView&query_session=1';
				window.open(url); 
			}else if(labeltype == 'signdate_num' || labeltype == 'sign_amount'){
				url = 'index.php?module=SalesOrder&action=ListView&query_session=1';
				window.open(url); 
				url = 'index.php?module=ServiceContracts&action=ListView&query_session=1';
				window.open(url); 
			}else if(labeltype == 'cashbill_amount'){
				url = 'index.php?module=CashBill&action=ListView&query_session=1';
				window.open(url); 
			}
		})
	}
}
