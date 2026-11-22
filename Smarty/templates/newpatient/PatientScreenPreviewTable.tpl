{*<style>
    .expand {
        cursor: pointer;
    }
    /*.glyphicon-chevron-right:before {
        content: "+";
    }
    .glyphicon-chevron-down:before {
        content: "-";
    }*/
</style>*}

    {*<tbody>
    {foreach $regions as $region}
        <tr>
            <td><span class="expand"  onclick="expandRegion({$region.id})"><span class="glyphicon glyphicon-chevron-right"></span>{$region.name}</span></td>
            <td></td>
            <td></td>
            <td></td>
        </tr>
        {foreach $region.provinces as $province}
            <tr class="province_{$region.id}" style="display: none;">
                <td></td>
                <td><span class="expand"  onclick="expandProvince({$province.id})"><span class="glyphicon glyphicon-chevron-right"></span>{$province.name}</span></td>
                <td></td>
                <td></td>
            </tr>
            {foreach $province.cities as $city}
                <tr class="city_{$province.id}" style="display: none;">
                    <td></td>
                    <td></td>
                    <td><span class="expand"  onclick="expandCity({$city.id})"><span class="glyphicon glyphicon-chevron-right"></span>{$city.name}</span></td>
                    <td></td>
                </tr>
                {foreach $city.hospitals as $hospital}
                    <tr class="hospital_{$city.id}" style="display: none;">
                        <td></td>
                        <td></td>
                        <td></td>
                        <td><span class="glyphicon glyphicon-file"  onclick="selectHospital({$hospital.id})">{$hospital.name}</span></td>
                    </tr>
                {/foreach}
            {/foreach}
        {/foreach}
    {/foreach}
    </tbody>*}



    {foreach $regions as $region}
        <tr>
            <td><span class="expand"  onclick="expandRegion(this,{$region.id})"><span class="glyphicon glyphicon-chevron-right"></span>{$region.name}({$stats['region'][{$region.name}]})</span></td>
            <td></td>
            <td></td>
            <td></td>
        </tr>
        {foreach $region.provinces as $province}
            <tr class="province_{$region.id}" style="display: none;">
                <td></td>
                <td><span class="expand"  onclick="expandProvince(this,{$province.id})"><span class="glyphicon glyphicon-chevron-right"></span>{$province.name}({$stats['province'][{$province.name}]})</span></td>
                <td></td>
                <td></td>
            </tr>
            {foreach $province.cities as $city}
                <tr class="city_{$province.id} city_region_{$region.id}" style="display: none;">
                    <td></td>
                    <td></td>
                    <td><span class="expand"  onclick="expandCity(this,{$city.id})"><span class="glyphicon glyphicon-chevron-right"></span>{$city.name}({$stats['city'][{$city.name}]})</span></td>
                    <td></td>
                </tr>
                {foreach $city.hospitals as $hospital}
                    <tr class="hospital_{$city.id} hospital_region_{$region.id} hospital_province_{$province.id}" style="display: none;">
                        <td></td>
                        <td></td>
                        <td></td>
                        <td><span class="glyphicon glyphicon-file"  onclick="selectHospital({$hospital.id})">{$hospital.name}({$stats['hospital'][{$hospital.name}]})</span></td>
                    </tr>
                {/foreach}
            {/foreach}
        {/foreach}
    {/foreach}






