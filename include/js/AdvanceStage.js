function AdvanceStage(){
   var refershtype = 'detail';
   var that=this;
   this.ue = '';
   this.init=function(module,record){
       this.module = module;
       this.record = record;
       AdvanceStage.record = record;
       AdvanceStage.module = module;
   }
   //保存必填字段的字段值
   this.SaveFieldValue = function(type){
        var popupobj = CrmPopup.getPopupObj('last');
        if(empty(type)){
            type = 'push';
        }
        //限制在任务区块中获取内容
        var fieldtask_num = ld("#"+popupobj.divid+" #AllTaskvalue [name=fieldtask_num]").val();
        //如果没有必填字段任务直接推进
        if(empty(fieldtask_num)||fieldtask_num ==0){
            if(type == 'push'){
                that.NewCheckSave();
            }
            return false;
        }
        var divid = 'AllTaskvalue';
        var tmpurl = '';
        //获取富文本框控件的值
        if(popupobj.ueditor_fieldname_arr != undefined && popupobj.ueditor_fieldname_arr.length>0){
            for(var i=0;i<popupobj.ueditor_fieldname_arr.length;i++){
                var tmpfieldname = popupobj.ueditor_fieldname_arr[i];
                var tmpfieldname_new = tmpfieldname+'_new';
                var fieldobj = CrmPopup.findHtmlobj(popupobj.popupdivid +' #'+divid,tmpfieldname_new);
                if(fieldobj.length>0){
                    var tmpokeditor = popupobj.oCKeditors[tmpfieldname_new];
                    fieldobj.attr('name',tmpfieldname);
                    fieldobj.attr('id',tmpfieldname);
                    fieldobj.html(tmpokeditor.getContent());
                }
            }
        }
        popupobj.divid = divid;
        
        if(popupobj.advancefields != undefined && popupobj.advancefields.length>0){
            var advancefields_arr = popupobj.advancefields;
            var tmp_field = {};
            for (i=0;i<advancefields_arr.length;i++){
                tmp_field = advancefields_arr[i];
                var typedata = tmp_field.typeofdata.split("~");
                var tmpobj = ld("#"+popupobj.divid+" [name=AllTaskvalue][name="+tmp_field.fieldname+"]");
                if (typedata[1] == "M") {
                    if (!emptyCheck(tmp_field.fieldname, tmp_field.fieldlabel, tmpobj.attr("type"))){
                        popupobj.divid = popupobj.popupdivid;
                        return false;
                    }

                }
            }
            //获取页面上所有的字段值
            tmpurl += SaveDataRecord.getFieldValue(popupobj,advancefields_arr,'');
        }
        
        AdvanceStage.reset_pupupobj_divid(popupobj);
        if (popupobj.module == 'Accounts' || popupobj.module == 'ServiceCharge') {
            tmpurl += '&contactid=' + CrmPopup.getHtmlobjval(popupobj.popupdivid, 'contact_id');
            tmpurl += '&lastname=' + CrmPopup.getHtmlobjval(popupobj.popupdivid, 'lastname');
        }
        // 销售线索，保存失败原因
        if (popupobj.module == 'Leads' && popupobj.advancedata.module_advacne.module_field == 'status') {
            var mapmodule = ld("#"+popupobj.divid).find("[name=next_mapmodule]").val();
            if(mapmodule == 'close'){
                tmpurl += '&failurereason=' + encodeURIComponent(ld("#"+popupobj.divid).find("[name=fileurereason]").val());
            }
        }
        //hzx BUG0062845 推进保存 字段属性“不允许重复”,“严格11位手机号码格式 ”不生效
        var tmp_fields = popupobj.fields;
        popupobj.fields = popupobj.advancefields;
        if(doformValidation('')){ //字段验证
            popupobj.fields = tmp_fields;
            popupobj.divid = popupobj.popupdivid;
            //为了避免和新建、编辑页面的富文本框控件名称冲突，将fieldname加上_new后缀
            if(popupobj.ueditor_fieldname_arr != undefined && popupobj.ueditor_fieldname_arr.length>0){
                for(var i=0;i<popupobj.ueditor_fieldname_arr.length;i++){
                    var tmpfieldname = popupobj.ueditor_fieldname_arr[i];
                    var tmpfieldname_new = tmpfieldname+'_new';
                    var fieldobj = CrmPopup.findHtmlobj(popupobj.popupdivid +' #'+divid,tmpfieldname);
                    if(fieldobj.length>0){
                        fieldobj.attr('name',tmpfieldname_new);
                        fieldobj.attr('id',tmpfieldname_new);
                    }
                }
            }
            var con = true;
            //duan 20240611 修改后需要判断是否重置审批状态,调整提示框
            con = validatasave.checkResetApprove(popupobj,that.record,that.module,function () {
                that.SaveFieldValue(type);
            });
            if (!con) {
               return '';
            }

			validatasave.CheckAllowSavePhpRule(that.module,that.record,tmpurl).then(result => {
				var con = result;
				if(!con){
					return '';
				}

				var surl = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=SaveAdvanceFieldValue';
				surl += '&record='+that.record+'&type='+type;
				ldAjax(surl,tmpurl,function(data){
					DelProgressObjs();
					if(data.code == 1){
						if(type == 'push'){
							that.NewCheckSave();
						}else{
							if(popupobj.pagetype == 'advancepopup'){
								popupobj.CancelEvent();
							}
							that.NewRefresh(data);
							// audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['SUCCESSFULLYSAVED']);
							MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYSAVED']);
						}
					}else if(data.code == -2){

                        if(!empty(data.result) && data.result.info == 'fieldrule'){
                            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                            var remindpopupobj = CrmPopup.getPopupObj("last");
                            //点击确认
                            //借用一下审批那边的转化url的函数
                            AjaxJSPage('cls_approve_mandatoryfield_js','include/js/modules/Approve/cls_approve_mandatoryfield.js');
                            var advancefield_json = cls_approve_mandatoryfield.transFieldValue(tmpurl);

                            ld('#'+remindpopupobj.divid+'_btnok').unbind('click').on('click',function(){
                                var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",popupobj.module,"","","","",popupobj.record);
                                Popupobj.prevshow();
                                PageRecordPopup.params['refreshpage']='no';
                                PageRecordPopup.params['miniedit_fieldrule']='fromadvance';

                                var tmpurl = '&miniedit_fieldrule=fromadvance';
                                if(!empty(advancefield_json)){
                                    tmpurl += '&fieldvaluejson='+advancefield_json;
                                }
                                Popupobj.addOtherSaveUrl = function () {
                                    return tmpurl;
                                }

                                PageRecordPopup.showpage(popupobj.module,popupobj.record,tmpurl,PageRecordPopup.params);

                            });
                        }else{
                            RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
                        }
					}else{
                        RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
                    }
				})

			})
       }

       popupobj.divid = popupobj.popupdivid;
       popupobj.fields = tmp_fields;
   }
   //切换追踪阶段
   this.ChangeAdvanceStage = function(obj){
        //调整其他阶段样式
        var popupobj = CrmPopup.getPopupObj('last');
        var prevpopupobj = CrmPopup.getPopupObj("lastprev");
        //获取当前字段值传到后台用于布局规则判断和显示字段值
        var tmpurl = '';
        if(popupobj.advancefields != undefined && popupobj.advancefields.length > 0){
            var tmpdivid = popupobj.popupdivid+' #AllTaskvalue';
            popupobj.divid = tmpdivid;
            //获取页面上所有的字段值
            tmpurl += SaveDataRecord.getFieldValue(popupobj,popupobj.advancefields,'');
        }
        var inpopup = 'yes';
        AdvanceStage.reset_pupupobj_divid(popupobj);
        if(popupobj.pagetype =='detailview_modulepage'){
            ld("#"+popupobj.divid+' #task .module-tagger-fm-button').css('color','#666666');
            ld("#"+popupobj.divid+' #task .module-tagger-fm-button').css('border-color','#DCDFE6');
            ld(obj).css('color','#3B7CFF');
            ld(obj).css('border-color','#3B7CFF');
            ld("#"+popupobj.divid+" [class=icon-choosed]").hide();
            ld(obj).parent().find('b').css('display','');
            var advanceid = ld(obj).attr('advanceid');
            var stagename = ld(obj).attr('stagename');
            var mapmodule = ld(obj).attr('data-mapmodule');
            inpopup = 'no';
        }else{
            var advanceid = ld(obj).find("option:selected").attr('advanceid');
            var stagename = ld(obj).val();
            var mapmodule = ld(obj).find("option:selected").attr('data-mapmodule');
        }
        
        var surl = 'index.php?module='+this.module+'&action='+this.module+'Ajax&file=getAdvanceTaskinfo';
        surl += '&record='+this.record+'&advanceid='+advanceid+'&inpopup='+inpopup;

        //借用一下审批那边的转化url的函数
        AjaxJSPage('cls_approve_mandatoryfield_js','include/js/modules/Approve/cls_approve_mandatoryfield.js');
        var param = {};
        param['requestvalue'] = cls_approve_mandatoryfield.transFieldValue(tmpurl);

        ldAjax(surl,param,function(data){
            DelProgressObjs();
            if(data.code == 1){
                ld("#"+popupobj.divid+" [name=AllTaskvalue]").html(data.result.content);
                var advancedata = data.result.advancedata;
                if(!empty(advancedata)) {
                    //如果自动化任务中设置了附件字段，则需要获取附件信息
                    if (advancedata.filejsondata != undefined) {
                        popupobj.filejsondata = advancedata.filejsondata;
                    }
                    if (advancedata.advancefields != undefined) {
                        popupobj.advancefields = advancedata.advancefields;
                    }
                    popupobj.advancedata = advancedata;
                }
                if(popupobj.pagetype == 'detailview_modulepage' || prevpopupobj.pagetype == 'detailview_modulepage'){
                    //crmPopupobj.picklist_arrow_click = prevpopupobj.picklist_arrow_click;
                    //crmPopupobj.picklist_end_foucs = prevpopupobj.picklist_end_foucs;
                    //crmPopupobj.picklistobjarray = prevpopupobj.picklistobjarray;
                }else{
                    popupobj = AdvanceStage.initpicklist(popupobj,data.result);
                }
                AdvanceStage.advance_load_tipevent();
                if(popupobj.pagetype =='detailview_modulepage'){
                    ld("#"+popupobj.divid+" [name=next_advanceid]").val(advanceid);
                    ld("#"+popupobj.divid+" [name=next_stagename]").val(stagename);
                    ld("#"+popupobj.divid+" [name=next_mapmodule]").val(mapmodule);
                }
                
                if(that.module=='Leads' && mapmodule=='close')  // wym XUQIU20240204-09 销售线索可编辑追踪字段
                {
                    ld("#"+popupobj.divid).find("[name=fileurereason_tr]").show();
                    ld("#"+popupobj.divid).find("[name=fileurereason]").val(advancedata.failurereason);
                }
                else if(that.module=='Leads')
                {
                    ld("#"+popupobj.divid+" [name=fileurereason_tr]").hide();
                }
                // wym XUQIU20240204-09 销售线索可编辑追踪字段
                if(!empty(mapmodule) && mapmodule!='close'){
            		ld("#"+popupobj.divid+" #advance_stage_upgrade").show();
            	}else{
            		ld("#"+popupobj.divid+" #advance_stage_upgrade").hide();
                }
            }else if(data.code == -1){
                RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
            }
        })
   }
   this.ShowAdvanceDetail = function(stagename){
        var surl = 'index.php?module='+this.module+'&action='+this.module+'Ajax&file=ShowAdvanceDetail';
        surl += '&record='+this.record;
        var param = {};
        param['stagename'] = stagename;
       var prev_popupobj = CrmPopup.getPopupObj('last');
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	    crmPopupobj.prevshow();
        ldAjax(surl,param,function(data){
        	if(data.code==1){
        		crmPopupobj.setParams(data.result.title,crmPopupobj.CancelEvent,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");  
        		crmPopupobj.show(data.result.content);

                var showstaytimecontentobj = ld('#'+prev_popupobj.divid+' [name=showstaytimecontent][stagename="'+stagename+'"]');
                if(showstaytimecontentobj.length>0){
                    showstaytimecontentobj.html(data.result.showstaytimecontent);
                }
                //判断是否需要显示创建单据的显示隐藏按钮
                AdvanceStage.showchangestatusbtn(crmPopupobj);
                // var tmpdivid=crmPopupobj.divid;
                // var tableobj= ld("#"+tmpdivid+" table[name=advancetask]");
                // var tdobjs = ld(tableobj).find('td');
                // var trobjs = ld(tableobj).find('tr');
                // tdobjs.removeAttr('class');
                // tdobjs.css('text-align','left');
                // tdobjs.attr('width','');
                // tdobjs.css('height','25px');
                // tdobjs.css('font-size','13px');
                // trobjs.css('height','25px');
        	}else if(data.code == -1){
                RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
        	}
        })
   }
   
   //点击推进后直接保存，不再显示推进选项
   //判断任务是否完成以及是否可以推进
   this.NewCheckSave = function(){
        var record = this.record;
        var module = this.module;
        //获取下一状态的值
        var popupobj=CrmPopup.getPopupObj("last");
    	if(popupobj.pagetype =='detailview_modulepage'){
            var advance_stage_value = ld("#"+popupobj.popupdivid+" [name=next_stagename]").val();
            if(empty(advance_stage_value)||advance_stage_value == undefined){
                RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['PLEASECHOOSENEXTSTAGE']+'!');
                return false;
            }
        }else{
            var advance_stage_type = ld("#"+popupobj.popupdivid+" [name=advance_stage_type]:checked").val();
        	var advance_stage_value = '';
            var mapmodule='';
        	if(advance_stage_type == 'next'){
        		advance_stage_value = ld("#"+popupobj.popupdivid+" [name=next_advance_stage]").val();
        	}else{
        		advance_stage_value = ld("#"+popupobj.popupdivid+" [name=specified_advance_stage]").val();
        	}
            if(empty(advance_stage_value)||advance_stage_value == undefined){
                RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['PLEASECHOOSENEXTSTAGE']+'!');
                return false;
            }
        }
        var pushcheck = 'yes';
        var url = "index.php?module="+module+"&action="+module+"Ajax&file=Taskprogress";
        url += "&record="+record +"&modulename="+module+"&pushcheck="+pushcheck+"&stagename_target="+encodeURIComponent(advance_stage_value)+"&mapmodule="+encodeURIComponent(mapmodule);
        ldAjax(url,'',function(data){
            if(data.code==1){
                if(data.result.allow_push == 'no'){
                    if(!empty(data.result.return_msg)){
                        var confirm_str = data.result.return_msg;
                    }else{
                        var confirm_str = arrJsPopLabel['CANNOTMOVEBEFORECOMPLETE'];
                    }

                    MessagePopup.TipOne_warning(confirm_str);
                    return false;
                }else{
                    if(data.result.confirm_save == 'yes'){
                        var confirm_str = data.result.return_msg;
                        MessagePopup.TipTwo_warning(confirm_str);
                        var popupobj=CrmPopup.getPopupObj('last');
                        ld('#'+popupobj.divid+' input[tagclick="msgConfirm"]').on('click', function () {
                            that.NewAdvanceSave();
                        });
                    }else{
                        that.NewAdvanceSave();
                    }
                }
            }
            DelProgressObjs();
        });
   }
   //推进并保存
   this.NewAdvanceSave = function(){
        var popupobj=CrmPopup.getPopupObj("last");
        var btnobj = ld('#'+popupobj.divid).find('#saveandpushbutton');
        if(btnobj.attr('isadvancing') == 'yes' || (popupobj.divid).indexOf('remindmsg') != -1){// 2024-6-24 xxy 防止重复点击
            return;
        }
        btnobj.attr('isadvancing','yes');
        AdvanceStage.reset_pupupobj_divid(popupobj);
        if(popupobj.pagetype =='detailview_modulepage'){
            var advance_stage_value = ld("#"+popupobj.popupdivid+" [name=next_stagename]").val();
            var mapmodule = ld("#"+popupobj.popupdivid+" [name=next_mapmodule]").val();
            if(empty(advance_stage_value)||advance_stage_value == undefined){
                RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['PLEASECHOOSENEXTSTAGE']+'!');
                btnobj.removeAttr('isadvancing');
                return false;
            }
        }else{
            var advance_stage_type = ld("#"+popupobj.divid+" [name=advance_stage_type]:checked").val();
        	var advance_stage_value = '';
            var mapmodule = '';
        	if(advance_stage_type == 'next'){
        		advance_stage_value = ld("#"+popupobj.divid+" [name=next_advance_stage]").val();
                mapmodule = ld("#"+popupobj.popupdivid+" [name=next_advance_stage]").find("option:selected").attr('data-mapmodule');
        	}else{
        		advance_stage_value = ld("#"+popupobj.divid+" [name=specified_advance_stage]").val();
                mapmodule = ld("#"+popupobj.popupdivid+" [name=specified_advance_stage]").find("option:selected").attr('data-mapmodule');
        	}
            if(empty(advance_stage_value)||advance_stage_value == undefined){
                RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['PLEASECHOOSENEXTSTAGE']+'!');
                btnobj.removeAttr('isadvancing');
                return false;
            }
        }
    	//chj 2021/1/20 44354: 销售线索->推进到失败关闭时，应该控制失败原因必填
    	if(this.module == 'Leads' && mapmodule == 'close'){  //wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段
    	   //edit:can 20210207 44621: 销售线索->推进到失败关闭时，失败原因是必填项，但是录入空格也能保存
    		if(ld("#"+popupobj.popupdivid+" [name=fileurereason]").val() != undefined && ld.trim(ld("#"+popupobj.popupdivid+" [name=fileurereason]").val()) == ''){
    			var __fileurereason = ld("#"+popupobj.popupdivid+" [name=fileurereason]").attr('tag');
    			RemindsMsg("","LdPopWidth400px","","yes","",__fileurereason+arrJsPopLabel['CANOTEMPTY']+'!');
                btnobj.removeAttr('isadvancing');
    			return false;
    		}
    	}
    	//销售线索推进界面保留原有的逻辑
  	    //chj 2020/12/21 43809: （http://51mis.com/ys/swl1234567/ [^]）销售管理>销售线索>推进>推进到指定阶段>升级；把“升级”改为“升级到客户”
    	//duan 2022/2/14 增加'升级到客户和销售机会'选项
        if(this.module == 'Leads' && (!empty(mapmodule) && mapmodule !='close')){
    		//@edit:liushuai,2020-09-02,reason:【ID1001055】/销售线索增加审批功能(只有审批通过后才能继续升级流程)
    		var surl = 'index.php?module=Leads&action=LeadsAjax&file=GetApproveDetail&record='+that.record+'&mapmodule='+mapmodule;
            var mapmodule_arr = mapmodule.split(":");
    		ldAjax(surl,"",function(data){
    			if(data.code == 1){
                    //edit:can 2021-01-11 044061: 销售线索推进升级为客户时，提示信息界面下面不应该出现进度刷新的圆圈
                    DelProgressObjs();
                    var confirm_str = arrJsPopLabel['TRANSFERTOMODULE'].replace('"{Module}"',data.result.modulename);
                    MessagePopup.TipTwo_warning(confirm_str);
    				that.confirmPopup().then(response => {//xxy 2023-11-23 修改样式，需要替换原本的confirm
                        if(response == true){
                            popupobj.CancelEvent();
                            var objparams = new CreatePagePopup.params();
                            var lasturl = "&upgradefrommodule=Leads&upgradefromid="+that.record+"&upgradestatus="+advance_stage_value;
                            if(mapmodule_arr.includes('Accounts') && mapmodule_arr.includes('Potentials')){
                                lasturl += "&upgradetomodule=Potentials";
                                mapmodule="Accounts";
                            }
                            objparams.params['isduplicate'] = 'no';
                            objparams.params['refreshpage'] = 'yes';
                            objparams.params['createdtype'] = 'create';
                             //wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段
                            CreatePagePopup.showpage(mapmodule,lasturl, objparams);
                            ld("#leads_mappingfields").css('display','none');
                            puyoungJS_DialogBox.unblock();
                            btnobj.removeAttr('isadvancing');
                            return true;
                        }
    				});
    			}else{
    			    DelProgressObjs();
                    if(data.code == -2){
                        var confirm_str = arrJsPopLabel['beforeoperationthisrecord4'].replace('"{Module}"', data.result.modulename);
                    }else{
                        if(mapmodule_arr.length==1){
                            var confirm_str = arrJsPopLabel['beforeoperationthisrecord3'].replace('"{Module}"', data.result.modulename);
                        }else{//wym 240322 目前多个模块只有客户和商机 先不改翻译
                            var confirm_str = arrJsPopLabel['beforeoperationthisrecord2'];
                        }
                    }
    				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                    btnobj.removeAttr('isadvancing');
    				return false;
    			}
    		})
    
    
    	}else{
    		var surl = 'index.php?module=Settings&action=SettingsAjax&file=AdvanceStage&mode=save&record='+that.record+'&frommodule='+that.module+'&advance_stage_value='+encodeURIComponent(advance_stage_value);
    		if(that.module == 'Leads' && mapmodule=='close'){
    			surl += '&fileurereason='+encodeURIComponent(ld("#"+popupobj.popupdivid+" [name=fileurereason]").val());
    		}
    		//alert(surl);
    		ldAjax(surl,"",function(data){
                if(popupobj.pagetype !='detailview_modulepage'){
                    popupobj.CancelEvent();
                }
    			if(data.code == 1){
    				that.NewRefresh(data.result);

                    workflowCallApiPop(data.result);//工作流API弹窗
    			}
                else{
    				RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
    				//点击确认
                    /*
    				ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
    					var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",that.module,"","","","",that.record);
    					 Popupobj.prevshow();
    					 PageRecordPopup.params['refreshpage']='no';
    					 var tmpurl = '&advance_field='+data.result.fieldname+'&advance_field_value='+encodeURIComponent(advance_stage_value);
    					 PageRecordPopup.showpage(that.module,that.record,tmpurl,PageRecordPopup.params);
    					
    				});
                    */

                    var remindpopupobj = CrmPopup.getPopupObj("last");
                    //点击确认
                    var advancefield = {};
                    advancefield[data.result.fieldname] = encodeURIComponent(advance_stage_value);
                    advancefield_json = JSON.stringify(advancefield);

                    ld('#'+remindpopupobj.divid+'_btnok').unbind('click').on('click',function(){
                        var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",popupobj.module,"","","","",popupobj.record);
                        Popupobj.prevshow();
                        PageRecordPopup.params['refreshpage']='no';
                        PageRecordPopup.params['miniedit_fieldrule']='fromadvance';

                        var tmpurl = '&miniedit_fieldrule=fromadvance';
                        if(!empty(advancefield_json)){
                            tmpurl += '&fieldvaluejson='+advancefield_json;
                        }
                        PageRecordPopup.showpage(popupobj.module,popupobj.record,tmpurl,PageRecordPopup.params);

                    });

                }
    			DelProgressObjs();
                btnobj.removeAttr('isadvancing');
    		})
    	}
    }
    this.NewRefresh = function(valueinfo){
        var lastpopupobj=CrmPopup.getPopupObj('last');
    	var tmparra=new Array();
    	tmparra.push(that.record);
    	var tmpobj= new AfterUpdatePrevPopupObjContent(that.module,valueinfo,tmparra);
    	tmparra=[that.module];
        tmpobj.eachrefreshDetailViewByModules(tmparra);
    	//DetailViewRelation.showpage_moduledetail(lastpopupobj);

       var iskanbanshow=ld('#iskanbanshow').val();
       if(iskanbanshow=='yes'){
           DelProgressObjs();
           var browserwidth=window.innerWidth;
           var pageleftwidth=ld("#pageleft_unfold").css('width');
           var browserheight=window.innerHeight;
           var pagetopheight=ld("#pagehead").css('height');

           pageleftwidth=browserwidth-parseFloat(pageleftwidth)+'px';
           var main_grid_topheight=0;
           if(ld("#ListViewNavBarAndBtn").length>0){
               main_grid_topheight+=parseFloat(ld("#ListViewNavBarAndBtn").css('height'));
           }
           if(ld("#ListViewBtnAndSeach").length>0){
               main_grid_topheight+=parseFloat(ld("#ListViewBtnAndSeach").css('height'));
           }

           var surl = '';
           var listpage_popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
           if(listpage_popupobj != undefined && listpage_popupobj.linkmodulecustom == 'yes'){
               surl += '&ajaxtype=ld_linkmodulecustom';
           }
           surl += '&viewid='+ld("#viewname").val();
           surl += '&viewname='+ld("#viewname").val();

           pagetopheight=browserheight-parseFloat(pagetopheight)-main_grid_topheight-10-50+'px';//10：头部间隔。50看板列头
           var urlstring='index.php?module='+module+'&action='+module+'Ajax&file=ListView&viewmode=kanban&kanbanajax=true&pageleftwidth='+pageleftwidth+'&pagetopheight='+pagetopheight+surl;
           ldAjax(urlstring,"",function(data){
               if(data.code==1){
                   // data.result.refreshdetailmodules.push(popupobj.module);
                   ld('#ListViewContents').html(data.result);
                   DelProgressObjs();
               }
           })
       }
       else{
           tmpobj.eachrefreshlistbyModules(tmparra);
           AdvanceStage.reset_pupupobj_divid(lastpopupobj);
           DelProgressObjs();
       }
   }
   //创建关联单据后刷新推进弹出层
   this.RefreshPopup = function(popupobj,newpopupobj){
        //判断是否启用了自动化任务
        if(!empty(popupobj.popupdivid)){
            popupobj.divid = popupobj.popupdivid;
        }
        if(ld('#'+popupobj.popupdivid+' #AllTaskvalue').length==0){
            DetailViewRelation.showpage_moduledetail(popupobj);
            return false;
        }
        //获取当前阶段，用于判断关联创建单据后是否触发了自动推进
        var stagename_now = ld('#'+popupobj.divid+' #AllTaskvalue [name=stagename_now]').val();
        if(popupobj.pagetype =='detailview_modulepage'){
            var advanceid = ld('#'+popupobj.divid+' [name=next_advanceid]').val();
            var stagename = ld('#'+popupobj.divid+' [name=next_stagename]').val();
        }else{
            var tag_value = ld("#"+popupobj.divid+" [name=advance_stage_type]:checked").val();
            if(tag_value == 'next'){
                var select_name = 'next_advance_stage';
            }else{
                var select_name = 'specified_advance_stage';
            }
            var obj = ld("#"+popupobj.divid+" [name="+select_name+"]");
            
            var advanceid = ld(obj).find("option:selected").attr('advanceid');
            var stagename = ld(obj).val();
        }
        var frommodule = newpopupobj.module;
        var surl = 'index.php?module='+popupobj.module+'&action='+popupobj.module+'Ajax&file=Taskprogress';
        surl += '&record='+popupobj.record+'&modulename='+popupobj.module+'&refresh_moduletask=yes';
        var param = {'stagename_now':stagename_now,'advanceid':advanceid,'frommodule':frommodule};
        ldAjaxNoProgress(surl,param,function(data){
            DelProgressObjs();
            if(data.code == 1){
                if(data.result.refresh_detailviewpage =='yes'){
                    if(popupobj.pagetype =='advancepopup'){
                        popupobj.CancelEvent();
                    }
                    var last_popupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
                    AdvanceStage.reset_pupupobj_divid(last_popupobj);
                    DetailViewRelation.showpage_moduledetail(last_popupobj);

                }else{
                    if(!empty(data.result.task_content)){
                        var module_tdobj = ld('#'+popupobj.popupdivid+' #AllTaskvalue [name=advancetask_module][module='+frommodule+']');

                        if(module_tdobj.length>0){
                            module_tdobj.html(data.result.task_content);
                        }
                    }
                }
            }else if(data.code == -1){ 
                RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
            }
            
        })
   }
   
   this.RefreshTaskAfterDelete = function(popupobj,newpopupobj){
        //判断是否启用了自动化任务
        if(!empty(popupobj.popupdivid)){
            popupobj.divid = popupobj.popupdivid;
        }
        if(ld('#'+popupobj.divid+' #AllTaskvalue').length == 0 ){
            return false;
        }
        var frommodule = newpopupobj.module;
        var module_tdobj = ld('#'+popupobj.divid+' #AllTaskvalue [name=advancetask_module][module='+frommodule+']');
        if(module_tdobj.length == 0){
            return false;
        }
        
        //获取当前阶段，用于判断关联创建单据后是否触发了自动推进
        var stagename_now = ld('#'+popupobj.divid+' #AllTaskvalue [name=stagename_now]').val();
        if(popupobj.pagetype =='detailview_modulepage'){
            var advanceid = ld('#'+popupobj.divid+' [name=next_advanceid]').val();
            var stagename = ld('#'+popupobj.divid+' [name=next_stagename]').val();
        }else{
            var tag_value = ld("#"+popupobj.divid+" [name=advance_stage_type]:checked").val();
            if(tag_value == 'next'){
                var select_name = 'next_advance_stage';
            }else{
                var select_name = 'specified_advance_stage';
            }
            var obj = ld("#"+popupobj.divid+" [name="+select_name+"]");
            
            var advanceid = ld(obj).find("option:selected").attr('advanceid');
            var stagename = ld(obj).val();
        }
        var surl = 'index.php?module='+popupobj.module+'&action='+popupobj.module+'Ajax&file=Taskprogress';
        surl += '&record='+popupobj.record+'&modulename='+popupobj.module+'&refresh_moduletask=yes';
        var param = {'stagename_now':stagename_now,'advanceid':advanceid,'frommodule':frommodule};
        ldAjaxNoProgress(surl,param,function(data){
            DelProgressObjs();
            if(data.code == 1){
                if(data.result.refresh_detailviewpage =='yes'){
                    if(popupobj.pagetype =='advancepopup'){
                        popupobj.CancelEvent();
                    }
                    var last_popupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
                    AdvanceStage.reset_pupupobj_divid(last_popupobj);
                    DetailViewRelation.showpage_moduledetail(last_popupobj);
                }else{
                    if(!empty(data.result.task_content)){
                        if(module_tdobj.length>0){
                            module_tdobj.html(data.result.task_content);
                        }
                    }
                }
            }else if(data.code == -1){ 
                RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
            }
        })
   }
    this.confirmPopup = function() {//代替原生confirm弹窗
        return new Promise((resolve, reject) => {
            var popupobj=CrmPopup.getPopupObj('last');
            ld('#'+popupobj.divid+' input[tagclick="msgConfirm"]').on('click', function () {
                resolve(true);
            });
            ld('#'+popupobj.divid+' [tagclick="msgConfirmCancel"]').on('click', function () {
                resolve(false);
            });
        })         
    }
}
//获取当前类对象
AdvanceStage.getInstance=function(module,record){
    var AdvanceStageobj=new AdvanceStage();
    AdvanceStageobj.init(module,record);
    return AdvanceStageobj;
}

