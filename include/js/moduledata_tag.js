function moduledata_tag(module,record){
   var that=this;
}

//刷新单据详情标签内容
moduledata_tag.refreshdetail = function(record,moduledata_tag,moduledata_tag_type){
	var popupobj=CrmPopup.getPopupObj("last");
	ld("#"+popupobj.divid+" [name=module_list_tagger_span]").find('a').each(function(){
		ld(this).remove();
	});
	if(!empty(moduledata_tag)){
		var moduledata_tag_array = moduledata_tag.split(',');
		var moduledata_tag_type_array = moduledata_tag_type.split(',');
		var tagger_obj = ld("#"+popupobj.divid+" [name=module_list_tagger_span]");
		ld.each(moduledata_tag_array,function(ikey,tag){
			var tag_li_html = '<a href="javascript:void(0)" class="module-tagger-fm-button '+moduledata_tag_type_array[ikey]+'" tag_type="'+moduledata_tag_type_array[ikey]+'" select_li_name="">'+tag+'</a>';
			tagger_obj.append(tag_li_html);
		});
	}
}

//新增标签
moduledata_tag.add = function(module,record){
	var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=moduledata_tag&record='+record;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,moduledata_tag.save,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
			crmPopupobj.show(data.result.content);
			//ld("#mul_moduledata_tag").select2({closeOnSelect: false});
			tagger_class({el:'#input_tagger'});
			crmPopupobj.setScrollDivMaxHeight();
			crmPopupobj.center();
			moduledata_tag.allmodulelabel = data.result.allmodulelabel;
			
		}
	})
}

//保存标签
moduledata_tag.save = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var new_moduledata_tag = ld("#"+popupobj.divid+" [name=new_moduledata_tag]").val();
	var selected_moduledata_tag = ld("#"+popupobj.divid+" [name=input_tagger]").attr('tag_id');
	var module = ld("#"+popupobj.divid+" [name=moduledata_module]").val();
	var record = ld("#"+popupobj.divid+" [name=moduledata_record]").val();
	var corp_tag = 'personal';
	//企业标签
	if(ld("#"+popupobj.divid+" [name=corp_tag]") != undefined && ld("#"+popupobj.divid+" [name=corp_tag]").is(':checked') == true){
		corp_tag = 'company';
	}
	var urlstring = 'index.php?module='+module+'&action='+module+'Ajax&ajax=true&file=moduledata_tag&save=true';
	urlstring += '&record='+record+'&new_moduledata_tag='+encodeURIComponent(new_moduledata_tag)+"&selected_moduledata_tag="+encodeURIComponent(selected_moduledata_tag)+"&corp_tag="+corp_tag;
	//alert(urlstring);return false;
	ldAjax(urlstring,"",function(data){
		if(data.code==1){
			popupobj.CancelEvent();
			DelProgressObjs();
			var moduledata_tag_content = data.result.tag;
			var moduledata_tag_type = data.result.tag_type;
			moduledata_tag.refreshdetail(record,moduledata_tag_content,moduledata_tag_type);
			 var tmparra=new Array();
              tmparra.push(popupobj.record);
              //edit:can 54573:合同订单，标签添加到单据详情界面之后，打开单据详情，再添加标签，回到单据详情界面的标签栏不会更新，需要刷新才行 
			 var tmpobj= new AfterUpdatePrevPopupObjContent(module,data,tmparra);
			 tmpobj.eachrefreshlistbyModules(new Array(module));
		}else{
			RemindsMsg("","LdPopWidth400px","","yes","",data.result.msg);
			return false;
		}
	})
}

