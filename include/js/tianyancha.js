var open_search_form_obj;//from obj
var open_search_form;
var open_search_obj;//div obj
//当前匹配区域总行数
var trRowNum;
//匹配项 当前选择行数
var trNum = 0;
var tianyanchaajaxobj=undefined;
var tianyanchatime=undefined;
function getTianyanByKeyWords(obj,rowid,module,event){
    var popupobj=CrmPopup.getPopupObj("last");
    
	open_search_obj = ld('#'+popupobj.divid+' [name=check_kewords]');
	var e = event || window.event;
	if(obj.value.replace(/[ ]/g,"") != '')
    {
		//获取DIV下拉拖动高度
		var scrollHeight = open_search_obj.prop('scrollHeight');
		var scrollTrNumber = 5;
		if(e.keyCode == 40 || e.keyCode == 38){//方向键(下：40，上38)
			var trHeight = scrollHeight/trRowNum;
			if(e.keyCode == 40)
			{
				if(trNum == trRowNum)
				{
					trNum = 0;
					scrollTop = 0;
				}
				if(trNum < trRowNum)
					trNum++;
				//默认8行
				if(eval(trNum) > eval(scrollTrNumber))
				{
					scrollTop = scrollTop+trHeight;
				}
			}
			else{
				if(trNum == 1)
				{
					trNum = trRowNum;
					scrollTop = scrollHeight;
				}
				else if(trNum > 1)
				{
					trNum--;
					if(eval(trRowNum) - eval(trNum) > eval(scrollTrNumber))
					{
						scrollTop = scrollTop-trHeight;
					}
				}   
			}
			open_search_obj.scrollTop(scrollTop);
			trMouseover(trNum);
			return false;
		}
		else if(e.keyCode == 13)    //回车键13
		{
			if(trNum > 0)
			{
				var tableName = ld('#selectTable_'+obj.name);
				ld('#search_tianyan_list_tr'+trNum).click();
				//scrollTop = 0;
				if (e && e.stopPropagation){
					e.stopPropagation();  
					e.preventDefault();  
				}
				else{
					e.returnValue = false; 
					e.cancelBubble=true;
				}
				open_search_obj.css('display','none');
				return false;
			}
			else
			{
				open_search_obj.css('display','none');
				return false;
			}
		}
		getTianyanSearchInfos(obj,rowid,module,event);
	}
	return false;
	
}

//@edit:zhaosk @date:2024/09/05 @reason:调天眼查api
/**
 *
 * @param obj
 * @param rowid
 * @param module
 * @param event
 */
function getTianyanSearchInfos(obj,rowid,module,event){
	var popupobj=CrmPopup.getPopupObj("last");

	open_search_obj = ld('#'+popupobj.divid+' [name=check_kewords]');
	if(obj.value.replace(/[ ]/g,"") != '')
	{
		//输入内容包含英语、数字及空格时不进行查询
		var regNumStr = /\w+/; //验证数字0-9、字母A-Za-z的任意最少出现1次。
		//var regSpace = /\s/;//空格
		if(!empty(obj.value) && obj.value.length>=2&&(!regNumStr.test(obj.value)&&(obj.value).indexOf(" ")<0)){
			//ld('#rptContentLoading').show();
			var urlstring = 'module=Users&action=UsersAjax&file=GetTianYanSearchInfo&ReportHeader=dheader&selectmodule='+module+'&permit=yes';
			var searchText = encodeURIComponent(obj.value);//关键字
			urlstring += '&keywords='+searchText;
			urlstring += '&open_type=list';
			if(tianyanchaajaxobj!=undefined)
			{

				tianyanchaajaxobj.abort();
			}

			if(tianyanchatime!=undefined)
			{
				clearTimeout(tianyanchatime);
			}
			tianyanchatime=setTimeout(function(){
				tianyanchaajaxobj=ldAjaxsyncNoProgress("index.php?",urlstring,function (ajaxdata){
					if(ajaxdata.code == -1){
						var confirm_str = data.msg;
						//创建提示弹出层
						RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
						return false;
					}
					else{
						restobj = ajaxdata.result;
						if(restobj.state == 'no'||restobj.permit == 'no')
						{
							//无任何记录

							open_search_obj.css('display','none');
							open_search_obj.html('');
						}
						else
						{
							//显示模糊查询内容
							var info = '<table id="search_tianyan_list" class="SelTabPro" width="100%" border="0" cellspacing="0" cellpadding="0">';
							for(var i = 0; i < Object.keys(restobj.entries).length; i++){
								var tmpsearchkeywords = obj.value;
								var entityname = restobj.entries[i]['name'];
								entityname = entityname.replace(tmpsearchkeywords,'<label style="color:blue">'+tmpsearchkeywords+'</label>');
								var input_name = restobj.entries[i]['title'];
								if(entityname != ''){
									trRowNum++;
									info += '<tr width="100%" height="25" id="search_tianyan_list_tr'+trRowNum+'" onmouseover="trMouseover('+trRowNum+')" onmousedown="open_selectrelated(this,\''+module+'\',\''+input_name+'\')" title="'+decodeURI(input_name)+'">';
									info += '<td id="selectRow"><div>'+entityname+'</div></td>';
									info += '</tr>';
								}
							}
							info += '</table>';
							var swidth = obj.clientWidth+2;//+2后看起来正常
							open_search_obj.css('width',swidth+'px');
							open_search_obj.css('display','block');
							open_search_obj.css('left','10px');
							if(popupobj.pagetype == undefined && popupobj.pagetype == "ListEditPagePopup"){
								open_search_obj.css('left','20px');
							}
							open_search_obj.html(info);
							open_search_obj.scrollTop(0);
						}
						//bug0034257: 客户新增、编辑界面>客户名称字段：输入公安弹出层的下拉选项，点击空白处下拉框不会消失。
						ld(document).one("click",
							function() { //对document绑定一个影藏Div方法
								ld('.SearchResult').hide();
						});
					}
				});
			},350);


		}else{
			ld('#rptContentLoading').hide();
			open_search_obj.css('display','none');
			open_search_obj.html('');
			if(tianyanchaajaxobj!=undefined)
				tianyanchaajaxobj.abort()
		}
	}
}
/**
 * edit:chj
 * date:2014-9-2
 * reason:鼠标移动到匹配项
 **/
function trMouseover(rowid)
{
    var tableName = document.getElementById('search_tianyan_list');
    var rowcount = tableName.rows.length;
    for(var i=0;i<rowcount;i++)
    {
        var trId = tableName.rows[i].id;    //每一行ID
        if(i == rowid - 1){
			ld('#'+trId+' td' ).css('background-color','#e7f4fe');
        }else{
			ld('#'+trId+' td' ).css('background-color','');
        }   
    }
    trNum = rowid;
}

