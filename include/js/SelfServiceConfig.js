ld(function () {
    SelfServiceConfig = {};
	//editor:gyq_104 reason:首页设置切换  2019/3/5 17:35
    SelfServiceConfig.bindtype = function(){
        var switchtype = ld('#weixinmp_switchtype').val();
        var bindtype = ld('#weixinmp_bindtype').val();
        if(switchtype==='Register'){
            ld('#phonefield_div').hide();
            ld('#setting_allowcreate').hide();
            ld('#setting_usecode').find("#useverificationcode").text(arrJsPopLabel['RegWhetherToUseCode']);
        }else{
            ld.ajax('index.php?module=Settings&action=SettingsAjax&file=SelfServiceConfig&from=bindtype&type=edit&ajax=true&bindtype='+bindtype)
                .done(function(response){
                    ld("#weixinmp_bindtype_phonefield").html(response);
                    ld('#phonefield_div').show();
                    ld('#setting_allowcreate').show();
                    ld('#setting_usecode').find("#useverificationcode").text(arrJsPopLabel['LoginWhetherToUseCode']);
                    // ld('#setting_allowcreate').find("input").prop("checked",true);
                    if(bindtype == "Accounts"){
                        ld('#setting_allowcreate').find("#allowcreatenew").text(arrJsPopLabel['WhetherAllowToCreateAccount']);
                    }
                    else{
                        ld('#setting_allowcreate').find("#allowcreatenew").text(arrJsPopLabel['WhetherAllowToCreateContact']);
                    }
                })
        }
        
    };
    //自助服务平台模块设置
	SelfServiceConfig.set_SelfConfig_Menu_Click = function(){
		ld("#selfconfig_field_create").unbind('click').bind('click',function(){
			var modulename = ld('#WeixinMpModule').val();
            var selftype = ld('#selftype').val();
			//BUG0065251：实现弹窗拖拽功能 2023-4-23  徐心玥
            var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth600px", 'Settings', "", "", "", "");
            crmPopupobj.prevshow();
            ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=SelfServiceConfig&from=field&type=edit&ajax=true&frommodule='+modulename+'&selftype='+selftype, "", function (data) {
                if (data.code == 1) {
                    crmPopupobj.setParams(data.result.title, SelfServiceConfig.SavefieldInfo, "", "LdPopWidth600px", 'Settings', "", data.result.oktext, "", data.result.canceltext, "");
                    crmPopupobj.show(data.result.content);
                    crmPopupobj.picklistvalues_arr = data.result.picklistvalues_arr;// 每个下拉框字段的选项值数组
                    // 设置内容最大高度
                    crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
                }
            })
		});
        ld("#selfconfig_listfield_create").unbind('click').bind('click',function(){
			var modulename = ld('#WeixinMpModule').val();
            var selftype = ld('#selftype').val();//自助小程序类型：服务、订单
		    //BUG0065251：实现弹窗拖拽功能 2023-4-23  徐心玥
            var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth600px", 'Settings', "", "", "", "");
            crmPopupobj.prevshow();
            ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=SelfServiceConfig&from=listfield&type=edit&ajax=true&frommodule='+modulename+'&selftype='+selftype, "", function (data) {
                if (data.code == 1) {
                    crmPopupobj.setParams(data.result.title, SelfServiceConfig.SaveListfieldInfo, "", "LdPopWidth600px", 'Settings', "", data.result.oktext, "", data.result.canceltext, "");
                    crmPopupobj.show(data.result.content);
                    // 设置内容最大高度
                    crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
                }
            })
		});
		ld('#WeixinMpModule').on('change',function(){
			var modulename = ld('#WeixinMpModule').val();
			ld.ajax('index.php?module=Settings&action=SettingsAjax&file=SelfServiceConfig&type=changemodule&frommodule='+modulename)
			.done(function(response){
                if(response.indexOf('$$$##$$$')>-1){
                    var ajaxhtml = response.split('$$$##$$$');
                    if(document.getElementById('MpModuleFields') != undefined){
                        document.getElementById('MpModuleFields').innerHTML = ajaxhtml[1];
                    }
                    if(document.getElementById('MpModuleListFields') != undefined){
                        document.getElementById('MpModuleListFields').innerHTML = ajaxhtml[2];
                    }
                    if(document.getElementById('MpModuleViewall') != undefined){
                        document.getElementById('MpModuleViewall').innerHTML = ajaxhtml[0];
                    }
                    //客户无列表字段设置
                    if(modulename=='Accounts'){
                        ld('#ModuleListFields').hide();
                    }else{
                        ld('#ModuleListFields').show();
                    }
                    SelfServiceConfig.movetable('moduledetail');
                }
			})
		});
        
        ld('#setsubmit').on('click',function(){
            var formData = new FormData();
            var modulename = ld('#WeixinMpModule').val();
            var viewall = ld('#viewall').is(':checked');
            var weixinmp_switchtype = ld('#weixinmp_switchtype').val();
            var weixinmp_bindtype = ld('#weixinmp_bindtype').val();
            var weixinmp_bindtype_phonefield = ld('#weixinmp_bindtype_phonefield').val();
            var weixinmp_bindtype_phonefield_frommodule = ld('#weixinmp_bindtype_phonefield').find('option:selected').attr('fieldfrom');
            var weixinmp_allowcreate = ld('#setting_allowcreate').find("input").is(":checked");
            var weixinmp_usecode = ld('#setting_usecode').find("input").is(":checked");
            // wsh 20240807 XUQIU20240725-02 服务小程序登录页设置--增加首页横幅图片设置
            var weiXinMp_banner_img =  ld("#setting_image").find("input[name=banner_img]").get(0).files[0];
            if(weiXinMp_banner_img && !empty(weiXinMp_banner_img)){
                if (weiXinMp_banner_img.type.startsWith('image/')) {
                    formData.append('weiXinMp_banner_img', weiXinMp_banner_img);
                }else {
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['FileFormatError']);
                    return;
                }
            }
            //editor:gyq_108 reason:订单小程序  2019/4/16 16:32
            var selftype = ld('#selftype').val();//自助小程序类型：服务、订单
            //editor:gyq_77 reason:客户服务单分配服务人员时，是否微信提醒最终客户 2018/8/24 15:35
            var weather_remind_contact = ld('#weather_remind_contact').prop('checked');
            viewall = viewall ? 'yes' : 'no';
            weixinmp_allowcreate = weixinmp_allowcreate ? 'yes' : 'no';
            weixinmp_usecode = weixinmp_usecode ? 'yes' : 'no';

            var smstemplateid='';
            if (weixinmp_usecode == 'yes' && ld("#setting_smstemplatelist").length>0) {//说明是阿里云短信需要选择短信模板  不启用就删掉
                smstemplateid = ld("#setting_smstemplatelist [name=smstemplatelist]").val();
                if (smstemplateid<1) {
                    MessagePopup.TipZero_warning(arrJsPopLabel['SELECTSMSTEMPLATES']);
                    return false;
                }
            }
            var surl = 'index.php?module=Settings&action=SettingsAjax&file=SelfServiceConfig&ajax=true&from=set' +
                '&frommodule=' + modulename + '&viewall=' + viewall + '&weixinmp_switchtype=' + weixinmp_switchtype + '&weixinmp_bindtype=' + weixinmp_bindtype + '&phonefield=' + weixinmp_bindtype_phonefield +
                '&weixinmp_allowcreate=' + weixinmp_allowcreate + '&weixinmp_usecode=' + weixinmp_usecode + '&weather_remind_contact=' + weather_remind_contact + '&selftype=' + selftype + '&phonefield_frommodule=' + weixinmp_bindtype_phonefield_frommodule + "&smstemplateid="+smstemplateid;
            ldAjax_File(surl, formData, function (data) {
                if (data.code == 1) {
                    var confirm_str = arrJsPopLabel['SUCCESSFULLYSAVED'];
                    // RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                    MessagePopup.TipOne_success(confirm_str);
                    //确定按钮
                    ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                        // @edit:liushuai,2021-04-21,reason: 0045533: （61mis.com/kfbcrm）系统设置-订单小程序设置，修改“小程序初始化首页设置”选项，保存后；界面小刷新显示了服务小程序的设置界面
                        SelfServiceConfig.refresh('login', selftype);
                    });
                }
                DelProgressObjs();
            })
        });


        if (ld("#setting_smstemplatelist").length>0) {
            ld('#setting_usecode [name=setting_usecode_checked]').on('click',function(){
                ld("#setting_smstemplatelist").toggle();
            });
        }


	}
    SelfServiceConfig.set_Save_SelfConfig_MainInfo = function(){
        ld("#fieldname").on('change',function(){
            var fieldnametext = ld('#fieldname').find("option:selected").text();
            ld('#fieldlabel').val(fieldnametext);
        })
        ld("#save_selfconfig_listfield").on('click',function(){
            var linenumber = ld('#linenumber').val();	//所在行
			var rownumber = ld('#rownumber').val();		//所在列
			var fieldname = ld('#fieldname').val();	//字段名称
			var frommodule = ld('#frommodule').val();
			var listfield_id = ld('#listfield_id').val();
			//字段名称不能为空
			if(empty(fieldname)){
				var mes = ld('#fieldname').attr('tag');
				var confirm_str = mes+arrJsPopLabel['CANOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
			var presence = ld("input[id='presence']").prop('checked')?0:1;
            var showtag = ld("input[id='showtag']").prop('checked')?0:1;
			ld.ajax('index.php?module=Settings&action=SettingsAjax&file=SelfServiceConfig&from=listfield&type=save&ajax=true&linenumber='+linenumber+'&rownumber='+rownumber+'&fieldname='+fieldname+'&presence='+presence+'&showtag='+showtag+'&frommodule='+frommodule+'&listfield_id='+listfield_id)
			.done(function(response){
			    if(response.indexOf('error') > -1){
                    RemindsMsg("","LdPopWidth400px","","yes","yes",'该位置已存在字段');
                    return false;
                }else{
    				fninvshnew('selfconfig_create');
    				document.getElementById('MpModuleListFields').innerHTML = response;
                }
			})
		});
		//取消
		ld("#cancel_selfconfig_maininfo,#colse_selfconfig_maininfo").on('click',function(){
			fninvshnew('selfconfig_create');
			return false;
		});
        ld("#cancel_selfconfig_module,#colse_selfconfig_module").on('click',function(){
			fninvshnew('selfconfig_module');
			return false;
		});
		//模块设置 - 保存
        ld('#save_selfconfig_module').on('click',function(){
            var mpentity = new Array();
            ld("#selfconfig_module_div tr[tag='module']").each(function(){
                var newentity = {};
                newentity.name = ld(this).find("input[tag='mplabel']").attr('name');
                newentity.value = ld(this).find("input[tag='mplabel']").val();
                newentity.en_value = ld(this).find("input[tag='mplabel_en']").val();
                mpentity.push(newentity);
            });
            var jsonentity = JSON.stringify(mpentity);
			var surl = 'index.php?module=Settings&action=SettingsAjax&file=SelfServiceConfig&from=module&type=save&ajax=true&jsonentity='+jsonentity;
		   ldAjax(surl,"",function(data){
				if(data.code==1){
					var confirm_str = arrJsPopLabel['SUCCESSFULLYSAVED'];
					// RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                    MessagePopup.TipOne_success(confirm_str);
					 //确定按钮
					ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
						SelfServiceConfig.refresh('module');
					});
				}
                DelProgressObjs();
			})
        });
	};
    //BUG0065251: 实现弹窗拖拽后，可以调用的新保存数据函数(okfun) 2023-4-23
    SelfServiceConfig.SavefieldInfo = function(){
        var popupobj = CrmPopup.getPopupObj('last');
        var fieldname = ld('#fieldname').val();	//字段名称
            var tabletype = ld('#fieldname').find("option:selected").attr("tabletype");
			var frommodule = ld('#frommodule').val();
			var field_id = ld('#field_id').val();
            var fieldlabel = ld('#fieldlabel').val();
            var fieldlabel_en = ld('#fieldlabel_en').val();
            var defaultvalue = ld('#defaultvalue').val();
            var displaytype = ld("input[name='displaytype']:checked").val();
            //zkt 20230428 BUG0065276 服务小程序----详情界面----服务人员，设置了新增界面不显示----但新增单据任然显示
            if(displaytype == undefined || displaytype == 'undefined'){
                displaytype = 'createno';
            }
            var typeofdata = ld("input[name='typeofdata']:checked").val();
            if(typeofdata == undefined || typeofdata == 'undefined'){
                typeofdata = 'o';
            }
			//字段名称不能为空
			if(empty(fieldname)||empty(fieldlabel)){
				var mes = ld('#fieldname').attr('tag');
				var confirm_str = mes+arrJsPopLabel['CANOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			}
			/*editor:gyq_95 reason:微信自助平台小程序扫码绑定  2018/12/27 9:45 */
            /*
			if(fieldname==='assigned_user_id'){
                if(defaultvalue.length === 0){
                    var confirm_str = arrJsPopLabel['REMINDDEFAULTVALUEFORSERVER']+'!';
                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                    return false;
                }
            }*/
        var url = 'module=Settings&action=SettingsAjax&file=SelfServiceConfig&from=field&type=save&ajax=true&fieldlabel='+fieldlabel+'&fieldlabel_en='+fieldlabel_en;
        url +='&fieldname='+fieldname+'&tabletype='+tabletype+'&displaytype='+displaytype+'&typeofdata='+typeofdata+'&defaultvalue='+defaultvalue+'&frommodule='+frommodule+'&field_id='+field_id;
        ldAjaxHtml('index.php?',url,function (response) {
            if(response.indexOf('error') > -1){
                RemindsMsg("","LdPopWidth400px","","yes","yes",'已存在字段：'+ld('#fieldname').find("option:selected").text());
                return false;
            }
            else if (response.indexOf('Display at least one field') > -1) {
                //BUG20240716-46 wsh 2024-08-06 后台设置->服务小程序->列表定制，将所有字段设置为不显示，移动端服务小程序只显示一行空白（服务小程序中的“详情定制”也有这个问题，应改为至少一个字段的“是否显示”按钮为开启状态
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", "至少显示一个字段");
                return false;
            }else{
                popupobj.CancelEvent();
                ld('#MpModuleFields').html(response);
                getJsScript('include/js/SelfServiceConfig.js',function (){
                    SelfServiceConfig.movetable('module');
                });
            }
            DelProgressObjs();
        });

    };
    SelfServiceConfig.SavefieldInfo.funname='SelfServiceConfig.SavefieldInfo';
    SelfServiceConfig.SaveListfieldInfo = function(){
        var popupobj = CrmPopup.getPopupObj('last');
        var linenumber = ld('#linenumber').val();	//所在行
        var rownumber = ld('#rownumber').val();		//所在列
        var fieldname = ld('#fieldname').val();	//字段名称
        var frommodule = ld('#frommodule').val();
        var listfield_id = ld('#listfield_id').val();
        //字段名称不能为空
        if(empty(fieldname)){
            var mes = ld('#fieldname').attr('tag');
            var confirm_str = mes+arrJsPopLabel['CANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
        var presence = ld("input[id='presence']").prop('checked')?0:1;
        var showtag = ld("input[id='showtag']").prop('checked')?0:1;
        var url = 'module=Settings&action=SettingsAjax&file=SelfServiceConfig&from=listfield&type=save&ajax=true&linenumber='+linenumber+'&rownumber='+rownumber
                    +'&fieldname='+fieldname+'&presence='+presence+'&showtag='+showtag+'&frommodule='+frommodule+'&listfield_id='+listfield_id;
        ldAjaxHtml('index.php?',url,function (response) {
            if(response.indexOf('error') > -1){
                MessagePopup.TipOne_warning('第'+linenumber+'行第'+rownumber+'列，该位置已存在字段');
                return false;
            }
            else if (response.indexOf('Display at least one field') > -1) {
                //BUG20240716-46 wsh 2024-08-06 后台设置->服务小程序->列表定制，将所有字段设置为不显示，移动端服务小程序只显示一行空白（服务小程序中的“详情定制”也有这个问题，应改为至少一个字段的“是否显示”按钮为开启状态
                MessagePopup.TipOne_warning("至少显示一个字段");
                return false;
            }else{
                fninvshnew('selfconfig_create');
                popupobj.CancelEvent();
                document.getElementById('MpModuleListFields').innerHTML = response;
            }
            DelProgressObjs();
        });


    }
	//刷新
	SelfServiceConfig.refresh = function(step,selftype){
	   if(typeof selftype=='undefined'||selftype==undefined)
       {
            selftype='service';

       }
		var surl = 'index.php?module=Settings&action=SelfServiceConfig&parenttab=Settings&selftype='+selftype+'&step='+step+'&ReportHeader=dheader';
        ldAjax(surl,"",function(data){
			if(data.code==1){
				ld(' [name=SettingRightContent]').html(data.result.content);

			}
            DelProgressObjs();
		})
	}

    //自助服务平台模块设置
    SelfServiceConfig.set_Save_SelfConfig_Module = function(){
		ld.ajax('index.php?module=Settings&action=SettingsAjax&file=SelfServiceConfig&from=module&type=edit&ajax=true')
		.done(function(response){
			//alert(response);
			$('selfconfig_module_div').innerHTML=response;
			fnvshobj(this, 'selfconfig_module');
			SelfServiceConfig.set_Save_SelfConfig_MainInfo();
            SelfServiceConfig.set_deleteextratag();
		})
    };

    //清除第一行的向上移动和最后一行的向下移动图标
    SelfServiceConfig.set_deleteextratag = function(){
        ld("#selfconfig_module_div tr[tag='module']").first().find('.category-sup').hide();
        ld("#selfconfig_module_div tr[tag='module']").last().find('.category-sdown').hide();
    };

    //向上向下移动
    SelfServiceConfig.set_moveupmodule = function(obj,type){
        ld("#selfconfig_module_div tr[tag='module']").first().find('.category-sup').show();
        ld("#selfconfig_module_div tr[tag='module']").last().find('.category-sdown').show();
        var boforeval = ld(obj).parent().prev().prev().find('input').val();
        var mhtml = ld(obj).parent().parent().html();
        var trhtml = "<tr tag='module' class='lvtColData'>"+mhtml+"</tr>";
        if(type=='up'){
            ld(obj).parent().parent().prev().before(trhtml);
            //ld(obj).parent().parent().prev().prev().find('input').val(boforeval);
        }else{
            ld(obj).parent().parent().next().after(trhtml);
            //ld(obj).parent().parent().next().next().find('input').val(boforeval);
        }
        ld(obj).parent().parent().remove();
        //editor:gyq_20191104 reason:初始化首尾按钮
        //0038389: （1.6）系统设置>服务小程序设置、订单小程序设置>模块设置>操作列：第一行的【上移】按钮应该去掉，第二行的【下移】按钮应该去掉。
        var trLength = ld('#selfconfig_module_div').find('tr[tag="module"]').length;
        ld.each(ld('#selfconfig_module_div').find('tr[tag="module"]'),function (i) {
            if(i===0){
                ld(this).find('a[tag="move_up"]').hide();
                ld(this).find('a[tag="move_down"]').show();
            }else if(i+1===trLength){
                ld(this).find('a[tag="move_up"]').show();
                ld(this).find('a[tag="move_down"]').hide();
            }else{
                ld(this).find('a[tag="move_up"]').show();
                ld(this).find('a[tag="move_down"]').show();
            }
            ld(this).find('td').eq(0).html(i+1);
        });
        //ld(obj).parent().parent().prev().prev().find('input').val(boforeval);
        SelfServiceConfig.set_deleteextratag();
    };


    //拖拽功能实现	BUG0075330	后台设置--服务小程序设置--模块设置--服务小程序模块设置--排序方式修改为拖拽排序
    SelfServiceConfig.movetable = function (type) {
        ld('[name=selfServiceModuleConfig] tr').hover(function(){
            ld('.ld-dragicon').hide();
            ld(this).find('.ld-dragicon').show();
        });
        var dragobj = ld("table[name=selfServiceModuleConfig]").find("tbody").get(0);
        if(dragobj && !empty(dragobj)){
            Sortable.create(dragobj, {
                group: 'SelfServiceConfig',
                animation: 150,
                draggable: ".ld-category-draggable",
                handle: ".drag-handle",
                onEnd: function (evt){
                    var sortfield_arr='', fieldid;
                    tableobj = ld('table[name=selfServiceModuleConfig]').find("tr");
                    tableobj.attr('onmouseover','');
                    tableobj.attr('onmouseout','');
                    tableobj.removeClass('lvtColData');
                    tableobj.removeClass('lvtColDataBj');
                    tableobj.removeClass('lvtColDataHover');
                    ld.each(tableobj,function(index,tmpobj){
                        if(index>0){
                            if(index%2==0){
                                ld(tmpobj).addClass('lvtColDataBj');
                                ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                                ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"On")');
                                fieldid=ld(tmpobj).attr('tagid');
                                sortfield_arr+=fieldid+",";
                                if(type != 'moduledetail'){
                                    ld(tmpobj.childNodes[1]).html(index);
                                }
                            }else{
                                ld(tmpobj).addClass('lvtColData');
                                ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                                ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
                                fieldid=ld(tmpobj).attr('tagid');
                                sortfield_arr+=fieldid+",";
                                if(type != 'moduledetail'){
                                    ld(tmpobj.childNodes[1]).html(index);
                                }
                            }
                        }
                    });
                    if (sortfield_arr != '') {
                        if(type == 'moduledetail'){
                            var update_url='index.php?module=Settings&action=SettingsAjax&file=SelfServiceConfig&type=saveModuledetailSet&ajax=true&tagids='+sortfield_arr;
                            ldAjax(update_url, '', function (data) {
                                if (data.code == 1) {
                                    DelProgressObjs();
                                }
                            })
                        }else{
                            var update_url='index.php?module=Settings&action=SettingsAjax&file=SelfServiceConfig&type=saveModuleSet&ajax=true&tagids='+sortfield_arr;
                            ldAjax(update_url, '', function (data) {
                                if (data.code == 1) {
                                    DelProgressObjs();
                                }
                            })
                        }
                    }
                }
            })
        }
    }


    //启用和停用
    SelfServiceConfig.set_ActiveOrInactive = function(moduleid,obj){
        ld.ajax('index.php?module=Settings&action=SettingsAjax&file=SelfServiceConfig&from=module&type=active&ajax=true&moduleid='+moduleid)
		.done(function(response){
			if(response.indexOf('##')>-1){
                //duan 2022-2-15 按钮样式修改
			}
		})
    }
    //选择用户
    SelfServiceConfig.set_choose_user = function(id){
        var module = 'Home';
    	var popup_caption_value = arrJsPopLabel['SELECT']+arrJsPopLabel['LBL_USERS'];
        var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=radio&popup_selecttype=user';
    	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
    		var methodObj = {'popup_check_inactiveuser':'yes'};
    		scopepopupobj =  new ScopePopupObj(methodObj);
            scopepopupobj.popup_caption_value = popup_caption_value;//标题title
    		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
    		   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
               cls_ScopePopup.prop.popup_module = module;//模块
    		   cls_ScopePopup.prop.popup_value = id;
    		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
    		    //重写确认按钮事件
                ld('#'+cls_ScopePopup.popup_divid).css('z-index',10001);
                ld('#'+cls_ScopePopup.popup_divid+'_olayernodeid').css('z-index',10000);
                scopepopupobj.setEventBtnOk=function(){
                    ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                        //没有选择任何用户，则给出提示
                        if(empty(cls_ScopePopup.return_obj.return_id)){
                            var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                            RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
                            return false;
                        }else{
                            var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                            var selected_name = cls_ScopePopup.return_obj.return_name;
    						ld('#defaultvalue').val(selected_user);
                            ld('#selectusername').val(selected_name);
    						//ld('#'+cls_ScopePopup.popup_divid).hide();
                            ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                        }
                    });
                }
    			// scopepopupobj.setEventBtnCancel=function(){
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
    					//ld('#'+cls_ScopePopup.popup_divid).hide();
    				});
    				return true;
    			// }
    		});
    	});
    }
    /*editor:gyq_74 date:20180730 reason:优化自助服务平台设置代码*/
    SelfServiceConfig.changeMpField = function(){
        var popupobj = CrmPopup.getPopupObj('last');
        var fieldname = ld("#"+popupobj.divid).find('#fieldname').val();
        var show_type_json = ld("#"+popupobj.divid).find('#fieldname').find("option:selected").attr("show_type");
        var reg = new RegExp('##',"g"); //定义正则表达式
        var show_type_obj =ld.parseJSON(show_type_json.replace(reg, '"')); //第一个参数是正则表达式。
        if(show_type_obj.show===1){
            ld('input[name="displaytype"]').prop('checked',true);
        }else{
            ld('input[name="displaytype"]').prop('checked',false);
        }
        if(show_type_obj.mandatory===1){
            ld('input[name="typeofdata"]').prop('checked',true);
        }else{
            ld('input[name="typeofdata"]').prop('checked',false);
        }
        if(show_type_obj.show_edit===1){
            ld('input[name="displaytype"]').removeAttr('disabled').prop('disabled',false);
        }else{
            ld('input[name="displaytype"]').removeAttr('disabled').prop('disabled',true);
        }
        if(show_type_obj.mandatory_edit===1){
            ld('input[name="typeofdata"]').removeAttr('disabled').prop('disabled',false);
        }else{
            ld('input[name="typeofdata"]').removeAttr('disabled').prop('disabled',true);
        }
        if(show_type_obj.default===1){
            ld('#defaultvalue').removeAttr('disabled').prop('disabled',false);
        }else{
            ld('#defaultvalue').removeAttr('disabled').prop('disabled',true);
        }
        var tdobj = ld("#"+popupobj.divid).find('#defaultvalue').parents('td:first');
        tdobj.html(`<input id="defaultvalue" type="text" class="ld-input-inner" name="defaultvalue" value="" />`);
        ld("#"+popupobj.divid).find('#defaultvalue').val(show_type_obj.default_value);
        if(show_type_obj.uitype==='53'){
            ld('#defaultvalue').hide();
            ld('#selectusername').show();
            ld('#selectusername_click').show();
            ld('#clearusername_click').show();
        }else if(show_type_obj.bigtype == 'picklist'){// 下拉框字段
            if(!empty(popupobj.picklistvalues_arr)){
                var picklistvalues = popupobj.picklistvalues_arr[fieldname];
                var selecthtml = `<select class="ld-select-inner" id="defaultvalue" name="defaultvalue">`;
                ld.each(picklistvalues, function(vkey, picklistvalue) {
                    if(vkey == show_type_obj.default_value)
                        selecthtml += `<option value="`+vkey+`" selected >`+picklistvalue+`</option>`;                    
                    else
                        selecthtml += `<option value="`+vkey+`">`+picklistvalue+`</option>`;
                });
                selecthtml += `</select>`;
                tdobj.html(selecthtml);
            }
        }else{
            ld('#defaultvalue').show();
            ld('#selectusername').hide();
            ld('#selectusername_click').hide();
            //editor:gyq_95 reason:微信自助平台小程序扫码绑定  2018/12/26 16:53 
            ld('#clearusername_click').hide();
        }
        return false;
    }
    /*editor:gyq_95 reason:微信自助平台小程序扫码绑定  2018/12/27 9:41 */
    SelfServiceConfig.clearusername = function(){
        ld('#selectusername').val('');
        ld('#defaultvalue').val('');
    }
    SelfServiceConfig.set_SelfConfig_Menu_Click();
    /*editor:gyq_104 reason:小程序设置优化  2019/3/5 17:00 */
    SelfServiceConfig.set_Save_SelfConfig_MainInfo();
    var instance;
    var _static = {
        getInstance: function () {
            if (instance === undefined) {
                instance = new entrance();
            }

            return instance;
        }
    };
    return _static;
});

