<?php

class WorkReport
{
    function WorkReport()
    {
        
    }
    
    function createViewHtml($languagetype)
    {
        //全部、日志、周计划、月计划、我发出的、我回复的、@我的,抄送给我的
        $customViewhtml[]=array('title'=>'全部','viewname'=>'ALL');
        $customViewhtml[]=array('title'=>'日志','viewname'=>1);
        $customViewhtml[]=array('title'=>'周计划','viewname'=>2);
        $customViewhtml[]=array('title'=>'月计划','viewname'=>3);
        $customViewhtml[]=array('title'=>'我发出的','viewname'=>4);
        $customViewhtml[]=array('title'=>'我回复的','viewname'=>5);
        $customViewhtml[]=array('title'=>'@我的','viewname'=>6);
        $customViewhtml[]=array('title'=>'抄送给我的','viewname'=>7);
        return $customViewhtml;
    }
}

?>