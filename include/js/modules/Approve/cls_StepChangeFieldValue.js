function cls_StepChangeFieldValue(approvestepobj)
{
	//审批步骤->高级功能
	var that=this;
	this.approvestepobj=approvestepobj;
	this.changefieldvalue_arr=approvestepobj.ajaxdata.result.changefieldvalue;
	this.fieldvalue_arr=approvestepobj.value_arr.fieldvalue;
	this.InitHtml=function(tag){
		that.tag=tag;
		var label_arr=that.approvestepobj.ajaxdata.result.label

		 ld('.first-drawer-body-content').append('<div style="display:none" class="first-drawer-content-items" tag="'+tag+'"></div>');
		var html='<table class="ld-approve-tablecontent lasttdbordernon DetailContentTable" name="changetable" width="100%" cellspacing="0" cellpadding="0" border="0">'+
				'<tr>' +
				'<th class="ld-from-headblock" width="90%" colspan="4" ><div class="ld-from-headblock-title">'+label_arr.dynamicassignvalue+'<input class="ld-button ld-button-primary" style="margin-top: -6px;float:right" type="button" name="btn_addchangfieldrow" value="'+label_arr.new+'"></div></th>'+
				'</tr>';
		html+='<tr><td width="20%">'+label_arr.AssignValueMethod+'</td><td width="20%">'+label_arr.fields+'</td><td width="55%">'+label_arr.Value+'</td><td width="5%">'+label_arr.operating+'</td></tr>';
		html+='</table>';
		ld('.first-drawer-content-items[tag='+tag+']').append(html);
		var obj=ld('.first-drawer-body-content').find(" [tag="+that.tag+"]");
		that.changefieldvalueEvent();
		var tableobj=ld(obj).find(" [name=changetable]");

		ld.each(this.fieldvalue_arr,function(tmpindex,tmpinfo){
				that.addtr();
				var trobj=ld(tableobj).find(" tr[deleted=no]:last");
                that.changefieldvalueEvent();
				ld(trobj).find(" [name=passtype]").val(tmpinfo.passtype);
                ld(trobj).find(" [name=passtype]").change();
				ld(trobj).find(" [name=passfield]").val(tmpinfo.columnname);
				that.passStatus(trobj);
				ld(trobj).find(" [name=fieldvalue]").val(tmpinfo.value);
				
		})

	}

	this.changefieldvalueEvent=function(){
		var obj=ld('.first-drawer-body-content').find(" [tag="+that.tag+"]");
		ld(obj).find(" [name=btn_deleterow]").unbind("click").bind("click",function(){
			var trobj=Tools.getParentobjByChild(ld(this),'tr');
			ld(trobj).remove();

		})
		 
		ld(obj).find(" [name=btn_addchangfieldrow]").unbind("click").bind("click",function(){
			//新增行
			 
			that.addtr()
			var obj=ld('.first-drawer-content-items[tag='+that.tag+']');
			var tableobj=ld(obj).find(" [name=changetable]");
			var trobj=ld(tableobj).find(" tr[deleted=no]:last");
			that.passStatus(trobj);
			that.changefieldvalueEvent();
		})
		ld(obj).find(" [name=passfield]").unbind("change").bind("change",function(){

			var trobj=Tools.getParentobjByChild(ld(this),'tr');
			that.passStatus(trobj);
		})
        ld(obj).find(" [name=passtype]").unbind("change").bind("change",function(){
			that.changepasstype(this);
		})
        
	}
	that.addtr=function(){
		var label_arr=that.approvestepobj.ajaxdata.result.label
		var obj=ld('.first-drawer-content-items[tag='+that.tag+']');
		var tableobj=ld(obj).find(" [name=changetable]");

		var html='<tr deleted="no">';
		html+='<td><select class="ld-select-inner" style="width: 80%" name="passtype">';
		html+='<option value=0>'+label_arr.pass+'</option>';
		html+='<option value=1>'+ arrJsPopLabel['NOTPASS'] + ' </option>';
		html+='</select></td>';
		html+='<td><select class="ld-select-inner" style="width: 80%"  name="passfield">';
		var trobj_arr=ld(tableobj).find(" tr[deleted=no]");
		var selectcolumn_arr=[];
		ld.each(trobj_arr,function(){
            var tmp_passfieldobj = ld(this).find(" [name=passfield]");
            var tmp_passtypeobj = ld(this).find(" [name=passtype]");
            if(0 == tmp_passtypeobj.val()){
                selectcolumn_arr.push(tmp_passfieldobj.val());
            }
		})
		ld.each(that.changefieldvalue_arr,function(tmpindex,tmpinfo){
			if(!selectcolumn_arr.includes(tmpinfo.columnname))//已经选择过的字段，下拉框不显示
				html+="<option value='"+tmpinfo.columnname+"'>"+tmpinfo.fieldlabel+'</option>'
		})
		html+='</select></td>';
		html+='<td name="td_value"></td>';
		html+='<td><a class="ld-category-icon ld-category-del" href="javascript:void(0);" name="btn_deleterow" title="'+ arrJsPopLabel['DELETE']+'"></a></td>';
		html+='</tr>';
		ld(tableobj).append(html);
	}

	this.passStatus=function (trobj){
	   var modulename=that.approvestepobj.approvestepflowobj.module;
	    var columnname=ld(trobj).find(" [name=passfield]").val();
	    var bigtype='';
	    ld.each(that.changefieldvalue_arr,function(tmpindex,tmpinfo){
	    	if(tmpinfo.columnname==columnname) {
	    		bigtype=tmpinfo.bigtype;
				return false;
	    	}
	    })
	    ld(trobj).find(" td[name=td_value]").html('');
	    if(bigtype=='picklist')
				    ld.ajax({
				        url: "index.php?module=Settings&action=SettingsAjax&file=getpicklistContent&fld_module="+modulename+"&columnname="+columnname,
				        type: 'POST',
				        data:{"namename": "uname", "namenameage": 18},
				       dataType:'json',
				        async: false,//
				        timeout: 10000,
				        success: function(data)
				        {
				            if(data.code==1)
				            {
								var html='<select class=\"ld-select-inner\" name="fieldvalue">';
								for(var tmpvalue in data.result.picklist) {
									html+='<option value="'+tmpvalue+'">'+tmpvalue+'</option>';
								}
								html+='</select>';
								ld(trobj).find(" td[name=td_value]").html(html);
				            }
				        },
				        error:function(data)
				        {
				         
				        }
				    });
		else if(bigtype=='longtextarea') {
				ld(trobj).find(" td[name=td_value]").html("<textarea class=\"ld-textarea-inner\" name='fieldvalue' ></textarea>")
		}
	    else{
	    	ld(trobj).find(" td[name=td_value]").html("<input class='detailedViewTextBox ld-input-inner' type='text' name='fieldvalue'/>")
	    }
	}
    //duan 20220131 审批步骤高级功能:将通过和不通过可选择的字段区分开,并切换后更新可选字段值
    this.changepasstype = function(obj){
        var optionvalue = ld(obj).val();
        var trobj=Tools.getParentobjByChild(ld(obj),'tr');
        var passfieldobj = trobj.find(" [name=passfield]");
        
        var divobj=ld('.first-drawer-content-items[tag='+that.tag+']');
		var tableobj=ld(divobj).find(" [name=changetable]");

		var trobj_arr=ld(tableobj).find(" tr[deleted=no]");
		var selectcolumn_arr=[];
		ld.each(trobj_arr,function(){
            var tmp_passfieldvalue = ld(this).find(" [name=passfield]").val();
            var tmp_passtypeobj = ld(this).find(" [name=passtype]");
            //如果当前行的赋值方式和选中行相同，则不显示已选中的字段
            if(optionvalue == tmp_passtypeobj.val() && ld(tmp_passtypeobj).get(0) != ld(obj).get(0)){
                selectcolumn_arr.push(tmp_passfieldvalue);
            }
		})
        var optionhtml = '';
		ld.each(that.changefieldvalue_arr,function(tmpindex,tmpinfo){
			if(!selectcolumn_arr.includes(tmpinfo.columnname))//已经选择过的字段，下拉框不显示
					optionhtml+="<option value='"+tmpinfo.columnname+"'>"+tmpinfo.fieldlabel+'</option>'

		})
        
        passfieldobj.html(optionhtml);
        passfieldobj.change();
    }

}