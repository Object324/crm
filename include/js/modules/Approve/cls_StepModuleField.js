function cls_StepModuleField(approvestepobj){
	var that=this;
	//审批必填
	this.approvestepobj=approvestepobj;
	this.module_Allfields=that.approvestepobj.ajaxdata.result.module_allfields;
	this.module_field=that.approvestepobj.value_arr.module_field;
	this.InitHtml=function(tag){
		that.tag=tag;
		var label_arr=that.approvestepobj.ajaxdata.result.label;
		ld('.first-drawer-body-content').append('<div style="display:none" class="first-drawer-content-items" tag="'+tag+'"></div>');
		var html='<table class="ld-approve-tablecontent lasttdbordernon" name="tablemodulefield" width="100%" cellspacing="0" cellpadding="0" border="0">'+
			'<tr>' +
			'<th class="ld-from-headblock" colSpan="4"><div class="ld-from-headblock-title">'+label_arr.modulefield+'<input class="ld-button" style="margin-top: -6px;float:right" type="button" id="btn_mandatoryfield" value="'+label_arr.new+'"></div></th>'+
			'</tr>';
		ld.each(that.module_Allfields,function(tmpindex,tmpinfo_arr){
			html+='<tr>';
			ld.each(tmpinfo_arr,function(tmptdindex,tmptdinfo){
				html+='<td align="left">';
				if(that.module_field.includes(tmptdinfo.fieldname))
					html+='<input type="checkbox" name="module_fldname"  id="'+tmptdinfo.fieldname+'" value="'+tmptdinfo.fieldname+'" checked>&nbsp;&nbsp;<label for="'+tmptdinfo.fieldname+'">'+tmptdinfo.fieldlabel+'</label></td>'
				else
					html+='<input type="checkbox" name="module_fldname" id="'+tmptdinfo.fieldname+'" value="'+tmptdinfo.fieldname+'">&nbsp;&nbsp;<label for="'+tmptdinfo.fieldname+'">'+tmptdinfo.fieldlabel+'</label></td>'
			})
			html+='</tr>';
		})
		html+='</tbody></table>';

		ld('.first-drawer-content-items[tag='+tag+']').append(html);
	}
	//duan 20230713 审批步骤中必填字段设置方式修改
	this.InitHtmlSecond = function (tag){
		that.tag=tag;
		ld('.first-drawer-body-content').append('<div style="display:none" class="first-drawer-content-items" tag="'+tag+'"></div>');
		var parent_obj = ld('.first-drawer-content-items[tag='+tag+']');
		var mandatoryfieldobj = new cls_approve_mandatoryfield(this.approvestepobj.approvestepflowobj.module);
		var augmentsingerobj = ld("#"+this.approvestepobj.popupobj.divid+" [name=is_augmentsinger]");
		mandatoryfieldobj.addsign = !empty(that.approvestepobj.value_arr['augmentsinger'])?'yes':'no';
		mandatoryfieldobj.setPopupobj(this.approvestepobj.popupobj);

		mandatoryfieldobj.setMandatoryFieldlabelArr(that.approvestepobj.ajaxdata.result.all_fieldlabel_arr);
		mandatoryfieldobj.setMandatoryField(that.approvestepobj.value_arr.mandatoryfield);
		mandatoryfieldobj.CreateTableHtml(parent_obj);
		this.approvestepobj.popupobj.mandatoryfieldobj = mandatoryfieldobj;
		augmentsingerobj.on('change',function () {
			mandatoryfieldobj.after_change_sign(this,parent_obj);
		})
	}

}