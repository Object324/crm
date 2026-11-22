function detail_selectReference(obj,event,module_popupobj){
	this.module = ld(obj).attr('curmodule');	//当前模块
	this.referencemodule = ld(obj).attr('reference');	//关联选择模块
	this.fieldname = ld(obj).attr('fieldname');
	this.bigtype = ld(obj).attr('bigtype');
	if(ld.isArray(obj) == false){
		this.modulefields = module_popupobj.fields;	//模块基本信息字段
		this.detailfields=module_popupobj.detailfields;	//明细字段
		this.productfieldinfo=module_popupobj.productfieldinfo;	//明细字段
		this.module_popupobj = module_popupobj;
		this.rowobj=this.module_popupobj.getTrObjByChild(obj);
		this.rowindex=ld(this.rowobj).attr("rowindex");
	}else{
		this.module = obj[1];	//当前模块
		this.referencemodule = obj[0];	//关联选择模块
		this.fieldname = obj[2];
		this.rowindex = obj[3];
		this.module_popupobj = module_popupobj;
	}
	var that = this;
	this.refersh = function(urlstring){
		ldAjax(urlstring,"",function(data){
				if(data.code==1)
				{
					var  selectsearchpopupobj=selectSearchPopup.load(data.result.title,"","",CrmPopup.getSmallpopupwidth(),that.module,"","","","",that.referencemodule);
					selectsearchpopupobj.show(data.result.content);
					selectsearchpopupobj.rowindex = that.rowindex;
					selectsearchpopupobj.detailcolumnname = that.fieldname;
					selectsearchpopupobj.selectfieldtype='detailfield';
					
					if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined"){
						cls_wxOpenDataobj.bindAllOpenDataByPopupObj(selectsearchpopupobj);	//通讯录(pc端企业微信)
					}
					var popupobj = CrmPopup.getPopupObj("last");
					ld("#"+popupobj.divid+" [name=search]").unbind('click').on('click',function(){
						that.Search();
					});

					ld("#"+popupobj.divid +" [name=popupListViewContents] a[referencemodule="+that.referencemodule+"] ").each(function(){
						ld(this).unbind('click').on('click',function(){
							that.setvalue(this,that.rowindex);
						})
					});
					getJsScript('include/js/PopupProductListDoubleClicks.js', function () {
						var PopupProductListDoubleClick = new PopupProductListDoubleClicks(crmpopupobj);
						PopupProductListDoubleClick.setProductListDoubleTip();
					});
					DelProgressObjs();
				}
			});
	}
	//显示
	this.show=function(){
		var base_url = 'index.php?';
		var urlstring = that.geturl();
		if (!urlstring){
			return false;
		}
		if(ld(this.rowobj).find(' #'+this.fieldname) && ld(this.rowobj).find(' #'+this.fieldname).val() > 0){
			urlstring+='&keywords='+encodeURIComponent(ld(this.rowobj).find(' #'+this.fieldname+'_name').val());
		}
		var  selectsearchpopupobj=selectSearchPopup.load('',"","",CrmPopup.getSmallpopupwidth(),that.module,"","","","",that.referencemodule);
		selectsearchpopupobj.prevshow();
		if(urlstring){
			ldAjax(base_url,urlstring,function(data){
				if(data.code==1)
				{
					selectsearchpopupobj.setParams(data.result.title,"","",CrmPopup.getSmallpopupwidth(),that.module,"","","","",that.referencemodule);

					CrmPopup.setPopupobjHtmlContent_scroll_jquery(selectsearchpopupobj,data.result.content)
					// selectsearchpopupobj.show(data.result.content);
					selectsearchpopupobj.rowindex = that.rowindex;
					selectsearchpopupobj.detailcolumnname = that.fieldname;
					selectsearchpopupobj.selectfieldtype='detailfield';
					selectsearchpopupobj.popuptype='select_related_popup';
					if(data.result.fullscreen=='yes'){
						selectsearchpopupobj.switchFullscreen();
					}
					if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined"){
						cls_wxOpenDataobj.bindAllOpenDataByPopupObj(selectsearchpopupobj);	//通讯录(pc端企业微信)
					}
					var popupobj = CrmPopup.getPopupObj("last");
					ld("#"+popupobj.divid+" [name=search]").unbind('click').on('click',function(){
						that.Search();
					});

					ld("#"+popupobj.divid +" [name=popupListViewContents] a[referencemodule="+that.referencemodule+"] ").each(function(){
						ld(this).unbind('click').on('click',function(){
							//超链接点击事件  // ls 20221208 BUG0059676 出差及日常费用报销单，表体字段“客户名称”无法选客户
							if (account_version == 'probiotic' && (that.referencemodule == 'CustomForm23' || that.referencemodule == 'CustomForm22')){
								//ls 20221111 XUQIU1000848  普罗定制开发表单特殊带入需求(弹窗点击“超链接”字段时带出赋值)
								that.setvaluePuluo(this,that.rowindex);
							}else{
								that.setvalue(this,that.rowindex);
							}
						})
					});
					//zkt 20230524 BUG0066861 （http://222.173.113.110:10190/crm）8499版本，目标管理CustomForm22，在分录中选择“客户经理”时，其他行也会变成该成员，不能做到一行一个成员。 
                    ld("#"+popupobj.divid +" #btnselectMoreRecord").attr('onclick','').unbind('click').on('click',function(){
                        that.selectMoreRecordByrow(that.referencemodule,that.fieldname,that.module,that.rowindex);
					});
                    //zkt 20221010 BUG0057125在费用报销单，单据分录中，点击‘源单’之后的加号，进入搜索界面，光标应该停留在搜索框（查找内容）里面。涉及合同订单里的选择源单后的框，合同订单里的团队成员
                    if(ld("#"+popupobj.divid+" [name=pop_search_text]").length>0){
                        ld("#"+popupobj.divid+" [name=pop_search_text]").focus();
                    }

					//树结构调整高度
					if (ld('#'+popupobj.divid).find('#isshowPopupModuleListTree') != undefined && ld('#'+popupobj.divid).find('#isshowPopupModuleListTree').val() == 'yes'){
						PopupModuleListTree.setHeight();
					}

					popupobj.detail_selectReferenceobj = that;
					popupobj.getSearch=function (){
						this.detail_selectReferenceobj.Search();
					};

					DelProgressObjs();
				}else{
					selectsearchpopupobj.CancelEvent();
					MessagePopup.TipOne_warning(data.msg);
				}
			});
		}
	}

	//获取链接
	this.geturl=function(){
		var keyids = '';
		//选择源单
      
		if(this.bigtype == 'selectsource'){
		
			if(ld(this.rowobj).find(' #select_'+this.fieldname).length > 0){
				var sourcemodule = ld(this.rowobj).find(' #select_'+this.fieldname).first().val();
               // alert(sourcemodule);
				if(empty(sourcemodule)){
				    //alert(ld('#'+this.module_popupobj.divid+' [name="detail_selectsource"]').size());
					if(ld('#'+this.module_popupobj.divid+' [name="detail_entitytype"]').length > 0){
					 //获取原单列名称
					 
						var confirm_str = arrJsPopLabel['pleaseselect'] + ld('#'+this.module_popupobj.divid+' [name="detail_entitytype"]').first().html();
						RemindsMsg("","LdPopWidth400px",this.module,"yes","yes",confirm_str);
						return false;
					}
					return false;
				}else{
					this.referencemodule = sourcemodule;
				}
			}
			//保留原先  - 选择源单的逻辑
			if(CrmPopup.isExistsObj(this.module_popupobj.divid,'account_id')){
				if(CrmPopup.getHtmlobjval(this.module_popupobj.divid,'account_id')!=0)
					keyids=CrmPopup.getHtmlobjval(this.module_popupobj.divid,'account_id');
			}
		}
		// var urlstring='module=Users&action=UsersAjax&file=select_related_popu&ajax=true&selectmodule='+this.referencemodule+'&frommodule='+this.module+'&keyids='+keyids+"&type=tabdetail_"+this.rowindex;
		var urlstring='module=Users&action=UsersAjax&file=select_related_popu&selectmodule='+this.referencemodule+'&frommodule='+this.module+'&keyids='+keyids+"&type=tabdetail_"+this.rowindex;
		urlstring+="&return_columnname="+this.fieldname;
		urlstring+="&fieldname="+this.fieldname+"&selectrelationfrom=entry";
		var popupobj = CrmPopup.getlastPopupObjByPageType("create_edit_modulepage");
		//duan 20240419 收款单,付款单分录选择单据时,增加源单类型获取,用于判断字段信息
		if(this.module == 'SendCashBill' || this.module == 'CashBill'){
			urlstring+="&sourcemodule="+ld('#'+popupobj.divid+ ' #selectsource').val();
		}
		var  requestvalues=getPageValueByCrmPopupFields(popupobj);
		//获取分录行数据
		var detailrequestrowvalues = getDetailRowValuesarr(popupobj,that.rowobj);

        urlstring+="&requestvalues="+encodeURIComponent(requestvalues['requestvalue']);
        urlstring+="&sensitiverequestfield="+encodeURIComponent(requestvalues['sensitiverequestfield']);
        urlstring+="&detailrequestrowvalues="+encodeURIComponent(JSON.stringify(detailrequestrowvalues));
		return urlstring;
	}

	//查询
	this.Search=function(){
		var base_url = 'index.php?';
		var urlstring = that.geturl();
		var popupobj = CrmPopup.getPopupObj("last");
		if(CrmPopup.isExistsObj(popupobj.divid,"pop_search_text")&&ld("#"+popupobj.divid+" [name=pop_search_text]").val()!="")
		{
			urlstring+='&keywords='+encodeURIComponent(ld("#"+popupobj.divid+" [name=pop_search_text]").val());
		}
		urlstring += '&search_type=true';
		urlstring += '&ajax=true';
		if (ld('#'+popupobj.divid +' [name=isshowPopupModuleListTree]') != undefined && ld('#'+popupobj.divid +' [name=isshowPopupModuleListTree]').val() == 'yes'){
			urlstring += '&isshowModuleListTree=yes';
		}

		//zkt 20240104 BUG0077942 租赁付款单选源单租赁付款计划时，按字段【最晚付款日期】进行筛选时，【租赁开始日期】也会进行筛选
		if(ld('#'+popupobj.divid+' #select_searchfieldname').length>0){
			var select_searchfieldname = ld('#'+popupobj.divid+' #select_searchfieldname').val();
			urlstring += '&select_searchfieldname='+select_searchfieldname;
		}
        // var  requestvalues=getPageValueByCrmPopupFields(CrmPopup.getPopupObj("lastprev"));
        // urlstring+="&requestvalues="+encodeURIComponent(requestvalues['requestvalue']);
        // urlstring+="&sensitiverequestfield="+encodeURIComponent(requestvalues['sensitiverequestfield']);
		ldAjax(base_url,urlstring,function(data){
			if(data.code == 1){
				var crmpopupobj=CrmPopup.getPopupObj("last");
				CrmPopup.findHtmlobj(crmpopupobj.divid,"popupListViewContents").html(data.result.content);
				ld("#"+crmpopupobj.divid +" [name=popupListViewContents] a[referencemodule="+that.referencemodule+"] ").each(function(){
					ld(this).unbind('click').on('click',function(){
						that.setvalue(this,that.rowindex);
					})
				})
				//wym 231117 BUG20240320-15 搜索后全屏或缩小要保持
				if(ld('#'+crmpopupobj.divid+'_fullscreen').length>0){
					var pop_switchtotype = ld('#'+crmpopupobj.divid+'_fullscreen').attr('switchtotype');
					if(pop_switchtotype=='recovery'){
						crmpopupobj.Fullscreencallback('fullscreen');
					}else{
						crmpopupobj.Fullscreencallback('recovery');
					}
				}
				//树结构设置高度
				if (ld('#'+crmpopupobj.divid).find('#isshowPopupModuleListTree') != undefined && ld('#'+crmpopupobj.divid).find('#isshowPopupModuleListTree').val() == 'yes'){
					PopupModuleListTree.setHeight();
				}
				DelProgressObjs();
			}
		});
		
	}

	this.setvaluePuluo = function(obj,rowid){
		var referencemodule = ld(obj).attr('referencemodule');
		var frommodule = ld(obj).attr('frommodule');
		var record = ld(obj).attr('record');
		var linkname = ld(obj).attr('linkname');
		var columnname = ld(obj).attr('columnname');
		var prepopupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
		var popupobj=CrmPopup.getPopupObj("last");
		if(prepopupobj!=popupobj)
			popupobj.CancelEvent();
		getValuePuluo(frommodule,columnname,referencemodule,record);
	}

	//选择：模糊查询也是调用的这个函数，所以这里另外传入了rowid
	this.setvalue = function(obj,rowid){
		var referencemodule = ld(obj).attr('referencemodule');
		var record = ld(obj).attr('record');
		var linkname = ld(obj).attr('linkname');
		var columnname = ld(obj).attr('columnname');
		var  prepopupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
		var tableobj=prepopupobj.getDetailTableObj();
		var rowobj=ld(tableobj).find("tr[rowindex="+rowid+"]");
		if(ld(rowobj).find(' [detailcolumnname="'+columnname+'"]').length > 0){
			var entityname = decodeURIComponent(linkname);
			ld(rowobj).find(' #'+columnname).val(record);
			ld(rowobj).find(' #'+columnname+'_name').get(0).value = entityname;//ls241211 普通发票（5%）这种decodeURI会报错
			ld(rowobj).find(' #'+columnname+'_name').get(0).disabled  = true;
			ld(rowobj).find(' #'+columnname+'_name').get(0).style.cursor = 'not-allowed';
			if(columnname == 'entitytypeid')
				getRelatedData(this.module,record,columnname,rowid);
			var popupobj=CrmPopup.getPopupObj("last");
			if(prepopupobj!=popupobj)
				 popupobj.CancelEvent();
			that.getRelatedModuleField(referencemodule,record,rowid,columnname);
			if(!empty(prepopupobj.detail2mainformulaobj)){
				var param = [];
				param['data'] = {'formulacolumn': columnname};
				prepopupobj.detail2mainformulaobj.startComputer(param);
			}
			if(!empty(prepopupobj.common_field_event_obj)){
				prepopupobj.common_field_event_obj.common_entry_changefun(ld(rowobj).find(' #'+columnname),columnname,rowid);
			}
		}
	}

	//选择引用字段
	this.getRelatedModuleField = function(referencemodule,record,rowid,trigger_column){
		var param ={}; //传值变量
		if (!empty(record)) //为空可能是替换下拉框值的带出，不需要param
			param[trigger_column]=record;

		var  popupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
		//获取页面单据头所有的值
		var requestvalues = getPageValueByCrmPopupFields(popupobj);
		//获取页面分录字段所有的值
		if (popupobj.detaildatavalue_arr) {
			var requestdetailvalue = JSON.stringify(popupobj.detaildatavalue_arr[rowid-1]);
		}else{
			var requestdetailvalues = getPageValueByCrmPopupDetailFields(popupobj,rowid);
			var requestdetailvalue = requestdetailvalues['requestdetailvalue'];
		}

		if(this.module=='CashBill'||this.module=='SendCashBill')
		{
			// BUG20240122-45 edit:can 20240123  收款单分录字段关联开票申请单据，新增引用字段，引用销售发票申请中开票金额，但字段类型发生改变，导致开票金额字段无法带出
			var urlstring='index.php?module=Users&action=UsersAjax&file=getRelatedFieldsData_detail&ajax=true&selectmodule='+referencemodule
				+'&curmodule='+this.module+'&record='+record+'&trigger_columnname='+trigger_column+'&param='+JSON.stringify(param);
			urlstring+='&sourcemodule='+ld("#"+this.module_popupobj.divid+" #selectsource").val();
		}
		else
		var urlstring='index.php?module=Users&action=UsersAjax&file=getRelatedFieldsData_detail&ajax=true&selectmodule='+referencemodule
			+'&curmodule='+this.module+'&record='+record+'&trigger_columnname='+trigger_column+'&param='+JSON.stringify(param);
		//alert(urlstring);
		ldAjax(urlstring,{"requestvalues":requestvalues['requestvalue'],"requestdetailvalues":requestdetailvalue},function(data){
			if(data.code == 1){
				var crmpopupobj=CrmPopup.getPopupObj("last");
				var  prepopupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
				var tableobj=prepopupobj.getDetailTableObj();
				var rowobj=ld(tableobj).find("tr[rowindex="+rowid+"]");
				if(data.result != '' && data.result != undefined && data.result != 'undefined'){
					ld.each(data.result, function(key, related_info){
						//wym XUQIU1002029 单据分录引用字段自动带出值
						if(key=='attachment'){
							ld.each(related_info,function(key,relatedinfos){
								var fldname = relatedinfos['input_name'];
								var bigtype = relatedinfos['bigtype'];
								if(bigtype=='image'||bigtype=='fileattachment'){
									if(ld(rowobj).find('#'+fldname).length>0){
										var fileuploader=ld(rowobj).find('#'+fldname);
										fileuploader.find('.uploader-list').html('');
										for(var j=0;j<crmpopupobj.detailfields.length;j++){
											if(crmpopupobj.detailfields[j].fieldname==fldname){
												if(relatedinfos['value'][fldname]){
													if(!crmpopupobj.detailfilejsondata[rowid]) {
														crmpopupobj.detailfilejsondata[rowid] = [];
													}
													crmpopupobj.detailfilejsondata[rowid][fldname]=relatedinfos['value'][fldname];
													ld.each(crmpopupobj.detailimage_arr,function(i,info){
														if(info['columnname']==fldname){
															if(crmpopupobj.detailfilejsondata[rowid][fldname]){
																ld(fileuploader).html('');
																var uploadFile = new WebUploadFile();
																globalWebUploadType = uploadFile.getScript(globalWebUploadType);
																uploadFile.setDetailEvent(globalWebUploadType,fileuploader,crmpopupobj,i,rowid);
															}else{
																ld(fileuploader).find('.webuploader-pick').html('<a class="icon-attachment icon-attachments inpb-attachments">'+'</a>'+arrJsPopLabel['ADDINGATTACHMENTS']);
															}
															return false;
														}
													})
												}
											}
										}
									}
								}
							});
						}
						if(!isNaN(key)){
							ld.each(related_info,function(key,relatedinfos){
								ld.each(relatedinfos.value,function(effect_columnname,_value){
										if(ld(rowobj).find(' #'+effect_columnname).val() != undefined){
											//chj 2021/4/6 45260: （61mis.com/kfbcrm）OA表单-佣金单-新建/编辑；分录中引用的日程管理字段，复选框变为了文本框，应为复选框类型
											if(ld(rowobj).find(' #'+effect_columnname).prop("type") == 'checkbox'){
												if(_value == '是'){
													ld(rowobj).find(' #'+effect_columnname).attr("checked",true);
												}else{
													ld(rowobj).find(' #'+effect_columnname).attr("checked",false);
												}
											}else{
												ld(rowobj).find(' #'+effect_columnname).val(_value);
											}
										}

									if(relatedinfos.bigtype == 'picklist'){
										//下拉框
										var picklistcontent={};

										if(_value.length > 0){
											for(var j=0;j<_value.length;j++)
											{
												var pickvalue= _value[j];
												if(j == 0){
													ld(rowobj).find(" #"+effect_columnname).val(pickvalue[1]);
													ld(rowobj).find(" [name=cmb_span_optiontext_"+effect_columnname+"]").val(pickvalue[1]);
												}
												picklistcontent[pickvalue[0]]=pickvalue[1];
											}

											//替换select值
											ld(rowobj).find(" #"+effect_columnname).empty();
											var strhtml = '';
											ld.each(picklistcontent,function(index,content){
												strhtml += '<option value="'+content+'">'+content+'</option>';
											});

											ld(rowobj).find(" #"+effect_columnname).html(strhtml);
										}else{
											ld(rowobj).find(" #"+effect_columnname).val('');
											ld(rowobj).find(" [name=cmb_span_optiontext_"+effect_columnname+"]").val('');
										}
										var cls_resetComboxHtmlobj=new cls_resetComboxHtml(effect_columnname);
										cls_resetComboxHtmlobj.setPopupObj(prepopupobj);
										cls_resetComboxHtmlobj.setDetailFieldRowIndex(rowid);
										cls_resetComboxHtmlobj.setPickListContent(picklistcontent);

										cls_resetComboxHtmlobj.removeAllLi(effect_columnname);
										cls_resetComboxHtmlobj.setEvent();
									}else if(relatedinfos.bigtype != 'reference'){
										if(ld(rowobj).find(' #span_'+effect_columnname).val() != undefined){
											//zkt 20240808 BUG20240730-39 角色职责，引用到甲乙方项目成员模块 字段引用过来，不换行了
											ld(rowobj).find(' #span_'+effect_columnname).html(_value.replace(/\n/g, "<br>\n"));
										}
									}

										//引用关联选择单据字段赋值
										//duan 20230228 数据库特殊配置，非产品分录引用关联选择单据字段，同时这个字段可直接选择单据
										if((relatedinfos.relatedmodulefield == 'yes'&&relatedinfos.parentbigtype == 'reference')||relatedinfos.bigtype == 'reference'){
											ld(rowobj).find(' #'+effect_columnname).val(relatedinfos.rawvalue[effect_columnname]);
											ld(rowobj).find(' #'+effect_columnname+'_name').val(_value);
											if(ld(rowobj).find(' #'+effect_columnname+'_name').val() != undefined){
												if(ld(rowobj).find(' #'+effect_columnname+'_name').prop("tagName").toLowerCase()=='span'){
													ld(rowobj).find(' #'+effect_columnname+'_name').html(_value);
												}

											}
											//zkt 20240528 BUG20240524-49  计划 分录中加了选客户字段，也加了引用字段引用客户上的BU线，但是带不出来
											if(ld(rowobj).find(' #span_'+effect_columnname+'').val() != undefined){
												if(ld(rowobj).find(' #span_'+effect_columnname+'').prop("tagName").toLowerCase()=='span'){
													ld(rowobj).find(' #span_'+effect_columnname+'').html(_value.replace(/\n/g, "<br>\n"));
												}

											}
										}
										//字段公式
										if(ld.inArray(effect_columnname,crmpopupobj.fieldformulaobj.formulaneedColumnarr)>=0)
										{
											if(relatedinfos.isproductdetails == 'yes')
												crmpopupobj.fieldformulaobj.changedatabyColumnname(effect_columnname,rowid);
											else{
												crmpopupobj.fieldformulaobj.setValueByFormula(ld(rowobj).find(" #"+effect_columnname),rowid);
												crmpopupobj.fieldformulaobj.haveFinishedFormulaColumnsarr=[];//BUG0059893 ls 20221214 带出值计算后也需要清空
												crmpopupobj.fieldformulaobj.finishedcolumncount=[];
											}

										}
										//edit:can 60937 【苏州灵当】V8.4.8.6（https://kh.xiaoshou360.com/suzhould/）报销平台->报销面单模块（原自定义表单26），表头报销金额和发票金额是新增字段（设置分录函数，自动计算分录的报销金额），现在不计算了（系统部署在上海总部）
										crmpopupobj.detail2mainformulaobj.CheckisComputer([effect_columnname]);
									});
							})
						}
					})

				}
			}
			//zkt 20240403 BUG20240402-51  选择系统后，会冲掉部分填写的字段
			if(crmpopupobj.relatedproducttoolfield != undefined && crmpopupobj.relatedproducttoolfield.length>0&&crmpopupobj.relatedproducttoolfield[0].trigger_columnname!='')
			{
				var tmptrigger_columnnamearr = crmpopupobj.relatedproducttoolfield[0].trigger_columnname;
				if(tmptrigger_columnnamearr.indexOf(trigger_column)>-1){
					crmpopupobj.RelatedProductToolFieldtriggcols = [];
					getRelatedProductToolFieldPriceCallBack(crmpopupobj, rowid);
				}
			}

			DelProgressObjs();
			crmpopupobj.fieldformulaobj.CountsubTotal();
		});
	}
	 
	//清除引用字段
	this.clearRelatedModuleField = function(curmodule,columnname,rowid){ 
		var urlstring='index.php?module=Users&action=UsersAjax&file=getRelatedFieldsData_detail&ajax=true&curmodule='+curmodule+'&trigger_columnname='+columnname+"&clear=yes";
		ldAjax(urlstring,"",function(data){
			if(data.code == 1){
				var crmpopupobj=CrmPopup.getPopupObj("last");
				var  prepopupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
				var tableobj=prepopupobj.getDetailTableObj();
				var rowobj=ld(tableobj).find("tr[rowindex="+rowid+"]");
				if(data.result != '' && data.result != undefined && data.result != 'undefined'){
					ld.each(data.result, function(key, related_info){
						var _val = related_info.value;	//金额字段小数位，后天已经处理，这里直接赋值即可
						if(related_info.bigtype == 'reference'){
							if(!empty(related_info.curmodule_columninfo)){
								var columns = new Array();
								columns = related_info.curmodule_columninfo.split(',');
								ld.each(columns, function(key, columnname){
									if(ld(rowobj).find(' #'+columnname).val() != undefined){
										var bigtype = ld(rowobj).find(' #'+columnname).attr('bigtype');
										ld(rowobj).find(' #'+columnname).val(_val);
										ld(rowobj).find(' #span_'+columnname).html('');
										if(bigtype != undefined && bigtype == 'reference'){
											//ld(rowobj).find(" [detailcolumnname="+columnname+']').val('');
											//ld(rowobj).find(" [detailcolumnname="+columnname+']').val(arrJsPopLabel['INPUTAKEYWORDSQUERY']);
											ld(rowobj).find(" #"+columnname).attr("disabled",false);
											ld(rowobj).find(" #"+columnname).css("cursor","");
										}
                                        if(ld(rowobj).find(' #'+columnname+'_name').val() != undefined){
            								ld(rowobj).find(' #'+columnname+'_name').html(_val);
            							}
									}
								});
							}
						}else if(related_info.bigtype == 'image'||related_info.bigtype == 'fileattachment'){
							//wym XUQIU1002029 引用附件字段自动删除附件图片
							var fldname = related_info.curmodule_columninfo;
							if(ld(rowobj).find('#'+fldname).length>0){
								ld(rowobj).find('#'+fldname).find('.uploader-list').html('');
								ld(rowobj).find('#'+fldname).find('.webuploader-pick').html('<a class="icon-attachment icon-attachments inpb-attachments">'+'</a>'+arrJsPopLabel['ADDINGATTACHMENTS']);
							}
						}else{
							var effect_columnname = related_info.curmodule_columninfo;
							if(ld(rowobj).find(' #'+effect_columnname).val() != undefined){
								if(ld(rowobj).find(' #'+effect_columnname).prop("type") == 'checkbox'){
									ld(rowobj).find(' #'+effect_columnname).attr("checked",false); 
								}else{
									ld(rowobj).find(' #'+effect_columnname).val(_val);
								}
							}
							if(ld(rowobj).find(' #span_'+effect_columnname).val() != undefined){
								ld(rowobj).find(' #span_'+effect_columnname).html(_val);
							}
							//字段公式
							if(ld.inArray(effect_columnname,crmpopupobj.fieldformulaobj.formulaneedColumnarr)>=0)
							{
								if(related_info.isproductdetails == 'yes')
									crmpopupobj.fieldformulaobj.changedatabyColumnname(effect_columnname,rowid);
								else{
									crmpopupobj.fieldformulaobj.setValueByFormula(ld(rowobj).find(" #"+effect_columnname),rowid);
									crmpopupobj.fieldformulaobj.haveFinishedFormulaColumnsarr=[];
									crmpopupobj.fieldformulaobj.finishedcolumncount=[];
								}
							}
						}
						
					})
				}
				DelProgressObjs();
				crmpopupobj.fieldformulaobj.CountsubTotal();
			}
		});
	}
    //zkt 20230524 BUG0066861 （http://222.173.113.110:10190/crm）8499版本，目标管理CustomForm22，在分录中选择“客户经理”时，其他行也会变成该成员，不能做到一行一个成员。 
    //多选用户字段，单选按钮，根据选择顺序显示结果-------分录
    this.selectMoreRecordByrow = function(module,fieldname,selectmodule,rowid){
        var popupobj=CrmPopup.getPopupObj("last");
        var  prepopupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
		
        var selected_objs = ld("#"+popupobj.divid+" [name=selected_id]");
        var allselected_obj = ld("#"+popupobj.divid+" [name=select_all]");
        var cur_sequence = parseInt(allselected_obj.attr('cur_sequence'));
        
        var tableobj=prepopupobj.getDetailTableObj();
		var rowobj=ld(tableobj).find("tr[rowindex="+rowid+"]");
        
        
        var id_str= ld(rowobj).find(" input#"+fieldname).val();
        var value_str= ld(rowobj).find(" input#"+fieldname+"_name").val();
        var value_arr = new Array();
        var id_arr = new Array();
        if(value_str !=''&&id_str !=''){
            value_arr = value_str.split(',');
            id_arr =  id_str.split(',');
        }
        
        var tmp_id = 0;
        var tmp_value = '';
        var count = 0;
        var sequence = 0;
        var i = 0;
        var tmp_objs ;
        
        for(i=0;i<cur_sequence;i++){
            ld.each(selected_objs,function(){
                sequence = ld(this).attr('sequence');
                if(ld(this).is(':checked')&&sequence==i){
                    tmp_id = ld(this).attr('billinfo');
                    //已选择的用户不再加入
                    if(tmp_id>0&&id_arr.indexOf(tmp_id)==-1){
                        tmp_value = ld(this).attr('link_field_value');
                        id_arr.push(tmp_id);
                        value_arr.push(tmp_value);
                    }
                    count++;
                }
            });
        }
        
        if(count==0){
            audioRemindsMsg("","LdPopWidth400px","","yes","yes","");
            return false;
        }
        id_str = id_arr.toString();
        value_str = value_arr.toString();
        
        ld(rowobj).find(" input#"+fieldname).val(id_str);
        ld(rowobj).find(" input#"+fieldname+"_name").val(value_str);
        ld(rowobj).find(" input#"+fieldname+"_name").attr("title",value_str);
        ld(rowobj).find(" input#"+fieldname+"_name").attr("disabled",true);
        ld(rowobj).find(" input#"+fieldname+"_name").css("cursor",'not-allowed');
        ld(rowobj).find(" input#"+fieldname).change();
        
        popupobj.CancelEvent();
    }
}
//回车事件
function detail_keydownsearch(event,frommodule,selectmodule,fieldname,rowid){
	var e = event || window.event;
		if(e.keyCode == 13)
		{
			var popupobj = CrmPopup.getPopupObj('last');
			popupobj.getSearch();
			// var reference_arr=[];
			// reference_arr.push(selectmodule);
			// reference_arr.push(frommodule);
			// reference_arr.push(fieldname);
			// reference_arr.push(rowid);
			// var fun_detail_selectReference = new detail_selectReference(reference_arr,event,rowid);
			// fun_detail_selectReference.Search();
		}
	
}