<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>
<!--中间-->
<div class="List3Box">
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
   
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
    <form action="index.php" method="post" onsubmit="puyoungJS_DialogBox.block();">
      <div class="DivCR">       
         <div class="ControlDiv1">
            <span class="Url fontbold">{'CONTROLPANEL'|@getFixedLabel} &gt; {'LBL_WECHATAPPLICATION'|@getFixedLabel}
                <font>（{'LBL_WECHATAPPLICATION_DESCRIPTION'|@getFixedLabel}）</font></span>
        </div>
        <div class="ControlDiv2">
        	<div class="F_r">
            <input class="editauto" title="{'LOGOUTS'|@getFixedLabel}" onclick="_wechatCacel(this)"  type="button" name="Edit" value="{'LBL_WECHATAPPLICATION'|@getFixedLabel}">
          </div>
	     </div>
        <div class="pad10" >
       
			<div class="TitleHeading">
         {'LBL_ENTERPRISEWECHAT'|@getFixedLabel}
      </div>
                <table  class=" singleList" width="100%"  border="0" cellspacing="0" cellpadding="5" style="color:#555;">
                  <tr>
                    <td width="20%" class="cellLabel"> {'wecharno'|@getFixedLabel} </td>
                    <td width="80%" class="borderBR">{$corp_name}</td>
                  </tr>
                  <tr >
                    <td class=" cellLabel"> {'authorizingperson'|@getFixedLabel} </td>
                    <td width="80%" class="borderBR">{$username}</td>
                  </tr>
                  <tr>
                    <td class=" cellLabel">{'authorizingdate'|@getFixedLabel} </td>
                    <td class=" borderBR">{$expired_time}</td>
                  </tr>
                  
                </table>
   			<table border=0 cellspacing=0 cellpadding=5 width=100% >
             <tr>
                  <td>
                  <div class="listRloesHelp" id="wechat_descritpion">
					{if $KEHU eq 'yes'}
						{'wechardescription'|@getFixedLabel}
					{else}
						{'wechardescription1'|@getFixedLabel}
					{/if}
                  </div>
                  </td>
                  <td style="display:none;">
                      <div class="qui_dialog_body ww_dialog_body" id="wechat_showTips">
                        <div class="msgDlg">
                            <div class="msgDlg_left">
                                <div class="ww_commonImg ww_commonImg_Alert msgDlg_left_icon"></div>
                            </div>
                            <div class="msgDlg_right">
                                <div class="msgDlg_right_text">{'wechardescription1'|@getFixedLabel}</div>
                            </div>
                            </div>
                        </div>
                  </td>                  
             </tr>
			</table>
                
        </div>         
      </div>
      </form>		
    </td>
  </tr>
</table>
</div>
<script language="JavaScript" type="text/javascript">
var is_kehu = '{$KEHU}';
{literal}
	function _wechatCacel(obj){
		var divobj = createElementDivs('wecharcacel');
		var wechat_descritpion = ld('#wechat_descritpion').html();
		ld(divobj).find('.D_pop_tit .D_ptita').html(obj.value);
		ld('#wecharcacelcontent').html(wechat_showTips);
		ld(divobj).css('max-height','500px');
        ld(divobj).css('width','450px');
        ld(divobj).css('background','#FDFDFD');
		ld('#wecharcacelcontent').css('max-height','400px');
		ld('#wecharcacelcontent').css('border','none');
		fnvshobj('', 'wecharcacel');
        ld(divobj).find('div.E_pbtn').addClass('ww_dialog_foot');
        
		ld(divobj).find('div.E_pbtn .E_pbtnok').unbind('click').on('click',function(){
			new Ajax.Request(
				'index.php',
				{queue: {position: 'end', scope: 'command'},
						method: 'post',
						postBody: 'module=Users&action=UsersAjax&file=eventToApiWX&method=uninstall_crm',
						onComplete: function(response) {
							var results = trim(response.responseText);
							if(results != ''){
								var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
								//成功
								if(restobj.code == 1){
									//kehu001
									if(is_kehu == 'yes'){
										
									}
								}
								fninvshnew('wecharcacel');puyoungJS_DialogBox.unblock();
								location.reload();
							}
						}
				}
			);
		});
	}
{/literal}
</script>
<!--中间 end-->