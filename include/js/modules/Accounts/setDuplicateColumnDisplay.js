/* createdby:gyq_12 reason:显示列查重JS文件 date:20160601 */
var setDuplicateColumnDisplay = (function () {

    //参数：传递给单例的一个参数集合
    function entrance() {
        this.dialogDivId = 'setColumnDisplay';
        this.rightselect = 'beselected_module';
        this.leftselect = 'tobeselecte_module';
    }

    /* 设置显示列字段按钮*/
    entrance.prototype.button_setColumnDisplay = function(obj,module){
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",module,"",'none',"","");
        var module_use = module;
        if(module_use == 'ServiceCharge') //服务收费管理模块调用客户模块查重功能
            module_use = 'Accounts';
		crmPopupobj.prevshow();
		ld.ajax({
			url:'index.php?module='+module_use+'&action='+module_use+'Ajax&file=duplicate_related_popu&action_type=selectdialog&parenttab=Settings&modulename='+module_use+'&ajax=true',
			type: 'POST',
			data:'',
			dataType:'json',
			async: true,//
			timeout: 5000,
			success: function(data)
			{
				if(data.code==1)
				{
					if($("status") != undefined)
						$("status").style.display="none";
					crmPopupobj.setParams(data.result.title,"","","LdPopWidth800px",module,"","","","");  
					crmPopupobj.quickcreatehtml=data.result.content;
					crmPopupobj.show(data.result.content);

                    // 需要去掉的给高度
                    crmPopupobj.reduceBodyHeight = 0;
                    // 设置内容最大高度
                    crmPopupobj.setPopBodyMaxHeight(".setDuplicate");

                    crmPopupobj.center();
                    var popupobj = CrmPopup.getPopupObj('last');
                    //查询字段
                    var tableobj1 = ld('#'+popupobj.divid).find("table[name=SearchFieldsTabel]");
                    var LeftObj1 = tableobj1.find(" .commonMultipleSelect:first");
                    var RightObj1 = tableobj1.find(" .commonMultipleSelect:last");
                    var Drag_Transfer1 = new DragTransfer();
                    Drag_Transfer1.SetDragTransfer(tableobj1,LeftObj1,RightObj1,'reset','335');
                    //显示字段
                    var tableobj2 = ld('#'+popupobj.divid).find("table[name=DisplayFieldsTable]");
                    var LeftObj2 = tableobj2.find(" .commonMultipleSelect:first");
                    var RightObj2 = tableobj2.find(" .commonMultipleSelect:last");
                    var Drag_Transfer2 = new DragTransfer();
                    Drag_Transfer2.SetDragTransfer(tableobj2,LeftObj2,RightObj2,'reset','335');
				}
			}
		});
    };
    /* 关闭弹框  */
    entrance.prototype.button_closeDiv = function(){
		cancelCrmPopup();
    }
    /* 移动选择字段 */
    entrance.prototype.copySelectedOptionsSettingField = function(actionType){
        if(actionType == 'lefttoright'){
            var srcObj = ld('#'+this.leftselect)[0];
            var destObj = ld('#'+this.rightselect)[0];
        }else if(actionType == 'righttoleft'){
            var srcObj = ld('#'+this.rightselect)[0];
            var destObj = ld('#'+this.leftselect)[0];
        }
        if(typeof(srcObj) == 'undefined' || typeof(destObj) == 'undefined'){
            return;
        }
        for(i=0;i<destObj.length;i++){
            destObj.options[i].selected=false;
        }
        for (i=0;i<srcObj.length;i++) {
            if (srcObj.options[i].selected==true) {
                var rowFound=false;
                var existingObj=null;
                for (j=0;j<destObj.length;j++) {
                    if (destObj.options[j].value==srcObj.options[i].value) {
                        srcObj.options.remove(i);//无论默认有无，都去掉该备选项 ,
                        rowFound=true
                        existingObj=destObj.options[j]
                        break
                    }
                }
                if (rowFound!=true) {
                    var newColObj=document.createElement("OPTION")
                    newColObj.value=srcObj.options[i].value
                    if (browser_ie)
                        newColObj.innerText=srcObj.options[i].innerText
                    else if (browser_nn4 || browser_nn6)
                        newColObj.text=srcObj.options[i].text
                    destObj.appendChild(newColObj)//右键
                    srcObj.options[i].selected=false
                    srcObj.options.remove(i);
                    i=-1;
                    newColObj.selected=true
                    rowFound=false
                } else {
                    if(existingObj != null)
                        existingObj.selected=true
                }
            }
        }
    };
    /* 上移 */
    entrance.prototype.fieldDetailmoveUp = function(){
        var elem = document.getElementById(this.rightselect);
        if(elem.options.selectedIndex>=0){
            for (var i=1;i<elem.options.length;i++){
                if(elem.options[i].selected == true){
                    //swap with one up
                    var first = elem.options[i-1];
                    var second = elem.options[i];
                    var temp = new Array();

                    temp.value = first.value;
                    temp.innerHTML = first.innerHTML;

                    first.value = second.value;
                    first.innerHTML = second.innerHTML;

                    second.value = temp.value;
                    second.innerHTML = temp.innerHTML;

                    first.selected = true;
                    second.selected = false;
                }
            }
        }
    };
    /* 下移 */
    entrance.prototype.fieldDetailmoveDown = function(){
        var elem = document.getElementById(this.rightselect);
        if(elem.options.selectedIndex>=0){
            for (var i=elem.options.length-2;i>=0;i--){
                if(elem.options[i].selected == true){
                    //swap with one down
                    var first = elem.options[i+1];
                    var second = elem.options[i];
                    var temp = new Array();

                    temp.value = first.value;
                    temp.innerHTML = first.innerHTML;

                    first.value = second.value;
                    first.innerHTML = second.innerHTML;

                    second.value = temp.value;
                    second.innerHTML = temp.innerHTML;

                    first.selected = true;
                    second.selected = false;
                }
            }
        }
    };

    /* 保存设置 */
    entrance.prototype.saveColumnSetting = function(module){
        var self = this;
        var string = '';
        var searchfields_string = '';
        var optionlength = ld('#beselected_module option').length;//查重显示字段个数
        var searchfield_optionlength = ld('#selected_searchfields option').length;//查询字段个数
        var module_use = module;
        if(module == 'ServiceCharge') //服务收费管理模块调用客户查重功能
            module_use = 'Accounts';
        //显示字段设置少于三条提示
        if(optionlength < 3){
            var confirm_str = arrJsPopLabel['SetLeast3DisplayFields'];
            MessagePopup.TipOne_warning(confirm_str);
            return false;
        }
        //可查询字段少于一条提示
        if(searchfield_optionlength < 1){
            var confirm_str = arrJsPopLabel['SetLeastOneFieldQuerying'];
            MessagePopup.TipOne_warning(confirm_str);
            return false;
        }
        ld('#beselected_module option').each(function(){//显示字段
            string += ld(this).val()+',';
        });
        ld('#selected_searchfields option').each(function(){//查询字段
            searchfields_string += ld(this).val()+',';
            searchfields_string = searchfields_string.replace("search_", "");
        });
        ldAjaxNoProgress("index.php",{action_type:"selectdialog",fieldids:string ,searchfieldids: searchfields_string,'module':module_use,file:"duplicate_related_popu",'action':module+"Ajax",'modulename':module_use},function(data){
            cancelCrmPopup();
            if(data.code == 1){
                var popupobj = CrmPopup.getPopupObj('last');
                ld("#"+popupobj.divid+" #cheack_repeat_columnname").attr('placeholder',data.result.SearchLabel)
                if(ld("#"+popupobj.divid+" #cheack_repeat_columnname").val() != ''){//xxy 2023-11-29 当输入框内有内容时才再进行自动查询一次
                    search_accounts('',module)
                }else{
                    search_accounts('',module,'settings')
                }
            }
        });
    }

//实例容器
    var instance;

    var _static = {

        //获取实例的方法
        getInstance: function () {
            if (instance === undefined) {
                instance = new entrance();
            }
            return instance;

        }
    };
    return _static;

})();