package String::FlexMatch;

use strict;
use warnings;
use Carp;
use Class::MethodMaker
    new_hash_with_init => 'new';

our $VERSION = '0.05';

use overload
    '""' => \&as_string,
    'eq' => \&is_eq,
    'ne' => \&is_ne;

sub init {}   # so potential subclasses can override

sub string {
    my $self = shift;
    @_ ? $self->{string} = shift : $self->{string};
}

sub force_regex {
    return unless defined $_[1];
    ref $_[1] eq 'Regexp' ? $_[1] : qr/$_[1]/
}

sub regex {
    my $self = shift;
    @_ ? $self->{regex} = $self->force_regex(+shift)
       : $self->force_regex($self->{regex});
}

sub force_code {
    return unless defined $_[1];
    ref $_[1] eq 'CODE' ? $_[1] : eval $_[1]
}

sub code {
    my $self = shift;
    @_ ? $self->{code} = $self->force_code(+shift)
       : $self->force_code($self->{code});
}

sub as_string { $_[0]->choice_attr }

sub is_eq {
    my ($lhs, $rhs) = @_;
    my $lhs_val = ref $lhs eq 'String::FlexMatch' ? $lhs->choice_attr : "$lhs";
    my $rhs_val = ref $rhs eq 'String::FlexMatch' ? $rhs->choice_attr : "$rhs";
    my $key = sprintf "%s_%s", map { ref || 'STRING' } $lhs_val, $rhs_val;

    our $match ||= {
        STRING_STRING => sub { $_[0] eq $_[1] },
        STRING_Regexp => sub { $_[0] =~ $_[1] },
        STRING_CODE   => sub { $_[1]->($_[0]) },
        Regexp_STRING => sub { $_[1] =~ $_[0] },
        CODE_STRING   => sub { $_[0]->($_[1]) },
    };

    my $handler = $match->{$key};
    croak "can't compare a " . join(' to a ', split(/_/, $key)) . '.'
        unless defined $handler;
    $handler->($lhs_val, $rhs_val);

}

sub is_ne { !is_eq(@_) }

sub choice_attr {
    my $self = shift;
    defined $self->string ? $self->string :
    defined $self->regex  ? $self->regex  :
    defined $self->code   ? $self->code   :
    undef;
}

1;
__END__

=head1 NAME

String::FlexMatch - flexible ways to match a string

=head1 SYNOPSIS

  use String::FlexMatch;

  my $s = String::FlexMatch->new(string => 'foobar');
  if ($s eq 'foobar') {
    ...
  }

  my $s = String::FlexMatch->new(regex => 'Error .* at line \d+');
  if ($s eq 'Error "foo" at line 58') {
    ...
  }

  my $s = String::FlexMatch->new(code => 'sub { length $_[0] < 10 }');
  # or:
  # my $s = String::FlexMatch->new(code => sub { length $_[0] < 10 });

  if ($s ne 'somelongstring') {
    ...
  }

=head1 DESCRIPTION

Normally when trying to see whether two strings are equal, you use
the C<eq> operator. If you want to find out whether one string matches
another more flexibly, you'd use a regular expression. And sometimes
you have to call a subroutine with a string argument that will tell you
whether that argument is interesting, i.e. matches in a broader sense.

When running data-driven tests, you sometimes don't know per se which form
of matching (C<eq>, regex or code) you need. Take the following example:

  use Test::More;
  use String::FlexMatch;
  use YAML;
  
  sub frobnicate { $_[0] + $_[1] }
  
  my $tests = Load do { local $/; <DATA> };
  plan tests => scalar @$tests;
  
  for my $test (@$tests) {
    my $baz = frobnicate($test->{testarg}{foo}, $test->{testarg}{bar});
    is($baz, $test->{expect}{baz});
  }
  
  __DATA__
  -
    testarg:
      foo: 2
      bar: 3
    expect:
      baz: 5
  -
    testarg:
      foo: 21
      bar: 34
    expect:
      baz: !perl/String::FlexMatch
        regex: '\d+'

A setup like this was the reason for writing this class. If you find any
other uses for it, please let me know so this manpage can be expanded
with a few cookbook-style examples.

=head1 PROPERTIES

=over 4

=item C<string([STRING])>

Gets or sets the object's string value.

=item C<regex([REGEX|STRING])>

Gets or sets the object's regex value. If a string is given, it is
converted to a regex via C<qr()>. Since creating the object by reading a
YAML file won't go through this accessor, it's still possible that this
property holds a string value, which is why it is converted to a regex,
if necessary, when reading the property as well.

=item C<code([CODE|STRING])>

Gets or sets the object's coderef value, which should be an anonymous
subroutine. If a string is given, it is converted to a code via
C<eval()>. Since creating the object by reading a YAML file won't go
through this accessor, it's still possible that this property holds a
string value, which is why it is converted to a coderef, if necessary,
when reading the property as well.

=back

=head1 OVERLOADS

=over 4

=item C<"">

Stringification returns (in order of preference) the string property
of the object (if it is defined), or the stringified regex (if it is
defined) or the stringified coderef (if it is defined). Otherwise it
returns C<undef>.

=item C<eq>

Comparing a string to this object via the C<eq> operator returns a true
value if one of the following conditions holds (checked in the order
given here):

=over 4

=item *

If the object has a defined string property then it must be equal (using
C<eq>) to the string.

=item *

If the object has a defined regex property, then the string must match
the regex.

=item *

If the object has a defined code property, then the anonymous sub is
called with the string as an argument and whatever that returns is also
returned as the result of the C<eq> operation.

=back

Note that at least one of the two things compared must be a string. It
is not possible to compare two String::FlexMatch objects if neither of
them has a defined string property. After all, how should a regex be
compared to coderef, or two regexes, or two coderefs?

=item C<ne>

Comparing a string to this object via the C<ne> operator returns the
inverse of the comparison via the C<eq> operator.

=back

=head1 BUGS

=over 4

=item *

Because of a change in Test::More's C<_deep_check()> in the version
used by perl 5.8.1-RC4, this class doesn't work with that Test::More's
C<is_deeply()>, C<eq_hash()> and C<eq_array()>.

=back

If you find any other bugs or oddities, please do inform the author.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit <http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see <http://www.perl.com/CPAN/authors/id/M/MA/MARCEL/>.

=head1 VERSION

This document describes version 0.05 of C<String::FlexMatch>.

=head1 AUTHOR

Marcel GrE<uuml>nauer <marcel@cpan.org>

=head1 COPYRIGHT

Copyright 2003 Marcel GrE<uuml>nauer. All rights reserved.

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