function open_selectrelated(obj,module,entityname){
	if(CrmPopup.isPopup()){
		var divid=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1].divid;
		var inputobj = ld(obj).parents('div[name=check_kewords]').siblings('input').eq(0);//2024-3-18 xxy 模糊查询点击公司名称回填到工商查询字段的input框
		ld(inputobj).val(entityname);
	}
	open_search_obj.css('display','none');
	open_search_obj.html('');
    autoBackFillTianYanContent(module,entityname);
}
function autoBackFillTianYanContent(module,keywords){
    var popupobj=CrmPopup.getPopupObj('last');
    
    if(!empty(keywords)){
		var urlstring = 'index.php?module=Users&action=UsersAjax&file=GetTianYanSearchInfo&ReportHeader=dheader';
		urlstring += '&keywords='+encodeURIComponent(keywords);
		urlstring += '&open_type=info';
        urlstring += '&frommodule='+module;
		ldAjaxNoProgresssync(urlstring,"",function(data){
			if(data.code==1){
				var restobj = data.result;
				if(restobj.entries != '')
				{
				    var popupobj=CrmPopup.getPopupObj("last");
                    var backfillarr=restobj.backfillarr;
                	var divid=popupobj.divid;
                    //详细地址信息储存于poi_address中
                    var pioaddress_arr = ['address','state','city','district','point','country'];
                    var detailaddress_arr = ['bill_country','bill_state','bill_city','bill_area','bill_street','street'];
                    var mapneedflag = 0;
                    var mapneedarr = new Array();
					var have_locationaddress = 'no';
                    //对设置的回填字段进行回填
                    for(var i = 0 ; i<backfillarr.length ; i++){
                        var tianyanchaname = backfillarr[i].tianyanchaname;
                        var trancolumnname = backfillarr[i].trancolumnname;
                        if(trancolumnname == 'null') continue;
						var fieldname = trancolumnname;
						if(backfillarr[i].trancolumnname != undefined){
							fieldname = backfillarr[i].trancolumnname;
						}
						//zkt 20231206 BUG0076216 1、客户模块，开启天眼查模糊查询功能，输入公司全称后，工商信息都能自动带出，但是国家 省份 城市 区域 详细地址字段没有带出来
                        if(pioaddress_arr.indexOf(tianyanchaname)>-1){
                            var backfillvalue = restobj.poi_address[tianyanchaname];//回填内容
                            if(backfillvalue != undefined && backfillvalue != ''&&trancolumnname!='street'&&detailaddress_arr.indexOf(trancolumnname)>=0){
                                mapneedarr[tianyanchaname] = backfillvalue;
                                mapneedflag++;
                            }
                        }
                        else{
                            var backfillvalue = restobj.entries[tianyanchaname];//回填内容
                        }
                        if(CrmPopup.findHtmlobj(divid,fieldname) != undefined && CrmPopup.findHtmlobj(divid,fieldname).val() != undefined && backfillvalue != undefined && backfillvalue != ''&& backfillvalue != null){
                            //回填对应字段类型为picklist时,若回填内容如不在picklist内，则添加回填内容至picklist内
                            if(backfillarr[i].type=='picklist'){
                                if(detailaddress_arr.indexOf(fieldname)>-1){
                                    CrmPopup.findHtmlobj(divid,fieldname).val(backfillvalue);
									CrmPopup.findHtmlobj(divid,'span_'+fieldname).html(backfillvalue);
                                    CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+fieldname).val(backfillvalue);
                                }
                                else{
                                    autoBackFillAddPickList(fieldname,backfillvalue);
                                }
                            }
                            else{
								if(popupobj.fieldSensitiveruleobj && !empty(popupobj.fieldSensitiveruleobj)){
									var tranfieldinfo = popupobj.fieldSensitiveruleobj.getFieldInfoBycolumnanme(trancolumnname);
									if(tranfieldinfo && tranfieldinfo.havesensitivevalue == 'yes' )
									{
										var tranfieldname = tranfieldinfo.fieldname;
										//设置值和设置小数位数是分开的
										var tmpEncryptytvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(backfillvalue,false,tranfieldinfo);//加密字段
										popupobj.fieldSensitiveruleobj.setfieldSensitiveinfo(tranfieldname,tranfieldinfo.havesensitivevalue,tmpEncryptytvalue);
									}
									else if(tranfieldinfo){
										var tranfieldname = tranfieldinfo.fieldname;
										CrmPopup.findHtmlobj(divid,tranfieldname).val(backfillvalue);
										if(tranfieldinfo.allowedit == 'no'){
											CrmPopup.findHtmlobj(divid,'span_'+tranfieldname).html(backfillvalue);
										}
										if(tranfieldinfo.uitype == 65){
											have_locationaddress = 'yes';
										}
									}
									else{
										CrmPopup.findHtmlobj(divid,trancolumnname).val(backfillvalue);
									}
								}
                            }
							if(popupobj.mainfieldformulaobj != undefined&&popupobj.mainfieldformulaobj.computerfieldnamesformula!=undefined&&popupobj.mainfieldformulaobj.computerfieldnamesformula[trancolumnname]!=undefined){
								popupobj.mainfieldformulaobj.setvaluebyformula(trancolumnname);
							}
                        }
                    }
                    //地图
                    var span_regLocation_point = restobj.poi_address['point'];
                	var point_arr = span_regLocation_point.split(',');
                	location_lat = point_arr[0];
                	location_lng = point_arr[1];
					//zkt 20240726 BUG20240724-44 （西安良医）客户：工商模糊查询会错误的回填联系人住址字段，回填字段里面并没有设置这个字段（kfbcrm也有这个问题）
                	if(mapneedflag>=5&&have_locationaddress == 'yes')
                		scriptMap(mapneedarr['address'],mapneedarr['district'],mapneedarr['city'],mapneedarr['state'],mapneedarr['country']);
					if(popupobj.fieldruleobj != undefined)
						popupobj.fieldruleobj.CheckReLoadPopup();//布局规则

				}
			}
			else if(data.code == -1){
				var confirm_str = data.msg;
				//创建提示弹出层
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			}
			
		});
		return false;
		
	}
    else{
        return false;
    }
}
//下拉框点击回填信息添加至选择列表
function autoBackFillAddPickList(fldname,fldvalue){
    var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var span_flag = 0;
	if(popupobj.picklistcontent!=null&&popupobj.picklistcontent!=undefined){
		for(var k=0;k<popupobj.picklistcontent.length;k++)
		{
			//下拉框
			var fieldname=popupobj.picklistcontent[k].fieldname;
			if(fieldname == fldname){
				var picklist_value = popupobj.picklistcontent[k].optionvalue;
				for(var i=0;i<picklist_value.length;i++)
				{
					var pick_text=picklist_value[i][0];
					if(pick_text == fldvalue){
						span_flag = 1;
					}
				}
			}
		}
	}
	if(span_flag != 1){
		var surl = 'index.php?module=PickList&action=PickListAjax&file=ShowPickListSet&mode=showpicklist&modulename='+popupobj.module+"&fieldname="+fldname;
		 var comboxarr = [];
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				ld.each(data.result.content,function(_key,picklist_value){
					var comboxtext = {'type':''+picklist_value.name+'','oldval':''+picklist_value.value+'','value':''+picklist_value.value+''};
					comboxarr.push(comboxtext);
				})
				//追加的值
				var comboxtext = {'type':'new','oldval':'','value':fldvalue};
				comboxarr.push(comboxtext);
				var comboxjson = JSON.stringify(comboxarr);
				var url='index.php?module=PickList&action=PickListAjax&file=PickListActions&mode=save';
				ld.ajax({
					url:url,
					type: 'POST',
					data:'fld_module='+popupobj.module+'&fieldname='+fldname+'&comboxjson='+encodeURIComponent(comboxjson)+'&selectvalue='+fldvalue,
					dataType:'json',
					async: false,//
					timeout: 20000,
					error: function(XMLHttpRequest, textStatus, errorThrown) {
					},
					success: function(data)
					{
						if(data.code==1)
						{
							var fieldname = fldname;
							coverComboxContent(data.result,fieldname);
							popupobj.picklistobjarray[fieldname].picklistcontentarray=data.result.selecttext;
						  
							for(var i=0;i<popupobj.picklistobjarray[fieldname].childdependfieldname.length;i++)
							{
								var childfieldname=popupobj.picklistobjarray[fieldname].childdependfieldname[i];
								if(popupobj.picklistobjarray[childfieldname]!=undefined)
									popupobj.picklistobjarray[childfieldname].picklistdepency=null;
								
							}
							if(popupobj.picklistobjarray[fieldname].parentdependfieldname!="")
							{
								 //重新给级联字段赋值(函数)
								 popupobj.picklistobjarray[fieldname].getpicklistDepencyByParentFieldname();
							}
							CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+fldname).val(fldvalue);
							CrmPopup.findHtmlobj(divid,fldname).val(fldvalue);
						}
					}
				})
			}
		})
	}else{
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+fldname).val(fldvalue);
		CrmPopup.findHtmlobj(divid,'span_'+fldname).html(fldvalue);
		CrmPopup.findHtmlobj(divid,fldname).val(fldvalue);
	}
}

