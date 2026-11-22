/**
 * 显示字段修改日志
 * @author Tujt 2015-06-15
 */
function ModTrackerShowHistory(record,module){
	var urldata = 'record='+record+'&rmodule='+module;
	getFieldUpdateLog(urldata,module);
}
/**
 * 获取字段修改日志列表
 * @author Tujt 2015-06-16
 */
function getFieldUpdateLog(urldata,module){
    var url = 'module=Users&action=UsersAjax&file=callStaticMethod';
	url += '&static=ModTracker&method=getFieldUpdateLog&'+urldata;
	RequestAjax(url,function(rest){
		if(empty(rest)) return false;
		var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
		var list = '<table class="listEntries" border="0" cellpadding="0" cellspacing="1" width="100%"><tbody><tr>';
		var idx = 0;
		ld.each(restobj.header,function(key,head){
			list += '<th><span style=\'cursor: pointer;\' fld=\''+key+'\' sorder=\''+restobj.filter.sorder+'\' title="'+head+'">'+head+'</span>';
			if(key == restobj.filter.order_by){
				if('desc' == restobj.filter.sorder){
					list += '<img src="themes/images/arrow_down.gif" border="0">';
				}else{
					list += '<img src="themes/images/arrow_up.gif" border="0">';
				}
			}
			list += '</th>';idx ++;
		});
		list += '</tr>';
		if(!empty(restobj.entries)){
			ld.each(restobj.entries,function(fldid,entity){
				list += '<tr bgcolor="white" class="Hover">';
                //19398: 首页>知识管理明细界面：关联创建--修改日志，弹出框显示出问题，
				ld.each(restobj.header,function(fld,head){
					if('whodid' == fld) fld = 'username';
                    //0020528: 项目：普通用户登录，（红杉项目）单据明细界面，关联创建-修改日志，修改日志底部右侧翻页按钮点击没有反应
                    if(entity[fld].value == null) entity[fld].value = '';
					list += '<td style="text-align: left;"><span title="'+htmldecode(entity[fld].value)+'">'+htmldecode(entity[fld].value)+'</span></td>';
				});
				list += '</tr>';
			});
			list += '<tr bgcolor="white" class="Hover"><td class="DivCR" valign="middle" colspan="'+idx+'">'+
						'<div class="PageDiv0">'+
							'<ul><li>'+restobj.navigation[0]+'</li>'+
							''+restobj.navigation[1]+'</ul>'+
						'</div>'+
					'</td></tr>';
		}else{
			list += '<tr bgcolor="white" class="Hover">';
			list += '<td colspan="'+idx+'" align="center">'+restobj.lbl_none+'</td>';
			list += '</tr>';
		}
		list += '</tbody></table>';
        var divobj = createElementDivs('ModTrackerDiv');
        ld(divobj).find('.D_pop_tit .D_ptita').html(restobj.title);
		ld('#ModTrackerDivcontent').html(list);
        ld(divobj).css('max-height','500px');
		ld('#ModTrackerDivcontent').css('max-height','400px');
		ld('#ModTrackerDivcontent').css('border','none');
		ld(divobj).find('.D_pbtn').css('display','none');
        ld('#ModTrackerDiv').css('margin-left','-345px');
        ld('#ModTrackerDiv').css('width','660px');//bug：2017/06/120028679: 修改日志界面问题
        ld('.PageDiv0').css('margin-top','2px');//bug： 2017/06/28：0028920: 单据明细界面：修改日志弹出层，翻页组件没上下居中显示
        ld('.Input').css('margin-top','-3px');
        fnvshobj('', 'ModTrackerDiv');
		ld(divobj).find('.pop_remind_content .listEntries .DivCR ul li .icon-firstpage,.icon-prevpage,.icon-nextpage,.icon-lastpage').on('click',function(){
			var start = ld(this).attr('start');
			var urldata = 'record='+restobj.filter.record+'&start='+start;
			urldata += '&order_by='+restobj.filter.order_by+'&sorder='+restobj.filter.sorder+'&rmodule='+module;
			getFieldUpdateLog(urldata,module);
		});
		//text-decoration:underline;
		ld(divobj).find('.D_pop_content th span').on({
			'mouseover':function(){
				ld(this).css('text-decoration','underline');
			},
			'mouseout':function(){
				ld(this).css('text-decoration','none');
			},
			'click':function(){
				var urldata = 'record='+restobj.filter.record+'&start='+restobj.filter.start;
				var sorder = '';
				if('desc' == ld(this).attr('sorder')){
					sorder = 'asc';
				}else{
					sorder = 'desc';
				}
				var order = ld(this).attr('fld');
				if('prevalue' == order) order = 'pre';//prevalue中的eval会被过滤掉
				urldata += '&order_by='+order+'&sorder='+sorder;
				getFieldUpdateLog(urldata,module);
			}
		});
		DelProgressObjs();
	});
}