//刷新
AdvanceStage.refresh = function(valueinfo){
	var lastpopupobj=CrmPopup.getPopupObj('last');
	var tmparra=new Array();
	tmparra.push(AdvanceStage.record);
	var tmpobj= new AfterUpdatePrevPopupObjContent(AdvanceStage.module,valueinfo,tmparra);
	tmparra=[AdvanceStage.module];
	tmpobj.eachrefreshlistbyModules(tmparra);
	tmpobj.eachrefreshDetailViewByModules(tmparra);
	AdvanceStage.reset_pupupobj_divid(lastpopupobj);
    //DetailViewRelation.showpage_moduledetail(lastpopupobj);
	DelProgressObjs();
}

//刷新
AdvanceStage.refresh_detail = function(record,module){
	/*var surl = 'index.php?module=Settings&action=SettingsAjax&file=AdvanceStage&mode=list&record='+record+'&frommodule='+module;
	ldAjax(surl,"",function(data){
		if(data.code==1){
			ld(' [name=advance_stage_div]').html(data.result.content);
		}
		DelProgressObjs();
	})*/
	//chj 2021/1/19 41949: （https://61mis.com/kfbcrm/ [^]）单据查看详情界面，推进的阶段布局规则设置了必填字段，进入编辑界面输入数据保存后，单据详情界面没有立即更新（销售机会模块测试）
	var tmparra=new Array();
	tmparra.push(record);
	var tmpobj= new AfterUpdatePrevPopupObjContent(module,"",tmparra);
	var refreshlistmodules = new Array(module);
	tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);
	tmpobj.update();
	delete tmpobj;
	DelProgressObjs();
}

