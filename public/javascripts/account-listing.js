$(document).ready(function() {

  /*  Ignore "the" at beginning of sortable columns             */
  /*  Based on: http://www.datatables.net/plug-ins/aaSorting    */
  jQuery.fn.dataTableExt.oSort['anti-the-asc']  = function(a,b) {
    var x = $(a).text().replace(/^[a,an,the] +/i, "");
    x = x.charAt(0).toUpperCase() + x.slice(1);
    var y = $(b).text().replace(/^[a,an,the] +/i, "");
    y = y.charAt(0).toUpperCase() + y.slice(1);
    return ((x < y) ? -1 : ((x > y) ? 1 : 0));
  };

  jQuery.fn.dataTableExt.oSort['anti-the-desc'] = function(a,b) {
    var x = $(a).text().replace(/^[a,an,the] +/i, "");
    x = x.charAt(0).toUpperCase() + x.slice(1);
    var y = $(b).text().replace(/^[a,an,the] +/i, "");
    y = y.charAt(0).toUpperCase() + y.slice(1);
    return ((x < y) ? 1 : ((x > y) ? -1 : 0));
  };

  /* Sort by item status if the column is present,  */
  /* otherwise sort by due date.                    */
  var sortOrder = $('.account-item-status-heading').length > 0 ? [[3, 'desc'], [4, 'asc']] : [[3, 'asc']];

  /* Initialize DataTable column sorting and callbacks */
  $('table.account-listing').dataTable({
    "aaSorting": sortOrder,
    "aoColumnDefs": [
    	{ "bSortable": false, "aTargets": [ 'account-number-heading', 'account-renew-heading', 'account-call-heading' ] }
    ],
  	"bAutoWidth": false,
  	"bInfo": false,
  	"bLengthChange": false,
  	"bPaginate": false,
  	"bFilter": false,
  	"fnDrawCallback": function ( oSettings ) {
  	  /* Maintain numerical order even after table changes */
			/* Need to redo the counters if filtered or sorted   */
			if ( oSettings.bSorted || oSettings.bFiltered )
			{
				for ( var i=0, iLen=oSettings.aiDisplay.length ; i<iLen ; i++ )
				{
					$('td:eq(0)', oSettings.aoData[ oSettings.aiDisplay[i] ].nTr ).html( i+1+'.' );
				}
			}
		}
  });
});
