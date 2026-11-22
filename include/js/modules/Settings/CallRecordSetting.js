function CallRecordSetting(){
    var that=this;
    var pagetype = '';
    this.tableobj = '';
    this.setPopupobj = function(obj){
        that.popupobj = obj;
    }
    //切换页签对应的事件
    this.changeNavBar = function (pagetype,ajaxdata){
        that.pagetype = pagetype;
        var popupobj = that.popupobj;
        if(pagetype == 'callrecordlogs'){
            var selectobj_field = ld("#"+popupobj.divid).find("select[name=selectmodule]");
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml("selectmodule");
            cls_resetComboxHtmlobj.setComboxObjHtml();
            var selectwidth = Tools.getParentobjByChild(selectobj_field,'td').width();
            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj_field,selectwidth+10);

            selectobj_field = ld("#"+popupobj.divid).find("select[name=selectcalltype]");
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml("selectcalltype");
            cls_resetComboxHtmlobj.setComboxObjHtml();
            var selectwidth = Tools.getParentobjByChild(selectobj_field,'td').width();
            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj_field,selectwidth+10);

            // 基本查找 搜索框聚焦事件
            ld('#basicSearchNewDiv').find('.ld-listview-basicsearch input').unbind('focus').bind('focus',function(){
                ld('#basicSearchNewDiv').find('#basicsearchcolumns_real select').addClass('ld-border-color-3b7cff');
                ld(this).addClass('ld-border-color-3b7cff');
            });
            ld('#basicSearchNewDiv').find('.ld-listview-basicsearch input').unbind('blur').bind('blur',function(){
                ld('#basicSearchNewDiv').find('#basicsearchcolumns_real select').removeClass('ld-border-color-3b7cff');
                ld(this).removeClass('ld-border-color-3b7cff');
            });
        }
    }
    
    // 启用通话录音
    this.enableCallRecord = function(obj){
        var callrecordstatus = ld(obj).prop('checked')?'yes':'no';
        var urlstring = 'module=Settings&action=SettingsAjax&file=CallRecordSetting&mode=enablecallrecord';
        urlstring += '&selectpage=functionsetting';
        urlstring += '&callrecordstatus='+callrecordstatus;
        ldAjaxNoProgress('index.php?',urlstring,function(data){
            if(data.code == 1){
                MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULOPERATION']);
            }
        })
    }
    // 编辑模块来电和去电号码匹配字段
    this.editFields = function(){
        //产生弹窗
        var popupobj = this.popupobj;
        var Popupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
        Popupobj.prevshow();
        var urlstring = 'module=Settings&action=SettingsAjax&file=CallRecordSetting&mode=editfields';
        urlstring += '&selectpage=functionsetting';
        ldAjaxNoProgress('index.php?',urlstring,function (data) {
            if (data.code == 1) {
                Popupobj.setParams(data.result.title, that.saveFields, "", "LdPopWidth600px", 'Settings', "", data.result.oktext, "", data.result.canceltext);
                var table_html = `<div class="divPopOverflow"><table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">`;
                ld.each(data.result.phonefields, function(module, info) {
                    table_html +=`<tr>
                                    <td class="ld-form-item-label">
                                        <input type="checkbox" class="Bornone input-btn-align" id="`+module+`" name="enablemodule" modulename="`+module+`" onclick="" `+info.checked+`/>
                                        <label style="cursor:pointer;margin-left: 5px;" for="`+module+`">`+info.label+`</label></td>
                                    </td>
                                    <td class="ld-form-item-content">
                                        <div id="divSelect`+module+`" class="" style="">
                                        <div width="100%" cellpadding="0" border="0" cellspacing="0" style="overflow-y:auto;overflow-x: hidden;border:0px #ccc solid;background:white;">
                                        <ul style="width:100%;">`;
                    ld.each(info.field, function(index, fieldinfo) {
                        var tmp_value = module+'_'+fieldinfo.columnname;
                        table_html +=`<li style="float:left;width:33%">
                                        <input type="checkbox" id="`+tmp_value+`" name="enablefield" columnname="`+fieldinfo.columnname+`" modulename="`+module+`"
                                            onclick="" style="border:none;" `+fieldinfo.checked+`/>
                                        <label style="cursor:pointer;margin-left: 5px;" for="`+tmp_value+`" onclick="">`+fieldinfo.fieldlabel+`</label>
                                    </li>`;
                    });
                    table_html += `</div></div></td><tr>`
                });
                table_html += '</table></div>';
                CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj, table_html);
                that.editFieldsBindEvent();// 绑定事件
                // 设置内容最大高度
                Popupobj.setPopBodyMaxHeight(".divPopOverflow");

            }
        })
    }
    // 编辑模块来电和去电号码匹配字段 - 绑定事件
    this.editFieldsBindEvent = function(){
        var popupobj = CrmPopup.getPopupObj('last');
        ld('#'+popupobj.divid).find('[name=enablemodule]').unbind('click').on('click', function (event) {
            if(!ld(this).is(':checked')){
                ld(this).parent().parent().find('[name=enablefield]').prop('checked',false);
            }
        })
        ld('#'+popupobj.divid).find('[name=enablefield]').unbind('click').on('click', function (event) {
            if(ld(this).is(':checked')){
                if(!ld(this).parents('tr').find('[name=enablemodule]').is(':checked')){
                    ld(this).parents('tr').find('[name=enablemodule]').prop('checked',true);
                }
            }
        })
    }
    // 保存模块来电和去电号码匹配字段
    this.saveFields=function(obj,module,type){
        
        var popupobj = CrmPopup.getPopupObj('last');
        var enablemoduleobj = ld('#'+popupobj.divid).find('[name=enablemodule]');// 启用模块checkbox
        // var modulestatus = [];
        var enabledmodule = [];// 启用的模块
        var enabledphonefields = {};// 模块和对应启用字段
        ld.each(enablemoduleobj, function(index, obj) {
            // modulestatus[ld(obj).attr('modulename')] = ld(obj).prop('checked')?'yes':'no';// 获取每个模块启用状态
            if(ld(obj).prop('checked')){
                enabledmodule.push(ld(obj).attr('modulename'));
            }
            enabledphonefields[ld(obj).attr('modulename')] = '';
        });
        var enablefieldobj = ld('#'+popupobj.divid).find('[name=enablefield]');// 启用字段checkbox
        ld.each(enablefieldobj, function(index, obj) {
            if(ld(obj).prop('checked')){
                if(!empty(enabledphonefields[ld(obj).attr('modulename')])){
                    enabledphonefields[ld(obj).attr('modulename')] += ','+ld(obj).attr('columnname');
                }else{
                    enabledphonefields[ld(obj).attr('modulename')] = ld(obj).attr('columnname');
                }
            }
        }); 
        var urlstring = 'module=Settings&action=SettingsAjax&file=CallRecordSetting&mode=savefields';
        urlstring += '&selectpage=functionsetting';
        urlstring += '&enabledmodule='+JSON.stringify(enabledmodule);
        urlstring += '&enabledphonefields='+JSON.stringify(enabledphonefields);
        ldAjaxNoProgress('index.php?',urlstring,function(data){
            if(data.code == 1){
                popupobj.CancelEvent();
                that.refreshContent();
                MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYSAVED']);
            }
        })
    }
    // 刷新页签中内容
    this.refreshContent=function(){
        var urlstring = 'module=Settings&action=SettingsAjax&file=CallRecordSetting&ajax=true';
        urlstring += '&selectpage='+this.pagetype;
        ldAjax('index.php?',urlstring,function(data){
            var CallRecordSettingContentObj = ld("#"+obj.divid).find("#CallRecordSettingContent");
            CallRecordSettingContentObj.html(data.result.content);
            that.changeNavBar(this.pagetype,data);
            DelProgressObjs();
        })
    }

    // 显示/隐藏 基本查找的清除按钮
    this.setShowOrHideClearIcon=function(){
        var popupobj = that.popupobj;
        var search_text = ld('#'+popupobj.divid).find('#basicSearchNewDiv').find('[name=search_text]').val();
        //显示清除按钮
        if(!empty(search_text)){
            ld('#'+popupobj.divid).find('#basicSearchNewDiv').find('.ld-icon-clearsearch').show();
        }else{
            ld('#'+popupobj.divid).find('#basicSearchNewDiv').find('.ld-icon-clearsearch').hide();
        }
    }
    // 基本查找清除内容
    this.clearBasicSearch=function(obj){
        var popupobj = that.popupobj;
        ld('#'+popupobj.divid).find('#basicSearchNewDiv').find('[name=search_text]').val('');
        ld('#'+popupobj.divid).find('#basicSearchNewDiv').find('.ld-icon-clearsearch').hide();
        ld('#'+popupobj.divid).find('#basicSearchNewDiv').find('[name=search_text]').focus();
    }
    // 查询日志
    this.searchLogs = function(pagenum=''){
        var popupobj = that.popupobj ? that.popupobj:CrmPopup.getPopupObj('last');
        var formobj = ld('#'+popupobj.divid).find('table#CallRecordLogsTable');
        var selectmodule = formobj.find('#selectmodule').val();
        var selectcalltype = formobj.find('#selectcalltype').val();
        var startdate = formobj.find('[name=startdate]').val();
        var enddate = formobj.find('[name=enddate]').val();
        var basicsearchoption = formobj.find('#basicSearchNewDiv').find('#bas_searchfield').val();
        var basicsearchvalue = formobj.find('#basicSearchNewDiv').find('.ld-listview-basicsearch').find('input').val();

		var mode = 'searchLogs';
		if(pagenum != ''){
			mode = 'changeLogspage';
		}
        var urlstring = 'module=Settings&action=SettingsAjax&file=CallRecordSetting'+'&mode='+mode;
        urlstring += '&selectpage=callrecordlogs';
		urlstring += '&selectmodule='+selectmodule+'&selectcalltype='+encodeURIComponent(selectcalltype)+'&startdate='+startdate+'&enddate='+enddate;
		urlstring += '&basicsearchoption='+basicsearchoption+'&basicsearchvalue='+encodeURIComponent(basicsearchvalue);
		urlstring += '&pagenum='+pagenum;
        
		ldAjaxNoProgress('index.php?',urlstring,function(data){
			if(data.code==1){
				if(mode == 'searchLogs'){
					ld('#'+popupobj.divid).find("#ld-operationlog-mainlist").html(data.result.content);
				}else if(mode == 'changeLogspage'){
					ld('#'+popupobj.divid).find("#ld-operationlog-list-table").html(data.result.content);
				}
				var widthbox = parseInt(ld('#'+popupobj.divid).find('#ld-operationlog-list').width())+17;
				ld('#'+popupobj.divid).find('div[name=operationlogs_header] table').css('width', widthbox +'px');
				ld('#'+popupobj.divid).find('div[name=operationlogs_content] table').css('width', widthbox +'px');
                
                if(ld('#'+popupobj.divid).find('#divFileCallButlerlist').length < 1)
                    ld('#'+popupobj.divid).find('#CallRecordSettingContent').append('<div id="divFileCallButlerlist" style="display:none;"></div>');
			}
		})
    }
    //切换页数
	this.changePage = function(pagenum){
		this.searchLogs(pagenum);
	}
	//设置最大条数
	this.setMaxEntriesPerPage = function(pagecount){
        var urlstring = 'module=Settings&action=SettingsAjax&file=CallRecordSetting&mode=setMaxEntriesPerPage';
        urlstring += '&selectpage=callrecordlogs';
		urlstring += '&pagecount='+pagecount;

		ldAjaxNoProgress('index.php?',urlstring,function(data){
			if(data.code==1){
				that.searchLogs();
			}
		})
	}
    // 播放
    this.playClick = function(sef,url){
        new Ajax.Request(
            'index.php',
            {queue: {position: 'end', scope: 'command'},
                method: 'post',
                postBody:'module=Users&action=UsersAjax&file=FileCheck&passUrl='+url+'&type=callbutler',
                onComplete: function(response) {
                    if(response.responseText.split("#########:#")[1]=='no')
                    {
                        var confirm_str = "录音文件不存在！";
                        MessagePopup.TipOne_warning(confirm_str);
                        return false;
                    }
                    else
                    {
                        var popupobj=CrmPopup.getPopupObj('last');
                        var div = document.getElementById('divFileCallButlerlist');
                        ld(div).css("display",'');
                        ld(div).css("position", "fixed");
                        ld(div).css("right", "50px");
                        ld(div).css("top", "125px");
                        ld(div).css("display", "flex");
                        ld(div).css("align-items", "center");
                        div.innerHTML='<audio controls id="audio_player" >  <source src="'+url+'" > </audio> <embed src="'+url+'" loop="0" autostart="true" hidden="true"></embed> ';
                        div.innerHTML+='<input style="display:none;" class="ld-button ld-button-primary" type="button" style="margin-bottom: 34px;" onclick="play_click.AudioStop(this)" value="关闭" />';
                        // div.innerHTML+='<input class="E_pbtnok" type="button" onclick="play_click.download(this)" value="下载" />';
                        //  div.innerHTML = '<embed src="'+url+'" loop="0" autostart="true" hidden="true"></embed>';
                        //  var emb = document.getElementsByTagName('EMBED')[0];
                        // if (emb) {
                            // window.location.href = emb.src;
                            audio_player.play();
                            //setTimeout(function(){div.innerHTML='';},1000);
                        //}
                    }
                }
            }
        );
        play_click.AudioStop=function(obj){
            audio_player.pause();
            var div = document.getElementById('divFileCallButlerlist');
            div.innerHTML='';
        }
    }
}
CallRecordSetting.curobj = '';
CallRecordSetting.getInstance=function(){
	if(!empty(CallRecordSetting.curobj)){
	}else{
		CallRecordSetting.curobj=new CallRecordSetting();
	}
    return CallRecordSetting.curobj;
}












