/**
 * status page communication with uls
 * ONLY difference of this from pz2_status.js is url
 * Can it be made to inherit somehow? Or variable?
 * @author David Walker
 * @author Graham Seaman
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */
$(document).ready(function(){

    // end the search early if requested by user
    $("#terminator").click(function() {
        $.ajax(
        { 
            url: "uls/ajaxterminate",
            data: "session=" + $('#pz2session').data('value'),
            cache: false,
            datatype: "json"
        })
        return false;
    });

    var completed = $('#pz2session').data('completed');

    if (completed != 1)
    {
        var querystring = $('#pz2session').data('querystring');
        var session = $('#pz2session').data('value');
        querystring = querystring + '&session=' + session;

        var statusfetch = setInterval(function()
        {
            $.ajax(
            { 
                url: "uls/ajaxstatus",
                data: querystring,
                cache: false,
                datatype: "json",
                success: function(data)
                {
                    // turn off the timer if no longer needed
                    // and loop back to the same page to show the results
                    if (data['global']['finished'])
                    {
                        clearInterval(statusfetch);
                        var url = data['global']['reload_url'];
                        window.location = url;
                    }
                    // if we're still waiting, display the status details
                    // progress bar first
                    $('#progress').width(data['global']['progress']+'%');
                    for (var i = 0; i < data['status'].length; i++) 
                    {
                        var target = data['status'][i];
                        $('#status-'+target['name']+' > span').attr('class', target['class']);
                        $('#status-'+target['name']+' span.status-state').text(target['state']);
                        $('#status-'+target['name']+' span.status-hits').text(' / '+target['hits']);
                        $('#status-'+target['name']+' span.status-records').text(target['records']);
                        //$('#status').hide();
                    }
                }, 
                error: function(e, xhr)
                {
                    // no point in getting status if comms down (maybe because search completed)
                    clearInterval(statusfetch);
                 }
            }) 
        }, 1000); // 1 seconds default between status fetches
    } // end conditional timer
});  

