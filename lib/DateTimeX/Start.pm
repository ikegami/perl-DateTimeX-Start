
package DateTimeX::Start;

use strict;
use warnings;

use version; our $VERSION = qv('v1.0.1');

use DateTime           qw( );
use DateTime::TimeZone qw( );
use Exporter           qw( import );
use Scalar::Util       qw( );


my @long  = qw( start_of_date start_of_month start_of_year start_of_today );
my @short = qw( date month year today );
our @EXPORT_OK = ( @long, @short );
our %EXPORT_TAGS = (
   'ALL'   => \@EXPORT_OK,
   'long'  => \@long,
   'short' => \@short,
);


sub _start_of_date {
   my ($trunc, $dt, $tz) = @_;

   if (Scalar::Util::blessed($dt)) {
      $tz ||= $dt->time_zone;
      $dt = $dt->clone->set_time_zone('floating')->truncate( to => $trunc )
         if $trunc;
   } else {
      $tz ||= 'local';
      $dt = DateTime->new( year => $dt->[0], month => $dt->[1] || 1, day => $dt->[2] || 1 );
   }

   $tz = DateTime::TimeZone->new( name => $tz )
      if !ref($tz);

   my $target_day = ( $dt->local_rd_values )[0];
   my $min_epoch = int($dt->epoch()/60) - 24*60;
   my $max_epoch = int($dt->epoch()/60) + 24*60;
   while ($max_epoch - $min_epoch > 1) {
      my $epoch = ( $min_epoch + $max_epoch ) >> 1;
      if (( DateTime->from_epoch( epoch => $epoch*60, time_zone => $tz )->local_rd_values )[0] < $target_day) {
         $min_epoch = $epoch;
      } else {
         $max_epoch = $epoch;
      }
   }

   return DateTime->from_epoch(epoch => $max_epoch*60, time_zone => $tz);
}

sub start_of_date  { _start_of_date(undef,   @_) }
sub start_of_month { _start_of_date('month', @_) }
sub start_of_year  { _start_of_date('year',  @_) }
sub start_of_today { _start_of_date(undef, DateTime->now( time_zone => $_[0] || 'local' )) }

{
   no warnings qw( once );
   *date  = \&start_of_date;
   *month = \&start_of_month;
   *year  = \&start_of_year;
   *today = \&start_of_today;
}


1;

__END__

=head1 NAME

DateTimeX::Start - Find the time at which a day starts.


=head1 VERSION

Version 1.0.1


=head1 SYNOPSIS

    use DateTimeX::Start qw( :ALL );

    my $dt = start_of_date([2013, 10, 20], 'America/Sao_Paulo');
    print("$dt\n");  # 2013-10-20T01:00:00
    $dt->subtract( seconds => 1 );
    print("$dt\n");  # 2013-10-19T23:59:59

    # These three are equivalent.
    my $dt = start_of_today();
    my $dt = start_of_today('local');
    my $dt = start_of_date( DateTime->now( time_zone => 'local' ) );

    # These three are equivalent.
    my $dt = start_of_date([2014, 1, 1], 'local');
    my $dt = start_of_date([2014, 1], 'local');
    my $dt = start_of_date([2014], 'local');

    my $dt = start_of_date(  DateTime->now( time_zone => 'local' ) );
    my $dt = start_of_month( DateTime->now( time_zone => 'local' ) );
    my $dt = start_of_year(  DateTime->now( time_zone => 'local' ) );


=head1 DESCRIPTION

In Sao Paulo, in the night of Oct 19th, 2013, the clocks went from 23:59:59 to 01:00:00.
That's just one example of the fact that not all days have a midnight hour.
This module provides a mean of determine when a particular day (or month or year) starts.


=head1 FUNCTIONS

=head2 start_of_date / date

    my $dt = start_of_date($date);
    my $dt = start_of_date($date, $tz_or_tz_name);
    my $dt = date($date);
    my $dt = date($date, $tz_or_tz_name);

Returns a DateTime object representing the earliest time of the specified date.

C<$date> must be one of the following:

=over 4

=item * A DateTime object (to find the first time of C<< $date->strftime('%Y-%m-%d') >>),

