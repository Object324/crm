function set_print_view(module,obj,divid,recordid)
{
	var popupobj = CrmPopup.load("", "", "", "LdPopWidth350px", module, "", '', "", "");
	popupobj.prevshow();
	ldAjax('index.php?',"module=Settings&action=SettingsAjax&file=Printview&returnModule="+module+"&recordid="+recordid+"&mode=ajax",function(data) {
		popupobj.setParams(arrJsPopLabel['PRINT'],savePrintViewSet,"","LdPopWidth350px",module,"",data.result.oktext,"",data.result.canceltext);
		popupobj.show(data.result.content);
		popupobj.center();
		popupobj.recordid=recordid;
		popupobj.module=module;
		// ljj 20231030 BUG0073655 kfbcrm-入库单-打印模板名称过长时超出宽度 改为可搜索下拉框，需要自建obj
		var printview_obj=CrmPopup.getPopupObj("last");
		var select=ld("#"+printview_obj.divid+" [name=templateprintmoduletype]");
		if(select.length>0&&select!=undefined) {
			var cls_resetComboxHtmlobj=new cls_resetComboxHtml(select.attr("name"));
			cls_resetComboxHtmlobj.setPopupObj(printview_obj);
			cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(select, 210);
		}
		DelProgressObjs();

	});
}
function savePrintViewSet(){
	var popupobj=CrmPopup.getPopupObj('last');
	var printid=ld('#'+popupobj.divid+" #templateprintmoduletype").val();
	if(printid==0) {
		MessagePopup.TipZero_warning(arrJsPopLabel['PLEASESELECTPRINTTEMPLATES']);
		return false;
	}
	var module=popupobj.module;
	var recordid=popupobj.recordid;
	setModulePrint(module,printid,recordid);
	popupobj.CancelEvent();
}

//模块列表标签功能
function ListTagView(event,module){
	var popupobj=CrmPopup.getPopupObj("last");
	var urlstring = 'index.php?module='+module+'&action='+module+'Ajax&file=getListForTag&frommodule='+module;
	urlstring += '&viewid='+ld("#"+popupobj.divid+" [name=viewname]").val();
	urlstring += '&viewname='+ld("#"+popupobj.divid+" [name=viewname]").val();
	var max_height = CrmPopup.getClientHeight();

	var tag_id = new Array();
	var i=0;
	ld("#"+popupobj.divid+" [name=module_list_tagger_span]").find('a').each(function() {
		if(ld(this).attr('tag_click') == 'yes'){
			tag_id[i] = ld(this).attr('tag_id');
			i++;
		}
	});

	ldAjax(urlstring,"",function(data){
		if(data.code == 1){
		//	popupobj.CancelEvent();
			ld("#"+popupobj.divid+" [name=listtag_div]").html(data.result.content);
			//没选择标签的时候 不需要重新请求数据  zxm 20220113
            if(ld("#"+popupobj.divid+" [name=listtag_div]").css("display")!="none"&&tag_id.length>0)
            {
                var viewid=ld("#"+popupobj.divid+' [name=selectcustomview_'+popupobj.module+']').val();
                //edit:can 2021-01-14 	0044156: （61mis.com/kfbcrm）标签；客户管理-客户；单据列表上方，点击标签查找，查找区域弹出，选择标签后，点击“标签查找”，查找区域收回；再次点击“标签查找”后，标签没有选中，那么单据列表应恢复成筛选标签前的状态
                showDefaultCustomView(undefined,popupobj.module,'',viewid);
                
            }
			ld("#"+popupobj.divid+" [name=moduletag_list]").css('max-height',max_height/9);
			ld("#"+popupobj.divid+" [name=moduletag_list]").css('overflow-y','auto');
			ListTagShow();
			ListTagBlock();
		}
        DelProgressObjs();
	})
	//CrmPopup.getClientHeight();
	
}

//标签列表显示
var ListTagShow = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	if(ld("#"+popupobj.divid+" [name=list_tagger_search]").val() != undefined && ld("#"+popupobj.divid+" [name=list_tagger_search]").val()!=''){
		var tagobj = ld("#"+popupobj.divid+" [name=list_tagger_search]");
		var list_tag = tagobj.val().split(',');
		var list_tag_id = tagobj.attr('tag_id').split(',');
		var list_tag_type = tagobj.attr('tag_type').split(',');
		var tagger_obj = ld('<span class="module_list_tagger_span" name="module_list_tagger_span"></span>');
		for (var i = 0; i < list_tag.length; i++) {
			tagger_obj.append( ld('<a href="javascript:void(0)" class="module-tagger-fm-button '+ list_tag_type[i] +'" tag_click="no" tag_id="'+list_tag_id[i]+'" select_li_name="" title="'+list_tag[i]+'">'+list_tag[i]+'</a>') );
		}
		tagobj.hide().after(tagger_obj);		ListTagShow.setEvent(tagger_obj);
	}
   
}
ListTagShow.setEvent=function(tagger_obj){
	tagger_obj.on('click','a',function(){
		var popupobj=CrmPopup.getPopupObj("last");
		if(ld(this).attr('tag_click') == 'no'){
			ld(this).attr('tag_click','yes');
			ld(this).css('color','#3B7CFF');
			ld(this).css('border','1px solid #3B7CFF');
		}
		else{
			ld(this).attr('tag_click','no');
			ld(this).css('color','#999999');
			ld(this).css('border','1px solid #999999');
		}
		ListTagSearch(popupobj.module);
	});
}
//标签详情页显示
var ListTagDetailShow = function(tag_input_name){
	var popupobj=CrmPopup.getPopupObj("last");
	var tagobj = ld("#"+popupobj.divid+" [name="+tag_input_name+"]");
    //费用预算单重算预算金额时会获取对象失败，重新获取
    if(ld(tagobj).length<=0)
    {
        return ;
    }
    if(tagobj.val() == undefined){
        var popupprevobj=CrmPopup.getPopupObj("lastprev");
        tagobj = ld("#"+popupprevobj.divid+" [name="+tag_input_name+"]");
    }
	var list_tag = tagobj.val().split(',');
	var list_tag_type = tagobj.attr('tag_type').split(',');
	var tagger_obj = ld('<span class="module_list_tagger_span" name="module_list_tagger_span"></span>');
	if(tagobj.val() != ''){
		for (var i = 0; i < list_tag.length; i++) {
			tagger_obj.append( ld('<a href="javascript:void(0)" class="module-tagger-fm-button '+list_tag_type[i]+'" tag_type="'+list_tag_type[i]+'" select_li_name="" title="'+list_tag[i]+'">'+list_tag[i]+'</a>') );
		}
	}
	tagobj.hide().after( tagger_obj );
}

//标签查找
function ListTagSearch(module){
	var popupobj=CrmPopup.getPopupObj("last");
    module = popupobj.module;
	var tag_id = new Array();
	var i = 0;
	var list_tag_div = ld("#"+popupobj.divid+" [name=listtag_div]").html();
	var viewid = ld("#"+popupobj.divid+" [name=viewname]").val();
	var fieldname = ld("#"+popupobj.divid+" [name=fieldname]").val();
	ld("#"+popupobj.divid+" [name=module_list_tagger_span]").find('a').each(function() {
		if(ld(this).attr('tag_click') == 'yes'){
			tag_id[i] = ld(this).attr('tag_id');
			i++;
		}
	});
	var divid='ListViewContents';
	if(module=='Users')
	{
		divid='ListViewContents';
	}
	ld('#rptContentLoading').show();
	if(ld("#"+popupobj.divid+" [name=SmOwnerSearchScope]")!=null && ld("#"+popupobj.divid+" [name=SmOwnerSearchScope]").val() != undefined)
		var searchScope= encodeURIComponent(ld("#"+popupobj.divid+" [name=SmOwnerSearchScope]").val());
	else
		var searchScope='SmOwner_Search_All';
    var file = 'index';
    if(module =='Calendar')//日程管理查询后返回列表页
        file = 'ListView';
	var urlstring ='SearchScope='+searchScope+'&viewid='+viewid+'&viewname='+viewid+'&searchtype=advance&wareid=0&query=true&file='+file+'&module='+module+'&action='+module+'Ajax&ajax=true&search=true&tag_search=true';
	// ljj 20230920 XUQIU1000542 选择源单、选择产品、基本查找和高级查找增加“搜索历史”功能（参考单据列表高级查找搜索历史功能）
	urlstring += '&searchfrom='+popupobj.type;
	//zkt 树结构显示增加条件，获取树结构点击条件
    if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
	   urlstring += '&isshowModuleListTree=yes';
	}
    if(tag_id.length > 0){
		urlstring += '&advft_criteria=[{"groupid":"1","columnname":"'+fieldname+'","comparator":"c","value":"'+tag_id.join(',')+'","columncondition":""}]&advft_criteria_groups=[null,{"groupcondition":""}]';
	}
	var listview_page=new ListView_Page(module,urlstring,divid);
	listview_page.callback_fun=function()
	{
		popupobj.listresizeobj.setReiszeTable_Init(popupobj.module,'ajax');
		IsFrameElement();
		ld("#"+popupobj.divid+" [name=listtag_div]").html(list_tag_div);
		ld("#"+popupobj.divid+" [name=listtag_div]").show();
		ld("#"+popupobj.divid+" [name=module_list_tagger_span]").on('click','a',function(){
			var popupobj=CrmPopup.getPopupObj("last");
			if(ld(this).attr('tag_click') == 'no'){
				ld(this).attr('tag_click','yes');
				ld(this).css('color','#3B7CFF');
				ld(this).css('border','1px solid #3B7CFF');
			}
			else{
				ld(this).attr('tag_click','no');
				ld(this).css('color','#999999');
				ld(this).css('border','1px solid #999999');
			}
		});
		if(ld("#"+popupobj.divid+" #Autohideafterfinding").length>0){
			ld('#tiledSearch').hide();
		}
		ld('#rptContentLoading').hide();
		setContentHeight(popupobj.module);//计算内容高度
	}
	listview_page.page();
}
//模块列表标签功能 - 显示、隐藏
function ListTagBlock(){
	//搜索div展示 
	var popupobj=CrmPopup.getPopupObj("last");
	ld("#"+popupobj.divid+" [name=listtag_div]").toggle();
	//var height = ld("#"+popupobj.divid+" [name=resize_content_table_divid]").height();
	//重置列表区域高度
	/*if(ld("#"+popupobj.divid+" [name=listtag_div]").is(":hidden")){
		var tmpheight = ld("#"+popupobj.divid+" [name=listtag_div]").height();
	}else{
		var tmpheight = -ld("#"+popupobj.divid+" [name=listtag_div]").height();
	}*/
	//ld('#resize_content_table_divid').height(height + tmpheight);
	//chj 2020/11/9 43166: 点击标签查找，再点击平铺查找，界面异常
	if(ld('#tiledSearch').css('display') != 'none'){
		ld('#tiledSearch').hide();
	}
	setContentHeight(popupobj.module);//计算内容高度
}

//列表选中变色
// function listOnMouseOver(sel_id){
//     var rows = "row_"+sel_id;
//     ld("#"+rows).removeClass("lvtColDataBj");
    
//     if(document.getElementById(sel_id)!=undefined){
//         if(document.getElementById(sel_id).checked){
//             ld("#"+rows).removeClass("lvtColDataHover") ;
//             ld("#"+rows).addClass("lvtColDataSelected") ;
//         }else{
//             ld("#"+rows).removeClass("lvtColDataSelected") ;
//             ld("#"+rows).addClass("lvtColDataHover") ;
            
//         }
//     }
//     else{
//         ld("#"+rows).removeClass("lvtColDataSelected") ;
//         ld("#"+rows).addClass("lvtColDataHover") ;
//     }
// }

// lqt 悬浮变色合集
function listOnMouseOver(obj, combine){
    // var rows = "row_"+sel_id;
    // 如果tr有record并且相同，合并对象
    var parentobj = ld(obj).parent().get(0);
    if(combine== '' || combine== undefined){
    	combine = 'record';
    }
    var chosetrobjs=ld(obj);
    if(parentobj!=undefined && ld(obj).attr(combine) != undefined){
	    var rowRecord = ld(obj).attr(combine);
	    chosetrobjs = ld(parentobj).find('tr['+combine+'='+rowRecord+']');
    }
    
    ld(chosetrobjs).removeClass("lvtColDataBj");
    var checkboxobj = ld(obj).children().get(0);
    if(ld(checkboxobj)!=undefined){
        if(ld(checkboxobj).find(" input[type='checkbox']").get(0)!=undefined && ld(checkboxobj).find(" input[type='checkbox']").get(0).checked){
            ld(chosetrobjs).removeClass("lvtColDataHover") ;
            ld(chosetrobjs).addClass("lvtColDataSelected") ;
        }else{
            ld(chosetrobjs).removeClass("lvtColDataSelected") ;
            ld(chosetrobjs).addClass("lvtColDataHover") ;
            
        }
    }
    else{
        ld(chosetrobjs).removeClass("lvtColDataSelected") ;
        ld(chosetrobjs).addClass("lvtColDataHover") ;
    }

    if(ld(chosetrobjs).find('a[name=RestoreDefaultIcon]')!= undefined){
    	ld(chosetrobjs).find('a[name=RestoreDefaultIcon]').css('display','');
	}
}

// function listOnMouseOut(sel_id,type){
//     var rows = "row_"+sel_id;
//    ld("#"+rows).removeClass("lvtColDataSelected");
//    ld("#"+rows).removeClass("lvtColDataHover") ;
//     if(document.getElementById(sel_id)!=undefined){
//         if(document.getElementById(sel_id).checked){
//             ld("#"+rows).addClass("lvtColDataSelected");
//             //document.getElementById(rows).className = "lvtColDataSelected";
//         }else{
//             ld("#"+rows).removeClass("lvtColDataSelected");
//             if(type == 'On'){
//                ld("#"+rows).addClass("lvtColDataBj");
//             }else{
//                 ld("#"+rows).addClass("lvtColData");
               
//             }
//         }
        
//     }
//     else{
        
//         if(type == 'On'){
//             //document.getElementById(rows).className = "lvtColDataBj";
//             ld("#"+rows).addClass("lvtColDataBj");
//         }else{
//             //document.getElementById(rows).className = "lvtColData";
//             ld("#"+rows).addClass("lvtColData");
//         }
//     }

// lqt 悬浮移除掉色合集
function listOnMouseOut(obj,type,combine){
	var parentobj = ld(obj).parent().get(0);
    if(combine== '' || combine== undefined){
    	combine = 'record';
    }
    var chosetrobjs=ld(obj);
    if(parentobj!=undefined && ld(obj).attr(combine) != undefined){
	    var rowRecord = ld(obj).attr(combine);
	    chosetrobjs = ld(parentobj).find('tr['+combine+'='+rowRecord+']');
    }
    
    ld(chosetrobjs).removeClass("lvtColDataSelected");
    ld(chosetrobjs).removeClass("lvtColDataHover");
    var checkboxobj = obj.children().get(0);
        if(ld(checkboxobj)!=undefined){
    	// console.log(obj.find().check);
		if(type == 'On'){
			ld(chosetrobjs).addClass("lvtColDataBj");
		}else{
			ld(chosetrobjs).addClass("lvtColData");

		}
        if(ld(checkboxobj).find(" input[type='checkbox']").get(0)!=undefined && ld(checkboxobj).find(" input[type='checkbox']").get(0).checked){
            ld(chosetrobjs).addClass("lvtColDataSelected");
            //document.getElementById(rows).className = "lvtColDataSelected";
        }else{
            ld(chosetrobjs).removeClass("lvtColDataSelected");
        }
    }
    else{
        
        if(type == 'On'){
            //document.getElementById(rows).className = "lvtColDataBj";
            ld(chosetrobjs).addClass("lvtColDataBj");
        }else{
            //document.getElementById(rows).className = "lvtColData";
            ld(chosetrobjs).addClass("lvtColData");
        }
    }

    if(chosetrobjs.find('a[name=RestoreDefaultIcon]')!= undefined){
    	ld(chosetrobjs).find('a[name=RestoreDefaultIcon]').css('display','none');
	}
}
function moveUp(){getJsScript('include/js/ldcrm.list.js',function(){moveUps();});}
function moveDown(){getJsScript('include/js/ldcrm.list.js',function(){moveDowns();});}
function toggleSelectAll(a,b,c){
	//editor:gyq_161 reason:带分录模块弹出层   2019/11/27 15:44
	if(c !== undefined){
        document.getElementById(c).className = "lvtColDataSelected";
    }
    getJsScript('include/js/ldcrm.list.js',function(){toggleSelectAlls(a,b,c);});
}



//@edit:liujiajun,2023-07-12,reason:BUG0069181:  列表界面点击行选中复选框--弹窗列表单选框
function toggleSelectAll_parent_td(obj) {
	var input = ld(obj).find("input");
	var input_checked=input.prop('checked');
	var e = event || window.event;
	if (e.target.nodeName.toLocaleLowerCase() != 'input') {
		input.prop('checked',!input_checked);
		fun_setCrmPopupWindow.setChooseInfo_arr(input);
		//wym 231227 BUG0077912 多选关联选择单据点击复选框的td时，无法触发复选框的点击事件
		var popupobj=CrmPopup.getPopupObj("last");
		if(!empty(popupobj.isMultiple) && !empty(popupobj.Multipleobj)){
			popupobj.Multipleobj.setChooseInfo_arr(input);
		}
	}
}

