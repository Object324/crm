/**
 * 初始化用户弹出层
 * @param Object obj 传递参数
 * field : 接收用户信息的字段值(ID) -- field_name 接收用户名、selectfield、必须选中的值
 * @param Function saveback 保存按钮点击后回传函数，回传函数中return true;则不在走下面的默认代码
 * @param Function callback 页面加载完成后执行该方法
 * @project PROT180 角色权限改进
 * @author Tujt 2015-03-24
 */

var selectNum = 0;
var selectUser = [];
//19363: 销售退货单>列表：查看范围，选择高级。然后，查看范围选择全部，勾选一条记录，共享给用户。结果：查看范围又跳转到了高级。
var obj_User_type={};
var obj_init_type='no';
function ViewUserPopups(obj,saveback,callback){
    //1、创建显示层 div
	var divid = 'viewuserpopup';var isinit = 0;var selectCheckNum = 0;//总的checkbox数 部门+用户
	//var titlename = arrJsPopLabel['LBL_SELECTUSER'];//弹出层名称
    /* editor:gyq_08 reason:分录自定义页面修改 date:2016 3 15 */
	var titlename = arrJsPopLabel['LBL_FIELDS_ACCESS'];//弹出层名称
    //alert(obj.type);
	if(!empty(obj.type)){//弹出层类型
		if(obj.type == 'userscope')
			titlename = arrJsPopLabel['THEQUERYSCOPE'];
        else if(obj.type == 'showusers'){
            titlename = arrJsPopLabel['LBL_SELECTUSER'];
        }
		else if(obj.type == 'listshare')
			titlename = arrJsPopLabel['SHARE'];
		else if(obj.type == 'searchscope')
			titlename = arrJsPopLabel['VIEWRANGESENIOR'];
        else if(obj.type=='Allocate')
            if(obj.module=='ServiceReturn'){
                titlename = arrJsPopLabel['DISTRIBUTECHANGESERVANT'];
            }else{
                titlename = arrJsPopLabel['DISTRIBUTECHANGEASSIGNED'];
            }
       else if(obj.type=='ChangeCreator'){
                titlename = arrJsPopLabel['CHANGECREATED'];
            }
       else if(obj.type=='highseaallocateuserid'){//公海分配
                titlename = arrJsPopLabel['LBL_DISTRIBUT_HIGHSEAS'];
            }
		if(!empty(obj.selecttype) && obj.selecttype == 'group'){
			titlename = arrJsPopLabel['SELECT']+arrJsPopLabel['USERGROUPLIST'];
		}
		//重新加载
		if(!empty(viewuserpopup_type) && viewuserpopup_type != obj.type){
			isinit = 0;// isinit = 2;//0018392: 客户>列表：勾选记录，共享给其他用户。再点击高级图标，结果：又弹出共享的提示框。
			//0018448: 所有模块>列表：共享单据后，点击高级图标。结果：高级弹出层的【取消】按钮不显示了。
			if(ld('#'+divid+' .D_pbtn .D_pbtncancel').attr('style') == 'display: none;'){
				ld('#'+divid+' .D_pbtn .D_pbtncancel').css('display','');
			}
		}
		viewuserpopup_type = obj.type;
	}else{
	   titlename = arrJsPopLabel['LBL_SELECTUSER'];//弹出层名称
	}
	//if(0 == ld('#'+divid).length){//当层未创建时，创建层
		//工作协同 - 选择抄送范围0018864: 首页>工作协同>发微博、发日志、发指令：选择抄送范围弹出层，点击全选复选框，选择所有用户后，再发微博，选择抄送范围，勾选人员后，不显示。
		if(obj.type == 'searchText'){
			selectNum = 0;
			selectUser = [];
			obj.selectUserid = '';
		}
		var divObj = document.createElement("div");
		divObj.setAttribute('id',divid);
		divObj.className = 'E_pop_box LdPopWidth600px';
		divObj.style.position = "absolute";
		divObj.style.zIndex = "10001";
		divObj.style.top = "120px";
		divObj.style.left = "350px";
		divObj.style.display = "none";
		divObj.style.backgroundColor = "#ffffff";
		document.body.appendChild(divObj);
		divObj.innerHTML = '<div class="E_pop_tit">'+
								'<strong class="E_ptita" id="titlename">'+titlename+'</strong>'+
								'<button class="E_ptitc" value="'+arrJsPopLabel['LBL_CLOSE']+'" title="'+arrJsPopLabel['LBL_CLOSE']+'"></button>'+
							'</div>'+
							'<div id="'+divid+'content" class="D_pop_content" style="padding:0px;">'+
								'&nbsp;'+
							'</div>';
		//工作协同 - 选择抄送范围  取消掉弹出筐头部
		if(obj.type == 'searchText'){
			divObj.innerHTML = '<div id="'+divid+'content" class="D_pop_content" style="padding:0px;border:0px;margin:0px;">'+
								'&nbsp;'+
							'</div>';
			divObj.innerHTML += '<div style="padding:10px 0px">&nbsp;&nbsp;&nbsp;'+arrJsPopLabel['isselect']+'<span id="selectnum">0</span> / <span id="totalnum">0</span></div>';
		}else{
			divObj.innerHTML +='<div class="E_pbtn"><input class="E_pbtnok" value="'+arrJsPopLabel['CONFIRME']+'" type="button"><span>&nbsp;</span>'+
							'<input class="E_pbtncancel" value="'+arrJsPopLabel['CANCEL']+'" type="button"></div>';	
		}
//	}
   
	if(ld('#viewuserlist').length == 1){
	   //19363: 销售退货单>列表：查看范围，选择高级。然后，查看范围选择全部，勾选一条记录，共享给用户。结果：查看范围又跳转到了高级。
	//	if(obj_init_type=="no"&&0 == isinit && obj_User_type.hasOwnProperty(obj.type) ) isinit = 1;
	}
    
    
    //2、显示bg底层，调整弹出层位置
	var fld = obj.field;//重要参数，回传的字段名(注：主要是用来保存弹出层选中的用户id)
	if(ld('#'+fld).length == 0){//如果字段不存在，就创建一个字段
		var hidhtml = '<input type=\'hidden\' id=\''+fld+'\' />';
		ld('#'+divid+' .E_pop_tit').after(hidhtml);
	}
	var fldobj = document.getElementById(fld);
	if(!empty(obj.value)){//默认值
		if('isnull' == obj.value){
			fldobj.value = '';
		}else{
			fldobj.value = obj.value;
		}
	}
	var isbg = 0;
	/*
    if(ld('#layer').length > 0){
		isbg = 1;
        ld('#'+divid).css('display','');
	}else{
	    fnvshobj(fldobj, divid);
	}
    */
    if(ld('#layer').length > 0){
		isbg = 1;
	}
    fnvshobj(fldobj, divid);//弹出层放在屏幕正中间，2015-12-15
    
	if(obj.type != 'listproductpermission'){
		if(1== isinit){//弹出层已经加载过，不需要重复加载0018301: 所有模块>列表：勾选记录1，共享给用户1，再勾选记录2，弹出勾选共享弹出层。结果：用户1显示了“√”，并且共享弹出层缺少了【取消】按钮。
			ld('#'+divid+' .filetree input[type=checkbox]').not('input[select=1]').prop('checked',false);
			if(obj.type == 'searchText'){
				var curr_id;
				if(obj.selectUserid.length > 0){
					curr_id = obj.selectUserid.join(',');
				}
			}else{
				var curr_id = ld('#'+fld).val();	
			}
			ld('#viewuserpopup .E_ptita').html(titlename);//重新给弹出层的标题赋值
			if(!empty(curr_id)) curr_id = ','+curr_id+',';
			ld('#'+divid+' .filetree span.user').each(function(){//循环所有file图标
				var record = ld(this).attr('record');
				var recordarr = record.split('_');
				//判断 fld 对应的值是否有值
				if(!empty(curr_id)){
					if(curr_id.indexOf(','+recordarr[1]+',') > -1){
						ld(this).find('input[type=checkbox]').prop('checked',true);
						//selectNum++;
					}
				}
			});
			if(obj.type == 'Settings_recordgroup'){
				ld('#viewuser_locationdiv').focus();
			}else{
				ld('#viewuser_locationdiv').focus();
			}	
			if(!empty(callback)) callback();//执行该方法
			return false;
		}else if(0 == isinit){//初次加载的时候才显示
                //19363: 销售退货单>列表：查看范围，选择高级。然后，查看范围选择全部，勾选一条记录，共享给用户。结果：查看范围又跳转到了高级。
           
           if(ld('#viewuserlist').length !=1)
			     ld('#'+divid).css('top','15%');
		}
	}
   
    obj_User_type[obj.type]=obj.type;
	ld('#'+divid+'content').html('');
	/**
	 * 关闭事件
	 * @author Tujt 2015-04-15
	 */
	ld('#'+divid+' .E_pop_tit .E_ptitc').unbind('click').on('click',function(){
		//工作协同 - 选择抄送范围 - 没有取消按钮
		//工作协同 - 选择抄送范围
		if(obj.type == 'searchText'){
			if(0 == isbg){
				fninvshnew(divid);
			}else{
				ld('#'+divid).css('display','none');
			}
			if(ld('#viewuserlist').length == 0){
				//删除div
				var divobj = ld('#'+divid).get(0);
				divobj.parentNode.removeChild(divobj);
			}
		}else{
			ld('#'+divid+' .E_pbtn .E_pbtncancel').click();
			return false;	
		}
	});
	ld('#'+divid+' .E_pbtn .E_pbtncancel').unbind('click').on('click',function(){
		ld('#'+divid+' .E_pbtn .E_pbtncancel').trigger('closediv');
	});
    ld('#'+divid+' .E_pbtn .E_pbtncancel').unbind('closediv').on('closediv',function(){
        if(0 == isbg){
			fninvshnew(divid);
		}else{
			ld('#'+divid).css('display','none');
		}
		if(ld('#viewuserlist').length == 0){
			//删除div
			var divobj = ld('#'+divid).get(0);
			divobj.parentNode.removeChild(divobj);
		}
    });
 
	//3、获取用户树状结构图
	var urlstring = 'module=Users&action=UsersAjax&file=viewuserinfo';
	//工作协同 - 选择抄送范围 - 都可以查看到全部
	if(obj.type == 'searchText'){//查看范围
		urlstring += '&view=All';
	}else if(!empty(obj.view)){
		urlstring += '&view='+obj.view;
	}
	if(!empty(obj.module)){//模块
		urlstring += '&fld_module='+obj.module;
	}
	if(!empty(obj.filterown)){//是否过滤自己
		urlstring += '&filterown='+obj.filterown;
	}
	if(!empty(obj.isbox)){//是否过滤自己
		urlstring += '&isbox='+obj.isbox;
	}
	if(!empty(obj.selecttype)){//调用部门
		urlstring += '&selecttype='+obj.selecttype;
	}
    if(!empty(obj.ishighseaallocate)){//公海分配按钮操作；
        urlstring += '&ishighseaallocate='+obj.ishighseaallocate;
    }
	RequestAjax(urlstring,function(rest){
		if(empty(rest)) return false;
		//工作协同 - 选择抄送范围
		if(obj.type == 'searchText'){
			var membermessage = arrJsPopLabel['searchforcolleagues'];
			var viewhtml = '<div class="select-input"><input type="text" placeholder=\''+membermessage+'\' class="ld-input-inner width150 marLR10" id=\'viewuser_locationdiv\' value=""><input type="checkbox" checked id=\'viewuser_nogroupuser\'><label for=\'viewuser_nogroupuser\'>'+arrJsPopLabel['SHOWNOGROUPUSER']+'</label><div class="ui-popup-close"><b style="line-hight:none;">×</b></div></div>';
		}else if(obj.type == 'Settings_recordgroup'){
			var membermessage = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];
			var viewhtml = '<div class="select-input"><label class="padL0">'
			+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'viewgroup_locationdiv\' value=\''+membermessage+'\'></div>';
		}else{
			var membermessage = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];
			var viewhtml = '';
			//0020784: 控制面板 > 单据分录自定义 界面：选择用户弹出层中增加说明信息：注意：选择的用户没有该字段的查看和编辑权限
			if(obj.type == 'listproductpermission'){
				viewhtml += '&nbsp;&nbsp;&nbsp;<span class="E_red_txt">'+arrJsPopLabel['NOTESELECTTHEUSERDOESNOTHAVETHEFIELDVIEWANDEDITPERMISSIONS']+'</span><br />';
			}
			viewhtml += '<div class="select-input"><label class="padL0">'
			+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'viewuser_locationdiv\' value=\''
			+membermessage+
			'\'><div><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'
			+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div></div>';
		}
		
		viewhtml += '<div style="padding:10px;max-height:350px;overflow-y:auto;width:95%;">'+rest+'</div>';
        
		ld('#'+divid+'content').html(viewhtml);

		ld("#viewuserlist").find("span").css({'backgroundPosition':'0px 1px','backgroundSize':'14px 14px'});//将viewuserlist 下span 图标向下移2像素

        ld('#'+divid).addClass('ui-popup');
        ld('#viewuser_search').css({'top':'32px','paddingLeft':'13px'});
		//ld('#viewuserlist').treeview();//日程管理查看范围
      
		var curr_id = ld('#'+fld).val();var select_idx = 0;
      
		if(!empty(curr_id)) curr_id = ','+curr_id+',';
		if(obj.type == 'listshare' && obj.empty == undefined){
			curr_id = '';
		}
		if(ld('#select'+fld).length > 0 && !empty(ld('#select'+fld).val())){
			select_idx = ld('#select'+fld).val();
			select_idx = ','+select_idx+',';
		}
		var allUserNum = [];//所有用户个数，不统计同样的姓名
		ld('#'+divid+' .filetree span.file').each(function(){//循环所有file图标
			var record = ld(this).attr('record');
			var recordarr = record.split('_');
         
			//4、处理用户图标、隐藏停用用户
			if('user' == recordarr[0]){//判断是用户
				ld(this).attr('class','user');
				var parentfilter = ld(this).attr('parent');
				var parentarr = parentfilter.split('_');
				if('Inactive' == parentarr[1]){//隐藏停用的用户
					ld(this).parent().css('display','none');
					ld(this).attr('class','user in-user');
                    if(ld('#viewuser_nogroupuser').prop("checked")!=true){
                        if('nogroup' == parentarr[1])
                        ld(this).parent().css('display','none');
                    }
				}

				if('nogroup' == parentarr[1]){//隐藏无部门的用户
                    if(ld('#viewuser_disableuser').prop("checked")!=true){
                        //if(parentarr[2]=='Inactive')//在无部门用户情况下隐藏停用用户
                        ld(this).parent().css('display','none');
                    }
					//ld(this).parent().css('display','none');
					ld(this).attr('class','user in-nogroupuser');//无部门用户则显示为红色
				}
				if('nogroup' == parentarr[1] && 'Inactive' == parentarr[2])//无部门用户，并且是不启用用户
				    ld(this).attr('class','user nogroupuser');
				ld(this).attr('title','部门：'+ld(this).parent().parent().parent().find('span label').html());
				//判断 fld 对应的值是否有值
                //18301: 所有模块>列表：勾选记录1，共享给用户1，再勾选记录2，弹出勾选共享弹出层。结果：用户1显示了“√”，并且共享弹出层缺少了【取消】按钮。
				//0018318: 控制面板>单据分录自定义：选择用户弹出层，勾选用户后保存，再次打开弹出层，结果：复选框的“√”没有显示。
				if(!empty(curr_id) ){
					if(curr_id.indexOf(','+recordarr[1]+',') > -1){
					    if(obj.isbox==2){
					       ld(this).find('input[type=radio]').prop('checked',true);
					    }else{
					       ld(this).find('input[type=checkbox]').prop('checked',true);
					    }
					}
				}
               
				//判断是否有必须选中的项
				if(!empty(select_idx)){
					if(select_idx.indexOf(','+recordarr[1]+',') > -1){
						ld(this).find('input[type=checkbox]').prop('checked',true);
						ld(this).find('input[type=checkbox]').attr('select','1');
						ld(this).find('input[type=checkbox]').on('click',function(){
							return false;
						});
					}
				}
				if((allUserNum['key'+recordarr[1]] == undefined || allUserNum['key'+recordarr[1]] == '')){
					allUserNum['key'+recordarr[1]] = recordarr[1];
					//停用用户不计
					if(parentarr[1] != 'Inactive'){
						selectCheckNum++;
					}
					//无部门用户，并且是不启用用户
					if('nogroup' == parentarr[1] && 'Inactive' == parentarr[2]){
						selectCheckNum--;
					}
				}
				
			}
			DelProgressObjs();
		});
		//工作协同 - 选择抄送范围
		if(obj.type == 'searchText'){
			ld('#totalnum').html(selectCheckNum);
		}
		//添加取消事件
		ld('#viewuserpopupcontent .ui-popup-close b').unbind('click').on('click',function(){
			if(0 == isbg){
				fninvshnew(divid);
			}else{
				ld('#'+divid).css('display','none');
			}
			if(ld('#viewuserlist').length == 0){
				//删除div
				var divobj = ld('#'+divid).get(0);
				divobj.parentNode.removeChild(divobj);
			}
		});
		//给文本框添加光标移入事件、光标移出事件
		// 用户
		ld('#viewuser_locationdiv').unbind('focus').on('focus',function(){
			ld(this).val(trim(ld(this).val()));//去掉输入框中的多余空格
			if(ld(this).val() == membermessage){//光标移入时文本框字样为：请输入要查找的用户
				ld(this).val('');//文本框置空
				ld(this).css('color','#000');//文字样式修改为黑色
			}
		});
		ld('#viewuser_locationdiv').unbind('blur').on('blur',function(){
			ld(this).val(trim(ld(this).val()));//去掉输入框中的多余空格
			if(empty(ld(this).val())){//光标移出文本框为也为空
				ld(this).val(membermessage);//重新给文本框赋值为：请输入要查找的用户
				ld(this).css('color','#999');//文字样式修改
			}
		});
		//部门
		ld('#viewgroup_locationdiv').unbind('focus').on('focus',function(){
			ld(this).val(trim(ld(this).val()));//去掉输入框中的多余空格
			if(ld(this).val() == membermessage){//光标移入时文本框字样为：请输入要查找的用户
				ld(this).val('');//文本框置空
				ld(this).css('color','#000');//文字样式修改为黑色
			}
		});
		ld('#viewgroup_locationdiv').unbind('blur').on('blur',function(){
			ld(this).val(trim(ld(this).val()));//去掉输入框中的多余空格
			if(empty(ld(this).val())){//光标移出文本框为也为空
				ld(this).val(membermessage);//重新给文本框赋值为：请输入要查找的用户
				ld(this).css('color','#999');//文字样式修改
			}
		});
       
		//5、显示、隐藏停用用户
		ld('#viewuser_disableuser').unbind('click').on('click',function(){
			if(ld(this).prop('checked')){
				ld('#'+divid+' .filetree span.user').each(function(){//循环所有file图标
					var parentfilter = ld(this).attr('parent');
					var parentarr = parentfilter.split('_');
					if('nogroup' == parentarr[1] && 'Inactive' == parentarr[2]){//无部门用户，并且是不启用用户
						ld(this).attr('class','user nogroupuser');
     	                  ld(this).parent().css('display','');
                           if(ld('#viewuser_nogroupuser').prop("checked")!=true){
                                if('nogroup' == parentarr[1])
                                 ld(this).parent().css('display','none');
                           }
					}
					if('Inactive' == parentarr[1]){//显示停用的用户
						ld(this).parent().css('display','');
					}
				});
			}else{
				ld('#'+divid+' .filetree span.user').each(function(){//循环所有file图标
					var parentfilter = ld(this).attr('parent');
					var parentarr = parentfilter.split('_');
					if('nogroup' == parentarr[1] && 'Inactive' == parentarr[2]){//无部门用户，并且是不启用用户
						ld(this).attr('class','user');
                        ld(this).parent().css('display','none');
					}
					if('Inactive' == parentarr[1]){//隐藏停用的用户
						ld(this).parent().css('display','none');
						ld(this).find('input[type=checkbox]').prop('checked',false);//取消选择
					}
				});
			}
		});
		//6、显示、隐藏无部门用户
		ld('#viewuser_nogroupuser').unbind('click').on('click',function(){
			if(ld(this).prop('checked')){
				ld('#'+divid+' .filetree span.user').each(function(){//循环所有file图标
					var parentfilter = ld(this).attr('parent');
					var parentarr = parentfilter.split('_');
                    
					if('nogroup' == parentarr[1]){//显示无部门的用户
                    //alert(ld('#viewuser_disableuser').prop("checked"));
                        if(parentarr[2]=='Inactive'&&ld('#viewuser_disableuser').prop("checked")!=true){
                       	    ld(this).parent().css('display','none');
                        }else{
                            ld(this).parent().css('display','');
                        }
						//工作协同 - 选择抄送范围
						if(obj.type == 'searchText'){
							selectCheckNum++;
							if(ld('#viewuser_disableuser').prop("checked") == true){
								selectNum++;
							}
						}
					}
					
				});
			}else{
				ld('#'+divid+' .filetree span.user').each(function(){//循环所有file图标
					var parentfilter = ld(this).attr('parent');
					var parentarr = parentfilter.split('_');
					if('nogroup' == parentarr[1]){//隐藏无部门的用户
						ld(this).parent().css('display','none');
						
						//工作协同 - 选择抄送范围 -- 全选后 - 不无部门用户
						if(obj.type == 'searchText' && ld(this).parent().attr('style') == 'display: none;'){
							var checklabel = ld(this).find('label').html();
							var record = ld(this).attr('record');
							var recordarr = record.split('_');
							setCoordination(obj,false,recordarr,checklabel,0);
							selectCheckNum--;
							if(ld(this).find('input[type=checkbox]').prop('checked') == true){
								selectNum--;
							}
						}
						ld(this).find('input[type=checkbox]').prop('checked',false);//取消选择
					}
				});
			}
			//工作协同 - 选择抄送范围
			if(obj.type == 'searchText'){
				if(selectNum < 0) selectNum = 0;
				if(selectCheckNum <0) selectCheckNum = 0;
				ld('#selectnum').html(selectNum);//已选
				ld('#totalnum').html(selectCheckNum);//全部
			}
		});
        
		//7、定位 keyup
		ld('#viewuser_locationdiv').attr("autocomplete","off");
		var usersearch = {};//用户信息
		var curr_idx = -1;var foridx = 0;
       
       getScriptBackWithURL('include/js/multipingyin.js',null);//加载拼音代码
        
		ld('#viewuser_locationdiv').unbind('keyup').on('keyup',function(event){
			//方向上下键快速选择用户、换行键选中用户
			if(ld('#viewuser_search .view-search div').length > 0){
				var e = event || window.event;
				if(e.keyCode == '38' || e.keyCode == '40'){//方向上键、方向下键键盘事件
					if(curr_idx == -1){
						curr_idx = 0;
						ld('#viewuser_search .view-search div').get(curr_idx).className = 'view-hover';
						return false;
					}
					ld('#viewuser_search .view-search div').get(curr_idx).className = '';
					if(e.keyCode == '38'){//方向上键
						curr_idx --;
						if(curr_idx < 0){
							curr_idx = foridx-1;
						}
						ld('#viewuser_search .view-search div').get(curr_idx).className = 'view-hover';
						return false;
					}else if(e.keyCode == '40'){//方向下键
						curr_idx ++;
						if(curr_idx >= foridx){
							curr_idx = 0;
						}
						ld('#viewuser_search .view-search div').get(curr_idx).className = 'view-hover';
						return false;
					}
					return false;
				}else if(e.keyCode == '13'){//enter右键事件
					if(ld('#viewuser_search .view-search div:eq('+curr_idx+')').length > 0){
					  
						ld('#viewuser_search .view-search div:eq('+curr_idx+')').click();
					}
				}
			}
			//1、获取输入的值
			ld(this).val(trim(ld(this).val()));//去掉输入框中的多余空格
			var searchtext = ld(this).val();//获取输入样式
			searchtext = trim(searchtext);
			if(empty(searchtext) || searchtext == membermessage){
				if(ld('#viewuser_search').length > 0){
					ld('#viewuser_search .view-search').html('');
					curr_idx = -1;
				}
				return false;
			}
			//特别命令
			if(':' == searchtext.charAt(0)){
				var Commandkey = searchtext.substring(1,searchtext.length);
				if('select' == Commandkey){//全选
					ld('#viewuserlist input[type=checkbox]').prop('checked',true);
					ld(this).val(':');
					return false;
				}else if('clear' == Commandkey){//全清
					ld('#viewuserlist input[type=checkbox]').prop('checked',false);
					ld(this).val(':');
					return false;
				}else if('view' == Commandkey){//显示隐藏停用用户
					ld('#viewuser_disableuser').click();
					ld('#viewuser_nogroupuser').click();
					ld(this).val(':');
					return false;
				}else if('save' == Commandkey){//保存
					ld('#viewuserpopup .D_pbtn .D_pbtnok').click();//保存
					ld(this).val('');
					return false;
				}else if('close' == Commandkey){//关闭
					ld('#viewuserpopup .D_pbtn .D_pbtncancel').click();
					ld(this).val('');
					return false;
				}
			}
            
			//2、添加搜索显示层
			if(ld('#viewuser_search').length == 0){
				if(obj.type == 'searchText'){
					ld(this).parent().after('<div id=\'viewuser_search\' style=\'padding-left:13px;display: block;position: absolute;top: 32px;\'><div class=\'view-search\' ></div></div>');
				}else{
					ld(this).parent().after('<div id=\'viewuser_search\' style=\'padding-left:67px;display: block;position: absolute;top: 71px;\'><div class=\'view-search\' ></div></div>');
				}
				
			}
			//3、获取用户结果集
			//获取所有用户信息，方便搜索显示用，不用每次都去页面获取数据
			if(empty(usersearch)){
				var username = '';var userpinyin = '';var inuser = '';
				ld('#'+divid+' .filetree span.user').each(function(){//循环所有User用户
					username = ld(this).find('label').html();
					userpinyin = makePy(username);
                    userpinyin=userpinyin.join("").toLowerCase();
					inuser = ld(this).attr('class');
					usersearch[username] = {'name':username,'pinyin':userpinyin,
											'record':ld(this).attr('record'),
											'inuser':inuser};
				});
			}
			//4、搜索用户
			var searchpinyin = makePy(searchtext);
            searchpinyin=searchpinyin.join("").toLowerCase();
			var searchhtml = '';
			ld('#viewuser_search .view-search').html('');
			foridx = 0;
			var viewuser_disable = ld('#viewuser_disableuser').prop('checked');
            var viewuser_nogroupuser = ld('#viewuser_nogroupuser').prop('checked');
			ld.each(usersearch,function(userid,userobj){
				/**
				 * 搜索用户时，如果为选择显示停用用户，则允许搜索出停用用户
				 * @author tujt 2015-05-04
				 */
                 //alert(userobj.name+'|'+userobj.inuser);
				if(!viewuser_disable && ('user in-user' == userobj.inuser||'user nogroupuser' == userobj.inuser)){
					return true;
				}
				if(!viewuser_nogroupuser && ('user in-nogroupuser' == userobj.inuser||'user nogroupuser' == userobj.inuser)){
					return true;
				}
                /*if(userobj.name.indexOf(searchtext) > -1 || userobj.pinyin.indexOf(searchtext) > -1){*/
                /* 模糊查询改为首字母查询 zyh 20150518 */
				if(userobj.name.indexOf(searchtext) == 0 || userobj.pinyin.indexOf(searchtext) == 0){
		            searchhtml += '<div record=\''+userobj.record+'\' idx=\''+foridx+'\'>'+userobj.name+'</div>';
                    foridx ++;
				}
			});
			ld('#viewuser_search .view-search').html(searchhtml);
			//5、绑定事件
			ld('#viewuser_search .view-search div').unbind('mouseover').on('mouseover',function(){
				ld(this).addClass('view-hover');//鼠标移入事件
				curr_idx = ld(this).attr('idx');
			});
			ld('#viewuser_search .view-search div').unbind('mouseout').on('mouseout',function(){
				ld(this).removeClass('view-hover');//鼠标移出事件
				curr_idx = ld(this).attr('idx');
			});
			//用户搜索结果层，点击事件
			ld('#viewuser_search .view-search div').unbind('click').on('click',function(){
				var userid = ld(this).attr('record');
				ld('#viewuser_locationdiv').val('');
				ld('#viewuser_search .view-search').html('');
				var scrollTo = '';var fori = 0;var useridx = 0;
				ld('#'+divid+' .filetree span.user').each(function(){//循环所有User用户
					if(userid == ld(this).attr('record')){
						//有可能有checkbox、radio两种元素，所以用name获取
                       //20778: 首页>工作协同>发微博、发日志、发指令：选择抄送范围弹出层，在搜索框输入关键字后，点击下拉选项后，人员显示勾选，但是实际上没有勾选。选择抄送范围还是没有显示人员
                        ld(this).find('input[name=viewuser_input]').prop("checked",true);
						ld(this).find('input[name=viewuser_input]').click();
                        //不是多余的代码（can),click事件反选所以必须添加该语句
                        ld(this).find('input[name=viewuser_input]').prop("checked",true);
						scrollTo = ld(this).get(0);
						useridx = fori;
					}
					fori ++;
				});
				var container = ld('#'+divid+' .filetree').parent().get(0);
				var input_h = scrollTo.offsetHeight;
                var hiddenobjcount=0;//隐藏元素
                var showobjcount=0;
                for(var i=0;i<ld("#viewuserlist").find("span").length;i++)
                {
                    var objspan=ld("#viewuserlist span:eq("+i+")").attr('record');
                   if(ld("#viewuserlist span:eq("+i+")").parent().attr("style")==undefined)
                   {
                        if(objspan==userid)
                           {
                            //17439: 共享弹出层：输入关键字后，按enter键，没有直接显示该用户(可以再减去可见区域的高度，我现在没有时间修改了)
                               if(showobjcount<=5&&container.scrollTop!=10)
                               {
                                     container.scrollTop=10;
                               }
                               else
                               {
                                    container.scrollTop=(showobjcount/ld("#viewuserlist").find("span").length)*ld("#viewuserlist").height()-20*5;
                                   
                               }
                                 break;
                           }
                           showobjcount++;
                   }
                   
                   
                }
			
			});
		});
       
		//7、部门定位 keyup
		ld('#viewgroup_locationdiv').attr("autocomplete","off");
		var groupsearch = {};//用户信息

		ld('#viewgroup_locationdiv').unbind('keyup').on('keyup',function(event){
			//方向上下键快速选择用户、换行键选中用户
			if(ld('#viewuser_search .view-search div').length > 0){
				var e = event || window.event;
				if(e.keyCode == '38' || e.keyCode == '40'){//方向上键、方向下键键盘事件
					if(curr_idx == -1){
						curr_idx = 0;
						ld('#viewuser_search .view-search div').get(curr_idx).className = 'view-hover';
						return false;
					}
					ld('#viewuser_search .view-search div').get(curr_idx).className = '';
					if(e.keyCode == '38'){//方向上键
						curr_idx --;
						if(curr_idx < 0){
							curr_idx = foridx-1;
						}
						ld('#viewuser_search .view-search div').get(curr_idx).className = 'view-hover';
						return false;
					}else if(e.keyCode == '40'){//方向下键
						curr_idx ++;
						if(curr_idx >= foridx){
							curr_idx = 0;
						}
						ld('#viewuser_search .view-search div').get(curr_idx).className = 'view-hover';
						return false;
					}
					return false;
				}else if(e.keyCode == '13'){//enter右键事件
					if(ld('#viewuser_search .view-search div:eq('+curr_idx+')').length > 0){
					  
						ld('#viewuser_search .view-search div:eq('+curr_idx+')').click();
					}
				}
			}
			//1、获取输入的值
			ld(this).val(trim(ld(this).val()));//去掉输入框中的多余空格
			var searchtext = ld(this).val();//获取输入样式
			searchtext = trim(searchtext);
			if(empty(searchtext) || searchtext == membermessage){
				if(ld('#viewuser_search').length > 0){
					ld('#viewuser_search .view-search').html('');
					curr_idx = -1;
				}
				return false;
			}
			//特别命令
			if(':' == searchtext.charAt(0)){
				var Commandkey = searchtext.substring(1,searchtext.length);
				if('select' == Commandkey){//全选
					ld('#viewuserlist input[type=checkbox]').prop('checked',true);
					ld(this).val(':');
					return false;
				}else if('clear' == Commandkey){//全清
					ld('#viewuserlist input[type=checkbox]').prop('checked',false);
					ld(this).val(':');
					return false;
				}else if('view' == Commandkey){//显示隐藏停用用户
					ld('#viewuser_disableuser').click();
					ld('#viewuser_nogroupuser').click();
					ld(this).val(':');
					return false;
				}else if('save' == Commandkey){//保存
					ld('#viewuserpopup .D_pbtn .D_pbtnok').click();//保存
					ld(this).val('');
					return false;
				}else if('close' == Commandkey){//关闭
					ld('#viewuserpopup .D_pbtn .D_pbtncancel').click();
					ld(this).val('');
					return false;
				}
			}
            
			//2、添加搜索显示层
			if(ld('#viewuser_search').length == 0){
				if(obj.type == 'searchText'){
					ld(this).parent().after('<div id=\'viewuser_search\' style=\'padding-left:13px;display: block;position: absolute;top: 32px;\'><div class=\'view-search\' ></div></div>');
				}else{
					ld(this).parent().after('<div id=\'viewuser_search\' style=\'padding-left:67px;display: block;position: absolute;top: 71px;\'><div class=\'view-search\' ></div></div>');
				}
				
			}
			//3、获取用户结果集
			//获取所有部门信息，方便搜索显示用，不用每次都去页面获取数据
			if(empty(groupsearch)){
				var groupname = '';var grouppinyin = '';var ingroup = '';
				ld('#'+divid+' .filetree span').each(function(){//循环所有部门用户
					groupname = ld(this).find('label').html();
					grouppinyin = makePy(groupname);
                    grouppinyin=grouppinyin.join("").toLowerCase();
					ingroup = ld(this).attr('class');
					groupsearch[groupname] = {'name':groupname,'pinyin':grouppinyin,
											'record':ld(this).attr('record'),
											'inuser':ingroup};
				});
			}
			//4、搜索用户
			var searchpinyin = makePy(searchtext);
            searchpinyin=searchpinyin.join("").toLowerCase();
			var searchhtml = '';
			ld('#viewuser_search .view-search').html('');
			foridx = 0;
			var viewuser_disable = ld('#viewuser_disableuser').prop('checked');
            var viewuser_nogroupuser = ld('#viewuser_nogroupuser').prop('checked');
			//获取模糊匹配项
			ld.each(groupsearch,function(userid,userobj){
				if(userobj.name.indexOf(searchtext) == 0 || userobj.pinyin.indexOf(searchtext) == 0){
		            searchhtml += '<div record=\''+userobj.record+'\' idx=\''+foridx+'\'>'+userobj.name+'</div>';
                    foridx ++;
				}
			});
			ld('#viewuser_search .view-search').html(searchhtml);
			//5、绑定事件
			ld('#viewuser_search .view-search div').unbind('mouseover').on('mouseover',function(){
				ld(this).addClass('view-hover');//鼠标移入事件
				curr_idx = ld(this).attr('idx');
			});
			ld('#viewuser_search .view-search div').unbind('mouseout').on('mouseout',function(){
				ld(this).removeClass('view-hover');//鼠标移出事件
				curr_idx = ld(this).attr('idx');
			});
			//用户搜索结果层，点击事件
			ld('#viewuser_search .view-search div').unbind('click').on('click',function(){
				var groupid = ld(this).attr('record');
				ld('#viewuser_locationdiv').val('');
				ld('#viewuser_search .view-search').html('');
				var scrollTo = '';var fori = 0;var useridx = 0;
				ld('#'+divid+' .filetree span').each(function(){//循环所有User用户
					if(groupid == ld(this).attr('record')){
						//有可能有checkbox、radio两种元素，所以用name获取
                        //20778: 首页>工作协同>发微博、发日志、发指令：选择抄送范围弹出层，在搜索框输入关键字后，点击下拉选项后，人员显示勾选，但是实际上没有勾选。选择抄送范围还是没有显示人员
                        ld(this).find('input[name=viewuser_input]').prop('checked',true);
						ld(this).find('input[name=viewuser_input]').click();
                        //不是多余的代码（can)
                        ld(this).find('input[name=viewuser_input]').prop('checked',true);
						scrollTo = ld(this).get(0);
						useridx = fori;
					}
					fori ++;
				});
				var container = ld('#'+divid+' .filetree').parent().get(0);
				var input_h = scrollTo.offsetHeight;
                var hiddenobjcount=0;//隐藏元素
                var showobjcount=0;
                for(var i=0;i<ld("#viewuserlist").find("span").length;i++)
                {
                    var objspan=ld("#viewuserlist span:eq("+i+")").attr('record');
                   if(ld("#viewuserlist span:eq("+i+")").parent().attr("style")==undefined)
                   {
                        if(objspan==groupid)
                           {
                            //17439: 共享弹出层：输入关键字后，按enter键，没有直接显示该用户(可以再减去可见区域的高度，我现在没有时间修改了)
                               if(showobjcount<=5&&container.scrollTop!=10)
                               {
                                     container.scrollTop=10;
                               }
                               else
                               {
                                    container.scrollTop=(showobjcount/ld("#viewuserlist").find("span").length)*ld("#viewuserlist").height()-20*5;
                                   
                               }
                                 break;
                           }
                           showobjcount++;
                   }
                   
                   
                }
			
			});
		});



		//8、选择部门后全选下级所有部门和用户
		ld('#'+divid+' .filetree li input[type=checkbox]').unbind('click').on('click',function(){
			//选中、取消选中一个用户后，相应将所有当前用户选中、取消,'user in-user':表示停用的用户
			if('user' == ld(this).parent().attr('class')||'user in-user'==ld(this).parent().attr('class') || (ld(this).parent().attr('class') == 'user in-nogroupuser' && obj.type == 'searchText')){
			
				var record = ld(this).parent().attr('record');
				var recordarr = record.split('_');
				record = recordarr[1];
				var check = ld(this).prop('checked');
				var userid='',useridarr=[];
				//工作协同 - 选择抄送范围
				if(obj.type == 'searchText'){
					var checklabel = ld(this).parent().find('label').html();
					setCoordination(obj,check,recordarr,checklabel,1);
				}
				ld('#'+divid+' .filetree span.user').each(function(){//循环所有User用户
					if('none' == ld(this).parent().css('display')) return true;//跳过当前循环
					userid = ld(this).attr('record');
					useridarr = userid.split('_');
					if(record == useridarr[1]){
						ld(this).find('input[type=checkbox]').prop('checked',check);
					}
				});
			}else{//选中上级部门，全选下级部门时，同时把下级部门在其他部门中重复的项也选中、取消
				var inputobj = ld(this).parent().parent().find('ul input[type=checkbox]').not('input[select=1]');
				if(ld(this).parent().parent().find('ul').length > 0){//存在下级
					if(ld(this).prop('checked')){//全选
						ld(inputobj).prop('checked',true);
					}else{//全不选
						ld(inputobj).prop('checked',false);
					}
				}
				
				ld(inputobj).each(function(){//
					if('user' == ld(this).parent().attr('class')||'user in-user'==ld(this).parent().attr('class')|| (ld(this).parent().attr('class') == 'user in-nogroupuser' && obj.type == 'searchText')){
						var record = ld(this).parent().attr('record');
						var recordarr = record.split('_');
						record = recordarr[1];
						var check = ld(this).prop('checked');
						var userid='',useridarr=[];
						ld('#'+divid+' .filetree span.user').each(function(){//循环所有User用户
							if('none' == ld(this).parent().css('display')) return true;//跳过当前循环
							userid = ld(this).attr('record');
							useridarr = userid.split('_');
							if(record == useridarr[1]){
								//工作协同 - 选择抄送范围
								if(obj.type == 'searchText'){
									var checklabel = ld(this).parent().find('label').html();
									setCoordination(obj,check,recordarr,checklabel,1);
								}else{
									ld(this).find('input[type=checkbox]').prop('checked',check);
								}
								
							}
						});
					}
				});
			}
			//工作协同 - 选择抄送范围
			if(obj.type == 'searchText'){
				if(selectNum <=0)selectNum=0;
				ld('#selectnum').html(selectNum);
			}
		});
		//9、选择用户
      
		ld('#'+divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
			var userobj = {};var userid = '',username = '',record = '';var recordarr = [];
            
			ld('#'+divid+' .filetree span.user').each(function(){//循环所有User用户
				if('none' == ld(this).parent().css('display')) return true;//跳过当前循环
				//用name获取，不管是checkbox还是radio都可以获取到
				if(ld(this).find('input[name=viewuser_input]').prop('checked')){
					record = ld(this).attr('record');
					recordarr = record.split('_');
					userobj[recordarr[1]] = ld(this).find('label').html();//防止重复
				}
			});
			var userarr = {};
           
			if(!empty(obj.empty) && empty(userobj)){//允许不选择用户
				ld('#'+fld).val('');
				ld('#'+fld+'_name').val('');
			}else{
				if(empty(userobj) && document.getElementById('permissionuserid') == undefined){
					alert(arrJsPopLabel['PLEASESELECTLESTONEUSER']);return false;
				}
				ld.each(userobj,function(id,name){
					if(!empty(userid)) userid += ',' + id;
					else userid = id;
					if(!empty(username)) username += ',' + name;
					else username = name;
				});
              
				ld('#'+fld).val(userid);
				if(ld('#'+fld+'_name').length > 0)
					ld('#'+fld+'_name').val(username);
				userarr['userid'] = {'value':userid};
				userarr['username'] = {'value':username};;
			}
			var issave = false;
			if(!empty(saveback)) var issave = saveback(userarr);
			if(empty(issave)) ld('#'+divid+' .D_pbtn .D_pbtncancel').trigger('closediv');//关闭窗口
		});
        
        fnvshobj(fldobj, divid);//弹出层放在屏幕正中间，2015-12-15
		ld('#viewuser_locationdiv').focus();
		if(!empty(callback)) callback();//弹出层加载完成后，执行该方法
		ld('#viewuserpopup .D_ptita').html(titlename);//重新给弹出层的标题赋值
	});
}
function setCoordination(obj,check,recordarr,checklabel,stype){
	if(check == true){
		if(selectUser['key'+recordarr[1]] != undefined && selectUser['key'+recordarr[1]] != ''){
			return false;
		}
		selectUser['key'+recordarr[1]] = checklabel;
		selectNum++;
		//添加新的li
		ld('#'+obj.tag+' ul.reader-bar-list').append('<li userid="'+recordarr[1]+'"><span class="item-name">'+checklabel+'</span><span class="remove-h">×</span></li>');
		//绑定删除事件
		ld('#'+obj.tag+' ul.reader-bar-list li[userid='+recordarr[1]+'] .remove-h').unbind('click').click(function(){
			var liuserid = ld(this).parent().attr('userid');
			ld('#'+obj.tag+' ul.reader-bar-list li[userid='+liuserid+']').remove();
			return false;
		});
		
	}else{
		ld('#'+obj.tag+' ul.reader-bar-list li').each(function(){
			if(ld(this).attr('userid') != undefined && ld(this).attr('userid') > 0){
				if(recordarr[1] == ld(this).attr('userid')){
					ld('#'+obj.tag+' ul.reader-bar-list li[userid='+ld(this).attr('userid')+']').remove();
					selectUser['key'+recordarr[1]] = '';
					//选择部门影响客户
					if(stype == 1){
						selectNum--;
					}
					return false;//结束循环
				}
			}
		});
	}
}
//高级
function UserHigherPop(module,searchview)
{
    
  
    if(0 == ld('#searchseniorview').length){
		var divObj = document.createElement("div");
		divObj.setAttribute('id','searchseniorview');
		divObj.style.display = "none";
		document.body.appendChild(divObj);
       
		divObj.innerHTML = '<input type="hidden" id="senioruserid"><input type="hidden" id="senioruserid_name">';
	}
	var obj = {'field':'senioruserid','view':'private','module':module,'type':'searchscope'};
	
	/*ViewUserPopup(obj,function(){
		var senioruserid = ld('#senioruserid').val();
		var urlstring = 'module='+module+'&action='+module+'Ajax';
		urlstring += '&file=ListView&ajax=true&start=1&query=true';
		var customtype = '';
		if(module == 'SalesGoal'){
			var actionname=document.getElementById('actionname').value;
			var editresult=document.getElementById('editresult').value;
			window.location.href="index.php?module="+module+"&action="+actionname+"&query="+editresult+"&parenttab=Tools&SmOwnerSearchScope="+searchview+"&show="+'yes&senioruserid='+senioruserid;
		}
		if(document.massdelete.publicaccounttype!=undefined)
			customtype=document.massdelete.publicaccounttype.value;
		urlstring += '&SearchScope='+searchview+'&senioruserid='+senioruserid+'&accounttype='+customtype+'';
		RequestAjax(urlstring,function(rest){
			result = rest.split('&#&#&#');
			if(empty(rest)){
				ld('#ListViewContents').html('');return false;
			}
			if("undefined" != typeof(result[2])){
				ld('#ListViewContents').html(result[2]);
			}else{
				ld('#ListViewContents').html(arrJsPopLabel['DATAERROR']);
			}
			if(ld('#servicechargeleft').length > 0){
				ld('#servicechargeleft').html(result[3]);//服务收费管理
			}
			if(result[1] != ''){
				ld('#basicsearchcolumns_real').html(ld('#basicsearchcolumns').html());
				ld('#basicsearchcolumns').html('');
				document.basicSearch.search_text.value = '';
			}
		});
	});*/
    
}
     

