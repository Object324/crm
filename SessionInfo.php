<?php



function setSession($key,$value)
{
    
    global $redisobj;
   
    $keys=$key;
   
    if(!is_array($key))
    {
        $keys=array($key);
    }
     $onekey=$keys[0];
    
     if(sizeof($keys)==1)
     {
        $_SESSION[$onekey]=$value;
     }
     else if(sizeof($keys)==2)
     {
        $_SESSION[$onekey][$keys[1]]=$value;
     }
     else if(sizeof($keys)==3)
     {
        $_SESSION[$onekey][$keys[1]][$keys[2]]=$value;
     }
     else if(sizeof($keys)==4)
     {
        $_SESSION[$onekey][$keys[1]][$keys[2]][$keys[3]]=$value;
     }
    
}
function getSession($key)
{
    
    
    $keys=$key;
    if(!is_array($key))
    {
        $keys=array($key);
    }
     $onekey=$keys[0];
     if(sizeof($keys)==1)
     {
        return $_SESSION[$onekey];
     }
     else if(sizeof($keys)==2)
     {
       return  $_SESSION[$onekey][$keys[1]];
     }
     else if(sizeof($keys)==3)
     {
       return $_SESSION[$onekey][$keys[1]][$keys[2]];
     }
     else if(sizeof($keys)==4)
     {
        return $_SESSION[$onekey][$keys[1]][$keys[2]][$keys[3]];
     }
    
}
function issetSession($key)
{
  
    
    $keys=$key;
    if(!is_array($key))
    {
        $keys=array($key);
    }
     $onekey=$keys[0];
     if(sizeof($keys)==1)
     {
        return isset($_SESSION[$onekey]);
     }
     else if(sizeof($keys)==2)
     {
       return isset( $_SESSION[$onekey][$keys[1]]);
     }
     else if(sizeof($keys)==3)
     {
       return isset($_SESSION[$onekey][$keys[1]][$keys[2]]);
     }
     else if(sizeof($keys)==4)
     {
        return isset($_SESSION[$onekey][$keys[1]][$keys[2]][$keys[3]]);
     }
}

function unsetSession($key)
{
      global $global_crmredisobj;
    $global_crmredisobj=CRMRedis::getInstance();
    if($global_crmredisobj!='error')
    {
        $keys=$key;
        if(!is_array($key))
        {
            $keys=array($key);
        }
       
        return $global_crmredisobj->del(implode("_",$keys));
        
    }
    $keys=$key;
    if(!is_array($key))
    {
        $keys=array($key);
    }
     $onekey=$keys[0];
     if(sizeof($keys)==1)
     {
         unset($_SESSION[$onekey]);
     }
     else if(sizeof($keys)==2)
     {
        unset( $_SESSION[$onekey][$keys[1]]);
     }
     else if(sizeof($keys)==3)
     {
        unset($_SESSION[$onekey][$keys[1]][$keys[2]]);
     }
     else if(sizeof($keys)==4)
     {
         unset($_SESSION[$onekey][$keys[1]][$keys[2]][$keys[3]]);
     }
}
setSession('lingdang_version',$lingdang_current_version);
?>