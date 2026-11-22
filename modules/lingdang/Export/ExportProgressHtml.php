<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
global $current_user;
$_SESSION[$currentModule][$current_user->id]['export']['starttime']=date("Y-m-d H:i:s");
@unlink(globalStatic::$root_directory.'storage/'.$current_user->id.'_'.$currentModule.'.csv');

$progresshtml='<div id="selectpopup_1">
                      
                      <table class="D_pop_bod" width="100%" cellspacing="1" cellpadding="2" border="0" align="center">
                        <tr>
                          <td style="padding: 10px;">
                            <div style="font-size: 16px;margin-bottom: 10px;color: #868686;text-align: center;" id="dvc" >'.getFixedLabel('EXPORTINGDATA').'</div>
                           
                            <div id="dv"></div>
                            <div class="progress" style="display:block">
                              <div id="dvExportprogress" class="bar">&nbsp;</div>
                            </div>
                             <div style="margin-top:10px;text-align:left" id="dvctimedescription" ></div>
                            <div class="clear"></div>        
                          </td>
                        </tr>    
                      </table>
                    </div>
                    <div style="height:20px"></div>';
  $_REQUEST['startexportindex']=0;
  $_REQUEST['endexportrow']=10;

?>