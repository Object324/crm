{*<style>
    /*.glyphicon-chevron-right:before {
        content: "+";
    }
    .glyphicon-chevron-down:before {
        content: "-";
    }*/
</style>*}


{*第三方主管146，分配坐席及重新分配坐席 的table*}

    {foreach $regions as $region}
        <tr>
            <td><span class="expand"  onclick="expandRegion(this,{$region.id})">{$region.name}({$stats['region'][{$region.name}]})</span></td>
            <td></td>
            <td></td>
            <td></td>
            <td>
                <select class="form-control" name="region_{$region.id}">
                    <option value=""></option>
                    {foreach item=last_name key=userid from=$assigned_person_arr}
                        <option value="{$userid}">{$last_name}</option>
                    {/foreach}
                </select>
            </td>
        </tr>
        {foreach $region.provinces as $province}
            <tr class="province_{$region.id}" style="display: none;">
                <td></td>
                <td><span class="expand"  onclick="expandProvince(this,{$province.id})">{$province.name}({$stats['province'][{$province.name}]})</span></td>
                <td></td>
                <td></td>
                <td>
                    <div>
                        <select class="form-control" name="region_{$region.id}_{$province.id}">
                            <option value=""></option>
                            {foreach item=last_name key=userid from=$assigned_person_arr}
                                <option value="{$userid}">{$last_name}</option>
                            {/foreach}
                        </select>
                    </div>
                </td>
            </tr>
            {foreach $province.cities as $city}
                <tr class="city_{$province.id} city_region_{$region.id}" style="display: none;">
                    <td></td>
                    <td></td>
                    <td><span class="expand"  onclick="expandCity(this,{$city.id})">{$city.name}({$stats['city'][{$city.name}]})</span></td>
                    <td></td>
                    <td>
                        <select class="form-control" name="region_{$region.id}_{$province.id}_{$city.id}">
                            <option value=""></option>
                            {foreach item=last_name key=userid from=$assigned_person_arr}
                                <option value="{$userid}">{$last_name}</option>
                            {/foreach}
                        </select>
                    </td>
                </tr>
                {foreach $city.hospitals as $hospital}
                    <tr class="hospital_{$city.id} hospital_region_{$region.id} hospital_province_{$province.id}" style="display: none;" hospital_id="{$hospital.hospital_id}">
                        <td></td>
                        <td></td>
                        <td></td>
                        <td><span onclick="selectHospital({$hospital.id})">{$hospital.name}({$stats['hospital'][{$hospital.name}]})</span></td>
                        <td>
                            <select class="form-control" name="region_{$region.id}_{$province.id}_{$city.id}_{$hospital.id}">
                                <option value=""></option>
                                {foreach item=last_name key=userid from=$assigned_person_arr}
                                    <option value="{$userid}">{$last_name}</option>
                                {/foreach}
                            </select>
                        </td>
                    </tr>
                {/foreach}
            {/foreach}
        {/foreach}
    {/foreach}