=item * A reference to an array containing a year, a month and a day (to find the first time of the specified date),

=item * A reference to an array containing a year and month (to find the first time of the specified month), or

=item * A reference to an array containing a year (to find the first time of the specified year).

=back

C<$tz_or_tz_name> must be either a time zone name supported by DateTime::TimeZone or a DateTime::TimeZone object.
It defaults to C<< $dt->time_zone >> if C<$date> is a DateTime object, and C<'local'> otherwise.


=head2 start_of_month / month

    my $dt = start_of_month($date);
    my $dt = start_of_month($date, $tz_or_tz_name);
    my $dt = month($date);
    my $dt = month($date, $tz_or_tz_name);

Returns a DateTime object representing the earliest time of the specified month.

C<$date> must be one of the following:

=over 4

=item * A DateTime object (to find the first time of the month given by C<< $date->strftime('%Y-%m') >>),

=item * A reference to an array containing a year and month (to find the first time of the specified month), or

=item * A reference to an array containing a year (to find the first time of the specified year)

=back

C<$tz_or_tz_name> must be either a time zone name supported by DateTime::TimeZone or a DateTime::TimeZone object.
It defaults to C<< $dt->time_zone >> if C<$date> is a DateTime object, and C<'local'> otherwise.


=head2 start_of_year / year

   my $dt = start_of_year($date);
   my $dt = start_of_year($date, $tz_or_tz_name);
   my $dt = year($date);
   my $dt = year($date, $tz_or_tz_name);

Returns a DateTime object representing the earliest time of the specified year.

C<$date> must be one of the following:

=over 4

=item * A DateTime object (to find the first time of the month given by C<< $date->year >>), or

=item * A reference to an array containing a year (to find the first time of the specified year)

=back

C<$tz_or_tz_name> must be either a time zone name supported by DateTime::TimeZone or a DateTime::TimeZone object.
It defaults to C<< $dt->time_zone >> if C<$date> is a DateTime object, and C<'local'> otherwise.


=head2 start_of_today

   my $dt = start_of_today();
   my $dt = start_of_today($tz_or_tz_name);
   my $dt = today();
   my $dt = today($tz_or_tz_name);

Returns a DateTime object representing the earliest time of the current day.

C<$tz_or_tz_name> must be either a time zone name supported by DateTime::TimeZone or a DateTime::TimeZone object.
It defaults to C<'local'>.


=head1 EXPORTS

Nothing is exported by default. The following are exported on demand:

=over 4

=item * C<start_of_date>

=item * C<start_of_month>

=item * C<start_of_year>

=item * C<start_of_today>

=item * C<date>

=item * C<month>

=item * C<year>

=item * C<today>

=item * C<:ALL>

For all of the above

=item * C<:long>

For C<start_of_date>, C<start_of_month>, C<start_of_year> and C<start_of_today>.

=item * C<:short>

For C<date>, C<month>, C<year> and C<today>.

=back


=head1 ASSUMPTIONS

The code makes the following assumptions about time zones:

=over 4

=item * There is no dt to which one can add time to obtain a dt with an earlier date.

=item * In no time zone does a date starts more than 24*60*60 seconds before the same date starts in UTC.

=item * In no time zone does a date starts more than 24*60*60 seconds after the same date starts in UTC.

=item * Jumps in time zones only occur on times with zero seconds. (Optimization)

=back


=head1 BUGS

Please report any bugs or feature requests to C<bug-DateTimeX-Start at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DateTimeX-Start>.
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DateTimeX::Start

You can also look for information at:

=over 4

=item * Search CPAN

L<http://search.cpan.org/dist/DateTimeX-Start>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=DateTimeX-Start>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DateTimeX-Start>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/DateTimeX-Start>

=back


=head1 AUTHOR

Eric Brine, C<< <ikegami@adaelis.com> >>


=head1 COPYRIGHT & LICENSE

No rights reserved.

The author has dedicated the work to the Commons by waiving all of his
or her rights to the work worldwide under copyright law and all related or
neighboring legal rights he or she had in the work, to the extent allowable by
law.

Works under CC0 do not require attribution. When citing the work, you should
not imply endorsement by the author.


=cut