function BackFillAddPickList(fldname,fldvalue){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var prevpopupobj=CrmPopup.getPopupObj("lastprev");
	var prev_divid=prevpopupobj.divid;
	var span_flag = 0;
	if(prevpopupobj.picklistcontent!=null&&prevpopupobj.picklistcontent!=undefined){
		for(var k=0;k<prevpopupobj.picklistcontent.length;k++)
		{
			//下拉框
			var fieldname=prevpopupobj.picklistcontent[k].fieldname;
			if(fieldname == fldname){
				var picklist_value = prevpopupobj.picklistcontent[k].optionvalue;
				for(var i=0;i<picklist_value.length;i++)
				{
					var pick_text=picklist_value[i][0];
					if(pick_text == fldvalue){
						span_flag = 1;
					}
				}
			}
		}
	}
	if(span_flag != 1){
		var surl = 'index.php?module=PickList&action=PickListAjax&file=ShowPickListSet&mode=showpicklist&modulename='+prevpopupobj.module+"&fieldname="+fldname;
		 var comboxarr = [];
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				ld.each(data.result.content,function(_key,picklist_value){
					var comboxtext = {'type':''+picklist_value.name+'','oldval':''+picklist_value.value+'','value':''+picklist_value.value+''};
					comboxarr.push(comboxtext);
				})
				//追加的值
				var comboxtext = {'type':'new','oldval':'','value':fldvalue};
				comboxarr.push(comboxtext);
				var comboxjson = JSON.stringify(comboxarr);
				var url='index.php?module=PickList&action=PickListAjax&file=PickListActions&mode=save';
				ld.ajax({
					url:url,
					type: 'POST',
					data:'fld_module='+prevpopupobj.module+'&fieldname='+fldname+'&comboxjson='+encodeURIComponent(comboxjson)+'&selectvalue='+fldvalue,
					dataType:'json',
					async: false,//
					timeout: 20000,
					error: function(XMLHttpRequest, textStatus, errorThrown) {
					},
					success: function(data)
					{
						if(data.code==1)
						{
							var fieldname = fldname;
							coverComboxContent(data.result,fieldname);
							prevpopupobj.picklistobjarray[fieldname].picklistcontentarray=data.result.selecttext;
						  
							for(var i=0;i<prevpopupobj.picklistobjarray[fieldname].childdependfieldname.length;i++)
							{
								var childfieldname=prevpopupobj.picklistobjarray[fieldname].childdependfieldname[i];
								if(prevpopupobj.picklistobjarray[childfieldname]!=undefined)
									prevpopupobj.picklistobjarray[childfieldname].picklistdepency=null;
								
							}
							if(prevpopupobj.picklistobjarray[fieldname].parentdependfieldname!="")
							{
								 //重新给级联字段赋值(函数)
								 prevpopupobj.picklistobjarray[fieldname].getpicklistDepencyByParentFieldname();
							}
							CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_'+fldname).val(fldvalue);
							CrmPopup.findHtmlobj(prev_divid,fldname).val(fldvalue);
						}
					}
				})
			}
		})
	}else{
		CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_'+fldname).val(fldvalue);
		CrmPopup.findHtmlobj(prev_divid,'span_'+fldname).html(fldvalue);
		CrmPopup.findHtmlobj(prev_divid,fldname).val(fldvalue);
	}
	/*ld('#'+prev_divid +' [name=cmb_ul_registeredcapital] li').each(function(){
		console.log(ld(this).text());
	});*/
}


