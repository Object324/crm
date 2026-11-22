/**
 * 初始化用户弹出层
 * @param Object obj 传递参数
 * field : 接收用户信息的字段值(ID) -- field_name 接收用户名、selectfield、必须选中的值
 * @param Function saveback 保存按钮点击后回传函数，回传函数中return true;则不在走下面的默认代码
 * @param Function callback 页面加载完成后执行该方法
 * @project PROT180 角色权限改进
 * @author Tujt 2015-03-24
 */
 var purview_type;//弹出框类型
 var searchmessage;//查询框默认显示信息
function ViewPopup(obj,saveback,callback){
    //创建显示层 div
	var isinit = 0;	//0 表示重新加载
	var divid = 'select_'+obj.type;	//div id
	var titlename = obj.pop_name;	//弹出层名称
	if(!empty(obj.type)){
		if(!empty(purview_type) && purview_type != obj.type){
			isinit = 0;
		}
		purview_type = obj.type;
		//设置查询框默认显示值
		if(purview_type == 'Group'){
			searchmessage = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];
		}
	}
	//if(0 == ld('#'+divid).length){//当层未创建时，创建层
		var divObj = document.createElement("div");
		divObj.setAttribute('id',divid);
		divObj.className = 'D_pop_box LdPopWidth600px';
		divObj.style.position = "absolute";
		divObj.style.zIndex = "10001";
		divObj.style.top = "120px";
		divObj.style.left = "350px";
		divObj.style.display = "none";
		divObj.style.backgroundColor = "#ffffff";
		document.body.appendChild(divObj);
		divObj.innerHTML = '<div class="D_pop_tit">'+
								'<strong class="D_ptita" id="titlename">'+
									''+titlename+'</strong>'+
								'<a href="javascript:;" class="D_ptitc">'+
									'<img class="D_ptitcimg" src="themes/icon/pop_close.png" '+
									'alt="'+arrJsPopLabel['LBL_CLOSE']+'" title="'+arrJsPopLabel['LBL_CLOSE']+'">'+
								'</a>'+
							'</div>'+
							'<div id="'+divid+'content" class="D_pop_content" style="padding:0px;">'+
								'&nbsp;'+
							'</div>';
		divObj.innerHTML +='<div class="D_pbtn"><input class="D_pbtnok" value="'+arrJsPopLabel['CONFIRME']+'" type="button"><span>&nbsp;</span>'+
						'<input class="D_pbtncancel" value="'+arrJsPopLabel['CANCEL']+'" type="button"></div>';	
	//}
	if(ld('#viewuserlist').length == 1){
		//if(0 == isinit) isinit = 1;
	}
    
	//2、显示bg底层，调整弹出层位置
	var fld = obj.field;//重要参数，回传的字段名
	if(ld('#'+fld).length == 0){//如果字段不存在，就创建一个字段
		var hidhtml = '<input type=\'hidden\' id=\''+fld+'\' />';
		ld('#'+divid+' .D_pop_tit').after(hidhtml);
	}
	var fldobj = document.getElementById(fld);
	var isbg = 0;
	if(ld('#layer').length > 0){
		isbg = 1;
		ld('#'+divid).css('display','');
	}else{
		fnvshobj(fldobj, divid);
	}
 
	if(1== isinit){
		ld('#'+divid+' .filetree input[type=checkbox]').not('input[select=1]').prop('checked',false);
		if(obj.type == 'searchText'){
			var curr_id;
			if(obj.selectUserid.length > 0){
				curr_id = obj.selectUserid.join(',');
			}
		}else{
			var curr_id = ld('#'+fld).val();	
		}
		ld('#titlename').html(titlename);//重新给弹出层的标题赋值
		if(!empty(curr_id)) curr_id = ','+curr_id+',';
		ld('#'+divid+' .filetree span').each(function(){//循环所有file图标
			var record = ld(this).attr('record');
			var recordarr = record.split('_');
			//判断 fld 对应的值是否有值
			if(!empty(curr_id)){
				if(curr_id.indexOf(','+recordarr[1]+',') > -1){
					ld(this).find('input[name=viewuser_input]').prop('checked',true);
				}
			}
		});
		ld('#viewuser_locationdiv').focus();
		if(!empty(callback)) callback();//执行该方法
		return false;
	}else if(0 == isinit){//初次加载的时候才显示
		ld('#'+divid).css('top','15%');
	}
   
	ld('#'+divid+'content').html('');
	/**
	 * 关闭事件
	 * @author Tujt 2015-04-15
	 */
	ld('#'+divid+' .D_pop_tit .D_ptitc').unbind('click').on('click',function(){
		ld('#'+divid+' .D_pbtn .D_pbtncancel').click();
		return false;	
	});
	ld('#'+divid+' .D_pbtn .D_pbtncancel').unbind('click').on('click',function(){
		ld('#'+divid+' .D_pbtn .D_pbtncancel').trigger('closediv');
	});
    ld('#'+divid+' .D_pbtn .D_pbtncancel').unbind('closediv').on('closediv',function(){
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
	if(!empty(obj.view)){//查看范围
		urlstring += '&view='+obj.view;
	}
	if(!empty(obj.module)){//模块
		urlstring += '&fld_module='+obj.module;
	}
	if(!empty(obj.filterown)){//是否过滤自己
		urlstring += '&filterown='+obj.filterown;
	}
	if(!empty(obj.isbox)){//单选 or 多选
		if(obj.isbox == 'sel_radio'){
			urlstring += '&isbox=2';
		}else{
			urlstring += '&isbox=1';
		}
	}
	if(purview_type == 'Group'){//调用部门
		urlstring += '&selecttype=1';
	}
	//用户和角色
	if(!empty(obj.type) && obj.type == 'selectprofileuser'){
		urlstring +='&selectprofileuser=yes';
	}
   // alert(urlstring);
	RequestAjax(urlstring,function(rest){
		if(empty(rest)){
			DelProgressObjs();
			return false;
		}
		var membermessage = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];
		var viewhtml = '<div style="text-align:left;padding-left:8px;padding-top:8px;">';
		//viewhtml += '<input type ="radio" id="selectprofileuser" name="selectprofileuser" value="profile" >按角色设置 &nbsp;&nbsp;&nbsp;<input type ="radio" id="selectprofileuser" name="selectprofileuser" checked value="user" >按用户设置'; 
		viewhtml += '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'viewuser_locationdiv\' value=\''
		+searchmessage+
		'\'></div>';
		if(obj.type == 'Users'){
			viewhtml += '<div id="selectUserCheck"><input type="checkbox" id=\'viewuser_disableuser\'><label id="viewuser_disableuser">'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
		}
		viewhtml += '</div>';
      
		viewhtml += '<div style="padding:10px;max-height:350px;overflow-y:auto;width:95%;">'+rest+'</div>';
        
		ld('#'+divid+'content').html(viewhtml);
		
		ld("#viewuserlist").find("span").css({'backgroundPosition':'0px 1px','backgroundSize':'14px 14px'});//将viewuserlist 下span 图标向下移2像素
		ld('#'+divid+' .filetree label').unbind('click').on('click',function(){
			var userarr = {};
			var record = ld(this).parent().attr('record');
			var recordarr = record.split('_');
			ld(this).parent().find('input[name=viewuser_input]').prop('checked',true);
			userarr['userid'] = {'value':recordarr[1]};
			userarr['username'] = {'value':ld(this).text()};
			if(!empty(saveback)) var issave = saveback(userarr);
			if(empty(issave)) ld('#'+divid+' .D_pbtn .D_pbtncancel').trigger('closediv');//关闭窗口
        
			ld('#viewuser_locationdiv').focus();
			if(!empty(callback)) callback();//弹出层加载完成后，执行该方法
			ld('#titlename').html(titlename);//重新给弹出层的标题赋值
		});
        
		//ld('#viewuserlist').treeview();//日程管理查看范围
      
		var curr_id = ld('#'+fld).val();
      
		if(!empty(curr_id)) curr_id = ','+curr_id+',';
		var allUserNum = [];//所有用户个数，不统计同样的姓名
		ld('#'+divid+' .filetree span').each(function(){//循环所有file图标
			var record = ld(this).attr('record');
			var recordarr = record.split('_');
			//4、处理用户图标、隐藏停用用户
			if('user' == recordarr[0] || 'profile' == recordarr[0]){//判断是用户
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
                        if(parentarr[2]=='Inactive')
                        ld(this).parent().css('display','none');
                    }
					//ld(this).parent().css('display','none');
					ld(this).attr('class','user in-nogroupuser');
				}
				if('nogroup' == parentarr[1] && 'Inactive' == parentarr[2])//无部门用户，并且是不启用用户
				    ld(this).attr('class','user nogroupuser');
				ld(this).attr('title','部门：'+ld(this).parent().parent().parent().find('span label').html());
				//判断 fld 对应的值是否有值
				if(!empty(curr_id) ){
					if(curr_id.indexOf(','+recordarr[1]+',') > -1){
						ld(this).find('input[name=viewuser_input]').prop('checked',true);
					}
				}
				if((allUserNum['key'+recordarr[1]] == undefined || allUserNum['key'+recordarr[1]] == '')){
					allUserNum['key'+recordarr[1]] = recordarr[1];
				}
				
			}else{
				if(!empty(curr_id) ){
					if(curr_id.indexOf(','+recordarr[1]+',') > -1){
						ld(this).find('input[name=viewuser_input]').prop('checked',true);
					}
				}
			}
			
		});
		if(0 == isinit){//初次加载的时候默认显示用户
			ld('#viewprofilelist').css('display','none');
		}		
		//切换角色、用户 设置
		ld('#'+divid+' input[name="selectprofileuser"]').unbind('click').on('click',function(){
			if(ld('#'+divid+' input[name="selectprofileuser"]:checked ').val() == 'user'){
				membermessage = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];
				ld('#viewuser_locationdiv').val(arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER']);
				ld('#viewuserlist').css('display','block');
				ld('#viewprofilelist').css('display','none');
				ld('#selectUserCheck').css('display','block');
			}else{
				membermessage = arrJsPopLabel['pleaseenterprofile'];
				ld('#viewuser_locationdiv').val(arrJsPopLabel['pleaseenterprofile']);
				ld('#viewuserlist').css('display','none');
				ld('#viewprofilelist').css('display','block');
				ld('#selectUserCheck').css('display','none');
			}
		});
		//给文本框添加光标移入事件、光标移出事件
		ld('#viewuser_locationdiv').unbind('focus').on('focus',function(){
			ld(this).val(trim(ld(this).val()));//去掉输入框中的多余空格
			if(ld(this).val() == searchmessage){//光标移入时文本框字样为：请输入要查找的用户
				ld(this).val('');//文本框置空
				ld(this).css('color','#000');//文字样式修改为黑色
			}
		});
		ld('#viewuser_locationdiv').unbind('blur').on('blur',function(){
			ld(this).val(trim(ld(this).val()));//去掉输入框中的多余空格
			if(empty(ld(this).val())){//光标移出文本框为也为空
				ld(this).val(searchmessage);//重新给文本框赋值为：请输入要查找的用户
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
					
					}
				});
			}else{
				ld('#'+divid+' .filetree span.user').each(function(){//循环所有file图标
					var parentfilter = ld(this).attr('parent');
					var parentarr = parentfilter.split('_');
					if('nogroup' == parentarr[1]){//隐藏无部门的用户
						ld(this).parent().css('display','none');
						ld(this).find('input[type=checkbox]').prop('checked',false);//取消选择
					}
				});
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
				ld(this).parent().after('<div id=\'viewuser_search\' style=\'padding-left:59px;display: block;position: absolute;\'><div class=\'view-search\' ></div></div>');
			}
			//3、获取用户结果集
			//获取所有用户信息，方便搜索显示用，不用每次都去页面获取数据
			if(empty(usersearch)){
				var search_name = '';var search_pinyin = '';var inuser = '';
				ld('#'+divid+' .filetree span').each(function(){//循环所有User用户
					search_name = ld(this).find('label').html();
					search_pinyin = makePy(search_name);
                    search_pinyin=search_pinyin.join("").toLowerCase();
					inuser = ld(this).attr('class');
					usersearch[search_name] = {'name':search_name,'pinyin':search_pinyin,
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
				ld('#'+divid+' .filetree span').each(function(){//循环所有User用户
					if(userid == ld(this).attr('record')){
						//有可能有checkbox、radio两种元素，所以用name获取
						ld(this).find('input[name=viewuser_input]').click();
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
       
		//8、选择部门后全选下级所有部门和用户
		ld('#'+divid+' .filetree li input[type=checkbox]').unbind('click').on('click',function(){
			//选中、取消选中一个用户后，相应将所有当前用户选中、取消,'user in-user':表示停用的用户
			if('user' == ld(this).parent().attr('class')||'user in-user'==ld(this).parent().attr('class') || (ld(this).parent().attr('class') == 'user in-nogroupuser' && obj.type == 'searchText')){
			
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
								ld(this).find('input[type=checkbox]').prop('checked',check);
								
							}
						});
					}
				});
			}
		});
		//9、选择用户
		ld('#'+divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
			var userobj = {};var userid = '',username = '',record = '';var recordarr = [];
			ld('#'+divid+' .filetree span').each(function(){//循环所有User用户
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
				if(empty(userobj)){
					var confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
					RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					return false;
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
				userarr['username'] = {'value':username};
			}
			var issave = false;
			if(!empty(saveback)) var issave = saveback(userarr);
			if(empty(issave)) ld('#'+divid+' .D_pbtn .D_pbtncancel').trigger('closediv');//关闭窗口
		});
        
		ld('#viewuser_locationdiv').focus();
		if(!empty(callback)) callback();//弹出层加载完成后，执行该方法
		ld('#titlename').html(titlename);//重新给弹出层的标题赋值
		DelProgressObjs();
	});
}
     