function toggleSelect_ListView(a,b,c){getJsScript('include/js/ldcrm.list.js',function(){toggleSelect_ListViews(a,b,c);});}
function toggleSelectAll_Records(module,state,relCheckName) {
	toggleSelect_ListView(state,relCheckName);
	if(state == true) {
		$('allselectedboxes').value = 'all';
		if(ld('#selectAllRec').length > 0){
			ld('#selectAllRec').hide();
		}
		if($('deSelectAllRec')){
			if($('deSelectAllRec').style && $('deSelectAllRec').style.display){
				$('deSelectAllRec').style.display = 'inline';
			}
		}
	} else {
		$('allselectedboxes').value = '';
		ld('#excludedRecords').val('');
		if($('selectCurrentPageRec')){
			$('selectCurrentPageRec').checked = false;
		}
		if($('selectAllRec')){
			if($('selectAllRec').style && $('selectAllRec').style.display){
				$('selectAllRec').style.display = 'inline';
			}
		}
		if($('deSelectAllRec')){
			if($('deSelectAllRec').style && $('deSelectAllRec').style.display){
				$('deSelectAllRec').style.display = 'none';
			}
		}
		if(ld('#linkForSelectAll').length > 0){
			$('linkForSelectAll').hide();
		}
		ld('#ld_listviewabtnrely').css('top','-50px').css('opacity','0').css('z-index','-1');
	}
	if(ld('#ld_listviewabtnrely')){
		List_CheckBox_Ids.getIds(module);
		var rows_num = List_CheckBox_Ids.num_rows;
		if(ld('#ld_listviewabtnrely').find('.ld_listviewchosenum .chosenum')){
			ld('#ld_listviewabtnrely').find('.ld_listviewchosenum .chosenum').html(rows_num);
		}
	}
}
function confirmedit(a,b){getJsScript('include/js/ldcrm.list.js',function(){confirmedits(a,b);});}
function stockfirmdelete(a,b,c){getJsScript('include/js/ldcrm.list.js',function(){confirmedit(a,b,c);});}
function confirmdelete(a,b){getJsScript('include/js/ldcrm.list.js',function(){confirmdeletes(a,b);});}
/*
edit:cdw
date:20130716
reason:0004459: 短信作业查询、短信清单查询点击界面上的 清空，弹出的提示信息：确定要删除吗？ 应该改成：确定要清空吗？
*/
function DeleteAllCommunication(url)
{
	//zkt 20231009 XUQIU1001341 SQL注入
	url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
     if(url = 'index.php?module=CommunicationLog&action=DeleteAll&parenttab=Marketing&type=smslist' )
     {
		var confirm_str = arrJsPopLabel['SUREWANTTOEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			document.location.href=url;
		})
     }
     else if(url = 'index.php?module=CommunicationLog&action=DeleteAll&parenttab=Marketing&type=smswork' )
     {
     	var confirm_str = arrJsPopLabel['SUREWANTTOEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			document.location.href=url;
		})
     }
}

//end
// MassEdit Feature
function massedit_togglediv(curTabId,total){

   for(var i=0;i<total;i++){
	tagName = $('massedit_div'+i);
	tagName1 = $('tab'+i);
	tagName.style.display = 'none';
	ld('#tab'+i).removeClass('ld-ui-tabs-active');
   }

   tagName = $('massedit_div'+curTabId);
   tagName.style.display = 'block';
   tagName1 = $('tab'+curTabId)
   ld('#tab'+curTabId).addClass('ld-ui-tabs-active');
}

function massedit_initOnChangeHandlers() {
	var form = document.getElementById('massedit_form');
	// Setup change handlers for input boxes
	var inputs = form.getElementsByTagName('input');
	for(var index = 0; index < inputs.length; ++index) {
		var massedit_input = inputs[index];
		// TODO Onchange on readonly and hidden fields are to be handled later.
		massedit_input.onchange = function() {
			var checkbox = document.getElementById(this.name + '_mass_edit_check');
			if(checkbox) checkbox.checked = true;
		}
	}
    //zkt 20220930 BUG0057328报价单->批量编辑弹出层中，“文本”、“文本区域”和“整行文本区域”字段输入值后，输入框前面的复选框没有自动勾选
    // Setup change handlers for textarea boxes
	var textareas = form.getElementsByTagName('textarea');
	for(var index = 0; index < textareas.length; ++index) {
		var massedit_textarea = textareas[index];
		// TODO Onchange on readonly and hidden fields are to be handled later.
		massedit_textarea.onchange = function() {
			var checkbox = document.getElementById(this.name + '_mass_edit_check');
			if(checkbox) checkbox.checked = true;
		}
	}
	// Setup change handlers for select boxes
	var selects = form.getElementsByTagName('select');
	for(var index = 0; index < selects.length; ++index) {
		var massedit_select = selects[index];
		massedit_select.onchange = function() {
			var checkbox = document.getElementById(this.name + '_mass_edit_check');
           
			if(checkbox) checkbox.checked = true;
		}
	}
}
/**
edit:chj
date:2013-12-19
reson:即时库存查询  待出入库数量 明细
**/
function setNationDetail(module,parenttab,recordid,divid,type,wareid)
{
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module="+module+"&action=DetailNation&returnModule=InventoryQuery&recordid="+recordid+"&file=SortView&mode=ajax&type="+type+"&wareid="+wareid+"",
			onComplete: function(response) {
				puyoungJS_DialogBox.block();
				//var result = response.responseText;
                var results=response.responseText.split('###SUCCESS###');
                
                $('detialnationview_div').innerHTML=results[1];                 
				fnvshobj(this, divid);
			}
		}
		);
    
}
function ShowSortView(obj,divid,module){

    $("status").style.display="inline";
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module="+encodeURIComponent(module)+"&action="+encodeURIComponent(module+'Ajax')
            +"&file=SortView&mode=ajax",
			onComplete: function(response) {
				$("status").style.display="none";

				var result = response.responseText;
                $("sortview_form_div").update(result);
                /* editor:gyq_X160314  reason:异步导致弹框不居中 date:2016 3 14*/
                fnvshobj(obj, divid);
			}
		}
		);
}
var gstart='';
function deleteAll(module){
	var viewid = getviewId();
    confirm_status = true;
	if(confirm_status){
    var confirm_str = arrJsPopLabel['DETERMINECLEARALLRECORDS'];
	RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){		
        document.getElementById("headerremindscount").innerHTML='';
			$("status").style.display="inline";
			ldAjaxHtmlNoProgress('index.php?',"module=Reminds&action=DeleteAll&return_module="+module+"&viewname="+viewid,function(response) {
				$("status").style.display="none";
				result = response.split('&#&#&#');
				$("ListViewContents").innerHTML= result[2];
				if(result[1] != '')
					RemindsMsg("","LdPopWidth400px","","yes","yes",result[1]);
				$('basicsearchcolumns').innerHTML = '';
				$('allselectedboxes').value='';
				$('excludedRecords').value='';
				ActivityReminderCallback();
			});
	})
	}    
}
////用户查询范围改变
//BY LD Can
//20121226
/*gyq?*/
function SmOwnerSearchScopeChange(selectView,module,parenttab)
{


     var popupobj=CrmPopup.getPopupObj("last");

     if(selectView.nodeName == 'SELECT'){
		 var searchscope = encodeURIComponent(selectView.options[selectView.options.selectedIndex].value);
	 }else if(selectView.nodeName == 'LI'){
		 var searchscope = encodeURIComponent(ld(selectView).data('value'));
	 }
    
	/**
	 * 查看范围 高级功能实现
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-25
	 */
	if('smowner_search_senior' == searchscope){//高级
		SmOwnerSearchSenior(module,searchscope);return false;
	}
	// @edit:liushuai,2021-07-22,reason:【ID1000477】PC端：日程管理日历视图界面增加人员查看范围
	if (module == 'Calendar' && popupobj.type == 'calendarview') {
		popupobj.clearHighSearch = true;
		calendar.refetchEvents();
		return false;
	}
	if(document.forms['massdelete'] != undefined && document.forms['massdelete'].action != undefined){
		if('CallButler' == document.forms['massdelete'].action.value){
			callButlerSearch();
			return false;
		}
	}
    var viewnamid="";
    
   // if(module=='Reminds'){
    //记住选择的数据分类
       var viewnamid = '&viewname='+ld('#viewname').val();
   // }
    var  customtype="";
	var iskanbanshow=ld('#iskanbanshow').val();
	if( iskanbanshow!='yes' ){
    if(document.massdelete.publicaccounttype!=undefined )
    customtype=document.massdelete.publicaccounttype.value;
	}
    //alert("module="+module+"&action="+module+"Ajax&file=ListView&ajax=true&start=1&query=true &SearchScope="+viewName+"&parenttab="+parenttab+"&accounttype="+customtype);
	ld('#rptContentLoading').show();
    //35186: （1.6账户）银行账户列表界面：勾选单据删除弹出的提示内容错误应该是：原因：该单据已经初始化。
	var urlstring = "module="+module+"&action="+module+"Ajax&file=ListView&ajax=true&start=1&query=true&SearchScope="+searchscope+"&accounttype="+customtype+viewnamid+"&query=true&querysession=1";
	if(module == 'Approve'){
		if(ld('#fromapprovemodule') != undefined){
			urlstring += '&fromapprovemodule='+ld('#fromapprovemodule').val();
		}
		if(ld('#approvestatus') != undefined){
			urlstring += '&approvestatus='+ld('#approvestatus').val();
		}
	}
	if(popupobj != undefined){
		if(popupobj.searchtype=='Advanced')
		{
			//32156: 单据列表：设置高级查询后，切换查看范围时，不清空高级查询条件
			var advft_criteria = ld('advft_criteria').value;
			var advft_criteria_groups = ld('advft_criteria_groups').value;
			urlstring += '&advft_criteria='+encodeURIComponent(advft_criteria)+'&advft_criteria_groups='+advft_criteria_groups+'&';
			urlstring += 'searchtype=advance';
		}
		else if(popupobj.searchtype=='Basic')
		{
			//zkt 20240125 BUG20240124-67 自定义表单101，单据列表界面，搜索全部字段“哆啦”后，查看范围选择“我创建的”查询时，搜索不到数据
			var divid="basicSearchNewDiv";
			search_fld_val= CrmPopup.findHtmlobj(divid,"search_field").val();
			if(search_fld_val=='all'){
				var optionvalues = ld("#bas_searchfield").eq(0).find(' option').map(function() {
					if(ld(this).val()!='all'){
						return ld(this).val();
					}
				}).get();
				var search_fld_val_arr=JSON.stringify(optionvalues);
				urlstring += 'search_field_arr='+search_fld_val_arr;
			}
		   search_txt_val= encodeURIComponent(CrmPopup.findHtmlobj(divid,'search_text').val());
		   urlstring += '&search_field='+search_fld_val+'&searchtype=BasicSearch&search_text='+search_txt_val+'&searchtype=BasicSearch';
		}else if(popupobj.searchtype=='Tiled'){
			// @edit:dong @date:2020/08/24 @reason: 平铺查找 获取本地搜索条件
			var criteriaConditions = getlocalStorageConditions(popupobj.module);
			var criteriaGroups = getlocalStorageGroups(popupobj.module);

			urlstring += '&advft_criteria='+encodeURIComponent(criteriaConditions)+'&advft_criteria_groups='+criteriaGroups+'&';
			urlstring += 'searchtype=tiled';
		}
        //zkt 20230301 BUG0062100kfbcrm 入库单、出库单、盘点单----点击任意仓库----再点击查看范围‘全部’---会把所有单据查出来
        if(module == 'BankCash' || module == 'Stock' || module == 'Checks' || module == 'OutboundOrder' || module == 'Prdtnums' || module == 'InventoryAccount' || module == 'InventoryQuery'){
            if (document.getElementById('wareid') != undefined && document.getElementById('wareid').value > 0) {
                wareid = document.getElementById('wareid').value;
                urlstring += '&wareid='+wareid;
            }
        }
	}

    //zkt 模块树结构显示增加条件，获取树结构点击条件
    if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
	   urlstring += '&isshowModuleListTree=yes';
	}
	var listPopupobj = CrmPopup.getlastPopupObjByPageType('listpage');
	if(module == 'Users' && listPopupobj.user_type){
		urlstring += '&user_type='+listPopupobj.user_type;
	}
	//分页
    var listview_page=new ListView_Page(module,urlstring,"ListViewContents");


    listview_page.callback_fun=function()
    {
        var popupobj=CrmPopup.getPopupObj('last');

        popupobj.listresizeobj.setReiszeTable_Init(module,'ajax');
        ld('#rptContentLoading').hide();

        setContentHeight(module);//计算内容高度

   /*     if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
        {
                         //通讯录(pc端企业微信)
                cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
        }*/
         IsFrameElement();
    //	document.getElementById('basicsearchcolumns_real').innerHTML = $('basicsearchcolumns').innerHTML
	//	document.getElementById('basicsearchcolumns').innerHTML = '';
		//document.basicSearch.search_text.value = '';
    }
	listview_page.http_page();
	toggleSelectAll_Records(module,false,'selected_id')
}
/*gyq?*/
function SmOwnerScopehightuser()
{

	var popupobj=CrmPopup.getPopupObj("last");

	if(document.getElementById('showselectsearchscope_new') != undefined){

		if(popupobj.Showselect_obj && popupobj.Showselect_obj.optionList && popupobj.Showselect_obj.optionList.length > 0){
			var optionlists = popupobj.Showselect_obj.optionList;
			for(var i=0;i<optionlists.length;i++){
				if(optionlists[i]['value'] == 'smowner_search_senior'){
					popupobj.Showselect_obj.eventChangeSelected(i);
					break;
				}
			}
		}
	}

	var fldname = 'SmOwnerSearchScope';
	if(document.getElementById(fldname)==undefined)
	{
		fldname='onlyforuser';
	}
	 if(document.getElementById(fldname) != undefined){
		var objoption=document.getElementById(fldname);
		var optiontext='';
		picklist=true;
		//BUG20240409-38 zxm 20240410 目标管理选人还是旧的样式
		if((objoption.localName == 'SELECT'||popupobj.module=='SalesGoal') && objoption.length != undefined){
			for(var i=0;i<objoption.length;i++)
			{
				if(objoption[i].value=='smowner_search_senior')
				{
					objoption[i].selected=true;
					optiontext=objoption[i].text;
					document.getElementById(fldname).options[i].selected=true;

					document.getElementById(fldname).selectedIndex=i;
					document.getElementById(fldname).options[i].value='smowner_search_senior';
					if(typeof document.getElementById(fldname).onchange=='function')
						document.getElementById(fldname).onchange();
					if(typeof(fielddepend)!='undefined'&&fielddepend!=undefined)
					{
						var sourcename = objoption.name;
						var sourcevalue = objoption.value;
						//fielddepend.fieldValueChange(sourcename, sourcevalue);
					}
					break;
				}
			}

            if(popupobj.type==ListPagePopup.type)
            {
				//BUG20240124-64 ls 240130 查看范围-点击高级图标，勾选成员-确定，查看范围下拉框内还是显示“全部” (高级查找图标绑定了其他事件,需要将popup对象获取提前,否则对象错误)
				ld("#"+popupobj.divid+" [name=cmb_span_optiontext_"+fldname+"]").val(optiontext);
				ld("#"+popupobj.divid+" [name=cmb_span_optiontext_"+fldname+"]").html(optiontext);
            }
            else
            {//为了将来选择用户也做成带拖拽的弹出框而设计
                 var popupobj=CrmPopup.getPopupObj("prevlast");
                 if (popupobj != undefined){
					 ld("#"+popupobj.divid+" [name=cmb_span_optiontext_"+fldname+"]").val(optiontext);
					 ld("#"+popupobj.divid+" [name=cmb_span_optiontext_"+fldname+"]").html(optiontext);
				 }
            }

			//document.getElementById('cmb_span_optiontext_'+fldname).innerHTML=optiontext;
		}
	 }

    //ld("#SmOwnerSearchScope").change();
}
/**
 * 查看范围高级功能
 * @project PROT180 角色权限改进
 * @author Tujt 2015-03-25
 */

function SmOwnerSearchSenior(module,searchview){
    /* editor:gyq_14 date:20160715*/
    getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
        ScopePopup_Details.getInstance().SmOwnerSearchSenior(module,searchview,'listview');
    });
}
//点击数据分类
function showDefaultCustomView(selectView,module,parenttab,viewid){
	if(ld('#customviewsequence').attr('name') == 'inactivate'){
		return;
	}
    getJsScript('include/js/ListViewButton.js',function(){
        showDefaultCustomViews(selectView,module,parenttab,viewid);
	});
}
function RequestServiceGroup()
{
    var str=http_reqfield.responseText;
    $('refreshgroup').innerHTML=str;
	isDuplicate=false;
}
/*
popup数据分类
BY LD Can
20140214
*/
function showDefaultCustomViewPopup(selectView,module,parenttab,viewid,noewviewid){
	if(ld('#customviewsequence').attr('name') == 'inactivate'){
		return;
	}
	getJsScript('include/js/ListViewButton.js',function(){
		showDefaultCustomViewPopups(selectView,module,parenttab,viewid,noewviewid);
	});
}
function getTableViewForFenzu(a,b,c,d){getJsScript('include/js/ldcrm.list.js',function(){getTableViewForFenzus(a,b,c,d);});}