function BackFillTianYanContent(){
	var popupobj=CrmPopup.getPopupObj("last");
    var backfillarr=popupobj.backfillarr;
	var divid=popupobj.divid;
	var prevpopupobj=CrmPopup.getPopupObj("lastprev");
	var prev_divid=prevpopupobj.divid;
    
    //详细地址信息回填内容中name为span_regLocation+tianyanchaname
    var pioaddress_arr = ['address','state','city','district','point','country'];
    var detailaddress_arr = ['bill_country','bill_state','bill_city','bill_area','bill_street','street'];
    var mapneedflag = 0;
    var mapneedarr = new Array();
	var have_locationaddress = 'no';
    //对设置的回填字段进行回填
    for(var i = 0 ; i<backfillarr.length ; i++){
        var tianyanchaname = backfillarr[i].tianyanchaname;
        var trancolumnname = backfillarr[i].trancolumnname;
        var fieldname = trancolumnname;
		if(backfillarr[i].trancolumnname != undefined){
			fieldname = backfillarr[i].trancolumnname;
		}
        if(trancolumnname == 'null') continue;
        if(pioaddress_arr.indexOf(tianyanchaname)>-1){
            tianyanchaname = 'span_regLocation_'+tianyanchaname;
            var backfillvalue = CrmPopup.findHtmlobj(divid,tianyanchaname).val();//回填内容
            //street 为供应商模块详细地址
            if(backfillvalue != undefined && backfillvalue != ''&&fieldname!='street'&&detailaddress_arr.indexOf(fieldname)>=0){
                mapneedarr[fieldname] = backfillvalue;
                mapneedflag++;
            }
		}
        else{
            var backfillvalue = popupobj.entries[tianyanchaname];//回填内容
        }
        
        if(CrmPopup.findHtmlobj(prev_divid,fieldname) != undefined && CrmPopup.findHtmlobj(prev_divid,fieldname).val() != undefined && backfillvalue != undefined &&backfillvalue!=''&&backfillvalue!=null){
            
            //回填对应字段类型为picklist时,若回填内容如不在picklist内，则添加回填内容至picklist内
            if(backfillarr[i].type=='picklist'){
                if(detailaddress_arr.indexOf(fieldname)>-1){
                    CrmPopup.findHtmlobj(prev_divid,fieldname).val(backfillvalue);
                    CrmPopup.findHtmlobj(prev_divid,'span_'+fieldname).html(backfillvalue);
                    CrmPopup.findHtmlobj(prev_divid,'cmb_span_optiontext_'+fieldname).val(backfillvalue);
                }
                else{
                    BackFillAddPickList(fieldname,backfillvalue);
                }
            }
            else{
				var tranfieldinfo = prevpopupobj.fieldSensitiveruleobj.getFieldInfoBycolumnanme(trancolumnname);
				if(tranfieldinfo && tranfieldinfo.havesensitivevalue == 'yes' )
				{
					var tranfieldname = tranfieldinfo.fieldname;
					//设置值和设置小数位数是分开的
					var tmpEncryptytvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(backfillvalue,false,tranfieldinfo);//加密字段
					prevpopupobj.fieldSensitiveruleobj.setfieldSensitiveinfo(tranfieldname,tranfieldinfo.havesensitivevalue,tmpEncryptytvalue);
				}
				else if(tranfieldinfo){
					var tranfieldname = tranfieldinfo.fieldname;
					CrmPopup.findHtmlobj(prev_divid,tranfieldname).val(backfillvalue);
					if(tranfieldinfo.allowedit == 'no'){
						CrmPopup.findHtmlobj(prev_divid,'span_'+tranfieldname).html(backfillvalue);
					}
					if(tranfieldinfo.uitype == '65'){
						have_locationaddress = 'yes';
					}
				}
				else{
                	CrmPopup.findHtmlobj(prev_divid,trancolumnname).val(backfillvalue);
				}
			}
			if(prevpopupobj.mainfieldformulaobj != undefined&&prevpopupobj.mainfieldformulaobj.computerfieldnamesformula!=undefined&&prevpopupobj.mainfieldformulaobj.computerfieldnamesformula[trancolumnname]!=undefined){
				prevpopupobj.mainfieldformulaobj.setvaluebyformula(trancolumnname);
			}
        }
    }
    //地图
    var span_regLocation_point = CrmPopup.findHtmlobj(divid,'span_regLocation_point').val();
	var point_arr = span_regLocation_point.split(',');
	location_lat = point_arr[0];
	location_lng = point_arr[1];
	if(mapneedflag>=5&&have_locationaddress=='yes')
		scriptMap(mapneedarr['address'],mapneedarr['district'],mapneedarr['city'],mapneedarr['state'],mapneedarr['country']);
	
	popupobj.CancelEvent();
	if(prevpopupobj.fieldruleobj != undefined)
		prevpopupobj.fieldruleobj.CheckReLoadPopup();//布局规则
}
function getTianyanByKeyWordForInfos(input_name,stype){
	if(stype == 'edit'){	//新增编辑
		if(CrmPopup.isPopup()){
			var divid=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1].divid;
			var input_value = ld("#"+divid+" input[name="+input_name+"]").val();
		}
	}else{
	   //zkt 20220720 BUG0054012【演示账套】V8.4.6.6.2（https://www.51mis.com/hy/DEMOX1/）工商查询信息错误（账套为销售360，这个问题为通用的问题）
	   var divid=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1].divid;
		var input_value = ld('#'+divid+' input[name='+input_name+'_name]').val();	//详情页
	}
	//请输入客户工商名称
	if(empty(input_value)){
		if(input_name == 'vendorname'){
			var confirm_str = arrJsPopLabel['pleaseenterthename1'];
		}else{
			var confirm_str = arrJsPopLabel['pleaseenterthename'];
		}
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		ld('#business_accountname').attr('onclick',_click);
		return false;
	}
	if(!empty(input_value)){
	   var popupobj=CrmPopup.getPopupObj("last");
       var frommodule = popupobj.module;
		var urlstring = 'index.php?module=Users&action=UsersAjax&file=GetTianYanSearchInfo&ReportHeader=dheader';
        //zkt 20221110 BUG0058584http://gzjq2022.gnway.cc:8000/crm/(广州杰青)：客户在天眼查中有工商信息单在系统中无法查询到工商信息。 客户名称“广州JFE钢板有限公司” 
		urlstring += '&keywords='+encodeURIComponent(input_value);
		urlstring += '&open_type=info';
		urlstring += '&stype='+stype;
        urlstring += '&frommodule='+frommodule;
		ldAjax(urlstring,"",function(data){
			if(data.code==1){
				var restobj = data.result;
				if(restobj.entries == '')
				{
				    //zkt 20230327 BUG0063323工商查询超时处理arrJsPopLabel['keyexpired'];//灵当查询已过期
					var confirm_str = arrJsPopLabel['GetCustomBusinessError']+''+arrJsPopLabel['PlaceCheckTianYanChaInterface'];//获取工商信息失败，请重试！（多次查询没有结果请联系管理员检查天眼查接口信息）
                    if(restobj.code !=undefined){
						if(restobj.code==300000){
                        	confirm_str = arrJsPopLabel['thecustomerbusiness'];//该客户工商信息不存在！
						}else if (restobj.code ==300003 || restobj.code==300006){
							confirm_str = arrJsPopLabel['BusinessInterfaceExpiredOrOutOfBalance'];
						}else if(restobj.reason&&!empty(restobj.reason)){
                        	confirm_str = restobj.reason;//eg:300009 没有数据
						}else if(restobj.code === -2){
							//@edit:frank,2023-07-24,reason:XUQIU1001657 客户/服务收费管理/供应商，工商查询接口设置界面功能优化
							confirm_str = arrJsPopLabel['keyexpired'];//灵当查询已过期
						}else if(restobj.code === -3){
							confirm_str = arrJsPopLabel['INVALIDKEY'];
						}
                    }
					//创建提示弹出层
					// RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					MessagePopup.TipOne_warning(confirm_str);
					return false;
				}else{
					var popupobj=CrmPopup.getPopupObj("last");
					var crmPopupobj=CrmPopup.load("","","","LdPopWidth900px",frommodule,"","","","");
					crmPopupobj.prevshow();
                    var displayarr = restobj.displayarr;
                    var backfilllabelarr = restobj.backfilllabelarr;
					ld.each(restobj.poi_address,function(tmpkey,tmpvalue){
						if(tmpvalue == 'null'){
							restobj.poi_address[tmpkey] = '';
						}
					})
					var table_html = '';
					table_html +='<table class="ld-gongshangcx-content" border="0" cellpadding="0" cellspacing="0" width="100%" style="width: 100%; table-layout: fixed;">';
					table_html +='<tbody>';
					//zkt 20240624 BUG20240605-14  工商数据错误--搜索“连云港市农业发展集团有限公司”，出来的结果是“连云港市农商控股集团有限公司”，应在公司名称后面加一个曾用名（已和赵克听沟通，先走一个bug看一下好不好加）
					var displaycolumnarr = ['name','historyNames','creditCode','regNumber','companyOrgType','estiblishTime','legalPersonName','regCapital','actualCapital','regInstitute','orgNumber','regLocation',
					'regStatus','industry','socialStaffNum','websiteList','phoneNumber','staffNumRange','email','type','percentileScore','isMicroEnt','property3','regCapitalCurrency','actualCapitalCurrency','bondType',
					'bondNum','bondName','businessScope'];
					var tmpi = 0;
					ld.each(displaycolumnarr,function(tmpindex,tmpname){
						var tmphtml = '';
						var colspan="";
						if(tmpname == 'businessScope'){
							colspan = 'colspan="3" style="line-height: 24px;white-space: inherit;"';
						}
						var tmplabel = backfilllabelarr[tmpname];
						if(backfilllabelarr[tmpname] == undefined){
							tmplabel = arrJsPopLabel[tmpname];
						}
						tmphtml += '<td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr[tmpname]+'">'+tmplabel+'</td><td class="ld-form-item-content" '+colspan+'><span name="span_'+tmpname+'">'+restobj.entries[tmpname]+'</span>';
						if(tmpname == 'regLocation'){
							tmphtml += '<input type="hidden" value="'+restobj.poi_address['state']+'" name="span_regLocation_state">';
							tmphtml += '<input type="hidden" value="'+restobj.poi_address['city']+'" name="span_regLocation_city">';
							tmphtml += '<input type="hidden" value="'+restobj.poi_address['district']+'" name="span_regLocation_district">';
							tmphtml += '<input type="hidden" value="'+restobj.poi_address['country']+'" name="span_regLocation_country">';
							tmphtml += '<input type="hidden" value="'+restobj.poi_address['address']+'" name="span_regLocation_address">';
							tmphtml += '<input type="hidden" value="'+restobj.poi_address['address']+'" name="span_regLocation_address">';
							tmphtml += '<input type="hidden" value="'+restobj.poi_address['point']+'" name="span_regLocation_point">';
						}
						tmphtml += '</td>';
						if(tmpname == 'businessScope'&&tmpindex%2 == 1){
							table_html += '<td class="ld-form-item-label"></td><td class="ld-form-item-content"></td></tr>';
							table_html += '<tr>';
						}
						else if(tmpindex%2 == 0){
							table_html += '<tr>';
						}
						table_html += tmphtml;
						if(tmpindex%2 == 1){
							table_html += '</tr>';
						}
						else if(tmpname == 'businessScope'&&tmpindex%2 == 0){
							table_html += '</tr>';
						}
					});


                    //zkt 20221101 BUG0058199客户工商查询---客户名称在天眼查已更改---但回填没有生效  例如：苏州长光华芯光电技术有限公司
					/*table_html += '<tr><td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['name']+'">'+arrJsPopLabel['COMPANYNAME']+'</td><td class="ld-form-item-content"><span name="span_name">'+restobj.entries['name']+'</span></td>';
					table_html += '<td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['historyNames']+'">'+backfilllabelarr['historyNames']+'</td><td class="ld-form-item-content"><span name="span_historyNames">'+restobj.entries['historyNames']+'</span></td></tr>';
					table_html += '<td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['creditCode']+'">'+arrJsPopLabel['creditCode']+'</td><td class="ld-form-item-content"><span name="span_creditCode">'+restobj.entries['creditCode']+'</span></td></tr>';
					table_html += '<tr><td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['regNumber']+'">'+arrJsPopLabel['regNumber']+'</td><td class="ld-form-item-content"><span name="span_regNumber">'+restobj.entries['regNumber']+'</span></td>';
					table_html += '<td class="ld-form-item-label" ><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['companyOrgType']+'">'+arrJsPopLabel['companyOrgType']+'</td><td class="ld-form-item-content"><span name="span_companyOrgType">'+restobj.entries['companyOrgType']+'</span></td></tr>';
					table_html += '<tr><td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['estiblishTime']+'">'+arrJsPopLabel['estiblishTime']+'</td><td class="ld-form-item-content"><span name="span_estiblishTime">'+restobj.entries['estiblishTime']+'</span></td>';
					table_html += '<td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['legalPersonName']+'">'+arrJsPopLabel['legalPersonName']+'</td><td class="ld-form-item-content"><span name="span_legalPersonName">'+restobj.entries['legalPersonName']+'</span></td></tr>';
					table_html += '<tr><td class="ld-form-item-label" ><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['regCapital']+'">'+arrJsPopLabel['regCapital']+'</td><td class="ld-form-item-content"><span name="span_regCapital">'+restobj.entries['regCapital']+'</span></td>';
					//wyt 220927 XUQIU1000522 工商回填增加“实收注册资金”和“公司名称”字段（戚涛）
					table_html += '<td class="ld-form-item-label" ><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['actualCapital']+'">'+arrJsPopLabel['PAIDINREGISTEREDCAPITAL']+'</td><td class="ld-form-item-content"><span name="span_actualCapital">'+restobj.entries['actualCapital']+'</span></td></tr>';
					table_html += '<tr><td class="ld-form-item-label" ><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['regInstitute']+'">'+arrJsPopLabel['regInstitute']+'</td><td class="ld-form-item-content"><span name="span_regInstitute">'+restobj.entries['regInstitute']+'</span></td>';
					// table_html += '<tr><td class="ld-form-item-label">'+arrJsPopLabel['toTime']+'</td><td class="ld-form-item-content">'+restobj.entries['toTime']+'</td></tr>';
					// table_html += '<td class="ld-form-item-label" >'+arrJsPopLabel['approvedTime']+'</td><td class="ld-form-item-content">'+restobj.entries['approvedTime']+'</td></tr>';
					table_html += '<td class="ld-form-item-label" ><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['orgNumber']+'">'+arrJsPopLabel['orgNumber']+'</td><td class="ld-form-item-content"><span name="span_orgNumber">'+restobj.entries['orgNumber']+'</span></td></tr>';
					table_html += '<tr><td class="ld-form-item-label" ><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['regLocation']+'">'+arrJsPopLabel['regLocation']+'</td><td class="ld-form-item-content" style="line-height: 24px;white-space: inherit;"><span name="span_regLocation">'+restobj.entries['regLocation']+'</span>';
					table_html += '<input type="hidden" value="'+restobj.poi_address['state']+'" name="span_regLocation_state">';
					table_html += '<input type="hidden" value="'+restobj.poi_address['city']+'" name="span_regLocation_city">';
					table_html += '<input type="hidden" value="'+restobj.poi_address['district']+'" name="span_regLocation_district">';
					table_html += '<input type="hidden" value="'+restobj.poi_address['country']+'" name="span_regLocation_country">';
					table_html += '<input type="hidden" value="'+restobj.poi_address['address']+'" name="span_regLocation_address">';
					table_html += '<input type="hidden" value="'+restobj.poi_address['address']+'" name="span_regLocation_address">';
					table_html += '<input type="hidden" value="'+restobj.poi_address['point']+'" name="span_regLocation_point">';
					table_html += '</td>';
					table_html += '<td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['regStatus']+'">'+arrJsPopLabel['regStatus']+'</td><td class="ld-form-item-content"><span name="span_regStatus">'+restobj.entries['regStatus']+'</span></td></tr>';
					table_html += '<tr><td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['industry']+'">'+arrJsPopLabel['industry']+'</td><td class="ld-form-item-content"><span name="span_industry">'+restobj.entries['industry']+'</span></td>';
                    table_html += '<td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['socialStaffNum']+'">'+arrJsPopLabel['socialStaffNum']+'</td><td class="ld-form-item-content"><span name="span_socialStaffNum">'+restobj.entries['socialStaffNum']+'</span></td></tr>';
					table_html += '<tr><td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['websiteList']+'">'+arrJsPopLabel['websiteList']+'</td><td class="ld-form-item-content"><span name="span_websiteList">'+restobj.entries['websiteList']+'</span></td>';
                    table_html += '<td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['phoneNumber']+'">'+arrJsPopLabel['companyphoneNumber']+'</td><td class="ld-form-item-content"><span name="span_phoneNumber">'+restobj.entries['phoneNumber']+'</span></td></tr>';
					table_html += '<tr><td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['staffNumRange']+'">'+arrJsPopLabel['staffNumRange']+'</td><td class="ld-form-item-content"><span name="span_staffNumRange">'+restobj.entries['staffNumRange']+'</span></td>';
                    table_html += '<td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['email']+'">'+arrJsPopLabel['companyEmail']+'</td><td class="ld-form-item-content"><span name="span_email">'+restobj.entries['email']+'</span></td></tr>';
					//zkt 20231127 BUG0076203 将天眼查开发新增的字段显示到工商查询弹出的界面上
					table_html += '<tr><td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['type']+'">'+backfilllabelarr['type']+'</td><td class="ld-form-item-content"><span name="span_staffNumRange">'+restobj.entries['type']+'</span></td>';
					table_html += '<td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['percentileScore']+'">'+backfilllabelarr['percentileScore']+'</td><td class="ld-form-item-content"><span name="span_email">'+restobj.entries['percentileScore']+'</span></td></tr>';
					table_html += '<tr><td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['isMicroEnt']+'">'+backfilllabelarr['isMicroEnt']+'</td><td class="ld-form-item-content"><span name="span_staffNumRange">'+restobj.entries['isMicroEnt']+'</span></td>';
					table_html += '<td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['property3']+'">'+backfilllabelarr['property3']+'</td><td class="ld-form-item-content"><span name="span_email">'+restobj.entries['property3']+'</span></td></tr>';
					table_html += '<tr><td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['regCapitalCurrency']+'">'+backfilllabelarr['regCapitalCurrency']+'</td><td class="ld-form-item-content"><span name="span_regCapitalCurrency">'+restobj.entries['regCapitalCurrency']+'</span></td>';
					table_html += '<td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['actualCapitalCurrency']+'">'+backfilllabelarr['actualCapitalCurrency']+'</td><td class="ld-form-item-content"><span name="span_actualCapitalCurrency">'+restobj.entries['actualCapitalCurrency']+'</span></td></tr>';
					//zkt 20240510 BUG20240509-44  工商查询详情加“股票类型”、“股票代码”、“股票名称”（按顺序加在经营范围前），同时应允许映射到单据详情内
					table_html += '<tr><td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['bondType']+'">'+backfilllabelarr['bondType']+'</td><td class="ld-form-item-content"><span name="span_bondType">'+restobj.entries['bondType']+'</span></td>';
					table_html += '<td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['bondNum']+'">'+backfilllabelarr['bondNum']+'</td><td class="ld-form-item-content"><span name="span_bondNum">'+restobj.entries['bondNum']+'</span></td></tr>';
					table_html += '<tr><td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['bondName']+'">'+backfilllabelarr['bondName']+'</td><td class="ld-form-item-content"><span name="span_bondType">'+restobj.entries['bondName']+'</span></td>';
					table_html += '<td class="ld-form-item-label"></td><td class="ld-form-item-content"></td></tr>';
					table_html += '<tr><td class="ld-form-item-label"><img src="./themes/images/check_on.png" style="width: 14px;margin-right: 5px;'+displayarr['businessScope']+'">'+arrJsPopLabel['businessScope']+'</td><td class="ld-form-item-content" colspan="3" style="line-height: 24px;white-space: inherit;"><span name="span_businessScope">'+restobj.entries['businessScope']+'</span></td>';
					*/
					//没有天眼查id时，徐重新访问天眼查接口去获取id
					if(restobj.business_insterfacekey_deploy_value != undefined && (restobj.business_insterfacekey_deploy_value === 0 || restobj.business_insterfacekey_deploy_value === '0'))
					{
						if(!empty(restobj.entries['id'])){
							table_html += '<tr><td align="center" colspan="4"><a href="https://www.tianyancha.com/company/'+restobj.entries['id']+'" target="_blank" style="display: block;margin-top: 2px;">'+arrJsPopLabel['selectmore']+'&nbsp;<img src="./themes/softed/images/tianyancha.png" style="width: 60px;"></a></td></tr>';
						}
						else{
							table_html += '<tr><td align="center" colspan="4"><a href="" onclick="getCompanyid();" style="display: block;margin-top: 2px;">'+arrJsPopLabel['selectmore']+'&nbsp;<img src="./themes/softed/images/tianyancha.png" style="width: 60px;"></a></td></tr>';
						}
					}
					table_html +='</tbody>';
					table_html +='</table>';
					if(stype == 'edit'){	//新增编辑
                        //重写创建弹出层底部事件
                        crmPopupobj.createBottomHtml=function(){
                            var ok_class = '';
                            this.popupbottomhtml='<div class="E_pbtn" id="'+this.divid+'_popupbottom"> ';
                            var funname=this.Okfun.funname;
                            if(funname==undefined){
                                funname=this.Okfun.name;
                            }
                            this.popupbottomhtml+=this.createTextBeforeSave();
                            this.popupbottomhtml+=' <input name="button" id="'+this.divid+'_btnok" class="E_pbtnok'+ok_class+'" value="'+this.OkText+'" tagClick="'+funname+'"  type="button">';
                            this.popupbottomhtml+='<span>&nbsp;</span><input name="button" class="E_pbtncancel" value="'+this.CancelText+'" id="'+this.divid+'_btncancel" type="button">'
                            if(restobj.admin=='on'){
                                //设置回填字段
                                this.popupbottomhtml+='<a style="float: right;" onclick="setBackFillTianYanContent()">'+arrJsPopLabel['Setbackfillfield']+'</a>'
                            }
                            this.popupbottomhtml+=' </div>';
                            this.btnokid=this.divid+"_btnok";
                            this.btncancelid=this.divid+"_btncancel";
                        };
						crmPopupobj.setParams(restobj.title+'<b style="font-weight:normal;padding-left:10px;color:#999;">'+arrJsPopLabel['CHECKREFILLABLEFIELD']+'</b>',BackFillTianYanContent,"","LdPopWidth900px",'Settings',"",restobj.oktext,"",restobj.canceltext);
					}else{
						crmPopupobj.setParams(restobj.title+'<b style="font-weight:normal;padding-left:10px;color:#999;">'+arrJsPopLabel['CHECKREFILLABLEFIELD']+'</b>',"","","LdPopWidth900px",'Settings',"","","","");
					}
					CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,table_html);
                    crmPopupobj.displayarr = restobj.displayarr;
                    crmPopupobj.backfillarr = restobj.backfillarr;
                    crmPopupobj.entries = restobj.entries;
                    crmPopupobj.module = frommodule;
					DelProgressObjs();
				}
			}
			else if(data.code == -1){
				var confirm_str = data.msg;
				//创建提示弹出层
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			}
		});
		return false;
		
	}else{
        var confirm_str = arrJsPopLabel['thecustomerbusiness'];//提示内容
        //创建提示弹出层
		MessagePopup.TipOne_warning(confirm_str);
		return false;
	}
}
function getCompanyid(){
	var popupobj=CrmPopup.getPopupObj("last");
	var keywords =popupobj.entries['name'];
	if(!empty(keywords)){
		var urlstring = 'index.php?module=Users&action=UsersAjax&file=GetCompanyid';
		urlstring += '&keywords='+keywords;
		urlstring += '&open_type='+gettianchaid;
		ldAjaxNoProgress(urlstring,'',function(ajaxdata){
			if(ajaxdata.code == 1){
				window.open(ajaxdata.result.url, '_blank');
			}
		});
	}
}
//设置回填字段
function setBackFillTianYanContent(){
    var popupobj=CrmPopup.getPopupObj("last");
    var frommodule = popupobj.module;
    var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=BackFillTianYanContentSettings&mode=edit&frommodule='+frommodule;
    ldAjax(urlstring,'',function(data){
        if(data.code == 1){
            
			var crmPopupobj=CrmPopup.load("","","","LdPopWidth900px",'Users',"","","","");
			crmPopupobj.prevshow();
            crmPopupobj.setParams(data.result.title,saveBackFillTianYanContent,"",'LdPopWidth900px','Users',"",data.result.oktext,"",data.result.canceltext);
            CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
            var popupobj=CrmPopup.getPopupObj("last");
            var backfillfields_arr = data.result.backfillfields;
            for(var i=0;i<backfillfields_arr.length;i++){
                //将选择模块select下拉框设置为不显示，并在其后插入输入下拉框div
                var selectobj=ld("#"+popupobj.divid).find(" select[name="+i+"]");
                if(selectobj.length>0&&selectobj!=undefined){
                    var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj.attr("name"));
                    cls_resetComboxHtmlobj.setPopupObj(popupobj);
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj,280);
                }
            }
            crmPopupobj.fieldcount = data.result.fieldcount;
            crmPopupobj.module = frommodule;
        }
        else{
            return false;
        }
    })
    
}
//回填字段保存
function saveBackFillTianYanContent(){
    var popupobj=CrmPopup.getPopupObj("last");
    var module = popupobj.module;
    var fieldcount = popupobj.fieldcount;
    //获取映射字段选中内容
    var selectoptions = new Array();
    for(var i = 0;i<fieldcount;i++){
        var tianyanchaname = ld("#"+popupobj.divid+" [name=isfieldname_"+i+"]").val();
        var selectoption = ld("#"+popupobj.divid+" [name="+i+"]").val();
        var optionvalue = selectoption.split(':');
        //天眼查回传内容不为日期，不能映射为日期格式
        //zkt 20230717 XUQIU1001418  需要允许回填日期字段
        if(account_version != 'zhongsi'){
            if(!empty(optionvalue[2])&& (optionvalue[2]=='date'||optionvalue[2]=='datetime')){
                if(tianyanchaname != undefined && tianyanchaname != 'estiblishTime'){
                    var fieldlabel = ld("#"+popupobj.divid+" [name=isfieldname_"+i+"]").attr('tag');
                    var tipcontent = fieldlabel+arrJsPopLabel['CANNOTFIELDTODATE'];
                    RemindsMsg("","LdPopWidth400px","","yes","",tipcontent);
                    return false;
                }
            }
        }
        selectoptions.push(tianyanchaname+':'+selectoption);
    }
    var tmpurl = '';
    if(selectoptions != undefined && !empty(selectoption)){
        tmpurl = '&selectoptions='+JSON.stringify(selectoptions);
    }
	ldAjaxNoProgress("index.php?module=Settings&action=SettingsAjax&file=BackFillTianYanContentSettings&mode=save&frommodule="+module,tmpurl,function(ajaxdata){
		if(ajaxdata.code == 1){
			prevpopupobj=CrmPopup.getPopupObj("lastprev");
			//更新可回填字段内容，可回填字段显示前图标
			var backfillarr = ajaxdata.result.backfillarr;
			if(backfillarr != undefined && !empty(backfillarr))
			{
				for(var i=0;i<backfillarr.length;i++)
				{
					var backfillinfo = backfillarr[i];
					var tianyanchaname = backfillinfo.tianyanchaname;
					var trancolumnname = backfillinfo.trancolumnname;
					var fieldobj = ld("#"+prevpopupobj.divid).find(" [name=span_"+tianyanchaname+"]");
					if(fieldobj!=undefined){
						var imgobj =fieldobj.parent().prev().find('img');
						if(imgobj != undefined){
							if(trancolumnname == 'null'){
								ld(imgobj).css('display','none');
							}
							else{
								ld(imgobj).css('display','inline');
							}
						}
					}
				}
				prevpopupobj.backfillarr = backfillarr;
			}
			popupobj=CrmPopup.getPopupObj("last");
			popupobj.CancelEvent();

		}
		else if(ajaxdata.code == -1){
			RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['Savefailed']);
			return false;
		}
	});
}