function fun_selfservice_config(){
	fun_selfservice_config.cur_obj=null;
}

fun_selfservice_config.getInstance=function(field_id){
    if(fun_selfservice_config.cur_obj==null){
        fun_selfservice_config.cur_obj=new fun_selfservice_config();
    }
    fun_selfservice_config.mobile_field_id = field_id;
    var modulename = ld('#WeixinMpModule').val();
    fun_selfservice_config.fieldurl = 'index.php?module=Settings&action=SettingsAjax&file=SelfServiceConfig&from=field&ajax=true&field_id='+field_id+'&frommodule='+modulename;
    fun_selfservice_config.listfieldurl = 'index.php?module=Settings&action=SettingsAjax&file=SelfServiceConfig&from=listfield&ajax=true&listfield_id='+field_id+'&frommodule='+modulename;
    return fun_selfservice_config.cur_obj;
}


//编辑
fun_selfservice_config.prototype.ssc_field_edit = function(){
    //BUG0065251：实现弹窗拖拽功能 2023-4-23 徐心玥
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
    ldAjaxNoProgress(fun_selfservice_config.fieldurl+'&type=edit',"",function(data){
        if(data.code==1){
            crmPopupobj.setParams(data.result.title,SelfServiceConfig.SavefieldInfo,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
            // SelfServiceConfig.changeMpField();
            crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
        }
    })
}
//删除
fun_selfservice_config.prototype.ssc_field_delete = function(){
    var str = arrJsPopLabel['SUREWANTDELETE'];
	RemindsMsg("","LdPopWidth400px","","yes","yes",str);
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
    	ld.ajax(fun_selfservice_config.fieldurl+'&type=delete')
    	.done(function(response){
             if(response.indexOf('$$$##$$$')>-1){
                var ajaxhtml = response.split('$$$##$$$');
                /*editor:gyq_20190531 reason:列表明细设置界面拆分后，这段没有改到*/
                //document.getElementById('MpModuleViewall').innerHTML = ajaxhtml[0];
                document.getElementById('MpModuleFields').innerHTML = ajaxhtml[1];
                //document.getElementById('MpModuleListFields').innerHTML = ajaxhtml[2];
                SelfServiceConfig.movetable('moduledetail');
            }
    	})
     });
}
//上移
fun_selfservice_config.prototype.ssc_field_moveup = function(){
    ld.ajax(fun_selfservice_config.fieldurl+'&type=moveup')
	.done(function(response){

		 document.getElementById('MpModuleFields').innerHTML = response;
	})
}
//下移
fun_selfservice_config.prototype.ssc_field_movedown = function(){
    ld.ajax(fun_selfservice_config.fieldurl+'&type=movedown')
	.done(function(response){

		 document.getElementById('MpModuleFields').innerHTML = response;
	})
}
//列表字段
//编辑
fun_selfservice_config.prototype.ssc_listfield_edit = function(){
//BUG0065251：实现弹窗拖拽功能 2023-4-23  徐心玥
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
    ldAjaxNoProgress(fun_selfservice_config.listfieldurl+'&type=edit',"",function(data){
        if(data.code==1){
            crmPopupobj.setParams(data.result.title,SelfServiceConfig.SaveListfieldInfo,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
            crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
        }
    })
}
//删除
fun_selfservice_config.prototype.ssc_listfield_delete = function(){
    var str = arrJsPopLabel['SUREWANTDELETE'];
	RemindsMsg("","LdPopWidth400px","","yes","yes",str);
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
    	ld.ajax(fun_selfservice_config.listfieldurl+'&type=delete')
    	.done(function(response){

    		 document.getElementById('MpModuleListFields').innerHTML = response;
    	})
     });
}