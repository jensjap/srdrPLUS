(function() {
  var printPrintableArea;

  printPrintableArea = function() {
    var mywindow;
    mywindow = window.open('', 'PRINT', 'height=800,width=1200');
    mywindow.document.write('<html><head><title>' + document.title + '</title>');
    mywindow.document.write('<style></style>');
    $('style').each(function() {
      mywindow.document.write('<style media="all">');
      mywindow.document.write($(this).html());
      return mywindow.document.write('</style>');
    });
    $('link').each(function() {
      var href;
      href = $(this).attr("href");
      mywindow.document.write('<link rel="stylesheet" media="all" href="http://localhost:3000');
      mywindow.document.write(href);
      return mywindow.document.write('" >');
    });
    mywindow.document.write('</head><body >');
    mywindow.document.write('<h1>' + document.title + '</h1>');
    mywindow.document.write(document.getElementById('printableArea').innerHTML);
    mywindow.document.write('</body></html>');
    mywindow.document.close();
    mywindow.focus();
    mywindow.print();
    return true;
  };

  window.printPrintableArea = printPrintableArea;

}).call(this);
