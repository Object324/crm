<?php

$_REQUEST['diony']='yes';
$fp = fopen('lockdata.txt', 'w');
if(flock($fp, LOCK_EX))
{
    $content= file_get_contents(globalStatic::$root_directory.'restoreline.txt');

    $content_arr=explode("/",$content);
    $line=$content_arr[0];//
    $totalline=$content_arr[1];
    $progresswidth=710;
    
    
    $step=$progresswidth/$totalline;

    
    $dvwidth=$line*$step;
     if($dvwidth>$progresswidth)  
     {
        $dvwidth=$progresswidth;
     } 
    
    flock($fp, LOCK_UN);
    ConvertTojsonString(1,array("line"=>$line,'totalline'=>$totalline,'dvwidth'=>$dvwidth),'success');

}
fclose($fp);
?>