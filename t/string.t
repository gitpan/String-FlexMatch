#!/usr/bin/perl

use warnings;
use strict;

use YAML;
use Test::More tests => 19;

BEGIN { use_ok('String::FlexMatch') }

my $data = Load do { local $/; <DATA> };

my $msg = 'Error 1 at file /foo/bar/lib/Baz.pm line 73';
is($data->{pure_str}, $msg, 'a - pure string');
is($data->{flex_str}, $msg, 'a - flex string');
is($data->{flex_regex}, $msg, 'a - flex regex');
is($data->{flex_code}, $msg, 'a - flex code');
is($data->{ok_regex}, $msg, 'a - ok regex');
is($data->{ok_code}, $msg, 'a - ok code');

$msg = 'Error 2 at file /frob/nule/lib/Baz.pm line 61';
isnt($data->{pure_str}, $msg, 'b - pure string');
isnt($data->{flex_str}, $msg, 'b - flex string');
is($data->{flex_regex}, $msg, 'b - flex regex');
is($data->{flex_code}, $msg, 'b - flex code');
is($data->{ok_regex}, $msg, 'b - ok regex');
is($data->{ok_code}, $msg, 'b - ok code');

$msg = 'foobar';
isnt($data->{pure_str}, $msg, 'c - pure string');
isnt($data->{flex_str}, $msg, 'c - flex string');
isnt($data->{flex_regex}, $msg, 'c - flex regex');
isnt($data->{flex_code}, $msg, 'c - flex code');
is($data->{ok_regex}, $msg, 'c - ok regex');
is($data->{ok_code}, $msg, 'c - ok code');

__DATA__
pure_str: Error 1 at file /foo/bar/lib/Baz.pm line 73
flex_str: !perl/String::FlexMatch
  string: Error 1 at file /foo/bar/lib/Baz.pm line 73
flex_regex: !perl/String::FlexMatch
  regex: Error \d+ at file .*/lib/Baz.pm line \d+
flex_code: !perl/String::FlexMatch
  code: sub { $_[0] =~ m!Error \d+ at file .*/lib/Baz.pm line \d+! }
ok_regex: !perl/String::FlexMatch
  regex: '.'
ok_code: !perl/String::FlexMatch
  code: sub { 1 }
