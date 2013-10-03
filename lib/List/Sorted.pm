use strict;
use warnings;
use 5.10.0;

package List::Sorted;
# ABSTRACT: Class representing a list that is always sorted

=head1 SYNOPSIS

    my $l = new List::Sorted;
    $l->insert(2,1,3);
    say $l->[1]; # says 2

=head1 DESCRIPTION

This class represents a list that remains sorted.

=cut

use List::BinarySearch qw(0.14 binsearch_pos);

=head1 OVERLOADING

    # get a List::Sorted $l
    my @data = @$l; # @data is a regular (sorted) array

Objects can be dereferenced to obtain the underlying array. Note that this 
should not be used to modify the array, since the list must remain sorted.

=cut

use overload '@{}' => 'as_array';

=method new

    $l = new List::Sorted [ccmp => sub {...}];

Create a new object. If I<ccmp> is given, it should be a coderef that compares 
two elements in the list (as in the C<comparator> argument in 
L<List::BinarySearch>). If it is not given, it defaults to the class's L</ccmp> 
method (which can be overriden in derived classes).

=cut

sub new {
    my $class = shift;
    my %self = @_;
    $self{'_data'} = [];
    my $self = bless \%self => $class;
    $self->{'ccmp'} //= sub { $self->ccmp(@_) };
    $self->{'_cmp'} = sub { $self->{'ccmp'}($a,$b) };
    $self
}

sub as_array { $_[0]->{'_data'} }

sub ccmp { $_[1] <=> $_[2] }

sub find_pos {
    my ($self, $i) = @_;
    my $pos = &binsearch_pos($self->{'_cmp'}, $i, $self->{'_data'})
}

sub insert {
    my $self = shift;
    for my $i (@_) {
        my $pos = $self->find_pos($i);
        splice @{$self->{'_data'}}, $pos, 0, $i;
    }
    $self
}

sub store {
    eval { require YAML::Any };
    return $@ if $@;
    my ($self, $file, $ver) = @_;
    eval { YAML::Any::DumpFile($file, $ver, $self->{'_data'}) };
    $@
}

sub load {
    eval { require YAML::Any };
    return $@ if $@;
    my ($self, $file, $ver) = @_;
    my ($fver, $data) = eval { YAML::Any::LoadFile($file) };
    return $@ if $@;
    if ( $ver == $fver ) {
        $self->{'_data'} = $data;
        return ();
    } else {
        return 
          "Cache file '$file' has version $fver, but our data version is $ver";
    }
}

=head1 SEE ALSO

L<List::BinarySearch>

=cut

1;
