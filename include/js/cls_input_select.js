/*
*edit: chj
*date: 2020/10/9
*reason: 下拉框模糊匹配
*/
function cls_input_select()
{
	cls_input_select.cur_obj = null;
}

cls_input_select.getInstance=function(input_type){
    if(cls_input_select.cur_obj==null){
        cls_input_select.cur_obj=new cls_input_select();
    }
	cls_input_select.input_type = input_type;
    return cls_input_select.cur_obj;
}

cls_input_select.prototype._onkeyup = function(obj,inputname,event){
	var input_obj = '';
	var pinyinArray = new Array();
	var popupobj=CrmPopup.getPopupObj("last");
    var blockid = ld(obj).attr('blockid');//hjz 增加页面设置的未启用字段查询
    var new_divid = 'hiddenfields_'+blockid;
    if(popupobj.divid == undefined){
        popupobj.divid=new_divid;
        input_obj=ld("#"+popupobj.divid+" [name="+inputname+"]");
    }else{
    	if(ld("#"+popupobj.divid+" [name="+inputname+"]") != undefined){
    	   input_obj = ld("#"+popupobj.divid+" [name="+inputname+"]");
    	}
    }
	if(input_obj != ''){
		var selectlength = ld("#"+popupobj.divid+" [name="+inputname+"] option ").length;
		var isSel=0;
		var isSelectOpteion =0;
		var objlength = obj.value.length;
		if(obj.value != '')
		{
			getScriptBack('include/js/multipingyin.js',null);//加载拼音代码  BUG0066311 ls 20230515 cdn慢,导致pakePy方法报错,改为加载本地js
			var selectHeight = input_obj[0].scrollHeight;//下拉框的高度
			var optionHeight = selectHeight/selectlength;
			 ld.each(ld("#"+popupobj.divid+" [name="+inputname+"] option "), function (keys, selobj) {
				var selectValue =selobj.text;
				var selT = selectValue.indexOf(obj.value);
				var pinyin = makePy(selectValue);//17222: (71mis.com/crm)控制面板>部门设置/权限管理,关于设置成员模糊搜索的问题
				pinyin=pinyin.join("").toLowerCase();

				//pinyinArray[i]=pinyin;
				var selP = pinyin.indexOf(obj.value);
				if(selT >=0 || selP >=0)
				{
					if(isSel == 0)
					{
						if(selP > 0){
							if(pinyin.indexOf(obj.value)>0){
							   selobj.selected = true;
							   isSel = 1
						   }
							//if(pinyin.substring(0, objlength) == obj.value){
								//objMember.options[i].selected = true;
								//isSel = 1;
							//}
						}
						else{
							selobj.selected = true;
							isSel = 1;
						}
						
						isSelectOpteion = keys;
					}
					else{
						selobj.selected = false;
					}
				}
				else{
					if(selobj.selected == true)
					{
						selobj.selected = false;
					}
				}
			});
			if(isSelectOpteion >=10){
				input_obj.animate({ scrollTop: optionHeight*isSelectOpteion-70});
			}else{
				input_obj.animate({ scrollTop: 0});
			}
			
		}else{
			ld.each(ld("#"+popupobj.divid+" [name="+inputname+"] option "), function (keys, selobj) {
				if(selobj.selected == true)
				{
					selobj.selected = false;
				}
			});
			isSel = 0;
			input_obj.scrollTop(0);
		}
	}

}
//2023-7-11 xxy 选择的option全换成checkbox和label XUQIU1001609 PC端-数据分类，选择显示字段优化（需求）
cls_input_select.prototype._onkeyup_input = function(obj,inputname,event){
	var input_obj = '';
	var pinyinArray = new Array();
	var popupobj=CrmPopup.getPopupObj("last");
    var blockid = ld(obj).attr('blockid');//hjz 增加页面设置的未启用字段查询
    var new_divid = 'keywordsearch';
    if(popupobj.divid == undefined){
        popupobj.divid=new_divid;
        input_obj=ld("#"+popupobj.divid);
    }else if(popupobj.divid == 'keywordsearch'){
		input_obj=ld("#"+inputname);
    }else{
    	if(ld("#"+popupobj.divid+" [name="+inputname+"]") != undefined){
    	   input_obj = ld("#"+popupobj.divid+" [name="+inputname+"] ");
    	}
    }
	if(input_obj != ''){
		var selectlength = input_obj.find('div').length;
		var isSel=0;
		var isSelectOpteion =0;
		var objlength = obj.value.length;

		if(obj.value != '')
		{
			getScriptBack('include/js/multipingyin.js',null);//加载拼音代码  BUG0066311 ls 20230515 cdn慢,导致pakePy方法报错,改为加载本地js
			var selectHeight = input_obj[0].scrollHeight;//下拉框的高度
			var optionHeight = selectHeight/selectlength;
			 ld.each(input_obj.find('div'), function (keys, selobj) {
				var selectValue =ld(selobj).find("label").text();
				var selT = selectValue.indexOf(obj.value);
				var pinyin = makePy(selectValue);//17222: (71mis.com/crm)控制面板>部门设置/权限管理,关于设置成员模糊搜索的问题
				pinyin=pinyin.join("").toLowerCase();

				//pinyinArray[i]=pinyin;
				var selP = pinyin.indexOf(obj.value);
				if(selT >=0 || selP >=0)
				{
					if(isSel == 0)
					{
						if(selP > 0){
							if(pinyin.indexOf(obj.value)>0){
							   	ld(selobj).find("input").prop("checked", true);
							   	isSel = 1
						   }
							//if(pinyin.substring(0, objlength) == obj.value){
								//objMember.options[i].selected = true;
								//isSel = 1;
							//}
						}
						else{
							ld(selobj).find("input").prop("checked", true);
							isSel = 1;
						}
						
						isSelectOpteion = keys;
					}
					else{
						ld(selobj).find("input").prop("checked", false);
					}
				}
				else{
					if(ld(selobj).find("input").is(":checked") == true)
					{
						ld(selobj).parent().prev().find("input").prop("checked", false);
						ld(selobj).find("input").prop("checked", false);
					}
				}
			});
			if(isSelectOpteion >=10){
				input_obj.animate({ scrollTop: optionHeight*isSelectOpteion-50});
			}else{
				input_obj.animate({ scrollTop: 0});
			}
			
		}else{
			ld.each(ld("#"+popupobj.divid+" [name="+inputname+"] option "), function (keys, selobj) {
				if(ld(selobj).find("input").is(":checked") == true)
				{
					ld(selobj).find("input").prop("checked", false);
				}
			});
			isSel = 0;
			input_obj.scrollTop(0);
		}
	}

}
cls_input_select.prototype._onblur = function(obj){
	if(obj.value == '')
	{
		obj.value = obj.getAttribute('tag');
		obj.style.color='#999';
	}
}

 cls_input_select.prototype._onfocus = function(obj){
	var membermessage = obj.getAttribute('tag');
	if(obj.value == membermessage)
	{
		obj.value="";
		obj.style.color='#000';
	}
}