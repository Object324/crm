//重算经纬度
function Reset_latandlong(module){
	this.module = module;
	this.success_num = 0;	//成功数
	this.progress_result = '';	//重算经纬度统计结果
	this.progress_log = '';	//重算经纬度日志
	var that = this;
	//显示重算经纬度界面
	this.view = function(){
		var popupobj=CrmPopup.getPopupObj("last");
		var select_options = ld("#"+popupobj.divid+" [name=allselectedboxes]").val();
		if(select_options == 'all'){
			//获取全选数量
			var selectlen = ld("#"+popupobj.divid+" [name=numOfRows]").val();
			if (parseInt(selectlen) > parseInt(getMaxMassOperationLimit())) {
				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', selectlen, getMaxMassOperationLimit(), '');
				RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);
				//确定事件
				ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
					that.show(select_options);
				});
			}
			else {
				that.show(select_options);
			}
		}else{
			if(select_options == ''){
				MessagePopup.TipOne_warning(arrJsPopLabel['PLEASESELECTONEENTITY']);
				return false;
			}
			var x = select_options.split(';');
            var count = x.length;
            if (parseInt(count) - 1 > parseInt(getMaxMassOperationLimit())) {
                var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', parseInt(count) - 1, getMaxMassOperationLimit(), '');
                //创建提示弹出层
                RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);
                //确定事件
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                    that.show(select_options);
                });
            } else {
                that.show(select_options);
            }
		}
			
	}
	this.show=function(select_options){
        var module = this.module;
		var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=Recalculation_latandlong&select_ids='+select_options;
		//基本、高级查询条件
		if(!empty(searchtype_btn)){
			surl += '&'+getUrlString(searchtype_btn);
			surl += "&query=true&ajax=true&search=true";
		}
        //zkt 模块树结构显示增加条件，获取树结构点击条件
        if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
    	   surl += '&isshowModuleListTree=yes';
    	}
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",module,"","","","");
		crmPopupobj.prevshow();
		ldAjax(surl,"",function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,that.submit,"","LdPopWidth600px",module,"",data.result.oktext,"",data.result.canceltext,"");
				crmPopupobj.show(data.result.content);
				crmPopupobj.center();
				DelProgressObjs();
			}
		})
	}
	//提交
	this.submit= function(){
		var popupobj=CrmPopup.getPopupObj("last");
        var module = this.module;
		var radio_recalculation = ld("#"+popupobj.divid+" [name=radio_recalculation]:checked").val();
		if(radio_recalculation == 'all'){
			that.record = ld("#"+popupobj.divid+" [name=have_address_records]").val();
		}else{
			that.record = ld("#"+popupobj.divid+" [name=have_address_and_no_latandlong_records]").val();
		}
		if(that.record == ''){
			RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['NOTFOUNDANYRECORD']);
			return false;
		}
		var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=Recalculation_latandlong&show_progress=yes';
		paramsurl = '&records='+that.record;
		that.crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
		that.crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,paramsurl,function(data){
			if(data.code==1){
				popupobj.CancelEvent();
				that.crmPopupobj.setParams(data.result.title,that.close,"","LdPopWidth600px",'Settings',"",data.result.oktext,"","","");
				that.crmPopupobj.show(data.result.content);
				that.crmPopupobj.center();
				ld("#"+that.crmPopupobj.divid+" [name=button]").hide();
				that.maxrows = data.result.maxrows;	//总条目数
				ld("#"+that.crmPopupobj.divid+" .import_info").html(data.result.timedescription);
				that.progress(0,4);	//执行，加载进度条
			}
		})
		return false;
	}
	//提交执行，加载进度条
	this.progress = function(startrow,endrow){
		var tmpurl = "&records="+that.record;
        var module = this.module;
		ld.ajax({
			url: 'index.php?module='+module+'&action='+module+'Ajax&file=Recalculation_latandlong&mode=update&startrow='+startrow+'&endrow='+endrow+"&success_num="+that.success_num,
			type: 'POST',
			data:tmpurl,
			dataType:'json',
			async: true,//
			timeout: 0,
			success: function(data)
			{
				if(data.code=='-1'){
					alert(data.msg);
					return false;
				}
				that.startrow=parseInt(data.result.endrow,10)+1;
				ld("#"+that.crmPopupobj.divid+" .import_info").html(data.result.timedescription);
				ld('#'+that.crmPopupobj.divid+" [name=process_now]").css("width",data.result.cur_progress_step+"%");
				ld("#"+that.crmPopupobj.divid+" .percent").html(data.result.cur_progress_step+"%");
				that.success_num = parseInt(data.result.success_num);
				that.progress_log += data.result.progress_log;
				that.progress_result = data.result.progress_result;

				if(parseInt(that.maxrows,10)<=parseInt(that.startrow)){
					that.finished();
				}else{
					for(var i=0;i<=2000;i++){
						//暂停
					}
					that.progress(that.startrow,that.startrow+4);
				}
			},
		})
	}
	//显示结果
	this.finished = function(){
		var prev_popupobj=CrmPopup.getPopupObj("lastprev");
		ld("#"+that.crmPopupobj.divid+" [name=button]").show();
		ld("#"+that.crmPopupobj.divid+" [name=progress_div]").hide();
		ld("#"+that.crmPopupobj.divid+" [name=progress_result]").html(that.progress_result);
		ld("#"+that.crmPopupobj.divid+" .ld-description .ld-description-content").html(that.progress_result);
		ld("#"+that.crmPopupobj.divid+" [name=progress_log]").html(that.progress_log);
		ld("#"+that.crmPopupobj.divid+" [name=massConvertcontent]").show();
		that.crmPopupobj.center();
		return false;
	}
	//关闭弹出层
	this.close=function(){
		var popupobj=CrmPopup.getPopupObj("lastprev");
		that.crmPopupobj.CancelEvent();
		ld("#"+popupobj.divid+" [name=basicsearchcolumns]").html('');
		ld("#"+popupobj.divid+" [name=allselectedboxes]").val('');
		ld("#"+popupobj.divid+" [name=selectedboxes]").val('');
		var pagenum = ld("#"+popupobj.divid+" [name=pagenum]").val();
		getListViewEntries_js(that.module,'&start='+pagenum);//刷新页面
	}
}