/**
 * @edit:liushuai
 * @date:2020-07-09
 * @reason:0041912: （61mis.com/kfbcrm）营销>群发邮件：右上角“创建分组”，点击“编辑”，“复制”按钮，自动跳转至首页界面
 * @description: 营销-》群发邮件的创建、编辑、复制、排序等功能块需要更新到新版本的json形式。
 */
function createFenzu(setype,category,type) {
	//index.php?module=Accounts&action=CustomView&parenttab=Marketing&groupEmail=Emails
	var module = setype;
	if(type){
		var groupEmail='MassSMS';
	}
	else{
		var groupEmail='Emails';
	}
     //var popupobj = CrmPopup.load(data.result.title,validateCV,"","LdPopWidth1100px",module,jspopup,data.result.oktext,"",data.result.canceltext);
    //Ajax之前创建弹出层外围popupobj.advanceSearchDivid，否则高级查询[AdvancceFilterNew.tpl]的nextnode会获取不到popupobj.advanceSearchDivid
	var popupobj=CrmPopup.load("","","","LdPopWidth1100px",module,"","","");
	popupobj.prevshow();
	//zkt 20231012 XUQIU1001341 SQL注入
	ldAjaxNoProgresssync("index.php?module="+module+"&action="+module+"Ajax&file=CustomView&parenttab=" + category + "&groupEmail=" + groupEmail,'',function(data)
	{
		if(data.code==1)
		{
			//定义保存的方法
			//	var popupobj = CrmPopup.load(data.result.title,validateCV,"","LdPopWidth1100px",module,jspopup,data.result.oktext,"",data.result.canceltext);
			//popupobj.show(data.result.content);
			// var okfunparams = [];
			// okfunparams.push(module, groupEmail);
			popupobj.setParams(data.result.title,newValidateCV,"","1000",module,"",data.result.oktext,"",data.result.canceltext);
			popupobj.advanceSearchDivid = popupobj.divid;
			CrmPopup.setPopupobjHtmlContent_scroll_jquery(popupobj,data.result.content);//以jq的方式加载页面js
		}
	});
}
newValidateCV.funname = 'newValidateCV'; //定义保存按钮的tagclick值
function newValidateCV() {
	// if(getObj('viewcopy').value=='')
	if(getObj('group').value!='')
	{
		if(New_checkAdvancedFilter()==false)
		{
			return false;
		}
	}
	else{
		if(newCheckDuplicate()) {
			if( New_checkAdvancedFilter()==false)
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}

	newCheckViewNameDup();
	return false;
}

function newCheckViewNameDup()
{
	var record=document.forms['CustomView'].record.value;
	var viewname=encodeURIComponent(document.forms['CustomView'].viewName.value);
	if(viewname.length == 0){
		var confirm_str = arrJsPopLabel['CANOTEMPTY'];//分组名不能为空
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	if(groupeamil_name=='MassSMS' || groupeamil_name=='Emails'){
		var module = groupeamil_name;
	}
	else{
		var module=document.forms['CustomView'].cvmodule.value;
	}
	var curpopup=CrmPopup.getPopupObj("last");
	var prevpopup=CrmPopup.getPopupObj("lastprev");
	var return_action = document.forms['CustomView'].return_action.value;
	var urlstring = "index.php?module=CustomView&action=Save&record="+record+"&cvmodule="+module+"&viewName="+viewname+"&repeat=1&ReportHeader=dheader&return_action="+return_action+"&refreshpage=no";
	urlstring += "&setStatus="+ld("#"+curpopup.divid+" [name=setStatus]").val();
	urlstring += "&stdDateFilterField="+ld("#"+curpopup.divid+" [name=stdDateFilterField]").val();
	urlstring += "&startdate="+ld("#"+curpopup.divid+" [name=startdate]").val();
	urlstring += "&enddate="+ld("#"+curpopup.divid+" [name=enddate]").val();
	urlstring += "&user_dateformat="+ld("#"+curpopup.divid+" [name=user_dateformat]").val();
	urlstring += "&SearchScope="+ld("#"+curpopup.divid+" [name=SearchScope]").val();
	urlstring += "&group="+ld("#"+curpopup.divid+" [name=group]").val();
	urlstring += "&cvmodule_field="+ld("#"+curpopup.divid+" [name=cvmodule]").val();
	//urlstring += "&"+ld("#"+curpopup.divid+' [name="CustomView"]').serialize();
	urlstring += "&advft_criteria="+curpopup.advft_criteria;
	urlstring += "&advft_criteria_groups="+curpopup.advft_criteria_groups;
	//zkt 20231012 XUQIU1001341 SQL注入
	ldAjaxNoProgresssync(urlstring,'',function(data) {
		if(data.code==1) {
			curpopup.CancelEvent();
			// console.log(ld("#"+curpopup.divid+' [name="customviewhtml"]'));
			ld("#"+prevpopup.divid+' [name="customviewhtml"]').html(data.result.datafenzucontent);

			// document.forms['CustomView'].submit();
		}else{
			var confirm_str = arrJsPopLabel['CANOTREPEATED'];//分组名不能重复
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
	});


	/*new Ajax.Request
	(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module=CustomView&action=Save&record="+record+"&cvmodule="+module+"&viewName="+viewname+"&repeat=1&ReportHeader=dheader",
			onComplete: function(response)
			{
				if(response.responseText.indexOf('###error####')>=0)
				{
					var confirm_str = viewnamelabel+arrJsPopLabel['CANOTREPEATED'];
					RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

				}
				else
				{

					document.forms['CustomView'].submit();

				}
			}
		}
	)*/
}

function newCheckDuplicate() {
	if($('jscal_field_date_start').value > $('jscal_field_date_end').value)
	{
		var confirm_str = arrJsPopLabel['STARTDATECANOTGREATERENDDATE'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	if(document.getElementById('more_listview') != undefined && document.getElementById('more_listview').value == 1)
	{
		return true;
	}
	if(getObj('viewName').value.toLowerCase() == 'all') {
		var confirm_str = arrJsPopLabel['CANOTUSERNAMEOFALL'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}

	var cvselect_array = new Array('column1','column2','column3','column4','column5','column6','column7','column8','column9')
	for(var loop=0;loop < cvselect_array.length-1;loop++) {
		selected_cv_columnvalue = $(cvselect_array[loop]).options[$(cvselect_array[loop]).selectedIndex].value;
		if(selected_cv_columnvalue != '') {
			for(var iloop=loop+1;iloop < cvselect_array.length;iloop++) {
				selected_cv_icolumnvalue = $(cvselect_array[iloop]).options[$(cvselect_array[iloop]).selectedIndex].value;
				if(selected_cv_columnvalue == selected_cv_icolumnvalue) {
					var confirm_str = arrJsPopLabel['COLNOTDUPLICATE'];
					RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					$(cvselect_array[iloop]).selectedIndex = 0;
					return false;
				}

			}
		}
	}
	return true;
}

//@edit:liushuai,2020-07-17,reason:0041912/营销>群发邮件（右上角编辑）
function editFenzu(setype,category,type) {
	var module = setype;
	var viewid = ld("#viewname").val();
	if(type){
		var groupEmail='MassSMS';
	}
	else{
		var groupEmail='Emails';
	}
	var url = "index.php?module=" + module +"&action="+module+"Ajax&file=CustomView&record=" + viewid +"&groupEmail="+groupEmail+"&parenttab="+category;
	// module=Accounts&action=CustomView&record=20&groupEmail=Emails&parenttab=Marketing
	// window.location.href = url;

	var popupobj=CrmPopup.load("","","","LdPopWidth1100px",module,"","","");
	popupobj.prevshow();
	ldAjaxNoProgresssync(url,'',function(data) {
		if(data.code==1)
		{
			popupobj.setParams(data.result.title,newValidateCV,"","1000",module,"",data.result.oktext,"",data.result.canceltext);
			popupobj.advanceSearchDivid = popupobj.divid;
			CrmPopup.setPopupobjHtmlContent_scroll_jquery(popupobj,data.result.content);//以jq的方式加载页面js
		}
	});
}
//@edit:liushuai,2020-07-17,reason:0041912/营销>群发邮件（右上角编辑）
function deleteFenzu(setype,category,type) {
	var module = setype;
	var viewid = ld("#viewname").val();
	if(ld('ul li[viewid='+viewid+']').attr('viewtype') == 'All'){
		RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['LBL_NOTDELETE_CUSTOMVIEW']);
		return false;
	}
	if(type){
		var groupEmail='MassSMS';
	}else{
		var groupEmail='Emails';
	}
	// var url ="index.php?module=CustomView&dmodule=" + setype +"&action=Delete&record=" + viewid +"&groupEmail="+groupEmail+"&parenttab="+category;
	var url = "index.php?module=CustomView&dmodule=" + setype +"&action=Delete&record=" + viewid +"&groupEmail="+groupEmail+"&parenttab="+category;
	RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['SUREWANTDELETE']);

	//zkt 20241105 BUG20241105-01 群发邮件，删除“分组”报错

	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		// window.location.href = url;
		ldAjaxNoProgress(url,'',function(data)
		{
			if(data.code==1)
			{
				var popupobj=CrmPopup.getPopupObj("last");
				ld("#"+popupobj.divid+' [name="customviewhtml"]').html(data.result.datafenzucontent);//更新邮件分组头部
			}
		});
	})
	//return false;
}

//@edit:liushuai,2020-07-21,reason:0041912/营销>群发邮件（右上角复制）
function copyFenzu(setype,type) {
	//index.php?module=Accounts&action=CustomView&record='+record+'&viewcopy=true&groupEmail=Emails
	var module = setype;
	var viewid = ld("#viewname").val();
	if(type){
		var groupEmail='MassSMS';
	}
	else{
		var groupEmail='Emails';
	}
	//var popupobj = CrmPopup.load(data.result.title,validateCV,"","LdPopWidth1100px",module,jspopup,data.result.oktext,"",data.result.canceltext);
	//Ajax之前创建弹出层外围popupobj.advanceSearchDivid，否则高级查询[AdvancceFilterNew.tpl]的nextnode会获取不到popupobj.advanceSearchDivid
	var popupobj=CrmPopup.load("","","","LdPopWidth1100px",module,"","","");
	popupobj.prevshow();
	//zkt 20231012 XUQIU1001341 SQL注入
	var urlsting = "index.php?module="+module+"&action="+module+"Ajax&file=CustomView&record=" + viewid + "&viewcopy=true&groupEmail=" + groupEmail;
	ldAjaxNoProgresssync(urlsting,'',function(data)
	{
		if(data.code==1)
		{
			popupobj.setParams(data.result.title,newValidateCV,"","1000",module,"",data.result.oktext,"",data.result.canceltext);
			popupobj.advanceSearchDivid = popupobj.divid;
			CrmPopup.setPopupobjHtmlContent_scroll_jquery(popupobj,data.result.content);//以jq的方式加载页面js
		}
	});
}

//@edit:liushuai,2020-07-21,reason:0041912/营销>群发邮件（右上角排序）
function sortViewFenzu(obj,divid,setype) {
	//"module="+encodeURIComponent(module)+"&action="+encodeURIComponent(module+'Ajax')
	// 				+"&file=SortView&mode=ajax"

	var module = setype;
	var popupobj=CrmPopup.load("","","","LdPopWidth300px",module,"","","");
	popupobj.prevshow();
	ld.ajax({
		url: "index.php?module="+encodeURIComponent(module)+"&action="+encodeURIComponent(module+'Ajax')+"&file=SortView&mode=ajax",
		type: 'POST',
		data:'',
		dataType:'json',
		async: false,//
		timeout: 10000,
		success: function(data)
		{
			// SaveViewOrder(this,'sortview','{$MODULE}');
			if(data.code==1)
			{
				popupobj.setParams(data.result.title,newSaveViewOrder,"","1000",module,"",data.result.oktext,"",data.result.canceltext);
				popupobj.advanceSearchDivid = popupobj.divid;
				CrmPopup.setPopupobjHtmlContent_scroll_jquery(popupobj,data.result.content);//以jq的方式加载页面js
			}
		}
	});
}
newSaveViewOrder.funname = 'newSaveViewOrder';
function newSaveViewOrder(){
	var curpopup=CrmPopup.getPopupObj("last");
	var prevpopup=CrmPopup.getPopupObj("lastprev");
	// console.log(ld("#sortview_form").serialize());  //获取值  module=Emails&action=GroupEmail&parenttab=Tools&selectedColumnsString2=&selectedColumns2=812

	var selectedFieldStr = "";
	if(document.getElementById('selectedColumns2')!=undefined){
		selectedColumnsObj=document.getElementById('selectedColumns2');
		for (i=0;i<selectedColumnsObj.options.length;i++){
			selectedFieldStr += selectedColumnsObj.options[i].value + ";";
		}
	}

	var selectedColumns2 = ld('#'+curpopup.divid+" [name=selectedColumns2]").val();
	var url = "index.php?module=Emails&action=EmailsAjax&file=GroupEmail&parenttab=Tools&selectedColumnsString2="+selectedFieldStr+"&selectedColumns2="+selectedColumns2+"&refreshpage=no";
	//zkt 20231012 XUQIU1001341 SQL注入
	ldAjaxNoProgresssync(url,'',function(data) {
		if(data.code==1) {
			curpopup.CancelEvent();
			ld("#"+prevpopup.divid+' [name="customviewhtml"]').html(data.result.datafenzucontent);

			// document.forms['CustomView'].submit();
		}else{
			var confirm_str = arrJsPopLabel['CANOTREPEATED'];//分组名不能重复
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
	});
}

//分页
function getListViewEntries_js(module,url){

//	getJsScript('include/js/ListViewButton.js',function(){

		getListViewEntries_jss(module,url);
	//});
}
//设置每页显示条数
function setMaxEntriesPerPage(module,pagepernum,tabname){

	var url='index.php?module=Users&action=UsersAjax&file=setMaxEntriesPerPage&modulename='+module+'&pagepernum='+pagepernum;
	ldAjaxNoProgresssync(url,'',function(data) {
		if(data.code==1) {
			if(module == 'Documents'){
				getListViewEntries_js(module,'parenttab='+tabname+'&start='+1+'&folderid=index');
			}else {
				getListViewEntries_js(module,'parenttab='+tabname+'s&start='+1);
			}
		}
	});
}
//全选方法
function check_object(sel_id,groupParentElementId){
     //1 == dynamicJsScript[JsFile]
	//getJsScript('include/js/ListViewButton.js',function(){

		check_objects(sel_id,groupParentElementId);

        //	});
}
function VT_disableFormSubmit(evt) {
	var evt = (evt) ? evt : ((event) ? event : null);
	var node = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null);
	if ((evt.keyCode == 13) && (node.type=='text')) {
		node.onchange();
		return false;
	}
	return true;
}
var statusPopupTimer = null;
function closeStatusPopup(elementid)
{
	statusPopupTimer = setTimeout("document.getElementById('" + elementid + "').style.display = 'none';", 50);
}


// mailer_export
function mailer_export() {
	var module = document.getElementById('curmodule').value;
	document.massdelete.action.value = "MailerExport";
	document.massdelete.step.value = "ask";
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: "module="+module+"&action=MailerExport&from="+module+"&step=ask"
		}
		);
}
// end of mailer export

function principal_edit(obj,divid,module,parenttab,principal)
{
   mass_edit(obj,divid,module,parenttab,principal)
}

/*
date:20130219
Edit by LD Can
reason:叙事簿图表
*/
function ChartOpen(chartref,chartfrom,querywhere)
{
     //chartref=encodeURIComponent(chartref);

     chartfrom=encodeURIComponent(chartfrom);
     chartwhere=encodeURIComponent(querywhere);
     // alert(querywhere);
    // alert(chartref+"&queryfrom="+chartfrom+"&querywhere="+chartwhere);
    window.open(chartref+"&queryfrom="+chartfrom+"&querywhere="+chartwhere,"chart","width=950,height=650,resizable=1,scrollbars=1");

}

function CalendarChart(obj,formname)
{
    document.forms[formname].submit();

}
function openSpecfiyWindown()
{

window.open('about:blank',"chart","width=950,height=650,resizable=1,scrollbars=1");

}
var drag_status=false;
 function setCapture1(){
    drag_status=true;
}

 function releaseCapture(){
    drag_status=false;
}

 function changeIndex(objdiv,e){
    if(drag_status==false)
    return;
    sx=e.clientX;
    sy=e.clientY;
    objdiv.style.position="absolute";
    objdiv.style.left=sx;
    objdiv.style.top=sy;
    objdiv.style.width="100px";
}


function selectedColumnClick(oSel)
{
	var error_msg = '';
	var error_str = false;
	if(oSel.selectedIndex > -1) {
                for(var i = 0; i < oSel.options.length; ++i) {
                        if(oSel.options[i].selected == true && oSel.options[i].disabled == true) {
                                error_msg = error_msg + oSel.options[i].text+',';
				error_str = true;
                                oSel.options[i].selected = false;
                        }
                }
        }
	if(error_str)
	{
		error_msg = error_msg.substr(0,error_msg.length-1);
		var confirm_str = arrJsPopLabel['ALLOWEDEDITTHESEFIELDS']+"\n"+error_msg;
		RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
		return false;
	}
	else
		return true;
}



