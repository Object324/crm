//zxm 20221114 动态获取当前网页的模块名称
var pageto_module = getSearchString('pageto_module',location.href);
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
            scopepopupobj.setInactiveNoShow=function(obj)
            {
                ld('#viewuser_disableuser').prop('checked',true);
            }
			scopepopupobj.popup_caption_value = popup_caption_value;//标题title
			getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
			   cls_ScopePopup.prop.popup_module = module;//模块
			   cls_ScopePopup.prop.popup_value = '';
                module = pageto_module;
			   cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user'
			   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('.E_pbtn .E_pbtnok').unbind('click').on('click',function(){
						if(empty(cls_ScopePopup.return_obj.return_id)){
                            var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
							return false;
						}else{
							ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
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
			scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP']+'\'></div>';
			getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
			   cls_ScopePopup.prop.popup_module = module;//模块
			   cls_ScopePopup.prop.popup_value = '';
                module = pageto_module;
			   cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewgroupinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=group';
			   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('.E_pbtn .E_pbtnok').unbind('click').on('click',function(){
						if(empty(cls_ScopePopup.return_obj.return_id)){
                            var confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
							return false;
						}else{
							ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
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
    document.getElementById('startmonth').value=day1+' '+'-'+' '+day2;
    setReportTime(document.getElementById('startmonth').value);
    ld('#startmonth').daterangepicker(null, function(start, end, label) {

      });
    //zxm 2021-1223    0049368: （https://81mis.com/kfbcrm [^]）库存台账，点击日期查询条件中的“本年”、“全部”等查询时，没有显示选中效果
    ld(obj).siblings().removeClass('onselected_A');
    ld(obj).addClass('onselected_A');
    if(ld('#daterangepicker_search') != undefined){
        ld('#daterangepicker_search').attr('class','changeday colorLink')
    }
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
	var url='module='+pageto_module+'&action=OftenUseReportListView';
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
    ld('#rptContentLoading').show();
    ldAjaxHtmlNoProgress('index.php?',url,function(response)
    {
        ld('#rptContentLoading').hide();
        var results=response.split("###SUCCESS###");
        document.getElementById('UseReportList').innerHTML=results[1];
        document.getElementById("BasicSearchreput").disabled=false;
    });
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
    var url='module='+pageto_module+'&action=OftenUseReportListView';
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
       
         ld('#rptContentLoading').show();
    ldAjaxNoProgresssync('index.php?',url,function (data) {
        document.getElementById("BasicSearchreput").disabled=false;
        ld('#rptContentLoading').hide();
        var pointobj=data;
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

    })
       
    
}
/*
edit:can
date:20131202
reason:立即查找
*/
//editor:gyq_132 reason:分页,库存报表分页支持高级查找  2019/7/18 14:06
function callOftenUseReportSearch(obj,searchtype,r_type,r_para)
{
	document.getElementById("BasicSearchreput").disabled=true;
	//editor:gyq_135 reason:修改报表文件结构  2019/8/8 21:46 ID1000568
    var index_report_style = ld('#index_report_style').val();
    var userreportname = ld('#hidden_userreportname').val();
    if(index_report_style === 'index_report'){
        var url='module='+pageto_module+'&file=index_report&report_name='+userreportname+'&action='+pageto_module+'Ajax&leftmenuclick=yes';
    }else{
        var url='module='+pageto_module+'&file=newindex&action='+pageto_module+'Ajax&leftmenuclick=yes';
    }
    var useReportid=0;
    //分页跳转有两种，一生成报表的分页跳转，属普通查询；二高级查找的分页跳转，属高级查询
    if(r_para &&ld('#advanced_filter_mark').val()==='yes'){
        callSearch('','&'+r_para);
        return false;
    }else{
        ld('#advanced_filter_mark').val('no');
    }
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
			if(document.forms['basicSearch'].createdtimeinput!= undefined){
                var createdtimeinput = document.forms['basicSearch'].createdtimeinput.value;//双时间录入框改为单时间段录入框
                url += '&createdtimeinput='+createdtimeinput;
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
		//视频租赁收入表 - 签约日期
		 if(document.forms['basicSearch'].duedate_start!=undefined && document.forms['basicSearch'].duedate_start!='undefined' && document.forms['basicSearch'].duedate_end != undefined && document.forms['basicSearch'].duedate_end != 'undefined'){
            var duedate_start=document.forms['basicSearch'].duedate_start.value;
			var duedate_end=document.forms['basicSearch'].duedate_end.value;
			url+='&duedate_start='+duedate_start;
			url+='&duedate_end='+duedate_end;
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
		// zxm 2020-1010 常用报表增加提成报表 按合同 按收款  只统计审批通过的合同订单和服务订单
        if(ld('#onlyshowapprovecontactandservice') != undefined){
            if(ld("#onlyshowapprovecontactandservice").prop("checked") == true){
                url+='&onlyshowapprovecontactandservice=yes';
            }else{
                url+='&onlyshowapprovecontactandservice=no';
            }
        }
        // zxm 2020-1010 常用报表增加提成报表 按合同 按收款 只统计审批通过的费用和佣金单
        if(ld('#onlyshowapprovefeeandcommissions') != undefined){
            if(ld("#onlyshowapprovefeeandcommissions").prop("checked") == true){
                url+='&onlyshowapprovefeeandcommissions=yes';
            }else{
                url+='&onlyshowapprovefeeandcommissions=no';
            }
        }
        // zxm 2020-1125 常用报表 服务收费奖金
        if(ld('#onlyshowapproveservicecontract') != undefined){
            if(ld("#onlyshowapproveservicecontract").prop("checked") == true){
                url+='&onlyshowapproveservicecontract=yes';
            }else{
                url+='&onlyshowapproveservicecontract=no';
            }
        }
        //zxm 2021-0220 产品销售排行榜 --产品名称  排行维度
        if(ld('#product_ranking_type') != undefined){
            url+='&product_ranking_type='+ld('#product_ranking_type').val();
        }
        if(ld('#product_name') != undefined){
            url+='&product_name='+ld('#product_name').val();
        }
        if(ld('#onlyshowapprovecashbill') != undefined){
            if(ld("#onlyshowapprovecashbill").prop("checked") == true){
                url+='&onlyshowapprovecashbill=yes';
            }else{
                url+='&onlyshowapprovecashbill=no';
            }
        }
        if(ld('#onlyshowapproveservicebill') != undefined){
            if(ld("#onlyshowapproveservicebill").prop("checked") == true){
                url+='&onlyshowapproveservicebill=yes';
            }else{
                url+='&onlyshowapproveservicebill=no';
            }
        }
        // zxm 2020-1010 常用报表增加提成报表 按合同 按收款 成本计算方法
        if(ld('#cost_accounting') != undefined){
            url+='&cost_accounting='+ld('#cost_accounting').val();
        }
        //zxm 2021-0716 东方报警  销售提成报表 按合同  订单分类的下拉框
        if(ld('#OrderClassification') != undefined){
            url+='&OrderClassification='+ld('#OrderClassification').val();
        }
        // zxm 2020-1010 常用报表增加提成报表 按合同 按收款 业绩计算方法
        if(ld('#achievement_type') != undefined){
            url+='&achievement_type='+ld('#achievement_type').val();
        }
        //zxm 2021-0112 微迪迦
        if(ld('#receivable_balance_morethan') != undefined){
            if(ld("#receivable_balance_morethan").prop("checked") == true){
                url+='&receivable_balance_morethan=yes';
            }else{
                url+='&receivable_balance_morethan=no';
            }
        }
        //VideoRentalOnlyApproved
        if(ld('#VideoRentalOnlyApproved') != undefined){
            if(ld("#VideoRentalOnlyApproved").prop("checked") == true){
                url+='&VideoRentalOnlyApproved=yes';
            }else{
                url+='&VideoRentalOnlyApproved=no';
            }
        }
        // zxm 2021-0118  //增加销售阶段的筛选 【销售预测分析表，机会编号增加超链接，可根据销售阶段查询】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001000170
        // if(ld('#potential_salesstage') != undefined){
        //     url+='&potential_salesstage='+ld('#potential_salesstage').val();
        // }
        //zxm 2021-1103 销售机会预测表  预计成交时间 预计收款时间
        if(ld('#receivablesforecastdateinput')!= undefined){
            url+='&receivablesforecastdateinput='+ld('#receivablesforecastdateinput').val();
        }
        if(ld('#closingdateinput')!= undefined){
            url+='&closingdateinput='+ld('#closingdateinput').val();
        }
        if(ld('#searchAcc input[name="potential_salesstage"]')!= undefined){
            var stagesStr = '';
            ld('#searchAcc input[name="potential_salesstage"]').each(function(){
                if(ld(this).prop('checked')){
                    stagesStr += "'"+ld(this).val() +"',";
                }
            });
            url+='&potential_salesstage='+stagesStr;
        }
		//editor:gyq_140 reason:即时库存查询优化，增加条件:显示库存数量为0的记录  2019/8/28 16:49 
        if(ld('input[name="show_zero_quantity"]') != undefined){
            if(ld('input[name="show_zero_quantity"]').prop("checked") == true){
                url+='&show_zero_quantity=yes';
            }else{
                url+='&show_zero_quantity=no';
            }
        }
        //zxm 服务看板 审批条件
        if(ld('input[name="approve_header_select_value[]"]') != undefined){
            var approve_header_select_value = '';
            ld('input[name="approve_header_select_value[]"]').each(function(){
                if(ld(this).prop("checked") == true){
                    approve_header_select_value += ld(this).val()+',';
                }
            });
            url+='&approve_header_select_value='+approve_header_select_value;
        }
        //zxm 服务看板 服务方式
        if(ld('#basicotherfindsservicetype')!= undefined&&ld('#basicotherfindsservicetype').length>0){
            url+='&basicotherfindsservicetype='+ld('#basicotherfindsservicetype').val();
        }
        //zxm 2022-0328 合同跟踪表 合同类型
        //zkt 20220607 52553系统新升级到V8.4.6.5后，合同跟踪表模块点“生成报表”后，报表数据查询不出来，刷新页面默认情况下有数据，一旦点“生成报表”就出不来。见附件截图。
        if(ld('#salesorder_contracttype_select')!= undefined&&ld('#salesorder_contracttype_select').length>0){
            url+='&salesorder_contracttype_select='+ld('#salesorder_contracttype_select').val();
        }
        if(ld('#servicecontract_contracttype_select')!= undefined&&ld('#servicecontract_contracttype_select').length>0){
            url+='&servicecontract_contracttype_select='+ld('#servicecontract_contracttype_select').val();
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
		url+='&usereport_search=yes';
        if(usereportorderobj!=null)
        {
           url+='&sorder='+usereportorderobj.fieldname+"&ordertype="+usereportorderobj.ordertype;
        }
         ld('#rptContentLoading').show();
        if(obj != null &&  obj.id=="recalculated_distance"){
            //签到报表距离重新计算
			url+="&recalculated_distance=yes";
		}
		//editor:gyq_86 reason:库存报表,分页 2018/12/10 17:48
        if(r_type==='page'){
            url+='&'+r_para;
        }
    }
	//视频租赁收入表  - 同步凭证
	if('VideoRentalIncomeStatement' == userreportname && obj != null && obj.id == 'BasicSearchreput' && obj.getAttribute('tag') == 'voucher'){
		if(!empty(url))
		{
			var new_url = url+ '&getVoucherNum=yes';
            ldAjaxHtmlNoProgress('index.php?',new_url,function(response)
            {
                ld('#rptContentLoading').hide();
                if(response >= 1){
                    RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['Confirmwhetherto']);
                    //点击确认
                    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                        videoReportAjax(new_url,0);
                    });
                }else{
                    RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['NOTFOUNDANYRECORD']);
                    return false;
                }

            })
		}
	}else{
		report_Ajax_Request(url,userreportname);	
	}
    
    //return false;
}

//视频租赁收入表  凭证导入
function videoReportAjax(url,startrow){
	var intervalrow=1;
	var new_url = url + "&startrow="+startrow;
    ldAjaxHtml('index.php?',new_url,function (response) {
        var restobj = eval('(' + response + ')') ? eval('(' + response + ')') : JSON.parse(response);
        var tmppopupobjobj;
        if(startrow==0){
            tmppopupobjobj=ProgressPopup.load(restobj.progresstitle,"","",500,'CustomForm96',"","","","");
            tmppopupobjobj.show();
        }else{
            tmppopupobjobj=CrmPopup.getPopupObj('last');
        }
        var maxrows=parseInt(restobj.maxrows);
        var percent=parseInt(((startrow+intervalrow)/maxrows*100));
        tmppopupobjobj.setPercentWidth(percent);
        tmppopupobjobj.setTotalNum(restobj.selectrows);
        tmppopupobjobj.setCurNum(startrow);

        if(maxrows!=restobj.selectrows){
            tmppopupobjobj.setValidataNum(maxrows);
        }
        if(parseInt(startrow+intervalrow)<parseInt(restobj.maxrows)){
            videoReportAjax(url,startrow+intervalrow);
            return false;
        }else{
            tmppopupobjobj.CancelEvent();
            RemindsMsg("","LdPopWidth400px","","","",'完成！');
        }
    });

}
/**
 * 2022/3/15
 * @param
 * @returns
 * @author chj
 */
function report_Ajax_Request(url,userreportname){
   if(!empty(url))
    {
        ldAjaxHtml('index.php?',url,function(response)
        {
            if(response.indexOf('###SUCCESS###') > -1){
                ld('#rptContentLoading').hide();
                var results=response.split("###SUCCESS###");
                if(userreportname==='Sign_in_track'||userreportname==='SignDistribution'){
                    update_signin_track_map(results[1]);
                    document.getElementById("BasicSearchreput").disabled=false;
                    return false;
                }
                document.getElementById('UseReportList').innerHTML=results[1];
                document.getElementById("BasicSearchreput").disabled=false;

                if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                {
                    //通讯录(pc端企业微信)

                    cls_wxOpenDataobj.bindAllOpenData();
                }
                //editor:gyq_135 reason:同步时，关闭弹出层  2019/8/15 15:04
                if(userreportname==='checkin_monthly'){
                    msgConfirm();
                }

            }else if(response.indexOf('###ERROR###') > -1){
                ld('#rptContentLoading').hide();
                document.getElementById("BasicSearchreput").disabled=false;
                var results=response.split("###ERROR###");
                //创建提示弹出层
                RemindsMsg("","LdPopWidth400px",'',"yes","yes",results[1]);
            }
        });
    }
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
    var url='module='+pageto_module+'&action=OftenUseReportListView&types=selectchange&selectid='+basicotherfinds;
    var objsel=document.getElementById("basicotherfindz");
    objsel.options.length=0;
    ldAjaxHtmlNoProgress('index.php?',url,function(response)
    {
        //$("status").style.display='none';
        ld('#rptContentLoading').hide();
        var results=response.split("###SUCCESS###");
        var s = eval(results[1]);
        for(var i=0;i<s.length;i++){
            objsel.options[i]=new Option(s[i],s[i]);
        }
        //$("UseReportList").innerHTML=results[1];

    })
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
	
	puyoungJS_DialogBox.block();
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
	var tmpurl ='action=OftenUseReportListView&ajax=true&module='+pageto_module+'&ajax=true&UseReport='+usereportid+'&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+"&searchtype=advSearch"+url;
    ldAjaxHtmlNoProgress('index.php?',tmpurl,function(response) {

        var results=response.split("###SUCCESS###");
        document.getElementById('UseReportList').innerHTML=results[1];
        //$("UseReportList").innerHTML=results[1];
        puyoungJS_DialogBox.unblock();
    });
}


/*
更新操作
edit:can
date:20131128
reason:常用报表高级查询保存(V3.1)
*/
function saveReportAdvFilter(reportid) {

	if(!checkAdvancedFilter()) return false;
	
	puyoungJS_DialogBox.block();
	
	var advft_criteria =document.getElementById('advft_criteria').value;// $('advft_criteria').value;
	var advft_criteria_groups =document.getElementById('advft_criteria_groups').value;// $('advft_criteria_groups').value;
    //alert(advft_criteria)
    //return false;
    //alert('action=ListView&ajax=true&module=OftenUseReport&submode=saveCriteria&UseReport='+reportid+'&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+"&searchtype=advSearch")
    var tmpurl = 'action=OftenUseReportListView&ajax=true&module='+pageto_module+'&submode=saveCriteria&UseReport='+reportid+'&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+"&searchtype=advSearch";
    ldAjaxHtmlNoProgress('index.php?',tmpurl,function(response) {
        var results=response.split("###SUCCESS###");
        document.getElementById('UseReportList').innerHTML=results[1];//$("UseReportList").innerHTML=results[1];
        puyoungJS_DialogBox.unblock();
    });
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
    //editor:gyq_135 reason:打印请求路径修改  2019/8/15 18:27
    var index_report_style = ld('#index_report_style').val();
    var userreportname = ld('#hidden_userreportname').val();
     if(index_report_style === 'index_report'){
        var url_header ='index.php?module='+pageto_module+'&action='+pageto_module+'Ajax&file=index_report&report_name='+userreportname;
    }else{
        var url_header ='index.php?module='+pageto_module+'&action='+pageto_module+'Ajax&file=OftenUseReportListView';
    }
    var url= url_header+'&ajax=true&Print=true&UseReport='+usereportid+'&SmOwnerSearchScope='+SmOwnerSearchScope;

    var strs= new Array(); //定义一数组
    //var receiverid=document.forms['basicSearch'].receiverid.value;
    /*editor:gyq_20190314 0036624: 报表-常用报表-即时库存查下点击打印报错（需要补丁）*/
    if(document.forms['basicSearch'].startmonth!=undefined) {
        var thequerytime=document.forms['basicSearch'].startmonth.value;//双时间录入框改为单时间段录入框
        strs=thequerytime.split(" - "); //字符分割
        var startmonth=trim(strs[0]);
        var endmonth=trim(strs[1]);
    }

    url+='&startmonth='+startmonth+'&endmonth='+endmonth;
    if(document.forms['basicSearch'].createdtimeinput!= undefined){
        var createdtimeinput = document.forms['basicSearch'].createdtimeinput.value;//双时间录入框改为单时间段录入框
        url += '&createdtimeinput='+createdtimeinput;
    }
    //ls 2022-01-10 0049593: （https://81mis.com/kfbcrm/index.php [^]）产品销售排行榜，操作高级查找后，导出excel显示空白(打印也没有传参排行纬度起止时间必要条件)
    //zxm 2021-0220 产品销售排行榜 --产品名称  排行维度
    if(ld('#product_ranking_type') != undefined){
        url+='&product_ranking_type='+ld('#product_ranking_type').val();
    }
    if(ld('#product_name') != undefined){
        url+='&product_name='+ld('#product_name').val();
    }
   //alert(searchtype);
    if(searchtype=="advSearch")
    {
   	    var advft_criteria =document.getElementById('advft_criteria').value;// $('advft_criteria').value;
        var advft_criteria_groups =document.getElementById('advft_criteria_groups').value;// $('advft_criteria_groups').value;
        url+='&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+"&searchtype=advSearch";
    }
    else if(searchtype=="BasicSearch")
    {
       // var startmonth=document.forms['basicSearch'].startmonth.value;
       // var endmonth=document.forms['basicSearch'].endmonth.value;
        if(document.forms['basicSearch'].datefindcolumn!=undefined) {
            var datefindcolumn=document.forms['basicSearch'].datefindcolumn.value;
        }
        if(document.forms['basicSearch'].otherfindcolumn!=undefined) {
            var otherfindcolumn=document.forms['basicSearch'].otherfindcolumn.value;
        }
        //useReportid=document.forms['BasicSearch'].UseReport.value;
        url+='&datefindcolumn='+datefindcolumn;
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
        //zxm 2021-0112 微迪迦
        if(ld('#receivable_balance_morethan') != undefined){
            if(ld("#receivable_balance_morethan").prop("checked") == true){
                url+='&receivable_balance_morethan=yes';
            }else{
                url+='&receivable_balance_morethan=no';
            }
        }
        //VideoRentalOnlyApproved
        if(ld('#VideoRentalOnlyApproved') != undefined){
            if(ld("#VideoRentalOnlyApproved").prop("checked") == true){
                url+='&VideoRentalOnlyApproved=yes';
            }else{
                url+='&VideoRentalOnlyApproved=no';
            }
        }
        // zxm 2022-0713 常用报表增加提成报表 按合同 按收款  只统计审批通过的合同订单和服务订单
        if(ld('#onlyshowapprovecontactandservice') != undefined){
            if(ld("#onlyshowapprovecontactandservice").prop("checked") == true){
                url+='&onlyshowapprovecontactandservice=yes';
            }else{
                url+='&onlyshowapprovecontactandservice=no';
            }
        }
        // zxm 2022-0713 常用报表增加提成报表 按合同 按收款 只统计审批通过的费用和佣金单
        if(ld('#onlyshowapprovefeeandcommissions') != undefined){
            if(ld("#onlyshowapprovefeeandcommissions").prop("checked") == true){
                url+='&onlyshowapprovefeeandcommissions=yes';
            }else{
                url+='&onlyshowapprovefeeandcommissions=no';
            }
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
    //zkt 20231010 XUQIU1001341 SQL注入
    url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
    //alert(url);
     window.open(url);
}


function UseReportColumnSet(usereportid,obj,divid)
{
    var urlstring = 'index.php?action='+pageto_module+'Ajax&file=UseReportSetColumn&module='+pageto_module+'&UseReport='+usereportid+"&ReportHeader=DHeader";
    ldAjaxNoProgress(urlstring,{},function(response) {
        DelProgressObjs();
        //var results=response.split("###SUCCESS###");
        //document.getElementById('columnset_form_div').innerHTML=results[1];//$("columnset_form_div").innerHTML=results[1];
        //fnvshobj(obj, divid);

        var Popupobj = CrmPopup.load(response.result.title, SaveColumnSet, "", "LdPopWidth600px", pageto_module, "", arrJsPopLabel['SAVE'], "", arrJsPopLabel['CANCEL']);
        Popupobj.setParams(response.result.title, SaveColumnSet, '', "LdPopWidth600px", pageto_module, "", arrJsPopLabel['SAVE'], "",  arrJsPopLabel['CANCEL']);
        Popupobj.prevshow();
        Popupobj.show(response.result.content);
        // 设置内容最大高度
        Popupobj.setPopBodyMaxHeight(".divPopOverflow");
        //穿梭框新样式
        var tableobj = ld('#'+Popupobj.divid).find("#AssmablyList").parents("table");
        var LeftObj = tableobj.find("#AssmablyList");
        var RightObj = tableobj.find("#selectedAssmablyColumns");
        var Drag_Transfer = new DragTransfer();
        Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','210');
    });
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
	ld('#rptContentLoading').show();
    var selobj=document.getElementById('selectedAssmablyColumns');
    if(selobj.options.length<2)
    {
        //至少设置显示3列！
        RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['SETDISPLAYLEASTTHREE']);
        return false;
    }
    for (var i=0;i<selobj.options.length;i++)
    {
        document.getElementById('selectedAssmablyColumnsString').value+=selobj.options[i].value+",";
    }
    //zkt 20220602 52427常用报表里的销售预测分析表导出Excel数据后，有一部分的表头没有显示，详情见附件。
    //已选字段，display;none的选项添加在显示的选项之后，影响sequence、列名称设置
    if(document.getElementById('UseReportShowColumnDisplayNone')!=undefined)
    {
        document.getElementById('selectedAssmablyColumnsString').value+=document.getElementById('UseReportShowColumnDisplayNone').value;
    }
    var searchtype=document.getElementById('printsearchType').value;//$('printsearchType').value;
    var usereportid=document.forms['basicSearch'].UseReport.value;
  

    var receiverid=document.forms['basicSearch'].receiverid.value;
    //var startmonth=document.forms['basicSearch'].startmonth.value;
    //var endmonth=document.forms['basicSearch'].endmonth.value;
    var thequerytime = '';
    if(document.forms['basicSearch'].startmonth!=undefined){
        thequerytime=document.forms['basicSearch'].startmonth.value;//双时间录入框改为单时间段录入框
    }

    var strs= new Array(); //定义一数组
    strs=thequerytime.split(" - "); //字符分割
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
    puyoungJS_DialogBox.block();
   var selectedAssmablyColumnsString=document.getElementById('selectedAssmablyColumnsString').value;
   
   if(searchtype=='advSearch')
   {
       var advft_criteria =document.getElementById('advft_criteria').value;// $('advft_criteria').value;
        var advft_criteria_groups =document.getElementById('advft_criteria_groups').value;// $('advft_criteria_groups').value;
       ldAjaxHtmlNoProgress('index.php?','action=OftenUseReportListView&ajax=true&module='+pageto_module+'&submode=SaveColumnSet&UseReport='+usereportid+'&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+"&searchtype=advSearch&selectedAssmablyColumnsString="+selectedAssmablyColumnsString+"&pagewidth=100&ReportHeader=DHeader",
       function(response) {
           var results=response.split("###SUCCESS###");
           ld('#rptContentLoading').hide();
           document.getElementById('UseReportList').innerHTML=results[1];;//$("UseReportList").innerHTML=results[1];
           fninvshnew('UseReportSet');
       });
   }
   else
   {
      var url='module='+pageto_module+'&action=OftenUseReportListView';
      url+='&datefindcolumn='+datefindcolumn+'&startmonth='+startmonth+'&endmonth='+endmonth;
        url+='&receiverid='+receiverid+"&UseReport="+useReportid;
        if(document.forms['basicSearch'].basicotherfind!=undefined&&document.forms['basicSearch'].basicotherfind.value!="")
        {
            url+='&otherfindcolumn='+otherfindcolumn+'&basicotherfind='+encodeURIComponent(document.forms['basicSearch'].basicotherfind.value);
        }
        url+='&ajax=true&searchtype=BasicSearch&submode=SaveColumnSet&selectedAssmablyColumnsString='+selectedAssmablyColumnsString+"&pagewidth=100&ReportHeader=DHeader";
       //zxm 微迪迦
       if(document.forms['basicSearch'].createdtimeinput!= undefined){
           var createdtimeinput = document.forms['basicSearch'].createdtimeinput.value;//双时间录入框改为单时间段录入框
           url += '&createdtimeinput='+createdtimeinput;
       }
       //zxm 2021-0112 微迪迦
       if(ld('#receivable_balance_morethan') != undefined){
           if(ld("#receivable_balance_morethan").prop("checked") == true){
               url+='&receivable_balance_morethan=yes';
           }else{
               url+='&receivable_balance_morethan=no';
           }
       }
        //VideoRentalOnlyApproved
       if(ld('#VideoRentalOnlyApproved') != undefined){
           if(ld("#VideoRentalOnlyApproved").prop("checked") == true){
               url+='&VideoRentalOnlyApproved=yes';
           }else{
               url+='&VideoRentalOnlyApproved=no';
           }
       }
       ldAjaxHtmlNoProgress('index.php?',url,function(response){
           ld('#rptContentLoading').hide();//$("status").style.display='none';
           var results=response.split("###SUCCESS###");
           var popupobj = CrmPopup.getPopupObj('last');
           popupobj.CancelEvent();
           document.getElementById('UseReportList').innerHTML=results[1];//$("UseReportList").innerHTML=results[1];
           fninvshnew('UseReportSet');
       });
   }
}

function EditUseReportColumn(usereportid,obj,divid)
{
    var urlstring = 'index.php?action='+pageto_module+'Ajax&file=EditUseReportColumn&module='+pageto_module+'&UseReport='+usereportid;
    ldAjaxNoProgress(urlstring,{},function(response) {
        DelProgressObjs();
        var Popupobj = CrmPopup.load(response.result.title, SaveUseReportColumn, "", "LdPopWidth600px", pageto_module, "", arrJsPopLabel['SAVE'], "", arrJsPopLabel['CANCEL']);
        Popupobj.setParams(response.result.title, SaveUseReportColumn, '', "LdPopWidth600px", pageto_module, "", arrJsPopLabel['SAVE'], "",  arrJsPopLabel['CANCEL']);
        Popupobj.prevshow();
        Popupobj.show(response.result.content);
        // 设置内容最大高度
        Popupobj.setPopBodyMaxHeight(".divPopOverflow");
    });
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
   //editor:gyq_135 reason:修改报表文件结构  2019/8/15 18:12
    var get_progress = 'no';
    var index_report_style = ld('#index_report_style').val();
    var userreportname = ld('#hidden_userreportname').val();
    if(index_report_style === 'index_report'){
        var url_header ='index.php?module='+pageto_module+'&action='+pageto_module+'Ajax&file=index_report&report_name='+userreportname;
    }else{
        var url_header ='index.php?module='+pageto_module+'&action='+pageto_module+'Ajax&file=OftenUseReportListView';
        //edit:duan date:2024/12/11 reason:签到统计表增加分页导出功能
        if(userreportname == 'SIGNINSTATISTICS')get_progress = 'yes';
    }
    var url=url_header+'&ajax=true&Export=true&UseReport='+usereportid;

    var datefindcolumn=document.getElementsByName('datefindcolumn')[0].value;
        var otherfindcolumn=document.getElementsByName('otherfindcolumn')[0].value;
        //var startmonth=document.getElementsByName('startmonth')[0].value;
        //var endmonth=document.getElementsByName('endmonth')[0].value;
        if(document.forms['basicSearch'].startmonth != undefined){
            var thequerytime=document.forms['basicSearch'].startmonth.value;//双时间录入框改为单时间段录入框
            //alert(thequerytime)
            var strs= new Array(); //定义一数组
            strs=thequerytime.split(" - "); //字符分割
            //alert(trim(strs[0]))
            //alert(trim(strs[1]))
            var startmonth=trim(strs[0]);
            var endmonth=trim(strs[1]);
        }
    if(document.forms['basicSearch'].createdtimeinput!= undefined){
        var createdtimeinput = document.forms['basicSearch'].createdtimeinput.value;//双时间录入框改为单时间段录入框
        url += '&createdtimeinput='+createdtimeinput;
    }
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

    //ls 2022-01-10 0049593: （https://81mis.com/kfbcrm/index.php [^]）产品销售排行榜，操作高级查找后，导出excel显示空白(导出没有传参排行纬度起止时间必要条件)
//zxm 2021-0220 产品销售排行榜 --产品名称  排行维度
    if(ld('#product_ranking_type') != undefined){
        url+='&product_ranking_type='+ld('#product_ranking_type').val();
    }
    if(ld('#product_name') != undefined){
        url+='&product_name='+ld('#product_name').val();
    }
    url+='&startmonth='+startmonth+'&endmonth='+endmonth;

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
            //editor:gyq_20190411 reason:变量名错误！！！！！！！！basicotherfind5？？
            var basicotherfind6=document.forms['basicSearch'].basicotherfind6.value;
            url+='&basicotherfind6='+basicotherfind6;
        }
        if(ld('#basicotherfindsapp') != undefined && document.forms['basicSearch'].basicotherfindsapp != undefined){
            var basicotherfindsapp=document.forms['basicSearch'].basicotherfindsapp.checked;
            url+='&basicotherfindsapp='+basicotherfindsapp;
        }
        url+='&datefindcolumn='+datefindcolumn;
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
    //zxm 服务看板 审批条件
    if(ld('input[name="approve_header_select_value[]"]') != undefined){
        var approve_header_select_value = '';
        ld('input[name="approve_header_select_value[]"]').each(function(){
            if(ld(this).prop("checked") == true){
                approve_header_select_value += ld(this).val()+',';
            }
        });
        url+='&approve_header_select_value='+approve_header_select_value;
    }
    //zxm 服务看板 服务方式
    if(ld('#basicotherfindsservicetype')!= undefined&&ld('#basicotherfindsservicetype').length>0){
        url+='&basicotherfindsservicetype='+ld('#basicotherfindsservicetype').val();
    }
    //zxm 2022-0414 合同跟踪表 合同类型
    if(ld('#salesorder_contracttype_select')!= undefined&&ld('#salesorder_contracttype_select').length>0){
        url+='&salesorder_contracttype_select='+ld('#salesorder_contracttype_select').val();
    }
    if(ld('#servicecontract_contracttype_select')!= undefined&&ld('#servicecontract_contracttype_select').length>0){
        url+='&servicecontract_contracttype_select='+ld('#servicecontract_contracttype_select').val();
    }
    //editor:gyq_20191203 reason:0038717: （kfbcrm）即时库存查询报表，点击“导出Excel”点不动（需要补丁）
    //editor:gyq_20191011 reason:即时库存查询优化，增加条件:显示库存数量为0的记录  2019/10/11 10:45
    if(ld('input[name="show_zero_quantity"]') != undefined){
        if(ld('input[name="show_zero_quantity"]').prop("checked") == true){
            url+='&show_zero_quantity=yes';
        }else{
            url+='&show_zero_quantity=no';
        }
    }
    //editor:gyq_20191129 reason:导出需要定位当前选择的产品 0038710: （kfbcrm）常用报表->库存台账：导出Excel表时，应该导出库存台账【全部】数据，目前只导出了第一页的数据（需要补丁）
    if(ld('#productinfo').size() > 0){
        let productinfo_url = decodeURIComponent ( ld('#productinfo').val());
        let productinfo_arr= eval('('+ productinfo_url +')')?eval('('+ productinfo_url +')'):JSON.parse(productinfo_url);
        let product_number = parseInt( ld('#product_number').text())-1;
        url+="&productid_current="+productinfo_arr[product_number]['productid'];
    }
        //alert(url);
   //  location.href="index.php?module=OftenUseReport&action=ExportOftenUseReport&usereportid="+useReportid;
   
    // zxm 2020-1010 常用报表增加提成报表 按合同 按收款 成本计算方法
    if(ld('#cost_accounting') != undefined){
        url+='&cost_accounting='+ld('#cost_accounting').val();
    }
    // zxm 2022-0713 常用报表增加提成报表 按合同 按收款  只统计审批通过的合同订单和服务订单
    if(ld('#onlyshowapprovecontactandservice') != undefined){
        if(ld("#onlyshowapprovecontactandservice").prop("checked") == true){
            url+='&onlyshowapprovecontactandservice=yes';
        }else{
            url+='&onlyshowapprovecontactandservice=no';
        }
    }
    // zxm 2022-0713 常用报表增加提成报表 按合同 按收款 只统计审批通过的费用和佣金单
    if(ld('#onlyshowapprovefeeandcommissions') != undefined){
        if(ld("#onlyshowapprovefeeandcommissions").prop("checked") == true){
            url+='&onlyshowapprovefeeandcommissions=yes';
        }else{
            url+='&onlyshowapprovefeeandcommissions=no';
        }
    }
    //zxm 2021-0716 东方报警  销售提成报表 按合同  订单分类的下拉框
    if(ld('#OrderClassification') != undefined){
        url+='&OrderClassification='+ld('#OrderClassification').val();
    }
    // zxm 2020-1010 常用报表增加提成报表 按合同 按收款 业绩计算方法
    if(ld('#achievement_type') != undefined){
        url+='&achievement_type='+ld('#achievement_type').val();
    }
    //zxm 2021-1103 销售机会预测表  预计成交时间 预计收款时间
    if(ld('#receivablesforecastdateinput')!= undefined){
        url+='&receivablesforecastdateinput='+ld('#receivablesforecastdateinput').val();
    }
    if(ld('#closingdateinput')!= undefined){
        url+='&closingdateinput='+ld('#closingdateinput').val();
    }
    if(ld('#searchAcc input[name="potential_salesstage"]')!= undefined){
        var stagesStr = '';
        ld('#searchAcc input[name="potential_salesstage"]').each(function(){
            if(ld(this).prop('checked')){
                stagesStr += "'"+ld(this).val() +"',";
            }
        });
        url+='&potential_salesstage='+stagesStr;
    }
    // zxm 2021-0118  //增加销售阶段的筛选 【销售预测分析表，机会编号增加超链接，可根据销售阶段查询】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001000170
    //if(ld('#potential_salesstage') != undefined){
        //url+='&potential_salesstage='+ld('#potential_salesstage').val();
    //}
    //zxm 2021-0112 微迪迦
    if(ld('#receivable_balance_morethan') != undefined){
        if(ld("#receivable_balance_morethan").prop("checked") == true){
            url+='&receivable_balance_morethan=yes';
        }else{
            url+='&receivable_balance_morethan=no';
        }
    }
//VideoRentalOnlyApproved
    if(ld('#VideoRentalOnlyApproved') != undefined){
        if(ld("#VideoRentalOnlyApproved").prop("checked") == true){
            url+='&VideoRentalOnlyApproved=yes';
        }else{
            url+='&VideoRentalOnlyApproved=no';
        }
    }
    //视频租赁收入表 - 签约日期
    if(document.forms['basicSearch'].duedate_start!=undefined && document.forms['basicSearch'].duedate_start!='undefined' && document.forms['basicSearch'].duedate_end != undefined && document.forms['basicSearch'].duedate_end != 'undefined'){
        var duedate_start=document.forms['basicSearch'].duedate_start.value;
        var duedate_end=document.forms['basicSearch'].duedate_end.value;
        url+='&duedate_start='+duedate_start;
        url+='&duedate_end='+duedate_end;
    }
    //edit:duan date:2024/12/11 reason:报表增加分页导出功能
    if(get_progress == 'yes'){
        ExproteoftenusereportProgress(url,0,10)
    }else{
        //zkt 20231010 XUQIU1001341 SQL注入
        url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
        location.href=url;
    }
}
function ExproteoftenusereportProgress(url,start,end) {
    var new_url = url
    new_url+='&get_progress=yes';
    new_url+= "&startExportRow="+start+ "&endExportRow="+end;
    var popupobj = CrmPopup.getPopupObj('last');

    getJsScript('include/js/SystemPopup/ExportPopup.js',function() {
        if(popupobj.type == ExportPopup.type){
            var crmPopupobj = popupobj;
        }else{
            var crmPopupobj = ExportPopup.load("", "", "", "LdPopWidth500px", 'OftenUseReport', "", 'none', "", "");
            crmPopupobj.prevshow();
        }

        ldAjaxNoProgress(new_url,{},function(ajaxdata){
            if (ajaxdata.code === 1) {
                crmPopupobj.setParams(ajaxdata.result.title, "", "", "LdPopWidth500px", 'OftenUseReport', "", "", "", "");
                crmPopupobj.show();
                crmPopupobj.update_progress(ajaxdata.result.startExportRow,ajaxdata.result.total_row);
                ExproteoftenusereportProgress(url,ajaxdata.result.startExportRow , ajaxdata.result.endExportRow);
            }else if (ajaxdata.code == 2) {
                crmPopupobj.CancelEvent();
                crmPopupobj.update_progress(ajaxdata.result.total_row,ajaxdata.result.total_row);
                ld('#rptContentLoading').hide();
                location.href = ajaxdata.result.downloadurl;
            }
        });
    });
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
	var startmonth = '';
	var endmonth = '';
    //var startmonth=document.forms['basicSearch'].startmonth.value;
    //var endmonth=document.forms['basicSearch'].endmonth.value;
	if(document.forms['basicSearch'].startmonth != undefined){
		var thequerytime=document.forms['basicSearch'].startmonth.value;//双时间录入框改为单时间段录入框
		//alert(thequerytime)
		var strs= new Array(); //定义一数组
		strs=thequerytime.split(" - "); //字符分割
		//alert(trim(strs[0]))
		//alert(trim(strs[1]))
		startmonth=trim(strs[0]);
		endmonth=trim(strs[1]);
	}

    var datefindcolumn=document.forms['basicSearch'].datefindcolumn.value;
    if(document.forms['basicSearch'].otherfindcolumn!=undefined)
        var otherfindcolumn=document.forms['basicSearch'].otherfindcolumn.value;
    useReportid=document.forms['basicSearch'].UseReport.value;
   
   puyoungJS_DialogBox.block();
   var columnid=document.forms['frmeditcolumn'].columnid.value;
   if(searchtype=='advSearch')
   {
        var advft_criteria = document.getElementById('advft_criteria').value;//$('advft_criteria').value;
       var advft_criteria_groups =document.getElementById('advft_criteria_groups').value;// $('advft_criteria_groups').value;
       var tmpurl = 'action='+pageto_module+'Ajax&file=OftenUseReportListView&ajax=true&module='+pageto_module+'&submode=editColumnName&UseReport='+usereportid+'&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+"&searchtype=advSearch"+txt+'&columnid='+columnid;
       ldAjaxHtml('index.php?',tmpurl,function(response) {
           ld('#rptContentLoading').hide();
           var results=response.split("###SUCCESS###");
           var popupobj =CrmPopup.getPopupObj('last');
           popupobj.CancelEvent();
           document.getElementById('UseReportList').innerHTML=results[1];;//$("UseReportList").innerHTML=results[1];
           fninvshnew('EditUseReportColum');
       });
   }
   else
   {
      var url='module='+pageto_module+'&action='+pageto_module+'Ajax&file=OftenUseReportListView';
      url+='&datefindcolumn='+datefindcolumn+'&startmonth='+startmonth+'&endmonth='+endmonth;
        url+='&receiverid='+receiverid+"&UseReport="+useReportid;
        if(document.forms['basicSearch'].basicotherfind!=undefined&&document.forms['basicSearch'].basicotherfind.value!="")
        {
            url+='&otherfindcolumn='+otherfindcolumn+'&basicotherfind='+encodeURIComponent(document.forms['basicSearch'].basicotherfind.value);
        }
        url+='&ajax=true&searchtype=BasicSearch&submode=editColumnName'+txt+'&editenColumnName'+txtc+'&columnid='+columnid;
       if(document.forms['basicSearch'].createdtimeinput!= undefined){
           var createdtimeinput = document.forms['basicSearch'].createdtimeinput.value;//双时间录入框改为单时间段录入框
           url += '&createdtimeinput='+createdtimeinput;
       }
       //zxm 2021-0112 微迪迦
       if(ld('#receivable_balance_morethan') != undefined){
           if(ld("#receivable_balance_morethan").prop("checked") == true){
               url+='&receivable_balance_morethan=yes';
           }else{
               url+='&receivable_balance_morethan=no';
           }
       }
//VideoRentalOnlyApproved
       if(ld('#VideoRentalOnlyApproved') != undefined){
           if(ld("#VideoRentalOnlyApproved").prop("checked") == true){
               url+='&VideoRentalOnlyApproved=yes';
           }else{
               url+='&VideoRentalOnlyApproved=no';
           }
       }
       ldAjaxHtmlNoProgress('index.php?',url,function(response){
           ld('#rptContentLoading').hide();//$("status").style.display='none';
           var results=response.split("###SUCCESS###");
           var popupobj =CrmPopup.getPopupObj('last');
           popupobj.CancelEvent();
           document.getElementById('UseReportList').innerHTML=results[1];//$("UseReportList").innerHTML=results[1];
           fninvshnew('EditUseReportColum');

       });
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
    ldAjaxHtmlNoProgress('index.php','action='+pageto_module+'Ajax&file=popupreport&module='+pageto_module+'&ReportHeader=DHeader&potentialid='+potentialid, function(response) {
            $("status").style.display="none";
            $("DivPopupReport").style.display ='none';
            $("DivPopupReport").style.zIndex='9999';
            $("DivPopupReport").innerHTML=response;
            fnvshobj(obj,'DivPopupReport');
    });
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
    var url='module='+pageto_module+'&action=OftenUseReportListView';
    url += '&begin_createdate='+begin_createdate;
    url += '&end_createdate='+end_createdate;
    var userid = document.forms['basicSearch'].SmOwnerSearchScope.value;
    url += '&userid='+userid;
    var UseReport = document.forms['basicSearch'].UseReport.value;
    url += '&UseReport='+UseReport;
    url += '&ajax=true';
    ldAjaxHtmlNoProgress('index.php',url,function(response) {
        ld('#rptContentLoading').hide();
        var results=response.split("###SUCCESS###");
        document.getElementById('AjaxTimeSheetTable').innerHTML=results[1];
    });
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
    ld('#rptContentLoading').show();
    //zkt 20231010 XUQIU1001341 SQL注入
    var url = cls_encryptyurl.Puyoung_Encryptyurl("index.php",{module:pageto_module ,file:"RecalculateDistance",signid:signid,'ajax':'true','action':pageto_module+"Ajax"});
    ld.post(url,{module:pageto_module ,file:"RecalculateDistance",signid:signid,'ajax':'true','action':pageto_module+"Ajax"},function(response) {
        ld('#rptContentLoading').hide();
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
//editor:gyq_86 reason:库存台账,向前，向后功能 2018/11/23 11:37
function redirect_record(r_type,r_specialurl) {

    var productinfo_url = decodeURIComponent ( ld('#productinfo').val());
    var productinfo_arr= eval('('+ productinfo_url +')')?eval('('+ productinfo_url +')'):JSON.parse(productinfo_url);
    var product_number = parseInt( ld('#product_number').text())-1;
    var product_number_amount = productinfo_arr.length;
    if(r_type==='qianjin'){
        var product_number_real = product_number+1;
    }else if(r_type==='houtui'){
        var product_number_real = product_number-1;
    }
    var js_url='module='+pageto_module+'&action='+pageto_module+'Ajax&file=OftenUseReportListView';
    if(r_type==='page') {
        var product_number_real = product_number;
        js_url+='&'+r_specialurl;
    }else{
        //超出范围不响应
        /* no-icon-prevpage  icon-nextpage   icon-prevpage  no-icon-nextpage*/
        if(product_number_real+1 >= product_number_amount){
            ld('#qianjin').prop('class',"no-icon-nextpage inventoryReporticon");
        }else{
            ld('#qianjin').prop('class',"icon-nextpage inventoryReporticon");
        }
        if(product_number_real <= 0){
            ld('#houtui').prop('class',"no-icon-prevpage inventoryReporticon");
        }else{
            ld('#houtui').prop('class',"icon-prevpage inventoryReporticon");
        }
        if(product_number_real+1 > product_number_amount ||product_number_real < 0){
            return false;
        }
        ld('#product_number').text(product_number_real+1);
        ld('span[ex_attr="productdetail"]').eq(0).text(productinfo_arr[product_number_real]['productname']);
        ld('span[ex_attr="productdetail"]').eq(1).text(productinfo_arr[product_number_real]['product_no']);
        ld('span[ex_attr="productdetail"]').eq(2).text(productinfo_arr[product_number_real]['usageunit']);
    }

    if (ld('#startmonth') !== undefined) {
        var thequerytime = ld('#startmonth').val();//双时间录入框改为单时间段录入框
        var strs = new Array(); //定义一数组
        strs = thequerytime.split(" - "); //字符分割
        var startmonth = trim(strs[0]);
        var endmonth = trim(strs[1]);
    }
    //js_url+='&basicotherfind5='+ld('#basicotherfind5').val();
    js_url+='&basicotherfind4='+ld('#basicotherfind4').val();
    js_url+='&basicotherfind6='+ld('#basicotherfind6').val();
    /*editor:20181227 0035890: （192.168.0.111:88）库存台账>筛选日期为“2018-01-01到2018-12-31”，仓库为“散采M10-64G”：筛选出来了67条数据，点击切换到第二页后，显示出了有400多条数据。（需要补丁）*/
    js_url+='&basicotherfind5='+ld('#basicotherfind5').val();
    if(ld('#basicotherfind3').length>0){
        js_url+='&basicotherfind3='+ld('#basicotherfind3').val();
    }
    var useReportid=document.forms['basicSearch'].UseReport.value;
    var datefindcolumn=document.forms['basicSearch'].datefindcolumn.value;

    js_url+='&datefindcolumn='+datefindcolumn+'&startmonth='+startmonth+'&endmonth='+endmonth+"&UseReport="+useReportid;
    js_url+="&productid_current="+productinfo_arr[product_number_real]['productid'];
    js_url+="&ajax=true&searchtype=BasicSearch&check_approve_status=no";
    ldAjaxHtmlNoProgress('index.php?',js_url,function(response){
        ld('#rptContentLoading').hide();
        var results=response.split("###SUCCESS###");
        document.getElementById('UseReportEntries').innerHTML=results[1];
        document.getElementById("BasicSearchreput").disabled=false;
    });
    return false;
}
//editor:gyq_86 reason:库存报表,库存台账，跳转到产品明细 2018/12/10 17:48
function redirect_record_detail(productid){
    var productinfo_url = decodeURIComponent ( ld('#productinfo').val());
    var productinfo_arr= eval('('+ productinfo_url +')')?eval('('+ productinfo_url +')'):JSON.parse(productinfo_url);
    var product_number = parseInt( ld('#product_number').text())-1;
    var productid = productinfo_arr[product_number]['productid'];
	DetailViewPage.showpage('Products',productid,"",{'pageto_module':'Products','pageto_action':'DetailView','pageto_record':productid});
   // window.open ("index.php?module=Products&action=DetailView&record="+productid);
}
//editor:gyq_86 reason:库存报表,即时库存查询  待出入库数量 明细  2018/11/30 16:57
function setNationDetailReport(recordid,type,r_request)
{
    r_request = encodeURIComponent(r_request);
    //zxm 20230908 报表分析->即时库存查询，“待入库数量”和“待出库数量”超链接点不动
    var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth900px", pageto_module, "", "none", "", "");
    crmPopupobj.prevshow();
    var surl = 'index.php?module='+pageto_module+'&action='+pageto_module+'Ajax&file=DetailNation&ajax=true&recordid='+recordid+'&type='+type+'&re_string='+r_request+'&get_productdetail=yes';
    ldAjax(surl,'',function(data){
        if (data.code == 1) {
            crmPopupobj.setParams(data.result.title,'',"","LdPopWidth900px",pageto_module,"","","",'',"");
            CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj, data.result.content);
            crmPopupobj.center();
        }
    })

    /*ld.post("index.php",{module : pageto_module ,action:pageto_module+"Ajax",file:"DetailNation",'ajax':'true','recordid':recordid,'type':type,'re_string':r_request,'get_productdetail':'yes'},function(response) {
        var data = ld.parseJSON(response);
        var crmPopupobj = CrmPopup.load(data.result.title, "", "", "LdPopWidth900px", pageto_module, '', '', "", data.result.canceltext);
        crmPopupobj.Okfun.funname='setNationDetailReport_Save';
        crmPopupobj.show(data.result.content);
    });*/
}
//editor:gyq_101 reason:产品单据明细界面,查看产品所在仓库数量分布情况  2019/1/28 16:59
function product_detail_qtyinstock(id,type){
    //zkt 20231010 XUQIU1001341 SQL注入
    //BUG20240304-23 报表分析->即时库存查询，审批状态选择全部，点击库存数量600，弹出层中没有显示仓库明细
    var param = {record : id ,module:"Products",file:"product_detail_qtyinstock",'action':'ProductsAjax','type':type,'approvestatus':ld("#basicotherfind6").val()};
    var url = cls_encryptyurl.Puyoung_Encryptyurl("index.php?",param);
    ld.post(url,param,function(response) {
        var data = ld.parseJSON(response);
        var crmPopupobj = CrmPopup.load(data.result.title, '', "", "LdPopWidth800px", '', '', '', "", '');

        crmPopupobj.show(data.result.content);

        crmPopupobj.center();
    });
}
function oftenusereport_advSearch(reportname)
{
	setListButtonColor("categoryAdvsear");
	$("status").style.display="none";
	var Popupobj=new ListHigherSearchPopup.load("",callSearch,"","LdPopWidth800px",'Accounts',"","","","");
	Popupobj.show();
	//wym 230505 报表高级查找添加搜索功能
    var columnIndex = advft_column_index_count;
    for(i=0;i<=columnIndex;i++){
        var selectname = 'fcol'+i;
        if(ld("#"+Popupobj.divid + ' #'+selectname).length>0){
            var selObj = ld("#"+Popupobj.divid + ' #'+selectname);
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectname);
            cls_resetComboxHtmlobj.setPopupObj(Popupobj);
            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selObj,180);
        }
    }

    if(ld("#"+Popupobj.divid).find('[id=advanced_search_fieldinfo]').length>0){
        var fieldinfoobj = ld("#"+Popupobj.divid).find('[id=advanced_search_fieldinfo]').get(0);
        var fieldinfoobjs=JSON.parse(ld(fieldinfoobj).val());
        Popupobj.fields=fieldinfoobjs;
    }
	ld(this).keydown( function(e) {
		var key = window.event?e.keyCode:e.which;
		if(key.toString() == "13"){
			return false;
		}
	});
	return false;
}

/**
 * 
 * @param
 * @returns
 * @author Tujt 
 */
//editor:gyq_132 reason:高级查找,库存报表分页支持高级查找  2019/7/18 14:07
//searchtype参数此处没用,仅用于站位
function callSearch(searchtype,r_url_para){
	var urlstring = '';
    r_url_para = r_url_para||'';
	if(!checkAdvancedFilter()) return false;
	var advft_criteria = $('advft_criteria').value;
	var advft_criteria_groups = $('advft_criteria_groups').value;
	var usereportid=document.forms['basicSearch'].UseReport.value;
	var url = 'action='+pageto_module+'Ajax&file=newindex&ajax=true&module='+pageto_module+'&ajax=true&UseReport='+usereportid+'&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+"&searchtype=advSearch&usereport_search=yes";
	if(document.forms['basicSearch'].basicotherfind6!=undefined&&document.forms['basicSearch'].basicotherfind6.value!=undefined&&document.forms['basicSearch'].basicotherfind6.value!=""){
		var basicotherfind6=document.forms['basicSearch'].basicotherfind6.value;
		url+='&basicotherfind6='+basicotherfind6;
	}
	if(document.forms['basicSearch'].basicotherfind3!=undefined&&document.forms['basicSearch'].basicotherfind3.value!=undefined&&document.forms['basicSearch'].basicotherfind3.value!=""){
		var basicotherfind3=document.forms['basicSearch'].basicotherfind3.value;
		url+='&basicotherfind3='+basicotherfind3;
	}
	//editor:gyq_140 reason:即时库存查询优化，增加条件:显示库存数量为0的记录  2019/8/28 16:27
    if(ld('input[name="show_zero_quantity"]') != undefined){
        if(ld('input[name="show_zero_quantity"]').prop("checked") == true){
            url+='&show_zero_quantity=yes';
        }else{
            url+='&show_zero_quantity=no';
        }
    }
    //zxm 2021-0220 产品销售排行榜 --产品名称  排行维度
    if(ld('#product_ranking_type') != undefined){
        url+='&product_ranking_type='+ld('#product_ranking_type').val();
    }
    if(ld('#product_name') != undefined){
        url+='&product_name='+ld('#product_name').val();
    }
	url += r_url_para;
    //editor:gyq_122临时 reason:高级查找，获取日期  2019/6/14 17:28
    if (ld('#startmonth') !== undefined) {
        var thequerytime = ld('#startmonth').val();
        if(thequerytime !== undefined && thequerytime.length > 0){
            var strs = new Array(); //定义一数组
            strs = thequerytime.split(" - "); //字符分割
            var startmonth = trim(strs[0]);
            var endmonth = trim(strs[1]);
            url+='&startmonth='+startmonth+'&endmonth='+endmonth;
        }
    }
	hidedv_listhighersearch();
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        if(response.indexOf('###SUCCESS###') > -1){
            var results=response.split("###SUCCESS###");
            document.getElementById('UseReportList').innerHTML=results[1];
            ld('#advanced_filter_mark').val('yes');
            puyoungJS_DialogBox.unblock();
            hidedv_listhighersearch();
            document.getElementById("BasicSearchreput").disabled=false;
        }else if(response.indexOf('###ERROR###') > -1){
            ld('#rptContentLoading').hide();
            document.getElementById("BasicSearchreput").disabled=false;
            var results=response.split("###ERROR###");
            //创建提示弹出层
            RemindsMsg("","LdPopWidth400px",'',"yes","yes",results[1]);
        }

    });
}
//editor:gyq_135 reason:微信打卡同步至月度考勤表  2019/8/9 13:54 ID1000568
function checkin_sync_button() {
    //editor:gyq_139 reason:月度考勤提示增加中英文  2019/8/28 14:09
    RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['CHECKINSETTING_REMIND1']);
    //获取同步的起始时间，截止时间
    var thequerytime = document.forms['basicSearch'].startmonth.value;
    var strs = new Array();
    strs = thequerytime.split(" - "); //字符分割
    var startmonth = trim(strs[0]);
    var endmonth = trim(strs[1]);
    var param = {report_name : 'checkin_monthly' ,module:pageto_module,report_file:"sync",action:pageto_module+'Ajax',file:'index_report',
        ajax:'true',startmonth:startmonth,endmonth:endmonth};
    var tmpurl = cls_encryptyurl.Puyoung_Encryptyurl("index.php?",param);
    ld.post(tmpurl,param,function(response) {
        var data = ld.parseJSON(response);
        msgConfirm();
        if(data.code === 1){
            RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['CHECKINSETTING_REMIND2']);
            callOftenUseReportSearch(null, 'BasicSearch');
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
        }
    });
}
// ls 2021-12-27 【1002356】公费电话直拨支持数据统计报表（蔡云桥-山水）
function dial_record_sync_button() {
    RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['CHECKINSETTING_REMIND1']);
    //获取同步的起始时间，截止时间
    var thequerytime = document.forms['basicSearch'].startmonth.value;
    var strs = new Array();
    strs = thequerytime.split(" - "); //字符分割
    var startmonth = trim(strs[0]);
    var endmonth = trim(strs[1]);
    ld.post("index.php",{report_name : 'dial_record' ,module:pageto_module,report_file:"sync",action:pageto_module+'Ajax',file:'index_report',
        ajax:'true',startmonth:startmonth,endmonth:endmonth},function(response) {
        var data = ld.parseJSON(response);
        msgConfirm();
        if(data.code === 1) {
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['CHECKINSETTING_REMIND2']);
            callOftenUseReportSearch(null, 'BasicSearch');
        }else if(data.code === 2){//未绑定Secret
            CrmPopup.getPopupObj('last').CancelEvent();
            var popupobj=CrmPopup.load(data.result.title,save_dial_record_secret,"",'550','',"",data.result.oktext,"",data.result.canceltext);
            popupobj.show(data.result.content);
            DelProgressObjs();
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
        }
    });
}
function save_dial_record_secret() {
    var popupobj=CrmPopup.getPopupObj("last");
    var secret_obj = CrmPopup.findHtmlobj(popupobj.divid,'secret');
    var secret = secret_obj.val().trim();
    if (empty(secret)){
        var confirm_str = secret_obj.attr("tag") + arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        DelProgressObjs();
        return false;
    }
    ldAjax("index.php",{report_name : 'dial_record' ,module:pageto_module,report_file:"sync",action:pageto_module+'Ajax',file:'index_report',
        ajax:'true',secret:encodeURIComponent(secret)},function(data){
        if (data.code == 1) {
            CrmPopup.getPopupObj("last").CancelEvent();
            dial_record_sync_button();
        }
    })
}