/**
 * 显示负责人修改日志
 * @author andrew 2015-08-31
 */
function ModTrackerShowAssignedUserHistory(record,module){
	var urldata = 'record='+record+'&rmodule='+module;
	getAssignedUserUpdateLog(urldata,module);
}
/**
 * 获取负责人修改日志列表
 * @author andrew 2015-08-31
 */
function getAssignedUserUpdateLog(urldata,module){
	var isinit = 0;
    var url = 'module=Users&action=UsersAjax&file=callStaticMethod';
	url += '&static=ModTracker&fieldtype=assigned_user_id&method=getFieldUpdateLog&'+urldata;
	RequestAjax(url,function(rest){
		if(empty(rest)) return false;
		var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
		var list = '<table class="listEntries" border="0" cellpadding="0" cellspacing="1" width="100%"><tbody><tr>';
		var idx = 0;
		ld.each(restobj.header,function(key,head){
			list += '<th><div><span style=\'cursor: pointer;\' fld=\''+key+'\' sorder=\''+restobj.filter.sorder+'\'>'+head+'</span>'+'</div>';
			if(key == restobj.filter.order_by){
				if('desc' == restobj.filter.sorder){
					list += '<img src="themes/images/arrow_down.gif" border="0">';
				}else{
					list += '<img src="themes/images/arrow_up.gif" border="0">';
				}
			}
			list += '</th>';idx ++;
		});
		list += '</tr>';
		if(!empty(restobj.entries)){
			ld.each(restobj.entries,function(fldid,entity){
				list += '<tr bgcolor="white" class="Hover">';
				ld.each(restobj.header,function(fld,head){
					if('whodid' == fld) fld = 'username';
					list += '<td><div align=\'left\'>'+entity[fld].value+'</div>'+'</td>';
				});
				list += '</tr>';
			});
			list += '<tr bgcolor="white" class="Hover"><td class="DivCR" valign="middle" colspan="'+idx+'">'+
						'<div class="PageDiv0">'+
							'<ul><li>'+restobj.navigation[0]+'</li>'+
							''+restobj.navigation[1]+'</ul>'+
						'</div>'+
					'</td></tr>';
		}else{
			list += '<tr bgcolor="white" class="Hover">';
			list += '<td colspan="'+idx+'" align="center">'+restobj.lbl_none+'</td>';
			list += '</tr>';
		}
		list += '</tbody></table>';
		if(ld('#ModTrackerDiv').length == 1){
			if(0 == isinit) isinit = 1;
		}
		var divobj = createElementDivs('ModTrackerDiv');
		ld(divobj).find('.D_pop_tit .D_ptita').html(restobj.title);
		ld('#ModTrackerDivcontent').html(list);
		//ld(divobj).css('max-height','500px');
		//ld(divobj).find('.D_pop_content').css('max-height','400px');
		ld('#ModTrackerDivcontent').css('border','none');
		ld(divobj).find('.D_pbtn').css('display','none');
		ld('.PageDiv0').css('margin-top','2px');//2017/06/28 0028920: 单据明细界面：修改日志弹出层，翻页组件没上下居中显示
		ld('.Input').css('margin-top','-3px');
		if(0 == isinit){//初次加载的时候才显示
			ld('#ModTrackerDiv').css('top','38%');
		}
		ld(divobj).find('.pop_remind_content .listEntries .DivCR ul li span').on('click',function(){
			var start = ld(this).attr('start');
			var urldata = 'record='+restobj.filter.record+'&start='+start;
			urldata += '&order_by='+restobj.filter.order_by+'&sorder='+restobj.filter.sorder+'&rmodule='+module;
			getAssignedUserUpdateLog(urldata,module);
		});
		
		//text-decoration:underline;
		ld(divobj).find('.D_pop_content th span').on({
			'mouseover':function(){
				ld(this).css('text-decoration','underline');
			},
			'mouseout':function(){
				ld(this).css('text-decoration','none');
			},
			'click':function(){
				var urldata = 'record='+restobj.filter.record+'&start='+restobj.filter.start;
				var sorder = '';
				if('desc' == ld(this).attr('sorder')){
					sorder = 'asc';
				}else{
					sorder = 'desc';
				}
				var order = ld(this).attr('fld');
				if('prevalue' == order) order = 'pre';//prevalue中的eval会被过滤掉
				urldata += '&order_by='+order+'&sorder='+sorder;
				getAssignedUserUpdateLog(urldata,module);
			}
		});
		DelProgressObjs();
	});
}