function formSelectColumnString2()
{
	var selectedColStr = "";
    if(document.getElementById('selectedColumns2')!=undefined)
    selectedColumnsObj=document.getElementById('selectedColumns2');
	for (i=0;i<selectedColumnsObj.options.length;i++)
	{
		selectedColStr += selectedColumnsObj.options[i].value + ";";
	}
    if(document.getElementById('curmodule').value=='MassSMS'){
        //20024: 群发短信>分组>排序功能不可用
        document.EditView.selectedColumnsString2.value = selectedColStr;
    }else{
   	    document.EditView.selectedColumnsString2.value = selectedColStr;
    }

}

function SaveViewOrder(obj,div,module){
    fninvshnew(div);
    formSelectColumnString2();
    if(module=='MassSMS'){
        //20024: 群发短信>分组>排序功能不可用
        document.EditView.submit();
    }else{
        document.EditView.submit();
    }

    //showDefaultCustomView(obj,module,'','');
}
/**
 * edit:kevin
 * date:2013-06-25
 * reason:群发短信
*/
function massSMS(module,oButton){
    var select_options = document.getElementById('allselectedboxes').value;
    if(select_options == 'all'){
        document.getElementById('idlist').value=idstring;
        allids = select_options;
    } else {
		var x = select_options.split(";");
		var count=x.length;
		select_options=select_options.slice(0,(select_options.length-1));
		if (count > 1) {
			idstring=select_options.replace(/;/g,',')
			document.getElementById('idlist').value=idstring;
		}
		else {
			var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
			RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
			return false;
		}
		var allids = document.getElementById('idlist').value;
	}
    if(allids.length>0)
    url='index.php?module=MassSMS&action=SendView&parenttab=Marketing&return_module='+module+'&select_options='+allids;
    openPopUp('Xsms',this,url,'createSmsWin',1024,768,'menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
    return true;
}
function detailview_MassSMS_account(){getJsScript('include/js/ldcrm.list.js',function(){detailview_MassSMS_accounts();});}
function detailview_email_account(){getJsScript('include/js/ldcrm.list.js',function(){detailview_email_accounts();});}
function detailview_email_contact(){getJsScript('include/js/ldcrm.list.js',function(){detailview_email_contacts();});}
function detailview_MassSMS_contact(){getJsScript('include/js/ldcrm.list.js',function(){detailview_MassSMS_contacts();});}
/**
更新操作
edit:cdw
date:20131126
reason:营销界面群发短信功能改进
**/
function show_contactSMS(contactid)
{
    if(document.getElementsByName("selected_id")!=undefined)
    {
        var str=document.getElementsByName("selected_id");
        var objarray=str.length;
        var chestr = "";
        for (i=0;i<objarray;i++)
        {
            if(str[i].checked == true)
            {
                chestr+=str[i].value+",";
            }
        }
        if(chestr == "")
        {
            var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
    }
	var pmodule = document.selectall.pmodule.value;
    var lastpopupobj=CrmPopup.getPopupObj('last');
    //edit:can 2021-01-14 43025: 营销>群发短信>选择“联系人”：点击“+”选择联系人，任意勾选一个联系人点击“选择”按钮，弹出界面有明显的从大变小的过程
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth350px",'Emails',"","","","");
	crmPopupobj.prevshow();
	//alert('index.php?module='+ pmodule +'&action=Popup&html=Popup_picker&form=HelpDeskEditView&popuptype=set_return_groupmasssms&select=enable&popup=yes&page_popup=yes&sendgroupemail=yes');
	var prevpopupobj=CrmPopup.getPopupObj('lastprev');
    var popuptype = '';
	if(prevpopupobj != undefined){
	   prevdivid=prevpopupobj.divid;

		if(CrmPopup.findHtmlobj(prevdivid,'popup_type') != undefined){

			if(CrmPopup.findHtmlobj(prevdivid,'popup_type').val()=='set_return_emails'||CrmPopup.findHtmlobj(prevdivid,'popup_type').val() == 'set_return_groupemails'){
				popuptype = '&popuptype=set_return_emails';
			}
		}else{
			popuptype = '&popuptype=set_return_groupmasssms';
		}

	}
	ld.ajax({
		url: 'index.php?module='+ pmodule +'&action=Popup&html=Popup_picker&form=HelpDeskEditView'+popuptype+'&select=enable&popup=yes&page_popup=yes&sendgroupemail=yes',
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,
		// @edit:dong @date:2020/09/25 @reason:  bug 0042779 超时导致弹窗失败
		timeout: 10000,
		success: function(data)
		{
			if(data.code==1)
			{
				 if(lastpopupobj.module=='Emails'){

                     if(data.result.mail_field <=0 || data.result.mail_field == ''){
    					RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['themodulehasenotemailfield']);
    					ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
    						cancelCrmPopup();
    					});

    					return false;
    				}
			     }
				crmPopupobj.setParams(data.result.title,'',"","LdPopWidth350px",'Emails',"","","","");
				crmPopupobj.show(data.result.content);
			}
		}
	})
	return false;
}
function show_contactEmail(contactid)
{
    if(document.getElementsByName("selected_id")!=undefined)
    {
        var str=document.getElementsByName("selected_id");
        var objarray=str.length;
        var chestr = "";
        for (i=0;i<objarray;i++)
        {
            if(str[i].checked == true)
            {
                chestr+=str[i].value+",";
            }
        }
        if(chestr == "")
        {
            var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
    }
    document.getElementById('contactid').value = contactid;
    document.getElementById('SMSedit').style.display = 'block';
    //puyoungJS_DialogBox.block();
    //Drag.init(document.getElementById("SMSedit_head"), document.getElementById("SMSedit"));
}
/**
edit:can
reason:群发短信选择用户
**/
function show_UserSMS()
{


     var chks=document.forms['selectall'].selected_id;
     allids='';


     for(var i=0;i<chks.length;i++)
     {
         if(chks[i].checked)
         {
            allids+=chks[i].value+',';

         }

     }
     if(chks.length==undefined&&chks!=undefined&&chks.checked)//edit:can 列表只有一条记录的时候，chks不是数组
     {
        allids=chks.value;
     }
     if(allids=='')
     {
		  var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
		  RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
          return false;
     }
      //alert("module=Users&action=UserSMS&allids="+allids+"&ReportHeader=dheader");
      new Ajax.Request(
        'index.php',
        {
            queue:
            {
                position: 'end', scope: 'command'
            },
            method: 'post',
            postBody:"module=Users&action=UserSMS&allids="+allids+"&ReportHeader=dheader",
            onComplete: function(response) {
            if(response.responseText.indexOf('#####SUCCESS#####')>-1)
            {
                var result=response.responseText.split('#####SUCCESS#####');
                var all_info_window = result[1];
				var popupobj=CrmPopup.getPopupObj('last');
				var prevpopupobj=CrmPopup.getPopupObj('lastprev');
				var popuptype = '';
				if(prevpopupobj != undefined){
					var prevdivid=prevpopupobj.divid;
					var divid = popupobj.divid;
					if(CrmPopup.findHtmlobj(divid,'popup_type') != undefined){
						if(CrmPopup.findHtmlobj(divid,'popup_type').val() == 'set_return_groupmasssms'){
							var receivephone = CrmPopup.findHtmlobj(prevdivid,'receivephone').val();
							CrmPopup.findHtmlobj(prevdivid,'receivephone').val(receivephone+all_info_window);
						}else{
							var receivephone = CrmPopup.findHtmlobj(prevdivid,'receivephonehidden').val();
							CrmPopup.findHtmlobj(prevdivid,'receivephonehidden').val(receivephone+'\n'+result[2]);
							var parent_name = CrmPopup.findHtmlobj(prevdivid,'parent_name').val();
							CrmPopup.findHtmlobj(prevdivid,'parent_name').val(parent_name+'\n'+all_info_window);
						}
					}
				}
                var popupobj=CrmPopup.getPopupObj("last");
				popupobj.CancelEvent();
                //用来提交的时候替换模板里面的字段的参数
            }
        }
        }
        );

}

/**
edit:can
reason:群发邮件选择用户
**/
function show_UserEmail()
{
	 var str=document.getElementsByName("selected_id");
        var objarray=str.length;
        var allids = "";
        for (i=0;i<objarray;i++)
        {
            if(str[i].checked == true)
            {
                allids+=str[i].value+",";
            }
        }
     if(allids=='')
     {
          var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
		  RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
          return false;
     }

	var popup_type = '';
	if(document.getElementById('popup_type') != undefined){
		popup_type = document.getElementById('popup_type').value;
	}
      new Ajax.Request(
        'index.php',
        {
            queue:
            {
                position: 'end', scope: 'command'
            },
            method: 'post',
            postBody:"module=Emails&action=UserEmail&allids="+allids+"&ReportHeader=dheader&popup_type="+popup_type,
            onComplete: function(response) {

            if(response.responseText.indexOf('#####SUCCESS#####')>-1){
                var result=response.responseText.split('#####SUCCESS#####');
                var all_info_window = result[1];
				var prevpopupobj=CrmPopup.getPopupObj('lastprev');

				if(prevpopupobj != undefined){

					prevdivid=prevpopupobj.divid;
					var parent_name = CrmPopup.findHtmlobj(prevdivid,'parent_name').val();
					CrmPopup.findHtmlobj(prevdivid,'parent_name').val(parent_name+all_info_window);
					//用来提交的时候替换模板里面的字段的参数
					if(CrmPopup.findHtmlobj(prevdivid,'tabid_fieldlabel_btn_listview_email').val() != undefined){
						CrmPopup.findHtmlobj(prevdivid,'tabid_fieldlabel_btn_listview_email').val(result[2]);	//主键值+邮件字段的fieldid
					}
					var popupobj=CrmPopup.getPopupObj("last");
					popupobj.CancelEvent();
				}else{
					if(typeof(window.document.EditView) != 'undefined'){
						var inputs = window.document.EditView;
						if(typeof(inputs.parent_name) != 'undefined'){
							inputs.parent_name.value = inputs.parent_name.value+all_info_window+'\r\n';
						}
						var popupobj=CrmPopup.getPopupObj("last");
						popupobj.CancelEvent();
					}
				}
            }
        }
        }
        );

}

/**
更新操作
edit:andrew
date:20131230
reason:新增多选
**/
function contact_btn_MassSMS()
{
    if(ld("#popup_rows_selectall").val()=='all')
    {
       contactid='all';
    }
    else
    {
         if(document.getElementById('contactid').value>0){
        var contactid = document.getElementById('contactid').value;
        }else{
            contactid = checkbox();
            contactid = contactid.substring(0,contactid.length-1) ;
        }
    }

    //获取所有的弹出框里选择的条目


    var tabid_fieldlabel ="";
	var popupobj=CrmPopup.getPopupObj('last');
	var divid = popupobj.divid;
    //获取界面发送短信的手机字段
    for(var i=0;i<100;i++)
    {
		 var id = i+'_checkbox_pop_sms';
        var id_check = CrmPopup.findHtmlobj(divid,id).prop("checked");
        if(id_check==undefined)
        {
            continue;
        }

        if(id_check)
        {

             tabid_fieldlabel += CrmPopup.findHtmlobj(divid,id).val()+",";
        }
    }
	var prevpopupobj=CrmPopup.getPopupObj('lastprev');
	prevdivid=prevpopupobj.divid;
	CrmPopup.findHtmlobj(prevdivid,'contact_btn_MassSMS_wildcard_id').val(contactid);
	CrmPopup.findHtmlobj(prevdivid,'contact_btn_MassSMS_wildcard_tabid_fieldlabel').val(tabid_fieldlabel);
    var search_field=ld("#"+prevdivid+" [name=search_field]").val();
    var search_text=ld("#"+prevdivid+" [name=search_text]").val();
	// @edit:dong @date:2020/09/23 @reason: bug0042714营销>群发短信：接收人手机选择“联系人”，勾选单据点击“选择”按钮，弹出框点击“选择”按钮没有反应
    var url="index.php?module=MassSMS&action=MassSMSAjax&file=checkbox_checkcontact&fieldname="+tabid_fieldlabel+"&allids="+contactid+"&mode=ajax";
    if(ld.trim(search_text)!='')
    {
        url+="&searchtype=BasicSearch&search_field="+search_field+"&search_text="+search_text;
    }
    ld.ajax({
        url: url,
        type: 'POST',
        dataType:'json',
        timeout:20000,
        success:function(data){
            // console.log(data.result.content);
            var all_info_window = data.result.content;
            var popupobj=CrmPopup.getPopupObj("last");
			popupobj.CancelEvent();
			var popupobj=CrmPopup.getPopupObj("last");
			popupobj.CancelEvent();
			var prevpopupobj=CrmPopup.getPopupObj('last');
			prevdivid=prevpopupobj.divid;
			var parent_name = CrmPopup.findHtmlobj(prevdivid,'receivephone').val();
			CrmPopup.findHtmlobj(prevdivid,'receivephone').val(parent_name+all_info_window);
			var receivephonehidden = CrmPopup.findHtmlobj(prevdivid,'receivephonehidden').val();
			CrmPopup.findHtmlobj(prevdivid,'receivephonehidden').val(receivephonehidden+result[2]);
        }
    });
	//alert("module=MassSMS&action=checkbox_checkcontact&fieldname="+tabid_fieldlabel+"&allids="+contactid);
    // new Ajax.Request(
    //     'index.php',
    //     {
    //         queue:
    //         {
    //             position: 'end', scope: 'command'
    //         },
    //         method: 'post',
    //         postBody:url,
    //         onComplete: function(response) {
    //         if(response.responseText.indexOf('#####SUCCESS#####')>=0)
    //         {

    //             var result=response.responseText.split('#####SUCCESS#####');
    //             var all_info_window = result[1];
				// var popupobj=CrmPopup.getPopupObj("last");
				// popupobj.CancelEvent();
				// var popupobj=CrmPopup.getPopupObj("last");
				// popupobj.CancelEvent();
				// var prevpopupobj=CrmPopup.getPopupObj('last');
				// prevdivid=prevpopupobj.divid;
				// var parent_name = CrmPopup.findHtmlobj(prevdivid,'receivephone').val();
				// CrmPopup.findHtmlobj(prevdivid,'receivephone').val(parent_name+all_info_window);
				// var receivephonehidden = CrmPopup.findHtmlobj(prevdivid,'receivephonehidden').val();
				// CrmPopup.findHtmlobj(prevdivid,'receivephonehidden').val(receivephonehidden+result[2]);
    //         }
    //     }
    //     }
    //     );
}
/**
更新操作
edit:cdw
date:20131126
reason:营销界面群发短信功能改进
**/
function show_accountSMS(accountid)
{
    document.getElementById('accountid').value = accountid;
    document.getElementById('SMSedit').style.display = 'block';
    puyoungJS_DialogBox.block();
    //Drag.init(document.getElementById("SMSedit_head"), document.getElementById("SMSedit"));
}
function show_accountEmail(accountid)
{
    document.getElementById('accountid').value = accountid;
    document.getElementById('SMSedit').style.display = 'block';
    puyoungJS_DialogBox.block();
}
/**
更新操作
edit:andrew
date:20131230
reason:新增多选
**/
function account_btn_Email()
{
    if(document.getElementById('accountid').value>0){
        var accountid = document.getElementById('accountid').value;
    }else{
        accountid = checkbox();
        accountid = accountid.substring(0,accountid.length-1) ;
    }

    //获取所有的弹出框里选择的条目
	var prevpopupobj=CrmPopup.getPopupObj('lastprev');
	prevdivid=prevpopupobj.divid;
	var popupobj=CrmPopup.getPopupObj('last');
	var divid = popupobj.divid;
    var num_rows = CrmPopup.findHtmlobj(prevdivid,'row_of_checkbox_account_pop_email').val();
    var tabid_fieldlabel ="";
    for(var i=0;i<num_rows;i++)
    {
        var id = i+'_checkbox_pop_email_account';
		var id_check = CrmPopup.findHtmlobj(divid,id).prop("checked");
        //选中的项目进行处理
        if(id_check)
        {
            var tabid_fieldlabel = tabid_fieldlabel + document.getElementById(id).value+"_";
        }
    }
    var popup_type = '';
	if(document.getElementById('popup_type') != undefined){
		popup_type = document.getElementById('popup_type').value;
	}
	ld.ajax({
        url:"index.php?module=Emails&action=EmailsAjax&file=checkbox_checkaccount&tabid_fieldlabel="+tabid_fieldlabel+"&accountid="+accountid+"&popup_type="+popup_type,
        type: 'POST',
        dataType:'json',
        timeout:20000,
        success:function(data){
            // console.log(data.result.content);
            var all_info_window = data.result.content;
            var popupobj=CrmPopup.getPopupObj("last");
			popupobj.CancelEvent();
			var popupobj=CrmPopup.getPopupObj("last");
			popupobj.CancelEvent();
			var prevpopupobj=CrmPopup.getPopupObj('last');
			prevdivid=prevpopupobj.divid;
            var parent_name = CrmPopup.findHtmlobj(prevdivid,'parent_name').val();
			CrmPopup.findHtmlobj(prevdivid,'parent_name').val(parent_name+all_info_window);
            //用来提交的时候替换模板里面的字段的参数
			if(CrmPopup.findHtmlobj(prevdivid,'tabid_fieldlabel_btn_listview_email').val() != undefined){
				CrmPopup.findHtmlobj(prevdivid,'tabid_fieldlabel_btn_listview_email').val(result[2]);
			}
            if(CrmPopup.findHtmlobj(prevdivid,'contact_email_tabid_fieldlabel').val() != undefined){
				CrmPopup.findHtmlobj(prevdivid,'contact_email_tabid_fieldlabel').val(tabid_fieldlabel);
			}
			if(CrmPopup.findHtmlobj(prevdivid,'contactid_btn').val() != undefined){
				CrmPopup.findHtmlobj(prevdivid,'contactid_btn').val(tabid_fieldlabel);
			}
        }
    });
    // new Ajax.Request(
    //     'index.php',
    //     {
    //         queue:
    //         {
    //             position: 'end', scope: 'command'
    //         },
    //         method: 'post',
    //         postBody:"module=Emails&action=EmailsAjax&file=checkbox_checkaccount&tabid_fieldlabel="+tabid_fieldlabel+"&accountid="+accountid+"&popup_type="+popup_type,
    //         onComplete: function(response) {
    //         if(response.responseText.indexOf('#####SUCCESS#####')>0)
    //         {
    //             var result=response.responseText.split('#####SUCCESS#####');
    //             var all_info_window = result[1];

				// var popupobj=CrmPopup.getPopupObj("last");
				// popupobj.CancelEvent();
				// var popupobj=CrmPopup.getPopupObj("last");
				// popupobj.CancelEvent();
				// var prevpopupobj=CrmPopup.getPopupObj('last');
				// prevdivid=prevpopupobj.divid;
    //             var parent_name = CrmPopup.findHtmlobj(prevdivid,'parent_name').val();
				// CrmPopup.findHtmlobj(prevdivid,'parent_name').val(parent_name+all_info_window);
    //             //用来提交的时候替换模板里面的字段的参数
				// if(CrmPopup.findHtmlobj(prevdivid,'tabid_fieldlabel_btn_listview_email').val() != undefined){
				// 	CrmPopup.findHtmlobj(prevdivid,'tabid_fieldlabel_btn_listview_email').val(result[2]);
				// }
    //             if(CrmPopup.findHtmlobj(prevdivid,'contact_email_tabid_fieldlabel').val() != undefined){
				// 	CrmPopup.findHtmlobj(prevdivid,'contact_email_tabid_fieldlabel').val(tabid_fieldlabel);
				// }
				// if(CrmPopup.findHtmlobj(prevdivid,'contactid_btn').val() != undefined){
				// 	CrmPopup.findHtmlobj(prevdivid,'contactid_btn').val(tabid_fieldlabel);
				// }
    //         }
    //     }
    //     }
    //     );
}
/**
更新操作
edit:andrew
date:20131230
reason:新增多选
**/
function account_btn_MassSMS()
{
    if(ld("#popup_rows_selectall").val()=='all')
    {
       accountid='all';
    }
    else
    {

        if(document.getElementById('accountid').value>0){
            var accountid = document.getElementById('accountid').value;
        }else{
            accountid = checkbox();
            accountid = accountid.substring(0,accountid.length-1) ;
        }
    }
    //获取所有的弹出框里选择的条目
	var prevpopupobj=CrmPopup.getPopupObj('lastprev');
	prevdivid=prevpopupobj.divid;
	var popupobj=CrmPopup.getPopupObj('last');
	var divid = popupobj.divid;
    var tabid_fieldlabel ="";
    for(var i=0;i<100;i++)
    {
        var id = i+'_checkbox_pop_sms_account';
		//chj 2021/1/5 44066: 子淇软件（没有外网）短信群发模块>选择"联系人"/"客户档案"后，确认按钮点击异常，无响应。（切换浏览器无法解决）
        var id_check = CrmPopup.findHtmlobj(divid,id).prop("checked");
        if(id_check==undefined)
        {
            continue;
        }

        //选中的项目进行处理
        if(id_check)
        {
             tabid_fieldlabel +=CrmPopup.findHtmlobj(divid,id).val()+",";
        }
    }

    var search_field=ld("#"+prevdivid+" [name=search_field]").val();
    var search_text=ld("#"+prevdivid+" [name=search_text]").val();
    var url="index.php?module=MassSMS&action=MassSMSAjax&file=checkbox_checkaccount&fieldname="+encodeURIComponent(tabid_fieldlabel)+"&accountid="+accountid+"&mode=ajax";
    if(ld.trim(search_text)!='')
    {
        url+="&searchtype=BasicSearch&search_field="+search_field+"&search_text="+search_text;
    }
	//alert(url);
    ld.ajax({
        url: url,
        type: 'POST',
        dataType:'json',
        timeout:20000,
        success:function(data){
            // console.log(data.result.content);
            var all_info_window = data.result.content;
            var popupobj=CrmPopup.getPopupObj("last");
			popupobj.CancelEvent();
			var popupobj=CrmPopup.getPopupObj("last");
			popupobj.CancelEvent();
			var popupobj=CrmPopup.getPopupObj('last');
			var divid=popupobj.divid;
            var receivephone = CrmPopup.findHtmlobj(divid,'receivephone').val();
			CrmPopup.findHtmlobj(divid,'receivephone').val(receivephone+all_info_window);
        }
    });
    // new Ajax.Request(
    //     'index.php',
    //     {
    //         queue:
    //         {
    //             position: 'end', scope: 'command'
    //         },
    //         method: 'post',
    //         postBody:url,
    //         onComplete: function(response) {
    //         if(response.responseText.indexOf('#####SUCCESS#####')>=0)
    //         {
    //             var result=response.responseText.split('#####SUCCESS#####');
    //             var all_info_window = result[1];
				// var popupobj=CrmPopup.getPopupObj("last");
				// popupobj.CancelEvent();
				// var popupobj=CrmPopup.getPopupObj("last");
				// popupobj.CancelEvent();
				// var popupobj=CrmPopup.getPopupObj('last');
				// var divid=popupobj.divid;
    //             var receivephone = CrmPopup.findHtmlobj(divid,'receivephone').val();
				// CrmPopup.findHtmlobj(divid,'receivephone').val(receivephone+all_info_window);
    //         }
    //     }
    //     }
    //     );
}
/**
更新操作
edit:cdw
date:20131125
reason:营销界面群发短信功能改进
       判断有没有选择客户并且弹出弹出框
**/
function show_detailSMS(cvid)
{
    //document.getElementById('SMSedit').style.display = 'block';

    module='MassSMS';
    action='check_accountid';
    //puyoungJS_DialogBox.block();
    //Drag.init(document.getElementById("SMSedit_head"), document.getElementById("SMSedit"));
    var url="module="+module+"&action="+action+"&parenttab=Marketing&cvid="+cvid;
    new Ajax.Request(
        'index.php',
        {
            queue:
            {
                position: 'end', scope: 'command'
            },
            method: 'post',
            postBody:url,
            onComplete: function(response) {
            if(response.responseText.indexOf('####$$$$')>0)
            {
                var result=response.responseText.split('####$$$$');
                //alert(result[1]);
                //return false;
                document.getElementById('accountid_chose').value = result[1];
            }
            fnvshobj('','SMSedit');
        }
        }
        );
}
/**
更新操作
edit:cdw
date:20131120
reason:客户序时簿界面群发短信功能改进
       关闭弹出框
**/
function close_SMS(type)
{
    if(type=='SMSedit')
    {
        document.getElementById('SMSedit').style.display = 'none';
    }
    else
    {
        document.getElementById('Emailedit').style.display = 'none';
    }
}

/**
更新操作
edit:cdw
date:20131120
reason:客户序时簿界面群发短信功能改进
       判断是否有选择checkbox
**/
function isselect_checkboxemail_account()
{
    var check_num = 0;
        var id="";
        var num_rows = document.getElementById("row_of_checkbox_account_email").value;

        for(var i=0;i<num_rows;i++)
        {
           var id = i+'_checkbox_email';
           var id_check = document.getElementById(id);

           if(id_check.checked==true)
           {
             check_num++;
           }
        }
    if(check_num==0)
    {
        //置灰选择按钮，属性disabled
        document.getElementById('chose_checkbox').disabled = true;
        document.getElementById('chose_checkbox').style.color = 'grey';
    }
    else
    {
        document.getElementById('chose_checkbox').disabled = false;
        document.getElementById('chose_checkbox').style.color = 'white';
    }
}
function isselect_checkboxemail_contact()
{
    var check_num = 0;
        var id="";
        var num_rows = document.getElementById("row_of_checkbox_contact_email").value;

        for(var i=0;i<num_rows;i++)
        {
           var id = i+'_checkbox_email_contact';
           var id_check = document.getElementById(id);

           if(id_check.checked==true)
           {
             check_num++;
           }
        }
    if(check_num==0)
    {
        //置灰选择按钮，属性disabled
        document.getElementById('chose_checkbox').disabled = true;
        document.getElementById('chose_checkbox').style.color = 'grey';
    }
    else
    {
        document.getElementById('chose_checkbox').disabled = false;
        document.getElementById('chose_checkbox').style.color = 'white';
    }
}
function isselect_checkbox(module)
{
    if(module=='Accounts')
    {
        var check_num = 0;
        var id="";
        var num_rows = document.getElementById("row_of_checkbox_account_email").value;

        for(var i=0;i<num_rows;i++)
        {
           var id = i+'_checkbox_email';
           var id_check = document.getElementById(id);

           if(id_check.checked==true)
           {
             check_num++;
           }
        }
    }
    else
    {
        var check_num = 0;
        var id="";
        var num_rows = document.getElementById("row_of_checkbox_contact_email").value;

        for(var i=0;i<num_rows;i++)
        {
           var id = i+'_checkbox_email';
           var id_check = document.getElementById(id);

           if(id_check.checked==true)
           {
             check_num++;
           }
        }
    }
//    alert(id);
//    return false;
    if(check_num==0)
    {
        //置灰选择按钮，属性disabled
        document.getElementById('chose_checkbox').disabled = true;
        document.getElementById('chose_checkbox').style.color = 'grey';
    }
    else
    {
        document.getElementById('chose_checkbox').disabled = false;
        document.getElementById('chose_checkbox').style.color = 'white';
    }
}
function isselect_checkboxsms()
{

        var check_num = 0;
        var id="";
        var num_rows = document.getElementById("row_of_checkbox_account_sms").value;

        for(var i=0;i<num_rows;i++)
        {
           var id = i+'_checkbox_sms';
           var id_check = document.getElementById(id);

           if(id_check.checked==true)
           {
             check_num++;
           }
        }
    if(check_num==0)
    {
        //置灰选择按钮，属性disabled
        document.getElementById('chose_checkbox_sms').disabled = true;
        document.getElementById('chose_checkbox_sms').style.color = 'grey';
    }
    else
    {
        document.getElementById('chose_checkbox_sms').disabled = false;
        document.getElementById('chose_checkbox_sms').style.color = 'white';
    }
}
function isselect_checkboxsms_contact()
{

        var check_num = 0;
        var id="";
        var num_rows = document.getElementById("row_of_checkbox_account").value;

        for(var i=0;i<num_rows;i++)
        {
           var id = i+'_checkbox_contact_sms';
           var id_check = document.getElementById(id);

           if(id_check.checked==true)
           {
             check_num++;
           }
        }
    if(check_num==0)
    {
        //置灰选择按钮，属性disabled
        document.getElementById('chose_checkbox_sms').disabled = true;
        document.getElementById('chose_checkbox_sms').style.color = 'grey';
    }
    else
    {
        document.getElementById('chose_checkbox_sms').disabled = false;
        document.getElementById('chose_checkbox_sms').style.color = 'white';
    }
}
function isselect_checkbox_MassSMS_SMS()
{
    var check_num = 0;
    var id="";
    //var num_rows = document.getElementById("row_of_checkbox_account").value;

    for(var i=0;i<100;i++)
    {
        var id = i+'_checkbox_MassSMS_SMS';
        var id_check = document.getElementById(id);
        if(id_check==undefined)
            break;
        if(id_check.checked==true)
        {
            check_num++;
        }
    }
    if(check_num==0)
    {
        //置灰选择按钮，属性disabled
        document.getElementById('chose_checkbox').disabled = true;
        document.getElementById('chose_checkbox').style.color = 'grey';
    }
    else
    {
        document.getElementById('chose_checkbox').disabled = false;
        document.getElementById('chose_checkbox').style.color = 'white';
    }
}
function isselect_checkbox_sms_pop()
{
    var check_num = 0;
    var id="";
    var num_rows = document.getElementById("row_of_checkbox_contact_pop").value;
    for(var i=0;i<num_rows;i++)
    {
        var id = i+'_checkbox_pop_sms';
        var id_check = document.getElementById(id);

        if(id_check.checked==true)
        {
        check_num++;
        }
    }
    if(check_num==0)
    {
        //置灰选择按钮，属性disabled
        document.getElementById('chose_checkbox').disabled = true;
        document.getElementById('chose_checkbox').style.color = 'grey';
    }
    else
    {
        document.getElementById('chose_checkbox').disabled = false;
        document.getElementById('chose_checkbox').style.color = 'white';
    }
}
function isselect_checkbox_groupemail()
{
    var check_num = 0;
    var id="";
    var num_rows = document.getElementById("row_of_checkbox_account_groupemail").value;
    for(var i=0;i<num_rows;i++)
    {
        var id = i+'_checkbox_groupemail_account';
        var id_check = document.getElementById(id);

        if(id_check.checked==true)
        {
        check_num++;
        }
    }
    if(check_num==0)
    {
        //置灰选择按钮，属性disabled
        document.getElementById('chose_checkbox').disabled = true;
        document.getElementById('chose_checkbox').style.color = 'grey';
    }
    else
    {
        document.getElementById('chose_checkbox').disabled = false;
        document.getElementById('chose_checkbox').style.color = 'white';
    }
}
function isselect_checkbox_pop_contact_email()
{
    var check_num = 0;
    var id="";
    var num_rows = document.getElementById("row_of_checkbox_contact_pop_email").value;
    for(var i=0;i<num_rows;i++)
    {
        var id = i+'_checkbox_pop_email';
        var id_check = document.getElementById(id);

        if(id_check.checked==true)
        {
        check_num++;
        }
    }
    if(check_num==0)
    {
        //置灰选择按钮，属性disabled
        document.getElementById('chose_checkbox').disabled = true;
        document.getElementById('chose_checkbox').style.color = 'grey';
    }
    else
    {
        document.getElementById('chose_checkbox').disabled = false;
        document.getElementById('chose_checkbox').style.color = 'white';
    }
}
function isselect_checkbox_pop_email_account()
{
    var check_num = 0;
    var id="";
    var num_rows = document.getElementById("row_of_checkbox_account_pop_email").value;
    for(var i=0;i<num_rows;i++)
    {
        var id = i+'_checkbox_pop_email_account';
        var id_check = document.getElementById(id);

        if(id_check.checked==true)
        {
        check_num++;
        }
    }
    if(check_num==0)
    {
        //置灰选择按钮，属性disabled
        document.getElementById('chose_checkbox').disabled = true;
        document.getElementById('chose_checkbox').style.color = 'grey';
    }
    else
    {
        document.getElementById('chose_checkbox').disabled = false;
        document.getElementById('chose_checkbox').style.color = 'white';
    }
}
function isselect_checkbox_pop_sms_account()
{
    var check_num = 0;
    var id="";

    for(var i=0;i<100;i++)
    {
        var id = i+'_checkbox_pop_sms_account';
        var id_check = document.getElementById(id);
        if(id_check==undefined)
            break;
        if(id_check.checked==true)
        {
            check_num++;
        }
    }
    if(check_num==0)
    {
        //置灰选择按钮，属性disabled
        document.getElementById('chose_checkbox').disabled = true;
        document.getElementById('chose_checkbox').style.color = 'grey';
    }
    else
    {
        document.getElementById('chose_checkbox').disabled = false;
        document.getElementById('chose_checkbox').style.color = 'white';
    }
}
/**
更新操作
edit:cdw
date:20131120
reason:客户序时簿界面群发短信功能改进
       点击选择按钮
**/
function chosebox_select_btn(){
	var popupobj=CrmPopup.getPopupObj('last');
	var divid = popupobj.divid;
	//CrmPopup.findHtmlobj(divid,'popup_type')
	var module = CrmPopup.findHtmlobj(divid,'module').val();
	var allids = CrmPopup.findHtmlobj(divid,'allidsinfo').val();
	var SMStype = CrmPopup.findHtmlobj(divid,'SMStype').val();
    //获取所有的弹出框里选择的条目
    var num_rows = CrmPopup.findHtmlobj(divid,'row_of_checkbox_account').val();
    var tabid_fieldlabel ="";
    if(module=='Accounts'||module=="ServiceCharge"){
        for(var i=0;i<num_rows;i++){
            var id = i+'_checkbox_sms';
            var id_check = CrmPopup.findHtmlobj(divid,id).prop('checked');
            //选中的项目进行处理
            if(id_check){
				var module_fieldname = document.getElementById(id).value.split('#');
                 tabid_fieldlabel +=  tabid_fieldlabel+module_fieldname[1]+",";
            }
        }
    }else{
        for(var i=0;i<num_rows;i++){
            var id = i+'_checkbox_contact_sms';
            var id_check = document.getElementById(id);
            //选中的项目进行处理
            if(id_check.checked==true){
                 tabid_fieldlabel += id_check.value+",";
            }
        }
    }
	//chj:我不知道以下这句话是什么问题。 我先注释掉了。如果有问题，讨论
	//0017523: 客户>序时簿,关于群发短信的问题
   // if(module == 'Accounts' && allids == 'all') module = 'ServiceCharge';
    var str_json={"fieldname":tabid_fieldlabel,"allids":allids,'SMStype':SMStype};
	if(module == 'Contacts'){
		var surl = 'index.php?module=Contacts&action=ContactsAjax&file=checkbox_check&frommodule='+module;
	}else{
		var surl = 'index.php?module=Accounts&action=AccountsAjax&file=checkbox_check&frommodule='+module;
	}
    //在链接模块中全选所有单据时，获取当前数据分类条件
    if(ld("#viewname")!=undefined&&ld("#viewname").val()>0){
	   surl += '&cvid='+ld("#viewname").val();
	}
	ld.ajax({
		url:surl,
		type:"POST",
		data:str_json,
		dataType:'html',
		async:false,
		success:function(rest)
		{
			var mobile_str = '';
			if(rest != 'null'){
				var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
				if(restobj.length > 0){
					var mobile_info = new Array();
					for(var i = 0; i < restobj.length; i++){
						if(!empty(restobj[i][0])){
							mobile_info[i] = restobj[i][1] + '<'+restobj[i][0]+'>';
						}else{
							mobile_info[i] = restobj[i][1];
						}
					}
					mobile_str = mobile_info.join('\n');
				}
			}
			cancelCrmPopup();
			getMassSmsPopup(mobile_str,SMStype);
			return false;
			var restarr = rest.split('#####SUCCESS#####');
			window.open("index.php?module=MassSMS&action=index&fieldname="+encodeURIComponent(tabid_fieldlabel)+"&allids="+allids+"&return_module="+module,'checkbox_MassSMS',getNewWindowParams());//getNewWindowParams 返回弹出窗口的基本参数
		}
	});
}
function chosebox_select_btn_MassSMS(type){
    //获取所有的弹出框里选择的条目
    if(type=='MassSMS'){

        var tabid_fieldlabel ="";

        for(var i=0;i<100;i++){
            var id = i+'_checkbox_MassSMS_SMS';
            var id_check = document.getElementById(id);
            if(id_check==undefined)
                break;
            //选中的项目进行处理
            if(id_check.checked==true){
                 tabid_fieldlabel += document.getElementById(id).value+",";
            }
        }
    }else{

        var tabid_fieldlabel ="";
        for(var i=0;i<100;i++)
        {
            var id = i+'_checkbox_groupemail_account';
            var id_check = document.getElementById(id);
             if(id_check==undefined)
                break;
            //选中的项目进行处理
            if(id_check.checked==true)
            {
                 tabid_fieldlabel += document.getElementById(id).value+",";
            }
        }
    }
    //获取所有的选择的客户id
    var accountid = document.getElementById('accountid_chose').value;
	if(type == 'MassSMS'){
	   var viewid=ld("#viewname").val();

		var url = "module=MassSMS&action=checkbox_check&fieldname="+encodeURIComponent(tabid_fieldlabel)+"&viewid="+viewid;
		RequestAjax(url,function(rest){
			if(rest.indexOf('#####SUCCESS#####') > 0){
				var restarr = rest.split('#####SUCCESS#####');
                  document.getElementById('parent_name').value = restarr[1];
                  document.getElementById('receivephonehidden').value = restarr[2];
				document.getElementById('SMSedit').style.display = 'none';
				DelProgressObjs();
			}
		});
	}else{
		var url = "module=Emails&action=checkbox_check&tabid_fieldlabel="+tabid_fieldlabel+"&accountid="+accountid;
		RequestAjax(url,function(rest){
			if(rest.indexOf('#####SUCCESS#####') > 0){
				var restarr = rest.split('#####SUCCESS#####');                 document.getElementById('parent_name').value = restarr[1];
				document.getElementById('SMSedit').style.display = 'none';
				DelProgressObjs();
			}
		});
	}
}
// @edit:liushuai @date:2020-07-09 @reason: 0041912/群发邮件模块[选择弹窗分组emails]
function New_chosebox_select_btn_MassSMS(type){
	//获取所有的弹出框里选择的条目
	if(type=='MassSMS'){

		var tabid_fieldlabel ="";

		for(var i=0;i<100;i++){
			var id = i+'_checkbox_MassSMS_SMS';
			var id_check = document.getElementById(id);
			if(id_check==undefined)
				break;
			//选中的项目进行处理
			if(id_check.checked==true){
				tabid_fieldlabel += document.getElementById(id).value+",";
			}
		}
	}else{

		var tabid_fieldlabel ="";
		for(var i=0;i<100;i++)
		{
			var id = i+'_checkbox_groupemail_account';
			var id_check = document.getElementById(id);
			if(id_check==undefined)
				break;
			//选中的项目进行处理
			if(id_check.checked==true)
			{
				tabid_fieldlabel += document.getElementById(id).value+",";
			}
		}
	}
	//获取所有的选择的客户id
	var accountid = document.getElementById('accountid_chose').value;
	if(type == 'MassSMS'){

        var viewid=ld("#viewname").val();
		var url = "module=MassSMS&action=checkbox_check&fieldname="+encodeURIComponent(tabid_fieldlabel)+"&viewid="+viewid;
		RequestAjax(url,function(rest){
			if(rest.indexOf('#####SUCCESS#####') > 0){
				var restarr = rest.split('#####SUCCESS#####');
				document.getElementById('parent_name').value = restarr[1];
				document.getElementById('receivephonehidden').value = restarr[2];
				document.getElementById('SMSedit').style.display = 'none';
				DelProgressObjs();
			}
		});
	}else{
	       var viewid=ld("#viewname").val();
		var url = "module=Emails&action=EmailsAjax&file=checkbox_check&tabid_fieldlabel="+tabid_fieldlabel+"&accountid="+accountid+"&viewid="+viewid;
		RequestAjax(url,function(rest){
			if(rest.indexOf('#####SUCCESS#####') != '-1'){
				var restarr = rest.split('#####SUCCESS#####');
				var popupobj=CrmPopup.getPopupObj('last');

				ld('#parent_name').val(restarr[1]); //document.getElementById('parent_name').value = restarr[1];
				popupobj.CancelEvent();
				/*document.getElementById('parent_name').value = restarr[1];
				document.getElementById('SMSedit').style.display = 'none';*/

			}
			DelProgressObjs();
		});
	}
}
/*
function setTrColor(row,sel_id,onlyid,tableid){
    tableid=ListView_Page.content_tableid;
    var table = document.getElementById(tableid);
	if(table!=undefined){
		var trs = table.getElementsByTagName('tr');
		var rowReacord = row.split(",");
		for(var i = 0; i<trs.length; i++){
			var rowTrs = trs[i].id.split(",");
			if(rowTrs[0] == rowReacord[0]){
				if(document.getElementById(sel_id)!=undefined){
					if(document.getElementById(sel_id).checked){
						document.getElementById(trs[i].id).className = "lvtColDataSelected";
					}else{
						document.getElementById(trs[i].id).className = "lvtColDataHover";
					}
				}else{
					if(document.getElementById(onlyid)!=undefined){
						if(document.getElementById(onlyid).checked){
							document.getElementById(trs[i].id).className = "lvtColDataSelected";
						}
						else{
							document.getElementById(trs[i].id).className = "lvtColDataHover";
						}
					}
					else{
						document.getElementById(trs[i].id).className = "lvtColDataHover";
					}
				}
			}
		}
	}
}
function setTrColorOut(row,sel_id,onlyid,type,tableid){
    tableid=ListView_Page.content_tableid;
    var table = document.getElementById(tableid);
	if(table != undefined){
		var trs = table.getElementsByTagName('tr');
		var rowReacord = row.split(",");
		for(var i = 0; i<trs.length; i++){
			var rowTrs = trs[i].id.split(",");
			if(rowTrs[0] == rowReacord[0]){
				if(document.getElementById(sel_id)!=undefined){
					if(document.getElementById(sel_id).checked){
						document.getElementById(trs[i].id).className = "lvtColDataSelected";
					}else{
						if(type == 'On'){
							document.getElementById(trs[i].id).className = "lvtColDataBj";
						}else{
							document.getElementById(trs[i].id).className = "lvtColData";
						}
					}
				}else{
					if(document.getElementById(onlyid)!=undefined){
						if(document.getElementById(onlyid).checked){
							document.getElementById(trs[i].id).className = "lvtColDataSelected";
						}
						else{
							if(type == 'On'){
								document.getElementById(trs[i].id).className = "lvtColDataBj";
							}else{
								document.getElementById(trs[i].id).className = "lvtColData";
							}
						}
					}
					else{
						if(type == 'On'){
							document.getElementById(trs[i].id).className = "lvtColDataBj";
						}else{
							document.getElementById(trs[i].id).className = "lvtColData";
						}
					}
				}
			}
		}
	}
}*/

// @edit:hjz @date:2022-06-08 @reason: 选择源单增加选中背景色
/*function setTrColorPop(row,sel_id,onlyid,tableid){
    var popupobj=CrmPopup.getPopupObj('last');
    var table = ld("#"+popupobj.divid+" [name=resize_content_tableid]")
    if(table!=undefined){
        var trs = ld("#"+popupobj.divid+" [name=resize_content_tableid]").find('tr');
  		var rowReacord = row.split(",");
		for(var i = 0; i<trs.length; i++){
			var rowTrs = trs[i].id.split(",");
			if(rowTrs[0] == rowReacord[0]){
				if(document.getElementById(sel_id)!=undefined){
					if(document.getElementById(sel_id).checked){
						document.getElementById(trs[i].id).className = "lvtColDataSelected";
					}else{
						document.getElementById(trs[i].id).className = "lvtColDataHover";
					}
				}else{
					if(document.getElementById(onlyid)!=undefined){
						if(document.getElementById(onlyid).checked){
							document.getElementById(trs[i].id).className = "lvtColDataSelected";
						}
						else{
							document.getElementById(trs[i].id).className = "lvtColDataHover";
						}
					}
					else{
						document.getElementById(trs[i].id).className = "lvtColDataHover";
					}
				}
			}
		}
    }
}*/
// @edit:hjz @date:2022-06-08 @reason: 选择源单增加选中背景色
/*function setTrColorOutPop(row,sel_id,onlyid,type,tableid){
    var popupobj=CrmPopup.getPopupObj('last');
    var table = ld("#"+popupobj.divid+" [name=resize_content_tableid]").get(0);
    if(table != undefined){
		var trs = table.getElementsByTagName('tr');
		var rowReacord = row.split(",");
		for(var i = 0; i<trs.length; i++){
			var rowTrs = trs[i].id.split(",");
			if(rowTrs[0] == rowReacord[0]){
				if(document.getElementById(sel_id)!=undefined){
					if(document.getElementById(sel_id).checked){
						document.getElementById(trs[i].id).className = "lvtColDataSelected";
					}else{
						if(type == 'On'){
							document.getElementById(trs[i].id).className = "lvtColDataBj";
						}else{
							document.getElementById(trs[i].id).className = "lvtColData";
						}
					}
				}else{
					if(document.getElementById(onlyid)!=undefined){
						if(document.getElementById(onlyid).checked){
							document.getElementById(trs[i].id).className = "lvtColDataSelected";
						}
						else{
							if(type == 'On'){
								document.getElementById(trs[i].id).className = "lvtColDataBj";
							}else{
								document.getElementById(trs[i].id).className = "lvtColData";
							}
						}
					}
					else{
						if(type == 'On'){
							document.getElementById(trs[i].id).className = "lvtColDataBj";
						}else{
							document.getElementById(trs[i].id).className = "lvtColData";
						}
					}
				}
			}
		}
	}
}*/

/**
更新操作
edit:cdw
date:20131127
reason:客户序时簿界面群发短信功能改进
       点击选择按钮
**/
function chosebox_select_btn_email(module){
	var allids = document.getElementById('allidsinfo_email').value;//获取所有的id
    var tabid_fieldlabel='';
    if(module == 'Accounts'){//获取所有的弹出框里选择的条目
        var num_rows = document.getElementById("row_of_checkbox_account_email").value;
        for(var i=0;i<num_rows;i++){
            var id = i+'_checkbox_email';
            var id_check = document.getElementById(id);
            if(id_check.checked==true){//选中的项目进行处理
				tabid_fieldlabel = tabid_fieldlabel + document.getElementById(id).value+"_";
            }
        }
    }else{
        var num_rows = document.getElementById("row_of_checkbox_contact_email").value;
        var tabid_fieldlabel ="";
        for(var i=0;i<num_rows;i++){
            var id = i+'_checkbox_email_contact';
            var id_check = document.getElementById(id);
            if(id_check.checked==true){//选中的项目进行处理
                 tabid_fieldlabel = tabid_fieldlabel + document.getElementById(id).value+"_";
            }
        }
    }
	if(module == 'Accounts'){
		var str_json={"tabid_fieldlabel":tabid_fieldlabel,"allids":allids};
		var url = "index.php?module=Accounts&action=AccountsAjax&file=checkbox_check_email";
		ldAjaxHtmlNoProgresssync(url,str_json,function (rest) {
			var restarr = rest.split('#####SUCCESS#####');
			var surl = "index.php?module=Emails&action=EmailsAjax&file=GroupEmail&return_module=Accounts&parenttab=Marketing&tabid_fieldlabel_listview_email="+tabid_fieldlabel+"&accountid_listview_email="+allids+"&result="+restarr[1];
			getJsScript('include/js/GroupEmail.js', function () {
				GroupEmail.openEmailWindow(surl);
			});
		});

	}else{
		/*var url = "module=Contacts&action=checkbox_check_email&tabid_fieldlabel="+tabid_fieldlabel+"&allids="+allids;
		RequestAjax(url,function(rest){
			if(rest.indexOf('#####SUCCESS#####') > 0){
				var restarr = rest.split('#####SUCCESS#####');
				window.open("index.php?module=Emails&action=GroupEmail&return_module=Contacts&parenttab=Marketing&contact_email_tabid_fieldlabel="+tabid_fieldlabel+"&allids="+allids+"&result="+restarr[1],'checkbox_MassSMS','menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
			}
		});*/
        var str_json={"tabid_fieldlabel":tabid_fieldlabel,"allids":allids};
		var url = "index.php?module=Contacts&action=ContactsAjax&file=checkbox_check_email";
		ldAjaxHtmlNoProgresssync(url,str_json,function (rest) {
			var restarr = rest.split('#####SUCCESS#####');

			var surl = "index.php?module=Emails&action=EmailsAjax&file=GroupEmail&return_module=Contacts&parenttab=Marketing&contact_email_tabid_fieldlabel="+tabid_fieldlabel+"&allids="+allids+"&result="+restarr[1];
			getJsScript('include/js/GroupEmail.js', function () {
				GroupEmail.openEmailWindow(surl);
			});
		});

	}
}
/**
*edit:andrew
*date:2013-12-27
*reason:获取多选框
*/
function checkbox(){
    var str=document.getElementsByName("selected_id");
    var objarray=str.length;
    var chestr="";
    for(i=0; i<objarray; i++){
        if(str[i].checked==true){
			//zkt 20241105 BUG20241105-02 群发邮件，选择"接收人email"，再选择甲方单位后，下方的邮箱地址地址没有自动出现，需要再次点“分组”全部后才出现。
			if(ld(str[i])&&ld(str[i]).attr('billinfo')!=undefined){
				chestr+=ld(str[i]).attr('billinfo')+",";
			}
			else{
				chestr+=str[i].value+",";
			}
        }
    }
    return chestr;
}

/**
*edit:kevin
*date:2013-07-08
reason:4403 更多信息，模块中加载列表事件
*/
function loadCvList(type,id) {
	var element = type+"_cv_list";
	var value = document.getElementById(element).value;
	var filter = $(element)[$(element).selectedIndex].value ;
	if(filter=='None')return false;
	if(value != '') {
		var url = 'module=Campaigns&action=CampaignsAjax&file=LoadList&ajax=true&return_action=DetailView&return_id='+id+'&list_type='+type+'&cvid='+value;
		RequestAjax(url,function(rest){
			if($("RLContents")){
				$("RLContents").update(rest);
			}else if($('refresh-'+type)){
				$('refresh-'+type).click();
			}
			DelProgressObjs();
		});
	}
}
function lookMakingDetail(type,records){
    window.open("index.php?module=CommunicationLog&action=lookDetail&type="+type+"&records="+records,"test","width=640,height=602,resizable=1,scrollbars=1");
}
function ExportFields(module,parenttab){
    window.location='index.php?module='+module+"&action=ExportTemplateFields&parenttab="+parenttab;
}

var http_reqfield;
function createfieldXMLHTTP(){
    var request;
    var browser=navigator.appName;
    if(browser=="Microsoft Internet Explorer"){
        var arrVersions=["MSXML2.XMLHttp.5.0","MSXML2.XMLHTTP.4.0","MSXML2.XMLHTTP.3.0","MSXML2.XMLHTTP","Microsoft.XMLHTTP"];
        for( var i=0;i<arrVersions.length;i++){
            try{
                 request=new ActiveXObject(arrVersions[i]);
                return request;
            }catch(exception){}
        }
    }else{
		request=new XMLHttpRequest();
		return request;
    }
 }

 /**
 *@author:andy
 *@data:20141008
 *@reason:客户序时簿‘跟进操作’新建联系记录
 *@version:|
 */
 function CreateContactRecordsByAccounts(obj,return_id,record,return_module,return_action) {
    getJsScript('include/js/QuickCreate.js',function(){
                   createContactRecords(obj,return_id,record,return_module,return_action);
	});

}
/**
 *@author:andy
 *@data:20141008
 *@reason:客户序时簿‘跟进操作’新建联系记录
 *@version:|
 */
 function CreateProjectProgressByProjectTask(obj,return_id,record,return_module,return_action) {
    getJsScript('include/js/QuickCreate.js',function(){
                   createProjectProgress(obj,return_id,record,return_module,return_action);
	});

}

/**
 *@author:andy
 *@data:20141024
 *@reason:服务收费序时簿‘跟进操作’新建联系记录
 *@version:|
 */
 function CreateContactRecordsByServiceCharge(obj,return_id,record,return_module,return_action) {
     getJsScript('include/js/QuickCreate.js',function(){
                   createContactRecords(obj,return_id,record,return_module,return_action);
	});

}
function SalesSmOwnerSearchScope(selectView,module)
{
    var viewName = encodeURIComponent(selectView.options[selectView.options.selectedIndex].value);
	/**
	 * 查看范围 高级功能实现
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-25
	 */
	if('smowner_search_senior' == viewName){//高级
		getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
			//XUQIU20240415-03 目标管理，增加“显示离职成员”参数（杨雅媚）wsh 20240918
			var scopepopupobj = ScopePopup_Details.getInstance();
			var popupobj=CrmPopup.getPopupObj("last");
			scopepopupobj.displayinactiv = ld('#'+popupobj.divid+' #ChooseSalesGoal').attr('displayinactiv');
			scopepopupobj.SmOwnerSearchSenior(module,viewName,'listview');
		});

		return false;
	}
    var actionname=document.getElementById('actionname').value;
    var editresult=document.getElementById('editresult').value;
	SalesGoalListClickSearch();

   // window.location.href="index.php?module="+module+"&action="+actionname+"&query="+editresult+"&SmOwnerSearchScope="+viewName+"&show="+'yes';
}
/**
 * 列表按钮点击事件
 * @author Tujt 2015-06-03
 */
