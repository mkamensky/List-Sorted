#!perl -T

use Test::More tests => 7;
BEGIN {
    use_ok qw(List::Sorted);
}

my $l = new_ok 'List::Sorted';
is_deeply([@$l], [], 'List created empty');
$l->insert(2,1,3);
is_deeply([@$l], [1,2,3], 'Simple insert');

my $l1 = new_ok 'List::Sorted' => [ccmp => sub { $_[1] <=> $_[0] }];
$l1->insert(2,1,3);
is_deeply([@$l1], [3,2,1], 'descending');

package Foo;
push @ISA, 'List::Sorted';

sub ccmp { $_[1] cmp $_[2] }

package main;

my $l2 = new Foo;
$l2->insert(qw(b a c));
is_deeply([@$l2], [qw(a b c)], 'Derived class, string');