//修改标签类型（个人、企业）
moduledata_tag.updateTagType = function(event,tagobj){
	var selfinput = tagobj.parent().prev().find('input');
	var tag_id = ld(selfinput).attr('tag_id');
	var tag_type = ld(selfinput).attr('tag_type');
	if(tag_id > 0 && !empty(tag_type)){
		var urlstring = 'index.php?module='+module+'&action='+module+'Ajax&ajax=true&file=moduledata_tag&updateTagType=true';
		urlstring += '&tag_id='+tag_id+'&tag_type='+tag_type;
		//alert(urlstring);return false;
		ldAjax(urlstring,"",function(data){
			if(data.code==1){
				DelProgressObjs();
				if(tag_type == 'personal'){
					tagobj.attr('class','module-tagger-icon-company');	//企业
                    //zkt 20220929 BUG0057230如图，标签设置的时候，更改个人和企业标签的图标，悬浮的文字没有变化
                    tagobj.attr('title',arrJsPopLabel['onverttopersonaltag']);	//转换为个人标签
					 ld(selfinput).attr('tag_type','company')
				}else{
					tagobj.attr('class','module-tagger-icon-personal');	//个人
                    tagobj.attr('title',arrJsPopLabel['Converttocampanytag']);	//转换为企业标签
					 ld(selfinput).attr('tag_type','personal')
				}
			}
		})
	}
}

//上移
moduledata_tag.move=function(obj,move_type){
	var selfinput = ld(obj).parent().prev().find('input');
	if(move_type == 'up')
		var upinput = ld(obj).parent().parent().prev().find('input:first');	//上移
	else{
		//chj 2021/8/9 47154: （81mis.com/kfbcrm）客户管理-客户，单据详情界面，点击添加标签-点击设置，调整标签顺序，第一个标签无法下移
		var upinput = ld(obj).parent().parent().next().find('input:first');	//下移
	}
	
	var selfval = ld(selfinput).val();
	var self_tag_id = ld(selfinput).attr('tag_id');
	var self_tag_type = ld(selfinput).attr('tag_type');
	var self_tag_sequence = ld(selfinput).attr('tag_sequence');
	var upval = ld(upinput).val();
	var up_tag_id = ld(upinput).attr('tag_id');
	var up_tag_type = ld(upinput).attr('tag_type');
	var up_tag_sequence = ld(upinput).attr('tag_sequence');
	//alert(up_tag_type+'=='+up_tag_sequence);
	//文本值
	ld(selfinput).val(upval);
	ld(selfinput).attr('tag_id',up_tag_id);
	ld(selfinput).attr('tag_type',up_tag_type);
	ld(upinput).val(selfval);
	ld(upinput).attr('tag_id',self_tag_id);
	ld(upinput).attr('tag_type',self_tag_type);
	//upinput
	var popupobj=CrmPopup.getPopupObj("last");
	if(self_tag_type == 'personal'){
		ld("#"+popupobj.divid+" [name=tag_sequence_"+up_tag_sequence+"]").attr('class','module-tagger-icon-personal');
		ld("#"+popupobj.divid+" [name=tag_sequence_"+up_tag_sequence+"]").attr('title',arrJsPopLabel['Converttocampanytag']);
	}else{
		ld("#"+popupobj.divid+" [name=tag_sequence_"+up_tag_sequence+"]").attr('class','module-tagger-icon-company');
		ld("#"+popupobj.divid+" [name=tag_sequence_"+up_tag_sequence+"]").attr('title',arrJsPopLabel['onverttopersonaltag']);
	}
	if(up_tag_type == 'personal'){
		ld("#"+popupobj.divid+" [name=tag_sequence_"+self_tag_sequence+"]").attr('class','module-tagger-icon-personal');
		ld("#"+popupobj.divid+" [name=tag_sequence_"+self_tag_sequence+"]").attr('title',arrJsPopLabel['Converttocampanytag']);
	}else{
		ld("#"+popupobj.divid+" [name=tag_sequence_"+self_tag_sequence+"]").attr('class','module-tagger-icon-company');
		ld("#"+popupobj.divid+" [name=tag_sequence_"+self_tag_sequence+"]").attr('title',arrJsPopLabel['onverttopersonaltag']);
	}
	
}