function listviewbutton_click(obj,module,setype,e){

    //阻止事件冒泡，如果不阻止则客户列表创建普通客户会有两个弹出层
     var e = e || window.event;
     if(e.stopPropagation) { //W3C阻止冒泡方法
         e.stopPropagation();
     } else {
         e.cancelBubble = true; //IE阻止冒泡方法
     }
    getJsScript('include/js/ListViewButton.js',function(){
       //edit:can 20200713 41833: （61mis.com/kfbcrm）快速创建弹出层：点击快速创建“报价单”没有反应。（需要补丁）
		listviewbuttons_click(obj,module,setype);
	});
}
/**
 * edit: xll 2023/02/27 XUQIU1001172
 * 相关信息栏打开新页签后，在新页签打开对应弹窗
 */
function isNewPage(){
    var event_content = '';
    event_content = sessionStorage.getItem('isNewPage');
    sessionStorage.removeItem('isNewPage');
    if(event_content != '' && event_content != null){
        var event_name =  event_content.split("(")[0];
        var event_click = event_content.split("%")[0];
        var module_name = event_content.split("%")[1];
        var filepath = 'include/js/modules/' + module_name + '/' + module_name + '.js';
        switch(event_name){
            case 'related_add_url':
            case 'moduledetail_related_add_url':
            case 'checkReturn':
            case 'checkPurchaseReturn':
                eval(event_click);
                break;
            case 'NewPaymentPlan':
            case 'NewSendPayment':
                getJsScript(filepath,function(){
                    eval(event_click);
            	});
                break;
        }
    }
}
//销售目标 显示提示信息
function showprompt(id){
    if(document.getElementById(id).style.display =='none'){
       document.getElementById(id).style.display = '';
    }else{
       document.getElementById(id).style.display = 'none';
    }

}
//列表打印
function setModulePrint(module,printid,record){
	var popupobj = CrmPopup.getPopupObj("last");
	var templatetype = ld("#"+popupobj.divid).find("[name=templateprintmoduletype]").find('option:selected').attr('type');// 模板类型
	ld.ajax("index.php?action=UsersAjax&module=Users&file=getModuleApprovePrint&print_module="+module+'&printid='+printid+"&record="+record)
	.done(function(results){
		if(results.indexOf('error') > -1){
			RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['ApprovedAllowPrintRemind']);
		}else{
			var urlstring = 'index.php?module=Settings&action=TemplatePrintHtml&tabname='+module+'&printid='+printid+'&record='+record;
			if(!empty(templatetype)){// XUQIU1000367 打印模板优化--新增Word和Excel打印模板--第一版（参考纷享）
				if(templatetype == 'Word')
					urlstring += '&CreateDOC=true';
				else if(templatetype == 'Excel')
					urlstring += '&CreateExcel=true';
				
				urlstring += '&mode=print';
				urlstring += '&templatetype=' + templatetype;
				ldAjaxNoProgress(urlstring, '', function (data) {
					if(data.code == 1){
						Pre_Attachment(data.result.fileobj);
					}
				});
			}else{
				OpenNewWebTab(urlstring);
				// window.open('index.php?module=Settings&action=TemplatePrintHtml&tabname='+module+'&printid='+printid+'&record='+record);
			}
		}
	});
}
//打开新弹出窗口 参数设置
function getNewWindowParams(){
	var params='',iTop=0,iLeft=0;
     var iWidth=800;                          //弹出窗口的宽度;
     var iHeight=600;                       //弹出窗口的高度;
     var w_width=typeof window.screen.availWidth ==='number'? window.screen.availWidth :0;
     var w_height=typeof window.screen.availHeight ==='number'? window.screen.availHeight :0;
     if(w_width&&w_height){
	     iTop = (window.screen.availHeight-30-iHeight)/2; //获得窗口的垂直位置（居中显示）
	     iLeft = (window.screen.availWidth-10-iWidth)/2;//获得窗口的水平位置（居中显示）
     }
		 params='width='+iWidth
                +',height='+iHeight
                +',top='+iTop
                +',left='+iLeft
                +',fullscreen=no' //是否使用全屏模式显示浏览器
                +',location=no'//是否显示地址字段。默认是 yes
                +',menubar=no'//是否显示菜单栏。默认是 yes
                +',resizable=yes'//窗口是否可调节尺寸。默认是 yes
                +',scrollbars=yes'//是否显示滚动条。默认是 yes
                +',status=no'//是否添加状态栏。默认是 yes
                +',toolbar=no'//默认是 yes
	return params;
}

