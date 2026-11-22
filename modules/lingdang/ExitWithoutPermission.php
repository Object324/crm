<?php

echo "  <div style='width: 30%;overflow: hidden;border-radius: 20px;box-shadow: 0px 2px 12px 3px rgb(0 0 0 / 20%);position: relative;top: 200px;left:34%;'>
            <div style='overflow: hidden;padding: 20px 50px;display: flex;'>
                <div style='float:left;width: 100px;'>
                    <img style='width: 100px;' src='". lingdang_imageurl('nopermission.jpg', $theme) ."' >
                </div>
                <div style='float: left;margin-left: 32px;line-height: 40px;'>
                    <div style='padding-top: 10px;color:#2d82f4;font-size: 18px;font-weight:bold;'>".getFixedLabel('WARMPROMPT')."</div>
                    <div style='line-height: 30px;'>".getFixedLabel('NOPERMITTEDEXECUTE')."</div>
                </div>
            </div>
        </div>
    ";
exit;



?>