//隐藏首末排序的上移下移
moduledata_tag.hidesort=function(){
	var popupobj=CrmPopup.getPopupObj("last");
	
	ld('#'+popupobj.divid+' .sort_td:first').children("a:eq(0)").hide();
	ld('#'+popupobj.divid+' .sort_td:last').children("a:eq(1)").hide();
}

//修改选择可用标签 - 删除操作
moduledata_tag.delSelectTag = function(event,tagobj){
	var popupobj=CrmPopup.getPopupObj("last");
	var deleted_tag_id = ld("#"+popupobj.divid+" [name=deleted_tag_id]").val();
	var selfinput = tagobj.parent().prev().find('input');
	var tag_id = ld(selfinput).attr('tag_id');
	if(deleted_tag_id == ''){
		ld("#"+popupobj.divid+" [name=deleted_tag_id]").val(tag_id);
	}else{
		ld("#"+popupobj.divid+" [name=deleted_tag_id]").val(deleted_tag_id+','+tag_id);
	}
	tagobj.parent().parent().remove();
	// moduledata_tag.hidesort();
}

//选择可用标签：下拉框选择事件
moduledata_tag.cmb_liclick =function(event,fldname,tagobj){
	var popupobj=CrmPopup.getPopupObj("last");
	var tagger_obj = ld("#"+popupobj.divid+" [name=tagger_span]");
	if (popupobj.divid.startsWith('Contacts')){
		tagger_obj.append( ld('<a href="javascript:void(0)" class="module-map-right-tagger-fm-button '+tagobj.attr('tag_type')+'" style="margin: 2px" tag_id="'+tagobj.attr('tag_id')+'" tag_type="'+tagobj.attr('tag_type')+'" select_li_name="'+tagobj.attr('name')+'" >'+tagobj.html()+'<em> </em></a>') );
	}else {
		tagger_obj.append( ld('<a href="javascript:void(0)" class="module-tagger-fm-button '+tagobj.attr('tag_type')+'" style="margin: 2px" tag_id="'+tagobj.attr('tag_id')+'" tag_type="'+tagobj.attr('tag_type')+'" select_li_name="'+tagobj.attr('name')+'" >'+tagobj.html()+'<em> </em></a>') );
	}
	ld("#"+popupobj.divid+" [name=cmb_span_optiontext_"+fldname+"]").val('');
	tagobj.hide();
	moduledata_tag.setInputTagValue();
	CrmPopup.findHtmlobj(popupobj.divid,"cmb_a_"+fldname).attr("class","");
    CrmPopup.findHtmlobj(popupobj.divid,"cmb_a_"+fldname).attr("class",'chzn-single');
	CrmPopup.findHtmlobj(popupobj.divid,'dv_drop_'+fldname).css("left","-9000px");//隐藏下拉框
    
    //edit: xll BUG0065788 kfbcrm-客户-单据详情-添加标签，若无可用标签时，应在下拉框内出现提示信息
    moduledata_tag.option_num_check('select');
    
	//alert(tagger_obj.text().match(/\S+/g).join(','));
	//alert(tagger_obj.attr('tag_id').match(/\S+/g).join(','));
	return false;
	//alert(fldname);
}

//添加删除后，给标签赋值
moduledata_tag.setInputTagValue =function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var module_tag_label = new Array();
	var module_tab_id = new Array();
	var module_tab_type = new Array();
	var i =0;
	ld("#"+popupobj.divid+" [name=tagger_span]").find('a>em').each(function() {
		module_tag_label[i] = ld(this).parent().text();
		module_tab_id[i] = ld(this).parent().attr('tag_id');
		module_tab_type[i] = ld(this).parent().attr('tag_type');
		i++;
	});
	ld("#"+popupobj.divid+" [name=input_tagger]").val(module_tag_label.join(','));
	ld("#"+popupobj.divid+" [name=input_tagger]").attr('tag_id',module_tab_id.join(','));
	ld("#"+popupobj.divid+" [name=input_tagger]").attr('tag_type',module_tab_type.join(','));
}

