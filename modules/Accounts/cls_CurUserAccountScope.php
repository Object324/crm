<?php

class cls_CurUserAccountScope extends cls_CurUserDataScope
{
     protected  function  getcurwhere($record)
     {
       $sql= parent::getcurwhere($record);
      
       $status=getAccount_Set('status');
	   $where = '';
       if($status == 0 ){
			$wheathershow=1;
			$wheathershow=getAccount_Set('wheathershow'); 
			if($wheathershow == 1)
			{
				$where = ' and ld_account.publicaccount = 0';

			}else if($wheathershow == 2){
				$where = ' and ld_account.publicaccount > 1';
			}else if($wheathershow == 3){
				$where = ' and ld_account.publicaccount = 1';
			}
			if(!empty($where)){
				if($sql!='All')
					$sql.=$where;
				else
					$sql=$where;
			}
        }
        return $sql;
     }
}

?>