//显示
AdvanceStage.show = function(record,module){
	AdvanceStage.record = record;
	AdvanceStage.module = module;
    var popupobj=CrmPopup.getPopupObj("last");
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=AdvanceStage&mode=show&record='+record+'&frommodule='+module;
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
    ld("#"+crmPopupobj.divid+' .E_pbtnok').hide();
    ld("#"+crmPopupobj.divid+' .E_pbtncancel').hide();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
            if(data.result.method == 'field'){
                var prevpopupobj = CrmPopup.getPopupObj("lastprev");
                crmPopupobj.setScrollDivMaxHeight = function () {
                    var maxheight = this.getMaxHeight()*0.5;
                    ld("#" + this.divid + " .dvpopupsroll").css("max-height", maxheight);
                }
                crmPopupobj.AdvanceStageobj = AdvanceStage.getInstance(module,record);
                crmPopupobj.createScrollDiv();
                crmPopupobj.setParams(data.result.title,crmPopupobj.AdvanceStageobj.SaveFieldValue,"","LdPopWidth600px",'Settings',"",data.result.pushtext,"",data.result.canceltext,"");
                CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj,data.result.content);
                crmPopupobj.setScrollDivMaxHeight();
                crmPopupobj.fields = prevpopupobj.fields;
                crmPopupobj.fieldname_fields = prevpopupobj.fieldname_fields;
                crmPopupobj.module = prevpopupobj.module;
                crmPopupobj.record = prevpopupobj.record;
                crmPopupobj.pagetype = 'advancepopup';
                crmPopupobj.savetype = 'push';
                crmPopupobj.oCKeditors=[];
                crmPopupobj.popupdivid = crmPopupobj.divid;
                crmPopupobj.columnfields_value = data.result.columnfields_value;
                if(empty(crmPopupobj.fieldname_fields))crmPopupobj.fieldname_fields = {};
                if(prevpopupobj.pagetype == 'detailview_modulepage'){
                    crmPopupobj.picklist_arrow_click = prevpopupobj.picklist_arrow_click;
                    crmPopupobj.picklist_end_foucs = prevpopupobj.picklist_end_foucs;
                    crmPopupobj.picklistobjarray = prevpopupobj.picklistobjarray;
                }else{
                    crmPopupobj = AdvanceStage.initpicklist(crmPopupobj,data.result);
                }
                var advancedata = data.result.advancedata;
                if(!empty(advancedata)) {
                    //如果自动化任务中设置了附件字段，则需要获取附件信息
                    if (advancedata.filejsondata != undefined) {
                        crmPopupobj.filejsondata = advancedata.filejsondata;
                    }
                    if (advancedata.advancefields != undefined) {
                        crmPopupobj.advancefields = advancedata.advancefields;
                    }
                    crmPopupobj.advancedata = advancedata;
                }
                crmPopupobj.isadmin = data.result.isadmin;
                
                ld("#"+crmPopupobj.divid+' .E_pbtnok').show();
                ld("#"+crmPopupobj.divid+' .E_pbtncancel').show();
                var btnobj = ld("#"+crmPopupobj.divid+'_btnok');
                var savebtnobj = ld('<input name="'+crmPopupobj.divid+'_btnsave" id="'+crmPopupobj.divid+'_btnsave" class="E_pbtnok" value="'+data.result.oktext+'" onclick="CrmPopup.getPopupObj(\'last\').AdvanceStageobj.SaveFieldValue(\'save\')" type="button"><span>&nbsp;</span>');
                btnobj.before(savebtnobj);
                
                AdvanceStage.advance_load_tipevent();
                //任务弹出层界面,控制td允许溢出,方便下拉框显示
                var tableobj= ld("#"+crmPopupobj.divid+" #AllTaskvalue table[name=advancetask]");
                if(tableobj.length>0){
                    var info_tdobjs = ld(tableobj).find('td[class*=DetailedTd2Info]');
                    info_tdobjs.css('overflow','unset');
                }
    			if(module == 'Leads'){
    				var popupobj=CrmPopup.getPopupObj("last");
    				var advance_stage_type = ld("#"+crmPopupobj.divid+" [name=advance_stage_type]:checked").val();
    				var advance_stage_value = '';
                    var mapmodule = '';
    				if(advance_stage_type == 'next'){
    					advance_stage_value = ld("#"+crmPopupobj.divid+" [name=next_advance_stage]").val();
                        mapmodule = ld("#"+crmPopupobj.divid+" [name=next_advance_stage]").find("option:selected").attr('data-mapmodule');
    				}else{
    					advance_stage_value = ld("#"+crmPopupobj.divid+" [name=specified_advance_stage]").val();
                        mapmodule = ld("#"+crmPopupobj.divid+" [name=specified_advance_stage]").find("option:selected").attr('data-mapmodule');
    				}
    				if(mapmodule == 'close'){
    					ld("#"+crmPopupobj.divid).find("[name=fileurereason_tr]").show();
                        ld("#"+crmPopupobj.divid).find("[name=fileurereason]").val(advancedata.failurereason);
    				}
    			}
                
                ld("#"+crmPopupobj.divid+" [name=advance_stage_type]").bind('click',function(){
                    var tag_value = ld(this).val();
                    if(tag_value == 'next'){
                        var select_name = 'next_advance_stage';
                    }else{
                        var select_name = 'specified_advance_stage';
                    }
                    AdvanceStage.changeNextStep(ld("#"+crmPopupobj.divid+" [name="+select_name+"]"));
                });
                
            }else{
                ld("#"+crmPopupobj.divid+' .E_pbtnok').show();
                ld("#"+crmPopupobj.divid+' .E_pbtncancel').show();
                crmPopupobj.setParams(data.result.title,AdvanceStage.save,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");  
                crmPopupobj.show(data.result.content);
            }
		}else if(data.code == -1){
            crmPopupobj.CancelEvent();
            var confirmstr = data.result.confirmstr;
            RemindsMsg("","LdPopWidth400px","","yes","",confirmstr);
		}
	})
}
//edit:can 2020-09-28 
AdvanceStage.changeNextStep=function(jqueryobj) {
    var prevpopupobj=CrmPopup.getPopupObj('lastprev');
    var popupobj=CrmPopup.getPopupObj('last');
    var mapmodule = ld(jqueryobj).find("option:selected").attr('data-mapmodule');
    if(prevpopupobj.module=='Leads'&&mapmodule=='close')
    {
        ld("#"+popupobj.divid).find("[name=fileurereason_tr]").show();
        ld("#"+popupobj.divid).find("[name=fileurereason]").val(popupobj.advancedata.failurereason);
    }
    else if(prevpopupobj.module=='Leads')
    {
        ld("#"+popupobj.divid+" [name=fileurereason_tr]").hide();
    }
    if(!empty(mapmodule) && mapmodule!='close'){
        ld('#advance_stage_upgrade').show();
    }else{
        ld('#advance_stage_upgrade').hide();
    }
    popupobj.AdvanceStageobj.ChangeAdvanceStage(jqueryobj);
}
//完成
AdvanceStage.Complete = function(record,module){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=AdvanceStage&mode=complete&record='+record+'&frommodule='+module;
	ldAjax(surl,"",function(data){
		if(data.code == 1){
		  //edit:can 20220507 回款动态菜单>应收款项模块>选择单据编号为“YS-32”点击完成会卡死 
          AdvanceStage.record = record;
			AdvanceStage.module = module;
			AdvanceStage.refresh(data);
		}
		DelProgressObjs();
	})
}
//追踪字段类型为时间范围时保存
AdvanceStage.save = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var advance_stage_type = ld("#"+popupobj.divid+" [name=advance_stage_type]:checked").val();
	var advance_stage_value = '';
    
	if(advance_stage_type == 'next'){
		advance_stage_value = ld("#"+popupobj.divid+" [name=next_advance_stage]").val();
	}else{
		advance_stage_value = ld("#"+popupobj.divid+" [name=specified_advance_stage]").val();
	}
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=AdvanceStage&mode=save&record='+AdvanceStage.record+'&frommodule='+AdvanceStage.module+'&advance_stage_value='+encodeURIComponent(advance_stage_value);
	//alert(surl);
	ldAjax(surl,"",function(data){
		if(data.code == 1){
			popupobj.CancelEvent();
			AdvanceStage.refresh(data.result);
		}
        else{
			RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
			//点击确认
			ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
				popupobj.CancelEvent();
				var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",AdvanceStage.module,"","","","",AdvanceStage.record);
				 Popupobj.prevshow();
				 PageRecordPopup.params['refreshpage']='no';
				 var tmpurl = '&advance_field='+data.result.fieldname+'&advance_field_value='+encodeURIComponent(advance_stage_value);
				 PageRecordPopup.showpage(AdvanceStage.module,AdvanceStage.record,tmpurl,PageRecordPopup.params);
				
			});
        }
		DelProgressObjs();
	})
}
//调整任务框位置
AdvanceStage.advance_load_tipevent = function(){
    var advancePopupobj=CrmPopup.getPopupObj('last');
    if(advancePopupobj.pagetype == 'advancepopup'){
        var Popupobj=advancePopupobj;
    }else{
        var Popupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
    }
    var tmpdivid=Popupobj.divid;
    var tableobj= ld("#"+Popupobj.divid+" #AllTaskvalue table[name=advancetask]");
    
    if(ld("#"+tmpdivid+" [name=task_num]").length>0 && ld("#"+tmpdivid+" [name=task_num]").val() >0){
     ld("#"+tmpdivid+" [name=advancetasklabel]").show();
    }else{
     ld("#"+tmpdivid+" [name=advancetasklabel]").hide();
    }
    if(Popupobj.pagetype !='detailview_modulepage'){
        if(ld("#"+tmpdivid+" [name=task_num]").length>0 && ld("#"+tmpdivid+" [name=task_num]").val() >0){
            ld("#"+tmpdivid+" [name=advancetasklabel]").show();
            ld("#"+tmpdivid).css('width','600px');
            Popupobj.center();
        }else{
            ld("#"+tmpdivid+" [name=advancetasklabel]").hide();
            ld("#"+tmpdivid).css('width','600px');
            Popupobj.center();
        }
    }
    //判断是否需要显示创建单据的显示隐藏按钮
    AdvanceStage.showchangestatusbtn(Popupobj);
    if(tableobj.length <=0 || ld("#"+tmpdivid+" [name=AllTaskvalue]").length <=0){
        // ld("#"+tmpdivid+" [name=nextstage_div]").css('border-bottom','');
        ld("#"+tmpdivid+"_btnsave").hide();
        ld("#"+tmpdivid+" #savebutton").hide();
        return false;
    }
    var tdobjs = ld(tableobj).find('td');
    //tdobjs.removeAttr('class');
    //tdobjs.attr('align','left');
    tdobjs.css('overflow','unset');
    // tdobjs.css('border-bottom','1px solid #F1F1F1');
    var label_tdobjs = ld(tableobj).find('td[class*=DetailedTd1Label]');
    label_tdobjs.attr('width','15%');
    label_tdobjs.css('text-align','right');
    //加载附件和多选框
    var taskvalue_divid = 'AllTaskvalue';
    Popupobj.ueditor_fieldname_arr = new Array();
    if(Popupobj.advancefields != undefined && Popupobj.advancefields.length>0 ){
        var orgin_fields = Popupobj.fields;
        Popupobj.fields = Popupobj.advancefields;
        var advancefields_arr = Popupobj.advancefields;
        var choose_fieldname_arr = new Array();
        for(var i=0;i<advancefields_arr.length;i++){
            choose_fieldname_arr.push(advancefields_arr[i].fieldname);
        }
        var tmp_field = {};
        for(var i=0;i<advancefields_arr.length;i++){
            tmp_field = advancefields_arr[i];
            
            Popupobj.fieldname_fields[tmp_field.fieldname] = tmp_field;
            if(!choose_fieldname_arr.includes(tmp_field.fieldname)){
                continue;
            }
            if(SaveDataRecord.isfileattachUitype(tmp_field.uitype))
            {
                var fileuploader=CrmPopup.findHtmlobj(tmpdivid+' #'+taskvalue_divid,tmp_field.fieldname);
                if(fileuploader.length>0)
                {
                    var uploadFile = new WebUploadFile();
                    uploadFile.set_file_fields(advancefields_arr);
                      globalWebUploadType = uploadFile.getScript(globalWebUploadType);
                      
                        uploadFile.setEvent(globalWebUploadType,fileuploader,Popupobj,i);
                }
               
                if(tmp_field.uitype==28)
                {
                    Popupobj.docfilename=tmp_field.fieldname;
                    showType();
    
                }
                window.setTimeout(function (i) {
                    
                    if(tmp_field.allowedit=='no'){
                         ld('#'+tmpdivid+' #'+taskvalue_divid+" [name="+tmp_field.fieldname+"]").find(" [tag=deletefile]").remove();
                         ld('#'+tmpdivid+' #'+taskvalue_divid+" [name="+tmp_field.fieldname+"]").find(" .webuploader-pick").remove();
                         ld('#'+tmpdivid+' #'+taskvalue_divid+" [name="+tmp_field.fieldname+"]").find(" [name=file]").parent().remove();
                    }     
                 },200,i);
            }else if(tmp_field.uitype==33){
                //修改多选框显示
                var tmpfieldname=tmp_field.fieldname;
                ld('#'+tmpdivid+' #'+taskvalue_divid+" [name='"+tmpfieldname+"[]']").select2({closeOnSelect: false, dropdownParent: ld("#"+taskvalue_divid)});
            }else if(tmp_field.uitype==19 || tmp_field.uitype==21){
                //调整文本区域显示
                var textareaobj = CrmPopup.findHtmlobj(tmpdivid+' #'+taskvalue_divid,tmp_field.fieldname);
                textareaobj.not('.proName_note').autosize();
            }else if(tmp_field.uitype==202){
                //重新设置选择源单按钮事件
                var selectsourceobj = CrmPopup.findHtmlobj(tmpdivid,'selectsource');
                var selectlistvalobj = CrmPopup.findHtmlobj(tmpdivid,'selectlistval');
                var selectlistlabelobj = CrmPopup.findHtmlobj(tmpdivid,'selectlistval_label');
                selectsourceobj.attr('onchange','').bind('change',function (){
                    selectlistvalobj.val('');
                    selectlistlabelobj.val('');
                })
                selectlistlabelobj.parent().find('[name=selectlistval_icon_select]').attr('onclick','').bind('click',function (){
                    getJsScript('include/js/SystemPopup/MultiplePopup.js',function () {
                        var chooseentityidarr = [];
                        if(selectsourceobj.val() == ''){
                            MessagePopup.TipOne_warning(arrJsPopLabel['SELECTTHESOURCEDOCUMENTTYPE']);
                            return '';
                        }
                        if(selectlistvalobj.val() != ''){
                            chooseentityidarr = selectlistvalobj.val().split(',');
                        }
                        var MultiplePopupobj = new MultiplePopup();
                        MultiplePopupobj.init(selectsourceobj.val(),'',this.popupobj.module);
                        MultiplePopupobj.width = CrmPopup.getClientWidth()*0.8;
                        MultiplePopupobj.setChooseEntityidArr(chooseentityidarr);
                        MultiplePopupobj.showPopup();
                        MultiplePopupobj.setReturnField(this.popupobj,'selectlistval','selectlistval_label');
                        MultiplePopupobj.showPopupAfter = function(){
                            //记录选中的单据id以及顺序
                            var that = this;
                            var popupobj = that.popupobj;
                            if(this.saveChooseInfo == 'yes'){
                                this.setCheckBoxEvent();
                            }
                            //重新设置选择单据的点击事件
                            if(this.selecttype == 'all' || this.selecttype == 'multiple'){
                                ld("#"+popupobj.divid+" .saveauto").show().attr('onclick','').bind("click",function(){
                                    that.MultiplePopupSelectRecord();
                                })
                            }
                            that.loadCheckbox();
                        }
                        MultiplePopupobj.ClickAfterReturn = function (){
                            var that = this;
                            ld("#"+that.prevpopupobj.divid+" [name='"+that.entityidlabel+"']").val(that.chooseentityid_arr.join(','));
                            ld("#"+that.prevpopupobj.divid+" [name='"+that.entitynamelabel+"']").val(that.chooseentityname_arr.join(','));
                            ld("#"+that.prevpopupobj.divid+" [name='"+that.entitynamelabel+"']").attr('title',that.chooseentityname_arr.join(','));
                        }
                    })
                })
                selectlistlabelobj.parent().find('[name=selectlistval_icon_clear]').attr('onclick','').bind('click',function (){
                    selectlistvalobj.val('');
                    selectlistlabelobj.val('');
                });
            }
            else  if(tmp_field.uitype==230 || tmp_field.uitype==231)
            {
                var tmpfieldname=tmp_field.fieldname;
                if(Popupobj.ueditor_fieldname_arr.indexOf(tmpfieldname) == -1){
                    Popupobj.ueditor_fieldname_arr.push(tmpfieldname);
                }
                //为了避免和新建、编辑页面的富文本框控件名称冲突，将fieldname加上_new后缀
                var textareaobj = CrmPopup.findHtmlobj(tmpdivid+' #'+taskvalue_divid,tmpfieldname);
                var tmpfieldname_new =  tmpfieldname+'_new';
                textareaobj.attr('name',tmpfieldname_new);
                textareaobj.attr('id',tmpfieldname_new);
                textareaobj.not('.proName_note').autosize();
                textareaobj.css('resize','none');
                
                var tmpokeditor= UE.getEditor(tmpfieldname_new,{
                    initialFrameWidth:"87%"
                });//实例化编辑器
                Popupobj.oCKeditor=tmpokeditor;
                if(Popupobj.oCKeditors == undefined){
                    Popupobj.oCKeditors = [];
                }
                Popupobj.oCKeditors[tmpfieldname_new]=tmpokeditor;   
                
                window.setTimeout(function(j){
                    var id=ld('#'+j).children("div:first-child").attr("id");
                    ld('#'+id).css('z-index','99999');
                    //Popupobj.oCKeditor.center();//38378: （51mis.com/kfbcrm）公告模块新增界面：新增弹出层没有在当前屏幕居中，太靠下了。
                },400, tmpfieldname_new);
                textareaobj.parent().css('min-width','800px');
            }
        }

        //推进字段添加绑定布局规则
        var advancedata = Popupobj.advancedata;
        var trigger_fieldname_arr = advancedata.trigger_fieldname_arr;
        if(!empty(trigger_fieldname_arr)){
            AjaxJSPage('cls_miniedit_fieldrule_js','include/js/cls_miniedit_fieldrule.js');
            Popupobj.minifieldruleobj = new cls_miniedit_fieldrule(Popupobj,trigger_fieldname_arr);
            Popupobj.minifieldruleobj.setParentobj(ld('#'+tmpdivid+' #'+taskvalue_divid));
            Popupobj.minifieldruleobj.set_trigger_fields_arr(Popupobj.advancefields);
            Popupobj.minifieldruleobj.setEvent();
            Popupobj.minifieldruleobj.setValues(advancedata.trigger_fieldvalue_arr);

            Popupobj.minifieldruleobj.reloadPopup = function (){
                if(Popupobj.pagetype == 'advancepopup'){
                    ld('#'+Popupobj.popupdivid+' [name=advance_stage_type]:checked').click();
                }else{
                    var advanceid = ld('#'+Popupobj.popupdivid+' [name=next_advanceid]').val();
                    ld('#'+Popupobj.popupdivid+' [name=advancestagebtn][advanceid='+advanceid+']').click();
                }
            }
        }
        if(advancedata.mainfieldformula != undefined){
            Popupobj.mainfieldformulaobj=new cls_mainfieldformula(advancedata.mainfieldformula);
            Popupobj.mainfieldformulaobj.setPopupobj(Popupobj);
            Popupobj.mainfieldformulaobj.init();
            Popupobj.mainfieldformulaobj.setEvent();
        }


        Popupobj.fields = orgin_fields;
    }
    
    //更新弹出层divid,获取不同区域的字段对象
    if(Popupobj.pagetype =='detailview_modulepage'){
        ld("#"+tmpdivid+" [name=displayfields]").attr("id",'displayfields');
        ld("#"+tmpdivid+" [name=displayfields]").unbind("mouseover").bind("mouseover",function(){
            Popupobj.divid = 'displayfields';
        });
        ld("#"+tmpdivid+" [name=displayfields]").unbind("mouseout").bind("mouseout",function(){
            Popupobj.divid = tmpdivid;
        });
        
        ld("#"+tmpdivid+" [name=AllTaskvalue]").unbind("mouseover").bind("mouseover",function(){
            Popupobj.divid = 'AllTaskvalue';
        });
        ld("#"+tmpdivid+" [name=AllTaskvalue]").unbind("mouseout").bind("mouseout",function(){
            Popupobj.divid = tmpdivid;
        });
    }
    
    
    //获取必填字段类型任务的数量，判断是否需要显示保存按钮
    var fieldtask_num = ld("#"+tmpdivid+" [name=fieldtask_num]").val();
    var task_num = ld("#"+tmpdivid+" [name=task_num]").val();
    if(Popupobj.pagetype !='detailview_modulepage'){
        if(task_num >0){
            ld("#"+tmpdivid+" [name=advancetasklabel]").show();
            ld("#"+tmpdivid).css('width','650px');
        }else{
            ld("#"+tmpdivid+" [name=advancetasklabel]").hide();
            ld("#"+tmpdivid).css('width','450px');
        }
    }
    if(!empty(fieldtask_num)&&fieldtask_num >0){
        ld("#"+tmpdivid+" #savebutton").show();
        ld("#"+tmpdivid+"_btnsave").show();
        //ld("#"+tmpdivid+" #saveandpushbutton").show(); 
        //ld("#"+tmpdivid+" [name=pushbutton]").hide();  
    }else{
        ld("#"+tmpdivid+" #savebutton").hide();
        ld("#"+tmpdivid+"_btnsave").hide();
        //ld("#"+tmpdivid+" #saveandpushbutton").hide(); 
        //ld("#"+tmpdivid+" [name=pushbutton]").show();  
    }





    return false;
}
//点击任务完成时触发
AdvanceStage.completetask = function(obj){
    var popupobj=CrmPopup.getPopupObj('last');
    var tasktype = ld(obj).attr("tasktype");
    var taskid = ld(obj).attr("taskid");
    var record = ld(obj).attr("record");
    var taskresult;
    if(tasktype == 'checkbox'){//两个复选框特殊控制
        if(ld(obj).is(':checked')){
            var checkbox_name = ld(obj).attr('name');
            var obj_value = ld(obj).val()
            var checkbox_objs = ld("#"+popupobj.divid+" input[name="+checkbox_name+"]");
            ld.each(checkbox_objs,function(){
                if(ld(this).val()!=obj_value&&!ld(this).prop('disabled'))
                    ld(this).prop("checked",false);
            })
            if(obj_value=='no'){
                taskresult = 'no';
            }else{
                taskresult = 'yes';
            }
        }else{
            taskresult = 'chebox_empty';
        }
    }else{
        taskresult = ld(obj).val();
    }
    var stagename = ld(obj).attr("stagename");
    var modulename = ld(obj).attr('modulename');
    var complete_task = "yes";
    if(tasktype =='module'){//创建单据完成任务后不在这里判断
        return false;
    }
    var param = {'taskresult':taskresult,'record':record,'tasktype':tasktype,'complete_task':complete_task,'modulename':modulename,'stagename':stagename,'taskid':taskid};
    var url = "index.php?module="+modulename+"&action="+modulename+"Ajax&file=Taskprogress";
    if(tasktype!='module'){
        ldAjax(url,param,function(data){
            if(data.code==1){
                DelProgressObjs();
                var popupobj=CrmPopup.getPopupObj('last');
                
                //自动推进后刷新详情页
                if(data.result.push_success =='yes'){
                    if(popupobj.pagetype !='detailview_modulepage'){
                        popupobj.CancelEvent();
                        popupobj=CrmPopup.getPopupObj('last');
                    }
                    popupobj.AdvanceStageobj.NewRefresh(data);
                }
            }
        });
    }
}
//重置弹出层对象divid
AdvanceStage.reset_pupupobj_divid = function(popupobj){
    //去除更改弹出层divid的事件，为了避免刷新页面时出现取对象错误的问题
    if(!empty(popupobj.popupdivid)){
        ld("#"+popupobj.popupdivid+" [name=AllTaskvalue]").unbind('mouseover');
        ld("#"+popupobj.popupdivid+" [name=displayfields]").unbind('mouseover');
        popupobj.divid = popupobj.popupdivid;
    }
}
//根据任务框重设进度追踪图宽度
AdvanceStage.advancetask_load = function(){
    var popupobj=CrmPopup.getPopupObj('last');
    var advance_objs = ld("#"+popupobj.divid+" div[name=advancestage]");
    var task_objs = ld("#"+popupobj.divid+" div[name=advanceHeader]");
    var popupobj_divobj = ld("#"+popupobj.divid);
    
    var advance_width = 120;
    var last_taskobj;
    var advance_obj;
    var task_obj;
    var reset_width = 'no';
    var first_index = 0;
    ld.each(task_objs,function(){
        if(ld(this).attr('tasknum')>0){
            reset_width = 'yes';
        }
    });
    if(reset_width == 'no'){
        
    }else{
        //重设推进点宽度
        for(var i=0;i<advance_objs.length;i++){
            advance_obj = ld("#"+popupobj.divid+" div[name=advancestage][tag="+i+"]");
            task_obj = ld("#"+popupobj.divid+" div[name=advanceHeader][tag="+i+"]");
            if(empty(advance_obj)||empty(task_obj)){
                first_index++;
                continue;
            }
            if(i==first_index){
                advance_width = advance_obj.parent().width();
            }
            between_width = 20;
            var task_width = task_obj.width();
            //使得阶段div和任务div大小一致
            if(parseInt(task_obj.attr('tasknum')) <= 0 || task_obj.attr('tasknum')=="" ){
                advance_obj.parent().css('width',(advance_width+between_width)+'px');
                task_obj.css('width',advance_width+'px');
            }else{
                if(advance_width>task_width){
                    task_obj.css('width',advance_width+'px');
                    advance_obj.parent().css('width',(advance_width+between_width)+'px');
                }else{
                    advance_obj.parent().css('width',(task_width+between_width)+'px');
                }
            }
            last_taskobj = task_objs;
        }
    }
    //使滚动条自动移动到当前阶段所在的点
    setTimeout(function(){
        var current_obj = ld("#"+popupobj.divid+" [class*=current][flag=yes]");
        if(current_obj.length>0 &&advance_objs.length>0){
            var headerobj = ld("#"+popupobj.divid+" .modal-header");
            var last_advance_obj = ld("#"+popupobj.divid+" div[name=advancestage]:last");
            //计算滚动条应该移动的宽度
            var between_width = current_obj.get(0).getBoundingClientRect().right-headerobj.get(0).getBoundingClientRect().left-popupobj_divobj.width()*0.5;
            headerobj.get(0).scrollLeft =between_width;
        }
    },200);   
}

