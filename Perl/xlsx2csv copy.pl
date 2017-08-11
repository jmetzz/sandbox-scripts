perl -MSpreadsheet::XLSX -e '
    $\ = "\n"; $, = ";";
    my $workbook = Spreadsheet::XLSX->new()->parse($ARGV[0]);
    my $worksheet = ($workbook->worksheets())[0];
    my ($row_min, $row_max) = $worksheet->row_range();
    my ($col_min, $col_max) = $worksheet->col_range();
    for my $row ($row_min..$row_max) {
        print map {$worksheet->get_cell($row,$_)->value()} ($col_min..$col_max);
    }
' filename.xlsx >filename.csv
