#!perl

use strict;
use warnings;

use Test::More;

use DateTime           qw( );
use DateTime::TimeZone qw( );
use DateTimeX::Start   qw( :ALL );


sub dt {
   return
      DateTime->new(
         year   => $_[0],
         month  => $_[1],
         day    => $_[2],
         hour   => $_[3] || 0,
         minute => $_[4] || 0,
         second => $_[5] || 0,
         time_zone => $_[6] || 'UTC',
      );
}


{
   my @tests = (
      [ 'An ordinary day',          '0.18', sub { start_of_date([ 2014,  2,  3 ], 'America/Toronto'  ) }, sub { dt(2014,  2,  3, 5, 0, 0)->set_time_zone('America/Toronto'  ) } ],
      [ 'A day without midnight',   '0.26', sub { start_of_date([ 2013, 10, 20 ], 'America/Sao_Paulo') }, sub { dt(2013, 10, 20, 3, 0, 0)->set_time_zone('America/Sao_Paulo') } ],
      [ 'A day with two midnights', '1.53', sub { start_of_date([ 2013, 11,  3 ], 'America/Havana'   ) }, sub { dt(2013, 11,  3, 4, 0, 0)->set_time_zone('America/Havana'   ) } ],
   );

   plan tests => 0+@tests;

   for my $test (@tests) {
      SKIP: {
         my ($name, $min_ver, $test_code, $expected_code) = @$test;

         skip("DateTime::TimeZone $min_ver required", 1)
            if $DateTime::TimeZone::VERSION < $min_ver;

         my $got_dt = eval { $test_code->() };
         if (!$got_dt) {
            my $e = $@;
            fail($name)
               or diag("Got exception executing test: $@");

            next;
         }

         my $expected_dt = eval { $expected_code->() };
         if (!$expected_dt) {
            my $e = $@;
            fail($name)
               or diag("Got exception determining expected value: $@");

            next;
         }

         my ($got, $expected) = map { join(' ', $_->epoch, $_->strftime('%Y-%m-%dT%H:%M:%S%z'), $_->time_zone->name) } $got_dt, $expected_dt;
         is($got, $expected, $name);
      }
   }
}