//批量回填
function tianyancha_batchbackfill(module)
{
    var select_options = document.getElementById('allselectedboxes').value;
    var count=select_options.split(";").length-1;
    if(select_options=='all')
    {
        count=$('numOfRows').value;
    }
    if(count <= 0){
        RemindsMsg("","LdPopWidth400px","","yes","","");
        return false;
    }

    if(count > getMaxMassOperationLimit()) {
        var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count,getMaxMassOperationLimit(),'');
    } else {
		var confirm_str = arrJsPopLabel['HAVESELECTEDWHETHERBATCHBUSINESS'];
		confirm_str = confirm_str.replace("{Var}", count);
    }
	RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
	//确定按钮
	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		comfirmbatchbackfill(module,select_options);
	})
}
//批量回填确认
function comfirmbatchbackfill(module,select_options)
{
    
    var gstart='';
    if(document.forms['massdelete'].pagenum!=undefined)
    {
        gstart="&start="+document.forms['massdelete'].pagenum.value;
    }
    else
    {
        gstart="&start="+document.forms['massdelete'].pagenum[0].value;
    }
    var viewname=document.getElementById("viewname").value;
    var searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    var excludedRecords = $('excludedRecords').value;
	ld("#BathbackfillDiv").css('display','none');

	var url ="index.php?module=Users&action=UsersAjax&file=TianYanChaBatchBackFill&frommodule="+module+gstart;
	//zkt 树结构显示增加条件，获取树结构点击条件
	if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
	   url += '&isshowModuleListTree=yes';
	}
	var data = {idstring:select_options,SearchScope:searchScope,viewname:viewname,excludedRecords:excludedRecords};
	ld('#rptContentLoading').show();
	url = cls_encryptyurl.Puyoung_Encryptyurl(url,data);
	//zkt 20231009 XUQIU1001994 认证咨询大数据平台 数据传输速度慢，卡顿（倪总的大数据平台）
	ld.ajax({url: url,
		type: 'POST',
		data:data,
		dataType:'json',
		async: true,//
		success: function(data)
		{
			ld('#rptContentLoading').hide();
			var restobj = data.result;
			if(data.code == -1){
				RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", data.msg);
				return false;
			}


			createElementDiv('BathbackfillConvert');//创建DIV

			ld('#BathbackfillConverttitlename').html(restobj.title.value);
			ld('#BathbackfillConverttitlename').html(restobj.title.value);
			//sethtml(document.getElementById('releaseConvertcontent'),restobj.log.value);

			ld('#BathbackfillConvertcontent').html(restobj.log.value);
			ld('#BathbackfillConvertcontent').css('overflow-y','auto');
			ld('#BathbackfillConvertcontent').css('max-height','350px');

			ld('#BathbackfillConvert .E_pbtn .E_pbtncancel').unbind('click').on('click',function() {
				fninvshnew('BathbackfillConvert');
				puyoungJS_DialogBox.unblock();
				ld('#current_page_boxes').val('');//清空所选单据checkbox
				ld('#allselectedboxes').val('');//清空选择全部参数
				ld('#selectedboxes').val('');
				getListViewEntries_js(module, restobj.start.value);//刷新页面
			});
			ld('#BathbackfillConvert .E_pbtn .E_pbtnok').unbind('click').on('click',function() {

				fninvshnew('BathbackfillConvert');
				puyoungJS_DialogBox.unblock();
				ld('#current_page_boxes').val('');//清空所选单据checkbox
				ld('#allselectedboxes').val('');//清空选择全部参数
				ld('#selectedboxes').val('');
				getListViewEntries_js(module, restobj.start.value);//刷新页面
			});

			fnvshobj('', 'BathbackfillConvert');
			ld("#layer").css("z-Index",CrmPopup.zIndex);
			CrmPopup.zIndex++;
			ld('#BathbackfillConvert').css("z-Index",CrmPopup.zIndex);
			CrmPopup.zIndex++;
		},
		error:function(jqXHR, textStatus, errorThrown)
		{
			ld('#rptContentLoading').hide();
			// alert(url);
			console.log(url);
			console.log(textStatus);

			//         alert(textStatus+"create");
			//       alert(jqXHR.status+"create");
			//alert(jqXHR.readyState+"create" );

		}
	});
}