function List_CheckBox_Ids()
{

}
List_CheckBox_Ids.getIds=function(module)
{
	var search_urlobj = ld("#search_url");
	var allselectedboxes_obj = ld("#allselectedboxes");
	var excludedRecords_obj = ld("#excludedRecords");
	var numOfRows_obj = ld("#numOfRows");
    var searchurl = '';
	if(search_urlobj.length>0){
		search_urlobj.get(0).value;
	}
	var viewid = getviewId();
	var idstring = "";
	//if(module != 'Documents'){

		var select_options = (allselectedboxes_obj.length>0)?allselectedboxes_obj.get(0).value:'';
		var excludedRecords = (excludedRecords_obj.length>0)?excludedRecords_obj.get(0).value:'';
		var numOfRows = (numOfRows_obj.length>0)?numOfRows_obj.get(0).value:'';
		if(select_options == 'all'){
			document.getElementById('idlist').value = select_options;
			idstring = select_options;
            List_CheckBox_Ids.ids='all';

			var skiprecords = excludedRecords.split(";");
			var count = skiprecords.length;
			if(count > 1){
				count = numOfRows - count + 1;
			} else {
				count = numOfRows;
			}
            List_CheckBox_Ids.num_rows=count
		}
		else if(select_options != undefined){
			var x = select_options.split(";");
			count = x.length;

            document.getElementById('idlist').value = select_options;
			idstring = select_options;
            List_CheckBox_Ids.ids=idstring;
			count = count - 1;
            List_CheckBox_Ids.num_rows=count;
		}

}

