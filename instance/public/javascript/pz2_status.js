/**
 * status page communication with pazpar2
 *
 * @author David Walker
 * @author Graham Seaman
 * @copyright 2011 California State University
 * @link http://xerxes.calstate.edu
 * @license http://www.gnu.org/licenses/
 * @version
 * @package Xerxes
 */
$(document).ready(function(){

    var completed = $('#pz2session').data('completed');

    if (completed != 1)
    {
        var querystring = $('#pz2session').data('querystring');

        var statusfetch = setInterval(function()
        {
            $.ajax(
            { 
                url: "pazpar2/ajaxstatus",
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
                        //alert(i + ' ' + target['name']);
                        //alert($('#status-'+target['name']+' > li > span .status-state').text());
                        $('#status-'+target['name']+' > li > span.status-state').text(target['state']);
                        $('#status-'+target['name']+' > li > span.status-hits').text(target['hits']);
                        $('#status-'+target['name']+' > li > span.status-records').text(target['records']);
                        $('#status-'+target['name']+' > li > span.status-diagnostic').text(target['diagnostic']);
                        //$('#status').hide();
                    }
                }, 
                error: function(e, xhr)
                {
                    // no point in getting status if comms down
                    alert("Debug: status incommunicado: "+e.responseText);
                    clearInterval(statusfetch);
                 }
            }) 
        }, 1000); // 1 seconds default between status fetches
    } // end conditional timer
});  
 
