<?php
if(!empty($_REQUEST['address'])){
    $address = $_REQUEST['address'];
	$strlen=mb_strlen($address);
	if($strlen<1)
	{
		$poi_address=array();
		$jsonentity = Zend_Json::encode($poi_address);
		echo $jsonentity;exit();
	}
	crm_load_class_file('cls_Tencent_Map', 'include/utils');
	$cls_Tencent_Map = new cls_Tencent_Map();
	if(!empty($_REQUEST['getpoint_list']) && $_REQUEST['getpoint_list'] == 'yes'){
		$address_info = $cls_Tencent_Map->getAddress($address);
		foreach($address_info as $arr){
			$poi_address['entries'][] = array(
				'address' => $arr[1],
				'state' => $arr[5],
				'city' => $arr[6],	//城市
				'district' => $arr[7],	//区域
				'point' => $arr[2].','.$arr[3],
				'country' => '中国'
			);
		}
		$jsonentity = Zend_Json::encode($poi_address);
		echo $jsonentity;exit();
	}
	if((!empty($_REQUEST['getpoint']) && $_REQUEST['getpoint'] == 'yes')){
		
      
		if(!empty($address)){
			$point = $cls_Tencent_Map->getPoint($address);
			if(!empty($point)){
				$poi_address = array();
				if($_REQUEST['getpoint'] == 'yes'){
					$poi_address['entries']['lng'] = $point['lng'];
					$poi_address['entries']['lat'] = $point['lat'];
				}else{
					$poi_info = $cls_Tencent_Map->getPoi($point['lng'],$point['lat']);
					if(!empty($poi_info)){
						foreach($poi_info as $point => $info){
							if(!empty($info['address'])){
								$address = $info['address'];
							}
							if(!empty($info['ad_info']->province)){
								$province = $info['ad_info']->province;	//省份
							}
							if(!empty($info['ad_info']->city)){
								$city = $info['ad_info']->city;	//城市
							}
							if(!empty($info['ad_info']->district)){
								$district = $info['ad_info']->district;	//区域
							}
							if(!empty($info['country'])){
								$country = $info['country'];
							}
							$poi_address['entries'][] = array(
								'address' => $address,
								'state' => $province,
								'city' => $city,	//城市
								'district' => $district,	//区域
								'point' => $point,
								'country' => $country
							);
						}
					}	
				}
			}
			
		}
		$jsonentity = Zend_Json::encode($poi_address);
		echo $jsonentity;exit();
	}
}

?>