//zxm 2020-0914产品总览 【上海鑫选-产品总览报表开发，已和刘总确认（徐昱轩）】
function setProductOverviewUrl(jqueryobj){
    var selectuserid = ld('#receiverid').val();
    var SmOwnerSearchScope = ld('#SmOwnerSearchScope').val();
    var modules=ld(jqueryobj).attr("module");
    var product_no=ld(jqueryobj).attr("product_no");
    ldAjaxHtmlNoProgress("index.php?module=Home&action=HomeAjax&file=setModuleSearchForHome&searchmodule="+modules,{selectuserid:selectuserid,productOverview:'yes','SmOwnerSearchScope':SmOwnerSearchScope,'product_no':product_no},function(ajaxdata){
        var pageurl=ld(jqueryobj).attr("pageurl");
        var addurl=encodeURIComponent("&query_session=1&start=1");
        var url = pageurl+'&page_addurl='+addurl;
        
        window.open(url);
    });
}
//生成签到轨迹表地图
function create_signin_track_map(){
    getJsScript('include/js/modules/OftenUseReport/SigninTrackMap.js',function(){
        UseTencentMapByexploer();
    });
}
//生成签到分布表地图
function create_signin_distribution_map(){
    getJsScript('include/js/modules/OftenUseReport/SigninTrackMap.js',function(){
        initMap_signin_distribution();
    });
}