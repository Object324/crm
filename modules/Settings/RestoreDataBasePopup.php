<?php
file_put_contents(globalStatic::$root_directory.'restoreline.txt',"0/0");
$str='<div>
        <table class="D_pop_bod" width="100%" cellspacing="1" cellpadding="2" border="0" align="center">
        <tbody>
            <tr>
                <td>
                    <div>
                        <div id="dv" style="float: left;">
                        </div>
                        <div style="float: right;">
                           
                        </div>
                    </div>
                    <div style="float:left;background-color:#FFFFFF;width:710px;height:20px;padding:1px;border:1px solid #ddd;border-radius: 5px;overflow:hidden;">
                        <div id="dvprogress" style="float:left;width:0;height:20px;background-color:#669966;overflow:hidden;">&nbsp;</div>
                    </div>
                    <div class="clear"></div>
                    <div style="margin-top:10px;" id="dvc"></div>
                </td>
            </tr>
        </tbody>
        </table></div>';
        

$_REQUEST['diony']='yes';

$arr['title']=getFixedLabel('RestoreDataBaseDemo');
$arr['content']=$str;

ConvertTojsonString(1,$arr,'success');


?>