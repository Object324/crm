{*+**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ***********************************************************************************+*}
<!--修改编码格式:统一编码：UTF-8-->
<div name="displayfields">
	<table class="DetailContentTable linefeed" width="100%" cellspacing="0" cellpadding="0" border="0">
	<!-- This is added to display the existing comments -->
		<tbody>
		<tr>
			<td colspan="4" class="editrelhead"><b>工单历史记录</b></td>
		</tr>
		</tbody>
	</table>
	<div style="overflow: auto;height: 230px;background-color: #fff;" name="saic_mobile_log">
		{include file="saic/saic_log_content.tpl"}
	</div>
</div>


<script>
	{literal}
		/*
		*edit: chj
		*date: 2020/7/28
		*reason: 赛克，呼叫中心弹屏
		*/
		function get_saic_api(){
			var popupobj=CrmPopup.getPopupObj("last");
			var divid=popupobj.divid;
			var usermobile = CrmPopup.findHtmlobj(divid,"cf_2832").val();	// 下单/接单号码 
			if(empty(usermobile)){
				//RemindsMsg("","LdPopWidth400px","","yes","","下单/接单号码不能为空！");
				//return false;
			}
			var surl = 'index.php?module=Accounts&action=AccountsAjax&file=saic_api&userMobile='+usermobile+'&complaintSource=1';
			var crmPopupobj=CrmPopup.load("","","","1200",'Settings',"","","","");
			crmPopupobj.prevshow();
			ldAjaxNoProgress(surl,"",function(data){
				if(data.code==1){
					crmPopupobj.setParams(data.result.title,"","","1200",'Settings',"","","","","");  
					crmPopupobj.show(data.result.content);
					var popupobj=CrmPopup.getPopupObj("last");
					var divid=popupobj.divid;
					CrmPopup.findHtmlobj(divid,"userMobile").val(usermobile);	// 下单/接单号码 
				}
			})
		}
		/*
		*edit: chj
		*date: 2020/7/28
		*reason: 赛克，呼叫中心弹屏查询时间
		*/
		function saic_search(){
			var popupobj=CrmPopup.getPopupObj("last");
			//手 机 号
			var userMobile = ld("#"+popupobj.divid+" [name=userMobile]").val();
			//乘客 司机
			var complaintSource = ld("#"+popupobj.divid+" [name=complaintSource]:checked").val();
			//MIS订单号
			var orderId = ld("#"+popupobj.divid+" [name=orderId]").val();
			//车 牌 号
			var vehicleNo = ld("#"+popupobj.divid+" [name=vehicleNo]").val();
			//下单 ： 开始时间
			var startTime = ld("#"+popupobj.divid+" [name=startTime]").val();
			//下单 ： 结束时间
			var endTime = ld("#"+popupobj.divid+" [name=endTime]").val();
			//接单 ： 开始时间
			var matchOrderTimeStart = ld("#"+popupobj.divid+" [name=matchOrderTimeStart]").val();
			//接单 ： 结束时间
			var matchOrderTimeEnd = ld("#"+popupobj.divid+" [name=matchOrderTimeEnd]").val();
			//订单来源
			var appId = ld("#"+popupobj.divid+" [name=appId]").val();

			if(!empty(startTime) && !empty(endTime) && startTime > endTime){
				//RemindsMsg("","LdPopWidth400px","","yes","","下单的开启日期不能大于结束日期！");
				//return false;
			}

			if(!empty(matchOrderTimeStart) && !empty(matchOrderTimeEnd) && matchOrderTimeStart > matchOrderTimeEnd){
				//RemindsMsg("","LdPopWidth400px","","yes","","接单的开启日期不能大于结束日期！");
				//return false;
			}
			var surl = "index.php?action=AccountsAjax&file=saic_api&module=Accounts&api=yes";
			if(userMobile != ''){
				surl += '&userMobile='+userMobile;
			}
			surl += '&complaintSource='+complaintSource;
			surl += '&orderId='+orderId;
			surl += '&vehicleNo='+vehicleNo;
			surl += '&startTime='+startTime;
			surl += '&endTime='+endTime;
			surl += '&matchOrderTimeStart='+matchOrderTimeStart;
			surl += '&matchOrderTimeEnd='+matchOrderTimeEnd;
			surl += '&appId='+appId;
			//alert(surl);
			ldAjax(surl,"",function(data){
				if(data.code == 1){
					CrmPopup.findHtmlobj(popupobj.divid,"saic_content").html(data.result.content);	
					//alert(data.result);
				}else{
					RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
					return false;
				}
				DelProgressObjs();
			})

		}
		//获取订单的详情
		function get_saic_orderdetail(orderId,ordernum,channelCode){
			var surl = 'index.php?module=Accounts&action=AccountsAjax&file=saic_api&orderId='+orderId+'&getorderdetail=yes';
			var popupobj=CrmPopup.getPopupObj("last");
			var source_order_type = 'order';	//order 关联订单  driver 关联司机
			if(ordernum >= 1){
				source_order_type = ld("#"+popupobj.divid+" [name=source_order_type_"+ordernum+"]:checked").val();
			}
			ldAjax(surl,"",function(data){
				if(data.code == 1){
					var popupobj=CrmPopup.getPopupObj("lastprev");
					var prev_divid=popupobj.divid;
					//司机UID
					CrmPopup.findHtmlobj(prev_divid,'cf_2848').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_2848').val(data.result.driverId);
					//司机接单手机号
					CrmPopup.findHtmlobj(prev_divid,'cf_2850').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_2850').val(data.result.driverMobile);
					//司机类型
					CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_cf_3088').html('');
					CrmPopup.findHtmlobj(prev_divid,'cf_3088').val('');
					CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_cf_3088').html(data.result.driverType);
					CrmPopup.findHtmlobj(prev_divid,'cf_3088').val(data.result.driverType);
					//司机所属城市
					CrmPopup.findHtmlobj(prev_divid,'cf_3090').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_3090').val(data.result.driverCityName);
					//司机群组
					CrmPopup.findHtmlobj(prev_divid,'cf_3092').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_3092').val(data.result.driverGroup);
					//租赁公司
					CrmPopup.findHtmlobj(prev_divid,'cf_3703').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_3703').val(data.result.leasingCompany);

					//清空
					CrmPopup.findHtmlobj(prev_divid,'cf_2834').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_3112').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_2842').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_2832').val('');
					CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_rating').html('');
					CrmPopup.findHtmlobj(prev_divid,'rating').val('');
					CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_cf_2840').html('');
					CrmPopup.findHtmlobj(prev_divid,'cf_2840').val('');
					CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_cf_3695').html('');
					CrmPopup.findHtmlobj(prev_divid,'cf_3695').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_2856').val('');
					CrmPopup.findHtmlobj(prev_divid,'span_cf_2856').val('');
					CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_accountsize').html('');
					CrmPopup.findHtmlobj(prev_divid,'accountsize').val('');
					CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_bill_city').html('');
					CrmPopup.findHtmlobj(prev_divid,'bill_city').val('');
					CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_registeredcapital').html('');
					CrmPopup.findHtmlobj(prev_divid,'registeredcapital').val('');
					CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_accountproperty').html('');
					CrmPopup.findHtmlobj(prev_divid,'accountproperty').val('');
					CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_important_level').html('');
					CrmPopup.findHtmlobj(prev_divid,'important_level').val('');
					CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_productcategory').html('');
					CrmPopup.findHtmlobj(prev_divid,'productcategory').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_2836').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_2846').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_2844').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_3118').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_3120').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_3122').val('');
					CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_cf_3124').html('');
					CrmPopup.findHtmlobj(prev_divid,'cf_3124').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_2852').val('');
					CrmPopup.findHtmlobj(prev_divid,'accountrelationship').val('');
					CrmPopup.findHtmlobj(prev_divid,'lastname').val('');
					CrmPopup.findHtmlobj(prev_divid,'cf_3116').val('');
					
					//下单/接单号码
					CrmPopup.findHtmlobj(prev_divid,'cf_2832').val(data.result.passengerMobile);
					if(source_order_type == 'order'){
						//订单号码
						CrmPopup.findHtmlobj(prev_divid,'cf_2834').val(orderId);
						//外部订单号
						CrmPopup.findHtmlobj(prev_divid,'cf_3112').val(data.result.thirdOrderId);
						//乘客UID
						CrmPopup.findHtmlobj(prev_divid,'cf_2842').val(data.result.passengerId);
						//客户名称
						CrmPopup.findHtmlobj(prev_divid,'lastname').val(data.result.passengerName);
						//订单状态
						CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_rating').html(data.result.orderStatus);
						CrmPopup.findHtmlobj(prev_divid,'rating').val(data.result.orderStatus);
						//订单类型
						CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_cf_2840').html(data.result.orderType);
						CrmPopup.findHtmlobj(prev_divid,'cf_2840').val(data.result.orderType);
						//产品类型
						CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_cf_3695').html(data.result.productType);
						CrmPopup.findHtmlobj(prev_divid,'cf_3695').val(data.result.productType);
						//车牌号码
						CrmPopup.findHtmlobj(prev_divid,'cf_2856').val(data.result.vehicleNo);
						CrmPopup.findHtmlobj(prev_divid,'span_cf_2856').html(data.result.vehicleNo);
						//订单车级
						CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_accountsize').html(data.result.carLevelName);
						CrmPopup.findHtmlobj(prev_divid,'accountsize').val(data.result.carLevelName);
						//订单城市
						CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_bill_city').html(data.result.cityName);
						CrmPopup.findHtmlobj(prev_divid,'bill_city').val(data.result.cityName);
						//用车方式
						CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_registeredcapital').html(data.result.useCarType);
						CrmPopup.findHtmlobj(prev_divid,'registeredcapital').val(data.result.useCarType);
						// 应用
						CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_accountproperty').html(data.result.appName);
						CrmPopup.findHtmlobj(prev_divid,'accountproperty').val(data.result.appName);
						// 平台
						CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_important_level').html(data.result.platForm);
						CrmPopup.findHtmlobj(prev_divid,'important_level').val(data.result.platForm);
						//订单渠道 - 应用
						CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_productcategory').html(data.result.appName);
						CrmPopup.findHtmlobj(prev_divid,'productcategory').val(data.result.appName);
						//企业名称
						CrmPopup.findHtmlobj(prev_divid,'cf_2836').val(data.result.enterpriseName);
						//实际乘车人
						CrmPopup.findHtmlobj(prev_divid,'cf_2846').val(data.result.actualPassengerName);
						//乘客历史订单数量
						CrmPopup.findHtmlobj(prev_divid,'cf_2844').val(data.result.orderCount);
						//乘客端预计金额
						CrmPopup.findHtmlobj(prev_divid,'cf_3118').val(data.result.estimatePrice);
						//乘客端实际金额
						CrmPopup.findHtmlobj(prev_divid,'cf_3120').val(data.result.amount);
						//实总付金额
						CrmPopup.findHtmlobj(prev_divid,'cf_3122').val(data.result.receipted);
						//支付状态
						CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_cf_3124').html(data.result.payStatus);
						CrmPopup.findHtmlobj(prev_divid,'cf_3124').val(data.result.payStatus);
						//租赁公司名称
						CrmPopup.findHtmlobj(prev_divid,'cf_2852').val(data.result.leasingCompany);
						//租赁公司名称
						CrmPopup.findHtmlobj(prev_divid,'cf_3114').val(data.result.flightNo);
						//订单标签(接力单/顺路单/跨城单…)
						if(data.result.isReser == 1){
							CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_accountrelationship').html('接力单');
							CrmPopup.findHtmlobj(prev_divid,'accountrelationship').val('接力单');
						}
						if(data.result.isCrossCity == 1){
							CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_accountrelationship').html('跨城单');
							CrmPopup.findHtmlobj(prev_divid,'accountrelationship').val('跨城单');
						}
						if(data.result.isByWay == 1){
							CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_accountrelationship').html('顺路单');
							CrmPopup.findHtmlobj(prev_divid,'accountrelationship').val('顺路单');
						} 
						//渠道
						if(channelCode == 'dc_ysh'){
							CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_cf_3116').html('游上海');
							CrmPopup.findHtmlobj(prev_divid,'cf_3116').val('游上海');
						}else if(channelCode == 'dc_esurfing'){
							CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_cf_3116').html('翼支付');
							CrmPopup.findHtmlobj(prev_divid,'cf_3116').val('翼支付');
						}
						
					}
					var popupobj=CrmPopup.getPopupObj("last");
					popupobj.CancelEvent();
				}else{
					
				}
				DelProgressObjs();
			})
		}
		//获取工单主状态
		function getAccountStatus(accountid){
			var htmlurl =  'index.php?module=Accounts&action=AccountsAjax&file=saic_api&getStatus=yes&record='+accountid;
			ld.ajax({
				url: htmlurl,
				type: 'POST',
				data: "",
				dataType: 'json',
				async: false,//
				timeout: 20000,

				success: function (data) {
					if (data.code == 1) {
						if(data.result.status != '结案'){
							return 1;
						}else{
							return 2;
						}
					}
				}
			})
		}
		//工单 wander:流转, closed:结案, update:更新, closedremarks:结案备注
		function set_saic_account(jqueryobj,event){
			var saic_type=ld(jqueryobj).attr("tag");
			var popupobj=CrmPopup.getPopupObj("last");
			var divid=popupobj.divid;
			var record = popupobj.record;
			if(record <= 0){
				//RemindsMsg("","LdPopWidth400px","","yes","","单据尚未提交，无法进行此操作！");
				//return false;
			}
			if(record == undefined){
				record = CrmPopup.findHtmlobj(divid,'return_id').val();
			}
			var cf_2880 = CrmPopup.findHtmlobj(divid,'cf_2880_name').val();	//工单主状态
			if((saic_type == 'update' || saic_type == 'wander' || saic_type == 'closed') && cf_2880 == '结案'){
				return false;
			}
			if(saic_type == 'wander'){	//流转
				set_wander(jqueryobj,record);
			}else if(saic_type == 'update'){	//更新
				set_update(jqueryobj,record);
			}else if(saic_type == 'closed'){	//结案
				set_closed(jqueryobj,record);
			}else if(saic_type == 'closedremarks'){	//结案备注
				set_closedremarks(jqueryobj,record);
			}else if(saic_type == 'submit1'){	//提交
				getAccountSinInfo(record,'提交','');
			}
			return false;
			var htmlurl =  'index.php?module=Accounts&action=AccountsAjax&file=saic_api&getStatus=yes&record='+record;
			ld.ajax({
				url: htmlurl,
				type: 'POST',
				data: "",
				dataType: 'json',
				async: false,//
				timeout: 20000,

				success: function (data) {
					if (data.code == 1) {
						if(data.result.status != '结案' || saic_type =='closed' || saic_type =='closedremarks' ){
							if(saic_type == 'wander'){	//流转
								set_wander(jqueryobj,record);
							}else if(saic_type == 'update'){	//更新
								set_update(jqueryobj,record);
							}else if(saic_type == 'closed'){	//结案
								set_closed(jqueryobj,record);
							}else if(saic_type == 'closedremarks'){	//结案备注
								set_closedremarks(jqueryobj,record);
							}else if(saic_type == 'submit1'){	//提交
								getAccountSinInfo(record,'提交','');
							}
						}else{
							if(saic_type == 'wander'){
								RemindsMsg("","LdPopWidth400px","","yes","","工单已经结案，无法流转！");
							}else if(saic_type == 'update'){
								RemindsMsg("","LdPopWidth400px","","yes","","工单已经结案，无法更新！");
							}else if(saic_type == 'submit1'){
								RemindsMsg("","LdPopWidth400px","","yes","","工单已经结案，无法提交！");
							}
							
							return false;
						}
					}
				}
			})
		}
		function getGongdanSinInfoForGroup(record,saic_subtype,str_smowerid){
			var htmlurl =  'index.php?module=Accounts&action=AccountsAjax&file=saic_api&getGroup=yes&str_smowerid='+str_smowerid;
			ld.ajax({
				url: htmlurl,
				type: 'POST',
				data: "",
				dataType: 'json',
				async: false,//
				timeout: 20000,

				success: function (data) {
					if(data.code == 1){
						getAccountSinInfo(record,saic_subtype,data.result.gongdan_zhuangtai)
					}
				}
			})
		}
		//提交
		function getAccountSinInfo(record,saic_subtype,str_status){
			var popupobj=CrmPopup.getPopupObj("last");
			var divid=popupobj.divid;
			var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Accounts',"","","","");
			crmPopupobj.prevshow();
			//提交：创建：【工单来源】+“创建”；
			var gongdan_zizhuangtai = '';
			if(saic_subtype == '提交'){
				//工单来源
				var leadsource = CrmPopup.findHtmlobj(divid,'leadsource').val();
				gongdan_zizhuangtai = leadsource + '创建';
			}else if(saic_subtype == '流转'){
				gongdan_zizhuangtai = str_status;
			}
			var table_html = '';
			table_html +='<table class="DetailContentTable linefeed" border="0" cellpadding="0" cellspacing="0" width="100%"><input type="hidden" value="'+record+'" name="module_record"><input type="hidden" value="'+saic_subtype+'" name="saic_subtype">';
			table_html +='<tbody>';
			table_html += '<tr><td class="DetailedTd1Label" align="right" style="width: 20%">工单子状态：</td><td class="DetailedTd1Label" align="left" style="width: 80%"><span name="gongdan_zhuangtai">'+gongdan_zizhuangtai+'</span></td></tr>';
			table_html += '<tr><td class="DetailedTd1Label" align="right" style="width: 20%"><font color="red">*</font>工单标签：</td><td class="DetailedTd1Label" align="left" style="width: 80%"><select style="width:200px;" name="gongdan_biaoqian" class="commonSelectPop"><option value=""></option><option value="聚合平台更新">聚合平台更新</option><option value="聚合平台加急">聚合平台加急</option><option value="待业务方反馈">待业务方反馈</option><option value="业务方已反馈">业务方已反馈</option><option value="待联系乘客">待联系乘客</option><option value="联系不上乘客">联系不上乘客</option><option value="待处理方案">待处理方案</option><option value="待补偿方案">待补偿方案</option><option value="其他特殊原因">其他特殊原因</option></select></td></tr>';
			table_html += '<tr><td class="DetailedTd1Label" align="right" style="width: 20%"><font color="red">*</font>标签特殊备注：</td><td class="DetailedTd1Label" align="left" style="width: 80%"><textarea class="detailedViewTextBox" tabindex="c" fieldonly="0" name="gongdan_beizhu" cols="90" style="height: 36px;overflow: hidden; overflow-wrap: break-word; resize: horizontal;"></textarea></td></tr>';
			table_html +='</tbody>';
			table_html +='</table>';
			crmPopupobj.setParams(saic_subtype,saveAccountSubInfo,"","LdPopWidth800px",'Accounts',"","确认","取消","");
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,table_html);
			DelProgressObjs();
		}
		
		//保存工单子状态、工单标签、标签特殊备注
		function saveAccountSubInfo(){
			var popupobj=CrmPopup.getPopupObj("last");
			var divid=popupobj.divid;
			//工单子状态
			var gongdan_zhuangtai = CrmPopup.findHtmlobj(divid,'gongdan_zhuangtai').html();
			//工单标签
			var gongdan_biaoqian = CrmPopup.findHtmlobj(divid,'gongdan_biaoqian').val();
			//标签特殊备注
			var gongdan_beizhu = CrmPopup.findHtmlobj(divid,'gongdan_beizhu').val();
			if(gongdan_biaoqian == ''){
				RemindsMsg("","LdPopWidth400px","","yes","","工单标签不能为空！");
				return false;
			}
			if(gongdan_beizhu == ''){
				RemindsMsg("","LdPopWidth400px","","yes","","标签特殊备注不能为空！");
				return false;
			}
			var record = CrmPopup.findHtmlobj(divid,'module_record').val();
			var saic_subtype = CrmPopup.findHtmlobj(divid,'saic_subtype').val();
			if(saic_subtype == '提交'){
				saic_subtype = '创建';
			}else{
				saic_subtype = '流转';
			}
			var surl = 'index.php?module=Accounts&action=AccountsAjax&file=saic_api&update_gongdan=yes&record='+record;
			surl += '&gongdan_zhuangtai='+encodeURIComponent(gongdan_zhuangtai);
			surl += '&gongdan_biaoqian='+encodeURIComponent(gongdan_biaoqian);
			surl += '&gongdan_beizhu='+encodeURIComponent(gongdan_beizhu);
			surl += '&saic_subtype='+encodeURIComponent(saic_subtype);
			//alert(surl);
			//return false;
			ldAjax(surl,"",function(data){
				if(data.code == 1){
					var prevpopupobj=CrmPopup.getPopupObj("lastprev");
					var prevdivid=prevpopupobj.divid;
					if(prevpopupobj.type == 'createpage' || prevpopupobj.type == 'pagerecord'){
						CrmPopup.findHtmlobj(prevdivid,'span_cf_2902').html(gongdan_zhuangtai);
						CrmPopup.findHtmlobj(prevdivid,'cf_2902').val(gongdan_zhuangtai);
						CrmPopup.findHtmlobj(prevdivid,'cmb_span_optiontext_cf_2904').html(gongdan_biaoqian);
						CrmPopup.findHtmlobj(prevdivid,'cf_2904').val(gongdan_biaoqian);
						CrmPopup.findHtmlobj(prevdivid,'cf_2888').val(gongdan_beizhu);
						if(CrmPopup.findHtmlobj(prevdivid,'cmb_span_optiontext_cf_2880') != undefined)
							CrmPopup.findHtmlobj(prevdivid,'cmb_span_optiontext_cf_2880').html(saic_subtype);
						CrmPopup.findHtmlobj(prevdivid,'cf_2880').val(saic_subtype);
						if(CrmPopup.findHtmlobj(prevdivid,'span_cf_2880') != undefined)
							CrmPopup.findHtmlobj(prevdivid,'span_cf_2880').html(saic_subtype);
					}else{
						CrmPopup.findHtmlobj(prevdivid,'dtlview_cf_2902').html(gongdan_zhuangtai);
						CrmPopup.findHtmlobj(prevdivid,'dtlview_cf_2904').html(gongdan_biaoqian);
						CrmPopup.findHtmlobj(prevdivid,'cf_2904').val(gongdan_biaoqian);
						CrmPopup.findHtmlobj(prevdivid,'dtlviewcf_2888').html(gongdan_beizhu);
						CrmPopup.findHtmlobj(prevdivid,'cf_2888').val(gongdan_beizhu);
						CrmPopup.findHtmlobj(prevdivid,'dtlviewcf_2880').html(saic_subtype);
						CrmPopup.findHtmlobj(prevdivid,'cf_2880').val(saic_subtype);	
					}
					popupobj.CancelEvent();
					prevpopupobj.CancelEvent();
					var tmparra=new Array();
					var refreshlistmodules = new Array('Accounts');
					var tmpobj= new AfterUpdatePrevPopupObjContent('Accounts',"",tmparra);
					tmpobj.eachrefreshlistbyModules(refreshlistmodules);
				}
				//RemindsMsg("","LdPopWidth400px","","yes","","工单"+saic_subtype+"成功！");
				//return false;
				
				DelProgressObjs();
			});
			return false;
		}
		
		//结案
		function saveAccountClosed(){
			var popupobj=CrmPopup.getPopupObj("last");
			var divid=popupobj.divid;
			var prevpopupobj=CrmPopup.getPopupObj("lastprev");
			var prevdivid=prevpopupobj.divid;
			var record = prevpopupobj.record;
			
			var surl = 'index.php?module=Accounts&action=AccountsAjax&file=saic_api&update_jiean=yes&record='+record;
			var jiean_content = CrmPopup.findHtmlobj(divid,'jiean_content').val();
			if(jiean_content == ''){
				//RemindsMsg("","LdPopWidth400px","","yes","","处理结果备注内容不能为空！");
				//return false;
			}
			var jiean_type = CrmPopup.findHtmlobj(divid,'jiean_type').val();
			surl += '&jiean_content='+encodeURIComponent(jiean_content);
			surl += '&jiean_type='+jiean_type;
			ldAjax(surl,"",function(data){
				if(data.code == 1){
					if(prevpopupobj.type == 'createpage' || prevpopupobj.type == 'pagerecord'){
						CrmPopup.findHtmlobj(prevdivid,'cmb_span_optiontext_cf_2880').html('结案');
						CrmPopup.findHtmlobj(prevdivid,'cf_2880').val('结案');
						CrmPopup.findHtmlobj(prevdivid,'span_cf_2880').html('结案');
						CrmPopup.findHtmlobj(prevdivid,'span_cf_2902').html(data.result.gongdan_zhuangtai);
						CrmPopup.findHtmlobj(prevdivid,'cf_2902').val(data.result.gongdan_zhuangtai);
					}else{
						CrmPopup.findHtmlobj(prevdivid,'cf_2880').val('结案');	
						CrmPopup.findHtmlobj(prevdivid,'dtlview_cf_2880').html('结案');
						CrmPopup.findHtmlobj(prevdivid,'cf_2902').val(data.result.gongdan_zhuangtai);	
						CrmPopup.findHtmlobj(prevdivid,'dtlview_cf_2902').html(data.result.gongdan_zhuangtai);
					}
					var tmparra=new Array();
					var refreshlistmodules = new Array('Accounts');
					var tmpobj= new AfterUpdatePrevPopupObjContent('Accounts',"",tmparra);
					tmpobj.eachrefreshlistbyModules(refreshlistmodules);
					popupobj.CancelEvent();
					prevpopupobj.CancelEvent();
					//RemindsMsg("","LdPopWidth400px","","yes","","工单结案成功！");
					//return false;
				}else{
					//RemindsMsg("","LdPopWidth400px","","yes","","工单尚未更新，无法结案！");
					//return false;
				}
				DelProgressObjs();
			});
		}
		
		//查询工单历史记录
		function saic_accountinfo(obj,module){
			var popupobj=CrmPopup.getPopupObj("last");
			var divid=popupobj.divid;
			var accountname = CrmPopup.findHtmlobj(divid,'accountname').val();
			if(accountname == ''){
				RemindsMsg("","LdPopWidth400px","","yes","","进线号码不能为空！");
				return false;
			}
			var surl = 'index.php?module=Accounts&action=AccountsAjax&file=saic_api&select_account=yes&saic_mobile='+accountname;
			//alert(surl);
			ldAjax(surl,"",function(data){
				//alert(data.code);
				if(data.code == 1){
					CrmPopup.findHtmlobj(divid,'saic_mobile_log').html(data.result.content);
					//popupobj.CancelEvent();
				}
				DelProgressObjs();
			});
			
		}
		//暂存
		function saic_save_account(jqueryobj,event){
			var saic_type=ld(jqueryobj).attr("tag");
			var popupobj=CrmPopup.getPopupObj("last");
			var divid=popupobj.divid;
			var cf_2880 = CrmPopup.findHtmlobj(divid,'cf_2880').val();	//工单主状态
			if((saic_type == 'zancun' || saic_type == 'update' || saic_type == 'submit1' || saic_type == 'wander') && cf_2880 == '结案'){
				return false;
			}
			if(saic_validate()){
				if(saic_duplicate()){
					saic_ajaxsave(jqueryobj,saic_type);
				}
			}
		}

		function saic_validate(){
			var popupobj=CrmPopup.getPopupObj("last");
			if (popupobj.before_validate()) {
				if (popupobj.detailfieldmodule != undefined && popupobj.detailfieldmodule == 'Products') {
					//产品分录明细保存
					if (validateInventory(popupobj.module)) {
						return popupobj.after_validate();
					}
				}
				
				else if (formValidate())   //验证
				{
					if(popupobj.hasOwnProperty('detailfieldmodule')&& popupobj.detailfieldmodule !== undefined 
						&& popupobj.detailfieldmodule.indexOf('detailhtml')>-1&&!verifyTabDetailField())
					{
						return false;
					}
					return popupobj.after_validate();
				}
			}
			return false;
		}

		function saic_duplicate(){
			 var popupobj = CrmPopup.getPopupObj("last");
			if (popupobj.hasOwnProperty('before_duplicate') && !popupobj.before_duplicate()) {
				return false;
			}
			if (FieldDuplicateValidate(popupobj.module, CrmPopup.findHtmlobj(popupobj.divid, "EditView"), '')) {
				return popupobj.after_duplicate();
			}

			return false;
		}
		
		function isfileattachUitype(uitype)  {
			if (uitype == 28 || uitype == 1109 || uitype == 69 || uitype == 1108||uitype==105) {

				return true;
			}
			else {
				return false;
			}

		}
		
		function getFileAttachmenturl(fieldinfo, divid)  {
			var htmlurl = "";
			var fieldname = fieldinfo.fieldname;
			if (fieldinfo.uitype == 28 && CrmPopup.getHtmlobjval(divid, 'filelocationtype') == "E") {
				htmlurl += "&" + fieldname + "_E__" + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "_E__"));
			}
			else if (CrmPopup.isExistsObj(divid, fieldname + '-file_num')) {
				var filenum = CrmPopup.getHtmlobjval(divid, fieldname + '-file_num');
				if (filenum > 0) {
					var tmpfilenum = 0;
					for (var k = 1; k < 60; k++) {
						//editor:gyq_169 reason:腾讯云COS文件上传预览    2020/2/26 23:00
						if (CrmPopup.isExistsObj(divid, fieldname + "-file_name_" + k)) {
							htmlurl += "&" + fieldname + "-file_name_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-file_name_" + k));
							htmlurl += "&" + fieldname + "-file_type_" + k + "=" + CrmPopup.getHtmlobjval(divid, fieldname + "-file_type_" + k);
							htmlurl += "&" + fieldname + "-file_size_" + k + "=" + CrmPopup.getHtmlobjval(divid, fieldname + "-file_size_" + k);
							htmlurl += "&" + fieldname + "-file_path_" + k + "=" + CrmPopup.getHtmlobjval(divid, fieldname + "-file_path_" + k);
							htmlurl += "&" + fieldname + "-newfile_name_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-newfile_name_" + k));
							htmlurl += "&" + fieldname + "-upload_from_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-upload_from_" + k));
						   // alert(globalWebUploadType);
						   //考虑历史数据
						  var storage_location=CrmPopup.getHtmlobjval(divid, fieldname + "-storage_location_" + k)
							if(storage_location=='cos'){
								htmlurl += "&" + fieldname + "-cloud_path_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-cloud_path_" + k));
							}
							htmlurl += "&" + fieldname + "-storage_location_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-storage_location_" + k));
							tmpfilenum++;
						}

					}

					htmlurl += "&" + fieldname + "-file_num=" + tmpfilenum+"&"+fieldname+"&-attachmentcolumnname="+fieldinfo.columnname;
				}
			}

			else {
			   

			}
			return htmlurl;
		}
		function saic_ajaxsave(jqueryobj,saic_type){
			var popupobj = CrmPopup.getPopupObj("last");
			var divid = popupobj.divid;
			var savedeskvaluepage = popupobj.getsavedeskpageValue();
			var module = popupobj.module;
			var filedataarr = popupobj.getFileDataArr();
			var htmlurl = "index.php?module=" + popupobj.module + "&action=Save";
			if (popupobj.frommodule != undefined) {
				htmlurl += "&frommodule=" + popupobj.frommodule + "&fromid=" + popupobj.fromid;
			}
			if (popupobj.record > 0) {

				htmlurl += "&record=" + popupobj.record + "&mode=edit";
				/*if(saic_type == 'wander'){	//流转
					set_wander(jqueryobj,record);
					return false;
				}else if(saic_type == 'update'){	//更新
					set_update(jqueryobj,record);
					return false;
				}else if(saic_type == 'closed'){	//结案
					set_closed(jqueryobj,record);
					return false;
				}else if(saic_type == 'closedremarks'){	//结案备注
					set_closedremarks(jqueryobj,record);
					return false;
				}*/
			}
			else if(popupobj.type==CreatePagePopup.type){
				 htmlurl += "&mode=create&Create=yes";
			}
			var tmpurl = "&refreshpage=no";
			var fieldlen=popupobj.fields.length;
			for (var i = 0; i < fieldlen; i++) {
				var fieldname = popupobj.fields[i].fieldname;
				
				if (isfileattachUitype(popupobj.fields[i].uitype))//附件，图片
				{
					htmlurl += getFileAttachmenturl(popupobj.fields[i], popupobj.divid);

				}
				else if(popupobj.fields[i].uitype==208)
				{
					tmpurl += '&selectsource=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, 'selectsource'));
					tmpurl += '&' + fieldname + '=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname));
				}
				else if(popupobj.fields[i].uitype==202)
				{
					tmpurl += '&selectsourcename=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, 'selectsource'));
					tmpurl += '&' + fieldname + '=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname));
				}
				else if(popupobj.fields[i].uitype==112)
				{
					tmpurl += '&reltab=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, 'related_to_type'));
					tmpurl += '&' + fieldname + '=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname));
				}
				else if (popupobj.fields[i].uitype == 117) {
					//币种
					var elementobj = CrmPopup.findHtmlobj(divid, fieldname);

					tmpurl += '&' + fieldname + '=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname));
					tmpurl += '&hidden_currency_id=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, 'hidden_currency_id'));
				}
				else if(popupobj.fields[i].uitype==99){
					//密码框
					 tmpurl += "&"+fieldname+'='+ld("#"+popupobj.divid+" [name="+fieldname+"]").val();
					 
				}
				else if (CrmPopup.isExistsObj(popupobj.divid, fieldname)) {

					if (popupobj.fields[i].uitype == 33) {

						var strtmp = getMultiPickListSelectValue(popupobj.fields[i].fieldname + "[]");
						htmlurl += "&" + fieldname + "=" + encodeURIComponent(strtmp);


					}

					else {
						var elementobj = CrmPopup.findHtmlobj(divid, fieldname);
					
						tmpurl += '&' + fieldname + '=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname));
					}
				}
				else if (ld.isArray(savedeskvaluepage))//新增界面
				{

					if (savedeskvaluepage[fieldname] != undefined) {
						tmpurl += '&' + fieldname + '=' + encodeURIComponent(savedeskvaluepage[fieldname]);
					}
					else {
						if (fieldname == 'reltab') {
							tmpurl += '&related_to_type=' + CrmPopup.getHtmlobjval(divid, 'related_to_type');
						} else
							tmpurl += '&' + fieldname + '= ';
					}

				}

				if (popupobj.fields[i].uitype == 125) {	//分摊 - 通用代码
					if (CrmPopup.getHtmlobjval(divid, fieldname + '_shareequally_value_count') > 0) {
						var shareequally_value_array = new Array();
						var shareequally_value_count = CrmPopup.getHtmlobjval(divid, fieldname + '_shareequally_value_count');
						tmpurl += '&' + fieldname + '_shareequally_value_count=' + shareequally_value_count;
						tmpurl += '&' + fieldname + '_shareequally_type=' + CrmPopup.getHtmlobjval(divid, fieldname + '_shareequally_type');
						for (var row_id = 1; row_id <= shareequally_value_count; row_id++) {
							tmpurl += '&' + fieldname + '_shareequally_value_' + row_id + '=' + CrmPopup.getHtmlobjval(divid, fieldname + '_shareequally_value_' + row_id);
						}
					}
				}
				if ('SendPayment' == popupobj.module && fieldname == 'purchaseorder_id') {
					tmpurl += '&selectsource=' + CrmPopup.getHtmlobjval(divid, 'selectsource');
					tmpurl += '&salesorder_id=' + CrmPopup.getHtmlobjval(divid, 'salesorder_id');
					tmpurl += '&entitytypeid=' + CrmPopup.getHtmlobjval(divid, 'entitytypeid');
				}
			}

			if (popupobj.module == 'Accounts' || popupobj.module == 'ServiceCharge') {
				tmpurl += '&contactid=' + CrmPopup.getHtmlobjval(divid, 'contactid');
			   // tmpurl += '&publicaccount=' + CrmPopup.getHtmlobjval(divid, 'publicaccount');
			}
			ld('#rptContentLoading').show();
			ld.ajax({
				url: htmlurl,
				type: 'POST',
				data: tmpurl,
				dataType: 'json',
				async: false,//
				timeout: 20000,

				success: function (data) {
					if (data.code == 1) {
						var record = data.result.fieldvalue.maintable_id;
						if(data.result.fieldvalue.faq_id > 0){
							CrmPopup.findHtmlobj(divid,'faq_id').val(data.result.fieldvalue.faq_id);
							CrmPopup.findHtmlobj(divid,'faq_id_name').val(data.result.fieldvalue.faq_no);
							CrmPopup.findHtmlobj(divid,'faq_id_name').css('cursor','not-allowed');	
							CrmPopup.findHtmlobj(divid,'faq_id_name').attr("disabled",true);
							if(data.result.fieldvalue.faq_smower_last_name != ''){
								CrmPopup.findHtmlobj(divid,'cf_3013').val(data.result.fieldvalue.faq_smower_id);
								CrmPopup.findHtmlobj(divid,'span_cf_3013').html(data.result.fieldvalue.faq_smower_last_name);
							}
						}
						ld('#rptContentLoading').hide();
						var refreshlistmodules = new Array('Accounts');
						popupobj.record = record;
						popupobj.type = 'pagerecord';
						//alert(record);
						var tmparra=new Array();
						var tmpobj= new AfterUpdatePrevPopupObjContent('Accounts',"",tmparra);
						tmpobj.eachrefreshlistbyModules(refreshlistmodules);
						if(saic_type == 'zancun'){	//暂存
							//RemindsMsg("","LdPopWidth400px","","yes","","工单暂存成功！");
							//return false;
						}else if(saic_type == 'wander'){	//流转
							set_wander(jqueryobj,record);
							return false;
						}else if(saic_type == 'update'){	//更新
							set_update(jqueryobj,record);
							return false;
						}else if(saic_type == 'closed'){	//结案
							set_closed(jqueryobj,record);
							return false;
						}else if(saic_type == 'closedremarks'){	//结案备注
							set_closedremarks(jqueryobj,record);
							return false;
						}else{
							getAccountSinInfo(record,'提交','');
						}
					}
				}
			})
			return false;
		}
		//结案备注
		function set_closedremarks(jqueryobj,record){
			var popupobj=CrmPopup.getPopupObj("last");
			var divid=popupobj.divid;
			var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Accounts',"","","","");
			crmPopupobj.prevshow();
			var jiean_content = '';
			var table_html = '';
			table_html +='<table class="DetailContentTable linefeed" border="0" cellpadding="0" cellspacing="0" width="100%"><input type="hidden" name="jiean_type" value="closedremarks">';
			table_html +='<tbody>';
			table_html += '<tr><td class="DetailedTd1Label" align="right" style="width: 20%">处理结果备注：</td><td class="DetailedTd2Info"><textarea style="height:150px;" name="jiean_content">'+jiean_content+'</textarea></td></tr>';
			table_html +='</tbody>';
			table_html +='</table>';
			crmPopupobj.setParams('结案备注',saveAccountClosed,"","LdPopWidth600px",'Accounts',"","确认","取消","");
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,table_html);
			DelProgressObjs();
		}
		//结案
		function set_closed(jqueryobj,record){
			var popupobj=CrmPopup.getPopupObj("last");
			var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Accounts',"","","","");
			crmPopupobj.prevshow();
			var table_html = '';
			table_html +='<table class="DetailContentTable linefeed" border="0" cellpadding="0" cellspacing="0" width="100%"><input type="hidden" name="jiean_type" value="closed">';
			table_html +='<tbody>';
			table_html += '<tr><td class="DetailedTd1Label" align="right" style="width: 20%">结案备注：</td><td class="DetailedTd2Info"><textarea style="height:150px;" name="jiean_content"></textarea></td></tr>';
			table_html +='</tbody>';
			table_html +='</table>';
			crmPopupobj.setParams('结案',saveAccountClosed,"","LdPopWidth600px",'Accounts',"","确认","取消","");
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,table_html);
			DelProgressObjs();
		}
		//更新
		function set_update(jqueryobj,record){
			var  popupobj = CrmPopup.getPopupObj("last");
            var  objparams = new CreatePagePopup.params();
			var lasturl = '&isDuplicate=no&frommodule=Accounts&fromid='+record+"&account_id="+record;
            objparams.params['createdtype'] = '';
			objparams.params['isduplicate'] = 'no';
            CreatePagePopup.showpage('Faq', lasturl, objparams);
			//related_add_url('index.php?module=Faq&action=EditView&return_module=Faq&return_action=DetailView&relatedcreate=yes&Create=true&frommodule=Accounts&fromid='+record+'&parent_id='+record+'&account_id='+record,'Accounts','Faq',record)
			//var page_addurl=encodeURIComponent("&Create=true&fromid="+record+"&frommodule=Accounts&relatedcreate=yes");
			// window.open("index.php?pageto_module=Faq&pageto_action=index&pageto_create=yes&page_addurl="+page_addurl);
		   return false;
		}
		//流转
		function set_wander(jqueryobj,record){
			detailbutton_click(jqueryobj,'Accounts','Share',record);return false;
		}
	{/literal}
</script>