List_CheckBox_Ids.getSelected_rows=function(module)
{
    List_CheckBox_Ids.getIds(module);
    return List_CheckBox_Ids.num_rows;
}
List_CheckBox_Ids.logic_operation=function(module)
{

    return false;
}

function showlistimageview(recordid)
{

    var galley = document.getElementById('listviewimage_'+recordid);

	previewImage(galley);

}
function previewImage(galley)
{

	var viewer = new Viewer(galley, {
        url:function(image){
			ld(".viewer-title").css("display","none");
            //ld(".viewer-title").html(decodeURIComponent(ld(".viewer-title").html()));
			return  (image.getAttribute("data-original"));
        } ,
        toolbar: {
        ///  oneToOne: true,

          prev: function() {
            viewer.prev(true);
          },


          next: function() {
            viewer.next(true);
          },
          rotateLeft: true,
         rotateRight: true,
			flipVertical: function() {//BUG0054680 下载是自定义功能没有图标，使用viewer-flip-vertical
            const a = document.createElement('a');

            a.href = viewer.image.src;
            a.target = '_blank';//BUG0054766 图片的这个按钮希望能够在新的标签页打开，目前(cos)点击之后没法再返回
            a.download = decodeURIComponent(viewer.image.alt);
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
          },
        },
      });
}
/**
 2020-4-29 Dong
 * ajax 图表请求
 * @param ajaxurl
 * @param columnname
 * @param queryfrom
 * @param querywhere
 * @param module
 * @param queryowner
 * @param relatedfrom
 */

// http://127.0.0.1:88/crm/index.php?module=Accounts&action=AccountsAjax&file=ListViewReportAjax
function ajaxChartOpen(ajaxurl,columnname,queryfrom,querywhere,module,queryowner,relatedfrom){
	EmptyProgressObjs();
	var tmppage_list_query = '';
	var tmppopupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
	if(tmppopupobj&&tmppopupobj.page_list_query){
		tmppage_list_query = tmppopupobj.page_list_query;
	}

	var that=this;
	ldAjax(ajaxurl,{columnname:columnname,queryfrom:queryfrom,querywhere:querywhere,queryowner:queryowner,relatedfrom:relatedfrom,page_list_query:tmppage_list_query},function(data){
		var popupobj=  CrmPopup.load(data.result.title,that.clickOktext,"",800,module,"",data.result.oktext,"",'');
		CrmPopup.setPopupobjHtmlContent_scroll(popupobj,data.result.content);
		newHighChart('container_listview',data.result);
		// console.log(data.result.fieldValue)
        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
        {
                         //通讯录(pc端企业微信)
                cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
        }

		DelProgressObjs();
	})
	that.clickOktext=function(){
		popupobj.CancelEvent();
	}
}

function newHighChart(id,data){
	var saveasimage = arrJsPopLabel['SAVEASIMAGE'];
	//zxm 2021-0309 highcharts改成echarts
	var value =[];
	if(data.lineName != undefined){
		for(let j =0;j<data.lineName.length;j++){
			let field = 'fieldValue'+j;
			let obj ={
				name:data.lineName[j],
				data: data[field],
				type:'bar',
				barMaxWidth :18,
                //显示数值
                label: {
					show: true, //开启显示
					position: 'top', //在上方显示
					rotate:45,
					distance:5,
					verticalAlign:"middle",
                  	textStyle: {
                    //数值样式
                    color: 'black',
                    fontSize: 10,
                  },
                },
            };
			value[j] =obj;
		}
	}else{
		//单柱状图的时候 系列名不需要显示 zxm 20220921BUG0056807
		value = [
			{
				data:data.fieldValue,
				type:'bar',
				barMaxWidth :18,
            	//显示数值
            	label: {
					show: true, //开启显示
					position: 'top', //在上方显示
					rotate:45,
					distance:5,
					verticalAlign:"middle",
					textStyle: {
						//数值样式
						color: 'black',
						fontSize: 12,
					},
				},
        }];
	}

	var myChart = echarts.init(document.getElementById(id),echartTheme);
	//wyt 221008 BUG0057412 (解决办法：tooltip的confine属性和extraCssText属性控制) 图中部分不应该超出这个弹框
	var tooltip = {
		trigger: 'axis',
		confine: true,
		extraCssText: 'white-space: normal; word-break: break-all;',
		axisPointer : { // 坐标轴指示器，坐标轴触发有效
			type : 'shadow' // 默认为直线，可选为：'line' | 'shadow'
		},
		textStyle:{
			align:'left'
		}
	};
	var title = {
		text: ''
	};
	var grid = {
		left: '3%',
		right: '4%',
		bottom: '15%',
		top: '5%',
		containLabel: true
	};
	var option = {
		title: title,
		grid: grid,
		legend:{
			'type':'scroll',
			'bottom':10
		},
		xAxis: {
			type: 'category',
			data: data.fieldName,
			axisTick:{interval:0},
			axisLabel:{rotate: 45}//BUG20240703-37	目标管理完成情况统计图，把下面X轴的时间做个旋转
		},
		yAxis: {
			min: 0,
			title: {
				text: ''
			},
			axisLabel: {
				formatter: function(value){
					if((value/(1000*1000*1000*1000))>1){
						return (value/(1000*1000*1000*1000))+"T";
					}else if((value/(1000*1000*1000))>1){
						return (value/(1000*1000*1000))+"G";
					}else if((value/(1000*1000))>1){
						return (value/(1000*1000))+"M";
					}else if((value/(1000))>1){
						return (value/(1000))+"K";
					}else{
						return value;
					}
				}
			}
		},
		tooltip: tooltip,
		series: value,
        toolbox: {
            show: true,
			right:'3%',
            feature: {
              saveAsImage: {
                name: data.title,
			  	title:saveasimage
              }
            }
        },
	}
	myChart.setOption(option);
}


// @edit:dong @date:2020/08/04 @reason: 地图定位功能 uitype65 需要的方法 由Accounts.js 移动出来
var location_lat = 0;
var location_lng = 0;

