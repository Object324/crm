<?php

 $service_id=113382;
 if(file_exists(globalStatic::$root_directory."user_privileges/yingyanInfo.txt"))
 {
        $service_id=file_get_contents(globalStatic::$root_directory."user_privileges/yingyanInfo.txt");
 }
 else
 {
    file_put_contents(globalStatic::$root_directory."user_privileges/yingyanInfo.txt",$service_id);
 }
    echo json_encode(array('serviceid'=>$service_id,'ak'=>'6GGuFE5FBge1YoNpMqYD0ihpFSzFkuIi'));

?>