//选择可用标签 - 设置修改
moduledata_tag.getCombox = function(module,fieldname){
	var popupobj=CrmPopup.getPopupObj("last");
	var select_module_tab_id = new Array();
	var i = 0;
	var comboxarr = [];
	ld("#"+popupobj.divid+" [name=cmb_ul_select_input_tagger]").find('li').each(function(){
		if(ld(this).attr('name') != 'li_chzn_select_input_tagger'){
			select_module_tab_id[i] = ld(this).attr('tag_id');
			 var comboxtext = {'tag_id':''+ld(this).attr('tag_id')+'','tag_display':''+ld(this).css('display')}; 
			 comboxarr.push(comboxtext);
			i++;
		}
	});
	var comboxjson = JSON.stringify(comboxarr);
	var urlstring = 'index.php?module='+module+'&action='+module+'Ajax&ajax=true&file=moduledata_tag&setSelect=true';
	urlstring += '&select_module_tag_json='+comboxjson;
	//alert(urlstring);return false;
	ld.ajax({
        url: urlstring,
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 5000,
        error: function(XMLHttpRequest, textStatus, errorThrown) {
        },
        success: function(data)
        {
            if(data.code==1)
            {
                var ComboxPopupobj=ComboxPopup.load(data.result.title,moduledata_tag.okfunctionname,"","LdPopWidth400px",module,[module,fieldname],data.result.oktext,"",data.result.canceltext);
                //console.log(data.result.title+'------------'+ComboxSave+'------------'+""+'------------'+"LdPopWidth350px"+'------------'+module+'------------'+[module,fieldname]+'------------'+data.result.oktext+'------------'+""+'------------'+data.result.canceltext);
                ComboxPopupobj.refreshpage='yes';
                ComboxPopupobj.show(data.result.content);
				//wym 240109 BUG20240108-93 标签-选择可用标签-设置-改为拖动按钮
				//moduledata_tag.hidesort();
				var dragobj = ld("table[name=moduletagcontent]").find("tbody").get(0);
				Sortable.create(dragobj, {
					draggable: ".ld-category-draggable",
					handle: ".drag-handle",
					onEnd: function (evt){
					}
				})
                ComboxPopupobj.editfieldname=fieldname;//修改的下拉框字段
            }
        }
    });
}
//选择可用标签 - 保存
moduledata_tag.okfunctionname = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var prev_popupobj=CrmPopup.getPopupObj("lastprev");
    var comboxarr = [];
    var emptycheck = true;
    ld("#"+popupobj.divid+" input[tag='combox']").each(function(){
        var tag_id = ld(this).attr('tag_id');
        var tag = ld(this).val();
		 var tag_type = ld(this).attr('tag_type');

        if(empty(tag)){
            emptycheck = false;
        }
        var comboxtext = {'tag':''+tag+'','tag_id':''+tag_id+'','tag_type':''+tag_type+''}; 
        comboxarr.push(comboxtext);
    });
	if(!emptycheck){
        var confirm_str = arrJsPopLabel['DROPDOWNBOXOPTIONCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
	var comboxjson = JSON.stringify(comboxarr);
    //edit: xll 2023/03/31 BUG0062888 “客户”模块，编辑标签，保存无效（邱：不知道是不是最上面特殊字符问题）
    comboxjson = encodeURIComponent(comboxjson);
	var deleted_tag_id = ld("#"+popupobj.divid+" [name=deleted_tag_id]").val();
	var urlstring = 'index.php?module='+popupobj.module+'&action='+popupobj.module+'Ajax&ajax=true&file=moduledata_tag&saveSelect=true';
	urlstring += '&tag_combox_json='+comboxjson+'&deleted_tag_id='+deleted_tag_id;
    
    //edit: xll 2023/05/05 BUG0065787 编辑已有标签时，标签类型转换后保存，当前标签栏对应标签颜色未改变，且可选标签下拉框选项不应包含已选标签
    var record = ld(" [name=moduledata_record]").val();
    urlstring += '&record='+record;
    
	//alert(urlstring);return false;
	ldAjax(urlstring,"",function(data){
		if(data.code==1){
			popupobj.CancelEvent();
			
			ld("#"+prev_popupobj.divid+" [name=cmb_ul_select_input_tagger]").find('li').each(function(){
				ld(this).remove();
			});
            //edit: xll 2023/03/31 BUG0062888 “客户”模块，编辑标签，保存无效（邱：不知道是不是最上面特殊字符问题）
			var restobj = data.result.comboxjson;
			var li_num = 0;
			var tagger_obj = ld("#"+prev_popupobj.divid+" [name=cmb_ul_select_input_tagger]");
			ld.each(restobj,function(ikey,tag_info){
				var tag_li_html = '<li class="active-result highlighted" style="padding: 6px 7px;" tag_id="'+tag_info.tag_id+'" tag_type="'+tag_info.tag_type+'" name="dv_chzn_'+li_num+'_select_input_tagger" onclick="moduledata_tag.cmb_liclick(event,\'select_input_tagger\',ld(this))" onmouseover="cmb_limouseover(event,\'select_input_tagger\',\'\')">'+tag_info.tag+'</li>';
				tagger_obj.append(tag_li_html);
				li_num++;
				
			});
            
            //edit: xll 2023/05/05 BUG0065787 编辑已有标签时，标签类型转换后保存，当前标签栏对应标签颜色未改变，且可选标签下拉框选项不应包含已选标签
			var moduledata_tag_type = data.result.tag_type;
			moduledata_tag.refreshcurrent(record,moduledata_tag_type,tagger_obj);
            
			DelProgressObjs();
		}
	})
}

moduledata_tag.com_img_change = function(event,fldname,parentdivid){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	cmb_parentdivid=divid;
	window.event? window.event.cancelBubble = true : e.stopPropagation();
	if(cmb_fldname!=''&&fldname!=cmb_fldname&&CrmPopup.isExistsObj(divid,"dv_drop_"+cmb_fldname)){ 
		CrmPopup.findHtmlobj(divid,"dv_drop_"+cmb_fldname).css("left","-9000px");
		CrmPopup.findHtmlobj(divid,"cmb_a_"+cmb_fldname).attr("class","");
		CrmPopup.findHtmlobj(divid,"cmb_a_"+cmb_fldname).addClass('chzn-single');
		CrmPopup.findHtmlobj(divid,'dv_chzn_'+cmb_fldname).attr("class","");

		CrmPopup.findHtmlobj(divid,'dv_chzn_'+cmb_fldname).removeClass().addClass('chzn-container');
		CrmPopup.findHtmlobj(divid,'dv_chzn_'+cmb_fldname).addClass('chzn-container-single');

		cmb_fldname='';
		is_leave=false;
	}
      
	cmb_fldname=fldname;

	var fromobj=CrmPopup.findHtmlobj(divid,"cmb_a_"+cmb_fldname);//获取点击按钮元素
	var dvdrop= CrmPopup.findHtmlobj(divid,"dv_drop_"+cmb_fldname);//获取下拉框内内容
	var j=1;
	var obj= CrmPopup.findHtmlobj(divid,fldname);

	ld("#"+divid+" [name=dv_chzn_"+fldname+"]").find(".chzn-results").find("li").attr("class","active-result");
    if(fromobj.attr("class")=='chzn-single')
    {   
		ld("#"+divid+" [name=dv_chzn_"+fldname+"]").find(" .chzn-drop").css("display",'');
		fromobj.addClass('chzn-single-with-drop') ;
		CrmPopup.findHtmlobj(divid,'dv_chzn_'+fldname).attr("class","");
		CrmPopup.findHtmlobj(divid,'dv_chzn_'+fldname).addClass("chzn-container");
		CrmPopup.findHtmlobj(divid,'dv_chzn_'+fldname).addClass("chzn-container-single");
		// CrmPopup.findHtmlobj(divid,'dv_chzn_'+fldname).addClass("chzn-container-active");

		dvdrop.css("left","0");
		dvdrop.css("display","");
		CrmPopup.findHtmlobj(divid,'txt_search_'+fldname).val('');
		CrmPopup.findHtmlobj(divid,'txt_search_'+fldname).focus();
    }
    else
    {
		fromobj.find(" .chzn-drop").css("display",'none');
		CrmPopup.findHtmlobj(divid,'dv_chzn_'+fldname).attr("class","");

		CrmPopup.findHtmlobj(divid,'dv_chzn_'+fldname).addClass("chzn-container");
		CrmPopup.findHtmlobj(divid,'dv_chzn_'+fldname).addClass("chzn-container-single");
		fromobj.attr("class","");
		fromobj.addClass('chzn-single');
		// dvdrop.style.left='-9000px';
		dvdrop.css("left","-9000px");
    }
	CrmPopup.findHtmlobj(divid,'li_chzn_'+fldname).attr("class","");
}


var tagger_class = function(opt){
	var tagpopupobj=CrmPopup.getPopupObj("last");//联系人图谱编辑打开标签再点开联系人打开标签会有两个opt
	var el = ld("#"+tagpopupobj.divid+" "+opt.el);
	var list_tag = el.val().split(',');
	var list_tag_id = el.attr('tag_id').split(',');
	var list_tag_type = el.attr('tag_type').split(',');
	var tagger_obj = ld('<span class="tagger_span" name="tagger_span"></span>');
	if(el.val() != ''){
		for (var i = 0; i < list_tag.length; i++) {
			if (tagpopupobj.divid.startsWith('Contacts')){
				tagger_obj.append( ld('<a href="javascript:void(0)" style="margin: 2px" class="module-map-right-tagger-fm-button '+list_tag_type[i]+'" style="margin: 2px" tag_id="'+list_tag_id[i]+'" tag_type="'+list_tag_type[i]+'" select_li_name="" >'+list_tag[i]+'<em> </em></a>') );
			}else {
				tagger_obj.append( ld('<a href="javascript:void(0)" style="margin: 2px" class="module-tagger-fm-button '+list_tag_type[i]+'" style="margin: 2px" tag_id="'+list_tag_id[i]+'" tag_type="'+list_tag_type[i]+'" select_li_name="" >'+list_tag[i]+'<em> </em></a>') );
			}
		}
	}
	el.hide().after( tagger_obj );
	tagger_obj.on('click','a>em',function(){	//刪除
		var popupobj=CrmPopup.getPopupObj("last");
		ld(this).parent().remove();
		var select_li_name = ld(this).parent().attr('select_li_name');
		var allmodulelabel = moduledata_tag.allmodulelabel
		if(select_li_name != ''){
			ld("#"+popupobj.divid+" [name="+select_li_name+"]").show();
		}else{
			var tagid = ld(this).parent().attr('tag_id');
			if (!empty(allmodulelabel[tagid])){
				var tagger_obj = ld("#"+popupobj.divid+" [name=cmb_ul_select_input_tagger]");
				var tagger_length = ld("#"+popupobj.divid+" [name=cmb_ul_select_input_tagger] li").length;
				var tag_li_html = '<li class="active-result highlighted" style="padding: 6px 7px;" tag_id="'+ld(this).parent().attr('tag_id')+'" tag_type="'+ld(this).parent().attr('tag_type')+'" name="dv_chzn_'+tagger_length+'_select_input_tagger" onclick="moduledata_tag.cmb_liclick(event,\'select_input_tagger\',ld(this))" onmouseover="cmb_limouseover(event,\'select_input_tagger\',\'\')">'+ld(this).parent().text()+'</li>';
				tagger_obj.append(tag_li_html);
			}
		}
		moduledata_tag.setInputTagValue();
        
        //edit: xll BUG0065788 kfbcrm-客户-单据详情-添加标签，若无可用标签时，应在下拉框内出现提示信息
        moduledata_tag.option_num_check('delete');
		//alert(tagger_obj.text().match(/\S+/g).join(','));
		//el.val( tagger_obj.text().match(/\S+/g).join(',') )
	});
}

/**
 * edit: xll 2023/05/05
 * BUG0065787
 * 刷新 ”新建/选择标签“ 页面的标签
 * */
moduledata_tag.refreshcurrent = function(record,moduledata_tag_type,tagger_obj){
	var popupobj=CrmPopup.getPopupObj("last");
	ld("#"+popupobj.divid+" [name=tagger_span]").find('a').each(function(){
		var tag_id = ld(this).attr("tag_id");
        //根据type是否存在进行标签修改或删去
        if(!empty(moduledata_tag_type) && moduledata_tag_type[tag_id] != undefined){
			if (popupobj.divid.startsWith("Contacts")){
				ld(this).attr("class","module-map-right-tagger-fm-button " + moduledata_tag_type[tag_id]);
			}else {
				ld(this).attr("class","module-tagger-fm-button " + moduledata_tag_type[tag_id]);
			}
			ld(this).attr("tag_type",moduledata_tag_type[tag_id]);
        }else{
            ld(this).remove();
        }
        
	});
    //删去下拉框中已选择的标签选项
    if(!empty(moduledata_tag_type)){
		ld.each(moduledata_tag_type,function(tag_id,tag_type){
		    tagger_obj.find("[tag_id="+tag_id+"]").remove();
		});
	}
// ljj 20230907 XUQIU1000834 联系人图谱相关功能优化--可在联系人图谱中直接添加和打标签
	var contact_record=ld("#"+popupobj.divid+" input[name=moduledata_record]").attr('value');
	if (contact_record !=''){
		var modulespantag=ld("#"+popupobj.divid+" [name=module_list_tagger_span_"+contact_record+"]").find('span');
		//判断是否在联系人图谱界面（含有图谱标签信息）
		if (!empty(modulespantag)){
			ld(modulespantag).each(function(){
				var maptag_id = ld(this).attr("tag_id");
				if( !empty(moduledata_tag_type) && moduledata_tag_type[maptag_id] != undefined){
				}
				else {
					var deletespan=ld("#"+popupobj.divid+" span[tag_id="+maptag_id+"]");
					ld(deletespan).remove();
				}

			});
		}
	}

}
/**
 * edit: xll 2023/05/12
 * BUG0065788
 * 检测可选标签是否为空，为空则显示无可选标签
 * */
moduledata_tag.option_num_check = function(checktype=''){
    var popupobj = popupobj=CrmPopup.getPopupObj("last");
    var optional_obj = ld("#"+popupobj.divid+" [name=cmb_ul_select_input_tagger]").find("li");
    var flag = 0;
    ld.each(optional_obj,function(){
        if(ld(this).css("display") == 'list-item'){
            flag = 1;
        }
    });
    if(flag == 0){
        ld("#"+popupobj.divid+" #NoOptionLabel").css("display","block");
    }else if(flag == 1){
        ld("#"+popupobj.divid+" #NoOptionLabel").css("display","none");
    }else{
        return false;
    }
	if (popupobj.popuptype != 'relationshipChartTag'){
		popupobj.center();
	}
    /*
    var option_obj = ld("#"+popupobj.divid+" #input_tagger_option");
    var option_id = ld(option_obj).val().split(",");
    tag_id_key = option_id.indexOf(tagobj.attr('tag_id'));
    if(checktype == 'select'){
        option_id.splice(tag_id_key,1);
        option_val = option_id.toString();
        if(option_val.length == 0){
            ld("#"+popupobj.divid+" #NoOptionLabel").css("display","block");
        }
        ld(option_obj).val(option_val);
        option_obj.attr("value",option_val);
    }else if(checktype == 'delete'){
        option_id.push(tag_id_key);
        option_val = option_id.toString();
        if(option_val.length > 0){
            ld("#"+popupobj.divid+" #NoOptionLabel").css("display","none");
        }
        ld(option_obj).val(option_val);
        option_obj.attr("value",option_val);
    }else{
        return false;
    }
    */
}