AdvanceStage.initpicklist = function(Popupobj,result){
    
    Popupobj.picklistcontent = result.picklistcontent;
    Popupobj.picklistdepencyfields = result.picklistdepencyfields;
    Popupobj.picklistobjarray = [];
    
    if (Popupobj.picklistcontent != null && Popupobj.picklistcontent != undefined){
        for (var k = 0; k < Popupobj.picklistcontent.length; k++) {
            //下拉框
            var fieldname = Popupobj.picklistcontent[k].fieldname;
            Popupobj.picklistobjarray[Popupobj.picklistcontent[k].fieldname] = new cls_picklist(Popupobj.picklistcontent[k].fieldname, Popupobj.picklistcontent[k].optionvalue);
            
            var tmpinputobj = CrmPopup.findHtmlobj(Popupobj.divid,"cmb_span_optiontext_"+fieldname);
            ld(tmpinputobj).unbind("keyup").bind("keyup",function(){
                var keyuppopupobj =  CrmPopup.getPopupObj('last');
                keyuppopupobj.picklistobjarray[fieldname].com_chosen(event);
                
                //下拉框内容重新定位
                var fromobj=CrmPopup.findHtmlobj(keyuppopupobj.divid,"cmb_a_"+fieldname);//获取点击按钮元素
                var dvdrop= CrmPopup.findHtmlobj(keyuppopupobj.divid,"dv_drop_"+fieldname);//获取下拉框内内容
                if(fromobj.hasClass('chzn-single-with-drop'))
                {
                    var dvfluobj= CrmPopup.findHtmlobj(cmb_parentdivid,"dv_cmb_"+fieldname);//
                    var newpicklistleft = ld(dvfluobj).offset().left;//left
                    var dvfluobjtop = ld(dvfluobj).offset().top;
                    var dvfluobjheight = ld(dvfluobjtop).height();
                    var dvchzncontentobj= CrmPopup.findHtmlobj(cmb_parentdivid,"dv_chzn_"+fieldname);//
                    var dvchzncontentheight = ld(dvchzncontentobj).height();
                    dvfluobjheight = dvfluobjheight>0?dvfluobjheight:dvchzncontentheight;
                    var picklisttop = ld(dvdrop).offset().top;
                    var picklistheight = ld(dvdrop).height();
                    var newpicklisttop = dvfluobjtop+dvfluobjheight;
                    var windowHeight =CrmPopup.getClientHeight();
                    newpicklisttop = (newpicklisttop+picklistheight)>windowHeight?(dvfluobjtop-picklistheight-2):newpicklisttop;
                    dvdrop.css("left",newpicklistleft);
                    dvdrop.css("top",newpicklisttop);
                }
            })
            if (Popupobj.picklistdepencyfields != null && Popupobj.picklistdepencyfields != "" && Popupobj.picklistdepencyfields[fieldname] != undefined) {
                Popupobj.picklistobjarray[Popupobj.picklistcontent[k].fieldname].setparentDependField(Popupobj.picklistdepencyfields[fieldname]);

            }
        }
    }
    if (Popupobj.picklistdepencyfields != null && Popupobj.picklistdepencyfields != undefined) {
        ld.each(Popupobj.picklistdepencyfields, function (childfieldname, parentfieldname) {
            if (Popupobj.picklistobjarray[parentfieldname] != undefined) {

                Popupobj.picklistobjarray[parentfieldname].setchildDependField(childfieldname);
            }
        });
    }
    Popupobj.picklist_end_foucs=function(event,fieldname)
    {
		ld("#"+Popupobj.divid+" [name=cmb_span_optiontext_"+fieldname+"]").select();
    }
    Popupobj.picklist_arrow_click = function (event, fieldname) {
        cmb_fldname = fieldname;//用于picklist.js中document.onclick调用
        cmb_parentdivid = Popupobj.divid;//用于picklist.js中document.onclick调用
        Popupobj.picklistobjarray[fieldname].arrow_click(fieldname);
    }
    
    return Popupobj;
}