function getLocationAddress(fldname,mode){

	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	if(!empty(fldname)){
		var locationaddressobj = CrmPopup.findHtmlobj(divid,fldname);
		if(locationaddressobj.length<=0){
			return false;
		}
		if (locationaddressobj.attr('inputtype') == 'start'){
			return false;
		}
	}

	//默认省份
	var bill_state = '';
	var bill_city = '';

	if(popupobj.pagetype==CreatePagePopup.pagetype){
		bill_state = CrmPopup.findHtmlobj(divid,'bill_state').val();
		bill_city = CrmPopup.findHtmlobj(divid,'bill_city').val();
	}else if(popupobj.pagetype==DetailViewPage.pagetype){
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
	var module_mod = '';
	if(mode == 'detail' || mode == 'edit'){
		var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint=yes";	//单
	}else{
		var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint_list=yes";	//多、列表
		module_mod = 'select';
	}
	ldAjaxHtmlNoProgress('index.php?',urlajax,function(ajaxhtml){
		var results = trim(ajaxhtml);
		if(results != ''){
			ld('#'+divid + ' .f-item').css('display', 'block');
			var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
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
				ld('#'+divid + ' .f-item').css('display', 'block');

				ld('#'+divid).unbind('click').on('click',function(){
					CrmPopup.findHtmlobj(divid,'search_location_address').hide();
				});


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
						if((CrmPopup.findHtmlobj(divid,'bill_street').val() != undefined && CrmPopup.findHtmlobj(divid,'bill_street').val() != '')||(CrmPopup.findHtmlobj(divid,'mailingstreet').val() != undefined && CrmPopup.findHtmlobj(divid,'mailingstreet').val() != '')||(CrmPopup.findHtmlobj(divid,'street').val() != undefined && CrmPopup.findHtmlobj(divid,'street').val() != '')){
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

	});
}

//加载地图
function scriptMap(address,district,city,state,country){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	//ls 20221228 按照district分割，地址只显示省市区后面的信息。
	if (!empty(address) && !empty(district)) {
		var address_arr = address.split(district);
		if (address_arr.length == 2) {//没有被分割或者分割多次则使用原地址
			address = address_arr[1];
		}
	}
	CrmPopup.findHtmlobj(divid,'bill_street').val(address);
	CrmPopup.findHtmlobj(divid,'span_bill_street').html(address);
	if(CrmPopup.findHtmlobj(divid,'mailingstreet').val() != undefined){
		CrmPopup.findHtmlobj(divid,'mailingstreet').val(address);
	}
	if(CrmPopup.findHtmlobj(divid,'street').val() != undefined){
		CrmPopup.findHtmlobj(divid,'street').val(address);
		CrmPopup.findHtmlobj(divid,'span_street').html(address);
	}
	if(CrmPopup.findHtmlobj(divid,'bill_city').val() != undefined){
		CrmPopup.findHtmlobj(divid,'bill_city').val(city);
		CrmPopup.findHtmlobj(divid,'span_bill_city').html(city);
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_city').val(city);
	}
	if(CrmPopup.findHtmlobj(divid,'bill_state').val() != undefined){
		CrmPopup.findHtmlobj(divid,'bill_state').val(state);
		CrmPopup.findHtmlobj(divid,'span_bill_state').html(state);
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_state').val(state);
	}
	if(CrmPopup.findHtmlobj(divid,'bill_area').val() != undefined){
		CrmPopup.findHtmlobj(divid,'bill_area').val(district);
		CrmPopup.findHtmlobj(divid,'span_bill_area').html(district);
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_area').val(district);
	}
	if(CrmPopup.findHtmlobj(divid,'bill_country').val() != undefined){
		CrmPopup.findHtmlobj(divid,'bill_country').val(country);
		CrmPopup.findHtmlobj(divid,'span_bill_country').html(country);
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_country').val(country);
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
	ld("#"+divid+" [name=location_map_td]").show();
	var center = new qq.maps.LatLng(location_lat,location_lng);
	//定义map变量 调用 qq.maps.Map() 构造函数   获取地图显示容器
	var map = new qq.maps.Map(ld("#"+divid+" [name=container]")[0], {
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

function enlarge_map(address){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	if(empty(address)){
		address = CrmPopup.findHtmlobj(divid,'locationaddress').val();
	}
	var record = CrmPopup.findHtmlobj(divid,'record').val();
	var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint=yes&record="+popupobj.record+"&frommodule="+popupobj.module;	//单
	//alert(urlajax);
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
					var table_html = '<div name="big_container" id="big_container" style="height:400px;"></div>';
					resultRemindsMsg(arrJsPopLabel['ACCOUNTSMAP'],"LdPopWidth800px","","yes","",table_html);
					//创建script标签
					var script = document.createElement("script");
					//设置标签的type属性
					script.type = "text/javascript";
					//设置标签的链接地址
					script.src = "https://map.qq.com/api/js?v=2.exp&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X&callback=Big_initMap";
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
var account_map,account_center,InfoWindow,infoWin;
function changeListMap(obj,module,btn_type,page,popupobj){

	var a = ld('#pagehead').outerHeight(true),//头部高度
		//zxm BUG0060693	已分派	功能BUG	正常处理	客户地图视图列表界面，左侧单据列表界面，没有显示上一页和下一页操作按钮
		//b = ld('.tabHieght').outerHeight(true),//标签高度
		b = 0,
		c = ld('.main_grid_top').outerHeight(true),//数据分类/按钮等区块的高度
		// d = ld('.D_btn_box').outerHeight(true);//按钮高度
		d = 0;//按钮高度
	h_height = 0,
		s_height = ld(window).height();

	if(a==null) a=0;
	if(a == 0) a=55;
	if(b==null) b=0;
	if(b == 0) b=10;
	if(c==null) c=0;
	if(d==null) d=0;
	h_height = a+b+c+d;

	//var  popupobj=CrmPopup.getPopupObj('last');
	popupobj.page=page;
	if(empty(page))page = 1;
	if(btn_type=='list')
	{
		popupobj.type=ListPagePopup.type;
	}
	else

		popupobj.type='maplist';

	var urlstring = "index.php?module=Accounts&action=AccountsAjax&file=Map_ListView&page="+page+'&frommodule='+module+'&';
	//基本、高级查询条件
 // alert(searchtype_btn);
	//if(!empty(searchtype_btn)){
	//	urlstring += getUrlString(searchtype_btn);
    //edit:can 20210514 0045889: （https://61mis.com/kfbcrm [^]）客户问题（广东新业），客户地图，点击“广东->广州”，进入客户单据列表界面，再点击“地图视图”模式图标时，带过来的查询条件没有生效（需要补丁）
		urlstring += "query_session=1";
//	}
	urlstring += '&btn_type='+btn_type;
	//@edit:zkt @date:2024/12/4 @reason: BUG20241203-75 登录陈增炬账号；政企客户管理-政企客户档案列表界面-点击地图视角提示“未找到任何记录”。管理员账号选择“陈增炬”的客户可以正常进入地图视角（潘：我启用了国家字段和重算经纬度都不行）
	if(popupobj != undefined && popupobj.linkmodulecustom == 'yes'){
		if(ld("#"+popupobj.divid+" [name=viewname]").length>0){
			urlstring += '&viewname='+ld("#"+popupobj.divid+" [name=viewname]").val();
		}
		urlstring += '&ajaxtype=ld_linkmodulecustom';
	}
    //zkt 20230703 BUG0068992  单据单页条数设置显示200条后打开客户档案中的客户地图一直装圈，无法加载
    ldAjax(urlstring,'',function(data){
        if(data.code==1)
			{
				ld("#divMapLeft").html(data.result.content);
				ld('.map-list').css('height','calc(100% - 57px)');

				var data_map_detail_json = eval('('+ data.result.map_content +')')?eval('('+ data.result.map_content +')'):JSON.parse(data.result.map_content);
				if(btn_type == 'list'){
					ld('#structuretree').show();
					ld('span.tree-closeopen').show();
					ld('#hdScrolllistentries_yy').show();
					ld(' .list-item span').removeClass('cur');
					ld(' .list-item span i.list-btn').parent().addClass('cur');
					ld('#divMapShow').hide();
				}else{
					ld('#structuretree').hide();
					ld('span.tree-closeopen').hide();
					ld('#hdScrolllistentries_yy').hide();
					ld(' .list-item span').removeClass('cur');
					ld(' .list-item span i.map-btn').parent().addClass('cur');
					ld('#divMapShow').show();
					var listviewscreenheight = ld('#ld-listview-screen').get(0).offsetHeight;
					ld('#divMapShow').css('height',s_height-h_height-listviewscreenheight-5);
					ld('#map_div').css('height','100%');

					//客户名称绑定事件
					ld('.map-list .map-list-item').on('click',function(e){
						var account_id = ld(this).attr('data-id');
						var account_latitude = ld(this).attr('data-latitude');
						var account_longtitude = ld(this).attr('data-longtitude');
						ld('.map-list .map-list-item').removeClass('cur');
						ld('.map-list .map-list-item[data-id='+account_id+']').addClass('cur');
						//明细界面
						if(ld(e.target).hasClass('title')){
							//console.log('明细界面');
						}
						//编辑界面
						else if(ld(e.target).hasClass('change-geo')){
							//alert('编辑界面');
							var module = 'Accounts';
							var urlstring = 'module=Users&action=UsersAjax&file=callStaticMethod';
							urlstring += '&static=puyoung&method=checkEditInfo';
							urlstring += '&fld_module=Accounts&record='+account_id;

							RequestAjax(urlstring,function(rest){
								if(empty(rest)){
									DelProgressObjs();
									return false;
								}
								var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
								if(restobj.check.indexOf('SUCCESS')>=0){
									var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",module,"","","","",account_id);
									Popupobj.prevshow();
									var url = 'module='+module+'&action=EditView&record='+account_id;
									url += '&return_module=module&return_action=ListView';

									//列表和相关信息编辑
									PageRecordPopup.params['refreshpage']='no';

									PageRecordPopup.showpage(module,account_id,"", PageRecordPopup.params);
									//zxm20230329  kfbcrm 客户地图--点击左侧列表编辑---弹出层会闪过空白页---没加载出来时，应该显示转圈
									//DelProgressObjs();
								}else{
									RemindsMsg("","LdPopWidth400px",module,"yes","",restobj.check);
									//zxm20230329  kfbcrm 客户地图--点击左侧列表编辑---弹出层会闪过空白页---没加载出来时，应该显示转圈
									//DelProgressObjs();
									return false;
								}
							});
						}
						//显示地图
						else{
							//console.log('显示地图');
							if (infoWin && infoWin.getMap()) {
								infoWin.setMap(null);
							}
							if(account_latitude == '' || account_longtitude == ''){
								return;
							}
							var title='', text = '';
							title = data_map_detail_json[account_id]['accountname'];
							for (fieldname in data_map_detail_json[account_id])
							{
								if(fieldname != 'accountname' && fieldname != 'local_address' && fieldname != 'lat' && fieldname != 'lng'){
									text +=data_map_detail_json[account_id][fieldname] + '<br/>';
								}
							}

							account_center = new qq.maps.LatLng(account_latitude,account_longtitude);
							account_map.setCenter(account_center);
							initMapAccount();
							infoWin = new qq.maps.InfoWindow({
								map: account_map
							});
							infoWin.open();
							infoWin.setContent( '<div style="width:320px;">' +
								'<div style="font-size: 14px;font-weight: bold;color: #333;padding-bottom: 5px;">'+ title +'</div>' +
								'<div style="font-size: 12px;color: #999;">'+ text +'</div>' +
								'</div>');
							infoWin.setPosition(account_center);
							setTimeout(function() {
								infoWin.close();
							}, 20 * 1000);
						}
					});
					//创建script标签
					var script = document.createElement("script");
					//设置标签的type属性
					script.type = "text/javascript";
					//设置标签的链接地址
					script.src = "https://map.qq.com/api/js?v=2.exp&callback=initMap2&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X";
					//添加标签到dom
					document.body.appendChild(script);

					//zxm 20230201 	BUG0060954	已分派	功能BUG	客户地图视图模式，左侧第一页点击详细地址时，右侧地图中没有显示地图详情信息
					setTimeout(function(){
						ld('.map-list .map-list-item').first().click();
					},500);
				}

				//yujun 只显示一个图标,先显示地图图标 2023-6-6
				var tmp_listbtn = ld(obj);
				if(obj.id == 'tip_list'){
					var parent_another_child = tmp_listbtn.parent().find('#tip_map');
					parent_another_child.css('display','block');
					tmp_listbtn.css('display','none');
				}else{
					var parent_another_child = tmp_listbtn.parent().find('#tip_list');
					parent_another_child.css('display','block');
					tmp_listbtn.css('display','none');
				}
			}
			else{
				var confirm_str = arrJsPopLabel['NORECORDSAREFOUND'];
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
            DelProgressObjs();
    })

}
//加载地图api后的回调函数
function initMap2(){
	var InfoWindow = null;
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	account_center = new qq.maps.LatLng(first_map_lat,first_map_lng);
	//定义map变量 调用 qq.maps.Map() 构造函数   获取地图显示容器
	account_map = new qq.maps.Map(ld("#"+divid+" [name=map_div]")[0], {
		center: account_center,      // 地图的中心地理坐标。
		zoom:15,                                           // 地图的中心地理坐标。
		disableDefaultUI: true
	});
	//创建标记
	var anchor = new qq.maps.Point(6, 6),
		size = new qq.maps.Size(23, 38),
		origin = new qq.maps.Point(0, 0);
	//icon = new qq.maps.MarkerImage('themes/images/location.png', size, origin, anchor);
	var marker = new qq.maps.Marker({
		//icon: icon,
		position: account_center,
		map: account_map
	});
	initMapAccount();
}
//加载地图上客户信息
function initMapAccount(){
	// BUG0071118 ls 20230816 项目信息（客户）模块的地图模式，第1、2页的地图点还显示正常，但是切换到第3页，地图点就只能显示一个，多的显示不出来(json解析错误)
	data_map_detail = data_map_detail.replace(/\s+/g, ' ');
	var data_map_detail_json = eval('('+ data_map_detail +')')?eval('('+ data_map_detail +')'):JSON.parse(data_map_detail);
	InfoWindow = new qq.maps.InfoWindow({ map: account_map });//添加提示窗
	var i = 0;
	for (account_id in data_map_detail_json){
		var _rotation = '';	//其他内
		var _name = '';	//主题
		var _lat = '';
		var _lng = '';
		for (fieldname in data_map_detail_json[account_id]){
			if(fieldname == 'accountname'){
				_name = data_map_detail_json[account_id][fieldname];
			}else if(fieldname == 'lat'){
				_lat = data_map_detail_json[account_id][fieldname];
			}else if(fieldname == 'lng'){
				_lng = data_map_detail_json[account_id][fieldname];
			}else{
				_rotation += data_map_detail_json[account_id][fieldname]+'<br>';
			}
		}
		var marker = new qq.maps.Marker({ position: new qq.maps.LatLng(_lat, _lng), map: account_map });//创建标记
		//***将必要的数据存入每一个对应的marker对象
		var j = i+1;
		marker.id = j;
		marker.name = _name;
		marker.rotation = _rotation;
		qq.maps.event.addListener(marker, 'click', function(event) {//获取标记的点击事件
			InfoWindow.open();//点击标记打开提示窗
			var content =   '<div style="width:320px;">' +
				'<div style="font-size: 14px;font-weight: bold;color: #333;padding-bottom: 5px;">'+ event.target.name +'</div>' +
				'<div style="font-size: 12px;color: #999;">'+ event.target.rotation +'</div>' +
				'</div>';
			InfoWindow.setContent(content);
			InfoWindow.setPosition(new qq.maps.LatLng(event.latLng.getLat(), event.latLng.getLng()));//提示窗位置
			setTimeout(function() {
				InfoWindow.close();
			}, 20 * 1000);
		});
		i++;
	}
}
// @edit:dong @date:2020/08/04 @reason: 地图定位功能 uitype65 需要的方法 由Accounts.js 移动出来
//end

function getListTotalRow(){
    var popupobj=CrmPopup.getPopupObj('last');

    ldAjax("index.php?module="+module+"&action="+module+"Ajax&file=getListTotalRow",{},function(ajaxdata){
        ld("#listrowcount").html("共有"+ajaxdata.result.count+"条记录");
        ld("#count").html(ajaxdata.result.count);
        //ld("#maxrecords").val(ajaxdata.result.count);
        ld("#numOfRows").val(ajaxdata.result.count);
        DelProgressObjs();
    })
}

//表单码列表页增加‘查看二维码’按钮
function viewFormQrCode_listview(modulename,fieldid,uitype,recordid){
    getJsScript('include/js/SystemPopup/DetailViewPage.js', function () {
                viewFormQrCode(modulename,fieldid,uitype,recordid);
            });
}
//表单码列表页增加‘查看提交日志’按钮
function FormQrCode_Viewlog_listview(trackid,module,fieldid,uitype,record){
    getJsScript('include/js/SystemPopup/DetailViewPage.js', function () {
                FormQrCode_Viewlog(trackid,module,fieldid,uitype,record);
            });
}

//duan 群发邮件-增加服务收费管理模块
function servicecharge_btn_MassSMS(){
    var prevpopupobj=CrmPopup.getPopupObj('lastprev');
	prevdivid=prevpopupobj.divid;
    var accountid = '';
    if(ld("#popup_rows_selectall").val()=='all')
    {
        accountid='all';
    }
    else
    {
        accountidobj = ld("#"+prevdivid+" [name=selected_id]");
        ld.each(accountidobj,function(){
            if(ld(this).prop('checked')){
                if(ld(this).attr('billinfo')!=undefined&&ld(this).attr('billinfo')>0){
                    accountid += ld(this).attr('billinfo')+',';
                }else{
                    accountid += ld(this).val()+',';
                }

            }
        })
        accountid = accountid.substring(0,accountid.length-1) ;
    }
    //获取所有的弹出框里选择的条目
	var popupobj=CrmPopup.getPopupObj('last');
	var divid = popupobj.divid;
    var tabid_fieldlabel ="";
    for(var i=0;i<100;i++)
    {
        var id = i+'_checkbox_pop_sms_account';
		//chj 2021/1/5 44066: 子淇软件（没有外网）短信群发模块>选择"联系人"/"客户档案"后，确认按钮点击异常，无响应。（切换浏览器无法解决）
        var id_check = CrmPopup.findHtmlobj(divid,id).prop("checked");
        if(id_check==undefined)
        {
            continue;
        }

        //选中的项目进行处理
        if(id_check)
        {
             tabid_fieldlabel +=CrmPopup.findHtmlobj(divid,id).val()+",";
        }
    }

    var search_field=ld("#"+prevdivid+" [name=search_field]").val();
    var search_text=ld("#"+prevdivid+" [name=search_text]").val();
    var url="index.php?module=MassSMS&action=MassSMSAjax&file=checkbox_checkservicecharge&fieldname="+encodeURIComponent(tabid_fieldlabel)+"&accountid="+accountid+"&mode=ajax";
    if(ld.trim(search_text)!='')
    {
        url+="&searchtype=BasicSearch&search_field="+search_field+"&search_text="+search_text+"&query=true";
    }
	//alert(url);
    ld.ajax({
        url: url,
        type: 'POST',
        dataType:'json',
        timeout:20000,
        success:function(data){
            // console.log(data.result.content);
            var all_info_window = data.result.content; 
            var popupobj=CrmPopup.getPopupObj("last");
			popupobj.CancelEvent();
			var popupobj=CrmPopup.getPopupObj("last");
			popupobj.CancelEvent();    
			var popupobj=CrmPopup.getPopupObj('last');
			var divid=popupobj.divid;
            var receivephone = CrmPopup.findHtmlobj(divid,'receivephone').val();
			CrmPopup.findHtmlobj(divid,'receivephone').val(receivephone+all_info_window);
        }
    });

}

//230711 wym 客户“圣拉维”，自定义表单01切换日历视图
function changeListCalendar(obj,module,page){
    
    var popupobj = CrmPopup.getPopupObj('last');
    var divid='ListViewContents';
	btn_type = ld(obj).attr('tag');
	var urlstring = "module=CustomForm01&action=CustomForm01Ajax&file=ListView&frommodule="+module;
	urlstring += '&btn_type='+btn_type+"&ajax=yes";
 
	 	var listview_page=new ListView_Page(module,urlstring,divid);
		listview_page.callback_fun=function()
		{
				if(document.getElementById('listview_advanced') != undefined){
					document.getElementById('listview_advanced').disabled = false;
				}
                if(btn_type == 'list'){
                    popupobj=CrmPopup.getPopupObj("last");
                    setContentHeight(popupobj.module);//计算内容高度
                    popupobj.listresizeobj.setReiszeTable_Init(module,'');
					ld('#tip_calendar').hide();
					ld('#tip_list_calendar').show();
                } else{
					ld('#tip_calendar').show();
					ld('#tip_list_calendar').hide();
				}
		 }
          listview_page.page();
}