//@edit:ljj,2023-08-01,reason:BUG0070359 kfbcrm-销售线索-推进阶段-点文字选不中
AdvanceStage.selectlabel=function(obj) {
    var input = ld(obj).prev("input")[0];
    var click_event = window.event;
    if (click_event.target != input) {
        ld(input).click();
    }
}

AdvanceStage.showchangestatusbtn = function(popupobj){
    var tmpdivid = popupobj.divid;
    var advance_record_divobjs = ld("#"+tmpdivid+" [name=advance_record_div]");
    ld.each(advance_record_divobjs,function (tmp_index,tmpobj) {
        var tmp_childobj = ld(tmpobj).find('[name=advance_record_child]');
        //如果总宽度不等于实际宽度，则需要显示展开按钮
        if(tmp_childobj.get(0).scrollWidth > tmp_childobj.width() + 10){
            if(tmp_childobj.attr('tag') == 'detail_log'){
                tmp_childobj.css('width','80%');
                ld(tmpobj).css('text-align','left');
            }
            ld(tmpobj).find('[name=show_record_btn]').show();
        }
    })
}

AdvanceStage.changerecordstatus=function(obj,type) {
    var parentdiv = ld(obj).parent().parent();
    var record_childobj = parentdiv.find('[name=advance_record_child]');
    var popupobj = CrmPopup.getPopupObj('last');
    if(type == 'show'){
        parentdiv.removeClass('advance_hiderecord').addClass('advance_showrecord');
        parentdiv.find('[name=hide_record_btn]').show();
        parentdiv.find('[name=show_record_btn]').hide();
        if(record_childobj.attr('tag') == 'detail_log'){
            record_childobj.css('width','');
        }
    }else{
        parentdiv.removeClass('advance_showrecord').addClass('advance_hiderecord');
        parentdiv.find('[name=hide_record_btn]').hide();
        parentdiv.find('[name=show_record_btn]').show();
        if(record_childobj.attr('tag') == 'detail_log'){
            record_childobj.css('width','80%');
        }
    }
    if(popupobj.pagetype =='detailview_modulepage'){
        var advance_processobj = new cls_advance_process(popupobj, popupobj.module);
        advance_processobj.setAdvancePadding(popupobj);
    }else{

    }

}
